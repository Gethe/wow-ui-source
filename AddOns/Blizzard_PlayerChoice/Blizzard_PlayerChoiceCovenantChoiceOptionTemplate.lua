PlayerChoiceCovenantChoiceOptionTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin);

function PlayerChoiceCovenantChoiceOptionTemplateMixin:OnLoad()
	self.WidgetContainer:Hide();

	self.OptionText:SetPoint("TOP", self, "TOP", 0, -165);
	self.OptionText:SetFontObject(QuestFont_Super_Huge);
	self.OptionText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA());
	self.OptionText:SetJustifyH("CENTER");

	self.OptionButtonsContainer:SetPoint("TOP", self.OptionText, "BOTTOM", 0, -10);
	self.OptionButtonsContainer.buttonTemplate = "PlayerChoiceSmallerOptionButtonTemplate";
end

-- We don't need a filler frame, Covenant Choice options are always the same size
function PlayerChoiceCovenantChoiceOptionTemplateMixin:GetFillerFrame()
	return nil;
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:Reset()
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:Layout()
	self.OptionButtonsContainer:Layout();
	self.OptionButtonsContainer:Hide();
end

local textureKitRegions = {
	Background = "UI-Frame-%s-CardParchment",
	ScrollingBG = "UI-Frame-%s-ScrollingBG",
};

function PlayerChoiceCovenantChoiceOptionTemplateMixin:SetupFrame()
	self:SetupTextureKitOnRegions(self, textureKitRegions);
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:SetupButtons()
	-- Grab the last button and remove it. That will be the preview covenant button and we want to handle it separately
	local previewButtonInfo = table.remove(self.optionInfo.buttons);
	self.PreviewButton:Setup(previewButtonInfo, self.optionInfo);

	self.OptionButtonsContainer:Setup(self.optionInfo);
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:OnUpdate()
	local mouseOver = RegionUtil.IsDescendantOfOrSame(GetMouseFocus(), self);
	if not mouseOver then
		self:OnLeave();
	end
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:OnEnter()
	self.Background:Hide();
	self.BlackBackground:Show();
	self.ScrollingBackgroundAnim:Restart();
	self.BackgroundShadowSmall:Hide();
	self.BackgroundShadowLarge:Show();
	self.OptionButtonsContainer:Show();
	self.PreviewButton:Show();

	self.oldFrameLevel = self:GetFrameLevel();
	self:SetFrameLevel(550);

	self:SetHitRectInsets(-25, -25, -43, -43);

	PlaySound(SOUNDKIT.UI_COVENANT_CHOICE_MOUSE_OVER_COVENANT);

	self:SetScript("OnEnter", nil);
	self:SetScript("OnUpdate", self.OnUpdate);
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:OnLeave()
	self.Background:Show();
	self.BlackBackground:Hide();
	self.ScrollingBackgroundAnim:Stop();
	self.ScrollingBG:SetAlpha(0);
	self.BackgroundShadowSmall:Show();
	self.BackgroundShadowLarge:Hide();
	self.OptionButtonsContainer:Hide();
	self.PreviewButton:Hide();

	self:SetFrameLevel(self.oldFrameLevel);
	self.oldFrameLevel = nil;

	self:SetHitRectInsets(0, 0, 0, 0);

	self:SetScript("OnUpdate", nil);
	self:SetScript("OnEnter", self.OnEnter);
end

function PlayerChoiceCovenantChoiceOptionTemplateMixin:OnSelected()
	PlaySound(SOUNDKIT.UI_COVENANT_CHOICE_CONFIRM_COVENANT);
	PlayerChoiceFrame:OnSelectionMade();
end

PlayerChoiceCovenantChoicePreviewButtonMixin = CreateFromMixins(PlayerChoiceBaseOptionButtonTemplateMixin);

function PlayerChoiceCovenantChoicePreviewButtonMixin:OnLoad()
	self.parentOption = self:GetParent();
end

function PlayerChoiceCovenantChoicePreviewButtonMixin:OnConfirm()
	C_PlayerChoice.SendPlayerChoiceResponse(self.buttonID);
end
