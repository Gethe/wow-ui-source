
local DISPLAY_STATE_CLOSED = 1;
local DISPLAY_STATE_OPEN_MAXIMIZED_NO_LOG = 2;
local DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG = 3;
local DISPLAY_STATE_OPEN_MINIMIZED = 4;

QuestLogOwnerMixin = { }

function QuestLogOwnerMixin:HandleUserActionToggleSelf()
	local displayState;

	if self:IsShown() then
		if not self:IsMaximized() then
			displayState = DISPLAY_STATE_CLOSED;
		else
			if self:ShouldBeMinimized() then
				displayState = DISPLAY_STATE_OPEN_MINIMIZED;
			else
				displayState = DISPLAY_STATE_CLOSED;
			end
		end
	else
		self.wasShowingQuestLog = nil;
		if self:ShouldBeMaximized() then
			if self:ShouldShowQuestLogPanel() then
				displayState = DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG; 
			else
				displayState = DISPLAY_STATE_OPEN_MAXIMIZED_NO_LOG;
			end
		else
			displayState = DISPLAY_STATE_OPEN_MINIMIZED;
		end
	end

	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionToggleQuestLog()
	local displayState;
	if self:IsShown() and self:IsMaximized() then
		if not self.QuestLog:IsShown() and self:ShouldShowQuestLogPanel() then
			displayState = DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG;
		else
			displayState = DISPLAY_STATE_OPEN_MAXIMIZED_NO_LOG;
		end
	else
		displayState = DISPLAY_STATE_OPEN_MINIMIZED;
	end

	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionMinimizeSelf()
	SetCVar("miniWorldMap", 1);
	self.wasShowingQuestLog = self.QuestLog:IsShown();
	local displayState = DISPLAY_STATE_OPEN_MINIMIZED;
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionMaximizeSelf()
	local displayState;
	SetCVar("miniWorldMap", 0);
	if self:ShouldShowQuestLogPanel() or self.wasShowingQuestLog then
		displayState = DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG;
	else
		displayState = DISPLAY_STATE_OPEN_MAXIMIZED_NO_LOG;
	end
	self:SetDisplayState(displayState);
end

function QuestLogOwnerMixin:HandleUserActionOpenQuestLog(mapID)
	if self:IsMaximized() then	
		if self:ShouldShowQuestLogPanel() then
			self:SetDisplayState(DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG);
		end
	else
		self:SetDisplayState(DISPLAY_STATE_OPEN_MINIMIZED);
	end
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

		if displayState == DISPLAY_STATE_OPEN_MINIMIZED then
			if self:IsMaximized() then
				self:Minimize();
				hasSynchronizedDisplayState = true;
			end
			self:SetQuestLogPanelShown(false);
		elseif displayState == DISPLAY_STATE_OPEN_MAXIMIZED_NO_LOG then
			if not self:IsMaximized() then
				self:Maximize();
				hasSynchronizedDisplayState = true;
			end
			self:SetQuestLogPanelShown(false);
		elseif displayState == DISPLAY_STATE_OPEN_MAXIMIZED_WITH_LOG then
			if not self:IsMaximized() then
				self:Maximize();
				hasSynchronizedDisplayState = true;
			end
			self:SetQuestLogPanelShown(true);
		end
	end

	self:RefreshQuestLog();

	if(OpacityFrame:IsShown()) then
		OpacityFrame:Hide();
	end

	if ( QuestLogDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogDetailFrame);
	end

	if ( QuestLogFrame:IsShown() ) then
		HideUIPanel(QuestLogFrame);
	end

	if not hasSynchronizedDisplayState then
		self:SynchronizeDisplayState();
	end
end

function QuestLogOwnerMixin:SetQuestLogPanelShown(shown)
	if self.QuestLog and shown ~= self.QuestLog:IsShown() then
		if shown then
			self.ScrollContainer:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -320, 236);
			self.QuestLog:Show();
			self.QuestLog:UpdatePOIs();
		else
			self.ScrollContainer:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -11, 30);
			self.QuestLog:Hide();
		end

		self:SynchronizeDisplayState();
	end
end

function QuestLogOwnerMixin:RefreshQuestLog()
	if self.QuestLog then
		self.QuestLog:Refresh();
	end
end

function QuestLogOwnerMixin:OnUIClose()
	if self.QuestLog then
		self.QuestLog:UpdatePOIs();
	end
end

function QuestLogOwnerMixin:ShouldShowQuestLogPanel()
	return GetCVarBool("questPOI") and GetCVarBool("questHelper");
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
