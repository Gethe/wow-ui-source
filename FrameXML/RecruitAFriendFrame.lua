RecruitAFriendFrameMixin = {};

function RecruitAFriendFrameMixin:OnLoad()
	self:SetRAFSystemEnabled(C_RecruitAFriend.IsEnabled());
	self:SetRAFRecruitingEnabled(C_RecruitAFriend.IsRecruitingEnabled());
	self:RegisterEvent("RAF_SYSTEM_ENABLED_STATUS");
	self:RegisterEvent("RAF_RECRUITING_ENABLED_STATUS");
	self:RegisterEvent("RAF_SYSTEM_INFO_UPDATED");
	self:RegisterEvent("RAF_INFO_UPDATED");
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
	self:RegisterEvent("VARIABLES_LOADED");

	self.recruitScrollFrame = self.RecruitList.ScrollFrame;

	local function UpdateRecruitList()
		if self.rafInfo then
			self:UpdateRecruitList(self.rafInfo.recruits);
		end
	end

	self.recruitScrollFrame.update = UpdateRecruitList;
	HybridScrollFrame_CreateButtons(self.recruitScrollFrame, "RecruitListButtonTemplate");

	local rafSystemInfo = C_RecruitAFriend.GetRAFSystemInfo();
	self:UpdateRAFSystemInfo(rafSystemInfo);

	local rafInfo = C_RecruitAFriend.GetRAFInfo();
	self:UpdateRAFInfo(rafInfo);
end

function RecruitAFriendFrameMixin:OnHide()
	CloseDropDownMenus();
	StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	StaticPopupSpecial_Hide(RecruitAFriendRewardsFrame);
end

function RecruitAFriendFrameMixin:OnEvent(event, ...)
	if event == "RAF_SYSTEM_ENABLED_STATUS" then
		local rafEnabled = ...;
		self:SetRAFSystemEnabled(rafEnabled);
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

function RecruitAFriendFrameMixin:SetRAFSystemEnabled(rafEnabled)
	self.rafEnabled = rafEnabled;
	self:UpdateRAFTutorialTips();
end

function RecruitAFriendFrameMixin:UpdateRAFTutorialTips()
	if self.varsLoaded and self.rafEnabled then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_RAF_INTRO) then
			local introHelpTipInfo = {
				text = RAF_INTRO_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_RAF_INTRO,
				targetPoint = HelpTip.Point.RightEdgeCenter,
			};
			HelpTip:Show(QuickJoinToastButton, introHelpTipInfo);
		elseif self:ShowRewardTutorial() then
			local rewardHelpTipInfo = {
				text = RAF_REWARD_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.RightEdgeCenter,
			};
			HelpTip:Show(QuickJoinToastButton, rewardHelpTipInfo);
			self.shownRewardTutorial = true;
		end
	end
end

function RecruitAFriendFrameMixin:SetRAFRecruitingEnabled(rafRecruitingEnabled)
	self.RecruitmentButton:SetShown(rafRecruitingEnabled);

	if not rafRecruitingEnabled then
		StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	end
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

local RECRUIT_HEIGHT = 45;

local function SortRecruits(a, b)
	if a.isOnline ~= b.isOnline then
		return a.isOnline;
	else
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

	-- Get account info for all recruits
	for _, recruitInfo in ipairs(recruits) do
		local accountInfo = C_BattleNet.GetAccountInfoByID(recruitInfo.bnetAccountID, recruitInfo.wowAccountGUID);

		if accountInfo then
			recruitInfo.isOnline = accountInfo.isOnline;
			recruitInfo.characterName = accountInfo.characterName;
			recruitInfo.nameText, recruitInfo.nameColor = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			recruitInfo.plainName = BNet_GetBNetAccountName(accountInfo);
		else
			-- We have no presence info for them yet...we will get an update when we do
			recruitInfo.isOnline = false;
			recruitInfo.nameText = BNet_GetTruncatedBattleTag(recruitInfo.battleTag);
			recruitInfo.plainName = recruitInfo.nameText;
			recruitInfo.nameColor = FRIENDS_GRAY_COLOR;
		end

		recruitInfo.accountInfo = accountInfo;

		if not seenAccounts[recruitInfo.bnetAccountID] then
			seenAccounts[recruitInfo.bnetAccountID] = 1;
		else
			seenAccounts[recruitInfo.bnetAccountID] = seenAccounts[recruitInfo.bnetAccountID] + 1;
		end

		-- Set an index so we can append it to the name if needed
		recruitInfo.recruitIndex = seenAccounts[recruitInfo.bnetAccountID];
	end

	-- Now that we have seen all recruits, loop through again and append the recruitIndex to any recruits that share a bnetAccountID and are not online
	for _, recruitInfo in ipairs(recruits) do
		if seenAccounts[recruitInfo.bnetAccountID] > 1 and not recruitInfo.characterName then
			recruitInfo.nameText = RAF_RECRUIT_NAME_MULTIPLE:format(recruitInfo.nameText, recruitInfo.recruitIndex);
		end
	end

	-- And then sort them by online status and name
	table.sort(recruits, SortRecruits);
