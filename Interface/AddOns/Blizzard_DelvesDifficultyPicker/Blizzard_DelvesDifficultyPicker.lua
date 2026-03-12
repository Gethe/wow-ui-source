--[[ LOCALS ]]
local DELVES_DIFFICULTY_PICKER_EVENTS = {
	"WALK_IN_DATA_UPDATE",
	"ACTIVE_DELVE_DATA_UPDATE",
	"PARTY_ELIGIBILITY_FOR_DELVE_TIERS_CHANGED",
	"PARTY_LEADER_CHANGED",
	"GROUP_LEFT",
};

-- Max number of rewards shown on the right side of the UI
local MAX_NUM_REWARDS = 4;

-- Used to select the bountiful widget, in order to show VFX based on the tier of key owned.
-- See DelvesKeyState enum and its usages
local BOUNTIFUL_DELVE_WIDGET_TAG = "delveBountiful";

-- Stores the last selected tier. If one hasn't been selected (value: 0), we'll force the player to select one.
-- If the last selected isn't available, we'll default to the highest unlocked tier.
local LAST_TIER_SELECTED_CVAR = "lastSelectedTieredEntranceTier";

-- Stores the highest unlocked delve difficulty tier. Default is 1
-- If this does not match the actual highest tier, we'll notify the player that they have new, higher tiers available
local HIGHEST_TIER_UNLOCKED_CVAR = "highestUnlockedTieredEntranceTier";

local TIER_SELECT_DROPDOWN_MENU_MIN_WIDTH = 110;
local TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH = 130;
local TIER_SELECT_DROPDOWN_MAX_WIDTH = 280;
local TIER_SELECT_DROPDOWN_DYNAMIC_PADDING = 34;	-- used when the dropdown resizes based on the longest option text

local DelvesKeyState = EnumUtil.MakeEnum(
	"None",
	"Normal"
);

local DelvesDisplayMode = EnumUtil.MakeEnum(
	"Default",
	"Traits"
);

function GetPlayerKeyState()
	local normalKeyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.DelvesConsts.DELVES_NORMAL_KEY_CURRENCY_ID);

	if normalKeyInfo and normalKeyInfo.quantity > 0 then
		return DelvesKeyState.Normal;
	else
		return DelvesKeyState.None;
	end
end

--[[ Difficulty Picker ]]
DelvesDifficultyPickerFrameMixin = {};

-- Required function, unused.
function DelvesDifficultyPickerFrameMixin:SetStartingPage()
end

function DelvesDifficultyPickerFrameMixin:OnLoad()
	local panelAttributes = {
		area = "center",
		whileDead = 0,
		pushable = 0,
		allowOtherPanels = 1,
	};
	RegisterUIPanel(self, panelAttributes);
	self.Dropdown:SetWidth(TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH);
	self.Border.Bg:Hide();
	self.displayMode = DelvesDisplayMode.Default;
end

function DelvesDifficultyPickerFrameMixin:OnEvent(event, ...)
	if event == "ACTIVE_DELVE_DATA_UPDATE" or event == "WALK_IN_DATA_UPDATE" then
		self:CheckForActiveDelveAndUpdate();
	elseif event == "PARTY_ELIGIBILITY_FOR_DELVE_TIERS_CHANGED" then
		local playerName, maxEligibleLevel = ...;
		self:OnPartyEligibilityChanged(playerName, maxEligibleLevel);
	elseif event == "TRAIT_CONFIG_UPDATED" then
		self:UpdatePortalButtonState();
	elseif event == "PARTY_LEADER_CHANGED" or event == "GROUP_LEFT" then
		self:UpdatePortalButtonState();
		if self.displayMode == DelvesDisplayMode.Traits then
			self.ChallengesContainerFrame:CheckPartyLeader();
		end
	end 
end 

