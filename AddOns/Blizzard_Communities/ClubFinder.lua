local GUILD_CARDS_PER_PAGE = 3; 
local LOAD_PAGES_IN_ADVANCE = 1;
local REQUEST_TO_JOIN_HEIGHT = 420; 
local REQUEST_TO_JOIN_TEXT_HEIGHT = 14; 
local MAX_DESCRIPTION_HEIGHT = 150; 
local REQUEST_TO_JOIN_OFFSET = 50;

local LAYOUT_TYPE_REGULAR_SEARCH = 1; 
local LAYOUT_TYPE_PENDING_LIST = 2; 


local CLUB_FINDER_FRAME_EVENTS = {
	"CLUB_FINDER_CLUB_LIST_RETURNED",
	"CLUB_FINDER_MEMBERSHIP_LIST_CHANGED",
	"CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED",
	"CLUB_FINDER_POST_UPDATED",
	"CLUB_FINDER_RECRUIT_LIST_CHANGED",
	"CLUB_FINDER_RECRUITS_UPDATED",
};

ClubsRecruitmentDialogMixin = {}; 

function ClubsRecruitmentDialogMixin:SetDisabledStateOnCommunityFinderOptions(shouldDisable)
	self.MaxLevelOnly.Button:SetEnabled(not shouldDisable); 
	self.MinIlvlOnly.Button:SetEnabled(not shouldDisable);
	if (shouldDisable) then 
		local fontColor = LIGHTGRAY_FONT_COLOR;
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		self.LookingForDropdown.LookingForDropDownLabel:SetTextColor(fontColor:GetRGB());
		self.ClubFocusDropdown.Label:SetTextColor(fontColor:GetRGB());
		self.RecruitmentMessageFrame.Label:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_DisableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_DisableDropDown(self.LookingForDropdown);
	else
		local fontColor = HIGHLIGHT_FONT_COLOR;
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		self.LookingForDropdown.LookingForDropDownLabel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.ClubFocusDropdown.Label:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.RecruitmentMessageFrame.Label:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		UIDropDownMenu_EnableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_EnableDropDown(self.LookingForDropdown);
	end 
end 

function ClubsRecruitmentDialogMixin:ResetClubFinderSettings()
	self.MinIlvlOnly.Button:SetChecked(false);
	self.MinIlvlOnly.EditBox:SetText(""); 
	self.MinIlvlOnly.EditBox.Text:Show();
	self.MaxLevelOnly.Button:SetChecked(false);
	self.ShouldListClub.Button:SetChecked(false);
	self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:SetText(""); 

	self.ClubFocusDropdown:Initialize(); 
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.Dungeons, true);
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize);
	self.ClubFocusDropdown:UpdateDropdownText(); 

	self.LookingForDropdown:Initialize(); 
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
	self.LookingForDropdown:UpdateDropdownText();
end 

function ClubsRecruitmentDialogMixin:OnLoad()
	self.LookingForDropdown:Initialize(); 
	self.ClubFocusDropdown:Initialize(); 
	self.clubId = nil;
	UIDropDownMenu_SetWidth(self.LookingForDropdown, 180);
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 180);
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
end 

function ClubsRecruitmentDialogMixin:UpdateSettingsInfoFromClubInfo()
	local communityFrame = self:GetParent();
	local clubInfo;

	if (self.clubId) then
		clubInfo = ClubFinderGetCurrentClubListingInfo(self.clubId); 
	else 
	 clubInfo = C_Club.GetClubInfo(communityFrame:GetSelectedClubId());
	end 

	self:ResetClubFinderSettings();
	if(clubInfo) then
		local clubPostingInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubInfo.clubId);
		if (clubPostingInfo) then
			self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:SetText(clubPostingInfo.comment); 
			self.LookingForDropdown:SetCheckedList(clubPostingInfo.recruitingSpecIds);
			self.LookingForDropdown:UpdateDropdownText();

			C_ClubFinder.SetAllRecruitmentSettings(clubPostingInfo.recruitmentFlags);

			local index = C_ClubFinder.GetFocusIndexFromFlag(clubPostingInfo.recruitmentFlags);
			C_ClubFinder.SetRecruitmentSettings(index, true);
			UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 

			if (clubPostingInfo.minILvl > 0) then 
				self.MinIlvlOnly.EditBox:SetText(clubPostingInfo.minILvl); 
				self.MinIlvlOnly.EditBox.Text:Hide();
				self.MinIlvlOnly.Button:SetChecked(true);
			else
				self.MinIlvlOnly.Button:SetChecked(false);
				self.MinIlvlOnly.EditBox:SetText(""); 
				self.MinIlvlOnly.EditBox.Text:Show();
			end

			local isMaxLevelChecked = self.ClubFocusDropdown:GetRecruitmentSettingByValue(Enum.ClubFinderSettingFlags.MaxLevelOnly);
			self.MaxLevelOnly.Button:SetChecked(isMaxLevelChecked);

			local shouldList = self.ClubFocusDropdown:GetRecruitmentSettingByValue(Enum.ClubFinderSettingFlags.EnableListing);
			self.ShouldListClub.Button:SetChecked(shouldList);	
			self:SetDisabledStateOnCommunityFinderOptions(not self.ShouldListClub.Button:GetChecked());
		end
	end
end

function ClubsRecruitmentDialogMixin:OnShow()
	self:GetParent():RegisterDialogShown(self);
	self:RegisterEvent("CLUB_FINDER_POST_UPDATED");
	self:UpdateSettingsInfoFromClubInfo();
end

function ClubsRecruitmentDialogMixin:OnHide() 
	self:UnregisterEvent("CLUB_FINDER_POST_UPDATED");
	self.clubId = nil;
end

function ClubsRecruitmentDialogMixin:OnEvent(event, ...)
	if (event == "CLUB_FINDER_POST_UPDATED") then 
		self:Hide(); 
	end		
end

