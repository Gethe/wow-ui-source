local HORDE_PLAYER_FACTION_GROUP_NAME = PLAYER_FACTION_GROUP[PLAYER_FACTION_GROUP.Horde];

local function GetInspectUnit()
	return InspectFrame:GetInspectUnit();
end

local function GetInspectUnitFactionGroup()
	return UnitFactionGroup(GetInspectUnit());
end

local function GetInspectPVPRankText(rank)
	if not rank or rank <= 0 then
		return PVP_RANK_0_NAME;
	end

	local factionAffix = (GetInspectUnitFactionGroup() == "Alliance") and "_1" or "_0";
	local rankTitleKey = "PVP_RANK_" .. tostring(Enum.PvPRanks.Rank_1 + rank - 1) .. factionAffix;
	local gender = UnitSex(GetInspectUnit());
	return GetText(rankTitleKey, gender);
end

InspectRewardBadgeMixin = {};

-- PVPHonorRewardTemplate uses local player-based tooltip data. Suppress it for inspect context.
function InspectRewardBadgeMixin:Update()
end

function InspectRewardBadgeMixin:OnEnter()
end

function InspectRewardBadgeMixin:OnLeave()
end

InspectPVPRankProgressBarDisplayMixin = {};

function InspectPVPRankProgressBarDisplayMixin:OnLoad()
	self:Pause();
	self.Bar:SetAtlas("UI-Character-Info-Honor-Bar");

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
	self.NextRewardLevel:Show();
end

function InspectPVPRankProgressBarDisplayMixin:UpdateFactionBadge(rankLevel)
	if rankLevel and rankLevel > 0 then
		local rankAtlas = string.format("UI-Character-Info-Honor-Icon-%d", rankLevel);
		if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(rankAtlas) then
			self.FactionBadge:SetAtlas(rankAtlas, TextureKitConstants.UseAtlasSize);
			return;
		end
	end

	if GetInspectUnitFactionGroup() == HORDE_PLAYER_FACTION_GROUP_NAME then
		self.FactionBadge:SetAtlas("UI-Character-Info-Honor-Icon-Horde", TextureKitConstants.UseAtlasSize);
	else
		self.FactionBadge:SetAtlas("UI-Character-Info-Honor-Icon-Alliance", TextureKitConstants.UseAtlasSize);
	end
end

function InspectPVPRankProgressBarDisplayMixin:Update(rankLevel, rankPoints, nextRankPointsThreshold)
	if GetInspectUnitFactionGroup() == HORDE_PLAYER_FACTION_GROUP_NAME then
		self.Background:SetAtlas("UI-Character-Info-Honor-Bar-BG-Horde", true);
	else
		self.Background:SetAtlas("UI-Character-Info-Honor-Bar-BG-Alliance", true);
	end

	self:UpdateFactionBadge(rankLevel);

	local progressPct = 0;
	if nextRankPointsThreshold and nextRankPointsThreshold > 0 then
		progressPct = rankPoints / nextRankPointsThreshold;
	end
	CooldownFrame_SetDisplayAsPercentage(self, progressPct);

	self.NextRewardLevel.LevelLabel:SetText(rankLevel or 0);
end

InspectPVPFrameMixin = {};

function InspectPVPFrameMixin:OnLoad()
	self:RegisterEvent("INSPECT_HONOR_UPDATE");
	self.currentSeason = 0;
end

function InspectPVPFrameMixin:OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame);
	self:Update();
end

function InspectPVPFrameMixin:OnEvent(event, ...)
	if event == "INSPECT_HONOR_UPDATE" then
		self:Update();
	end
end

function InspectPVPFrameMixin:Update()
	if not GetInspectUnit() then
		return;
	end

	local todayHK, _, _, _, lifetimeHK, _, honorLevel, honorCurrent, honorNextLevel = GetInspectHonorData();
	honorCurrent = honorCurrent or 0;
	honorNextLevel = honorNextLevel or 0;
	todayHK = todayHK or 0;
	lifetimeHK = lifetimeHK or 0;

	self.currentSeason = GetCurrentArenaSeason();
	self.MainInfoFrame.CurrentSeasonField:SetText(string.format(EXPANSION_SEASON_NAME, "", self.currentSeason));
	self.MainInfoFrame.CurrentSeasonField:SetShown(self.currentSeason > 0);

	local rankLevel = honorLevel or 0;
	local rankTitle = GetInspectPVPRankText(rankLevel);
	if rankLevel > 0 then
		self.MainInfoFrame.CurrentRankField:SetText(PVP_RANK_NUMBER_AND_TITLE:format(rankLevel, rankTitle));
	else
		self.MainInfoFrame.CurrentRankField:SetText(PVP_RANK_0_NAME);
	end

	self.MainInfoFrame.CurrentRankProgressField:SetText(string.format(PVP_RANK_CURRENT_PROGRESS, honorCurrent, honorNextLevel));
	self.MainInfoFrame.RankProgressBarDisplay:Update(rankLevel, honorCurrent, honorNextLevel);
	self.MainInfoFrame.HonorableKillsField:SetText(HONORABLE_KILLS);
	self.MainInfoFrame.LifetimeHKsField:SetText(string.format("%s: %d", HONOR_LIFETIME, lifetimeHK));
	self.MainInfoFrame.TodayHKsField:SetText(string.format("%s: %d", HONOR_TODAY, todayHK));
end
