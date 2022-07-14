local NUM_REWARDS_PER_MEDAL = 2;
local MAXIMUM_REWARDS_LEVEL = 15;
local MAX_PER_ROW = 9;

local LEGENDARY_COMPLETION_LEVEL = 15;
local EPIC_COMPLETION_LEVEL = 10;
local RARE_COMPLETION_LEVEL = 7;
local UNCOMMON_COMPLETION_LEVEL = 4;
local COMMON_COMPLETION_LEVEL = 2;

local CHEST_STATE_WALL_OF_TEXT = 1;
local CHEST_STATE_INCOMPLETE = 2;
local CHEST_STATE_COMPLETE = 3;
local CHEST_STATE_COLLECT = 4;

local SHADOWLANDS_FIRST_SEASON = 5;

local function GetRunQualityBasedOnLevel(level)
	if (level >= LEGENDARY_COMPLETION_LEVEL) then
		return Enum.ItemQuality.Legendary; 
	elseif (level < LEGENDARY_COMPLETION_LEVEL and level >= EPIC_COMPLETION_LEVEL) then
		return Enum.ItemQuality.Epic;
	elseif (level < EPIC_COMPLETION_LEVEL and level >= RARE_COMPLETION_LEVEL) then
		return Enum.ItemQuality.Rare;
	elseif (level < RARE_COMPLETION_LEVEL and level >= UNCOMMON_COMPLETION_LEVEL) then
		return Enum.ItemQuality.Uncommon;
	elseif (level < UNCOMMON_COMPLETION_LEVEL and level >= COMMON_COMPLETION_LEVEL) then
		return Enum.ItemQuality.Common;
	else 
		return Enum.ItemQuality.Poor;
	end
end 

