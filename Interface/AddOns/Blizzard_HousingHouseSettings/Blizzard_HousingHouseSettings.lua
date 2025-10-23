HousingHouseSettingsFrameMixin = {}

local HouseSettingsFrameShownEvents =
{
	"PLAYER_CHARACTER_LIST_UPDATED",
	"CURRENT_HOUSE_INFO_RECIEVED",
};

local HouseAccessFlags =
{
	Enum.HouseSettingFlags.HouseAccessNeighbors,
	Enum.HouseSettingFlags.HouseAccessGuild,
	Enum.HouseSettingFlags.HouseAccessFriends,
	Enum.HouseSettingFlags.HouseAccessParty,
};

local PlotAccessFlags =
{
	Enum.HouseSettingFlags.PlotAccessNeighbors,
	Enum.HouseSettingFlags.PlotAccessGuild,
	Enum.HouseSettingFlags.PlotAccessFriends,
	Enum.HouseSettingFlags.PlotAccessParty,
};

function HousingHouseSettingsFrameMixin:OnLoad()
	self.PlotAccess:SetupOptions(HOUSING_HOUSE_SETTINGS_PLOTACCESS, PlotAccessFlags, Enum.HouseSettingFlags.PlotAccessAnyone);
	self.PlotAccess:SetOptionSelectedCallback(self.OnAccessChanged);
	self.PlotAccess:SetupAccessTypeDropdown();

	self.HouseAccess:SetupOptions(HOUSING_HOUSE_SETTINGS_HOUSEACCESS, HouseAccessFlags, Enum.HouseSettingFlags.HouseAccessAnyone);
	self.HouseAccess:SetOptionSelectedCallback(self.OnAccessChanged);
	self.HouseAccess:SetupAccessTypeDropdown();

	self.IgnoreListButton:SetScript("OnClick", self.OnIgnoreListClicked);
	self.AbandonHouseButton:SetScript("OnClick", GenerateClosure(self.OnAbandonHouseClicked, self));
	self.SaveButton:SetScript("OnClick", GenerateClosure(self.OnSaveClicked, self));

	self.HouseOwnerDropdown:SetWidth(200);
end

function HousingHouseSettingsFrameMixin:SetHouseInfo(houseInfo)
	--If the plotID is -1 we failed to fetch the info for this house from the server
	--disable house settings until we get current house settings
	if houseInfo.plotID == -1 then
		self.HouseNameText:SetText("");
		self.PlotAccess:DisableSettings();
		self.HouseAccess:DisableSettings();
		self.AbandonHouseButton:Disable();
		self.SaveButton:Disable();
		return;
	end
	self.houseInfo = houseInfo;
	self.HouseNameText:SetText(houseInfo.houseName);
	local selectedSettings = C_Housing.GetHousingAccessFlags();
	self.PlotAccess:SetSelectedSettings(selectedSettings);
	self.HouseAccess:SetSelectedSettings(selectedSettings);
	self.AbandonHouseButton:Enable();
	self.SaveButton:Enable();
end

function HousingHouseSettingsFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_CHARACTER_LIST_UPDATED" then
		local characterList, currentOwnerIndex = ...;
		self:SetupOwnerDropdown(characterList, currentOwnerIndex);
	elseif event == "CURRENT_HOUSE_INFO_RECIEVED" then
		local houseInfo = ...;
		self:SetHouseInfo(houseInfo);
		C_Housing.RequestPlayerCharacterList();
	elseif event == "CURRENT_HOUSE_INFO_UPDATED" then
		local houseInfo = ...;
		self:SetHouseInfo(houseInfo);
	end
end

function HousingHouseSettingsFrameMixin:OnOwnerSelected(houseOwnerID)
	self.selectedOwnerID = houseOwnerID;
	local text, color = self:GetSelectedOwnerText();
	self.HouseOwnerDropdown:OverrideText(text);
	self.HouseOwnerDropdown.Text:SetTextColor(color.r, color.g, color.b);
end

