ReportFrameMixin = CreateFromMixins(SharedReportFrameMixin);

--override
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
			return IsPlayerInGuildFromGUID(reportedPlayer);
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

--override
function ReportFrameMixin:ShouldDisplayTooltip()
	return true;
end

--override
function ReportFrameMixin:ManageButton(button, isActive)
	button:SetEnabled(isActive);
end
