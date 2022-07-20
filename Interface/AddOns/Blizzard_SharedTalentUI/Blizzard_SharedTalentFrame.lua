
local TalentFrameZoomSpeed = 0.05;
local AutoPanSpeed = 350;
local AutoPanEdgeSize = 40;
local AutoPanOverEdge = 10;
local AutoPanDelay = 0.35;


TalentFrameBaseButtonsParentMixin = {};

function TalentFrameBaseButtonsParentMixin:OnUpdate(dt)
	local currentEdgeTime = self.edgeTime;
	self.edgeTime = nil;

	local talentFrame = self:GetParent();
	local isPanning = self:IsPanning();
	if isPanning then
		if self:IsPanningMouseButtonDown() then
			local cursorX, cursorY = GetScaledCursorPosition();
			local deltaX = cursorX - self.panningPosX;
			local deltaY = cursorY - self.panningPosY;

			local zoomLevelFactor = (1 / talentFrame:GetZoomLevel());
			talentFrame:AdjustPanOffset(-deltaX * zoomLevelFactor, deltaY * zoomLevelFactor);
			self:MarkPanningPosition();
		else
			self:StopPanning();
		end
	elseif self:IsEdgePanningEnabled() and DoesAncestryInclude(talentFrame, GetMouseFocus()) then
		local cursorX, cursorY = GetScaledCursorPosition();
		local scale = self:GetScale();

		local horizontalMovement = 0;
		local leftOffset = cursorX - (self:GetLeft() * scale);
		if (leftOffset < AutoPanEdgeSize) and (leftOffset > -AutoPanOverEdge) then
			horizontalMovement = -AutoPanSpeed;
		else
			local rightOffset = (self:GetRight() * scale) - cursorX;
			if (rightOffset < AutoPanEdgeSize) and (rightOffset > -AutoPanOverEdge) then
				horizontalMovement = AutoPanSpeed;
			end
		end

		local verticalMovement = 0;
		local topOffset = (self:GetTop() * scale) - cursorY;
		if (topOffset < AutoPanEdgeSize) and (topOffset > -AutoPanOverEdge) then
			verticalMovement = -AutoPanSpeed;
		else
			local bottomOffset = cursorY - (self:GetBottom() * scale);
			if (bottomOffset < AutoPanEdgeSize) and (bottomOffset > -AutoPanOverEdge) then
				verticalMovement = AutoPanSpeed;
			end
		end

		if (horizontalMovement ~= 0) or (verticalMovement ~= 0) then
			self.edgeTime = (currentEdgeTime or 0) + dt;
			if self.edgeTime > AutoPanDelay then
				talentFrame:AdjustPanOffset(horizontalMovement * dt, verticalMovement * dt);
			end
		end
	end
end

function TalentFrameBaseButtonsParentMixin:OnMouseDown()
	self:StartPanning();
end

function TalentFrameBaseButtonsParentMixin:OnMouseWheel(value)
	local zoomAdjustment = (value < 0) and -TalentFrameZoomSpeed or TalentFrameZoomSpeed;
	self:GetParent():AdjustZoomLevel(zoomAdjustment);
end

function TalentFrameBaseButtonsParentMixin:IsPanningMouseButtonDown()
	return IsMouseButtonDown("LeftButton");
end

function TalentFrameBaseButtonsParentMixin:SetEdgePanningEnabled(edgePanningEnabled)
	self.edgePanningEnabled = edgePanningEnabled;
end

function TalentFrameBaseButtonsParentMixin:IsEdgePanningEnabled()
	return not not self.edgePanningEnabled;
end

function TalentFrameBaseButtonsParentMixin:StartPanning()
	self:MarkPanningPosition();
	self.isPanning = true;
end

function TalentFrameBaseButtonsParentMixin:StopPanning()
	self.isPanning = false;
end

function TalentFrameBaseButtonsParentMixin:IsPanning()
	return self.isPanning;
end

function TalentFrameBaseButtonsParentMixin:MarkPanningPosition()
	local cursorX, cursorY = GetScaledCursorPosition();
	self.panningPosX = cursorX;
	self.panningPosY = cursorY;
end


TalentFrameBaseMixin = CreateFromMixins(CallbackRegistryMixin);

