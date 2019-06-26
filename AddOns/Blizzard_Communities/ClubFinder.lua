local GUILD_CARDS_PER_PAGE = 3; 

ClubsRecruitmentDialogMixin = {}; 

function ClubsRecruitmentDialogMixin:OnLoad()
	self.LookingForDropdown:Initialize(); 
	self.ClubFocusDropdown:Initialize(); 
	UIDropDownMenu_SetWidth(self.LookingForDropdown, 180);
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 180);
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 
end 

function ClubsRecruitmentDialogMixin:OnShow()
	self:GetParent():RegisterDialogShown(self);
end 

function ClubsRecruitmentDialogMixin:PostClub() 
	local communityFrame = self:GetParent();
	local clubInfo = C_Club.GetClubInfo(communityFrame:GetSelectedClubId());
	local specsInList = self.LookingForDropdown:GetSpecsList(); 

	local minItemLevel = self.MinIlvlOnly.EditBox:GetNumber();
	local description = self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:GetText():gsub("\n",""); 
	local minimumLevel = 0; 

	if (self.MaxLevelOnly.Button:GetChecked()) then 
		minimumLevel = GetMaxLevelForExpansionLevel(LE_EXPANSION_BATTLE_FOR_AZEROTH);
	end 

	if(clubInfo) then 
		local autoAcceptApplicants = false; -- Guild finder should never have the ability to auto-accept. 
		C_ClubFinder.PostClub(clubInfo.clubId, self.ShouldListClub.Button:GetChecked(), autoAcceptApplicants,  minimumLevel, minItemLevel, clubInfo.name, description, specsInList, Enum.ClubFinderRequestType.Guild);
		self:Hide(); 
	end
end 

ClubFinderRequestToJoinMixin = {};

function ClubFinderRequestToJoinMixin:ApplyToClub()
	local editbox = self.MessageFrame.MessageScroll.EditBox;
	local selectedSpecs = { }; 
	for i, spec in ipairs(self.Specs) do 
		if(spec.CheckBox:GetChecked()) then 
			table.insert(selectedSpecs, spec.specID);
		end 
	end 

	C_ClubFinder.RequestMembershipToClub(self.info.clubFinderGUID, editbox:GetText():gsub("\n",""), selectedSpecs);
	local requestType; 
	if (self:GetParent().isGuildType) then 
		requestType = Enum.ClubFinderRequestType.Guild; 
	else 
		requestType = Enum.ClubFinderRequestType.Community; 
	end

	C_ClubFinder.PlayerRequestPendingClubsList(requestType);

	self.card.RequestJoin:Hide(); 
	self.card.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	self.card.RequestStatus:SetText(CLUB_FINDER_PENDING);
	self.card.RequestStatus:Show();
end 

function ClubFinderRequestToJoinMixin:HideSpecButtons()
	for _, SpecButton in ipairs(self.Specs) do 
		SpecButton:Hide();
	end 
end 

function ClubFinderRequestToJoinMixin:EnableOrDisableApplyButton()
	local checkedCount = 0; 
	for _, spec in ipairs(self.Specs) do 
		if(spec.CheckBox:GetChecked()) then 
			checkedCount = checkedCount + 1; 
		end
	end 

	self.Apply:SetEnabled(checkedCount ~= 0);
end

function ClubFinderRequestToJoinMixin:Initialize()
	self.info = self.card.cardInfo;

	self:HideSpecButtons();

	if (not self.info) then 
		return; 
	end
	local classDisplayName, classTag = UnitClass("player");
	local color = CreateColor(GetClassColor(classTag));

	self.ClubName:SetText(self.info.name);
	self.ClubDescription:SetText(self.info.comment); 
	local specIds = ClubFinderGetPlayerSpecIds();
	local matchingSpecNames = { }; 
	local shouldShowSpecIndex = 0;

	for i, specId in ipairs(specIds) do 
		if (self.card.recruitingSpecIds[specId]) then
			local _, name, _, _, role = GetSpecializationInfoForSpecID(specId);
			table.insert(matchingSpecNames, name);
			shouldShowSpecIndex = shouldShowSpecIndex + 1; 
			self.Specs[shouldShowSpecIndex].SpecName:SetText(name); 
			self.Specs[shouldShowSpecIndex].specID = specIds[i];
			self.Specs[shouldShowSpecIndex]:Show(); 
		end
	end 

	if (#matchingSpecNames == 1) then 
		self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_RECRUITING_ONE_SPEC:format(matchingSpecNames[1], classDisplayName));
	elseif (#matchingSpecNames == 2) then 
		self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_RECRUITING_TWO_SPECS:format(matchingSpecNames[1], matchingSpecNames[2], classDisplayName));
	elseif (#matchingSpecNames == 3) then 
		self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_RECRUITING_THREE_SPECS:format(matchingSpecNames[1], matchingSpecNames[2], matchingSpecNames[3], classDisplayName));
	elseif (#matchingSpecNames == 4) then 
		self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_RECRUITING_FOUR_SPECS:format(matchingSpecNames[1], matchingSpecNames[2], matchingSpecNames[3], matchingSpecNames[4], classDisplayName));
	end 
	self:EnableOrDisableApplyButton();
	self:Show(); 
end 

SettingsDropdownMixin = {}; 
function SettingsDropdownMixin:Initialize()
	self.checkedCount = 0;
	self.checkedList = { };
end 

function SettingsDropdownMixin:AddOrRemoveFromCheckedList(text, shouldAdd)
	if (shouldAdd and not self.checkedList[text]) then 
		self.checkedCount = self.checkedCount + 1; 
	elseif (not shouldAdd and self.checkedList[text]) then 
		self.checkedCount = self.checkedCount - 1; 
	end
	self.checkedList[text] = shouldAdd and true or nil; 
end 

function SettingsDropdownMixin:UpdateDropdownText()
	if (self.checkedCount > 1) then 
		UIDropDownMenu_SetText(self, CLUB_FINDER_MULTIPLE_CHECKED);
		return;
	elseif(self.checkedCount == 1) then 
		local text = next(self.checkedList);
		UIDropDownMenu_SetText(self, text); 
	elseif(self.checkedCount == 0) then 
		UIDropDownMenu_SetText(self, NONE); 
	end
end