end

function RecruitAFriendFrameMixin:UpdateRecruitList(recruits)
	local offset = HybridScrollFrame_GetOffset(self.recruitScrollFrame);
	local buttons = self.recruitScrollFrame.buttons;
	local numButtons = #buttons;
	local usedHeight = 0;

	ProcessAndSortRecruits(recruits);

	local numRecruits = #recruits;

	self.RecruitList.NoRecruitsDesc:SetShown(numRecruits == 0);

	local totalHeight = numRecruits * RECRUIT_HEIGHT;

	self.RecruitList.Header.Count:SetText(RAF_RECRUITED_FRIENDS_COUNT:format(numRecruits, maxRecruits));

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i;
		if index <= numRecruits then
			button.index = index;
			usedHeight = usedHeight + RECRUIT_HEIGHT;
			button:SetupRecruit(recruits[index]);
			button:Show();
		else
			button.recruitInfo = nil;
			button:Hide();
		end
	end

	HybridScrollFrame_Update(self.recruitScrollFrame, totalHeight, usedHeight);
end

function RecruitAFriendFrameMixin:SetNextRewardName(rewardName, count)
	if count > 1 then
		self.RewardClaiming.NextRewardName:SetText(RAF_REWARD_NAME_MULTIPLE:format(rewardName, count));
	else
		self.RewardClaiming.NextRewardName:SetText(rewardName);
	end
	self.RewardClaiming.NextRewardName:Show();
end

function RecruitAFriendFrameMixin:OnUnwrapFlashBegun()
	if self.pendingNextReward then
		self:UpdateNextReward(self.pendingNextReward);
	end
end

local function GetTitleNameFromTitleID(titleID)
	local titleName = GetTitleName(titleID);
	if titleName then
		return strtrim(titleName);
	end
end

function RecruitAFriendFrameMixin:UpdateNextReward(nextReward)
	if self.RewardClaiming.NextRewardButton:WaitingForFlash() then
		-- The next reward button is animating, cache off the next reward and call again when we are done
		self.pendingNextReward = nextReward;
		return;
	else
		self.pendingNextReward = nil;
	end

	if not nextReward then
		self.RewardClaiming.EarnInfo:Hide();
		self.RewardClaiming.NextRewardButton:Hide();
		self.RewardClaiming.NextRewardName:Hide();

		local noUnclaimedReward = false;
		self.RewardClaiming.ClaimOrViewRewardButton:Update(noUnclaimedReward);
		return;
	end

	self.RewardClaiming.ClaimOrViewRewardButton:Update(nextReward.canClaim);

	if nextReward.canClaim then
		self.RewardClaiming.EarnInfo:SetText(RAF_YOU_HAVE_EARNED);
	elseif nextReward.monthCost > 1 then
		self.RewardClaiming.EarnInfo:SetText(RAF_NEXT_REWARD_AFTER:format(nextReward.availableInMonths));
	elseif nextReward.monthsRequired == 0 then
		self.RewardClaiming.EarnInfo:SetText(RAF_FIRST_REWARD);
	else
		self.RewardClaiming.EarnInfo:SetText(RAF_NEXT_REWARD);
	end

	if nextReward.petInfo then
		self:SetNextRewardName(nextReward.petInfo.speciesName, nextReward.repeatableClaimCount);
	elseif nextReward.mountInfo then
		local name = C_MountJournal.GetMountInfoByID(nextReward.mountInfo.mountID);
		self:SetNextRewardName(name, nextReward.repeatableClaimCount);
	elseif nextReward.itemInfo then
		local item = Item:CreateFromItemID(nextReward.itemInfo.itemID);
		item:ContinueOnItemLoad(function()
			self:SetNextRewardName(item:GetItemName(), nextReward.repeatableClaimCount);
		end);
	elseif nextReward.appearanceInfo then
		local item = Item:CreateFromItemID(nextReward.appearanceInfo.itemID);
		item:ContinueOnItemLoad(function()
			self:SetNextRewardName(item:GetItemName(), nextReward.repeatableClaimCount);
		end);
	elseif nextReward.titleInfo then
		local titleName = GetTitleNameFromTitleID(nextReward.titleInfo.titleID);
		if titleName then
			self:SetNextRewardName(RAF_REWARD_TITLE:format(titleName), nextReward.repeatableClaimCount);
		end
	elseif nextReward.appearanceSetInfo then
		self:SetNextRewardName(nextReward.appearanceSetInfo.setName, nextReward.repeatableClaimCount);
	else
		self:SetNextRewardName(RAF_BENEFIT4, nextReward.repeatableClaimCount);
	end

	local rightAlignedTooltip = true;
	self.RewardClaiming.NextRewardButton:Setup(nextReward, rightAlignedTooltip);
	self.RewardClaiming.EarnInfo:Show();
