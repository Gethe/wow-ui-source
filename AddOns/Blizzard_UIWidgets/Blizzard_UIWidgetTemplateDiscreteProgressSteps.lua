local MAX_SUPPORTED_STEPS = 6; -- Number of steps in XML + 1

local function GetDiscreteProgressStepsVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DiscreteProgressSteps, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDiscreteProgressSteps"}, GetDiscreteProgressStepsVisInfoData);

local textureKitRegionInfo = {
	["Step1Disabled"] = {formatString = "%s-step1-disable", setVisibility = true, useAtlasSize = true},
	["Step2Disabled"] = {formatString = "%s-step2-disable", setVisibility = true, useAtlasSize = true},
	["Step3Disabled"] = {formatString = "%s-step3-disable", setVisibility = true, useAtlasSize = true},
	["Step4Disabled"] = {formatString = "%s-step4-disable", setVisibility = true, useAtlasSize = true},
	["Step5Disabled"] = {formatString = "%s-step5-disable", setVisibility = true, useAtlasSize = true},
	["Step1Enabled"] = {formatString = "%s-step1-enable", setVisibility = false, useAtlasSize = true},
	["Step2Enabled"] = {formatString = "%s-step2-enable", setVisibility = false, useAtlasSize = true},
	["Step3Enabled"] = {formatString = "%s-step3-enable", setVisibility = false, useAtlasSize = true},
	["Step4Enabled"] = {formatString = "%s-step4-enable", setVisibility = false, useAtlasSize = true},
	["Step5Enabled"] = {formatString = "%s-step5-enable", setVisibility = false, useAtlasSize = true},
	["Step1Activation"] = {formatString = "%s-step1-enable", setVisibility = false, useAtlasSize = true},
	["Step2Activation"] = {formatString = "%s-step2-enable", setVisibility = false, useAtlasSize = true},
	["Step3Activation"] = {formatString = "%s-step3-enable", setVisibility = false, useAtlasSize = true},
	["Step4Activation"] = {formatString = "%s-step4-enable", setVisibility = false, useAtlasSize = true},
	["Step5Activation"] = {formatString = "%s-step5-enable", setVisibility = false, useAtlasSize = true},
}

UIWidgetTemplateDiscreteProgressStepsMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateDiscreteProgressStepsMixin:SetAnchors()
	-- Hard-coded for Eye of the Jailer configuration. Anchoring here so that it is easier to anchor for other widget uses.
	self.Step1Enabled:SetPoint("CENTER", self, "CENTER", -55, -10);
	self.Step1Disabled:SetPoint("CENTER", self, "CENTER", -55, -10);
	self.Step1Activation:SetPoint("CENTER", self, "CENTER", -55, -10);
	self.Step2Enabled:SetPoint("CENTER", self, "CENTER", -40, -40);
	self.Step2Disabled:SetPoint("CENTER", self, "CENTER", -40, -40);
	self.Step2Activation:SetPoint("CENTER", self, "CENTER", -40, -40);
	self.Step3Enabled:SetPoint("CENTER", self, "CENTER", 0, -60);
	self.Step3Disabled:SetPoint("CENTER", self, "CENTER", 0, -60);
	self.Step3Activation:SetPoint("CENTER", self, "CENTER", 0, -60);
	self.Step4Enabled:SetPoint("CENTER", self, "CENTER", 40, -40);
	self.Step4Disabled:SetPoint("CENTER", self, "CENTER", 40, -40);
	self.Step4Activation:SetPoint("CENTER", self, "CENTER", 40, -40);
	self.Step5Enabled:SetPoint("CENTER", self, "CENTER", 55, -10);
	self.Step5Disabled:SetPoint("CENTER", self, "CENTER", 55, -10);
	self.Step5Activation:SetPoint("CENTER", self, "CENTER", 55, -10);
end

function UIWidgetTemplateDiscreteProgressStepsMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	self.wasDeactivated = {};
	self.wasActivated = {};
end

function UIWidgetTemplateDiscreteProgressStepsMixin:Setup(widgetInfo, widgetContainer)
	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);

	local textureKit = widgetInfo.textureKit;
	local progMin = widgetInfo.progressMin;
	local progMax = widgetInfo.progressMax;
	local progCurr = widgetInfo.progressVal;
	local numSteps = widgetInfo.numSteps;
	numSteps = Clamp(numSteps, 1, MAX_SUPPORTED_STEPS);
	progCurr = Clamp(progCurr, progMin, progMax);
	SetupTextureKitsFromRegionInfo(textureKit, self, textureKitRegionInfo);
	self:SetAnchors();
	self:SetTooltip(widgetInfo.tooltip);
	if ( (progMin >= progMax) ) then
		-- Show an obvious error state.
		self.Step1Disabled:Show();
		self.Step1Enabled:Hide();
		for i = 2, MAX_SUPPORTED_STEPS - 1 do
			self.EnabledArray[i]:Hide();
			self.DisabledArray[i]:Hide();
		end
		return;
	end

	local stepSize = (progMax - progMin) / numSteps;
	local stepsCompleted = math.floor((progCurr - progMin) / stepSize);
	for i = 1, math.min(stepsCompleted, numSteps - 1) do
		self.EnabledArray[i]:Show();
		if ( self.wasDeactivated[i] ) then
			self.ActivationAnimArray[i]:Play();
		end
		self.wasDeactivated[i] = false;
		self.wasActivated[i] = true;
	end
	for i = stepsCompleted + 1, numSteps - 1 do
		self.ActivationArray[i]:Hide();
		if ( self.wasActivated[i] ) then
			self.DisableAnimArray[i]:Play();
		else
			self.EnabledArray[i]:Hide();
		end
		self.wasDeactivated[i] = true;
		self.wasActivated[i] = false;
	end
end

function UIWidgetTemplateDiscreteProgressStepsMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.wasDeactivated = {};
	self.wasActivated = {};
	for i = 1, MAX_SUPPORTED_STEPS - 1 do
		self.ActivationAnimArray[i]:Stop();
		self.DisableAnimArray[i]:Stop();
		self.EnabledArray[i]:Hide();
		self.DisabledArray[i]:Hide();
		self.ActivationArray[i]:Hide();
	end
end