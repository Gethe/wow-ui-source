local InvalidGUID = 0;

AccountSelectorMixin = {};

-- Copied, aand refactored slightly to only have one return, from Store UI, should share, but there's a chance this will all live here someday.
-- Possibly move this to a util function?
local function StripWoWAccountLicenseInfo(gameAccount)
	if (string.find(gameAccount, '#')) then
		local text, matchCount = string.gsub(gameAccount,'%d+#(%d)','WoW%1');
		return text;
	end
	return gameAccount;
end

local function MakeAccountData(guid, name)
	return {guid = guid, name = name};
end

local function DoesAccountDataMatch(acc1, acc2)
	if (acc1 == nil) or (acc2 == nil) then
		return false;
	end

	return (acc1 == acc2) or (acc1.guid == acc2.guid);
end

local function HasValidGUID(accountData)
	return accountData and accountData.guid ~= 0;
end

function AccountSelectorMixin:OnLoad()
	self.anyAccountSelectedCallback = function()
		CharSelectServicesFlowFrame:ClearErrorMessage();
		self:CallOnSelectedCallback();
	end;

	self.DestinationDropdown:SetWidth(228);
	self.BNetWoWAccountDropdown:SetWidth(228);

	EventRegistry:RegisterFrameEvent("VAS_TRANSFER_VALIDATION_UPDATE");
	EventRegistry:RegisterCallback("VAS_TRANSFER_VALIDATION_UPDATE", self.OnVASTranferValidationUpdate, self);
end

function AccountSelectorMixin:GetSelectedDestinationAccountData()
	return self.selectedDestinationAccountData;
end

function AccountSelectorMixin:SetSelectedDestinationAccountData(accountData)
	self.selectedDestinationAccountData = accountData;
end

function AccountSelectorMixin:GetSelectedWoWAccountData()
	return self.selectedWoWAccountData;
end

function AccountSelectorMixin:SetSelectedWoWAccountData(accountData)
	self.selectedWoWAccountData = accountData;
end

local function GenerateAccountOptions(rootDescription, accounts, isLocalAccount, isSelected, setSelected)
	local currentAccountGUID = GetCurrentWoWAccountGUID();
	for index, accountName in ipairs(accounts) do
		local accountGUID = C_StoreSecure.GetWoWAccountGUIDFromName(accountName, isLocalAccount);
		if accountGUID ~= currentAccountGUID then
			local accountData = MakeAccountData(accountGUID, accountName);
			rootDescription:CreateRadio(StripWoWAccountLicenseInfo(accountName), isSelected, setSelected, accountData);
		end
	end
end

function AccountSelectorMixin:Initialize(results, wasFromRewind)
	if wasFromRewind then
		return;
	end

	self.DestinationBlizzardAccountEdit:SetText("");
	self:SetSelectedWoWAccountData(nil);

	-- The dropdown description element count is being used to determine visibility. Discard it
	-- and expect the next PopulateBNetWoWAccountDropdown() call to reinitialize it before displaying it.
	self.BNetWoWAccountDropdown:ClearMenuState();

	-- Set the account destination before generating the menu.
	local accountData = MakeAccountData(GetCurrentWoWAccountGUID(), PCT_FLOW_DESTINATION_ACCOUNT_DROPDOWN_NONE);
	self:SetSelectedDestinationAccountData(accountData);

	local function IsSelected(accountData)
		return DoesAccountDataMatch(accountData, self:GetSelectedDestinationAccountData());
	end

	local function SetSelected(accountData)
		self:SetSelectedDestinationAccountData(accountData);

		self.anyAccountSelectedCallback();
	end
	
	self.DestinationDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_SERVICE");

		rootDescription:CreateRadio(accountData.name, IsSelected, SetSelected, accountData);

		local isLocalAccount = true;
		GenerateAccountOptions(rootDescription, C_Login.GetGameAccounts(), isLocalAccount, IsSelected, SetSelected);

		if C_CharacterServices.ArePaidCharacterTransfersBetweenBnetAccountsEnabled() then
			local differentAccountData = MakeAccountData(InvalidGUID, PCT_FLOW_DESTINATION_ACCOUNT_DROPDOWN_DIFFERENT);
			rootDescription:CreateRadio(differentAccountData.name, IsSelected, SetSelected, differentAccountData);
		end
	end);

	self.anyAccountSelectedCallback();
end

function AccountSelectorMixin:GetFirstTransferBNetWoWGameAccount()
	local isLocalAccount = false;
	local currentAccountGUID = GetCurrentWoWAccountGUID();
	for index, accountName in ipairs(self:GetBNetWoWGameAccounts()) do
		local accountGUID = C_StoreSecure.GetWoWAccountGUIDFromName(accountName, isLocalAccount);
		if accountGUID ~= currentAccountGUID then
			return MakeAccountData(accountGUID, accountName);
		end
	end
end

function AccountSelectorMixin:PopulateBNetWoWAccountDropdown()
	local accountData = self:GetFirstTransferBNetWoWGameAccount();
	if not accountData then
		-- The account data is requested and this will be called again by UpdateDestinationBNetAccount() when it's ready.
		return;
	end

	-- Set the WoW account before generating the menu.
	self:SetSelectedWoWAccountData(accountData);

	local function IsSelected(accountData)
		return DoesAccountDataMatch(accountData, self:GetSelectedWoWAccountData());
	end

	local function SetSelected(accountData)
		self:SetSelectedWoWAccountData(accountData);

		self.anyAccountSelectedCallback();
	end

	self.BNetWoWAccountDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_SERVICE_ACCOUNT");

		local isLocalAccount = false;
		GenerateAccountOptions(rootDescription, self:GetBNetWoWGameAccounts(), isLocalAccount, IsSelected, SetSelected);
	end);
	
	self.anyAccountSelectedCallback();
