EVENT_TRACE_EVENT_HEIGHT = 16;
EVENT_TRACE_MAX_ENTRIES = 1000;

local _normalFontColor = { 1, .82, 0, 1 };

EVENT_TRACE_SYSTEM_TIMES = {};
EVENT_TRACE_SYSTEM_TIMES["System"] = true;
EVENT_TRACE_SYSTEM_TIMES["Elapsed"] = true;

EVENT_TRACE_EVENT_COLORS = {};
EVENT_TRACE_EVENT_COLORS["System"] = _normalFontColor;
EVENT_TRACE_EVENT_COLORS["Elapsed"] = { .6, .6, .6, 1 };

local _EventTraceFrame;

local _framesSinceLast = 0;
local _timeSinceLast = 0;

local _timer = CreateFrame("FRAME");
_timer:SetScript("OnUpdate", function (self, elapsed) _framesSinceLast = _framesSinceLast + 1; _timeSinceLast = _timeSinceLast + elapsed; end);

function CanAccessObject(obj)
	return issecure() or not obj:IsForbidden();
end

function EventTraceFrame_OnLoad (self)
	self.buttons = {};
	self.events = {};
	self.times = {};
	self.rawtimes = {};
	self.eventids = {};
	self.eventtimes = {};
	self.numhandlers = {};
	self.slowesthandlers = {};
	self.slowesthandlertimes = {}
	self.timeSinceLast = {};
	self.framesSinceLast = {};
	self.args = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {} };
	self.ignoredEvents = {};
	self.lastIndex = 0;
	self.visibleButtons = 0;
	_EventTraceFrame = self;
	self:SetScript("OnSizeChanged", EventTraceFrame_OnSizeChanged);
	EventTraceFrame_OnSizeChanged(self, self:GetWidth(), self:GetHeight());
	self:EnableMouse(true);
	self:EnableMouseWheel(true);
	self:SetScript("OnMouseWheel", EventTraceFrame_OnMouseWheel);
end

local _workTable = {};
function EventTraceFrame_OnEvent (self, event, ...)
	if ( not self.ignoredEvents[event] ) then
		if ( _framesSinceLast ~= 0 and event ~= "On Update") then
			EventTraceFrame_OnEvent(self, "On Update");
		end

		local nextIndex = self.lastIndex + 1;
		if ( nextIndex > EVENT_TRACE_MAX_ENTRIES ) then
			local staleIndex = nextIndex - EVENT_TRACE_MAX_ENTRIES;
			self.events[staleIndex] = nil;
			self.times[staleIndex] = nil;
			self.rawtimes[staleIndex] = nil;
			self.timeSinceLast[staleIndex] = nil;
			self.framesSinceLast[staleIndex] = nil;
			self.eventids[staleIndex] = nil;
			self.eventtimes[staleIndex] = nil;
			self.numhandlers[staleIndex] = nil;
			self.slowesthandlers[staleIndex] = nil;
			self.slowesthandlertimes[staleIndex] = nil;
			for k, v in next, self.args do
				self.args[k][staleIndex] = nil;
			end
		end

		if ( event == "Begin Capture" or event == "End Capture" ) then
			self.times[nextIndex] = "System";
			if ( self.eventsToCapture ) then
				self.events[nextIndex] = string.format("%s (%s events)", event, tostring(self.eventsToCapture));
			else
				self.events[nextIndex] = event;
			end
			self.timeSinceLast[nextIndex] = 0;
			self.framesSinceLast[nextIndex] = 0;
		elseif ( event == "On Update" ) then
			self.times[nextIndex] = "Elapsed";
			self.events[nextIndex] = string.format("%.3f sec - %d frame(s)", _timeSinceLast, _framesSinceLast);
			self.timeSinceLast[nextIndex] = _timeSinceLast;
			self.framesSinceLast[nextIndex] = _framesSinceLast;
			_timeSinceLast = 0;
			_framesSinceLast = 0;
		else
			self.events[nextIndex] = event;
			local seconds = GetTime();
			local minutes = math.floor(math.floor(seconds) / 60);
			local hours = math.floor(minutes / 60);
			seconds = seconds - 60 * minutes;
			minutes = minutes - 60 * hours;
			hours = hours % 1000;
			self.times[nextIndex] = string.format("%.2d:%.2d:%06.3f", hours, minutes, seconds);
			self.timeSinceLast[nextIndex] = 0;
			self.framesSinceLast[nextIndex] = 0;
			self.eventids[nextIndex] = GetCurrentEventID();

			local numArgs = select("#", ...);
			for i=1, numArgs do
				if ( not self.args[i] ) then
					self.args[i] = {};
				end
				self.args[i][nextIndex] = select(i, ...);
			end

			if ( self.eventsToCapture ) then
				self.eventsToCapture = self.eventsToCapture - 1;
			end
		end

		-- NOTE: Remember that this work will be captured in the elapsed time for this event, so
		-- don't do anything slow here or it will throw off the profiled data

		self.rawtimes[nextIndex] = GetTime();
		self.lastIndex = nextIndex;
		if ( self.eventsToCapture and self.eventsToCapture <= 0 ) then
			self.eventsToCapture = nil;
			EventTraceFrame_StopEventCapture();
		end
	end
