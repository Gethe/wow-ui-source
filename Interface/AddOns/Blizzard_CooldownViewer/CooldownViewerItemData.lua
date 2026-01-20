CooldownViewerItemDataMixin = {};

function CooldownViewerItemDataMixin:SetCooldownID(cooldownID, forceSet)
	if forceSet or self.cooldownID ~= cooldownID then
		self.cooldownID = cooldownID;
		self:OnCooldownIDSet();
	end
end

function CooldownViewerItemDataMixin:FindLinkedSpellForCurrentAuras()
	if self.cooldownInfo and self.cooldownInfo.linkedSpellIDs then
		for _, spellID in ipairs(self.cooldownInfo.linkedSpellIDs) do
			local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID);
			if auraData then
				return spellID;
			end
		end
	end

	return nil;
end

function CooldownViewerItemDataMixin:OnCooldownIDSet()
	self.cooldownInfo = CooldownViewerSettings:GetDataProvider():GetCooldownInfoForID(self:GetCooldownID());
	self.validAlertTypes = nil;

	self:ClearEditModeData();

	-- If one of the item's linked spells currenly has an active aura, it needs to be linked now because
	-- the UNIT_AURA event for it may have already happened and there might not be another one. e.g. the
	-- case of an infinite duration aura.
	local linkedSpellID = self:FindLinkedSpellForCurrentAuras();
	if linkedSpellID then
		self:SetLinkedSpell(linkedSpellID);
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
	self.validAlertTypes = nil;
	self:ClearAuraInstanceInfo();
	self:ClearTotemData();

	self:RefreshData();
	self:UpdateShownState();
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
	return cooldownInfo and cooldownInfo.linkedSpellID;
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
	if cooldownInfo.linkedSpellID and spellID == self:GetBaseSpellID() then
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
	return cooldownInfo and cooldownInfo.spellID;
end

--[[
	NOTE: In general the order of precedence for getting the spellID from a cooldown item is:
	1. Active Aura
	2. Active Linked Spell (usually because a matching aura is active)
	3. Override tooltip spell even if the linked spell is not active, it will always be one of the associated linkedSpellIDs
	4. Override Spell
	5. Base Spell

	There are some cases where the base spell may be preferred over the override spell, because the client API for spells already takes overrides into account.
	In those cases, the aura/tooltip override is checked manually.
--]]
function CooldownViewerItemDataMixin:GetSpellID()
	local auraSpellID = self:GetAuraSpellID();
	if auraSpellID then
		return auraSpellID;
	end

	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo then
		if cooldownInfo.linkedSpellID then
			return cooldownInfo.linkedSpellID;
		end

		if cooldownInfo.overrideTooltipSpellID then
			return cooldownInfo.overrideTooltipSpellID;
		end

		if cooldownInfo.overrideSpellID then
			return cooldownInfo.overrideSpellID;
		end

		return cooldownInfo.spellID;
	end

	return nil;
end

function CooldownViewerItemDataMixin:SpellIDMatchesAnyAssociatedSpellIDs(spellID)
	if spellID == self:GetAuraSpellID() then
		return true;
	end

	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo then
		if cooldownInfo.linkedSpellID == spellID then
			return true;
		end

		if cooldownInfo.overrideTooltipSpellID == spellID then
			return true;
		end

		if cooldownInfo.overrideSpellID == spellID then
			return true;
		end

		if cooldownInfo.spellID == spellID then
			return true;
		end

		if cooldownInfo.linkedSpellIDs then
			for _, linkedSpellID in ipairs(cooldownInfo.linkedSpellIDs) do
				if linkedSpellID == spellID then
					return true;
				end
			end
		end
	end

	return false;
end

function CooldownViewerItemDataMixin:GetAuraSpellID()
	return self.auraSpellID;
end

function CooldownViewerItemDataMixin:GetAuraSpellInstanceID()
	return self.auraInstanceID;
end

function CooldownViewerItemDataMixin:SetAuraInstanceInfo(auraInfo)
	local auraSpellID, auraInstanceID = auraInfo.spellId, auraInfo.auraInstanceID;
	if self.auraInstanceID ~= auraInstanceID or self.auraSpellID ~= auraSpellID then
		self.auraInstanceID = auraInstanceID;
		self.auraSpellID = auraSpellID;

		self:OnAuraInstanceInfoSet(auraSpellID, auraInstanceID);
	end
end

function CooldownViewerItemDataMixin:ClearAuraInstanceInfo()
	local auraSpellID, auraInstanceID = self.auraSpellID, self.auraInstanceID;
	if auraSpellID or auraInstanceID then
		self.auraInstanceID = nil;
		self.auraSpellID = nil;

		self:OnAuraInstanceInfoCleared(auraSpellID, auraInstanceID);
	end
end

function CooldownViewerItemDataMixin:OnAuraInstanceInfoSet(_auraSpellID, _auraInstanceID)
	-- override as needed
end

function CooldownViewerItemDataMixin:OnAuraInstanceInfoCleared(_auraSpellID, _auraInstanceID)
	-- override as needed