local TalentFrameBaseEvents = {
	"TRAIT_NODE_CHANGED",
	"TRAIT_NODE_ENTRY_UPDATED",
	"TRAIT_TREE_CHANGED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

TalentFrameBaseMixin:GenerateCallbackEvents(
{
	"TalentButtonAcquired",
	"TalentButtonReleased",
});

function TalentFrameBaseMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:SetBasePanOffset(self.basePanOffsetX or 0, self.basePanOffsetY or 0);

	if not self.enableZoomAndPan then
		self:DisableZoomAndPan();
	end

	self:UpdatePadding();

	self.talentButtonCollection = CreateFramePoolCollection();
	self.talentDislayFramePool = CreateFramePoolCollection();
	self.edgePool = CreateFramePoolCollection();
	self.gatePool = CreateFramePool("FRAME", self.ButtonsParent, "TalentFrameGateTemplate");
	self.nodeIDToButton = {};
	self.buttonsWithDirtyEdges = {};
	self.treeInfoDirty = false;
	self.talentInfoCache = {};
	self.dirtyTalentIDSet = {};
	self.entryInfoCache = {};
	self.dirtyEntryIDSet = {};
	self.talentNodeInfoCache = {};
	self.dirtyTalentNodeIDSet = {};
	self.condInfoCache = {};
	self.dirtyCondIDSet = {};
	self.panOffsetX = 0;
	self.panOffsetY = 0;
end

function TalentFrameBaseMixin:RegisterOnUpdate()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function TalentFrameBaseMixin:OnUpdate()
	-- Clear this first so it can be re-registered if necessary.
	self:SetScript("OnUpdate", nil);

	if self:IsTreeDirty() then
		self:LoadTalentTree();
	else
		-- A node update will cause an entry update, etc, so only do the top level update and let it propagate.
		local buttonsToUpdateMethods = {};

		for condID, isDirty in pairs(self.dirtyCondIDSet) do
			self.condInfoCache[condID] = nil;
		end

		for talentID, isDirty in pairs(self.dirtyTalentIDSet) do
			self.talentInfoCache[talentID] = nil;
			for talentButton in self:EnumerateAllTalentButtons() do
				-- TODO:: This sets a dangerous precedent for a very expensive iteration.
				-- Consider replacing this with a pattern similar to nodeIDToButton or something else entirely.
				-- We may not need this at all. This will only happen in response to a hotfix in practice, so we
				-- could just reload the entire tree.
				if talentID == talentButton:GetTalentID() then
					buttonsToUpdateMethods[talentButton] = talentButton.UpdateTalentInfo;
				end
			end
		end

		for entryID, isDirty in pairs(self.dirtyEntryIDSet) do
			self.entryInfoCache[entryID] = nil;
			for talentButton in self:EnumerateAllTalentButtons() do
				-- TODO:: This sets a dangerous precedent for a very expensive iteration.
				-- Consider replacing this with a pattern similar to nodeIDToButton or something else entirely.
				-- We may not need this at all. This will only happen in response to a hotfix in practice, so we
				-- could just reload the entire tree.
				if entryID == talentButton:GetEntryID() then
					buttonsToUpdateMethods[talentButton] = talentButton.UpdateEntryInfo;
				end
			end
		end

		for talentNodeID, isDirty in pairs(self.dirtyTalentNodeIDSet) do
			self.talentNodeInfoCache[talentNodeID] = nil;
			local talentButton = self.nodeIDToButton[talentNodeID];
			if talentButton then
				buttonsToUpdateMethods[talentButton] = talentButton.UpdateTalentNodeInfo;
			end
		end

		self.dirtyCondIDSet = {};
		self.dirtyTalentIDSet = {};
		self.dirtyEntryIDSet = {};
		self.dirtyTalentNodeIDSet = {};

		if self.treeInfoDirty then
			self.treeInfoDirty = false;
			self:UpdateTreeInfo();
		end

		for button, updateMethod in pairs(buttonsToUpdateMethods) do
			updateMethod(button);
		end

		for button, isDirty in pairs(self.buttonsWithDirtyEdges) do
			self:UpdateEdgesForButton(button);
		end
	end
end

function TalentFrameBaseMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TalentFrameBaseEvents);

	if self:IsTreeDirty() then
		self:LoadTalentTree();
	elseif self:GetTalentTreeID() then
		-- Currency info may have been changed since the frame was last opened.
		self:UpdateTreeCurrencyInfo();
	end
end

function TalentFrameBaseMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TalentFrameBaseEvents);

	self:ClearInfoCaches();
end

function TalentFrameBaseMixin:OnEvent(event, ...)
	if event == "TRAIT_NODE_CHANGED" then
		local nodeID = ...;
		self:MarkTalentNodeInfoCacheDirty(nodeID);
	elseif event == "TRAIT_NODE_ENTRY_UPDATED" then
		local entryID = ...;
		self:MarkEntryInfoCacheDirty(entryID);
	elseif event == "TRAIT_TREE_CHANGED" then
		local treeID = ...;
		if treeID == self:GetTalentTreeID() then
			self:MarkTreeDirty();
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...;
		if treeID == self:GetTalentTreeID() then
			self:UpdateTreeCurrencyInfo();
		end
	end
end

function TalentFrameBaseMixin:UpdatePadding()
	local zoomLevelFactor = (1 / self:GetZoomLevel());
	local left = self.leftPadding * zoomLevelFactor;
	local top = -self.topPadding * zoomLevelFactor;
	local right = -self.rightPadding * zoomLevelFactor;
	local bottom = self.bottomPadding * zoomLevelFactor;
	self.ButtonsParent:SetPoint("TOPLEFT", left, top);
	self.ButtonsParent:SetPoint("BOTTOMRIGHT", right, bottom);
end

function TalentFrameBaseMixin:IsPanning()
	return self.ButtonsParent:IsPanning();
end

function TalentFrameBaseMixin:SetEdgePanningEnabled(edgePanningEnabled)
	self.ButtonsParent:SetEdgePanningEnabled(edgePanningEnabled);
end

