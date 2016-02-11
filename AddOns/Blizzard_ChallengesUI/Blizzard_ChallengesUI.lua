local NUM_REWARDS_PER_MEDAL = 2;

function ChallengesFrame_OnLoad(self)
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");

	
	-- set up accessors
	self.getSelection = ChallengesFrame_GetSelection;
	self.update = ChallengesFrame_Update;
	-- set up buttons
	local maps = { };
	C_ChallengeMode.GetMapTable(maps);
	self.numMaps = #maps;
	local lastButton = ChallengeFrameChallengeButton1;
	for i = 1, self.numMaps do
		local button = _G["ChallengesFrameDungeonButton"..i];
		if ( not button ) then
			button = CreateFrame("BUTTON", "ChallengesFrameDungeonButton"..i, ChallengesFrame, "ChallengesDungeonButtonTemplate");
			button:SetPoint("TOP", lastButton, "BOTTOM", 0, -2);
			self["button"..i] = button;
		end
		local name, mapID = C_ChallengeMode.GetMapInfo(maps[i]);
		button.id = maps[i];
		button.text:SetText(name);
		button.mapID = mapID;
		lastButton = button;
	end

	-- reward row colors
	self.RewardRow1.Bg:SetColorTexture(0.859, 0.545, 0.204);				-- bronze
	self.RewardRow1.MedalName:SetTextColor(0.859, 0.545, 0.204);
	self.RewardRow2.Bg:SetColorTexture(0.780, 0.722, 0.741);				-- silver
	self.RewardRow2.MedalName:SetTextColor(0.780, 0.722, 0.741);
	self.RewardRow3.Bg:SetColorTexture(0.945, 0.882, 0.337);				-- gold
	self.RewardRow3.MedalName:SetTextColor(0.945, 0.882, 0.337);
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
			
			local rewardRowIndex = 0;
			for medal = NUM_CHALLENGE_MEDALS, 1, -1 do
				local rewardsRow = ChallengesFrame["RewardRow"..medal];
				rewardsRow.MedalIcon:SetTexture(CHALLENGE_MEDAL_TEXTURES_SMALL[medal]);
				rewardsRow.MedalName:SetText(_G["CHALLENGE_MODE_MEDAL"..medal]);
				rewardsRow.TimeLimit:SetText(GetTimeStringFromSeconds(0));
				-- go through the rewards
				-- want rewards to be right-justified
				local rewardIndexOffset = C_ChallengeMode.GetNumMapRewards(mapID, medal) - NUM_REWARDS_PER_MEDAL;
				for rewardIndex = 1, NUM_REWARDS_PER_MEDAL do
					local itemID, itemName, iconTexture, quantity, isCurrency = C_ChallengeMode.GetMapRewardInfo(mapID, medal, rewardIndex + rewardIndexOffset);
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
	C_ChallengeMode.RequestMapInfo();
	C_ChallengeMode.RequestRewards();
	local mapID = self.selectedMapID or ChallengesFrameDungeonButton1.mapID;
	C_ChallengeMode.RequestLeaders(mapID);
end

function ChallengesFrameDungeonButton_OnClick(self, button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	ChallengesFrame_Update(ChallengesFrame, self.mapID);
	C_ChallengeMode.RequestLeaders(self.mapID);
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
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHALLENGE_MODE_GUILD_BEST);
	
	local numGuildBest = GetChallengeBestTimeNum(guildTime.mapID, true);
	for i = 1, numGuildBest do
		local name, className, class, specID, gender = GetChallengeBestTimeInfo(guildTime.mapID, i, true);
		if (name) then
			local classColor = RAID_CLASS_COLORS[class].colorStr;
			local _, specName = GetSpecializationInfoByID(specID, gender);
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
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHALLENGE_MODE_REALM_BEST);
	local numRealmBest = GetChallengeBestTimeNum(realmTime.mapID, false);
	for i = 1, numRealmBest do
		local name, className, class, specID, gender = GetChallengeBestTimeInfo(realmTime.mapID, i, false);
		if (name) then
			local classColor = RAID_CLASS_COLORS[class].colorStr;
			local _, specName = GetSpecializationInfoByID(specID, gender);
			if (specName and specName ~= "") then
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS, classColor, specName, className));
			else
				GameTooltip:AddLine(name.." - "..format(PLAYER_CLASS_NO_SPEC, classColor, className));
			end
		end
	end
	
	GameTooltip:Show();
end

ChallengesKeystoneFrameMixin = {};

function ChallengesKeystoneFrameMixin:OnLoad()
	self.baseStates = {};
	
	local regions = {self:GetRegions()};
	for i = 1, #regions do
		local r = regions[i];
		self.baseStates[r] = {
			["shown"] = r:IsShown(),
			["alpha"] = r:GetAlpha(),
		};
	end
end

function ChallengesKeystoneFrameMixin:OnHide()
	C_ChallengeMode.CloseKeystoneFrame();
	C_ChallengeMode.ClearKeystone();
	self:Reset();
end

function ChallengesKeystoneFrameMixin:Reset()
	self.KeystoneSlot:Reset();
	self.PulseAnim:Stop();
	self.InsertedAnim:Stop();
	self.RunesLargeAnim:Stop();
	self.RunesLargeRotateAnim:Stop();
	self.RunesSmallAnim:Stop();
	self.RunesSmallRotateAnim:Stop();
	self.StartButton:Disable();
	
	for i = 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end

	for k, v in pairs(self.baseStates) do
		k:SetShown(v.shown);
		k:SetAlpha(v.alpha);
	end
