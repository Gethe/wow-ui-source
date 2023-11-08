
local TalentFrameZoomSpeed = 0.05;
local AutoPanSpeed = 350;
local AutoPanEdgeSize = 40;
local AutoPanOverEdge = 10;
local AutoPanDelay = 0.35;

-- Delays less than 0.5 risk displaying the spinner right before the commit cast bar starts showing
-- Rather than reducing this, we should expand the cases where we can safely pass skipSpinnerDelay instead
-- (See SetCommitVisualsActive)
local CommitSpinnerWithBarDelay = 0.5;


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
	"TRAIT_NODE_CHANGED_PARTIAL",
	"TRAIT_NODE_ENTRY_UPDATED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

TalentFrameBaseMixin:GenerateCallbackEvents(
{
	"TalentButtonAcquired",
	"TalentButtonReleased",
	"CommitStatusChanged",
});

TalentFrameBaseMixin.CommitUpdateReasons = {
	CommitStarted = 1,
	CommitSucceeded = 2,
	CommitFailed = 3,
	InstantCommit = 4,
};

TalentFrameBaseMixin.VisualsUpdateReasons = {
	FrameHidden = 1,
	CommitOngoing = 2,
	CommitStoppedComplete = 3,
	CommitStoppedIncomplete = 4,
	TalentTreeReset = 5,
};

function TalentFrameBaseMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:SetBasePanOffset(self.basePanOffsetX or 0, self.basePanOffsetY or 0);

	if not self.enableZoomAndPan then
		self:DisableZoomAndPan();
	end
	
	self.DisabledOverlay.GrayOverlay:SetAlpha(self.disabledOverlayAlpha);

	self:UpdatePadding();

	self.talentButtonCollection = CreateFramePoolCollection();
	self.talentDislayFramePool = CreateFramePoolCollection();
	self.edgePool = CreateFramePoolCollection();
	self.gatePool = CreateFramePool("FRAME", self.ButtonsParent, "TalentFrameGateTemplate");
	self.nodeIDToButton = {};
	self.buttonsWithDirtyEdges = {};
	self.treeInfoDirty = false;
	self.definitionInfoCache = {};
	self.dirtyDefinitionIDSet = {};
	self.entryInfoCache = {};
	self.dirtyEntryIDSet = {};
	self.nodeInfoCache = {};
	self.dirtyNodeIDSet = {};
	self.condInfoCache = {};
	self.dirtyCondIDSet = {};
	self.panOffsetX = 0;
	self.panOffsetY = 0;
	
	self.areBaseCommitVisualsActive = false;

	-- These need to always be registered so that the entire loadout change process is always captured.
	self:RegisterEvent("TRAIT_CONFIG_UPDATED");
	self:RegisterEvent("CONFIG_COMMIT_FAILED");
	self:RegisterEvent("TRAIT_TREE_CHANGED");

	-- Monitor changes to color blind mode
	CVarCallbackRegistry:RegisterCallback("colorblindMode", self.UpdateColorBlindModeUI, self);
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

		for definitionID, isDirty in pairs(self.dirtyDefinitionIDSet) do
			self.definitionInfoCache[definitionID] = nil;
			for talentButton in self:EnumerateAllTalentButtons() do
				-- TODO:: This sets a dangerous precedent for a very expensive iteration.
				-- Consider replacing this with a pattern similar to nodeIDToButton or something else entirely.
				-- We may not need this at all. This will only happen in response to a hotfix in practice, so we
				-- could just reload the entire tree.
				if definitionID == talentButton:GetDefinitionID() then
					buttonsToUpdateMethods[talentButton] = talentButton.UpdateDefinitionInfo;
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

		for nodeID, isDirty in pairs(self.dirtyNodeIDSet) do
			self.nodeInfoCache[nodeID] = nil;
			local talentButton = self.nodeIDToButton[nodeID];
			if talentButton then
				buttonsToUpdateMethods[talentButton] = talentButton.UpdateNodeInfo;
			end
		end

		self.dirtyCondIDSet = {};
		self.dirtyDefinitionIDSet = {};
		self.dirtyEntryIDSet = {};
		self.dirtyNodeIDSet = {};

		if self.treeInfoDirty then
			self.treeInfoDirty = false;
			self:UpdateTreeInfo();
		end

		for button, updateMethod in pairs(buttonsToUpdateMethods) do
			updateMethod(button);
		end

		local skipEdgeUpdates = self.edgePool:GetNumActive() == 0;
		for button, isDirty in pairs(self.buttonsWithDirtyEdges) do
			if isDirty then
				self:UpdateEdgesForButton(button, skipEdgeUpdates);
			end
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

	if self:IsCommitInProgress() then
		local active = true;
		local skipSpinnerDelay = true;
		self:SetCommitVisualsActive(active, TalentFrameBaseMixin.VisualsUpdateReasons.CommitOngoing, skipSpinnerDelay);
	else
		self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.CommitStoppedIncomplete);
	end