local function CreateFrames(self, array, num, template)
    while (#self[array] < num) do
		local frame = CreateFrame("Frame", nil, self, template);
	end

    for i = num + 1, #self[array] do
		self[array][i]:Hide();
	end
end

local function ReanchorFrames(frames, anchorPoint, anchor, relativePoint, width, spacing, distance)
    local num = #frames;
    local numButtons = math.min(MAX_PER_ROW, num);
    local fullWidth = (width * numButtons) + (spacing * (numButtons - 1));
    local halfWidth = fullWidth / 2;

    local numRows = math.floor((num + MAX_PER_ROW - 1) / MAX_PER_ROW) - 1;
    local fullDistance = numRows * frames[1]:GetHeight() + (numRows + 1) * distance;

    -- First frame
    frames[1]:ClearAllPoints();
    frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, fullDistance);

    -- first row
    for i = 2, math.min(MAX_PER_ROW, #frames) do
        frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
    end

    -- n-rows after
    if (num > MAX_PER_ROW) then
        local currentExtraRow = 0;
        local finished = false;
        repeat
            local setFirst = false;
            for i = (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + 1, (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow)) + MAX_PER_ROW do
                if (not frames[i]) then
                    finished = true;
                    break;
                end
                if (not setFirst) then
                    frames[i]:SetPoint("TOPLEFT", frames[i - (MAX_PER_ROW + (MAX_PER_ROW * currentExtraRow))], "BOTTOMLEFT", 0, -distance);
                    setFirst = true;
                else
                    frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", spacing, 0);
                end
            end
            currentExtraRow = currentExtraRow + 1;
        until finished;
    end
end

local function LineUpFrames(frames, anchorPoint, anchor, relativePoint, width)
    local num = #frames;

	local distanceBetween = 2;
	local spacingWidth = distanceBetween * num;
	local widthRemaining = width - spacingWidth;

    local halfWidth = width / 2;

	local calculateWidth = widthRemaining / num;

    -- First frame
    frames[1]:ClearAllPoints();
	if(frames[1].Icon) then
		frames[1].Icon:SetSize(calculateWidth, calculateWidth);
	end
	frames[1]:SetSize(calculateWidth, calculateWidth);
    frames[1]:SetPoint(anchorPoint, anchor, relativePoint, -halfWidth, 5);

	for i = 2, #frames do
		if(frames[i].Icon) then
			frames[i].Icon:SetSize(calculateWidth, calculateWidth);
		end
		frames[i].Icon:SetSize(calculateWidth, calculateWidth);
		frames[i]:SetSize(calculateWidth, calculateWidth);
		frames[i]:SetPoint("LEFT", frames[i-1], "RIGHT", distanceBetween, 0);
	end

end

function ChallengesFrame_OnLoad(self)
	-- events
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED");
    self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
	self:RegisterEvent("CHALLENGE_MODE_RESET");

    self.leadersAvailable = false;
	self.maps = C_ChallengeMode.GetMapTable();
end

function ChallengesFrame_OnEvent(self, event)
	if (event == "CHALLENGE_MODE_RESET") then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
	else
        if (event == "CHALLENGE_MODE_LEADERS_UPDATE") then
            self.leadersAvailable = true;
        end
        ChallengesFrame_Update(self);
	end
end

function ChallengesFrame_OnShow(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
	self:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");

    PVEFrame:SetPortraitToAsset("Interface\\Icons\\achievement_bg_wineos_underxminutes");
	PVEFrame.TitleText:SetText(CHALLENGES);
	PVEFrame_HideLeftInset();

	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
	if GetServerExpansionLevel() < LE_EXPANSION_SHADOWLANDS then
		C_MythicPlus.RequestRewards();
	end
    for i = 1, #self.maps do
        C_ChallengeMode.RequestLeaders(self.maps[i]);
    end
    ChallengesFrame_Update(self);
end

function ChallengesFrame_OnHide(self)
    PVEFrame_ShowLeftInset();
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
	self:UnregisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE");
end

function ChallengesFrame_Update(self)
    local sortedMaps = {};

    local hasWeeklyRun = false;
    for i = 1, #self.maps do
		local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.maps[i]);
		local level, quality; 
        if (not inTimeInfo) then
			if(overtimeInfo) then 
				level = overtimeInfo.level; 
			else
				level = 0; 
			end
			tinsert(sortedMaps, { id = self.maps[i], level = level, quality = Enum.ItemQuality.Poor});
        else
			level = inTimeInfo.level; 
			quality = GetRunQualityBasedOnLevel(level);
            hasWeeklyRun = true;
			tinsert(sortedMaps, { id = self.maps[i], level = level, quality = quality, inTime = true});
		end

    end
	
    table.sort(sortedMaps, 
	function(a, b) 
		if(a.inTime ~= b.inTime) then 
			return a.inTime;
		end 
		return a.level > b.level; 
	end);

	local weeklySortedMaps = {};
	 for i = 1, #self.maps do
		local _, weeklyLevel = C_MythicPlus.GetWeeklyBestForMap(self.maps[i])
        if (not weeklyLevel) then
            weeklyLevel = 0;
        else
            hasWeeklyRun = true;
        end
        tinsert(weeklySortedMaps, { id = self.maps[i], weeklyLevel = weeklyLevel});
     end

    table.sort(weeklySortedMaps, function(a, b) return a.weeklyLevel > b.weeklyLevel end);

    local frameWidth = self.WeeklyInfo:GetWidth()

    local num = #sortedMaps;

    CreateFrames(self, "DungeonIcons", num, "ChallengesDungeonIconFrameTemplate");
    LineUpFrames(self.DungeonIcons, "BOTTOMLEFT", self, "BOTTOM", frameWidth);

    for i = 1, #sortedMaps do
        local frame = self.DungeonIcons[i];
        frame:SetUp(sortedMaps[i], i == 1);
        frame:Show();

		if (i == 1) then
			self.WeeklyInfo.Child.SeasonBest:ClearAllPoints();
			self.WeeklyInfo.Child.SeasonBest:SetPoint("TOPLEFT", self.DungeonIcons[i], "TOPLEFT", 5, 15);
		end
    end

    local _, _, _, _, backgroundTexture = C_ChallengeMode.GetMapUIInfo(sortedMaps[1].id);
    if (backgroundTexture ~= 0) then
        self.Background:SetTexture(backgroundTexture);
    end

    self.WeeklyInfo:SetUp(hasWeeklyRun, sortedMaps[1]);

	local activeChest, inactiveChest;
	if GetServerExpansionLevel() < LE_EXPANSION_SHADOWLANDS then
		activeChest = self.WeeklyInfo.Child.LegacyWeeklyChest;
		inactiveChest = self.WeeklyInfo.Child.WeeklyChest;
	else
		activeChest = self.WeeklyInfo.Child.WeeklyChest;
		inactiveChest = self.WeeklyInfo.Child.LegacyWeeklyChest;
	end

	local bestMapID = weeklySortedMaps[1].id;
	local chestState = activeChest:Update(bestMapID);

	activeChest:SetShown(chestState ~= CHEST_STATE_WALL_OF_TEXT);	
	inactiveChest:Hide();

	if chestState == CHEST_STATE_COLLECT then
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();	
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_COMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	elseif chestState == CHEST_STATE_INCOMPLETE then
		self.WeeklyInfo.Child.ThisWeekLabel:Show();
		self.WeeklyInfo.Child.Description:Hide();
	else
		self.WeeklyInfo.Child.ThisWeekLabel:Hide();
		self.WeeklyInfo.Child.Description:Show();
		if sortedMaps[1].level == 0 and not C_MythicPlus.GetOwnedKeystoneLevel() then
			self.WeeklyInfo:HideAffixes();
		end
	end

	local lastSeasonNumber = tonumber(GetCVar("newMythicPlusSeason"));
	local currentSeason = C_MythicPlus.GetCurrentSeason(); 
	if (currentSeason and lastSeasonNumber < currentSeason) then 
		local noticeFrame = self.SeasonChangeNoticeFrame;
		if (currentSeason == SHADOWLANDS_FIRST_SEASON) then
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_FIRST_SEASON);
			noticeFrame.SeasonDescription2:SetText(nil);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription, "BOTTOM", 0, -14);
		else
			noticeFrame.SeasonDescription:SetText(MYTHIC_PLUS_SEASON_DESC1);
			noticeFrame.SeasonDescription2:SetText(MYTHIC_PLUS_SEASON_DESC2);
			noticeFrame.SeasonDescription3:SetPoint("TOP", noticeFrame.SeasonDescription2, "BOTTOM", 0, -14);
		end
		noticeFrame.Affix:Hide();
		local affixes = C_MythicPlus.GetCurrentAffixes();
		if (affixes) then
			for i, affix in ipairs(affixes) do
				if(affix.seasonID == currentSeason) then 
					noticeFrame.Affix:SetUp(affix.id);
					local affixName = C_ChallengeMode.GetAffixInfo(affix.id);
					noticeFrame.SeasonDescription3:SetText(MYTHIC_PLUS_SEASON_DESC3:format(affixName));
					break; 
				end
			end
		end
		self.SeasonChangeNoticeFrame:Show(); 
	end
