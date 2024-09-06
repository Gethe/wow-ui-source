--[[
Blizzard_Settings implementation guide

Blizzard_Settings was originally implemented in 10.0 but has been updated in 11.0 to address
usability concerns.

Addons can describe settings using canvas or vertical list frames.

*** Categories and Subcategories ***
Categories are containers for your settings and can be represented by either a canvas or vertical list:
local category, layout = Settings.RegisterCanvasLayoutCategory(myFrame, "My Addon");
or
local category, layout = Settings.RegisterVerticalLayoutCategory("My Addon");

Subcategories are attached to a category. Note that the parent category type is interchangable if you want
a combination of techiques.
local subcategory, subcategoryLayout = Settings.RegisterCanvasLayoutSubcategory(category, myFrame, "My Addon Subcategory");
or
local subcategory, subcategoryLayout = Settings.RegisterVerticalLayoutSubcategory(category, "My Addon Subcategory");

The layout object returned by each of these functions has a different API that pertains to the presentation
type selected. For vertical lists, in general, you will not need to interact with the layout object at all
unless you need to create custom controls and/or frames to represent a setting.

*** Canvas ***
Canvas refers to a frame that is designed entirely in your addon. This technique was retained from the
legacy settings system. The settings system will display your frame when the category is selected. Other than
some optional functions, the implemeentation details of the frame are up to you.

The canvas layout object allows you to customize the anchoring. If no anchor points are provided, 
the frame will be anchored to TOPLEFT (0,0) and BOTTOMRIGHT (0,0) in the panel space.
layout:AddAnchorPoint("TOPLEFT", 50, -50);
layout:AddAnchorPoint("BOTTOMRIGHT", -50, 50);

There are 3 optional functions you can define in your frame:
1) OnCommit: Called when the Apply option is selected in the settings panel. This is called if any
setting with the Apply commit flag has been changed.
to you if you have settings objects with the Apply commit flag set.
2) OnDefault: Called when defaults are applied.
3) OnRefresh: Called when the settings panel is shown.

After you have registered a category for your frame, the last step should be to register the category:
Settings.RegisterAddOnCategory(category);

*** Vertical list ***
Vertical lists allow you to forgoe the design work of creating controls and handling their layout. 
These lists are populated using a combination of setting objects and settings controls. This is the
technique used to display most of the WoW game settings.

This example creates a category with a checkbox using a proxy setting, and a subcategory with a checkbox
using an addon setting.

MyAddon.toc:
## SavedVariables: MyAddonSettings

MyAddon.lua:
EventUtil.ContinueOnAddOnLoaded("MyAddon", function()
	local category, layout = Settings.RegisterVerticalLayoutCategory("My Addon");

	-- A proxy setting allows for get and set accessors, but it is your responsibility to default initialize the
	-- saved variable value and write the value to your saved variable table when it changes.

	if MyAddonSettings.canLog == nil then
		MyAddonSettings.canLog = Settings.Default.True;
	end

	local function GetValue()
		return MyAddonSettings.canLog;
	end

	local function SetValue(value)
		MyAddonSettings.canLog = value;
		-- Your implementation to apply the 'canLog' value.
	end

	-- "MY_ADDON_CAN_LOG" and "MY_ADDON_CAN_LOG_ATTACKS" are the variable names and are 
	-- necessary for setting lookups.
	local canLogSetting = Settings.RegisterProxySetting(category, "MY_ADDON_CAN_LOG", 
		Settings.VarType.Boolean, "Can Log", Settings.Default.True, GetValue, SetValue)
	Settings.CreateCheckbox(category, canLogSetting);

	-- An addon setting will write any value changes directly to your saved variable table. Assign a callback
	-- to apply value changes to your code. Note that unlike a proxy setting, you do not need to default 
	-- initialize the variable table if the value is currently nil as it will be done for you before 
	-- RegisterAddOnSetting returns.

	local logCategory, logLayout = Settings.RegisterVerticalLayoutSubcategory(category, "Log Details");
	local logAttacksSetting = Settings.RegisterAddOnSetting(logCategory, "MY_ADDON_CAN_LOG_ATTACKS", "logAttacks", 
		MyAddonSettings, Settings.VarType.Boolean, "Log Attacks", Settings.Default.True);
	
	logAttacksSetting:SetValueChangedCallback(function(setting, value)
		--  Your implementation to apply the 'logAttacks' value.
	end);

	Settings.CreateCheckbox(logCategory, logAttacksSetting);

	Settings.RegisterAddOnCategory(category);
end);