end

function TalentFrameBaseMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TalentFrameBaseEvents);

	self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.FrameHidden);

	self:SetCommitCompleteVisualsActive(false);

	self:ClearInfoCaches();
end

function TalentFrameBaseMixin:OnEvent(event, ...)
	if event == "TRAIT_NODE_CHANGED" then
		local nodeID = ...;
		self:MarkNodeInfoCacheDirty(nodeID);
	elseif event == "TRAIT_NODE_CHANGED_PARTIAL" then
		local nodeID, partialUpdate = ...;
		if not self:IsNodeInfoCacheDirty() then
			local cachedNodeInfo = self.nodeInfoCache[nodeID];
			if cachedNodeInfo then
				for key, value in pairs(partialUpdate) do
					if value ~= nil then
						cachedNodeInfo[key] = value;
					end
				end

				local button = self:GetTalentButtonByNodeID(nodeID);
				if button then
					button:UpdateNodeInfo();
				end
			end
		end
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
		if treeID == self:GetTalentTreeID() and not self:IsCommitInProgress() then
			self:UpdateTreeCurrencyInfo();
		end
	elseif event == "TRAIT_CONFIG_UPDATED" then
		local configID = ...;
		self:OnTraitConfigUpdated(configID);
	elseif event == "CONFIG_COMMIT_FAILED" then
		if self:IsCommitInProgress() then
			self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.CommitFailed);
			self:UpdateTreeCurrencyInfo();
		end
	end
end

function TalentFrameBaseMixin:OnTraitConfigUpdated(configID)
	if (configID == self.commitedConfigID) and self:IsCommitInProgress() then
		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.CommitSucceeded);
		self:UpdateTreeCurrencyInfo();
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
	local treeInfo = self:GetTreeInfoOrLayoutDefaults();
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
		local nodeInfo = talentButton:GetNodeInfo();
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

	if left == nil or top == nil or scale == nil then
		return 1, 1;
	end

	return left * scale, top * scale;
end

function TalentFrameBaseMixin:GetPanExtents()
	local treeInfo = self:GetTreeInfoOrLayoutDefaults();
	local zoomLevel = self:GetZoomLevel();
	local zoomLevelFactor = (1 / zoomLevel);

	local basePanWidth, basePanHeight = self:GetPanViewSize();
	local minZoom = treeInfo.minZoom;
	local maxZoomFactor = (1 / minZoom);
	local maxTreeWidth = (basePanWidth * maxZoomFactor);
	local maxTreeHeight = (basePanHeight * maxZoomFactor);
	local panWidth = maxTreeWidth - (basePanWidth * zoomLevelFactor);
	local panHeight = maxTreeHeight - (basePanHeight * zoomLevelFactor);
	return Clamp(panWidth, 0, math.huge), Clamp(panHeight, 0, math.huge);
end

function TalentFrameBaseMixin:TalentButtonCollectionReset(framePool, talentButton)
	local function TalentFrameBaseIsEdgeConnectedToTalentButton(edgeFrame)
		return (edgeFrame:GetEndButton() == talentButton) or (edgeFrame:GetStartButton() == talentButton);
	end

	if self.edgePool:GetNumActive() > 0 then
		self:ReleaseEdgesByCondition(TalentFrameBaseIsEdgeConnectedToTalentButton);
	end

	local nodeID = talentButton:GetNodeID();
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

