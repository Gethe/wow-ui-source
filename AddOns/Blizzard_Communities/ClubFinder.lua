local GUILD_CARDS_PER_PAGE = 3;
local LOAD_PAGES_IN_ADVANCE = 1;
local REQUEST_GUILD_CARDS_NUM = 21;
local REQUEST_TO_JOIN_HEIGHT = 420;
local REQUEST_TO_JOIN_TEXT_HEIGHT = 14;
local MAX_DESCRIPTION_HEIGHT = 150;

local LAYOUT_TYPE_REGULAR_SEARCH = 1;
local LAYOUT_TYPE_PENDING_LIST = 2;

local POSTING_EXPIRATION_DAYS = 30;
local APPLICATION_EXPIRATION_DAYS = 7;
local CLUB_FINDER_WIDE_DROPDOWN_WIDTH = 180;
local CLUB_FINDER_WIDE_DROPDOWN_MENU_WIDTH = CLUB_FINDER_WIDE_DROPDOWN_WIDTH + 10;

local function ClubFinderGetTotalNumSpecializations()
	local numClasses = GetNumClasses();
	local count = 0;
	for i = 1, numClasses do
		local _, _, classID = GetClassInfo(i);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			count = count + 1
		end
	end
	return count;
end

local CLUB_FINDER_MAX_NUM_SPECIALIZATIONS = ClubFinderGetTotalNumSpecializations();

local CLUB_FINDER_FRAME_EVENTS = {
	"CLUB_FINDER_CLUB_LIST_RETURNED",
	"CLUB_FINDER_MEMBERSHIP_LIST_CHANGED",
	"CLUB_FINDER_PLAYER_PENDING_LIST_RECIEVED",
	"CLUB_FINDER_POST_UPDATED",
	"CLUB_FINDER_RECRUIT_LIST_CHANGED",
	"CLUB_FINDER_RECRUITS_UPDATED",
	"CLUB_FINDER_CLUB_REPORTED",
};

ClubsRecruitmentDialogMixin = {};


function ClubsRecruitmentDialogMixin:UpdatedPostingInformationInit()
	self:RegisterEvent("CLUB_FINDER_RECRUITMENT_POST_RETURNED");
	local clubId;
	if (self.clubId) then
		clubId = self.clubId;
	else
		clubInfo = C_Club.GetClubInfo(self:GetParent():GetSelectedClubId());
		clubId = clubInfo.clubId;
	end

	if(C_ClubFinder.RequestPostingInformationFromClubId(clubId)) then
		self.waitingForResponseToShow = true;
	else
		self:OnUpdatedPostingInformationRecieved();
	end
end

function ClubsRecruitmentDialogMixin:OnUpdatedPostingInformationRecieved()
	self:UnregisterEvent("CLUB_FINDER_RECRUITMENT_POST_RETURNED");
	self.waitingForResponseToShow = false;
	if(not self:IsShown()) then
		CommunitiesFrame.RecruitmentDialog:Show();
	end
end

function ClubsRecruitmentDialogMixin:SetDisabledStateOnCommunityFinderOptions(shouldDisable)
	self.MaxLevelOnly.Button:SetEnabled(not shouldDisable);
	self.MinIlvlOnly.Button:SetEnabled(not shouldDisable);
	if (shouldDisable) then
		local fontColor = LIGHTGRAY_FONT_COLOR;
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_DisableDropDown(self.ClubFocusDropdown);
		UIDropDownMenu_DisableDropDown(self.LookingForDropdown);
		UIDropDownMenu_DisableDropDown(self.LanguageDropdown); 
	else
		local fontColor = HIGHLIGHT_FONT_COLOR;
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_EnableDropDown(self.ClubFocusDropdown);
		UIDropDownMenu_EnableDropDown(self.LookingForDropdown);
		UIDropDownMenu_EnableDropDown(self.LanguageDropdown);
	end
	self:CheckLanguageDropdownTutorial();
end

function ClubsRecruitmentDialogMixin:ResetClubFinderSettings()
	self.MinIlvlOnly.Button:SetChecked(false);
	self.MinIlvlOnly.EditBox:SetText("");
	self.MinIlvlOnly.EditBox.Text:Show();
	self.MaxLevelOnly.Button:SetChecked(false);
	self.ShouldListClub.Button:SetChecked(false);
	self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:SetText("");

	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.Social, true);
	self.ClubFocusDropdown:Initialize();
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize);
	self.ClubFocusDropdown:UpdateDropdownText();

	self.LookingForDropdown:Initialize();
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize);
	self.LookingForDropdown:UpdateDropdownText();

	UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize);
	self.LanguageDropdown:SetLanguageChecked(self.LanguageDropdown.initLocale, true);
end

function ClubsRecruitmentDialogMixin:OnLoad()
	self.LookingForDropdown:Initialize();
	self.ClubFocusDropdown:Initialize();
	self.LanguageDropdown:Initialize(); 
	self.clubId = nil;
	UIDropDownMenu_SetWidth(self.LookingForDropdown, 150);
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 150);
	UIDropDownMenu_SetWidth(self.LanguageDropdown, 150);
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize);
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize);
	UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize); 
	UIDropDownMenu_JustifyText(self.ClubFocusDropdown, "LEFT");
	UIDropDownMenu_JustifyText(self.LookingForDropdown, "LEFT");
	UIDropDownMenu_JustifyText(self.LanguageDropdown, "LEFT");
end

function ClubsRecruitmentDialogMixin:CheckLanguageDropdownTutorial()
	local languageSelected = not self.LanguageDropdown.showAnyLanguage;
	local shouldListChecked =  self.ShouldListClub.Button:GetChecked();
	if languageSelected or not shouldListChecked then
		HelpTip:HideAll(self.LanguageDropdown);
	else
		local helpTipInfo = {
			text = CLUB_FINDER_TUTORIAL_LANGUAGE_SET,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -4,
			useParentStrata = true,
		};
		HelpTip:Show(self.LanguageDropdown, helpTipInfo);
	end

	self:UpdateCreateButton();
end

function ClubsRecruitmentDialogMixin:AcceptButtonOnEnter()
	if self.Accept:IsEnabled() then
		GameTooltip:Hide();
	else
		GameTooltip:SetOwner(self.Accept, "ANCHOR_RIGHT", 0, 0);
		GameTooltip_AddErrorLine(GameTooltip, LFG_LIST_SELECT_A_CATEGORY);
		GameTooltip:Show();
	end
end

function ClubsRecruitmentDialogMixin:UpdateCreateButton()
	local languageSelected = not self.LanguageDropdown.showAnyLanguage;
	local shouldListChecked =  self.ShouldListClub.Button:GetChecked();
	self.Accept:SetEnabled(languageSelected or not shouldListChecked);
	if self.Accept:IsMouseOver() then
		self:AcceptButtonOnEnter();
	end
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
			self.LookingForDropdown:Initialize();
			self.LookingForDropdown:SetCheckedList(clubPostingInfo.recruitingSpecIds);
			self.LookingForDropdown:UpdateDropdownText();

			C_ClubFinder.SetAllRecruitmentSettings(clubPostingInfo.recruitmentFlags);

			local index = C_ClubFinder.GetFocusIndexFromFlag(clubPostingInfo.recruitmentFlags);
			C_ClubFinder.SetRecruitmentSettings(index, true);
			UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize);

			UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize);
			if not clubPostingInfo.localeSet then
				self.LanguageDropdown:SetShowAnyLanguage(true);
			else
				self.LanguageDropdown:SetLanguageChecked(clubPostingInfo.recruitmentLocale, true);
			end

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
		else
			self:SetDisabledStateOnCommunityFinderOptions(true);
		end
	end
end

function ClubsRecruitmentDialogMixin:OnShow()
	self:GetParent():RegisterDialogShown(self);
	self:RegisterEvent("CLUB_FINDER_POST_UPDATED");
	self:UpdateSettingsInfoFromClubInfo();

	HelpTip:Acknowledge(CommunitiesFrame, CLUB_FINDER_TUTORIAL_POSTING);
	HelpTip:Acknowledge(CommunitiesFrame, CLUB_FINDER_TUTORIAL_LANGUAGE_FILTER);
end

