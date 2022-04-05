ReportFrameMixin = { };

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
		self:UpdateThankYouMessage(true);
	end		
end	

function ReportFrameMixin:UpdateThankYouMessage(showThankYouMessage)
	self.MinorCategoryButtonPool:ReleaseAll(); 
	self.Comment:SetShown(not showThankYouMessage); 
	self.MinorReportDescription:SetShown(not showThankYouMessage); 
	self.ReportString:SetShown(not showThankYouMessage); 
	self.ReportButton:SetShown(not showThankYouMessage); 
	self.ReportingMajorCategoryDropdown:SetShown(not showThankYouMessage);
	self.ThankYouText:SetShown(showThankYouMessage); 
	self.Watermark:SetShown(showThankYouMessage); 
	self:Layout(); 
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
	self.playerName = playerName; 
	self:UpdateThankYouMessage(false);

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
	local minorCategories = C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory(reportType, majorType); 
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

	if(self.reportInfo.reportType == Enum.ReportType.PvP) then 
		ReportPlayerIsPVPAFK(self.playerName);
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
	
	local reportOptions = C_ReportSystem.GetMajorCategoriesForReportType(self.reportType);
	if(not reportOptions) then 
		return; 
	end
		
	local info = UIDropDownMenu_CreateInfo();
	for _, majorType in ipairs(reportOptions) do 
		local reportText = _G[C_ReportSystem.GetMajorCategoryString(majorType)];
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
	UIDropDownMenu_SetText(self, _G[C_ReportSystem.GetMajorCategoryString(majorType)]);
end	

ReportingFrameMinorCategoryButtonMixin = { };

function ReportingFrameMinorCategoryButtonMixin:SetupButton(minorCategory)
	if(not minorCategory) then 
		return; 
	end 
	self.minorCategory = minorCategory; 
	local categoryName = _G[C_ReportSystem.GetMinorCategoryString(minorCategory)];
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