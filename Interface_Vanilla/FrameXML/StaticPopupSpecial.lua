PlayerReportFrameMixin = {};

function PlayerReportFrameMixin:OnLoad()
	self.CommentBox = self.Comment.ScrollFrame.CommentBox;
	self.exclusive = true;
	self.hideOnEscape = true;
end

function PlayerReportFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function PlayerReportFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function PlayerReportFrameMixin:InitiateReport(reportType, playerName, playerLocation)
	if ( self:IsShown() ) then
		StaticPopupSpecial_Hide(self);
	end
	CloseDropDownMenus();

	local reportReason;
	if reportType == PLAYER_REPORT_TYPE_SPAM then
		reportReason = REPORT_SPAMMING;
	elseif reportType == PLAYER_REPORT_TYPE_LANGUAGE then
		reportReason = REPORT_BAD_LANGUAGE;
	elseif reportType == PLAYER_REPORT_TYPE_ABUSE then
		reportReason = REPORT_ABUSE;
	elseif reportType == PLAYER_REPORT_TYPE_BAD_PLAYER_NAME then
		reportReason = REPORT_BAD_NAME;
	elseif reportType == PLAYER_REPORT_TYPE_BAD_GUILD_NAME then
		reportReason = REPORT_BAD_GUILD_NAME;
	elseif reportType == PLAYER_REPORT_TYPE_BAD_BATTLEPET_NAME or reportType == PLAYER_REPORT_TYPE_BAD_PET_NAME then
		reportReason = REPORT_PET_NAME;
	elseif reportType == PLAYER_REPORT_TYPE_CHEATING then
		reportReason = REPORT_CHEATING;
	else
		error("Unsupported report type");
		return;
	end

	self.reportType = reportType;
	self.playerLocation = playerLocation;

	self.Title:SetText(REPORT_PLAYER_LABEL:format(reportReason));
	self.Name:SetText(playerName);

	StaticPopupSpecial_Show(self);
end

function PlayerReportFrameMixin:ConfirmReport()
	local comments = self.CommentBox:GetText();
	if self.playerLocation and self.playerLocation:IsValid() then 
		C_ChatInfo.ReportPlayer(self.reportType, self.playerLocation, comments);
	else
		C_ChatInfo.ReportPlayer(self.reportType, nil, comments);
	end
	StaticPopupSpecial_Hide(self);
end

function PlayerReportFrameMixin:CancelReport()
	StaticPopupSpecial_Hide(self);
end
