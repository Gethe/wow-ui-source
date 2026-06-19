
RecruitListButtonSocialMixin = CreateFromMixins(RecruitListButtonMixin) --building off the existing one.

local TOP_BOTTOM_RECRUIT_PADDING = 4;

local function GetRecruitHeight()
	local normalHeight = GetFontInfo(UserScaledFontGameNormal).height;
	local smallHeight = GetFontInfo(UserScaledFontGameNormalSmall).height;

	local betweenPadding = 4;
	return normalHeight + smallHeight * 2 + TOP_BOTTOM_RECRUIT_PADDING * 2 + betweenPadding * 2, normalHeight, smallHeight;
end

local DIVIDER_HEIGHT = 16;

function RecruitListButtonSocialMixin:SetupRecruit(recruitInfo)
	RecruitListButtonMixin.SetupRecruit(self, recruitInfo);
	--do a normal setup, but then custom logic for resizing the frame.

	local totalHeight, normalHeight, smallHeight = GetRecruitHeight();

	local extraPadding = 0;
	if recruitInfo.characterName then
		self.CharacterName:SetText(recruitInfo.characterName);
	else
		self.CharacterName:SetText("");
		extraPadding =  smallHeight/2 - 2;
	end

	self.Name:SetPoint("TOPLEFT", 15, -TOP_BOTTOM_RECRUIT_PADDING - normalHeight/2 - extraPadding);
	self.InfoText:SetPoint("BOTTOMLEFT", 15, TOP_BOTTOM_RECRUIT_PADDING + smallHeight/2 + extraPadding);

	self:SetHeight(totalHeight);

	--and a new icon for friends status
	local accountInfo = recruitInfo.accountInfo;
	local statusAtlas = "friends-status-offline";
	if accountInfo then
		if accountInfo.isAFK then
			statusAtlas = "friends-status-away";
		elseif accountInfo.isDND then
			statusAtlas = "friends-status-busy";
		elseif accountInfo.gameAccountInfo.isOnline then
			statusAtlas = "friends-status-online";
		end
	end
	self.FriendsStatus:SetAtlas(statusAtlas);
	
	--we're using the plainname
	self.Name:SetText(recruitInfo.plainName);
end

function RecruitListButtonSocialMixin:MakeDivider(isDivider)
	RecruitListButtonMixin.MakeDivider(self, isDivider);

	self.FriendsStatus:SetShown(not isDivider);
	self.CharacterName:SetShown(not isDivider);
end

RecruitAFriendFrameSocialMixin = CreateFromMixins(RecruitAFriendFrameMixin) --building off the existing one.


function RecruitAFriendFrameSocialMixin:UpdateScrollBox()
	self.RecruitList.ScrollBox:Rebuild(ScrollBoxConstants.RetainScrollPosition);
	self.RecruitList.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);

	--have to reset the text so it recalculates the height.
	self:SetNoRecruitsText(RAF_NO_RECRUITS_DESC);
	self.RecruitList.NoRecruitsScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately);
end

function RecruitAFriendFrameSocialMixin:OnLoad()
	RecruitAFriendFrameMixin.OnLoad(self);
	local view = CreateScrollBoxLinearView();
	ScrollUtil.InitScrollBoxWithScrollBar(self.RecruitList.NoRecruitsScrollBox, self.RecruitList.NoRecruitsScrollBar, view);
end

function RecruitAFriendFrameSocialMixin:OnHide()
	RecruitAFriendFrameMixin.OnHide(self);

	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function RecruitAFriendFrameSocialMixin:OnShow()
	RecruitAFriendFrameMixin.OnShow(self);

	self:UpdateScrollBox();
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.UpdateScrollBox, self);
end

function RecruitAFriendFrameSocialMixin:ScrollElementExtentCalculator(dataIndex, elementData)
	local recruitHeight = GetRecruitHeight();
	return elementData.isDivider and DIVIDER_HEIGHT or recruitHeight;
end

function RecruitAFriendFrameSocialMixin:HideShowContents(anyRecruits)
	self.RecruitList.NoRecruitsScrollBox:SetShown(not anyRecruits);
	self.RecruitList.NoRecruitsScrollBar:SetShown(not anyRecruits);
	self.RecruitList.ScrollBar:SetShown(anyRecruits);
end

function RecruitAFriendFrameSocialMixin:SetNoRecruitsText(text)
	self.RecruitList.NoRecruitsScrollBox.NoRecruitsDesc:SetText(text);
end

function RecruitAFriendFrameSocialInitializeAADC(tabData)
	local frame = tabData.contentFrame;
	if C_SocialRestrictions.IsFriendsDisabled() then
		frame.RewardClaiming:Hide();
		frame.RecruitList:Hide();
		frame.FriendsDisabledText:SetText(SOCIAL_TAB_UNAVAILABLE:format(tabData.tabName));
		frame.FriendsDisabledText:Show();

		frame.RecruitmentButton:SetEnabled(false);
		frame.RecruitmentButton.disableTooltip = RECRUITING_FRIENDS_DISABLED;
	else
		frame.RewardClaiming:Show();
		frame.RecruitList:Show();
		frame.FriendsDisabledText:Hide();
		frame.RecruitmentButton:SetEnabled(true);
		frame.RecruitmentButton.disableTooltip = nil;
	end
end



