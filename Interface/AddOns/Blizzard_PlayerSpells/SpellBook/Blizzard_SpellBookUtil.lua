SpellBookUtil = {};

local ActionBarStatusTooltips = {
	[ActionButtonUtil.ActionBarActionStatus.NotMissing] = nil,
	[ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars] = TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR,
	[ActionButtonUtil.ActionBarActionStatus.OnInactiveBonusBar] = TALENT_BUTTON_TOOLTIP_ON_INACTIVE_BONUSBAR,
	[ActionButtonUtil.ActionBarActionStatus.OnDisabledActionBar] = TALENT_BUTTON_TOOLTIP_ON_DISABLED_ACTIONBAR,
}

function SpellBookUtil.GetTooltipForActionBarStatus(status)
	return ActionBarStatusTooltips[status];
end

function SpellBookUtil.GetActionBarStatusForSpellBookItem(spellBookItemInfo)
	if spellBookItemInfo.isPassive then
		return ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	local status = ActionButtonUtil.ActionBarActionStatus.NotMissing;

	local itemType = spellBookItemInfo.itemType;

	if itemType == Enum.SpellBookItemType.Spell then
		local excludeNonPlayerBars = true;
		local excludeSpecialPlayerBars = false;
		status = ActionButtonUtil.GetActionBarStatusForSpell(spellBookItemInfo.spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
	elseif itemType == Enum.SpellBookItemType.PetAction then
		status = ActionButtonUtil.GetActionBarStatusForPetAction(spellBookItemInfo.actionID);
	elseif itemType == Enum.SpellBookItemType.Flyout then
		status = ActionButtonUtil.GetActionBarStatusForFlyout(spellBookItemInfo.actionID);
	end

	return status;
end