function SettingsDropdownMixin:SetDropdownInfoForPreferences(info, value, isPlayerApplicant, text)
	if(isPlayerApplicant) then 
		self:AddOrRemoveFromCheckedList(text, self:GetPlayerSettingsByValue(value));
		self:UpdateDropdownText(); 

		info.checked = function() return self:GetPlayerSettingsByValue(value); end;  
		info.func = function() 
			local playerValue = self:GetPlayerSettingsByValue(value);
			C_ClubFinder.SetPlayerApplicantSettings(value, not playerValue); 
			self:AddOrRemoveFromCheckedList(text, not playerValue);
			self:UpdateDropdownText(); 
		end;
	else 
		self:AddOrRemoveFromCheckedList(text, self:GetRecruitmentSettingByValue(value));
		self:UpdateDropdownText(); 

		info.checked = function() return self:GetRecruitmentSettingByValue(value) end; 
		info.func = function()
			local recruitmentValue = self:GetRecruitmentSettingByValue(value);
			C_ClubFinder.SetRecruitmentSettings(value, not recruitmentValue); 
			self:AddOrRemoveFromCheckedList(text, not recruitmentValue);
			self:UpdateDropdownText(); 
		end;
	end 
end

function SettingsDropdownMixin:GetPlayerSettingsByValue(value)
	return ClubFinderGetPlayerSettingsByValue(value);
end

function SettingsDropdownMixin:GetRecruitmentSettingByValue(value)
	local clubSettings = C_ClubFinder.GetClubRecruitmentSettings();
	if (value == Enum.ClubFinderSettingFlags.Dungeons) then 
		return clubSettings.playStyleDungeon;
	elseif (value == Enum.ClubFinderSettingFlags.Raids) then 
		return clubSettings.playStyleRaids;
	elseif (value == Enum.ClubFinderSettingFlags.Pvp) then 
		return clubSettings.playStylePvp;
	elseif (value == Enum.ClubFinderSettingFlags.Rp) then 
		return clubSettings.playStyleRP;
	elseif (value == Enum.ClubFinderSettingFlags.Social) then 
		return clubSettings.playStyleSocial;
	end
end 

ClubFocusDropdownMixin = CreateFromMixins(SettingsDropdownMixin);
function ClubFocusClubDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	info.text = GUILD_INTEREST_DUNGEON;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Dungeons, self.isPlayerApplicant, GUILD_INTEREST_DUNGEON)
	UIDropDownMenu_AddButton(info, level);

	info.text = GUILD_INTEREST_RAID;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Raids, self.isPlayerApplicant, GUILD_INTEREST_RAID)
	UIDropDownMenu_AddButton(info, level);

	info.text = PVP_ENABLED;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Pvp, self.isPlayerApplicant, PVP_ENABLED)
	UIDropDownMenu_AddButton(info, level);

	info.text = GUILD_INTEREST_RP;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Rp, self.isPlayerApplicant, GUILD_INTEREST_RP)
	UIDropDownMenu_AddButton(info, level);

	info.text = SOCIAL_BUTTON;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Social, self.isPlayerApplicant, SOCIAL_BUTTON)
	UIDropDownMenu_AddButton(info, level); 
end

LookingForDropdownMixin = CreateFromMixins(SettingsDropdownMixin); 

function LookingForDropdownMixin:GetSpecsList()
	local specList = { };
	for i, spec in pairs(self.checkedList) do 
		table.insert(specList, spec.specID);
	end 
	return specList; 
end 

function LookingForDropdownMixin:IsSpecInList(specID)
	if (self.checkedList and self.checkedList[specID]) then 
		return true; 
	else 
		return false;
	end 
end 

function LookingForDropdownMixin:ModifyTrackedSpecList(specName, className, specID, shouldAdd)
	if((shouldAdd and not self.checkedList[specID]))then
		self.checkedCount = self.checkedCount + 1; 
	elseif ((not shouldAdd and self.checkedList[specID])) then 
		self.checkedCount = self.checkedCount - 1;
	end
	self.checkedList[specID] = shouldAdd and {specID = specID, specName = specName, className = className} or nil ; 
end

function LookingForDropdownMixin:CheckOrUncheckAll(info, roleToMatch, checkAll)
	local numClasses = GetNumClasses();
	local sex = UnitSex("player");
	for i = 1, numClasses do
		local className, classTag, classID = GetClassInfo(i);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			local specID, specName, _, _, role = GetSpecializationInfoForClassID(classID, i, sex);
			if(role == roleToMatch) then 
				self:ModifyTrackedSpecList(specName, className, specID, checkAll); 
			end
		end
	end
end 

function LookingForDropdownMixin:UpdateDropdownText(textToUpdateTo)
	 if (self.checkedCount > 1) then 
		UIDropDownMenu_SetText(self, CLUB_FINDER_MULTIPLE_ROLES);
	 elseif(self.checkedCount == 1) then 
		local specID, specInfo = next(self.checkedList);
		UIDropDownMenu_SetText(self, TEXT_MODE_A_STRING_VALUE_SCHOOL:format(specInfo.specName, specInfo.className)); 
	elseif(self.checkedCount == 0) then 
		UIDropDownMenu_SetText(self, NONE); 
	end
end 

function LookingForDropdownMixin:AddButtons(info, roleToMatch, level)
	local numClasses = GetNumClasses();
	local sex = UnitSex("player");

	info.text = CHECK_ALL;
	info.func = function() self:CheckOrUncheckAll(info, roleToMatch, true); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(); end; 
	UIDropDownMenu_AddButton(info, level);

	info.text = UNCHECK_ALL; 
	info.func = function() self:CheckOrUncheckAll(info, roleToMatch, false); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(); end; 
	UIDropDownMenu_AddButton(info, level);

	for i = 1, numClasses do
		local className, classTag, classID = GetClassInfo(i);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			local specID, specName, _, _, role = GetSpecializationInfoForClassID(classID, i, sex);
			if(role == roleToMatch) then 
				info.hasArrow = false;
				info.text = TEXT_MODE_A_STRING_VALUE_SCHOOL:format(specName, className);
				local r, g, b = GetClassColor(classTag);
				info.colorCode = string.format("|cFF%02x%02x%02x", r*255, g*255, b*255);
				info.checked = function() return self:IsSpecInList(specID) end; 
				info.func = function() self:ModifyTrackedSpecList(specName, className, specID, not self:IsSpecInList(specID)); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(TEXT_MODE_A_STRING_VALUE_SCHOOL:format(specName, className)); end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end 

function LookingForDropdownMixin:SetSpecialDropdownInfo(info, value, isPlayerApplicant)
	if(isPlayerApplicant) then 
		info.checked =  function() return self:GetPlayerSettingsByValue(value); end;  
		info.func = function() 
			local playerValue = self:GetPlayerSettingsByValue(value);
			C_ClubFinder.SetPlayerApplicantSettings(value, not playerValue); 
			UIDropDownMenu_Refresh(self, 1, 2); 
		end
	else 
		info.checked = function() return self:GetRecruitmentSettingByValue(value) end; 
		info.func = function()
			local recruitmentValue = self:GetRecruitmentSettingByValue(value);
			C_ClubFinder.SetRecruitmentSettings(value, not recruitmentValue); 
			UIDropDownMenu_Refresh(self, 1, 2); 
		end
	end
