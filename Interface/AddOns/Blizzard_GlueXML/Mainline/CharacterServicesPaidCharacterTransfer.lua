local function RequestAssignPCTForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());

	return C_CharacterServices.AssignPCTDistribution(
		currentRealmAddress,
		results.selectedCharacterGUID,
		results.destinationRealmAddress,
		results.account.accountGUID,
		results.account.bnetAccountGUID,
		isValidationOnly
	);
end

local PCTCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	PCTCharacterSelectBlock.FrameName = "PCTCharacterSelect";
	PCTCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	PCTCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function DoesClientThinkTheCharacterIsEligibleForPCT(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local errors = {};

	if characterInfo then
		local isSameRealm = CharacterSelectUtil.IsSameRealmAsCurrent(characterInfo.realmAddress);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_1, isSameRealm);
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_ON_DIFFERENT_REALM_2, isSameRealm);

		if characterInfo.mailSenders then
			CheckAddVASErrorCode(errors, Enum.VasError.HasMail, #characterInfo.mailSenders == 0);
		end

		CheckAddVASErrorCode(errors, Enum.VasError.CharLocked, not characterInfo.hasVasRevoked)
		CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, characterInfo.experienceLevel >= 10);
		CheckAddVASErrorCode(errors, Enum.VasError.IsNpeRestricted, not IsCharacterNPERestricted(characterInfo.guid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(characterInfo.guid, Enum.ValueAddedServiceType.PaidCharacterTransfer));

		local canTransfer = #errors == 0;
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, nil, false;
end

function PCTCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForPCT(characterID);
	serviceInfo.isEligible = canTransferCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	return serviceInfo;
end

TransferRealmEditboxMixin = {};

function TransferRealmEditboxMixin:Initialize(results, wasFromRewind)
	if not wasFromRewind then
		self:ClearAutoCompleteList();
		self:SetText("");
	end
end

function TransferRealmEditboxMixin:OnEnter()
	GetAppropriateTooltip():SetOwner(self, "ANCHOR_RIGHT");
	GetAppropriateTooltip():SetText(VAS_TRANSFER_REALM_TOOLTIP);
	GetAppropriateTooltip():Show();
end

function TransferRealmEditboxMixin:OnTextChanged(isUser)
	self:CallOnTextChangedCallback();
end

function TransferRealmEditboxMixin:SetOnTextChangedCallback(callback)
	self.callback = callback;
end

function TransferRealmEditboxMixin:CallOnTextChangedCallback()
	if self.callback then
		self.callback();
	end
end

function TransferRealmEditboxMixin:GetRealmName()
	local name = self:GetText();
	if name == "" then
		name = select(1, GetServerName());
	end

	return name or "";
end

function TransferRealmEditboxMixin:GetRealmAddress()
	return self:GetAutoCompleteUserDataForValue(self:GetText());
end

local PCTDestinationSelectBlock = {
	FrameName = "PCTDestinationSelect",
	Back = true,
	Next = true,
	Finish = false,
	ActiveLabel = PCT_FLOW_SLECT_DESTINATION_ACTIVE,
	ResultsLabel = PCT_FLOW_SLECT_DESTINATION_RESULTS
};

function PCTDestinationSelectBlock:Initialize(results, wasFromRewind)
	local controlsFrame = self.frame.ControlsFrame;

	if not wasFromRewind then
		local checkUpdate = function()
			self:CheckUpdate();
		end

		controlsFrame.TransferRealmEditbox:SetOnTextChangedCallback(checkUpdate);
		controlsFrame.TransferAccountContainer:SetOnSelectedCallback(checkUpdate);
	end

	controlsFrame.TransferRealmEditbox:Initialize(results, wasFromRewind);
	controlsFrame.TransferAccountContainer:Initialize(results, wasFromRewind);
end

function PCTDestinationSelectBlock:CheckUpdate()
	CharacterServicesMaster_Update();
end

local function IsSameRealm(candidate)
	return not candidate or candidate == "" or candidate == GetServerName();
end

local function ValidateVasRealm(candidate)
	if IsSameRealm(candidate) then
		local currentRealmAddress = select(5, GetServerName());
		return currentRealmAddress, true;
	end

	local realms = C_StoreSecure.GetVASRealmList();

	for index, realm in ipairs(realms) do
		if realm.realmName == candidate then
			return realm.virtualRealmAddress, IsSameRealm(realm.realmName);
		end
	end

	return nil;
end

function PCTDestinationSelectBlock:IsFinished(wasFromRewind)
	if wasFromRewind then
		return false;
	end

	local result = self:GetResult();

	-- You can transfer to:
	-- Same realm, different account (if the realm is the same the account MUST be different)
	-- Different realm, same account
	-- Different realm, different account

	local realmAddress, isSameRealm = ValidateVasRealm(result.destinationRealm);
	if realmAddress then
		if isSameRealm then
			return (result.account.accountGUID and GetCurrentWoWAccountGUID() ~= result.account.accountGUID) or IsValidEmailAddress(result.account.accountEmail);
		else
			return result.account.accountGUID or IsValidEmailAddress(result.account.accountEmail);
		end
	end

	return false;
end

function PCTDestinationSelectBlock:OnRewind()
	CharSelectServicesFlowFrame:ClearErrorMessage();
end

function PCTDestinationSelectBlock:GetResult()
	return {
		destinationRealm = self.frame.ControlsFrame.TransferRealmEditbox:GetRealmName(),
		destinationRealmAddress = self.frame.ControlsFrame.TransferRealmEditbox:GetRealmAddress(),
		account = self.frame.ControlsFrame.TransferAccountContainer:GetResult(),
	};
end

function PCTDestinationSelectBlock:FormatResult()
	local result = self:GetResult();
	local formattedResult = {};

	if not IsSameRealm(result.destinationRealm) then
		table.insert(formattedResult, PCT_DESTINATION_REALM_LABEL_COMPLETE:format(result.destinationRealm));
	end

	if result.account.accountGUID ~= GetCurrentWoWAccountGUID() then
		local account = result.account.accountName or result.account.accountEmail;
		table.insert(formattedResult, PCT_DESTINATION_ACCOUNT_LABEL_COMPLETE:format(account));
	end

	return table.concat(formattedResult, "\n");
end

local PCTChoiceVerificationBlock = CreateFromMixins(VASChoiceVerificationBlockBase);

function PCTChoiceVerificationBlock:RequestAssignVASForResults(results, isValidationOnly)
	return RequestAssignPCTForResults(results, isValidationOnly);
end

local PCTAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase);
do
	PCTAssignConfirmationBlock.dialogText = PCT_FLOW_FINISH_BODY_TEXT;
	PCTAssignConfirmationBlock.dialogAcceptLabel = PCT_FLOW_FINISH_LABEL;
	PCTAssignConfirmationBlock.dialogCancelLabel = PCT_FLOW_CANCEL_LABEL;
