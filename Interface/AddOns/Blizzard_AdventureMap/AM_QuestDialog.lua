--[[ Quest Choice Dialog ]]--
AdventureMapQuestChoiceDialogMixin = {};

QUEST_CHOICE_DIALOG_RESULT_ACCEPTED = 1;
QUEST_CHOICE_DIALOG_RESULT_DECLINED = 2;
QUEST_CHOICE_DIALOG_RESULT_ABSTAIN = 3;

function AdventureMapQuestChoiceDialogMixin:OnLoad()
	self.rewardPool = CreateFramePool("FRAME", self, "AdventureMapQuestRewardTemplate");
end

function AdventureMapQuestChoiceDialogMixin:OnParentHide(parent)
	if parent == self:GetParent() then
		self:DeclineQuest(true);
	end
end

function AdventureMapQuestChoiceDialogMixin:ShowWithQuest(parent, anchorRegion, questID, onClosedCallback, animDelay)
	local newQuest = self.questID ~= questID;
	if self:IsShown() and newQuest then
		-- Already open, cancel the current
		self:DeclineQuest(true);
	end

	self:SetParent(parent);
	self:SetFrameStrata("DIALOG");
	self.questID = questID;
	self.onClosedCallback = onClosedCallback;

	self:ClearAllPoints();
	self.anchorRegion = anchorRegion;
	self:SetPoint("CENTER", anchorRegion);

	if newQuest then
		self.FadeIn:Stop();
		local delayAnim = self.FadeIn:GetAnimations();
		delayAnim:SetDuration(animDelay or .3);
		self.FadeIn:Play();
	end

	self:Show();
end

function AdventureMapQuestChoiceDialogMixin:SetPortraitAtlas(atlas, width, height, xOffset, yOffset)
	local useAtlasSize = width == nil or height == nil;
	self.Portrait:SetAtlas(atlas, useAtlasSize);
	if not useAtlasSize then
		self.Portrait:SetSize(width, height);
	end
	self.Portrait:ClearAllPoints();
	self.Portrait:SetPoint("TOP", self, "TOP", xOffset, yOffset)
end

function AdventureMapQuestChoiceDialogMixin:OnEvent(event, ...)
	if event =="ADVENTURE_MAP_QUEST_UPDATE" then
		local questID = ...;
		if questID == self.questID then
			self:Refresh();
		end
	elseif event == "QUEST_LOG_UPDATE" then
		-- unfortunately have to use generic event to update in case of rewards being loaded async
		self:Refresh();
	end
end