end

function LookingForClubDropdownInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	self.isPlayerApplicant = true; 

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		self:AddButtons(info, "TANK", level); 
	end

	if UIDROPDOWNMENU_MENU_VALUE == 2 then
		self:AddButtons(info, "HEALER", level); 
	end

	if UIDROPDOWNMENU_MENU_VALUE == 3 then
		self:AddButtons(info, "DAMAGER", level); 
	end

	if(level == 1) then 
		info.text = TANK;
		info.value = 1; 
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func = nil;
		info.hasArrow = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = HEALER;
		info.value = 2;
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func = nil;
		info.hasArrow = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = DAMAGE;
		info.value = 3; 
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func = nil;
		info.hasArrow = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);
	end 
end

ClubSizeDropdownMixin = CreateFromMixins(SettingsDropdownMixin); 

function ClubSizeDropdownInitialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	info.text = SMALL;
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Small, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = TIME_LEFT_MEDIUM;
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Medium, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = LARGE;
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Large, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);
end

ClubFinderTypeDropdownMixin = { };
function ClubSizeTypeDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);

	info.isRadio = false;
	info.value = 1; 
	info.checked = info.value == selectedValue;

	local factionGroup = UnitFactionGroup("player");
	info.text = CLUB_FINDER_TYPE_COMMUNITY:format(factionGroup);
	local dropdownText = info.text; 

	if (info.checked) then 
		UIDropDownMenu_SetText(self, dropdownText);
	end 

	local value = info.value; 
	info.func = function() UIDropDownMenu_SetSelectedValue(self, value); self:GetParent():GetParent():UpdateType(false); UIDropDownMenu_SetText(self, dropdownText); end; 
	UIDropDownMenu_AddButton(info, level);

	info.isRadio = false;
	info.text = CLUB_FINDER_TYPE_GUILD;
	info.value = 2; 
	info.checked = info.value == selectedValue;

	local value = info.value; 
	info.func = function() UIDropDownMenu_SetSelectedValue(self, value); self:GetParent():GetParent():UpdateType(true); UIDropDownMenu_SetText(self, CLUB_FINDER_TYPE_GUILD); end; 
	UIDropDownMenu_AddButton(info, level);
end

ClubFinderOptionsMixin = { };

function ClubFinderOptionsMixin:OnLoad()
	self:SetupClubFinderOptions(); 
	self:InitializeRoleButtons(); 
	self:SetEnabledRoles(); 
end

function ClubFinderOptionsMixin:SetType(isGuildType, shouldShowGuildFinderOnly)
	if(shouldShowGuildFinderOnly) then 
		self:SetupPureGuildFinderOptions();
	elseif(isGuildType) then
		self:SetupGuildFinderOptions(); 
	else 
		self:SetupClubFinderOptions(); 
	end 
end 

function ClubFinderOptionsMixin:OnSearchButtonClick()
	local searchTerms = self.SearchBox:GetText():gsub("\n",""); 

	local classDisplayName, classTag = UnitClass("player");
	local color = CreateColor(GetClassColor(classTag));
	local specIDs = ClubFinderGetPlayerSpecIds(); 
	local filteredSpecIDs = { }; 
	for _, playerSpecID in ipairs(specIDs) do 
		local _, name, _, _, role = GetSpecializationInfoForSpecID(playerSpecID);
		if (role == "TANK" and self.TankRoleFrame.CheckBox:GetChecked()) then
			table.insert(filteredSpecIDs, playerSpecID);
		elseif (role == "DAMAGER" and self.DpsRoleFrame.CheckBox:GetChecked()) then
			table.insert(filteredSpecIDs, playerSpecID);
		elseif (role == "HEALER" and self.HealerRoleFrame.CheckBox:GetChecked()) then
			table.insert(filteredSpecIDs, playerSpecID);
		end
	end
	C_ClubFinder.RequestClubsList(self:GetParent().isGuildType, searchTerms, filteredSpecIDs); 
end 

function ClubFinderOptionsMixin:InitializeRoleButtons()
	self.TankRoleFrame.Icon:SetDesaturated(true);
	self.TankRoleFrame.CheckBox:Disable(); 
	self.HealerRoleFrame.Icon:SetDesaturated(true);
	self.HealerRoleFrame.CheckBox:Disable(); 
	self.DpsRoleFrame.Icon:SetDesaturated(true);
	self.DpsRoleFrame.CheckBox:Disable(); 

	self.DpsRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Damage));
	self.HealerRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Healer));
	self.TankRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Tank));
end 

function ClubFinderOptionsMixin:SetEnabledRoles()
	local playerSpecs = { };
	local _, _, classID = UnitClass("player");
	for i = 1, 4 do
		local role = select(5,GetSpecializationInfoForClassID(classID, i));
		if (role == "TANK") then
			self.TankRoleFrame.Icon:SetDesaturated(false);
			self.TankRoleFrame.CheckBox:Enable(); 
		elseif(role == "HEALER") then 
			self.HealerRoleFrame.Icon:SetDesaturated(false);
			self.HealerRoleFrame.CheckBox:Enable(); 
		elseif(role == "DAMAGER") then
			self.DpsRoleFrame.Icon:SetDesaturated(false);
			self.DpsRoleFrame.CheckBox:Enable(); 
		end
	end
end 

function ClubFinderOptionsMixin:SetupPureGuildFinderOptions()
	self.ClubSizeDropdown.isPlayerApplicant = true; 
	self.ClubSizeDropdown:Initialize(); 
	UIDropDownMenu_SetWidth(self.ClubSizeDropdown, 80);
	UIDropDownMenu_Initialize(self.ClubSizeDropdown, ClubSizeDropdownInitialize); 
	self.ClubSizeDropdown:ClearAllPoints(); 
	self.ClubSizeDropdown:SetPoint("RIGHT", self.ClubFocusDropdown, "RIGHT", 110, 0);
	self.ClubSizeDropdown:Show(); 

	self.ClubFocusDropdown.isPlayerApplicant = true;
	self.ClubFocusDropdown:Initialize(); 
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 180);
	UIDropDownMenu_JustifyText(self.ClubFocusDropdown, "LEFT");
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 
	self.ClubFocusDropdown:ClearAllPoints();
	self.ClubFocusDropdown:SetPoint("TOPLEFT", -5, 18);
	self.ClubFocusDropdown:Show(); 
	
	self.TankRoleFrame:ClearAllPoints(); 
	self.TankRoleFrame:SetPoint("RIGHT", self.ClubSizeDropdown, "RIGHT", 50, 10);

	self.SearchBox:ClearAllPoints(); 
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 145, 10);

	self.SortByDropdown:Hide(); 
	self.TypeDropdown:Hide(); 
