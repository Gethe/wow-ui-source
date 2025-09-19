CooldownViewerItemDataMixin = {};

function CooldownViewerItemDataMixin:SetCooldownID(cooldownID, forceSet)
	if self.cooldownID ~= cooldownID or forceSet then
		self.cooldownID = cooldownID;
		self:OnCooldownIDSet();
	end
end

function CooldownViewerItemDataMixin:OnCooldownIDSet()
	self.cooldownInfo = CooldownViewerSettings:GetDataProvider():GetCooldownInfoForID(self.cooldownID);

	self:ClearEditModeData();

	-- If one of the item's linked spells currenly has an active aura, it needs to be linked now because
	-- the UNIT_AURA event for it may have already happened and there might not be another one. e.g. the
	-- case of an infinite duration aura.
	if self.cooldownInfo and self.cooldownInfo.linkedSpellIDs then
		for _, spellID in ipairs(self.cooldownInfo.linkedSpellIDs) do
			local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID);
			if auraData then
				self:SetLinkedSpell(spellID);
			end
		end
	end

	self:RefreshData();
	self:UpdateShownState();
end

function CooldownViewerItemDataMixin:ClearCooldownID()
	if self.cooldownID ~= nil then
		self.cooldownID = nil;
		self:OnCooldownIDCleared();
	end
end

function CooldownViewerItemDataMixin:OnCooldownIDCleared()
	self.cooldownInfo = nil;
	self:ClearAuraInfo();
	self:ClearTotemData();

	self:RefreshData();
	self:UpdateShownState();
end

function CooldownViewerItemDataMixin:ClearAuraInfo()
	-- override as needed
end

function CooldownViewerItemDataMixin:ClearTotemData()
	-- override as needed
end

function CooldownViewerItemDataMixin:HasEditModeData()
	-- override as needed
	return false;
end

function CooldownViewerItemDataMixin:ClearEditModeData()
	-- override if necessary
end

