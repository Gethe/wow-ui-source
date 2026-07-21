
function MicroMenuMixin:GenerateButtonInfos()
	local buttonInfos = {
		MicroMenuUtil.GenerateButtonInfo(CharacterMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SpellbookMicroButton),
		MicroMenuUtil.GenerateButtonInfo(TalentMicroButton),
		MicroMenuUtil.GenerateButtonInfo(AchievementMicroButton),
		MicroMenuUtil.GenerateButtonInfo(QuestLogMicroButton),
		MicroMenuUtil.GenerateButtonInfo(SocialsMicroButton),
		MicroMenuUtil.GenerateButtonInfo(GuildMicroButton),
		MicroMenuUtil.GenerateButtonInfo(PVPMicroButton),
		MicroMenuUtil.GenerateButtonInfo(LFGMicroButton),
		MicroMenuUtil.GenerateButtonInfo(CollectionsMicroButton),
		MicroMenuUtil.GenerateButtonInfo(EJMicroButton),
		MicroMenuUtil.GenerateButtonInfo(StoreMicroButton),
		MicroMenuUtil.GenerateButtonInfo(MainMenuMicroButton),
	};

	return buttonInfos;
end

function MicroMenuMixin:ApplyMicroMenuOverrides()
	self.childXPadding = -4;
end