function ClubsRecruitmentDialogMixin:OnHide()
	self:UnregisterEvent("CLUB_FINDER_POST_UPDATED");
	self.clubId = nil;

	-- Check the communities frame for any other tutorials we should show.
	self:GetParent():CheckForTutorials();
end

function ClubsRecruitmentDialogMixin:OnEvent(event, ...)
	if (event == "CLUB_FINDER_POST_UPDATED") then
		self:Hide();
	elseif(event == "CLUB_FINDER_RECRUITMENT_POST_RETURNED") then
		if (self.waitingForResponseToShow) then
			self:OnUpdatedPostingInformationRecieved();
		end
	end
end

function ClubsRecruitmentDialogMixin:PostClub()
	local communityFrame = self:GetParent();
	local clubInfo;
	local clubId;

	if (self.clubId) then
		clubInfo = ClubFinderGetCurrentClubListingInfo(self.clubId);
		clubId = self.clubId;
	else
		clubInfo = C_Club.GetClubInfo(communityFrame:GetSelectedClubId());
		clubId = clubInfo.clubId;
	end
	local specsInList = self.LookingForDropdown:GetSpecsList();

	local minItemLevel = self.MinIlvlOnly.EditBox:GetNumber();
	local description = self.RecruitmentMessageFrame.RecruitmentMessageInput.EditBox:GetText();


	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.MaxLevelOnly, self.MaxLevelOnly.Button:GetChecked());
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.EnableListing, self.ShouldListClub.Button:GetChecked());

	if (clubInfo) then
		C_ClubFinder.PostClub(clubId, minItemLevel, clubInfo.name, description, clubInfo.avatarId, specsInList, Enum.ClubFinderRequestType.Guild);
	elseif (self.clubName) then
		C_ClubFinder.PostClub(clubId, minItemLevel, self.clubName, description, self.clubAvatarId, specsInList, Enum.ClubFinderRequestType.Guild);
	end
end

ClubFinderRequestToJoinMixin = {};

function ClubFinderRequestToJoinMixin:OnShow()
	self:GetCommunitiesFrame():RegisterDialogShown(self);
end

function ClubFinderRequestToJoinMixin:OnHide()
	self.SpecsPool:ReleaseAll();
	self.MessageFrame.MessageScroll.EditBox:SetText("");
end

function ClubFinderRequestToJoinMixin:ApplyButtonOnEnter()
	GameTooltip:SetOwner(self.Apply, "ANCHOR_LEFT", 0, -65);
	if (not self.Apply:IsEnabled()) then
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ONE_SPEC_REQUIRED, RED_FONT_COLOR);
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

	if (self.isLinkedPosting) then -- If we are requesting from finder.
		self:GetCommunitiesFrame():SelectClub(nil);
		self:GetCommunitiesFrame():UpdateClubSelection();
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

function ClubFinderRequestToJoinMixin:GetCommunitiesFrame()
	return self:GetParent():GetParent();
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
	local specIds = ClubFinderGetPlayerSpecIds();
	self.ClubDescription:SetHeight(usedHeight);

	if (self.SpecsPool) then
		self.SpecsPool:ReleaseAll();
	end

	local isRecruitingAllSpecs = #self.info.recruitingSpecIds == 0 or #self.info.recruitingSpecIds == CLUB_FINDER_MAX_NUM_SPECIALIZATIONS;
	if (not isRecruitingAllSpecs and not self:DoesPlayerMatchRecruitingSpecs()) then
		self.SpecsPool = CreateFramePool("FRAME", self, "ClubFinderLittleSpecializationCheckBoxTemplate");
		self.noMatchingSpecs = true;
		if (#specIds < 4) then
			extraFrameHeight = 65;
		else
			extraFrameHeight = 70; --Base offset;
		end
	else
		self.SpecsPool = CreateFramePool("FRAME", self, "ClubFinderBigSpecializationCheckBoxTemplate");
		self.noMatchingSpecs = false;
		if (#specIds < 4) then
			extraFrameHeight = 40;
		else
			extraFrameHeight = 60; --Base offset;
		end
	end

	self:SetHeight((REQUEST_TO_JOIN_HEIGHT + extraFrameHeight) - (extraHeight));

	self.ClubDescription:ClearAllPoints();
	self.ClubDescription:SetPoint("BOTTOM", self.ClubName, "BOTTOM", 0, -(usedHeight + 2));

	self.MessageFrame:ClearAllPoints();
	self.MessageFrame:SetPoint("BOTTOM", self.ClubDescription, "BOTTOM", 0, -85);

	self.RecruitingSpecDescriptions:ClearAllPoints();
	self.RecruitingSpecDescriptions:SetPoint("BOTTOM", self.MessageFrame, "BOTTOM", 0, -35);

	self.ErrorDescription:ClearAllPoints();
	self.ErrorDescription:SetPoint("BOTTOM", self.MessageFrame, "BOTTOM", 0, -30);

	local matchingSpecNames = { };

	for i, specId in ipairs(specIds) do
		local specButton = self.SpecsPool:Acquire();

		if (self.noMatchingSpecs and not isRecruitingAllSpecs) then
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

	self.RecruitingSpecDescriptions:SetShown(#matchingSpecNames > 0 or isRecruitingAllSpecs);
	self.ClubDescription2:SetShown(#matchingSpecNames == 0 and not isRecruitingAllSpecs);
	self.ErrorDescription:SetShown(#matchingSpecNames == 0 and not isRecruitingAllSpecs);

	if(self.lastSpecButton) then
		self.ClubDescription2:SetPoint("BOTTOM", self.lastSpecButton, "BOTTOM", 0, -30);
	end

	local classDisplayName = UnitClass("player");

	if(isRecruitingAllSpecs) then
		if(self.info.isGuild) then
			self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_GUILD_LOOKING_ALL_SPECS);
		else
			self.RecruitingSpecDescriptions:SetText(CLUB_FINDER_COMMUNITY_LOOKING_ALL_SPECS);
		end
	elseif (#matchingSpecNames == 1) then
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

function SettingsDropdownMixin:UpdateDropdownText(text, evalValue, value, allowMultipleSelection)
	if (allowMultipleSelection) then
		local selectedCount = C_ClubFinder.GetPlayerSettingsFocusFlagsSelectedCount();
		if selectedCount > 1 then
			UIDropDownMenu_SetText(self, CLUB_FINDER_MULTIPLE_CHECKED);
		elseif selectedCount == 0 then
			UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG);
		else
			UIDropDownMenu_Refresh(self);
		end
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

function SettingsDropdownMixin:SetDropdownInfoForPreferences(info, value, text, allowMultipleSelection, isRadioStyle)
	if(self.isPlayerApplicant) then
		self:UpdateDropdownText(text, self:GetPlayerSettingsByValue(value), value, allowMultipleSelection);

		info.checked = function() return self:GetPlayerSettingsByValue(value) end;
		info.func = function()
			local playerValue = self:GetPlayerSettingsByValue(value);
			local newValue = isRadioStyle and true or (not playerValue);
			C_ClubFinder.SetPlayerApplicantSettings(value, newValue);
			self:UpdateDropdownText(text, newValue, value, allowMultipleSelection);
		end;
	else
		self:UpdateDropdownText(text, self:GetRecruitmentSettingByValue(value), value);

		info.checked = function() return self:GetRecruitmentSettingByValue(value) end;
		info.func = function()
			local recruitmentValue = self:GetRecruitmentSettingByValue(value);
			local newValue = isRadioStyle and true or (not recruitmentValue);
			C_ClubFinder.SetRecruitmentSettings(value, newValue, value);
			self:UpdateDropdownText(text, newValue, value);
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
	elseif (value == Enum.ClubFinderSettingFlags.PvP) then
		return clubSettings.playStylePvp;
	elseif (value == Enum.ClubFinderSettingFlags.RP) then
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
	local isRadioStyle = false;
	local allowMultipleSelection = false;

	if(self.isPlayerApplicant) then
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		allowMultipleSelection = true;
	else
		info.keepShownOnClick = false;
		isRadioStyle = true;
	end

	info.minWidth = CLUB_FINDER_WIDE_DROPDOWN_MENU_WIDTH;

	info.text = CLUB_FINDER_FOCUS_SOCIAL_LEVELING;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Social, CLUB_FINDER_FOCUS_SOCIAL_LEVELING, allowMultipleSelection, isRadioStyle);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_DUNGEON;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Dungeons, GUILD_INTEREST_DUNGEON, allowMultipleSelection, isRadioStyle);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_RAID;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Raids, GUILD_INTEREST_RAID, allowMultipleSelection, isRadioStyle);
	UIDropDownMenu_AddButton(info);

	info.text = CLUB_FINDER_FOCUS_PVP;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.PvP, PVP_ENABLED, allowMultipleSelection, isRadioStyle);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_RP;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.RP, GUILD_INTEREST_RP, allowMultipleSelection, isRadioStyle);
	UIDropDownMenu_AddButton(info);
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
		local id, name, description, texture, role, class, classDisplayName = GetSpecializationInfoByID(specId);
		self:ModifyTrackedSpecList(name, classDisplayName, specId, true);
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
		UIDropDownMenu_SetText(self, TALENT_SPEC_AND_CLASS:format(specInfo.specName, specInfo.className));
	elseif(self.checkedCount == 0) then
		UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG);
	end
