-- Season/reward data
local MIN_REP_RANK_FOR_REWARDS = 1;
local MIN_REP_THRESHOLD_BAR_VALUE = MIN_REP_RANK_FOR_REWARDS - 1;
local MAX_REP_RANK_FOR_REWARDS = 10;
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
	DelvesDashboardFrame.uiDisplaySeason = C_DelvesUI.GetCurrentDelvesSeasonNumber();
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
			self.renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(C_DelvesUI.GetDelvesFactionForSeason());
			self:SetThresholds();
		end);
	end
end

function DelvesDashboardFrameMixin:OnShow()
	self.renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(C_DelvesUI.GetDelvesFactionForSeason());
	self.rewardsInfo = self:GetRewardsInfo();

    PVEFrame:SetPortraitToAsset("Interface\\ICONS\\UI_Delves");
	self:UpdateTitles();
	self:SetThresholds();
	self:UpdateGreatVaultVisibility();
    self.ButtonPanelLayoutFrame:Layout();
end

function DelvesDashboardFrameMixin:SetThresholds()
	local oldThresholdValue = math.floor(GetCVarNumberOrDefault(DELVES_SEASON_RENOWN_CVAR));
	local thresholdValueForBar = self.renownInfo and (self.renownInfo.renownLevel + (self.renownInfo.renownReputationEarned / self.renownInfo.renownLevelThreshold)) or 0;
	local thresholdValue = math.floor(thresholdValueForBar);
	self.shouldPlayAnims = thresholdValue > oldThresholdValue;
	SetCVar(DELVES_SEASON_RENOWN_CVAR, thresholdValue);

	self.ThresholdBar:SetMinMaxValues(MIN_REP_THRESHOLD_BAR_VALUE, MAX_REP_RANK_FOR_REWARDS);
	self.ThresholdBar:SetValue(thresholdValueForBar);
	self.ThresholdBar.BarEnd:SetShown(self.ThresholdBar:GetValue() >= MIN_REP_RANK_FOR_REWARDS);

	if not self.thresholdFrames then
		self.thresholdFrames = {};
	end

	local currentThreshold = MIN_REP_RANK_FOR_REWARDS;
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

	if ShouldPlayAnims() and thresholdValue >= MIN_REP_RANK_FOR_REWARDS then
		self.ThresholdBar.GlowAnim:Play(true);
	end
end

function DelvesDashboardFrameMixin:GetRewardsInfo()
	local rewardsInfo = {};
	local seasonFactionID = C_DelvesUI.GetDelvesFactionForSeason();
	
	for i = MIN_REP_RANK_FOR_REWARDS, MAX_REP_RANK_FOR_REWARDS do
		local renownLevelRewards = C_MajorFactions.GetRenownRewardsForLevel(seasonFactionID, i);

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


	if playerLevel < maxLevel or not HasActiveSeason() then
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
		self.Reward.IconBorder:SetDesaturated(true);
		return;
	else
		self.Reward.Icon:SetDesaturated(false);
		self.Reward.IconBorder:SetDesaturated(false);
	end

	if renownInfo.renownLevel >= thresholdLevel then
		self.Reward.IconBorder:SetDesaturated(false);
		if not isFinalReward then
			self.LineIncomplete:Hide();
			self.LineComplete:Show();
			self.Reward.IconBorder:SetAtlas("delves-dashboard-bar-diamond-complete");
		else
			self.Reward.IconBorder:SetAtlas("delves-dashboard-bar-reward-border");
		end

		local oldThresholdValue = math.floor(GetCVarNumberOrDefault(DELVES_SEASON_RENOWN_CVAR));
		self.animPlayed = thresholdLevel < oldThresholdValue;

		if ShouldPlayAnims() and not self.animPlayed then
			self.Reward.EarnedAnim:Play();
			self.animPlayed = true;
			local forceNoDuplicates = true;

			if isFinalReward then
				PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETED_PROGRESS, nil, forceNoDuplicates);
			else
				PlaySound(SOUNDKIT.TRADING_POST_UI_REWARD_TIER_COMPLETE, nil, forceNoDuplicates);
			end
		else
			self.Reward.Icon:SetDesaturated(false);
			self.Reward.Glow:SetAlpha(1);
			self.Reward.EarnedCheckmark:SetAlpha(1);
		end
	else
		self.Reward.IconBorder:SetDesaturated(true);
		if not isFinalReward then
			self.LineIncomplete:Show();
			self.LineComplete:Hide();
			self.Reward.IconBorder:SetAtlas("delves-dashboard-bar-diamond-incomplete");
		else
			self.Reward.IconBorder:SetAtlas("delves-dashboard-bar-reward-border-disabled");
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
	--! TODO BRANN_COMPANION_INFO_ID to be replaced with other data source in the future, keeping it explicit for now
	local traitTreeID = C_DelvesUI.GetTraitTreeForCompanion(Constants.DelvesConsts.BRANN_COMPANION_INFO_ID);
	local companionFactionID = C_DelvesUI.GetFactionForCompanion(Constants.DelvesConsts.BRANN_COMPANION_INFO_ID);

    local companionFactionInfo = C_Reputation.GetFactionDataByID(companionFactionID);

    self.PanelTitle:SetText(companionFactionInfo.name);
    self.PanelDescription:SetText(DELVES_COMPANION_LABEL);

	if not C_Traits.GetConfigIDByTreeID(traitTreeID) then
		self.CompanionConfigButton.disabled = true;
		self.CompanionConfigButton:SetEnabled(false);
		self.CompanionConfigButton.ButtonText:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self.CompanionConfigButton.disabled = false;
		self.CompanionConfigButton:SetEnabled(true);
		self.CompanionConfigButton.ButtonText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self:InitBackground();
