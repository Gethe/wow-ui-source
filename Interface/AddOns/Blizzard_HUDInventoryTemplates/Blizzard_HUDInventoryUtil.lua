
HUDInventoryUtil = {};

local hudElements = {};

function HUDInventoryUtil.RegisterHUDElement(hudElement)
	table.insert(hudElements, hudElement);
end

function HUDInventoryUtil.DoQuickKeybindModeChange(showQuickKeybindMode)
	for _, hudElement in ipairs(hudElements) do
		hudElement:DoQuickKeybindModeChange(showQuickKeybindMode);
	end
end
