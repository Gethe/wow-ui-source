local CONDUIT_TEMPLATE = "SoulbindConduitNodeTemplate";
local TRAIT_TEMPLATE = "SoulbindTraitNodeTemplate";
local LINK_TEMPLATE = "SoulbindTreeNodeLinkTemplate";
local SELECT_ANIM_TEMPLATE = "PowerSwirlTemplate";

local SoulbindTreeEvents =
{
	"SOULBIND_NODE_LEARNED",
	"SOULBIND_NODE_UNLEARNED",
	"SOULBIND_PATH_CHANGED",
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
	elseif event == "SOULBIND_NODE_UNLEARNED" then
		local nodeID = ...;
		self:OnNodeUnlearned(nodeID);
	elseif event == "SOULBIND_PATH_CHANGED" then
		self:OnPathChanged();
	elseif event == "CURSOR_CHANGED" then
		local isDefault, newCursorType, oldCursorType = ...;
		self:OnCursorChanged(isDefault, oldCursorType);
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
	self:StopThenApplyAttentionAnims();

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

function SoulbindTreeMixin:OnNodeLearned(nodeID)
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
	PlaySound(SOUNDKIT.SOULBINDS_NODE_LEARNED);
end

function SoulbindTreeMixin:OnNodeUnlearned(nodeID)
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
end

function SoulbindTreeMixin:OnPathChanged()
	-- Temp. Removed once the tree isn't being reset.
	Soulbinds.SetPathChangePending(true);
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);
	PlaySound(SOUNDKIT.SOULBINDS_NODE_LEARNED);
	Soulbinds.SetPathChangePending(false);
end

function SoulbindTreeMixin:SelectNode(button, buttonName)
	if buttonName == "LeftButton" and (button:IsUnselected() or button:IsSelectable()) then
		if button:IsSelectable() then
			self:PlayNodeSelectionAnim(button);
		end

		C_Soulbinds.SelectNode(button:GetID());
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
	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	local linked = false;
	if IsModifiedClick("CHATLINK") then
		local link = GetSpellLink(button:GetSpellID());
		linked = HandleModifiedItemClick(link);
	end

	if not linked then
		self:SelectNode(button, buttonName);
	end
end

function SoulbindTreeMixin:OnConduitClicked(button, buttonName)
	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	if buttonName == "RightButton" then
		C_Soulbinds.RemovePendingConduit(button:GetID());
 	elseif Soulbinds.HasConduitAtCursor() then
		if not button:IsUnavailable() then
			self:TryInstallConduitAtCursor(button);
		end
	else
		local linked = false;
		local conduit = button:GetConduit();
		if conduit and IsModifiedClick("CHATLINK") then
			local link = C_Soulbinds.GetConduitHyperlink(conduit:GetConduitID(), conduit:GetConduitRank());
			linked = HandleModifiedItemClick(link);
		end

		if not linked then
			self:SelectNode(button, buttonName);
		end
	end
end

function SoulbindTreeMixin:OnConduitReceiveDrag(button)
	if C_Soulbinds.CanModifySoulbind() and not button:IsUnavailable() then
		self:TryInstallConduitAtCursor(button);
	end
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
	if C_Soulbinds.IsConduitInstalled(button:GetID()) then
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

function SoulbindTreeMixin:StopNodeAnimations()
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:StopAnimations();
	end
end

function SoulbindTreeMixin:ApplyConduitEnterAnim(conduitType)
	if not C_Soulbinds.CanModifySoulbind() then
		return;
	end

	local canAnimateConduit = (function()
		local canAnimate = function(nodeFrame, conduitType)
			return nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) and not C_Soulbinds.IsConduitInstalled(nodeFrame:GetID());
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
			nodeFrame:SetConduitPickupAnimShown(true);
		end
	end
end

function SoulbindTreeMixin:OnCollectionConduitEnter(conduitType)
	local oldTimer = self.mouseOverTimer;
	if oldTimer then
		self.mouseOverTimer:Cancel();
		self.mouseOverTimer = nil;
	end

	if not Soulbinds.HasConduitAtCursor() then
		if self.mouseOverConduit ~= conduitType or not oldTimer then
			self:StopNodeAnimations();
			self:ApplyConduitEnterAnim(conduitType);
		end
	end

	self.mouseOverConduit = conduitType;
end

function SoulbindTreeMixin:OnCollectionConduitLeave()
	if not Soulbinds.HasConduitAtCursor() then
		if self.mouseOverTimer then
			self.mouseOverTimer:Cancel();
		end

		self.mouseOverTimer = C_Timer.NewTicker(.1, function()
			self:StopThenApplyAttentionAnims();
			self.mouseOverTimer = nil;
		end, 1);
	end
end

function SoulbindTreeMixin:OnCursorChanged(isDefault, oldCursorType)
	if isDefault and oldCursorType == Enum.UICursorType.ConduitCollectionItem then
		local previewConduitType = Soulbinds.GetPreviewConduitType();
		if previewConduitType then
			self:StopNodeAnimations();
			self:ApplyConduitEnterAnim(previewConduitType);
		else
			self:StopThenApplyAttentionAnims();
		end
		self.handleCursor = false;
	end
end

function SoulbindTreeMixin:StopThenApplyAttentionAnims()
	self:StopNodeAnimations();
	
	local selectableCount = AccumulateIf(self.nodeFrames, 
		function(nodeFrame)
			return nodeFrame:IsSelectable();
		end
	);

	local canModifySoulbind = C_Soulbinds.CanModifySoulbind();
	local multipleSelectable = selectableCount > 1;
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:SetActivationOverlayShown(nodeFrame:IsSelectable(), canModifySoulbind, multipleSelectable);
	end

	if selectableCount == 0 then
		for _, nodeFrame in pairs(self.nodeFrames) do
			if nodeFrame:IsSelected() and nodeFrame:IsConduit() and not nodeFrame:GetConduit() then
				nodeFrame:SetAttentionAnimShown(canModifySoulbind);
			end
		end
	end
end

function SoulbindTreeMixin:TryInstallConduitInSlot(nodeID, conduitID)
	if C_Soulbinds.IsConduitInstalled(nodeID) then
		return;
	end

	if C_Soulbinds.IsConduitInstalledInSoulbind(self.soulbindID, conduitID) then
		return;
	end

	local pendingConduitID = C_Soulbinds.GetPendingConduitID(nodeID);
	if pendingConduitID and pendingConduitID == conduitID then
		return;
	end

	local pendingNodeID = C_Soulbinds.GetPendingNodeIDInSoulbind(self.soulbindID, conduitID);
	if pendingNodeID > 0 then
		C_Soulbinds.RemovePendingConduit(pendingNodeID);
		StaticPopup_Show("SOULBIND_DIALOG_MOVE_CONDUIT", nil, nil);
	end

	C_Soulbinds.AddPendingConduit(nodeID, conduitID);

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
				y = y + NegateIf(cellChevronDist, row < 4);
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
	for _, node in ipairs(nodes) do
		local nodeID = node.ID;
		local nodeFrame = self.nodeFrames[nodeID];
		nodeFrame:Init(node);
		nodeFrame:SetAnimDuration(animDuration);
	end

	for _, nodeFrame in pairs(self.nodeFrames) do
		local state = nodeFrame:GetState();
		for _, linkFrame in ipairs(nodeFrame:GetLinks()) do
			local linkToFrame = self.linkToFrames[linkFrame];
			local linkToFrameState = linkToFrame:GetState();
			linkFrame:SetState(linkToFrame:IsSelected() and state or Enum.SoulbindNodeState.Unselected);
		end
	end

	self:StopThenApplyAttentionAnims();
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