function AdventureMapQuestChoiceDialogMixin:OnShow()
	self:RegisterEvent("ADVENTURE_MAP_QUEST_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:Refresh();
end

function AdventureMapQuestChoiceDialogMixin:OnHide()
	self:UnregisterEvent("ADVENTURE_MAP_QUEST_UPDATE");
	self:UnregisterEvent("QUEST_LOG_UPDATE");

	self:Finalize();
end

function AdventureMapQuestChoiceDialogMixin:Finalize()
	if self.onClosedCallback then
		local result = self.result;
		self.result = nil;
		self.onClosedCallback(result);
		self.onClosedCallback = nil;
	end
	self.questID = nil;
end

function AdventureMapQuestChoiceDialogMixin:Refresh()
	if self.questID then
		self:RefreshRewards();
		self:RefreshDetails();
	end
end

local REWARD_FRAME_WIDTH = 135;
local REWARD_FRAME_HEIGHT = 41;
local REWARD_FRAME_PADDING = 5;
local MAX_REWARD_FRAMES = 6;

function AdventureMapQuestChoiceDialogMixin:RefreshRewards()
	self.rewardPool:ReleaseAll();

	local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(self.questID);
	if artifactXP > 0 then
		local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
		self:AddReward(BreakUpLargeNumbers(artifactXP), icon or "Interface\\Icons\\INV_Misc_QuestionMark", "Interface\\Artifacts\\ArtifactPower-QuestBorder", 0, "NumberFontNormal", ARTIFACT_XP_REWARD);
	end

	local xp = GetQuestLogRewardXP(self.questID);
	if xp > 0 and not IsPlayerAtEffectiveMaxLevel() then
		self:AddReward(BreakUpLargeNumbers(xp), "Interface\\Icons\\XP_Icon", nil, 0, "NumberFontNormal");
	end

	for index, currencyReward in ipairs(C_QuestLog.GetQuestRewardCurrencies(self.questID)) do
		local rewardFrame = self:AddReward(currencyReward.name, currencyReward.texture, nil, currencyReward.totalRewardAmount, "GameFontHighlightSmall");
		local currencyColor = GetColorForCurrencyReward(currencyReward.currencyID, currencyReward.totalRewardAmount);
		rewardFrame.Count:SetTextColor(currencyColor:GetRGB());
	end

	for itemIndex = 1, GetNumQuestLogRewards(self.questID) do
		local name, texture, count, quality, isUsable = GetQuestLogRewardInfo(itemIndex, self.questID);
		self:AddReward(name, texture, nil, count, "GameFontHighlightSmall");
	end

	local money = GetQuestLogRewardMoney(self.questID);
	if money > 0  then
		self:AddReward(GetMoneyString(money), "Interface\\Icons\\inv_misc_coin_01", nil, 0, "GameFontHighlight");
	end

	local numActiveRewardFrames = self.rewardPool:GetNumActive();
	if numActiveRewardFrames == 0 then
		self.Rewards:Hide();
		self.RewardsHeader:Hide();
		self.rewardsHeight = 0;
	else
		self.Rewards:Show();
		self.RewardsHeader:Show();
		local info = C_Texture.GetAtlasInfo("AdventureMapQuest-RewardsPanel");
		local height = info and info.height or 1; -- prevent divide by 0
		self.rewardsHeight = math.min(math.ceil(numActiveRewardFrames / 2) * (REWARD_FRAME_HEIGHT + REWARD_FRAME_PADDING) + 53, height);
		self.Rewards:SetHeight(self.rewardsHeight);
		self.Rewards:SetTexCoord(0, 1, 0, self.rewardsHeight / height);
	end
end

function AdventureMapQuestChoiceDialogMixin:AddReward(label, texture, overlayTexture, count, font, tooltipText)
	local numActiveRewardFrames = self.rewardPool:GetNumActive();
	if numActiveRewardFrames < MAX_REWARD_FRAMES then
		local rewardFrame = self.rewardPool:Acquire();

		local START_X = 5;
		local START_Y = -50;
		local offsetX = START_X + (numActiveRewardFrames % 2) * (REWARD_FRAME_WIDTH + REWARD_FRAME_PADDING);
		local offsetY = START_Y - math.floor(numActiveRewardFrames / 2) * (REWARD_FRAME_HEIGHT + REWARD_FRAME_PADDING);

		rewardFrame:SetPoint("TOPLEFT", self.Rewards, offsetX, offsetY);
		rewardFrame.Name:SetText(label);
		rewardFrame.Name:SetFontObject(font);
		rewardFrame.Icon:SetTexture(texture);
		if overlayTexture then
			rewardFrame.Overlay:SetTexture(overlayTexture);
			rewardFrame.Overlay:Show();
		else
			rewardFrame.Overlay:Hide();
		end
		rewardFrame.Count:SetText(count > 0 and count or nil);
		rewardFrame.Count:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		rewardFrame.tooltipText = tooltipText;

		rewardFrame:Show();
		return rewardFrame;
	end
	return nil;
end

-- There are 2 versions of the frame because the background can't be tiled or stretched too much.
local HEIGHT_SHORT = 380;
local HEIGHT_LONG = 456;				-- used when both rewards and widgets are present
local HEIGHT_UNUSABLE_SPACE = 78;		-- the art includes the border plus empty space above & below
local WIDGET_VERTICAL_ADJUSTMENT = -16;	-- adjustment when calculating widget height
local REWARDS_VERTICAL_ADJUSTMENT = 8;	-- adjustment when calculating rewards height

function AdventureMapQuestChoiceDialogMixin:RefreshDetails()
	local questTitle, descriptionText, objectiveText = C_AdventureMap.GetQuestInfo(self.questID);
	if descriptionText then
		local widgetSetID = C_TaskQuest.GetQuestUIWidgetSetByType(self.questID, Enum.MapIconUIWidgetSetType.AdventureMapDetails);
		if widgetSetID then
			if not self.widgetContainer then
				self.widgetContainer = CreateFrame("FRAME", nil, self, "UIWidgetContainerTemplate");
				self.widgetContainer.verticalAnchorPoint = "TOP";
				self.widgetContainer.verticalRelativePoint = "BOTTOM";
				self.widgetContainer.showAndHideOnWidgetSetRegistration = false;
			end
			self.widgetContainer:RegisterForWidgetSet(widgetSetID);
		elseif self.widgetContainer then
			self.widgetContainer:UnregisterForWidgetSet();
		end

		local frameHeight;
		local hasWidgets = self.widgetContainer and self.widgetContainer.numWidgetsShowing and self.widgetContainer.numWidgetsShowing > 0;
		local hasRewards = self.Rewards:IsShown();
		if hasWidgets and hasRewards then
			frameHeight = HEIGHT_LONG;
			self.widgetContainer:SetPoint("BOTTOM", self.RewardsHeader, "TOP", 0, 12);
			self.Background:SetAtlas("AdventureMapQuest-QuestPane-9sliced", TextureKitConstants.UseAtlasSize);
		else
			frameHeight = HEIGHT_SHORT;
			if hasWidgets then
				self.widgetContainer:SetPoint("BOTTOM", 0, 36);
			end
			self.Background:SetAtlas("AdventureMapQuest-QuestPane", TextureKitConstants.UseAtlasSize);
		end

		self:SetHeight(frameHeight);
		local detailsHeight = frameHeight - HEIGHT_UNUSABLE_SPACE;
		if hasWidgets then
			detailsHeight = detailsHeight - self.widgetContainer:GetHeight() + WIDGET_VERTICAL_ADJUSTMENT;
		end
		if hasRewards then
			detailsHeight = detailsHeight - self.rewardsHeight + REWARDS_VERTICAL_ADJUSTMENT;
		end
		self.Details:SetHeight(detailsHeight);

		self.Details.Child.TitleHeader:SetText(questTitle);
		self.Details.Child.DescriptionText:SetText(descriptionText);
		self.Details.Child.ObjectivesText:SetText(objectiveText);

		local height = 45;
		for i, element in ipairs(self.Details.Child.Elements) do
			height = height + element:GetHeight();
		end
		self.Details.Child:SetHeight(height);

		self.Details:Show();

		local portraitInfo = C_AdventureMap.GetQuestPortraitInfo(self.questID);
		if portraitInfo and portraitInfo.portraitDisplayID ~= 0 then
			QuestFrame_ShowQuestPortrait(self, portraitInfo.portraitDisplayID, portraitInfo.mountPortraitDisplayID, portraitInfo.modelSceneID, portraitInfo.text, portraitInfo.name, -0, -27, true);
			local xOffset = QuestModelScene:GetWidth() / 2;
			self:SetPoint("CENTER", self.anchorRegion, -xOffset , 0);
		else
			QuestFrame_HideQuestPortrait();
			self:SetPoint("CENTER", self.anchorRegion, 0, 0);
		end
	else
		QuestFrame_HideQuestPortrait();
		self.Details:Hide();
	end
end

function AdventureMapQuestChoiceDialogMixin:AcceptQuest()
	C_AdventureMap.StartQuest(self.questID);
	self.result = QUEST_CHOICE_DIALOG_RESULT_ACCEPTED;
	AdventureMapQuestChoiceDialog:Hide();
end

function AdventureMapQuestChoiceDialogMixin:DeclineQuest(abstain)
	if abstain then
		self.result = QUEST_CHOICE_DIALOG_RESULT_ABSTAIN;
	else
		self.result = QUEST_CHOICE_DIALOG_RESULT_DECLINED;
	end
	AdventureMapQuestChoiceDialog:Hide();
end

