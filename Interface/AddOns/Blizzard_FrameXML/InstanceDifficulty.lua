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
		self:SetIsGuildGroup(isGuildGroup);
	elseif ( event == "PLAYER_DIFFICULTY_CHANGED") then
		self:Update();
	elseif ( event == "UPDATE_INSTANCE_INFO" or event == "INSTANCE_GROUP_SIZE_CHANGED" or event == "GROUP_ROSTER_UPDATE") then
		RequestGuildPartyState();
		self:Update();
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		local tabard = self.Guild;
		SetSmallGuildTabardTextures("player", tabard.Emblem, tabard.Background, tabard.Border);
		if ( IsInGuild() ) then
			RequestGuildPartyState();
		else
			self:SetIsGuildGroup(false);
		end
	else
		RequestGuildPartyState();
	end
end

function InstanceDifficultyMixin:SetIsGuildGroup(isGuildGroup)
	if ( isGuildGroup ~= self.isGuildGroup ) then
		self.isGuildGroup = isGuildGroup;
		self:Update();
	end
end

function InstanceDifficultyMixin:IsGuildGroup()
	return self.isGuildGroup;
end

function InstanceDifficultyMixin:GetDifficultyTexture(difficultyTextureFrame, displayChallengeMode, displayMythic, displayHeroic)
	if ( not difficultyTextureFrame) then
		return nil;
	elseif ( difficultyTextureFrame.ChallengeModeTexture and displayChallengeMode ) then
		return difficultyTextureFrame.ChallengeModeTexture;
	elseif ( difficultyTextureFrame.MythicTexture and displayMythic ) then
		return difficultyTextureFrame.MythicTexture;
	elseif ( difficultyTextureFrame.HeroicTexture and displayHeroic ) then
		return difficultyTextureFrame.HeroicTexture;
	elseif ( difficultyTextureFrame.WalkInTexture and C_PartyInfo.IsPartyWalkIn() ) then
		return difficultyTextureFrame.WalkInTexture;
	elseif (difficultyTextureFrame.NormalTexture ) then
		return difficultyTextureFrame.NormalTexture;
	end

	return nil;
end

function InstanceDifficultyMixin:Update()
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.InstanceDifficultyBanner) then
		for _, frame in ipairs(self.ContentModes) do
			frame:Hide();
		end
		return;
	end

	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize = GetInstanceInfo();
	local _, _, isHeroic, isChallengeMode, displayHeroic, displayMythic = GetDifficultyInfo(difficulty);

	-- The frames for the different modes of content the player can engage in.
	local defaultFrame = self.Default;
	local guildFrame = self.Guild;
	local challengeModeFrame = self.ChallengeMode;

	-- The frame for the content the player is currently engaging in.
	local contentFrame = nil;

	-- The frame that contains the text and textures showing the content information.
	local instanceFrame = nil;

	if ( self.isGuildGroup ) then
		contentFrame = guildFrame;
		instanceFrame = guildFrame.Instance;
	elseif ( isChallengeMode ) then
		contentFrame = challengeModeFrame;
	elseif (instanceType ~= "none") then
		contentFrame = defaultFrame;
		instanceFrame = defaultFrame;
	end

	if ( contentFrame == guildFrame ) then
		if ( instanceGroupSize == 0 ) then
			instanceFrame.Text:SetText("");
		else
			instanceFrame.Text:SetText(instanceGroupSize);
		end

		SetSmallGuildTabardTextures("player", guildFrame.Emblem, guildFrame.Background, guildFrame.Border);
	elseif ( contentFrame == defaultFrame ) then
		instanceFrame.Text:SetText(instanceGroupSize);
	end
	
	if (instanceFrame) then
		local difficultyTexture = self:GetDifficultyTexture(instanceFrame, isChallengeMode, displayMythic, isHeroic or displayHeroic);

		-- Only one difficulty texture should ever be shown.
		for _, texture in ipairs(instanceFrame.DifficultyTextures) do
			texture:SetShown(difficultyTexture == texture);
		end

		instanceFrame:Layout();
	end

	-- Only one mode should ever be shown.
	for _, frame in ipairs(self.ContentModes) do
		frame:SetShown(contentFrame == frame);
	end
end

function InstanceDifficultyMixin:OnEnter()
	if ( not self.Default:IsShown() ) then
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
	GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers));
	GameTooltip:Show();
end

function InstanceDifficultyMixin:OnLeave()
	GameTooltip_Hide();
end

function InstanceDifficultyMixin:SetFlipped(flipped)
	local background = flipped and "ui-hud-minimap-guildbanner-background-bottom" or "ui-hud-minimap-guildbanner-background-top";
	local border = flipped and "ui-hud-minimap-guildbanner-border-bottom" or "ui-hud-minimap-guildbanner-border-top";

	local defaultFrame = self.Default;
	local guildFrame = self.Guild;
	local challengeModeFrame = self.ChallengeMode;

	defaultFrame.Background:SetAtlas(background);
	defaultFrame.Border:SetAtlas(border);
	guildFrame.Background:SetAtlas(background);
	guildFrame.Border:SetAtlas(border);
	challengeModeFrame.Background:SetAtlas(background);
	challengeModeFrame.Border:SetAtlas(border);
end

GuildInstanceDifficultyMixin = { };

function GuildInstanceDifficultyMixin:OnEnter()
	local guildName = GetGuildInfo("player");
	local _, instanceType, difficulty, _, maxPlayers, _, _, _, instanceGroupSize = GetInstanceInfo();
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
	GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_BANNER_TOOLTIP_PLAYER_COUNT:format(instanceGroupSize, maxPlayers));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, GUILD_GROUP, GREEN_FONT_COLOR);
	if ( xpMultiplier < 1 ) then
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP:format(numGuildRequired, instanceGroupSize, guildName, xpMultiplier * 100), true);
	elseif ( xpMultiplier > 1 ) then
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP:format(guildName, xpMultiplier * 100), true);
	else
		if ( instanceType == "party" and maxPlayers == 5 ) then
			numGuildRequired = 4;
		end
		GameTooltip_AddNormalLine(GameTooltip, GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, instanceGroupSize, guildName), true);
	end
	GameTooltip:Show();
end

function GuildInstanceDifficultyMixin:OnLeave()
	GameTooltip_Hide();
end
