local scanUnits = { "player", "target" };

CooldownViewerItemDataMixin = {};

function CooldownViewerItemDataMixin:SetCooldownID(cooldownID, forceSet)
	if forceSet or self.cooldownID ~= cooldownID then
		self.cooldownID = cooldownID;
		self:OnCooldownIDSet();
	end
end

function CooldownViewerItemDataMixin:FindLinkedSpellForCurrentAuras(unit)
	if self.cooldownInfo and self.cooldownInfo.linkedSpellIDs then
		for _, spellID in ipairs(self.cooldownInfo.linkedSpellIDs) do
			local auraData = C_UnitAuras.GetUnitAuraBySpellID(unit, spellID);
			if auraData and auraData.sourceUnit == "player" then
				return spellID, auraData;
			end
		end
	end

	return nil;
end

function CooldownViewerItemDataMixin:RefreshLinkedSpell()
	-- If one of the item's linked spells currenly has an active aura, it needs to be linked now because
	-- the UNIT_AURA event for it may have already happened and there might not be another one. e.g. the
	-- case of an infinite duration aura.
	-- This could also happen if the remaining duration on an aura expires (but the aura is somehow not removed via UNIT_AURA)
	-- and there's still an active aura on the player that hasn't expired so the expiration of the current linked spell
	-- needs to cause the cooldown item to update its linked spells.
	local linkedSpellChanged;
	for _index, unit in ipairs(scanUnits) do
		local linkedSpellID, auraData = self:FindLinkedSpellForCurrentAuras(unit);
		linkedSpellChanged = self:SetLinkedSpell(linkedSpellID) or linkedSpellChanged;

		if auraData then
			self:SetAuraInstanceInfo(auraData);
			return linkedSpellChanged;
		end
	end

	return linkedSpellChanged;
end

function CooldownViewerItemDataMixin:OnCooldownIDSet()
	self.cooldownInfo = CooldownViewerSettings:GetDataProvider():GetCooldownInfoForID(self:GetCooldownID());
	self.validAlertTypes = nil;

	self:ClearEditModeData();
	self:RefreshLinkedSpell();
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
		self:ClearAuraInstanceInfo();

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

	local auraData = self:GetAuraDataCached();
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

local function GetTargetAurasFilterString(unit)
	if UnitExists(unit) then
		if UnitIsFriend("player", unit) then
			return "HELPFUL|PLAYER|INCLUDE_NAME_PLATE_ONLY";
		end
	end

	-- If there's no unit or it's not a friend, assume we want debuffs.
	return "HARMFUL|PLAYER";
end

local targetAuraCacheTime = {};
local targetAuraCache = {};
local function GetUnitAurasCached(unit, timeNow)
	local now = timeNow or GetTime();
	if not targetAuraCacheTime[unit] or now ~= targetAuraCacheTime[unit] then
		targetAuraCacheTime[unit] = now;

		local filterString = GetTargetAurasFilterString(unit);
		if filterString then
			targetAuraCache[unit] = C_UnitAuras.GetUnitAuras(unit, filterString) or {};
		else
			targetAuraCache[unit] = {};
		end
	end

	return targetAuraCache[unit];
end

local function IsAuraActive(aura, timeNow)
	return aura.expirationTime == nil or aura.expirationTime == 0 or aura.expirationTime > timeNow;
end

function CooldownViewerItemDataMixin:GetUnitRelatedAuraInfo(unit, timeNow)
	for _, aura in ipairs(GetUnitAurasCached(unit, timeNow)) do
		if IsAuraActive(aura, timeNow) and self:SpellIDMatchesAnyAssociatedSpellIDs(aura.spellId) then
			return aura;
		end
	end

	return nil;
end

function CooldownViewerItemDataMixin:GetAuraData()
	local timeNow = GetTime();
	for _index, unit in ipairs(scanUnits) do
		local auraData = self:GetUnitRelatedAuraInfo(unit, timeNow);
		if auraData then
			self.auraDataCached = auraData;
			self.auraDataUnit = unit;
			return auraData;
		end
	end

	self.auraDataUnit = nil;
	self.auraDataCached = nil;
	return nil;
end

function CooldownViewerItemDataMixin:GetAuraDataCached()
	return self.auraDataCached;
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

function CooldownViewerItemDataMixin:GetTotemSlot()
	return self.totemData and self.totemData.slot or nil;
end

function CooldownViewerItemDataMixin:ClearTotemData()
	self.totemData = nil;
end

local playerTotemCacheTime;
local playerTotemCache;
local function GetPlayerTotemsCached()
	local now = GetTime();
	if not playerTotemCache or not playerTotemCacheTime or now ~= playerTotemCacheTime then
		playerTotemCache = {};
		local workingCacheBySpellID = {};

		for slot = 1, GetNumTotemSlots() do
			local hasTotem, name, startTime, duration, _icon, modRate, spellID = GetTotemInfo(slot);
			if hasTotem then
				local totemInfo = {
					spellID = spellID,
					slot = slot,
					expirationTime = (startTime or 0) + (duration or 0),
					duration = duration,
					name = name,
					modRate = modRate;
				};

				-- Replace totems with duplicate spells with the one that has the longer duration
				if spellID then
					local existingTotem = workingCacheBySpellID[spellID];
					if existingTotem then
						if totemInfo.expirationTime > existingTotem.expirationTime then
							workingCacheBySpellID[spellID] = totemInfo;
						end
					else
						workingCacheBySpellID[spellID] = totemInfo;
					end
				end
			end
		end

		for _spellID, totemInfo in pairs(workingCacheBySpellID) do
			playerTotemCache[totemInfo.slot] = totemInfo;
		end

		playerTotemCacheTime = now;
	end

	return playerTotemCache;
end

function CooldownViewer_MarkTotemCacheDirty()
	playerTotemCacheTime = nil;
end

function CooldownViewerItemDataMixin:GetCurrentPlayerTotemCache()
	return GetPlayerTotemsCached();
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
	local auraUnit = self:GetAuraDataUnit();
	if auraInstanceID and auraUnit then
		tooltip:SetUnitAuraByAuraInstanceID(auraUnit, auraInstanceID, "INCLUDE_NAME_PLATE_ONLY");
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
