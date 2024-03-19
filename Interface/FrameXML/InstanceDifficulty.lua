--
-- Dungeon Difficulty
--

InstanceDifficultyMixin = { };

function InstanceDifficultyMixin:OnLoad()
	self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED");
	self:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("GUILD_PARTY_STATE_UPDATED");
	self:Update();
end

function InstanceDifficultyMixin:OnEvent(event, ...)
	if ( event == "GUILD_PARTY_STATE_UPDATED" ) then
		local isGuildGroup = ...;
		if ( isGuildGroup ~= self.isGuildGroup ) then
			self.isGuildGroup = isGuildGroup;
			self:Update();
		end
	elseif ( event == "PLAYER_DIFFICULTY_CHANGED") then
		self:Update();
	elseif ( event == "UPDATE_INSTANCE_INFO" or event == "INSTANCE_GROUP_SIZE_CHANGED" ) then
		RequestGuildPartyState();
		self:Update();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		local tabard = self.Guild;
		SetSmallGuildTabardTextures("player", tabard.Emblem, tabard.Background, tabard.Border);
		if ( IsInGuild() ) then
			RequestGuildPartyState();
		else
			IS_GUILD_GROUP = nil;
			self:Update();
		end
	else
		RequestGuildPartyState();
	end
end

function InstanceDifficultyMixin:Update()
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.InstanceDifficultyBanner) then
		self.Instance:Hide();
		self.Guild:Hide();
		self.ChallengeMode:Hide();
		return;
	end

	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize = GetInstanceInfo();
	local _, _, isHeroic, isChallengeMode, displayHeroic, displayMythic = GetDifficultyInfo(difficulty);

	local instanceFrame = self.Instance;
	local guildFrame = self.Guild;
	local challengeModeFrame = self.ChallengeMode;

	local showDifficultyFrame = nil;
	if ( self.isGuildGroup ) then
		showDifficultyFrame = guildFrame;
	elseif ( isChallengeMode ) then
		showDifficultyFrame = challengeModeFrame;
	elseif (instanceType ~= "none") then
		showDifficultyFrame = instanceFrame;
	end

	if ( showDifficultyFrame == guildFrame ) then
		local guildInstance = guildFrame.Instance;

		if ( instanceGroupSize == 0 ) then
			guildInstance.Text:SetText("");
		else
			guildInstance.Text:SetText(instanceGroupSize);
		end

		local challengeModeTexture = guildInstance.ChallengeModeTexture;
		local mythicTexture = guildInstance.MythicTexture;
		local heroicTexture = guildInstance.HeroicTexture;
		local normalTexture = guildInstance.NormalTexture;

		local symbolTexture = nil;
		if ( isChallengeMode ) then
			symbolTexture = challengeModeTexture;
		elseif ( displayMythic ) then
			symbolTexture = mythicTexture;
		elseif ( isHeroic or displayHeroic ) then
			symbolTexture = heroicTexture;
		else
			symbolTexture = normalTexture;
		end
		
		challengeModeTexture:SetShown(symbolTexture == challengeModeTexture);
		mythicTexture:SetShown(symbolTexture == mythicTexture);
		heroicTexture:SetShown(symbolTexture == heroicTexture);
		normalTexture:SetShown(symbolTexture == normalTexture);

		guildInstance:Layout();
		guildFrame:Layout();

		SetSmallGuildTabardTextures("player", guildFrame.Emblem, guildFrame.Background, guildFrame.Border);

	elseif ( showDifficultyFrame == instanceFrame ) then
		instanceFrame.Text:SetText(instanceGroupSize);
		instanceFrame.HeroicTexture:SetShown((isHeroic or displayHeroic) and not displayMythic);
		instanceFrame.MythicTexture:SetShown(displayMythic);
		instanceFrame.NormalTexture:SetShown(not isHeroic and not displayHeroic and not displayMythic);

		instanceFrame:Layout();
	end
	
	instanceFrame:SetShown(showDifficultyFrame == instanceFrame);
	guildFrame:SetShown(showDifficultyFrame == guildFrame);
	challengeModeFrame:SetShown(showDifficultyFrame == challengeModeFrame);
end

function InstanceDifficultyMixin:OnEnter()
	if ( not self.Instance:IsShown() ) then
		return;
	end
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize, lfgID = GetInstanceInfo();
	local isLFR = select(8, GetDifficultyInfo(difficulty))

	if (not DifficultyUtil.GetDifficultyName(difficulty)) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
	GameTooltip_SetTitle(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP:format(DifficultyUtil.GetDifficultyName(difficulty)));
	if (isLFR and lfgID) then
		GameTooltip_SetTitle(GameTooltip, RAID_FINDER);
	end
	GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(GetNumGroupMembers(), maxPlayers));
	GameTooltip:Show();
end

function InstanceDifficultyMixin:OnLeave()
	GameTooltip_Hide();
end

function InstanceDifficultyMixin:SetFlipped(flipped)
	local background = flipped and "ui-hud-minimap-guildbanner-background-bottom" or "ui-hud-minimap-guildbanner-background-top";
	local border = flipped and "ui-hud-minimap-guildbanner-border-bottom" or "ui-hud-minimap-guildbanner-border-top";

	local instanceFrame = self.Instance;
	local guildFrame = self.Guild;
	local challengeModeFrame = self.ChallengeMode;

	instanceFrame.Background:SetAtlas(background);
	instanceFrame.Border:SetAtlas(border);
	guildFrame.Background:SetAtlas(background);
	guildFrame.Border:SetAtlas(border);
	challengeModeFrame.Background:SetAtlas(background);
	challengeModeFrame.Border:SetAtlas(border);
end

GuildInstanceDifficultyMixin = { };

function GuildInstanceDifficultyMixin:OnEnter()
	local guildName = GetGuildInfo("player");
	local _, instanceType, difficulty, _, maxPlayers = GetInstanceInfo();
	local _, numGuildPresent, numGuildRequired, xpMultiplier = InGuildParty();

	if (not DifficultyUtil.GetDifficultyName(difficulty)) then
		return;
	end
	
	-- hack alert
	if ( instanceType == "arena" ) then
		maxPlayers = numGuildRequired;
	end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
	GameTooltip_SetTitle(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP:format(DifficultyUtil.GetDifficultyName(difficulty)));
	GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(GetNumGroupMembers(), maxPlayers));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, GUILD_GROUP, GREEN_FONT_COLOR);
	if ( xpMultiplier < 1 ) then
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP:format(numGuildRequired, maxPlayers, guildName, xpMultiplier * 100), true);
	elseif ( xpMultiplier > 1 ) then
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP:format(guildName, xpMultiplier * 100), true);
	else
		if ( instanceType == "party" and maxPlayers == 5 ) then
			numGuildRequired = 4;
		end
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, maxPlayers, guildName), true);
	end
	GameTooltip:Show();
end

function GuildInstanceDifficultyMixin:OnLeave()
	GameTooltip_Hide();
end