end

function EventTraceFrame_OnShow(self)
	wipe(self.ignoredEvents);
	local scrollBar = _G["EventTraceFrameScroll"];
	local minValue, maxValue = scrollBar:GetMinMaxValues();
	scrollBar:SetValue(maxValue);
end

function EventTraceFrame_OnUpdate (self, elapsed)
	EventTraceFrame_Update();
end

function EventTraceFrame_OnSizeChanged (self, width, height)
	local numButtonsToDisplay = math.floor((height - 36)/EVENT_TRACE_EVENT_HEIGHT);
	local numButtonsCreated = #self.buttons;

	if ( numButtonsCreated < numButtonsToDisplay ) then
		for i = numButtonsCreated + 1, numButtonsToDisplay do
			local button = CreateFrame("BUTTON", "EventTraceFrameButton" .. i, self, "EventTraceEventTemplate");
			button:SetPoint("BOTTOMLEFT", 12, (16 * (i - 1)) + 12);
			button:SetPoint("RIGHT", -28, 0);
			tinsert(self.buttons, button);
		end
		for i = self.visibleButtons + 1, numButtonsToDisplay do
			self.buttons[i]:Show();
		end
		self.visibleButtons = numButtonsToDisplay;
		EventTraceFrame_Update();
	elseif ( self.visibleButtons < numButtonsToDisplay ) then
		for i = self.visibleButtons + 1, numButtonsToDisplay do
			self.buttons[i]:Show();
		end
		self.visibleButtons = numButtonsToDisplay;
		EventTraceFrame_Update();
	elseif ( numButtonsToDisplay < self.visibleButtons ) then
		for i = numButtonsToDisplay + 1, self.visibleButtons do
			self.buttons[i]:Hide();
		end
		self.visibleButtons = numButtonsToDisplay;
	end
end

function EventTraceFrame_Update ()
	local offset = 0;

	local scrollBar = _G["EventTraceFrameScroll"];
	local scrollBarValue = scrollBar:GetValue();
	local minValue, maxValue = scrollBar:GetMinMaxValues();

	local firstID = max(1, _EventTraceFrame.lastIndex - EVENT_TRACE_MAX_ENTRIES + 1);
	local lastID = _EventTraceFrame.lastIndex or 1;

	if ( firstID >= lastID ) then
		scrollBar:SetMinMaxValues(firstID-1, lastID);
	else
		scrollBar:SetMinMaxValues(firstID, lastID);
	end
	if ( scrollBarValue < firstID ) then
		scrollBar:SetValue(firstID);
		scrollBarValue = firstID;
	end

	if ( scrollBarValue < 1 ) then
		scrollBarValue = 1;
	elseif ( not _EventTraceFrame.selectedEvent ) then
		if ( scrollBarValue == maxValue ) then
			scrollBar:SetValue(_EventTraceFrame.lastIndex);
		end
	end

	for i = 1, _EventTraceFrame.visibleButtons do
		local button = _EventTraceFrame.buttons[i];
		if ( button ) then
			local index = scrollBarValue - (i - 1);
			local event = _EventTraceFrame.events[index];
			if ( event ) then
				local timeString = _EventTraceFrame.times[index]
				button.index = index;
				button.time:SetText(timeString);
				button.event:SetText(event);
				if (_EventTraceFrame.eventids[index] and not _EventTraceFrame.eventtimes[index]) then
					local eventTime, numHandlers, slowestHandler, slowestHandlerTime = GetEventTime(_EventTraceFrame.eventids[index]);
					_EventTraceFrame.eventtimes[index] = eventTime;
					_EventTraceFrame.numhandlers[index] = numHandlers;
					_EventTraceFrame.slowesthandlers[index] = slowestHandler;
					_EventTraceFrame.slowesthandlertimes[index] = slowestHandlerTime;
				end
				local color = EVENT_TRACE_EVENT_COLORS[event] or EVENT_TRACE_EVENT_COLORS[timeString];
				if ( color ) then
					button.time:SetTextColor(unpack(color));
					button.event:SetTextColor(unpack(color));
				else
					local eventTime = _EventTraceFrame.eventtimes[index];
					if (eventTime and eventTime > 50.0) then
						button.time:SetTextColor(1, 0, 0, 1);
						button.event:SetTextColor(1, 0, 0, 1);
					elseif (eventTime and eventTime > 20.0) then
						button.time:SetTextColor(1, .5, 0, 1);
						button.event:SetTextColor(1, .5, 0, 1);
					elseif (eventTime and eventTime > 10.0) then
						button.time:SetTextColor(1, .8, 0, 1);
						button.event:SetTextColor(1, .8, 0, 1);
					elseif (eventTime and eventTime > 5.0) then
						button.time:SetTextColor(1, 1, .6, 1);
						button.event:SetTextColor(1, 1, .6, 1);
					else
						button.time:SetTextColor(1, 1, 1, 1);
						button.event:SetTextColor(1, 1, 1, 1);
					end
				end
				button:Show();
				if ( _EventTraceFrame.selectedEvent ) then
					if ( index == _EventTraceFrame.selectedEvent ) then
						EventTraceFrameEvent_DisplayTooltip(button);
						button:GetHighlightTexture():SetVertexColor(.15, .25, 1, .35);
						button:LockHighlight(true);
						button.wasSelected = true;
					elseif ( button.wasSelected ) then
						button.wasSelected = nil;
						button:GetHighlightTexture():SetVertexColor(.8, .8, 1, .15);
						button:UnlockHighlight();
					end
				else
					if ( button.wasSelected ) then
						button.wasSelected = nil;
						button:GetHighlightTexture():SetVertexColor(.8, .8, 1, .15);
						button:UnlockHighlight();
					end
				end
				if ( button:IsMouseOver() ) then
					EventTraceFrameEvent_OnEnter(button);
				else
					button.HideButton:Hide();
				end
			else
				button.index = index;
				button:Hide();
			end
		end
	end

	EventTraceFrame_UpdateKeyboardStatus();