function TalentFrameBaseMixin:InvokeTalentButtonMethodByNodeID(methodName, nodeID, ...)
	local button = self:GetTalentButtonByNodeID(nodeID);
	if button then
		return true, button[methodName](button, ...);
	end

	return false;
end

function TalentFrameBaseMixin:PlaySelectSoundForButton(unused_button)
	if self.defaultSelectSound then
		PlaySound(self.defaultSelectSound);
	end
end

function TalentFrameBaseMixin:PlayDeselectSoundForButton(unused_button)
	if self.defaultDeselectSound then
		PlaySound(self.defaultDeselectSound);
	end
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

function TalentFrameBaseMixin:AcquireTalentDisplayFrame(talentType, specializedMixin, useLarge)
	specializedMixin = specializedMixin or nil;

	local nodeInfo = nil;
	local templateType = self.getTemplateType(nodeInfo, talentType, useLarge);
	local resetterFunction = nil;
	local forbidden = false;
	local pool = self.talentDislayFramePool:GetOrCreatePool("BUTTON", self, templateType, resetterFunction, forbidden, specializedMixin);
	return pool:Acquire();
end

function TalentFrameBaseMixin:ReleaseTalentDisplayFrame(displayFrame)
	self.talentDislayFramePool:Release(displayFrame);
end

function TalentFrameBaseMixin:GetSpecializedSelectionChoiceMixin(entryInfo, talentType)
	return self.getSpecializedChoiceMixin and self.getSpecializedChoiceMixin(entryInfo, talentType) or nil;
end

function TalentFrameBaseMixin:AreSelectionsOpen(button)
	return self.SelectionChoiceFrame:IsShown() and (self.SelectionChoiceFrame:GetBaseButton() == button);
end

function TalentFrameBaseMixin:ToggleSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost)
	if not self.SelectionChoiceFrame:IsDraggingSpell() then
		if self:AreSelectionsOpen(button) then
			self:HideSelections();
		else
			self:ShowSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost);
		end
	end
end

function TalentFrameBaseMixin:ShowSelections(button, selectionOptions, canSelectChoice, currentSelection, baseCost)
	if not self.SelectionChoiceFrame:IsDraggingSpell() then
		self.SelectionChoiceFrame:SetPoint("BOTTOM", button, "TOP", 0, -10);
		self.SelectionChoiceFrame:SetSelectionOptions(button, selectionOptions, canSelectChoice, currentSelection, baseCost);
		self.SelectionChoiceFrame:Show();
	end
end

function TalentFrameBaseMixin:UpdateSelections(button, canSelectChoice, currentSelection, baseCost)
	if self:AreSelectionsOpen(button) then
		self.SelectionChoiceFrame:UpdateSelectionOptions(canSelectChoice, currentSelection, baseCost);
	end
end

function TalentFrameBaseMixin:HideSelections(button)
	if self:AreSelectionsOpen(button) then
		-- Leave the choice frame open if we're dragging from it.
		if not self.SelectionChoiceFrame:IsDraggingSpell() then
			self.SelectionChoiceFrame:Hide();
		end
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

function TalentFrameBaseMixin:UpdateEdgesForButton(button, skipEdgeUpdates)
	local function TalentFrameBaseIsEdgeFromTalentButton(edgeFrame)
		return (edgeFrame:GetStartButton() == button);
	end

	local function TalentFrameBaseIsEdgeToTalentButton(edgeFrame)
		return (edgeFrame:GetEndButton() == button);
	end

	if not skipEdgeUpdates then
		self:ReleaseEdgesByCondition(TalentFrameBaseIsEdgeFromTalentButton);
		self:UpdateEdgesByCondition(TalentFrameBaseIsEdgeToTalentButton);
	end

	if self:ShouldButtonShowEdges(button) then
		local nodeInfo = button:GetNodeInfo();
		if nodeInfo then
			for i, edgeVisualInfo in ipairs(nodeInfo.visibleEdges) do
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
	nodeInfo = nodeInfo or self:GetAndCacheNodeInfo(nodeID);

	if not nodeInfo.isVisible and not self:ShouldInstantiateInvisibleButtons() then
		return nil;
	end

	local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
	local entryInfo = (activeEntryID ~= nil) and self:GetAndCacheEntryInfo(activeEntryID) or nil;
	local talentType = (entryInfo ~= nil) and entryInfo.type or nil;
	local function InitTalentButton(newTalentButton)
		newTalentButton:SetNodeID(nodeID);
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
	local existingButton = self:GetTalentButtonByNodeID(nodeID);
	if existingButton then
		return self:ReleaseAndReinstantiateTalentButton(existingButton);
	else
		return self:InstantiateTalentButton(nodeID);
	end
