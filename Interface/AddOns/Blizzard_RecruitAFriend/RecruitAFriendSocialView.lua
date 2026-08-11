
RecruitListButtonSocialMixin = CreateFromMixins(RecruitListButtonMixin);

function RecruitListButtonSocialMixin:SetupRecruit(recruitInfo)
	RecruitListButtonMixin.SetupRecruit(self, recruitInfo);

	self:UpdateCardTextColors(recruitInfo);

	self:InitializePresenceDisplay(recruitInfo);
	self:LayoutScaledContent();
end

-- The Social UI uses a different set of colors for most of the text on the recruit card (compared to the base)
function RecruitListButtonSocialMixin:UpdateCardTextColors(recruitInfo)
	local characterName = recruitInfo.characterName or "";

	if recruitInfo.isOnline then
		self.Name:SetText(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(recruitInfo.plainName));
		self.CharacterName:SetText(NORMAL_FONT_COLOR:WrapTextInColorCode(characterName));
		-- The InfoText color is set per-status by the base SetupRecruit.
	else
		self.Name:SetText(DARKGRAY_COLOR:WrapTextInColorCode(recruitInfo.plainName));
		self.CharacterName:SetText(DARKGRAY_COLOR:WrapTextInColorCode(characterName));
		self.InfoText:SetTextColor(DARKGRAY_COLOR:GetRGB());
	end
end

function RecruitListButtonSocialMixin:InitializePresenceDisplay(recruitInfo)
	local presenceType = SocialUIUtil.GetPresenceTypeForBattleNetAccountInfo(recruitInfo.accountInfo);
	self.PresenceHolder:SetPresence(presenceType);
end

-- We attempt to keep the anchoring of elements visually consistent as they get bigger due to font scaling
function RecruitListButtonSocialMixin:LayoutScaledContent()
	self:LayoutScaledPresenceHolderAnchors();
	self:LayoutScaledTextHolderAnchors();
	self:LayoutCardDisplayText();
end

function RecruitListButtonSocialMixin:LayoutScaledPresenceHolderAnchors()
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledPresenceHolderXOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderXOffset, scaleWeightSource);
	local scaledPresenceHolderYOffset = TextSizeManager:GetScaledValueWeighted(self.presenceHolderYOffset, scaleWeightSource);

	presenceHolder:ClearAllPoints();
	presenceHolder:SetPoint("CENTER", self, "TOPLEFT", scaledPresenceHolderXOffset, scaledPresenceHolderYOffset);
end

function RecruitListButtonSocialMixin:LayoutScaledTextHolderAnchors()
	local textHolder = self.TextHolder;
	local presenceHolder = self.PresenceHolder;

	local scaleWeightSource = presenceHolder;
	local scaledTextHolderTopLeftXOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftXOffset, scaleWeightSource);
	local scaledTextHolderTopLeftYOffset = TextSizeManager:GetScaledValueWeighted(self.textHolderTopLeftYOffset, scaleWeightSource);

	textHolder:ClearAllPoints();
	textHolder:SetPoint("TOPLEFT", presenceHolder, "BOTTOMRIGHT", scaledTextHolderTopLeftXOffset, scaledTextHolderTopLeftYOffset);
	textHolder:SetPoint("RIGHT", self:GetBestRightAnchorForTextHolder(), "LEFT", self.textHolderRightXOffset, 0);
	textHolder:SetPoint("BOTTOM", self, "BOTTOM", 0, self.textHolderBottomYOffset);
end

-- The activity chests live on the right side of the card, so the text stops at the innermost one and truncates.
function RecruitListButtonSocialMixin:GetBestRightAnchorForTextHolder()
	return self.Activities[1];
end