end

function LookingForDropdownMixin:AddButtons(info, roleToMatch, level)
	local numClasses = GetNumClasses();
	local sex = UnitSex("player");

	info.text = CHECK_ALL;
	info.func = function()
		self:CheckOrUncheckAll(info, roleToMatch, true);
		self:Refresh();
		self:UpdateDropdownText();
	end;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);

	info.text = UNCHECK_ALL;
	info.func = function()
		self:CheckOrUncheckAll(info, roleToMatch, false);
		self:Refresh();
		self:UpdateDropdownText();
	end;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);

	for i = 1, numClasses do
		local className, classTag, classID = GetClassInfo(i);
		for i = 1, GetNumSpecializationsForClassID(classID) do
			local specID, specName, _, _, role = GetSpecializationInfoForClassID(classID, i, sex);
			if(role == roleToMatch) then
				info.hasArrow = false;
				info.notCheckable = false;

				info.text = TALENT_SPEC_AND_CLASS:format(specName, className);
				local _, _, _, colorString = GetClassColor(classTag);
				info.colorCode = string.format("|c%s", colorString);
				info.checked = function()
					return self:IsSpecInList(specID)
				end;
				info.func = function()
					self:ModifyTrackedSpecList(specName, className, specID, not self:IsSpecInList(specID));
					self:Refresh();
					self:UpdateDropdownText(TALENT_SPEC_AND_CLASS:format(specName, className));
				end;
				info.isNotRadio = true;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

function LookingForDropdownMixin:SetSpecialDropdownInfo(info, value, isPlayerApplicant)
	if(isPlayerApplicant) then
		info.checked =  function()
			return self:GetPlayerSettingsByValue(value);
		end;
		info.func = function()
			local playerValue = self:GetPlayerSettingsByValue(value);
			C_ClubFinder.SetPlayerApplicantSettings(value, not playerValue);
			self:Refresh();
		end
	else
		info.checked = function()
			return self:GetRecruitmentSettingByValue(value)
		end;
		info.func = function()
			local recruitmentValue = self:GetRecruitmentSettingByValue(value);
			C_ClubFinder.SetRecruitmentSettings(value, not recruitmentValue);
			self:Refresh();
		end
	end
end

function LookingForDropdownMixin:Refresh()
	UIDropDownMenu_Refresh(self, 1, 2);
	UIDropDownMenu_Refresh(self, 1, 1);
end

local function LookingForClubDropdownFunc(self, role)
	local isEverySpecChecked = self:IsEverySpecCheckedForRole(role);
	self:CheckOrUncheckAll(info, role, not isEverySpecChecked);
	self:Refresh();
	self:UpdateDropdownText();
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
		info.checked = function()
			return self:IsEverySpecCheckedForRole("TANK");
		end;
		info.func = function()
			LookingForClubDropdownFunc(self, "TANK");
		end;
		info.isNotRadio = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_HEALER;
		info.value = 2;
		info.checked = 	function()
			return self:IsEverySpecCheckedForRole("HEALER");
		end;
		info.func = function()
			LookingForClubDropdownFunc(self, "HEALER");
		end;
		info.isNotRadio = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_DAMAGE;
		info.value = 3;
		info.checked = 	function()
			return self:IsEverySpecCheckedForRole("DAMAGER");
		end;
		info.func = function()
			LookingForClubDropdownFunc(self, "DAMAGER");
		end;
		info.isNotRadio = true;
		info.hasArrow = true;
		UIDropDownMenu_AddButton(info, level);
	end
end

ClubFinderLanguageDropdownMixin = {};

function ClubFinderLanguageDropdownMixin:Initialize(isPlayerApplicant)
	self.isPlayerApplicant = isPlayerApplicant;
	if isPlayerApplicant then
		self.currentLanguages = CreateFromMixins(FlagsMixin);
		self.currentLanguages:OnLoad();
	else
		self.currentLanguage = 0;
	end
end

function ClubFinderLanguageDropdownMixin:SetLanguageChecked(language, checked)
	if self.isPlayerApplicant then
		self.currentLanguages:SetOrClear(language, checked);
		C_ClubFinder.SetPlayerApplicantLocaleFlags(self.currentLanguages:GetFlags());
	else
		self:SetShowAnyLanguage(false);
		self.currentLanguage = language;	-- Only 1 language allowed for postings
		UIDropDownMenu_SetSelectedValue(self, language);
		C_ClubFinder.SetRecruitmentLocale(language)
	end
end

function ClubFinderLanguageDropdownMixin:SetLanguageFlags(languageFlags)
	if self.isPlayerApplicant then
		self.currentLanguages.flags = languageFlags;
		C_ClubFinder.SetPlayerApplicantLocaleFlags(self.currentLanguages:GetFlags());
	end
end

function ClubFinderLanguageDropdownMixin:IsLanguageChecked(language)
	if self.showAnyLanguage then
		return false;
	elseif self.isPlayerApplicant then
		return self.currentLanguages:IsSet(language);
	else
		return self.currentLanguage == language;
	end
end

function ClubFinderLanguageDropdownMixin:GetCurrentLanguageValue()
	if self.isPlayerApplicant then
		return self.currentLanguages:GetFlags();
	else
		return self.currentLanguage;
	end
end

function ClubFinderLanguageDropdownMixin:SetShowAnyLanguage(showAnyLanguage)
	self.showAnyLanguage = showAnyLanguage;
	if showAnyLanguage then
		UIDropDownMenu_SetSelectedValue(self, nil);
		UIDropDownMenu_SetText(self, CLUB_FINDER_ANY_FLAG);
	else
		UIDropDownMenu_SetText(self, "");
	end
	self:GetParent():CheckLanguageDropdownTutorial();
end

function ClubFinderLanguageDropdownMixin:ShouldShowAnyLanguage()
	return self.showAnyLanguage;
end

function ClubFinderLanguageDropdownMixin:RefreshSelectedValue()
	if not self:ShouldShowAnyLanguage() then
		UIDropDownMenu_SetSelectedValue(self, self:GetCurrentLanguageValue());
	end
end

function ClubFinderLanguageDropdownInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = self.isPlayerApplicant;
	info.isNotRadio = self.isPlayerApplicant;
	info.ignoreAsMenuSelection = self.isPlayerApplicant;

	local currentLocale = GetCVar("textLocale");
	self.initLocale = nil;

	local ignoreLocaleRestrictions = true;
	local locales = GetAvailableLocaleInfo(ignoreLocaleRestrictions);
	for _, localeInfo in pairs(locales) do
		if LanguageRegions[localeInfo.localeName] then
			InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeChoice(info, localeInfo.localeName);
			if self.isPlayerApplicant then
				info.value = bit.lshift(1, localeInfo.localeId);	-- Multiple can be selected, so convert this to a mask to we can use it in a bit flag
			else
				info.value = localeInfo.localeId;
			end
			info.func = function(button, _, _, checked)
							return self:SetLanguageChecked(button.value, checked);
						end;
			info.checked =	function(button)
								return self:IsLanguageChecked(button.value); 
							end;
			UIDropDownMenu_AddButton(info);

			if not self.initLocale or (currentLocale == localeInfo.localeName) then
				self.initLocale = info.value;
			end
		end
	end

	if not self.initLocale then
		self.initLocale = 0;
	end
