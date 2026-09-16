PlayerChoiceGenericPowerChoiceOptionTemplateMixin = {};

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:OnLoad()
	PlayerChoicePowerChoiceTemplateMixin.OnLoad(self);
	self.CircleBorder.topPadding = 15;
	self.CircleBorder.bottomPadding = 20;
	self.selectedEffects = { {id = 143}, {id = 150, scaleMultiplier = 1.5} };
end

function PlayerChoiceGenericPowerChoiceOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);
	local atlasData = self:GetAtlasDataForRarity();

	self.ArtworkGlow1:SetVertexColor(1, 1, 1);
	self.ArtworkGlow2:SetVertexColor(1, 1, 1);
	if atlasData then
		useTextureRegions.ArtworkGlow1 = "UI-Frame-%s"..atlasData.postfixData.portraitBackgroundGlow1;
		useTextureRegions.ArtworkGlow2 = "UI-Frame-%s"..atlasData.postfixData.portraitBackgroundGlow2;

		if atlasData.overrideColor then
			self.ArtworkGlow1:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
			self.ArtworkGlow2:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
		end
	end

	useTextureRegions.CircleBorder = "UI-Frame-%s-Portrait-Border";
	self.CircleBorder:SetVertexColor(1, 1, 1);

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
