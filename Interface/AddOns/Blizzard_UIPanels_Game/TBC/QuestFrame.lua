
UIPanelWindows["QuestFrame"] = { area = "left", pushable = 0, whileDead = 1 };

function QuestFrame_ShowQuestPortrait(parentFrame, portraitDisplayID, mountPortraitDisplayID, modelSceneID, text, name, x, y)
	QuestModelScene:SetParent(parentFrame);
	QuestModelScene:SetFrameLevel(600);
	QuestModelScene:ClearAllPoints();
	QuestModelScene:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y);
	QuestModelScene:ClearScene();
	QuestModelScene:TransitionToModelSceneID(modelSceneID or QUEST_FRAME_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
	QuestModelScene:Show();
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
		local actor = QuestModelScene:GetPlayerActor("player");
		local sheathWeapons = false;
		actor:SetModelByUnit("player", sheathWeapons);
	else
		local mount, rider;
		local mountTag = "mount";
		local riderTag = "rider";

		if mountPortraitDisplayID > 0 then
			mount = QuestModelScene:GetActorByTag(mountTag);
			mount:SetModelByCreatureDisplayID(mountPortraitDisplayID);
			mountActor:SetAnimation(618);
		else
			-- these is no mount, so use the mount actor as the main actor for the rider
			riderTag = mountTag;
		end

		if portraitDisplayID > 0 then
			rider = QuestModelScene:GetActorByTag(riderTag);
			rider:SetModelByCreatureDisplayID(portraitDisplayID);
			rider:SetAnimation(0);
		end
		if mount and rider then
			local defaultMountAnimation = 91;
			local spellVisualKitID = 0;
			mount:AttachToMount(rider, defaultMountAnimation, spellVisualKitID);
		end
	end
end

function QuestFrame_HideQuestPortrait(optPortraitOwnerCheckFrame)
	optPortraitOwnerCheckFrame = optPortraitOwnerCheckFrame or QuestModelScene:GetParent();
	if optPortraitOwnerCheckFrame == QuestModelScene:GetParent() then
		QuestModelScene:Hide();
		QuestModelScene:SetParent(nil);
	end
end