end

function TalentFrameBaseMixin:ReleaseAndReinstantiateTalentButton(talentButton)
	local nodeID = talentButton:GetNodeID();
	local entryID = talentButton:GetEntryID();

	local forReinstantiation = true;
	self:ReleaseTalentButton(talentButton, forReinstantiation);
	self:ForceEntryInfoCacheUpdate(entryID);
	self:ForceNodeInfoUpdate(nodeID);

	local newTalentButton = self:InstantiateTalentButton(nodeID);
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

function TalentFrameBaseMixin:GetButtonsInOrder(comparison)
	local talentButtons = {};
	for talentButton in self:EnumerateAllTalentButtons() do
		table.insert(talentButtons, talentButton);
	end

	table.sort(talentButtons, comparison);
	return talentButtons;
end

function TalentFrameBaseMixin:GetButtonsInTopLeftOrder()
	local function CompareTalentButtons(lhsButton, rhsButton)
		local lhsIsShown = lhsButton:IsShown();
		if lhsIsShown ~= rhsButton:IsShown() then
			return lhsIsShown;
		end

		local lhsTop = lhsButton:GetTop();
		local rhsTop = rhsButton:GetTop();
		if math.abs(lhsTop - rhsTop) > 3 then
			return lhsTop > rhsTop;
		end

		local lhsLeft = lhsButton:GetLeft();
		local rhsLeft = rhsButton:GetLeft();
		if math.abs(lhsLeft - rhsLeft) > 3 then
			return lhsLeft < rhsLeft;
		end

		return lhsButton:GetNodeID() < rhsButton:GetNodeID();
	end

	return self:GetButtonsInOrder(CompareTalentButtons);
end

function TalentFrameBaseMixin:UpdateAllButtons()
	for talentButton in self:EnumerateAllTalentButtons() do
		talentButton:FullUpdate();
	end

	if self.SelectionChoiceFrame:IsShown() then
		self.SelectionChoiceFrame:UpdateVisualState();
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

	talentButton:UpdateNodeInfo();
end

function TalentFrameBaseMixin:OnDefinitionInfoUpdated(definitionID)
	for talentButton in self:EnumerateAllTalentButtons() do
		if definitionID == talentButton:GetDefinitionID() then
			talentButton:UpdateDefinitionInfo();
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

function TalentFrameBaseMixin:ForceNodeInfoUpdate(nodeID)
	if not self:IsNodeInfoCacheDirty(nodeID) then
		return;
	end

	self.dirtyNodeIDSet[nodeID] = nil;
	self.nodeInfoCache[nodeID] = nil;
	self:OnNodeInfoUpdated(nodeID);
end

function TalentFrameBaseMixin:ForceCondInfoUpdate(condID)
	if not self:IsCondInfoCacheDirty(condID) then
		return;
	end

	self.dirtyCondIDSet[condID] = nil;
	self.condInfoCache[condID] = nil;
end

function TalentFrameBaseMixin:GetAndCacheNodeInfo(nodeID)
	local function GetNodeInfoCallback()
		self.dirtyNodeIDSet[nodeID] = nil;
		return C_Traits.GetNodeInfo(self:GetConfigID(), nodeID);
	end

	return GetOrCreateTableEntryByCallback(self.nodeInfoCache, nodeID, GetNodeInfoCallback);
end

function TalentFrameBaseMixin:ForceDefinitionInfoUpdate(definitionID)
	if not self:IsDefinitionInfoCacheDirty(definitionID) then
		return;
	end

	self.dirtyDefinitionIDSet[definitionID] = nil;
	self.definitionInfoCache[definitionID] = nil;
	self:OnDefinitionInfoUpdated(definitionID);
end

