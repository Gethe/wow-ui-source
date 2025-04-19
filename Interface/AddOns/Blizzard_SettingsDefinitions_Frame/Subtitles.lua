-- Constants
local SUBTITLES_ENABLED_CVAR = "movieSubtitle";
local SUBTITLES_BACKGROUND_CVAR = "movieSubtitleBackground";
local SUBTITLES_BACKGROUND_OPACITY_CVAR = "movieSubtitleBackgroundAlpha";
local BACKGROUND_TYPE_DEFAULT = 1; -- NONE
local BACKGROUND_OPACITY_DEFAULT = 0.7; -- 70%
local BACKGROUND_OPACITY_MIN = 50; -- 0.5, 50%
local BACKGROUND_OPACITY_MAX = 100; -- 1, 100%
local BACKGROUND_OPACITY_STEP = 10; -- 0.1, 10%

SubtitlesPreviewMixin = {};

function SubtitlesPreviewMixin:OnLoad()
	EventRegistry:RegisterCallback("Settings.CategoryChanged", function(...)
		local _, categoryData = ...;
		if categoryData and categoryData.name == CINEMATIC_SUBTITLES_OPTIONS_HEADER then
			self:Show();
		else
			self:Hide();
		end 
	end, self);

	EventRegistry:RegisterCallback("CVAR_UPDATE", function(...)
		local _, cvar = ...;
		local args = {
			subtitleBackground = GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_CVAR),
			subtitleBackgroundAlpha = (GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_OPACITY_CVAR) / 100),
		};
	
		self:UpdatePreview(args);
	end, self);
end

function SubtitlesPreviewMixin:OnShow()
	local currentCategory = SettingsPanel:GetCurrentCategory();
	local currentCategoryName = currentCategory and currentCategory.name or nil;

	if currentCategoryName and currentCategoryName ~= CINEMATIC_SUBTITLES_OPTIONS_HEADER then
		self:Hide();
		return;
	end
	
	local args = {
		subtitleBackground = GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_CVAR),
		subtitleBackgroundAlpha = (GetCVarNumberOrDefault(SUBTITLES_BACKGROUND_OPACITY_CVAR) / 100),
	};

	self:UpdatePreview(args);
	self.NineSlice:Hide();
end

-- NOTE: Background types are also used in Blizzard_Subtitles.lua
function SubtitlesPreviewMixin:UpdatePreview(args)
	if not GetCVarBool(SUBTITLES_ENABLED_CVAR) then 
		self:Hide();
	else
		self:Show();
		if args.subtitleBackground then
			if args.subtitleBackground > BACKGROUND_TYPE_DEFAULT then
				local backgroundTypes = {
					nil,
					CINEMATIC_SUBTITLES_BLACK_BACKGROUND_COLOR,
					CINEMATIC_SUBTITLES_LIGHT_BACKGROUND_COLOR,
				};
		
				self.PreviewFontStringBackground:SetColorTexture(backgroundTypes[args.subtitleBackground]:GetRGB());
				if args.subtitleBackgroundAlpha then
					self.PreviewFontStringBackground:SetAlpha(args.subtitleBackgroundAlpha);
				else
					self.PreviewFontStringBackground:SetAlpha(BACKGROUND_OPACITY_DEFAULT);
				end
			else
				self.PreviewFontStringBackground:SetAlpha(0);
			end
		end
	end
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(CINEMATIC_SUBTITLES_OPTIONS_HEADER);

	-- DISPLAY header
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CINEMATIC_SUBTITLES_DISPLAY_SUBHEADER));

	-- Subtitles on/off
	local subtitlesEnabledSetting = Settings.SetupCVarCheckbox(category, SUBTITLES_ENABLED_CVAR, CINEMATIC_SUBTITLES, OPTION_TOOLTIP_CINEMATIC_SUBTITLES);

	-- Subtitle Background
	do
		local function GetValue()
			local movieSubtitleBackground = C_CVar.GetCVar(SUBTITLES_BACKGROUND_CVAR);
			return tonumber(movieSubtitleBackground);
		end

		local function SetValue(value)
			C_CVar.SetCVar(SUBTITLES_BACKGROUND_CVAR, tostring(value));
		end

		local function OnEntryEnter(entry)
			local args = {
				subtitleBackground = entry.value or BACKGROUND_TYPE_DEFAULT,
				subtitleBackgroundAlpha = tonumber(C_CVar.GetCVar(SUBTITLES_BACKGROUND_OPACITY_CVAR) / 100) or BACKGROUND_OPACITY_DEFAULT,
			};

			SettingsPanel.SubtitlePreview:UpdatePreview(args);
		end

        local function OnHide()
            local args = {
                subtitleBackground = GetValue() or BACKGROUND_TYPE_DEFAULT,
                subtitleBackgroundAlpha = tonumber(C_CVar.GetCVar(SUBTITLES_BACKGROUND_OPACITY_CVAR) / 100) or BACKGROUND_OPACITY_DEFAULT,
            };

            SettingsPanel.SubtitlePreview:UpdatePreview(args);
        end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, CINEMATIC_SUBTITLES_BACKGROUND_OPTION_NONE);
			container:Add(2, CINEMATIC_SUBTITLES_BACKGROUND_OPTION_DARK);
			container:Add(3, CINEMATIC_SUBTITLES_BACKGROUND_OPTION_LIGHT);

			local data = container:GetData();
			for index, entry in ipairs(data) do
				entry.onEnter = OnEntryEnter;
			end
			return data;
		end

		local setting = Settings.RegisterProxySetting(category, "PROXY_MOVIE_SUBTITLE_BACKGROUND", Settings.VarType.Number, CINEMATIC_SUBTITLES_BACKGROUND_COLOR_OPTION_LABEL, BACKGROUND_TYPE_DEFAULT, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions);

        local function ShownPredicate()
            return subtitlesEnabledSetting:GetValue();
        end

        initializer.OnHide = OnHide;
        initializer:AddShownPredicate(ShownPredicate);
	end

	-- Subtitle Background Alpha
	do
		local defaultValue = BACKGROUND_OPACITY_DEFAULT * 100; -- 70, making the numbers easier to work with
		local minValue, maxValue, step = BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, BACKGROUND_OPACITY_STEP;

		local function GetValue()
			local movieSubtitleBackgroundAlpha = C_CVar.GetCVar(SUBTITLES_BACKGROUND_OPACITY_CVAR);
			return tonumber(movieSubtitleBackgroundAlpha);
		end	

		local function SetValue(value)
			C_CVar.SetCVar(SUBTITLES_BACKGROUND_OPACITY_CVAR, tostring(value));
		end

		local function Formatter(value)
			return PERCENTAGE_STRING:format(value);
		end

		local setting = Settings.RegisterProxySetting(category, "PROXY_MOVIE_SUBTITLE_BACKGROUND_ALPHA", Settings.VarType.Number, CINEMATIC_SUBTITLES_BACKGROUND_OPACITY_OPTION_LABEL, defaultValue, GetValue, SetValue);
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, Formatter);
		local initializer = Settings.CreateSlider(category, setting, options);

        local function ShownPredicate()
            local subtitlesEnabled = subtitlesEnabledSetting:GetValue();
            local backgroundTypeValid = Settings.GetValue("PROXY_MOVIE_SUBTITLE_BACKGROUND") > 1;

            return subtitlesEnabled and backgroundTypeValid;
        end
        
        initializer:AddShownPredicate(ShownPredicate);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);