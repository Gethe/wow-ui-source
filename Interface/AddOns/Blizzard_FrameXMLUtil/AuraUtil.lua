DEFAULT_AURA_DURATION_FONT = "GameFontNormalSmall";
BUFF_DURATION_WARNING_TIME = 90;

--Aubrie TODO move these.. to something else
DebuffTypeColor = { };
DebuffTypeColor["none"]	=		{ r = 0.8000, g = 0.0000, b = 0.0000, a = 1 };
DebuffTypeColor["Magic"] = 		{ r = 0.0000, g = 0.5059, b = 1.0000, a = 1 };
DebuffTypeColor["Curse"] = 		{ r = 0.6235, g = 0.0235, b = 0.8941, a = 1 };
DebuffTypeColor["Disease"] =	{ r = 0.9451, g = 0.4157, b = 0.0353, a = 1 };
DebuffTypeColor["Poison"] = 	{ r = 0.4824, g = 0.7804, b = 0.0000, a = 1 };
DebuffTypeColor["Bleed"] =		{ r = 0.7216, g = 0.0000, b = 0.0588, a = 1 };
DebuffTypeColor[""]	= DebuffTypeColor["none"];

DebuffTypeSymbol = { };
DebuffTypeSymbol["Magic"] = DEBUFF_SYMBOL_MAGIC;
DebuffTypeSymbol["Curse"] = DEBUFF_SYMBOL_CURSE;
DebuffTypeSymbol["Disease"] = DEBUFF_SYMBOL_DISEASE;
DebuffTypeSymbol["Poison"] = DEBUFF_SYMBOL_POISON;
DebuffTypeSymbol["Bleed"] = DEBUFF_SYMBOL_BLEED;

AuraUtil = {};

local AuraUtilDataProvider = C_UnitAuras;
function AuraUtil.SetDataProvider(dataProvider)
	AuraUtilDataProvider = dataProvider;
end

function AuraUtil.ClearDataProvider()
	AuraUtil.SetDataProvider(C_UnitAuras);
end

local function CallDataProviderMethod(methodName, ...)
	return AuraUtilDataProvider[methodName](...);
end

function AuraUtil.GetAuraDataByAuraInstanceID(...)
	return CallDataProviderMethod("GetAuraDataByAuraInstanceID", ...);
end

-- For backwards compatibility with old APIs, this helper function returns aura data values unpacked in the same order as before.
function AuraUtil.UnpackAuraData(auraData)
	if not auraData then
		return nil;
	end

	return auraData.name,
		auraData.icon,
		auraData.applications,
		auraData.dispelName,
		auraData.duration,
		auraData.expirationTime,
		auraData.sourceUnit,
		auraData.isStealable,
		auraData.nameplateShowPersonal,
		auraData.spellId,
		auraData.canApplyAura,
		auraData.isBossAura,
		auraData.isFromPlayerOrPlayerPet,
		auraData.nameplateShowAll,
		auraData.timeMod,
		unpack(auraData.points);
end

local function FindAuraRecurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2, predicateArg3, ...)
	if ... == nil then
		return nil; -- Not found
	end
	if predicate(predicateArg1, predicateArg2, predicateArg3, ...) then
		return ...;
	end
	auraIndex = auraIndex + 1;
	return FindAuraRecurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2, predicateArg3, AuraUtil.UnpackAuraData(CallDataProviderMethod("GetAuraDataByIndex", unit, auraIndex, filter)));
end

-- Find an aura by any predicate, you can pass in up to 3 predicate specific parameters
-- The predicate will also receive all aura params, if the aura data matches return true
function AuraUtil.FindAura(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
	local auraIndex = 1;
	return FindAuraRecurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2, predicateArg3, AuraUtil.UnpackAuraData(CallDataProviderMethod("GetAuraDataByIndex", unit, auraIndex, filter)));
end

-- Finds the first aura that matches the name
-- Notes:
--		aura names are not unique!
--		aura names are localized, what works in one locale might not work in another
--			consider that in English two auras might have different names, but once localized they have the same name, so even using the localized aura name in a search it could result in different behavior
--		the unit could have multiple auras with the same name, this will only find the first
function AuraUtil.FindAuraByName(auraName, unit, filter)
	return AuraUtil.UnpackAuraData(CallDataProviderMethod("GetAuraDataBySpellName", unit, auraName, filter));
end

