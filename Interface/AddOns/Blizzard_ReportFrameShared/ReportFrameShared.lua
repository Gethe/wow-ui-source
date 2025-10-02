SharedReportFrameMixin = { };

function SharedReportFrameMixin:OnLoad()
	NineSliceUtil.ApplyLayoutByName(self.Border, "Dialog");
	self.minorCategoryFlags = CreateFromMixins(FlagsMixin);
	self.minorCategoryFlags:OnLoad();
	self.selectedMajorType = nil;
	self.MinorCategoryButtonPool = CreateFramePool("CHECKBUTTON", self, "ReportingFrameMinorCategoryButtonTemplate");
	self:RegisterEvent("REPORT_PLAYER_RESULT");
	self:RegisterEvent("REPORT_SCREENSHOT_READY");

	self.ScreenshotReportingFrame.TakeScreenshotButton:SetScript("OnClick", GenerateClosure(self.OnTakeScreenshotClicked, self));

	self.ReportingMajorCategoryDropdown:SetWidth(200);
	self.ReportingMajorCategoryDropdown:SetDefaultText(REPORTING_MAKE_SELECTION);
end

function SharedReportFrameMixin:OnHide()
	if not self.enteringScreenshotMode then 
		self:Reset();
	end
end

function SharedReportFrameMixin:OnTakeScreenshotClicked()
	self.enteringScreenshotMode = true;
	ReportScreenshotModeFrame:Show();
end

function SharedReportFrameMixin:OnEvent(event, ...)
	if(event == "REPORT_PLAYER_RESULT") then
		self:UpdateThankYouMessage(true);
	elseif(event == "REPORT_SCREENSHOT_READY") then
		self.hasScreenshot = true;
		self.ScreenshotReportingFrame.ScreenshotEmptyText:Hide();
		self.ReportButton:UpdateButtonState();
		C_ReportSystem.SetScreenshotPreviewTexture(self.ScreenshotReportingFrame.ScreenshotPreview);
	end
end

function SharedReportFrameMixin:Reset()
	self.MinorCategoryButtonPool:ReleaseAll();
	self.selectedMajorType = nil;
	self.Comment:ClearAllPoints();
	self.ScreenshotReportingFrame.ScreenshotPreview:SetAtlas("UI-Frame-DialogBox-BackgroundTile");
	self.ScreenshotReportingFrame.ScreenshotEmptyText:Show();
	self.ScreenshotReportingFrame:ClearAllPoints();
	self.ScreenshotReportingFrame:Hide();
	self.hasScreenshot = nil;
	self.reporPlayerLocation = nil;
	self.reportInfo = nil;
	self.minorCategoryFlags:ClearAll();
	self.Comment.EditBox:SetText("");
	self:Layout();
end

function SharedReportFrameMixin:UpdateThankYouMessage(showThankYouMessage)
	self.MinorCategoryButtonPool:ReleaseAll();
	self.ScreenshotReportingFrame:SetShown(not showThankYouMessage);
	self.Comment:SetShown(not showThankYouMessage);
	self.MinorReportDescription:SetShown(not showThankYouMessage);
	self.ReportString:SetShown(not showThankYouMessage);
	self.ReportButton:SetShown(not showThankYouMessage);
	self.ReportingMajorCategoryDropdown:SetShown(not showThankYouMessage);
	self.ThankYouText:SetShown(showThankYouMessage);
	self.Watermark:SetShown(showThankYouMessage);
	self:Layout();
end

function SharedReportFrameMixin:SetupDropdownByReportType(reportType)
	local function IsChecked(majorType)
		return self.selectedMajorType == majorType;
	end

	local function SetChecked(majorType)
		self:MajorTypeSelected(reportType, majorType);
	end

	self.ReportingMajorCategoryDropdown:SetupMenu(function(dropdown, rootDescription)
		local majorCategories = C_ReportSystem.GetMajorCategoriesForReportType(reportType);
		for index_, majorType in ipairs(majorCategories) do
			local text = _G[C_ReportSystem.GetMajorCategoryString(majorType)];
			if text then
				rootDescription:CreateRadio(text, IsChecked, SetChecked, majorType);
			end
		end
	end);

	self.ReportingMajorCategoryDropdown:Show();
end

function SharedReportFrameMixin:InitiateReport(reportInfo, playerName, playerLocation, isBnetReport)
	self:SetAttribute("initiate_report", {
		reportInfo = reportInfo,
		playerName = playerName,
		playerLocation = playerLocation,
		isBnetReport = isBnetReport,
	});
end