end

ChallengeModeWeeklyChestMixin = { };

function ChallengeModeWeeklyChestMixin:Update(bestMapID)
	local chestState = CHEST_STATE_WALL_OF_TEXT;

	if C_WeeklyRewards.HasAvailableRewards() then
		chestState = CHEST_STATE_COLLECT;

		self.Icon:SetAtlas("mythicplus-greatvault-collect", TextureKitConstants.UseAtlasSize);
		self.RunStatus:SetText(MYTHIC_PLUS_COLLECT_GREAT_VAULT);
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	elseif self:HasUnlockedRewards() then
		chestState = CHEST_STATE_COMPLETE;

		self.Icon:SetAtlas("mythicplus-greatvault-complete", TextureKitConstants.UseAtlasSize);
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	elseif C_MythicPlus.GetOwnedKeystoneLevel() then
		chestState = CHEST_STATE_INCOMPLETE;

		self.Icon:SetAtlas("mythicplus-greatvault-incomplete", TextureKitConstants.UseAtlasSize);	
		self.RunStatus:SetText(MYTHIC_PLUS_COMPLETE_MYTHIC_DUNGEONS);
		self.AnimTexture:Hide();
	end

	self.state = chestState;
	return chestState;
end

function ChallengeModeWeeklyChestMixin:HasUnlockedRewards()
	local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
		if activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus and activityInfo.progress >= activityInfo.threshold then
			return true;
		end
	end
	return false;