function DelvesDifficultyPickerFrameMixin:OnShow()
	self:ClearAllPoints();
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 110);
	FrameUtil.RegisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuOpen, function(dropdown)
		self:HideHelpTip();

		if dropdown.NewLabel:IsShown() then
			dropdown.NewLabel:Hide();
		end

		if dropdown.menu.ScrollBox:HasScrollableExtent() then
			local selectedTierInfo = self:GetSelectedTierInfo();
			local index = selectedTierInfo and selectedTierInfo.tier or 1;
			dropdown.menu.ScrollBox:ScrollToElementDataIndex(index, ScrollBoxConstants.AlignBegin);
		end
	end, self.Dropdown);

	self.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuClose, function(dropdown, menu, closeReason)
		self:TryShowHelpTip();
		self.newTiers = {};
	end);
	
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	self:SetInitialTier();
	self:CheckForActiveDelveAndUpdate();
	self:TryShowHelpTip();
	self:CheckForNewTierUnlocks();
	self.partyTierEligibility = {};
	C_DelvesUI.RequestPartyEligibilityForDelveTiers(C_DelvesUI.GetDelveEntranceMapID());
end

function DelvesDifficultyPickerFrameMixin:CheckAndSetDisplayMode()
	local displayMode = DelvesDisplayMode.Default;
	local traitTreeID = C_DelvesUI.GetTieredEntranceOptionalAffixTraitTreeID();
	if traitTreeID then
		displayMode = DelvesDisplayMode.Traits;
	end

	if self.displayMode == displayMode then
		return;
	end
	self.displayMode = displayMode;

	local enterButton = self.EnterDelveButton;
	local modifiersContainer = self.DelveModifiersWidgetContainer;
	local rewardsContainer = self.DelveRewardsContainerFrame;
	local challengesContainer = self.ChallengesContainerFrame;
	local dropdown = self.Dropdown;

	if displayMode == DelvesDisplayMode.Traits then
		self.ScenarioLabel:SetText(RITUAL_SITE_LABEL);
		if self.DelveModifiersWidgetContainer:HasAnyWidgetsShowing() then 
			self.ModifiersLabel:Show();
			self.DividingLine:Show();
		end

		local width = dropdown.Text:GetUnboundedStringWidthForText(self.longestDropdownString) + TIER_SELECT_DROPDOWN_DYNAMIC_PADDING;
		dropdown:SetWidth(Clamp(width, TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH, TIER_SELECT_DROPDOWN_MAX_WIDTH));

		modifiersContainer:ClearAllPoints();
		modifiersContainer:SetPoint("CENTER", self.Title);
		modifiersContainer:SetPoint("TOP", self.ModifiersLabel, "BOTTOM", 0, -10);

		enterButton:ClearAllPoints();
		enterButton:SetPoint("BOTTOMRIGHT", -49, 34);
		enterButton:SetWidth(148);

		rewardsContainer:ClearAllPoints();
		rewardsContainer:SetPoint("BOTTOM", enterButton, "TOP", 6, 15);
		rewardsContainer.RewardText:ClearAllPoints();
		rewardsContainer.RewardText:SetPoint("TOP", -5, 0);

		challengesContainer:Show();
		local systemID = C_Traits.GetSystemIDByTreeID(traitTreeID);
		challengesContainer:SetConfigIDBySystemID(systemID);

		-- Because the grid anchors from top-left, but we want the icons to grow upwards,
		-- we need to math it out and move the container to achieve that
		local nodeIDs = C_Traits.GetTreeNodes(traitTreeID);
		local numNodes = nodeIDs and #nodeIDs or 0;
		local numRows = math.ceil(numNodes / challengesContainer.stride);
		local challengesHeight = numRows * challengesContainer.buttonSize + (numRows - 1) * challengesContainer.paddingY;
		challengesContainer:SetPoint("BOTTOM", 0, -challengesContainer:GetHeight() + challengesHeight + 48);
		self:RegisterEvent("TRAIT_CONFIG_UPDATED");
		challengesContainer:RegisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self.OnChallengesCommitStatusChanged, self);
	else
		self.ScenarioLabel:SetText(DELVE_LABEL);
		self.ModifiersLabel:Hide();
		self.DividingLine:Hide();

		dropdown:SetWidth(TIER_SELECT_DROPDOWN_MENU_BTN_WIDTH);

		modifiersContainer:ClearAllPoints();
		modifiersContainer:SetPoint("CENTER", self.Title);
		modifiersContainer:SetPoint("BOTTOM", 0, 75);

		enterButton:ClearAllPoints();
		enterButton:SetPoint("CENTER", self.Title);
		enterButton:SetPoint("BOTTOM", 0, 25);
		enterButton:SetWidth(110);

		rewardsContainer:ClearAllPoints();
		rewardsContainer:SetPoint("RIGHT", -25, 0);
		rewardsContainer:SetPoint("BOTTOM", self.EnterDelveButton);
		rewardsContainer.RewardText:ClearAllPoints();
		rewardsContainer.RewardText:SetPoint("TOPLEFT", 15, 0);

		challengesContainer:Hide();
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
		challengesContainer:UnregisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self);
	end

	-- this is going to be affected by displayMode
	self:UpdatePortalButtonState();