function SharedReportFrameMixin:UpdateHarmfulToMinorsMinorCategoryEnabled()
	if (self.reportHarmfulToMinorsCategory and self.selectedMajorType == Enum.ReportMajorCategory.InappropriateName) then
		local minorFlags = self.minorCategoryFlags:GetFlags();
		local shouldEnable = bit.band(minorFlags, bit.bnot(Enum.ReportMinorCategory.HarmfulToMinors)) ~= 0;
		self.reportHarmfulToMinorsCategory:SetMinorCategoryEnabled(shouldEnable);
	end
end

function SharedReportFrameMixin:InitiateReportInternal(reportInfo, playerName, playerLocation, isBnetReport)
	if(not reportInfo) then
		return;
	end

	self.reportInfo = reportInfo;
	self:ReportByType(reportInfo.reportType);
	self.reportPlayerLocation = playerLocation;
	self.playerName = playerName;
	self:UpdateThankYouMessage(false);

	self.isBnetReport = isBnetReport;
	self:Show();

	if(playerName) then
		if (reportInfo.reportType == Enum.ReportType.HousingDecor) then
			self.ReportString:SetText(REPORTING_REPORT_PLAYER_HOUSE:format(playerName));
		else
			self.ReportString:SetText(REPORTING_REPORT_PLAYER:format(playerName));
		end
	end
	self.ReportString:SetShown(playerName)
	self.MinorCategoryButtonPool:ReleaseAll();
	self.selectedMajorType = nil;
	self.ScreenshotReportingFrame:Hide();
	self.Comment:Hide();
	self.MinorReportDescription:Hide();
	self.ReportButton:UpdateButtonState();
	self:UpdateHarmfulToMinorsMinorCategoryEnabled();
	self:Layout();
end

function SharedReportFrameMixin:ReportByType(reportType)
	self:SetupDropdownByReportType(reportType);
end

--virtual
function SharedReportFrameMixin:CanDisplayMinorCategory(minorCategory) end

--virtual
function SharedReportFrameMixin:ShouldDisplayTooltip() end

--virtual
function SharedReportFrameMixin:ManageButton(button, isActive) end

function SharedReportFrameMixin:MajorTypeSelected(reportType, majorType)
	local minorCategories = C_ReportSystem.GetMinorCategoriesForReportTypeAndMajorCategory(reportType, majorType);
	self.selectedMajorType = majorType;
	self.minorCategoryFlags:ClearAll();
	self.requiresScreenshot = C_ReportSystem.RequiresScreenshotForReportType(reportType);
	if(not minorCategories and not self.requiresScreenshot) then
		return;
	end
	self.lastCategory = nil;
	self.reportHarmfulToMinorsCategory = nil;
	self.MinorCategoryButtonPool:ReleaseAll();
	for index, minorCategory in ipairs(minorCategories) do
		if (self:CanDisplayMinorCategory(minorCategory)) then
			self.lastCategory = self:AnchorMinorCategory(index, minorCategory);

			if (majorType == Enum.ReportMajorCategory.InappropriateName and minorCategory == Enum.ReportMinorCategory.HarmfulToMinors) then
				self.reportHarmfulToMinorsCategory = self.lastCategory;
				self.reportHarmfulToMinorsCategory.disabledTooltipText = HARMFUL_TO_MINORS_DISABLED_TOOLTIP;
				self.reportHarmfulToMinorsCategory:SetMinorCategoryEnabled(false);
			end
		end
	end
	if(self.lastCategory) then
		self.MinorReportDescription:Show();
	end
	if(self.requiresScreenshot) then
		self.ScreenshotReportingFrame:ClearAllPoints();
		if(not self.lastCategory) then
			self.ScreenshotReportingFrame:SetPoint("TOP", self.MinorReportDescription, "TOP", 0, -3);
		else
			self.ScreenshotReportingFrame:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -3);
		end
		self.ScreenshotReportingFrame:Show();
		self.lastCategory = self.ScreenshotReportingFrame;
	end
	self.Comment:ClearAllPoints();
	self.Comment:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -10);
	self.Comment:Show();
	self.ReportButton:UpdateButtonState();
	self:UpdateHarmfulToMinorsMinorCategoryEnabled();
	self:Layout();
end

function SharedReportFrameMixin:SetMajorType(type)
	self.selectedMajorType = type;
end

function SharedReportFrameMixin:AnchorMinorCategory(index, minorCategory)
	local minorCategoryButton = self.MinorCategoryButtonPool:Acquire();

	if(not self.lastCategory) then
		minorCategoryButton:SetPoint("TOP", self.MinorReportDescription, "BOTTOM", 0, -3);
	else
		minorCategoryButton:SetPoint("TOP", self.lastCategory, "BOTTOM", 0, -3);
	end

	minorCategoryButton:SetupButton(minorCategory);
	return minorCategoryButton;
