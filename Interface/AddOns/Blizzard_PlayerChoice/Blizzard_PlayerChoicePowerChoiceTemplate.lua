PlayerChoicePowerChoiceTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin);

function PlayerChoicePowerChoiceTemplateMixin:OnLoad()
	self.OptionText:SetUseHTML(false);
	self.OptionText:SetJustifyH("CENTER");
	self.OptionButtonsContainer.buttonTemplate = "PlayerChoiceSmallerOptionButtonTemplate";
end

function PlayerChoicePowerChoiceTemplateMixin:Reset()
	PlayerChoiceBaseOptionTemplateMixin.Reset(self);
	self:SetAlpha(1);
	self.selected = false;
end

function PlayerChoicePowerChoiceTemplateMixin:OnShow()
	self:SetAlpha(1);
	if(self.PassiveAnimations) then
		for _, animation in ipairs(self.PassiveAnimations) do
			animation:Play();
		end
	end
end

function PlayerChoicePowerChoiceTemplateMixin:OnHide()
	if(self.PassiveAnimations) then
		for _, animation in ipairs(self.PassiveAnimations) do
			animation:Stop();
		end
	end
	if self.ChoiceSelectedAnimation then
		self.ChoiceSelectedAnimation:Stop();
	end
	self.FadeoutSelected:Stop();
	self.FadeoutUnselected:Stop();
	self:CancelEffects();
	self:SetAlpha(1);
	self:EnableMouse(true);
	self.selected = false;
end

function PlayerChoicePowerChoiceTemplateMixin:OnEnter()
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

function PlayerChoicePowerChoiceTemplateMixin:OnLeave()
	GameTooltip_Hide();
end

function PlayerChoicePowerChoiceTemplateMixin:FadeOut()
	if self.selected then
		if self.ChoiceSelectedAnimation then
			self.ChoiceSelectedAnimation:Restart();
		end
		if self.selectedEffects ~= nil then
			self.selectedEffectControllers = {};
			for _, effect in ipairs(self.selectedEffects) do
				table.insert(self.selectedEffectControllers, GlobalFXDialogModelScene:AddEffect(effect.id, self.Artwork, self.Artwork, nil, nil, effect.scaleMultiplier or 1));
			end
		end

		local toggleButton = PlayerChoiceToggle_GetActiveToggle();
		if toggleButton then
			toggleButton:Hide();
		end
		C_Timer.After(1.25, function() self:CancelEffects(); self:EnableMouse(false); end);
		self:SetAlpha(1);
		self.FadeoutSelected:Restart();
		if self.choiceSelectedSound then
			PlaySound(self.choiceSelectedSound);
		end
	else
		self:CancelEffects();
		self:SetAlpha(1);
		self:EnableMouse(false);
		self.FadeoutUnselected:Restart();
	end

	self.OptionButtonsContainer:DisableButtons();
end

function PlayerChoicePowerChoiceTemplateMixin:OnSelected()
	self.selected = true;
	PlayerChoiceFrame:FadeOutAllOptions();
end

function PlayerChoicePowerChoiceTemplateMixin:GetMinOptionHeight()
	return self.minOptionHeight;
end

local textureKitRegions = {
	Background = "UI-Frame-%s-CardParchment",
};

local NUM_BG_STYLES = 3;

local rarityToCircleBorderPostfix = 
{
	[Enum.PlayerChoiceRarity.Common] = "-border",
	[Enum.PlayerChoiceRarity.Uncommon] = "-QualityUncommon-border",
	[Enum.PlayerChoiceRarity.Rare] = "-QualityRare-border",
	[Enum.PlayerChoiceRarity.Epic] = "-QualityEpic-border",
};

-- May be overriden by inheriting frame
function PlayerChoicePowerChoiceTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = CopyTable(textureKitRegions);

	local styleNum = mod(self.layoutIndex - 1, NUM_BG_STYLES) + 1;
	useTextureRegions.Background = useTextureRegions.Background.."-Style"..styleNum;

	useTextureRegions.CircleBorder = "UI-Frame-%s-Portrait"..(rarityToCircleBorderPostfix[self.optionInfo.rarity] or "-border");

	return useTextureRegions;
end

function PlayerChoicePowerChoiceTemplateMixin:SetupFrame()
	self.Artwork:SetTexture(self.optionInfo.choiceArtID);

	local useTextureRegions = self:GetTextureKitRegionTable();
	self:SetupTextureKitOnRegions(self, useTextureRegions);

	self:BeginEffects();
end

function PlayerChoicePowerChoiceTemplateMixin:BeginEffects()
	-- Overriden by inheriting frame, if needed
end

function PlayerChoicePowerChoiceTemplateMixin:CancelEffects()
	if self.selectedEffectControllers then
		for _, effectController in ipairs(self.selectedEffectControllers) do
			effectController:CancelEffect();
		end
		self.selectedEffectControllers = nil;
	end
end

function PlayerChoicePowerChoiceTemplateMixin:SetupHeader()
	if self.TypeIcon ~= nil then
		self.TypeIcon:SetTexture(self.optionInfo.typeArtID);
	end

	if self.optionInfo.header and self.optionInfo.header ~= "" then
		self.Header.Text:SetText(self.optionInfo.header);
		self.Header:Show();
	else
		self.Header:Hide();
	end
end

local OPTION_FONT_COLORS = {
	title = HIGHLIGHT_FONT_COLOR,
	description = NORMAL_FONT_COLOR,
};

function PlayerChoicePowerChoiceTemplateMixin:GetOptionFontColors()
	return OPTION_FONT_COLORS;
end

function PlayerChoicePowerChoiceTemplateMixin:SetupTextColors()
	local fontColors = self:GetOptionFontColors();
	if self.optionInfo.rarityColor then
		self.Header.Text:SetTextColor(self.optionInfo.rarityColor:GetRGBA());
	else
		self.Header.Text:SetTextColor(fontColors.title:GetRGBA());
	end
	self.OptionText:SetTextColor(fontColors.description:GetRGBA());
end

local OPTION_TEXT_WIDTH = 160;
local OPTION_TEXT_HEIGHT = 115;

function PlayerChoicePowerChoiceTemplateMixin:SetupOptionText()
	self.OptionText:ClearText()
	self.OptionText:SetStringHeight(OPTION_TEXT_HEIGHT);
	self.OptionText:SetWidth(OPTION_TEXT_WIDTH);
	self.OptionText:SetText(self:GetRarityDescriptionString()..self.optionInfo.description);
end

local rarityToString = 
{
	[Enum.PlayerChoiceRarity.Common] = PLAYER_CHOICE_QUALITY_STRING_COMMON,
	[Enum.PlayerChoiceRarity.Uncommon] = PLAYER_CHOICE_QUALITY_STRING_UNCOMMON,
	[Enum.PlayerChoiceRarity.Rare] = PLAYER_CHOICE_QUALITY_STRING_RARE,
	[Enum.PlayerChoiceRarity.Epic] = PLAYER_CHOICE_QUALITY_STRING_EPIC,
};

-- May be overriden by inheriting frame
function PlayerChoicePowerChoiceTemplateMixin:GetRarityDescriptionString()
	return rarityToString[self.optionInfo.rarity] or "";
end
