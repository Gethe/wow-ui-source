local CONDUIT_TEMPLATE = "SoulbindConduitNodeTemplate";
local TRAIT_TEMPLATE = "SoulbindTraitNodeTemplate";
local LINK_TEMPLATE = "SoulbindTreeNodeLinkTemplate";
local SELECT_ANIM_TEMPLATE = "PowerSwirlTemplate";

local SoulbindTreeEvents =
{
	"SOULBIND_NODE_LEARNED",
	"SOULBIND_PATH_CHANGED",
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"CURRENCY_DISPLAY_UPDATE",
	"CURSOR_CHANGED",
};

SoulbindTreeMixin = CreateFromMixins(CallbackRegistryMixin);

SoulbindTreeMixin:GenerateCallbackEvents(
	{
		"OnNodeChanged",
	}
);

function SoulbindTreeMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local resetterCb = function(pool, frame)
		frame:Reset();
		FramePool_HideAndClearAnchors(pool, frame);
	end;
	
	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("BUTTON", self.NodeContainer, TRAIT_TEMPLATE, resetterCb);
	self.pools:CreatePool("BUTTON", self.NodeContainer, CONDUIT_TEMPLATE, resetterCb);
	self.pools:CreatePool("FRAME", self.LinkContainer, LINK_TEMPLATE, resetterCb);
	self.pools:CreatePool("FRAME", self.Fx, SELECT_ANIM_TEMPLATE);
end

function SoulbindTreeMixin:OnEvent(event, ...)
	if event == "SOULBIND_NODE_LEARNED" then
		local nodeID = ...;
		self:OnNodeLearned(nodeID);
	elseif event == "SOULBIND_PATH_CHANGED" then
		self:OnPathChanged();
	elseif event == "SOULBIND_CONDUIT_COLLECTION_UPDATED" then
		self:OnConduitCollectionUpdated();
	elseif event == "CURSOR_CHANGED" then
		local isDefault, newCursorType, oldCursorType, oldCursorVirtualID = ...;
		self:OnCursorChanged(isDefault, newCursorType, oldCursorType, oldCursorVirtualID);
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		local currencyID = ...;
		if currencyID == SOULBINDS_RENOWN_CURRENCY_ID then
			self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
		end
	end
end

function SoulbindTreeMixin:Reset()
	self.pools:ReleaseAll();
	self.soulbindID = nil;
	self.nodeFrames = nil;
	self.linkToFrames = nil;
	if self.mouseOverTimer then
		self.mouseOverTimer:Cancel();
	end
end

function SoulbindTreeMixin:OnShow()
	self:StopThenApplySelectableAndUnsocketedAnims();

	if self.constructed then
		FrameUtil.RegisterFrameForEvents(self, SoulbindTreeEvents);
	end
end

function SoulbindTreeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindTreeEvents);

	self:Reset();
end

function SoulbindTreeMixin:HasSelectedNodes()
	return ContainsIf(self.nodeFrames, function(nodeFrame)
		return nodeFrame:IsSelected();
	end);
end

function SoulbindTreeMixin:GetNodes()
	return self.nodeFrames;
end

function SoulbindTreeMixin:OnNodeLearned(nodeID)
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
	PlaySound(SOUNDKIT.SOULBINDS_NODE_LEARNED);
	PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_PATH);
end

function SoulbindTreeMixin:OnNodeSwitched(nodeID)
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
end

function SoulbindTreeMixin:OnPathChanged()
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
	PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_PATH);
end

function SoulbindTreeMixin:OnConduitCollectionUpdated()
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
end

function SoulbindTreeMixin:SelectNode(button)
	if button:IsSelectable() then
		if C_Soulbinds.CanModifySoulbind() then
			self:PlayNodeSelectionAnim(button);
			C_Soulbinds.SelectNode(button:GetID());
		end
	elseif button:IsUnselected() then
		if C_Soulbinds.CanSwitchActiveSoulbindTreeBranch() then
			C_Soulbinds.SelectNode(button:GetID());
		end
	end
end

function SoulbindTreeMixin:PlayNodeSelectionAnim(button)
	local frame = self.pools:Acquire(SELECT_ANIM_TEMPLATE);
	frame:SetAllPoints(button.FxModelScene);
	frame:Show();
	frame.Anim:SetScript("OnFinished", GenerateClosure(self.OnSelectAnimFinished, self, swirlFrame));
	frame.Anim:Play();
