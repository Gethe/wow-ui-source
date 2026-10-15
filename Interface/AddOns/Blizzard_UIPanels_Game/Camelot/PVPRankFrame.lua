local PVP_RANK_POINTS_FACTION_ID = 2800;

local HORDE_PLAYER_FACTION_GROUP_NAME = PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Horde];
local ALLIANCE_PLAYER_FACTION_GROUP_NAME = PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Alliance];

-- rank is the simple numerical rank (0 means unranked)
local function GetPVPRankText(rank)
	if not rank or rank <= 0 then
		return PVP_RANK_0_NAME;
	end

	local gender = UnitSex("player");
	local faction01 = (UnitFactionGroup("player") == "Alliance" and 1) or 0;
	local rankTitleKey = "PVP_RANK_" .. tostring(Enum.PvPRanks.Rank_1 + rank - 1) .. "_" .. tostring(faction01);

	return GetText(rankTitleKey, gender);
end

local durationFormatter = CreateFromMixins(SecondsFormatterMixin);
durationFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold, 
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);
durationFormatter:SetDesiredUnitCount(2);

-------------------------------------[[ Top-Level Frame ]]-------------------------------------------------------
PVPRankFrameMixin = {};

function PVPRankFrameMixin:OnLoad()
	if CharacterFrame and CharacterFrame.ModeTabs and CharacterFrame.ModeTabs.PvPTab then
		CharacterFrame.ModeTabs.PvPTab:SetShown(true);
	end

	self.currentSeason = GetCurrentArenaSeason();
end

local PVPRankFrameEvents = {
	"UPDATE_FACTION",
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
}

function PVPRankFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, PVPRankFrameEvents);

	self:Update();

	-- Create a timer to update the season countdown
	if not self.countdownUpdateTimer then
		self.countdownUpdateTimer = C_Timer.NewTicker(1, function()
			-- Update the season end countdown timer
			self:UpdateSeasonCountdownTimer();

			-- If the season changed over, refresh everything
			if self.currentSeason ~= GetCurrentArenaSeason() then
				self:Update();
			end
		end);
	end

end

function PVPRankFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, PVPRankFrameEvents);

	if self.countdownUpdateTimer then
		self.countdownUpdateTimer:Cancel();
		self.countdownUpdateTimer = nil;
	end
end

function PVPRankFrameMixin:OnEvent(event, ...)
	if event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "UPDATE_FACTION" then
		self:Update();
	end
end

function PVPRankFrameMixin:UpdateSeasonCountdownTimer()
	-- We may not actually know the season end, in which case it will return 0 and we should hide the timer
	local duration = C_SeasonInfo.GetTimeUntilCurrentPVPSeasonEnd();
	if duration > SECONDS_PER_DAY then
		durationFormatter:SetMinInterval(SecondsFormatter.Interval.Days);
	else
		durationFormatter:SetMinInterval(SecondsFormatter.Interval.Seconds);
	end
	self.SeasonTimerField:SetText(string.format(SEASON_ENDS_IN_TIME, durationFormatter:Format(duration)));
	self.SeasonTimerField:SetShown(duration > 0);
end

function PVPRankFrameMixin:Update()
	local progressionInfo = C_MajorFactions.GetMajorFactionProgressionInfo(PVP_RANK_POINTS_FACTION_ID);

	if not progressionInfo then
		return;
	end

	-- Time until season end
	self:UpdateSeasonCountdownTimer();

	-- Current season
	self.currentSeason = GetCurrentArenaSeason();
	self.MainInfoFrame.CurrentSeasonField:SetText(string.format(EXPANSION_SEASON_NAME, '', self.currentSeason));
	self.MainInfoFrame.CurrentSeasonField:SetShown(self.currentSeason > 0);

	-- Current rank
	local rankLevel = progressionInfo.renownLevel;
	if not rankLevel or rankLevel == 0 then
		self.MainInfoFrame.CurrentRankField:SetText(PVP_RANK_0_NAME);
	else
		self.MainInfoFrame.CurrentRankField:SetText(PVP_RANK_NUMBER_AND_TITLE:format(rankLevel, GetPVPRankText(rankLevel)));
	end

	-- Rank visual progress
	self.MainInfoFrame.RankProgressBarDisplay:Update();

	-- Rank progress
	local rankPoints = progressionInfo.renownReputationEarned;
	local nextRankPointsThreshold = progressionInfo.renownLevelThreshold;
	self.MainInfoFrame.CurrentRankProgressField:SetText(string.format(PVP_RANK_CURRENT_PROGRESS, rankPoints, nextRankPointsThreshold));

	self.DetailFrame:Refresh();