end	

local function GetLowestLevelInTopRuns(numRuns)
	local runHistory = C_MythicPlus.GetRunHistory();
	table.sort(runHistory, function(left, right) return left.level > right.level; end);
	local lowestLevel;
	local lowestCount = 0;
	for i = math.min(numRuns, #runHistory), 1, -1 do
		local run = runHistory[i];
		if not lowestLevel then
			lowestLevel = run.level;
		end
		if lowestLevel == run.level then
			lowestCount = lowestCount + 1;
		else
			break;
		end
	end
	return lowestLevel, lowestCount;
end

function ChallengeModeWeeklyChestMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	-- always direct players to great vault if there are rewards to be claimed
	if self.state == CHEST_STATE_COLLECT then
		GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	-- now determine progress for this week
	local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus);
	table.sort(activities, function(left, right) return left.index < right.index; end);
	local lastCompletedIndex = 0;
	for i, activityInfo in ipairs(activities) do
		if activityInfo.progress >= activityInfo.threshold then
			lastCompletedIndex = i;
		end
	end
	if lastCompletedIndex == 0 then
		GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
	else
		if lastCompletedIndex == #activities then
			GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
			local info = activities[lastCompletedIndex];
			local level, count = GetLowestLevelInTopRuns(info.threshold);
			GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, level + 1));
		else
			local nextInfo = activities[lastCompletedIndex + 1];
			local textString = (lastCompletedIndex == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
			local level, count = GetLowestLevelInTopRuns(nextInfo.threshold);
			GameTooltip_AddNormalLine(GameTooltip, textString:format(nextInfo.threshold - nextInfo.progress, nextInfo.threshold, level));
		end
	end

	GameTooltip:Show();
end

ChallengeModeLegacyWeeklyChestMixin = {};

function ChallengeModeLegacyWeeklyChestMixin:Update(bestMapID)
	self.name = C_ChallengeMode.GetMapUIInfo(bestMapID);
	self.ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel();
	self.level, self.rewardLevel, self.nextRewardLevel, self.nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel();

	local chestState = CHEST_STATE_WALL_OF_TEXT;

	if C_MythicPlus.IsWeeklyRewardAvailable() then
		chestState = CHEST_STATE_COLLECT;

		self.challengeMapId, self.level = C_MythicPlus.GetLastWeeklyBestInformation();
		self.name = C_ChallengeMode.GetMapUIInfo(self.challengeMapId);
		self.rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(self.level);
		self.CollectChest.FinalKeyLevel:SetText(MYTHIC_PLUS_WEEKLY_CHEST_LEVEL:format(self.name, self.level));
		self:SetupChest(self.CollectChest);

		self.RunStatus:SetPoint("TOP", 0, 87);
		self.RunStatus:SetText(MYTHIC_PLUS_CLAIM_REWARD_MESSAGE);
		self:GetParent():GetParent():HideAffixes();
	elseif self.level > 0 then
		chestState = CHEST_STATE_COMPLETE;

		self:SetupChest(self.CompletedKeystoneChest);

		self.RunStatus:SetPoint("TOP", 0, 25);
		self.RunStatus:SetText(MYTHIC_PLUS_BEST_WEEKLY:format(self.name, self.level));
	elseif self.ownedKeystoneLevel then
		chestState = CHEST_STATE_INCOMPLETE;

		self.rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(self.ownedKeystoneLevel);
		self:SetupChest(self.MissingKeystoneChest);

		self.RunStatus:SetPoint("TOP", 0, 25);
		self.RunStatus:SetText(MYTHIC_PLUS_INCOMPLETE_WEEKLY_KEYSTONE);
	end

	return chestState;
end

function ChallengeModeLegacyWeeklyChestMixin:SetupChest(chestFrame)
	if (chestFrame == self.CollectChest) then
		self.MissingKeystoneChest:Hide();
		self.CompletedKeystoneChest:Hide();
		chestFrame.Anim:Play();
		chestFrame.SparkleRotation:Play();

		chestFrame:Show();
		chestFrame.Level:SetText(self.level);

		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel);

		if (self.level >= MAXIMUM_REWARDS_LEVEL) then
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR:GetRGB());
		else
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	elseif (chestFrame == self.CompletedKeystoneChest) then
		self.MissingKeystoneChest:Hide();
		self.CollectChest:Hide();
		self.CollectChest.Anim:Stop();
		self.CollectChest.SparkleRotation:Stop();

		chestFrame:Show();

		chestFrame.Level:SetText(self.level);

		self.rewardTooltipText = MYTHIC_PLUS_WEEKLY_CHEST_REWARD:format(self.rewardLevel);

		if (self.level >= MAXIMUM_REWARDS_LEVEL) then
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_ABOVE_15;
			chestFrame.Level:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		else
			--This is a special case, if two levels share the same item level reward, we want to show the next highest level! 
			self.rewardTooltipText2 = MYTHIC_PLUS_CHEST_LEVEL_BELOW_15:format(self.nextBestLevel, self.nextRewardLevel); 
			chestFrame.Level:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	elseif (chestFrame == self.MissingKeystoneChest) then
		self.CompletedKeystoneChest:Hide();
		self.CollectChest:Hide();
		self.CollectChest.Anim:Stop();
		self.CollectChest.SparkleRotation:Stop();
		chestFrame:Show();

		self.rewardTooltipText2 = nil;
		self.rewardTooltipText = MYTHIC_PLUS_MISSING_WEEKLY_CHEST_REWARD:format(self.ownedKeystoneLevel, self.rewardLevel);
	end