function HousingHouseSettingsFrameMixin:SetupOwnerDropdown(characterList, currentOwnerIndex)
	self.selectedOwnerID = currentOwnerIndex;
	self.characterList = characterList;

	self.HouseOwnerDropdown:SetupMenu(function(dropdown, rootDescription)
		local extent = 20;
		local maxHousesShown = 8;
		local maxScrollExtent = extent * maxHousesShown;
		rootDescription:SetScrollMode(maxScrollExtent);

		for houseOwnerID = 1, #characterList do
			local function OnClick()
				self:OnOwnerSelected(houseOwnerID);
			end;
			local charInfo = characterList[houseOwnerID];
			local classInfo = C_CreatureInfo.GetClassInfo(charInfo.classID);
			local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
			local button = rootDescription:CreateButton(charInfo.characterName, OnClick);
			button:AddInitializer(function(button, description, menu)
				button.fontString:SetTextColor(color.r, color.g, color.b);
			end);
			if charInfo.error ~= Enum.HouseOwnerError.None then
				button:SetEnabled(false);
				button:SetOnEnter(function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
					GameTooltip:SetText(HouseOwnerErrorTypeStrings[charInfo.error], RED_FONT_COLOR:GetRGB());
					GameTooltip:Show();
				end);
				button:SetOnLeave(function(self)
					GameTooltip:Hide();
				end);
			end
		end
	end);

	local text, color = self:GetSelectedOwnerText();
	self.HouseOwnerDropdown:OverrideText(text);
	self.HouseOwnerDropdown.Text:SetTextColor(color.r, color.g, color.b);

	--If the selected index is -1 we failed to fetch the player's list of characters from the server
	if self.selectedOwnerID == -1 then
		self.HouseOwnerDropdown:Disable();
	else
		self.HouseOwnerDropdown:Enable();
	end
end

function HousingHouseSettingsFrameMixin:GetSelectedOwnerText()
	if self.selectedOwnerID == -1 then
		return "", RED_FONT_COLOR;
	end
	local charInfo = self.characterList[self.selectedOwnerID];
	local classInfo = C_CreatureInfo.GetClassInfo(charInfo.classID);
	local color = (classInfo and RAID_CLASS_COLORS[classInfo.classFile]) or NORMAL_FONT_COLOR;
	return charInfo.characterName, color;
end

function HousingHouseSettingsFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HouseSettingsFrameShownEvents);
	C_Housing.RequestCurrentHouseInfo();
end

function HousingHouseSettingsFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseSettingsFrameShownEvents);
end

function HousingHouseSettingsFrameMixin:OnAccessChanged()
	--TODO: save out a dirty bool in case we want a popup when closing the panel with pending changes instead of saving?
end

function HousingHouseSettingsFrameMixin:OnIgnoreListClicked()
	ToggleFriendsFrame(FRIEND_TAB_FRIENDS);
	ToggleIgnorePanel();
end

function HousingHouseSettingsFrameMixin:OnAbandonHouseClicked()
	PlaySound(SOUNDKIT.HOUSING_SETTINGS_RELINQUISH_BUTTON);
	AbandonHouseConfirmationDialog:SetHouseInfo(self.houseInfo);
	StaticPopupSpecial_Show(AbandonHouseConfirmationDialog);
end

function HousingHouseSettingsFrameMixin:OnSaveClicked()
	PlaySound(SOUNDKIT.HOUSING_SETTINGS_SAVE_BUTTON);
	local newOwnerGUID = self.characterList[self.selectedOwnerID].playerGUID;
	local accessSettings = FlagsUtil.Combine(self.PlotAccess.selectedOptions, self.HouseAccess.selectedOptions, true);
	C_Housing.SaveHouseSettings(newOwnerGUID, accessSettings);
	HideUIPanel(self);
end

HouseSettingsAccessOptionsMixin = {}

function HouseSettingsAccessOptionsMixin:SetSelectedSettings(currentlySelectedSettings)
	self.selectedOptions = 0;
	if FlagsUtil.IsSet(currentlySelectedSettings, self.anyoneAccessFlag) then
		self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, self.anyoneAccessFlag, true);
		self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_ANYONE);
	else
		local noneSelected = true;
		for _i, accessOption in pairs(self.accessOptions) do
			if FlagsUtil.IsSet(currentlySelectedSettings, accessOption.Checkbox.accessType) then
				local isSet = true;
				local shouldCallback = false;
				self:OptionSelected(accessOption.Checkbox.accessType, isSet, shouldCallback);
				noneSelected = false;
			end
		end
		if noneSelected then
			self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_NOONE);
		end
	end
end

function HouseSettingsAccessOptionsMixin:DisableSettings()
	for _i, accessOption in pairs(self.accessOptions) do
		accessOption.Checkbox:Disable();
		accessOption.OptionLabel:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
end

function HouseSettingsAccessOptionsMixin:SetupAccessTypeDropdown()

	self.AccessTypeDropdown:SetupMenu(function(dropdown, rootDescription)

		rootDescription:CreateButton(HOUSING_HOUSE_SETTINGS_ANYONE, function() self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_ANYONE) end);
		rootDescription:CreateButton(HOUSING_HOUSE_SETTINGS_NOONE, function() self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_NOONE) end);
		rootDescription:CreateButton(HOUSING_HOUSE_SETTINGS_LIMITED, function() self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_LIMITED) end);

	end);

	self:OnAccessTypeSelected(HOUSING_HOUSE_SETTINGS_LIMITED)