do
	local function ForEachAuraHelper(unit, filter, func, usePackedAura, continuationToken, ...)
		-- continuationToken is the first return value of UnitAuraSlots()
		local n = select('#', ...);
		for i=1, n do
			local slot = select(i, ...);
			local done;
			local auraInfo = CallDataProviderMethod("GetAuraDataBySlot", unit, slot);

			-- Protect against GetAuraDataBySlot desyncing with GetAuraSlots
			if auraInfo then
				if usePackedAura then
					done = func(auraInfo);
				else
					done = func(AuraUtil.UnpackAuraData(auraInfo));
				end
			end
			if done then
				-- if func returns true then no further slots are needed, so don't return continuationToken
				return nil;
			end
		end
		return continuationToken;
	end

	function AuraUtil.ForEachAura(unit, filter, batchSize, func, usePackedAura)
		if batchSize and batchSize <= 0 then
			return;
		end
		local continuationToken;
		repeat
			-- continuationToken is the first return value of UnitAuraSlots
			continuationToken = ForEachAuraHelper(unit, filter, func, usePackedAura, CallDataProviderMethod("GetAuraSlots", unit, filter, batchSize, continuationToken));
		until continuationToken == nil;
	end
end

function AuraUtil.DefaultAuraCompare(a, b)
	local aFromPlayer = (a.sourceUnit ~= nil) and UnitIsUnit("player", a.sourceUnit) or false;
	local bFromPlayer = (b.sourceUnit ~= nil) and UnitIsUnit("player", b.sourceUnit) or false;
	if aFromPlayer ~= bFromPlayer then
		return aFromPlayer;
	end

	if a.canApplyAura ~= b.canApplyAura then
		return a.canApplyAura;
	end

	return a.auraInstanceID < b.auraInstanceID;
end

function AuraUtil.BigDefensiveAuraCompare(a, b)
	-- Comparison rules, note that everything that's compared in here should be known to be a "big defensive" already.
	-- The longest duration that is NOT yours has the highest priority, then another defensive that is not yours even at shorter duration should be next priority,
	-- then show yours in center if there are no other defensives on the target.

	-- Keeping the "is player caster" in sync with DefaultAuraCompare:
	local aFromPlayer = (a.sourceUnit ~= nil) and UnitIsUnit("player", a.sourceUnit) or false;
	local bFromPlayer = (b.sourceUnit ~= nil) and UnitIsUnit("player", b.sourceUnit) or false;
	if aFromPlayer ~= bFromPlayer then
		return not aFromPlayer; -- Big difference from above, we prefer showing things that are not cast by the player
	end

	if a.expirationTime ~= b.expirationTime then
		return a.expirationTime > b.expirationTime;
	end

	return a.auraInstanceID < b.auraInstanceID;
end

AuraUtil.AuraFilters =
{
	Helpful = "HELPFUL",
	Harmful = "HARMFUL",
	Raid = "RAID",
	IncludeNameplateOnly = "INCLUDE_NAME_PLATE_ONLY",
	Player = "PLAYER",
	Cancelable = "CANCELABLE",
	NotCancelable = "NOT_CANCELABLE",
	Maw = "MAW",
	ExternalDefensive = "EXTERNAL_DEFENSIVE",
};

function AuraUtil.CreateFilterString(...)
	return string.join("|", ...);
end

AuraUtil.DispellableDebuffTypes =
{
	Magic = true,
	Curse = true,
	Disease = true,
	Poison = true,
	Bleed = true,
};

AuraUtil.AuraUpdateChangedType = EnumUtil.MakeEnum(
	"None",
	"Debuff",
	"Buff",
	"Dispel"
);

AuraUtil.UnitFrameDebuffType = EnumUtil.MakeEnum(
	"BossDebuff",
	"BossBuff",
	"PriorityDebuff",
	"NonBossRaidDebuff",
	"NonBossDebuff"
);

function AuraUtil.UnitFrameDebuffComparator(a, b)
	if a.debuffType ~= b.debuffType then
		return a.debuffType < b.debuffType;
	end

	return AuraUtil.DefaultAuraCompare(a, b);
end

function AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs)
	if aura == nil then
		return AuraUtil.AuraUpdateChangedType.None;
	end

	if aura.isNameplateOnly then
		return AuraUtil.AuraUpdateChangedType.None;
	end

	if (aura.isBossAura or AuraUtil.IsRoleAura(aura)) and not aura.isRaid and not ignoreDebuffs then
		aura.debuffType = aura.isHarmful and AuraUtil.UnitFrameDebuffType.BossDebuff or AuraUtil.UnitFrameDebuffType.BossBuff;
		return AuraUtil.AuraUpdateChangedType.Debuff;
	elseif aura.isHarmful and not aura.isRaid and not ignoreDebuffs then
		if AuraUtil.IsPriorityDebuff(aura.spellId) then
			aura.debuffType = AuraUtil.UnitFrameDebuffType.PriorityDebuff;
			return AuraUtil.AuraUpdateChangedType.Debuff;
		elseif not displayOnlyDispellableDebuffs and AuraUtil.ShouldDisplayDebuff(aura.sourceUnit, aura.spellId) then
			aura.debuffType = AuraUtil.UnitFrameDebuffType.NonBossDebuff;
			return AuraUtil.AuraUpdateChangedType.Debuff;
		end
	elseif aura.isHelpful and not ignoreBuffs and AuraUtil.ShouldDisplayBuff(aura.sourceUnit, aura.spellId, aura.canApplyAura) then
		aura.isBuff = true;
		return AuraUtil.AuraUpdateChangedType.Buff;
	elseif aura.isHarmful and aura.isRaid then
		if displayOnlyDispellableDebuffs and not ignoreDebuffs and not (aura.isBossAura or AuraUtil.IsRoleAura(aura)) and AuraUtil.ShouldDisplayDebuff(aura.sourceUnit, aura.spellId) and not AuraUtil.IsPriorityDebuff(aura.spellId) then
			aura.debuffType = AuraUtil.UnitFrameDebuffType.NonBossRaidDebuff;
			return AuraUtil.AuraUpdateChangedType.Debuff;
		elseif not ignoreDispelDebuffs and AuraUtil.DispellableDebuffTypes[aura.dispelName] ~= nil then
			aura.debuffType = (aura.isBossAura or AuraUtil.IsRoleAura(aura)) and AuraUtil.UnitFrameDebuffType.BossDebuff or AuraUtil.UnitFrameDebuffType.NonBossRaidDebuff;
			return AuraUtil.AuraUpdateChangedType.Dispel;
		end
	end

	return AuraUtil.AuraUpdateChangedType.None;
end