function ClubsRecruitmentDialogMixin:PostClub() 
	local communityFrame = self:GetParent();
	local clubInfo; 

	if (self.clubId) then
		ClubFinderGetCurrentClubListingInfo(self.clubId); 
	else 
		local clubInfo = C_Club.GetClubInfo(communityFrame:GetSelectedClubId());
	end 
	local specsInList = self.LookingForDropdown:GetSpecsList(); 

	local minItemLevel = self.MinIlvlOnly.EditBox:GetNumber();
	local description = self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:GetText(); 

	
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.MaxLevelOnly, self.MaxLevelOnly.Button:GetChecked()); 
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.EnableListing, self.ShouldListClub.Button:GetChecked());


	if(clubInfo) then 
		local autoAcceptApplicants = false; -- Guild finder should never have the ability to auto-accept. 
		C_ClubFinder.PostClub(clubInfo.clubId, minItemLevel, clubInfo.name, description, specsInList, Enum.ClubFinderRequestType.Guild);
	end
end 

ClubFinderRequestToJoinMixin = {};

function ClubFinderRequestToJoinMixin:OnHide()
	self.SpecsPool:ReleaseAll();
end

function ClubFinderRequestToJoinMixin:ApplyButtonOnEnter() 
	GameTooltip:SetOwner(self.Apply, "ANCHOR_LEFT", 0, -65);
	if (not self.Apply:IsEnabled()) then 
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ONE_SPEC_REQUIRED, RED_FONT_COLOR, true);
		GameTooltip:Show();
	end 
end 

function ClubFinderRequestToJoinMixin:ApplyButtonOnLeave()
	GameTooltip:Hide();
end 

function ClubFinderRequestToJoinMixin:ApplyToClub()
	local editbox = self.MessageFrame.MessageScroll.EditBox;
	local selectedSpecs = { }; 

	for button in self.SpecsPool:EnumerateActive() do 
		if(button.CheckBox:GetChecked()) then 
			table.insert(selectedSpecs, button.specID);
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

	if (self.card.RequestJoin) then -- If we are requesting from finder. 
		self.card.RequestJoin:Hide(); 
		self.card.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self.card.RequestStatus:SetText(CLUB_FINDER_PENDING);
		self.card.RequestStatus:Show();
	else -- If we are requesting from a link. 
		self:GetParent():GetParent():SelectClub(nil);
		self:GetParent():GetParent():UpdateClubSelection();
	end
end 

function ClubFinderRequestToJoinMixin:EnableOrDisableApplyButton()
	local checkedCount = 0; 
	for button in self.SpecsPool:EnumerateActive() do 
		if(button.CheckBox:GetChecked()) then 
			checkedCount = checkedCount + 1; 
		end
	end 

	self.Apply:SetEnabled(checkedCount ~= 0);
end

function ClubFinderRequestToJoinMixin:DoesPlayerMatchRecruitingSpecs()
	local specIds = ClubFinderGetPlayerSpecIds(); 

	for i, specId in ipairs(specIds) do 
		if (self.card.recruitingSpecIds[specId]) then
			return true;
		end 
	end
	return false;
end 

