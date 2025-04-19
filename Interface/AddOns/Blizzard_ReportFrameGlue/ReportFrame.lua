ReportFrameMixin = CreateFromMixins(SharedReportFrameMixin);

--override
function ReportFrameMixin:CanDisplayMinorCategory(minorCategory)
	if (minorCategory == Enum.ReportMinorCategory.BTag and not self.isBnetReport) then
		return false;
	elseif (minorCategory == Enum.ReportMinorCategory.GuildName) then
		return false; --no guilds in Glue
	elseif (minorCategory == Enum.ReportMinorCategory.CharacterName) then
		return false; --only battletags in Glue.
	end
	return true;
end

--override
function ReportFrameMixin:ShouldDisplayTooltip()
	return false;
end

--override
function ReportFrameMixin:ManageButton(button, isActive)
	if (isActive) then
		button:Show();
	else
		button:Hide();
	end
end