end

ClubFinderFilterDropdownMixin = CreateFromMixins(SettingsDropdownMixin, ClubFinderLanguageDropdownMixin);

function ClubFinderFilterDropdownMixin:Initialize()
	SettingsDropdownMixin.Initialize(self);
	local isPlayerApplicant = true;
	ClubFinderLanguageDropdownMixin.Initialize(self, isPlayerApplicant)
end

function ClubFinderFilterDropdownInitialize(self, level)
	-- Add the focus label
	local info = UIDropDownMenu_CreateInfo();
	info.text = CLUB_FINDER_FOCUS;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	-- And the focus options
	ClubFocusClubDropdownInitialize(self);

	-- Then the language label
	info.text = LANGUAGE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	-- And finally the language options
	ClubFinderLanguageDropdownInitialize(self);
end

ClubSortByDropdownMixin = CreateFromMixins(SettingsDropdownMixin);

local ClubSortByFlags = {
	[Enum.ClubFinderSettingFlags.SortRelevance] = CLUB_FINDER_SORT_BY_RELEVANCE,
	[Enum.ClubFinderSettingFlags.SortMemberCount] = CLUB_FINDER_SORT_BY_MOST_MEMBERS,
	[Enum.ClubFinderSettingFlags.SortNewest] = CLUB_FINDER_SORT_BY_NEWEST,
};

function ClubSortByDropdownInitialize(self)
	local hasAnySet = false;
	for sortByFlag, text in pairs(ClubSortByFlags) do
		if self.isPlayerApplicant then
			hasAnySet = self:GetPlayerSettingsByValue(sortByFlag);
		else
			hasAnySet = self:GetRecruitmentSettingByValue(sortByFlag);
		end

		if hasAnySet then
			break;
		end
	end

	if not hasAnySet then
		if self.isPlayerApplicant then
			C_ClubFinder.SetPlayerApplicantSettings(Enum.ClubFinderSettingFlags.SortRelevance, true);
		else
			C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.SortRelevance, true);
		end
	end

	local allowMultipleSelection = false;
	local isRadioStyle = true;

	local info = UIDropDownMenu_CreateInfo();
	for sortByFlag, text in pairs(ClubSortByFlags) do
		info.text = text;
		local dropdownText = info.text;
		self:SetDropdownInfoForPreferences(info, sortByFlag, dropdownText, allowMultipleSelection, isRadioStyle);
		UIDropDownMenu_AddButton(info);
	end
end

ClubSizeDropdownMixin = CreateFromMixins(SettingsDropdownMixin);

function ClubSizeDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();

	info.text = SMALL;
	local dropdownText = info.text;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Small, dropdownText)	
	UIDropDownMenu_AddButton(info);

	info.text = CLUB_FINDER_MEDIUM;
	local dropdownText = info.text;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Medium, dropdownText)
	UIDropDownMenu_AddButton(info);

	info.text = LARGE;
	local dropdownText = info.text;
	self:SetDropdownInfoForPreferences(info, Enum.ClubFinderSettingFlags.Large, dropdownText)
	UIDropDownMenu_AddButton(info);
end

ClubFinderOptionsMixin = { };

function ClubFinderOptionsMixin:OnLoad()
	self:InitializeRoleButtons();
	self:SetEnabledRoles();
end

function ClubFinderOptionsMixin:OnShow()
	self:RefreshRoleButtons();
	self:CheckDisabled();
end

function ClubFinderOptionsMixin:CheckDisabled()
	local disabledReason = C_ClubFinder.GetClubFinderDisableReason();
	local enabled = disabledReason == nil;
	if enabled then
		UIDropDownMenu_EnableDropDown(self.ClubFilterDropdown);
		UIDropDownMenu_EnableDropDown(self.ClubSizeDropdown);
		UIDropDownMenu_EnableDropDown(self.SortByDropdown);
	else
		UIDropDownMenu_DisableDropDown(self.ClubFilterDropdown);
		UIDropDownMenu_DisableDropDown(self.ClubSizeDropdown);
		UIDropDownMenu_DisableDropDown(self.SortByDropdown);
	end

	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();
	self.TankRoleFrame:SetEnabled(canBeTank and enabled);
	self.HealerRoleFrame:SetEnabled(canBeHealer and enabled);
	self.DpsRoleFrame:SetEnabled(canBeDPS and enabled);
	self.SearchBox:SetEnabled(enabled);
	self.Search:SetEnabled(enabled and self.Search:ShouldBeEnabled());
end

function ClubFinderOptionsMixin:SetType(isGuildType)
	if(isGuildType) then
		self:SetupGuildFinderOptions();
	else
		self:SetupCommunityFinderOptions();
	end

	self.ClubFilterDropdown:SetLanguageFlags(C_ClubFinder.GetPlayerApplicantLocaleFlags());
end

function ClubFinderOptionsMixin:OnSearchButtonClick()
	local searchTerms = self.SearchBox:GetText():gsub("\n","");
	local specIDs = ClubFinderGetPlayerSpecIds();
	local filteredSpecIDs = { };
	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();

	for _, playerSpecID in ipairs(specIDs) do
		local _, name, _, _, role = GetSpecializationInfoForSpecID(playerSpecID);
		if (canBeTank and role == "TANK" and self.TankRoleFrame.CheckBox:GetChecked()) then
			table.insert(filteredSpecIDs, playerSpecID);
		elseif (canBeDPS and role == "DAMAGER" and self.DpsRoleFrame.CheckBox:GetChecked()) then
			table.insert(filteredSpecIDs, playerSpecID);
		elseif (canBeHealer and role == "HEALER" and self.HealerRoleFrame.CheckBox:GetChecked()) then
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

function ClubFinderOptionsMixin:InitializeRoleButton(button)
	button.Icon:SetDesaturated(true);
	button.CheckBox:Disable();
end

function ClubFinderOptionsMixin:InitializeRoleButtons()
	self:InitializeRoleButton(self.TankRoleFrame);
	self:InitializeRoleButton(self.HealerRoleFrame);
	self:InitializeRoleButton(self.DpsRoleFrame);
end

function ClubFinderOptionsMixin:RefreshRoleButtons()
	self.DpsRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Damage));
	self.HealerRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Healer));
	self.TankRoleFrame.CheckBox:SetChecked(ClubFinderGetPlayerSettingsByValue(Enum.ClubFinderSettingFlags.Tank));
end

function ClubFinderOptionsMixin:SetOptionsState(shouldHide)
	self.TankRoleFrame:SetShown(not shouldHide);
	self.HealerRoleFrame:SetShown(not shouldHide);
	self.DpsRoleFrame:SetShown(not shouldHide);
	self.ClubFilterDropdown:SetShown(not shouldHide);

	if(self:GetParent().isGuildType) then
		self.ClubSizeDropdown:SetShown(not shouldHide);
	else
		self.SortByDropdown:SetShown(not shouldHide);
	end
	self.Search:SetShown(not shouldHide);
	self.SearchBox:SetShown(not shouldHide);

	self.PendingTextFrame:SetShown(shouldHide);
end

function ClubFinderOptionsMixin:SetEnabledRoles()
	local _, _, classID = UnitClass("player");
	local canBeTank, canBeHealer, canBeDPS = C_LFGList.GetAvailableRoles();

	for i = 1, 4 do
		local role = select(5,GetSpecializationInfoForClassID(classID, i));
		if (canBeTank and role == "TANK") then
			self.TankRoleFrame.Icon:SetDesaturated(false);
			self.TankRoleFrame.CheckBox:Enable();
		elseif(canBeHealer and role == "HEALER") then
			self.HealerRoleFrame.Icon:SetDesaturated(false);
			self.HealerRoleFrame.CheckBox:Enable();
		elseif(canBeDPS and role == "DAMAGER") then
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
	self.ClubSizeDropdown:SetPoint("RIGHT", self.ClubFilterDropdown, "RIGHT", 110, 0);
	self.ClubSizeDropdown:Show();

	self.ClubFilterDropdown:Initialize();
	UIDropDownMenu_SetWidth(self.ClubFilterDropdown, CLUB_FINDER_WIDE_DROPDOWN_WIDTH);
	UIDropDownMenu_JustifyText(self.ClubFilterDropdown, "LEFT");
	UIDropDownMenu_Initialize(self.ClubFilterDropdown, ClubFinderFilterDropdownInitialize);
	self.ClubFilterDropdown:ClearAllPoints();
	self.ClubFilterDropdown:SetPoint("TOPLEFT", -5, 18);
	self.ClubFilterDropdown:Show();

	self.TankRoleFrame:ClearAllPoints();
	self.TankRoleFrame:SetPoint("RIGHT", self.ClubSizeDropdown, "RIGHT", 40, 10);

	self.SearchBox:ClearAllPoints();
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 160, 10);

	self.SortByDropdown:Hide();
