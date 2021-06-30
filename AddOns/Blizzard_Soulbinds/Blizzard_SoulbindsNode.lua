SoulbindTreeNodeMixin = CreateFromMixins(CallbackRegistryMixin);

SoulbindTreeNodeMixin:GenerateCallbackEvents(
	{
		"OnDragReceived",
		"OnClick",
	}
);

function SoulbindTreeNodeMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self.linkFrames = {};
end

function SoulbindTreeNodeMixin:OnClick(buttonID)
	self:TriggerEvent(SoulbindTreeNodeMixin.Event.OnClick, self, buttonID);
end

function SoulbindTreeNodeMixin:OnEnter()
	self:LoadTooltip();
	self.MouseOverlay:Show();
end

function SoulbindTreeNodeMixin:OnLeave()
	GameTooltip:Hide();
	self.MouseOverlay:Hide();
end

function SoulbindTreeNodeMixin:SetAnimDuration(seconds)
	self.RingOverlay.Anim.FadeIn:SetDuration(seconds);
	self.RingOverlay.Anim.FadeOut:SetDuration(seconds);
end

function SoulbindTreeNodeMixin:Init(node)
	self:SetNode(node);
	self:UpdateVisuals();
end

function SoulbindTreeNodeMixin:PlaySelectionEffect()
	local modelScene = self:GetFxModelScene();
	local NODE_SELECTION_FX_1 = 42;
	local NODE_SELECTION_FX_2 = 48;
	modelScene:AddEffect(NODE_SELECTION_FX_1, self);
	modelScene:AddEffect(NODE_SELECTION_FX_2, self);
end

function SoulbindTreeNodeMixin:OnStateTransition(oldState, newState)
	if newState == Enum.SoulbindNodeState.Selected and oldState == Enum.SoulbindNodeState.Selectable then
		self:PlaySelectionEffect();
		local LEARN_SHAKE_DELAY = 0;
		C_Timer.After(LEARN_SHAKE_DELAY, GenerateClosure(self.Shake, self));
	end
end

function SoulbindTreeNodeMixin:Shake()
	if self:IsShown() then
		local SHAKE = { { x = 0, y = -5}, { x = 0, y = 5}, { x = 0, y = -5}, { x = 0, y = 5}, { x = -3, y = -2}, { x = 2, y = 2}, { x = -1, y = -2}, { x = 3, y = 2}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, };
		local SHAKE_DURATION = 0.1;
		local SHAKE_FREQUENCY = 0.001;
		ScriptAnimationUtil.ShakeFrame(UIParent, SHAKE, SHAKE_DURATION, SHAKE_FREQUENCY)
	end
end

function SoulbindTreeNodeMixin:GetFxModelScene()
	return self.FxModelScene;
end

function SoulbindTreeNodeMixin:Reset()
	self.node = nil;
	self.linkFrames = {};
	self.RingOverlay:Hide();
	self.RingOverlay.Anim:Stop();
	self:GetFxModelScene():ClearEffects();
	self:UnregisterEvents();
end

function SoulbindTreeNodeMixin:UpdateVisuals()
	if self:IsUnavailable() then
		self.Icon:SetDesaturated(true);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	elseif self:IsUnselected() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(true);
		self.MouseOverlay:SetDesaturated(true);
	elseif self:IsSelectable() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	elseif self:IsSelected() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	end
end

function SoulbindTreeNodeMixin:IsSelected()
	return self:GetState() == Enum.SoulbindNodeState.Selected;
end

function SoulbindTreeNodeMixin:IsSelectable()
	return self:GetState() == Enum.SoulbindNodeState.Selectable;
end

function SoulbindTreeNodeMixin:IsUnselected()
	return self:GetState() == Enum.SoulbindNodeState.Unselected;
end

function SoulbindTreeNodeMixin:IsUnavailable()
	return self:GetState() == Enum.SoulbindNodeState.Unavailable;
end

function SoulbindTreeNodeMixin:GetState()
	return self.node and self.node.state or nil;
end

function SoulbindTreeNodeMixin:GetNode()
	return self.node;
