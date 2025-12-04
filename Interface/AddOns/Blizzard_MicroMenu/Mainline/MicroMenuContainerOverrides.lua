
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonGameRuleInfo(CharacterMicroButton, Enum.GameRule.CharacterPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(ProfessionMicroButton, Enum.GameRule.SpellbookPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(PlayerSpellsMicroButton, Enum.GameRule.TalentsPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(AchievementMicroButton, Enum.GameRule.AchievementsPanelDisabled),
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
