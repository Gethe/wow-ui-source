local MAX_SUPPORTED_STEPS = 6; -- Number of steps in XML + 1

local function GetDiscreteProgressStepsVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.DiscreteProgressSteps, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateDiscreteProgressSteps"}, GetDiscreteProgressStepsVisInfoData);

local textureKitRegionInfo = {
	["Background"] = {formatString = "%s-bar", setVisibility = true, useAtlasSize = true},
};

local stepsTextureKitRegionInfo = {
	["Step1Background"] = {formatString = "%s-runebg", setVisibility = true, useAtlasSize = true},
	["Step2Background"] = {formatString = "%s-runebg", setVisibility = true, useAtlasSize = true},
	["Step3Background"] = {formatString = "%s-runebg", setVisibility = true, useAtlasSize = true},
	["Step4Background"] = {formatString = "%s-runebg", setVisibility = true, useAtlasSize = true},
	["Step5Background"] = {formatString = "%s-runebg", setVisibility = true, useAtlasSize = true},
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
};

local textureKitTooltipBackdropStyles = {
	["eyeofthejailer"] = GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY,
};

UIWidgetTemplateDiscreteProgressStepsMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplateDiscreteProgressStepsMixin:SetupStepAnchors(stepIndex, positionVector, rotationDegrees)
	positionVector:RotateDirection(math.rad(rotationDegrees));
	local x, y = positionVector:GetXY();

	self.Steps.BGArray[stepIndex]:SetPoint("CENTER", self.Steps, "CENTER", x, y);
	self.Steps.DisabledArray[stepIndex]:SetPoint("CENTER", self.Steps, "CENTER", x, y);
	self.Steps.EnabledArray[stepIndex]:SetPoint("CENTER", self.Steps, "CENTER", x, y);
	self.Steps.ActivationArray[stepIndex]:SetPoint("CENTER", self.Steps, "CENTER", x, y);
end

function UIWidgetTemplateDiscreteProgressStepsMixin:SetAnchors(numSteps, deadSpacePercentage)
	local deadSpaceDegrees = 360 * deadSpacePercentage;
	local aliveSpaceDegrees = 360 - deadSpaceDegrees;
	local stepDegrees = aliveSpaceDegrees / (numSteps + 1);
	local step1Degrees = (deadSpaceDegrees / 2) + stepDegrees;
	local positionVector = CreateVector2D(0, 53);

	for i = 1, numSteps do
		self:SetupStepAnchors(i, positionVector, i == 1 and step1Degrees or stepDegrees);
	end
end

function UIWidgetTemplateDiscreteProgressStepsMixin:OnLoad()
	UIWidgetBaseTemplateMixin.OnLoad(self);
	self.Steps:SetFrameLevel(self:GetFrameLevel() + 10);
	self.wasDeactivated = {};
	self.wasActivated = {};
end

function UIWidgetTemplateDiscreteProgressStepsMixin:EvaluateTutorials(textureKit)
	if textureKit == "eyeofthejailer" then
		local helpTipInfo = {
			text = EYE_OF_JAILER_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_EYE_OF_JAILER,
			checkCVars = true,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetY = -20,
			extraRightMarginPadding = 12, 
		};
		HelpTip:Show(self, helpTipInfo);
	end
end 

