--! TODO sounds
--! TODO art
--! TODO [PH] strings still exist in data

-- TODO / NOTE : To test that the GV button opens the GV frame properly, ensure that active TimeEvent matches live, and the current live season is selected. Revist closer to ship
-- TODO / NOTE : To test the current/max rewards tooltip properly on the GV button, ensure that active TimeEvent is 11.0 Season 1 start, and run BeginSeason_WarWithin_Season1 in console. Use weeklyRewardsActivity 8 1 1 1 to fake unlocks
-- ^ The GV frame will be broken because TWW S1 lacks Ranked PVP activities, but that is changing soon.
--! TODO ^ revisit both of these closer to launch

-- Season/reward data
local MIN_REP_RANK_FOR_REWARDS = 2;
local MAX_REP_RANK_FOR_REWARDS = 11;
local MAX_NUM_REWARDS = 10;
local DELVES_SEASON_RENOWN_CVAR = "lastRenownForDelvesSeason";
local REPUTATION_UPDATE_TIMEOUT_SECONDS = 0.2; -- 200ms

-- Model scene data
local DASHBOARD_MODEL_SCENE_ACTOR_TAG = "actor";
local DASHBOARD_MODEL_SCENE_ID = 898;

local DASHBOARD_ON_LOAD_EVENTS = {
	"UPDATE_FACTION"
};

local function HasActiveSeason()
	DelvesDashboardFrame.uiDisplaySeason = PVPUtil.GetCurrentSeasonNumber();
    return DelvesDashboardFrame.uiDisplaySeason and DelvesDashboardFrame.uiDisplaySeason > 0;
end

local function GetDisplaySeason()
	return DelvesDashboardFrame.uiDisplaySeason;
end

local function ShouldPlayAnims()
	return DelvesDashboardFrame.shouldPlayAnims;
end

--[[ Delves Dashboard ]]
DelvesDashboardFrameMixin = {};

function DelvesDashboardFrameMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, DASHBOARD_ON_LOAD_EVENTS);
	self.ThresholdBar.BarFillGlow:SetPoint("LEFT", self.ThresholdBar.BarFill, "LEFT", 0, 0);
	self.ThresholdBar.BarFillGlow:SetPoint("RIGHT", self.ThresholdBar.BarFill, "RIGHT", 0, 0);
	self.ThresholdBar.BarEnd:SetPoint("CENTER", self.ThresholdBar.BarFill, "RIGHT", 0, 0);
end

function DelvesDashboardFrameMixin:OnEvent(event)
	if event == "UPDATE_FACTION" and self:IsVisible() then
		C_Timer.After(REPUTATION_UPDATE_TIMEOUT_SECONDS, function()
			self.renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(Constants.DelvesConsts.DELVES_S1_FACTION_ID);
			self:SetThresholds();
		end);
	end
end

function DelvesDashboardFrameMixin:OnShow()
	self.renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(Constants.DelvesConsts.DELVES_S1_FACTION_ID);
	self.rewardsInfo = self:GetRewardsInfo();

    PVEFrame:SetPortraitToAsset("Interface\\ICONS\\INV_Cape_Special_Explorer_B_03");
	self:UpdateTitles();
	self:SetThresholds();
	self:UpdateGreatVaultVisibility();
    self.ButtonPanelLayoutFrame:Layout();
end

