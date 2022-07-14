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
	self.Comment.EditBox:SetText("");
	self:Layout(); 
	Enable_BagButtons();
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



function ReportFrameMixin:InitiateReport(reportInfo, playerName, playerLocation, isBnetReport, sendReportWithoutDialog)
	self:SetAttribute("initiate_report", {
		reportInfo = reportInfo,
		playerName = playerName,
		playerLocation = playerLocation,
		isBnetReport = isBnetReport,
		sendReportWithoutDialog = sendReportWithoutDialog,
	});
end

function ReportFrameMixin:InitiateReportInternal(reportInfo, playerName, playerLocation, isBnetReport, sendReportWithoutDialog) 	
	if(not reportInfo) then 
		return;
	end 

	self.reportInfo = reportInfo; 
	self:ReportByType(reportInfo.reportType);
	self.reportPlayerLocation = playerLocation; 
	self.playerName = playerName; 
	self:UpdateThankYouMessage(false);
	
	self.isBnetReport = isBnetReport; 
	self:SetShown(not sendReportWithoutDialog);
	if (sendReportWithoutDialog) then 
		self:SendReport(); 
		return; 
	end

	if(playerName) then 
		self.ReportString:SetText(REPORTING_REPORT_PLAYER:format(playerName));
	end 
	self.ReportString:SetShown(playerName)
	self.MinorCategoryButtonPool:ReleaseAll();
	self.selectedMajorType = nil; 
	self.Comment:Hide(); 
	self.MinorReportDescription:Hide();
	self.ReportButton:UpdateButtonState(); 
	self:Layout(); 
	Disable_BagButtons(); 
end		

function ReportFrameMixin:ReportByType(reportType) 
	self:SetupDropdownByReportType(reportType);
end

function ReportFrameMixin:CanDisplayMinorCategory(minorCategory) 
	if (minorCategory == Enum.ReportMinorCategory.BTag and not self.isBnetReport) then 
		return false; 
	elseif (minorCategory == Enum.ReportMinorCategory.GuildName) then 
		if(self.reportInfo.clubFinderGUID) then 
			local clubFinderType = C_ClubFinder.GetClubTypeFromFinderGUID(self.reportInfo.clubFinderGUID);
			return clubFinderType and clubFinderType == Enum.ClubFinderRequestType.Guild;
		else 
			local playerLocationGUID =  self.reportPlayerLocation and self.reportPlayerLocation:GetGUID() or nil;
			local reportedPlayer = playerLocationGUID and playerLocationGUID or self.reportInfo.reportTarget; 
			return C_PlayerInfo.IsPlayerInGuildFromGUID(reportedPlayer);
		end 
	elseif (self.reportInfo.reportType == Enum.ReportType.ClubFinderPosting and minorCategory == Enum.ReportMinorCategory.Name) then 
		if (self.reportInfo.clubFinderGUID) then 
			local clubFinderType = C_ClubFinder.GetClubTypeFromFinderGUID(self.reportInfo.clubFinderGUID);
			return clubFinderType and clubFinderType == Enum.ClubFinderRequestType.Community;
		else 
			return false; 
		end
	end		
	return true; 
end

function ReportFrameMixin:MajorTypeSelected(reportType, majorType)
	local minorCategories = C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory(reportType, majorType); 
	self.selectedMajorType = majorType; 
	self.minorCategoryFlags:ClearAll();
	if(not minorCategories) then 
		return; 
	end 
	self.lastCategory = nil; 
	self.MinorCategoryButtonPool:ReleaseAll(); 
	for index, minorCategory in ipairs(minorCategories) do 
		if (self:CanDisplayMinorCategory(minorCategory)) then 
			self.lastCategory = self:AnchorMinorCategory(index, minorCategory);
		end
	end 
	self.MinorReportDescription:Show(); 
	self.Comment:ClearAllPoints(); 
	self.Comment:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -10);
	self.Comment:Show(); 
	self.ReportButton:UpdateButtonState(); 
	self:Layout(); 
end