end

PVPRankDetailFrameMixin = CreateFromMixins(CharacterFrameSidePaneMixin);

local PVP_RANK_DETAIL_DESCRIPTION_HEIGHT = 60;

function PVPRankDetailFrameMixin:OnShow()
	self:Refresh();
end

function PVPRankDetailFrameMixin:Refresh()
	local factionID = PVP_RANK_POINTS_FACTION_ID;
	local progressionInfo = C_MajorFactions.GetMajorFactionProgressionInfo(factionID);
	if not progressionInfo then
		self:SetEmpty(PVP_RANK_DETAIL_UNAVAILABLE);
		return;
	end

	self:ClearEmpty();

	local rankLevel = progressionInfo.renownLevel;
	local rankPoints = progressionInfo.renownReputationEarned;
	local currentWeekProgressiveMaxRank = progressionInfo.currentWeekProgressiveMaxLevel;
	local previousWeekProgressiveMaxLevel = progressionInfo.previousWeekProgressiveMaxLevel;
	local seasonEndMaxRank = progressionInfo.maxLevel;
	local totalRepForCurrentWeekProgressiveMaxRank = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, currentWeekProgressiveMaxRank);
	local totalRepForPreviousWeekProgressiveMaxRank = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, previousWeekProgressiveMaxLevel);
	local totalRepForSeasonEndMaxRank = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, seasonEndMaxRank);
	local thisWeekIncrementalCapIncrease = totalRepForCurrentWeekProgressiveMaxRank - totalRepForPreviousWeekProgressiveMaxRank;
	local totalRepForCurrentRank = C_MajorFactions.GetTotalReputationForRenownLevel(factionID, rankLevel);
	local myTotalRep = totalRepForCurrentRank + rankPoints;

	if rankLevel > 0 then
		self:SetPaneTitle(GetPVPRankText(rankLevel), string.format(PVP_RANK_NUMBER, rankLevel));
	else
		self:SetPaneTitle(GetPVPRankText(rankLevel), nil);
	end
	
	self:SetPaneTitleColor(CHARACTER_FRAME_SIDE_PANEL_PVP_COLOR, WHITE_FONT_COLOR);

	self:SetDescription(string.format(PVP_RANK_SEASON_RANKUP_DESCRIPTION, totalRepForSeasonEndMaxRank, seasonEndMaxRank), PVP_RANK_DETAIL_DESCRIPTION_HEIGHT);

	self:ResetRows();

	if myTotalRep > 0 and totalRepForCurrentWeekProgressiveMaxRank == 0 then
		self:AddWrappedRow(string.format(PVP_RANK_SEASON_PROGRESS_NO_MAX, myTotalRep), HIGHLIGHT_FONT_COLOR);
	elseif myTotalRep > 0 and totalRepForCurrentWeekProgressiveMaxRank > 0 then
		self:AddWrappedRow(string.format(PVP_RANK_SEASON_PROGRESS, myTotalRep, totalRepForCurrentWeekProgressiveMaxRank), HIGHLIGHT_FONT_COLOR);
	end

	if thisWeekIncrementalCapIncrease > 0 then
		self:AddSpacer(4);
		self:AddWrappedRow(string.format(PVP_RANK_WEEKLY_CAP_INCREASE, thisWeekIncrementalCapIncrease), NORMAL_FONT_COLOR);
	end

	self:AddNextRewardRows(rankLevel, seasonEndMaxRank);

	self:LayoutRows();
end

