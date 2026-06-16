local BaseMixin = {};

function BaseMixin:GetTextureKitRegionTable(textureKitRegions)
	local useTextureRegions = {};

	for key, value in pairs(textureKitRegions) do
		useTextureRegions[key] = value .. (self.soloOption and "Wider" or "");
	end

	if self.optionInfo.desaturatedArt then
		useTextureRegions.ArtworkBorder = useTextureRegions.ArtworkBorder.."Disable";
	end

	return useTextureRegions;
end

local customFontInfo = {
	alliance = {
		titleColor = CreateColor(0.008, 0.051, 0.192),
		descriptionColor = CreateColor(0.082, 0.165, 0.373),
	},

	horde = {
		titleColor = CreateColor(0.192, 0.051, 0.008),
		descriptionColor = CreateColor(0.412, 0.020, 0.020),
	},

	marine = {
		titleColor = CreateColor(0.192, 0.051, 0.008),
		descriptionColor = CreateColor(0.192, 0.051, 0.008),
	},

	mechagon = {
		titleFont = "SystemFont_Shadow_Med3",
		titleColor = CreateColor(0.969, 0.855, 0.667),
		descriptionColor = CreateColor(0.969, 0.855, 0.667),
	},

	Kyrian = {
		titleColor = CreateColor(0.008, 0.051, 0.192),
		descriptionColor = CreateColor(0.082, 0.165, 0.373),
	},

	thewarwithin = {
		titleFont = "SystemFont_Shadow_Med3",
		titleColor = CreateColor(0.972, 0.812, 0.706),
		descriptionColor = CreateColor(0.972, 0.812, 0.706),
	},

	midnight = {
		titleFont = "SystemFont_Shadow_Med3",
		titleColor = CreateColor(0.807, 0.772, 0.941),
		descriptionColor = CreateColor(0.807, 0.772, 0.941),
	},
};

local defaultOptionFontInfo = {
	titleFont = "SystemFont_Med3",
	titleColor = BLACK_FONT_COLOR,
	descriptionColor = WARBOARD_OPTION_TEXT_COLOR,
};

function BaseMixin:GetOptionFontInfo()
	return customFontInfo[self:GetTextureKit()] or defaultOptionFontInfo;
end

-- Mixin order is important as BaseMixin provides overrides to PlayerChoiceBaseOptionTemplateMixin
PlayerChoiceNormalOptionTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin, BaseMixin);

local MIN_OPTION_HEIGHT_DEFAULT = 439;
local MIN_OPTION_HEIGHT_NO_HEADER = 410;

function PlayerChoiceNormalOptionTemplateMixin:GetMinOptionHeight()
	return self.Header:IsShown() and MIN_OPTION_HEIGHT_DEFAULT or MIN_OPTION_HEIGHT_NO_HEADER;
end

local STANDARD_SIZE_WIDTH = 240;
local WIDE_SIZE_WIDTH = 501;

do
	local textureKitRegions = {
		ArtworkBorder = "UI-Frame-%s-Portrait",
		Background = "UI-Frame-%s-CardParchment",
	};

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

		local useTextureRegions = self:GetTextureKitRegionTable(textureKitRegions);
		self:SetupTextureKitOnRegions(self, useTextureRegions)

		self.Background:SetDesaturated(self.optionInfo.disabledOption);
		self.Artwork:SetDesaturated(self.optionInfo.disabledOption or self.optionInfo.desaturatedArt);
		self.ArtworkBorder:SetDesaturated(not self.optionInfo.desaturatedArt and self.optionInfo.disabledOption);
	end
end

local headerTextureKitRegions = {
	Ribbon = "UI-Frame-%s-Ribbon",
};

local customHeaderInfo = {
	thewarwithin = {
		textAreaWidth = 160,
	},
};

local DEFAULT_HEADER_TEXT_AREA_WIDTH = 195;

function PlayerChoiceNormalOptionTemplateMixin:GetOptionHeaderTextAreaWidth()
	local customInfo = customHeaderInfo[self:GetTextureKit()];
	return customInfo and customInfo.textAreaWidth or DEFAULT_HEADER_TEXT_AREA_WIDTH;
end

function PlayerChoiceNormalOptionTemplateMixin:SetupHeader()
	if self.optionInfo.header and self.optionInfo.header ~= "" then
		self:SetupTextureKitOnRegions(self.Header, headerTextureKitRegions)
		self.Header.Ribbon:SetDesaturated(self.optionInfo.disabledOption);

		if self.optionInfo.headerIconAtlasElement then
			self.Header.Contents.Icon:SetAtlas(self.optionInfo.headerIconAtlasElement, true);
			self.Header.Contents.Icon:Show();
			self.Header.Contents.Text:SetWidth(self:GetOptionHeaderTextAreaWidth() - (self.Header.Contents.Icon:GetWidth() + self.Header.Contents.spacing));
		else
			self.Header.Contents.Icon:Hide();
			self.Header.Contents.Text:SetWidth(self:GetOptionHeaderTextAreaWidth());
		end

		self.Header.Contents.Text:SetText(self.optionInfo.header);

		-- hack: related to text_width_incorrect_bug
		if self.Header.Contents.Text:GetNumLines() > 1 then
			self.Header.Contents.Text:SetWidth(self.Header.Contents.Text:GetWrappedWidth() + 0.1);
		else
			self.Header.Contents.Text:SetWidth(self.Header.Contents.Text:GetStringWidth() + 0.1);
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

