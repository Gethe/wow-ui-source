local FIRST_QUEST_ID = 90882;
local LAST_QUEST_ID = 90911;

StaticPopupDialogs["RPE_ASSISTED_HIGHLIGHT_CHOICE"] = {
	text = RPE_ASSISTED_HIGHLIGHT_TURN_CHOICE,
	button1 = RPE_ASSISTED_HIGHLIGHT_TURN_OFF,
	button2 = RPE_ASSISTED_HIGHLIGHT_KEEP_ON,
	OnAccept = function()
		SetCVar("assistedCombatHighlight", false);
		SetCVar("assistedCombatHighlightRPE", false);
	end,
	OnCancel = function()
		SetCVar("assistedCombatHighlightRPE", false);
	end,
	timeout = 0,
	whileDead = 1,
	wide = 1,
}

function AddAssistedHighlightTutorials()
	if not TutorialManager:GetWatcher("AssistedHighlight_RPE_Watcher") then
		if C_PlayerInfo.IsPlayerInRPE() then
			TutorialManager:AddWatcher(Class_AssistedHighlight_RPE_Watcher:new(), true);
			if GetCVarBool("assistedCombatHighlightRPE") and C_QuestLog.IsOnQuest(LAST_QUEST_ID) then
				StaticPopup_Show("RPE_ASSISTED_HIGHLIGHT_CHOICE");
			end	
		else
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
				AddAssistedHighlightTutorials();
			end, Class_AssistedHighlight_RPE_Watcher);
		end
	else
		-- left the experience, undo cvars that were forced on
		if GetCVarBool("assistedCombatHighlightRPE") then
			SetCVar("assistedCombatHighlight", false);
			SetCVar("assistedCombatHighlightRPE", false);
		end
		StaticPopup_Hide("RPE_ASSISTED_HIGHLIGHT_CHOICE");
	end
end

Class_AssistedHighlight_RPE_Watcher = class("AssistedHighlight_RPE_Watcher", Class_TutorialBase);

function Class_AssistedHighlight_RPE_Watcher:StartWatching()
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_IN_COMBAT_CHANGED", self.OnCombatChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("QUEST_ACCEPTED", self.OnQuestAccepted, self);
end

function Class_AssistedHighlight_RPE_Watcher:OnCombatChanged(inCombat)
	if inCombat and C_QuestLog.IsOnQuest(FIRST_QUEST_ID) and not GetCVarBool("assistedCombatHighlight") then
		SetCVar("assistedCombatHighlight", true);
		SetCVar("assistedCombatHighlightRPE", true);
		local highlightFrame = CreateFrame("FRAME", nil, nil, "ActionBarButtonAssistedCombatHighlightTemplate");
		highlightFrame:Show();
		highlightFrame.Flipbook.Anim:Play();
		local content = { text = RPE_ASSISTED_HIGHLIGHT_ACTIVATED, iconFrame = highlightFrame };
		local duration = 10;
		self:ShowScreenTutorial(content, duration);
	end
end

function Class_AssistedHighlight_RPE_Watcher:OnQuestAccepted(questID)
	if questID == LAST_QUEST_ID and GetCVarBool("assistedCombatHighlightRPE") then
		StaticPopup_Show("RPE_ASSISTED_HIGHLIGHT_CHOICE");
	end
end