end

function HouseSettingsAccessOptionsMixin:OnAccessTypeSelected(accessType)

	self.AccessTypeDropdown:OverrideText(accessType);
	if accessType == HOUSING_HOUSE_SETTINGS_ANYONE then
		self.selectedOptions = 0;
		self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, self.anyoneAccessFlag, true);
		for _i, accessOption in pairs(self.accessOptions) do
			accessOption.Checkbox:SetChecked(true);
			self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, accessOption.Checkbox.accessType, true);
			accessOption.Checkbox:Disable();
			accessOption.OptionLabel:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	elseif accessType == HOUSING_HOUSE_SETTINGS_NOONE then
		self.selectedOptions = 0;
		for _i, accessOption in pairs(self.accessOptions) do
			accessOption.Checkbox:SetChecked(false);
			self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, accessOption.Checkbox.accessType, false);
			accessOption.Checkbox:Disable();
			accessOption.OptionLabel:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end
	elseif accessType == HOUSING_HOUSE_SETTINGS_LIMITED then
		self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, self.anyoneAccessFlag, false);
		for _i, accessOption in pairs(self.accessOptions) do
			accessOption.Checkbox:Enable();
			accessOption.OptionLabel:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	end

end

function HouseSettingsAccessOptionsMixin:SetupOptions(label, accessTypes, anyoneAccessFlag)
	self.accessOptions = {};
	self.anyoneAccessFlag = anyoneAccessFlag;
	self.selectedOptions = 0;
	self.Label:SetText(label);
	for i, accessType in pairs(accessTypes) do
		local option = CreateFrame("FRAME", nil, self.Options, "HouseSettingsAccessButtonTemplate");
		option.layoutIndex = i;
		option.OptionLabel:SetText(HousingAccessTypeStrings[accessType]);
		option.Checkbox.accessType = accessType;
		option.Checkbox.accessOptionsMixin = self;
		option.Checkbox:SetScript("OnClick", function(self)
			self.accessOptionsMixin:OptionSelected(self.accessType, self:GetChecked(), true);
			PlaySound(SOUNDKIT.HOUSING_SETTINGS_TOGGLE_CHECKBOX);
		end);
		--option.Checkbox:SetChecked(FlagsUtil.IsSet(selectedAccessTypes, accessType));
		table.insert(self.accessOptions, option);
	end
	self.Options:Layout();
end

function HouseSettingsAccessOptionsMixin:SetOptionSelectedCallback(callbackFunction)
	self.callbackFunction = callbackFunction;
end

function HouseSettingsAccessOptionsMixin:OptionSelected(accessType, isChecked, shouldCallback)
	self.selectedOptions = FlagsUtil.Combine(self.selectedOptions, accessType, isChecked);
	for _i, accessOption in ipairs(self.accessOptions) do
		accessOption.Checkbox:SetChecked(FlagsUtil.IsSet(self.selectedOptions, accessOption.Checkbox.accessType));
	end

	if self.callbackFunction then
		self.callbackFunction(self.selectedOptions);
	end
end

AbandonHouseConfirmationDialogMixin = {}

function AbandonHouseConfirmationDialogMixin:OnLoad()
	self.ConfirmButton:SetText(HOUSING_HOUSE_SETTINGS_ABANDON_CONFIRM);
	self.CancelButton:SetText(HOUSING_HOUSE_SETTINGS_ABANDON_CANCEL);
	self.ConfirmButton:SetScript("OnClick", GenerateClosure(self.OnConfirmClicked, self));
	self.CancelButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_SETTINGS_RELINQUISH_BUTTON_CANCEL);
		StaticPopupSpecial_Hide(AbandonHouseConfirmationDialog);
	end);
end

function AbandonHouseConfirmationDialogMixin:SetHouseInfo(houseInfo)
	self.houseInfo = houseInfo;
	self.HouseName:SetText(houseInfo.houseName);
	self.PlotNumber:SetText(string.format(HOUSING_PLOT_NUMBER, houseInfo.plotID));
	self.NameNeighborhoodName:SetText(houseInfo.neighborhoodName);
	MoneyFrame_Update("AbandonHouseRefundMoneyFrame", 0); --TODO: Include refund amount in house info to display here
end

function AbandonHouseConfirmationDialogMixin:OnConfirmClicked()
	PlaySound(SOUNDKIT.HOUSING_SETTINGS_RELINQUISH_BUTTON_CONFIRMATION);

	C_Housing.RelinquishHouse(self.houseInfo.houseGUID);
	StaticPopupSpecial_Hide(AbandonHouseConfirmationDialog);
	HideUIPanel(HousingHouseSettingsFrame);
end