function ClubFinderRequestToJoinMixin:Initialize()
	self.info = self.card.cardInfo;
	if (not self.info) then 
		return; 
	end

	self.ClubDescription:SetHeight(MAX_DESCRIPTION_HEIGHT);
	self.ClubName:SetText(self.info.name);
	self.ClubDescription:SetText(self.info.comment:gsub("\n",""));
	
	-- Calculate how tall the frame should be based off of the size of the descriptions
	local extraFrameHeight = 0; 
	local numLines = self.ClubDescription:GetNumLines(); 
	local usedHeight = (numLines * REQUEST_TO_JOIN_TEXT_HEIGHT);
	local extraHeight = (MAX_DESCRIPTION_HEIGHT - usedHeight); 
	self.ClubDescription:SetHeight(usedHeight);

	if (self.SpecsPool) then 
		self.SpecsPool:ReleaseAll();
	end

	if (not self:DoesPlayerMatchRecruitingSpecs()) then 
		extraFrameHeight = 80; 
		self.SpecsPool = CreateFramePool("FRAME", self, "ClubFinderLittleSpecializationCheckBoxTemplate");
		self.noMatchingSpecs = true;
	else 
		self.SpecsPool = CreateFramePool("FRAME", self, "ClubFinderBigSpecializationCheckBoxTemplate");
		self.noMatchingSpecs = false;
		extraFrameHeight = 70; --Base offset; 
	end 
		
	self:SetHeight((REQUEST_TO_JOIN_HEIGHT + extraFrameHeight) - (extraHeight));

	self.ClubDescription:ClearAllPoints();
	self.ClubDescription:SetPoint("BOTTOM", self.ClubName, "BOTTOM", 0, -usedHeight);

	self.MessageFrame:ClearAllPoints();
	self.MessageFrame:SetPoint("BOTTOM", self.ClubDescription, "BOTTOM", 0, -85);

	self.RecruitingSpecDescriptions:ClearAllPoints(); 
	self.RecruitingSpecDescriptions:SetPoint("BOTTOM", self.MessageFrame, "BOTTOM", 0, -35);

	self.ErrorDescription:ClearAllPoints();
	self.ErrorDescription:SetPoint("BOTTOM", self.MessageFrame, "BOTTOM", 0, -30);

	local specIds = ClubFinderGetPlayerSpecIds();
	local matchingSpecNames = { }; 

	for i, specId in ipairs(specIds) do 
		local specButton = self.SpecsPool:Acquire(); 

		if (self.noMatchingSpecs) then 
			if (i == 1) then 
				specButton:ClearAllPoints();
				specButton:SetPoint("BOTTOMLEFT", self.ErrorDescription, "BOTTOMLEFT", 10, -35); 
			else 
				specButton:ClearAllPoints();
				specButton:SetPoint("BOTTOMLEFT", self.lastSpecButton, "BOTTOMLEFT", 0, -20); 
			end 
		else 
			if (i == 1) then 
				specButton:ClearAllPoints();
				specButton:SetPoint("BOTTOMLEFT", self.RecruitingSpecDescriptions, "BOTTOMLEFT", 10, -45); 
			else 
				specButton:ClearAllPoints();
				specButton:SetPoint("BOTTOMLEFT", self.lastSpecButton, "BOTTOMLEFT", 0, -25); 
			end 
		end 

		local _, name = GetSpecializationInfoForSpecID(specId);
		specButton.SpecName:SetText(name); 
		specButton.specID = specId;
		specButton:Show(); 

		if (self.card.recruitingSpecIds[specId]) then
			table.insert(matchingSpecNames, name);
		end 

		self.lastSpecButton = specButton; 
	end

	self.RecruitingSpecDescriptions:SetShown(#matchingSpecNames > 0); 
	self.ClubDescription2:SetShown(#matchingSpecNames == 0);
	self.ErrorDescription:SetShown(#matchingSpecNames == 0);

	if(self.lastSpecButton) then 
		self.ClubDescription2:SetPoint("BOTTOM", self.lastSpecButton, "BOTTOM", 0, -30);
	end

	local classDisplayName = UnitClass("player");

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
	self.selectedValue = nil;
end 

function SettingsDropdownMixin:UpdateDropdownText(text, evalValue, value, isPlayerFocusDropdown)
	if (isPlayerFocusDropdown and C_ClubFinder.GetPlayerSettingsFocusFlagsSelectedCount() > 1) then 
		UIDropDownMenu_SetText(self, CLUB_FINDER_MULTIPLE_CHECKED); 
		self.selectedValue = value;
	elseif (evalValue and value ~= self.selectedValue) then 
		UIDropDownMenu_SetText(self, text); 
		self.selectedValue = value;
	elseif (not evalValue and value == self.selectedValue) then
		UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG); 
		self.selectedValue = nil;
	elseif (not self.selectedValue) then 
		UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG); 
	end
end

function SettingsDropdownMixin:SetDropdownInfoForPreferences(info, value, isPlayerApplicant, text, isPlayerFocusDropdown)
	if(isPlayerApplicant) then 
		self:UpdateDropdownText(text, self:GetPlayerSettingsByValue(value), value, isPlayerFocusDropdown);

		info.checked = function() return self:GetPlayerSettingsByValue(value) end;  
		info.func = function() 
			local playerValue = self:GetPlayerSettingsByValue(value);
			C_ClubFinder.SetPlayerApplicantSettings(value, not playerValue); 
			self:UpdateDropdownText(text, not playerValue, value, isPlayerFocusDropdown);
		end;
	else 

		self:UpdateDropdownText(text, self:GetRecruitmentSettingByValue(value), value); 

		info.checked = function() return self:GetRecruitmentSettingByValue(value) end; 
		info.func = function()
			local recruitmentValue = self:GetRecruitmentSettingByValue(value);
			C_ClubFinder.SetRecruitmentSettings(value, not recruitmentValue, value);	
			self:UpdateDropdownText(text, not recruitmentValue, value);
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
	elseif (value == Enum.ClubFinderSettingFlags.MaxLevelOnly) then
		return clubSettings.maxLevelOnly; 
	elseif (value == Enum.ClubFinderSettingFlags.EnableListing) then
		return clubSettings.enableListing; 
	end
end 

ClubFocusDropdownMixin = CreateFromMixins(SettingsDropdownMixin);
function ClubFocusClubDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();

	if(self.isPlayerApplicant) then 
		info.keepShownOnClick = true;
	else 
		info.keepShownOnClick = false; 
	end

	info.text = GUILD_INTEREST_DUNGEON;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Dungeons, self.isPlayerApplicant, GUILD_INTEREST_DUNGEON, self.isPlayerApplicant)
	UIDropDownMenu_AddButton(info, level);

	info.text = GUILD_INTEREST_RAID;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Raids, self.isPlayerApplicant, GUILD_INTEREST_RAID, self.isPlayerApplicant)
	UIDropDownMenu_AddButton(info, level);

	info.text = CLUB_FINDER_FOCUS_PVP;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Pvp, self.isPlayerApplicant, PVP_ENABLED, self.isPlayerApplicant)
	UIDropDownMenu_AddButton(info, level);

	info.text = GUILD_INTEREST_RP;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Rp, self.isPlayerApplicant, GUILD_INTEREST_RP, self.isPlayerApplicant)
	UIDropDownMenu_AddButton(info, level);

	info.text = CLUB_FINDER_FOCUS_SOCIAL_LEVELING;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Social, self.isPlayerApplicant, SOCIAL_BUTTON, self.isPlayerApplicant)
	UIDropDownMenu_AddButton(info, level); 
end

LookingForDropdownMixin = { }; 

function LookingForDropdownMixin:Initialize()
	self.checkedCount = 0;
	self.checkedList = { };
end 

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

function LookingForDropdownMixin:SetCheckedList(specIds) 
	for _, specId in ipairs(specIds) do
		local id, name, description, texture, role, class = GetSpecializationInfoByID(specId);
		self:ModifyTrackedSpecList(name, class, specId, true); 
	end
end 

function LookingForDropdownMixin:IsEverySpecCheckedForRole(roleToMatch)
	local numClasses = GetNumClasses();
	local sex = UnitSex("player");
	for i = 1, numClasses do
		local className, classTag, classID = GetClassInfo(i);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			local specID, specName, _, _, role = GetSpecializationInfoForClassID(classID, i, sex);
			if(role == roleToMatch) then 
				if (not self:IsSpecInList(specID)) then
					return false;
				end 
			end
		end
	end
	return true;
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
		UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG); 
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
		info.text = CLUB_FINDER_TANK;
		info.value = 1; 
		info.checked = self:IsEverySpecCheckedForRole("TANK");  
		info.func =  function() local isEverySpecChecked = self:IsEverySpecCheckedForRole("TANK"); self:CheckOrUncheckAll(info, "TANK", not isEverySpecChecked); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(); end;
		info.isNotRadio = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_HEALER;
		info.value = 2;
		info.checked = 	self:IsEverySpecCheckedForRole("HEALER");  
		info.isNotRadio = true;
		info.func = function() local isEverySpecChecked = self:IsEverySpecCheckedForRole("HEALER"); self:CheckOrUncheckAll(info, "HEALER", not isEverySpecChecked); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(); end;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_DAMAGE;
		info.value = 3; 
		info.checked = 	self:IsEverySpecCheckedForRole("DAMAGER"); 
		info.isNotRadio = true;
		info.func = function() local isEverySpecChecked = self:IsEverySpecCheckedForRole("DAMAGER"); self:CheckOrUncheckAll(info, "DAMAGER", not isEverySpecChecked); UIDropDownMenu_Refresh(self, 1, 2); self:UpdateDropdownText(); end;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);
	end 
end

ClubSortByDropdownMixin = CreateFromMixins(SettingsDropdownMixin); 

function ClubSortByDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();

	info.text = CLUB_FINDER_SORT_BY_RELEVANCE;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.SortRelevance, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = CLUB_FINDER_SORT_BY_MOST_MEMBERS;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.SortMemberCount, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = CLUB_FINDER_SORT_BY_NEWEST;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.SortNewest, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);