end 

function ClubFinderOptionsMixin:SetupGuildFinderOptions()
	self.ClubSizeDropdown.isPlayerApplicant = true; 
	self.ClubFocusDropdown.isPlayerApplicant = true;
	self.TypeDropdown.isPlayerApplicant = true; 

	self.ClubSizeDropdown:Initialize(); 
	self.ClubFocusDropdown:Initialize(); 

	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 90);
	UIDropDownMenu_SetWidth(self.TypeDropdown, 90);
	UIDropDownMenu_SetWidth(self.ClubSizeDropdown, 80);

	UIDropDownMenu_Initialize(self.ClubSizeDropdown, ClubSizeDropdownInitialize); 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 

	self.ClubSizeDropdown:ClearAllPoints(); 
	self.ClubSizeDropdown:SetPoint("RIGHT", self.ClubFocusDropdown, "RIGHT", 110, 0);

	self.SortByDropdown:Hide(); 
	self.TypeDropdown:Show(); 
	self.ClubSizeDropdown:Show(); 
	self.ClubFocusDropdown:Show(); 
end 

function ClubFinderOptionsMixin:SetupClubFinderOptions()
	self.ClubFocusDropdown.isPlayerApplicant = true;
	self.TypeDropdown.isPlayerApplicant = true; 
	self.SortByDropdown.isPlayerApplicant = true; 

	self.ClubFocusDropdown:Initialize(); 
	self.SortByDropdown:Initialize(); 

	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 90);
	UIDropDownMenu_SetWidth(self.TypeDropdown, 90);
	UIDropDownMenu_SetWidth(self.SortByDropdown, 80);

	UIDropDownMenu_SetSelectedValue(self.TypeDropdown, 1);

	UIDropDownMenu_Initialize(self.TypeDropdown, ClubSizeTypeDropdownInitialize); 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 
	UIDropDownMenu_Initialize(self.SortByDropdown, ClubSizeDropdownInitialize); 

	self.ClubFocusDropdown:ClearAllPoints();
	self.ClubFocusDropdown:SetPoint("RIGHT", self.TypeDropdown, "RIGHT", 120, 0); 

	self.SortByDropdown:ClearAllPoints();
	self.SortByDropdown:SetPoint("RIGHT", self.ClubFocusDropdown, "RIGHT", 110, 0);

	self.TankRoleFrame:ClearAllPoints(); 
	self.TankRoleFrame:SetPoint("RIGHT", self.SortByDropdown, "RIGHT", 35, 10);

	self.SearchBox:ClearAllPoints(); 
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 130, 10);

	self.SearchBox:SetWidth(115); 
	self.Search:SetWidth(120);

	self.ClubSizeDropdown:Hide(); 
	self.SortByDropdown:Show(); 
	self.ClubFocusDropdown:Show(); 
	self.TypeDropdown:Show(); 
end 

function CardRightClickOptionsMenuInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		info.text = CLUB_FINDER_REPORT_SPAM; 
		info.notCheckable = true; 
		info.func = function() C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_SPAM, self:GetParent():GetCardName()); end
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_NAME; 
		info.notCheckable = true; 
		info.func = function() C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_LANGUAGE, self:GetParent():GetCardName()); end
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_DESCRIPTION; 
		info.notCheckable = true; 
		info.func = function() C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_LANGUAGE, self:GetParent():GetCardName()); end
		UIDropDownMenu_AddButton(info, level); 
	end
	
	if (level == 1) then 
		info.text = self:GetParent():GetCardName();
		info.isTitle = true; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level);

		if (self.isGuildCard) then 
			info.text = CLUB_FINDER_WHISPER_OFFICER;	
		else 
			info.text = WHISPER;
		end 

		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.isTitle = false; 
		info.notCheckable = true; 
		info.disabled = nil;
		UIDropDownMenu_AddButton(info, level);

		 if(self:GetParent():GetCardStatus() == Enum.PlayerClubRequestStatus.Pending) then 
			info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
			info.text = CANCEL;
			info.isTitle = false; 
			info.notCheckable = true; 
			info.disabled = nil;
			info.func = function()  C_ClubFinder.CancelMembershipRequest(self:GetParent():GetClubGUID()); end
			UIDropDownMenu_AddButton(info, level);
		end

		info.text = CLUB_FINDER_REPORT_FOR; 
		info.isTitle = false; 
		info.disabled = nil;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.notCheckable = true; 
		info.hasArrow = true
		info.value = 1; 
		UIDropDownMenu_AddButton(info, level);
	end
end
ClubFinderGuildCardMixin = { };

function ClubFinderGuildCardMixin:RequestToJoinClub()
	self:GetParent():GetParent().RequestToJoinFrame.card = self;

	self:GetParent():GetParent().RequestToJoinFrame:Initialize(); 
end 

function ClubFinderGuildCardMixin:GetCardName()
	return self.cardInfo.name;
end 

function ClubFinderGuildCardMixin:GetClubGUID()
	return self.cardInfo.clubFinderGUID;
end

function ClubFinderGuildCardMixin:GetCardStatus()
	return self.cardInfo.clubStatus;
end 

function ClubFinderGuildCardMixin:OnMouseDown(button)
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 100, 0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end 

function ClubFinderGuildCardMixin:SetDisabledState(shouldDisable)
	local fontColor;
	if (shouldDisable) then 
		fontColor = LIGHTGRAY_FONT_COLOR; 
		self.GuildBannerBackground:SetVertexColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
		self.GuildBannerBorder:SetVertexColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
		self.GuildBannerEmblemLogo:SetVertexColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
		self.Description:SetTextColor(fontColor:GetRGB()); 
	else 
		fontColor = HIGHLIGHT_FONT_COLOR; 
		self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB()); 
	end 

	self.CardBackground:SetDesaturated(shouldDisable);	
	self.MemberIcon:SetDesaturated(shouldDisable); 

	self.Name:SetTextColor(fontColor:GetRGB()); 
	self.MemberCount:SetTextColor(fontColor:GetRGB()); 
end 

function ClubFinderGuildCardMixin:CreateRecruitingSpecsMap()
	self.recruitingSpecIds  = { };
	for i, specId in ipairs(self.cardInfo.recruitingSpecIds) do
		self.recruitingSpecIds [specId] = {specID = specID}; 
	end
end 

