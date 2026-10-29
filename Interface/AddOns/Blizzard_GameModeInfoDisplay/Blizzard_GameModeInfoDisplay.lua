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
		logo = [[Interface\Glues\Common\Glues-WoW-TaleboundLogo.blp]],
		logoOffsetX = 228,
		logoOffsetY = -90,
		contentOffsetX = 50,
		contentOffsetY = -7,
		topDescriptionOffsetX = -28,
		topDescriptionOffsetY = 3,
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
	self.gameModeForSplashScreen = C_GameRules.GetActiveGameModeForSplashScreen() or self.gameModeForSplashScreen or C_GameRules.GetActiveGameMode();
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

	local logo = self.InfoPanel.Logo;
	local logoOffsetX = gameModeAtlasSettings.logoOffsetX or 175;
	local logoOffsetY = gameModeAtlasSettings.logoOffsetY or -70;
	logo:ClearAllPoints();
	logo:SetPoint("CENTER", self.InfoPanel, "TOPLEFT", logoOffsetX, logoOffsetY);

	if gameModeAtlasSettings.logo then
		logo:SetTexture(gameModeAtlasSettings.logo);
		logo:Show();
	else
		local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
		if currentExpansionLevel then
			SetExpansionLogo(logo, currentExpansionLevel);
		end
	end

	local topDescription = self.InfoPanel.TopDescription;
	local topDescriptionOffsetX = gameModeAtlasSettings.topDescriptionOffsetX or -40;
	local topDescriptionOffsetY = gameModeAtlasSettings.topDescriptionOffsetY or 3;
	topDescription:ClearAllPoints();
	topDescription:SetPoint("LEFT", logo, "RIGHT", topDescriptionOffsetX, topDescriptionOffsetY);

	local questsHeader = self.InfoPanel.QuestsHeader;
	local contentOffsetX = gameModeAtlasSettings.contentOffsetX or 80;
	local contentOffsetY = gameModeAtlasSettings.contentOffsetY or -20;
	questsHeader:ClearAllPoints();
	questsHeader:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", contentOffsetX, contentOffsetY);

	self.InfoPanel.Background:SetAtlas(gameModeAtlasSettings.background);
	self.InfoPanel.QuestsBullet:SetAtlas(gameModeAtlasSettings.bullet, true);
	self.InfoPanel.ItemsBullet:SetAtlas(gameModeAtlasSettings.bullet, true);
	self.InfoPanel.RewardsBullet:SetAtlas(gameModeAtlasSettings.bullet, true);
	self.InfoPanel.RewardsBird:SetAtlas(gameModeAtlasSettings.rewards, true);

	topDescription:SetText(gameModeAtlasSettings.topDescription);
	self.InfoPanel.QuestsHeader:SetText(gameModeAtlasSettings.questsHeader);
	self.InfoPanel.QuestsDescription:SetText(gameModeAtlasSettings.questsDescription);
	self.InfoPanel.ItemsHeader:SetText(gameModeAtlasSettings.itemsHeader);
	self.InfoPanel.ItemsDescription:SetText(gameModeAtlasSettings.itemsDescription);
	self.InfoPanel.RewardsHeader:SetText(gameModeAtlasSettings.rewardsHeader);
	self.InfoPanel.RewardsDescription:SetText(gameModeAtlasSettings.rewardsDescription);

	self.targetGameModeRecId = C_GameRules.GetActiveGameModeRecIdForSplashScreen() or self.targetGameModeRecId or C_GameRules.GetCurrentGameModeRecordID();

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
