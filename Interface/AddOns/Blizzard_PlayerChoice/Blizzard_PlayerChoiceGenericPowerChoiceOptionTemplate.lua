PlayerChoiceGenericPowerChoiceOptionTemplateMixin = {};

local rarityToCircleBorderPostfix = 
{
	[Enum.PlayerChoiceRarity.Common] = "-Portrait-border",
	[Enum.PlayerChoiceRarity.Uncommon] = "-QualityUncommon-border",
	[Enum.PlayerChoiceRarity.Rare] = "-QualityRare-border",
	[Enum.PlayerChoiceRarity.Epic] = "-QualityEpic-border",
};

local rarityToGlowBGPostfix =
{
	[Enum.PlayerChoiceRarity.Common] = "-portrait",
	[Enum.PlayerChoiceRarity.Uncommon] = "-portrait-qualityuncommon",
	[Enum.PlayerChoiceRarity.Rare] = "-portrait-qualityrare",
	[Enum.PlayerChoiceRarity.Epic] = "-portrait-qualityepic",
};

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);
	local rarity = self.optionInfo.rarity or Enum.PlayerChoiceRarity.Common;
	useTextureRegions.CircleBorder = "UI-Frame-%s"..rarityToCircleBorderPostfix[rarity];
	useTextureRegions.GlowBG = "UI-Frame-%s"..rarityToGlowBGPostfix[rarity];
	useTextureRegions.Background = "UI-Frame-%s-CardParchment";
	return useTextureRegions;
end

local OPTION_TEXT_WIDTH = 165;
local OPTION_TEXT_HEIGHT = 135;

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:SetupOptionText()
	self.OptionText:ClearText()
	self.OptionText:SetStringHeight(OPTION_TEXT_HEIGHT);
	self.OptionText:SetWidth(OPTION_TEXT_WIDTH);
	self.OptionText:SetText(self:GetRarityDescriptionString()..self.optionInfo.description);
end