end

function DelvesDifficultyPickerFrameMixin:OnChallengesCommitStatusChanged()
	self:UpdatePortalButtonState();
end

DelveChallengesContainerFrameMixin = { };

function DelveChallengesContainerFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);
	self.ButtonsParent:SetClipsChildren(false);
end

function DelveChallengesContainerFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);
	self:CheckPartyLeader();
end

function DelveChallengesContainerFrameMixin:CheckPartyLeader()
	-- show blocking frame if in a group and not leader
	local doShow = false;
	if UnitInParty("player") then
		if not UnitIsGroupLeader("player") then
			doShow = true;
		end
	end
	self.BlockingFrame:SetShown(doShow);
end

function DelveChallengesContainerFrameMixin:GetTemplateForTalentType(_nodeInfo, _talentType, _useLarge)
	return "TalentButtonDelveChallengeCircleTemplate";
end

function DelveChallengesContainerFrameMixin:GetConfigCommitErrorString()
	return TIERED_ENTRANCE_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function DelveChallengesContainerFrameMixin:CheckAndReportCommitOperation()
	if not C_Traits.IsReadyForCommit() then
		self:ReportConfigCommitError();
		return false;
	end

	return TalentFrameBaseMixin.CheckAndReportCommitOperation(self);
end

-- TalentFrameBaseMixin override to commit changes immediately
function DelveChallengesContainerFrameMixin:AttemptConfigOperation(...)
	if TalentFrameBaseMixin.AttemptConfigOperation(self, ...) then
		if not self:CommitConfig() then
			self:MarkTreeDirty();
			return false;
		end

		return true;
	else
		self:MarkTreeDirty();
	end

	return false;
end

function DelveChallengesContainerFrameMixin:SetDisabledOverlayShown(_shown)
	-- do nothing, this will keep the buttons clickable
end

function DelvesDifficultyPickerFrameMixin:CheckForNewTierUnlocks()
	-- Track new tiers, since you can unlock more than one at a time
	-- The "NEW" label we show if *anything* new is unlocked, but inside the dropdown we want to show which tiers are new with pips
	self.newTiers = {};

	local tierInfos = self:GetTierInfos();
	if tierInfos then
		local pdeID = C_DelvesUI.GetTieredEntrancePDEID();
		local defaultTier = 0;
		local oldHighestUnlockedTier = GetCVarTableValue(HIGHEST_TIER_UNLOCKED_CVAR, pdeID, defaultTier);
		local newHighestUnlockedTier = nil;
		for _, tierInfo in ipairs(tierInfos) do
			-- Tier is unlocked and new, let the player know
			if tierInfo.unlocked and tierInfo.tier > oldHighestUnlockedTier then
				self.newTiers[tierInfo.tier] = true;
				self.Dropdown.NewLabel:Show();
				newHighestUnlockedTier = tierInfo.tier;
			-- Tier is locked, but old highest is higher somehow or doesn't exist - we should rollback or reset 
			elseif not tierInfo.unlocked and oldHighestUnlockedTier >= tierInfo.tier then
				newHighestUnlockedTier = tierInfo.tier - 1;
				if newHighestUnlockedTier < 1 or not tierInfos[newHighestUnlockedTier] then 
					newHighestUnlockedTier = 1;
				end
				break;
			end
		end
		if newHighestUnlockedTier then
			SetCVarTableValue(HIGHEST_TIER_UNLOCKED_CVAR, pdeID, newHighestUnlockedTier);
		end
	end
end