end

function SoulbindTreeMixin:OnSelectAnimFinished(frame, anim)
	local pool = self.pools:GetPool(SELECT_ANIM_TEMPLATE);
	pool:Release(frame);
end

function SoulbindTreeMixin:OnNodeClicked(button, buttonName)
	if buttonName == "LeftButton" then
		local linked = false;
		if IsModifiedClick("CHATLINK") then
			local link = GetSpellLink(button:GetSpellID());
			linked = HandleModifiedItemClick(link);
		end

		if not linked then
			self:SelectNode(button);
		end
	end
end

function SoulbindTreeMixin:OnConduitClicked(button, buttonName)
	if buttonName == "RightButton" then
		if C_Soulbinds.CanModifySoulbind() then
			local nodeID = button:GetID();
			if C_Soulbinds.IsNodePendingModify(nodeID) then
				C_Soulbinds.UnmodifyNode(nodeID);
			else
				local conduitID = C_Soulbinds.GetInstalledConduitID(nodeID);
				if conduitID > 0 then
					C_Soulbinds.ModifyNode(nodeID, conduitID, Enum.SoulbindConduitTransactionType.Uninstall);
				end
			end
		end
 	elseif buttonName == "LeftButton" then
		if Soulbinds.HasConduitAtCursor() then
			if not (button:IsSelected() or button:IsUnselected()) then
				if SOULBIND_SELECT_BEFORE_INSTALL then
					UIErrorsFrame:AddMessage(SOULBIND_SELECT_BEFORE_INSTALL, RED_FONT_COLOR:GetRGBA());	
				end
			else
				self:TryInstallConduitAtCursor(button);
			end
		else
			local linked = false;
			local conduit = button:GetConduit();
			if conduit and IsModifiedClick("CHATLINK") then
				linked = HandleModifiedItemClick(conduit:GetHyperlink());
			end

			if not linked then
				self:SelectNode(button);
			end
		end
	end
end

function SoulbindTreeMixin:OnConduitReceiveDrag(button)
	self:TryInstallConduitAtCursor(button);
end

local function GetConduitMismatchString(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_TYPE_MISMATCH_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_TYPE_MISMATCH_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_TYPE_MISMATCH_FINESSE;
	end
end

function SoulbindTreeMixin:TryInstallConduitAtCursor(button)
	if not (button:IsSelected() or button:IsUnselected()) then
		return;
	end

	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	local conduitData = C_Soulbinds.GetConduitCollectionDataAtCursor();
	if conduitData then
		if button:IsConduitType(conduitData.conduitType) then
			local nodeID = button:GetID();
			self:TryInstallConduitInSlot(nodeID, conduitData.conduitID);
		else
			UIErrorsFrame:AddMessage(GetConduitMismatchString(button:GetConduitType()), RED_FONT_COLOR:GetRGBA());	
		end
	end
end

function SoulbindTreeMixin:StopNodeAnimationsIf(predicate)
	for _, nodeFrame in pairs(self.nodeFrames) do
		if predicate(nodeFrame) then
			nodeFrame:StopAnimations();
		end
	end
end

function SoulbindTreeMixin:StopNodeAnimations()
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:StopAnimations();
	end
end

local function AreConduitsResettingOrIsUninstalled(nodeFrame)
	return Soulbinds.IsConduitResetPending() or (C_Soulbinds.GetConduitCharges() > 0 or not C_Soulbinds.IsConduitInstalled(nodeFrame:GetID()));
end

local function IsInstallingConduitsOrNotPending(soulbindID, nodeFrame)
	if not Soulbinds.IsConduitCommitPending() then
		return true;
	end

	local conduit = nodeFrame:GetConduit();
	return not conduit or conduit:GetConduitID() == 0;
end

function SoulbindTreeMixin:ApplyConduitPickupAnim(conduitType, conduitID)
	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	local canAnimateConduit = (function()
		local canAnimate = function(nodeFrame, conduitType)
			-- If a conduit reset or install is pending, the animation conditions won't be accurately
			-- evaluable in the sense that their actual state would not match their expected state. 
			-- For example a commit is in flight, entering the collection would incorrectly animate
			-- a conduit that is about to be installed. Similarly, if conduits are being reset, entering the 
			-- collection would incorrect disallow animation because it would still appear installed. 
			return nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) and 
				AreConduitsResettingOrIsUninstalled(nodeFrame) and IsInstallingConduitsOrNotPending(self.soulbindID, nodeFrame);
		end

		if C_Soulbinds.IsUnselectedConduitPendingInSoulbind(self.soulbindID) then
			return function(nodeFrame)
				return not nodeFrame:IsUnavailable() and canAnimate(nodeFrame, conduitType);
			end;
		else
			return function(nodeFrame)
				return nodeFrame:IsSelected() and canAnimate(nodeFrame, conduitType);
			end;
		end
	end)();

	for _, nodeFrame in pairs(self.nodeFrames) do
		if canAnimateConduit(nodeFrame, conduitType) then
			nodeFrame:SetConduitPickupAnimShown(true, conduitID);
		end
	end
