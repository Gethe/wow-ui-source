ReportFrameMixin = { };

local ReportMajorCategoriesByReportType = { 
	[Enum.ReportType.Chat] = {
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.InWorld] = { 
		Enum.ReportMajorCategory.InappropriateName, 
		Enum.ReportMajorCategory.Cheating,
		Enum.ReportMajorCategory.GameplaySabotage 
	},
	[Enum.ReportType.ClubFinderPosting] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName
	},
	[Enum.ReportType.ClubFinderApplicant] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName
	},
	[Enum.ReportType.GroupFinderPosting] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.GroupFinderApplicant] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.ClubMember] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.GroupMember] = {
		Enum.ReportMajorCategory.InappropriateName,
		Enum.ReportMajorCategory.InappropriateCommunication,
	},
	[Enum.ReportType.Friend] = { 
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.Pet] = { 
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.BattlePet] = { 
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.Calendar] = { 
		Enum.ReportMajorCategory.InappropriateName,
		Enum.ReportMajorCategory.InappropriateCommunication
	},
	[Enum.ReportType.Mail] = { 
		Enum.ReportMajorCategory.InappropriateName,
		Enum.ReportMajorCategory.InappropriateCommunication
	},
	[Enum.ReportType.PvP] = { 
		Enum.ReportMajorCategory.InappropriateName,
	},
}

local ReportSubCategoriesByTypeAndMajorType = {
	[Enum.ReportType.Chat] = {  
		[Enum.ReportMajorCategory.InappropriateCommunication] = {
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Spam,
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Boosting,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
			Enum.ReportMinorCategory.BTag,
			Enum.ReportMinorCategory.GroupName,
		},
	},
	[Enum.ReportType.InWorld] = {
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
			Enum.ReportMinorCategory.BTag,
			Enum.ReportMinorCategory.GroupName,
			Enum.ReportMinorCategory.GuildName, 
		},
		[Enum.ReportMajorCategory.Cheating] = 
		{
			Enum.ReportMinorCategory.Hacking,
			Enum.ReportMinorCategory.Botting,
		},
		[Enum.ReportMajorCategory.GameplaySabotage] = 
		{
			Enum.ReportMinorCategory.Afk,
			Enum.ReportMinorCategory.IntentionallyFeeding,
			Enum.ReportMinorCategory.BlockingProgress, 
		},
	},
	[Enum.ReportType.ClubFinderPosting] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Description,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
			Enum.ReportMinorCategory.Name,
		},
	},
	[Enum.ReportType.ClubFinderApplicant] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Description,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
	},
	[Enum.ReportType.GroupFinderPosting] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Description,
			Enum.ReportMinorCategory.VoiceChat, 
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.GroupName,
			Enum.ReportMinorCategory.CharacterName,
		},
	},
	[Enum.ReportType.GroupFinderApplicant] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Description,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
			Enum.ReportMinorCategory.Name,
		},
	},
	[Enum.ReportType.ClubMember] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Boosting,
			Enum.ReportMinorCategory.Spam, 
			Enum.ReportMinorCategory.Advertisement,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
	},
	[Enum.ReportType.GroupMember] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Boosting,
			Enum.ReportMinorCategory.Spam, 
			Enum.ReportMinorCategory.Advertisement,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
	},
	[Enum.ReportType.Friend] = {
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
			Enum.ReportMinorCategory.BTag,
		},
	},
	[Enum.ReportType.Pet] = {
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Name
		},
	},
	[Enum.ReportType.BattlePet] = {
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Name
		},
	},
	[Enum.ReportType.Mail] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Spam,
			Enum.ReportMinorCategory.Advertisement,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
	},
	[Enum.ReportType.Calendar] = {
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Description,
		},
	},
	[Enum.ReportType.PvP] = { 
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.CharacterName,
		},
	},
}