end

ClubSizeDropdownMixin = CreateFromMixins(SettingsDropdownMixin); 

function ClubSizeDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();

	info.text = SMALL;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Small, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = CLUB_FINDER_MEDIUM;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Medium, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);

	info.text = LARGE;
	info.isRadio = false; 
	local dropdownText = info.text; 
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Large, self.isPlayerApplicant, dropdownText)
	UIDropDownMenu_AddButton(info, level);
end

ClubFinderOptionsMixin = { };

function ClubFinderOptionsMixin:OnLoad()
	self:InitializeRoleButtons(); 
	self:SetEnabledRoles(); 
end

function ClubFinderOptionsMixin:SetType(isGuildType)
	if(isGuildType) then
		self:SetupGuildFinderOptions(); 
	else 
		self:SetupCommunityFinderOptions(); 
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

	local searchingForGuild = self:GetParent().isGuildType;

	if (not searchingForGuild) then
		self:GetParent().CommunityCards.newRequest = true;
	else 
		self:GetParent().GuildCards.newRequest = true; 
	end 

	C_ClubFinder.RequestClubsList(searchingForGuild, searchTerms, filteredSpecIDs); 
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

function ClubFinderOptionsMixin:SetOptionsState(shouldDisable)
	if (shouldDisable) then 
		self.TankRoleFrame.Icon:SetDesaturated(true);
		self.TankRoleFrame.CheckBox:SetEnabled(false)
		self.HealerRoleFrame.Icon:SetDesaturated(true);
		self.HealerRoleFrame.CheckBox:SetEnabled(false)
		self.DpsRoleFrame.Icon:SetDesaturated(true);
		self.DpsRoleFrame.CheckBox:SetEnabled(false);
		self.Search:SetEnabled(false)
		UIDropDownMenu_DisableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_DisableDropDown(self.SortByDropdown);
		UIDropDownMenu_DisableDropDown(self.ClubSizeDropdown); 
		self.SearchBox:Disable();
	else 
		self:SetEnabledRoles();
		self.Search:SetEnabled(true);
		self.SearchBox:Enable();
		UIDropDownMenu_EnableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_EnableDropDown(self.SortByDropdown);
		UIDropDownMenu_EnableDropDown(self.ClubSizeDropdown); 
	end

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

function ClubFinderOptionsMixin:SetupGuildFinderOptions()
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
	self.TankRoleFrame:SetPoint("RIGHT", self.ClubSizeDropdown, "RIGHT", 40, 10);

	self.SearchBox:ClearAllPoints(); 
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 160, 10);

	self.SortByDropdown:Hide(); 
end 

function ClubFinderOptionsMixin:SetupCommunityFinderOptions()
	self.ClubFocusDropdown.isPlayerApplicant = true;
	self.SortByDropdown.isPlayerApplicant = true; 

	UIDropDownMenu_SetWidth(self.SortByDropdown, 80);
	UIDropDownMenu_Initialize(self.SortByDropdown, ClubSortByDropdownInitialize); 

	self.SortByDropdown:ClearAllPoints(); 
	self.SortByDropdown:SetPoint("RIGHT", self.ClubFocusDropdown, "RIGHT", 110, 0);
	self.SortByDropdown:Show(); 

	self.ClubFocusDropdown.isPlayerApplicant = true;
	self.ClubFocusDropdown:Initialize(); 
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 180);
	UIDropDownMenu_JustifyText(self.ClubFocusDropdown, "LEFT");
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 

	self.ClubFocusDropdown:ClearAllPoints();
	self.ClubFocusDropdown:SetPoint("TOPLEFT", -5, 18);
	self.ClubFocusDropdown:Show(); 
	
	self.TankRoleFrame:ClearAllPoints(); 
	self.TankRoleFrame:SetPoint("RIGHT", self.SortByDropdown, "RIGHT", 40, 10);

	self.SearchBox:ClearAllPoints(); 
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 160, 10);

	self.ClubSizeDropdown:Hide(); 
end 

function CardRightClickOptionsMenuInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		info.text = self:GetParent().isGuildType and CLUB_FINDER_REPORT_GUILD_NAME or CLUB_FINDER_REPORT_COMMUNITY_NAME;
		info.notCheckable = true; 
		info.func = function() ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.ClubName, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_NAME;
		info.notCheckable = true; 
		info.func = function() ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.PostersName, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_DESCRIPTION; 
		info.notCheckable = true; 
		info.func = function() 	ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.PostingDescription, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
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
			info.text = CLUB_FINDER_CANCEL_APPLICATION;
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
function ClubFinderCreateRecruitingSpecsMap(specIds)
	local recruitingSpecIds  = { };
	for i, specId in ipairs(specIds) do
		recruitingSpecIds[specId] = true;
	end
	return recruitingSpecIds; 
end 

ClubFinderCardMixin = { };

function ClubFinderCardMixin:OnLoad() 
	UIDropDownMenu_Initialize(self.RightClickDropdown, CardRightClickOptionsMenuInitialize, "MENU");
end

function ClubFinderCardMixin:OnMouseDown(button) 
	if (IsModifiedClick("CHATLINK")) then 
		local link = GetClubFinderLink(self.cardInfo.clubFinderGUID, self.cardInfo.name);
		ChatEdit_InsertLink(link);
	end
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 100, 0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end 

function ClubFinderCardMixin:CreateRecruitingSpecsMap()
	self.recruitingSpecIds = ClubFinderCreateRecruitingSpecsMap(self.cardInfo.recruitingSpecIds); 
end 

function ClubFinderCardMixin:OnLeave()
	GameTooltip:Hide(); 
end

function ClubFinderCardMixin:GetLastPosterGUID()
	return self.cardInfo.lastPosterGUID;
end 

function ClubFinderCardMixin:GetCardName()
	return self.cardInfo.name;
end 

function ClubFinderCardMixin:GetClubGUID()
	return self.cardInfo.clubFinderGUID;
end

function ClubFinderCardMixin:GetCardStatus()
	return self.cardInfo.clubStatus;
end 
ClubFinderGuildCardMixin = CreateFromMixins(ClubFinderCardMixin);


function ClubFinderGuildCardMixin:RequestToJoinClub()
	self:GetParent():GetParent().RequestToJoinFrame.card = self;

	self:GetParent():GetParent().RequestToJoinFrame:Initialize(); 
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

