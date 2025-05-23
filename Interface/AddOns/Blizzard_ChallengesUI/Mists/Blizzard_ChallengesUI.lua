local NUM_REWARDS_PER_MEDAL = 2;
local CHALLENGE_BRONZE_MEDAL_COLOR = CreateColor(0.859, 0.545, 0.204);				-- bronze
local CHALLENGE_SILVER_MEDAL_COLOR = CreateColor(0.780, 0.722, 0.741);				-- silver
local CHALLENGE_GOLD_MEDAL_COLOR = CreateColor(0.945, 0.882, 0.337);				-- gold


-- STUBS

function RequestChallengeModeLeaders(mapID)
	C_MythicPlus.RequestMapInfo();
	local maps = C_ChallengeMode.GetMapTable();
	for i = 1, #maps do
		C_ChallengeMode.RequestLeaders(maps[i]);
	end
end

function GetChallengeModeMapPlayerStats(challengeModeID)
	local info = C_MythicPlus.GetSeasonTimesForMap(challengeModeID);
	if (info == nil) then
		return nil, nil, nil;
	end
	--lastTime, bestTime, medal
	return info.lastTime, info.bestTime, info.medal
end

function GetChallengeBestTime(mapID)
	-- guildBest, realmBest
	return C_ChallengeMode.GetChallengeBestTime(mapID);
end

function ChallengesFrame_OnLoad(self)
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");

	-- set up accessors
	self.getSelection = ChallengesFrame_GetSelection;
	self.update = ChallengesFrame_Update;
	-- set up buttons
	local maps = C_ChallengeMode.GetMapTable();
	self.numMaps = #maps;
	local lastButton = ChallengeFrameChallengeButton1;
	for i = 1, self.numMaps do
		local button = _G["ChallengesFrameDungeonButton"..i];
		if ( not button ) then
			button = CreateFrame("BUTTON", "ChallengesFrameDungeonButton"..i, ChallengesFrame, "ChallengesDungeonButtonTemplate");
			button:SetPoint("TOP", lastButton, "BOTTOM", 0, -2);
			self["button"..i] = button;
		end
		local name, _, _, _, _, mapID = C_ChallengeMode.GetMapUIInfo(maps[i]);
		button.id = maps[i];
		button.text:SetText(name);
		button.mapID = mapID;
		lastButton = button;
	end

	-- reward row colors
	self.RewardRow1.Bg:SetColorTexture(CHALLENGE_BRONZE_MEDAL_COLOR:GetRGB());				-- bronze
	self.RewardRow1.MedalName:SetTextColor(CHALLENGE_BRONZE_MEDAL_COLOR:GetRGB());
	self.RewardRow2.Bg:SetColorTexture(CHALLENGE_SILVER_MEDAL_COLOR:GetRGB());				-- silver
	self.RewardRow2.MedalName:SetTextColor(CHALLENGE_SILVER_MEDAL_COLOR:GetRGB());
	self.RewardRow3.Bg:SetColorTexture(CHALLENGE_GOLD_MEDAL_COLOR:GetRGB());				-- gold
	self.RewardRow3.MedalName:SetTextColor(CHALLENGE_GOLD_MEDAL_COLOR:GetRGB());
end

function ChallengesFrame_OnEvent(self, event)
	if ( event == "CHALLENGE_MODE_MAPS_UPDATE" ) then
		ChallengesFrame_Update(self);
	elseif (event == "CHALLENGE_MODE_LEADERS_UPDATE") then
		ChallengesFrameBestTimes_Update(self);
	end
end

function ChallengesFrame_GetSelection(self)
	return self.selectedMapID;
end

function ChallengesFrame_Update(self, mapID)
	mapID = mapID or self.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	for i = 1, self.numMaps do
		local button = self["button"..i];
		local lastTime, bestTime, medal = GetChallengeModeMapPlayerStats(button.id);
		if ( CHALLENGE_MEDAL_TEXTURES_SMALL[medal] ) then
			button.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES_SMALL[medal]);
			button.MedalIcon:Show();
			button.NoMedal:Hide();
		else
			button.MedalIcon:Hide();
			button.NoMedal:Show();
		end
		if ( button.mapID == mapID ) then
			button.selectedTex:Show();
			button.text:SetFontObject("GameFontHighlight");
			self.selectedMapID = mapID;
			-- update selection details
			-- TODO: update dungeon background
			local details = self.details;
			details.MapName:SetText(button.text:GetText());
			if ( CHALLENGE_MEDAL_TEXTURES[medal] ) then
				details.NoMedalLabel:Hide();
				details.BestMedal:Show();
				details.BestMedal:SetTexture(CHALLENGE_MEDAL_TEXTURES[medal]);
			else
				details.NoMedalLabel:Show();
				details.BestMedal:Hide();
			end
			if ( lastTime ) then
				bestTime = ceil(bestTime / 1000);
				details.RecordTime:SetText(GetTimeStringFromSeconds(bestTime));
				details.RecordTime:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				lastTime = ceil(lastTime / 1000);
				details.LastRunTime:SetText(GetTimeStringFromSeconds(lastTime));
				details.LastRunTime:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				details.RecordTime:SetText(CHALLENGES_NO_TIME);
				details.RecordTime:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				details.LastRunTime:SetText(CHALLENGES_NO_TIME);
				details.LastRunTime:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			local times = C_ChallengeMode.GetChallengeModeMapTimes(mapID);
			local rewardRowIndex = 0;
			for n = NUM_CHALLENGE_MEDALS, 1, -1 do
				local rewardsRow = ChallengesFrame["RewardRow"..n];
				rewardsRow.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES_SMALL[n]);
				rewardsRow.MedalName:SetText(_G["CHALLENGE_MODE_MEDAL"..n]);
				rewardsRow.TimeLimit:SetText(GetTimeStringFromSeconds(times[n]));
				-- go through the rewards
				-- want rewards to be right-justified
				local numRewards = C_ChallengeMode.GetNumChallengeMapRewards(mapID, n);
				for rewardIndex = 1, NUM_REWARDS_PER_MEDAL do
					local rewardButton = rewardsRow["Reward"..rewardIndex];
					if rewardIndex <= numRewards then
						local itemID, itemName, iconTexture, quantity, isCurrency = C_ChallengeMode.GetChallengeMapRewardInfo(mapID, n, rewardIndex - 1);
						if ( itemID ) then
							rewardButton:Show();
							rewardButton.Icon:SetTexture(iconTexture);
							if ( quantity > 1 ) then
								rewardButton.Count:SetText(quantity);
							else
								rewardButton.Count:SetText();
							end
							rewardButton.itemID = itemID;
							rewardButton.isCurrency = isCurrency;
						else
							rewardButton:Hide();
						end
					else
						rewardButton:Hide();
					end
				end
			end
		else
			button.selectedTex:Hide();
			button.text:SetFontObject("GameFontNormal");
		end
	end