function DelvesDifficultyPickerFrameMixin:TryShowHelpTip()
	local selectedTierInfo = self:GetSelectedTierInfo();
	local pdeID = C_DelvesUI.GetTieredEntrancePDEID();
	local defaultTier = 0;
	local lastSelectedTier = GetCVarTableValue(LAST_TIER_SELECTED_CVAR, pdeID, defaultTier);

	-- If there's no tier selected and last selected tier is 0, we're seeing the FTUE and should show the helptip
	if not selectedTierInfo and lastSelectedTier == 0 then
		local helpTipInfo = {
			text = DELVES_TIER_SELECT_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			offsetX = -3,
		};
		HelpTip:Show(self.Dropdown, helpTipInfo);
	else
		self:HideHelpTip();
	end
end

function DelvesDifficultyPickerFrameMixin:HideHelpTip()
	HelpTip:HideAll(self.Dropdown);
end

function DelvesDifficultyPickerFrameMixin:CheckForActiveDelveAndUpdate()
	if C_DelvesUI.HasActiveDelve() then
		local activeDelveTierInfo = C_DelvesUI.GetActiveDelveTier();
		-- Prefer active delve tier (from walk in party)
		if activeDelveTierInfo and activeDelveTierInfo.tier then
			self:SetSelectedTierInfo(activeDelveTierInfo);
			self:UpdateWidgets();
		elseif self.selectedTierInfo and self.selectedTierInfo.tier then
			-- If active delve tier is empty, player probably entered and then left. Fall back on the last selected tier,
			-- which should match the active delv
			self:UpdateWidgets();
		end
		self.DelveRewardsContainerFrame:SetRewards();
		self.Dropdown:Update();
		self.Dropdown:SetEnabled(false);
		self:UpdatePortalButtonState();
	else
		self.Dropdown:SetEnabled(true);
	end

	self:CheckAndSetDisplayMode();
end

function DelvesDifficultyPickerFrameMixin:SetupDropdown()
	local longestString;
	local longestStringWidth = 0;

	self.Dropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DELVES_DIFFICULTY");

		local buttonSize = 20;
		local maxButtons = 7;
		rootDescription:SetScrollMode(buttonSize * maxButtons);
		rootDescription:SetMinimumWidth(TIER_SELECT_DROPDOWN_MENU_MIN_WIDTH);
		
		local entranceTiers = DelvesDifficultyPickerFrame:GetTierInfos();
		if not entranceTiers then
			return;
		end

		local function IsSelected(tierInfo)
			return DelvesDifficultyPickerFrame:GetSelectedTierInfo().tier == tierInfo.tier;
		end

		local function SetSelected(tierInfo)
			DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:Hide();
			DelvesDifficultyPickerFrame:SetSelectedTierInfo(tierInfo);
			DelvesDifficultyPickerFrame:UpdateWidgets();
			DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
			DelvesDifficultyPickerFrame:UpdatePortalButtonState();
			local pdeID = C_DelvesUI.GetTieredEntrancePDEID();
			SetCVarTableValue(LAST_TIER_SELECTED_CVAR, pdeID, tierInfo.tier);
		end

		local function SetupButton(tierInfo, isLocked)
			local radio = rootDescription:CreateRadio(tierInfo.tierDescription, IsSelected, SetSelected, tierInfo);
			-- These are all going to be similar strings so byte count should be enough
			local stringWidth = #tierInfo.tierDescription;
			if stringWidth > longestStringWidth then
				longestString = tierInfo.tierDescription;
				longestStringWidth = stringWidth;
			end

			-- Add the "new" tier pip for recently unlocked tiers
			radio:AddInitializer(function(button, description, menu)
				if tierInfo.unlocked and self.newTiers and self.newTiers[tierInfo.tier] then
					local texture = button:AttachTexture();
					texture:SetSize(13, 13);
					texture:SetPoint("LEFT", button.fontString, "RIGHT", 3, 0);
					texture:SetAtlas("ui-hud-micromenu-communities-icon-notification");
				end
			end);

			if isLocked then
				radio:SetEnabled(false);
			end
			
			local partyTierEligibility = DelvesDifficultyPickerFrame:GetPartyTierEligibility();
			radio:SetTooltip(function(tooltip, elementDescription)
					if isLocked then
						-- Locked tiers get an error line stating they need to complete the prior tier. This assumes Delves, and failure conditions which are always based on tiers.
						-- If we extend TieredEntrances to other content, this should become based on the TieredEntrance type.
						-- If we allow override PlayerConditions for tier eligibility, this should use the PlayerCondition faillure description instead if present.
						if tierInfo.lockedReason then
							GameTooltip_AddErrorLine(GameTooltip, tierInfo.lockedReason);
						else
							GameTooltip_AddErrorLine(GameTooltip, TIERED_ENTRANCE_LOCKED_DEFAULT_TOOLTIP_DELVE:format(tierInfo.tier - 1));
						end
					else
						-- Unlocked tiers get an ilvl suggestion.
						GameTooltip_AddNormalLine(GameTooltip,TIERED_ENTRANCE_ILVL_SUGGESTION:format(tierInfo.suggestedILvl));
						-- And a list of any party members who will be ineligible for the tier
						if partyTierEligibility ~= nil then
							for playerName,maxEligibleLevel in pairs(partyTierEligibility) do
								if maxEligibleLevel < tierInfo.tier then
									GameTooltip_AddErrorLine(GameTooltip, DELVES_PARTY_MEMBER_INELIGIBLE_FOR_TIER_TOOLTIP:format(playerName), false);
								end
							end
						end
					end
				end);
		end
		
		for i, tierInfo in ipairs(entranceTiers) do
			SetupButton(tierInfo, not tierInfo.unlocked);
		end
	end);
	self.longestDropdownString = longestString;
