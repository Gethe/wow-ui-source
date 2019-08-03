QuestIndicatorBaseMixin = {};

function QuestIndicatorBaseMixin:SetIndicatorEnabled(enabled)
	self.enabled = enabled;

	local atlas = self:GetAtlas();
	self.Icon:SetAtlas(atlas);
	self.IconHighlight:SetAtlas(atlas);

	self:UpdateTooltipForEnabledState();
end

function QuestIndicatorBaseMixin:SetIndicatorAtlas(atlas)
	self.indicatorAtlas = atlas;
end

function QuestIndicatorBaseMixin:SetIndicatorDisabledAtlas(atlas)
	self.indicatorDisabledAtlas = atlas;
end

function QuestIndicatorBaseMixin:GetAtlas()
	return self.enabled and self.indicatorAtlas or self.indicatorDisabledAtlas;
end

function QuestIndicatorBaseMixin:IsIndicatorEnabled()
	return self.enabled;
end

function QuestIndicatorBaseMixin:UpdateTooltipForEnabledState()
	if GameTooltip:GetOwner() == self then
		self:ShowTooltip();
	end
end

function QuestIndicatorBaseMixin:OnEnter()
	self.IconHighlight:Show();
	self:ShowTooltip();
end

function QuestIndicatorBaseMixin:OnLeave()
	self.IconHighlight:Hide();
	GameTooltip:Hide();
end

function QuestIndicatorBaseMixin:ShowTooltip()
	GameTooltip:Hide();
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	self:SetupTooltip();
end

QuestReplayIndicatorMixin = {};

function QuestReplayIndicatorMixin:SetQuest(questID)
	self:SetIndicatorEnabled(C_QuestLog.IsQuestReplayable(questID))
end

function QuestReplayIndicatorMixin:SetupTooltip()
	local title = QUEST_SESSION_REPLAY_TOOLTIP_TITLE_DISABLED;
	local body = QUEST_SESSION_REPLAY_TOOLTIP_BODY_DISABLED;

	if self:IsIndicatorEnabled() then
		title = QUEST_SESSION_REPLAY_TOOLTIP_TITLE_ENABLED;
		body = QUEST_SESSION_REPLAY_TOOLTIP_BODY_ENABLED;
	end

	GameTooltip_SetTitle(GameTooltip, title);
	GameTooltip_AddNormalLine(GameTooltip, body);
	GameTooltip:Show();
end

QuestSessionBonusRewardsMixin = {};

function QuestSessionBonusRewardsMixin:OnLeave()
	QuestIndicatorBaseMixin.OnLeave(self);
	self:CancelCallbacks();
end

function QuestSessionBonusRewardsMixin:OnHide()
	self:CancelCallbacks();
end

function QuestSessionBonusRewardsMixin:SetQuest(questID)
	local function UpdateStatus()
		self:SetIndicatorEnabled(QuestUtils_DoesQuestSessionQuestQualifyForBonusRewardBox(questID));
	end

	self:AddQuestCallback(questID, UpdateStatus);
end

function QuestSessionBonusRewardsMixin:SetupTooltip()
	if self:IsIndicatorEnabled() then
		self:ShowBonusTooltip();
	else
		self:ShowDisabledTooltip();
	end
end

function QuestSessionBonusRewardsMixin:ShowBonusTooltip()
	local QUEST_SESSION_BONUS_REWARD_ITEM_ID = 171305;

	local function UpdateItemTooltip()
		GameTooltip_SetTitle(GameTooltip, QUEST_SESSION_BONUS_LOOT_TOOLTIP_TITLE_ENABLED);
		GameTooltip_AddNormalLine(GameTooltip, QUEST_SESSION_BONUS_LOOT_TOOLTIP_BODY_ENABLED);
		GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1);
		GameTooltip_AddNormalLine(GameTooltip, QUEST_REWARDS);
		EmbeddedItemTooltip_SetItemByID(GameTooltip.ItemTooltip, QUEST_SESSION_BONUS_REWARD_ITEM_ID);
		GameTooltip:Show();
	end

	self:AddItemCallback(QUEST_SESSION_BONUS_REWARD_ITEM_ID, UpdateItemTooltip);
end

function QuestSessionBonusRewardsMixin:ShowDisabledTooltip()
	GameTooltip_SetTitle(GameTooltip, QUEST_SESSION_BONUS_LOOT_TOOLTIP_TITLE_DISABLED);
	GameTooltip_AddNormalLine(GameTooltip, QUEST_SESSION_BONUS_LOOT_TOOLTIP_BODY_DISABLED);
	GameTooltip:Show();
end

function QuestSessionBonusRewardsMixin:AddItemCallback(id, cb)
	self:CancelItemCallback();
	self.cancelItemCallback = ItemEventListener:AddCancelableCallback(id, cb);
end

function QuestSessionBonusRewardsMixin:CancelItemCallback()
	if self.cancelItemCallback then
		self.cancelItemCallback();
		self.cancelItemCallback = nil;
	end
end

function QuestSessionBonusRewardsMixin:AddQuestCallback(id, cb)
	self:CancelItemCallback();
	self.cancelItemCallback = QuestEventListener:AddCancelableCallback(id, cb);
end

function QuestSessionBonusRewardsMixin:CancelQuestCallback()
	if self.cancelQuestCallback then
		self.cancelQuestCallback();
		self.cancelQuestCallback = nil;
	end
end

function QuestSessionBonusRewardsMixin:CancelCallbacks()
	self:CancelItemCallback();
	self:CancelQuestCallback();
end

QuestIndicatorsMixin = {};

function QuestIndicatorsMixin:OnLoad()
	ResizeLayoutMixin.OnLoad(self);

	self.Inset:SetAtlas(self.inset or "QuestSharing-QuestLog-Details-ModifiersBG", true);

	self.BonusIndicator:SetIndicatorAtlas("QuestSharing-QuestLog-Loot");
	self.BonusIndicator:SetIndicatorDisabledAtlas(self.indicatorOffBonus or "QuestSharing-QuestLog-Details-ModifiersLootIconOff");

	self.ReplayIndicator:SetIndicatorAtlas("QuestSharing-ReplayIconOn");
	self.ReplayIndicator:SetIndicatorDisabledAtlas(self.indicatorOffReplay or "QuestSharing-QuestLog-Details-ModifiersReplayIconOff");
end

function QuestIndicatorsMixin:Layout()
	self:UpdateIndicatorAnchoring();
	ResizeLayoutMixin.Layout(self);
end

function QuestIndicatorsMixin:SetQuest(questID)
	for index, indicator in pairs(self.Indicators) do
		indicator:SetQuest(questID);
	end
end

function QuestIndicatorsMixin:UpdateIndicatorAnchoring()
	local previousFrame;
	for index, indicator in pairs(self.Indicators) do
		if indicator:IsVisible() then
			indicator:ClearAllPoints();

			if previousFrame then
				indicator:SetPoint("LEFT", previousFrame, "RIGHT", 0, 0);
			else
				indicator:SetPoint("LEFT", self, "LEFT", self.initialOffsetX or 10, self.initialOffsetY or 0);
			end

			previousFrame = indicator;
		end
	end
end