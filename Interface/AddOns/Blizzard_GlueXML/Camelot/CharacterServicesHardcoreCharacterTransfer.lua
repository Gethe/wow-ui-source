local function RequestAssignHCTForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());

	return C_CharacterServices.AssignHCTDistribution(
		currentRealmAddress,
		results.selectedCharacterGUID,
		results.superDistrictInfo.superDistrictID,
		isValidationOnly
	);
end

local HCTCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	HCTCharacterSelectBlock.FrameName = "HCTCharacterSelect";
	HCTCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	HCTCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

function DoesClientThinkTheCharacterIsEligibleForHCT(characterID)
	local characterInfo = CharacterSelectUtil.GetCharacterInfoTable(characterID);
	local errors = {};

	if characterInfo then
		if characterInfo.mailSenders then
			CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasMail, #characterInfo.mailSenders == 0);
		end

		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbCharLocked, not characterInfo.hasVasRevoked);
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbUnderMinLevelReq, characterInfo.experienceLevel >= 10);
		CheckAddVASErrorCode(errors, Enum.VasTransactionPurchaseResult.DbHasNewPlayerExperienceRestriction, not IsCharacterNPERestricted(characterInfo.guid));
		CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, not IsCharacterVASRestricted(characterInfo.guid, Enum.ValueAddedServiceType.HardcoreCharacterTransfer));

		local canTransfer = #errors == 0;
		return canTransfer, errors, characterInfo.guid, characterInfo.characterServiceRequiresLogin;
	end
	return false, errors, nil, false;
end

function HCTCharacterSelectBlock:GetServiceInfoByCharacterID(characterID)
	local serviceInfo = { checkErrors = true };
	local canTransferCharacter, errors, playerguid, characterServiceRequiresLogin = DoesClientThinkTheCharacterIsEligibleForHCT(characterID);
	serviceInfo.isEligible = canTransferCharacter;
	serviceInfo.errors = errors;
	serviceInfo.playerguid = playerguid;
	serviceInfo.requiresLogin = characterServiceRequiresLogin;
	return serviceInfo;
end

local HCTDestinationSelectBlock = {
	FrameName = "HCTDestinationSelect",
	Back = true,
	Next = true,
	Finish = false,
	ActiveLabel = HCT_FLOW_SLECT_DESTINATION_ACTIVE,
	ResultsLabel = HCT_FLOW_SLECT_DESTINATION_RESULTS
};

function HCTDestinationSelectBlock:Initialize(results, wasFromRewind)
	local controlsFrame = self.frame.ControlsFrame;

	if not wasFromRewind then
		local checkUpdate = function()
			self:CheckUpdate();
		end

		controlsFrame.TransferSuperDistrictHCTContainer:SetOnSelectedCallback(checkUpdate);
	end

	controlsFrame.TransferSuperDistrictHCTContainer:Initialize(results, wasFromRewind);

	local basicInfo = GetBasicCharacterInfo(results.selectedCharacterGUID);
	self.selectedCharacterSuperDistrictID = basicInfo.superDistrictID;
end

function HCTDestinationSelectBlock:CheckUpdate()
	CharacterServicesMaster_Update();
end

function HCTDestinationSelectBlock:IsSameSuperDistrict(superDistrictInfo)
	-- 0 is an invalid superDistrictID, so early out
	if (not superDistrictInfo) or (superDistrictInfo.superDistrictID == 0) then
		return true;
	end

	return superDistrictInfo.superDistrictID == self.selectedCharacterSuperDistrictID;
end

function HCTDestinationSelectBlock:IsFinished(wasFromRewind)
	if wasFromRewind then
		return false;
	end

	local result = self:GetResult();
	return not self:IsSameSuperDistrict(result.superDistrictInfo);
end

function HCTDestinationSelectBlock:OnRewind()
	CharSelectServicesFlowFrame:ClearErrorMessage();
end

function HCTDestinationSelectBlock:GetResult()
	return {
		superDistrictInfo = self.frame.ControlsFrame.TransferSuperDistrictHCTContainer:GetResult(),
	};
end

function HCTDestinationSelectBlock:FormatResult()
	local result = self:GetResult();
	local formattedResult = {};

	if not self:IsSameSuperDistrict(result.superDistrictInfo) then
		table.insert(formattedResult, HCT_DESTINATION_SUPER_DISTRICT_LABEL_COMPLETE:format(result.superDistrictInfo.displayName));
	end

	return table.concat(formattedResult, "\n");
end

local HCTChoiceVerificationBlock = CreateFromMixins(VASChoiceVerificationBlockBase);

