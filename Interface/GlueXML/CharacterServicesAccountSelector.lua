AccountSelectorMixin = {};

-- Copied, aand refactored slightly to only have one return, from Store UI, should share, but there's a chance this will all live here someday.
-- Possibly move this to a util function?
local function StripWoWAccountLicenseInfo(gameAccount)
	if (string.find(gameAccount, '#')) then
		local text, matchCount = string.gsub(gameAccount,'%d+\#(%d)','WoW%1');
		return text;
	end
	return gameAccount;
end

local function BuildDropdownOptions(self, gameAccounts, isLocalAccount)
	local currentAccountGUID = GetCurrentWoWAccountGUID();
	local options = {};

	if isLocalAccount then
		table.insert(options, self:CreateOption(currentAccountGUID, PCT_FLOW_DESTINATION_ACCOUNT_DROPDOWN_NONE));
	end

	self.gameAccountGUIDToNameMapping = {};

	for index, gameAccount in ipairs(gameAccounts) do
		local accountGUID = C_StoreSecure.GetWoWAccountGUIDFromName(gameAccount, isLocalAccount);
		self.gameAccountGUIDToNameMapping[accountGUID] = gameAccount;
		if (accountGUID ~= currentAccountGUID) then
			table.insert(options, self:CreateOption(accountGUID, StripWoWAccountLicenseInfo(gameAccount)));
		end
	end

	if isLocalAccount then
		table.insert(options, self:CreateOption("DifferentBlizzardAccount", PCT_FLOW_DESTINATION_ACCOUNT_DROPDOWN_DIFFERENT));
	end

	return options;
end

function AccountSelectorMixin:OnLoad()
	local wowAccountSelectedCallback = function(value, isUserInput)
		CharSelectServicesFlowFrame:ClearErrorMessage();
		self:CallOnSelectedCallback();
	end

	self.Dropdown:UpdateWidth(165);
	self.Dropdown:SetOptionSelectedCallback(wowAccountSelectedCallback);

	self.BNetWoWAccountDropdown:UpdateWidth(195);
	self.BNetWoWAccountDropdown:SetOptionSelectedCallback(wowAccountSelectedCallback);

	EventRegistry:RegisterFrameEvent("VAS_TRANSFER_VALIDATION_UPDATE");
	EventRegistry:RegisterCallback("VAS_TRANSFER_VALIDATION_UPDATE", self.OnVASTranferValidationUpdate, self);
end

function AccountSelectorMixin:Initialize(results, wasFromRewind)
	if not wasFromRewind then
		self.DestinationBlizzardAccountEdit:SetText("");
		self.Dropdown:ClearOptions();
		self.BNetWoWAccountDropdown:ClearOptions();
		self:PopulateDropDown();
	end
end

function AccountSelectorMixin:PopulateDropDown()
	local isLocalAccount = true;
	local options = BuildDropdownOptions(self.Dropdown, C_Login.GetGameAccounts(), isLocalAccount);
	local selectedValue = self.Dropdown:GetSelectedValue() or GetCurrentWoWAccountGUID();
	self.Dropdown:SetOptions(options, selectedValue);
	self:UpdateVisibilityState();
end

function AccountSelectorMixin:PopulateBNetWoWAccountDropDown()
	local isLocalAccount = false;
	local accounts = self:GetBNetWoWGameAccounts()
	local options = BuildDropdownOptions(self.BNetWoWAccountDropdown, accounts, isLocalAccount);
	local selectedValue = self.BNetWoWAccountDropdown:GetSelectedValue();

	if not selectedValue and #options > 0 then
		selectedValue = options[1].value;
	end

	self.BNetWoWAccountDropdown:SetOptions(options, selectedValue);
	self:UpdateVisibilityState();
end

function AccountSelectorMixin:UpdateVisibilityState()
	local showAccountEdit = self.Dropdown:GetSelectedValue() == "DifferentBlizzardAccount";
	self.DestinationBlizzardAccountEdit:SetShown(showAccountEdit);
	self.BlizzardAccountLabel:SetShown(showAccountEdit);

	local showBNetWoWAccountDropdown = showAccountEdit and self.BNetWoWAccountDropdown:HasOptions();
	self.BNetWoWAccountDropdown:SetShown(showBNetWoWAccountDropdown);

	self:Layout();
end

function AccountSelectorMixin:GetSelectedAccountNameFromDropdown(dropdown)
	if dropdown.gameAccountGUIDToNameMapping then
		return dropdown.gameAccountGUIDToNameMapping[dropdown:GetSelectedValue()] or "";
	end

	return "";
end

function AccountSelectorMixin:GetSelectedAccountName()
	return self:GetSelectedAccountNameFromDropdown(self.Dropdown);
end

function AccountSelectorMixin:GetSelectedBNetWoWAccountName()
	return self:GetSelectedAccountNameFromDropdown(self.BNetWoWAccountDropdown);
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
	self:PopulateBNetWoWAccountDropDown();

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
	self:PopulateBNetWoWAccountDropDown();
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
	local selectedGUID = self.Dropdown:GetSelectedValue()
	if selectedGUID then
		if selectedGUID == "DifferentBlizzardAccount" then
			return {
				accountEmail = self.DestinationBlizzardAccountEdit:GetText(),
				accountName = self:GetSelectedBNetWoWAccountName(),
				bnetAccountGUID = self:GetBNetAccountGUID(),
				accountGUID = self.BNetWoWAccountDropdown:GetSelectedValue(),
			};
		else
			return {
				accountGUID = selectedGUID,
				accountName = self:GetSelectedAccountName(),
				bnetAccountGUID = GetCurrentBNetAccountGUID(),
			};
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