end

function SoulbindTreeMixin:EvaluatePickupAnimOverrides(conduitID)
	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsConduit() then
			nodeFrame:EvaluatePickupAnimOverride(conduitID);
		end
	end
end

function SoulbindTreeMixin:OnCollectionConduitClick(conduitID)
	self:EvaluatePickupAnimOverrides(conduitID);
end

function SoulbindTreeMixin:EvaluateSelectableAnim(conduitType)
	local canModifySoulbind = C_Soulbinds.CanModifySoulbind();
	local canSelectMultiple = self:GetSelectableCount() > 1;
	for _, nodeFrame in pairs(self.nodeFrames) do
		local unfiltered = nodeFrame:IsConduit() and (not conduitType or nodeFrame:GetConduitType() == conduitType);
		local shown = unfiltered and nodeFrame:IsSelectable();
		nodeFrame:SetSelectableAnimShown(shown, canModifySoulbind, canSelectMultiple);
	end
end

function SoulbindTreeMixin:OnCollectionConduitEnter(conduitType, conduitID)
	if not C_Soulbinds.CanModifySoulbind() or Soulbinds.HasConduitAtCursor() then
		return;
	end

	local oldTimer = self.mouseOverTimer;
	if oldTimer then
		self.mouseOverTimer:Cancel();
		self.mouseOverTimer = nil;
	end

	if not Soulbinds.HasConduitAtCursor() then
		if self.mouseOverConduit ~= conduitType or not oldTimer then
			self:StopNodeAnimationsIf(function(nodeFrame)
				return not (nodeFrame:IsConduit() and nodeFrame:GetConduitType() == conduitType and nodeFrame:IsSelectable());
			end);
			self:ApplyConduitPickupAnim(conduitType, conduitID);
		end
	end

	self:EvaluateSelectableAnim(conduitType);
	self:EvaluatePickupAnimOverrides(conduitID);

	self.mouseOverConduit = conduitType;
end

function SoulbindTreeMixin:OnCollectionConduitLeave()
	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	if not Soulbinds.HasConduitAtCursor() then
		if self.mouseOverTimer then
			self.mouseOverTimer:Cancel();
		end

		local time = .1;
		local frequency = 1;
		local func = function()
			self:StopThenApplySelectableAndUnsocketedAnims();
			self:EvaluatePickupAnimOverrides(nil);
			self.mouseOverTimer = nil;
		end;
		self.mouseOverTimer = C_Timer.NewTicker(time, func, frequency);
	end
end

function SoulbindTreeMixin:OnCursorChanged(isDefault, newCursorType, oldCursorType, oldCursorVirtualID)
	if isDefault and oldCursorType == Enum.UICursorType.ConduitCollectionItem then
		local previewConduitType, previewConduitID = Soulbinds.GetPreviewConduit();
		
		if previewConduitID and oldCursorVirtualID > 0 then
			local conduitData = C_Soulbinds.GetConduitCollectionDataByVirtualID(oldCursorVirtualID);
			if conduitData.conduitID == previewConduitID then
				return;
			end
		end

		self:EvaluatePickupAnimOverrides(previewConduitID);

		if previewConduitType then
			self:StopNodeAnimations();
			self:ApplyConduitPickupAnim(previewConduitType, previewConduitID);
		else
			self:StopThenApplySelectableAndUnsocketedAnims();
		end

		self:EvaluateSelectableAnim(previewConduitType);

		self.handleCursor = false;
	end

	if newCursorType == Enum.UICursorType.ConduitCollectionItem then
		PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_CURSOR_BEGIN);
	elseif oldCursorType == Enum.UICursorType.ConduitCollectionItem then
		PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_CURSOR_END);
	end
end