end

function AccountSelectorMixin:UpdateVisibilityState()
	local accountData = self:GetSelectedDestinationAccountData();
	local showAccountEdit = accountData and accountData.guid == InvalidGUID;
	self.DestinationBlizzardAccountEdit:SetShown(showAccountEdit);
	self.BlizzardAccountLabel:SetShown(showAccountEdit);

	local showWoWAccountDropdown = showAccountEdit and self.BNetWoWAccountDropdown:HasElements();
	self.BNetWoWAccountDropdown:SetShown(showWoWAccountDropdown);

	self:Layout();
end

local function GetSelectedAccountNameFromAccountData(accountData)
	return HasValidGUID(accountData) and accountData.name or "";
end

function AccountSelectorMixin:GetSelectedAccountName()
	return GetSelectedAccountNameFromAccountData(self:GetSelectedDestinationAccountData());
end

function AccountSelectorMixin:GetSelectedBNetWoWAccountName()
	return GetSelectedAccountNameFromAccountData(self:GetSelectedWoWAccountData());
end

function AccountSelectorMixin:ClearBNetAccountGuid()
	self:SetBNetAccountGuid(nil);
end

function AccountSelectorMixin:SetBNetAccountGuid(guid)
	self.bnetAccountGuid = guid;
end

function AccountSelectorMixin:GetBNetAccountGUID()
	return self.bnetAccountGuid;
end

function AccountSelectorMixin:ClearBNetWoWGameAccounts()
	self:SetBnetWoWGameAccounts(nil);
end

function AccountSelectorMixin:SetBnetWoWGameAccounts(gameAccounts)
	self.bnetWoWGameAccounts = gameAccounts;
end

function AccountSelectorMixin:GetBNetWoWGameAccounts()
	return self.bnetWoWGameAccounts or {};
end

function AccountSelectorMixin:ClearDestinationBNetAccount(clearErrorMessage)
	self:ClearBNetAccountGuid();
	self:ClearBNetWoWGameAccounts();
	self:PopulateBNetWoWAccountDropdown();

	if clearErrorMessage then
		CharSelectServicesFlowFrame:ClearErrorMessage();
	end
end

function AccountSelectorMixin:ValidateBnetTransfer(bnetAccountEmail)
	if not self.awaitingBnetTransferResponse then
		self.awaitingBnetTransferResponse = true;
		C_StoreSecure.ValidateBnetTransfer(bnetAccountEmail); -- Request info, will respond with VAS_TRANSFER_VALIDATION_UPDATE
	end
end

function AccountSelectorMixin:UpdateDestinationBNetAccount()
	local guid, gameAccounts = C_StoreSecure.GetBnetTransferInfo();
	self:SetBNetAccountGuid(guid);
	self:SetBnetWoWGameAccounts(gameAccounts);
	self:PopulateBNetWoWAccountDropdown();
end

function AccountSelectorMixin:OnVASTranferValidationUpdate(error)
	self.awaitingBnetTransferResponse = nil;
	if error then
		self:ClearDestinationBNetAccount();
		CharSelectServicesFlowFrame:SetErrorMessage(BLIZZARD_STORE_VAS_ERROR_INVALID_BNET_ACCOUNT);
	else
		self:UpdateDestinationBNetAccount();
		CharSelectServicesFlowFrame:ClearErrorMessage();
	end
end

function AccountSelectorMixin:SetOnSelectedCallback(callback)
	self.onSelectedCallback = callback;
end

function AccountSelectorMixin:CallOnSelectedCallback()
	if self.onSelectedCallback then
		self.onSelectedCallback();
	end

	self:UpdateVisibilityState();
end

function AccountSelectorMixin:GetResult()
	local accountData = self:GetSelectedDestinationAccountData();
	if accountData then
		if HasValidGUID(accountData) then
			return {
				accountGUID = accountData.guid,
				accountName = self:GetSelectedAccountName(),
				bnetAccountGUID = GetCurrentBNetAccountGUID(),
			};
		else
			local result = {
				accountEmail = self.DestinationBlizzardAccountEdit:GetText(),
				accountName = self:GetSelectedBNetWoWAccountName(),
				bnetAccountGUID = self:GetBNetAccountGUID(),
			};

			local wowAccountData = self:GetSelectedWoWAccountData();
			if wowAccountData then
				result.accountGUID = wowAccountData.guid;
			end
			return result;
		end
	end

	return {};
end

function AccountSelectorMixin:IsFinished()
	local result = self:GetResult();
	return result.accountGUID or result.accountEmail;
end

DestinationBlizzardAccountEditMixin = {};

function DestinationBlizzardAccountEditMixin:OnTextChanged(isUser)
	if isUser then
		local text = self:GetText();
		local clearErrorMessage = text == "";
		-- Always clear the potentially valid account guid when text changes...
		self:GetParent():ClearDestinationBNetAccount(clearErrorMessage);

		-- ...but then automatically begin validation on emails that look legit as the user enters text.
		if IsValidEmailAddress(text) then
			-- Don't flood the server with requests, it won't respond to any messages until it has responded to the first valid request.
			-- So just delay the query an acceptable amout
			C_Timer.After(2, function()
				self:GetParent():ValidateBnetTransfer(self:GetText()); -- make sure to get the text at the time we make the call.
			end);
		end
	end
end

function DestinationBlizzardAccountEditMixin:OnEnterPressed()
	self:ClearFocus();
end