end

function ChallengeModeLegacyWeeklyChestMixin:OnEnter()
	GameTooltip:SetText(" ");
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -15);
	if (self.level > 0) then
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.level), HIGHLIGHT_FONT_COLOR);
	elseif (self.ownedKeystoneLevel) then
		GameTooltip_SetTitle(GameTooltip, MYTHIC_PLUS_CHEST_KEYSTONE_LEVEL:format(self.ownedKeystoneLevel), HIGHLIGHT_FONT_COLOR);
	end
	if (self.rewardTooltipText) then 
		GameTooltip_AddNormalLine(GameTooltip, self.rewardTooltipText, true);
	end
	if (self.rewardTooltipText2) then 
		GameTooltip:AddLine(" "); 
		GameTooltip_AddNormalLine(GameTooltip, self.rewardTooltipText2, true);
	end
    GameTooltip:Show();
end

ChallengesDungeonIconMixin = {};

function ChallengesDungeonIconMixin:SetUp(mapInfo, isFirst)
    self.mapID = mapInfo.id;

    local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(mapInfo.id);

    if (texture == 0) then
        texture = "Interface\\Icons\\achievement_bg_wineos_underxminutes";
    end

    self.Icon:SetTexture(texture);
    self.Icon:SetDesaturated(mapInfo.level == 0);

	local color = ITEM_QUALITY_COLORS[mapInfo.quality]; 

    if (mapInfo.level > 0) then
        self.HighestLevel:SetText(mapInfo.level);
        self.HighestLevel:SetTextColor(color.r, color.g, color.b);
        self.HighestLevel:Show();
    else
        self.HighestLevel:Hide();
    end
end


