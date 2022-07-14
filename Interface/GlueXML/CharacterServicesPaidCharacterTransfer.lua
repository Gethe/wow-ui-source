local function RequestAssignPCTForResults(results, isValidationOnly)
	local currentRealmAddress = select(5, GetServerName());

	return C_CharacterServices.AssignPCTDistribution(
		currentRealmAddress,
		results.selectedCharacterGUID,
		results.destinationRealmAddress,
		results.account.accountGUID,
		results.account.bnetAccountGUID,
		results.isGuildFollow,
		isValidationOnly
	);
end

local PCTCharacterSelectBlock = CreateFromMixins(VASCharacterSelectBlockBase);
do
	PCTCharacterSelectBlock.FrameName = "PCTCharacterSelect";
	PCTCharacterSelectBlock.ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL;
	PCTCharacterSelectBlock.ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL;
end

local function DoesClientThinkTheCharacterIsEligibleForPCT(characterID)
	local level, _, _, _, _, _, _, _, playerguid, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, mailSenders, _, _, characterServiceRequiresLogin = select(7, GetCharacterInfo(characterID));
	local errors = {};

	CheckAddVASErrorCode(errors, Enum.VasError.UnderMinLevelReq, level >= 10);
	CheckAddVASErrorCode(errors, Enum.VasError.HasMail, #mailSenders == 0);
	CheckAddVASErrorCode(errors, Enum.VasError.IsNpeRestricted, not IsCharacterNPERestricted(playerguid));
	CheckAddVASErrorString(errors, BLIZZARD_STORE_VAS_ERROR_CHARACTER_INELIGIBLE_FOR_THIS_SERVICE, C_StoreSecure.IsVASEligibleCharacterGUID(playerguid));

	local canTransfer = #errors == 0;
	return canTransfer, errors, playerguid, characterServiceRequiresLogin;
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

FollowGuildMixin = {};

function FollowGuildMixin:Initialize(results, wasFromRewind)
	if not wasFromRewind then
		self:SetChecked(false);
	end
end

function FollowGuildMixin:OnClick()
	self:CallOnClickedCallback();
end

function FollowGuildMixin:SetOnClickedCallback(callback)
	self.callback = callback;
end

function FollowGuildMixin:CallOnClickedCallback()
	if self.callback then
		self.callback();
	end
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
	if not wasFromRewind then
		local checkUpdate = function()
			self:CheckUpdate();
		end

		self.frame.ControlsFrame.TransferRealmEditbox:SetOnTextChangedCallback(checkUpdate);
		self.frame.ControlsFrame.TransferAccountContainer:SetOnSelectedCallback(checkUpdate);
		self.frame.ControlsFrame.FollowGuildCheckbox:SetOnClickedCallback(checkUpdate);

		self.frame.ControlsFrame.LoadingSpinner:ClearAllPoints();
		self.frame.ControlsFrame.LoadingSpinner:SetPoint("TOP", self.frame.ControlsFrame:GetParent().StepActiveLabel, "BOTTOM");
		self.frame.ControlsFrame.FollowGuildCheckbox.Label:SetSize(250, 32);
	end

	self.frame.ControlsFrame.TransferRealmEditbox:Initialize(results, wasFromRewind);
	self.frame.ControlsFrame.TransferAccountContainer:Initialize(results, wasFromRewind);
	self.frame.ControlsFrame.FollowGuildCheckbox:Initialize(results, wasFromRewind);

	self:RequestGuildFollowInfo(results.selectedCharacterGUID);
end

function PCTDestinationSelectBlock:RequestGuildFollowInfo(characterGUID)
	--- Request information about whether or not this character will need to follow a guild for this transfer.
	EventRegistry:RegisterFrameEvent("STORE_GUILD_FOLLOW_INFO_RECEIVED");
	EventRegistry:RegisterCallback("STORE_GUILD_FOLLOW_INFO_RECEIVED", self.OnStoreGuildFollowInfoReceived, self);

	self.awaitingGuildFollowCharacterGUID = characterGUID;

	local currentRealmAddress = select(5, GetServerName());
	C_StoreSecure.RequestCharacterGuildFollowInfo(characterGUID, currentRealmAddress); -- TODO: Await results if this has already been requested?
	self:SetState("AwaitingGuildFollowInfo");
end

function PCTDestinationSelectBlock:OnStoreGuildFollowInfoReceived(characterGUID, guildFollowInfo)
	EventRegistry:UnregisterFrameEvent("STORE_GUILD_FOLLOW_INFO_RECEIVED");
	EventRegistry:UnregisterCallback("STORE_GUILD_FOLLOW_INFO_RECEIVED", self);

	local guildFollowResultsMatchCharacter = characterGUID == self.awaitingGuildFollowCharacterGUID;
	self:SetCanFollowGuild(guildFollowInfo and guildFollowInfo.transferredRealm);
	self:UpdateFollowGuildCheckbox(guildFollowResultsMatchCharacter, guildFollowInfo);
	self:SetState("GuildFollowReceived");
end

function PCTDestinationSelectBlock:UpdateFollowGuildCheckbox(guildFollowResultsMatchCharacter, guildFollowInfo)
	if guildFollowInfo and guildFollowInfo.transferredRealm then
		local checkboxString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_FACTION_CHANGE;
		if guildFollowInfo.transferredRealm then
			checkboxString = BLIZZARD_STORE_VAS_FOLLOW_GUILD_TRANSFER:format(guildFollowInfo.transferredRealm);
		end

		self.frame.ControlsFrame.FollowGuildCheckbox.Label:SetText(checkboxString);
		self.frame.ControlsFrame.FollowGuildCheckbox:SetChecked(true);
		self.frame.ControlsFrame.FollowGuildCheckbox:OnClick(true);
		self.frame.ControlsFrame.FollowGuildCheckbox:Show();
	else
		self.frame.ControlsFrame.FollowGuildCheckbox:Hide();
	end
end

function PCTDestinationSelectBlock:UpdateVisibleState()
	local isWaiting = self:GetState() == "AwaitingGuildFollowInfo";
	local hasFollowInfo = self:GetState() == "GuildFollowReceived";
	local hasGuildFollowOption = hasFollowInfo and self:CanFollowGuild();
	local willFollowGuild = hasGuildFollowOption and self:WillFollowGuild();
	local showDestinationSelectFrames = not (isWaiting or willFollowGuild);

	self.frame.ControlsFrame.TransferRealmLabel:SetShown(showDestinationSelectFrames);
	self.frame.ControlsFrame.TransferRealmEditbox:SetShown(showDestinationSelectFrames);
	self.frame.ControlsFrame.TransferAccountContainer:SetShown(showDestinationSelectFrames);
	self.frame.ControlsFrame.FollowGuildCheckbox:SetShown(hasGuildFollowOption);

	self.frame.ControlsFrame.LoadingSpinner:SetShown(isWaiting);

	self.frame.ControlsFrame.TransferRealmLabel:ClearAllPoints();
	if hasGuildFollowOption then
		self.frame.ControlsFrame.TransferRealmLabel:SetPoint("TOPLEFT", self.frame.ControlsFrame.FollowGuildCheckbox, "BOTTOMLEFT", 6, -9);
	else
		self.frame.ControlsFrame.TransferRealmLabel:SetPoint("TOPLEFT", self.frame.ControlsFrame, "TOPLEFT", 112, -55);
	end
end

function PCTDestinationSelectBlock:SetState(state)
	self.state = state;
	self:UpdateVisibleState();
	self:CheckUpdate();
end

function PCTDestinationSelectBlock:GetState()
	return self.state;
end

function PCTDestinationSelectBlock:CanFollowGuild()
	return self.canFollowGuild;
end

function PCTDestinationSelectBlock:SetCanFollowGuild(follow)
	self.canFollowGuild = follow;
end

function PCTDestinationSelectBlock:WillFollowGuild()
	return self.frame.ControlsFrame.FollowGuildCheckbox:GetChecked();
end

function PCTDestinationSelectBlock:CheckUpdate()
	self:UpdateVisibleState();
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

	if self:GetState() == "AwaitingGuildFollowInfo" then
		return false;
	end

	-- Not sure about this yet, seems like the user actually does have an option, but we always return true here if the user can and will follow the guild
	if self:CanFollowGuild() and self:WillFollowGuild() then
		return true;
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
		isGuildFollow = self:WillFollowGuild(),
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
		C_Timer.NewTimer(1, CharacterSelect_GetCharacterListUpdate);
	end

	return isFinished;
end