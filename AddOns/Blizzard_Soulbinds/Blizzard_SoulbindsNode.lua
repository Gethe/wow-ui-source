local CONDUIT_INSTALLED_SOUND_KIT = 856;

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

function SoulbindTreeNodeMixin:AddContentToTooltip()
	GameTooltip_SetTitle(GameTooltip, self.spell:GetSpellName());
	GameTooltip_AddNormalLine(GameTooltip, self.spell:GetSpellDescription(), true);
end

function SoulbindTreeNodeMixin:SetupTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:AddContentToTooltip();
	GameTooltip:Show();
end

function SoulbindTreeNodeMixin:LoadTooltip()
	local onLoad = function()
		self:SetupTooltip()
	end;
	self.spell:ContinueOnSpellLoad(onLoad);
end

function SoulbindTreeNodeMixin:Init(node)
	self.node = node;
	self.spell = Spell:CreateFromSpellID(self:GetSpellID());

	self:UpdateVisuals();
end

function SoulbindTreeNodeMixin:Reset()
	self.linkFrames = {};
	self.RingOverlay.Pulse:Stop();
	self:UnregisterEvents();
end

function SoulbindTreeNodeMixin:UpdateVisuals()
	if self:IsUnavailable() then
		self.Icon:SetDesaturated(true);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(false);
	elseif self:IsUnselectable() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Show();
		self.Ring:SetDesaturated(true);
	elseif self:IsSelectable() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
	elseif self:IsSelected() then
		self.Icon:SetDesaturated(false);
		self.IconOverlay:Hide();
		self.Ring:SetDesaturated(false);
	end
end

function SoulbindTreeNodeMixin:IsOwned()
	return self:IsSelected(); -- FIXME
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
	return self.node.state;
end

function SoulbindTreeNodeMixin:GetNode()
	return self.node;
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
end

function SoulbindTreeNodeMixin:StopAnimations()
	self.RingOverlay.Pulse:Stop();
	self.Arrow:Hide();
end

SoulbindTraitNodeMixin = CreateFromMixins(SoulbindTreeNodeMixin);

function SoulbindTraitNodeMixin:OnLoad()
	SoulbindTreeNodeMixin.OnLoad(self);
end

function SoulbindTraitNodeMixin:Init(node)
	SoulbindTreeNodeMixin.Init(self, node);

	self.Icon:SetTexture(self:GetIcon());
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
	if conduitType == Enum.SoulbindConduitType.Zealous then
		return "Soulbinds_Tree_Conduit_Icon_Attack";
	elseif conduitType == Enum.SoulbindConduitType.Vigilant then
		return "Soulbinds_Tree_Conduit_Icon_Protect";
	elseif conduitType == Enum.SoulbindConduitType.Cunning then
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
	self:SetConduitID_Internal(node.conduitID);

	local atlas = GetConduitEmblemAtlas(node.conduitType);
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

function SoulbindConduitNodeMixin:IsConduitType(type)
	return self.node.conduitType == type;
end

function SoulbindConduitNodeMixin:SetConduitID(itemID)
	self:SetConduitID_Internal(itemID);

	if itemID > 0 then
		self:PlayInstallAnim();
		PlaySound(CONDUIT_INSTALLED_SOUND_KIT);
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

function SoulbindConduitNodeMixin:SetConduitID_Internal(itemID)
	if itemID > 0 then
		if not self.conduit or self.conduit:GetItemID() ~= itemID then
			self.conduit = Item:CreateFromItemID(itemID);
			local onLoad = function()
				self.Icon:SetTexture(self.conduit:GetItemIcon());
				self.Icon:Show();
			end;
			self.conduit:ContinueOnItemLoad(onLoad);
		end
	else
		self.Icon:Hide();
		self.conduit = nil;
	end
end

function SoulbindTreeNodeMixin:LoadTooltip()
	if self.conduit then
		local loaded = {false, false};
		local onLoad = function(index)
			loaded[index] = true;
			if (loaded[1] and loaded[2]) then
				self:SetupTooltip();
			end
		end;

		local onSpellLoad = function()
			onLoad(1);
		end;
		self.spell:ContinueOnSpellLoad(onSpellLoad);

		local onConduitLoad = function()
			onLoad(2);
		end;
		self.conduit:ContinueOnItemLoad(onConduitLoad);
	else
		local onLoad = function()
			self:SetupTooltip();
		end;
		self.spell:ContinueOnSpellLoad(onLoad);
	end
end

function SoulbindConduitNodeMixin:AddContentToTooltip()
	SoulbindTreeNodeMixin.AddContentToTooltip(self);

	if self.conduit then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		EmbeddedItemTooltip_SetItemByID(GameTooltip.ItemTooltip, self.conduit:GetItemID());
	end
end