local CONDUIT_TEMPLATE = "SoulbindConduitNodeTemplate";
local TRAIT_TEMPLATE = "SoulbindTraitNodeTemplate";
local LINK_TEMPLATE = "SoulbindTreeNodeLinkTemplate";

local SoulbindTreeEvents =
{
	"SOULBIND_NODE_LEARNED",
	"SOULBIND_NODE_UNLEARNED",
	"SOULBIND_PATH_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"CURSOR_UPDATE",
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
end

function SoulbindTreeMixin:OnEvent(event, ...)
	if event == "SOULBIND_NODE_LEARNED" or event == "SOULBIND_NODE_UNLEARNED" then
		local nodeID = ...;
		self:OnNodeChanged(nodeID);
	elseif event == "SOULBIND_PATH_CHANGED" then
		self:OnPathChanged();
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		local nodeID, conduitData = ...;
		self:OnConduitInstalled(nodeID, conduitData);
	elseif event == "SOULBIND_CONDUIT_UNINSTALLED" then
		local nodeID = ...;
		self:OnConduitUninstalled(nodeID);
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorStateChanged();
	end
end

function SoulbindTreeMixin:OnShow()
	self:StopThenApplyNodeAnimations();

	if self.constructed then
		FrameUtil.RegisterFrameForEvents(self, SoulbindTreeEvents);
	end
end

function SoulbindTreeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindTreeEvents);
end

function SoulbindTreeMixin:IsEditable()
	return self.editable;
end

function SoulbindTreeMixin:SetEditable(editable)
	self.editable = editable;
end

function SoulbindTreeMixin:HasSelectedNodes()
	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsSelected() then
			return true;
		end
	end
	return false;
end

function SoulbindTreeMixin:OnNodeChanged(nodeID)
	self:Init(C_Soulbinds.GetSoulbindData(self.soulbindID));
	self:TriggerEvent(SoulbindTreeMixin.Event.OnNodeChanged);

	PlaySound(SOUNDKIT.SOULBINDS_NODE_LEARNED);
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
	if buttonName == "LeftButton" then
		if button:IsUnselected() or button:IsSelectable() then
			C_Soulbinds.SelectNode(button:GetID());
		end
	end
end

function SoulbindTreeMixin:OnNodeClicked(button, buttonName)
	if not self:IsEditable() then
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
	if not self:IsEditable() then
		return;
	end

	if buttonName == "RightButton" then
 		local nodeID = button:GetID();
 		if C_Soulbinds.HasInstalledConduit(nodeID) then
			local callback = GenerateClosure(C_Soulbinds.UninstallConduitInSlot, nodeID);
			StaticPopup_Show("SOULBIND_DIALOG_UNINSTALL_CONDUIT", nil, nil, callback);
 		end
 	elseif Soulbinds.HasConduitAtCursor() then
		if not button:IsUnavailable() then
			self:TryInstallConduitAtCursor(button);
		end
	else
		local linked = false;
		if button:IsInstalled() and IsModifiedClick("CHATLINK") then
			local conduitID = button:GetConduitID();
			local conduitRank = button:GetRank();
			local link = C_Soulbinds.GetConduitHyperlink(conduitID, conduitRank);
			linked = HandleModifiedItemClick(link);
		end

		if not linked then
			self:SelectNode(button, buttonName);
		end
	end
end

function SoulbindTreeMixin:OnConduitReceiveDrag(button)
	if not self:IsEditable() then
		return;
	end

	if not button:IsUnavailable() then
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
	local conduitType, conduitID = Soulbinds.GetConduitDataAtCursor();
	if conduitType then
		if button:IsConduitType(conduitType) then
			local nodeID = button:GetID();
			self:TryInstallConduitInSlot(nodeID, conduitID);
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

function SoulbindTreeMixin:ApplyTargetedConduitAnimation(conduitType, requireEditable)
	if requireEditable and not self:IsEditable() then
		return;
	end

	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsSelected() and nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) then
			local withArrows = requireEditable;
			nodeFrame:SetConduitMouseoverAnimShown(true, withArrows);
		end
	end
end

function SoulbindTreeMixin:OnCollectionConduitEnter(conduitType)
	self.handleLeave = true;

	if not Soulbinds.HasConduitAtCursor() then
		self:StopNodeAnimations();
		local requireEditable = false;
		self:ApplyTargetedConduitAnimation(conduitType, requireEditable);
	end
end

function SoulbindTreeMixin:OnCollectionConduitLeave()
	if self.handleLeave and not Soulbinds.HasConduitAtCursor() then
		self:StopThenApplyNodeAnimations();
	end
	self.handleLeave = false;
end