function DelvesDashboardFrameMixin:SetThresholds()
	local oldThresholdValue = tonumber(GetCVar(DELVES_SEASON_RENOWN_CVAR));
	local thresholdValue = self.renownInfo.renownLevel + (self.renownInfo.renownReputationEarned / self.renownInfo.renownLevelThreshold);
	self.shouldPlayAnims = thresholdValue > oldThresholdValue;
	SetCVar(DELVES_SEASON_RENOWN_CVAR, thresholdValue);

	self.ThresholdBar:SetMinMaxValues(1, MAX_REP_RANK_FOR_REWARDS);
	self.ThresholdBar:SetValue(thresholdValue);
	self.ThresholdBar.BarEnd:SetShown(self.ThresholdBar:GetValue() > 1);

	if not self.thresholdFrames then
		self.thresholdFrames = {};
	end

	local currentThreshold = 2;
	for i, thresholdInfo in pairs(self.rewardsInfo) do
		local thresholdName = "Threshold" .. currentThreshold;
		local thresholdFrame = self.ThresholdBar[thresholdName];

		local template = "ReputationThresholdTemplate";
		if i == MAX_NUM_REWARDS then
			template = "ReputationThresholdLargeTemplate";
		end

		if not thresholdFrame then
			thresholdFrame = CreateFrame("Frame", nil, self.ThresholdBar, template);
			self.ThresholdBar[thresholdName] = thresholdFrame;
			table.insert(self.thresholdFrames, thresholdFrame);
		end
		
		local xOffset = i * self.ThresholdBar:GetWidth() / MAX_NUM_REWARDS;

		if i < MAX_NUM_REWARDS then
			thresholdFrame:SetPoint("CENTER", self.ThresholdBar, "BOTTOMLEFT", xOffset, -8);
		elseif i == MAX_NUM_REWARDS then
			thresholdFrame:SetPoint("CENTER", self.ThresholdBar, "BOTTOMRIGHT", 5, 9);
		end
		
		local isFinalReward = template == "ReputationThresholdLargeTemplate";
		thresholdFrame:Setup(thresholdInfo, self.renownInfo, currentThreshold, isFinalReward);
		currentThreshold = currentThreshold + 1;
	end

	if ShouldPlayAnims() then
		self.ThresholdBar.GlowAnim:Play(true);
	end
end

function DelvesDashboardFrameMixin:GetRewardsInfo()
	local rewardsInfo = {};
	
	for i = MIN_REP_RANK_FOR_REWARDS, MAX_REP_RANK_FOR_REWARDS do
		local renownLevelRewards = C_MajorFactions.GetRenownRewardsForLevel(Constants.DelvesConsts.DELVES_S1_FACTION_ID, i);

		-- There should only ever be one reward per level for Delves, up to a maximum of 10 levels (MAX_REP_RANK_FOR_REWARDS)
		-- There *can* be multiple rewards per level, but we only care about the first.
		if renownLevelRewards[1] then
			local icon, name, _, desc = RenownRewardUtil.GetUnformattedRenownRewardInfo(renownLevelRewards[1]);
			tinsert(rewardsInfo, {icon = icon, name = name, description = desc});
		end
	end

	return rewardsInfo;
end

function DelvesDashboardFrameMixin:UpdateGreatVaultVisibility()
	local serverExpansionLevel = GetServerExpansionLevel();
	local maxLevel = GetMaxLevelForExpansionLevel(serverExpansionLevel);
	local playerLevel = UnitLevel("player");
	local greatVaultPanel = self.ButtonPanelLayoutFrame.GreatVaultButtonPanel;


	if playerLevel < maxLevel then
		greatVaultPanel.ButtonPanelBackground:SetDesaturated(true);
        greatVaultPanel.PanelTitle:SetTextColor(GRAY_FONT_COLOR:GetRGB());
        greatVaultPanel.PanelDescription:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		greatVaultPanel.disabled = true;
	else
		greatVaultPanel.ButtonPanelBackground:SetDesaturated(false);
        greatVaultPanel.PanelTitle:SetTextColor(WHITE_FONT_COLOR:GetRGB());
        greatVaultPanel.PanelDescription:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		greatVaultPanel.disabled = false;
	end
end