do
	-- Cache securecallfunction in case it changes in the global environment
	local securecallfunction = securecallfunction;

	local hasValidPlayer = false;
	EventRegistry:RegisterFrameEvent("PLAYER_ENTERING_WORLD");
	EventRegistry:RegisterFrameEvent("PLAYER_LEAVING_WORLD");
	EventRegistry:RegisterCallback("PLAYER_ENTERING_WORLD", function()
		hasValidPlayer = true;
	end, {});
	EventRegistry:RegisterCallback("PLAYER_LEAVING_WORLD", function()
		hasValidPlayer = false;
	end, {});

	local cachedVisualizationInfo = {};

	-- Visualization info is specific to the spec it was checked under
	EventRegistry:RegisterFrameEvent("PLAYER_SPECIALIZATION_CHANGED");
	EventRegistry:RegisterCallback("PLAYER_SPECIALIZATION_CHANGED", function()
		cachedVisualizationInfo = {};
	end, {});

	local function GetCachedVisibilityInfo(spellId)
		if cachedVisualizationInfo[spellId] == nil then
			local newInfo = {C_Spell.GetVisibilityInfo(spellId, UnitAffectingCombat("player") and Enum.SpellAuraVisibilityType.RaidInCombat or Enum.SpellAuraVisibilityType.RaidOutOfCombat)};
			if not hasValidPlayer then
				-- Don't cache the info if the player is not valid since we didn't get a valid result
				return unpack(newInfo);
			end
			cachedVisualizationInfo[spellId] = newInfo;
		end

		local info = cachedVisualizationInfo[spellId];
		return unpack(info);
	end

	function AuraUtil.ShouldDisplayDebuff(unitCaster, spellId)
		local hasCustom, alwaysShowMine, showForMySpec = securecallfunction(GetCachedVisibilityInfo, spellId);
		if ( hasCustom ) then
			return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
		else
			return true;
		end
	end

	local cachedSelfBuffChecks = {};
	local function CheckIsSelfBuff(spellId)
		if cachedSelfBuffChecks[spellId] == nil then
			cachedSelfBuffChecks[spellId] = C_Spell.IsSelfBuff(spellId);
		end

		return cachedSelfBuffChecks[spellId];
	end

	function AuraUtil.ShouldDisplayBuff(unitCaster, spellId, canApplyAura)
		local hasCustom, alwaysShowMine, showForMySpec = securecallfunction(GetCachedVisibilityInfo, spellId);

		if ( hasCustom ) then
			return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
		elseif (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura then
			return not securecallfunction(CheckIsSelfBuff, spellId);
		else
			return false;
		end
	end

	local cachedPriorityChecks = {};
	function AuraUtil.CheckIsPriorityAura(spellId)
		if cachedPriorityChecks[spellId] == nil then
			cachedPriorityChecks[spellId] = C_Spell.IsPriorityAura(spellId);
		end

		return cachedPriorityChecks[spellId];
	end

	local cachedBigDefensives = {};
	function AuraUtil.IsBigDefensive(aura)
		-- EditMode data support without mocking an entire API
		if aura.isBigDefensive ~= nil then
			return aura.isBigDefensive;
		end

		local spellID = aura.spellId;
		if cachedBigDefensives[spellID] == nil then
			cachedBigDefensives[spellID] = securecallfunction(C_UnitAuras.AuraIsBigDefensive, spellID);
		end

		return cachedBigDefensives[spellID];
	end

	local function DumpCaches()
		cachedVisualizationInfo = {};
		cachedSelfBuffChecks = {};
		cachedPriorityChecks = {};
	end
	EventRegistry:RegisterFrameEvent("PLAYER_REGEN_ENABLED");
	EventRegistry:RegisterFrameEvent("PLAYER_REGEN_DISABLED");
	EventRegistry:RegisterCallback("PLAYER_REGEN_ENABLED", DumpCaches, {});
	EventRegistry:RegisterCallback("PLAYER_REGEN_DISABLED", DumpCaches, {});
end

local function RefreshBuffs(frame, unit, numBuffs, suffix, checkCVar)
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numBuffs = numBuffs or MAX_PARTY_BUFFS;
	suffix = suffix or "Buff";

	local unitStatus, statusColor;
	local debuffTotal = 0;

	local filter = ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showCastableBuffs") and UnitCanAssist("player", unit) ) and "HELPFUL|RAID" or "HELPFUL";
	local numFrames = 0;
	AuraUtil.ForEachAura(unit, filter, numBuffs, function(...)
		local name, icon, count, debuffType, duration, expirationTime = ...;

		-- if we have an icon to show then proceed with setting up the aura
		if ( icon ) then
			numFrames = numFrames + 1;
			local buffName = frameName..suffix..numFrames;

			-- set the icon
			local buffIcon = _G[buffName.."Icon"];
			buffIcon:SetTexture(icon);

			-- setup the cooldown
			local coolDown = _G[buffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end

			-- show the aura
			_G[buffName]:Show();
		end
		return numFrames >= numBuffs;
	end);

	for i=numFrames + 1,numBuffs do
		local buffName = frameName..suffix..i;
		local buffFrame = _G[buffName];
		if buffFrame then
			buffFrame:Hide();
		else
			break;
		end
	end
end

local function RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	local frameName = frame:GetName();
	suffix = suffix or "Debuff";
	local frameNameWithSuffix = frameName..suffix;

	frame.hasDispellable = nil;

	numDebuffs = numDebuffs or MAX_PARTY_DEBUFFS;

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local isEnemy = UnitCanAttack("player", unit);

	local filter = ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", unit) ) and "HARMFUL|RAID" or "HARMFUL";

	if strsub(unit, 1, 5) == "party" then
		unitStatus = _G[frameName.."Status"];
	end
	AuraUtil.ForEachAura(unit, filter, numDebuffs, function(...)
		local name, icon, count, debuffType, duration, expirationTime, caster = ...;

		if ( icon and ( SHOW_CASTABLE_DEBUFFS == "0" or not isEnemy or caster == "player" ) ) then
			debuffTotal = debuffTotal + 1;
			local debuffName = frameNameWithSuffix..debuffTotal;
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local debuffIcon = _G[debuffName.."Icon"];
			debuffIcon:SetTexture(icon);

			-- setup the border
			local debuffBorder = _G[debuffName.."Border"];
			local debuffColor = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);

			-- record interesting data for the aura button
			statusColor = debuffColor;
			frame.hasDispellable = 1;

			-- setup the cooldown
			local coolDown = _G[debuffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end

			-- show the aura
			_G[debuffName]:Show();
		end
		return debuffTotal >= numDebuffs;
	end);

	for i=debuffTotal+1,numDebuffs do
		local debuffName = frameNameWithSuffix..i;
		_G[debuffName]:Hide();
	end

	frame.debuffTotal = debuffTotal;
	-- Reset unitStatus overlay graphic timer
	if ( frame.numDebuffs and debuffTotal >= frame.numDebuffs ) then
		frame.debuffCountdown = 30;
	end
	if ( unitStatus and statusColor ) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	end
end

function AuraUtil.RefreshAuras(frame, unit, numAuras, suffix, checkCVar, showBuffs)
	if ( showBuffs ) then
		RefreshBuffs(frame, unit, numAuras, suffix, checkCVar);
	else
		RefreshDebuffs(frame, unit, numAuras, suffix, checkCVar);
	end
end

function AuraUtil.IsRoleAura(aura)
	return aura.isTankRoleAura or aura.isHealerRoleAura or aura.isDPSRoleAura;
end

function AuraUtil.SetAuraBorderColor(borderRegion, dispelType)
	local color = DebuffTypeColor[dispelType] or DebuffTypeColor["none"];
	borderRegion:SetVertexColor(color.r, color.g, color.b, color.a);
end