end

function CompanionConfigButtonPanelMixin:InitBackground()
	if self.isCompanionButtonPanelFrame then
		self.ButtonPanelBackground:SetAtlas("delves-dashboard-card-companion");
	else
		self.ButtonPanelBackground:SetAtlas("delves-dashboard-card");
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

		--! TODO BRANN_COMPANION_INFO_ID to be replaced with other data source in the future, keeping it explicit for now
		actor:SetModelByCreatureDisplayID(C_DelvesUI.GetCreatureDisplayInfoForCompanion(Constants.DelvesConsts.BRANN_COMPANION_INFO_ID));
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
        self.ButtonPanelBackground:SetAtlas("delves-dashboard-card-disabled");
        self.PanelTitle:SetTextColor(GRAY_FONT_COLOR:GetRGB());
        self.PanelDescription:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		self.PanelDescription:SetText(DELVES_GREAT_VAULT_UNAVAILABLE_LABEL);
    else
        self.ButtonPanelBackground:SetAtlas("delves-dashboard-card");
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
	
	if C_WeeklyRewards.HasAvailableRewards() then
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	else
		self.AnimTexture.Anim:Stop();
		self.AnimTexture:Hide();
	end

	local atlas = "gficon-chest-evergreen-greatvault-"..state;
	local useAtlasSize = true;
	self.ChestTexture:SetAtlas(atlas, useAtlasSize);
	self.Highlight:SetAtlas(atlas, useAtlasSize);

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

	local maxUnlocks = self:GetMaxNumRewards(Enum.WeeklyRewardChestThresholdType.World);
	local unlocksCompleted = self:GetNumUnlockedRewards(Enum.WeeklyRewardChestThresholdType.World);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, GREAT_VAULT_REWARDS);

	if maxUnlocks > 0 then
		if C_WeeklyRewards.HasAvailableRewards() then
			GameTooltip_AddNormalLine(GameTooltip, DELVES_WEEKLY_REWARDS_UNCLAIMED_TEXT);
		else
			local description = DELVES_GREAT_VAULT_TOOLTIP:format(unlocksCompleted, maxUnlocks);
			GameTooltip_AddNormalLine(GameTooltip, description);
		end
	end

	GameTooltip_AddInstructionLine(GameTooltip, WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS);
	GameTooltip:Show();

	if self.AnimTexture.Anim:IsPlaying() then
		self.AnimTexture.Anim:Stop();
		self.AnimTexture:Hide();
	end
end

function GreatVaultButtonMixin:OnLeave()
	GameTooltip:Hide();

	if C_WeeklyRewards.HasAvailableRewards() then
		self.AnimTexture:Show();
		self.AnimTexture.Anim:Play();
	end
end

function GreatVaultButtonMixin:OnMouseUp(...)
	if not HasActiveSeason() or self:GetParent().disabled then
		return;
	end

	WeeklyRewardMixin.OnMouseUp(self, ...);
end

DelvesDashboardButtonPanelFrameMixin = {};

function DelvesDashboardButtonPanelFrameMixin:OnEnter()
	if self.PanelDescription:IsTruncated() then
		GameTooltip:SetOwner(self.PanelDescription, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, self.PanelDescription:GetText());
		GameTooltip:Show();
	end
end

function DelvesDashboardButtonPanelFrameMixin:OnLeave()
	if GameTooltip:GetOwner() == self.PanelDescription then
		GameTooltip:Hide();
	end
end