end

local function SortRewards(a, b)
	return a.monthsRequired < b.monthsRequired;
end

function RecruitAFriendFrameMixin:UpdateRAFInfo(rafInfo)
	if rafInfo then
		table.sort(rafInfo.rewards, SortRewards);

		self:UpdateRecruitList(rafInfo.recruits);

		self.RewardClaiming.MonthCount:SetText(RAF_MONTHS_EARNED:format(rafInfo.lifetimeMonths));
		self:UpdateNextReward(rafInfo.nextReward);

		RecruitAFriendRewardsFrame:UpdateRewards(rafInfo.rewards);
		RecruitAFriendRecruitmentFrame:UpdateRecruitmentInfo(rafInfo.recruitmentInfo);

		self.rafInfo = rafInfo;
	end

	self:UpdateRAFTutorialTips();
end

function RecruitAFriendFrameMixin:ShowRewardTutorial()
	return not self:IsShown() and not self.shownRewardTutorial and self.rafInfo and self.rafInfo.nextReward and self.rafInfo.nextReward.canClaim;
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

RecruitListButtonMixin = {};

function RecruitListButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	GameTooltip_SetTitle(GameTooltip, self.recruitInfo.nameText, self.recruitInfo.nameColor);

	local wrap = true;
	GameTooltip_AddNormalLine(GameTooltip, RAF_RECRUIT_TOOLTIP_DESC:format(maxRecruitMonths), wrap);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	local usedMonths = math.max(maxRecruitMonths - self.recruitInfo.monthsRemaining, 0);
	GameTooltip_AddColoredLine(GameTooltip, RAF_RECRUIT_TOOLTIP_MONTH_COUNT:format(usedMonths, maxRecruitMonths), HIGHLIGHT_FONT_COLOR, wrap);
	GameTooltip:Show();
end

function RecruitListButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RecruitListButtonMixin:OnClick(button)
	if button == "RightButton" then
		RecruitAFriendFrame:ShowRecruitDropDown(self);
	end
end

function RecruitListButtonMixin:SetupRecruit(recruitInfo)
	self.recruitInfo = recruitInfo;

	self.Name:SetText(recruitInfo.nameText);
	self.Name:SetTextColor(recruitInfo.nameColor:GetRGB());

	if recruitInfo.subStatus == Enum.RafRecruitSubStatus.Active then
		self.SubStatus:SetText(RAF_ACTIVE_RECRUIT);
		self.SubStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	elseif recruitInfo.subStatus == Enum.RafRecruitSubStatus.Trial then
		self.SubStatus:SetText(RAF_TRIAL_RECRUIT);
		self.SubStatus:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	else
		self.SubStatus:SetText(RAF_INACTIVE_RECRUIT);
		self.SubStatus:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	end

	local mouseOnMe = (GameTooltip:GetOwner() == self);
	if mouseOnMe then
		self:OnEnter();
	end

	self:Show();
end

RecruitAFriendDropDownMixin = {};

function RecruitAFriendDropDownMixin:OnLoad()
	self.isSelf = false;
	self.isMobile = false;
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
		self.guid = accountInfo.playerGuid;
	end

	UnitPopup_ShowMenu(self, "RAF_RECRUIT", nil, recruitInfo.plainName);
