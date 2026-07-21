local function RequestAssignFCMForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());

	return C_CharacterServices.AssignFCMDistribution(
		currentRealmAddress,
		results.selectedCharacterGUID,
		results.destinationRealmAddress,
		GetCurrentWoWAccountGUID(),
		GetCurrentBNetAccountGUID(),
		isValidationOnly
	);
end

local FCMCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	FCMCharacterSelectBlock.FrameName = "FCMCharacterSelect";
	FCMCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	FCMCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function DoesClientThinkTheCharacterIsEligibleForFCM(characterID)
	local level, _, _, _, _, _, _, _, playerguid, _, _, _, _, _, _, _, _, _, _, _, _, _, _, mailSenders, _, _, _, _, _, _, hasVasRevoked = select(7, GetCharacterInfo(characterID));
	local errors = {};
	
	CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbCharLocked, not hasVasRevoked)
	CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasMail, #mailSenders == 0);
	CheckAddVASErrorString(errors, CHARACTER_SELECT_REVOKED_BOOST_TOKEN_LOCKED_TOOLTIP_TITLE, not IsCharacterVASLocked(playerguid));
	CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(playerguid, Enum.ValueAddedServiceType.FreeCharacterTransfer));

	local canTransfer = #errors == 0;
	return canTransfer, errors, playerguid, characterServiceRequiresLogin;
end

function FCMCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForFCM(characterID);
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

local FCMDestinationSelectBlock = {
	FrameName = "FCMDestinationSelect",
	Back = true,
	Next = true,
	Finish = false,
	ActiveLabel = PCT_FLOW_SLECT_DESTINATION_ACTIVE,
	ResultsLabel = PCT_FLOW_SLECT_DESTINATION_RESULTS
};

function FCMDestinationSelectBlock:Initialize(results, wasFromRewind)
	local controlsFrame = self.frame.ControlsFrame;

	if not wasFromRewind then
		local checkUpdate = function()
			self:CheckUpdate();
		end

		controlsFrame.TransferRealmEditbox:SetOnTextChangedCallback(checkUpdate);
	end

	controlsFrame.TransferRealmEditbox:Initialize(results, wasFromRewind);
end

function FCMDestinationSelectBlock:CheckUpdate()
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

function FCMDestinationSelectBlock:IsFinished(wasFromRewind)
	if wasFromRewind then
		return false;
	end

	local result = self:GetResult();

	local realmAddress, isSameRealm = ValidateVasRealm(result.destinationRealm);
	if realmAddress and not isSameRealm then
		return true;
	end

	return false;
end

function FCMDestinationSelectBlock:OnRewind()
	CharSelectServicesFlowFrame:ClearErrorMessage();
end

function FCMDestinationSelectBlock:GetResult()
	return {
		destinationRealm = self.frame.ControlsFrame.TransferRealmEditbox:GetRealmName(),
		destinationRealmAddress = self.frame.ControlsFrame.TransferRealmEditbox:GetRealmAddress()
	};
end

function FCMDestinationSelectBlock:FormatResult()
	local result = self:GetResult();
	local formattedResult = {};

	if not IsSameRealm(result.destinationRealm) then
		table.insert(formattedResult, PCT_DESTINATION_REALM_LABEL_COMPLETE:format(result.destinationRealm));
	end

	return table.concat(formattedResult, "\n");
end

local FCMChoiceVerificationBlock = CreateFromMixins(VASChoiceVerificationBlockBase);

function FCMChoiceVerificationBlock:RequestAssignVASForResults(results, isValidationOnly)
	return RequestAssignFCMForResults(results, isValidationOnly);
end

local FCMAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase);
do
	FCMAssignConfirmationBlock.dialogText = PCT_FLOW_FINISH_BODY_TEXT;
	FCMAssignConfirmationBlock.dialogAcceptLabel = PCT_FLOW_FINISH_LABEL;
	FCMAssignConfirmationBlock.dialogCancelLabel = PCT_FLOW_CANCEL_LABEL;
end

function FCMAssignConfirmationBlock:RequestForResults(results, isValidationOnly)
	RequestAssignFCMForResults(self.results, isValidationOnly);
end

FCMEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function FCMEndStep:Initialize(results, wasFromRewind)
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

function FCMEndStep:BeginTimer()
	self.timer = C_Timer.NewTimer(10, function()
		self.timedOut = true;
		CharacterServicesMaster_Update();
	end);
end

function FCMEndStep:CancelTimer()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function FCMEndStep:OnStoreVASPurchaseError()
	self:CancelTimer();
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	local displayMsg = VASErrorData_GetCombinedMessage(self.results.selectedCharacterGUID);

	CharSelectServicesFlowFrame:SetErrorMessage(displayMsg);
	CharacterServicesMaster_Update();
end

function FCMEndStep:OnAssignVASResponse(token, storeError, vasPurchaseResult)
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

function FCMEndStep:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function FCMEndStep:OnAdvance()
	self:UnregisterHandlers();
end

function FCMEndStep:OnHide()
	self:UnregisterHandlers();
end

function FCMEndStep:OnRewind()
	self:UnregisterHandlers();
end

function FCMEndStep:IsFinished()
	return self.purchaseComplete or self.timedOut;
end

function FCMEndStep:GetResult()
	return { purchaseComplete = self.purchaseComplete, timedOut = self.timedOut };
end

FreeCharacterTransferFlow = Mixin(
	{
		FinishLabel = PCT_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,

		Steps = {
			FCMCharacterSelectBlock,
			FCMDestinationSelectBlock,
			FCMChoiceVerificationBlock,
			CreateFromMixins(VASReviewChoicesBlockBase),
			FCMAssignConfirmationBlock,
			FCMEndStep,
		},
	},
	CharacterServicesFlowMixin
);

function FreeCharacterTransferFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.FreeCharacterTransfer);
end

function FreeCharacterTransferFlow:OnStoreCharacterListReceived()
	self:GetStep(1):CheckEnable();
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function FreeCharacterTransferFlow:OnHide()
	CharacterServicesFlowMixin.OnHide(self);
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function FreeCharacterTransferFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function FreeCharacterTransferFlow:Finish(controller)
	local isFinished = self:GetStep(6):IsFinished();
	if isFinished then
		-- NOTE: This cannot be called while a flow is active, the handler for the retrieving character
		-- list event conflicts with the character button state updates.
		-- Just wait a small amount of time, and call it later.
		C_Timer.NewTimer(1, CharacterSelect_GetCharacterListUpdate);
	end

	return isFinished;
end