function TalentFrameBaseMixin:GetAndCacheDefinitionInfo(definitionID)
	local function GetDefinitionInfoCallback()
		self.dirtyDefinitionIDSet[definitionID] = nil;
		return C_Traits.GetDefinitionInfo(definitionID);
	end

	return GetOrCreateTableEntryByCallback(self.definitionInfoCache, definitionID, GetDefinitionInfoCallback);
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

function TalentFrameBaseMixin:MarkDefinitionInfoCacheDirty(definitionID)
	self.dirtyDefinitionIDSet[definitionID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkEntryInfoCacheDirty(entryID)
	self.dirtyEntryIDSet[entryID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkNodeInfoCacheDirty(nodeID)
	self.dirtyNodeIDSet[nodeID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:MarkCondInfoCacheDirty(condID)
	self.dirtyCondIDSet[condID] = true;
	self:RegisterOnUpdate();
end

function TalentFrameBaseMixin:IsDefinitionInfoCacheDirty(definitionID)
	return self.dirtyDefinitionIDSet[definitionID] and (self.definitionInfoCache[definitionID] ~= nil);
end

function TalentFrameBaseMixin:IsEntryInfoCacheDirty(entryID)
	return self.dirtyEntryIDSet[entryID] and (self.entryInfoCache[entryID] ~= nil);
end

function TalentFrameBaseMixin:IsNodeInfoCacheDirty(nodeID)
	return self.dirtyNodeIDSet[nodeID] and (self.nodeInfoCache[nodeID] ~= nil);
end

function TalentFrameBaseMixin:IsCondInfoCacheDirty(condID)
	return self.dirtyCondIDSet[condID] and (self.condInfoCache[condID] ~= nil);
end

function TalentFrameBaseMixin:ClearInfoCaches()
	self.definitionInfoCache = {};
	self.dirtyDefinitionIDSet = {};
	self.entryInfoCache = {};
	self.dirtyEntryIDSet = {};
	self.nodeInfoCache = {};
	self.dirtyNodeIDSet = {};
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
	self.treeCurrencyInfoMap = {};

	local configID = self:GetConfigID();
	local treeID = self:GetTalentTreeID();
	if configID and treeID then
		self.treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, self.excludeStagedChangesForCurrencies);

		for i, treeCurrency in ipairs(self.treeCurrencyInfo) do
			self.treeCurrencyInfoMap[treeCurrency.traitCurrencyID] = treeCurrency;
		end

		if not skipButtonUpdates then
			self:UpdateAllButtons();
		end
	end
end

function TalentFrameBaseMixin:GetTreeInfo()
	return self.talentTreeInfo;
end

function TalentFrameBaseMixin:GetTreeInfoOrLayoutDefaults()
	local treeInfo = self.talentTreeInfo or {};
	treeInfo.minZoom = (treeInfo.minZoom and treeInfo.minZoom > 0) and treeInfo.minZoom or 1;
	treeInfo.maxZoom = (treeInfo.maxZoom and treeInfo.maxZoom > 0) and treeInfo.maxZoom or 1;
	treeInfo.buttonSize = treeInfo.buttonSize or 40;
	return treeInfo;
end

function TalentFrameBaseMixin:GetButtonSize()
	return self.buttonSize;
end

function TalentFrameBaseMixin:ShouldHideSingleRankNumbers()
	return self:GetTreeInfo().hideSingleRankNumbers;
end

function TalentFrameBaseMixin:RefreshGates()
	self.gatePool:ReleaseAll();

	-- Possible we've put off loading tree info because frame hasn't been shown yet
	if not self.talentTreeInfo or not self.talentTreeInfo.gates then
		return;
	end

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

function TalentFrameBaseMixin:SetDisabledOverlayShown(shown)
	self.DisabledOverlay:SetShown(shown);
end

function TalentFrameBaseMixin:SetCommitSpinnerShown(shown)
	local isCastBarActive = self.enableCommitCastBar and OverlayPlayerCastingBarFrame:IsShown();

	if shown and not isCastBarActive and self:IsVisible() then
		self.CommitSpinner:Show();
	else
		if self.spinnerTimer then
			self.spinnerTimer:Cancel();
		end
		self.CommitSpinner:Hide();
	end
end

function TalentFrameBaseMixin:SetCommitVisualsActive(active, reason, skipSpinnerDelay)
	if active and not self:IsVisible() then
		return;
	end

	if self.areBaseCommitVisualsActive == active then
		return;
	end

	self.areBaseCommitVisualsActive = active;

	self.DisabledOverlay:SetShown(active);

	if self.enableCommitCastBar then
		if active then
			OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(self.DisabledOverlay, { overrideBarType = "applyingtalents" });
		else
			OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
		end
	end

	local isCastBarActive = self.enableCommitCastBar and OverlayPlayerCastingBarFrame:IsShown();

	if self.enableCommitSpinner then
		if active and not isCastBarActive then
			-- If the cast bar is also in use, put the spinner on a delay in case the bar is about to display
			-- skipSpinnerDelay should only be passed in cases we know the cast bar will never be used
			if self.enableCommitCastBar and not skipSpinnerDelay then
				self.spinnerTimer = C_Timer.NewTimer(CommitSpinnerWithBarDelay, function()
					self:SetCommitSpinnerShown(true);
				end);
			else
				self:SetCommitSpinnerShown(true);
			end
		else
			self:SetCommitSpinnerShown(false);
		end
	end

	-- If both the spinner and cast bar are in use, listen for cast bar activating so we can hide spinner
	if self.enableCommitSpinner and self.enableCommitCastBar then
		if active then
			EventRegistry:RegisterCallback("OverlayPlayerCastBar.OnShow", self.OnCommitCastBarShow, self);
		else
			EventRegistry:UnregisterCallback("OverlayPlayerCastBar.OnShow", self);
		end
	end
end

function TalentFrameBaseMixin:OnCommitCastBarShow()
	self:SetCommitSpinnerShown(false);
end

function TalentFrameBaseMixin:SetCommitCompleteVisualsActive(active)
	if active and not self:IsVisible() then
		return;
	end

	local playingBackgroundFlash = self.AnimationHolder.BackgroundFlashAnim:IsPlaying();
	if self.enableCommitEndFlash and (active ~= playingBackgroundFlash) then
		if active then
			self.AnimationHolder.BackgroundFlashAnim:Restart();
		else
			self.BackgroundFlash:SetAlpha(0);
			self.AnimationHolder.BackgroundFlashAnim:Stop();
		end
	end
end

function TalentFrameBaseMixin:CanCommitInstantly()
	-- Override in your derived mixin.
	return false;
end

function TalentFrameBaseMixin:SetCommitStarted(configID, reason, skipAnimation)
	local isCommitStarted = (configID ~= nil);
	local wasCommitActive = self:IsCommitInProgress();

	self.commitedConfigID = configID;

	if reason == TalentFrameBaseMixin.CommitUpdateReasons.CommitFailed then
		self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.CommitStoppedIncomplete);
	elseif isCommitStarted ~= wasCommitActive then
		local isCommitOngoing = isCommitStarted and (reason ~= TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit);
		if isCommitOngoing then
			self:SetCommitVisualsActive(true, TalentFrameBaseMixin.VisualsUpdateReasons.CommitOngoing);
		else
			self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.CommitStoppedComplete);
		end
	end

	if not isCommitStarted and self.commitTimer then
		self.commitTimer:Cancel();
		self.commitTimer = nil;
	end

	if self:IsShown() then
		if reason == TalentFrameBaseMixin.CommitUpdateReasons.CommitFailed then
			self:SetCommitCompleteVisualsActive(false);
		elseif not skipAnimation then
			if reason == TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit then
				self:SetCommitCompleteVisualsActive(true);
			elseif (self.previousCommitUpdateReason ~= TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit) and (reason == TalentFrameBaseMixin.CommitUpdateReasons.CommitSucceeded) then
				self:SetCommitCompleteVisualsActive(true);
			end
		end
	end

	self.previousCommitUpdateReason = reason;

	self:TriggerEvent(TalentFrameBaseMixin.Event.CommitStatusChanged);