function DelvesDashboardFrameMixin:UpdateTitles()
    local currExpID = GetExpansionLevel();
    local expName = _G["EXPANSION_NAME"..currExpID];
	
	if ( not HasActiveSeason() ) then
		PVEFrame:SetTitle(DELVES_LABEL);
		self.ReputationBarTitle:SetText(DELVES_REPUTATION_BAR_TITLE_NO_SEASON);
		self.ReputationBarTitle:SetTextColor(GRAY_FONT_COLOR:GetRGB());
    else
        PVEFrame:SetTitle( DELVES_DASHBOARD_SEASON_TITLE:format(DELVES_LABEL, expName, GetDisplaySeason()));
		self.ReputationBarTitle:SetText(DELVES_REPUTATION_BAR_TITLE:format(expName, GetDisplaySeason()));
		self.ReputationBarTitle:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	end
end

--[[ Reputation Threshold + Reward Info ]]
ReputationThresholdMixin = {};

function ReputationThresholdMixin:Setup(thresholdInfo, renownInfo, thresholdLevel, isFinalReward)
	self.Reward.name = thresholdInfo.name;
	self.Reward.description = thresholdInfo.description;

	self.Reward.Icon:SetTexture(thresholdInfo.icon);
	self.Reward.CheckmarkFlipbook:SetAlpha(0);

	if not HasActiveSeason() then
		self.Reward.Icon:SetDesaturated(true);
		self.Reward.EarnedCheckmark:SetAlpha(0);
		if isFinalReward then
			self.Reward.IconBorder:SetDesaturated(true);
		end
		return;
	else
		self.Reward.Icon:SetDesaturated(false);
		if isFinalReward then
			self.Reward.IconBorder:SetDesaturated(false);
		end
	end

	if renownInfo.renownLevel >= thresholdLevel then
		if not isFinalReward then
			self.LineIncomplete:Hide();
			self.LineComplete:Show();
		else
			self.Reward.IconBorder:SetDesaturated(false);
		end

		if ShouldPlayAnims() and not self.animPlayed then
			self.Reward.EarnedAnim:Play();
			self.animPlayed = true;
		else
			self.Reward.Icon:SetDesaturated(false);
			self.Reward.Glow:SetAlpha(1);
			self.Reward.EarnedCheckmark:SetAlpha(1);
		end
	else
		if not isFinalReward then
			self.LineIncomplete:Show();
			self.LineComplete:Hide();
		else
			self.Reward.IconBorder:SetDesaturated(true);
		end
		self.Reward.Icon:SetDesaturated(true);
		self.Reward.Glow:SetAlpha(0);
		self.Reward.EarnedCheckmark:SetAlpha(0);
	end
end

ReputationThresholdRewardMixin = {};

function ReputationThresholdRewardMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.name);
	GameTooltip_AddNormalLine(GameTooltip, self.description);
	GameTooltip:Show();
end

--[[ Companion Config Button Panel ]]
CompanionConfigButtonPanelMixin = {};

function CompanionConfigButtonPanelMixin:OnShow()
    local companionFactionInfo = C_Reputation.GetFactionDataByID(Constants.DelvesConsts.BRANN_FACTION_ID);

    self.PanelTitle:SetText(companionFactionInfo.name);
    self.PanelDescription:SetText(DELVES_COMPANION_LABEL);

	if not C_Traits.GetConfigIDByTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID) then
		self.CompanionConfigButton.disabled = true;
		self.CompanionConfigButton:SetEnabled(false);
		self.CompanionConfigButton.ButtonText:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self.CompanionConfigButton.disabled = false;
		self.CompanionConfigButton:SetEnabled(true);
		self.CompanionConfigButton.ButtonText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function CompanionConfigButtonPanelMixin:OnEnter()
	if self.disabled then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, DELVES_COMPANION_NOT_ENABLED_TOOLTIP);
		GameTooltip:Show();
	end
end

function CompanionConfigButtonPanelMixin:OnClick()
    if not DelvesCompanionConfigurationFrame:IsShown() then
        ShowUIPanel(DelvesCompanionConfigurationFrame);
    else
        HideUIPanel(DelvesCompanionConfigurationFrame);
    end
end