end

function EventTraceFrame_SetEventSet (cmd, eventSet)
	-- Always unregister old events if we had any
	if _EventTraceFrame.eventSet then
		for k, v in ipairs(_EventTraceFrame.eventSet) do
			_EventTraceFrame:UnregisterEvent(v);
		end
	end

	if cmd == "start" then
		-- When starting capture, either register specific events, or register all
		_EventTraceFrame.eventSet = eventSet;

		if eventSet then
			for k, v in ipairs(_EventTraceFrame.eventSet) do
				_EventTraceFrame:RegisterEvent(v);
			end
		else
			_EventTraceFrame:RegisterAllEvents();
		end
	else
		-- When stopping, only unregister all if there was no previous set, the previous set was already unregistered.
		if not _EventTraceFrame.eventSet then
			_EventTraceFrame:UnregisterAllEvents();
		end

		_EventTraceFrame.eventSet = nil;
	end
end

function EventTraceFrame_StartEventCapture (eventSet)
	if ( _EventTraceFrame.started ) then -- Nothing to do?
		return;
	end

	_EventTraceFrame.started = true;
	_framesSinceLast = 0;
	_timeSinceLast = 0;
	EventTraceFrame_SetEventSet("start", eventSet);
	EventTraceFrame_OnEvent(_EventTraceFrame, "Begin Capture");
end

function EventTraceFrame_StopEventCapture ()
	if ( not _EventTraceFrame.started ) then -- Nothing to do!
		EventTraceFrame_SetEventSet(nil); -- well, nothing except ensuring that custom events aren't registered
		return;
	end

	_EventTraceFrame.started = false;
	_framesSinceLast = 0;
	_timeSinceLast = 0;

	EventTraceFrame_SetEventSet("stop");
	EventTraceFrame_OnEvent(_EventTraceFrame, "End Capture");
end

function EventTraceFrame_ParseArgsForEvents (msg, ...)
	msg = strlower(msg);
	if select("#", ...) > 0 then
		return msg, { select(1, ...) };
	end

	return msg;
end

function EventTraceFrame_ParseArgs (msg)
	if not msg or msg == "" then
		return "";
	elseif #msg >= 4 then
		local isMark = string.lower(string.sub(msg, 1, 4)) == "mark";
		if isMark then
			return "mark";
		end
	end

	return EventTraceFrame_ParseArgsForEvents(strsplit(" ", msg));
end

