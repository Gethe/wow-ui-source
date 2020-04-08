local NODE_LEARNED_SOUND_KIT = 856;
local CONDUIT_START_INTALL_SOUND_KIT = 856;
local CONDUIT_TEMPLATE = "SoulbindConduitNodeTemplate";
local TRAIT_TEMPLATE = "SoulbindTraitNodeTemplate";
local LINK_TEMPLATE = "SoulbindTreeNodeLinkTemplate";

local SoulbindTreeEvents =
{
	"SOULBIND_NODE_LEARNED",
	"SOULBIND_NODE_UNLEARNED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"CURSOR_UPDATE",
	"BAG_UPDATE",
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
		self:OnNodeChanged(...);
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		self:OnConduitInstalled(...);
	elseif event == "SOULBIND_CONDUIT_UNINSTALLED" then
		self:OnConduitUninstalled(...);
	elseif event == "CURSOR_UPDATE" then
		self:OnCursorStateChanged();
	elseif event == "BAG_UPDATE" then
		self:OnBagChanged();
	end
end

function SoulbindTreeMixin:OnShow()
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

	PlaySound(NODE_LEARNED_SOUND_KIT);
end

function SoulbindTreeMixin:OnNodeClicked(button, buttonID)
	if not self:IsEditable() then
		return;
	end

	if button:IsSelectable() then
		C_Soulbinds.LearnNode(button:GetID());
	end
end

function SoulbindTreeMixin:OnConduitClicked(button, buttonID)
	if not self:IsEditable() then
		return;
	end

	if Soulbinds.HasConduitAtCursor() then
		if button:IsOwned() then
			self:TryInstallConduitAtCursor(button);
		end
	else
		self:OnNodeClicked(button, buttonID);
	end
end

function SoulbindTreeMixin:OnConduitReceiveDrag(button)
	if not self:IsEditable() then
		return;
	end

	if button:IsOwned() then
		self:TryInstallConduitAtCursor(button);
	end
end

function SoulbindTreeMixin:TryInstallConduitAtCursor(button)
	local itemLocation, conduitType = Soulbinds.GetConduitInfoAtCursor();
	if itemLocation and button:IsConduitType(conduitType) then
		local nodeID = button:GetID();
		self:TryInstallConduitInSlot(nodeID, itemLocation);
	end
end

function SoulbindTreeMixin:IsConduitDragInProgress()
	return select(2, Soulbinds.GetConduitInfoAtCursor()) ~= nil;
end

function SoulbindTreeMixin:StopNodeAnimations()
	for _, nodeFrame in pairs(self.nodeFrames) do
		nodeFrame:StopAnimations();
	end
end

function SoulbindTreeMixin:ApplyTargetedConduitAnimation(conduitType)
	self:StopNodeAnimations();

	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsOwned() and nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) then
			nodeFrame:SetInstallOverlayPlaying(true);
		end
	end
end

function SoulbindTreeMixin:OnInventoryItemEnter(bag, slot)
	local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
	if not itemLocation:IsValid() then
		return;
	end

	local item = Item:CreateFromItemLocation(itemLocation);
	local itemCallback = function()
		local conduitType = C_Soulbinds.GetItemConduitType(item:GetItemLocation());
		if conduitType then
			self.handleLeave = true;
			
			if not self:IsConduitDragInProgress() then
				self:ApplyTargetedConduitAnimation(conduitType);
			end
		end
	end;
	item:ContinueOnItemLoad(itemCallback);
end

function SoulbindTreeMixin:OnInventoryItemLeave(bag, slot)
	if self.handleLeave and not self:IsConduitDragInProgress() then
		self:ApplyNodeAnimations();
	end
	self.handleLeave = false;
end

function SoulbindTreeMixin:OnCursorStateChanged()
	local itemLocation, conduitType = Soulbinds.GetConduitInfoAtCursor();
	if conduitType then
		self.handleCursor = true;

		self:StopNodeAnimations();

		for _, nodeFrame in pairs(self.nodeFrames) do
			if nodeFrame:IsOwned() and nodeFrame:IsConduit() and nodeFrame:IsConduitType(conduitType) then
				nodeFrame:SetInstallOverlayShown(true);
			end
		end
	elseif self.handleCursor then
		self.handleCursor = false;

		self:EvaluateItemAtCursor();
	end
