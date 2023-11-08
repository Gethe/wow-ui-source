PlayerChoiceNormalOptionTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin);

local MIN_OPTION_HEIGHT_DEFAULT = 439;
local MIN_OPTION_HEIGHT_NO_HEADER = 410;

function PlayerChoiceNormalOptionTemplateMixin:GetMinOptionHeight()
	return self.Header:IsShown() and MIN_OPTION_HEIGHT_DEFAULT or MIN_OPTION_HEIGHT_NO_HEADER;
end

local textureKitRegions = {
	ArtworkBorder = "UI-Frame-%s-Portrait",
	Background = "UI-Frame-%s-CardParchment",
};

function PlayerChoiceNormalOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = {};

	for key, value in pairs(textureKitRegions) do
		useTextureRegions[key] = value .. (self.soloOption and "Wider" or "");
	end

	if self.optionInfo.desaturatedArt then
		useTextureRegions.ArtworkBorder = useTextureRegions.ArtworkBorder.."Disable";
	end

	return useTextureRegions;
end

local STANDARD_SIZE_WIDTH = 240;
local WIDE_SIZE_WIDTH = 501;

function PlayerChoiceNormalOptionTemplateMixin:SetupFrame()
	self.fixedWidth = self.soloOption and WIDE_SIZE_WIDTH or STANDARD_SIZE_WIDTH;

	self.Artwork:SetTexture(self.optionInfo.choiceArtID);

	self.Artwork:ClearAllPoints();
	if PlayerChoiceFrame:IsLegacy() then
		-- Legacy player choice options used textures with the frame built into it
		self.Artwork:SetPoint("CENTER", self.ArtworkBorder, "CENTER", 0, 0);

		-- Using alpha here instead of hiding it because we still want ArtworkBorder to be used for the layout process
		self.ArtworkBorder:SetAlpha(0);
	else
		self.Artwork:SetPoint("TOPLEFT", self.ArtworkBorder, "TOPLEFT", 10, -9);
		self.Artwork:SetPoint("BOTTOMRIGHT", self.ArtworkBorder, "BOTTOMRIGHT", -10, 9);
		self.ArtworkBorder:SetAlpha(1);
	end

	local useTextureRegions = self:GetTextureKitRegionTable();
	self:SetupTextureKitOnRegions(self, useTextureRegions)

	self.Background:SetDesaturated(self.optionInfo.disabledOption);
	self.Artwork:SetDesaturated(self.optionInfo.disabledOption or self.optionInfo.desaturatedArt);
	self.ArtworkBorder:SetDesaturated(not self.optionInfo.desaturatedArt and self.optionInfo.disabledOption);
end

local headerTextureKitRegions = {
	Ribbon = "UI-Frame-%s-Ribbon",
};

local HEADER_TEXT_AREA_WIDTH = 195;

function PlayerChoiceNormalOptionTemplateMixin:SetupHeader()
	if self.optionInfo.header and self.optionInfo.header ~= "" then
		self:SetupTextureKitOnRegions(self.Header, headerTextureKitRegions)
		self.Header.Ribbon:SetDesaturated(self.optionInfo.disabledOption);

		if self.optionInfo.headerIconAtlasElement then
			self.Header.Contents.Icon:SetAtlas(self.optionInfo.headerIconAtlasElement, true);
			self.Header.Contents.Icon:Show();
			self.Header.Contents.Text:SetWidth(HEADER_TEXT_AREA_WIDTH - (self.Header.Contents.Icon:GetWidth() + self.Header.Contents.spacing));
		else
			self.Header.Contents.Icon:Hide();
			self.Header.Contents.Text:SetWidth(HEADER_TEXT_AREA_WIDTH);
		end

		self.Header.Contents.Text:SetText(self.optionInfo.header);

		if self.Header.Contents.Text:GetNumLines() > 1 then
			self.Header.Contents.Text:SetWidth(self.Header.Contents.Text:GetWrappedWidth());
		else
			self.Header.Contents.Text:SetWidth(self.Header.Contents.Text:GetStringWidth());
		end

		self.Header:Show();

		self.ArtworkBorder.topPadding = -16;
		self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -8, -36);
	else
		self.Header:Hide();

		self.ArtworkBorder.topPadding = 50;
		self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -8, 0);
	end
end

local subHeaderTextureKitRegions = {
	BG = "UI-Frame-%s-Subtitle",
};

local subHeaderTextureKitRegionsDisabled = {
	BG = "UI-Frame-%s-DisableSubtitle",
};

function PlayerChoiceNormalOptionTemplateMixin:SetupSubHeader()
	if self.optionInfo.subHeader then
		local useDisabledTexture = not self.optionInfo.disabledOption and self.optionInfo.desaturatedArt
		self:SetupTextureKitOnRegions(self.SubHeader, useDisabledTexture and subHeaderTextureKitRegionsDisabled or subHeaderTextureKitRegions)
		self.SubHeader.BG:SetDesaturated(self.optionInfo.disabledOption);
		self.SubHeader.Text:SetText(self.optionInfo.subHeader);
		self.SubHeader:Show();
	else
		self.SubHeader:Hide();
	end
end

local customFontColorInfo = {
	alliance = {
		title = CreateColor(0.008, 0.051, 0.192),
		description = CreateColor(0.082, 0.165, 0.373),
	},

	horde = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.412, 0.020, 0.020),
	},

	marine = {
		title = CreateColor(0.192, 0.051, 0.008),
		description = CreateColor(0.192, 0.051, 0.008),
	},

	mechagon = {
		title = CreateColor(0.969, 0.855, 0.667),
		description = CreateColor(0.969, 0.855, 0.667),
	},

	Kyrian = {
		title = CreateColor(0.008, 0.051, 0.192),
		description = CreateColor(0.082, 0.165, 0.373),
	},
};

local defaultOptionFontColors = {
	title = BLACK_FONT_COLOR,
	description = WARBOARD_OPTION_TEXT_COLOR,
};

function PlayerChoiceNormalOptionTemplateMixin:GetOptionFontColors()
	return customFontColorInfo[self:GetTextureKit()] or defaultOptionFontColors;
end

function PlayerChoiceNormalOptionTemplateMixin:SetupTextColors()
	local fontColors = self:GetOptionFontColors();
	self.Header.Contents.Text:SetTextColor(fontColors.title:GetRGBA());
	self.OptionText:SetTextColor(fontColors.description:GetRGBA());
end

local STANDARD_SIZE_TEXT_WIDTH = 196;
local WIDE_SIZE_TEXT_WIDTH = 356;

function PlayerChoiceNormalOptionTemplateMixin:SetupOptionText()
	if self.optionInfo.description == "" then
		self.OptionText:Hide();
	else
		self.OptionText:Show();
		self.OptionText:ClearText()
		self.OptionText:SetWidth(self.soloOption and WIDE_SIZE_TEXT_WIDTH or STANDARD_SIZE_TEXT_WIDTH);
		self.OptionText:SetText(self.optionInfo.description);
	end
end

function PlayerChoiceNormalOptionTemplateMixin:SetupButtons()
	self.OptionButtonsContainer:Setup(self.optionInfo, self.soloOption and 2 or 1);
end

function PlayerChoiceNormalOptionTemplateMixin:SetupRewards()
	local fontColors = self:GetOptionFontColors();
	self.Rewards:Setup(self.optionInfo, fontColors.description);
end
