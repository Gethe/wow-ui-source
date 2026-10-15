local AddonName = ...;

TraitUtil.RegisterTraitFrameCallbackByTreeID(1167, function()
	local displayOnly = false;
	ShowScribeUI(displayOnly);
end);

function ScribeUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function CheckLoad()
	if not ScribeFrame then
		ScribeUI_LoadUI();
	end
end

function ToggleScribeUI(displayOnly)
	CheckLoad();
	ScribeFrame:SetDisplayOnly(displayOnly);
	ToggleUIPanel(ScribeFrame);
end

function ShowScribeUI(displayOnly)
	CheckLoad();
	ScribeFrame:SetDisplayOnly(displayOnly);
	ShowUIPanel(ScribeFrame);
end

function IsScribeFromMicroButtonEditable()
	-- If the intro isn't completed, then we never want the Scribe UI to be Display Only
	local WOWHACK_INTRO_COMPLETED_QUEST = 93203;
	return not C_QuestLog.IsQuestFlaggedCompleted(WOWHACK_INTRO_COMPLETED_QUEST);
end
