-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- Combat Log APIs
--
-- Some functions have been relocated to the secure environment, for which no
-- deprecation is (intentionally) provided.

do
	CombatLog_Object_IsA = C_CombatLog.DoesObjectMatchFilter;
	CombatLogAddFilter = C_CombatLog.AddEventFilter;
	CombatLogClearEntries = C_CombatLog.ClearEntries;
	CombatLogGetCurrentEntry = C_CombatLog.GetCurrentEntryInfo;
	CombatLogGetCurrentEventInfo = C_CombatLog.GetCurrentEventInfo;
	CombatLogGetNumEntries = C_CombatLog.GetEntryCount;
	CombatLogGetRetentionTime = C_CombatLog.GetEntryRetentionTime;
	CombatLogResetFilter = C_CombatLog.ClearEventFilters;
	CombatLogSetRetentionTime = C_CombatLog.SetEntryRetentionTime;
	CombatLogShowCurrentEntry = C_CombatLog.ShouldShowCurrentEntry;

	CombatTextSetActiveUnit = C_CombatText.SetActiveUnit;
	GetCurrentCombatTextEventInfo = C_CombatText.GetCurrentEventInfo;

	DeathRecap_GetEvents = C_DeathRecap.GetRecapEvents;
	DeathRecap_HasEvents = C_DeathRecap.HasRecapEvents;
	GetDeathRecapLink = C_DeathRecap.GetRecapLink;
end

-- Combat Log constants
--
-- The COMBATLOG_FILTER_* constants are not deprecated but have been
-- relocated to Blizzard_CombatLogBase with their existing global names.

do
	COMBATLOG_OBJECT_AFFILIATION_MINE = Enum.CombatLogObject.AffiliationMine;
	COMBATLOG_OBJECT_AFFILIATION_PARTY = Enum.CombatLogObject.AffiliationParty;
	COMBATLOG_OBJECT_AFFILIATION_RAID = Enum.CombatLogObject.AffiliationRaid;
	COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = Enum.CombatLogObject.AffiliationOutsider;
	COMBATLOG_OBJECT_REACTION_FRIENDLY = Enum.CombatLogObject.ReactionFriendly;
	COMBATLOG_OBJECT_REACTION_NEUTRAL = Enum.CombatLogObject.ReactionNeutral;
	COMBATLOG_OBJECT_REACTION_HOSTILE = Enum.CombatLogObject.ReactionHostile;
	COMBATLOG_OBJECT_CONTROL_PLAYER = Enum.CombatLogObject.ControlPlayer;
	COMBATLOG_OBJECT_CONTROL_NPC = Enum.CombatLogObject.ControlNpc;
	COMBATLOG_OBJECT_TYPE_PLAYER = Enum.CombatLogObject.TypePlayer;
	COMBATLOG_OBJECT_TYPE_NPC = Enum.CombatLogObject.TypeNpc;
	COMBATLOG_OBJECT_TYPE_PET = Enum.CombatLogObject.TypePet;
	COMBATLOG_OBJECT_TYPE_GUARDIAN = Enum.CombatLogObject.TypeGuardian;
	COMBATLOG_OBJECT_TYPE_OBJECT = Enum.CombatLogObject.TypeObject;
	COMBATLOG_OBJECT_TARGET = Enum.CombatLogObject.Target;
	COMBATLOG_OBJECT_FOCUS = Enum.CombatLogObject.Focus;
	COMBATLOG_OBJECT_MAINTANK = Enum.CombatLogObject.Maintank;
	COMBATLOG_OBJECT_MAINASSIST = Enum.CombatLogObject.Mainassist;
	COMBATLOG_OBJECT_NONE = Enum.CombatLogObject.None;

	COMBATLOG_OBJECT_AFFILIATION_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_AFFILIATION_MASK;
	COMBATLOG_OBJECT_REACTION_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_REACTION_MASK;
	COMBATLOG_OBJECT_CONTROL_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_CONTROL_MASK;
	COMBATLOG_OBJECT_TYPE_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_TYPE_MASK;
	COMBATLOG_OBJECT_SPECIAL_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_SPECIAL_MASK;

	COMBATLOG_OBJECT_RAIDTARGET1 = Enum.CombatLogObjectTarget.Raidtarget1;
	COMBATLOG_OBJECT_RAIDTARGET2 = Enum.CombatLogObjectTarget.Raidtarget2;
	COMBATLOG_OBJECT_RAIDTARGET3 = Enum.CombatLogObjectTarget.Raidtarget3;
	COMBATLOG_OBJECT_RAIDTARGET4 = Enum.CombatLogObjectTarget.Raidtarget4;
	COMBATLOG_OBJECT_RAIDTARGET5 = Enum.CombatLogObjectTarget.Raidtarget5;
	COMBATLOG_OBJECT_RAIDTARGET6 = Enum.CombatLogObjectTarget.Raidtarget6;
	COMBATLOG_OBJECT_RAIDTARGET7 = Enum.CombatLogObjectTarget.Raidtarget7;
	COMBATLOG_OBJECT_RAIDTARGET8 = Enum.CombatLogObjectTarget.Raidtarget8;
	COMBATLOG_OBJECT_RAID_NONE = Enum.CombatLogObjectTarget.RaidNone;

	COMBATLOG_OBJECT_RAIDTARGET_MASK = Constants.CombatLogObjectTargetMasks.COMBATLOG_OBJECT_RAID_TARGET_MASK;
	COMBATLOG_OBJECT_RAID_MASK = Constants.CombatLogObjectTargetMasks.COMBATLOG_OBJECT_RAID_MASK;
