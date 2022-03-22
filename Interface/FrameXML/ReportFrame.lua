ReportFrameMixin = { };

local ReportMajorCategoriesByReportType = { 
	[Enum.ReportType.Chat] = {
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.InWorld] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName, 
		Enum.ReportMajorCategory.Cheating,
		Enum.ReportMajorCategory.GameplaySabotage 
	},
	[Enum.ReportType.ClubFinder] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName
	},
	[Enum.ReportType.GroupFinder] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.ClubMember] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
	[Enum.ReportType.GroupMember] = {
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName,
		Enum.ReportMajorCategory.Cheating,
		Enum.ReportMajorCategory.GameplaySabotage 
	},
	[Enum.ReportType.Friend] = { 
		Enum.ReportMajorCategory.InappropriateCommunication,
		Enum.ReportMajorCategory.InappropriateName 
	},
}

local ReportSubCategoriesByTypeAndMajorType = {
	[Enum.ReportType.Chat] = {  
		[Enum.ReportMajorCategory.InappropriateCommunication] = {
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Spam,
			Enum.ReportMinorCategory.Advirtisement,
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
		},
	},
	[Enum.ReportType.InWorld] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.Cheating] = 
		{
			Enum.ReportMinorCategory.Afk,
			Enum.ReportMinorCategory.Hacking,
			Enum.ReportMinorCategory.Botting,
		},
		[Enum.ReportMajorCategory.GameplaySabotage] = 
		{
			Enum.ReportMinorCategory.Afk,
			Enum.ReportMinorCategory.Hacking,
			Enum.ReportMinorCategory.IntentionallyFeeding,
		},
	},
	[Enum.ReportType.ClubFinder] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Boosting,
			Enum.ReportMinorCategory.Spam,
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.GroupName,
			Enum.ReportMinorCategory.Inaproppriate,
		},
	},
	[Enum.ReportType.GroupFinder] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.Boosting,
			Enum.ReportMinorCategory.Spam,
			Enum.ReportMinorCategory.Advertisement,
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.GroupName,
			Enum.ReportMinorCategory.Inaproppriate,
		},
	},
	[Enum.ReportType.ClubMember] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
			Enum.ReportMinorCategory.Spam, 
			Enum.ReportMinorCategory.Advertisement,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Inaproppriate,
		},
	},
	[Enum.ReportType.GroupMember] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
			Enum.ReportMinorCategory.Spam,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Inaproppriate,
		},
		[Enum.ReportMajorCategory.Cheating] = 
		{
			Enum.ReportMinorCategory.Afk,
			Enum.ReportMinorCategory.Hacking,
			Enum.ReportMinorCategory.Botting,
		},
		[Enum.ReportMajorCategory.GameplaySabotage] = 
		{
			Enum.ReportMinorCategory.Afk,
			Enum.ReportMinorCategory.Hacking,
			Enum.ReportMinorCategory.IntentionallyFeeding,
			Enum.ReportMinorCategory.BlockingProgress, 
		},
	},
	[Enum.ReportType.Friend] = {
		[Enum.ReportMajorCategory.InappropriateCommunication] = 
		{
			Enum.ReportMinorCategory.TextChat,
			Enum.ReportMinorCategory.Inaproppriate,
			Enum.ReportMinorCategory.Spam,
		},
		[Enum.ReportMajorCategory.InappropriateName] = 
		{
			Enum.ReportMinorCategory.Inaproppriate,
			Enum.ReportMinorCategory.BTag,
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
	[Enum.ReportMinorCategory.Afk] = REPORTING_MINOR_CATEGORY_AFK,
	[Enum.ReportMinorCategory.Hacking] = REPORTING_MINOR_CATEGORY_HACKING,
	[Enum.ReportMinorCategory.Inaproppriate] = REPORTING_MINOR_CATEGORY_INAPPROPRIATE,
	[Enum.ReportMinorCategory.BTag] = REPORTING_MINOR_CATEGORY_BTAG,
	[Enum.ReportMinorCategory.VoiceChat] = REPORTING_MINOR_CATEGORY_VOICE_CHAT,
	[Enum.ReportMinorCategory.Spam] = REPORTING_MINOR_CATEGORY_SPAM,
	[Enum.ReportMinorCategory.BlockingProgress] = REPORTING_MINOR_CATEGORY_BLOCKING_PROG,
	[Enum.ReportMinorCategory.IntentionallyFeeding] = REPORTING_MINOR_CATEGORY_FEEDING,
	[Enum.ReportMinorCategory.Botting] = REPORTING_MINOR_CATEGORY_BOTTING,
	[Enum.ReportMinorCategory.Advertisement] = REPORTING_MINOR_CATEGORY_ADVERTISEMENT,
	[Enum.ReportMinorCategory.GroupName] = REPORTING_MINOR_CATEGORY_GROUP_NAME,
	[Enum.ReportMinorCategory.Boosting] = REPORTING_MINOR_CATEGORY_BOOSTING,
	[Enum.ReportMinorCategory.CustomGameName] = REPORTING_MINOR_CATEGORY_CUSTOM_GAME_NAME,

}

function ReportFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
	self.MinorCategoryButtonPool = CreateFramePool("BUTTON", self, "ReportingFrameMinorCategoryButtonTemplate", FramePool_HideAndClearAnchors);
end		

function ReportFrameMixin:SetupDropdownByReportType(reportType)
	self.ReportingMajorCategoryDropdown.reportType = reportType; 
	UIDropDownMenu_SetWidth(self.ReportingMajorCategoryDropdown, 200);
	UIDropDownMenu_Initialize(self.ReportingMajorCategoryDropdown, ReportingMajorCategoryDropdownInitialize);
	self.ReportingMajorCategoryDropdown:Show(); 
end

function ReportFrameMixin:InitiateReportOfType(reportType, playerName) 
	if(not reportType or not playerName) then 
		return;
	end 

	self:ReportByType(reportType);
	self.ReportString:SetText(REPORTING_REPORT_PLAYER:format(playerName));
	ShowUIPanel(ReportFrame);
end		

function ReportFrameMixin:ReportByType(reportType) 
	self:SetupDropdownByReportType(reportType);
end

function ReportFrameMixin:MajorTypeSelected(reportType, majorType)
	local minorCategories = ReportSubCategoriesByTypeAndMajorType[reportType][majorType]; 
	if(not minorCategories) then 
		return; 
	end 
	self.lastCategory = nil; 
	self.MinorCategoryButtonPool:ReleaseAll(); 
	for index, minorCategory in ipairs(minorCategories) do 
		self.lastCategory = self:AnchorMinorCategory(index, minorCategory);
	end 
	self.MinorReportDescription:Show(); 
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

ReportingFrameMinorCategoryButtonMixin = { }

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