function EventTraceFrame_HandleSlashCmd (msg)
	local originalMsg = msg;
	msg, eventSet = EventTraceFrame_ParseArgs(msg);
	local fixedEventCount = tonumber(msg) or 0; -- This may not be set, that's fine.

	if msg == "start" then
		EventTraceFrame_StartEventCapture(eventSet);
	elseif msg == "stop" then
		EventTraceFrame_StopEventCapture();
	elseif fixedEventCount > 0 then
		if not _EventTraceFrame.started then
			_EventTraceFrame.eventsToCapture = fixedEventCount;
			EventTraceFrame_StartEventCapture();
		end
	elseif msg == "mark" then
		EventTraceFrame_AddMark(originalMsg:sub(5));
	else
		if not _EventTraceFrame:IsShown() then
			_EventTraceFrame:Show();
			if _EventTraceFrame.started == nil then
				EventTraceFrame_StartEventCapture(eventSet); -- If this is the first time we're showing the window, start capturing events immediately.
			end
		else
			_EventTraceFrame:Hide();
		end
	end
end

function EventTraceFrame_AddMessage(fmt, ...)
	EventTraceFrame_OnEvent(_EventTraceFrame, fmt:format(...));
end

function EventTraceFrame_AddMark(customMark)
	if customMark and customMark ~= '' then
		EventTraceFrame_AddMessage("|cff00ff00--- %s ---|r", tostring(customMark));
	else
		EventTraceFrame_AddMessage("|cff00ff00--- Mark ---|r");
	end
end

function EventTraceFrame_OnMouseWheel (self, delta)
	local scrollBar = _G["EventTraceFrameScroll"];
	local minVal, maxVal = scrollBar:GetMinMaxValues();
	local currentValue = scrollBar:GetValue();

	local newValue = currentValue - ( delta * 3 );
	newValue = max(newValue, minVal);
	newValue = min(newValue, maxVal);
	if ( newValue ~= currentValue ) then
		scrollBar:SetValue(newValue);
	end
end

function EventTraceFrame_UpdateKeyboardStatus ()
	if ( _EventTraceFrame.selectedEvent ) then
		local focus = GetMouseFocus();
		if ( focus == _EventTraceFrame or (focus and focus:GetParent() == _EventTraceFrame) ) then
			_EventTraceFrame:EnableKeyboard(true);
			return;
		end
	end
	_EventTraceFrame:EnableKeyboard(false);
end

function EventTraceFrame_OnKeyUp (self, key)
	if ( key == "ESCAPE" ) then
		self.selectedEvent = nil;
		EventTraceTooltip:Hide();
		EventTraceFrame_Update();
	end
end

function EventTraceFrame_RemoveEvent(i)
	if (i >= 1 and i <= EventTraceFrame.lastIndex) then
		tremove(EventTraceFrame.events, i);
		tremove(EventTraceFrame.times, i);
		tremove(EventTraceFrame.rawtimes, i);
		tremove(EventTraceFrame.timeSinceLast, i);
		tremove(EventTraceFrame.framesSinceLast, i);
		tremove(EventTraceFrame.eventtimes, i);
		tremove(EventTraceFrame.eventids, i);
		tremove(EventTraceFrame.numhandlers, i);
		tremove(EventTraceFrame.slowesthandlers, i);
		tremove(EventTraceFrame.slowesthandlertimes, i);

		for k, v in next, EventTraceFrame.args do
			-- can't use tremove because some of these are nil
			for j = i, EventTraceFrame.lastIndex do
				EventTraceFrame.args[k][j] = EventTraceFrame.args[k][j+1];
			end
		end
		EventTraceFrame.lastIndex = EventTraceFrame.lastIndex-1;
	end
end

local TIME_LABEL = "Time:";
local DETAILS_LABEL = "Details:";
local SLOWEST_LABEL = "Slowest:";
local ARGUMENT_LABEL_FORMAT = "arg %d:";
local NUM_HANDLERS_FORMAT = "(%d handlers)";
local EVENT_TIME_FORMAT = "%.2fms";

local function EventTrace_FormatArgValue (val)
	if ( type(val) == "string" ) then
		return string.format('"%s"', val);
	elseif ( type(val) == "number" ) then
		return tostring(val);
	elseif ( type(val) == "boolean" ) then
		return string.format('|cffaaaaff%s|r', tostring(val));
	elseif ( type(val) == "table" or type(val) == "bool" ) then
		return string.format('|cffffaaaa%s|r', tostring(val));
	end
end

