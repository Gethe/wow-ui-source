-- There are no consumers of these events when this file is loaded because UIParent
-- is always the first frame to be loaded and shown.
assert(UIParent:IsShown());

UIParent:SetScript("OnShow", function()
	EventRegistry:TriggerEvent("UI.TopLevelParentShown");
end);

UIParent:SetScript("OnHide", function()
	EventRegistry:TriggerEvent("UI.TopLevelParentHidden");
end);
