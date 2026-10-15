-- Utility functions
function toCharacterNameCasing(name)
	return C_CharacterServices.CapitalizeCharName(name);
end

function RequestAssignPNCForResults(results, isValidationOnly)
	return C_CharacterServices.AssignNameChangeDistribution(
		results.selectedCharacterGUID,
		results.name,
		results.surname,
		isValidationOnly,
		Enum.ValueAddedServiceType.PaidNameChange
	);
end

-- Flow functions
-- PNCCharacterSelectBlock
PNCCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	PNCCharacterSelectBlock.FrameName = "PNCCharacterSelect";
	PNCCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	PNCCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function PNCCharacterSelectBlock:SetResultsShown(shown)
	self.frame.ResultsFrame:SetShown(shown);
end

function PNCCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForPNC(characterID);
	serviceInfo.isEligible = canTransferCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	return serviceInfo;
end

-- PNCNameSelect
PNCNameSelectBlock = {
	FrameName = "PNCNameSelect",
	Back = true,
	ActiveLabel = C_CharacterCreation.AreRegionalUniqueNamesEnabled() and PNC_FLOW_SLECT_FULL_NAME_ACTIVE or PNC_FLOW_SLECT_NAME_ACTIVE,
	ResultsLabel = C_CharacterCreation.AreRegionalUniqueNamesEnabled() and PNC_FLOW_SLECT_FULL_NAME_RESULTS or PNC_FLOW_SLECT_NAME_RESULTS,
};

function PNCNameSelectBlock:Initialize(results, wasFromRewind)
	local newNameEditbox = self.frame.ControlsFrame.NewNameEditbox;
	local newSurnameLabel = self.frame.ControlsFrame.NewSurnameLabel;
	local newSurnameEditbox = self.frame.ControlsFrame.NewSurnameEditbox;

	if not wasFromRewind then
		local checkUpdate = function()
			self:CheckUpdate();
		end

		newNameEditbox:SetOnTextChangedCallback(checkUpdate);
		newSurnameEditbox:SetOnTextChangedCallback(checkUpdate);
	end

	newNameEditbox:Initialize(results, wasFromRewind);
	newSurnameEditbox:Initialize(results, wasFromRewind);

	newSurnameLabel:SetShown(newSurnameLabel:ShouldShow());
	newSurnameEditbox:SetShown(newSurnameEditbox:ShouldShow());

	if C_CharacterCreation.AreRegionalUniqueNamesEnabled() then
		self.frame.ControlsFrame.NewNameLabel:SetText(PNC_FLOW_NEW_MAIN_NAME_LABEL);
	end

	self:CheckUpdate();
end

function PNCNameSelectBlock:CheckUpdate()
	CharacterServicesMaster_Update();
end

function PNCNameSelectBlock:GetResult()
	local formatedName = toCharacterNameCasing(self.frame.ControlsFrame.NewNameEditbox:GetNewName());
	local formattedSurname = toCharacterNameCasing(self.frame.ControlsFrame.NewSurnameEditbox:GetNewSurname());
	return {
		name = formatedName,
		surname = formattedSurname,
	}
end

function PNCNameSelectBlock:IsFinished(wasFromRewind)
	if wasFromRewind then
		return false;
	end

	local result = self:GetResult();
	local hasValidName = result.name and #result.name > 2;
	local hasValidSurname = true;
	if self.frame.ControlsFrame.NewSurnameEditbox:IsShown() then
		hasValidSurname = result.surname and #result.surname > 2;
	end

	if hasValidName and hasValidSurname then
		return true;
	end

	return false;
end

NewNameEditboxMixin = {};

function NewNameEditboxMixin:Initialize(_, wasFromRewind)
	if not wasFromRewind then
		self:SetText("");
	end
	self:SetMaxLetters(12); -- From CharacterNameStringConsts::CHARACTERNAME in CharacterConstants.tag.
end

function NewNameEditboxMixin:OnEnter()
	GetAppropriateTooltip():SetOwner(self, "ANCHOR_RIGHT");
	GetAppropriateTooltip():SetText(VAS_NAME_CHANGE_TOOLTIP);
	GetAppropriateTooltip():Show();
end

function NewNameEditboxMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function NewNameEditboxMixin:GetNewName()
	return self:GetText() or nil;
end

function NewNameEditboxMixin:SetOnTextChangedCallback(callback)
	self.callback = callback;
end

function NewNameEditboxMixin:OnTextChanged()
	if self.callback then
		self.callback();
	end
end

function NewNameEditboxMixin:OnTabPressed()
	if (not self:GetParent().NewSurnameEditbox:IsShown()) then
		return;
	end

	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().NewSurnameEditbox:SetFocus();
end

NewSurnameLabelMixin = {};

function NewSurnameLabelMixin:ShouldShow()
	return C_CharacterCreation.AreRegionalUniqueNamesEnabled();