end

function SharedReportFrameMixin:SendReport()
	if(not self.reportInfo) then
		return;
	end

	if(self.reportInfo.reportType == Enum.ReportType.PvP) then
		ReportPlayerIsPVPAFK(self.playerName);
		self:UpdateThankYouMessage(true);
		return;
	end

	self.reportInfo:SetReportMajorCategory(self.selectedMajorType);
	self.reportInfo:SetMinorCategoryFlags(self.minorCategoryFlags:GetFlags());
	self.reportInfo:SetComment(self.Comment.EditBox:GetText());

	C_ReportSystem.SendReport(self.reportInfo, self.reportPlayerLocation);
end

function SharedReportFrameMixin:SetMinorCategoryFlag(flag, flagValue)
	self.minorCategoryFlags:SetOrClear(flag, flagValue);
end

ScreenshotModeFrameMixin = {};

function ScreenshotModeFrameMixin:OnShow()
	SetAlternateTopLevelParent(self);
	UIParent:Hide();
end

function ScreenshotModeFrameMixin:OnHide()
	ClearAlternateTopLevelParent();
	UIParent:Show();
	ReportFrame.enteringScreenshotMode = false;
end

function ScreenshotModeFrameMixin:OnMouseUp(button)
	if ( button == "LeftButton" ) then
		PlaySound(SOUNDKIT.REPORT_SCREENSHOT_CAMERA);
		if C_Housing.ValidateReportScreenshot(ReportFrame.reportInfo.plotIndex) then
			C_ReportSystem.TakeReportScreenshot();
		else
			-- TODO: Display error
		end
		self:Hide();
	end
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
	self:SetEnabled(true);
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	self:SetAlpha(1.0);

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
	parent:UpdateHarmfulToMinorsMinorCategoryEnabled();
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function ReportingFrameMinorCategoryButtonMixin:OnEnter()
	if self:IsEnabled() then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddErrorLine(GameTooltip, self.disabledTooltipText);
	GameTooltip:Show();
end

function ReportingFrameMinorCategoryButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ReportingFrameMinorCategoryButtonMixin:SetMinorCategoryEnabled(enabled)
	self:SetEnabled(enabled);

	local alpha = enabled and 1.0 or 0.75;
	self:SetAlpha(alpha);

	local color = enabled and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
	self.Text:SetTextColor(color:GetRGB());


	if (not enabled) then
		self:SetChecked(false);
	end

	local parent = self:GetParent();
	parent:SetMinorCategoryFlag(self.minorCategory, self:GetChecked());
	parent.ReportButton:UpdateButtonState();
end

ReportButtonMixin = { };
function ReportButtonMixin:OnClick()
	self:GetParent():SendReport();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function ReportButtonMixin:UpdateButtonState()
	local parent = self:GetParent();
	local buttonActive = (parent.requiresScreenshot and parent.hasScreenshot) or (parent.selectedMajorType and parent.minorCategoryFlags:IsAnySet());
	parent:ManageButton(self, buttonActive);
end

function ReportButtonMixin:OnEnter()
	if(self:IsEnabled()) then
		return;
	end

	if (self:GetParent():ShouldDisplayTooltip()) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, REPORTING_MAKE_SELECTION);
		GameTooltip:Show();
	end
end

function ReportButtonMixin:OnLeave()
	if (self:GetParent():ShouldDisplayTooltip()) then
		GameTooltip:Hide();
	end
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

function ReportInfo:CreateCraftingOrderReportInfo(reportType, craftingOrderID)
	if(reportType ~= Enum.ReportType.CraftingOrder) then
		return nil;
	end
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetCraftingOrderID(craftingOrderID);
	return reportInfo;
end

function ReportInfo:CreateNeighborhoodReportInfo(reportType)
	local reportInfo = self:CreateReportInfoFromType(reportType);
	return reportInfo;
end

function ReportInfo:CreateDecorReportInfo(reportType, plotIndex)
	local reportInfo = self:CreateReportInfoFromType(reportType);
	reportInfo:SetPlotIndex(plotIndex);
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
	self.neighborhoodGUID = nil;
	self.plotIndex = nil;
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

function ReportInfoMixin:SetReportedChatInline()
	self.reportedChatInline = true;
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

function ReportInfoMixin:SetCraftingOrderID(craftingOrderID)
	self.craftingOrderID = craftingOrderID;
end

function ReportInfoMixin:SetPlotIndex(plotIndex)
	self.plotIndex = plotIndex;
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

	function SharedReportFrameMixin:OnAttributeChanged(attribute, data)
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
			self:InitiateReportInternal(reportInfo, playerName, playerLocation, isBnetReport);
		end
	end
end