function TalentFrameBaseMixin:IsEdgePanningEnabled()
	return self.ButtonsParent:IsEdgePanningEnabled();
end

function TalentFrameBaseMixin:AdjustZoomLevel(adjustment)
	local zoomLevel = self:GetZoomLevel() + adjustment;
	self:SetZoomLevel(zoomLevel);
end

function TalentFrameBaseMixin:SetZoomLevel(zoomLevel)
	local treeInfo = self:GetTreeInfo();
	zoomLevel = Clamp(zoomLevel, treeInfo.minZoom, treeInfo.maxZoom);
	self:SetZoomLevelInternal(zoomLevel);
end

function TalentFrameBaseMixin:SetZoomLevelInternal(zoomLevel)
	local oldPanWidth, oldPanHeight = self:GetPanExtents();

	self.ButtonsParent:SetScale(zoomLevel);

	local newPanWidth, newPanHeight = self:GetPanExtents();
	local panWidthDelta = newPanWidth - oldPanWidth;
	local panHeightDelta = newPanHeight - oldPanHeight;

	local frameWidth, frameHeight = self:GetPanViewSize();
	local left, top = self:GetPanViewCornerPosition();
	local cursorX, cursorY = GetScaledCursorPosition();
	local relativeCursorX = (cursorX - left);
	local relativeCursorY = (top - cursorY);
	local normalizedCursorX = (relativeCursorX / frameWidth);
	local normalizedCursorY = (relativeCursorY / frameHeight);

	self:AdjustPanOffset(panWidthDelta * normalizedCursorX, panHeightDelta * normalizedCursorY);

	self:UpdatePadding();
end

function TalentFrameBaseMixin:GetZoomLevel()
	return self.ButtonsParent:GetScale();
end

function TalentFrameBaseMixin:AdjustPanOffset(deltaX, deltaY)
	self:SetPanOffset(self.panOffsetX + deltaX, self.panOffsetY + deltaY);
end

function TalentFrameBaseMixin:SetPanOffset(x, y)
	local panWidth, panHeight = self:GetPanExtents();
	x = Clamp(x, 0, panWidth);
	y = Clamp(y, 0, panHeight);

	self.panOffsetX = x;
	self.panOffsetY = y;

	self:UpdateAllTalentButtonPositions();
	self:UpdateAllGatePositions();
end

function TalentFrameBaseMixin:UpdateAllTalentButtonPositions()
	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeInfo = talentButton:GetTalentNodeInfo();
		TalentButtonUtil.ApplyPosition(talentButton, self, nodeInfo.posX, nodeInfo.posY);
	end
end

function TalentFrameBaseMixin:UpdateAllGatePositions()
	for gate in self.gatePool:EnumerateActive() do
		self:AnchorGate(gate, gate:GetAnchorButton());
	end
end

function TalentFrameBaseMixin:SetBasePanOffset(basePanOffsetX, basePanOffsetY)
	self.basePanOffsetX = basePanOffsetX;
	self.basePanOffsetY = basePanOffsetY;
end

function TalentFrameBaseMixin:GetPanOffset()
	return self.basePanOffsetX + self.panOffsetX, self.basePanOffsetY + self.panOffsetY;
end

function TalentFrameBaseMixin:GetPanViewSize()
	local frameWidth, frameHeight = self.ButtonsParent:GetSize();
	local scale = self.ButtonsParent:GetScale();
	return frameWidth * scale, frameHeight * scale;
end

function TalentFrameBaseMixin:GetPanViewCornerPosition()
	local left = self.ButtonsParent:GetLeft();
	local top = self.ButtonsParent:GetTop();
	local scale = self.ButtonsParent:GetScale();
	return left * scale, top * scale;
end

function TalentFrameBaseMixin:GetPanExtents()
	local treeInfo = self:GetTreeInfo();
	local zoomLevel = self:GetZoomLevel();
	local zoomLevelFactor = (1 / zoomLevel);

	local basePanWidth, basePanHeight = self:GetPanViewSize();
	local maxZoomFactor = (1 / treeInfo.minZoom);
	local rawPanWidth = (basePanWidth * maxZoomFactor);
	local rawPanHeight = (basePanHeight * maxZoomFactor);

	local treePanWidth = (treeInfo.panWidth or 0);
	local treePanHeight = (treeInfo.panHeight or 0);

	local maxTreeWidth = math.max(rawPanWidth, treePanWidth);
	local maxTreeHeight = math.max(rawPanHeight, treePanHeight);

	local panWidth = maxTreeWidth - (basePanWidth * zoomLevelFactor);
	local panHeight = maxTreeHeight - (basePanHeight * zoomLevelFactor);
	return Clamp(panWidth, 0, math.huge), Clamp(panHeight, 0, math.huge);
end

function TalentFrameBaseMixin:TalentButtonCollectionReset(framePool, talentButton)
	local function TalentFrameBaseIsEdgeConnectedToTalentButton(edgeFrame)
		return (edgeFrame:GetEndButton() == talentButton) or (edgeFrame:GetStartButton() == talentButton);
	end

	self:ReleaseEdgesByCondition(TalentFrameBaseIsEdgeConnectedToTalentButton);

	local nodeID = talentButton:GetTalentNodeID();
	if self.nodeIDToButton[nodeID] == talentButton then
		self.nodeIDToButton[nodeID] = nil;
	end

	talentButton:OnRelease();

	self.buttonsWithDirtyEdges[talentButton] = nil;

	FramePool_HideAndClearAnchors(framePool, talentButton);