function RecruitListButtonSocialMixin:LayoutCardDisplayText()
	local scaledLineSpacing = TextSizeManager:GetScaledValue(self.lineSpacing);

	self.Name:ClearAllPoints();
	self.Name:SetPoint("TOPLEFT", self.TextHolder);
	self.Name:SetPoint("RIGHT", self.TextHolder);

	-- The character name is the middle line and isn't always present. 
	-- If it's missing we'll reanchor the infoText to make it the second line instead
	local hasCharacterName = self:HasCharacterName();
	self.CharacterName:SetShown(hasCharacterName);

	local lineAboveInfoText = self.Name;
	if hasCharacterName then
		self.CharacterName:ClearAllPoints();
		self.CharacterName:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -scaledLineSpacing);
		self.CharacterName:SetPoint("RIGHT", self.TextHolder);
		lineAboveInfoText = self.CharacterName;
	end

	self.InfoText:ClearAllPoints();
	self.InfoText:SetPoint("TOPLEFT", lineAboveInfoText, "BOTTOMLEFT", 0, -scaledLineSpacing);
	self.InfoText:SetPoint("RIGHT", self.TextHolder);
end

function RecruitListButtonSocialMixin:UpdateBackground(recruitInfo, _versionRecruited)
	local backgroundAtlas = recruitInfo.isOnline and "friends-card-default" or "friends-card-disabled";
	self.Background:SetAtlas(backgroundAtlas, TextureKitConstants.IgnoreAtlasSize);
end

function RecruitListButtonSocialMixin:HasCharacterName()
	local recruitInfo = self.recruitInfo;
	return recruitInfo ~= nil and recruitInfo.characterName ~= nil;
end

-- We don't use a divider in the Social UI, so this is a no-op to prevent the base logic from attempting to set one up
-- RecruitAFriendFrameSocialViewMixin:ShouldInsertOnlineOfflineDividerForRecruits should prevent one from making it into the data provider
function RecruitListButtonSocialMixin:MakeDivider(_isDivider)
end

RecruitAFriendFrameSocialViewMixin = CreateFromMixins(RecruitAFriendFrameMixin, SocialUIScrollableElementExtentPreviewerMixin);

function RecruitAFriendFrameSocialViewMixin:OnLoad()
	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);
	self:RegisterScrollableTemplatesForExtentPreview({ self.scrollContentsTemplate });

	RecruitAFriendFrameMixin.OnLoad(self);

	self:InitializeRecruitHeader();
	self:InitializeTopDividerAnchoring();
	self:InitializeActionButton();
	self:InitializeClaimOrViewRewardButton();
	self:InitializeNoRecruitsScrollBox();
end

function RecruitAFriendFrameSocialViewMixin:InitializeRecruitHeader()
	-- Reset the width so it grows exactly to the size of the text
	-- The "Count" font string is anchored to the right of the header and we want it to be right next to the header text
	self.Header:SetWidth(0);
	self.Header:SetText(RAF_RECRUITED_FRIENDS);
end

-- We're inheriting from SocialUIContactsFrameTemplate which comes with a filter bar
-- We need to hide it, and then reanchor the top divider to our header instead
function RecruitAFriendFrameSocialViewMixin:InitializeTopDividerAnchoring()
	self:SetFilterBarShown(false);

	self.TopDivider:SetWidth(self.BottomDivider:GetWidth());
	self:AnchorTopDividerBelowHeader();
end

function RecruitAFriendFrameSocialViewMixin:AnchorTopDividerBelowHeader()
	self.TopDivider:ClearAllPoints();
	self.TopDivider:SetPoint("TOP", self.Header, "BOTTOM", 0, -5);
	self.TopDivider:SetPoint("LEFT", self, "LEFT", 5, 0);
end

-- For the case where the friends system is disabled
-- We basically show a blank screen so we anchor to the top
function RecruitAFriendFrameSocialViewMixin:AnchorTopDividerToTop()
	self.TopDivider:ClearAllPoints();
	self.TopDivider:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -15);
	self.TopDivider:SetPoint("TOPRIGHT", self, "TOPRIGHT", -5, -15);
end

function RecruitAFriendFrameSocialViewMixin:InitializeActionButton()
	Mixin(self.ActionButton, RecruitAFriendSocialViewActionButtonMixin);
	self.ActionButton:SetText(RAF_RECRUITMENT);
end

function RecruitAFriendFrameSocialViewMixin:InitializeClaimOrViewRewardButton()
	self.RewardClaiming.ClaimOrViewRewardButton:SetText(RAF_VIEW_ALL_REWARDS);
