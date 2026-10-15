
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonGameRuleInfo(CharacterMicroButton, Enum.GameRule.CharacterPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(ProfessionMicroButton, Enum.GameRule.ProfessionsPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(SpellbookMicroButton),
		MicroMenuUtil.GenerateButtonGameRuleInfo(TalentMicroButton),
		MicroMenuUtil.GenerateButtonGameRuleInfo(LegacyMicroButton),
		MicroMenuUtil.GenerateButtonGameRuleInfo(QuestLogMicroButton, Enum.GameRule.QuestLogMicrobuttonDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(HousingMicroButton, Enum.GameRule.HousingDashboardDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(GuildMicroButton, Enum.GameRule.CommunitiesPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(LFDMicroButton, Enum.GameRule.FinderPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(CollectionsMicroButton, Enum.GameRule.CollectionsPanelDisabled),
		MicroMenuUtil.GenerateButtonCallbackInfo(EJMicroButton, GameRulesUtil.EJIsDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(HelpMicroButton, Enum.GameRule.HelpPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(StoreMicroButton, Enum.GameRule.StoreDisabled),
		MicroMenuUtil.GenerateButtonInfo(MainMenuMicroButton),
	};

	return buttonInfos;
end