function SoulbindTreeMixin:OnCursorStateChanged()
	local conduitType = Soulbinds.GetConduitDataAtCursor();
	if conduitType then
		self.handleCursor = true;

		if self:IsEditable() then
			self:StopNodeAnimations();

			for _, nodeFrame in pairs(self.nodeFrames) do
				if nodeFrame:IsSelected() and nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) then
					nodeFrame:SetConduitPickupAnimShown(true);
				end
			end
		end
	elseif self.handleCursor then
		self.handleCursor = false;
	end
end

function SoulbindTreeMixin:StopThenApplyNodeAnimations()
	self:StopNodeAnimations();
	
	local selectableCount = AccumulateIf(self.nodeFrames, 
		function(nodeFrame)
			return nodeFrame:IsSelectable();
		end
	);

	local editable = C_Soulbinds.IsAtSoulbindForge();
	local multipleSelectable = selectableCount > 1;
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:SetActivationOverlayShown(nodeFrame:IsSelectable(), editable, multipleSelectable);
	end

	if selectableCount == 0 then
		for _, nodeFrame in pairs(self.nodeFrames) do
			if nodeFrame:IsSelected() and nodeFrame:IsConduit() and not nodeFrame:IsInstalled() then
				nodeFrame:SetAvailableConduitsAnimShown(editable);
			end
		end
	end
end

function SoulbindTreeMixin:OnConduitInstalled(nodeID, conduitData)
	local conduitFrame = self.nodeFrames[nodeID];
	if conduitFrame then
		local conduit = SoulbindConduitMixin_Create(conduitData.conduitID, conduitData.conduitRank);
		conduitFrame:SetConduit(conduit);
	end
end

function SoulbindTreeMixin:OnConduitUninstalled(nodeID)
	local conduitFrame = self.nodeFrames[nodeID];
	if conduitFrame then
		conduitFrame:SetConduit(nil);
	end
end

function SoulbindTreeMixin:CommitInstallConduit(nodeID, conduitID)
	local result = C_Soulbinds.InstallConduitInSlot(nodeID, conduitID);
	if result == Enum.SoulbindConduitInstallResult.Success then
		local nodeFrame = self.nodeFrames[nodeID];
		if nodeFrame then
			nodeFrame:PlayInstallAnim();
		end
	
		ClearCursor();
	elseif result == Enum.SoulbindConduitInstallResult.DuplicateConduit then
		UIErrorsFrame:AddMessage(ERR_SOULBIND_DUPLICATE_CONDUIT, RED_FONT_COLOR:GetRGBA());
	end
	
	return result;
end

function SoulbindTreeMixin:TryInstallConduitInSlot(nodeID, conduitID)
	if C_Soulbinds.HasInstalledConduit(nodeID) then
		local dialogCallback = GenerateClosure(self.CommitInstallConduit, self, nodeID, conduitID);
		StaticPopup_Show("SOULBIND_DIALOG_REPLACE_CONDUIT", nil, nil, dialogCallback);
		
		PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_START_INSTALL);
	else
		local nodeFrame = self.nodeFrames[nodeID];
		if nodeFrame:IsUnselected() then
			local dialogCallback = GenerateClosure(self.CommitInstallConduit, self, nodeID, conduitID);
			StaticPopup_Show("SOULBIND_DIALOG_INSTALL_CONDUIT_UNUSABLE", nil, nil, dialogCallback);
		
			PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_START_INSTALL_UNUSABLE);
		else
			self:CommitInstallConduit(nodeID, conduitID);
		end
	end
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

	local atForge = C_Soulbinds.IsAtSoulbindForge();
	local pulseDuration = atForge and .6 or .8;
	for _, node in ipairs(nodes) do
		local nodeID = node.ID;
		local nodeFrame = self.nodeFrames[nodeID];
		nodeFrame:Init(node);
		nodeFrame:SetPulseAnimDuration(pulseDuration);
	end

	for _, nodeFrame in pairs(self.nodeFrames) do
		local state = nodeFrame:GetState();
		for _, linkFrame in ipairs(nodeFrame:GetLinks()) do
			local linkToFrame = self.linkToFrames[linkFrame];
			local linkToFrameState = linkToFrame:GetState();
			linkFrame:SetState(linkToFrame:IsSelected() and state or Enum.SoulbindNodeState.Unselected);
		end
	end

	self:SetEditable(tree.editable);
	self:StopThenApplyNodeAnimations();
end

StaticPopupDialogs["SOULBIND_DIALOG_REPLACE_CONDUIT"] = {
	text = SOULBIND_DIALOG_REPLACE_CONDUIT,
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

StaticPopupDialogs["SOULBIND_DIALOG_UNINSTALL_CONDUIT"] = {
	text = SOULBIND_DIALOG_UNINSTALL_CONDUIT,

	button1 = ACCEPT,
	button2 = CANCEL,
	enterClicksFirstButton = true,
	hideOnEscape = 1,
	showAlert = 1,

	OnButton1 = function(self, callback)
		callback();
	end,
};