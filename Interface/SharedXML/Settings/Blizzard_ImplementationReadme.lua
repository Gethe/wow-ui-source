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
Settings.RegisterCategory(category);

-- To assign a subcategory:
local category = category or Settings.GetCategory("My Category Name");

-- a frame:
local category = category or Settings.GetCategory("My Category Name");
local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, "My Subcategory Name");

-- or a settings list:
local subcategory, layout = Settings.RegisterVerticalLayoutSubcategory(category, "My Subcategory Name");
... setting initializers assigned to layout.
Settings.RegisterCategory(subcategory);


]]--