end

function CooldownViewerItemDataMixin:GetSpellCooldownInfo()
	local spellID = self:GetSpellID();
	if not spellID then
		return nil;
	end

	return C_Spell.GetSpellCooldown(spellID);
end

function CooldownViewerItemDataMixin:GetSpellChargeInfo()
	-- To ensure that charges work correctly for cooldown items that are actively cast, apply auras, and have charges
	-- only check the override or base spell ids.
	-- NOTE: This uses internal data instead of the spellID API for perf reasons
	local info = self:GetCooldownInfo();
	if info then
		local chargeSpellID = info.overrideSpellID or info.spellID;
		if chargeSpellID then
			return C_Spell.GetSpellCharges(chargeSpellID);
		end
	end

	return nil;
end

function CooldownViewerItemDataMixin:GetFallbackSpellTexture()
	-- override as needed
	return nil;
end

function CooldownViewerItemDataMixin:GetSpellTexture()
	-- Checking auraSpellID here is done instead of calling self:GetSpellID() because of the override texture logic.
	local auraSpellID = self:GetAuraSpellID();
	if auraSpellID then
		return C_Spell.GetSpellTexture(auraSpellID);
	end

	local linkedSpellID = self:GetLinkedSpell();
	if linkedSpellID then
		return C_Spell.GetSpellTexture(linkedSpellID);
	end

	-- Overriding the tooltip also serves to override the texture
	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo and cooldownInfo.overrideTooltipSpellID then
		return C_Spell.GetSpellTexture(cooldownInfo.overrideTooltipSpellID);
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

local targetAuraCacheTime;
local targetAuraCache;
local function GetTargetAurasCached()
	local now = GetTime();
	if not targetAuraCache or not targetAuraCacheTime or now ~= targetAuraCacheTime then
		targetAuraCache = C_UnitAuras.GetUnitAuras("target", "HARMFUL|PLAYER") or {};
		targetAuraCacheTime = now;
	end

	return targetAuraCache;
end

function CooldownViewerItemDataMixin:GetTargetRelatedAuraInfo()
	for _, aura in ipairs(GetTargetAurasCached()) do
		if self:SpellIDMatchesAnyAssociatedSpellIDs(aura.spellId) then
			return aura;
		end
	end

	return nil;
end

function CooldownViewerItemDataMixin:GetAuraData()
	-- TODO: Cache these results.

	-- TODO: If we get enough cases where having the aura means "it's active" then there are some other checks that can be nuked
	local spellID = self:GetSpellID();
	if spellID then
		local selfAura = C_UnitAuras.GetPlayerAuraBySpellID(spellID);
		if selfAura then
			self.auraDataUnit = "player";
			return selfAura;
		end
	end

	local targetAura = self:GetTargetRelatedAuraInfo();
	if targetAura then
		self.auraDataUnit = "target";
		return targetAura;
	end

	self.auraDataUnit = nil;
	return nil;
end

function CooldownViewerItemDataMixin:GetAuraDataUnit()
	return self.auraDataUnit;
end

function CooldownViewerItemDataMixin:CanUseAuraForCooldown()
	local cooldownInfo = self:GetCooldownInfo();
	if cooldownInfo and cooldownInfo.flags then
		return not FlagsUtil.IsSet(cooldownInfo.flags, Enum.CooldownSetSpellFlags.HideAura);
	end

	return true;
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
	local auraInstanceID = self:GetAuraSpellInstanceID();
	if auraInstanceID then
		tooltip:SetUnitAuraByAuraInstanceID(self:GetAuraDataUnit(), auraInstanceID);
	else
		local spellID = self:GetSpellID();
		if spellID then
			local isPet = false;
			tooltip:SetSpellByID(spellID, isPet);
		end
	end
end

function CooldownViewerItemDataMixin:UpdateShownState()
	-- override as needed
end

function CooldownViewerItemDataMixin:IsActivelyCast()
	-- override as necessary; this indicates that the spell related to the cooldown item can be cast by the player and isn't a proc.
	return false;
end

function CooldownViewerItemDataMixin:CheckCreateValidAlertTypes()
	if not self.validAlertTypes then
		self.validAlertTypes = tInvert(C_CooldownViewer.GetValidAlertTypes(self:GetCooldownID()));
	end
end

function CooldownViewerItemDataMixin:GetValidAlertTypes()
	self:CheckCreateValidAlertTypes();
	return self.validAlertTypes;
end

function CooldownViewerItemDataMixin:CanTriggerAlertType(alertType)
	local validAlertTypes = self:GetValidAlertTypes();
	return validAlertTypes[alertType] ~= nil;
end

function CooldownViewerItemDataMixin:GetFirstValidAlertType()
	local validAlertTypes = self:GetValidAlertTypes();
	local alertType = next(validAlertTypes);
	return alertType;
end

function CooldownViewerItemDataMixin:CanTriggerAnyAlertType()
	return self:GetFirstValidAlertType() ~= nil;
end