end

function TalentFrameBaseMixin:GetTalentButtonByNodeID(nodeID)
	return self.nodeIDToButton[nodeID];
end

function TalentFrameBaseMixin:AcquireTalentButton(nodeInfo, talentType, offsetX, offsetY, initFunction)
	offsetX = (offsetX or 0);
	offsetY = (offsetY or 0);

	local templateType = self.getTemplateType(nodeInfo, talentType);
	if templateType == nil then
		return nil;
	end

	local specializedMixin = self.getSpecializedMixin(nodeInfo, talentType) or TalentButtonBaseMixin;
	local forbidden = nil;
	local pool, isNewPool = self.talentButtonCollection:GetOrCreatePool("BUTTON", self.ButtonsParent, templateType, GenerateClosure(self.TalentButtonCollectionReset, self), forbidden, specializedMixin);

	if isNewPool then
		pool:SetResetDisallowedIfNew(true);
	end

	local newTalentButton, isNewButton = pool:Acquire(templateType);
	local buttonSize = self:GetButtonSize();
	newTalentButton:SetAndApplySize(buttonSize, buttonSize);
	newTalentButton:SetPoint("CENTER", self.ButtonsParent, "TOPLEFT", offsetX, offsetY);

	if isNewButton then
		newTalentButton:Init(self);
	end

	-- For setup that must be done before the event trigger below.
	if initFunction ~= nil then
		initFunction(newTalentButton);
	end

	self:MarkEdgesDirty(newTalentButton);

	self:TriggerEvent(TalentFrameBaseMixin.Event.TalentButtonAcquired, newTalentButton);
	return newTalentButton;
end

function TalentFrameBaseMixin:AcquireTalentDisplayFrame(talentType, specializedMixin)
	specializedMixin = specializedMixin or nil;

	local nodeInfo = nil;
	local templateType = self.getTemplateType(nodeInfo, talentType);
	local resetterFunction = nil;
	local forbidden = false;
	local pool = self.talentDislayFramePool:GetOrCreatePool("BUTTON", self, templateType, resetterFunction, forbidden, specializedMixin);
	return pool:Acquire();
end

function TalentFrameBaseMixin:ReleaseTalentDisplayFrame(displayFrame)
	self.talentDislayFramePool:Release(displayFrame);
end

function TalentFrameBaseMixin:AreSelectionsOpen(button)
	return self.SelectionChoiceFrame:IsShown() and (self.SelectionChoiceFrame:GetBaseButton() == button);
end

function TalentFrameBaseMixin:ToggleSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost)
	if self:AreSelectionsOpen(button) then
		self:HideSelections();
	else
		self:ShowSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost);
	end
end

function TalentFrameBaseMixin:ShowSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost)
	self.SelectionChoiceFrame:SetPoint("BOTTOM", button, "TOP", 0, 0);
	self.SelectionChoiceFrame:SetSelectionOptions(button, selectionOptions, canSelectChoice, currentSelection, baseCost);
	self.SelectionChoiceFrame:Show();
end

function TalentFrameBaseMixin:UpdateSelections(button, canSelectChoice, currentSelection, baseCost)
	if self:AreSelectionsOpen(button) then
		self.SelectionChoiceFrame:UpdateSelectionOptions(canSelectChoice, currentSelection, baseCost);
	end
end

function TalentFrameBaseMixin:HideSelections(button)
	if self:AreSelectionsOpen(button) then
		self.SelectionChoiceFrame:Hide();
	end
end

function TalentFrameBaseMixin:IsMouseOverSelections()
	return DoesAncestryInclude(self.SelectionChoiceFrame, GetMouseFocus());
end

function TalentFrameBaseMixin:MarkEdgesDirty(button)
	self.buttonsWithDirtyEdges[button] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:ShouldButtonShowEdges(button)
	return button:ShouldBeVisible();
end

function TalentFrameBaseMixin:UpdateEdgesForButton(button)
	local function TalentFrameBaseIsEdgeFromTalentButton(edgeFrame)
		return (edgeFrame:GetStartButton() == button);
	end

	self:ReleaseEdgesByCondition(TalentFrameBaseIsEdgeFromTalentButton);

	local function TalentFrameBaseIsEdgeToTalentButton(edgeFrame)
		return (edgeFrame:GetEndButton() == button);
	end

	self:UpdateEdgesByCondition(TalentFrameBaseIsEdgeToTalentButton);

	if self:ShouldButtonShowEdges(button) then
		local talentNodeInfo = button:GetTalentNodeInfo();
		if talentNodeInfo then
			for i, edgeVisualInfo in ipairs(talentNodeInfo.visibleEdges) do
				local targetButton = self:GetTalentButtonByNodeID(edgeVisualInfo.targetNode);
				if targetButton and self:ShouldButtonShowEdges(targetButton) then
					self:AcquireEdge(button, targetButton, edgeVisualInfo);
				end
			end
		end
	end

	self.buttonsWithDirtyEdges[button] = nil;