--[[ Companion Config Button Panel Model Scene ]]
CompanionConfigButtonPanelModelSceneMixin = CreateFromMixins(NoCameraControlModelSceneMixin);

function CompanionConfigButtonPanelModelSceneMixin:OnShow()
	local forceSceneChange = true;
	self:TransitionToModelSceneID(DASHBOARD_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	local actor = self:GetActorByTag("actor");
	if actor then
		actor:Hide();
		actor:SetOnModelLoadedCallback(GenerateClosure(self.OnModelLoaded, actor));
		actor:SetModelByCreatureDisplayID(Constants.DelvesConsts.BRANN_CREATURE_DISPLAY_ID);
	end
end

function CompanionConfigButtonPanelModelSceneMixin:OnModelLoaded(actor)
	actor:Show();
end

--[[ Great Vault Button Panel ]]
GreatVaultButtonPanelMixin = {};

function GreatVaultButtonPanelMixin:OnShow()
   self.PanelTitle:SetText(DELVES_GREAT_VAULT_LABEL);

    if not HasActiveSeason() then
        self.ButtonPanelBackground:SetDesaturated(true);
        self.PanelTitle:SetTextColor(GRAY_FONT_COLOR:GetRGB());
        self.PanelDescription:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		self.PanelDescription:SetText(DELVES_GREAT_VAULT_UNAVAILABLE_LABEL);
    else
        self.ButtonPanelBackground:SetDesaturated(false);
        self.PanelTitle:SetTextColor(WHITE_FONT_COLOR:GetRGB());
        self.PanelDescription:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.PanelDescription:SetText(DELVES_GREAT_VAULT_DESCRIPTION_SEASON_STARTED);
    end
end

--[[ Great Vault Button ]]
GreatVaultButtonMixin = CreateFromMixins(WeeklyRewardMixin);

function GreatVaultButtonMixin:GetState()
	if C_WeeklyRewards.HasAvailableRewards() then
		return "collect";
    elseif self:HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.World) then
		return "complete";
	end

	return "incomplete";
end

function GreatVaultButtonMixin:OnShow()
	local state = self:GetState();
	local atlas = "pvpqueue-chest-dragonflight-greatvault-"..state;
	self.ChestTexture:SetAtlas(atlas);
	self.Highlight:SetAtlas(atlas);

	local desaturated = not HasActiveSeason();
	self.ChestTexture:SetDesaturated(desaturated);
	self.Highlight:SetDesaturated(desaturated);
end

function GreatVaultButtonMixin:OnEnter()
	if not HasActiveSeason() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
		GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
		GameTooltip_AddNormalLine(GameTooltip, DELVES_GREAT_VAULT_REQUIRES_ACTIVE_SEASON);
		GameTooltip:Show();
		return;
	end

	if self:GetParent().disabled then
		local serverExpansionLevel = GetServerExpansionLevel();
		local maxLevel = GetMaxLevelForExpansionLevel(serverExpansionLevel);

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);
		GameTooltip_AddDisabledLine(GameTooltip, UNAVAILABLE);
		GameTooltip_AddNormalLine(GameTooltip, DELVES_GREAT_VAULT_ERR_AVAIL_AT_MAX_LEVEL:format(maxLevel));
		GameTooltip:Show();
		return;
	end

	local state = self:GetState();
	local maxUnlocks = self:GetMaxNumRewards(Enum.WeeklyRewardChestThresholdType.World);
	local unlocksCompleted = self:GetNumUnlockedRewards(Enum.WeeklyRewardChestThresholdType.World);
	local description = DELVES_GREAT_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	if maxUnlocks > 0 then
		GameTooltip_AddNormalLine(GameTooltip, description);
	end

	GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
	GameTooltip:Show();
end

function GreatVaultButtonMixin:OnMouseUp(...)
	if not HasActiveSeason() or self:GetParent().disabled then
		return;
	end

	WeeklyRewardMixin.OnMouseUp(self, ...);
end