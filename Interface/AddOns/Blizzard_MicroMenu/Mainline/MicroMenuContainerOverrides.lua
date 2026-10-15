
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonGameRuleInfo(CharacterMicroButton, Enum.GameRule.CharacterPanelDisabled),
		MicroMenuUtil.GenerateButtonGameRuleInfo(ProfessionMicroButton, Enum.GameRule.ProfessionsPanelDisabled),
		MicroMenuUtil.GenerateButtonCallbackInfo(PlayerSpellsMicroButton, GameRulesUtil.SharedSpellAndTalentMicroButtonDisabled),
		MicroMenuUtil.GenerateButtonCallbackInfo(SpellbookMicroButton, GameRulesUtil.SpellBookMicroButtonDisabled),
		MicroMenuUtil.GenerateButtonCallbackInfo(TalentMicroButton, GameRulesUtil.TalentMicroButtonDisabled),
		MicroMenuUtil.GenerateButtonCallbackInfo(ScribeMicroButton, GameRulesUtil.ScribeMicroButtonDisabled),
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
