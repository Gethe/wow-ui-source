local TIMER_PANEL_BASE_HEIGHT = 43;
local TIMER_ROW_HEIGHT = 16;
local OBJECTIVE_PANEL_SPACING = 18;

QuestTimerMixin = {};

function QuestTimerMixin:OnLoad()
	self.numTimers = 0;
	
	self.templateName = "QuestTimerButtonTemplate";
	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("BUTTON", self, self.templateName);
	self.activeElements = {};
	self.topPadding = QUEST_TIMER_FRAME_TOP_PADDING;
	
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.updating = nil;
end

function QuestTimerMixin:OnHide()
	self.pools:ReleaseAll();
end

function QuestTimerMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:UpdateIfNeeded();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateIfNeeded();
		EventRegistry:TriggerEvent("ObjectiveTrackerContainerMixin.AddTopPaddingProvider", self);
	end
end

function QuestTimerMixin:UpdateIfNeeded()
	if not self.updating then
		self:Update();
	end
end

function QuestTimerMixin:Update(elapsed)
	self.updating = 1;
	local questTimers = C_QuestLog.GetQuestTimers() or {};
	self:UpdateQuestTimers(questTimers);
	self.updating = nil;
end

function QuestTimerMixin:GetFrameHeight()
	if ( self.numTimers > 0 ) then
		return TIMER_PANEL_BASE_HEIGHT + (TIMER_ROW_HEIGHT * self.numTimers);
	end
	return 0;
end

function QuestTimerMixin:GetTopPadding()
	if not self:IsVisible() then
		return 0;
	end
	local height = self:GetFrameHeight();
	return height + OBJECTIVE_PANEL_SPACING;
end

function QuestTimerMixin:UpdateQuestTimers(questTimers)
	local numTimers = #questTimers;
	for i = 1, numTimers, 1 do
		local questTimeInfo = questTimers[i]

		if not self.activeElements[i] then
			local frame = self.pools:Acquire(self.templateName);
			-- Not tracked yet new element, set everything and show it
			frame.Name:SetText(SecondsToTime(questTimeInfo.questTimer));
			frame.questID = questTimeInfo.questID;

			-- Position the frame
			frame:ClearAllPoints();
			if i == 1 then
				frame:SetPoint("TOP", self, "TOP", 0, -30);
			else
				frame:SetPoint("TOP", self.activeElements[i-1], "BOTTOM", 0, 0);
			end

			frame:Show();
			table.insert(self, frame);
			self.activeElements[i] = frame;
		else
			-- Already active just refresh the timer text
			self.activeElements[i].Name:SetText(SecondsToTime(questTimeInfo.questTimer));
		end
	end

	-- Remove elements that are unneeded.
	for i = numTimers + 1, MAX_QUESTS, 1 do
		if self.activeElements[i] then
			local frame = self.activeElements[i];
			frame:Hide();
			frame:ClearAllPoints();
			self.pools:Release(frame);
			self.activeElements[i] = nil;
		end
	end
	self.numTimers = numTimers;
	if ( numTimers > 0 ) then
		self:SetHeight(self:GetFrameHeight());
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

function QuestTimerButtonMixin:OnLeave()
	GameTooltip:Hide();
end