end

RecruitAFriendClaimOrViewRewardButtonMixin = {};

function RecruitAFriendClaimOrViewRewardButtonMixin:OnClick()
	if self.haveUnclaimedReward then
		if RecruitAFriendFrame.RewardClaiming.NextRewardButton:IsUnwrapAnimating() then
			return;
		end

		if C_RecruitAFriend.ClaimNextReward() then
			RecruitAFriendFrame.RewardClaiming.NextRewardButton:PlayClaimRewardFanfare();
		end
	else
		if RecruitAFriendRewardsFrame:IsShown() then
			StaticPopupSpecial_Hide(RecruitAFriendRewardsFrame);
		else
			StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
			StaticPopupSpecial_Show(RecruitAFriendRewardsFrame);
		end
	end
end

function RecruitAFriendClaimOrViewRewardButtonMixin:Update(haveUnclaimedReward)
	self.haveUnclaimedReward = haveUnclaimedReward;

	if haveUnclaimedReward then
		self:SetText(CLAIM_REWARD);
		StaticPopupSpecial_Hide(RecruitAFriendRewardsFrame);
	else
		self:SetText(RAF_VIEW_ALL_REWARDS);
	end
end

RecruitAFriendRewardsFrameMixin = {};

function RecruitAFriendRewardsFrameMixin:OnLoad()
	self.rewardPool = CreateFramePool("FRAME", self, "RecruitAFriendRewardTemplate");
end

function RecruitAFriendRewardsFrameMixin:OnShow()
	HideUIPanel(DressUpFrame);
	SetUpSideDressUpFrame(self, 500, 682, "LEFT", "RIGHT", -5, 0);
end

function RecruitAFriendRewardsFrameMixin:OnHide()
	CloseSideDressUpFrame(self);
end

function RecruitAFriendRewardsFrameMixin:UpdateRewards(rewards)
	self.rewardPool:ReleaseAll();

	local lastRewardFrame;
	for index, rewardInfo in ipairs(rewards) do
		if index > 13 then
			return;
		end

		local rewardFrame = self.rewardPool:Acquire();
		if index == 1 then
			rewardFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 90, -110);
		elseif index == 7 then
			rewardFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 285, -110);
		elseif index == 13 then
			rewardFrame:SetPoint("BOTTOM", self, "BOTTOM", 0, 40);
		else
			rewardFrame:SetPoint("TOPLEFT", lastRewardFrame, "BOTTOMLEFT", 0, -15);
		end

		local tooltipRightAligned = (index >= 7 and index <= 12);
		rewardFrame:Setup(rewardInfo, tooltipRightAligned);
		lastRewardFrame = rewardFrame;
	end
end

RecruitAFriendRewardMixin = {};

function RecruitAFriendRewardMixin:Setup(rewardInfo, tooltipRightAligned)
	self.Button:Setup(rewardInfo, tooltipRightAligned);

	if rewardInfo.claimed then
		self.Months:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	elseif rewardInfo.canClaim then
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

function RecruitAFriendRewardButtonMixin:Setup(rewardInfo, tooltipRightAligned)
	self.rewardInfo = rewardInfo;
	self.tooltipRightAligned = tooltipRightAligned;

	self.Icon:SetTexture(rewardInfo.iconID);
	self.Icon:SetDesaturated(not rewardInfo.claimed and not rewardInfo.canClaim);
	self.IconBorder:SetDesaturated(not rewardInfo.claimed and not rewardInfo.canClaim);

	self:SetClaimed(rewardInfo.claimed);
	self:SetCanClaim(rewardInfo.canClaim);

	self.dressupReward = false;
	self.item = nil;
	self.titleName = nil;

	if self.rewardInfo.petInfo then
		self.dressupReward = self.rewardInfo.petInfo.displayID > 0;
	elseif self.rewardInfo.mountInfo then
		self.dressupReward = self.rewardInfo.mountInfo.mountID > 0;
	elseif self.rewardInfo.itemInfo then
		self.item = Item:CreateFromItemID(self.rewardInfo.itemInfo.itemID);
		self.dressupReward = IsDressableItem(self.rewardInfo.itemInfo.itemID);
	elseif self.rewardInfo.appearanceInfo then
		self.item = Item:CreateFromItemID(self.rewardInfo.appearanceInfo.itemID);
		self.dressupReward = IsDressableItem(self.rewardInfo.appearanceInfo.appearanceID);
	elseif self.rewardInfo.titleInfo then
		self.titleName = GetTitleNameFromTitleID(self.rewardInfo.titleInfo.titleID);
	elseif self.rewardInfo.appearanceSetInfo then
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
		elseif self.rewardInfo.itemInfo then
			self.item:ContinueOnItemLoad(function()
				DressUpItemLink(self.item:GetItemLink());
			end);
		elseif self.rewardInfo.appearanceInfo then
			DressUpItemLink(self.rewardInfo.appearanceInfo.appearanceID);
		elseif self.rewardInfo.appearanceSetInfo then
			DressUpTransmogSet(self.rewardInfo.appearanceSetInfo.appearanceIDs)
		end
	end