end

function SoulbindTreeNodeMixin:SetNode(node)
	local oldState = self:GetState();
	self.node = node;
	local newState = self:GetState();
	if oldState and oldState ~= newState then
		self:OnStateTransition(oldState, newState);
	end
end

function SoulbindTreeNodeMixin:AddLink(linkFrame)
	table.insert(self.linkFrames, linkFrame);
end

function SoulbindTreeNodeMixin:GetLinks()
	return self.linkFrames;
end

function SoulbindTreeNodeMixin:GetID()
	return self.node.ID;
end

function SoulbindTreeNodeMixin:GetRow()
	return self.node.row;
end

function SoulbindTreeNodeMixin:GetColumn()
	return self.node.column;
end

function SoulbindTreeNodeMixin:GetIcon()
	return self.node.icon;
end

function SoulbindTreeNodeMixin:GetSpellID()
	return self.node.spellID;
end

function SoulbindTreeNodeMixin:GetParentNodeIDs()
	return self.node.parentNodeIDs;
end

function SoulbindTreeNodeMixin:IsConduit()
	return self.node.conduitType ~= nil;
end

function SoulbindTreeNodeMixin:GetConduitID()
	return self.node and self.node.conduitID or nil;
end

function SoulbindTreeNodeMixin:GetConduitRank()
	return self.node.conduitRank;
end

function SoulbindTreeNodeMixin:GetUnavailableReason()

	if self.node.failureRenownRequirement then

		local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
		local renownRequirement = self.node.failureRenownRequirement;

		return SOULBIND_NODE_RENOWN_ERROR_FORMAT:format(renownRequirement, renownLevel);
		
	elseif self.node.playerConditionReason then
		return self.node.playerConditionReason;
	end
end

function SoulbindTreeNodeMixin:SetSelectableAnimShown(shown, editable, canSelectMultiple)
	self.RingOverlay:SetShown(shown);
	
	local animated = shown and editable;
	if animated then
		self.RingOverlay.Anim:SetPlaying(shown);
	end

	local showArrow = animated and canSelectMultiple;
	self.Arrow:SetShown(showArrow);
	self.Arrow2:SetShown(showArrow);
end

function SoulbindTreeNodeMixin:StopAnimations()
	self.RingOverlay:Hide();
	self.RingOverlay.Anim:Stop();
	self.Arrow:Hide();
	self.Arrow2:Hide();
end

SoulbindTraitNodeMixin = CreateFromMixins(SoulbindTreeNodeMixin);

function SoulbindTraitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);
end

function SoulbindTraitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);
	
	if not self.spell then
		self.spell = Spell:CreateFromSpellID(self:GetSpellID());
	end

	self.Icon:SetTexture(self:GetIcon());
end

function SoulbindTraitNodeMixin:LoadTooltip()
	local onSpellLoad = function()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spell:GetSpellID());
		self:AddTooltipContents();
		GameTooltip:Show();
	end;
	self.spell:ContinueOnSpellLoad(onSpellLoad);
end

function SoulbindTraitNodeMixin:Reset()
	SoulbindTreeNodeMixin.Reset(self);

	self.spell = nil;
end

function SoulbindTraitNodeMixin:UpdateVisuals()
	SoulbindTreeNodeMixin.UpdateVisuals(self);

	if self:IsUnavailable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Ring_Disabled", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Ring_Disabled", false);
	else
		self.Ring:SetAtlas("Soulbinds_Tree_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Ring", false);
	end
end

SoulbindConduitNodeMixin = CreateFromMixins(SoulbindTreeNodeMixin);

local SoulbindConduitNodeEvents =
{
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"CURSOR_CHANGED",
}

function SoulbindConduitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);
	self.animTextures =
	{
		self.PickupOverlay,
		self.PickupOverlay2,
		self.PickupArrowsOverlay,
		self.UnsocketedWarning,
		self.UnsocketedWarning2,
	};
end

function SoulbindConduitNodeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindConduitNodeEvents);
end

function SoulbindConduitNodeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindConduitNodeEvents);
end

