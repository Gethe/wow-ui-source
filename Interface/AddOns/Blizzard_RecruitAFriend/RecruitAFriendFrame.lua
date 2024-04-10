local RECRUIT_HEIGHT = 34;
local DIVIDER_HEIGHT = 16;

RecruitAFriendSystemMixin = {};

function RecruitAFriendSystemMixin:GetRecruitAFriendFrame()
	return RecruitAFriendFrame;
end

function RecruitAFriendSystemMixin:GetRecruitAFriendRewardsFrame()
	return RecruitAFriendRewardsFrame;
end

RecruitAFriendFrameMixin = CreateFromMixins(CallbackRegistryMixin);

RecruitAFriendFrameMixin:GenerateCallbackEvents(
{
	"NewRewardTabSelected",
	"SelectedRAFVersionChanged",
	"RewardsListOpened",
	"RewardsListClosed",
});

function RecruitAFriendFrameMixin:OnLoad()
	self:SetRAFSystemEnabled(C_RecruitAFriend.IsEnabled());
	self:SetRAFRecruitingEnabled(C_RecruitAFriend.IsRecruitingEnabled());
	self:RegisterEvent("RAF_SYSTEM_ENABLED_STATUS");
	self:RegisterEvent("RAF_RECRUITING_ENABLED_STATUS");
	self:RegisterEvent("RAF_SYSTEM_INFO_UPDATED");
	self:RegisterEvent("RAF_INFO_UPDATED");
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
	self:RegisterEvent("VARIABLES_LOADED");

	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(self, RecruitAFriendFrameMixin.Event.NewRewardTabSelected, self.OnNewRewardTabSelected);
	self:AddDynamicEventMethod(self, RecruitAFriendFrameMixin.Event.RewardsListOpened, self.OnRewardsListOpened);
	self:AddDynamicEventMethod(self, RecruitAFriendFrameMixin.Event.RewardsListClosed, self.OnRewardsListClosed);

	self.RecruitList.NoRecruitsDesc:SetText(RAF_NO_RECRUITS_DESC);

	local view = CreateScrollBoxListLinearView();
	-- SetElementExtentCalculator could be removed if the element initializer is replaced with a factory
	-- and the concepts of divider and recruit entry split apart from RecruitListButtonTemplate.
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		return elementData.isDivider and DIVIDER_HEIGHT or RECRUIT_HEIGHT;
	end);
	view:SetElementInitializer("RecruitListButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.RecruitList.ScrollBox, self.RecruitList.ScrollBar, view);

	local rafSystemInfo = C_RecruitAFriend.GetRAFSystemInfo();
	self:UpdateRAFSystemInfo(rafSystemInfo);

	local rafInfo = C_RecruitAFriend.GetRAFInfo();
	self:UpdateRAFInfo(rafInfo);
end

function RecruitAFriendFrameMixin:OnHide()
	CloseDropDownMenus();
	RecruitAFriendRewardsFrame:Hide();
	StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
end

function RecruitAFriendFrameMixin:OnEvent(event, ...)
	if event == "RAF_SYSTEM_ENABLED_STATUS" then
		local rafEnabled = ...;
		self:SetRAFSystemEnabled(rafEnabled);
		if self.rafEnabled then
			self:UpdateRAFInfo(C_RecruitAFriend.GetRAFInfo());
		end
	elseif event == "RAF_RECRUITING_ENABLED_STATUS" then
		local rafRecruitingEnabled = ...;
		self:SetRAFRecruitingEnabled(rafRecruitingEnabled);
	elseif event == "RAF_SYSTEM_INFO_UPDATED" then
		local rafSystemInfo = ...;
		self:UpdateRAFSystemInfo(rafSystemInfo);
	elseif event == "RAF_INFO_UPDATED" then
		local rafInfo = ...;
		self:UpdateRAFInfo(rafInfo);
	elseif event == "BN_FRIEND_INFO_CHANGED" then
		if self.rafInfo then
			self:UpdateRecruitList(self.rafInfo.recruits);
		end
	elseif event == "VARIABLES_LOADED" then
		self.varsLoaded = true;
		self:UpdateRAFTutorialTips();
	end
end

local splashFrameTextureKitRegions = {
	Watermark = "recruitafriend_%s_iwatermark_big",
	Picture = "recruitafriend_%s_splash_picture",
};
function RecruitAFriendFrameMixin:ShowSplashScreen()
	local latestRAFVersion = self:GetLatestRAFVersion();
	local useLegacyArt = RAFUtil.DoesRAFVersionUseLegacyArt(latestRAFVersion);
	self.SplashFrame.Background:SetAtlas(useLegacyArt and self.SplashFrame.legacyBackgroundAtlas or self.SplashFrame.backgroundAtlas, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnRegions(RAFUtil.GetTextureKitForRAFVersion(latestRAFVersion), self.SplashFrame, splashFrameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.SplashFrame:Show();
end

function RecruitAFriendFrameMixin:SetRAFSystemEnabled(rafEnabled)
	self.rafEnabled = rafEnabled;
	self:UpdateRAFTutorialTips();
end

function RecruitAFriendFrameMixin:UpdateRAFTutorialTips()
	local showRewardTutorial = self.varsLoaded and self.rafEnabled and self:ShouldShowRewardTutorial();

	if showRewardTutorial then
		local rewardHelpTipInfo = {
			text = RAF_REWARD_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			autoEdgeFlipping = true,
			useParentStrata = true,
			system = "Chat",
			systemPriority = 30,
		};
		HelpTip:Show(QuickJoinToastButton, rewardHelpTipInfo);
		self.shownRewardTutorial = true;
	else
		HelpTip:Hide(QuickJoinToastButton, RAF_REWARD_TUTORIAL_TEXT);
	end
end

function RecruitAFriendFrameMixin:SetRAFRecruitingEnabled(rafRecruitingEnabled)
	self.RecruitmentButton:SetShown(rafRecruitingEnabled);

	if not rafRecruitingEnabled then
		StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	end

	self.rafRecruitingEnabled = rafRecruitingEnabled;
	self:UpdateRAFTutorialTips();
end

local maxRecruits = 0;
local maxRecruitMonths = 0;
local maxRecruitLinkUses = 0;
local daysInCycle = 0;

function RecruitAFriendFrameMixin:UpdateRAFSystemInfo(rafSystemInfo)
	if rafSystemInfo then
		maxRecruits = rafSystemInfo.maxRecruits;
		maxRecruitMonths = rafSystemInfo.maxRecruitMonths;
		maxRecruitLinkUses = rafSystemInfo.maxRecruitmentUses;
		daysInCycle = rafSystemInfo.daysInCycle;
	end
end

local function SortRecruits(a, b)
	if a.isOnline ~= b.isOnline then
		return a.isOnline;
	else
		if a.versionRecruited ~= b.versionRecruited then
			return a.versionRecruited > b.versionRecruited;
		end

		return a.nameText < b.nameText;
	end
end

local function SortRecruitsByWoWAccount(a, b)
	if a.bnetAccountID == b.bnetAccountID then
		return a.wowAccountGUID < b.wowAccountGUID;
	end
end

local function ProcessAndSortRecruits(recruits)
	local seenAccounts = {};

	-- First, sort recruits that share a bnetAccountID by wowAccountGUID (so they are in a consistent order)
	table.sort(recruits, SortRecruitsByWoWAccount);

	local haveOnlineFriends = false;
	local haveOfflineFriends = false;

	-- Get account info for all recruits
	for _, recruitInfo in ipairs(recruits) do
		local accountInfo = C_BattleNet.GetAccountInfoByID(recruitInfo.bnetAccountID, recruitInfo.wowAccountGUID);

		if accountInfo and accountInfo.gameAccountInfo and not accountInfo.gameAccountInfo.isWowMobile then
			recruitInfo.isOnline = accountInfo.gameAccountInfo.isOnline;
			recruitInfo.characterName = accountInfo.gameAccountInfo.characterName;
			recruitInfo.nameText, recruitInfo.nameColor = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			recruitInfo.plainName = BNet_GetBNetAccountName(accountInfo);
		else
			-- We have no presence info for them yet...we will get an update when we do
			recruitInfo.isOnline = false;
			recruitInfo.nameText = BNet_GetTruncatedBattleTag(recruitInfo.battleTag);
			recruitInfo.plainName = recruitInfo.nameText;
			recruitInfo.nameColor = FRIENDS_GRAY_COLOR;
		end

		if recruitInfo.nameText == "" and RAF_PENDING_RECRUIT then
			recruitInfo.nameText = RAF_PENDING_RECRUIT;
			recruitInfo.plainName = RAF_PENDING_RECRUIT;
		end

		recruitInfo.accountInfo = accountInfo;

		if not seenAccounts[recruitInfo.bnetAccountID] then
			seenAccounts[recruitInfo.bnetAccountID] = 1;
		else
			seenAccounts[recruitInfo.bnetAccountID] = seenAccounts[recruitInfo.bnetAccountID] + 1;
		end

		-- Set an index so we can append it to the name if needed
		recruitInfo.recruitIndex = seenAccounts[recruitInfo.bnetAccountID];

		if recruitInfo.isOnline then
			haveOnlineFriends = true;
		else
			haveOfflineFriends = true;
		end
	end

	-- Now that we have seen all recruits, loop through again and append the recruitIndex to any recruits that share a bnetAccountID and are not online
	for _, recruitInfo in ipairs(recruits) do
		if seenAccounts[recruitInfo.bnetAccountID] > 1 and not recruitInfo.characterName then
			recruitInfo.nameText = RAF_RECRUIT_NAME_MULTIPLE:format(recruitInfo.nameText, recruitInfo.recruitIndex);
		end
	end

	-- And then sort them by online status, RAF version, and name
	table.sort(recruits, SortRecruits);

	return haveOnlineFriends and haveOfflineFriends;
end

function RecruitAFriendFrameMixin:UpdateRecruitList(recruits)
	local numRecruits = #recruits;

	self.RecruitList.NoRecruitsDesc:SetShown(numRecruits == 0);
	self.RecruitList.Header.Count:SetText(RAF_RECRUITED_FRIENDS_COUNT:format(numRecruits, maxRecruits));

	local needDivider = ProcessAndSortRecruits(recruits);
	local dataProvider = CreateDataProvider();
	for index = 1, numRecruits do
		local recruit = recruits[index];
		if needDivider and not recruit.isOnline then
			dataProvider:Insert({isDivider=true});
			needDivider = false;
		end
		dataProvider:Insert(recruit);
	end

	self.RecruitList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function RecruitAFriendFrameMixin:SetNextRewardName(rewardName, count, rewardType)
	if count > 1 then
		self.RewardClaiming.NextRewardName:SetText(RAF_REWARD_NAME_MULTIPLE:format(rewardName, count));
	else
		self.RewardClaiming.NextRewardName:SetText(rewardName);
	end
	self.RewardClaiming.NextRewardName:Show();

	if rewardType == Enum.RafRewardType.GameTime then
		self.RewardClaiming.NextRewardName:SetTextColor(HEIRLOOM_BLUE_COLOR:GetRGBA());
	else
		self.RewardClaiming.NextRewardName:SetTextColor(EPIC_PURPLE_COLOR:GetRGBA());
	end
end

function RecruitAFriendFrameMixin:OnUnwrapFlashBegun()
	if self.pendingNextReward then
		self:UpdateNextReward(self.pendingNextReward);
	end
end

local rewardClaimTextureKitRegions = {
	Watermark = "recruitafriend_%s_watermark_medium",
};
function RecruitAFriendFrameMixin:UpdateNextReward(nextReward)
	if self.RewardClaiming.NextRewardButton:WaitingForFlash() then
		-- The next reward button is animating, cache off the next reward and call again when we are done
		self.pendingNextReward = nextReward;
		return;
	else
		self.pendingNextReward = nil;
	end

	self.RewardClaiming.Background:SetAtlas(RAFUtil.DoesRAFVersionUseLegacyArt(nextReward.rafVersion) and self.RewardClaiming.legacyBackgroundAtlas or self.RewardClaiming.backgroundAtlas, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnRegions(RAFUtil.GetTextureKitForRAFVersion(nextReward.rafVersion), self.RewardClaiming, rewardClaimTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self.RewardClaiming.ClaimOrViewRewardButton:Update(nextReward, self.claimInProgress);

	if not nextReward then
		self.RewardClaiming.EarnInfo:Hide();
		self.RewardClaiming.NextRewardButton:Hide();
		self.RewardClaiming.NextRewardName:Hide();
		return;
	end

	if nextReward.canClaim then
		self.RewardClaiming.EarnInfo:SetText(RAF_YOU_HAVE_EARNED);
	elseif nextReward.monthCost > 1 then
		self.RewardClaiming.EarnInfo:SetText(RAF_NEXT_REWARD_AFTER:format(nextReward.monthCost - nextReward.availableInMonths, nextReward.monthCost));
	elseif nextReward.monthsRequired == 0 then
		self.RewardClaiming.EarnInfo:SetText(RAF_FIRST_REWARD);
	else
		self.RewardClaiming.EarnInfo:SetText(RAF_NEXT_REWARD);
	end

	local rightAlignedTooltip = true;
	self.RewardClaiming.NextRewardButton:Setup(nextReward, rightAlignedTooltip);

	if nextReward.petInfo then
		self:SetNextRewardName(nextReward.petInfo.speciesName, nextReward.repeatableClaimCount, nextReward.rewardType);
	elseif nextReward.mountInfo then
		local name = C_MountJournal.GetMountInfoByID(nextReward.mountInfo.mountID);
		self:SetNextRewardName(name, nextReward.repeatableClaimCount, nextReward.rewardType);
	elseif nextReward.appearanceInfo or nextReward.appearanceSetInfo or nextReward.illusionInfo then
		self.RewardClaiming.NextRewardButton.item:ContinueOnItemLoad(function()
			self:SetNextRewardName(self.RewardClaiming.NextRewardButton.item:GetItemName(), nextReward.repeatableClaimCount, nextReward.rewardType);
		end);
	elseif nextReward.titleInfo then
		local titleName = TitleUtil.GetNameFromTitleMaskID(nextReward.titleInfo.titleMaskID);
		if titleName then
			self:SetNextRewardName(RAF_REWARD_TITLE:format(titleName), nextReward.repeatableClaimCount, nextReward.rewardType);
		end
	else
		self:SetNextRewardName(RAF_BENEFIT4, nextReward.repeatableClaimCount, nextReward.rewardType);
	end

	self.RewardClaiming.EarnInfo:Show();
end

function RecruitAFriendFrameMixin:UpdateRAFInfo(rafInfo)
	if self.rafEnabled and rafInfo and #rafInfo.versions > 0 then
		self.rafInfo = rafInfo;

		local latestRAFVersionInfo = self:GetLatestRAFVersionInfo();
		if not self:GetSelectedRAFVersionInfo() then
			self:SetSelectedRAFVersion(latestRAFVersionInfo.rafVersion);
		end

		self:UpdateRecruitList(rafInfo.recruits);

		if (latestRAFVersionInfo.numRecruits == 0) and (latestRAFVersionInfo.monthCount.lifetimeMonths == 0) then
			self.RewardClaiming.MonthCount:SetText(RAF_FIRST_MONTH);
		else
			self.RewardClaiming.MonthCount:SetText(RAF_MONTHS_EARNED:format(latestRAFVersionInfo.monthCount.lifetimeMonths));
		end

		self.claimInProgress = rafInfo.claimInProgress;
		if latestRAFVersionInfo.nextReward then
			self:UpdateNextReward(latestRAFVersionInfo.nextReward);
		end

		RecruitAFriendRewardsFrame:SetUpTabs(rafInfo);
		RecruitAFriendRewardsFrame:Refresh();

		local recruitsAreMaxed = (#rafInfo.recruits >= maxRecruits);
		RecruitAFriendRecruitmentFrame:UpdateRecruitmentInfo(rafInfo.recruitmentInfo, recruitsAreMaxed);
	end

	self:UpdateRAFTutorialTips();
end

function RecruitAFriendFrameMixin:GetRAFInfo()
	return self.rafInfo;
end

function RecruitAFriendFrameMixin:OnRewardsListOpened()
	self:SetSelectedRAFVersion(self:GetLatestRAFVersion());
	self.RewardClaiming.ClaimOrViewRewardButton:UpdateUnclaimedRewardsAnim();
end

function RecruitAFriendFrameMixin:OnRewardsListClosed()
	self.RewardClaiming.ClaimOrViewRewardButton:UpdateUnclaimedRewardsAnim();
end	

function RecruitAFriendFrameMixin:OnNewRewardTabSelected(tabRAFVersion)
	self:SetSelectedRAFVersion(tabRAFVersion);
end

function RecruitAFriendFrameMixin:SetSelectedRAFVersion(rafVersion)
	if self.selectedRAFVersion == rafVersion then
		return;
	end

	self.selectedRAFVersion = rafVersion;
	self:TriggerEvent(RecruitAFriendFrameMixin.Event.SelectedRAFVersionChanged);
	RecruitAFriendRewardsFrame.ClaimLegacyRewardsButton:SetAutoClaimRewardsEnabled(false);
	RecruitAFriendRewardsFrame:Refresh();
end

function RecruitAFriendFrameMixin:GetSelectedRAFVersion()
	return self.selectedRAFVersion;
end

function RecruitAFriendFrameMixin:GetRAFVersionInfo(rafVersion)
	for index, versionInfo in ipairs(self.rafInfo.versions) do
		if versionInfo.rafVersion == rafVersion then
			return versionInfo;
		end
	end
end

function RecruitAFriendFrameMixin:GetSelectedRAFVersionInfo()
	return self:GetRAFVersionInfo(self.selectedRAFVersion);
end

function RecruitAFriendFrameMixin:GetLatestRAFVersion()
	return self.rafInfo.versions[1].rafVersion;
end

function RecruitAFriendFrameMixin:GetLatestRAFVersionInfo()
	return self.rafInfo.versions[1];
end

function RecruitAFriendFrameMixin:IsLegacyRAFVersion(rafVersion)
	return rafVersion ~= self:GetLatestRAFVersion();
end

function RecruitAFriendFrameMixin:AreAnyRewardsAffordable()
	for index, versionInfo in ipairs(self.rafInfo.versions) do
		if versionInfo.numAffordableRewards > 0 then
			return true;
		end
	end

	return false;
end

function RecruitAFriendFrameMixin:HasActivityRewardToClaim()
	if self.rafInfo then
		for _, recruitInfo in ipairs(self.rafInfo.recruits) do
			for _, activityInfo in ipairs(recruitInfo.activities) do
				if activityInfo.state == Enum.RafRecruitActivityState.Complete then
					return true;
				end
			end
		end
	end
end

function RecruitAFriendFrameMixin:ShouldShowRewardTutorial()
	local hasRafRewardToClaim = self.rafInfo and (#self.rafInfo.versions > 0) and self:AreAnyRewardsAffordable();
	return not self:IsShown() and not self.shownRewardTutorial and (hasRafRewardToClaim or self:HasActivityRewardToClaim());
end

function RecruitAFriendFrameMixin:ShowRecruitDropDown(recruitButton)
	if recruitButton then
		self.selectedRecruit = recruitButton;
		ToggleDropDownMenu(1, nil, self.DropDown, recruitButton, 0, 0);
	end
end

function RecruitAFriendFrameMixin:GetSelectedRecruit()
	return self.selectedRecruit;
end

function RecruitAFriendFrameMixin:OnDropDownClosed()
	self.selectedRecruit = nil;
end

RecruitActivityButtonMixin = {};

function RecruitActivityButtonMixin:OnLoad()
	self.ClaimGlowSpinAnim:Play(); -- Just leave this playing
end

function RecruitActivityButtonMixin:OnHide()
	self.Model:Hide();
end

function RecruitActivityButtonMixin:UpdateQuestName()
	if not self.questName and self.activityInfo then
		-- If we don't have the name now, get it. If it's not in the quest cache this will request it
		self.questName = C_QuestLog.GetTitleForQuestID(self.activityInfo.rewardQuestID);
	end
end

function RecruitActivityButtonMixin:OnEnter()
	self:GetParent():EnableDrawLayer("HIGHLIGHT");

	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local wrap = true;

	self:UpdateQuestName();
	self:UpdateIcon();

	if not self.questName then
		GameTooltip_SetTitle(EmbeddedItemTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		GameTooltip_SetTooltipWaitingForData(EmbeddedItemTooltip, true);
		self.UpdateTooltip = self.OnEnter;
	else
		GameTooltip_SetTitle(EmbeddedItemTooltip, self.questName, nil, wrap);

		EmbeddedItemTooltip:SetMinimumWidth(300);
		GameTooltip_AddNormalLine(EmbeddedItemTooltip, RAF_RECRUIT_ACTIVITY_DESCRIPTION:format(self.recruitInfo.nameText), true);

		local reqTextLines = C_RecruitAFriend.GetRecruitActivityRequirementsText(self.activityInfo.activityID, self.recruitInfo.acceptanceID);
		for i = 1, #reqTextLines do
			local reqText = reqTextLines[i];
			GameTooltip_AddColoredLine(EmbeddedItemTooltip, reqText, HIGHLIGHT_FONT_COLOR, wrap);
		end

		GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);

		if self.activityInfo.state == Enum.RafRecruitActivityState.Incomplete then
			GameTooltip_AddNormalLine(EmbeddedItemTooltip, QUEST_REWARDS, wrap);
		else
			GameTooltip_AddNormalLine(EmbeddedItemTooltip, YOU_EARNED_LABEL, wrap);
		end

		GameTooltip_AddQuestRewardsToTooltip(EmbeddedItemTooltip, self.activityInfo.rewardQuestID, TOOLTIP_QUEST_REWARDS_STYLE_NONE);

		if self.activityInfo.state == Enum.RafRecruitActivityState.Complete then
			GameTooltip_AddBlankLineToTooltip(EmbeddedItemTooltip);
			GameTooltip_AddInstructionLine(EmbeddedItemTooltip, CLICK_CHEST_TO_CLAIM_REWARD, wrap);
		end

		GameTooltip_SetTooltipWaitingForData(EmbeddedItemTooltip, false);
		self.UpdateTooltip = nil;
	end

	EmbeddedItemTooltip:Show();
end

function RecruitActivityButtonMixin:OnLeave()
	self:GetParent():DisableDrawLayer("HIGHLIGHT");
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
	self:UpdateIcon();
end

function RecruitActivityButtonMixin:PlayClaimRewardFanfare()
	self.ModelFadeOutAnim:Stop();
	self.Model:SetAlpha(1);

	-- Intentionaly hiding here before showing because we rely on the OnShow to set the model and kick off the animation, etc.
	self.Model:Hide();
	self.Model:Show();	-- This sets the model, which in turn starts the exploding animation, etc.
end

function RecruitActivityButtonMixin:OnClick()
	if self.activityInfo.state == Enum.RafRecruitActivityState.Complete then
		if C_RecruitAFriend.ClaimActivityReward(self.activityInfo.activityID, self.recruitInfo.acceptanceID) then
			self:PlayClaimRewardFanfare();
			PlaySound(SOUNDKIT.RAF_RECRUIT_REWARD_CLAIM);

			C_Timer.After(0.3, function()
				self.activityInfo.state = Enum.RafRecruitActivityState.RewardClaimed;
				self:Refresh();
			end)
		end
	end
end

function RecruitActivityButtonMixin:UpdateIcon()
	local useAtlasSize = true;
	if self:IsMouseOver() then
		if self.activityInfo.state == Enum.RafRecruitActivityState.RewardClaimed then
			self.Icon:SetAtlas("RecruitAFriend_RecruitedFriends_CursorOverChecked", useAtlasSize);
		else
			self.Icon:SetAtlas("RecruitAFriend_RecruitedFriends_CursorOver", useAtlasSize);
		end
	else
		if self.activityInfo.state == Enum.RafRecruitActivityState.Incomplete then
			self.Icon:SetAtlas("RecruitAFriend_RecruitedFriends_ActiveChest", useAtlasSize);
		elseif self.activityInfo.state == Enum.RafRecruitActivityState.Complete then
			self.Icon:SetAtlas("RecruitAFriend_RecruitedFriends_OpenChest", useAtlasSize);
		else
			self.Icon:SetAtlas("RecruitAFriend_RecruitedFriends_ClaimedChest", useAtlasSize);
		end
	end
end

function RecruitActivityButtonMixin:Setup(activityInfo, recruitInfo)
	self.activityInfo = activityInfo;
	self.recruitInfo = recruitInfo;

	if not activityInfo then
		self:Hide();
		return;
	end

	self:UpdateQuestName();
	self:UpdateIcon();

	local canClaim = (activityInfo.state == Enum.RafRecruitActivityState.Complete);
	if self.lastCanClaim == nil then
		if canClaim then
			self.ClaimGlow:SetAlpha(0.8);
			self.ClaimGlowSpin:SetAlpha(0.3);
		end
	else
		if canClaim ~= self.lastCanClaim then
			if canClaim then
				self.ClaimGlowOutAnim:Stop();
				self.ClaimGlowInAnim:Play();
			else
				self.ClaimGlowInAnim:Stop();
				self.ClaimGlowOutAnim:Play();
			end
		end
	end

	self.lastCanClaim = canClaim;
end

function RecruitActivityButtonMixin:Refresh()
	self:Setup(self.activityInfo, self.recruitInfo);
end

RecruitActivityButtonModelMixin = {};

function RecruitActivityButtonModelMixin:OnLoad()
	self.parentButton = self:GetParent();
	self:SetParent(RecruitAFriendFrame);
	self:SetFrameLevel(self.parentButton:GetFrameLevel() + 1);
end

function RecruitActivityButtonModelMixin:OnShow()
	self:SetModel(1601381);			--7FX_ARGUS_LIGHTFORGED_SIEGEWEAPON_IMPACT_HOLY.m2
end

function RecruitActivityButtonModelMixin:OnHide()
	self:ClearModel();
end

function RecruitActivityButtonModelMixin:OnModelLoaded()
	self:MakeCurrentCameraCustom();
	self:SetCameraPosition(0, 0, -25);
end

function RecruitActivityButtonModelMixin:OnAnimStarted()
	self.parentButton.ModelFadeOutAnim:Play();	-- Start a slight alpha fade so the explosion isn't as extreme
end

function RecruitActivityButtonModelMixin:OnAnimFinished()
	self:Hide();	-- Only play the animation once
end

RecruitListButtonMixin = {};

function RecruitListButtonMixin:Init(elementData)
	if elementData.isDivider then
		self:SetupDivider();
	else
		self:SetupRecruit(elementData);
	end
end

function RecruitListButtonMixin:OnEnter()
	if self.recruitInfo then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		GameTooltip_SetTitle(GameTooltip, self.recruitInfo.nameText, self.recruitInfo.nameColor);

		local wrap = true;
		GameTooltip_AddNormalLine(GameTooltip, RAF_RECRUIT_TOOLTIP_DESC:format(maxRecruitMonths), wrap);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);

		local usedMonths = math.max(maxRecruitMonths - self.recruitInfo.monthsRemaining, 0);
		GameTooltip_AddColoredLine(GameTooltip, RAF_RECRUIT_TOOLTIP_MONTH_COUNT:format(usedMonths, maxRecruitMonths), HIGHLIGHT_FONT_COLOR, wrap);
		GameTooltip:Show();
	end
end

function RecruitListButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RecruitListButtonMixin:OnClick(button)
	if self.recruitInfo and button == "RightButton" then
		RecruitAFriendFrame:ShowRecruitDropDown(self);
	end
end

function RecruitListButtonMixin:MakeDivider(isDivider)
	self.DividerTexture:SetShown(isDivider);
	self.Background:SetShown(not isDivider);
	self.Name:SetShown(not isDivider);
	self.InfoText:SetShown(not isDivider);
	self.Icon:SetShown(not isDivider);

	for i = 1, #self.Activities do
		self.Activities[i]:SetShown(not isDivider);
	end

	if isDivider then
		self:SetHeight(DIVIDER_HEIGHT);
		self:Disable();
	else
		self:SetHeight(RECRUIT_HEIGHT);
		self:Enable();
	end
end

function RecruitListButtonMixin:SetupDivider()
	self:MakeDivider(true);
	self.recruitInfo = nil;
	self:Show();
end

function RecruitListButtonMixin:UpdateActivities(recruitInfo)
	for i = 1, #self.Activities do
		local activityInfo = recruitInfo.activities[i];
		self.Activities[i]:Setup(activityInfo, recruitInfo);
	end
end

local recruitListButtonTextureKitRegions = {
	Icon = "recruitafriend_friendslist_%s_icon",
};
function RecruitListButtonMixin:SetupRecruit(recruitInfo)
	self:MakeDivider(false);

	self.recruitInfo = recruitInfo;

	self.Name:SetText(recruitInfo.nameText);
	self.Name:SetTextColor(recruitInfo.nameColor:GetRGB());

	local versionRecruited = self.recruitInfo.versionRecruited;
	SetupTextureKitOnRegions(RAFUtil.GetTextureKitForRAFVersion(versionRecruited), self, recruitListButtonTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	if recruitInfo.isOnline then
		self.Background:SetColorTexture(RAFUtil.GetColorForRAFVersion(versionRecruited):GetRGBA());
		if recruitInfo.subStatus == Enum.RafRecruitSubStatus.Active then
			self.InfoText:SetText(RAF_ACTIVE_RECRUIT);
			self.InfoText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		elseif recruitInfo.subStatus == Enum.RafRecruitSubStatus.Trial then
			self.InfoText:SetText(RAF_TRIAL_RECRUIT);
			self.InfoText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		else
			self.InfoText:SetText(RAF_INACTIVE_RECRUIT);
			self.InfoText:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		end
	else
		self.Background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR:GetRGBA());
		self.InfoText:SetTextColor(GRAY_FONT_COLOR:GetRGB());

		if recruitInfo.subStatus == Enum.RafRecruitSubStatus.Inactive then
			self.InfoText:SetText(RAF_INACTIVE_RECRUIT);
		else
			self.InfoText:SetText(FriendsFrame_GetLastOnlineText(recruitInfo.accountInfo));
		end
	end

	local mouseOnMe = (GameTooltip:GetOwner() == self);
	if mouseOnMe then
		self:OnEnter();
	end

	self:UpdateActivities(recruitInfo);

	self:Show();
end

RecruitAFriendDropDownMixin = {};

function RecruitAFriendDropDownMixin:OnLoad()
	self.isSelf = false;
	self.isRafRecruit = true;

	UIDropDownMenu_Initialize(self, self.Init, "MENU");
end

function RecruitAFriendDropDownMixin:OnHide()
	self.bnetIDAccount = nil;
	self.guid = nil;
	RecruitAFriendFrame:OnDropDownClosed();
end

function RecruitAFriendDropDownMixin:Init()
	local selectedRecruit = RecruitAFriendFrame:GetSelectedRecruit();
	if not selectedRecruit or not selectedRecruit.recruitInfo then
		return;
	end

	local recruitInfo = selectedRecruit.recruitInfo;
	local accountInfo = selectedRecruit.recruitInfo.accountInfo;

	self.bnetIDAccount = recruitInfo.bnetAccountID;
	self.wowAccountGUID = recruitInfo.wowAccountGUID;

	if accountInfo then
		self.guid = accountInfo.gameAccountInfo.playerGuid;
	end

	UnitPopup_ShowMenu(self, "RAF_RECRUIT", nil, recruitInfo.plainName);
end

RecruitAFriendNextRewardInfoButtonMixin = CreateFromMixins(RecruitAFriendSystemMixin);

function RecruitAFriendNextRewardInfoButtonMixin:OnEnter()
	local xOffset, yOffset = 0, 40;
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", xOffset, yOffset);
	GameTooltip_AddNormalLine(GameTooltip, RAF_NEXT_REWARD_HELP_TEXT);
	GameTooltip:Show();
end

function RecruitAFriendNextRewardInfoButtonMixin:OnLeave()
	GameTooltip_Hide();
end

RecruitAFriendVersionInfoButtonMixin = CreateFromMixins(RecruitAFriendSystemMixin);

function RecruitAFriendVersionInfoButtonMixin:OnEnter()
	local recruitAFriendFrame = self:GetRecruitAFriendFrame();
	local selectedVersionInfo = recruitAFriendFrame:GetSelectedRAFVersionInfo();

	local xOffset, yOffset = -5, -46;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", xOffset, yOffset);
	local helpText = recruitAFriendFrame:IsLegacyRAFVersion(selectedVersionInfo.rafVersion) and RAF_LEGACY_REWARDS_HELP_TEXT or RAF_LATEST_REWARDS_HELP_TEXT;
	GameTooltip_AddNormalLine(GameTooltip, helpText:format(selectedVersionInfo.numRecruits, selectedVersionInfo.numAffordableRewards));
	GameTooltip:Show();
end

function RecruitAFriendVersionInfoButtonMixin:OnLeave()
	GameTooltip_Hide();
end

RecruitAFriendClaimRewardButtonBaseMixin = CreateFromMixins(RecruitAFriendSystemMixin);

function RecruitAFriendClaimRewardButtonBaseMixin:OnEnter()
	if not self:IsEnabled() then
		local wrap = true;
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, BLIZZARD_STORE_PROCESSING, RED_FONT_COLOR, wrap);
		self.disabledTooltipShowing = true;
		GameTooltip:Show();
	end
end

function RecruitAFriendClaimRewardButtonBaseMixin:HideDisabledTooltip()
	GameTooltip_Hide();
	self.disabledTooltipShowing = false;
end

function RecruitAFriendClaimRewardButtonBaseMixin:OnLeave()
	self:HideDisabledTooltip();
end

function RecruitAFriendClaimRewardButtonBaseMixin:OnHide()
	self:HideDisabledTooltip();
end

local RecruitAFriendClaimLegacyRewardsButtonEvents = {
	"RAF_REWARD_CLAIM_FAILED",
};

-- Global function for call from token claim dialog
function RecruitAFriend_TryCancelAutoClaim()
	RecruitAFriendRewardsFrame.ClaimLegacyRewardsButton:SetAutoClaimRewardsEnabled(false);
	RecruitAFriendRewardsFrame.ClaimLegacyRewardsButton:UpdateUnclaimedRewardsAnim();
end

RecruitAFriendClaimLegacyRewardsButtonMixin = {};

function RecruitAFriendClaimLegacyRewardsButtonMixin:OnEvent(event, ...)
	if event == "RAF_REWARD_CLAIM_FAILED" then
		self:SetAutoClaimRewardsEnabled(false);
		self:UpdateUnclaimedRewardsAnim();
	end
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, RecruitAFriendClaimLegacyRewardsButtonEvents);
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:OnClick()
	if self.haveUnclaimedReward then
		if self:GetRecruitAFriendFrame().RewardClaiming.NextRewardButton:IsUnwrapAnimating() then
			return;
		end

		self.autoClaimRewards = true;
		self:ClaimNextReward();
	end
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:Update(selectedRAFVersionInfo)
	self.nextReward = selectedRAFVersionInfo.nextReward;
	self.haveUnclaimedReward = self.nextReward and self.nextReward.canClaim;
	self.numAffordableRewards = selectedRAFVersionInfo.numAffordableRewards;
	
	local isShown = self.haveUnclaimedReward;
	
	self:SetShown(isShown);
	if self.autoClaimRewards and self.numAffordableRewards <= 0 then
		self.autoClaimRewards = false;
	end
	self:UpdateButtonEnabledState();
	self:UpdateUnclaimedRewardsAnim();

	self:SetText(self.numAffordableRewards == 1 and CLAIM_REWARD or RAF_CLAIM_MULTIPLE_REWARDS:format(self.numAffordableRewards));
	if isShown and self:IsMouseOver() and not self:IsEnabled() and not self.disabledTooltipShowing then
		self:OnEnter();
	elseif not isShown or self:IsEnabled() and self.disabledTooltipShowing then
		self:HideDisabledTooltip();
	end

	if self.autoClaimRewards and self.haveUnclaimedReward and not self:GetRecruitAFriendFrame().claimInProgress then
		C_Timer.After(1.75, function() 
			if self.autoClaimRewards then 
				self:ClaimNextReward();
			end
		end);
	end
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:UpdateButtonEnabledState()
	self:SetEnabled(not self.autoClaimRewards and self.haveUnclaimedReward and not self:GetRecruitAFriendFrame().claimInProgress);
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:UpdateUnclaimedRewardsAnim()
	if self.numAffordableRewards <= 0 or self:GetRecruitAFriendFrame().claimInProgress then
		self.UnclaimedRewardsAnim:Stop();
		return;
	end

	self.UnclaimedRewardsAnim:SetPlaying(self:IsEnabled() and self.numAffordableRewards > 0);
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:SetAutoClaimRewardsEnabled(enabled)
	self.autoClaimRewards = enabled;
	self:UpdateButtonEnabledState();
end

function RecruitAFriendClaimLegacyRewardsButtonMixin:ClaimNextReward()
	if self.nextReward.rewardType == Enum.RafRewardType.GameTime then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
		WowTokenRedemptionFrame_ShowDialog("RAF_GAME_TIME_REDEEM_CONFIRMATION_SUB", self.nextReward.rafVersion);
	else 
		self.autoClaimRewards = C_RecruitAFriend.ClaimNextReward(self.nextReward.rafVersion);
	end
end

RecruitAFriendClaimOrViewRewardButtonMixin = {};

function RecruitAFriendClaimOrViewRewardButtonMixin:OnLoad()
	self:SetEnabled(false);
end

function RecruitAFriendClaimOrViewRewardButtonMixin:OnClick()
	if self.haveUnclaimedReward then
		if RecruitAFriendFrame.RewardClaiming.NextRewardButton:IsUnwrapAnimating() then
			return;
		end

		if self.nextReward.rewardType == Enum.RafRewardType.GameTime then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
			WowTokenRedemptionFrame_ShowDialog("RAF_GAME_TIME_REDEEM_CONFIRMATION_SUB", self.nextReward.rafVersion);
		elseif C_RecruitAFriend.ClaimNextReward() then
			RecruitAFriendFrame.RewardClaiming.NextRewardButton:PlayClaimRewardFanfare();
		end
	else
		if RecruitAFriendRewardsFrame:IsShown() then
			RecruitAFriendRewardsFrame:Hide();
		else
			RecruitAFriendRewardsFrame:Show();
			StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
		end
	end
end

function RecruitAFriendClaimOrViewRewardButtonMixin:Update(nextReward, claimInProgress)
	self.nextReward = nextReward;
	self.haveUnclaimedReward = nextReward and nextReward.canClaim;

	if self.haveUnclaimedReward then
		self:SetEnabled(not claimInProgress);
		self:SetText(CLAIM_REWARD);
		RecruitAFriendRewardsFrame:Hide();
	else
		self:SetEnabled(true);
		self:SetText(RAF_VIEW_ALL_REWARDS);
	end

	self:UpdateUnclaimedRewardsAnim();

	if self:IsMouseOver() and not self:IsEnabled() and not self.disabledTooltipShowing then
		self:OnEnter();
	elseif self:IsEnabled() and self.disabledTooltipShowing then
		self:HideDisabledTooltip();
	end
end

function RecruitAFriendClaimOrViewRewardButtonMixin:UpdateUnclaimedRewardsAnim()
	if not self:IsEnabled() then
		self.UnclaimedRewardsAnim:Stop();
		return;
	end

	local recruitAFriendFrame = self:GetRecruitAFriendFrame();
	local claimInProgress = recruitAFriendFrame.claimInProgress;
	local rewardsListOpen = self:GetRecruitAFriendRewardsFrame():IsShown();
	if claimInProgress or rewardsListOpen then
		self.UnclaimedRewardsAnim:Stop();
		return;
	end

	self.UnclaimedRewardsAnim:SetPlaying(recruitAFriendFrame:AreAnyRewardsAffordable());
end

RecruitAFriendRewardsFrameMixin = CreateFromMixins(RecruitAFriendSystemMixin);

function RecruitAFriendRewardsFrameMixin:OnLoad()
	self.rewardPool = CreateFramePool("FRAME", self, "RecruitAFriendRewardTemplate");
	self.rewardTabPool = CreateFramePool("CHECKBUTTON", self, "RecruitAFriendRewardTabTemplate");
end

function RecruitAFriendRewardsFrameMixin:OnShow()
	self:GetRecruitAFriendFrame():TriggerEvent(RecruitAFriendFrameMixin.Event.RewardsListOpened);

	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	HideUIPanel(DressUpFrame);
end

function RecruitAFriendRewardsFrameMixin:OnHide()
	self:GetRecruitAFriendFrame():TriggerEvent(RecruitAFriendFrameMixin.Event.RewardsListClosed);

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	CloseSideDressUpFrame(self);
	self.ClaimLegacyRewardsButton:SetAutoClaimRewardsEnabled(false);
end

local rewardsFrameTextureKitRegions = {
	Watermark = "recruitafriend_%s_iwatermark_big",
};
function RecruitAFriendRewardsFrameMixin:UpdateBackground()
	local selectedRAFVersion = self:GetRecruitAFriendFrame():GetSelectedRAFVersion();
	self.Background:SetAtlas(RAFUtil.DoesRAFVersionUseLegacyArt(selectedRAFVersion) and self.legacyBackgroundAtlas or self.backgroundAtlas, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnRegions(RAFUtil.GetTextureKitForRAFVersion(selectedRAFVersion), self, rewardsFrameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

function RecruitAFriendRewardsFrameMixin:UpdateDescription(selectedRAFVersionInfo)
	self.Description:SetText((selectedRAFVersionInfo.rafVersion == self:GetRecruitAFriendFrame():GetLatestRAFVersion()) and RAF_REWARDS_DESC or RAF_LEGACY_REWARDS_DESC);
end

function RecruitAFriendRewardsFrameMixin:SetUpTabs(rafInfo)
	self.rewardTabPool:ReleaseAll();

	local needTabs = #rafInfo.versions > 1;
	if not needTabs then
		return;
	end

	local lastRewardTab;
	for index, versionInfo in ipairs(rafInfo.versions) do
		local rewardTab = self.rewardTabPool:Acquire();

		if lastRewardTab == nil then
			rewardTab:SetPoint("TOPLEFT", self, "TOPRIGHT", -3, -35);
		else
			rewardTab:SetPoint("TOPLEFT", lastRewardTab, "BOTTOMLEFT", 0, -17);
		end
		
		rewardTab:Setup(versionInfo.rafVersion);
		lastRewardTab = rewardTab;
	end
end

function RecruitAFriendRewardsFrameMixin:UpdateRewards(rewards)
	self.rewardPool:ReleaseAll();

	if not rewards then
		return;
	end

	local lastRewardFrame;
	for index, rewardInfo in ipairs(rewards) do	
		if index > 13 then
			return;
		end

		local leftColumnStartIndex = 1;
		local rightColumnStartIndex = leftColumnStartIndex + (#rewards - 1) / 2;
		local finalRewardIndex = #rewards;
		local rewardFrame = self.rewardPool:Acquire();
		if index == leftColumnStartIndex then
			rewardFrame:SetPoint("TOPLEFT", self.Background, "TOPLEFT", 69, -98);
		elseif index == rightColumnStartIndex then
			rewardFrame:SetPoint("TOPLEFT", self.Background, "TOPLEFT", 209, -98);
		elseif index == finalRewardIndex then
			rewardFrame:SetPoint("BOTTOM", self.Background, "BOTTOM", 0, 44);
		else
			rewardFrame:SetPoint("TOPLEFT", lastRewardFrame, "BOTTOMLEFT", 0, -9);
		end

		local tooltipRightAligned = (index >= rightColumnStartIndex and index < finalRewardIndex);
		rewardFrame:Setup(rewardInfo, tooltipRightAligned);
		lastRewardFrame = rewardFrame;
	end
end

function RecruitAFriendRewardsFrameMixin:Refresh()
	local recruitAFriendFrame = self:GetRecruitAFriendFrame();
	local selectedRAFVersionInfo = recruitAFriendFrame:GetSelectedRAFVersionInfo();

	local isUsingDressUp = SideDressUpFrame:IsShown() and SideDressUpFrame:GetParent() == self;
	CloseSideDressUpFrame(self);

	self:UpdateBackground();
	self:UpdateDescription(selectedRAFVersionInfo);
	self:UpdateRewards(selectedRAFVersionInfo.rewards);
	self.ClaimLegacyRewardsButton:Update(selectedRAFVersionInfo, recruitAFriendFrame.claimInProgress);
	self:Layout();

	SetUpSideDressUpFrame(self, 500, 682, "TOPLEFT", "TOPRIGHT", -5, -2);
	SetUIPanelShown(SideDressUpFrame, isUsingDressUp);
end

RecruitAFriendRewardMixin = {};

function RecruitAFriendRewardMixin:Setup(rewardInfo, tooltipRightAligned)
	self.Button:Setup(rewardInfo, tooltipRightAligned);

	if rewardInfo.claimed then
		self.Months:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	elseif rewardInfo.canClaim or rewardInfo.canAfford then
		self.Months:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	else
		self.Months:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	end

	if rewardInfo.repeatable then
		self.Months:SetText(RAF_REPEATABLE_MONTHS:format(rewardInfo.monthCost));
	else
		self.Months:SetText(RAF_MONTHS:format(rewardInfo.monthsRequired + rewardInfo.monthCost));
	end

	self:SetWidth(self.Button:GetWidth() + self.Months:GetWidth() + 7);
	self:Show();
end

RecruitAFriendRewardButtonMixin = {};

function RecruitAFriendRewardButtonMixin:OnLoad()
	self.tooltipXOffset = 5;
end

function RecruitAFriendRewardButtonMixin:Setup(rewardInfo, tooltipRightAligned)
	self.rewardInfo = rewardInfo;
	self.tooltipRightAligned = tooltipRightAligned;

	self.Icon:SetTexture(rewardInfo.iconID);
	if not rewardInfo.claimed and not rewardInfo.canClaim and not rewardInfo.canAfford then
		self.Icon:SetDesaturated(true);
		self.IconOverlay:SetShown(true);
	else
		self.Icon:SetDesaturated(false);
		self.IconOverlay:SetShown(false);
	end

	self:SetClaimed(rewardInfo.claimed);
	self:SetCanClaim(rewardInfo.canClaim);

	self.dressupReward = false;
	self.item = nil;
	self.titleName = nil;

	if self.rewardInfo.itemID > 0 then
		self.item = Item:CreateFromItemID(self.rewardInfo.itemID);
	end

	if self.rewardInfo.petInfo then
		self.dressupReward = self.rewardInfo.petInfo.displayID > 0;
	elseif self.rewardInfo.mountInfo then
		self.dressupReward = self.rewardInfo.mountInfo.mountID > 0;
	elseif self.rewardInfo.titleInfo then
		self.titleName = TitleUtil.GetNameFromTitleMaskID(self.rewardInfo.titleInfo.titleMaskID);
	elseif self.rewardInfo.appearanceInfo or self.rewardInfo.appearanceSetInfo or self.rewardInfo.illusionInfo then
		self.dressupReward = true;
	end

	self:Show();
end

function RecruitAFriendRewardButtonMixin:OnClick()
	if IsModifiedClick("DRESSUP") and self.dressupReward then
		if self.rewardInfo.petInfo then
			DressUpBattlePet(self.rewardInfo.petInfo.creatureID, self.rewardInfo.petInfo.displayID, self.rewardInfo.petInfo.speciesID);
		elseif self.rewardInfo.mountInfo then
			DressUpMount(self.rewardInfo.mountInfo.mountID);
		elseif self.rewardInfo.appearanceInfo then
			DressUpVisual(self.rewardInfo.appearanceInfo.appearanceID);
		elseif self.rewardInfo.appearanceSetInfo then
			DressUpTransmogSet(self.rewardInfo.appearanceSetInfo.appearanceIDs)
		elseif self.rewardInfo.illusionInfo then
			local weaponSlot, weaponSourceID = TransmogUtil.GetBestWeaponInfoForIllusionDressup();
			DressUpVisual(weaponSourceID, weaponSlot, self.rewardInfo.illusionInfo.spellItemEnchantmentID);
		end
	elseif IsModifiedClick("CHATLINK") then
		local itemID = self.rewardInfo.itemID;
		if itemID then
			local name, link = C_Item.GetItemInfo(itemID);
			if not ChatEdit_InsertLink(link) then
				ChatFrame_OpenChat(link);
			end
		end
	end
end

function RecruitAFriendRewardButtonMixin:SetTooltipOwner()
	local anchorPoint, xOffset;
	if self.tooltipRightAligned then
		anchorPoint = "ANCHOR_RIGHT";
		xOffset = self.tooltipXOffset;
	else
		anchorPoint = "ANCHOR_LEFT";
		xOffset = -self.tooltipXOffset;
	end
	GameTooltip:SetOwner(self, anchorPoint, xOffset, -self:GetHeight());
end

function RecruitAFriendRewardButtonMixin:OnEnter()
	if not self.rewardInfo then
		return;
	end

	self:SetTooltipOwner();

	GameTooltip:SetItemByID(self.rewardInfo.itemID);

	if self.dressupReward then
		self.UpdateTooltip = function() self:OnEnter(); end;
	else
		self.UpdateTooltip = nil;
	end

	if IsModifiedClick("DRESSUP") and self.dressupReward then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function RecruitAFriendRewardButtonMixin:OnLeave()
	self.UpdateTooltip = nil;
	ResetCursor();
	GameTooltip_Hide();
end

function RecruitAFriendRewardButtonMixin:SetClaimed(claimed)
	--overridden in inherited mixins
end

function RecruitAFriendRewardButtonMixin:SetCanClaim(canClaim)
	--overridden in inherited mixins
end

RecruitAFriendRewardButtonWithCheckMixin = CreateFromMixins(RecruitAFriendRewardButtonMixin);

function RecruitAFriendRewardButtonWithCheckMixin:SetClaimed(claimed)
	self.CheckMark:SetShown(claimed);
end

function RecruitAFriendRewardButtonWithCheckMixin:Setup(rewardInfo, tooltipRightAligned)
	RecruitAFriendRewardButtonMixin.Setup(self, rewardInfo, tooltipRightAligned);

	if not rewardInfo.claimed and not rewardInfo.canClaim and not rewardInfo.canAfford then
		self.IconBorder:SetDesaturated(true);
		self.IconBorder:SetVertexColor(WHITE_FONT_COLOR:GetRGBA());
	else
		self.IconBorder:SetDesaturated(false);
		if rewardInfo.rewardType == Enum.RafRewardType.GameTime then
			self.IconBorder:SetVertexColor(HEIRLOOM_BLUE_COLOR:GetRGBA());
		else
			self.IconBorder:SetVertexColor(EPIC_PURPLE_COLOR:GetRGBA());
		end
	end
end

local RAF_FANFARE_MODEL_SCENE = 253;

RecruitAFriendRewardButtonWithFanfareMixin = CreateFromMixins(RecruitAFriendRewardButtonMixin);

function RecruitAFriendRewardButtonWithFanfareMixin:OnLoad()
	self.tooltipXOffset = 10;
	self.ModelScene:EnableMouse(false);
end

function RecruitAFriendRewardButtonWithFanfareMixin:Setup(rewardInfo, tooltipRightAligned)
	RecruitAFriendRewardButtonMixin.Setup(self, rewardInfo, tooltipRightAligned);

	if not rewardInfo.claimed and not rewardInfo.canClaim then
		self.IconBorder:SetAtlas("RecruitAFriend_ClaimPane_SepiaRing", true);
	else
		self.IconBorder:SetAtlas("RecruitAFriend_ClaimPane_GoldRing", true);
	end
end

function RecruitAFriendRewardButtonWithFanfareMixin:OnClick()
	if IsModifiedClick("DRESSUP") and self.dressupReward then
		if RecruitAFriendRewardsFrame:IsShown() then
			RecruitAFriendRewardsFrame:Hide();
		end
		RecruitAFriendRewardButtonMixin.OnClick(self);
	end
end

function RecruitAFriendRewardButtonWithFanfareMixin:WaitingForFlash()
	return self.waitingForFlash;
end

function RecruitAFriendRewardButtonWithFanfareMixin:IsUnwrapAnimating()
	return self.ModelScene:IsUnwrapAnimating();
end

function RecruitAFriendRewardButtonWithFanfareMixin:SetCanClaim(canClaim)
	self.ClaimGlowSpinAnim:Play(); -- Just leave this playing

	if self.lastCanClaim == nil then
		-- Initialization..if we start in a claimable state just go to the end of the anim and show the fanfare model scene
		if canClaim then
			self.ClaimGlow:SetAlpha(0.8);
			self.ClaimGlowSpin:SetAlpha(0.3);
			self:UpdateFanfareModelScene(canClaim);
		end
	else
		if canClaim ~= self.lastCanClaim then
			if canClaim then
				self.ClaimGlowOutAnim:Stop();
				self.ClaimGlowInAnim:Play();
				self:UpdateFanfareModelScene(canClaim);
			else
				self.ClaimGlowInAnim:Stop();
				self.ClaimGlowOutAnim:Play();
				if not self:IsUnwrapAnimating() then
					self.ModelScene:Hide();
				end
			end
		end
	end

	self.lastCanClaim = canClaim;
end

function RecruitAFriendRewardButtonWithFanfareMixin:UpdateFanfareModelScene(canClaim)
	if canClaim then
		self.ModelScene:TransitionToModelSceneID(RAF_FANFARE_MODEL_SCENE, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, true);
		self.ModelScene:PrepareForFanfare(true);
		self.ModelScene:Show();
	else
		self.ModelScene:Hide();
	end
end

-- Global function for call from token claim dialog
function RecruitAFriend_TryPlayClaimRewardFanfare(rewardRAFVersion)
	if rewardRAFVersion ~= RecruitAFriendFrame:GetLatestRAFVersion() then
		return;
	end

	RecruitAFriendFrame.RewardClaiming.NextRewardButton:PlayClaimRewardFanfare();
end

function RecruitAFriendRewardButtonWithFanfareMixin:PlayClaimRewardFanfare()
	self.waitingForFlash = true;
	C_Timer.After(0.8, function()
		self.ClaimFlashAnim:Stop();
		self.ClaimFlashAnim:Play();
		self.waitingForFlash = false;
		RecruitAFriendFrame:OnUnwrapFlashBegun();
	end)

	local function OnFinishedCallback()
		self:UpdateFanfareModelScene(self.lastCanClaim);
	end

	self.ModelScene:StartUnwrapAnimation(OnFinishedCallback);
end

RecruitAFriendRewardTabMixin = CreateFromMixins(RecruitAFriendSystemMixin);

function RecruitAFriendRewardTabMixin:OnLoad()
	self:AddDynamicEventMethod(self:GetRecruitAFriendFrame(), RecruitAFriendFrameMixin.Event.SelectedRAFVersionChanged, self.OnSelectedRAFVersionChanged)
end

function RecruitAFriendRewardTabMixin:OnSelectedRAFVersionChanged()
	self:RefreshVisuals();
end

function RecruitAFriendRewardTabMixin:Setup(rafVersion)
	self.rafVersion = rafVersion;

	self.Icon:SetAtlas(self.IconAtlasFormat:format(RAFUtil.GetTextureKitForRAFVersion(self.rafVersion), TextureKitConstants.UseAtlasSize));
	self:RefreshVisuals();

	self:Show();
end

function RecruitAFriendRewardTabMixin:GetRAFVersion(rafVersion)
	return self.rafVersion;
end

function RecruitAFriendRewardTabMixin:TrySetChecked()
	self:SetChecked(self.rafVersion == self:GetRecruitAFriendFrame():GetSelectedRAFVersion());
end

function RecruitAFriendRewardTabMixin:TryPlayUnclaimedRewardsAnim(versionInfo)
	if self:GetChecked() then
		self.UnclaimedRewardsAnim:Stop();
		return;
	end

	local recruitAFriendFrame = self:GetRecruitAFriendFrame();
	local isLegacyRewardTab = recruitAFriendFrame:IsLegacyRAFVersion(self.rafVersion);
	if not isLegacyRewardTab then
		self.UnclaimedRewardsAnim:Stop();
		return;
	end

	local versionInfo = recruitAFriendFrame:GetRAFVersionInfo(self.rafVersion);
	local canClaimNextReward = versionInfo.nextReward and versionInfo.nextReward.canClaim;
	self.UnclaimedRewardsAnim:SetPlaying(canClaimNextReward);
end

function RecruitAFriendRewardTabMixin:RefreshVisuals()
	self:TrySetChecked();
	self:TryPlayUnclaimedRewardsAnim();
end

function RecruitAFriendRewardTabMixin:OnClick()
	self:GetRecruitAFriendFrame():TriggerEvent(RecruitAFriendFrameMixin.Event.NewRewardTabSelected, self.rafVersion);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

RecruitAFriendRecruitmentButtonMixin = {};

function RecruitAFriendRecruitmentButtonMixin:OnClick()
	if RecruitAFriendRecruitmentFrame:IsShown() then
		StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	else
		C_RecruitAFriend.RequestUpdatedRecruitmentInfo();
		RecruitAFriendRewardsFrame:Hide();
		StaticPopupSpecial_Show(RecruitAFriendRecruitmentFrame);
	end
end

RecruitAFriendRecruitmentFrameMixin = {};

function RecruitAFriendRecruitmentFrameMixin:OnLoad()
	self.EditBox:Disable();
end

function RecruitAFriendRecruitmentFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function RecruitAFriendRecruitmentFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

local PLAYER_REALM_NAME = GetRealmName();
local _, PLAYER_FACTION_NAME = UnitFactionGroup("player");

function RecruitAFriendRecruitmentFrameMixin:UpdateRecruitmentInfo(recruitmentInfo, recruitsAreMaxed)
	if recruitmentInfo then
		local expireDate = date("*t", recruitmentInfo.expireTime);
		recruitmentInfo.expireDateString = FormatShortDate(expireDate.day, expireDate.month, expireDate.year)

		self.Description:SetText(RAF_RECRUITMENT_DESC:format(recruitmentInfo.totalUses, daysInCycle));

		if recruitmentInfo.sourceFaction ~= "" then
			self.FactionAndRealm:SetText(RAF_RECRUITS_FACTION_AND_REALM:format(recruitmentInfo.sourceFaction, recruitmentInfo.sourceRealm));
			self.FactionAndRealm:Show();
		else
			self.FactionAndRealm:Hide();
		end

		self.EditBox.Instructions:Hide();
		self.EditBox:SetText(recruitmentInfo.recruitmentURL);
		self.EditBox:SetCursorPosition(0);
	else
		self.Description:SetText(RAF_RECRUITMENT_DESC:format(maxRecruitLinkUses, daysInCycle));
		self.FactionAndRealm:SetText(RAF_RECRUITS_FACTION_AND_REALM:format(PLAYER_FACTION_NAME, PLAYER_REALM_NAME));

		self.EditBox.Instructions:SetText(RAF_NO_ACTIVE_LINK:format(daysInCycle));
		self.EditBox.Instructions:Show();
		self.EditBox:SetText("");
	end

	if recruitsAreMaxed then
		self.InfoText1:SetText(RAF_FULL_RECRUITS:format(maxRecruits, maxRecruits));
		self.InfoText1:SetTextColor(RED_FONT_COLOR:GetRGB());
		self.InfoText1:Show();
		self.InfoText2:Hide();
	elseif recruitmentInfo then
		self.InfoText1:SetTextColor(WHITE_FONT_COLOR:GetRGB());

		if recruitmentInfo.remainingUses > 0 then
			self.InfoText1:SetText(RAF_ACTIVE_LINK_EXPIRE_DATE:format(recruitmentInfo.expireDateString));
		else
			self.InfoText1:SetText(RAF_EXPENDED_LINK_EXPIRE_DATE:format(recruitmentInfo.expireDateString));
		end

		if recruitmentInfo.remainingUses > 0 then
			self.InfoText2:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		else
			self.InfoText2:SetTextColor(RED_FONT_COLOR:GetRGB());
		end

		local timesUsed = recruitmentInfo.totalUses - recruitmentInfo.remainingUses;
		self.InfoText2:SetText(RAF_LINK_REMAINING_USES:format(timesUsed, recruitmentInfo.totalUses));

		self.InfoText1:Show();
		self.InfoText2:Show();
	else
		self.InfoText1:Hide();
		self.InfoText2:Hide();
	end

	self.GenerateOrCopyLinkButton:Update(recruitmentInfo, recruitsAreMaxed);
end

RecruitAFriendGenerateOrCopyLinkButtonMixin = {};

function RecruitAFriendGenerateOrCopyLinkButtonMixin:OnClick()
	if self.recruitmentInfo then
		CopyToClipboard(self.recruitmentInfo.recruitmentURL);
	else
		if C_RecruitAFriend.GenerateRecruitmentLink() then
			self.waitingForRecruitmentInfo = true;
			self:Disable();
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:OnEnter()
	if not self:IsEnabled() then
		local wrap = true;

		if self.recruitsAreMaxed then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, RAF_FULL_RECRUITS:format(maxRecruits, maxRecruits), RED_FONT_COLOR, wrap);
			GameTooltip:Show();
		elseif not self.waitingForRecruitmentInfo then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, RAF_EXPENDED_LINK_EXPIRE_DATE:format(self.recruitmentInfo.expireDateString), RED_FONT_COLOR, wrap);
			GameTooltip:Show();
		end
	end
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:Update(recruitmentInfo, recruitsAreMaxed)
	self.recruitmentInfo = recruitmentInfo;
	self.recruitsAreMaxed = recruitsAreMaxed;

	if recruitmentInfo then
		self.waitingForRecruitmentInfo = false;
		self:SetText(RAF_COPY_LINK);
		self:SetEnabled(recruitmentInfo.remainingUses > 0 and not recruitsAreMaxed);
	else
		self:SetText(RAF_GENERATE_LINK);
		self:SetEnabled(not self.waitingForRecruitmentInfo and not recruitsAreMaxed);
	end
end
