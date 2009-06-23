function QuestTimerFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.numTimers = 0;
	self.updating = nil;
end

function QuestTimerFrame_OnEvent(self, event, ...)
	-- if ( event == "QUEST_LOG_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		-- if ( not self.updating ) then
			-- QuestTimerFrame_Update(self, GetQuestTimers());
		-- end
	-- end
end

function QuestTimerFrame_Update(self, ...)
	QuestTimerFrame:Hide();
	if ( true ) then
		return;
	end
	
	self.updating = 1;
	self.numTimers = select("#", ...);
	for i=1, self.numTimers, 1 do
		_G["QuestTimer"..i.."Text"]:SetText(SecondsToTime(select(i, ...)));
		_G["QuestTimer"..i]:Show();
	end
	for i=self.numTimers + 1, MAX_QUESTS, 1 do
		_G["QuestTimer"..i]:Hide();
	end
	if ( self.numTimers > 0 ) then
		self:SetHeight(45 + (16 * self.numTimers));
		self:Show();
	else
		self:Hide();
	end
	self.updating = nil;
end

function QuestTimerFrame_OnUpdate(self, elapsed)
	if ( self.numTimers > 0 ) then
		QuestTimerFrame_Update(self, GetQuestTimers());
	end
end

function QuestTimerButton_OnClick(self, button)
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(GetQuestIndexForTimer(self:GetID()));
	QuestLog_Update();
end

function QuestTimerFrame_OnShow()
	UIParent_ManageFramePositions();
end

function QuestTimerFrame_OnHide()
	UIParent_ManageFramePositions();
end