end

function DelvesDifficultyPickerFrameMixin:CanEnterDelve()
	if self.displayMode == DelvesDisplayMode.Traits then
		if self.ChallengesContainerFrame:IsCommitInProgress() then
			return false;
		end

		if UnitInParty("player") then
			if not UnitIsGroupLeader("player") then
				return false;
			end
		end
	end

	local selectedTierInfo = self:GetSelectedTierInfo();
	if not selectedTierInfo or not selectedTierInfo.unlocked then
		return false;
	end

	local minLevel = C_DelvesUI.GetDelvesMinRequiredLevel();
	if not minLevel or UnitLevel("player") < minLevel then
		return false;
	end

	local isEnabled, failureReason = C_DelvesUI.IsDelveEntranceTierEnabled(selectedTierInfo.tier);
	if not isEnabled then
		return false, failureReason;
	end

	return true;
end

function DelvesDifficultyPickerFrameMixin:UpdatePortalButtonState()
	local canEnter, failureReason = self:CanEnterDelve();
	self.EnterDelveButton:SetEnabled(canEnter);
	self.EntranceErrorText:SetText(failureReason);
end

function DelvesDifficultyPickerFrameMixin:GetTierInfos()
	return self.tierInfos;
end

function DelvesDifficultyPickerFrameMixin:SetSelectedTierInfo(tierInfo)
	self.selectedTierInfo = tierInfo;
	self:UpdatePortalButtonState();
end

function DelvesDifficultyPickerFrameMixin:SetInitialTier()
	DelvesDifficultyPickerFrame:SetSelectedTierInfo(nil);
	local pdeID = C_DelvesUI.GetTieredEntrancePDEID();
	local defaultTier = 0;
	local lastSelectedTier = GetCVarTableValue(LAST_TIER_SELECTED_CVAR, pdeID, defaultTier);

	if self.tierInfos then
		DelvesDifficultyPickerFrame:SetSelectedTierInfo(self.tierInfos[1]);

		-- If last selected tier is 0, then the player is opening Delves for the first time. We'll force them to pick a tier.
		-- Otherwise, try to use their last selected tier. Failing that, use the highest unlocked tier
		if lastSelectedTier > 0 then
			local lastSelectedTierInfo = self.tierInfos[lastSelectedTier];

			if lastSelectedTierInfo and lastSelectedTierInfo.unlocked then
				DelvesDifficultyPickerFrame:SetSelectedTierInfo(lastSelectedTierInfo);
			else
				for _, tierInfo in pairs(self.tierInfos) do 
					if tierInfo.unlocked and tierInfo.tier > self.selectedTierInfo.tier then
						DelvesDifficultyPickerFrame:SetSelectedTierInfo(tierInfo);
					else
						break;
					end
				end
			end
		end
	end

	self:SetupDropdown();

	if self.selectedTierInfo then
		DelvesDifficultyPickerFrame:UpdateWidgets();
		DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
		DelvesDifficultyPickerFrame:UpdatePortalButtonState();
	end
