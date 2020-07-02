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

function SoulbindTreeNodeMixin:SetPulseAnimDuration(seconds)
	self.RingOverlay.Pulse.FadeIn:SetDuration(seconds);
	self.RingOverlay.Pulse.FadeOut:SetDuration(seconds);
end

function SoulbindTreeNodeMixin:Init(node)
	self:SetNode(node);
	self:UpdateVisuals();
end

function SoulbindTreeNodeMixin:OnStateTransition(oldState, newState)
	if oldState == Enum.SoulbindNodeState.Selectable and newState == Enum.SoulbindNodeState.Selected then
		local NODE_SELECTION_FX_1 = 42;
		local NODE_SELECTION_FX_2 = 48;
		local modelScene = self:GetFxModelScene();
		modelScene:AddEffect(NODE_SELECTION_FX_1, self);
		modelScene:AddEffect(NODE_SELECTION_FX_2, self);
	end
end

function SoulbindTreeNodeMixin:GetFxModelScene()
	return self.FxModelScene;
end

function SoulbindTreeNodeMixin:Reset()
	self.node = nil;
	self.linkFrames = {};
	self.RingOverlay.Pulse:Stop();
	self:GetFxModelScene():ClearEffects();
	self:UnregisterEvents();
end

function SoulbindTreeNodeMixin:UpdateVisuals()
	if self:IsUnavailable() then
		self.Icon:SetDesaturated(true);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(false);
		self.MouseOverlay:SetDesaturated(false);
	elseif self:IsUnselectable() then
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

function SoulbindTreeNodeMixin:IsUnselectable()
	return self:GetState() == Enum.SoulbindNodeState.Unselectable;
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

function SoulbindTreeNodeMixin:SetActivationOverlayShown(shown, displayArrow)
	self.RingOverlay.Pulse:SetPlaying(shown);
	self.Arrow:SetShown(displayArrow or false);
	self.Arrow2:SetShown(displayArrow or false);
end

function SoulbindTreeNodeMixin:StopAnimations()
	self.RingOverlay.Pulse:Stop();
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

local function GetConduitEmblemAtlas(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return "Soulbinds_Tree_Conduit_Icon_Attack";
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return "Soulbinds_Tree_Conduit_Icon_Protect";
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return "Soulbinds_Tree_Conduit_Icon_Utility";
	end
end

function SoulbindConduitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);

	local onFinished = function()
		for _, ringFrame in ipairs(self.installAnimTextures) do
			ringFrame:Hide();
		end
	end;

	self.InstallAnim:SetScript("OnFinished", onFinished);
end

function SoulbindConduitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);

	if node.conduitID > 0 then
		local conduit = SoulbindConduitMixin_Create(node.conduitID, node.conduitRank);
		self:SetConduitID_Internal(conduit);
	else
		self:SetConduitID_Internal(nil);
	end

	local atlas = GetConduitEmblemAtlas(self:GetConduitType());
	self.Emblem:SetAtlas(atlas);
	self.EmblemBg:SetAtlas(atlas)
	self.EmblemBg:SetVertexColor(0, 0, 0);
end

function SoulbindConduitNodeMixin:UpdateVisuals()
	SoulbindTreeNodeMixin.UpdateVisuals(self);
	
	if self:IsUnavailable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring_Disabled", false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	elseif self:IsUnselectable() then
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.Emblem:SetDesaturated(true);
		self.Emblem:SetAlpha(.75);
	else
		self.Ring:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.MouseOverlay:SetAtlas("Soulbinds_Tree_Conduit_Ring", false);
		self.Emblem:SetDesaturated(false);
		self.Emblem:SetAlpha(1.0);
	end
end

function SoulbindConduitNodeMixin:Reset()
	SoulbindTreeNodeMixin.Reset(self);
	self.conduit = nil;

	self.Icon:Hide();
	self.InstallAnim:Stop();
end

function SoulbindConduitNodeMixin:OnClick(...)
	SoulbindTreeNodeMixin.OnClick(self, ...)
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

function SoulbindConduitNodeMixin:SetConduit(conduit)
	self:SetConduitID_Internal(conduit);

	if conduit then
		self:PlayInstallAnim();
		PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_INSTALLED);

		local CONDUIT_INSTALL_FX_1 = 48;
		local CONDUIT_INSTALL_FX_2 = 44;
		self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_1, self);
		self:GetFxModelScene():AddEffect(CONDUIT_INSTALL_FX_2, self);
	end

	if GameTooltip:IsShown() then
		GameTooltip:Hide();
		self:LoadTooltip();
	end
end

function SoulbindConduitNodeMixin:SetInstallOverlayShown(shown)
	if shown then
		self.RingOverlay2:Show();
		self.RingOverlay2:SetAlpha(1.0);
	else
		self.RingOverlay2:Hide();
	end
end

function SoulbindConduitNodeMixin:SetInstallOverlayPlaying(playing)
	if playing then
		self.RingOverlay2:Show();
		self.RingOverlay2.Pulse:Play();
	else
		self.RingOverlay2:Hide();
	end
end

function SoulbindConduitNodeMixin:PlayInstallAnim()
	for _, ringFrame in ipairs(self.installAnimTextures) do
		ringFrame:Show();
	end
	self.InstallAnim:Play();
end

function SoulbindConduitNodeMixin:StopAnimations()
	SoulbindTreeNodeMixin.StopAnimations(self);

	self.RingOverlay2.Pulse:Stop();
	self.RingOverlay2:Hide();
end

function SoulbindConduitNodeMixin:IsInstalled()
	return self.conduit ~= nil;
end

function SoulbindConduitNodeMixin:GetRank()
	return self.conduit and self.conduit:GetRank() or 0;
end

function SoulbindConduitNodeMixin:GetConduitID()
	return self.conduit and self.conduit:GetConduitID() or 0;
end

function SoulbindConduitNodeMixin:SetConduitID_Internal(conduit)
	local oldConduit = self.conduit;
	self.conduit = conduit;
	if conduit then
		if not conduit.Matches(oldConduit) then
			conduit:ContinueOnSpellLoad(GenerateClosure(self.OnConduitSpellLoad, self));
		end
	else
		self.Icon:Hide();
	end	
end

function SoulbindConduitNodeMixin:OnConduitSpellLoad()
	local spellID = self.conduit:GetSpellID();
	self.Icon:SetTexture(GetSpellTexture(spellID));
	self.Icon:Show();
end

local function GetUninstalledConduitStrings(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return CONDUIT_TYPE_POTENCY, CONDUIT_TYPE_DESC_POTENCY;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return CONDUIT_TYPE_ENDURANCE, CONDUIT_TYPE_DESC_ENDURANCE;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return CONDUIT_TYPE_FINESSE, CONDUIT_TYPE_DESC_FINESSE;
	end
end

function SoulbindConduitNodeMixin:LoadTooltip()
	if self.conduit then
		local onConduitLoad = function()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetConduit(self.conduit:GetConduitID(), self.conduit:GetRank()); 
			GameTooltip:Show();
		end;
		self.conduit:ContinueOnSpellLoad(onConduitLoad);
	else
		local title, description = GetUninstalledConduitStrings(self:GetConduitType());
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, title);
		GameTooltip_AddNormalLine(GameTooltip, description, true);
		GameTooltip:Show();
	end
end