function SoulbindTreeMixin:GetSelectableCount()
	return AccumulateIf(self.nodeFrames, 
		function(nodeFrame)
			return nodeFrame:IsSelectable();
		end
	);
end

function SoulbindTreeMixin:StopThenApplySelectableAndUnsocketedAnims()
	self:StopNodeAnimations();
	
	local selectableCount = self:GetSelectableCount();

	local canModifySoulbind = C_Soulbinds.CanModifySoulbind();
	local multipleSelectable = selectableCount > 1;
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:SetSelectableAnimShown(nodeFrame:IsSelectable(), canModifySoulbind, multipleSelectable);
	end

	-- Appears only once there are no selections possible.
	if selectableCount == 0 then
		for _, nodeFrame in pairs(self.nodeFrames) do
			if nodeFrame:IsSelected() and nodeFrame:IsConduit() then
				local conduit = nodeFrame:GetConduit();
				if conduit and conduit:GetConduitID() == 0 then
					nodeFrame:SetUnsocketedWarningAnimShown(canModifySoulbind);
				end
			end
		end
	end
end

function SoulbindTreeMixin:TryInstallConduitInSlot(nodeID, conduitID)
	if C_Soulbinds.GetTotalConduitChargesPending() >= C_Soulbinds.GetConduitCharges() then
		UIErrorsFrame:AddExternalErrorMessage(CONDUIT_CHARGE_ERROR);	
		return;
	end

	local pendingInstallConduitID = C_Soulbinds.GetConduitIDPendingInstall(nodeID);
	if pendingInstallConduitID and pendingInstallConduitID == conduitID then
		return;
	end

	local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(self.soulbindID, conduitID);
	local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(self.soulbindID, conduitID);
	local appearInstalledNodeID = C_Soulbinds.FindNodeIDAppearingInstalled(self.soulbindID, conduitID);
	local pending = pendingUninstallNodeID > 0 or pendingInstallNodeID > 0;

	local isPendingInstall = pendingInstallNodeID > 0;
	local isPendingUninstall = pendingUninstallNodeID > 0;
	if isPendingInstall then
		C_Soulbinds.UnmodifyNode(pendingInstallNodeID);
	elseif isPendingUninstall then
		C_Soulbinds.UnmodifyNode(pendingUninstallNodeID);
	end

	local consumeInstall = false;
	local actualConduitID = C_Soulbinds.GetInstalledConduitID(nodeID);
	if actualConduitID == conduitID then
		if pendingUninstallNodeID == 0 then
			return;
		elseif pendingUninstallNodeID == nodeID then
			consumeInstall = true;
			C_Soulbinds.UnmodifyNode(nodeID);
		end
	end

	local actuallyInstalledNodeID = C_Soulbinds.FindNodeIDActuallyInstalled(self.soulbindID, nodeID);
	if ((actuallyInstalledNodeID > 0) or isPendingInstall) and (actuallyInstalledNodeID ~= nodeID) then
		StaticPopup_Show("SOULBIND_DIALOG_MOVE_CONDUIT", nil, nil);
	end 

	if not consumeInstall then
		C_Soulbinds.ModifyNode(nodeID, conduitID, Enum.SoulbindConduitTransactionType.Install);
	end
	
	ClearCursor();
end

