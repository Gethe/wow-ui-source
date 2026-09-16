local DEFAULT_UIPANEL_LAYOUT_ATTRIBUTES = {
	DEFAULT_FRAME_WIDTH = 384,
	TOP_OFFSET = -116,
	LEFT_OFFSET = 16,
	CENTER_OFFSET = 384,
	RIGHT_OFFSET = 768,
	RIGHT_OFFSET_BUFFER = 80,
	PANEl_SPACING_X = 32,
};

UIPanelLayoutFrame = CreateFrame("FRAME", "UIPanelLayoutFrame", UIParent);

for name, value in pairs(DEFAULT_UIPANEL_LAYOUT_ATTRIBUTES) do
	UIPanelLayoutFrame:SetAttribute(name, value);
end

function GetUIPanelLayoutFrame()
	return UIPanelLayoutFrame;
end

function GetUIPanelLayoutAttribute(name)
	return UIPanelLayoutFrame:GetAttribute(name);
end

function SetUIPanelLayoutAttribute(name, value)
	UIPanelLayoutFrame:SetAttribute(name, value);
end
