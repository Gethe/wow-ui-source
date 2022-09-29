ColorblindSelectorMixin = {};

function ColorblindSelectorMixin:OnLoad()
	local qualityIDs = 
	{
		Enum.ItemQuality.Uncommon,
		Enum.ItemQuality.Rare,
		Enum.ItemQuality.Epic,
		Enum.ItemQuality.Legendary,
		Enum.ItemQuality.Heirloom,
	};
	for index, qualityID in ipairs(qualityIDs) do
		local itemQuality = self.ColorblindExamples.ItemQualities[index];
		itemQuality:SetText(_G["ITEM_QUALITY"..qualityID.."_DESC"]);
		itemQuality:SetTextColor(ITEM_QUALITY_COLORS[qualityID].color:GetRGB());
	end
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(COLORBLIND_LABEL);

	-- Enable Colorblind Mode
	Settings.SetupCVarCheckBox(category, "colorblindMode", USE_COLORBLIND_MODE, OPTION_TOOLTIP_USE_COLORBLIND_MODE);

	-- Colorblind Filter
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, COLORBLIND_OPTION_NONE);
			container:Add(1, COLORBLIND_OPTION_PROTANOPIA);
			container:Add(2, COLORBLIND_OPTION_DEUTERANOPIA);
			container:Add(3, COLORBLIND_OPTION_TRITANOPIA);
			return container:GetData();
		end

		local filterSetting = Settings.RegisterCVarSetting(category, "colorblindSimulator", Settings.VarType.Number, COLORBLIND_FILTER);
		local filterInitializer = Settings.CreateDropDown(category, filterSetting, GetOptions, OPTION_TOOLTIP_COLORBLIND_FILTER);
	
		-- Adjust Strength
		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

		local strengthSetting, strengthInitializer = Settings.SetupCVarSlider(category, "colorblindWeaknessFactor", options, ADJUST_COLORBLIND_STRENGTH, OPTION_TOOLTIP_ADJUST_COLORBLIND_STRENGTH);

		local function IsModifiable()
			return filterSetting:GetValue() > 0;
		end
		strengthInitializer:SetParentInitializer(filterInitializer, IsModifiable);
	end

	-- Custom colorblind type and intensity
	do
		local settings = 
		{
			colorblindSimulator = Settings.RegisterCVarSetting(category, "colorblindSimulator", Settings.VarType.Number, COLORBLIND_FILTER),
			colorblindFactor = Settings.RegisterCVarSetting(category, "colorblindWeaknessFactor", Settings.VarType.Number, ADJUST_COLORBLIND_STRENGTH),
		};
		local data = { settings = settings };
		local initializer = Settings.CreatePanelInitializer("ColorblindSelectorTemplate", data);
		layout:AddInitializer(initializer);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);