end

function ClubFinderOptionsMixin:SetupCommunityFinderOptions()
	self.SortByDropdown.isPlayerApplicant = true;
	UIDropDownMenu_SetWidth(self.SortByDropdown, 80);
	UIDropDownMenu_Initialize(self.SortByDropdown, ClubSortByDropdownInitialize);

	self.SortByDropdown:ClearAllPoints();
	self.SortByDropdown:SetPoint("RIGHT", self.ClubFilterDropdown, "RIGHT", 110, 0);
	self.SortByDropdown:Show();

	self.ClubFilterDropdown:Initialize();
	UIDropDownMenu_SetWidth(self.ClubFilterDropdown, CLUB_FINDER_WIDE_DROPDOWN_WIDTH);
	UIDropDownMenu_JustifyText(self.ClubFilterDropdown, "LEFT");
	UIDropDownMenu_Initialize(self.ClubFilterDropdown, ClubFinderFilterDropdownInitialize);

	self.ClubFilterDropdown:ClearAllPoints();
	self.ClubFilterDropdown:SetPoint("TOPLEFT", -5, 18);
	self.ClubFilterDropdown:Show();

	self.TankRoleFrame:ClearAllPoints();
	self.TankRoleFrame:SetPoint("RIGHT", self.SortByDropdown, "RIGHT", 40, 10);

	self.SearchBox:ClearAllPoints();
	self.SearchBox:SetPoint("RIGHT", self.DpsRoleFrame, "RIGHT", 160, 10);

	self.ClubSizeDropdown:Hide();
end

ClubFinderSearchButtonMixin = { };

function ClubFinderSearchButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():OnSearchButtonClick();
end

function ClubFinderSearchButtonMixin:ShouldBeEnabled()
	local searchTextLen = strlenutf8(self:GetParent().SearchBox:GetText());
	return searchTextLen == 0 or searchTextLen >= 3;
end

function ClubFinderSearchButtonMixin:OnEnter()
	self.mouseInButton = true;
	self:UpdateTooltip();
end

function ClubFinderSearchButtonMixin:OnLeave()
	self.mouseInButton = nil;
	self:UpdateTooltip();
end

function ClubFinderSearchButtonMixin:UpdateEnabledState()
	self:SetEnabled(self:ShouldBeEnabled());
	self:UpdateTooltip();
end

function ClubFinderSearchButtonMixin:UpdateTooltip()
	if self.mouseInButton and not self:IsEnabled() then
		self:ShowTooltip();
	else
		self:HideTooltip();
	end
end

function ClubFinderSearchButtonMixin:ShowTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_SEARCH_ERROR, RED_FONT_COLOR);
	GameTooltip:Show();
end

function ClubFinderSearchButtonMixin:HideTooltip()
	GameTooltip:Hide();
end

ClubFinderSearchEditBoxMixin = { };

function ClubFinderSearchEditBoxMixin:OnEnterPressed()
	if (self:GetParent().Search:ShouldBeEnabled()) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self:GetParent():OnSearchButtonClick();
	end
end

function ClubFinderSearchEditBoxMixin:OnTextChanged()
	self:GetParent().Search:UpdateEnabledState();
end

function CardRightClickOptionsMenuInitialize(self, level)

	if(self:GetParent():IsReported() or not self:GetParent().cardInfo) then 
		return; 
	end

	local info = UIDropDownMenu_CreateInfo();

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		info.text = self:GetParent().cardInfo.isGuild and CLUB_FINDER_REPORT_GUILD_NAME or CLUB_FINDER_REPORT_COMMUNITY_NAME;
		info.notCheckable = true;
		info.func = function() ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.ClubName, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_REPORT_NAME;
		info.notCheckable = true;
		info.func = function() ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.PostersName, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
		UIDropDownMenu_AddButton(info, level);

		local guildDescrip = self:GetParent().cardInfo.comment;
		if(guildDescrip:gsub("%s", "") ~= "") then 
			info.text = CLUB_FINDER_REPORT_DESCRIPTION;
			info.notCheckable = true;
			info.func = function() 	ClubFinderReportFrame:ShowReportDialog(Enum.ClubFinderPostingReportType.PostingDescription, self:GetParent():GetClubGUID(), self:GetParent():GetLastPosterGUID(), self:GetParent().cardInfo); end
			UIDropDownMenu_AddButton(info, level);
		end
	end

	if (level == 1) then
		info.text = self:GetParent():GetCardName();
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);

		local cardStatus =  self:GetParent():GetCardStatus();
		local requestToJoinOption = not (C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(self:GetParent():GetClubGUID())
		or (cardStatus == Enum.PlayerClubRequestStatus.None) or (cardStatus == Enum.PlayerClubRequestStatus.Pending) or (cardStatus ==  Enum.PlayerClubRequestStatus.Declined) or (cardStatus ==  Enum.PlayerClubRequestStatus.Accepted) or (cardStatus ==  Enum.PlayerClubRequestStatus.AutoApproved));

		local requestToJoinReRequest = (not C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(self:GetParent():GetClubGUID()) and cardStatus ==  Enum.PlayerClubRequestStatus.Declined);

		local cancelOption = not ( C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(self:GetParent():GetClubGUID())
			or (cardStatus == Enum.PlayerClubRequestStatus.None)
			or (cardStatus == Enum.PlayerClubRequestStatus.Declined)
			or (cardStatus == Enum.PlayerClubRequestStatus.Joined)
			or (cardStatus == Enum.PlayerClubRequestStatus.JoinedAnother)
			or (cardStatus == Enum.PlayerClubRequestStatus.Canceled)
			or (cardStatus == Enum.PlayerClubRequestStatus.Accepted)
			or (cardStatus == Enum.PlayerClubRequestStatus.AutoApproved)
			);

		if(requestToJoinReRequest) then
			info.colorCode = RED_FONT_COLOR;
			info.text = CLUB_FINDER_REAPPLY:format(ClubFinderGetClubApplicationExpirationTime(self:GetParent().cardInfo.lastUpdatedTime));
			info.isTitle = false;
			info.notCheckable = true;
			info.disabled = true;
			info.func = nil;
			UIDropDownMenu_AddButton(info, level);
		end

		if(requestToJoinOption) then
			info.colorCode = HIGHLIGHT_FONT_COLOR_CODE;
			info.text = CLUB_FINDER_REQUEST_TO_JOIN;
			info.isTitle = false;
			info.notCheckable = true;
			info.disabled = nil;
			info.func = function() self:GetParent():RequestToJoinClub(); end;
			UIDropDownMenu_AddButton(info, level);
		end

		if(cancelOption) then
			info.colorCode = HIGHLIGHT_FONT_COLOR_CODE;
			info.text = CLUB_FINDER_CANCEL_APPLICATION;
			info.isTitle = false;
			info.notCheckable = true;
			info.disabled = nil;
			info.func = function() C_ClubFinder.CancelMembershipRequest(self:GetParent():GetClubGUID()); end
			UIDropDownMenu_AddButton(info, level);
		end

		info.text = CLUB_FINDER_REPORT_FOR;
		info.isTitle = false;
		info.disabled = nil;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE;
		info.notCheckable = true;
		info.hasArrow = true
		info.func = nil;
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
	if ( button == "RightButton" and not C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(self.cardInfo.clubFinderGUID)) then
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

function ClubFinderCardMixin:IsReported() 
	return self.isReported;
end 