end

function TalentFrameBaseMixin:ReleaseEdgesByCondition(condition)
	local edgesToRelease = {};
	for edgeFrame in self.edgePool:EnumerateActive() do
		if condition(edgeFrame) then
			table.insert(edgesToRelease, edgeFrame);
		end
	end

	for i, edgeToRelease in ipairs(edgesToRelease) do
		self:ReleaseEdge(edgeToRelease);
	end
end

function TalentFrameBaseMixin:UpdateEdgesByCondition(condition)
	for edgeFrame in self.edgePool:EnumerateActive() do
		if condition(edgeFrame) then
			edgeFrame:UpdateState();
		end
	end
end

function TalentFrameBaseMixin:SetElementFrameLevel(element, frameLevel)
	-- Hack to get around the problem that clickable frames will be raised when clicked and adjust frame levels automatically.
	element:SetFixedFrameLevel(false);
	element:SetFrameLevel(frameLevel);
	element:SetFixedFrameLevel(true);
end

function TalentFrameBaseMixin:GetFrameLevelForEdge(startButton, unused_endButton)
	-- By default, layer edges under buttons. Override in your derived Mixin as desired.
	return startButton:GetFrameLevel() - 1;
end

function TalentFrameBaseMixin:AcquireEdge(startButton, endButton, edgeInfo)
	local templateType = self.getEdgeTemplateType(edgeInfo.visualStyle);
	local pool = self.edgePool:GetOrCreatePool("FRAME", self.ButtonsParent, templateType);
	local newEdge = pool:Acquire();
	newEdge:Init(startButton, endButton, edgeInfo);
	self:SetElementFrameLevel(newEdge, self:GetFrameLevelForEdge(startButton, endButton));
	newEdge:Show();
	return newEdge;
end

function TalentFrameBaseMixin:ReleaseEdge(edgeFrame)
	self.edgePool:Release(edgeFrame);
end

function TalentFrameBaseMixin:ShouldInstantiateInvisibleButtons()
	-- Override in your derived Mixin as desired.
	return false;
end

function TalentFrameBaseMixin:GetFrameLevelForButton(unused_nodeInfo)
	-- By default, draw over edges. Override in your derived Mixin as desired.
	return 100;
end

function TalentFrameBaseMixin:InstantiateTalentButton(nodeID, nodeInfo)
	nodeInfo = nodeInfo or self:GetAndCacheTalentNodeInfo(nodeID);

	if not nodeInfo.isVisible and not self:ShouldInstantiateInvisibleButtons() then
		return nil;
	end

	local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
	local entryInfo = (activeEntryID ~= nil) and self:GetAndCacheEntryInfo(activeEntryID) or nil;
	local talentType = (entryInfo ~= nil) and entryInfo.type or nil;
	local function InitTalentButton(newTalentButton)
		newTalentButton:SetTalentNodeID(nodeID);
	end

	local offsetX = nil;
	local offsetY = nil;
	local newTalentButton = self:AcquireTalentButton(nodeInfo, talentType, offsetX, offsetY, InitTalentButton);

	if newTalentButton then
		TalentButtonUtil.ApplyPosition(newTalentButton, self, nodeInfo.posX, nodeInfo.posY);

		local frameLevel = newTalentButton:GetParent():GetFrameLevel() + self:GetFrameLevelForButton(nodeInfo);
		self:SetElementFrameLevel(newTalentButton, frameLevel);
		newTalentButton:Show();
	end

	return newTalentButton;
end

function TalentFrameBaseMixin:ReleaseTalentButton(talentButton, forReinstantiation)
	self:TriggerEvent(TalentFrameBaseMixin.Event.TalentButtonReleased, talentButton, forReinstantiation);
	self.talentButtonCollection:Release(talentButton);
end

function TalentFrameBaseMixin:ReleaseAndReinstantiateTalentButtonByID(nodeID)
	return self:ReleaseAndReinstantiateTalentButton(self:GetTalentButtonByNodeID(nodeID));
end

function TalentFrameBaseMixin:ReleaseAndReinstantiateTalentButton(talentButton)
	local talentNodeID = talentButton:GetTalentNodeID();
	local entryID = talentButton:GetEntryID();

	local forReinstantiation = true;
	self:ReleaseTalentButton(talentButton, forReinstantiation);
	self:ForceEntryInfoCacheUpdate(entryID);
	self:ForceTalentNodeInfoUpdate(talentNodeID);

	local newTalentButton = self:InstantiateTalentButton(talentNodeID);
	return newTalentButton;
end

function TalentFrameBaseMixin:ReleaseAllTalentButtons()
	for talentButton in self:EnumerateAllTalentButtons() do
		self:TriggerEvent(TalentFrameBaseMixin.Event.TalentButtonReleased, talentButton);
	end

	self.edgePool:ReleaseAll();
	self.talentButtonCollection:ReleaseAll();
	self.buttonsWithDirtyEdges = {};
end