local ReportMajorCategoryStrings = { 
	[Enum.ReportMajorCategory.InappropriateCommunication] = REPORTING_MAJOR_CATEGORY_INAPPROPRIATE_COMMUNICATION,
	[Enum.ReportMajorCategory.InappropriateName] = REPORTING_MAJOR_CATEGORY_INAPPROPRIATE_NAME,
	[Enum.ReportMajorCategory.Cheating] = REPORTING_MAJOR_CATEGORY_CHEATING,
	[Enum.ReportMajorCategory.GameplaySabotage] = REPORTING_MAJOR_CATEGORY_GAMEPLAY_SABOTAGE
}

local ReportMinorCategoryStrings = {
	[Enum.ReportMinorCategory.TextChat] = REPORTING_MINOR_CATEGORY_TEXT_CHAT,
	[Enum.ReportMinorCategory.Boosting] = REPORTING_MINOR_CATEGORY_BOOSTING,
	[Enum.ReportMinorCategory.Spam] = REPORTING_MINOR_CATEGORY_SPAM,
	[Enum.ReportMinorCategory.Afk] = REPORTING_MINOR_CATEGORY_AFK,
	[Enum.ReportMinorCategory.IntentionallyFeeding] = REPORTING_MINOR_CATEGORY_FEEDING,
	[Enum.ReportMinorCategory.BlockingProgress] = REPORTING_MINOR_CATEGORY_BLOCKING_PROG,
	[Enum.ReportMinorCategory.Hacking] = REPORTING_MINOR_CATEGORY_HACKING,
	[Enum.ReportMinorCategory.Botting] = REPORTING_MINOR_CATEGORY_BOTTING,
	[Enum.ReportMinorCategory.Advertisement] = REPORTING_MINOR_CATEGORY_ADVERTISEMENT,
	[Enum.ReportMinorCategory.BTag] = REPORTING_MINOR_CATEGORY_BTAG,
	[Enum.ReportMinorCategory.GroupName] = REPORTING_MINOR_CATEGORY_GROUP_NAME,
	[Enum.ReportMinorCategory.CharacterName] = REPORTING_MINOR_CATEGORY_CHARACTER_NAME,
	[Enum.ReportMinorCategory.GuildName] = REPORTING_MINOR_CATEGORY_GUILD_NAME,
	[Enum.ReportMinorCategory.Description] = REPORTING_MINOR_CATEGORY_DESCRIPTION,
	[Enum.ReportMinorCategory.Name] = REPORTING_MINOR_CATEGORY_NAME,
}

function ReportFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
	self.minorCategoryFlags = CreateFromMixins(FlagsMixin);
	self.minorCategoryFlags:OnLoad();
	self.selectedMajorType = nil; 
	self.MinorCategoryButtonPool = CreateFramePool("CHECKBUTTON", self, "ReportingFrameMinorCategoryButtonTemplate", FramePool_HideAndClearAnchors);
	self:RegisterEvent("REPORT_PLAYER_RESULT");
end		

function ReportFrameMixin:OnHide()
	self.MinorCategoryButtonPool:ReleaseAll();
	self.selectedMajorType = nil; 
	self.Comment:ClearAllPoints(); 
	self.reporPlayerLocation = nil;
	self.reportInfo = nil; 
	self.minorCategoryFlags:ClearAll(); 
	self:Layout(); 
end

function ReportFrameMixin:OnEvent(event, ...)
	if(event == "REPORT_PLAYER_RESULT") then 
		self:Hide();
	end		
end		

function ReportFrameMixin:SetupDropdownByReportType(reportType)
	self.ReportingMajorCategoryDropdown.reportType = reportType; 
	UIDropDownMenu_SetWidth(self.ReportingMajorCategoryDropdown, 200);
	UIDropDownMenu_Initialize(self.ReportingMajorCategoryDropdown, ReportingMajorCategoryDropdownInitialize);
	self.ReportingMajorCategoryDropdown:Show(); 
end