end

function RecruitAFriendRewardButtonMixin:SetTooltipOwner()
	local anchorPoint, xOffset;
	if self.tooltipRightAligned then
		anchorPoint = "ANCHOR_RIGHT";
		xOffset = 5;
	else
		anchorPoint = "ANCHOR_LEFT";
		xOffset = -5;
	end
	GameTooltip:SetOwner(self, anchorPoint, xOffset, -self:GetHeight());
end

function RecruitAFriendRewardButtonMixin:OnEnter()
	self:SetTooltipOwner();

	local wrap = true;

	if self.rewardInfo.petInfo then
		GameTooltip_SetTitle(GameTooltip, self.rewardInfo.petInfo.speciesName);
		GameTooltip_AddColoredLine(GameTooltip, TOOLTIP_BATTLE_PET, HIGHLIGHT_FONT_COLOR, wrap);
		GameTooltip_AddNormalLine(GameTooltip, self.rewardInfo.petInfo.description, wrap);
		GameTooltip:Show();
	elseif self.rewardInfo.mountInfo then
		GameTooltip:SetSpellByID(self.rewardInfo.mountInfo.spellID);
	elseif self.rewardInfo.itemInfo then
		GameTooltip:SetItemByID(self.rewardInfo.itemInfo.itemID);
	elseif self.rewardInfo.appearanceInfo then
		self.item:ContinueOnItemLoad(function()
			local mouseStillOnMe = (GameTooltip:GetOwner() == self);
			local idsMatch = self.rewardInfo.appearanceInfo and (self.rewardInfo.appearanceInfo.itemID == self.item.itemID);

			if mouseStillOnMe and idsMatch then
				local itemName = self.item:GetItemName();
				local itemQuality = self.item:GetItemQuality();
				if itemName and itemQuality then
					GameTooltip_SetTitle(GameTooltip, itemName, BAG_ITEM_QUALITY_COLOR_OBJECTS[itemQuality]);
					GameTooltip_AddColoredLine(GameTooltip, APPEARANCE_LABEL, HIGHLIGHT_FONT_COLOR, wrap);
					GameTooltip:Show();
				end
			end
		end);
	elseif self.titleName then
		GameTooltip_SetTitle(GameTooltip, RAF_REWARD_TITLE:format(self.titleName));
	elseif self.rewardInfo.appearanceSetInfo then
		GameTooltip_SetTitle(GameTooltip, RAF_REWARD_APPEARANCE_SET:format(self.rewardInfo.appearanceSetInfo.setName), nil, wrap);
	elseif self.rewardInfo.rewardType == Enum.RafRewardType.GameTime then
		GameTooltip_SetTitle(GameTooltip, RAF_BENEFIT4);
	end

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

local RAF_FANFARE_MODEL_SCENE = 253;

RecruitAFriendRewardButtonWithFanfareMixin = CreateFromMixins(RecruitAFriendRewardButtonMixin);

function RecruitAFriendRewardButtonWithFanfareMixin:OnLoad()
	self.ModelScene:EnableMouse(false);
end

function RecruitAFriendRewardButtonWithFanfareMixin:OnClick()
	if IsModifiedClick("DRESSUP") and self.dressupReward then
		if RecruitAFriendRewardsFrame:IsShown() then
			StaticPopupSpecial_Hide(RecruitAFriendRewardsFrame);
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

RecruitAFriendRecruitmentButtonMixin = {};

