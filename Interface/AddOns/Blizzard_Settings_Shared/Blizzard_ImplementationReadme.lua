--[[
Frames or vertical settings list are registered differently.
- a frame:
local frame = CreateFrame("Frame", nil, nil, "MyFrameTemplateName");
local category, layout = Settings.RegisterCanvasLayoutCategory(frame, "My Category Name");

-- Any anchors assigned to the frame will be disposed. Intended anchors need to be provided through
-- the layout object. If no anchor points are provided, the frame will be anchored to TOPLEFT (0,0)
-- and BOTTOMRIGHT (0,0).
layout:AddAnchorPoint("TOPLEFT", 10, -10);
layout:AddAnchorPoint("BOTTOMRIGHT", -10, 10);

Frames are required to have OnCommit, OnDefault, and OnRefresh functions even if their implementations are empty.

-- or a settings list:
local category, layout = Settings.RegisterVerticalLayoutCategory("My Category Name");
... setting initializers assigned to layout.
Settings.RegisterAddOnCategory(category);

-- To assign a subcategory:
local category = category or Settings.GetCategory("My Category Name");

-- a frame:
local category = category or Settings.GetCategory("My Category Name");
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, "My Subcategory Name");

-- or a settings list:
local subcategory, layout = Settings.RegisterVerticalLayoutSubcategory(category, "My Subcategory Name");
... setting initializers assigned to layout.
Settings.RegisterAddOnCategory(subcategory);

-- Sample setting creation and registration:
local myVariableTable = {}; -- Saved in your .toc

-- check box
local variable, name, tooltip = "MyCheckbox", "My Checkbox", "My Checkbox Tooltip";
local setting = Settings.RegisterProxySetting(category, variable, myVariableTable, Settings.VarType.Boolean, name, Settings.Default.True);
Settings.CreateCheckbox(category, setting, tooltip);

-- slider
local variable, name, tooltip = "MySlider", "My Slider", "My Slider Tooltip";
local minValue, maxValue, step = 1, 100, 1;
local options = Settings.CreateSliderOptions(minValue, maxValue, step);
options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

local defaultValue = 50;
local setting = Settings.RegisterProxySetting(category, variable, myVariableTable, Settings.VarType.Number, name, defaultValue);
Settings.CreateSlider(category, setting, options, tooltip);

-- dropdown
local variable, name, tooltip = "MyDropdown", "My Dropdown", "My Dropdown Tooltip";
local function GetOptions()
    local container = Settings.CreateControlTextContainer();
    container:Add(0, "Option A");
    container:Add(1, "Option B");
    container:Add(2, "Option C");
    return container:GetData();
end

local defaultValue = 0;
local setting = Settings.RegisterProxySetting(category, variable, myVariableTable, Settings.VarType.Number, name, defaultValue);
Settings.CreateDropdown(category, setting, GetOptions, tooltip);
]]--