function ClubFinderGetFocusStringFromFlags(recruitmentFlags)
	local focusFlag = C_ClubFinder.GetFocusIndexFromFlag(recruitmentFlags)
	if (focusFlag == Enum.ClubFinderSettingFlags.None) then 
		return NONE;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Dungeons) then 
		return GUILD_INTEREST_DUNGEON;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Raids) then 
		return GUILD_INTEREST_RAID;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Pvp) then 
		return CLUB_FINDER_FOCUS_PVP;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Rp) then 
		return GUILD_INTEREST_RP;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Social) then 
		return CLUB_FINDER_FOCUS_SOCIAL_LEVELING;
	else 
		return NONE; 
	end
end 

function ClubFinderGuildCardMixin:UpdateCard()
	local info = self.cardInfo;

	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment:gsub("\n","")); 
	self.MemberCount:SetText(info.numActiveMembers); 
	self.RightClickDropdown.isGuildCard = true; 
	local focusString = ClubFinderGetFocusStringFromFlags(info.recruitmentFlags);
	self.Focus:SetText(focusString);
	SetLargeTabardTexturesFromColorRGB("player", self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, info.tabardInfo); 

	if(C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(info.clubFinderGUID)) then
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 
		self.RequestStatus:SetText(CLUB_FINDER_ALREADY_IN_THAT_CLUB);
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		self:SetDisabledState(true); 
	elseif (info.clubStatus) then 
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 
		if(info.clubStatus == Enum.PlayerClubRequestStatus.None or info.clubStatus == Enum.PlayerClubRequestStatus.Canceled) then 
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
		elseif (info.clubStatus == Enum.PlayerClubRequestStatus.Joined) then 
			self.RequestStatus:SetText(CLUB_FINDER_JOINED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			
		end			
	else 
		self.RequestJoin:Show(); 
		self.RequestStatus:Hide(); 
		self:SetDisabledState(false); 
	end 
end 

function ClubFinderGuildCardMixin:OnEnter() 
	local info = self.cardInfo;
	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT", 10, -250);
	GameTooltip_AddColoredLine(GameTooltip, info.name, GREEN_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ACTIVE_MEMBERS:format(info.numActiveMembers));
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_LEADER:format(info.guildLeader));

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
	GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_CLUB_DESCRIPTION:format(info.comment), GRAY_FONT_COLOR, true);
	GameTooltip:Show();
end 

ClubFinderCommunitiesCardMixin = CreateFromMixins(ClubFinderCardMixin);

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

function ClubFinderCommunitiesCardMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	self:RequestToJoinClub();
end

function ClubFinderCommunitiesCardMixin:UpdateCard()
	local info = self.cardInfo;
	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment); 
	self.MemberCount:SetText(info.numActiveMembers); 
	self.RightClickDropdown.isGuildCard = false; 

	local focusString = ClubFinderGetFocusStringFromFlags(info.recruitmentFlags);
	self.Focus:SetText(focusString);

	if (info.emblemInfo > 0) then 
		C_Club.SetAvatarTexture(self.CommunityLogo, info.emblemInfo, Enum.ClubType.Character);
	end

	if(C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(info.clubFinderGUID)) then
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 
		self.RequestStatus:SetText(CLUB_FINDER_ALREADY_IN_THAT_CLUB);
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		self:SetDisabledState(true); 
	elseif (info.clubStatus) then 
		self.RequestJoin:Hide(); 
		self.RequestStatus:Show(); 

		if (info.clubStatus == Enum.PlayerClubRequestStatus.None or info.clubStatus == Enum.PlayerClubRequestStatus.Canceled) then 
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
end 

function ClubFinderCommunitiesCardMixin:OnEnter() 
	local info = self.cardInfo;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddColoredLine(GameTooltip, info.name, GREEN_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ACTIVE_MEMBERS:format(info.numActiveMembers));
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_LEADER:format(info.guildLeader));
	
	if (self.RequestJoin:IsShown()) then
		self.RequestJoin.Highlight:Show();
	end 

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
	GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_CLUB_DESCRIPTION:format(info.comment), GRAY_FONT_COLOR, true);
	GameTooltip:Show();
end 

function ClubFinderCommunitiesCardMixin:OnLeave()
	if (self.RequestJoin:IsShown()) then
		self.RequestJoin.Highlight:Hide();
	end 
	ClubFinderCardMixin.OnLeave();
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

ClubFinderCommunitiesCardsBaseMixin = { }; 

function ClubFinderCommunitiesCardsBaseMixin:OnLoad()
	self.CardList = { };
	self.ListScrollFrame.update = function() self:RefreshLayout() end;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "ClubFinderCommunitiesCardTemplate", 13, -6, "TOPLEFT", nil, nil, -5);
end 	

function ClubFinderCommunitiesCardsBaseMixin:UpateCardsAlreadyInList(clubFinderGUIDS)
	if(not clubFinderGUIDS or #clubFinderGUIDS == 0) then 
		return; 
	end 

	for i = 1, #self.CardList do 
		for _, finderGUID in pairs(clubFinderGUIDS) do 
			if(self.CardList[i].clubFinderGUID == finderGUID) then 
				local recruitingClubInfo = C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(finderGUID)
				if (recruitingClubInfo) then
					self.CardList[i].clubStatus = recruitingClubInfo.clubStatus; 
				end 
			end
		end
	end
end 

function ClubFinderCommunitiesCardsBaseMixin:OnShow()
	self:RefreshLayout();
end

function ClubFinderCommunitiesCardsBaseMixin:RefreshLayout()
	local playerSpecs = ClubFinderGetPlayerSpecIds(); 
	local showingCards = 0; 
	local numCardsTotal = 0; 
	self.showingCards = false;
	local scrollFrame = self.ListScrollFrame;

	if (not self:IsShown()) then 
		return;
	end 

	if (self.newRequest) then 
		scrollFrame:SetVerticalScroll(0);
		scrollFrame.scrollBar:SetValue(0);
		HybridScrollFrame_SetOffset(scrollFrame, 0);
		self.newRequest = nil; 
	end 

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	HybridScrollFrame_SetDoNotHideScrollBar(scrollFrame, true);

	local index; 
	if (self.ListScrollFrame.buttons) then 
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
				self.showingCards = true; 
			else 
				currentCard:Hide(); 
			end 
		end
	end 

	local displayedHeight = showingCards * 76;
	local totalHeight = numCardsTotal * 76;

	totalHeight = totalHeight + 7;

	self:GetParent().InsetFrame.GuildDescription:SetShown(not self.showingCards); 

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight); 

	local threshold = 1;
	local lastDisplayed = offset + showingCards;
	local requestMoreValues = numCardsTotal ~= 0 and numCardsTotal - lastDisplayed < threshold;

	if (self.pagingEnabled and not self.requestedNextPage and  requestMoreValues and numCardsTotal < self.totalListSize) then
		C_ClubFinder.RequestNextCommunityPage(lastDisplayed + 1, showingCards);
		self.requestedNextPage = true; 
	end 