function EventTraceFrameEvent_DisplayTooltip (eventButton)
	local index = eventButton.index;
	if ( not index ) then
		return;
	end

	local tooltip = _G["EventTraceTooltip"];
	tooltip:SetOwner(eventButton, "ANCHOR_NONE");
	tooltip:SetPoint("TOPLEFT", eventButton, "TOPRIGHT", 24, 2);
	local timeString = _EventTraceFrame.times[index]
	if ( EVENT_TRACE_SYSTEM_TIMES[timeString] ) then
		tooltip:AddLine(timeString, 1, 1, 1);
		tooltip:AddDoubleLine(TIME_LABEL, _EventTraceFrame.rawtimes[index], 1, .82, 0, 1, 1, 1);
		tooltip:AddDoubleLine(DETAILS_LABEL, _EventTraceFrame.events[index], 1, .82, 0, 1, 1, 1);
	else
		tooltip:AddLine(_EventTraceFrame.events[index], 1, 1, 1);
		local eventTime = _EventTraceFrame.eventtimes[index];
		if (eventTime) then
			if (eventTime < 0) then
				eventTime = "?";
			else
				eventTime = format(EVENT_TIME_FORMAT, eventTime);
			end
			tooltip:AddDoubleLine(TIME_LABEL, eventTime .. "  " .. format(NUM_HANDLERS_FORMAT, _EventTraceFrame.numhandlers[index] or 0), 1, .82, 0, 1, 1, 1);
		else
			tooltip:AddDoubleLine(TIME_LABEL, _EventTraceFrame.rawtimes[index], 1, .82, 0, 1, 1, 1);
		end
		if (_EventTraceFrame.slowesthandlers[index]) then
			tooltip:AddDoubleLine(SLOWEST_LABEL, format("%s  (%.2fms)", _EventTraceFrame.slowesthandlers[index], _EventTraceFrame.slowesthandlertimes[index]), 1, .82, 0, 1, 1, 1);
		end
		for k, v in ipairs(EventTraceFrame.args) do
			if ( v[index] ) then
				tooltip:AddDoubleLine(format(ARGUMENT_LABEL_FORMAT, k), EventTrace_FormatArgValue(v[index]), 1, .82, 0, 1, 1, 1);
			end
		end
	end
	tooltip:Show();
end

function EventTraceFrameEvent_OnEnter (self)
	if (not EVENT_TRACE_SYSTEM_TIMES[EventTraceFrame.times[self.index]]) then
		self.HideButton:Show();
	else
		self.HideButton:Hide();
	end
	if ( _EventTraceFrame.selectedEvent ) then
		return;
	else
		EventTraceFrameEvent_DisplayTooltip(self);
	end
end

function EventTraceFrameEvent_OnLeave (self)
	if ( not self.HideButton:IsMouseOver()) then
		self.HideButton:Hide();
	end
	if ( not _EventTraceFrame.selectedEvent ) then
		EventTraceTooltip:Hide();
	end
end

function EventTraceFrameEvent_OnClick (self)
	if ( _EventTraceFrame.selectedEvent == self.index ) then
		_EventTraceFrame.selectedEvent = nil;
	else
		_EventTraceFrame.selectedEvent = self.index;
	end
	EventTraceFrame_Update();
end

function EventTraceFrameEventHideButton_OnClick (button)
	local eventName = button:GetParent().event:GetText();
	EventTraceFrame.ignoredEvents[eventName] = 1;
	EventTraceFrame.selectedEvent = nil;

	-- Remove matching all events of this type
	for i = EventTraceFrame.lastIndex, 1, -1  do
		if (EventTraceFrame.events[i] == eventName) then
			EventTraceFrame_RemoveEvent(i);
		end
	end

	-- Consolidate "Elapsed" lines
	local lastWasElapsed = false;
	for i = EventTraceFrame.lastIndex, 1, -1  do
		if (EventTraceFrame.times[i] == "Elapsed") then
			if (lastWasElapsed) then
				EventTraceFrame.timeSinceLast[i] = EventTraceFrame.timeSinceLast[i] + EventTraceFrame.timeSinceLast[i+1];
				EventTraceFrame.framesSinceLast[i] = EventTraceFrame.framesSinceLast[i] + EventTraceFrame.framesSinceLast[i+1];
				EventTraceFrame.events[i] = string.format(string.format("%.3f sec", EventTraceFrame.timeSinceLast[i]) .. " - %d frame(s)", EventTraceFrame.framesSinceLast[i]);
				EventTraceFrame_RemoveEvent(i+1);
			end
			lastWasElapsed = true;
		else
			lastWasElapsed = false;
		end
	end

	EventTraceFrame_Update();
end

function DebugTooltip_OnLoad(self)
	SharedTooltip_OnLoad(self);
	self:SetFrameLevel(self:GetFrameLevel() + 2);
end

function FrameStackTooltip_OnDisplaySizeChanged(self)
	local height = GetScreenHeight();
	if (height > 768) then
		self:SetScale(768/height);
	else
		self:SetScale(1);
	end
end

function FrameStackTooltip_IsShowHiddenEnabled()
	return GetCVarBool("fstack_showhidden");
end