function ClubFinderGuildCardMixin:UpdateCard()
	local info = self.cardInfo;

	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment); 
	self.MemberCount:SetText(info.numActiveMembers); 
	self.RightClickDropdown.isGuildCard = true; 
	if (info.tabardInfo) then 
		self.GuildBannerBackground:SetVertexColor(info.tabardInfo.backgroundColor.r, info.tabardInfo.backgroundColor.g, info.tabardInfo.backgroundColor.b);
		self.GuildBannerBorder:SetVertexColor(info.tabardInfo.borderColor.r, info.tabardInfo.borderColor.g, info.tabardInfo.borderColor.b);
		self.GuildBannerEmblemLogo:SetVertexColor(info.tabardInfo.emblemColor.r, info.tabardInfo.emblemColor.g, info.tabardInfo.emblemColor.b);
		self.GuildBannerEmblemLogo:SetTexture(info.tabardInfo.emblemFileID);
	end 
	if (info.clubStatus) then 
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 
		if(info.clubStatus == Enum.PlayerClubRequestStatus.None) then 
			self.RequestJoin:Show(); 
			self.RequestStatus:Hide(); 
			self:SetDisabledState(false); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Pending) then 
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self.RequestStatus:SetText(CLUB_FINDER_PENDING);
			self:SetDisabledState(false); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Approved or info.clubStatus == Enum.PlayerClubRequestStatus.AutoApproved) then 
			self.RequestStatus:SetText(CLUB_FINDER_ACCEPTED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Declined) then 
			self.RequestStatus:SetText(CLUB_FINDER_DECLINED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Canceled) then 
			self.RequestStatus:SetText(CLUB_FINDER_CANCELED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Joined) then 
			self.RequestStatus:SetText(CLUB_FINDER_JOINED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			
		end			
	else 
		self.RequestJoin:Show(); 
		self.RequestStatus:Hide(); 
		self:SetDisabledState(false); 
	end 
	UIDropDownMenu_Initialize(self.RightClickDropdown, CardRightClickOptionsMenuInitialize, "MENU");
end 

function ClubFinderGuildCardMixin:OnEnter() 
	local info = self.cardInfo;
	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT", 10, -60);
	GameTooltip_AddColoredLine(GameTooltip, info.name, GREEN_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, GUILD, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ACTIVE_MEMBERS:format(info.numActiveMembers));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_LOOKING_FOR);

	local classDisplayName, classTag = UnitClass("player");
	local color = CreateColor(GetClassColor(classTag));
	for _, playerSpecID in ipairs(self.playerSpecs) do 
		if (self.recruitingSpecIds[playerSpecID]) then
			local _, name, _, _, role = GetSpecializationInfoForSpecID(playerSpecID);
			local texture;
			if (role == "TANK") then
				texture = CreateAtlasMarkup("roleicon-tiny-tank");
			elseif (role == "DAMAGER") then
				texture = CreateAtlasMarkup("roleicon-tiny-dps");
			elseif (role == "HEALER") then
				texture = CreateAtlasMarkup("roleicon-tiny-healer");
			end
			GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, name.. " " ..classDisplayName), color);
		end
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, info.comment, HIGHLIGHT_FONT_COLOR, true);
	GameTooltip:Show();
end 

function ClubFinderGuildCardMixin:OnLeave()
	GameTooltip:Hide(); 
end

ClubFinderCommunitiesCardMixin = { };

function ClubFinderCommunitiesCardMixin:CreateRecruitingSpecsMap()
	self.recruitingSpecIds  = { };
	for i, specId in ipairs(self.cardInfo.recruitingSpecIds) do
		self.recruitingSpecIds [specId] = {specID = specID}; 
	end
end 

function ClubFinderCommunitiesCardMixin:GetGuildAndCommunityFrame()
	return self:GetParent():GetParent():GetParent():GetParent();
end 

function ClubFinderCommunitiesCardMixin:RequestToJoinClub()	
	local parentFrame = self:GetGuildAndCommunityFrame();
	parentFrame.RequestToJoinFrame.card = self;
	parentFrame.RequestToJoinFrame:Initialize(); 
end 

function ClubFinderCommunitiesCardMixin:SetDisabledState(shouldDisable)
	if (shouldDisable) then 
		self.Name:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGB()); 
		self.MemberCount:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGB()); 
	else 
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB()); 
		self.MemberCount:SetTextColor(NORMAL_FONT_COLOR:GetRGB()); 
	end 

	self.Background:SetDesaturated(shouldDisable);	
	self.LogoBorder:SetDesaturated(shouldDisable); 
	self.MemberIcon:SetDesaturated(shouldDisable); 
	self.CommunityLogo:SetDesaturated(shouldDisable); 
end 

function ClubFinderCommunitiesCardMixin:GetCardName()
	return self.cardInfo.name;
end 

function ClubFinderCommunitiesCardMixin:GetClubGUID()
	return self.cardInfo.clubFinderGUID;
end

function ClubFinderCommunitiesCardMixin:GetCardStatus()
	return self.cardInfo.clubStatus;
end 

function ClubFinderCommunitiesCardMixin:OnMouseDown(button)
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 0, 0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end 
function ClubFinderCommunitiesCardMixin:UpdateCard()
	local info = self.cardInfo;
	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment); 
	self.MemberCount:SetText(info.numActiveMembers); 
	self.RightClickDropdown.isGuildCard = false; 

	if (info.clubStatus) then 
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 
		if (info.clubStatus == Enum.PlayerClubRequestStatus.Pending) then 
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self.RequestStatus:SetText(CLUB_FINDER_PENDING);
			self:SetDisabledState(false); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Approved or info.clubStatus == Enum.PlayerClubRequestStatus.AutoApproved) then 
			self.RequestStatus:SetText(CLUB_FINDER_ACCEPTED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Declined) then 
			self.RequestStatus:SetText(CLUB_FINDER_DECLINED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Canceled) then 
			self.RequestStatus:SetText(CLUB_FINDER_CANCELED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true); 
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Joined) then 
			self.RequestStatus:SetText(CLUB_FINDER_Joined);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false); 
		end			
	else 
		self.RequestJoin:Show(); 
		self.RequestStatus:Hide(); 
		self:SetDisabledState(false); 
	end 

	UIDropDownMenu_Initialize(self.RightClickDropdown, CardRightClickOptionsMenuInitialize, "MENU");
end 