function ChallengesDungeonIconMixin:OnEnter()
    local name = C_ChallengeMode.GetMapUIInfo(self.mapID);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(name, 1, 1, 1);

    local inTimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(self.mapID);
	local isOverTimeRun = false; 

	local seasonBestDurationSec, seasonBestLevel, members; 

	--If there is a best overtime run we want to show that as well. 
	if(not inTimeInfo and overtimeInfo) then 
		seasonBestDurationSec = overtimeInfo.durationSec; 
		seasonBestLevel = overtimeInfo.level;
		members = overtimeInfo.members;

		isOverTimeRun = true; 
	elseif(inTimeInfo) then 
		seasonBestDurationSec = inTimeInfo.durationSec; 
		seasonBestLevel = inTimeInfo.level; 
		members = inTimeInfo.members;
	end

    if (seasonBestDurationSec and seasonBestLevel) then
        if (addSpacer) then
            GameTooltip:AddLine(" ");
        end

		-- Completed a higher key, but not in time. 
		if (overtimeInfo and inTimeInfo and  overtimeInfo.level > inTimeInfo.level) then 
			GameTooltip_AddNormalLine(GameTooltip, MYTHIC_PLUS_OVERTIME_SEASON_BEST);
			GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(overtimeInfo.level), HIGHLIGHT_FONT_COLOR);
			GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(overtimeInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
			GameTooltip_AddBlankLineToTooltip(GameTooltip); 
		end 

		-- If this is an overtime run we want to display a little bit differently. 
		if (isOverTimeRun) then 
			GameTooltip_AddNormalLine(GameTooltip, MYTHIC_PLUS_OVERTIME_SEASON_BEST);
		else 
			GameTooltip_AddNormalLine(GameTooltip, MYTHIC_PLUS_SEASON_BEST);
		end 

        GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(seasonBestLevel), HIGHLIGHT_FONT_COLOR);
        GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(seasonBestDurationSec, true), HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddBlankLineToTooltip(GameTooltip); 

		for i, member in ipairs(members) do
			if (member.name) then
				local role = GetSpecializationRoleByID(member.specID);
				local classInfo = C_CreatureInfo.GetClassInfo(member.classID);
				local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
				local texture;
				if (role == "TANK") then
					texture = CreateAtlasMarkup("roleicon-tiny-tank");
				elseif (role == "DAMAGER") then
					texture = CreateAtlasMarkup("roleicon-tiny-dps");
				elseif (role == "HEALER") then
					texture = CreateAtlasMarkup("roleicon-tiny-healer");
				end
				  GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, member.name), color);
			end
		end
    end
    GameTooltip:Show();
end

ChallengesFrameWeeklyInfoMixin = {};

function ChallengesFrameWeeklyInfoMixin:SetUp(hasWeeklyRun, bestData)
	local affixes = C_MythicPlus.GetCurrentAffixes();
	if (affixes) then
		for i, affix in ipairs(affixes) do
			local frame = self.Child.Affixes[i];
			if (not frame) then
				frame = CreateFrame("Frame", nil, self.Child, "ChallengesKeystoneFrameAffixTemplate");
				frame:SetPoint("LEFT", self.Child.Affixes[i-1], "RIGHT", 10, 0);
			end
			frame:SetUp(affix.id);
		end
		self:Show();
	end
end

function ChallengesFrameWeeklyInfoMixin:HideAffixes()
	if(self.Child.Affixes) then
		for i = 1, #self.Child.Affixes do
			local frame = self.Child.Affixes[i];
			frame:Hide();
		end
	end
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

function ChallengesKeystoneFrameMixin:OnShow()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_OPEN);
    self:Reset();
end

function ChallengesKeystoneFrameMixin:OnHide()
    if (not self.startedChallengeMode) then
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_CLOSE);
    end
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
	self.TimeLimit:Hide();
    self.DungeonName:Hide();

	for i = 1, #self.Affixes do
		self.Affixes[i]:Hide();
	end

	for k, v in pairs(self.baseStates) do
		k:SetShown(v.shown);
		k:SetAlpha(v.alpha);
	end

    self.startedChallengeMode = nil;
end

function ChallengesKeystoneFrameMixin:OnMouseUp()
	if (CursorHasItem()) then
		C_ChallengeMode.SlotKeystone();
	end
end

