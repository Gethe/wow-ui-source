
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonInfo(CharacterMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SpellbookMicroButton),
		MicroMenuUtil.GenerateButtonInfo(TalentMicroButton),
		MicroMenuUtil.GenerateButtonInfo(QuestLogMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SocialsMicroButton),
		MicroMenuUtil.GenerateButtonInfo(GuildMicroButton),
		MicroMenuUtil.GenerateButtonInfo(MainMenuMicroButton),
		MicroMenuUtil.GenerateButtonInfo(HelpMicroButton),
	};

	return buttonInfos;
end