function FrameStackTooltip_IsHighlightEnabled()
	return GetCVarBool("fstack_showhighlight");
end

function FrameStackTooltip_IsShowRegionsEnabled()
	return GetCVarBool("fstack_showregions");
end

function FrameStackTooltip_IsShowAnchorsEnabled()
	return GetCVarBool("fstack_showanchors");
end

function FrameStackTooltip_OnFramestackVisibilityUpdated(self)
	if ( self:IsVisible() ) then
		--[[Since these properties impact the contents displayed on the framestack,
		toggle the framestack off and then on to reinitialize it.--]]
		FrameStackTooltip_Hide(self);

		local showHidden = FrameStackTooltip_IsShowHiddenEnabled();
		local showRegions = FrameStackTooltip_IsShowRegionsEnabled();
		local showAnchors = FrameStackTooltip_IsShowAnchorsEnabled();

		FrameStackTooltip_Show(self, showHidden, showRegions, showAnchors);
	end
end

function FrameStackTooltip_OnLoad(self)
	Mixin(self, CallbackRegistryMixin);
	CallbackRegistryMixin.OnLoad(self);
	self:GenerateCallbackEvents({ "FrameStackOnHighlightFrameChanged", "FrameStackOnShow", "FrameStackOnHide", "FrameStackOnTooltipCleared" });

	DebugTooltip_OnLoad(self);
	self.nextUpdate = 0;

	FrameStackTooltip_OnDisplaySizeChanged(self);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("FRAMESTACK_VISIBILITY_UPDATED");

	self.commandKeys =
	{
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, 1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("LALT")),
		KeyCommand_Create(function() FrameStackTooltip_ChangeHighlight(self, -1); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("RALT")),
		KeyCommand_Create(function() FrameStackTooltip_InspectTable(self); end, KeyCommand.RUN_ON_UP, KeyCommand_CreateKey("CTRL")),
		KeyCommand_Create(function() FrameStackTooltip_ToggleTextureInformation(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("SHIFT")),
		KeyCommand_Create(function() FrameStackTooltip_HandleFrameCommand(self); end, KeyCommand.RUN_ON_DOWN, KeyCommand_CreateKey("CTRL", "C")),
	};
end

function FrameStackTooltip_ChangeHighlight(self, direction)
	self.highlightIndexChanged = direction;
	self.shouldSetFSObj = true;
end

function FrameStackTooltip_InspectTable(self)
	if self.highlightFrame then
		TableAttributeDisplay:InspectTable(self.highlightFrame);
		TableAttributeDisplay:Show();
	end
end

function FrameStackTooltip_ToggleTextureInformation(self)
	self.showTextureInfo = not self.showTextureInfo;
end

function FrameStackTooltip_HandleFrameCommand(self)
	if self.currentAssets then
		for index, asset in ipairs(self.currentAssets) do
			local assetName, assetType = asset[1], asset[2];

			if assetType == "Atlas" then
				HandleAtlasMemberCommand(assetName);
				PlaySound(SOUNDKIT.MAP_PING);
				break;
			elseif assetType == "File" then
				CopyToClipboard(assetName);
				PlaySound(SOUNDKIT.UI_BONUS_LOOT_ROLL_END); -- find sound
			end
		end
	end
end

function FrameStackTooltip_OnEvent(self, event, ...)
	if ( event == "DISPLAY_SIZE_CHANGED" ) then
		FrameStackTooltip_OnDisplaySizeChanged(self);
	elseif ( event == "FRAMESTACK_VISIBILITY_UPDATED" ) then
		FrameStackTooltip_OnFramestackVisibilityUpdated(self);
	end
end

local function AreTextureCoordinatesValid(...)
	local coordCount = select("#", ...);
	for i = 1, coordCount do
		if type(select(i, ...)) ~= "number" then
			return false;
		end
	end

	return coordCount == 8;
end

local function AreTextureCoordinatesEntireImage(...)
	local ulX, ulY, blX, blY, urX, urY, brX, brY = ...;
	return	ulX == 0 and ulY == 0 and
			blX == 0 and blY == 1 and
			urX == 1 and urY == 0 and
			brX == 1 and brY == 1;
end

local function FormatTextureCoordinates(...)
	if AreTextureCoordinatesValid(...) then
		if not AreTextureCoordinatesEntireImage(...) then
			return WrapTextInColorCode(("UL:(%.2f, %.2f), BL:(%.2f, %.2f), UR:(%.2f, %.2f), BR:(%.2f, %.2f)"):format(...), "ff00ffff");
		end

		return "";
	end

	return "invalid coordinates";
end