function ClubFinderCommunitiesCardMixin:OnEnter() 
	local info = self.cardInfo;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddColoredLine(GameTooltip, info.name, GREEN_FONT_COLOR);
	GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_COMMUNITY_TYPE, HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ACTIVE_MEMBERS:format(info.numActiveMembers));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_LOOKING_FOR);
	local classDisplayName, classTag = UnitClass("player");
	local color = CreateColor(GetClassColor(classTag));
	for _, playerSpecID in ipairs(self.playerSpecs) do 
		if (self.recruitingSpecIds [playerSpecID]) then
			local _, name, _, _, role = GetSpecializationInfoForSpecID(playerSpecID);
			local texture;
			if (role == "TANK") then
				texture = CreateAtlasMarkup("roleicon-tiny-tank");
			elseif (role == "DAMAGER") then
				texture = CreateAtlasMarkup("roleicon-tiny-dps");
			elseif (role == "HEALER") then
				texture = CreateAtlasMarkup("roleicon-tiny-healer");
			end
			GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, name.. " " ..classDisplayName), color);
		end
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, info.comment, HIGHLIGHT_FONT_COLOR, true);
	GameTooltip:Show();
end 

function ClubFinderCommunitiesCardMixin:OnLeave()
	GameTooltip:Hide(); 
end

function ClubFinderGetPlayerSpecIds()
	local playerSpecs = { };
	local _, _, classID = UnitClass("player");
	for i = 1, GetNumSpecializationsForClassID(classID) do
		local specID = GetSpecializationInfoForClassID(classID, i);
		if(specID) then 
			table.insert(playerSpecs, specID); 
		end
	end
	return playerSpecs;
end 

ClubFinderCommunitiesCardFrameMixin = { }; 

function ClubFinderCommunitiesCardFrameMixin:OnLoad()
	self.PendingCardList = { };
	self.CardList = { };
	self.pendingCardListSize = 0; 
	self.isPendingListShowing = false;
	self.ListScrollFrame.update = function() self:RefreshLayout() end;

	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "ClubFinderCommunitiesCardTemplate", 13, -10, "TOPLEFT", nil, nil, -5);
end 

function ClubFinderCommunitiesCardFrameMixin:BuildCardList()
	self.CardList = C_ClubFinder.ReturnMatchingCommunityList(); 
	self.ListScrollFrame.scrollBar:Hide();
	self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND); 	
end 

function ClubFinderCommunitiesCardFrameMixin:BuildPendingCardList()
	self.PendingCardList = C_ClubFinder.PlayerReturnPendingCommunitiesList(); 
	self.pendingCardListSize = #self.PendingCardList;
	self.ListScrollFrame.scrollBar:Hide();
	self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND); 
end 

function ClubFinderCommunitiesCardFrameMixin:RefreshLayout()
	local playerSpecs = ClubFinderGetPlayerSpecIds(); 
	local showingCards = 0; 
	local numCardsTotal = 0; 
	local scrollFrame = self.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);

	local index; 
	if (self.ListScrollFrame.buttons) then 
		if (self.isPendingListShowing) then 
			numCardsTotal = self.pendingCardListSize;
			for i = 1, #self.ListScrollFrame.buttons do 
				index = offset + i;
				local cardInfo = self.PendingCardList[index]; 
				local currentCard = self.ListScrollFrame.buttons[i];
				if (cardInfo) then 
					currentCard.playerSpecs = playerSpecs; 
					currentCard.cardInfo = cardInfo;
					currentCard:UpdateCard(); 
					currentCard:Show();  
					showingCards = showingCards + 1; 
				else 
					currentCard:Hide(); 
				end
			end
		else
			numCardsTotal = #self.CardList;
			for i = 1, #self.ListScrollFrame.buttons do 
				index = offset + i;
				local cardInfo = self.CardList[index]; 
				local currentCard = self.ListScrollFrame.buttons[i];
				if(cardInfo) then 
					currentCard.playerSpecs = playerSpecs; 
					currentCard.cardInfo = cardInfo;
					currentCard:UpdateCard(); 
					currentCard:Show();  
					showingCards = showingCards + 1; 
				else 
					currentCard:Hide(); 
				end 
			end
		end 
	end 

	if (showingCards > 0) then 
		if (self:GetParent().InsetFrame.GuildDescription:IsShown()) then 
			self:GetParent().InsetFrame.GuildDescription:Hide(); 
		end
		self:Show(); 
	else 
		self:GetParent().InsetFrame.GuildDescription:Show(); 
	end 

	local displayedHeight = showingCards * 76;
	local totalHeight = numCardsTotal * 76;
	HybridScrollFrame_Update(self.ListScrollFrame, totalHeight, displayedHeight);
end 

ClubFinderGuildCardsMixin = { }; 

function ClubFinderGuildCardsMixin:OnLoad()
	self.PendingCardList = { };
	self.CardList = { }; 
	self.numPages = 1;
	self.pageNumber = 1;
end 

function ClubFinderGuildCardsMixin:OnShow()
	self:RefreshLayout(self.pageNumber);
end 

function ClubFinderGuildCardsMixin:PageNext()
	self.pageNumber = self.pageNumber + 1; 
	self:RefreshLayout(self.pageNumber);
end 

function ClubFinderGuildCardsMixin:PagePrevious()
	self.pageNumber = self.pageNumber - 1; 
	self:RefreshLayout(self.pageNumber);
end