function ReportFrameMixin:SetMajorType(type)
	self.selectedMajorType = type; 
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
	local selectedMajorType = self:GetParent().selectedMajorType; 
	for _, majorType in ipairs(reportOptions) do 
		local reportText = _G[C_ReportSystem.GetMajorCategoryString(majorType)];
		if(reportText) then 
			info.text = reportText; 
			info.value = majorType; 
			info.func = function() self:ValueSelected(self.reportType, majorType); end; 
			info.checked = function() return selectedMajorType == majorType; end; 
			UIDropDownMenu_AddButton(info);
		end		
	end
	self.Text:SetJustifyH("LEFT"); 
	if (selectedMajorType) then 
		local selectedText = _G[C_ReportSystem.GetMajorCategoryString(selectedMajorType)];
		UIDropDownMenu_SetText(self, selectedText);
	else 
		UIDropDownMenu_SetText(self, REPORTING_MAKE_SELECTION);
	end 
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

	self:SetChecked(false);
	self.Text:SetText(categoryName);
	self:Show(); 
end

function ReportingFrameMinorCategoryButtonMixin:OnClick()
	if(not self.minorCategory) then 
		return; 
	end 
	self:GetParent():SetMinorCategoryFlag(self.minorCategory, self:GetChecked());
	local parent = self:GetParent(); 
	parent.ReportButton:UpdateButtonState(); 
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

ReportButtonMixin = { }; 
function ReportButtonMixin:OnClick()
	self:GetParent():SendReport();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function ReportButtonMixin:UpdateButtonState()
	local parent = self:GetParent(); 	
	self:SetEnabled(parent.selectedMajorType and parent.minorCategoryFlags:IsAnySet());
end 

function ReportButtonMixin:OnEnter()
	if(self:IsEnabled()) then 
		return;
	end 

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddErrorLine(GameTooltip, REPORTING_MAKE_SELECTION); 
	GameTooltip:Show(); 
end

function ReportButtonMixin:OnLeave()
	GameTooltip:Hide();
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

do
	local securecallfunction = securecallfunction;
	local type = type;
	local pairs = pairs;
	local Mixin = Mixin;
	local ReportInfoMixin = ReportInfoMixin;
	local PlayerLocationMixin = PlayerLocationMixin;

	local function EnumerateTaintedKeysTable(attributeTable)
		local pairsIterator, enumerateTable, initialIteratorKey = securecallfunction(pairs, attributeTable);
		local function IteratorFunction(tbl, key)
			return securecallfunction(pairsIterator, tbl, key);
		end

		return IteratorFunction, enumerateTable, initialIteratorKey;
	end

	local SanitizableTypeSet = {
		["string"] = true,
		["number"] = true,
		["boolean"] = true,
	};

	local function CopyTableWithCleanedPairs(attributeTable, shouldRecurse)
		local cleanedTable = {};
		for key, value in EnumerateTaintedKeysTable(attributeTable) do
			if type(key) == "string" then
				local valueType = type(value);
				if SanitizableTypeSet[valueType] then
					cleanedTable[key] = value;
				elseif shouldRecurse and (valueType == "table") then
					local shouldSubRecurse = false;
					cleanedTable[key] = CopyTableWithCleanedPairs(value, shouldSubRecurse);
				end
			end
		end

		return cleanedTable;
	end

	function ReportFrameMixin:OnAttributeChanged(attribute, data)
		if (attribute == "initiate_report") then
			local shouldRecurse = true;
			data = CopyTableWithCleanedPairs(data, shouldRecurse);

			if (not data.reportInfo) then
				return;
			end

			local reportInfo = Mixin(data.reportInfo, ReportInfoMixin);
			local playerName = data.playerName;
			local playerLocation = data.playerLocation and Mixin(data.playerLocation, PlayerLocationMixin) or nil;
			local isBnetReport = data.isBnetReport;
			local sendReportWithoutDialog = data.sendReportWithoutDialog;
			self:InitiateReportInternal(reportInfo, playerName, playerLocation, isBnetReport, sendReportWithoutDialog);
		end
	end
end