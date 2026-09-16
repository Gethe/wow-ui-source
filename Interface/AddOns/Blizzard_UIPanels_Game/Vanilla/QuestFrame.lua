
UIPanelWindows["QuestFrame"] = { area = "left", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140+12, width = 353, height = 424, whileDead = 1 };

function QuestFrame_ShowQuestPortrait(parentFrame, portraitDisplayID, mountPortraitDisplayID, text, name, x, y)
	QuestNPCModel:SetParent(parentFrame);
	QuestNPCModel:ClearAllPoints();
	QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y);
	QuestNPCModel:Show();
	QuestFrame_UpdatePortraitText(text);

	if (name and name ~= "") then
		QuestNPCModelNameplate:Show();
		QuestNPCModelBlankNameplate:Hide();
		QuestNPCModelNameText:Show();
		QuestNPCModelNameText:SetText(name);
	else
		QuestNPCModelNameplate:Hide();
		QuestNPCModelBlankNameplate:Show();
		QuestNPCModelNameText:Hide();
	end

	if (portraitDisplayID == -1) then
		QuestNPCModel:SetUnit("player");
	else
		QuestNPCModel:SetDisplayInfo(portraitDisplayID, mountPortraitDisplayID);
	end
end

function QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame)
	optPortraitOwnerCheckFrame = optPortraitOwnerCheckFrame or QuestNPCModel:GetParent();
	if optPortraitOwnerCheckFrame == QuestNPCModel:GetParent() then
		QuestNPCModel:Hide();
		QuestNPCModel:SetParent(nil);
	end
end