function ChallengesKeystoneFrameMixin:ShowKeystoneFrame()
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
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_SOCKET);
	self.InsertedAnim:Play();
	self.RunesLargeAnim:Play();
	self.RunesSmallAnim:Play();
	self.RunesLargeRotateAnim:Play();
	self.RunesSmallRotateAnim:Play();
	self.InstructionBackground:Hide();
	self.Instructions:Hide();

	local mapID, affixes, powerLevel, charged = C_ChallengeMode.GetSlottedKeystoneInfo();
	if mapID ~= nil then
		local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID);

		self.DungeonName:SetText(name);
		self.DungeonName:Show();
		self.TimeLimit:SetText(SecondsToTime(timeLimit, false, true));
		self.TimeLimit:Show();

		self.PowerLevel:SetText(CHALLENGE_MODE_POWER_LEVEL:format(powerLevel));
		self.PowerLevel:Show();

		local dmgPct, healthPct = C_ChallengeMode.GetPowerLevelDamageHealthMod(powerLevel);
		local highLevelKeyDamageHealthModifier = 0;

		if (powerLevel >= 3) then
			highLevelKeyDamageHealthModifier = 2;
			self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
			self.Affixes[1]:SetUp({key = "dmg", pct = dmgPct});
			self.Affixes[2]:SetUp({key = "health", pct = healthPct});
		else
			self:CreateAndPositionAffixes(highLevelKeyDamageHealthModifier + #affixes);
		end

		for i = 1, #affixes do
			self.Affixes[i+highLevelKeyDamageHealthModifier]:SetUp(affixes[i]);
		end
	end
end

function ChallengesKeystoneFrameMixin:OnKeystoneRemoved()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_REMOVE_KEYSTONE);
	self:Reset();
	self.StartButton:Disable();
end

function ChallengesKeystoneFrameMixin:StartChallengeMode()
    PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_SOCKET_PAGE_ACTIVATE_BUTTON);
    C_ChallengeMode.StartChallengeMode();
    self.startedChallengeMode = true;
    self:Hide();
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
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	end
end

function ChallengesKeystoneFrameAffixMixin:SetUp(affixInfo)
	if (type(affixInfo) == "table") then
		local info = affixInfo;

		SetPortraitToTexture(self.Portrait, CHALLENGE_MODE_EXTRA_AFFIX_INFO[info.key].texture);

        if (info.pct > 999) then
            self.Percent:SetFontObject("SystemFont_Shadow_Med1_Outline");
        else
            self.Percent:SetFontObject("SystemFont_Shadow_Large_Outline");
        end

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

ChallengeModeCompleteBannerMixin = {};

function ChallengeModeCompleteBannerMixin:OnLoad()
    self.timeToHold = 5;
    self.unitTokens = { "player", "party1", "party2", "party3", "party4" };
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
end

function ChallengeModeCompleteBannerMixin:OnEvent(event, ...)
    if (event == "CHALLENGE_MODE_COMPLETED") then
        local mapID, level, time, onTime, keystoneUpgradeLevels, practiceRun = C_ChallengeMode.GetCompletionInfo();

		if not practiceRun then
			TopBannerManager_Show(self, { mapID = mapID, level = level, time = time, onTime = onTime, keystoneUpgradeLevels = keystoneUpgradeLevels });
		end
    end
end

