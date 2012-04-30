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
end

function ChallengesFrame_OnEvent(self, event)
	ChallengesFrame_Update(self);
end

function ChallengesFrame_GetSelection(self)
	return self.selectedMapID;
end

function ChallengesFrame_Update(self, mapID)
	mapID = mapID or self.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	local times = { };
	for i = 1, self.numMaps do
		local button = self["button"..i];
		local lastTime, bestTime, medal = GetChallengeModeMapPlayerStats(button.id);
		SetChallengeModeMedalTexture(button.medal, medal, 35, 7, 0);
		if ( button.mapID == mapID ) then
			button.selectedTex:Show();
			button.text:SetFontObject("GameFontHighlight");
			self.selectedMapID = mapID;
			-- update selection details
			-- TODO: update dungeon background
			local details = self.details;
			details.mapName:SetText(button.text:GetText());
			if ( not medal or medal == CHALLENGE_MEDAL_NONE ) then
				details.noMedal:Show();
				details.bestMedal:Hide();
			else
				details.noMedal:Hide();
				details.bestMedal:Show();
				SetChallengeModeMedalTexture(details.bestMedal, medal);
			end
			if ( lastTime ) then
				bestTime = ceil(bestTime / 1000);
				details.recordTime:SetText(GetTimeStringFromSeconds(bestTime));
				details.recordTime:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				lastTime = ceil(lastTime / 1000);
				details.lastRunTime:SetText(GetTimeStringFromSeconds(lastTime));
				details.lastRunTime:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			else
				details.recordTime:SetText(CHALLENGES_NO_TIME);
				details.recordTime:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				details.lastRunTime:SetText(CHALLENGES_NO_TIME);
				details.lastRunTime:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			times = { GetChallengeModeMapTimes(mapID) };
			for i = 1, NUM_CHALLENGE_MEDALS do
				details["time"..i]:SetText(GetTimeStringFromSeconds(times[i]));
				if ( medal and medal >= i ) then
					details["medal"..i]:SetAlpha(1);
					details["time"..i]:SetFontObject("GameFontHighlight");
				else
					details["medal"..i]:SetAlpha(0.5);
					details["time"..i]:SetFontObject("GameFontDisable");
				end
			end
			-- rewards
			local rewardRowIndex = 0;
			for medalIndex = NUM_CHALLENGE_MEDALS, 1, -1 do
				local numRewards = GetNumChallengeMapRewards(mapID, medalIndex);
				-- only do work if there are rewards for a medal
				if ( numRewards > 0 ) then
					-- show and set the medal
					rewardRowIndex = rewardRowIndex + 1;
					local rewardsRow = ChallengesFrame["rewardRow"..rewardRowIndex];
					rewardsRow:Show();
					SetChallengeModeMedalTexture(rewardsRow.medalIcon, medalIndex);
					-- go through the rewards
					for rewardIndex = 1, NUM_REWARDS_PER_MEDAL do
						local itemID, itemName, iconTexture, quantity, isCurrency = GetChallengeMapRewardInfo(mapID, medalIndex, rewardIndex);
						local rewardButton = rewardsRow["item"..rewardIndex];
						if ( itemID ) then
							-- set the reward and show the reward button
							rewardButton:Show();
							rewardButton.name:SetText(itemName);
							rewardButton.icon:SetTexture(iconTexture);
							if ( quantity > 1 ) then
								rewardButton.count:SetText(quantity);
							else
								rewardButton.count:SetText();
							end
							rewardButton.itemID = itemID;
							rewardButton.isCurrency = isCurrency;
						else
							rewardButton:Hide();
						end
					end
				end
			end
			-- hide entire rows of unused rewards
			for row = rewardRowIndex + 1, NUM_CHALLENGE_MEDALS do
				ChallengesFrame["rewardRow"..row]:Hide();
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