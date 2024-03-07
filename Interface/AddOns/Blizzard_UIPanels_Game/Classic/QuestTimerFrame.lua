function QuestTimerFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.numTimers = 0;
	self.updating = nil;
end

function QuestTimerFrame_OnEvent(self, event, ...)
	if ( event == "QUEST_LOG_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		if ( not self.updating ) then
			QuestTimerFrame_Update(self);
		end
	end
end

function QuestTimerFrame_Update(self, elapsed)
	self.updating = 1;
	QuestTimerFrame_UpdateQuestTimers(self, GetQuestTimers());
	self.updating = nil;
end

function QuestTimerFrame_UpdateQuestTimers(self, ...)
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

function QuestTimerFrame_OnUpdate(self)
	if ( self.numTimers > 0 ) then
		QuestTimerFrame_Update(self);
	end
end

function QuestTimerButton_OnClick(self)
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(GetQuestIndexForTimer(self:GetID()));
	QuestLog_Update();
end

function QuestTimerFrame_OnShow(self)
	UIParent_ManageFramePositions();
end

function QuestTimerFrame_OnHide(self)
	UIParent_ManageFramePositions();
end

--[[
function QuestTimerFrame_UpdatePosition()
	if ( MultiBarLeft:IsVisible() ) then
		QuestTimerFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", -75, 0);
	elseif ( MultiBarRight:IsVisible() ) then
		QuestTimerFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", -30, 0);
	else
		QuestTimerFrame:SetPoint("TOP", "MinimapCluster", "BOTTOM", 10, 0);
	end
end
]]