function ClubFinderCardMixin:GetCardStatus()
	return C_ClubFinder.GetPlayerClubApplicationStatus(self.cardInfo.clubFinderGUID);
end

ClubFinderGuildCardMixin = CreateFromMixins(ClubFinderCardMixin);

function ClubFinderGuildCardMixin:RequestToJoinClub()
	self:GetParent():GetParent().RequestToJoinFrame.card = self;
	self:GetParent():GetParent().RequestToJoinFrame.isLinkedPosting = false;
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
		SetLargeGuildTabardTextures(nil, self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, self.cardInfo.tabardInfo);
	end

	self.CardBackground:SetDesaturated(shouldDisable);
	self.MemberIcon:SetDesaturated(shouldDisable);

	self.Name:SetTextColor(fontColor:GetRGB());
	self.MemberCount:SetTextColor(fontColor:GetRGB());
end

function ClubFinderGetFocusStringFromFlags(recruitmentFlags)
	local focusFlag = C_ClubFinder.GetFocusIndexFromFlag(recruitmentFlags)
	if (focusFlag == Enum.ClubFinderSettingFlags.Dungeons) then
		return GUILD_INTEREST_DUNGEON;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Raids) then
		return GUILD_INTEREST_RAID;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.PvP) then
		return CLUB_FINDER_FOCUS_PVP;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.RP) then
		return GUILD_INTEREST_RP;
	elseif (focusFlag == Enum.ClubFinderSettingFlags.Social) then
		return CLUB_FINDER_FOCUS_SOCIAL_LEVELING;
	else
		return nil;
	end
end

function ClubFinderGuildCardMixin:SetReportedCardState(isReported)
	self.Name:SetShown(not isReported);
	self.Description:SetShown(not isReported);
	self.MemberCount:SetShown(not isReported);
	self.RequestJoin:SetShown(not isReported);
	self.MemberIcon:SetShown(not isReported);
	self.ReportedDescription:SetShown(isReported);
	self.RequestStatus:SetShown(isReported);
	self.Focus:SetShown(not isReported);
	self:SetDisabledState(isReported)
	if(isReported) then
		self.RequestStatus:SetText(CLUB_FINDER_REPORTED);
		SetLargeGuildTabardTextures(nil, self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, nil);
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
	end
	self.isReported = isReported; 
end

function ClubFinderGuildCardMixin:UpdateCard()
	local info = self.cardInfo;
	if (info.isReported) then
		self:SetReportedCardState(true);
		return;
	else
		self:SetReportedCardState(false);
	end
	local clubStatus = C_ClubFinder.GetPlayerClubApplicationStatus(info.clubFinderGUID);

	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment:gsub("\n",""));
	self.MemberCount:SetText(info.numActiveMembers);
	self.RightClickDropdown.isGuildCard = true;
	local focusString = ClubFinderGetFocusStringFromFlags(info.recruitmentFlags);
	if (focusString) then
		self.Focus:SetText(CLUB_FINDER_FOCUS_STRING:format(focusString));
		self.Focus:Show();
	else
		self.Focus:Hide();
	end
	SetLargeGuildTabardTextures(nil, self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, info.tabardInfo);

	if(C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(info.clubFinderGUID)) then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		self.RequestStatus:SetText(CLUB_FINDER_ALREADY_IN_THAT_CLUB);
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		self:SetDisabledState(true);
	elseif (clubStatus) then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		if(clubStatus == Enum.PlayerClubRequestStatus.None) then
			self.RequestJoin:Show();
			self.RequestStatus:Hide();
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Pending) then
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self.RequestStatus:SetText(CLUB_FINDER_PENDING);
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Approved or clubStatus == Enum.PlayerClubRequestStatus.AutoApproved) then
			self.RequestStatus:SetText(CLUB_FINDER_INVITED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Declined) then
			self.RequestStatus:SetText(CLUB_FINDER_DECLINED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Canceled) then
			self.RequestStatus:SetText(CLUB_FINDER_CANCELED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Joined) then
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

	CommunitiesUtil.AddLookingForLines(GameTooltip, info.recruitingSpecIds, self.recruitingSpecIds, self.playerSpecs);

	if (info.comment ~= "") then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_CLUB_DESCRIPTION:format(info.comment), GRAY_FONT_COLOR);
	end
	GameTooltip:Show();
end

ClubFinderCommunitiesCardMixin = CreateFromMixins(ClubFinderCardMixin);

function ClubFinderCommunitiesCardMixin:SetReportedCardState(isReported)
	self.Name:SetShown(not isReported);
	self.Description:SetShown(not isReported);
	self.MemberCount:SetShown(not isReported);
	self.RequestJoin:SetShown(not isReported);
	self.MemberIcon:SetShown(not isReported);
	self.ReportedDescription:SetShown(isReported);
	self.RequestStatus:SetShown(isReported);
	self.Focus:SetShown(not isReported);
	self:SetDisabledState(isReported)
	self.RequestStatus:SetText(CLUB_FINDER_REPORTED);
	self.LogoBorder:SetDesaturated(isReported);
	self.MemberIcon:SetDesaturated(isReported);
	self.CommunityLogo:SetDesaturated(isReported);
	if(isReported) then
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		self.RequestStatus:SetText(CLUB_FINDER_REPORTED);
	end
	self.isReported = isReported;
end

function ClubFinderCommunitiesCardMixin:GetGuildAndCommunityFrame()
	return self:GetParent():GetParent():GetParent():GetParent();
end

function ClubFinderCommunitiesCardMixin:RequestToJoinClub()
	local parentFrame = self:GetGuildAndCommunityFrame();
	parentFrame.RequestToJoinFrame.card = self;
	parentFrame.RequestToJoinFrame.isLinkedPosting = false;
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

function ClubFinderCommunitiesCardMixin:AllowOrDiallowClicks(shouldAllow)
	self.allowClicks = shouldAllow;
end

function ClubFinderCommunitiesCardMixin:OnClick()
	if(self.allowPendingClicks and self.allowClicks and not IsModifiedClick("CHATLINK")) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
		self:RequestToJoinClub();
	end
end

function ClubFinderCommunitiesCardMixin:UpdateCard()
	local info = self.cardInfo;

	if (info.isReported) then
		self:SetReportedCardState(true);
		return;
	else
		self:SetReportedCardState(false);
	end

	local clubStatus = C_ClubFinder.GetPlayerClubApplicationStatus(info.clubFinderGUID);
	self:CreateRecruitingSpecsMap();

	self.Name:SetText(info.name);
	self.Description:SetText(info.comment);
	self.MemberCount:SetText(info.numActiveMembers);
	self.RightClickDropdown.isGuildCard = false;

	local focusString = ClubFinderGetFocusStringFromFlags(info.recruitmentFlags);
	if (focusString) then
		self.Focus:SetText(CLUB_FINDER_FOCUS_STRING:format(focusString));
		self.Focus:Show();
	else
		self.Focus:Hide();
	end
	if (info.emblemInfo > 0) then
		C_Club.SetAvatarTexture(self.CommunityLogo, info.emblemInfo, Enum.ClubType.Character);
	end

	self:AllowOrDiallowClicks(false);

	if(C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(info.clubFinderGUID)) then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		self.RequestStatus:SetText(CLUB_FINDER_ALREADY_IN_THAT_CLUB);
		self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
		self:SetDisabledState(true);
	elseif (clubStatus) then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		if (clubStatus == Enum.PlayerClubRequestStatus.None) then
			self.RequestJoin:Show();
			self.RequestStatus:Hide();
			self:SetDisabledState(false);
			self:AllowOrDiallowClicks(true);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Pending) then
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self.RequestStatus:SetText(CLUB_FINDER_PENDING);
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Approved or clubStatus == Enum.PlayerClubRequestStatus.AutoApproved) then
			self.RequestStatus:SetText(CLUB_FINDER_INVITED);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Declined) then
			self.RequestStatus:SetText(CLUB_FINDER_DECLINED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Joined) then
			self.RequestStatus:SetText(CLUB_FINDER_Joined);
			self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
			self:SetDisabledState(false);
		elseif (clubStatus == Enum.PlayerClubRequestStatus.Canceled) then
			self.RequestStatus:SetText(CLUB_FINDER_CANCELED);
			self.RequestStatus:SetTextColor(RED_FONT_COLOR:GetRGB());
			self:SetDisabledState(true);
		end
	else
		self.RequestJoin:Show();
		self.RequestStatus:Hide();
		self:SetDisabledState(false);
		self:AllowOrDiallowClicks(true);
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

	CommunitiesUtil.AddLookingForLines(GameTooltip, info.recruitingSpecIds, self.recruitingSpecIds, self.playerSpecs);

	if (info.comment ~= "") then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_CLUB_DESCRIPTION:format(info.comment), GRAY_FONT_COLOR);
	end
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

