GossipTitleButtonMixin = CreateFromMixins(GossipSharedTitleButtonMixin)
function GossipTitleButtonMixin:OnEnter()
	if (self.spellID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show();
	end
end

function GossipTitleButtonMixin:OnLeave()
	GameTooltip:Hide();
end

GossipQuestButtonMixin = CreateFromMixins(GossipSharedQuestButtonMixin);
function GossipQuestButtonMixin:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial)
	GossipSharedQuestButtonMixin.UpdateTitleForQuest(self, questID, titleText, isIgnored, isTrivial);
	self:AddCallbackForQuest(questID, UpdateTitle);
end
function GossipQuestButtonMixin:OnHide()
	self:CancelCallback();
end

function GossipQuestButtonMixin:CancelCallback()
	if self.cancelCallback then
		self.cancelCallback();
		self.cancelCallback = nil;
	end
end

function GossipQuestButtonMixin:AddCallbackForQuest(questID, cb)
	self:CancelCallback();
	self.cancelCallback = QuestEventListener:AddCancelableCallback(questID, cb);
end

GossipAvailableQuestButtonMixin = CreateFromMixins(GossipSharedAvailableQuestButtonMixin);

function GossipAvailableQuestButtonMixin:Setup(questInfo)
	QuestUtil.ApplyQuestIconOfferToTexture(self.Icon, questInfo.isLegendary, questInfo.frequency, questInfo.isRepeatable, QuestUtil.ShouldQuestIconsUseCampaignAppearance(questInfo.questID), C_QuestLog.IsQuestCalling(questInfo.questID))
	GossipSharedAvailableQuestButtonMixin.Setup(self, questInfo);
end

GossipActiveQuestButtonMixin = CreateFromMixins(GossipSharedActiveQuestButtonMixin);
function GossipActiveQuestButtonMixin:Setup(questInfo)
	QuestUtil.ApplyQuestIconActiveToTexture(self.Icon, questInfo.isComplete, questInfo.isLegendary, nil, nil, QuestUtil.ShouldQuestIconsUseCampaignAppearance(questInfo.questID), C_QuestLog.IsQuestCalling(questInfo.questID));
	GossipSharedActiveQuestButtonMixin.Setup(self, questInfo);
end

GossipGreetingTextMixin = { }
function GossipGreetingTextMixin:Setup(text)
	self.GreetingText:SetText(text);
	self:Show();
	self:SetSize(270, self.GreetingText:GetHeight());
end

GossipFrameMixin = CreateFromMixins(GossipFrameSharedMixin);
function GossipFrameMixin:OnLoad()
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:UpdateScrollBox();
	self:SetTitleColor(HIGHLIGHT_FONT_COLOR);
end

function GossipFrameMixin:HandleShow(textureKit)
	GossipFrameSharedMixin.HandleShow(self);
	self.Background:SetAtlas(self:GetBackgroundTexture(textureKit), TextureKitConstants.UseAtlasSize);
	self.FriendshipStatusBar:Update();
	self:Update();
end

local backgroundTextureKit = "QuestBG-%s";
function GossipFrameMixin:GetBackgroundTexture(textureKit)
	if (textureKit) then
		local backgroundAtlas = GetFinalNameFromTextureKit(backgroundTextureKit, textureKit);
		local atlasInfo = C_Texture.GetAtlasInfo(backgroundAtlas);
		if(atlasInfo) then
			return backgroundAtlas;
		end
	end
	return QuestUtil.GetDefaultQuestBackgroundTexture();
end

function GossipFrameMixin:OnEvent(event, ...)
	if ( event == "QUEST_LOG_UPDATE" and GossipFrame.hasActiveQuests ) then
		self:Update();
	end
end

function GossipFrameMixin:SetGossipTutorialMode(tutorialMode)
	self.tutorialMode = tutorialMode;
	self.tutorialButtons = { };
	self.GreetingPanel.GoodbyeButton:SetShown(not tutorialMode);
end

function GossipFrameMixin:GetTutorialButtons()
	return self.tutorialButtons;
end

function GossipFrameMixin:SortOrder(leftInfo, rightInfo)
	return leftInfo.orderIndex < rightInfo.orderIndex;
end