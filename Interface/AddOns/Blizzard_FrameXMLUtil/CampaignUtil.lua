CampaignUtil = {};

function CampaignUtil.BuildChapterProgressText(campaign, formatString, canHideChapters, hideChaptersFormatString)
	local chapterCount = campaign:GetChapterCount();
	local completedChapterCount = campaign:GetCompletedChapterCount();

	if canHideChapters and campaign.hideFutureChapters then
		local percentage = 0;
		if chapterCount > 0 then
			percentage = math.floor((completedChapterCount / chapterCount) * 100);
		end
		return (hideChaptersFormatString or formatString or CAMPAIGN_PROGRESS_CHAPTERS_PERCENT):format(percentage);
	else
		return (formatString or CAMPAIGN_PROGRESS_CHAPTERS):format(completedChapterCount, chapterCount);
	end
end

function CampaignUtil.GetSingleChapterText(chapterID, lineSpacing, hideFutureChapters)
	local chapter = CampaignChapterCache:Get(chapterID);
	if chapter:IsComplete() then
		return CreateTextureMarkup("Interface/Scenarios/ScenarioIcon-Check", 16, 16, 16, 16, 0, 1, 0, 1, 0, -lineSpacing) .. " " .. GREEN_FONT_COLOR:WrapTextInColorCode(chapter.name);
	else
		local isInProgress = chapter:IsInProgress();
		if not isInProgress and hideFutureChapters then
			return nil;
		else
			local color = isInProgress and HIGHLIGHT_FONT_COLOR or LIGHTGRAY_FONT_COLOR;
			return color:WrapTextInColorCode(chapter.name);
		end
	end
end

function CampaignUtil.BuildAllChaptersText(campaign, lineSpacing, canHideChapters)
	local hideFutureChapters = canHideChapters and campaign.hideFutureChapters;
	local chapterText = {};
	for index, chapterID in ipairs(campaign.chapterIDs) do
		table.insert(chapterText, CampaignUtil.GetSingleChapterText(chapterID, lineSpacing, hideFutureChapters));
	end

	-- show at least 1 chapter
	if #chapterText == 0 and hideFutureChapters and campaign:GetChapterCount() > 0 then
		local chapterID = campaign.chapterIDs[1];
		table.insert(chapterText, CampaignUtil.GetSingleChapterText(chapterID, lineSpacing));
	end

	return table.concat(chapterText, "\n");
end