end

function TalentFrameBaseMixin:GetMaximumCommitTime()
	return self.maximumCommitTime;
end

function TalentFrameBaseMixin:CommitConfig()
	if self:IsCommitInProgress() or not self:CheckAndReportCommitOperation() then
		return;
	end

	self:PlayCommitConfigSound();

	self:SetCommitStarted(self:GetConfigID(), self:CanCommitInstantly() and TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit or TalentFrameBaseMixin.CommitUpdateReasons.CommitStarted);

	if self.commitTimer then
		self.commitTimer:Cancel();
		self.commitTimer = nil;
	end

	-- TODO:: Consider removing this backup now that we're confident with the proper flow.
	self.commitTimer = C_Timer.NewTimer(self:GetMaximumCommitTime(), function()
		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.CommitFailed);
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

	self:PlayRollbackConfigSound();

	return C_Traits.RollbackConfig(self:GetConfigID());
end

function TalentFrameBaseMixin:TryPlaySound(soundKit)
	if not self.suppressedSounds or not tContains(self.suppressedSounds, soundKit) then
		PlaySound(soundKit);
	end
end

function TalentFrameBaseMixin:SetSuppressedSounds(suppressedSounds)
	self.suppressedSounds = suppressedSounds;
end

function TalentFrameBaseMixin:ClearSuppressedSounds()
	self.suppressedSounds = nil;