local function ColorAssetType(assetType)
	if assetType == "Atlas" then
		return WrapTextInColorCode(assetType, "ff00ff00");
	end

	return WrapTextInColorCode(assetType, "ffff0000");
end

local function FormatTextureAssetName(assetName, assetType)
	return ("%s: %s"):format(ColorAssetType(assetType), tostring(assetName));
end

local function FormatTextureInfo(region, ...)
	if ... ~= nil then
		local assetInfo = { select(1, ...), select(2, ...) };
		return ("%s : %s %s"):format(region:GetDebugName(), FormatTextureAssetName(...), FormatTextureCoordinates(select(3, ...))), assetInfo;
	end
end

local function CheckGetRegionsTextureInfo(...)
	local info = {};
	local assets = {};
	for i = 1, select("#", ...) do
		local region = select(i, ...);
		if CanAccessObject(region) and region:IsMouseOver() then
			local textureInfo, assetInfo = FormatTextureInfo(region, GetTextureInfo(region))
			if textureInfo then
				table.insert(info, textureInfo);
				table.insert(assets, assetInfo);
			end
		end
	end

	if #info > 0 then
		return table.concat(info, "\n"), assets;
	end
end

local function CheckFormatTextureInfo(self, obj)
	if self.showTextureInfo and CanAccessObject(obj) then
		if obj.GetRegions then
			return CheckGetRegionsTextureInfo(obj:GetRegions());
		else
			return CheckGetRegionsTextureInfo(obj);
		end
	end
end

function FrameStackTooltip_OnTooltipSetFrameStack(self, highlightFrame)
	self.highlightFrame = highlightFrame;

	if self.highlightFrame then
		local textureInfo, assets = CheckFormatTextureInfo(self, self.highlightFrame);
		if textureInfo then
			self:AddLine(textureInfo);
			self.currentAssets = assets;
		end
	end

	if self.shouldSetFSObj then
		fsobj = self.highlightFrame;
		self.shouldSetFSObj = nil;

		self:TriggerEvent(self.Event.FrameStackOnHighlightFrameChanged, fsobj);
	end

	if fsobj then
		self:AddLine(("\nfsobj = %s"):format(fsobj:GetDebugName()));
	end
end

function FrameStackTooltip_Show(self, showHidden, showRegions, showAnchors)
	self:SetOwner(UIParent, "ANCHOR_NONE");
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(CONTAINER_OFFSET_X or 0) - 13, (CONTAINER_OFFSET_Y or 0));
	self.default = 1;
	self.showRegions = showRegions;
	self.showHidden = showHidden;
	self.showAnchors = showAnchors;
	self:SetFrameStack(showHidden, showRegions);
end

function FrameStackTooltip_Hide(self)
	self:Hide();
	FrameStackHighlight:Hide();
end

function FrameStackTooltip_ToggleDefaults()
	local tooltip = FrameStackTooltip;
	if ( tooltip:IsVisible() ) then
		FrameStackTooltip_Hide(tooltip);
	else
		local showHidden = FrameStackTooltip_IsShowHiddenEnabled();
		local showRegions = FrameStackTooltip_IsShowRegionsEnabled();
		local showAnchors = FrameStackTooltip_IsShowAnchorsEnabled();
		FrameStackTooltip_Show(tooltip, showHidden, showRegions, showAnchors);
	end
end

function FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors)
	local tooltip = FrameStackTooltip;
	if ( tooltip:IsVisible() ) then
		FrameStackTooltip_Hide(tooltip);
	else
		FrameStackTooltip_Show(tooltip, showHidden, showRegions, showAnchors);
	end
end

local function AnchorHighlight(frame, highlight, relativePoint)
	highlight:ClearAllPoints();
	highlight:SetAllPoints(frame);
	highlight:Show();

	if highlight.AnchorPoint then
		if relativePoint then
			highlight.AnchorPoint:ClearAllPoints();
			highlight.AnchorPoint:SetPoint("CENTER", highlight, relativePoint);
			highlight.AnchorPoint:Show();
		else
			highlight.AnchorPoint:Hide();
		end
	end
end

AnchorHighlightMixin = {};

