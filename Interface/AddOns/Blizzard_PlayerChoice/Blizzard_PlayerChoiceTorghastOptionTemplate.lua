PlayerChoiceTorghastOptionTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin);

function PlayerChoiceTorghastOptionTemplateMixin:OnLoad()
	self.OptionText:SetUseHTML(false);
	self.OptionText:SetJustifyH("CENTER");
	self.OptionButtonsContainer.buttonTemplate = "PlayerChoiceSmallerOptionButtonTemplate";
end

function PlayerChoiceTorghastOptionTemplateMixin:Reset()
	PlayerChoiceBaseOptionTemplateMixin.Reset(self);
	self:SetAlpha(1);
	self.selected = false;
end

function PlayerChoiceTorghastOptionTemplateMixin:OnShow()
	self:SetAlpha(1);
	self.SwirlAndGlowAnimations:Play();
end

function PlayerChoiceTorghastOptionTemplateMixin:OnHide()
	self.SwirlAndGlowAnimations:Stop();
	self.ChoiceSelectedAnimation:Stop();
	self.FadeoutSelected:Stop();
	self.FadeoutUnselected:Stop();
	self:CancelEffects();
	self:SetAlpha(1);
	self:EnableMouse(true);
	self.selected = false;
end

function PlayerChoiceTorghastOptionTemplateMixin:OnEnter()
	GameTooltip:SetOwner(self.OptionText, "ANCHOR_RIGHT");
	if self.optionInfo.rarityColor then
		GameTooltip_AddColoredLine(GameTooltip, self.optionInfo.header, self.optionInfo.rarityColor);
	else
		GameTooltip_AddHighlightLine(GameTooltip, self.optionInfo.header);
	end
	if self.optionInfo.rarity and self.optionInfo.rarityColor then
		local rarityStringIndex = self.optionInfo.rarity + 1;
		local rarityText = _G["ITEM_QUALITY"..rarityStringIndex.."_DESC"];
		GameTooltip_AddColoredLine(GameTooltip, rarityText, self.optionInfo.rarityColor);
	end
	GameTooltip_AddNormalLine(GameTooltip, self.optionInfo.description);
	GameTooltip:Show();
end

function PlayerChoiceTorghastOptionTemplateMixin:OnLeave()
	GameTooltip_Hide();
end

local selectedEffectID = 97;

function PlayerChoiceTorghastOptionTemplateMixin:FadeOut()
	if self.selected then
		self.ChoiceSelectedAnimation:Restart();
		self.selectedEffectController = GlobalFXDialogModelScene:AddEffect(selectedEffectID, self.Artwork);

		PlayerChoiceToggleButton:Hide();
		C_Timer.After(1.25, function() self:CancelEffects(); self:EnableMouse(false); end);
		self:SetAlpha(1);
		self.FadeoutSelected:Restart();
		PlaySound(SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_FADEOUT_POWERS_NOT_PICKED);
	else
		self:CancelEffects();
		self:SetAlpha(1);
		self:EnableMouse(false);
		self.FadeoutUnselected:Restart();
	end
end

function PlayerChoiceTorghastOptionTemplateMixin:OnSelected()
	self.selected = true;
	PlayerChoiceFrame:FadeOutAllOptions();
end

local MIN_OPTION_HEIGHT = 388;

function PlayerChoiceTorghastOptionTemplateMixin:GetMinOptionHeight()
	return MIN_OPTION_HEIGHT;
end

local textureKitRegions = {
	Background = "UI-Frame-%s-CardParchment",
};

local NUM_BG_STYLES = 3;

local rarityToSwirlPostfix = 
{
	[Enum.PlayerChoiceRarity.Common] = "",
	[Enum.PlayerChoiceRarity.Uncommon] = "-QualityUncommon",
	[Enum.PlayerChoiceRarity.Rare] = "-QualityRare",
	[Enum.PlayerChoiceRarity.Epic] = "-QualityEpic",
};

local rarityToCircleBorderPostfix = 
{
	[Enum.PlayerChoiceRarity.Common] = "-border",
	[Enum.PlayerChoiceRarity.Uncommon] = "-QualityUncommon-border",
	[Enum.PlayerChoiceRarity.Rare] = "-QualityRare-border",
	[Enum.PlayerChoiceRarity.Epic] = "-QualityEpic-border",
};

function PlayerChoiceTorghastOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = CopyTable(textureKitRegions);

	local styleNum = mod(self.layoutIndex - 1, NUM_BG_STYLES) + 1;
	useTextureRegions.Background = useTextureRegions.Background.."-Style"..styleNum;

	useTextureRegions.SwirlBG = "UI-Frame-%s-Portrait"..rarityToSwirlPostfix[self.optionInfo.rarity];
	useTextureRegions.GlowBG = useTextureRegions.SwirlBG;
	useTextureRegions.CircleBorder = "UI-Frame-%s-Portrait"..rarityToCircleBorderPostfix[self.optionInfo.rarity];

	return useTextureRegions;
end

function PlayerChoiceTorghastOptionTemplateMixin:SetupFrame()
	self.Artwork:SetTexture(self.optionInfo.choiceArtID);

	local useTextureRegions = self:GetTextureKitRegionTable();
	self:SetupTextureKitOnRegions(self, useTextureRegions);

	self:BeginEffects();
end

local powerSwirlEffectID = 95;
local smokeEffectID = 89;

function PlayerChoiceTorghastOptionTemplateMixin:BeginEffects()
	if not self.powerSwirlEffectController then
		self.powerSwirlEffectController = PlayerChoiceFrame.BorderLayerModelScene:AddEffect(powerSwirlEffectID, self.Artwork);
	end

	if not self.smokeEffectController then
		self.smokeEffectController = GlobalFXBackgroundModelScene:AddEffect(smokeEffectID, self.Background);
	end
end

function PlayerChoiceTorghastOptionTemplateMixin:CancelEffects()
	if self.powerSwirlEffectController then
		self.powerSwirlEffectController:CancelEffect();
		self.powerSwirlEffectController = nil;
	end

	if self.smokeEffectController then
		self.smokeEffectController:CancelEffect();
		self.smokeEffectController = nil;
	end

	if self.selectedEffectController then
		self.selectedEffectController:CancelEffect();
		self.selectedEffectController = nil;
	end
end

function PlayerChoiceTorghastOptionTemplateMixin:SetupHeader()
	self.TypeIcon:SetTexture(self.optionInfo.typeArtID);

	if self.optionInfo.header and self.optionInfo.header ~= "" then
		self.Header.Text:SetText(self.optionInfo.header);
		self.Header:Show();
	else
		self.Header:Hide();
	end
end

local TORGHAST_FONT_COLORS = {
	title = HIGHLIGHT_FONT_COLOR,
	description = NORMAL_FONT_COLOR,
};

function PlayerChoiceTorghastOptionTemplateMixin:GetOptionFontColors()
	return TORGHAST_FONT_COLORS;
end

function PlayerChoiceTorghastOptionTemplateMixin:SetupTextColors()
	local fontColors = self:GetOptionFontColors();
	if self.optionInfo.rarityColor then
		self.Header.Text:SetTextColor(self.optionInfo.rarityColor:GetRGBA());
	else
		self.Header.Text:SetTextColor(fontColors.title:GetRGBA());
	end
	self.OptionText:SetTextColor(fontColors.description:GetRGBA());
end

local TORGHAST_TEXT_WIDTH = 160;
local TORGHAST_TEXT_HEIGHT = 115;

function PlayerChoiceTorghastOptionTemplateMixin:SetupOptionText()
	self.OptionText:ClearText()
	self.OptionText:SetStringHeight(TORGHAST_TEXT_HEIGHT);
	self.OptionText:SetWidth(TORGHAST_TEXT_WIDTH);
	self.OptionText:SetText(self:GetRarityDescriptionString()..self.optionInfo.description);
end

local rarityToString = 
{
	[Enum.PlayerChoiceRarity.Common] = PLAYER_CHOICE_QUALITY_STRING_COMMON,
	[Enum.PlayerChoiceRarity.Uncommon] = PLAYER_CHOICE_QUALITY_STRING_UNCOMMON,
	[Enum.PlayerChoiceRarity.Rare] = PLAYER_CHOICE_QUALITY_STRING_RARE,
	[Enum.PlayerChoiceRarity.Epic] = PLAYER_CHOICE_QUALITY_STRING_EPIC,
};

function PlayerChoiceTorghastOptionTemplateMixin:GetRarityDescriptionString()
	return rarityToString[self.optionInfo.rarity] or PLAYER_CHOICE_QUALITY_STRING_COMMON;
end