function ClubFinderCommunitiesCardsBaseMixin:ClearCardList()
	self.CardList = { };
	self.totalListSize = 0;
end

function ClubFinderCommunitiesCardsBaseMixin:OnLoad()
	self.CardList = { };
	self.ListScrollFrame.update = function() self:RefreshLayout() end;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "ClubFinderCommunitiesCardTemplate", 13, -6, "TOPLEFT", nil, nil, -5);
end

function ClubFinderCommunitiesCardsBaseMixin:FindAndSetReportedCard(clubFinderGUID)
	for i = 1, #self.CardList do
		if (self.CardList[i].clubFinderGUID == clubFinderGUID) then
			self.CardList[i].isReported = true;
			return;
		end
	end
end


function ClubFinderCommunitiesCardsBaseMixin:UpateCardsAlreadyInList(clubFinderGUIDS)
	if(not clubFinderGUIDS or #clubFinderGUIDS == 0) then
		return;
	end

	local scrollFrame = self.ListScrollFrame;
	if (not self:IsShown()) then
		return;
	end

	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	HybridScrollFrame_SetDoNotHideScrollBar(scrollFrame, true);

	local index;
	if (scrollFrame.buttons) then
		numCardsTotal = #self.CardList;
		for i = 1, #scrollFrame.buttons do
			index = offset + i;
			for _, finderGUID in pairs(clubFinderGUIDS) do
				local cardInfo = self.CardList[index];
				local currentCard = scrollFrame.buttons[i];
				if(cardInfo and finderGUID == cardInfo.clubFinderGUID) then
					currentCard.cardInfo.clubStatus =  C_ClubFinder.GetPlayerClubApplicationStatus(cardInfo.clubFinderGUID);
					currentCard:UpdateCard();
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
				if (currentCard:IsMouseOver()) then
					currentCard:OnEnter();
				end
				currentCard.allowPendingClicks = not self.isPendingCardList;
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
	self.isPendingCardList = false;
	self:GetParent().InsetFrame.GuildDescription:SetText(CLUB_FINDER_SEARCH_NOTHING_FOUND);
end

ClubFinderPendingCommunitiesCardsMixin = CreateFromMixins(ClubFinderCommunitiesCardsBaseMixin);
function ClubFinderPendingCommunitiesCardsMixin:BuildCardList()
	self.pagingEnabled = false;
	self.isPendingCardList = true;
	self.CardList = C_ClubFinder.PlayerReturnPendingCommunitiesList();
end

ClubFinderGuildCardsBaseMixin = { };

function ClubFinderGuildCardsBaseMixin:ClearCardList()
	self.CardList = { };
	self.numPages = 0;
	self.pageNumber = 1;
end

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

function ClubFinderGuildCardsBaseMixin:OnMouseWheel(delta)
	local nextPageValue = self.pageNumber + 1;
	local previousPageValue = self.pageNumber - 1;
	if ( delta < 0 and previousPageValue > 0) then
		self:PagePrevious();
	elseif(delta > 0 and nextPageValue <= self.numPages) then
		self:PageNext();
	end
end

function ClubFinderGuildCardsBaseMixin:SetSearchingState()
	self.SearchingSpinner:Show();
	self:GetParent().InsetFrame.GuildDescription:Hide();
	self.NextPage:SetEnabled(false);
	self:HideCardList();
end

function ClubFinderGuildCardsBaseMixin:PageNext()
	if (self.requestedPage and not self.newRequest) then
		self:SetSearchingState();
		return;
	end

	self.pageNumber = self.pageNumber + 1;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CloseDropDownMenus();
	self:RefreshLayout(self.pageNumber);
end

function ClubFinderGuildCardsBaseMixin:PagePrevious()
	self.pageNumber = self.pageNumber - 1;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CloseDropDownMenus();
	self:RefreshLayout(self.pageNumber);
end

function ClubFinderGuildCardsBaseMixin:HideCardList()
	for i = 1, #self.Cards do
		self.Cards[i]:Hide();
	end
end

function ClubFinderGuildCardsBaseMixin:FindAndSetReportedCard(clubFinderGUID)
	for i = 1, #self.CardList do
		if (self.CardList[i].clubFinderGUID == clubFinderGUID) then
			self.CardList[i].isReported = true;
			return;
		end
	end
end

function ClubFinderGuildCardsBaseMixin:RefreshLayout(cardPage)
	if (not self:IsShown()) then
		return;
	end

	if(not cardPage) then
		cardPage = 1;
	end

	self.SearchingSpinner:Hide();
	local playerSpecs = ClubFinderGetPlayerSpecIds();
	self.showingCards = false;
	local numCardsTotal = #self.CardList;
	for i = 1, #self.Cards do
		local cardIndex = (cardPage - 1) * GUILD_CARDS_PER_PAGE + i;
		local cardInfo = self.CardList[cardIndex];
		if(cardInfo) then
			self.Cards[i].playerSpecs = playerSpecs;
			self.Cards[i].cardInfo = cardInfo;
			self.Cards[i]:UpdateCard();
			self.Cards[i]:Show();
			if (self.Cards[i]:IsMouseOver()) then
				self.Cards[i]:OnEnter();
			end
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
		if (self.requestedPage and not self.newRequest) then
			self:SetSearchingState();
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
	local numLoadedPages = math.ceil(numCardsTotal / GUILD_CARDS_PER_PAGE);
	local shouldRequestNextPage = (self.pagingEnabled and (cardPage + LOAD_PAGES_IN_ADVANCE == numLoadedPages) and ( cardPage + LOAD_PAGES_IN_ADVANCE < self.numPages));

	if (shouldRequestNextPage and self.showingCards and not self.requestedPage) then
		local startingIndex = cardPage * GUILD_CARDS_PER_PAGE;
		C_ClubFinder.RequestNextGuildPage(startingIndex, REQUEST_GUILD_CARDS_NUM);
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

function ClubFinderGuildAndCommunityMixin:UpdateEnabledState()
	local enabled = C_ClubFinder.IsEnabled();

	self.OptionsList:SetShown(enabled);
	self.InsetFrame:SetShown(enabled);
	self.ClubFinderSearchTab:SetShown(enabled);
	self.ClubFinderPendingTab:SetShown(enabled);

	self.DisabledFrame:SetShown(not enabled);
end

function ClubFinderGuildAndCommunityMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CLUB_FINDER_FRAME_EVENTS);
	self.selectedTab = LAYOUT_TYPE_REGULAR_SEARCH;
	C_ClubFinder.PlayerRequestPendingClubsList(Enum.ClubFinderRequestType.All); -- Player's applications to a guild or community
	self:UpdateEnabledState();
end

function ClubFinderGuildAndCommunityMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CLUB_FINDER_FRAME_EVENTS);
end

function ClubFinderGuildAndCommunityMixin:UpdatePendingTab()
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
end