*** Setting Controls ***
Settings can be easily paired with a control using the following utility functions. Exerpts are from examples in WoW code:

Settings.CreateCheckbox():

local function GetValue()
	return tonumber(GetCVar("softTargetEnemy")) == Enum.SoftTargetEnableFlags.Any;
end

local function SetValue(value)
	SetCVar("softTargetEnemy", value and Enum.SoftTargetEnableFlags.Any or Enum.SoftTargetEnableFlags.Gamepad);
end

local defaultValue = false;
local setting = Settings.RegisterProxySetting(category, "PROXY_ACTION_TARGETING",
	Settings.VarType.Boolean, ACTION_TARGETING_OPTION, defaultValue, GetValue, SetValue);
Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_ACTION_TARGETING);





Settings.CreateSlider():

local max = 1.0;
local function GetValue()
	return max - C_VoiceChat.GetMasterVolumeScale();
end

local function SetValue(value)
	C_VoiceChat.SetMasterVolumeScale(max - value);
end

local defaultValue = tonumber(GetCVarDefault("VoiceChatMasterVolumeScale"));
local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_DUCKING",
	Settings.VarType.Number, VOICE_CHAT_DUCKING_SCALE, defaultValue, GetValue, SetValue);

local minValue, maxValue, step = 0, max, .01;
local options = Settings.CreateSliderOptions(minValue, maxValue, step);
options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

local initializer = Settings.CreateSlider(category, setting, options, VOICE_CHAT_AUDIO_DUCKING);
initializer:SetParentInitializer(outputInitializer);





Settings.CreateDropdown():

local function GetValue()
	local chatBubbles = C_CVar.GetCVarBool("chatBubbles");
	local chatBubblesParty = C_CVar.GetCVarBool("chatBubblesParty");
	if chatBubbles and chatBubblesParty then
		return 1;
	elseif not chatBubbles then
		return 2;
	elseif chatBubbles and not chatBubblesParty then
		return 3;
	end
end

local function SetValue(value)
	if value == 1 then
		SetCVar("chatBubbles", "1");
		SetCVar("chatBubblesParty", "1");
	elseif value == 2 then
		SetCVar("chatBubbles", "0");
		SetCVar("chatBubblesParty", "0");
	elseif value == 3 then
		SetCVar("chatBubbles", "1");
		SetCVar("chatBubblesParty", "0");
	end
end

local function GetOptions()
	local container = Settings.CreateControlTextContainer();
	container:Add(1, ALL);
	container:Add(2, NONE);
	container:Add(3, CHAT_BUBBLES_EXCLUDE_PARTY_CHAT);
	return container:GetData();
end

local defaultValue = 1;
local setting = Settings.RegisterProxySetting(category, "PROXY_CHAT_BUBBLES",
	Settings.VarType.Number, CHAT_BUBBLES_TEXT, defaultValue, GetValue, SetValue);
Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_CHAT_BUBBLES);





*** Accessing Setting Values ***
After a setting is registered you can retrieve the object using Settings.GetSetting(variable). 
To access or change the setting's value, use setting:SetValue(value) and setting:GetValue() respectively.

You can also access or change a setting's value by setting variable alone using
Settings.GetValue(variable) and Settings.SetValue(variable, value) respectively.

*** Opening Settings to a Category ***
You can open the settings UI to your category using:
Settings.OpenToCategory(categoryID, scrollToElementName);

For vertical lists, the optional 'scrollToElementName' refers to display name assigned to the setting. 
If this is omitted, the category will be opened to the top of the list. The ID needs to be retrieved
from your category or subcategory using GetID():

For example:
Settings.OpenToCategory(category:GetID());
or
local settingName = "Can Log";
Settings.OpenToCategory(category:GetID(), settingName);

*** Addon Subcategory Sorting ***
While addon categories are sorted alphabetically, subcategories are not.
You can enable subcategory sorting using:
category:SetShouldSortAlphabetically(true);
]]--