function ClubFinderGuildCardsMixin:BuildCardList()
	self.CardList = { }; 
	self.CardList = C_ClubFinder.ReturnMatchingGuildList(); 
	self.numPages = 0;

	if( #self.CardList == 0) then 
		self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND); 
	else 
		self.numPages = math.floor(#self.CardList / GUILD_CARDS_PER_PAGE); --Need to get the number of pages
	end
end 

function ClubFinderGuildCardsMixin:BuildPendingCardList()
	self.PendingCardList = C_ClubFinder.PlayerReturnPendingGuildsList(); 
	self.pendingCardListSize = #self.PendingCardList; 
	self.numPendingPages = math.floor(#self.PendingCardList / GUILD_CARDS_PER_PAGE); 
end 

function ClubFinderGuildCardsMixin:HideCardList()
	for i = 1, #self.Cards do 
		self.Cards[i]:Hide(); 
	end
end 
		
function ClubFinderGuildCardsMixin:RefreshLayout(cardPage)
	if(not cardPage) then
		cardPage = 1; 
	end

	self:HideCardList(); 

	local playerSpecs = ClubFinderGetPlayerSpecIds(); 
	local showingCards = false;

	if (self.isPendingListShowing) then
		for i = 1, #self.Cards do 
			local pendingCardIndex = (cardPage - 1) * GUILD_CARDS_PER_PAGE + i; 
			local cardInfo = self.PendingCardList[pendingCardIndex]; 
			if(cardInfo) then 
				self.Cards[i].playerSpecs = playerSpecs; 
				self.Cards[i].cardInfo = cardInfo;
				self.Cards[i]:UpdateCard(); 
				self.Cards[i]:Show();  
				showingCards = true; 
			else 
				self.Cards[i]:Hide(); 
			end
		end
	else
		for i = 1, #self.Cards do 
			local cardIndex = (cardPage - 1) * GUILD_CARDS_PER_PAGE + i; 
			local cardInfo = self.CardList[cardIndex]; 
			if(cardInfo) then 
				self.Cards[i].playerSpecs = playerSpecs; 
				self.Cards[i].cardInfo = cardInfo;
				self.Cards[i]:UpdateCard(); 
				self.Cards[i]:Show();  
				showingCards = true; 
			else 
				self.Cards[i]:Hide(); 
			end 
		end
	end
	if (showingCards) then 
		if(self.numPages <= 1) then 
			self.PreviousPage:Hide(); 
			self.NextPage:Hide(); 
		else 
			self.PreviousPage:Show(); 
			self.NextPage:Show(); 
		end
		if (self:GetParent().InsetFrame.GuildDescription:IsShown()) then 
			self:GetParent().InsetFrame.GuildDescription:Hide(); 
		end
		self:Show(); 
	else 
		self:GetParent().InsetFrame.GuildDescription:Show(); 
		self.PreviousPage:Hide(); 
		self.NextPage:Hide(); 
	end 

	if(cardPage <= 1) then 
		self.PreviousPage:SetEnabled(false); 
	else 
		self.PreviousPage:SetEnabled(true); 
	end 

	if((cardPage <= self.numPages and not shouldShowPendingList) or (cardPage <= self.numPendingPages and shouldShowPendingList)) then
		self.NextPage:SetEnabled(true);
	else 
		self.NextPage:SetEnabled(false); 
	end 
end 

ClubFinderCheckboxMixin = { }; 
function ClubFinderCheckboxMixin:OnClick() 
	if (self:GetChecked()) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end 
ClubFinderGuildAndCommunityMixin = { }; 
function ClubFinderGuildAndCommunityMixin:OnLoad()
	self.PendingClubs:SetEnabled(false); 
	self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(0));
	self.InsetFrame.GuildDescription:Show(); 
	self.GuildCards.pendingCardListSize = 0;
	self:Show(); 
end 

function ClubFinderGuildAndCommunityMixin:SetGuildFinderModeOnly()
	self.OptionsList:SetType(self.isGuildType, self.shouldShowGuildFinderOnly);
	self.GuildCards:RefreshLayout(); 
	self.InsetFrame.GuildDescription:SetText(CLUB_FINDER_NO_OPTIONS_SELECTED_GUILD_MESSAGE);
	self.CommunityCards:Hide(); 
	if (self.GuildCards.pendingCardListSize) then 
		self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(self.GuildCards.pendingCardListSize));

		if (self.GuildCards.pendingCardListSize > 0) then 
			self.PendingClubs:SetEnabled(true); 
		else 
			self.PendingClubs:SetEnabled(false); 
		end
	end
end 

function ClubFinderGuildAndCommunityMixin:OnShow()
	CommunitiesFrameInset:Hide(); 
	self:RegisterEvent("CLUB_FINDER_CLUB_LIST_RETURNED");
	self:RegisterEvent("CLUB_FINDER_MEMBERSHIP_LIST_CHANGED");
	self:RegisterEvent("CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED");
	self:RegisterEvent("CLUB_FINDER_POST_UPDATED");
	self:RegisterEvent("CLUB_FINDER_RECRUIT_LIST_CHANGED");
	self:RegisterEvent("CLUB_FINDER_RECRUITS_UPDATED");
	
	C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All); -- Player's applications to a guild or community
	self:UpdateType(self.shouldShowGuildFinderOnly); --Should show communities list first. 
	self.OptionsList:Show(); 
end 

function ClubFinderGuildAndCommunityMixin:ResetToDefaults()
	self.GuildCards.CardList = { }; 
	self.CommunityCards.CardList = { };
	self.GuildCards.PendingCardList = { }; 
	self.CommunityCards.PendingCardList = { };
	self.OptionsList.SearchBox:SetText("");
	self.isPendingListShowing = true;
end 

function ClubFinderGuildAndCommunityMixin:OnHide()
	CommunitiesFrameInset:Show(); 
	self:ResetToDefaults();
end 

function ClubFinderGuildAndCommunityMixin:OnEvent(event, ...)
	if (event == "CLUB_FINDER_CLUB_LIST_RETURNED") then
		local requestType = ...;
		local buildGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All); 
		local builCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All); 
		if (buildGuild) then
			self.GuildCards:BuildCardList();
			if (self.isGuildType) then
				self.GuildCards.isPendingListShowing = false; 
				self.GuildCards:RefreshLayout(); 
				self.GuildCards:Show(); 
			end 
		end
		if (builCommunity) then
			self.CommunityCards:BuildCardList(); 
			if (not self.isGuildType) then
				self.CommunityCards.isPendingListShowing = false; 
				self.CommunityCards:RefreshLayout(); 
				self.CommunityCards:Show(); 
			end
		end
	elseif (event == "CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED") or (event == "CLUB_FINDER_RECRUIT_LIST_CHANGED") or (event == "CLUB_FINDER_RECRUITS_UPDATED") then 
		local requestType = ...;
		local buildGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All); 
		local builCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All); 
		if (buildGuild) then
			self.GuildCards:BuildPendingCardList();
			self.GuildCards:RefreshLayout(); 
		end
		if (builCommunity) then
			self.CommunityCards:BuildPendingCardList();
			self.GuildCards:RefreshLayout(); 
		end
		self:UpdateType(self.isGuildType);

		if (self.isGuildType) then 
			self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(self.GuildCards.pendingCardListSize));
		else 
			self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(self.CommunityCards.pendingCardListSize));
		end
	end 
end 

function ClubFinderGuildAndCommunityMixin:UpdateType(isGuild)
	if (isGuild) then 
		self.isGuildType = true; 
		self.OptionsList:SetType(self.isGuildType, self.shouldShowGuildFinderOnly);
		self.GuildCards:RefreshLayout(); 
		self.InsetFrame.GuildDescription:SetText(CLUB_FINDER_NO_OPTIONS_SELECTED_GUILD_MESSAGE);
		self.CommunityCards:Hide(); 
		if (self.GuildCards.pendingCardListSize) then 
			self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(self.GuildCards.pendingCardListSize));
			if (self.GuildCards.pendingCardListSize > 0) then 
				self.PendingClubs:SetEnabled(true); 
			else 
				self.PendingClubs:SetEnabled(false); 
			end
		end
	else 
		self.isGuildType = false; 
		self.OptionsList:SetType(self.isGuildType, self.shouldShowGuildFinderOnly);
		self.CommunityCards:RefreshLayout(); 
		self.GuildCards:Hide(); 
		self.InsetFrame.GuildDescription:SetText(BROWSE_SEARCH_TEXT);
		if (self.CommunityCards.pendingCardListSize) then 

			self.PendingClubs:SetText(CLUB_FINDER_PENDING_REQUESTS:format(self.CommunityCards.pendingCardListSize));

			if (self.CommunityCards.pendingCardListSize > 0) then 
				self.PendingClubs:SetEnabled(true); 
			else 
				self.PendingClubs:SetEnabled(false); 
			end 
		end
	end