end

function PCTAssignConfirmationBlock:RequestForResults(results, isValidationOnly)
	RequestAssignPCTForResults(self.results, isValidationOnly);
end

PCTEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function PCTEndStep:Initialize(results, wasFromRewind)
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

function PCTEndStep:BeginTimer()
	self.timer = C_Timer.NewTimer(10, function()
		self.timedOut = true;
		CharacterServicesMaster_Update();
	end);
end

function PCTEndStep:CancelTimer()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function PCTEndStep:OnStoreVASPurchaseError()
	self:CancelTimer();
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	local displayMsg = VASErrorData_GetCombinedMessage(self.results.selectedCharacterGUID);

	CharSelectServicesFlowFrame:SetErrorMessage(displayMsg);
	CharSelectServicesFlowFrame.CloseButton:Show();
	CharacterServicesMaster_Update();
end

function PCTEndStep:OnAssignVASResponse(token, storeError, vasPurchaseResult)
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

function PCTEndStep:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function PCTEndStep:OnAdvance()
	self:UnregisterHandlers();
end

function PCTEndStep:OnHide()
	self:UnregisterHandlers();
end

function PCTEndStep:OnRewind()
	self:UnregisterHandlers();
end

function PCTEndStep:IsFinished()
	return self.purchaseComplete or self.timedOut;
end

function PCTEndStep:GetResult()
	return { purchaseComplete = self.purchaseComplete, timedOut = self.timedOut };
end

PaidCharacterTransferFlow = Mixin(
	{
		FinishLabel = PCT_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,

		Steps = {
			PCTCharacterSelectBlock,
			PCTDestinationSelectBlock,
			PCTChoiceVerificationBlock,
			CreateFromMixins(VASReviewChoicesBlockBase),
			PCTAssignConfirmationBlock,
			PCTEndStep,
		},
	},
	CharacterServicesFlowMixin
);

function PaidCharacterTransferFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.PaidCharacterTransfer);
end

function PaidCharacterTransferFlow:OnStoreCharacterListReceived()
	self:GetStep(1):CheckEnable();
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function PaidCharacterTransferFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function PaidCharacterTransferFlow:Finish(controller)
	local isFinished = self:GetStep(6):IsFinished();
	if isFinished then
		-- NOTE: This cannot be called while a flow is active, the handler for the retrieving character
		-- list event conflicts with the character button state updates.
		-- Just wait a small amount of time, and call it later.
		C_Timer.NewTimer(1, CharacterSelectListUtil.GetCharacterListUpdate);
	end

	return isFinished;
end