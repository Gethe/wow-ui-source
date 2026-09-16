QuestMapFrameOverrides = {};

function QuestMapFrameOverrides.GetQuestsTabAnchorOffset()
	return 3, -28;
end

-- Returns the text to prepend to a quest log title, or nil for none.
function QuestMapFrameOverrides.GetQuestTitlePrefix(info)
	if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") or CVarCallbackRegistry:GetCVarValueBool("showQuestLevel") then
		return "[" .. info.difficultyLevel .. "] ";
	end

	return nil;
end

-- Quest Tag Text is not displayed for Mainline standard.
function QuestMapFrameOverrides.GetQuestTagText(_info)
	return nil;
end