end 

ClubFinderPendingClubsMixin = { }; 

function ClubFinderPendingClubsMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local parentFrame = self:GetParent();
	if (self:GetParent().isGuildType) then 
		parentFrame.GuildCards.isPendingListShowing = not parentFrame.GuildCards.isPendingListShowing;
		self:GetParent().GuildCards:RefreshLayout(1);
	else 
		parentFrame.CommunityCards.isPendingListShowing = not parentFrame.CommunityCards.isPendingListShowing
		self:GetParent().CommunityCards:RefreshLayout(); 
	end
end 


ClubFinderInvitationsFrameMixin = { }; 

function ClubFinderInvitationsFrameMixin:DisplayInvitation(clubInfo) 
	self.clubInfo = clubInfo; 
	if(not clubInfo) then 
		return;
	end
	if (clubInfo.tabardInfo) then 
		self.GuildBannerBackground:SetVertexColor(clubInfo.tabardInfo.backgroundColor.r, clubInfo.tabardInfo.backgroundColor.g, clubInfo.tabardInfo.backgroundColor.b);
		self.GuildBannerBorder:SetVertexColor(clubInfo.tabardInfo.borderColor.r, clubInfo.tabardInfo.borderColor.g, clubInfo.tabardInfo.borderColor.b);
		self.GuildBannerEmblemLogo:SetVertexColor(clubInfo.tabardInfo.emblemColor.r, clubInfo.tabardInfo.emblemColor.g, clubInfo.tabardInfo.emblemColor.b);
		self.GuildBannerEmblemLogo:SetTexture(clubInfo.tabardInfo.emblemFileID);
	end

	local isGuild = clubInfo.isGuild; 

	if	(isGuild) then 
		self.Type:SetText(CLUB_FINDER_TYPE_GUILD); 
	else 
		self.Type:SetText(CLUB_FINDER_COMMUNITY_TYPE); 
	end

	self.Icon:SetShown(not isGuild); 
	self.IconRing:SetShown(not isGuild); 
	self.CircleMask:SetShown(not isGuild);
	self.GuildBannerBackground:SetShown(isGuild); 
	self.GuildBannerBorder:SetShown(isGuild); 
	self.GuildBannerEmblemLogo:SetShown(isGuild); 
	self.GuildBannerShadow:SetShown(isGuild);
	self.Name:SetText(clubInfo.name);
	self.Description:SetText(clubInfo.comment);
	self.Leader:SetText(COMMUNITIES_INVIVATION_FRAME_LEADER_FORMAT:format(clubInfo.guildLeader)); 
	self.MemberCount:SetText(COMMUNITIES_INVITATION_FRAME_MEMBER_COUNT:format(clubInfo.numActiveMembers or 1));
	self.InvitationText:SetText(COMMUNITY_INVITATION_FRAME_INVITATION_TEXT:format(clubInfo.guildLeader));
	self:GetParent().InvitationFrame:Hide();
	self:Show(); 
end 

function ClubFinderInvitationsFrameMixin:AcceptInvitation()
	C_ClubFinder.ApplicantAcceptClubInvite(self.clubInfo.clubFinderGUID);
	self:GetParent():SelectClub(nil);
	self:GetParent():UpdateClubSelection();
	self:Hide();

	if (self.clubInfo.isGuild) then 
		C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.Guild)
	else 
		C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.Community)
	end
end 


function ClubFinderInvitationsFrameMixin:DeclineInvitation()
	C_ClubFinder.ApplicantDeclineClubInvite(self.clubInfo.clubFinderGUID);
	self:GetParent():SelectClub(nil);
	self:GetParent():UpdateClubSelection();
	self:Hide();

	if (self.clubInfo.isGuild) then 
		C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.Guild)
	else 
		C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.Community)
	end
end 

ClubsFinderJoinClubWarningMixin = { };

function ClubsFinderJoinClubWarningMixin:OnShow() 
	if (IsInGuild()) then 
		self:SetSize(400, 80);
		self.DialogLabel:SetText(CLUB_FINDER_ACCEPT_GUILD_ALREADY_IN_GUILD_WARNING); 
	else 
		self:SetSize(400, 90);
		self.DialogLabel:SetText(CLUB_FINDER_ACCEPT_GUILD_STANDARD_WARNING); 
	end 
end

function ClubsFinderJoinClubWarningMixin:OnAcceptButtonClick() 
	self:GetParent():AcceptInvitation();
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end 

function ClubsFinderJoinClubWarningMixin:OnCancelButtonClick()
	self:Hide(); 
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end 

function ClubFinderGetPlayerSettingsByValue(value)
	local playerSettings = C_ClubFinder.GetPlayerApplicantSettings();
	if (value == Enum.ClubFinderSettingFlags.Dungeons) then 
		return playerSettings.playStyleDungeon;
	elseif (value == Enum.ClubFinderSettingFlags.Raids) then 
		return playerSettings.playStyleRaids;
	elseif (value == Enum.ClubFinderSettingFlags.Pvp) then 
		return playerSettings.playStylePvp;
	elseif (value == Enum.ClubFinderSettingFlags.Rp) then 
		return playerSettings.playStyleRP;
	elseif (value == Enum.ClubFinderSettingFlags.Social) then 
		return playerSettings.playStyleSocial;
	elseif (value == Enum.ClubFinderSettingFlags.Tank) then 
		return playerSettings.roleTank; 
	elseif (value ==  Enum.ClubFinderSettingFlags.Healer) then 
		return playerSettings.roleHealer; 
	elseif (value ==  Enum.ClubFinderSettingFlags.Damage) then 
		return playerSettings.roleDps; 
	elseif (value ==  Enum.ClubFinderSettingFlags.Small) then 
		return playerSettings.sizeSmall;
	elseif (value ==  Enum.ClubFinderSettingFlags.Medium) then 
		return playerSettings.sizeMedium;
	elseif (value ==  Enum.ClubFinderSettingFlags.Large) then 
		return playerSettings.sizeLarge;
	end
end