end

function DelvesDifficultyPickerFrameMixin:UpdateWidgets()
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.Bg:Show();

	local backgroundWidgetSetID = C_DelvesUI.GetDelveEntranceBackgroundWidgetSetID();
	if (backgroundWidgetSetID) then
		self.DelveBackgroundWidgetContainer:RegisterForWidgetSet(backgroundWidgetSetID);
		self.Bg:Hide();
	end
	
	-- If level selected or player eligible for tier, show modifiers
	if self.selectedTierInfo then
		self.DelveModifiersWidgetContainer:RegisterForWidgetSet(self.selectedTierInfo.modifierUIWidgetSetID);
	end

	if self.displayMode == DelvesDisplayMode.Traits then
		if self.DelveModifiersWidgetContainer:HasAnyWidgetsShowing() then
			self.DividingLine:Show();
			self.ModifiersLabel:Show();
		else
			self.DividingLine:Hide();
			self.ModifiersLabel:Hide();			
		end
	end

	self:UpdateBountifulWidgetVisualization();
end

function DelvesDifficultyPickerFrameMixin:UpdateBountifulWidgetVisualization()
	for _, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag(BOUNTIFUL_DELVE_WIDGET_TAG) do
		local playerKeyState = GetPlayerKeyState();
		
		-- Cancel the model scene effect if player does not own any keys
		if playerKeyState ~= DelvesKeyState.Normal and widgetFrame.effectController then
			widgetFrame.effectController:CancelEffect();
			widgetFrame.effectController = nil;
		end

		-- Add glow animation if player owns at least one key
		if playerKeyState >= DelvesKeyState.Normal and not self.bountifulAnimFrame then
			self.bountifulAnimFrame = CreateFrame("FRAME", "BountifulWidgetAnimationFrame", widgetFrame, "BountifulWidgetAnimationTemplate");
			self.bountifulAnimFrame.FadeIn:Play();
			self.bountifulAnimFrame.RaysTranslation:Play();
		end

		if self.bountifulAnimFrame then
			self.bountifulAnimFrame:ClearAllPoints();
			self.bountifulAnimFrame:SetPoint("CENTER", widgetFrame, "CENTER", 0, -3);
		end
	end
end

function DelvesDifficultyPickerFrameMixin:GetSelectedTierInfo()
	return self.selectedTierInfo;
end

local function EntranceTierSort(leftInfo, rightInfo)
	return leftInfo.tier < rightInfo.tier;
end  

function CustomGossipFrameBaseMixin:SetupTiers()
	self.tierInfos = C_DelvesUI.GetDelveEntranceTiers();
	table.sort(self.tierInfos, EntranceTierSort);
	self:UpdatePortalButtonState();
end

function DelvesDifficultyPickerFrameMixin:TryShow(textureKit) 
	self.textureKit = textureKit; 
	self.Title:SetText(C_DelvesUI.GetDelveEntranceHeaderString());
	self.Description:SetText(C_DelvesUI.GetDelveEntranceDescriptionString());
	self:SetupTiers();
	ShowUIPanel(self);
end 

function DelvesDifficultyPickerFrameMixin:OnHide()
	self.DelveBackgroundWidgetContainer:UnregisterForWidgetSet();
	self.DelveModifiersWidgetContainer:UnregisterForWidgetSet();
	self.DelveRewardsContainerFrame:Hide();
	FrameUtil.UnregisterFrameForEvents(self, DELVES_DIFFICULTY_PICKER_EVENTS);
	self.Dropdown:UnregisterCallback(DropdownButtonMixin.Event.OnMenuClose, self);
	self.Dropdown:UnregisterCallback(DropdownButtonMixin.Event.OnMenuOpen, self);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TieredEntrance);
	if self.bountifulAnimFrame then
		self.bountifulAnimFrame:Hide();
		self.bountifulAnimFrame = nil;
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end		

