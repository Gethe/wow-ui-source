----
-- Character Services uses a master which acts as a sort of state machine in combination with flows and blocks.
--
-- Flows must have the following functions:
--  :Finish(controller):  Finishes the flow and does whatever it needs to process the data.  Should return true if completed sucessfully or false if it failed.
--
-- The methods are provided by a base class for all flows but may be overridden if necessary:
--  :Initialize(controller):  This sets up the flow and any associated blocks.
--  :Advance(controller):  Advances the flow one step.
--  :SetUpBlock(controller): This sets up the current block for the given step.
--  :Rewind(controller): Backs the flow up to the next available step.
--  :HideBlock():  Hides the current block.
--  :Restart(controller):  Hide all blocks and restart the flow at step 1.
--  :OnHide():  Check each block for a :OnHide method and call it if it exists.
--  :GetFinishLabel(): The label for the final step of a flow is updated every time the flow is updated (going to next step, etc) this allows a dynamic string to be used.
--
-- Flows should have the following members:
--  .data - reference to an entry in CharacterUpgrade_Items with display info
--  .FinishLabel - The label to show on the finish button for this flow.
--
-- The following members may be present on a flow:
--  .AutoCloseAfterFinish - If true the flow will automatically close down the controller when completed, this can be necessary when there's no finish button.
--
-- Blocks are opaque data structures.  Frames that belong to blocks inherit the template for blocks, and all controls used for data collection must be in the ControlsFrame.
--
-- Blocks must have the following methods:
--  :Initialize(results, wasFromRewind) - Initializes the block and any controls to the active state.  The argument wasFromRewind indicates whether or not this block is being checked due to the user returning to this step.
--  :IsFinished(wasFromRewind) - Returns whether or not the block is finished and its result set. The argument wasFromRewind indicates whether or not this block is being checked due to the user returning to this step.
--  :GetResult() - Gets the result from the block in a table passed back to the flow.
--
-- The following optional methods may be present on a block:
--  :FormatResult() - Formats the result for display with the result label.  If absent, :GetResult() will be used instead.
--  :OnHide() - This function is called when a block needs to handle any resetting when the flow is hidden.
--  :OnAdvance() - This function is called in response to the flow:Advance call if the block needs to handle any logic here.
--  :OnRewind() - This function is called in response to the flow:Rewind call if the block needs to handle any logic here.
--  :SkipIf() - Skip this block if a certain result is present
--  :OnSkip() - If you have a SkipIf() then OnSkip() will perform any actions you need if you are skipped.
--  :ShouldShowPopup() - If you have a .Popup, then ShouldShowPopup will perform a check if the popup should appear.
--  :GetPopupText() - If you have a .Popup, then GetPopupText fetch the text to display.
--
-- The following members must be present on a block:
--  .Back - Show the back button on the flow frame.
--  .Next - Show the next button on the flow frame.  Conflicts with .Finish
--  .Finish - Show the finish button on the flow frame.  Conflicts with .Next

-- The following must be on all blocks not marked as HiddenStep:
--  .ActiveLabel - The label to show when the block is active above the controls.
--  .ResultsLabel - The label to show when the block is finished above the results themselves.
--
-- The following members may be present on a block:
--  .AutoAdvance - If true the flow will automatically advance when the block is finished and will not wait for user input.
--  .HiddenStep - This is only valid for the end step of any flow.  This says that this block has no meaningful controls or results for the user and should instead just
--    cause the master to change the flow controls.
--  .SkipOnRewind - This tells the flow to ignore the :IsFinished() result when deciding where to rewind and instead skip this block.
--  .ExtraOffset - May be set on a block by the flow for the master to add extra vertical offset to a block based on previous results.
--  .Popup - May be set on a block to potentially show a popup before advancing to the next step.
--
-- However a block uses controls to gather data, once it has data and is finished it should call
-- CharacterServicesMaster_Update() to advance the flow and button states.
----

CharacterServicesFlowMixin = {};

function CharacterServicesFlowMixin:Initialize(controller)
	for index, block in ipairs(self.Steps) do
		block.frame = _G[block.FrameName];
	end

	self:Restart(controller);
end

function CharacterServicesFlowMixin:BuildResults(steps)
	self.results = {};
	for i = 1, steps do
		for k,v in pairs(self:GetStep(i):GetResult()) do
			self.results[k] = v;
		end
	end
	return self.results;
end

function CharacterServicesFlowMixin:Advance(controller)
	if (self.step == self:GetNumSteps()) then
		self:Finish(controller);

		if self.AutoCloseAfterFinish then
			controller:GetParent():Hide();
		end
	else
		local block = self:GetCurrentStep();
		if (block.OnAdvance) then
			block:OnAdvance();
		end

		local results = self:BuildResults(self.step);
		if self.OnAdvance then
			self:OnAdvance(controller, results);
		end

		self.step = self.step + 1;

		local currentStep = self:GetCurrentStep();

		while (currentStep.SkipIf and currentStep:SkipIf(results)) do
			if (currentStep.OnSkip) then
				currentStep:OnSkip();
			end

			self.step = self.step + 1;
			currentStep = self:GetCurrentStep();
		end

		self:SetUpBlock(controller, results);
	end
end

