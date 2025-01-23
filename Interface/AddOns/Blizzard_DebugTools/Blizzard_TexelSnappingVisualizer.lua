if not IsGMClient() then
	return; -- This tool only functions in GM builds
end

if C_Glue.IsOnGlueScreen() then
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

	local dropdownFrame = FrameUtil.CreateFrame(nil, self, "WowStyle1DropdownTemplate");
	do
		dropdownFrame:SetPoint("TOPLEFT", 20, -40);
			
		local function IsSelected(value)
			return GetCVar("overridePixelGridSnapping") == value;
		end

		local function SetSelected(value)
			SetCVar("overridePixelGridSnapping", value); 
		end

		dropdownFrame:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_TEXEL_VIS");

			rootDescription:CreateRadio("Default", IsSelected, SetSelected, "-1");
			rootDescription:CreateRadio("Override On", IsSelected, SetSelected, "1");
			rootDescription:CreateRadio("Override Off", IsSelected, SetSelected, "0");
		end);
	end

	do
		local dropdownLabel = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
		dropdownLabel:SetText("Vertex Pixel Snapping:");
		dropdownLabel:SetPoint("BOTTOMLEFT", dropdownFrame, "TOPLEFT", 0, 3);
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

Mixin(CreateFrame("FRAME", "TexelSnappingVisualizer", UIParent, "TooltipBackdropTemplate"), TexelSnappingVisualizerMixin):OnCreated();