function TalentFrameBaseMixin:EnumerateAllTalentButtons()
	return self.talentButtonCollection:EnumerateActive();
end

function TalentFrameBaseMixin:UpdateAllButtons()
	for talentButton in self:EnumerateAllTalentButtons() do
		talentButton:FullUpdate();
	end
end

function TalentFrameBaseMixin:OnButtonNodeIDSet(talentButton, oldNodeID, newNodeID)
	if oldNodeID ~= nil then
		if self.nodeIDToButton[oldNodeID] == talentButton then
			self.nodeIDToButton[oldNodeID] = nil;
		end
	end

	if newNodeID ~= nil then
		self.nodeIDToButton[newNodeID] = talentButton;
	end
end

function TalentFrameBaseMixin:OnNodeInfoUpdated(nodeID)
	local talentButton = self.nodeIDToButton[nodeID];
	if talentButton == nil then
		return;
	end

	talentButton:UpdateTalentNodeInfo();
end

function TalentFrameBaseMixin:OnTalentInfoUpdated(talentID)
	for talentButton in self:EnumerateAllTalentButtons() do
		if talentID == talentButton:GetTalentID() then
			talentButton:UpdateTalentInfo();
		end
	end
end

function TalentFrameBaseMixin:MarkTreeInfoDirty()
	self.treeInfoDirty = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:ForceEntryInfoCacheUpdate(entryID)
	if not self:IsEntryInfoCacheDirty(entryID) then
		return;
	end

	self.dirtyEntryIDSet[entryID] = nil;
	self.entryInfoCache[entryID] = nil;
end

function TalentFrameBaseMixin:ForceTalentNodeInfoUpdate(talentNodeID)
	if not self:IsTalentNodeInfoCacheDirty(talentNodeID) then
		return;
	end

	self.dirtyTalentNodeIDSet[talentNodeID] = nil;
	self.talentNodeInfoCache[talentNodeID] = nil;
	self:OnNodeInfoUpdated(talentNodeID);
end

function TalentFrameBaseMixin:ForceCondInfoUpdate(condID)
	if not self:IsCondInfoCacheDirty(condID) then
		return;
	end

	self.dirtyCondIDSet[condID] = nil;
	self.condInfoCache[condID] = nil;
end

function TalentFrameBaseMixin:GetAndCacheTalentNodeInfo(talentNodeID)
	local function GetTalentNodeInfoCallback()
		self.dirtyTalentNodeIDSet[talentNodeID] = nil;
		return C_Traits.GetNodeInfo(self:GetConfigID(), talentNodeID);
	end

	return GetOrCreateTableEntryByCallback(self.talentNodeInfoCache, talentNodeID, GetTalentNodeInfoCallback);
end

function TalentFrameBaseMixin:ForceTalentInfoUpdate(talentID)
	if not self:IsTalentInfoCacheDirty(talentID) then
		return;
	end

	self.dirtyTalentIDSet[talentID] = nil;
	self.talentInfoCache[talentID] = nil;
	self:OnTalentInfoUpdated(talentID);
end

function TalentFrameBaseMixin:GetAndCacheTalentInfo(talentID)
	local function GetTalentInfoCallback()
		self.dirtyTalentIDSet[talentID] = nil;
		return C_Traits.GetDefinitionInfo(talentID);
	end

	return GetOrCreateTableEntryByCallback(self.talentInfoCache, talentID, GetTalentInfoCallback);
end

function TalentFrameBaseMixin:GetAndCacheEntryInfo(entryID)
	local function GetEntryInfoCallback()
		self.dirtyEntryIDSet[entryID] = nil;
		return C_Traits.GetEntryInfo(self:GetConfigID(), entryID);
	end

	return GetOrCreateTableEntryByCallback(self.entryInfoCache, entryID, GetEntryInfoCallback);
end

function TalentFrameBaseMixin:GetAndCacheCondInfo(condID)
	local function GetCondInfoCallback()
		self.dirtyCondIDSet[condID] = nil;
		return C_Traits.GetConditionInfo(self:GetConfigID(), condID);
	end

	return GetOrCreateTableEntryByCallback(self.condInfoCache, condID, GetCondInfoCallback);
end