end

function SoulbindTreeMixin:OnBagChanged()
	self:EvaluateItemAtCursor();
end

function SoulbindTreeMixin:EvaluateItemAtCursor()
	local itemLocation = ContainerFrame_FindItemLocationUnderCursor();
	if itemLocation then
		if itemLocation:IsValid() then
			local item = Item:CreateFromItemLocation(itemLocation);
			local itemCallback = function()
				local conduitType = C_Soulbinds.GetItemConduitType(itemLocation);
				if conduitType then
					self:ApplyTargetedConduitAnimation(conduitType);
				else
					self:ApplyNodeAnimations();
				end
			end;
			item:ContinueOnItemLoad(itemCallback);

			return;
		end
	end

	self:ApplyNodeAnimations();
end

function SoulbindTreeMixin:ApplyNodeAnimations()
	self:StopNodeAnimations();
	
	local selectableNodeCount = 0;
	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsSelectable() then
			selectableNodeCount = selectableNodeCount + 1;
		end
	end

	if selectableNodeCount > 0 and C_Soulbinds.IsAtSoulbindForge() then
		local displayArrow = selectableNodeCount > 1;
		
		for _, nodeFrame in pairs(self.nodeFrames) do
			if nodeFrame:IsSelectable() then
				nodeFrame:SetActivationOverlayShown(true, displayArrow);
			end
		end
	else
		for _, nodeFrame in pairs(self.nodeFrames) do
			nodeFrame:SetActivationOverlayShown(false);
			
			if nodeFrame:IsOwned() and nodeFrame:IsConduit() and not nodeFrame:IsInstalled() then
				nodeFrame:SetInstallOverlayPlaying(true);
			end
		end	
	end
end

function SoulbindTreeMixin:OnConduitInstalled(nodeID, itemID)
	local conduitFrame = self.nodeFrames[nodeID];
	if conduitFrame then
		conduitFrame:SetConduitID(itemID);
	end
end

function SoulbindTreeMixin:OnConduitUninstalled(nodeID)
	local conduitFrame = self.nodeFrames[nodeID];
	if conduitFrame then
		conduitFrame:SetConduitID(0);
	end
end

function SoulbindTreeMixin:CommitInstallConduit(nodeID, itemLocation)
	C_Soulbinds.InstallConduitInSlot(nodeID, itemLocation);
	
	local nodeFrame = self.nodeFrames[nodeID];
	if nodeFrame then
		nodeFrame:PlayInstallAnim();
	end
end

function SoulbindTreeMixin:TryInstallConduitInSlot(nodeID, itemLocation)
	local item = Item:CreateFromItemLocation(itemLocation);
	local itemCallback = function()
		if C_Soulbinds.HasInstalledConduit(nodeID) then
			local dialogCallback = GenerateClosure(self.CommitInstallConduit, self, nodeID, itemLocation);
			StaticPopup_Show("SOULBIND_DIALOG_REPLACE_CONDUIT", nil, nil, dialogCallback);
			
			PlaySound(CONDUIT_START_INTALL_SOUND_KIT);
		else
			self:CommitInstallConduit(nodeID, itemLocation);
		end
		ClearCursor();
	end;

	item:ContinueOnItemLoad(itemCallback);
end

function SoulbindTreeMixin:UninstallConduits()
	C_Soulbinds.UninstallConduits();
	
	for _, nodeFrame in pairs(self.nodeFrames) do
		if nodeFrame:IsConduit() then
			nodeFrame:SetConduitID(0);
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
			linkFrame:SetState(linkToFrame:IsSelected() and state or Enum.SoulbindNodeState.Unselectable);
		end
	end

	self:SetEditable(tree.editable);
	self:ApplyNodeAnimations();
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