function AnchorHighlightMixin:RetrieveAnchorHighlight(pointIndex)
	if not self.AnchorHighlights then
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate1", self, "FrameStackAnchorHighlightTemplate");
	end

	while pointIndex > #self.AnchorHighlights do
		CreateFrame("FRAME", "FrameStackAnchorHighlightTemplate"..(#self.AnchorHighlights + 1), self, "FrameStackAnchorHighlightTemplate");
	end

	return self.AnchorHighlights[pointIndex];
end

function AnchorHighlightMixin:HighlightFrame(baseFrame, showAnchors)
	AnchorHighlight(baseFrame, self);

	local pointIndex = 1;
	if (showAnchors and baseFrame.GetNumPoints and baseFrame.GetPoint) then -- TODO: Fix for lines
		while pointIndex <= baseFrame:GetNumPoints() do
			local _, anchorFrame, anchorRelativePoint = baseFrame:GetPoint(pointIndex);
			AnchorHighlight(anchorFrame, self:RetrieveAnchorHighlight(pointIndex), anchorRelativePoint);
			pointIndex = pointIndex + 1;
		end
	end

	while self.AnchorHighlights and self.AnchorHighlights[pointIndex] do
		self.AnchorHighlights[pointIndex]:Hide();
		pointIndex = pointIndex + 1;
	end
end

FRAMESTACK_UPDATE_TIME = .1

function FrameStackTooltip_OnUpdate(self)
	KeyCommand_Update(self.commandKeys);

	local now = GetTime();
	if now >= self.nextUpdate or self.highlightIndexChanged ~= 0 then
		self.nextUpdate = now + FRAMESTACK_UPDATE_TIME;
		self.highlightFrame = self:SetFrameStack(self.showHidden, self.showRegions, self.highlightIndexChanged);
		self.highlightIndexChanged = 0;
		if self.highlightFrame and FrameStackTooltip_IsHighlightEnabled() then
			FrameStackHighlight:HighlightFrame(self.highlightFrame, self.showAnchors);
		end
	end

end

function FrameStackTooltip_OnShow(self)
	local parent = self:GetParent() or UIParent;
	local ps = parent:GetEffectiveScale();
	local px, py = parent:GetCenter();
	px, py = px * ps, py * ps;
	local x, y = GetCursorPosition();
	self:ClearAllPoints();
	if (x > px) then
		if (y > py) then
			self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 20, 20);
		else
			self:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, -20);
		end
	else
		if (y > py) then
			self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 20);
		else
			self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -20);
		end
	end

	self:TriggerEvent(self.Event.FrameStackOnShow);
end

function FrameStackTooltip_OnHide(self)
	self:TriggerEvent(self.Event.FrameStackOnHide);
end

function FrameStackTooltip_OnTooltipCleared(self)
	self:TriggerEvent(self.Event.FrameStackOnTooltipCleared);
end

FrameStackTooltip_OnEnter = FrameStackTooltip_OnShow;

local DebugHighlightColors = {
	CreateColor(0.1, 0.0, 0.0, 0.5),
	CreateColor(0.0, 0.1, 0.0, 0.5),
	CreateColor(0.0, 0.0, 0.1, 0.5),
	CreateColor(0.1, 0.1, 0.0, 0.5),
	CreateColor(0.1, 0.1, 0.1, 0.5),
};

local function GetDebugIdentifierLevel(debugIdentifierFrame)
	local debugIdentifierLevel = 1;
	local parent = debugIdentifierFrame:GetParent();
	while parent and parent.DebugHighlight ~= nil do
		debugIdentifierLevel = debugIdentifierLevel + 1;
		parent = parent:GetParent();
	end

	return debugIdentifierLevel;
end

function DebugIdentifierFrame_OnLoad(self)
	if self.DebugName then
		local debugNameText = string.gsub(self:GetDebugName(), "[.]", " ");
		self.DebugName:SetText(debugNameText);

		C_Timer.After(0.05, function ()
			local extraWidth = 10;
			while (self.DebugName:IsTruncated()) do
				self.DebugName:SetPoint("LEFT", -extraWidth, 0);
				self.DebugName:SetPoint("RIGHT", extraWidth, 0);
				extraWidth = extraWidth + 10;
			end
		end);
	end

	local debugIdentifierLevel = GetDebugIdentifierLevel(self);
	local debugHighlightColor = DebugHighlightColors[math.min(debugIdentifierLevel, #DebugHighlightColors)];
	self.DebugHighlight:SetColorTexture(debugHighlightColor:GetRGBA());
end

-- for checking that deprecated functions returns the same info as the original version
function CompareFunctionReturns(func1, func2, ...)
	local ret1 = { func1(...) };
	local ret2 = { func2(...) };
	local size = max(#ret1, #ret2);
	local allPassed = true;
	for i = 1, size do
		if ret1[i] == ret2[i] then
			print("["..i.."] pass");
		else
			print("["..i.."] "..RED_FONT_COLOR_CODE.."fail");
			print(ret1[i]);
			print(ret2[i]);
			allPassed = false;
		end
	end
	if allPassed then
		print("=== PASS ===");
	else
		print("=== " ..RED_FONT_COLOR_CODE.."FAIL"..FONT_COLOR_CODE_CLOSE.." ===");
	end
end