end

NewSurnameEditboxMixin = {};

function NewSurnameEditboxMixin:Initialize(_, wasFromRewind)
	if not wasFromRewind then
		self:SetText("");
	end
	self:SetMaxLetters(12); -- From CharacterNameStringConsts::SURNAMEUSERINPUT in CharacterConstants.tag.
end

function NewSurnameEditboxMixin:OnEnter()
	GetAppropriateTooltip():SetOwner(self, "ANCHOR_RIGHT");
	GetAppropriateTooltip():SetText(VAS_NAME_CHANGE_TOOLTIP);
	GetAppropriateTooltip():Show();
end

function NewSurnameEditboxMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function NewSurnameEditboxMixin:GetNewSurname()
	return self:IsShown() and self:GetText() or "";
end

function NewSurnameEditboxMixin:SetOnTextChangedCallback(callback)
	self.callback = callback;
end

function NewSurnameEditboxMixin:OnTextChanged()
	if self.callback then
		self.callback();
	end
end

function NewSurnameEditboxMixin:OnTabPressed()
	self:ClearFocus();
	EditBox_ClearHighlight(self);
	self:GetParent().NewNameEditbox:SetFocus();
end

function NewSurnameEditboxMixin:ShouldShow()
	return C_CharacterCreation.AreRegionalUniqueNamesEnabled();
end

-- PNCAssignConfirmationBlock
PNCAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase)
do
	PNCAssignConfirmationBlock.dialogText = PNC_CUSTOMIZE_DIALOG_TEXT;
	PNCAssignConfirmationBlock.dialogAcceptLabel = PNC_FLOW_FINISH_LABEL;
	PNCAssignConfirmationBlock.dialogCancelLabel = CANCEL;
end

function PNCAssignConfirmationBlock:RequestForResults(_, isValidationOnly)
	RequestAssignPNCForResults(self.results, isValidationOnly);
end

-- Endstep
PNCEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function PNCEndStep:Initialize(results, wasFromRewind)
	self.results = results;
	self.purchaseComplete = nil;
	self.timedOut = nil;

	self:CancelTimer(); -- Just in case an older timer was running.

	if not wasFromRewind then
		self:BeginTimer();

		EventRegistry:RegisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
		EventRegistry:RegisterCallback("STORE_VAS_PURCHASE_ERROR", self.OnStoreVASPurchaseError, self);

		EventRegistry:RegisterFrameEvent("ASSIGN_VAS_RESPONSE");
		EventRegistry:RegisterCallback("ASSIGN_VAS_RESPONSE", self.OnAssignVASResponse, self);
	end

	CharacterServicesMaster_Update();
end

function PNCEndStep:BeginTimer()
	self.timer = C_Timer.NewTimer(10, function()
		self.timedOut = true;
		CharacterServicesMaster_Update();
	end);
end

function PNCEndStep:CancelTimer()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function PNCEndStep:OnStoreVASPurchaseError()
	self:CancelTimer();
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	local displayMsg = VASErrorData_GetCombinedMessage(self.results.selectedCharacterGUID);

	CharSelectServicesFlowFrame:SetErrorMessage(displayMsg);
	CharSelectServicesFlowFrame.CloseButton:Show();
	CharacterServicesMaster_Update();
end

function PNCEndStep:OnAssignVASResponse(token, storeError, vasPurchaseResult)
	self:CancelTimer();
	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);

	local errorMsg;
	self.purchaseComplete, errorMsg = IsVASAssignmentValid(storeError, vasPurchaseResult, self.results.selectedCharacterGUID);

	if not self.purchaseComplete then
		CharSelectServicesFlowFrame:SetErrorMessage(errorMsg);
	end

	CharacterServicesMaster_Update();
end

function PNCEndStep:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function PNCEndStep:OnAdvance()
	self:UnregisterHandlers();
end

function PNCEndStep:OnHide()
	self:UnregisterHandlers();
end

function PNCEndStep:OnRewind()
	self:UnregisterHandlers();
end

function PNCEndStep:IsFinished()
	return self.purchaseComplete or self.timedOut;
end

function PNCEndStep:GetResult()
	return { purchaseComplete = self.purchaseComplete, timedOut = self.timedOut };
end

--Flow declaration
PaidNameChangeFlow = Mixin(
	{
		FinishLabel = PNC_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,
	},
	CharacterServicesFlowMixin
);

function PaidNameChangeFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.PaidNameChange);
end

function PaidNameChangeFlow:OnStoreCharacterListReceived()
	local fromInitialize = false;
	self:GetStep(1):CheckEnable(fromInitialize);
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function PaidNameChangeFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function PaidNameChangeFlow:Finish(controller)
	local isFinished = self:IsAllFinished();
	return isFinished;
end