function SoulbindConduitNodeMixin:OnEnter()
	SoulbindTreeNodeMixin.OnEnter(self);

	self:TrySetConduitListConduitsPulsePlaying();
end

function SoulbindConduitNodeMixin:OnLeave()
	SoulbindTreeNodeMixin.OnLeave(self);

	SoulbindViewer:SetConduitListConduitsPulsePlaying(self:GetConduitType(), false);
end

function SoulbindConduitNodeMixin:TrySetConduitListConduitsPulsePlaying()
	if not Soulbinds.HasConduitAtCursor() and C_Soulbinds.GetConduitDisplayed(self:GetID()) == 0 then
		SoulbindViewer:SetConduitListConduitsPulsePlaying(self:GetConduitType(), true);
	end
end

function SoulbindConduitNodeMixin:EvaluateSetConduitListConduitsPulsePlaying()
	local playing = false;
	if not Soulbinds.HasConduitAtCursor() and C_Soulbinds.GetConduitDisplayed(self:GetID()) == 0 then
		playing = true;
	end
	SoulbindViewer:SetConduitListConduitsPulsePlaying(self:GetConduitType(), playing);
end

function SoulbindConduitNodeMixin:Reset()
	SoulbindTreeNodeMixin.Reset(self);
	self.conduit = nil;
	self.Icon:Hide();
	for _, texture in ipairs(self.SocketAnimTextures) do
		texture.Anim:Stop();
	end
end

function SoulbindConduitNodeMixin:SetConduit(conduitID, initializing)
	local oldConduitID = self.conduit and self.conduit:GetConduitID() or 0;
	self.conduit = SoulbindConduitMixin_Create(conduitID);
	local newConduitID = self.conduit:GetConduitID();

	self:DisplayConduit();

	if not initializing and conduitID > 0 and C_Soulbinds.GetInstalledConduitID(self:GetID()) ~= conduitID and (oldConduitID ~= newConduitID) then
		self:PlaySocketAnimation();
		PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_ADD_PENDING);
		
		if GameTooltip:IsShown() then
			GameTooltip:Hide();
			self:LoadTooltip();
		end
	end

	self:UpdatePendingAnim();
	self:UpdateEnhancedSheenAnim();
end

function SoulbindConduitNodeMixin:GetConduit()
	return self.conduit;
end

function SoulbindConduitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);
	
	local atlas = Soulbinds.GetConduitEmblemAtlas(self:GetConduitType());
	self.Emblem:SetAtlas(atlas);
	self.EmblemBg:SetAtlas(atlas)
	self.EmblemBg:SetVertexColor(0, 0, 0);

	local conduitID = C_Soulbinds.GetConduitDisplayed(self:GetID());
	local initializing = true;
	self:SetConduit(conduitID, initializing);

	self:DisplayConduit();
	self:UpdatePendingAnim();
	self:UpdateEnhancedSheenAnim();
end

function SoulbindConduitNodeMixin:PlaySocketAnimation()
	for _, texture in ipairs(self.SocketAnimTextures) do
		texture.Anim:Play();
	end

	local CONDUIT_INSTALL_FX_1 = 48;
	local CONDUIT_INSTALL_FX_2 = 44;
	self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_1, self);
	self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_2, self);
end

function SoulbindConduitNodeMixin:OnInstalled()
	self:Init(C_Soulbinds.GetNode(self:GetID()));
	
	self:PlaySelectionEffect();
	self:UpdatePendingAnim();
	self:UpdateEnhancedSheenAnim();
end

function SoulbindConduitNodeMixin:OnUninstalled()
	self:Init(C_Soulbinds.GetNode(self:GetID()));
end

function SoulbindConduitNodeMixin:IsPending()
	return self.conduit:GetConduitID() ~= self:GetConduitID();
end

function SoulbindConduitNodeMixin:UpdatePendingAnim()
	local pending = self:IsPending();
	self.Pending:SetShown(pending);
	self.PendingStick.RotateAnim:SetPlaying(pending);
	self.PendingStick2.RotateAnim:SetPlaying(pending);
end

