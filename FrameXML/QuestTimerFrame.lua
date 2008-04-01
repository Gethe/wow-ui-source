function QuestTimerFrame_OnLoad()
	this:RegisterEvent("QUEST_LOG_UPDATE");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this.numTimers = 0;
	this.updating = nil;
end

function QuestTimerFrame_OnEvent()
	if ( event == "QUEST_LOG_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		if ( not this.updating ) then
			QuestTimerFrame_Update(GetQuestTimers());
		end
	end
end

function QuestTimerFrame_Update(...)
	this.updating = 1;
	this.numTimers = select("#", ...);
	for i=1, this.numTimers, 1 do
		getglobal("QuestTimer"..i.."Text"):SetText(SecondsToTime(select(i, ...)));
		getglobal("QuestTimer"..i):Show();
	end
	for i=this.numTimers + 1, MAX_QUESTS, 1 do
		getglobal("QuestTimer"..i):Hide();
	end
	if ( this.numTimers > 0 ) then
		this:SetHeight(45 + (16 * this.numTimers));
		this:Show();
	else
		this:Hide();
	end
	this.updating = nil;
end

function QuestTimerFrame_OnUpdate()
	if ( this.numTimers > 0 ) then
		QuestTimerFrame_Update(GetQuestTimers());
	end
end

function QuestTimerButton_OnClick()
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(GetQuestIndexForTimer(this:GetID()));
	QuestLog_Update();
end

function QuestTimerFrame_OnShow()
	UIParent_ManageFramePositions();
end

function QuestTimerFrame_OnHide()
	UIParent_ManageFramePositions();
end