end 

ClubFinderCommunitiesCardsMixin = CreateFromMixins(ClubFinderCommunitiesCardsBaseMixin);
 
function ClubFinderCommunitiesCardsMixin:BuildCardList()
	self.pagingEnabled = true; 
	self.CardList = C_ClubFinder.ReturnMatchingCommunityList(); 
	self.totalListSize = C_ClubFinder.GetTotalMatchingCommunityListSize();
	self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND); 	
end 

ClubFinderPendingCommunitiesCardsMixin = CreateFromMixins(ClubFinderCommunitiesCardsBaseMixin);
function ClubFinderPendingCommunitiesCardsMixin:BuildCardList()
	self.pagingEnabled = false; 
	self.CardList = C_ClubFinder.PlayerReturnPendingCommunitiesList(); 
end 

ClubFinderGuildCardsBaseMixin = { }; 

function ClubFinderGuildCardsBaseMixin:OnLoad()
	self.CardList = { }; 
	self.numPages = 1;
	self.pageNumber = 1;
end 

function ClubFinderGuildCardsBaseMixin:OnShow()
	self:RefreshLayout(self.pageNumber);
	self.requestedPage = false; 
end 

function ClubFinderGuildCardsBaseMixin:OnHide() 
	self.pageNumber = 1;
end 

function ClubFinderGuildCardsBaseMixin:PageNext()
	self.pageNumber = self.pageNumber + 1; 
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:RefreshLayout(self.pageNumber);
end 

function ClubFinderGuildCardsBaseMixin:PagePrevious()
	self.pageNumber = self.pageNumber - 1; 
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:RefreshLayout(self.pageNumber);
end

function ClubFinderGuildCardsBaseMixin:HideCardList()
	for i = 1, #self.Cards do 
		self.Cards[i]:Hide(); 
	end
end 

function ClubFinderGuildCardsBaseMixin:UpateCardsAlreadyInList(clubFinderGUIDS)
	if(not clubFinderGUIDS or #clubFinderGUIDS == 0) then 
		return; 
	end 

	for i = 1, #self.CardList do 
		for _, finderGUID in pairs(clubFinderGUIDS) do 
			if(self.CardList[i].clubFinderGUID == finderGUID) then 
				local recruitingClubInfo = C_ClubFinder.GetRecruitingClubInfoFromFinderGUID(finderGUID)
				if (recruitingClubInfo) then
					self.CardList[i].clubStatus = recruitingClubInfo.clubStatus; 
				end 
			end
		end
	end
end 

		
function ClubFinderGuildCardsBaseMixin:RefreshLayout(cardPage)
	if (not self:IsShown()) then 
		return; 
	end 

	if (not self:IsShown()) then 
		return;
	end 

	if(not cardPage) then
		cardPage = 1; 
	end

	self.SearchingSpinner:Hide(); 
	local playerSpecs = ClubFinderGetPlayerSpecIds(); 
	self.showingCards = false;
	local numCardsTotal = 0;
	for i = 1, #self.Cards do 
		local cardIndex = (cardPage - 1) * GUILD_CARDS_PER_PAGE + i; 
		local cardInfo = self.CardList[cardIndex]; 
		numCardsTotal = #self.CardList; 
		if(cardInfo) then 
			self.Cards[i].playerSpecs = playerSpecs; 
			self.Cards[i].cardInfo = cardInfo;
			self.Cards[i]:UpdateCard(); 
			self.Cards[i]:Show();  
			self.showingCards = true; 
		else 
			self.Cards[i]:Hide(); 
		end 
	end

	self:GetParent().InsetFrame.GuildDescription:SetShown(not self.showingCards); 

	if (self.showingCards) then 
		if(self.numPages <= 1) then 
			self.PreviousPage:Hide(); 
			self.NextPage:Hide(); 
		else 
			self.PreviousPage:Show(); 
			self.NextPage:Show(); 
		end
	else 
		if (self.requestedPage) then 
			self.SearchingSpinner:Show();
		else
			self.PreviousPage:Hide(); 
			self.NextPage:Hide(); 
		end
	end 

	if(cardPage <= 1) then 
		self.PreviousPage:SetEnabled(false); 
	else 
		self.PreviousPage:SetEnabled(true); 
	end 
	local shouldShowNextPage = cardPage < self.numPages;
	local shouldRequestNextPage = (self.pagingEnabled and (cardPage + LOAD_PAGES_IN_ADVANCE) > self.numPages) and self.numPages > 0; 

	if (shouldRequestNextPage) then 
		local startingIndex = cardPage * GUILD_CARDS_PER_PAGE;
		local pageSize = LOAD_PAGES_IN_ADVANCE * GUILD_CARDS_PER_PAGE;
		C_ClubFinder.RequestNextGuildPage(startingIndex, pageSize);
		self.requestedPage = true; 
	end 

	if(shouldShowNextPage) then
		self.NextPage:SetEnabled(true);
	else 
		self.NextPage:SetEnabled(false); 
	end 
end 

ClubFinderGuildCardsMixin = CreateFromMixins(ClubFinderGuildCardsBaseMixin); 

function ClubFinderGuildCardsMixin:BuildCardList() 
	self.pagingEnabled = true; 

	self.numPages = 0;
	self.CardList = C_ClubFinder.ReturnMatchingGuildList(); 
	local totalSize = C_ClubFinder.GetTotalMatchingGuildListSize()

	if( #self.CardList == 0) then 
		self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND); 
	else 
		self.numPages = math.ceil(totalSize / GUILD_CARDS_PER_PAGE); --Need to get the number of pages
	end
end 

ClubFinderPendingGuildCardsMixin = CreateFromMixins(ClubFinderGuildCardsBaseMixin); 
function ClubFinderPendingGuildCardsMixin:BuildCardList()
	self.numPages = 0;
	self.pagingEnabled = false;
	self.CardList = C_ClubFinder.PlayerReturnPendingGuildsList();
	self.numPages = math.ceil(#self.CardList / GUILD_CARDS_PER_PAGE); 
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
	self:RegisterEvent("CLUB_FINDER_LINKED_CLUB_RETURNED");
	self:RegisterEvent("CLUB_FINDER_POST_UPDATED");
	self:RegisterEvent("CLUB_FINDER_APPLICATIONS_UPDATED");
	self.InsetFrame.GuildDescription:Show(); 

	self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(0);
end 

function ClubFinderGuildAndCommunityMixin:ClubFinderOnClickHyperLink(clubFinderId)
	local clubType = C_ClubFinder.GetClubTypeFromFinderGUID(clubFinderId);
	local isGuildType = clubType == Enum.ClubFinderRequestType.Guild;
	local isLinkedPosting = true;
	C_ClubFinder.LookupClubPostingFromClubFinderGUID(clubFinderId, isLinkedPosting);
end 

function ClubFinderGuildAndCommunityMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CLUB_FINDER_FRAME_EVENTS);
	C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All); -- Player's applications to a guild or community
	self.OptionsList:Show(); 