end

function TalentFrameBaseMixin:PlayCommitConfigSound()
	if self.commitSound then
		self:TryPlaySound(self.commitSound);
	end
end

function TalentFrameBaseMixin:PlayRollbackConfigSound()
	if self.rollbackSound then
		PlaySound(self.rollbackSound);
	end
end

function TalentFrameBaseMixin:IsCommitInProgress()
	return self.commitedConfigID ~= nil;
end

function TalentFrameBaseMixin:CheckAndReportCommitOperation()
	if self:IsCommitInProgress() then
		self:ReportConfigCommitError();
		return false;
	end

	if not self:GetConfigID() then
		-- This is a silent error because it should never happen.
		return false;
	end

	return true;
end

function TalentFrameBaseMixin:GetConfigCommitErrorString()
	-- Override in your derived Mixin.
	return nil;
end

function TalentFrameBaseMixin:ReportConfigCommitError()
	local errorString = self:GetConfigCommitErrorString();
	if errorString then
		UIErrorsFrame:AddExternalErrorMessage(errorString);
	end
end

function TalentFrameBaseMixin:AttemptConfigOperation(operation, ...)
	if not self:CheckAndReportCommitOperation() then
		return false;
	end

	if not operation(self:GetConfigID(), ...) then
		UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
		return false;
	end

	return true;
end

function TalentFrameBaseMixin:PurchaseRank(nodeID)
	return self:AttemptConfigOperation(C_Traits.PurchaseRank, nodeID);
end

function TalentFrameBaseMixin:CascadeRepurchaseRanks(nodeID)
	return self:AttemptConfigOperation(C_Traits.CascadeRepurchaseRanks, nodeID);
end

function TalentFrameBaseMixin:RefundRank(nodeID)
	return self:AttemptConfigOperation(C_Traits.RefundRank, nodeID);
end

function TalentFrameBaseMixin:RefundAllRanks(nodeID)
	return self:AttemptConfigOperation(C_Traits.RefundAllRanks, nodeID);
end

function TalentFrameBaseMixin:SetSelection(nodeID, entryID)
	return self:AttemptConfigOperation(C_Traits.SetSelection, nodeID, entryID);
end

function TalentFrameBaseMixin:ClearCascadeRepurchaseHistory()
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

	C_Traits.ClearCascadeRepurchaseHistory(self:GetConfigID());
end

function TalentFrameBaseMixin:GetNodeCost(nodeID)
	return C_Traits.GetNodeCost(self:GetConfigID(), nodeID);
end

function TalentFrameBaseMixin:IsLocked()
	-- Override in your derived mixin.

	-- Returns whether or not the frame is globally locked, and if so, an optional error message.
	return false, nil;
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

	local costStrings = self:GetCostStrings(traitCurrenciesCost);

	if #costStrings > 0 then
		GameTooltip_AddBlankLineToTooltip(tooltip);

		local costString = TALENT_BUTTON_TOOLTIP_COST_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));
		GameTooltip_AddHighlightLine(tooltip, costString);
	end
end

function TalentFrameBaseMixin:GetCostStrings(traitCurrenciesCost)
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
	return costStrings;