--[[ Enter Button ]]
DelvesDifficultyPickerEnterDelveButtonMixin = {};

function DelvesDifficultyPickerEnterDelveButtonMixin:OnEnter()
	local selectedTierInfo = self:GetParent():GetSelectedTierInfo();
	local minLevel = C_DelvesUI.GetDelvesMinRequiredLevel();

	if minLevel and UnitLevel("player") < minLevel then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 225);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ENTRANCE_LEVEL_REQUIREMENT_ERROR:format(minLevel));
		GameTooltip:Show();
	elseif not selectedTierInfo then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 175);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ERR_SELECT_TIER);
		GameTooltip:Show();
	elseif not selectedTierInfo.unlocked then
		self:SetEnabled(false);
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 175);
		GameTooltip_AddErrorLine(GameTooltip, DELVES_ERR_TIER_INELIGIBLE);
		GameTooltip:Show();
	else
		local partyTierEligibility = self:GetParent():GetPartyTierEligibility();
		if partyTierEligibility ~= nil then
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 50);
			local ineligibleParty = false;
			for playerName,maxEligibleLevel in pairs(partyTierEligibility) do
				if maxEligibleLevel < selectedTierInfo.tier then
					GameTooltip_AddErrorLine(GameTooltip, DELVES_PARTY_MEMBER_INELIGIBLE_FOR_TIER_TOOLTIP:format(playerName), false);
					ineligibleParty = true;
				end
			end

			if ineligibleParty then
				GameTooltip:Show();
			end
		end
	end
end 

function DelvesDifficultyPickerEnterDelveButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function DelvesDifficultyPickerEnterDelveButtonMixin:OnClick()
	local selectedTierInfo = DelvesDifficultyPickerFrame:GetSelectedTierInfo();
	if not selectedTierInfo then
		return; 
	end
	PlaySound(SOUNDKIT.PVP_ENTER_QUEUE);
	C_DelvesUI.SelectDelveEntranceTier(selectedTierInfo.tier);
end 

function DelvesDifficultyPickerFrameMixin:OnPartyEligibilityChanged(playerName, maxEligibleLevel)
	self.partyTierEligibility[playerName] = maxEligibleLevel;
end

function DelvesDifficultyPickerFrameMixin:GetPartyTierEligibility()
	return self.partyTierEligibility;
end

--[[ Rewards Container + Buttons ]]
DelveRewardsContainerFrameMixin = {};

local REWARDS_SCROLL_SPACING = 5;