function ReportFrameMixin:InitiateReport(reportInfo, playerName, playerLocation) 
	if(not reportInfo) then 
		return;
	end 

	self.reportInfo = reportInfo; 
	self:ReportByType(reportInfo.reportType);
	self.reportPlayerLocation = playerLocation; 
	if(playerName) then 
		self.ReportString:SetText(REPORTING_REPORT_PLAYER:format(playerName));
	end 
	self.ReportString:SetShown(playerName)
	self:Show();

	self.MinorCategoryButtonPool:ReleaseAll();
	self.selectedMajorType = nil; 
	self.Comment:Hide(); 
	self.MinorReportDescription:Hide();
	self:Layout(); 
end		

function ReportFrameMixin:ReportByType(reportType) 
	self:SetupDropdownByReportType(reportType);
end

function ReportFrameMixin:MajorTypeSelected(reportType, majorType)
	local minorCategories = ReportSubCategoriesByTypeAndMajorType[reportType][majorType]; 
	self.selectedMajorType = majorType; 
	if(not minorCategories) then 
		return; 
	end 
	self.lastCategory = nil; 
	self.MinorCategoryButtonPool:ReleaseAll(); 
	for index, minorCategory in ipairs(minorCategories) do 
		self.lastCategory = self:AnchorMinorCategory(index, minorCategory);
	end 
	self.MinorReportDescription:Show(); 
	self.Comment:ClearAllPoints(); 
	self.Comment:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -10);
	self.Comment:Show(); 
	self:Layout(); 
end

function ReportFrameMixin:AnchorMinorCategory(index, minorCategory)
	local minorCategoryButton = self.MinorCategoryButtonPool:Acquire(); 

	if(not self.lastCategory) then 
		minorCategoryButton:SetPoint("TOP", self.MinorReportDescription, "BOTTOM", 0, -3); 
	else 
		minorCategoryButton:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -3);
	end		

	minorCategoryButton:SetupButton(minorCategory);
	return minorCategoryButton;
end 

function ReportFrameMixin:SendReport()
	if(not self.reportInfo) then
		return; 
	end		
	self.reportInfo:SetReportMajorCategory(self.selectedMajorType);
	self.reportInfo:SetMinorCategoryFlags(self.minorCategoryFlags:GetFlags());
	self.reportInfo:SetComment(self.Comment.EditBox:GetText());
	C_ReportSystem.SendReport(self.reportInfo, self.reportPlayerLocation); 
end 

function ReportFrameMixin:SetMinorCategoryFlag(flag, flagValue)
	self.minorCategoryFlags:SetOrClear(flag, flagValue);
end 

ReportingMajorCategoryDropdownMixin = { }; 
function ReportingMajorCategoryDropdownInitialize(self)
	if(not self.reportType) then 
		return; 
	end		
	
	local reportOptions = ReportMajorCategoriesByReportType[self.reportType];
	if(not reportOptions) then 
		return; 
	end
		
	local info = UIDropDownMenu_CreateInfo();
	for _, majorType in ipairs(reportOptions) do 
		local reportText = ReportMajorCategoryStrings[majorType];
		if(reportText) then 
			info.text = reportText; 
			info.value = majorType; 
			info.func = function() self:ValueSelected(self.reportType, majorType); end; 
			UIDropDownMenu_AddButton(info);
		end		
	end
	self.Text:SetJustifyH("LEFT");
	UIDropDownMenu_SetText(self, REPORTING_MAKE_SELECTION);
end

function ReportingMajorCategoryDropdownMixin:ValueSelected(reportType, majorType)
	self:GetParent():MajorTypeSelected(reportType, majorType);
	UIDropDownMenu_SetText(self, ReportMajorCategoryStrings[majorType]);
end	

ReportingFrameMinorCategoryButtonMixin = { };