end

-- Combat Log UI constants

do
	AURA_TYPE_BUFF = "BUFF";
	AURA_TYPE_DEBUFF = "DEBUFF";

	COMBATLOG_HIGHLIGHT_MULTIPLIER = 1.5;

	COMBATLOG_ICON_RAIDTARGET1 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget1);
	COMBATLOG_ICON_RAIDTARGET2 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget2);
	COMBATLOG_ICON_RAIDTARGET3 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget3);
	COMBATLOG_ICON_RAIDTARGET4 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget4);
	COMBATLOG_ICON_RAIDTARGET5 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget5);
	COMBATLOG_ICON_RAIDTARGET6 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget6);
	COMBATLOG_ICON_RAIDTARGET7 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget7);
	COMBATLOG_ICON_RAIDTARGET8 = CombatLogUtil.GetRaidTargetIcon(Enum.CombatLogObjectTarget.Raidtarget8);
end

-- Combat Log UI functions

do
	Blizzard_CombatLog_BitToBraceCode = CombatLogUtil.GetRaidTargetBraceCode;
	CombatLog_Color_ColorArrayByEventType = CombatLogUtil.GetColorByEventType;
	CombatLog_Color_ColorArrayBySchool = CombatLogUtil.GetColorBySchool;
	CombatLog_Color_ColorArrayByUnitType = CombatLogUtil.GetColorByUnitType;
	CombatLog_Color_HighlightColorArray = CombatLogUtil.HighlightColor;
	CombatLog_String_DamageResultString = CombatLogUtil.GenerateDamageResultString;
	CombatLog_String_GetIcon = CombatLogUtil.GetUnitIcon;
	CombatLog_String_PowerType = CombatLogUtil.GetPowerTypeString;
	CombatLog_String_SchoolString = CombatLogUtil.GetSpellSchoolString;

	function CombatLog_Color_FloatToText(r, g, b, a)
		if type(r) == "table" then
			r, g, b, a = r.r, r.g, r.b, r.a;
		end

		a = math.min(1, a or 1) * 255;
		r = math.min(1, r) * 255;
		g = math.min(1, g) * 255;
		b = math.min(1, b) * 255;

		return ("%.2x%.2x%.2x%.2x"):format(floor(a), floor(r), floor(g), floor(b));
	end

	function CombatLog_Color_ColorArrayByEventType(event, filterSettings)
		return CombatLogUtil.GetColorByEventType(event, filterSettings or Blizzard_CombatLog_CurrentSettings);
	end

	function CombatLog_Color_ColorArrayByUnitType(unitFlags, filterSettings)
		return CombatLogUtil.GetColorByUnitType(unitFlags, filterSettings or Blizzard_CombatLog_CurrentSettings);
	end

	function CombatLog_Color_ColorArrayBySchool(school, filterSettings)
		return CombatLogUtil.GetColorBySchool(school, filterSettings or Blizzard_CombatLog_CurrentSettings);
	end

	function CombatLog_Color_ColorStringByEventType(unitFlags, filterSettings)
		return CombatLog_Color_FloatToText(CombatLog_Color_ColorArrayByEventType(unitFlags, filterSettings));
	end

	function CombatLog_Color_ColorStringBySchool(school, filterSettings)
		return CombatLog_Color_FloatToText(CombatLog_Color_ColorArrayBySchool(school, filterSettings));
	end

	function CombatLog_Color_ColorStringByUnitType(unitFlags, filterSettings)
		return CombatLog_Color_FloatToText(CombatLog_Color_ColorArrayByUnitType(unitFlags, filterSettings));
	end
end