end

function ChallengesKeystoneFrameMixin:OnMouseUp()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

function ChallengesKeystoneFrameMixin:ShowKeystoneFrame()
	local _, _, _, _, _, _, _, mapID = GetInstanceInfo();
	local name, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID);

	self.DungeonName:SetText(name);
	self.TimeLimit:SetText(SecondsToTime(timeLimit, false, true));

	self:Show();
end

function ChallengesKeystoneFrameMixin:CreateAndPositionAffixes(num)
	local index = #self.Affixes + 1;
	local frameWidth, spacing, distance = 52, 4, -34;
	while (#self.Affixes < num) do
		local frame = CreateFrame("Frame", nil, self, "ChallengesKeystoneFrameAffixTemplate");
		local prev = self.Affixes[index - 1];
		frame:SetPoint("LEFT", prev, "RIGHT", spacing, 0);
		index = index + 1;
	end
	-- Figure out where to place the leftmost spell
	local frame = self.Affixes[1];
	frame:ClearAllPoints();
	if (num % 2 == 1) then
		local x = (num - 1) / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth / 2) + (frameWidth * x) + (spacing * x)), distance);
	else
		local x = num / 2;
		frame:SetPoint("TOPLEFT", self.Divider, "TOP", -((frameWidth * x) + (spacing * (x - 1)) + (spacing / 2)), distance);
	end
	
	for i = num + 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneSlotted()
	self.InsertedAnim:Play();
	self.RunesLargeAnim:Play();
	self.RunesSmallAnim:Play();
	self.RunesLargeRotateAnim:Play();
	self.RunesSmallRotateAnim:Play();
	self.InstructionBackground:Hide();
	self.Instructions:Hide();
	self.TimeLimit:Show();
	local mapID, affixes, powerLevel, charged = C_ChallengeMode.GetSlottedKeystoneInfo();
	
	self.PowerLevel:SetText(CHALLENGE_MODE_POWER_LEVEL:format(powerLevel));
	self.PowerLevel:Show();
	
	local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel);
	
	self:CreateAndPositionAffixes(2 + #affixes);
	
	self.Affixes[1]:SetUp({key = "dmg", pct = dmgPct});
	self.Affixes[2]:SetUp({key = "health", pct = healthPct});
	

	for i = 1, #affixes do
		self.Affixes[i+2]:SetUp(affixes[i]);
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneRemoved()
	self:Reset();
	self.StartButton:Disable();
end

function ChallengesKeystoneFrameMixin:OnChallengeStarted()
	self.ActivateAnim:Play();
end

ChallengesKeystoneSlotMixin = {};

function ChallengesKeystoneSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED");
end

function ChallengesKeystoneSlotMixin:OnEvent(event, ...)
	if (event == "CHALLENGE_MODE_KEYSTONE_SLOTTED") then
		local itemID= ...;
		
		local texture = select(10, GetItemInfo(itemID));
		
		SetPortraitToTexture(self.Texture, texture);
		
		self:GetParent():OnKeystoneSlotted();
	end
end

function ChallengesKeystoneSlotMixin:OnEnter()
	if (C_ChallengeMode.HasSlottedKeystone()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		C_ChallengeMode.SetKeystoneTooltip();
		GameTooltip:Show();
	end
end

function ChallengesKeystoneSlotMixin:Reset()
	self.Texture:SetTexture(nil);
end

function ChallengesKeystoneSlotMixin:OnReceiveDrag()
	C_ChallengeMode.SlotKeystone();
end

function ChallengesKeystoneSlotMixin:OnDragStart()
	if (C_ChallengeMode.RemoveKeystone()) then
		self:GetParent():Reset();
	end
end

function ChallengesKeystoneSlotMixin:OnClick()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

ChallengesKeystoneFrameAffixMixin = {};

CHALLENGE_MODE_EXTRA_AFFIX_INFO = {
	["dmg"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_DAMAGE_DESCRIPTION,
		texture = "Interface\\Icons\\Ability_DualWield",
	},
	["health"] = {
		name = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH,
		desc = CHALLENGE_MODE_ENEMY_EXTRA_HEALTH_DESCRIPTION,
		texture = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
	},
};

function ChallengesKeystoneFrameAffixMixin:OnEnter()
	if (self.affixID or self.info) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		
		local name, description;

		if (self.info) then
			local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[self.info.key];
			name = tbl.name;
			description = string.format(tbl.desc, self.info.pct);
		else
			name, description = C_ChallengeMode.GetAffixInfo(self.affixID);
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, 1, 1, 1, 1, true);
		GameTooltip:AddLine(description);
		GameTooltip:Show();
	end
end

function ChallengesKeystoneFrameAffixMixin:SetUp(affixInfo)
	if (type(affixInfo) == "table") then
		local info = affixInfo;

		SetPortraitToTexture(self.Portrait, CHALLENGE_MODE_EXTRA_AFFIX_INFO[info.key].texture);
	
		self.Percent:SetText(("+%d%%"):format(info.pct));
		self.Percent:Show();

		self.info = info;
	else
		local affixID = affixInfo;

		local _, _, filedataid = C_ChallengeMode.GetAffixInfo(affixID);

		SetPortraitToTexture(self.Portrait, filedataid);

		self.Percent:Hide();

		self.affixID = affixID;
	end

	self:Show();
end