function PVPRankDetailFrameMixin:AddNextRewardRows(rankLevel, seasonEndMaxRank)
	local nextRewardRank, nextRewards;
	for testRank = rankLevel + 1, seasonEndMaxRank do
		local rewardInfos = C_MajorFactions.GetRenownRewardsForLevel(PVP_RANK_POINTS_FACTION_ID, testRank);
		if rewardInfos and #rewardInfos > 0 then
			nextRewardRank = testRank;
			nextRewards = rewardInfos;
			break;
		end
	end

	if not nextRewardRank or not nextRewards then
		return;
	end

	self:AddSpacer(8);
	self:AddCategory(string.format(PVP_RANK_NEXT_REWARD, nextRewardRank));

	local addedReward = false;
	for _, rewardInfo in ipairs(nextRewards) do
		if rewardInfo.description then
			if addedReward then
				self:AddSpacer(4);
			end

			self:AddIconRow(rewardInfo.icon, rewardInfo.description, NORMAL_FONT_COLOR);
			addedReward = true;
		end
	end

	self:AddSpacer(6);
	local vendorText = (UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME)
		and PVP_RANK_REWARDS_VENDOR_HORDE
		or PVP_RANK_REWARDS_VENDOR_ALLIANCE;
	self:AddWrappedRow(vendorText, NORMAL_FONT_COLOR);
end

-------------------------------------[[ PVPUIHonorLevelDisplay Frame ]]-------------------------------------------------------
RankProgressBarDisplayMixin = { };

function RankProgressBarDisplayMixin:OnLoad()
	self:Pause();

	self.Bar:SetAtlas("UI-Character-Info-Honor-Bar");

	if UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME then
		self.Background:SetAtlas("UI-Character-Info-Honor-Bar-BG-Horde", true);
	else
		self.Background:SetAtlas("UI-Character-Info-Honor-Bar-BG-Alliance", true);
	end

	self:UpdateFactionBadge(0);

	self.NextRewardLevel.RingBorder:SetAtlas("UI-Character-Info-Honor-RewardRing");
	self.NextRewardLevel.LevelLabel:SetText("");
	self.NextRewardLevel.LevelLabel:SetFontObject(GameFontNormalLarge);
	self.NextRewardLevel.LevelLabel:SetTextColor(GameFontNormalLarge:GetTextColor());
	self.NextRewardLevel.LevelLabel:SetPoint("CENTER");
	self.NextRewardLevel.LevelLabel:SetJustifyH("CENTER");
	self.NextRewardLevel.IconCover:SetDrawLayer("BACKGROUND", -1);
	self.NextRewardLevel.IconCover:SetColorTexture(0.1, 0.1, 0.1, 1);
	self.NextRewardLevel.IconCover:Show();
	self.NextRewardLevel.RewardIcon:Hide();
end

function RankProgressBarDisplayMixin:UpdateFactionBadge(rankLevel)
	if not rankLevel or rankLevel == 0 then
		if UnitFactionGroup("player") == HORDE_PLAYER_FACTION_GROUP_NAME then
			self.FactionBadge:SetAtlas("UI-Character-Info-Honor-Icon-Horde", TextureKitConstants.UseAtlasSize);
		else
			self.FactionBadge:SetAtlas("UI-Character-Info-Honor-Icon-Alliance", TextureKitConstants.UseAtlasSize);
		end
	else
		self.FactionBadge:SetAtlas(string.format("UI-Character-Info-Honor-Icon-%d", rankLevel), TextureKitConstants.UseAtlasSize);
	end
end

function RankProgressBarDisplayMixin:Update()
	local progressionInfo = C_MajorFactions.GetMajorFactionProgressionInfo(PVP_RANK_POINTS_FACTION_ID);

	if not progressionInfo then
		return;
	end

	local rankLevel = progressionInfo.renownLevel;
	local rankPoints = progressionInfo.renownReputationEarned;
	local nextRankPointsThreshold = progressionInfo.renownLevelThreshold;
	local maxRankLevel = progressionInfo.maxLevel;

	self:UpdateFactionBadge(rankLevel);

	-- progress bar
	local progressPct = 1;
	if nextRankPointsThreshold > 0 then
		progressPct = rankPoints / nextRankPointsThreshold;
	end
	CooldownFrame_SetDisplayAsPercentage(self, progressPct);

	-- show current rank
	self.NextRewardLevel.LevelLabel:SetText(rankLevel);
end

RewardBadgeMixin = {};

-- Override the Update from PVPHonorRewardMixin. We don't want to do anything.
function RewardBadgeMixin:Update()
end

-- PVPHonorRewardTemplate wires OnEnter/OnLeave to its own tooltip. The reward information lives
-- in the detail pane now, so suppress it rather than showing two versions of the same thing.
function RewardBadgeMixin:OnEnter()
end

function RewardBadgeMixin:OnLeave()
end
