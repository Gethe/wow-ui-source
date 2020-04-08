
local DISPLAY_STATE_CLOSED = 1;
local DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG = 2;
local DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG = 3;
local DISPLAY_STATE_OPEN_MAXIMIZED = 4;

QuestLogOwnerMixin = { }

function QuestLogOwnerMixin:HandleUserActionToggleSelf()
	local displayState;
	if self:IsShown() then
		if self:IsMaximized() then
			displayState = DISPLAY_STATE_CLOSED;
		else
			if self:ShouldShowQuestLogPanel() == self.QuestLog:IsShown() then
				if self:ShouldBeMaximized() then
					displayState = DISPLAY_STATE_OPEN_MAXIMIZED;
				else
					displayState = DISPLAY_STATE_CLOSED;
				end
			else
				if self:ShouldBeMaximized() then
					displayState = DISPLAY_STATE_OPEN_MAXIMIZED;
				else
					displayState = DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG;
				end
			end
		end
	else
		self.wasShowingQuestLog = nil;
		if self:ShouldBeMinimized() then
			if self:ShouldShowQuestLogPanel() then
				displayState = DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG;
			else
				displayState = DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG;
			end
		else
			displayState = DISPLAY_STATE_OPEN_MAXIMIZED;
		end
	end
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionToggleQuestLog()
	local displayState;
	if self:IsShown() and self.QuestLog:IsShown() then
		displayState = DISPLAY_STATE_CLOSED;
	else
		displayState = DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG;
	end
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionToggleSidePanel()
	local displayState;
	if self.QuestLog:IsShown() then
		SetCVar("questLogOpen", 0);
		displayState = DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG;
	else
		SetCVar("questLogOpen", 1);
		displayState = DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG;
	end
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionMinimizeSelf()
	local displayState;
	SetCVar("miniWorldMap", 1);
	if self:ShouldShowQuestLogPanel() or self.wasShowingQuestLog then
		displayState = DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG;
	else
		displayState = DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG;
	end
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionMaximizeSelf()
	SetCVar("miniWorldMap", 0);
	self.wasShowingQuestLog = self.QuestLog:IsShown();
	displayState = DISPLAY_STATE_OPEN_MAXIMIZED;
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionOpenQuestLog(mapID)
	self:SetDisplayState(DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG);
	if mapID then
		self:SetMapID(mapID);
	end
end

function QuestLogOwnerMixin:HandleUserActionOpenSelf(mapID)
	-- any displayState is fine for this
	ShowUIPanel(self);
	if mapID then
		self:SetMapID(mapID);
	end
end

function QuestLogOwnerMixin:SetDisplayState(displayState)
	if displayState == DISPLAY_STATE_CLOSED then
		HideUIPanel(self);
	else
		ShowUIPanel(self);

		local hasSynchronizedDisplayState = false;

		if displayState == DISPLAY_STATE_OPEN_MAXIMIZED then
			if not self:IsMaximized() then
				self:SetQuestLogPanelShown(false);
				self:Maximize();
				self.BorderFrame.MaximizeMinimizeFrame:SetMinimizedLook();
				hasSynchronizedDisplayState = true;
			end
		elseif displayState == DISPLAY_STATE_OPEN_MINIMIZED_NO_LOG then
			if self:IsMaximized() then
				self:Minimize();
				hasSynchronizedDisplayState = true;
			end
			self:SetQuestLogPanelShown(false);
		elseif displayState == DISPLAY_STATE_OPEN_MINIMIZED_WITH_LOG then
			if self:IsMaximized() then
				self:Minimize();
				self.BorderFrame.MaximizeMinimizeFrame:SetMaximizedLook();
				hasSynchronizedDisplayState = true;
			end
			self:SetQuestLogPanelShown(true);
		end
	end

	if self:IsMaximized() then
		self.SidePanelToggle:Hide();
	else
		self.SidePanelToggle:Show();
		self.SidePanelToggle:Refresh();
	end

	self:RefreshQuestLog();
	self:UpdateSpacerFrameAnchoring();

	if not hasSynchronizedDisplayState then
		self:SynchronizeDisplayState();
	end
end

function QuestLogOwnerMixin:SetQuestLogPanelShown(shown)
	if self.QuestLog and shown ~= self.QuestLog:IsShown() then
		if shown then
			self:SetWidth(self.minimizedWidth + self.questLogWidth);
			self.QuestLog:Show();
		else
			self:SetWidth(self.minimizedWidth);
			self.QuestLog:Hide();
		end

		UpdateUIPanelPositions(self);
	end
end

function QuestLogOwnerMixin:RefreshQuestLog()
	if self.QuestLog and self.QuestLog:IsShown() then
		self.QuestLog:Refresh();
	end
end

function QuestLogOwnerMixin:OnUIClose()
	if self.QuestLog then
		self.QuestLog:UpdatePOIs();
	end
end

function QuestLogOwnerMixin:ShouldShowQuestLogPanel()
	return GetCVarBool("questLogOpen");
end

function QuestLogOwnerMixin:ShouldBeMinimized()
	return GetCVarBool("miniWorldMap");
end

function QuestLogOwnerMixin:ShouldBeMaximized()
	return not self:ShouldBeMinimized();
end

function QuestLogOwnerMixin:IsSidePanelShown()
	return self.QuestLog:IsShown();
end

function QuestLogOwnerMixin:SetHighlightedQuestID(questID)
	-- override in your mixin
end

function QuestLogOwnerMixin:GetHighlightedQuestID()
	-- override in your mixin
end

function QuestLogOwnerMixin:ClearHighlightedQuestID()
	-- override in your mixin
end

function QuestLogOwnerMixin:SetFocusedQuestID(questID)
	-- override in your mixin
end

function QuestLogOwnerMixin:ClearFocusedQuestID()
	-- override in your mixin
end

function QuestLogOwnerMixin:CanDisplayQuestLog()
	-- override in your mixin
end

function QuestLogOwnerMixin:OnQuestLogShow()
	-- override in your mixin
end

function QuestLogOwnerMixin:OnQuestLogHide()
	-- override in your mixin
end

function QuestLogOwnerMixin:OnQuestLogOpen()
	-- override in your mixin, this is when the quest log is directed to open (like from keybind) which will force the parent to open as well if needed
end

function QuestLogOwnerMixin:OnQuestLogUpdate()
	-- override in your mixin
end