PlayerReportFrameBaseMixin = {}; 

function PlayerReportFrameBaseMixin:OnShow()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function PlayerReportFrameBaseMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	self.CommentBox:SetText("");
end

function PlayerReportFrameBaseMixin:CancelReport()
	StaticPopupSpecial_Hide(self);
end

function PlayerReportFrameBaseMixin:OnLoad()
	self.CommentBox = self.Comment.ScrollFrame.CommentBox;
end

PlayerReportFrameMixin = CreateFromMixins(PlayerReportFrameBaseMixin);

function PlayerReportFrameMixin:OnLoad()
	PlayerReportFrameBaseMixin.OnLoad(self);
	self.exclusive = true;
	self.hideOnEscape = true;
	self:RegisterEvent("OPEN_REPORT_PLAYER");
end

function PlayerReportFrameMixin:OnEvent(event, ...)
	if ( event == "OPEN_REPORT_PLAYER" ) then
		local reportToken, reportType, playerName = ...;
		self:ShowReportDialog(reportToken, reportType, playerName);
	end
end

function PlayerReportFrameMixin:ShowReportDialog(reportToken, reportType, playerName)
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

	self.reportToken = reportToken;

	self.Title:SetText(REPORT_PLAYER_LABEL:format(reportReason));
	self.Name:SetText(playerName);

	StaticPopupSpecial_Show(self);
end

function PlayerReportFrameMixin:ConfirmReport()
	local comments = self.CommentBox:GetText();
	C_ReportSystem.SendReportPlayer(self.reportToken, comments);
	StaticPopupSpecial_Hide(self);
end

ClubFinderReportFrameMixin = CreateFromMixins(PlayerReportFrameBaseMixin);

function ClubFinderReportFrameMixin:ShowReportDialog(reportType, clubGUID, playerGUID, reportInfo)
	if ( self:IsShown() ) then
		StaticPopupSpecial_Hide(self);
	end

	CloseDropDownMenus();

	if (reportType == Enum.ClubFinderPostingReportType.PostersName) then
		self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_POSTERS_NAME));
		self.Name:SetText(reportInfo.guildLeader);
	elseif (reportType == Enum.ClubFinderPostingReportType.ClubName) then 
		if (reportInfo.isGuild) then
			self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_GUILD_NAME));
		else 
			self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_COMMUNITY_NAME));
		end
		self.Name:SetText(reportInfo.name);
	elseif (reportType == Enum.ClubFinderPostingReportType.PostingDescription) then 
		self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_POSTING_DESCRIPTION));
		self.Name:SetText(reportInfo.comment);
	elseif (reportType == Enum.ClubFinderPostingReportType.ApplicantsName) then 
		self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_APPLICANT_NAME));
		self.Name:SetText(reportInfo.name);
	elseif (reportType == Enum.ClubFinderPostingReportType.JoinNote) then 
		self.Title:SetText(CLUB_FINDER_REPORT:format(CLUB_FINDER_REPORT_REASON_APPLICANT_NOTE));
		self.Name:SetText(reportInfo.message);
	end

	self.clubGUID = clubGUID; 
	self.reportType = reportType; 
	self.playerGUID = playerGUID;
	StaticPopupSpecial_Show(self);
end

function ClubFinderReportFrameMixin:ConfirmReport()
	local comments = self.CommentBox:GetText();
	C_ClubFinder.ReportPosting(self.reportType, self.clubGUID, self.playerGUID, comments);
	StaticPopupSpecial_Hide(self);
end