function HCTChoiceVerificationBlock:RequestAssignVASForResults(results, isValidationOnly)
	return RequestAssignHCTForResults(results, isValidationOnly);
end

local HCTAssignConfirmationBlock = CreateFromMixins(VASAssignConfirmationBlockBase);
do
	HCTAssignConfirmationBlock.dialogText = HCT_FLOW_FINISH_BODY_TEXT;
	HCTAssignConfirmationBlock.dialogAcceptLabel = HCT_FLOW_FINISH_LABEL;
	HCTAssignConfirmationBlock.dialogCancelLabel = HCT_FLOW_CANCEL_LABEL;
end

function HCTAssignConfirmationBlock:RequestForResults(results, isValidationOnly)
	RequestAssignHCTForResults(self.results, isValidationOnly);
end

HCTEndStep =
{
	AutoAdvance = true,
	Back = true,
	Next = false,
	Finish = false,
	HiddenStep = true,
	SkipOnRewind = true,
};

function HCTEndStep:Initialize(results, wasFromRewind)
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

function HCTEndStep:BeginTimer()
	self.timer = C_Timer.NewTimer(10, function()
		self.timedOut = true;
		CharacterServicesMaster_Update();
	end);
end

function HCTEndStep:CancelTimer()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function HCTEndStep:OnStoreVASPurchaseError()
	self:CancelTimer();
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	local displayMsg = VASErrorData_GetCombinedMessage(self.results.selectedCharacterGUID);

	CharSelectServicesFlowFrame:SetErrorMessage(displayMsg);
	CharSelectServicesFlowFrame.CloseButton:Show();
	CharacterServicesMaster_Update();
end

function HCTEndStep:OnAssignVASResponse(token, storeError, vasPurchaseResult)
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

function HCTEndStep:UnregisterHandlers()
	EventRegistry:UnregisterFrameEvent("STORE_VAS_PURCHASE_ERROR");
	EventRegistry:UnregisterCallback("STORE_VAS_PURCHASE_ERROR", self);

	EventRegistry:UnregisterFrameEvent("ASSIGN_VAS_RESPONSE");
	EventRegistry:UnregisterCallback("ASSIGN_VAS_RESPONSE", self);
end

function HCTEndStep:OnAdvance()
	self:UnregisterHandlers();
end

function HCTEndStep:OnHide()
	self:UnregisterHandlers();
end

function HCTEndStep:OnRewind()
	self:UnregisterHandlers();
end

function HCTEndStep:IsFinished()
	return self.purchaseComplete or self.timedOut;
end

function HCTEndStep:GetResult()
	return { purchaseComplete = self.purchaseComplete, timedOut = self.timedOut };
end

HardcoreCharacterTransferFlow = Mixin(
	{
		FinishLabel = HCT_FLOW_FINISH_LABEL,
		AutoCloseAfterFinish = true,

		Steps = {
			HCTCharacterSelectBlock,
			HCTDestinationSelectBlock,
			HCTChoiceVerificationBlock,
			CreateFromMixins(VASReviewChoicesBlockBase),
			HCTAssignConfirmationBlock,
			HCTEndStep,
		},
	},
	CharacterServicesFlowMixin
);

function HardcoreCharacterTransferFlow:Initialize(controller)
	CharacterServicesFlowMixin.Initialize(self, controller);

	CharacterServicesCharacterSelector:Hide();

	EventRegistry:RegisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:RegisterCallback("STORE_CHARACTER_LIST_RECEIVED", self.OnStoreCharacterListReceived, self);

	C_StoreGlue.RequestStoreCharacterListForVasType(Enum.ValueAddedServiceType.HardcoreCharacterTransfer);
end

function HardcoreCharacterTransferFlow:OnStoreCharacterListReceived()
	local fromInitialize = false;
	self:GetStep(1):CheckEnable(fromInitialize);
	EventRegistry:UnregisterFrameEvent("STORE_CHARACTER_LIST_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_CHARACTER_LIST_RECEIVED", self);
end

function HardcoreCharacterTransferFlow:ShouldFinishBehaveLikeNext()
	return true;
end

function HardcoreCharacterTransferFlow:Finish(controller)
	local isFinished = self:GetStep(6):IsFinished();
	if isFinished then
		-- NOTE: This cannot be called while a flow is active, the handler for the retrieving character
		-- list event conflicts with the character button state updates.
		-- Just wait a small amount of time, and call it later.
		C_Timer.NewTimer(1, CharacterSelectListUtil.GetCharacterListUpdate);
	end

	return isFinished;
end
