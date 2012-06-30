local NUM_REWARDS_PER_MEDAL = 2;

function ChallengesFrame_OnLoad(self)
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	RequestChallengeModeMapInfo();
	RequestChallengeModeRewards();
	-- set up accessors
	self.getSelection = ChallengesFrame_GetSelection;
	self.update = ChallengesFrame_Update;
	-- set up buttons
	local maps = { };
	GetChallengeModeMapTable(maps);
	self.numMaps = #maps;
	local lastButton = ChallengeFrameChallengeButton1;
	for i = 1, self.numMaps do
		local button = _G["ChallengesFrameDungeonButton"..i];
		if ( not button ) then
			button = CreateFrame("BUTTON", "ChallengesFrameDungeonButton"..i, ChallengesFrame, "ChallengesDungeonButtonTemplate");
			button:SetPoint("TOP", lastButton, "BOTTOM", 0, -2);
			self["button"..i] = button;
		end
		local name, mapID = GetChallengeModeMapInfo(maps[i]);
		button.id = maps[i];
		button.text:SetText(name);
		button.mapID = mapID;
		lastButton = button;
	end
	-- reward row colors
	self.RewardRow1.Bg:SetTexture(0.859, 0.545, 0.204);				-- bronze
	self.RewardRow1.MedalName:SetTextColor(0.859, 0.545, 0.204);
	self.RewardRow2.Bg:SetTexture(0.780, 0.722, 0.741);				-- silver
	self.RewardRow2.MedalName:SetTextColor(0.780, 0.722, 0.741);
	self.RewardRow3.Bg:SetTexture(0.945, 0.882, 0.337);				-- gold
	self.RewardRow3.MedalName:SetTextColor(0.945, 0.882, 0.337);
end

function ChallengesFrame_OnEvent(self, event)
	ChallengesFrame_Update(self);
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
			
			local times = { GetChallengeModeMapTimes(mapID) };
			local rewardRowIndex = 0;
			for medal = NUM_CHALLENGE_MEDALS, 1, -1 do
				local rewardsRow = ChallengesFrame["RewardRow"..medal];
				rewardsRow.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES_SMALL[medal]);
				rewardsRow.MedalName:SetText(_G["CHALLENGE_MODE_MEDAL"..medal]);
				rewardsRow.TimeLimit:SetText(GetTimeStringFromSeconds(times[medal]));
				-- go through the rewards
				-- want rewards to be right-justified
				local rewardIndexOffset = GetNumChallengeMapRewards(mapID, medal) - NUM_REWARDS_PER_MEDAL;
				for rewardIndex = 1, NUM_REWARDS_PER_MEDAL do
					local itemID, itemName, iconTexture, quantity, isCurrency = GetChallengeMapRewardInfo(mapID, medal, rewardIndex + rewardIndexOffset);
					local rewardButton = rewardsRow["Reward"..rewardIndex];
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
				end
			end
		else
			button.selectedTex:Hide();
			button.text:SetFontObject("GameFontNormal");
		end
	end
end

function ChallengesFrame_OnShow(self)
	SetPortraitToTexture(PVEFrame.portrait, "Interface\\Icons\\INV_Misc_Ribbon_01");
	PVEFrame.TitleText:SetText(CHALLENGES);
end

function ChallengesFrameDungeonButton_OnClick(self, button)
	ChallengesFrame_Update(ChallengesFrame, self.mapID);
end