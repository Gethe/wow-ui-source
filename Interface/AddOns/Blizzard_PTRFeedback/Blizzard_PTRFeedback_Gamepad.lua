function PTR_IssueReporter:RegisterForInterfaceTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function PTR_IssueReporter:SetupGamepad()
	local function TriggerIssueReport()
		PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.UIButtonClicked, PTR_IssueReporter.Data.CurrentBugButtonContext, PTR_IssueReporter.Data.ButtonDataPackage);
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end

	local promptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, TriggerIssueReport, "Report Issue");

	self.buttonFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "PTRIssueReporterFooter");
	self.buttonFooter:SetCustomAnchor(CreateAnchor("TOP", self.ReportBug, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin));
	self.buttonFooter:AddPromptedBinding(promptedBinding);
	self.buttonFooter:Finalize();

	self.oldOnShowScript = self:GetScript("OnShow");
end

function PTR_IssueReporter:OnGamepadMainMenuShow()
	self:Show();
	self.buttonFooter:ShowAndActivateBindings();
end

function PTR_IssueReporter:OnGamepadMainMenuHide()
	self.buttonFooter:HideAndDeactivateBindings();
	self:Hide();
end

function PTR_IssueReporter:InitializeGamepad()
	self:Hide();

	-- OnShow overrides the button position - disable this when gamepad is enabled
	self:SetScript("OnShow", nil);

	-- Instead position in the center
	self:ClearAllPoints();
	local yOffset = self.Body:GetHeight() / 2;
	self:SetPoint("CENTER", self:GetParent(), "CENTER", 0, yOffset);

	EventRegistry:RegisterCallback("Gamepad.ShowMainMenu", self.OnGamepadMainMenuShow, self);
	EventRegistry:RegisterCallback("Gamepad.HideMainMenu", self.OnGamepadMainMenuHide, self);
end

function PTR_IssueReporter:UninitializeGamepad()
	EventRegistry:UnregisterCallback("Gamepad.ShowMainMenu", self);
	EventRegistry:UnregisterCallback("Gamepad.HideMainMenu", self);

	-- Restore the old position handler
	if self.oldOnShowScript then
		self:SetScript("OnShow", self.oldOnShowScript);
	end

	self:Show();
end

local function SelectSurveyTextField(surveyFrame)
	for _, component in ipairs (surveyFrame.FrameComponents) do
		if (component.FrameType == "StandaloneQuestion") and (component.EditBox) then
			SmartNavigation:SetTargetButtonForFrame(surveyFrame, component.EditBox);
			return;
		end
	end
end

local function ClearSurveyTextFieldFocus(surveyFrame)
	for _, component in ipairs (surveyFrame.FrameComponents) do
		if (component.FrameType == "StandaloneQuestion") and (component.EditBox) and (component.EditBox:HasFocus()) then
			component.EditBox:ClearFocus();
			return;
		end
	end
end

function PTR_IssueReporter.RefreshStandaloneSurveyGamepad()
	if not (InputUtil.IsGamepadUIEnabled()) then
		return;
	end

	local surveyFrame = PTR_IssueReporter.StandaloneSurvey.SurveyFrame;
	SelectSurveyTextField(surveyFrame);
end