function PlayerChoiceNormalOptionTemplateMixin:SetupTextFonts()
	local fontInfo = self:GetOptionFontInfo();
	self.Header.Contents.Text:SetFontObject(fontInfo.titleFont);
	self.Header.Contents.Text:SetTextColor(fontInfo.titleColor:GetRGBA());
	self.OptionText:SetTextColor(fontInfo.descriptionColor:GetRGBA());
end

local STANDARD_SIZE_TEXT_WIDTH = 196;
local WIDE_SIZE_TEXT_WIDTH = 356;

function PlayerChoiceNormalOptionTemplateMixin:SetupOptionText()
	if self.optionInfo.description == "" then
		self.OptionText:Hide();
	else
		self.OptionText:Show();
		self.OptionText:ClearText();
		self.OptionText:SetWidth(self.soloOption and WIDE_SIZE_TEXT_WIDTH or STANDARD_SIZE_TEXT_WIDTH);
		self.OptionText:SetText(self.optionInfo.description);
	end
end

function PlayerChoiceNormalOptionTemplateMixin:SetupButtons()
	self.OptionButtonsContainer.numColumns = (self.soloOption and not self.showAsList) and 2 or 1;
	PlayerChoiceBaseOptionTemplateMixin.SetupButtons(self);
end

function PlayerChoiceNormalOptionTemplateMixin:SetupRewards()
	local fontInfo = self:GetOptionFontInfo();
	self.Rewards:Setup(self.optionInfo, fontInfo.descriptionColor);
end

PlayerChoiceNormalOptionGridTemplateMixin = CreateFromMixins(PlayerChoiceBaseOptionTemplateMixin, BaseMixin);

function PlayerChoiceNormalOptionGridTemplateMixin:Setup(optionInfo, frameTextureKit)
	self.optionInfo = optionInfo;
	self.uiTextureKit = optionInfo.uiTextureKit;
	self.frameTextureKit = frameTextureKit;

	self:SetupFrame();
end

do
	local textureKitRegions = {
		ArtworkBorder = "UI-Frame-%s-Portrait",
	};
	
	function PlayerChoiceNormalOptionGridTemplateMixin:SetupFrame()
		local optionInfo = self.optionInfo;
		self.Text:SetText(optionInfo.header);

		if self.optionInfo.subHeader then
			self.Text:SetPoint("BOTTOMLEFT", 22, 26);
			self.SubHeaderText:SetText(self.optionInfo.subHeader);
			self.SubHeaderText:Show();
			self.TextBackground:SetAtlas("playerchoice-text-gradient-tall", TextureKitConstants.UseAtlasSize);
		else
			self.Text:SetPoint("BOTTOMLEFT", 22, 12);
			self.SubHeaderText:Hide();
			self.TextBackground:SetAtlas("playerchoice-text-gradient-short", TextureKitConstants.UseAtlasSize);
		end

		local useTextureRegions = self:GetTextureKitRegionTable(textureKitRegions);
		self:SetupTextureKitOnRegions(self, useTextureRegions);

		local artID = optionInfo.choiceArtID;
		local desaturated = optionInfo.disabledOption or optionInfo.desaturatedArt;
		self.ArtworkAdditive:SetTexture(artID);
		self.ArtworkAdditive:SetDesaturated(desaturated);
		self.Artwork:SetTexture(artID);
		self.Artwork:SetDesaturated(desaturated);
		self.ArtworkBorder:SetDesaturated(not optionInfo.desaturatedArt and optionInfo.disabledOption);

		self.Selected:SetShown(optionInfo.selected);
	end
end

local defaultGridOptionFontInfo = {
	widgetColor = HIGHLIGHT_FONT_COLOR,
	descriptionColor = NORMAL_FONT_COLOR,
	headerColor = HIGHLIGHT_FONT_COLOR,
};

function PlayerChoiceNormalOptionGridTemplateMixin:GetOptionFontInfo()
	return customFontInfo[self:GetTextureKit()] or defaultGridOptionFontInfo;
end

function PlayerChoiceNormalOptionGridTemplateMixin:SetSelected(selected)
	self.Selected:SetShown(selected);
end

function PlayerChoiceNormalOptionGridTemplateMixin:Reset()
end