end

function ChallengesFrameBestTimes_Update(self, mapID)
	mapID = mapID or self.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	local details = self.details;
	
	local guildBest, realmBest = GetChallengeBestTime(mapID);
	
	if (guildBest) then
		guildBest = ceil(guildBest / 1000);
		details.GuildTime:SetText(GetTimeStringFromSeconds(guildBest));
		details.GuildTime.hasTime = true;
		details.GuildTime.mapID = mapID;
	else
		details.GuildTime:SetText(CHALLENGES_NO_TIME);
		details.GuildTime.hasTime = nil;
	end
	if (realmBest) then
		realmBest = ceil(realmBest / 1000);
		details.RealmTime:SetText(GetTimeStringFromSeconds(realmBest));
		details.RealmTime.hasTime = true;
		details.RealmTime.mapID = mapID;
	else
		details.RealmTime:SetText(CHALLENGES_NO_TIME);
		details.RealmTime.hasTime = nil;
	end
	
end

function ChallengesFrame_OnShow(self)
	SetPortraitToTexture(PVEFrame.portrait, "Interface\\Icons\\achievement_bg_wineos_underxminutes");
	PVEFrame.TitleText:SetText(CHALLENGES);
	local mapID = self.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	RequestChallengeModeLeaders(mapID);
end

function ChallengesFrameDungeonButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ChallengesFrame_Update(ChallengesFrame, self.mapID);
	RequestChallengeModeLeaders(self.mapID);
	ChallengesFrameBestTimes_Update(ChallengesFrame, self.mapID);
end

function ChallengesFrameLeaderboard_OnClick(self)
	local id = ChallengesFrame.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	StaticPopup_Show("CONFIRM_LAUNCH_URL", nil, nil, {index=4, mapID=id});
end

function ChallengesFrameGuild_OnEnter(self)
	local guildTime = ChallengesFrame.details.GuildTime;
	if (not guildTime.hasTime or not guildTime.mapID) then
		return;
	end

	local bestTimeInfo = C_ChallengeMode.GetChallengeGuildBestTimeInfo(guildTime.mapID);
	if (not bestTimeInfo or #bestTimeInfo.members == 0) then
		return;
	end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHALLENGE_MODE_GUILD_BEST);

	for i = 1, #bestTimeInfo.members do
		local member = bestTimeInfo.members[i];
		local name, className, class, specID = member.name, member.className, member.classFileName, member.specializationID;
		if (name) then
			local classColor = RAID_CLASS_COLORS[class].colorStr;
			local specName = GetSpecializationNameForSpecID(specID);
			if (specName and specName ~= "") then
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS, classColor, specName, className));
			else
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS_NO_SPEC, classColor, className));
			end
		end
	end
	
	GameTooltip:Show();
end

function ChallengesFrameRealm_OnEnter(self)
	local realmTime = ChallengesFrame.details.RealmTime;
	if (not realmTime.hasTime or not realmTime.mapID) then
		return;
	end

	local bestTimeInfo = C_ChallengeMode.GetChallengeRealmBestTimeInfo(realmTime.mapID);
	if (not bestTimeInfo or #bestTimeInfo.members == 0) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHALLENGE_MODE_REALM_BEST);

	for i = 1, #bestTimeInfo.members do
		local member = bestTimeInfo.members[i];
		local name, className, class, specID = member.name, member.className, member.classFileName, member.specializationID;
		if (name) then
			local classColor = RAID_CLASS_COLORS[class].colorStr;
			local specName = GetSpecializationNameForSpecID(specID);
			if (specName and specName ~= "") then
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS, classColor, specName, className));
			else
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS_NO_SPEC, classColor, className));
			end
		end
	end
	
	GameTooltip:Show();
end
