
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonInfo(CharacterMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SpellbookMicroButton),
		MicroMenuUtil.GenerateButtonInfo(TalentMicroButton),
		MicroMenuUtil.GenerateButtonInfo(AchievementMicroButton),
		MicroMenuUtil.GenerateButtonInfo(QuestLogMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SocialsMicroButton),
		MicroMenuUtil.GenerateButtonInfo(GuildMicroButton),
		MicroMenuUtil.GenerateButtonInfo(CollectionsMicroButton),
		MicroMenuUtil.GenerateButtonInfo(PVPMicroButton),
		MicroMenuUtil.GenerateButtonInfo(LFGMicroButton),
		MicroMenuUtil.GenerateButtonInfo(MainMenuMicroButton),
		MicroMenuUtil.GenerateButtonInfo(HelpMicroButton),
	};

	return buttonInfos;
end

function MicroMenuMixin:ApplyMicroMenuOverrides()
	self.childXPadding = -4;
end
