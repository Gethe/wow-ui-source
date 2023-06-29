if not IsGMClient() then
	return; -- This tool only functions in GM builds
end

if IsOnGlueScreen() then
	return;
end

TexelSnappingVisualizerMixin = {};

function TexelSnappingVisualizerMixin:OnCreated()
	self:Hide();

	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnMouseDown", self.StartMoving);
	self:SetScript("OnMouseUp", self.StopMovingOrSizing);

	self:SetSize(300, 150);
	self:SetPoint("CENTER");
	self:SetFrameStrata("DIALOG");
	self:EnableMouse(true);
	self:SetClampedToScreen(true);
	self:SetMovable(true);

	self:SetBackdropColor(0, 0, 0);

	do
		local titleLabel = self:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		titleLabel:SetText("Texel Snapping Vis");
		titleLabel:SetPoint("TOP", 0, -8);
	end

	local dropdownFrame = CreateFrame("FRAME", nil, self, "UIDropDownMenuTemplate");
	do
		dropdownFrame:SetPoint("TOPLEFT", 0, -40);

		local function OpenDropdown(dropdownFrame, level, menuList)
			self:OpenDropdown(dropdownFrame, level, menuList);
		end
		UIDropDownMenu_Initialize(dropdownFrame, OpenDropdown);
		UIDropDownMenu_SetSelectedValue(dropdownFrame, GetCVar("overridePixelGridSnapping"));
	end

	do
		local dropdownLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		dropdownLabel:SetText("Vertex Pixel Snapping:");
		dropdownLabel:SetPoint("BOTTOMLEFT", dropdownFrame, "TOPLEFT", 10, 3);
	end

	do
		local texelSnappingSlider = CreateFrame("SLIDER", nil, self, "UISliderTemplate");
		texelSnappingSlider:SetPoint("BOTTOM", self, "BOTTOM", 0, 15);
		texelSnappingSlider:SetSize(200, 16);
		local MIN_VALUE = -.25;
		texelSnappingSlider:SetMinMaxValues(MIN_VALUE, 1);

		local texelSnappingLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		texelSnappingLabel:SetPoint("TOP", texelSnappingSlider, "TOP", 0, 30);

		texelSnappingSlider:SetScript("OnValueChanged", function(self, value)
			if value < 0 and value < MIN_VALUE * .5 then
				texelSnappingSlider:SetValue(MIN_VALUE);
				SetCVar("overrideTexelSnappingBias", "-1");

				texelSnappingLabel:SetFormattedText("Texel Snapping Strength: %s", YELLOW_FONT_COLOR:WrapTextInColorCode("Default"));
			else
				local clampedValue = Clamp(value, 0, 1);
				SetCVar("overrideTexelSnappingBias", clampedValue);
				texelSnappingSlider:SetValue(clampedValue);

				local textValue = clampedValue == 0 and RED_FONT_COLOR:WrapTextInColorCode("Forced Off") or LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(FormatPercentage(clampedValue));
				texelSnappingLabel:SetFormattedText("Texel Snapping Strength: %s", textValue);
			end
		end);
		texelSnappingSlider:SetValue(tonumber(GetCVar("overrideTexelSnappingBias")) or 0);

		do
			local defaultLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
			defaultLabel:SetText("Default");
			defaultLabel:SetPoint("RIGHT", texelSnappingSlider, "LEFT", 0, 0);

			local forceOffLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
			forceOffLabel:SetText("Force Off");
			forceOffLabel:SetPoint("BOTTOM", texelSnappingSlider, "TOP", texelSnappingSlider:GetWidth() * MIN_VALUE, 0);

			local forceOffMax = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
			forceOffMax:SetText("Max");
			forceOffMax:SetPoint("LEFT", texelSnappingSlider, "RIGHT", 0, 0);

			local forceOffTick = self:CreateTexture(nil, "OVERLAY");
			forceOffTick:SetColorTexture(1, 1, 1, 1);
			forceOffTick:SetSize(2, 16);
			forceOffTick:SetPoint("CENTER", texelSnappingSlider, "CENTER", texelSnappingSlider:GetWidth() * MIN_VALUE, 0);
		end
	end

	do
		local closeButton = CreateFrame("BUTTON", nil, self, "UIPanelCloseButton");
		closeButton:SetPoint("TOPRIGHT", -5, -5);
		closeButton:SetScript("OnClick", function() self:Hide() end);
	end
end

local PIXEL_SNAPPING_OPTIONS = {
	{ text = "Default", cvarValue = "-1" },
	{ text = "Override On", cvarValue = "1" },
	{ text = "Override Off", cvarValue = "0" },
};

function TexelSnappingVisualizerMixin:OpenDropdown(dropdownFrame, level, menuList)
	for i, pixelSnappingOptions in ipairs(PIXEL_SNAPPING_OPTIONS) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = pixelSnappingOptions.text;
		info.checked = GetCVar("overridePixelGridSnapping") == pixelSnappingOptions.cvarValue;
		info.func = function() 
			SetCVar("overridePixelGridSnapping", pixelSnappingOptions.cvarValue); 
			UIDropDownMenu_SetSelectedValue(dropdownFrame, pixelSnappingOptions.cvarValue); 
		end;
		info.value = pixelSnappingOptions.cvarValue;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
end

Mixin(CreateFrame("FRAME", "TexelSnappingVisualizer", UIParent, "TooltipBackdropTemplate"), TexelSnappingVisualizerMixin):OnCreated();