end 

function ClubFinderGuildAndCommunityMixin:ResetToDefaults()
	self.GuildCards.CardList = { }; 
	self.GuildCards:RefreshLayout(); 
	self.CommunityCards.CardList = { };
	self.CommunityCards:RefreshLayout(); 
	
	self.PendingGuildCards.CardList = { }; 
	self.PendingGuildCards:RefreshLayout(); 
	self.PendingCommunityCards.CardList = { };
	self.PendingCommunityCards:RefreshLayout(); 

	self.OptionsList.SearchBox:SetText("");
end 

function ClubFinderGuildAndCommunityMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CLUB_FINDER_FRAME_EVENTS);
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
				self.requestedPage = false;
				if (self.GuildCards.newRequest) then 
					self.GuildCards.pageNumber = 1; 
					self.GuildCards.newRequest = false; 
				end 

				self.GuildCards:RefreshLayout(self.GuildCards.pageNumber); 
			end 
		end
		if (builCommunity) then
			self.CommunityCards:BuildCardList(); 
			if (not self.isGuildType) then
				self.CommunityCards.requestedNextPage = nil;
				self.CommunityCards:RefreshLayout(); 
			end
		end
	elseif (event == "CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED") or (event == "CLUB_FINDER_RECRUIT_LIST_CHANGED") or (event == "CLUB_FINDER_RECRUITS_UPDATED") then 
		local requestType = ...;
		local buildGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All); 
		local buildCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All); 
		if (buildGuild) then
			self.PendingGuildCards:BuildCardList();
			self.PendingGuildCards:RefreshLayout(); 
		end
		if (buildCommunity) then
			self.PendingCommunityCards:BuildCardList();
			self.PendingCommunityCards:RefreshLayout(); 
		end

		if (self.isGuildType) then 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(#self.PendingGuildCards.CardList);
			if (#self.PendingGuildCards.CardList > 0) then 
				self.ClubFinderPendingTab:Enable();
				self.ClubFinderPendingTab.Icon:SetDesaturated(false);
			else 
				self.ClubFinderPendingTab:Disable();
				self.ClubFinderPendingTab.Icon:SetDesaturated(true);
			end
		else 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(#self.PendingCommunityCards.CardList);
			if (#self.PendingCommunityCards.CardList > 0) then 
				self.ClubFinderPendingTab:Enable();
				self.ClubFinderPendingTab.Icon:SetDesaturated(false);
			else 
				self.ClubFinderPendingTab:Disable();
				self.ClubFinderPendingTab.Icon:SetDesaturated(true);
			end
		end
	elseif (event == "CLUB_FINDER_LINKED_CLUB_RETURNED") then 
		local clubInfo = ...; 
		local communitiesFrame = self:GetParent();
		communitiesFrame.ClubFinderInvitationFrame:DisplayInvitation(clubInfo, true);
	elseif (event == "CLUB_FINDER_APPLICATIONS_UPDATED") then
		local requestType, finderGuids = ...; 
		local updateGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All); 
		local updateCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All); 
		if (updateGuild) then
			self.GuildCards:UpateCardsAlreadyInList(finderGuids);
			self.GuildCards:RefreshLayout();
		end
		if (updateCommunity) then
			self.CommunityCards:UpateCardsAlreadyInList(finderGuids);
			self.CommunityCards:RefreshLayout();
		end
	end 
end 

function ClubFinderGuildAndCommunityMixin:UpdateType()
	if (self.isGuildType) then 
		self.OptionsList:SetType(self.isGuildType);
		self.InsetFrame.GuildDescription:SetText(CLUB_FINDER_NO_OPTIONS_SELECTED_GUILD_MESSAGE);

		if (#self.PendingGuildCards.CardList > 0) then 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(#self.PendingGuildCards.CardList);
			self.ClubFinderPendingTab:Enable();
			self.ClubFinderPendingTab.Icon:SetDesaturated(false);
		else 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(0);
			self.ClubFinderPendingTab:Disable();
			self.ClubFinderPendingTab.Icon:SetDesaturated(true);
		end
	else 
		self.OptionsList:SetType(self.isGuildType);
		self.InsetFrame.GuildDescription:SetText(BROWSE_SEARCH_TEXT);

		if (#self.PendingCommunityCards.CardList > 0) then 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(#self.PendingCommunityCards.CardList);
			self.ClubFinderPendingTab:Enable();
			self.ClubFinderPendingTab.Icon:SetDesaturated(false);
		else 
			self.ClubFinderPendingTab.tooltip = CLUB_FINDER_PENDING_REQUESTS:format(0);
			self.ClubFinderPendingTab:Disable();
			self.ClubFinderPendingTab.Icon:SetDesaturated(true);
		end
	end
	 self.ClubFinderSearchTab:SetChecked(true);
	self:GetDisplayModeBasedOnSelectedTab(LAYOUT_TYPE_REGULAR_SEARCH);
end 

function ClubFinderGuildAndCommunityMixin:GetDisplayModeBasedOnSelectedTab(selectedTab)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local tabSelection = selectedTab;

	local isSearchTabSelected = tabSelection == LAYOUT_TYPE_REGULAR_SEARCH;

	self.ClubFinderSearchTab:SetChecked(isSearchTabSelected); 
	self.ClubFinderPendingTab:SetChecked(not isSearchTabSelected); 

	self.GuildCards:SetShown(isSearchTabSelected and self.isGuildType);
	self.CommunityCards:SetShown(isSearchTabSelected and not self.isGuildType);
	self.PendingGuildCards:SetShown(not isSearchTabSelected and self.isGuildType);
	self.PendingCommunityCards:SetShown(not isSearchTabSelected and not self.isGuildType);
	
	self.OptionsList:SetOptionsState(not isSearchTabSelected);
	
	if (self.isGuildType) then 
		self.InsetFrame.GuildDescription:SetText(CLUB_FINDER_NO_OPTIONS_SELECTED_GUILD_MESSAGE);
	else 
		self.InsetFrame.GuildDescription:SetText(BROWSE_SEARCH_TEXT);
	end
end 

ClubFinderInvitationsFrameMixin = { }; 

function ClubFinderInvitationsFrameMixin:DisplayInvitation(clubInfo, isLinkInvitation) 
	self.clubInfo = clubInfo; 
	if(not clubInfo) then 
		return;
	end

	local isGuild = clubInfo.isGuild; 

	if (isGuild) then 
		SetLargeTabardTexturesFromColorRGB("player", self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, clubInfo.tabardInfo);
	end

	if(clubInfo.emblemInfo > 0 and not isGuild) then 
		C_Club.SetAvatarTexture(self.Icon, clubInfo.emblemInfo, Enum.ClubType.Character);
	end

	if	(isGuild) then 
		self.Type:SetText(CLUB_FINDER_TYPE_GUILD); 
		self.Name:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	else 
		self.Type:SetText(CLUB_FINDER_COMMUNITY_TYPE); 
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
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
	self.ApplyButton:SetShown(isLinkInvitation); 
	self.AcceptButton:SetShown(not isLinkInvitation);

	if(isLinkInvitation) then
		self.ApplyButton:SetEnabled(not C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(clubInfo.clubFinderGUID));	
	else 
		if (isGuild and (IsGuildLeader() or IsInGuild())) then 
			self.AcceptButton:SetEnabled(false);
		else 
			self.AcceptButton:SetEnabled(true);
		end 
	end
	self:GetParent().InvitationFrame:Hide();
	self:Show(); 
end 


function ClubFinderInvitationsFrameMixin:ApplyToLinkedClub()
	self.recruitingSpecIds = ClubFinderCreateRecruitingSpecsMap(self.clubInfo.recruitingSpecIds); 
	self.RequestToJoinFrame.card = self; 
	self.RequestToJoinFrame.card.cardInfo = self.clubInfo;
	self.RequestToJoinFrame:Initialize(); 
end 

function ClubFinderInvitationsFrameMixin:OnAcceptButtonEnter()
	GameTooltip:SetOwner(self.AcceptButton, "ANCHOR_LEFT", 0, -65);
	if (not self.AcceptButton:IsEnabled() and self.AcceptButton:IsShown()) then 
		if (IsGuildLeader()) then 
			GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_IS_GUILD_LEADER_JOIN_ERROR, RED_FONT_COLOR, true);
		else 
			GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ALREADY_IN_GUILD_PLEASE_LEAVE, RED_FONT_COLOR, true);
		end 
		GameTooltip:Show();
	end 
end 

function ClubFinderInvitationsFrameMixin:OnAcceptButtonLeave()
	GameTooltip:Hide();
end

function ClubFinderInvitationsFrameMixin:OnApplyButtonEnter()
	GameTooltip:SetOwner(self.ApplyButton, "ANCHOR_LEFT", 0, -65);
	if (not self.ApplyButton:IsEnabled() and self.ApplyButton:IsShown()) then 
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ALREADY_IN_THAT_CLUB, RED_FONT_COLOR, true);
		GameTooltip:Show();
	end 
end 

function ClubFinderInvitationsFrameMixin:OnApplyButtonLeave()
	GameTooltip:Hide();
end

function ClubFinderInvitationsFrameMixin:AcceptInvitation()
	C_ClubFinder.ApplicantAcceptClubInvite(self.clubInfo.clubFinderGUID);
	self:GetParent():SelectClub(nil);
	self:GetParent():UpdateClubSelection();
	if(self.WarningDialog:IsShown()) then 
		self.WarningDialog:Hide();
	end 
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
	if(self.WarningDialog:IsShown()) then 
		self.WarningDialog:Hide();
	end 
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

ClubFinderTabMixin = { }; 

function ClubFinderTabMixin:SetTab()
	if (self == self:GetParent().ClubFinderSearchTab) then 
		self:GetParent():GetDisplayModeBasedOnSelectedTab(LAYOUT_TYPE_REGULAR_SEARCH);
	else 
		self:GetParent():GetDisplayModeBasedOnSelectedTab(LAYOUT_TYPE_PENDING_LIST);
	end 

end 

ClubFinderRoleMixin = { }; 

function ClubFinderRoleMixin:OnEnter()
	local clubFinderFrame = self:GetParent():GetParent(); 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 5);
	if (clubFinderFrame.isGuildType) then 
		GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ROLE_TOOLTIP:format(CLUB_FINDER_GUILDS));
	else 
		GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ROLE_TOOLTIP:format(CLUB_FINDER_COMMUNITIES));
	end 
	GameTooltip:Show()
end 

function ClubFinderRoleMixin:OnLeave()
	GameTooltip:Hide();
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
	elseif (value == Enum.ClubFinderSettingFlags.SortRelevance) then 
		return playerSettings.sortRelevance;
	elseif (value == Enum.ClubFinderSettingFlags.SortMemberCount) then 
		return playerSettings.sortMembers;
	elseif (value == Enum.ClubFinderSettingFlags.SortNewest) then 
		return playerSettings.sortNewest;
	end
end

function ClubFinderGetCurrentClubListingInfo(clubId)
	local clubPostingInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId);
	if (clubPostingInfo) then
		return clubPostingInfo; 
	end 
	return nil;
end

function ClubFinderDoesSelectedClubHaveActiveListing(clubId) 
	if (ClubFinderGetCurrentClubListingInfo(clubId)) then 
		return true; 
	else 
		return false; 
	end
end 