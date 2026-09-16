SpellSearchUtil = {};

SpellSearchUtil.MatchType = {
	DescriptionMatch = 1,
	NameMatch = 2,
	RelatedMatch = 3,
	ExactMatch = 4,
	NotOnActionBar = 5,
	OnInactiveBonusBar = 6,
	OnDisabledActionBar = 7,
	AssistedCombat = 8,
};

SpellSearchUtil.SourceType = {
	Trait = 1,
	PvPTalent = 2,
	SpellBookItem = 3,
};

SpellSearchUtil.FilterType = {
	Text = 1,
	ActionBar = 2,
	Name = 3,
	AssistedCombat = 4,
};

SpellSearchUtil.ActionBarStatusTooltips = {
	[ActionButtonUtil.ActionBarActionStatus.NotMissing] = nil,
	[ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars] = TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR,
	[ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar] = TALENT_BUTTON_TOOLTIP_ON_INACTIVE_BONUSBAR,
	[ActionButtonUtil.ActionBarActionStatus.OnDisabledActionBar] = TALENT_BUTTON_TOOLTIP_ON_DISABLED_ACTIONBAR,
};

SpellSearchUtil.ActionBarStatusMatchTypes = {
	[ActionButtonUtil.ActionBarActionStatus.NotMissing] = nil,
	[ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars] = SpellSearchUtil.MatchType.NotOnActionBar,
	[ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar] = SpellSearchUtil.MatchType.OnInactiveBonusBar,
	[ActionButtonUtil.ActionBarActionStatus.OnDisabledActionBar] = SpellSearchUtil.MatchType.OnDisabledActionBar,
};

function SpellSearchUtil.DoStringsMatch(string1, string2)
	if not string1 or not string2 then
		return (not string1 and not string2);
	end
	return strcmputf8i(string1, string2) == 0;
end

function SpellSearchUtil.DoesStringContain(parentString, substring)
	-- We should really implement a utf8-aware substring find
	return strfind(parentString:lower(), substring:lower(), 1, true);
end

function SpellSearchUtil.GetTooltipForActionBarStatus(actionBarStatus)
	return SpellSearchUtil.ActionBarStatusTooltips[actionBarStatus];
end

function SpellSearchUtil.GetActionbarStatusForSpell(spellID)
	local excludeNonPlayerBars = true;
	local excludeSpecialPlayerBars = false;
	return ActionButtonUtil.GetActionBarStatusForSpell(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
end

function SpellSearchUtil.GetActionbarStatusForSpellBookItem(slotIndex, spellBank)
	local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, spellBank);
	return spellBookItemInfo and SpellSearchUtil.GetActionbarStatusForSpellBookItemInfo(spellBookItemInfo) or nil;
end

function SpellSearchUtil.GetActionbarStatusForSpellBookItemInfo(spellBookItemInfo)
	if spellBookItemInfo.isPassive or spellBookItemInfo.isOffSpec then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	if spellBookItemInfo.itemType == Enum.SpellBookItemType.FutureSpell then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local status = ActionButtonUtil.ActionBarActionStatus.NotMissing;
	local itemType = spellBookItemInfo.itemType;

	if itemType == Enum.SpellBookItemType.Spell then
		-- Currently avoiding flagging auto combat spells as not on action bars
		if not C_Spell.IsAutoAttackSpell(spellBookItemInfo.spellID) and not C_Spell.IsRangedAutoAttackSpell(spellBookItemInfo.spellID) then
			-- Use the base spell ID to match what's stored on the action bar.
			status = SpellSearchUtil.GetActionbarStatusForSpell(spellBookItemInfo.actionID);
		end
	elseif itemType == Enum.SpellBookItemType.PetAction then
		status = ActionButtonUtil.GetActionBarStatusForPetAction(spellBookItemInfo.actionID);
	elseif itemType == Enum.SpellBookItemType.Flyout then
		status = ActionButtonUtil.GetActionBarStatusForFlyout(spellBookItemInfo.actionID);
	end

	return status;
end

function SpellSearchUtil.GetActionBarStatusForTraitNode(talentNodeInfo, spellID)
	if not talentNodeInfo or not talentNodeInfo.entryIDsWithCommittedRanks or (#talentNodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	return SpellSearchUtil.GetActionbarStatusForSpell(spellID);
end

function SpellSearchUtil.GetActionBarStatusForTraitNodeEntry(talentEntryID, talentNodeInfo, spellID)
	if not talentNodeInfo or not talentNodeInfo.entryIDsWithCommittedRanks or (#talentNodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local isEntryCommitted = false;
	for _, committedEntryID in ipairs(talentNodeInfo.entryIDsWithCommittedRanks) do
		if committedEntryID == talentEntryID then
			isEntryCommitted = true;
			break;
		end
	end

	if not isEntryCommitted then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	return SpellSearchUtil.GetActionbarStatusForSpell(spellID);
end

function SpellSearchUtil.IsActionBarMatchType(matchType)
	return matchType == SpellSearchUtil.MatchType.NotOnActionBar
		or matchType == SpellSearchUtil.MatchType.OnInactiveBonusBar
		or matchType == SpellSearchUtil.MatchType.OnDisabledActionBar;
end