function TalentFrameBaseMixin:MarkTalentInfoCacheDirty(talentID)
	self.dirtyTalentIDSet[talentID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkEntryInfoCacheDirty(entryID)
	self.dirtyEntryIDSet[entryID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkTalentNodeInfoCacheDirty(talentNodeID)
	self.dirtyTalentNodeIDSet[talentNodeID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkCondInfoCacheDirty(condID)
	self.dirtyCondIDSet[condID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:IsTalentInfoCacheDirty(talentID)
	return self.dirtyTalentIDSet[talentID] and (self.talentInfoCache[talentID] ~= nil);
end

function TalentFrameBaseMixin:IsEntryInfoCacheDirty(entryID)
	return self.dirtyEntryIDSet[entryID] and (self.entryInfoCache[entryID] ~= nil);
end

function TalentFrameBaseMixin:IsTalentNodeInfoCacheDirty(talentNodeID)
	return self.dirtyTalentNodeIDSet[talentNodeID] and (self.talentNodeInfoCache[talentNodeID] ~= nil);
end

function TalentFrameBaseMixin:IsCondInfoCacheDirty(condID)
	return self.dirtyCondIDSet[condID] and (self.condInfoCache[condID] ~= nil);
end

function TalentFrameBaseMixin:ClearInfoCaches()
	self.talentInfoCache = {};
	self.dirtyTalentIDSet = {};
	self.entryInfoCache = {};
	self.dirtyEntryIDSet = {};
	self.talentNodeInfoCache = {};
	self.dirtyTalentNodeIDSet = {};
	self.condInfoCache = {};
	self.dirtyCondIDSet = {};
end

function TalentFrameBaseMixin:SetConfigID(configID)
	self.configID = configID;
end

function TalentFrameBaseMixin:GetConfigID()
	return self.configID;
end

function TalentFrameBaseMixin:SetTalentTreeID(talentTreeID, forceUpdate)
	if not forceUpdate and (talentTreeID == self:GetTalentTreeID()) then
		return false;
	end

	self.talentTreeID = talentTreeID;
	self:LoadTalentTree();
	return true;
end

function TalentFrameBaseMixin:GetTalentTreeID()
	return self.talentTreeID;
end

function TalentFrameBaseMixin:UpdateTreeInfo(skipButtonUpdates)
	self.talentTreeInfo = C_Traits.GetTreeInfo(self:GetConfigID(), self:GetTalentTreeID());
	self:UpdateTreeCurrencyInfo(skipButtonUpdates);

	if not skipButtonUpdates then
		self:RefreshGates();
	end
end

function TalentFrameBaseMixin:UpdateTreeCurrencyInfo(skipButtonUpdates)
	self.treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(self:GetConfigID(), self:GetTalentTreeID(), self.excludeStagedChangesForCurrencies);

	self.treeCurrencyInfoMap = {};
	for i, treeCurrency in ipairs(self.treeCurrencyInfo) do
		self.treeCurrencyInfoMap[treeCurrency.traitCurrencyID] = treeCurrency;
	end

	if not skipButtonUpdates then
		self:UpdateAllButtons();
	end
end

function TalentFrameBaseMixin:GetTreeInfo()
	return self.talentTreeInfo;
end

function TalentFrameBaseMixin:GetButtonSize()
	return self:GetTreeInfo().buttonSize;
end

function TalentFrameBaseMixin:RefreshGates()
	self.gatePool:ReleaseAll();

	for i, gateInfo in ipairs(self.talentTreeInfo.gates) do
		local firstButton = self:GetTalentButtonByNodeID(gateInfo.topLeftNodeID);
		local condInfo = self:GetAndCacheCondInfo(gateInfo.conditionID);
		if firstButton and self:ShouldDisplayGate(firstButton, condInfo) then
			local gate = self.gatePool:Acquire();
			gate:Init(self, firstButton, condInfo);
			self:AnchorGate(gate, firstButton);
			gate:Show();

			self:OnGateDisplayed(gate, firstButton, condInfo);
		end
	end
end

function TalentFrameBaseMixin:ShouldDisplayGate(firstButton, condInfo)
	return firstButton:IsVisible() and not condInfo.isMet;
end

function TalentFrameBaseMixin:OnGateDisplayed(gate, firstButton, condInfo)
	-- Override in your derived Mixin.
end

function TalentFrameBaseMixin:AnchorGate(gate, button)
	gate:SetPoint("RIGHT", button, "LEFT", -12, 0);
end

function TalentFrameBaseMixin:MarkTreeDirty()
	if not self.treeIsDirty then
		self.treeIsDirty = true;
		self:RegisterOnUpdate();
	end
end

function TalentFrameBaseMixin:MarkTreeClean()
	self.treeIsDirty = nil;
end

function TalentFrameBaseMixin:IsTreeDirty()
	return self.treeIsDirty;
end

function TalentFrameBaseMixin:LoadTalentTree()
	if not self:IsVisible() then
		self:MarkTreeDirty();
		return;
	end

	local skipButtonUpdates = true;
	self:UpdateTreeInfo(skipButtonUpdates);
	self:LoadTalentTreeInternal();
end

function TalentFrameBaseMixin:LoadTalentTreeInternal()
	self:ReleaseAllTalentButtons();
	self:ClearInfoCaches();
	self:SetZoomLevel(1);
	self:SetPanOffset(0, 0);

	local treeID = self:GetTalentTreeID();
	local nodeIDs = C_Traits.GetTreeNodes(treeID);

	for i, nodeID in ipairs(nodeIDs) do
		self:InstantiateTalentButton(nodeID);
	end

	self:RefreshGates();

	self:MarkTreeClean();
end

function TalentFrameBaseMixin:SetTreeCurrencyDisplayTextCallback(getDisplayTextFromTreeCurrency)
	self.getDisplayTextFromTreeCurrency = getDisplayTextFromTreeCurrency;
end

function TalentFrameBaseMixin:CommitConfig()
	if not self:CheckAndReportCommitOperation() then
		return;
	end

	self.commitStarted = true;

	-- TODO:: Replace this with a proper response. For now, we'll just assume things finish out in 0.5 or less.
	-- Wait until we have server to client error messaging as well WOW10-27631
	C_Timer.After(0.5, function()
		self.commitStarted = false;
	end);

	return self:CommitConfigInternal();
end

function TalentFrameBaseMixin:CommitConfigInternal()
	return C_Traits.CommitConfig(self:GetConfigID());
end

function TalentFrameBaseMixin:RollbackConfig()
	if not self:CheckAndReportCommitOperation() then
		return;
	end

	return C_Traits.RollbackConfig(self:GetConfigID());
end

function TalentFrameBaseMixin:IsCommitInProgress()
	return self.commitStarted;
end

function TalentFrameBaseMixin:CheckAndReportCommitOperation()
	if self:IsCommitInProgress() then
		self:ReportConfigCommitError();
		return false;
	end

	return true;
end

function TalentFrameBaseMixin:GetConfigCommitErrorString()
	-- Override in your derived Mixin.
	return nil;
end

function TalentFrameBaseMixin:ReportConfigCommitError()
	UIErrorsFrame:AddExternalErrorMessage(self:GetConfigCommitErrorString());
end

function TalentFrameBaseMixin:AttemptConfigOperation(operation, ...)
	if not self:CheckAndReportCommitOperation() then
		return;
	end

	if not operation(self:GetConfigID(), ...) then
		UIErrorsFrame:AddExternalErrorMessage("Trait operation failed.");
	end
end

function TalentFrameBaseMixin:PurchaseRank(nodeID, entryID)
	self:AttemptConfigOperation(C_Traits.PurchaseRank, nodeID, entryID);
end

function TalentFrameBaseMixin:RefundRank(nodeID, entryID)
	self:AttemptConfigOperation(C_Traits.RefundRank, nodeID, entryID);
end

function TalentFrameBaseMixin:RefundAllRanks(nodeID)
	self:AttemptConfigOperation(C_Traits.RefundAllRanks, nodeID);
end

function TalentFrameBaseMixin:SetSelection(nodeID, entryID)
	self:AttemptConfigOperation(C_Traits.SetSelection, nodeID, entryID);
end

function TalentFrameBaseMixin:GetNodeCost(nodeID)
	return C_Traits.GetNodeCost(self:GetConfigID(), nodeID);
end

function TalentFrameBaseMixin:CanAfford(traitCurrenciesCost)
	for i, traitCurrencyCost in ipairs(traitCurrenciesCost) do
		local treeCurrency = self.treeCurrencyInfoMap[traitCurrencyCost.ID];
		if not treeCurrency or (treeCurrency.quantity < traitCurrencyCost.amount) then
			return false;
		end
	end

	return true;
end

function TalentFrameBaseMixin:AddCostToTooltip(tooltip, traitCurrenciesCost)
	if not self.getDisplayTextFromTreeCurrency then
		return;
	end

	local costStrings = {};
	for i, traitCurrencyCost in ipairs(traitCurrenciesCost) do
		local treeCurrency = self.treeCurrencyInfoMap[traitCurrencyCost.ID];
		local displayText = treeCurrency and self.getDisplayTextFromTreeCurrency(treeCurrency) or nil;
		if treeCurrency and displayText then
			local amount = traitCurrencyCost.amount;
			local costEntryString = TALENT_BUTTON_TOOLTIP_COST_ENTRY_FORMAT:format(amount, displayText);
			if treeCurrency.quantity < amount then
				costEntryString = RED_FONT_COLOR:WrapTextInColorCode(costEntryString);
			end

			table.insert(costStrings, costEntryString);
		end
	end

	if #costStrings > 0 then
		GameTooltip_AddBlankLineToTooltip(tooltip);

		local costString = TALENT_BUTTON_TOOLTIP_COST_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));
		GameTooltip_AddHighlightLine(tooltip, costString);
	end
end

function TalentFrameBaseMixin:DisableZoomAndPan()
	self.ButtonsParent:SetScript("OnUpdate", nil);
	self.ButtonsParent:SetScript("OnMouseWheel", nil);
	self.ButtonsParent:EnableMouse(false);
end

function TalentFrameBaseMixin:AddConditionsToTooltip(tooltip, conditionIDs, shouldAddSpacer)
	if #conditionIDs < 0 then
		return;
	end

	local bestGateConditionID = nil;
	local bestGateSpentRequired = nil;
	for i, conditionID in ipairs(conditionIDs) do
		local condInfo = self:GetAndCacheCondInfo(conditionID);
		if condInfo.isGate then
			if not bestGateConditionID or (condInfo.spentAmountRequired > bestGateSpentRequired) then
				bestGateConditionID = conditionID;
				bestGateSpentRequired = condInfo.spentAmountRequired;
			end
		end
	end

	for i, conditionID in ipairs(conditionIDs) do
		local condInfo = self:GetAndCacheCondInfo(conditionID);
		if condInfo.tooltipText and (not condInfo.isGate or (conditionID == bestGateConditionID)) then
			if shouldAddSpacer then
				shouldAddSpacer = false;
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			GameTooltip_AddHighlightLine(tooltip, condInfo.tooltipText);
		end
	end
end