function RecruitAFriendRecruitmentButtonMixin:OnClick()
	if RecruitAFriendRecruitmentFrame:IsShown() then
		StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	else
		C_RecruitAFriend.RequestUpdatedRecruitmentInfo();
		StaticPopupSpecial_Hide(RecruitAFriendRewardsFrame);
		StaticPopupSpecial_Show(RecruitAFriendRecruitmentFrame);
	end
end

RecruitAFriendRecruitmentFrameMixin = {};

function RecruitAFriendRecruitmentFrameMixin:OnLoad()
	self.EditBox:Disable();
end

local PLAYER_REALM_NAME = GetRealmName();
local _, PLAYER_FACTION_NAME = UnitFactionGroup("player");

function RecruitAFriendRecruitmentFrameMixin:UpdateRecruitmentInfo(recruitmentInfo)
	if recruitmentInfo then
		recruitmentInfo.remainingTimeDays = math.ceil(recruitmentInfo.remainingTimeSeconds / SECONDS_PER_DAY);

		self.Description:SetText(RAF_RECRUITMENT_DESC:format(recruitmentInfo.totalUses, daysInCycle));

		local factionName = PLAYER_FACTION_GROUP[recruitmentInfo.sourceFaction];
		if factionName then
			self.FactionAndRealm:SetText(RAF_RECRUITS_FACTION_AND_REALM:format(factionName, recruitmentInfo.sourceRealm));
			self.FactionAndRealm:Show();
		else
			self.FactionAndRealm:Hide();
		end

		self.EditBox.Instructions:Hide();
		self.EditBox:SetText(recruitmentInfo.recruitmentURL);

		local timesUsed = recruitmentInfo.totalUses - recruitmentInfo.remainingUses;
		self.LinkUses:SetText(RAF_LINK_REMAINING_USES:format(timesUsed, recruitmentInfo.totalUses));
		self.LinkUses:Show();

		if recruitmentInfo.remainingUses > 0 then
			self.LinkUses:SetTextColor(WHITE_FONT_COLOR:GetRGB());
			self.LinkExpires:SetText(RAF_ACTIVE_LINK_DAYS_LEFT:format(recruitmentInfo.remainingTimeDays));
		else
			self.LinkUses:SetTextColor(RED_FONT_COLOR:GetRGB());
			self.LinkExpires:SetText(RAF_EXPENDED_LINK_DAYS_LEFT:format(recruitmentInfo.remainingTimeDays));
		end
		self.LinkExpires:Show();
	else
		self.Description:SetText(RAF_RECRUITMENT_DESC:format(maxRecruitLinkUses, daysInCycle));
		self.FactionAndRealm:SetText(RAF_RECRUITS_FACTION_AND_REALM:format(PLAYER_FACTION_NAME, PLAYER_REALM_NAME));

		self.EditBox.Instructions:SetText(RAF_NO_ACTIVE_LINK:format(daysInCycle));
		self.EditBox.Instructions:Show();
		self.EditBox:SetText("");

		self.LinkUses:Hide();
		self.LinkExpires:Hide();
	end

	self.GenerateOrCopyLinkButton:Update(recruitmentInfo);
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
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:OnEnter()
	if not self:IsEnabled() and not self.waitingForRecruitmentInfo then
		local wrap = true;
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, RAF_COPY_LINK_EXPENDED_TOOLTIP:format(self.recruitmentInfo.remainingTimeDays), RED_FONT_COLOR, wrap);
	end
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function RecruitAFriendGenerateOrCopyLinkButtonMixin:Update(recruitmentInfo)
	self.recruitmentInfo = recruitmentInfo;

	if recruitmentInfo then
		self.waitingForRecruitmentInfo = false;
		self:SetText(RAF_COPY_LINK);
		self:SetEnabled(recruitmentInfo.remainingUses > 0);
	else
		self:SetText(RAF_GENERATE_LINK);
		self:SetEnabled(not self.waitingForRecruitmentInfo);
	end
end

RecruitHelpBoxMixin = {};

function RecruitHelpBoxMixin:OnShow()
	local height = self.Text:GetHeight() + 30;
	if self.OkayButton:IsShown() then
		height = height + 40;
	end
	height = max(height, 55);
	self:SetHeight(height);
end

function RecruitHelpBoxMixin:ShowHelpBox(text, showOKButton)
	self.Text:SetText(text);
	self.OkayButton:SetShown(showOKButton);
	self:Show();
end
