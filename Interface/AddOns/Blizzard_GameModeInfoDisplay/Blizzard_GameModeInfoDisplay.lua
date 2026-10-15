GameModeInfoDisplayMixin = {
	targetGameModeRecId = nil;
	pendingCreateCharacter = false;
	gameModeForSplashScreen = nil;
};

function GameModeInfoDisplayMixin:OnLoad()
	self.InfoPanel.CloseButton:SetScript("OnClick", function()
		self:Hide();
		self.pendingCreateCharacter = false;
	end);
end

local GM_SPLASH_SCREEN_MAP = {
	[Enum.GameMode.WoWHack] = {
		background = "timerunning-infographic-background-talebound",
		bullet = "timerunning-infographic-bullet",
		rewards = "timerunning-infographic-rewards-talebound",
		topDescription = GAME_MODE_INFO_DISPLAY_WOWHACK_TOP_DESCRIPTION,
		questsHeader = GAME_MODE_INFO_DISPLAY_WOWHACK_QUESTS_HEADER,
		questsDescription = GAME_MODE_INFO_DISPLAY_WOWHACK_QUESTS_DESCRIPTION,
		itemsHeader = GAME_MODE_INFO_DISPLAY_WOWHACK_ITEMS_HEADER,
		itemsDescription = GAME_MODE_INFO_DISPLAY_WOWHACK_ITEMS_DESCRIPTION,
		rewardsHeader = GAME_MODE_INFO_DISPLAY_WOWHACK_REWARDS_HEADER,
		rewardsDescription = GAME_MODE_INFO_DISPLAY_WOWHACK_REWARDS_DESCRIPTION,
		playNowButton = GAME_MODE_INFO_DISPLAY_WOWHACK_PLAY_NOW_BUTTON,
	},
};

function GameModeInfoDisplayMixin:OnShow()
	self.gameModeForSplashScreen = C_GameRules.GetActiveGameModeForSplashScreen() or self.gameModeForSplashScreen;
	if not self.gameModeForSplashScreen then
		self:SetShown(false);
		return;
	end

	local gameModeAtlasSettings = GM_SPLASH_SCREEN_MAP[self.gameModeForSplashScreen];
	if not gameModeAtlasSettings then
		self:SetShown(false);
		return;
	end

	if C_GameRules.AlreadyShownOnce() then
		self:SetShown(false);
		return;
	else
		C_GameRules.SetAlreadyShownOnce(true);
	end

	local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
	if currentExpansionLevel then
		SetExpansionLogo(self.InfoPanel.Logo, currentExpansionLevel);
	end

	self.InfoPanel.Background:SetAtlas(gameModeAtlasSettings.background);
	self.InfoPanel.QuestsBullet:SetAtlas(gameModeAtlasSettings.bullet);
	self.InfoPanel.ItemsBullet:SetAtlas(gameModeAtlasSettings.bullet);
	self.InfoPanel.RewardsBullet:SetAtlas(gameModeAtlasSettings.bullet);
	self.InfoPanel.RewardsBird:SetAtlas(gameModeAtlasSettings.rewards);

	self.InfoPanel.TopDescription:SetText(gameModeAtlasSettings.topDescription);
	self.InfoPanel.QuestsHeader:SetText(gameModeAtlasSettings.questsHeader);
	self.InfoPanel.QuestsDescription:SetText(gameModeAtlasSettings.questsDescription);
	self.InfoPanel.ItemsHeader:SetText(gameModeAtlasSettings.itemsHeader);
	self.InfoPanel.ItemsDescription:SetText(gameModeAtlasSettings.itemsDescription);
	self.InfoPanel.RewardsHeader:SetText(gameModeAtlasSettings.rewardsHeader);
	self.InfoPanel.RewardsDescription:SetText(gameModeAtlasSettings.rewardsDescription);

	self.targetGameModeRecId = C_GameRules.GetActiveGameModeRecIdForSplashScreen() or self.targetGameModeRecId;

	self.InfoPanel.PlayNowButton:SetText(gameModeAtlasSettings.playNowButton);
	self.InfoPanel.PlayNowButton:SetScript("OnClick", function()
		assert(self.targetGameModeRecId);

		if C_GameRules.GetCurrentGameModeRecordID() == self.targetGameModeRecId then
			self:SetShown(false);
			CharSelectCreateCharacterButton:Click();
			return;
		end

		if not C_GameRules.IsCharacterlessLoginActive() then
			CharacterSelectListUtil.SaveCharacterOrder();
		end

		C_GameRules.AutoConnectToGameModeRealm(self.targetGameModeRecId);

		self.pendingCreateCharacter = true;
	end);
end

function GameModeInfoDisplayMixin:TryPendingCreateCharacter()
	if self.pendingCreateCharacter then
		self.pendingCreateCharacter = false;
		CharSelectCreateCharacterButton:Click();
	end
end

function GameModeInfoDisplayMixin:ResetShownOnce()
	C_GameRules.SetAlreadyShownOnce(false);
end
