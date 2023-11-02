PlayerChoiceGenericPowerChoiceOptionTemplateMixin = {};

local rarityToGlowPostfix =
{
	[Enum.PlayerChoiceRarity.Common] = 		{ glow1 = "-portrait-qualitygeneric-01", 	glow2 = "-portrait-qualitygeneric-02" },
	[Enum.PlayerChoiceRarity.Uncommon] = 	{ glow1 = "-portrait-qualityuncommon-01", 	glow2 = "-portrait-qualityuncommon-02" },
	[Enum.PlayerChoiceRarity.Rare] = 		{ glow1 = "-portrait-qualityrare-01", 		glow2 = "-portrait-qualityrare-02" },
	[Enum.PlayerChoiceRarity.Epic] = 		{ glow1 = "-portrait-qualityepic-01", 		glow2 = "-portrait-qualityepic-02" },
};

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:OnLoad()
	PlayerChoicePowerChoiceTemplateMixin.OnLoad(self);
	self.CircleBorder.topPadding = 15;
	self.CircleBorder.bottomPadding = 20;
	self.selectedEffects = { {id = 143}, {id = 150, scaleMultiplier = 1.5} };
end

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);
	local rarity = self.optionInfo.rarity or Enum.PlayerChoiceRarity.Common;
	local rarityGlows = rarityToGlowPostfix[rarity];
	useTextureRegions.ArtworkGlow1 = "UI-Frame-%s"..rarityGlows.glow1;
	useTextureRegions.ArtworkGlow2 = "UI-Frame-%s"..rarityGlows.glow2;

	useTextureRegions.CircleBorder = "UI-Frame-%s-Portrait-Border";
	return useTextureRegions;
end

local OPTION_TEXT_WIDTH = 165;
local OPTION_TEXT_HEIGHT = 135;

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:SetupOptionText()
	if self.optionInfo.description == "" then
		self.OptionText:Hide();
	else
		self.OptionText:Show();
		self.OptionText:ClearText()
		self.OptionText:SetStringHeight(OPTION_TEXT_HEIGHT);
		self.OptionText:SetWidth(OPTION_TEXT_WIDTH);
		self.OptionText:SetText(self:GetRarityDescriptionString()..self.optionInfo.description);
	end
end