function DelveRewardsContainerFrameMixin:OnLoad()
	local function RewardResetter(framePool, frame)
		SetItemButtonTexture(frame, nil);
		SetItemButtonQuality(frame, nil);
		SetItemButtonCount(frame, nil);
		frame.Name:SetText("");
		frame.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		frame:ClearAllPoints();
		frame:Hide();
	end

	self.rewardPool = CreateFramePool("FRAME", self, "DelveRewardItemButtonTemplate", RewardResetter);

	local function InitializeReward(button, rewardInfo)
		SetItemButtonTexture(button, rewardInfo.texture);
		SetItemButtonQuality(button, rewardInfo.quality);
		button.Name:SetText(rewardInfo.name);

		local colorData = ColorManager.GetColorDataForItemQuality(rewardInfo.quality);
		if colorData then
			button.Name:SetTextColor(colorData.color:GetRGB());
		end

		if rewardInfo.quantity and rewardInfo.quantity > 1 then
			SetItemButtonCount(button, rewardInfo.quantity);
		end

		button.id = rewardInfo.id;
		button.context = rewardInfo.context;
		button:Show();
	end

	local defaultPad = 5;
	local view = CreateScrollBoxListLinearView(defaultPad, defaultPad, defaultPad, defaultPad, REWARDS_SCROLL_SPACING);
	view:SetElementInitializer("DelveRewardItemButtonTemplate", InitializeReward);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function DelveRewardsContainerFrameMixin:SetRewards()
	if not DelvesDifficultyPickerFrame:GetSelectedTierInfo() then
		return;
	end

	local continuableContainer = ContinuableContainer:Create();
	local tierRewards = DelvesDifficultyPickerFrame:GetSelectedTierInfo().rewards;
	local rewardInfo = {};

	self.rewardPool:ReleaseAll();

	if not tierRewards then
		return;
	end
	
	for _, reward in ipairs(tierRewards) do
		if reward.rewardType == Enum.TieredEntranceRewardType.Item then 
			local item = Item:CreateFromItemID(reward.id);
			continuableContainer:AddContinuable(item);
		else
			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(reward.id, reward.quantity); 
			if IsCurrencyContainer then 
				local name, texture, quantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, quantity);
				table.insert(rewardInfo, {id = reward.id, texture = texture, quantity = quantity, quality = quality, name = name, isCurrencyContainer = true});
			else
				local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.id);
				table.insert(rewardInfo, {id = reward.id, texture = currencyInfo.iconFileID, quantity = reward.quantity, quality = currencyInfo.quality, name = currencyInfo.name, isCurrencyContainer = false});
			end
		end
	end

	continuableContainer:ContinueOnLoad(function()
		for  _, reward in ipairs(tierRewards) do
			if	reward.rewardType == Enum.TieredEntranceRewardType.Item then 
				local name, _, quality, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(reward.id);
				local contextQuality = reward.context and C_Item.GetDelvePreviewItemQuality(reward.id, reward.context) or nil;
				table.insert(rewardInfo, {id = reward.id, quality = contextQuality or quality, quantity = reward.quantity, texture = itemIcon, name = name, context = reward.context});
			end
		end

		if #rewardInfo > 0 then
			local dataProvider = CreateDataProvider();

			for i, reward in ipairs(rewardInfo) do
				dataProvider:Insert(reward);
			end

			local buttonTemplateInfo = C_XMLUtil.GetTemplateInfo("DelveRewardItemButtonTemplate");
			local buttonHeight = buttonTemplateInfo.height;
			local numItems = math.min(#rewardInfo, MAX_NUM_REWARDS);
			local newHeight = self.RewardText:GetHeight() + ((buttonHeight + REWARDS_SCROLL_SPACING) * numItems);
			self:SetHeight(newHeight);
			self.ScrollBox:SetHeight(newHeight - REWARDS_SCROLL_SPACING);

			local scrollWidthPadding = 4;
			self.ScrollBox:SetWidth(buttonTemplateInfo.width + scrollWidthPadding);

			self.ScrollBox:SetDataProvider(dataProvider);
			self.ScrollBar:SetShown((#rewardInfo) > MAX_NUM_REWARDS);

			self:Show();
		end
	end);
end

DelveRewardsButtonMixin = {};

function DelveRewardsButtonMixin:OnEnter()
	if not self.id then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local item = Item:CreateFromItemID(self.id);
	self.itemCancelFunc = item:ContinueWithCancelOnItemLoad(function()
		if GameTooltip:GetOwner() == self then
			if self.context then
				self.itemLink = C_Item.GetDelvePreviewItemLink(self.id, self.context);
			else
				self.itemLink = item:GetItemLink();
			end
			GameTooltip:SetHyperlink(self.itemLink);
			GameTooltip:Show();
		end
	end);
end

function DelveRewardsButtonMixin:OnUpdate()
	if TooltipUtil.ShouldDoItemComparison(GameTooltip) then
		GameTooltip_ShowCompareItem(GameTooltip);
	else
		GameTooltip_HideShoppingTooltips(GameTooltip);
	end
end

function DelveRewardsButtonMixin:OnMouseDown()
	if not self.itemLink then
		return;
	end

	if IsModifiedClick() then
		HandleModifiedItemClick(self.itemLink);
	end
end

function DelveRewardsButtonMixin:OnLeave()
	if self.itemCancelFunc then
		self.itemCancelFunc();
		self.itemCancelFunc = nil;
	end
	GameTooltip:Hide();
end

--[[ Difficulty Dropdown ]]
DelvesDifficultyPickerDropdownMixin = {};

function DelvesDifficultyPickerDropdownMixin:OnEnter()
	if not self:IsEnabled() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, ERR_DELVE_IN_PROGRESS:format(self.text or ""));
		GameTooltip:Show();
	end
end

function DelvesDifficultyPickerDropdownMixin:OnLeave()
	GameTooltip:Hide();
end
