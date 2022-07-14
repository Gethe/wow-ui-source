
FRAMERATE_FREQUENCY = 0.25;
local TUTORIAL_TIMER_CLOSE_TO_QUEST = 0;
local TUTORIAL_TIMER_FIRST_QUEST_COMPLETE = 20;

function ToggleFramerate(benchmark)
	FramerateText.benchmark = benchmark;
	if ( FramerateText:IsShown() ) then
		FramerateLabel:Hide();
		FramerateText:Hide();
	else
		FramerateLabel:Show();
		FramerateText:Show();
	end
	WorldFrame.fpsTime = 0;
end

function WorldFrame_OnLoad(self)
	self:IgnoreDepth(true);
	TUTORIAL_TIMER_CLOSE_TO_QUEST = 0;
	TUTORIAL_TIMER_FIRST_QUEST_COMPLETE = 10;
end

function WorldFrame_OnUpdate(self, elapsed)
	if ( FramerateText:IsShown() ) then
		local timeLeft = self.fpsTime - elapsed
		if ( timeLeft <= 0 ) then
			self.fpsTime = FRAMERATE_FREQUENCY;
			local framerate = GetFramerate();
			FramerateText:SetFormattedText("%.1f", framerate);
		else
			self.fpsTime = timeLeft;
		end
	end
	-- Process dialog onUpdates if the map is up or the ui is hidden
	local dialog;
	for i = 1, STATICPOPUP_NUMDIALOGS, 1 do
		dialog = _G["StaticPopup"..i];
		if ( dialog and dialog:IsShown() and not dialog:IsVisible() ) then
			StaticPopup_OnUpdate(dialog, elapsed);
		end
	end

	-- Process breathbar onUpdates if the map is up or the ui is hidden
	local bar;
	for i=1, MIRRORTIMER_NUMTIMERS do
		bar = _G["MirrorTimer"..i];
		if ( bar and bar:IsShown() and not bar:IsVisible() ) then
			MirrorTimerFrame_OnUpdate(bar, elapsed);
		end
	end

	-- Process item translation onUpdates if the map is up or the ui is hidden
	if ( ItemTextFrame:IsShown() and not ItemTextFrame:IsVisible() ) then
		ItemTextFrame_OnUpdate(elapsed);
	end

	-- Process time manager alarm onUpdates in order to allow the alarm to go off without the clock
	-- being visible
	if ( TimeManagerClockButton and not TimeManagerClockButton:IsVisible() and TimeManager_ShouldCheckAlarm() ) then
		TimeManager_CheckAlarm(elapsed);
	end
	if ( StopwatchTicker and not StopwatchTicker:IsVisible() and Stopwatch_IsPlaying() ) then
		StopwatchTicker_OnUpdate(StopwatchTicker, elapsed);
	end

	-- need to do some polling for a few tutorials
	if ( not IsTutorialFlagged(4) and IsTutorialFlagged(10) and not IsTutorialFlagged(55) and TUTORIAL_QUEST_TO_WATCH ) then
		TUTORIAL_TIMER_CLOSE_TO_QUEST = TUTORIAL_TIMER_CLOSE_TO_QUEST + elapsed;
		local questIndex = C_QuestLog.GetLogIndexForQuestID(TUTORIAL_QUEST_TO_WATCH);
		if questIndex and (TUTORIAL_TIMER_CLOSE_TO_QUEST > 2) then
			TUTORIAL_TIMER_CLOSE_TO_QUEST = 0;
			local distSq = C_QuestLog.GetDistanceSqToQuest(TUTORIAL_QUEST_TO_WATCH);
			if (distSq and distSq > 0 and distSq < TUTORIAL_DISTANCE_TO_QUEST_KILL_SQ) then
				TriggerTutorial(4);
			end
		end
	end
	if ( CURRENT_TUTORIAL_QUEST_INFO and CURRENT_TUTORIAL_QUEST_INFO.showReminder and not IsTutorialFlagged(34) and IsTutorialFlagged(2) and not TutorialFrame:IsShown() and not QuestFrame:IsShown() ) then
		TUTORIAL_TIMER_FIRST_QUEST_COMPLETE = TUTORIAL_TIMER_FIRST_QUEST_COMPLETE - elapsed;
		if (TUTORIAL_TIMER_FIRST_QUEST_COMPLETE < 0) then
			TUTORIAL_TIMER_FIRST_QUEST_COMPLETE = 30;
			TriggerTutorial(57);
		end
	end
end