function SoulbindTreeMixin:Init(soulbindData)
	local reconstructTree = not self.soulbindID or self.soulbindID ~= soulbindData.ID;
	self.soulbindID = soulbindData.ID;

	local cellVerticalDist = 61;
	local cellHorizontalDist = 85;
	local cellChevronDist = cellVerticalDist / 3.8;
	local tree = soulbindData.tree;
	local nodes = tree.nodes;
	if reconstructTree then
		if not self.constructed then
			self.constructed = true;
			FrameUtil.RegisterFrameForEvents(self, SoulbindTreeEvents);
		end
		
		self.pools:ReleaseAll();
		self.nodeFrames = {};
		self.linkToFrames = {};

		for _, node in ipairs(nodes) do
			local template = node.conduitType and CONDUIT_TEMPLATE or TRAIT_TEMPLATE;
			local nodeFrame = self.pools:Acquire(template);
			nodeFrame:Init(node);
			if nodeFrame:IsConduit() then
				nodeFrame:RegisterCallback(SoulbindTreeNodeMixin.Event.OnClick, self.OnConduitClicked, self);
				nodeFrame:RegisterCallback(SoulbindTreeNodeMixin.Event.OnDragReceived, self.OnConduitReceiveDrag, self);
			else
				nodeFrame:RegisterCallback(SoulbindTreeNodeMixin.Event.OnClick, self.OnNodeClicked, self);
			end

			local row = nodeFrame:GetRow();
			local column = nodeFrame:GetColumn();
			local x = column * cellHorizontalDist;
			local y = row * cellVerticalDist;
			local centerColumn = column == 1;
			if centerColumn then
				y = y + NegateIf(cellChevronDist, row < 6);
			end

			local coord = {x = x, y = -y};
			nodeFrame:SetPoint("CENTER", nodeFrame:GetParent(), "TOPLEFT", coord.x, coord.y);
			nodeFrame.coord = coord;

			local nodeID = nodeFrame:GetID();
			self.nodeFrames[nodeID] = nodeFrame;
			nodeFrame:Show();
		end
	
		local diagonalDistSq = Square(cellHorizontalDist) + Square(cellVerticalDist);
		
		for _, linkFromFrame in pairs(self.nodeFrames) do
			if linkFromFrame:GetRow() > 0 then
				for _, parentID in ipairs(linkFromFrame:GetParentNodeIDs()) do
					local linkToFrame = self.nodeFrames[parentID];
					local linkFrame = self.pools:Acquire(LINK_TEMPLATE);

					local toColumn = linkToFrame:GetColumn();
					local fromColumn = linkFromFrame:GetColumn();
					local offset = toColumn - fromColumn;
					
					if offset < 0 then
						linkFrame:SetPoint("BOTTOMRIGHT", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOPLEFT", linkToFrame, "CENTER");
					elseif offset > 0 then
						linkFrame:SetPoint("BOTTOMLEFT", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOPRIGHT", linkToFrame, "CENTER");
					else
						linkFrame:SetPoint("BOTTOM", linkFromFrame, "CENTER");
						linkFrame:SetPoint("TOP", linkToFrame, "CENTER");
					end

					local direction;
					local diagonal = toColumn ~= fromColumn;
					if diagonal then
						local distSq = RegionUtil.CalculateDistanceSqBetween(linkFromFrame, linkToFrame);
						direction = distSq < diagonalDistSq and SoulbindTreeLinkDirections.Converge or SoulbindTreeLinkDirections.Diverge;
					else
						direction = SoulbindTreeLinkDirections.Vertical;
					end

					local quarter = (math.pi / 2);
					local angle = RegionUtil.CalculateAngleBetween(linkToFrame, linkFromFrame) - quarter;

					self.linkToFrames[linkFrame] = linkToFrame;

					linkFrame:Init(direction, angle);
					linkFrame:Show();

					linkFromFrame:AddLink(linkFrame);
				end
			end
		end
	end

	local canModifySoulbind = C_Soulbinds.CanModifySoulbind();
	local animDuration = canModifySoulbind and .6 or .8;
	if reconstructTree then
		for _, node in ipairs(nodes) do
			local nodeFrame = self.nodeFrames[node.ID];
			nodeFrame:SetAnimDuration(animDuration);
		end
	else
		for _, node in ipairs(nodes) do
			local nodeFrame = self.nodeFrames[node.ID];
			nodeFrame:Init(node);
			nodeFrame:SetAnimDuration(animDuration);
		end
	end

	for _, nodeFrame in pairs(self.nodeFrames) do
		local state = nodeFrame:GetState();
		for _, linkFrame in ipairs(nodeFrame:GetLinks()) do
			local linkToFrame = self.linkToFrames[linkFrame];
			local linkToFrameState = linkToFrame:GetState();
			linkFrame:SetState(linkToFrame:IsSelected() and state or Enum.SoulbindNodeState.Unselected);
		end
	end

	self:StopThenApplySelectableAndUnsocketedAnims();
end

StaticPopupDialogs["SOULBIND_DIALOG_MOVE_CONDUIT"] = {
	text = SOULBIND_DIALOG_MOVE_CONDUIT,
	button1 = ACCEPT,
	enterClicksFirstButton = true,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["SOULBIND_DIALOG_INSTALL_CONDUIT_UNUSABLE"] = {
	text = SOULBIND_DIALOG_INSTALL_CONDUIT_UNUSABLE,
	button1 = ACCEPT,
	button2 = CANCEL,
	enterClicksFirstButton = true,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,

	OnButton1 = function(self, callback)
		callback();
	end,
};