function CooldownViewerItemDataMixin:SetOverrideSpell(overrideSpellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if cooldownInfo.overrideSpellID == overrideSpellID then
		return false;
	end

	-- Capture the previous override for rare conditions involving spells that remove their
	-- override before the Update Cooldown Event is sent.
	if cooldownInfo.overrideSpellID and overrideSpellID == nil then
		cooldownInfo.previousOverrideSpellID = cooldownInfo.overrideSpellID;
	end

	cooldownInfo.overrideSpellID = overrideSpellID;

	return true;
end

function CooldownViewerItemDataMixin:SetLinkedSpell(linkedSpellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if cooldownInfo.linkedSpellID == linkedSpellID then
		return false;
	end

	cooldownInfo.linkedSpellID = linkedSpellID;

	return true;
end

function CooldownViewerItemDataMixin:GetLinkedSpell()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end

	return cooldownInfo.linkedSpellID;
end

function CooldownViewerItemDataMixin:UpdateLinkedSpell(spellID)
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return false;
	end

	if not cooldownInfo.linkedSpellIDs then
		return false;
	end

	-- If the provided spellId matches the base spell then remove the linked spell's precedence.
	if cooldownInfo.linkedSpellID and spellID == cooldownInfo.spellID then
		return self:SetLinkedSpell(nil);
	end

	-- If the provided spellID is one of the item's linked spells, then give precedence to the linked spell.
	if tContains(cooldownInfo.linkedSpellIDs, spellID) then
		return self:SetLinkedSpell(spellID);
	end

	return false;
end

function CooldownViewerItemDataMixin:GetCooldownID()
	return self.cooldownID;
end

function CooldownViewerItemDataMixin:GetCooldownInfo()
	return self.cooldownInfo;
end

-- Prefer calling GetSpellID in most cases. This function is provided for unique cases where the base spell is needed.
function CooldownViewerItemDataMixin:GetBaseSpellID()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end

	return cooldownInfo.spellID;
end

function CooldownViewerItemDataMixin:GetSpellID()
	if self.auraSpellID then
		return self.auraSpellID;
	end

	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return nil;
	end

	if cooldownInfo.linkedSpellID then
		return cooldownInfo.linkedSpellID;
	end

	if cooldownInfo.overrideSpellID then
		return cooldownInfo.overrideSpellID;
	end

	return cooldownInfo.spellID;
end

function CooldownViewerItemDataMixin:GetTooltipSpellID()
	-- NOTE: This doesn't apply to auraInstanceID at all, call this if it's known
	-- that a spellID is needed for the tooltip.
	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo and cooldownInfo.overrideTooltipSpellID then
		return cooldownInfo.overrideTooltipSpellID;
	end

	local spellID = self:GetSpellID();
	return spellID;
end

function CooldownViewerItemDataMixin:GetSpellCooldownInfo()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end

	return C_Spell.GetSpellCooldown(spellID);
end

function CooldownViewerItemDataMixin:GetSpellChargeInfo()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end

	return C_Spell.GetSpellCharges(spellID);
end

function CooldownViewerItemDataMixin:GetFallbackSpellTexture()
	-- override as needed
	return nil;
end

function CooldownViewerItemDataMixin:GetSpellTexture()
	-- Overriding the tooltip also serves to override the texture
	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo and cooldownInfo.overrideTooltipSpellID then
		return C_Spell.GetSpellTexture(cooldownInfo.overrideTooltipSpellID);
	end

	local linkedSpellID = self:GetLinkedSpell();
	if linkedSpellID then
		return C_Spell.GetSpellTexture(linkedSpellID);
	end

	-- Intentionally always use the base spell when calling C_Spell.GetSpellTexture. Its internal logic will handle the override if needed.
	local spellID = self:GetBaseSpellID();
	if spellID then
		return C_Spell.GetSpellTexture(spellID);
	end

	return self:GetFallbackSpellTexture();
end

function CooldownViewerItemDataMixin:GetNameText()
	local totemData = self:GetTotemData();
	if totemData then
		return totemData.name;
	end

	local auraData = self:GetAuraData();
	if auraData then
		return auraData.name;
	end

	local spellID = self:GetSpellID();
	if spellID then
		return C_Spell.GetSpellName(spellID);
	end

	if self:HasEditModeData() then
		return HUD_EDIT_MODE_COOLDOWN_VIEWER_EXAMPLE_BUFF_NAME;
	end

	return "";
end

function CooldownViewerItemDataMixin:GetAuraData()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end

	return C_UnitAuras.GetPlayerAuraBySpellID(spellID);
end

function CooldownViewerItemDataMixin:UseAuraForCooldown()
	local cooldownInfo = self:GetCooldownInfo();
	if not cooldownInfo then
		return true;
	end

	if cooldownInfo.flags == nil then
		return true;
	end

	return FlagsUtil.IsSet(cooldownInfo.flags, Enum.CooldownSetSpellFlags.HideAura) == false;
end

function CooldownViewerItemDataMixin:SetTotemData(totemData)
	self.totemData = totemData;
end

function CooldownViewerItemDataMixin:GetTotemData()
	return self.totemData;
end

function CooldownViewerItemDataMixin:ClearTotemData()
	self.totemData = nil;
end

function CooldownViewerItemDataMixin:RefreshData()
	assertsafe(false, "RefreshData must be overridden by a derived mixin.");
end

function CooldownViewerItemDataMixin:SetTooltipAnchor(tooltip)
	GameTooltip_SetDefaultAnchor(tooltip, self);
end

function CooldownViewerItemDataMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	self:SetTooltipAnchor(tooltip);
	self:RefreshTooltip();
	tooltip:Show();
end

function CooldownViewerItemDataMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function CooldownViewerItemDataMixin:RefreshTooltip()
	local tooltip = GetAppropriateTooltip();
	if self.auraInstanceID then
		tooltip:SetUnitBuffByAuraInstanceID("player", self.auraInstanceID);
	else
		local spellID = self:GetTooltipSpellID();
		if spellID then
			local isPet = false;
			tooltip:SetSpellByID(spellID, isPet);
		end
	end
end

function CooldownViewerItemDataMixin:UpdateShownState()
	-- override as needed
end