function ReportingFrameMinorCategoryButtonMixin:SetupButton(minorCategory)
	if(not minorCategory) then 
		return; 
	end 
	self.minorCategory = minorCategory; 
	local categoryName = ReportMinorCategoryStrings[minorCategory];
	if(not categoryName) then 
		return;
	end 

	self.Text:SetText(categoryName);
	self:Show(); 
end

function ReportingFrameMinorCategoryButtonMixin:OnClick()
	if(not self.minorCategory) then 
		return; 
	end 
	self:GetParent():SetMinorCategoryFlag(self.minorCategory, self:GetChecked());
end

ReportButtonMixin = { }; 

function ReportButtonMixin:OnClick()
	self:GetParent():SendReport();
end
	
ReportInfo = { };
function ReportInfo:CreateReportInfoFromType(reportType)
	local reportInfo = CreateFromMixins(ReportInfoMixin);
	reportInfo:SetReportType(reportType);
	return reportInfo; 
end

function ReportInfo:CreateClubFinderReportInfo(reportType, clubFinderGUID)
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetClubFinderGUID(clubFinderGUID);
	return reportInfo; 
end

function ReportInfo:CreatePetReportInfo(reportType, petGUID)
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetPetGUID(petGUID);
	return reportInfo; 
end

function ReportInfo:CreateGroupFinderPostingReportInfo(reportType, postingID)
	if(reportType ~= Enum.ReportType.GroupFinderPosting) then 
		return nil;
	end 

	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetGroupFinderSearchResultID(postingID); 
	return reportInfo;
end

function ReportInfo:CreateGroupFinderApplicantReportInfo(reportType, applicantID)
	if(reportType ~= Enum.ReportType.GroupFinderApplicant) then 
		return nil;
	end 
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetGroupFinderApplicantID(applicantID); 
	return reportInfo; 
end

function ReportInfo:CreateMailReportInfo(reportType, mailIndex)
	if(reportType ~= Enum.ReportType.Mail) then 
		return nil;
	end 
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetMailIndex(mailIndex);
	return reportInfo; 
end

ReportInfoMixin = { }; 
function ReportInfoMixin:Clear()
	self.reportType = nil;
	self.majorCategory = nil;
	self.minorCategoryFlags = nil;
	self.reportTarget = nil;
	self.comment = nil; 
	self.groupFinderSearchResultID = nil;
	self.groupFinderApplicantID = nil;
	self.clubFinderGUID = nil;
	self.mailIndex = nil;
	self.petGUID = nil; 
end

function ReportInfoMixin:SetMailIndex(mailIndex)
	self.mailIndex = mailIndex - 1;
end 

function ReportInfoMixin:SetClubFinderGUID(clubFinderGUID)
	self.clubFinderGUID = clubFinderGUID; 
end		

function ReportInfoMixin:SetReportTarget(reportTarget)
	self.reportTarget = reportTarget; 
end

function ReportInfoMixin:SetComment(comment)
	self.comment = comment; 
end		

function ReportInfoMixin:SetGroupFinderSearchResultID(groupFinderSearchResultID) 
	self.groupFinderSearchResultID = groupFinderSearchResultID
end

function ReportInfoMixin:SetGroupFinderApplicantID(groupFinderApplicantID) 
	self.groupFinderApplicantID = groupFinderApplicantID
end		

function ReportInfoMixin:SetReportType(reportType)
	self.reportType = reportType; 
end

function ReportInfoMixin:SetReportMajorCategory(majorCategory)
	self.majorCategory = majorCategory; 
end

function ReportInfoMixin:SetMinorCategoryFlags(minorCategoryFlags)
	self.minorCategoryFlags = minorCategoryFlags; 
end

function ReportInfoMixin:SetPetGUID(petGUID) 
	self.petGUID = petGUID; 
end		

function ReportInfoMixin:SetBasicReportInfo(reportType, majorCategory, minorCategoryFlags)
	self.majorCategory = majorCategory; 
	self.minorCategoryFlags = minorCategoryFlags; 
end	