function CharacterServicesFlowMixin:Rewind(controller)
	local block = self:GetCurrentStep();
	local results;
	local wasFromRewind = true;

	if (block.OnRewind) then
		block:OnRewind();
	end

	if (block:IsFinished(wasFromRewind) and not block.SkipOnRewind) then
		if (self.step ~= 1) then
			results = self:BuildResults(self.step - 1);
		end
		self:SetUpBlock(controller, results, wasFromRewind);
	else
		self:HideBlock(self.step);
		self.step = self.step - 1;
		local currentStep = self:GetCurrentStep();
		while (currentStep.SkipOnRewind ) do
			if (currentStep.OnRewind) then
				currentStep:OnRewind();
			end
			self:HideBlock(self.step);
			self.step = self.step - 1;
			currentStep = self:GetCurrentStep();
		end

		if (self.step ~= 1) then
			results = self:BuildResults(self.step - 1);
		end
		self:SetUpBlock(controller, results, wasFromRewind);
	end
end

function CharacterServicesFlowMixin:RequestRewind()
	self.rewindRequested = true;
end

function CharacterServicesFlowMixin:CheckRewind(controller)
	if self.rewindRequested then
		self.rewindRequested = false;
		self:Rewind(controller);
	end
end

function CharacterServicesFlowMixin:HideBlocks()
	for i = 1, #self.Steps do
		self:HideBlock(i);
	end
end

function CharacterServicesFlowMixin:Restart(controller)
	CharSelectServicesFlowFrame:ClearErrorMessage();
	self:HideBlocks()

	self.step = 1;
	self.warningAccepted = nil;
	self:SetUpBlock(controller);
end

function CharacterServicesFlowMixin:MoveBlock(block, offset)
	local extraOffset = block.ExtraOffset or 0;
	local lastNonHiddenStep = self.step - 1;
	while (self:GetStep(lastNonHiddenStep).HiddenStep and lastNonHiddenStep >= 1) do
		lastNonHiddenStep = lastNonHiddenStep - 1;
	end

	if (lastNonHiddenStep >= 1) then
		block.frame:SetPoint("TOP", self:GetStep(lastNonHiddenStep).frame, "TOP", 0, offset - extraOffset);
	end
end

local stepTextures = {
	[1] = { 0.16601563, 0.23535156, 0.00097656, 0.07812500 },
	[2] = { 0.23730469, 0.30664063, 0.00097656, 0.07812500 },
	[3] = { 0.30859375, 0.37792969, 0.00097656, 0.07812500 },
	[4] = { 0.37988281, 0.44921875, 0.00097656, 0.07812500 },
	[5] = { 0.45117188, 0.52050781, 0.00097656, 0.07812500 },
	[6] = { 0.52246094, 0.59179688, 0.00097656, 0.07812500 },
	[7] = { 0.59375000, 0.66308594, 0.00097656, 0.07812500 },
	[8] = { 0.66503906, 0.73437500, 0.00097656, 0.07812500 },
	[9] = { 0.73632813, 0.80566406, 0.00097656, 0.07812500 },
};

function CharacterServicesFlowMixin:SetUpBlock(controller, results, wasFromRewind)
	local block = self:GetCurrentStep();
	CharacterServicesMaster_SetCurrentBlock(controller, block, wasFromRewind);
	if (not block.HiddenStep) then
		if (self.step == 1) then
			block.frame:SetPoint("TOP", CharacterServicesMaster, "TOP", -30, 0);
		else
			self:MoveBlock(block, -105);
		end
		block.frame.StepNumber:SetTexCoord(unpack(stepTextures[self.step]));
		block.frame:Show();
	end
	block:Initialize(results, wasFromRewind);
	CharacterServicesMaster_Update();
end

function CharacterServicesFlowMixin:HideBlock(step)
	local block = self:GetStep(step);
	if (not block.HiddenStep and block.frame) then
		block.frame:Hide();
	end
end

function CharacterServicesFlowMixin:OnHide()
	for index, block in ipairs(self.Steps) do
		if (block.OnHide) then
			block:OnHide();
		end
	end
end

function CharacterServicesFlowMixin:GetFinishLabel()
	return self.FinishLabel or "";
end

function CharacterServicesFlowMixin:SetTarget(data)
	self.data = data;
end

function CharacterServicesFlowMixin:GetCurrentStep()
	return self:GetStep(self.step);
end

function CharacterServicesFlowMixin:GetStep(stepIndex)
	return self.Steps[stepIndex];
end

function CharacterServicesFlowMixin:GetNumSteps()
	return #self.Steps;
end

function CharacterServicesFlowMixin:IsAllFinished()
	local lastStep = self:GetStep(self:GetNumSteps());
	return lastStep:IsFinished();
end

function CharacterServicesFlowMixin:IsWarningAccepted()
	return self.warningAccepted;
end

function CharacterServicesFlowMixin:ShouldFinishBehaveLikeNext()
	-- Override as needed
	return false;
end

GlueDialogTypes["CHARACTER_SERVICES_CHECK_APPLY"] = {
	text = "",
	button1 = "",
	button2 = "",
	OnAccept = function()
		local flow = GlueDialog.data;
		flow:SetWarningAccepted(true);
	end,

	OnCancel = function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local flow = GlueDialog.data;
		flow:SetWarningAccepted(false);
	end,

	OnShow = function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
		CharacterSelect_UpdateButtonState();
		CharSelectServicesCover:Show();
		CharacterServicesMaster_UpdateServiceButton();
	end,

	OnHide = function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
		CharacterSelect_UpdateButtonState();
		CharSelectServicesCover:Hide();
		CharacterServicesMaster_UpdateServiceButton();
	end,
};

function CharacterServicesFlow_ShowFinishConfirmation(data, bodyText, acceptText, cancelText)
	local warningDialog = GlueDialogTypes["CHARACTER_SERVICES_CHECK_APPLY"];
	warningDialog.button1 = acceptText;
	warningDialog.button2 = cancelText;

	GlueDialog_Show("CHARACTER_SERVICES_CHECK_APPLY", bodyText, data);
end