function ChallengeModeCompleteBannerMixin:PlayBanner(data)
    local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(data.mapID);

    self.Title:SetText(name);

    self.Level:SetText(data.level);
    local lvlStr = tostring(data.level);
    if (tonumber(lvlStr:sub(1,1)) == 1) then
        self.Level:SetPoint("CENTER", self.SkullCircle, -4, 0);
    else
        self.Level:SetPoint("CENTER", self.SkullCircle, 0, 0);
    end

	self.Level:Show();

    if (data.onTime) then
        self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_BEAT_TIMER);
        self.DescriptionLineTwo:SetFormattedText(CHALLENGE_MODE_COMPLETE_KEYSTONE_UPGRADED, data.keystoneUpgradeLevels);
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
    else
        self.DescriptionLineOne:SetText(CHALLENGE_MODE_COMPLETE_TIME_EXPIRED);
        self.DescriptionLineTwo:SetText(CHALLENGE_MODE_COMPLETE_TRY_AGAIN);
        PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);
    end

    local sortedUnitTokens = self:GetSortedPartyMembers();

    self:Show();
    self.AnimIn:Play();

    self:CreateAndPositionPartyMembers(#sortedUnitTokens);
	for i = 1, #sortedUnitTokens do
        self.PartyMembers[i]:SetUp(sortedUnitTokens[i]);
    end


    C_Timer.After(self.timeToHold, function()
        self:PerformAnimOut();
    end);
end

function ChallengeModeCompleteBannerMixin:StopBanner()
    self.AnimIn:Stop();
    self:Hide();
end

function ChallengeModeCompleteBannerMixin:GetSortedPartyMembers()
    local unitRoleMap = {};

    local sortedUnitTokens = {};

    for i = 1, #self.unitTokens do
        if (UnitExists(self.unitTokens[i])) then
            local role = UnitGroupRolesAssigned(self.unitTokens[i]);
            if (role == "DAMAGER" or role == "NONE") then
                if (not unitRoleMap[role]) then
                    unitRoleMap[role] = {};
                end
                tinsert(unitRoleMap[role], self.unitTokens[i]);
            else
                unitRoleMap[role] = self.unitTokens[i];
            end
        end
    end

    if (unitRoleMap["TANK"]) then
        tinsert(sortedUnitTokens, unitRoleMap["TANK"]);
    end

    if (unitRoleMap["HEALER"]) then
        tinsert(sortedUnitTokens, unitRoleMap["HEALER"]);
    end

    if (unitRoleMap["DAMAGER"]) then
        for i = 1, #unitRoleMap["DAMAGER"] do
            tinsert(sortedUnitTokens, unitRoleMap["DAMAGER"][i]);
        end
    end

    if (unitRoleMap["NONE"]) then
        for i = 1, #unitRoleMap["NONE"] do
            tinsert(sortedUnitTokens, unitRoleMap["NONE"][i]);
        end
    end

    return sortedUnitTokens;
end

function ChallengeModeCompleteBannerMixin:CreateAndPositionPartyMembers(num)
	local frameWidth, spacing, distance = 61, 22, -100;

    CreateFrames(self, "PartyMembers", num, "ChallengeModeBannerPartyMemberTemplate");
    ReanchorFrames(self.PartyMembers, "TOPLEFT", self.Title, "TOP", frameWidth, spacing, distance);
end

function ChallengeModeCompleteBannerMixin:PerformAnimOut()
    self.AnimOut:Play()
    for i = 1, #self.PartyMembers do
        if (self.PartyMembers[i]:IsShown()) then
            self.PartyMembers[i].AnimOut:Play();
        end
    end
end

function ChallengeModeCompleteBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner:Hide();
	banner.BannerTop:SetAlpha(0);
	banner.BannerBottom:SetAlpha(0);
	banner.BannerMiddle:SetAlpha(0);
	banner.BottomFillagree:SetAlpha(0);
	banner.RightFillagree:SetAlpha(0);
	banner.LeftFillagree:SetAlpha(0);
	banner.Title:SetAlpha(0);
	TopBannerManager_BannerFinished();
end

ChallengeModeBannerPartyMemberMixin = {};

function ChallengeModeBannerPartyMemberMixin:SetUp(unitToken)
    SetPortraitTexture(self.Portrait, unitToken);

    local name = UnitName(unitToken);
    local _, classFileName = UnitClass(unitToken);

    local classColorStr = RAID_CLASS_COLORS[classFileName].colorStr;
    self.Name:SetText(("|c%s%s|r"):format(classColorStr, name));

    local role = UnitGroupRolesAssigned(unitToken);
    if ( role == "TANK" or role == "HEALER" or role == "DAMAGER" ) then
		self.RoleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
		self.RoleIcon:Show();
	else
		self.RoleIcon:Hide();
	end

    self:SetAlpha(0);
    self:Show();
    self.AnimIn:Play();
end


function MythicPlusSeasonChangeNoticeOnCloseClick(self)
	self:GetParent():Hide(); 
	SetCVar("newMythicPlusSeason", C_MythicPlus.GetCurrentSeason()); 
	PlaySound(SOUNDKIT.UI_80_ISLANDS_TUTORIAL_CLOSE);
end