function SoulbindConduitNodeMixin:IsEnhanced()
	return self.node.socketEnhanced;
end

function SoulbindConduitNodeMixin:UpdateVisuals()
	SoulbindTreeNodeMixin.UpdateVisuals(self);

	local ringAtlas = self:IsEnhanced() and "Soulbinds_Tree_Conduit_Ring_Enhanced" or "Soulbinds_Tree_Conduit_Ring";
	
	if self:IsUnavailable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	elseif self:IsUnselected() then
		self.Ring:SetAtlas(ringAtlas, false);
		self.MouseOverlay:SetAtlas(ringAtlas, false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	else
		self.Ring:SetAtlas(ringAtlas, false);
		self.MouseOverlay:SetAtlas(ringAtlas, false);
		self.Emblem:SetDesaturated(false);
		self.Emblem:SetAlpha(1.0);
	end
end

function SoulbindConduitNodeMixin:OnClick(...)
	SoulbindTreeNodeMixin.OnClick(self, ...)
end

function SoulbindConduitNodeMixin:OnEvent(event, ...)
	if event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID = ...;
		if nodeID == self:GetID() then
			local conduitID = C_Soulbinds.GetConduitDisplayed(nodeID);
			self:SetConduit(conduitID);

			self:EvaluateSetConduitListConduitsPulsePlaying();
		end
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		local nodeID, conduitData = ...;
		if nodeID == self:GetID() then
			self:OnInstalled();
		end
	elseif event == "SOULBIND_CONDUIT_UNINSTALLED" then
		local nodeID = ...;
		if nodeID == self:GetID() then
			self:OnUninstalled();
		end
	elseif event == "CURSOR_CHANGED" then
		local isDefault, newCursorType, oldCursorType = ...;
		if isDefault and oldCursorType == Enum.UICursorType.ConduitCollectionItem then
			if self:IsMouseOver() then
				self:TrySetConduitListConduitsPulsePlaying();
			end
		end
	end
end

function SoulbindConduitNodeMixin:OnReceiveDrag()
	self:TriggerEvent(SoulbindTreeNodeMixin.Event.OnDragReceived, self);
end

function SoulbindConduitNodeMixin:GetConduitType()
	return self.node.conduitType;
end

function SoulbindConduitNodeMixin:IsConduitType(type)
	return self:GetConduitType() == type;
end

function SoulbindConduitNodeMixin:SetUsingStaticAnimOverride(useAnimOverride)
	if useAnimOverride then
		self.PickupArrowsOverlay:SetAtlas(nil);
		self.PickupArrowsStatic:Show();
	else
		self.PickupArrowsOverlay:SetAtlas("Soulbinds_Tree_Conduit_Arrows", false);
		self.PickupArrowsStatic:Hide();
	end
end

function SoulbindConduitNodeMixin:EvaluatePickupAnimOverride(conduitID)
	if conduitID and conduitID > 0 then
		local appearsInstalledID = C_Soulbinds.FindNodeIDAppearingInstalled(Soulbinds.GetOpenSoulbindID(), conduitID);
		local useAnimOverride =  appearsInstalledID == self:GetID();
		self:SetUsingStaticAnimOverride(useAnimOverride);
	else
		local useAnimOverride = false;
		self:SetUsingStaticAnimOverride(useAnimOverride);
	end
end

function SoulbindConduitNodeMixin:SetConduitPickupAnimShown(shown, conduitID)
	for _, texture in ipairs(self.PickupAnimTextures) do
		texture:SetShown(shown);
		texture.Anim:SetPlaying(shown);
	end

	self:EvaluatePickupAnimOverride(conduitID);
end

function SoulbindConduitNodeMixin:SetUnsocketedWarningAnimShown(shown)
	for _, texture in ipairs(self.UnsocketedWarningTextures) do
		texture:SetShown(shown);
		texture.Anim:SetPlaying(shown);
	end
end

function SoulbindConduitNodeMixin:UpdateEnhancedSheenAnim()
	local playSheenAnim = self:IsEnhanced() and not self:IsPending() and (self:IsSelectable() or self:IsSelected());
	self.EnhancedNodeSheen.Anim:SetPlaying(playSheenAnim);
end

function SoulbindConduitNodeMixin:StopAnimations()
	SoulbindTreeNodeMixin.StopAnimations(self);

	for _, texture in ipairs(self.animTextures) do
		texture.Anim:Stop();
		texture:Hide();
	end
end

function SoulbindConduitNodeMixin:DisplayConduit()
	local conduit = self.conduit;
	if conduit:IsValid() then
		if not conduit.Matches(self:GetConduit()) then
			local onConduitSpellLoad = function()
				local spellID = conduit:GetSpellID();
				self.Icon:SetTexture(GetSpellTexture(spellID));
				self.Icon:Show();
			end
			conduit:ContinueOnSpellLoad(onConduitSpellLoad);
		end
	else
		self.Icon:Hide();
	end
end

function SoulbindTreeNodeMixin:AddNotInProximityLine()
	if self:IsConduit() then
		GameTooltip_AddErrorLine(GameTooltip, SOULBIND_CONDUIT_ACTIVATE_UNAVAIL);
	else
		GameTooltip_AddErrorLine(GameTooltip, SOULBIND_NODE_ACTIVATE_UNAVAIL);
	end
end

function SoulbindTreeNodeMixin:AddTooltipContents()
	if self:IsSelectable() then
		if C_Soulbinds.CanModifySoulbind() then
			GameTooltip_AddInstructionLine(GameTooltip, SOULBIND_NODE_ACTIVATE);
		else
			self:AddNotInProximityLine();
		end
	elseif self:IsUnselected() then
		local canModify = C_Soulbinds.CanModifySoulbind();
		local canAdjustFlow = C_Soulbinds.CanSwitchActiveSoulbindTreeBranch();

		if canModify or canAdjustFlow then
			GameTooltip_AddInstructionLine(GameTooltip, SOULBIND_NODE_SELECT_PATH);
		else
			GameTooltip_AddErrorLine(GameTooltip, SOULBIND_NODE_UNSELECTED);
		end
	elseif self:IsUnavailable() then
		local reason = self:GetUnavailableReason();
		if reason then
			GameTooltip_AddErrorLine(GameTooltip, reason);
		else
			if C_Soulbinds.CanModifySoulbind() then
				GameTooltip_AddErrorLine(GameTooltip, SOULBIND_NODE_DISCONNECTED);
			else
				self:AddNotInProximityLine();
			end
		end
	end
end

local function GetUninstalledConduitStrings(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_SLOT_POTENCY, CONDUIT_TYPE_DESC_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_SLOT_ENDURANCE, CONDUIT_TYPE_DESC_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_SLOT_FINESSE, CONDUIT_TYPE_DESC_FINESSE;
	end
end

function SoulbindConduitNodeMixin:LoadTooltip()
	local conduit = self:GetConduit();
	if conduit:IsValid() then
		local onConduitLoad = function()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			if self:IsEnhanced() then 
				GameTooltip:SetEnhancedConduit(conduit:GetConduitID(), conduit:GetConduitRank());
			else
				GameTooltip:SetConduit(conduit:GetConduitID(), conduit:GetConduitRank()); 
			end
			self:AddTooltipContents();
			GameTooltip:Show();
		end;
		conduit:ContinueOnSpellLoad(onConduitLoad);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if Soulbinds.HasConduitAtCursor() and not C_Soulbinds.CanModifySoulbind() then
			GameTooltip_AddErrorLine(GameTooltip, SOULBIND_CONDUIT_INSTALL_UNAVAIL);
		else
			local title, description = GetUninstalledConduitStrings(self:GetConduitType());
			GameTooltip_SetTitle(GameTooltip, title);
			if self:IsEnhanced() then 
				GameTooltip_AddColoredLine(GameTooltip, SOULBIND_CONDUIT_ENHANCED, SOULBIND_CONDUIT_ENHANCED_COLOR, false);
			end
			GameTooltip_AddNormalLine(GameTooltip, description);
			self:AddTooltipContents();
		end
		GameTooltip:Show();
	end
end