function PTR_IssueReporter.SetupStandaloneSurveyGamepad(titleBox)
	if not (InputUtil.IsGamepadUIEnabled()) then
		return;
	end

	local surveyFrame = titleBox.SurveyFrame;

	InputUtil.RegisterForInterfaceTransitions(surveyFrame);
	InputUtil.RegisterGamepadSetup(surveyFrame, function()
		surveyFrame.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(surveyFrame, "PTRIssueReporterSurvey");
		surveyFrame.gamepadFooter:SetCustomAnchor(CreateAnchor("TOP", titleBox.submitButton, "BOTTOM", 0, -PTR_IssueReporter.Data.FrameComponentMargin));
		surveyFrame.gamepadFooter:AddStandardSelectPrompt();
		surveyFrame.gamepadFooter:AddStandardBackPrompt();
		surveyFrame.gamepadFooter:Finalize();
	end)

	function surveyFrame:FocusGamepad()
		self.gamepadFooter:ShowAndActivateBindings();
		SelectSurveyTextField(self);
	end

	function surveyFrame:UnfocusGamepad()
		self.gamepadFooter:HideAndDeactivateBindings();
	end

	function surveyFrame:SmartNavigationCloseHandler()
		self:Hide();
		return true;
	end

	surveyFrame:HookScript("OnShow", function(self)
		if (InputUtil.IsGamepadUIEnabled()) then
			GamepadMode.FrameControlsManager:FrameShown(self);
		end
	end)

	surveyFrame:HookScript("OnHide", function(self)
		if (InputUtil.IsGamepadUIEnabled()) then
			GamepadMode.FrameControlsManager:FrameHidden(self);
		end
	end)
end

function PTR_IssueReporter.SetupAttachedSurveyGamepad(surveyFrame, panelFrame)
	if not (InputUtil.IsGamepadUIEnabled()) then
		return;
	end

	surveyFrame.useFooterJumpHints = true;
	surveyFrame.layoutType = "ButtonFrameTemplateNoPortrait";

	Mixin(surveyFrame, FocusFramesInterfaceMixin);

	surveyFrame.FrameGlow = CreateFrame("Frame", nil, surveyFrame, "FrameGlowTemplate");
	surveyFrame.FrameGlow:SetFrameLevel(505);
	surveyFrame.FrameGlow:Hide();

	surveyFrame.LeftJumpHint = CreateFrame("Frame", nil, surveyFrame, "FrameLeftJumpHintTemplate");
	surveyFrame.LeftJumpHint:SetFrameLevel(515);
	surveyFrame.LeftJumpHint:Hide();
	surveyFrame.RightJumpHint = CreateFrame("Frame", nil, surveyFrame, "FrameRightJumpHintTemplate");
	surveyFrame.RightJumpHint:SetFrameLevel(515);
	surveyFrame.RightJumpHint:Hide();
	surveyFrame.FocusJumpHint = CreateFrame("Frame", nil, surveyFrame, "FrameFocusJumpHintTemplate");
	surveyFrame.FocusJumpHint:SetFrameLevel(515);
	surveyFrame.FocusJumpHint:Hide();

	function surveyFrame:GetJumpHintLabel()
		return "Issue Reporter";
	end

	function surveyFrame:SmartNavigationCloseHandler()
		ClearSurveyTextFieldFocus(self);
		return GamepadMode.FrameControlsManager:FocusFrame(panelFrame);
	end

	InputUtil.RegisterForInterfaceTransitions(surveyFrame);
	InputUtil.RegisterGamepadSetup(surveyFrame, function()
		surveyFrame.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(surveyFrame, "PTRIssueReporterAttachedSurvey");
		surveyFrame.gamepadFooter:AddStandardSelectPrompt();
		surveyFrame.gamepadFooter:AddStandardFrameControlManagerBindings(surveyFrame);
		surveyFrame.gamepadFooter:AddStandardBackPrompt();
		surveyFrame.gamepadFooter:Finalize();
	end)

	function surveyFrame:FocusGamepad()
		self.gamepadFooter:ShowAndActivateBindings();
	end

	function surveyFrame:UnfocusGamepad()
		self.gamepadFooter:HideAndDeactivateBindings();
	end

	surveyFrame:HookScript("OnShow", function(self)
		if (InputUtil.IsGamepadUIEnabled()) then
			GamepadMode.FrameControlsManager:FrameShown(self, false, false);
		end
	end)

	surveyFrame:HookScript("OnHide", function(self)
		if (InputUtil.IsGamepadUIEnabled()) then
			GamepadMode.FrameControlsManager:FrameHidden(self);
		end
	end)
end
