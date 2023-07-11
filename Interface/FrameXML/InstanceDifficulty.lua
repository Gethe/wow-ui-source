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
	elseif ( instanceType == "raid" or isHeroic or displayMythic or displayHeroic ) then
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

		local symbolTexture = nil;
		if ( isChallengeMode ) then
			symbolTexture = challengeModeTexture;
		elseif ( displayMythic ) then
			symbolTexture = mythicTexture;
		elseif ( isHeroic or displayHeroic ) then
			symbolTexture = heroicTexture;
		end
		
		challengeModeTexture:SetShown(symbolTexture == challengeModeTexture);
		mythicTexture:SetShown(symbolTexture == mythicTexture);
		heroicTexture:SetShown(symbolTexture == heroicTexture);

		guildInstance:Layout();
		guildFrame:Layout();

		SetSmallGuildTabardTextures("player", guildFrame.Emblem, guildFrame.Background, guildFrame.Border);

	elseif ( showDifficultyFrame == instanceFrame ) then
		instanceFrame.Text:SetText(instanceGroupSize);
		instanceFrame.HeroicTexture:SetShown((isHeroic or displayHeroic) and not displayMythic);
		instanceFrame.MythicTexture:SetShown(displayMythic);

		instanceFrame:Layout();
	end
	
	instanceFrame:SetShown(showDifficultyFrame == instanceFrame);
	guildFrame:SetShown(showDifficultyFrame == guildFrame);
	challengeModeFrame:SetShown(showDifficultyFrame == challengeModeFrame);
end

function InstanceDifficultyMixin:OnEnter()
	local _, instanceType, difficulty, _, maxPlayers, playerDifficulty, isDynamicInstance, _, instanceGroupSize, lfgID = GetInstanceInfo();
	local isLFR = select(8, GetDifficultyInfo(difficulty))
	if (isLFR and lfgID) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
		local name = GetLFGDungeonInfo(lfgID);
		GameTooltip:SetText(RAID_FINDER, 1, 1, 1);
		GameTooltip:AddLine(name);
		GameTooltip:Show();
	end
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
	local _, instanceType, _, _, maxPlayers = GetInstanceInfo();
	local _, numGuildPresent, numGuildRequired, xpMultiplier = InGuildParty();
	-- hack alert
	if ( instanceType == "arena" ) then
		maxPlayers = numGuildRequired;
	end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 8, 8);
	GameTooltip:SetText(GUILD_GROUP, 1, 1, 1);
	if ( xpMultiplier < 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MINXP, numGuildRequired, maxPlayers, guildName, xpMultiplier * 100), nil, nil, nil, true);
	elseif ( xpMultiplier > 1 ) then
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE_MAXXP, guildName, xpMultiplier * 100), nil, nil, nil, true);
	else
		if ( instanceType == "party" and maxPlayers == 5 ) then
			numGuildRequired = 4;
		end
		GameTooltip:AddLine(string.format(GUILD_ACHIEVEMENTS_ELIGIBLE, numGuildRequired, maxPlayers, guildName), nil, nil, nil, true);
	end
	GameTooltip:Show();
end

function GuildInstanceDifficultyMixin:OnLeave()
	GameTooltip:Hide();
end