end

function RecruitAFriendFrameSocialViewMixin:InitializeNoRecruitsScrollBox()
	local view = CreateScrollBoxLinearView();
	ScrollUtil.InitScrollBoxWithScrollBar(self.NoRecruitsScrollBox, self.NoRecruitsScrollBar, view);
end

function RecruitAFriendFrameSocialViewMixin:OnHide()
	RecruitAFriendFrameMixin.OnHide(self);

	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function RecruitAFriendFrameSocialViewMixin:OnShow()
	RecruitAFriendFrameMixin.OnShow(self);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnTextScaleUpdated, self);
end

function RecruitAFriendFrameSocialViewMixin:OnTextScaleUpdated()
	self:ClearTemplateExtentCache();

	-- We need to refresh our scrollable contents to account for the text scale change
	local rafInfo = self:GetRAFInfo();
	if rafInfo then
		self:UpdateRecruitList(rafInfo.recruits);
	end

	self:SetNoRecruitsText(RAF_NO_RECRUITS_DESC);
end

function RecruitAFriendFrameSocialViewMixin:GetScrollBoxPadding()
	local topPadding, bottomPadding, leftPadding, rightPadding = 13, 15, 10, 6;
	local elementSpacing = 2;
	return topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing;
end

function RecruitAFriendFrameSocialViewMixin:GetRecruitScrollBox()
	return self.ScrollBox;
end

function RecruitAFriendFrameSocialViewMixin:GetRecruitScrollBar()
	return self.ScrollBar;
end

function RecruitAFriendFrameSocialViewMixin:GetRecruitCountFontString()
	return self.Count;
end

function RecruitAFriendFrameSocialViewMixin:GetRecruitmentButton()
	return self.ActionButton;
end

-- We don't use a divider in the Social UI, so this prevents one from being inserted into the data provider
function RecruitAFriendFrameSocialViewMixin:ShouldInsertOnlineOfflineDividerForRecruits()
	return false;
end

function RecruitAFriendFrameSocialViewMixin:ScrollElementExtentCalculator(_dataIndex, _elementData)
	return self:GetTemplateExtent(self.scrollContentsTemplate);
end

-- At any given time we should only be showing either the recruit list or the "no recruit" scrollable text
function RecruitAFriendFrameSocialViewMixin:HideShowContents(anyRecruits)
	self.ScrollBox:SetShown(anyRecruits);
	self.ScrollBar:SetShown(anyRecruits);
	self.NoRecruitsScrollBox:SetShown(not anyRecruits);
	self.NoRecruitsScrollBar:SetShown(not anyRecruits);
end

function RecruitAFriendFrameSocialViewMixin:HasRecruits()
	local rafInfo = self:GetRAFInfo();
	return rafInfo ~= nil and rafInfo.recruits ~= nil and #rafInfo.recruits > 0;
end

function RecruitAFriendFrameSocialViewMixin:SetNoRecruitsText(text)
	self.NoRecruitsScrollBox.NoRecruitsDesc:SetText(text);
end

RecruitAFriendSocialViewActionButtonMixin = CreateFromMixins(SocialUIActionButtonMixin);

function RecruitAFriendSocialViewActionButtonMixin:IsActionEnabled()
	local isFriendsEnabled = not C_SocialRestrictions.IsFriendsDisabled();
	return isFriendsEnabled;
end

function RecruitAFriendSocialViewActionButtonMixin:ShowDisabledTooltip()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddErrorLine(tooltip, RECRUITING_FRIENDS_DISABLED);
	tooltip:Show();
end

function RecruitAFriendSocialViewActionButtonMixin:PerformClickAction()
	if RecruitAFriendRecruitmentFrame:IsShown() then
		StaticPopupSpecial_Hide(RecruitAFriendRecruitmentFrame);
	else
		C_RecruitAFriend.RequestUpdatedRecruitmentInfo();
		RecruitAFriendRewardsFrame:Hide();
		StaticPopupSpecial_Show(RecruitAFriendRecruitmentFrame);
	end
end

RecruitAFriendSocialViewClaimOrViewRewardButtonMixin = CreateFromMixins(RecruitAFriendClaimOrViewRewardButtonMixin);