end

function TalentFrameBaseMixin:DisableZoomAndPan()
	self.ButtonsParent:SetScript("OnUpdate", nil);
	self.ButtonsParent:SetScript("OnMouseWheel", nil);
	self.ButtonsParent:EnableMouse(false);
end

function TalentFrameBaseMixin:AddConditionsToTooltip(tooltip, conditionIDs, shouldAddSpacer)
	if #conditionIDs < 0 then
		return false;
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

	local addedAny = false;
	for i, conditionID in ipairs(conditionIDs) do
		local condInfo = self:GetAndCacheCondInfo(conditionID);
		if condInfo.tooltipText and (not condInfo.isGate or (conditionID == bestGateConditionID)) then
			if shouldAddSpacer then
				shouldAddSpacer = false;
				GameTooltip_AddBlankLineToTooltip(tooltip);
			end

			GameTooltip_AddHighlightLine(tooltip, condInfo.tooltipText);
			addedAny = true;
		end
	end

	return addedAny;
end

function TalentFrameBaseMixin:AddEdgeRequirementsToTooltip(tooltip, nodeID, shouldAddSpacer)
	local incomingEdges = self:GetIncomingEdgeInfoForNode(nodeID);

	local requiresAllPrecedingTraits = true;
	local areAllPrecedingEdgesActive = true;
	local numOfEdges = 0;
	for _, edgeVisualInfo in ipairs(incomingEdges) do
		numOfEdges = numOfEdges + 1;
		if edgeVisualInfo.type ~= Enum.TraitEdgeType.RequiredForAvailability then
			requiresAllPrecedingTraits = false;
		end

		if not edgeVisualInfo.isActive then
			areAllPrecedingEdgesActive = false;
		end
	end

	if requiresAllPrecedingTraits and numOfEdges > 1 and not areAllPrecedingEdgesActive then
		if shouldAddSpacer then
			GameTooltip_AddBlankLineToTooltip(tooltip);
		end

		GameTooltip_AddErrorLine(tooltip, GENERIC_TRAIT_FRAME_EDGE_REQUIREMENTS_BUTTON_TOOLTIP);
		return true;
	end

	return false;
end

function TalentFrameBaseMixin:GetIncomingEdgeInfoForNode(nodeID)
	local incomingEdges = {};
	local i = 1;
	for edgeFrame in self.edgePool:EnumerateActive() do
		local edgeInfo = edgeFrame.edgeInfo;
		-- TODO: TraitEdge uses targetNodeID but SharedTraits uses targetNode. Update ShareTraits and change to targetNodeID
		if edgeInfo.targetNode == nodeID  then
			incomingEdges[i] = edgeInfo;
			i = i + 1;
		end
	end
	return incomingEdges;
end

function TalentFrameBaseMixin:UpdateColorBlindModeUI(isColorBlindModeActive)
	for talentButton in self:EnumerateAllTalentButtons() do
		if talentButton and talentButton.UpdateColorBlindVisuals then
			talentButton:UpdateColorBlindVisuals(isColorBlindModeActive);
		end
	end
end

function TalentFrameBaseMixin:GetSearchPreviewContainer()
	-- Override in your derived Mixin.
	return nil;
end

function TalentFrameBaseMixin:SetPreviewResultSearch(searchText)
	-- Override in your derived Mixin.
end

function TalentFrameBaseMixin:HidePreviewResultSearch()
	-- Override in your derived Mixin.
end

function TalentFrameBaseMixin:SetFullResultSearch(searchText)
	-- Override in your derived Mixin.
end

function TalentFrameBaseMixin:SetSelectedSearchResult(definitionID)
	-- Override in your derived Mixin.
end

function TalentFrameBaseMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	-- Override in your derived Mixin.
	return nil;
end

function TalentFrameBaseMixin:IsInspecting()
	-- Override in your derived Mixin.
	return self:GetInspectUnit() ~= nil;
end

function TalentFrameBaseMixin:GetInspectUnit()
	-- Override in your derived Mixin.
	return nil;
end

function TalentFrameBaseMixin:ShouldShowConfirmation()
	-- Override in your derived Mixin as desired.
	return false;
end