CampaignUtil = {};

function CampaignUtil.BuildChapterProgressText(campaign, formatString)
	local chapterCount = campaign:GetChapterCount();
	local completedChapterCount = campaign:GetCompletedChapterCount();

	return (formatString or CAMPAIGN_PROGRESS_CHAPTERS):format(completedChapterCount, chapterCount);
end

function CampaignUtil.GetSingleChapterText(chapterID, lineSpacing)
	local chapter = CampaignChapterCache:Get(chapterID);
	if chapter:IsComplete() then
		return CreateTextureMarkup("Interface/Scenarios/ScenarioIcon-Check", 16, 16, 16, 16, 0, 1, 0, 1, 0, -lineSpacing) .. " " .. GREEN_FONT_COLOR:WrapTextInColorCode(chapter.name);
	else
		local color = chapter:IsInProgress() and HIGHLIGHT_FONT_COLOR or LIGHTGRAY_FONT_COLOR;
		return color:WrapTextInColorCode(chapter.name);
	end
end

function CampaignUtil.BuildAllChaptersText(campaign, lineSpacing)
	local chapterText = {};
	for index, chapterID in ipairs(campaign.chapterIDs) do
		table.insert(chapterText, CampaignUtil.GetSingleChapterText(chapterID, lineSpacing));
	end

	return table.concat(chapterText, "\n");
end