function RecruitAFriendSocialViewClaimOrViewRewardButtonMixin:OnLoad()
	UserScaledButtonFitToTextMixin.OnLoad(self);
	RecruitAFriendClaimOrViewRewardButtonMixin.OnLoad(self);
end

function RecruitAFriendSocialViewClaimOrViewRewardButtonMixin:OnEnter()
	-- The base mixin has logic for when you're claiming rewards and the button is disabled
	-- We'll use that if the button is disabled, otherwise we'll use the SocialUIActionButtonMixin tooltip logic
	if not self:IsEnabled() then
		RecruitAFriendClaimRewardButtonBaseMixin.OnEnter(self);
		return;
	end

	SocialUIActionButtonMixin.OnEnter(self);
end

-- We attempt to keep the anchoring of elements visually consistent as they get bigger due to font scaling
function RecruitAFriendSocialViewClaimOrViewRewardButtonMixin:OnTextScaleUpdated(scale, registrationInfo)
	UserScaledButtonFitToTextMixin.OnTextScaleUpdated(self, scale, registrationInfo);

	self:LayoutScaledButtonAnchors(registrationInfo);
	self:LayoutScaledClaimGlow(scale, registrationInfo);
end

-- We reanchor the button so it visually has the same spacing regardless of font size
function RecruitAFriendSocialViewClaimOrViewRewardButtonMixin:LayoutScaledButtonAnchors(registrationInfo)
	local scaledBottomYOffset = TextSizeManager:GetScaledValueWeighted(self.bottomAnchorYOffset, registrationInfo);
	self:ClearAllPoints();
	self:SetPoint("BOTTOM", 0, scaledBottomYOffset);
end

-- The yellow "claim" glow was made for the old style red button art
-- The newer red button is a bit larger/thicker, so we need to make some adjustments to the scale and anchoring to have it properly fit
local CLAIM_REWARD_GLOW_BASE_SCALE = 1.4;
local CLAIM_REWARD_GLOW_BASE_EDGE_OVERHANG = 17;
function RecruitAFriendSocialViewClaimOrViewRewardButtonMixin:LayoutScaledClaimGlow(scale, registrationInfo)
	local weightedScale = self:GetWeightedScale("width", scale, registrationInfo);

	-- To fit the new button art at default size we want scale CLAIM_REWARD_GLOW_BASE_SCALE, and then that needs to take the weighted scale into account
	local glowScale = CLAIM_REWARD_GLOW_BASE_SCALE * weightedScale;
	self.YellowGlow.Left:SetScale(glowScale);
	self.YellowGlow.Right:SetScale(glowScale);

	local edgeOverhang = CLAIM_REWARD_GLOW_BASE_EDGE_OVERHANG * weightedScale;
	self.YellowGlow:SetPoint("LEFT", self, "LEFT", -edgeOverhang, 0);
	self.YellowGlow:SetPoint("RIGHT", self, "RIGHT", edgeOverhang, 0);
end

function RecruitAFriendFrameSocialViewInitializeAADC(tabData)
	local frame = tabData.contentFrame;
	local isFriendsEnabled = not C_SocialRestrictions.IsFriendsDisabled();

	frame.RewardClaiming:SetShown(isFriendsEnabled);
	frame.Header:SetShown(isFriendsEnabled);
	frame.Count:SetShown(isFriendsEnabled);
	frame.FriendsDisabledText:SetShown(not isFriendsEnabled);

	if isFriendsEnabled then
		frame:AnchorTopDividerBelowHeader();
		-- Show only the recruit list or the empty-state scrollbox, never both.
		frame:HideShowContents(frame:HasRecruits());
	else
		frame:AnchorTopDividerToTop();
		frame.FriendsDisabledText:SetText(SOCIAL_TAB_UNAVAILABLE:format(tabData.tabName));
		frame.ScrollBox:Hide();
		frame.ScrollBar:Hide();
		frame.NoRecruitsScrollBox:Hide();
		frame.NoRecruitsScrollBar:Hide();
	end

	frame.ActionButton:RefreshEnabledState();
end