function ClubFinderGuildAndCommunityMixin:OnEvent(event, ...)
	if (event == "CLUB_FINDER_CLUB_LIST_RETURNED") then
		local requestType = ...;
		local buildGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All);
		local builCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All);
		if (buildGuild) then
			self.GuildCards:BuildCardList();
			if (self.isGuildType) then
				self.GuildCards.requestedPage = false;
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
			self.GuildCards:RefreshLayout(self.GuildCards.pageNumber);
			self.PendingGuildCards:RefreshLayout(self.PendingGuildCards.pageNumber);
		end
		if (buildCommunity) then
			self.PendingCommunityCards:BuildCardList();
			self.PendingCommunityCards:RefreshLayout();
			self.CommunityCards:RefreshLayout();
		end
		self:UpdatePendingTab();
	elseif (event == "CLUB_FINDER_LINKED_CLUB_RETURNED") then
		local clubInfo = ...;
		local communitiesFrame = self:GetParent();
		communitiesFrame.ClubFinderInvitationFrame:DisplayInvitation(clubInfo, true);
	elseif (event == "CLUB_FINDER_APPLICATIONS_UPDATED") then
		local requestType, finderGuids = ...;
		local updateGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All);
		local updateCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All);
		if (updateGuild) then
			self.PendingGuildCards:BuildCardList();
			self.GuildCards:RefreshLayout(self.GuildCards.pageNumber);
			self.PendingGuildCards:RefreshLayout(self.PendingGuildCards.pageNumber);
		end
		if (updateCommunity) then
			self.PendingCommunityCards:BuildCardList();
			self.CommunityCards:UpateCardsAlreadyInList(finderGuids);
			self.PendingCommunityCards:UpateCardsAlreadyInList(finderGuids);
		end
		self:UpdatePendingTab();
	elseif(event == "CLUB_FINDER_CLUB_REPORTED") then
		local requestType, clubFinderGUID = ...;
		local updateGuild = (requestType == Enum.ClubFinderRequestType.Guild) or (requestType == Enum.ClubFinderRequestType.All);
		local updateCommunity = (requestType == Enum.ClubFinderRequestType.Community) or (requestType == Enum.ClubFinderRequestType.All);
		if (updateGuild) then
			self.GuildCards:FindAndSetReportedCard(clubFinderGUID);
			self.GuildCards:RefreshLayout(self.GuildCards.pageNumber);
			self.PendingGuildCards:FindAndSetReportedCard(clubFinderGUID);
			self.PendingGuildCards:RefreshLayout(self.PendingGuildCards.pageNumber);
		elseif (updateCommunity) then
			self.CommunityCards:FindAndSetReportedCard(clubFinderGUID);
			self.CommunityCards:RefreshLayout();
			self.PendingCommunityCards:FindAndSetReportedCard(clubFinderGUID);
			self.PendingCommunityCards:RefreshLayout();
		end
	end
end

function ClubFinderGuildAndCommunityMixin:ClearAllCardLists()
	self.PendingGuildCards:ClearCardList();
	self.GuildCards:ClearCardList();
	self.PendingCommunityCards:ClearCardList();
	self.CommunityCards:ClearCardList();
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
	self:GetDisplayModeBasedOnSelectedTab();
end

function ClubFinderGuildAndCommunityMixin:GetDisplayModeBasedOnSelectedTab()
	local tabSelection = self.selectedTab;

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

function ClubFinderInvitationsFrameMixin:OnShow()
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
end

function ClubFinderInvitationsFrameMixin:OnHide()
	self:UnregisterEvent("PLAYER_GUILD_UPDATE");
end

function ClubFinderInvitationsFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_GUILD_UPDATE" then
		if(not self.clubInfo) then
			return;
		end
		if(not self.isLinkInvitation) then
			if (isGuild and (IsGuildLeader() or IsInGuild())) then
				self.AcceptButton:SetEnabled(false);
			else
				self.AcceptButton:SetEnabled(true);
			end
		end
	end
end

function ClubFinderInvitationsFrameMixin:DisplayInvitation(clubInfo, isLinkInvitation)
	self.clubInfo = clubInfo;
	if(not clubInfo) then
		return;
	end

	self:GetParent():SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.INVITATION);
	self:GetParent():SelectClub(nil);

	local isGuild = clubInfo.isGuild;
	self.isLinkInvitation = isLinkInvitation;

	if (isGuild) then
		SetLargeGuildTabardTextures(nil, self.GuildBannerEmblemLogo, self.GuildBannerBackground, self.GuildBannerBorder, clubInfo.tabardInfo);
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
		local doesPlayerBelongToClub = C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(clubInfo.clubFinderGUID);
		local hasPlayerAlreadyAppliedToClub = C_ClubFinder.HasAlreadyAppliedToLinkedPosting(clubInfo.clubFinderGUID);
		self.ApplyButton:SetEnabled(not doesPlayerBelongToClub and not hasPlayerAlreadyAppliedToClub);
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
	self.RequestToJoinFrame.isLinkedPosting = true;
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

	local doesPlayerBelongToClub = C_ClubFinder.DoesPlayerBelongToClubFromClubGUID(self.clubInfo.clubFinderGUID);
	local hasPlayerAlreadyAppliedToClub = C_ClubFinder.HasAlreadyAppliedToLinkedPosting(self.clubInfo.clubFinderGUID);

	if (not self.ApplyButton:IsEnabled() and self.ApplyButton:IsShown()) then
		if (doesPlayerBelongToClub) then
			GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ALREADY_IN_THAT_CLUB, RED_FONT_COLOR, true);
			GameTooltip:Show();
		elseif (hasPlayerAlreadyAppliedToClub) then
			GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_ALREADY_APPLIED_ERROR, RED_FONT_COLOR, true);
			GameTooltip:Show();
		end
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
	local parent = self:GetParent();

	if (self == self:GetParent().ClubFinderSearchTab) then
		parent.selectedTab = LAYOUT_TYPE_REGULAR_SEARCH;
		self:GetParent():GetDisplayModeBasedOnSelectedTab();
	else
		parent.selectedTab = LAYOUT_TYPE_PENDING_LIST;
		self:GetParent():GetDisplayModeBasedOnSelectedTab();
	end

end

ClubFinderRoleCheckBoxMixin = { };

function ClubFinderRoleCheckBoxMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 5);

	if self:IsEnabled() then
		local clubFinderFrame = self:GetParent():GetParent():GetParent();
		if (clubFinderFrame.isGuildType) then
			GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ROLE_TOOLTIP:format(CLUB_FINDER_GUILDS));
		else
			GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_ROLE_TOOLTIP:format(CLUB_FINDER_COMMUNITIES));
		end
	else
		local wrap = false;
		GameTooltip_AddErrorLine(GameTooltip, YOUR_CLASS_MAY_NOT_PERFORM_ROLE, wrap);
	end

	GameTooltip:Show()
end

function ClubFinderRoleCheckBoxMixin:OnLeave()
	GameTooltip:Hide();
end


ClubFinderRoleMixin = { };

function ClubFinderRoleMixin:OnEnter()
	self.CheckBox:OnEnter();
end

function ClubFinderRoleMixin:OnLeave()
	self.CheckBox:OnLeave();
end

function ClubFinderRoleMixin:SetEnabled(enabled)
	self.CheckBox:SetEnabled(enabled);
	self.Icon:SetDesaturated(not enabled);
end

function ClubFinderGetPlayerSettingsByValue(value)
	local playerSettings = C_ClubFinder.GetPlayerApplicantSettings();
	if (value == Enum.ClubFinderSettingFlags.Dungeons) then
		return playerSettings.playStyleDungeon;
	elseif (value == Enum.ClubFinderSettingFlags.Raids) then
		return playerSettings.playStyleRaids;
	elseif (value == Enum.ClubFinderSettingFlags.PvP) then
		return playerSettings.playStylePvp;
	elseif (value == Enum.ClubFinderSettingFlags.RP) then
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
	local currentInfo = ClubFinderGetCurrentClubListingInfo(clubId)
	if (currentInfo and C_ClubFinder.IsListingEnabledFromFlags(currentInfo.recruitmentFlags)) then
		return true;
	else
		return false;
	end
end

function ClubFinderGetClubPostingExpirationTime(clubId)
	local clubPostingInfo = ClubFinderGetCurrentClubListingInfo(clubId);
	if (clubPostingInfo and C_ClubFinder.IsListingEnabledFromFlags(clubPostingInfo.recruitmentFlags)) then
		local unixTime = C_DateAndTime.GetServerTimeLocal() - clubPostingInfo.lastUpdatedTime;
		return POSTING_EXPIRATION_DAYS - math.ceil(unixTime / SECONDS_PER_DAY);
	end
	return nil;
end

function ClubFinderGetClubApplicationExpirationTime(time)
	local unixTime = C_DateAndTime.GetServerTimeLocal() - time;
	return APPLICATION_EXPIRATION_DAYS - math.ceil(unixTime / SECONDS_PER_DAY);
end