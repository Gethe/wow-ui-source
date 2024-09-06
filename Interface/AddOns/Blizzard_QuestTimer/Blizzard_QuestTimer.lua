QuestTimerMixin = {};

function QuestTimerMixin:OnLoad()
	self.numTimers = 0;
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.updating = nil;
end

function QuestTimerMixin:OnEvent(event, ...)
	if ( event == "QUEST_LOG_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		if ( not self.updating ) then
			self:Update();
		end
	end
end

function QuestTimerMixin:Update(elapsed)
	self.updating = 1;
	self:UpdateQuestTimers(GetQuestTimers());
	self.updating = nil;
end

function QuestTimerMixin:UpdateQuestTimers(...)
	local numTimers = select("#",...);
	for i=1, numTimers, 1 do
		local time = select(i,...);
		_G["QuestTimer"..i.."Text"]:SetText(SecondsToTime(time));
		_G["QuestTimer"..i]:Show();
	end
	for i=numTimers + 1, MAX_QUESTS, 1 do
		_G["QuestTimer"..i]:Hide();
	end
	self.numTimers = numTimers;
	if ( numTimers > 0 ) then
		self:SetHeight(43 + (16 * numTimers));
		self:Show();
	else
		self:Hide();
	end
	self.updating = nil;
end

function QuestTimerMixin:OnUpdate()
	if ( self.numTimers > 0 ) then
		self:Update();
	end
end

function QuestTimerMixin:OnShow()
	UIParent_ManageFramePositions();
end

function QuestTimerMixin:OnHide()
	UIParent_ManageFramePositions();
end

QuestTimerButtonMixin = {};

function QuestTimerButtonMixin:OnClick()
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(GetQuestIndexForTimer(self:GetID()));
	QuestLog_Update();
end