-- Adjusts progCurr to account for the space under each step background (so each section of the bar goes up the edge of each step background)
function UIWidgetTemplateDiscreteProgressStepsMixin:GetAdjustedCurrentValue(progCurr, progMin, range, numSteps, stepSize, stepsCompleted, stepCoverPercentage)
	if stepsCompleted == numSteps then
		-- Nothing to do, the bar is full
		return progCurr;
	end

	local deadSpacePercentageInCurrentStep;
	
	if (stepsCompleted == 0) or (stepsCompleted == numSteps - 1) then
		-- If we are before the first step or after the last step, we only need to remove half of stepCoverPercentage (because there is no step at each end point)
		deadSpacePercentageInCurrentStep = stepCoverPercentage / 2;
	else
		deadSpacePercentageInCurrentStep = stepCoverPercentage;
	end

	local deadSpaceProgressInCurrentStep = range * deadSpacePercentageInCurrentStep;
	local newStepSize = stepSize - deadSpaceProgressInCurrentStep;

	local lastStepProg = progMin + stepsCompleted * stepSize;
	local nextStepProg = progMin + (stepsCompleted + 1) * stepSize;

	local percentageToNextStep = ClampedPercentageBetween(progCurr, lastStepProg, nextStepProg);

	if stepsCompleted == 0 then
		return progMin + percentageToNextStep * newStepSize;
	elseif progCurr == lastStepProg then
		return progCurr;
	else
		local lastStepProgNoDeadSpace = lastStepProg + (range * (stepCoverPercentage / 2));
		return lastStepProgNoDeadSpace + percentageToNextStep * newStepSize;
	end
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

	local range = progMax - progMin;
	local stepSize = range / numSteps;
	local stepsCompleted = math.floor((progCurr - progMin) / stepSize);

	local stepCoverPercentage = 0.1;
	local adjustedProgCurr = self:GetAdjustedCurrentValue(progCurr, progMin, range, numSteps, stepSize, stepsCompleted, stepCoverPercentage);

	local deadSpacePercentage = 0.2;
	self.Bar:Setup(widgetContainer, progMin, progMax, adjustedProgCurr, deadSpacePercentage, textureKit);

	local tooltipTextureKit = strsub(textureKit, 1, 14);
	self.tooltipBackdropStyle = textureKitTooltipBackdropStyles[tooltipTextureKit];

	SetupTextureKitsFromRegionInfo(textureKit, self, textureKitRegionInfo);
	SetupTextureKitsFromRegionInfo(textureKit, self.Steps, stepsTextureKitRegionInfo);
	self:SetAnchors(numSteps - 1, deadSpacePercentage);
	self:SetTooltip(widgetInfo.tooltip);
	if ( (progMin >= progMax) ) then
		-- Show an obvious error state.
		self.Steps.Step1Disabled:Show();
		self.Steps.Step1Enabled:Hide();
		for i = 2, MAX_SUPPORTED_STEPS - 1 do
			self.Steps.EnabledArray[i]:Hide();
			self.Steps.DisabledArray[i]:Hide();
		end
		return;
	end

	for i = 1, math.min(stepsCompleted, numSteps - 1) do
		self.Steps.EnabledArray[i]:Show();
		if ( self.wasDeactivated[i] ) then
			self.Steps.ActivationAnimArray[i]:Play();
		end
		self.wasDeactivated[i] = false;
		self.wasActivated[i] = true;
	end
	for i = stepsCompleted + 1, numSteps - 1 do
		self.Steps.ActivationArray[i]:Hide();
		if ( self.wasActivated[i] ) then
			self.Steps.DisableAnimArray[i]:Play();
		else
			self.Steps.EnabledArray[i]:Hide();
		end
		self.wasDeactivated[i] = true;
		self.wasActivated[i] = false;
	end
	if numSteps < MAX_SUPPORTED_STEPS then
		for i = numSteps, MAX_SUPPORTED_STEPS - 1 do
			self.Steps.ActivationAnimArray[i]:Stop();
			self.Steps.DisableAnimArray[i]:Stop();
			self.Steps.ActivationArray[i]:Hide();
			self.Steps.BGArray[i]:Hide();
			self.Steps.EnabledArray[i]:Hide();
			self.Steps.DisabledArray[i]:Hide();
			self.wasDeactivated[i] = false;
			self.wasActivated[i] = false;
		end
	end
	self:EvaluateTutorials(textureKit);
end

function UIWidgetTemplateDiscreteProgressStepsMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.wasDeactivated = {};
	self.wasActivated = {};
	for i = 1, MAX_SUPPORTED_STEPS - 1 do
		self.Steps.ActivationAnimArray[i]:Stop();
		self.Steps.DisableAnimArray[i]:Stop();
		self.Steps.EnabledArray[i]:Hide();
		self.Steps.DisabledArray[i]:Hide();
		self.Steps.ActivationArray[i]:Hide();
	end
end