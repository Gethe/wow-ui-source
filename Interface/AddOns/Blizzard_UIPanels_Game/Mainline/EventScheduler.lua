local function GetEventPOI(uiMapID, areaPoiID)
	local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
	if poiInfo then
		-- Stopgap to ensure that events don't contain widgets that are only intended for map display
		if poiInfo.tooltipWidgetSet == 1016 then
			poiInfo.tooltipWidgetSet = 1481;
			poiInfo.description = nil;
		end
	end

	return poiInfo;
end

local function ShouldShowTimeLeftInTooltip(poiInfo)
	if poiInfo.tooltipWidgetSet == 1355 then
		return false;
	end
	return true;
end

local function ShouldHideRewardedEvents()
	-- return GetCVarBool("hideRewardedEvents");
	return false; -- remove this when issues are addressed
end

local SCHEDULED_EVENTS_INDENT = 16;
local ELEMENT_SPACING = 3;
local SCHEDULED_ENTRY_HEIGHT = nil;		-- calculated when first needed
local SCHEDULED_HEADER_SPACING = 8;		-- spacing from header to first event
local MAX_UPDATE_TIMER_DURATION = 60 * 60 * 24;		-- one day

local EntryType = EnumUtil.MakeEnum(
	"OngoingHeader",
	"OngoingEvent",
	"ScheduledHeader",
	"ScheduledEvent",
	"Date",
	"HiddenEventsLabel",
	"NoEventsLabel"
);

local AnimState = EnumUtil.MakeEnum(
	"Pending",
	"Playing",
	"Finished"
);

local AnimType = EnumUtil.MakeEnum(
	"Started",
	"Expired"
);

local s_templates = {
	[EntryType.OngoingHeader] = "EventSchedulerOngoingHeaderTemplate",
	[EntryType.OngoingEvent] = "EventSchedulerOngoingEntryTemplate",
	[EntryType.ScheduledHeader] = "EventSchedulerScheduledHeaderTemplate",
	[EntryType.ScheduledEvent] = "EventSchedulerScheduledEntryTemplate",
	[EntryType.Date] = "EventSchedulerDateLabelTemplate",
	[EntryType.HiddenEventsLabel] = "EventSchedulerHiddenEventsLabelTemplate",
	[EntryType.NoEventsLabel] = "EventSchedulerNoEventsLabelTemplate",
};

local s_templateInfoCache = CreateTemplateInfoCache();

local eventSecondsFormatter = CreateFromMixins(SecondsFormatterMixin);
eventSecondsFormatter:Init(0, SecondsFormatter.Abbreviation.None, true, true);

EventSchedulerAnimationManager = { anims = { }; };

-- until the UI is reloaded, an event can only have one anim of each type
function EventSchedulerAnimationManager:AddAnim(eventKey, animType)
	if not self:HasAnim(eventKey, animType) then
		table.insert(self.anims, { eventKey = eventKey, animType = animType, animState = AnimState.Pending, elapsedTime = 0 });
		return true;
	end
	return false;
end

function EventSchedulerAnimationManager:GetAnim(eventKey, animType)
	for i, anim in ipairs(self.anims) do
		if anim.eventKey == eventKey and anim.animType == animType then
			return anim;
		end
	end
end

function EventSchedulerAnimationManager:HasAnim(eventKey, animType)
	return self:GetAnim(eventKey, animType) and true or false;
end

function EventSchedulerAnimationManager:HasActiveAnim(eventKey, animType)
	local anim = self:GetAnim(eventKey, animType);
	return anim and anim.animState ~= AnimState.Finished;
end

function EventSchedulerAnimationManager:UpdateAnimElapsedTime(eventKey, animType, elapsedTime)
	local anim = self:GetAnim(eventKey, animType);
	if anim and anim.animState == AnimState.Playing then
		anim.elapsedTime = elapsedTime;
	end
end

function EventSchedulerAnimationManager:FinishAnim(eventKey, animType)
	local anim = self:GetAnim(eventKey, animType);
	if anim and anim.animState == AnimState.Playing then
		anim.animState = AnimState.Finished;
	end
end

function EventSchedulerAnimationManager:FinishAllAnims()
	for i, anim in ipairs(self.anims) do
		anim.animState = AnimState.Finished;
	end	
end

function EventSchedulerAnimationManager:HasPlayingAnims()
	for i, anim in ipairs(self.anims) do
		if anim.animState == AnimState.Playing then
			return true;
		end
	end
	return false;
end

function EventSchedulerAnimationManager:PlayNextAnimation(scrollBox)
	-- want all expired to play together, then all started
	local haveExpired = false;
	for i, anim in ipairs(self.anims) do
		if anim.animState == AnimState.Pending or anim.animState == AnimState.Playing then
			local frame = self:GetEventFrame(scrollBox, anim.eventKey);
			if frame then
				if anim.animType == AnimType.Expired then
					anim.animState = AnimState.Playing;
					frame:PlayExpiredAnim(anim.elapsedTime);
					haveExpired = true;
				elseif not haveExpired and anim.animType == AnimType.Started then
					anim.animState = AnimState.Playing;
					frame:PlayStartedAnim(anim.elapsedTime);
				end
			else
				anim.animState = AnimState.Finished;
			end
		end
	end
end

function EventSchedulerAnimationManager:GetEventFrame(scrollBox, eventKey)
	local frame = scrollBox:FindFrameByPredicate(function(button, elementData)
		local eventInfo = elementData.data.eventInfo;
		return eventInfo and eventInfo.eventKey == eventKey;
	end);
	return frame;
end

-- for tools
function EventSchedulerAnimationManager:ClearAnims(eventKey)
	for i = #self.anims, 1, -1 do
		local anim = self.anims[i];
		if anim.eventKey == eventKey then
			table.remove(self.anims, i);
		end
	end
end

function EventSchedulerAnimationManager:ClearAllAnims()
	wipe(self.anims);
end

EventSchedulerMixin = { };

function EventSchedulerMixin:OnLoad()
	local indent = 0;
	local topPadding = 3;
	local bottomPadding = 15;
	local leftPadding = 8;
	local rightPadding = 5;
	local elementSpacing = ELEMENT_SPACING;
	local view = CreateScrollBoxListTreeListView(indent, topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	view:SetVirtualized(false);

	view:SetElementFactory(function(factory, node)
		local data = node:GetData();

		local function Initializer(frame)
			frame.owner = self;
			frame:Init(data);
		end
		factory(s_templates[data.entryType], Initializer);
	end);

	view:SetElementIndentCalculator(function(elementData)
		if elementData.data.entryType == EntryType.ScheduledEvent then
			return SCHEDULED_EVENTS_INDENT;
		else
			return 0;
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	-- settings dropdown
	do
		local function IsSelected()
			return GetCVarBool("hideRewardedEvents");
		end

		local function SetSelected()
			-- Restore when issues are addressed
			-- SetCVar("hideRewardedEvents", not IsSelected());
			-- self:Refresh();
		end

		self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_QUEST_MAP_FRAME_SETTINGS");
			local checkbox = rootDescription:CreateCheckbox(EVENT_SCHEDULER_HIDE_REWARDED_EVENTS, IsSelected, SetSelected);
			checkbox:AddInitializer(function(frame, description, menu)
				local fontString = frame.fontString;
				fontString:SetSize(168, 0);
				fontString:SetMaxLines(4);
			end);
		end);
	end
end

function EventSchedulerMixin:OnShow()
	self:RegisterEvent("EVENT_SCHEDULER_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	C_EventScheduler.RequestEvents();
	self:Refresh();
end

function EventSchedulerMixin:OnHide()
	self:UnregisterEvent("EVENT_SCHEDULER_UPDATE");
	self:UnregisterEvent("QUEST_LOG_UPDATE");
	self:CancelTimer();
	EventSchedulerAnimationManager:FinishAllAnims();
end

function EventSchedulerMixin:OnEvent(event)
	self:Refresh();
end

function EventSchedulerMixin:CancelTimer()
	if self.timer then
		self.timer:Cancel();
		self.timer = nil;
	end
end

function EventSchedulerMixin:AddOngoingEvents(dataProvider, ongoingEvents, hideRewardedEvents)
	if not ongoingEvents or not TableHasAnyEntries(ongoingEvents) then
		return;
	end

	local data = { entryType = EntryType.OngoingHeader };
	local categorySubtree = dataProvider:Insert(data);
	for i, eventInfo in ipairs(ongoingEvents) do
		if not hideRewardedEvents or not eventInfo.rewardsClaimed then
			local uiMapID = nil;
			local poiInfo = GetEventPOI(uiMapID, eventInfo.areaPoiID);
			if poiInfo then
				local eventData = { entryType = EntryType.OngoingEvent, poiInfo = poiInfo, eventInfo = eventInfo };
				categorySubtree:Insert(eventData);
			end
		else
			self.numHiddenEvents = self.numHiddenEvents + 1;
		end
	end
	-- if nothing is showing because it's all hidden
	local entryCount = categorySubtree:GetSize();
	local headerData = categorySubtree:GetData();
	headerData.entryCount = entryCount;
	if entryCount == 0 then
		local noEventsData = { entryType = EntryType.NoEventsLabel, height = 39 };
		categorySubtree:Insert(noEventsData);
	end
end

function EventSchedulerMixin:AddScheduledEvents(dataProvider, scheduledEvents, hideRewardedEvents)
	if not scheduledEvents or not TableHasAnyEntries(scheduledEvents) then
		return nil;
	end

	local timeNow = time();
	local dateNow = date("*t");
	local lastSeenDay = dateNow.yday;	-- the events are already ordered by startTime
	local lastEventData = nil;
	local nextUpdateTime = nil;
	local firstToday = true;
	local firstOfAnyDay = true;
	local numTodayEvents = 0;
	local numFutureEvents = 0;
	local lastUpdateTime = tonumber(C_CVar.GetCVar("eventSchedulerLastUpdate"));

	local data = { entryType = EntryType.ScheduledHeader };
	local categorySubtree = dataProvider:Insert(data);

	for i, eventInfo in ipairs(scheduledEvents) do
		if numFutureEvents < Constants.EventScheduler.SCHEDULED_EVENT_FUTURE_LIMIT then
			local isHidden = hideRewardedEvents and eventInfo.rewardsClaimed;
			if isHidden then
				self.numHiddenEvents = self.numHiddenEvents + 1;
			end

			local showEvent = not isHidden;
			if showEvent and eventInfo.endTime <= timeNow then
				-- expired event, show it only if anim needs to play
				local eventAnimatingOut = EventSchedulerAnimationManager:HasActiveAnim(eventInfo.eventKey, AnimType.Expired);
				if not eventAnimatingOut and eventInfo.endTime > lastUpdateTime then
					eventAnimatingOut = EventSchedulerAnimationManager:AddAnim(eventInfo.eventKey, AnimType.Expired);
				end
				showEvent = eventAnimatingOut;
			end

			if showEvent then
				local uiMapID = nil;
				local info = GetEventPOI(uiMapID, eventInfo.areaPoiID);
				if info then
					local eventDate = date("*t", eventInfo.startTime);
					if eventDate.yday == dateNow.yday then
						numTodayEvents = numTodayEvents + 1;
					end
					if eventDate.yday ~= lastSeenDay then
						if lastEventData then
							lastEventData.lastInSection = true;
						end
						firstToday = false;
						firstOfAnyDay = true;
						lastSeenDay = eventDate.yday;

						local dateLabelData = { entryType = EntryType.Date, date = eventDate };
						categorySubtree:Insert(dateLabelData);
					end

					-- play started anim if startTime was before lastUpdateTime
					if timeNow >= eventInfo.startTime and eventInfo.startTime > lastUpdateTime and eventInfo.endTime > timeNow then
						EventSchedulerAnimationManager:AddAnim(eventInfo.eventKey, AnimType.Started);
					end

					local wantAMPM = true;
					local startTimeText = GameTime_GetFormattedTime(eventDate.hour, eventDate.min, wantAMPM);
					local hasActiveAnim = EventSchedulerAnimationManager:HasActiveAnim(eventInfo.eventKey, AnimType.Started);
					local active = timeNow >= eventInfo.startTime and timeNow < eventInfo.endTime and not hasActiveAnim;
					local eventData = {
						entryType = EntryType.ScheduledEvent,
						poiInfo = info,
						eventInfo = eventInfo,
						startTimeText = startTimeText,
						firstToday = firstToday,
						firstOfAnyDay = firstOfAnyDay,
						active = active,
					};
					categorySubtree:Insert(eventData);

					lastEventData = eventData;
					firstToday = false;
					firstOfAnyDay = false;

					if eventInfo.endTime > timeNow then
						numFutureEvents = numFutureEvents + 1;
					end

					if eventInfo.startTime > timeNow and (not nextUpdateTime or eventInfo.startTime < nextUpdateTime) then
						nextUpdateTime = eventInfo.startTime;
					end
					if eventInfo.endTime > timeNow and (not nextUpdateTime or eventInfo.endTime < nextUpdateTime) then
						nextUpdateTime = eventInfo.endTime;
					end
				end
			end
		end
	end

	if lastEventData then
		lastEventData.lastInSection = true;
	end

	local headerData = categorySubtree:GetData();
	headerData.numTodayEvents = numTodayEvents;
	local entryCount = categorySubtree:GetSize();
	headerData.entryCount = entryCount;
	-- if nothing is showing because it's all hidden
	if entryCount == 0 then
		local noEventsData = { entryType = EntryType.NoEventsLabel, height = 35 };
		categorySubtree:Insert(noEventsData);
	end

	return nextUpdateTime;
end

function EventSchedulerMixin:AddAllEvents(dataProvider, ongoingEvents, scheduledEvents)
	local hideRewardedEvents = ShouldHideRewardedEvents();
	self.numHiddenEvents = 0;

	self:AddOngoingEvents(dataProvider, ongoingEvents, hideRewardedEvents);
	local nextUpdateTime = self:AddScheduledEvents(dataProvider, scheduledEvents, hideRewardedEvents);

	-- if there any hidden events, display the count
	if self.numHiddenEvents > 0 then
		local data = { entryType = EntryType.HiddenEventsLabel, count = self.numHiddenEvents };
		dataProvider:InsertAtIndex(data, 1);
	end

	-- set up refresh timer
	if nextUpdateTime then
		local duration = nextUpdateTime - time();
		if duration >= 0 and duration <= MAX_UPDATE_TIMER_DURATION then
			self.timer = C_Timer.NewTimer(duration, function()
				self:Refresh();
			end);
		end
	end
end

function EventSchedulerMixin:Refresh()
	self:CancelTimer();

	local dataProvider = CreateTreeDataProvider();

	local ongoingEvents = C_EventScheduler.GetOngoingEvents();
	local scheduledEvents = C_EventScheduler.GetScheduledEvents();

	-- show the loading frame while waiting on server response, and empty text if there were no events
	if not ongoingEvents and not scheduledEvents then
		if C_EventScheduler.HasData() then
			self.LoadingFrame:Hide();
			self.ScrollBox.EmptyText:Show();
		else
			self.LoadingFrame:Show();
			self.ScrollBox.EmptyText:Hide();
		end
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
		return;
	else
		self.LoadingFrame:Hide();
		self.ScrollBox.EmptyText:Hide();
	end

	self:AddAllEvents(dataProvider, ongoingEvents, scheduledEvents);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	EventSchedulerAnimationManager:PlayNextAnimation(self.ScrollBox);

	C_CVar.SetCVar("eventSchedulerLastUpdate", time());
end

function EventSchedulerMixin:OnAnimationFinished(eventKey, animType)
	EventSchedulerAnimationManager:FinishAnim(eventKey, animType);
	if not EventSchedulerAnimationManager:HasPlayingAnims() then
		self:Refresh();
	end
end

EventSchedulerBaseEntryMixin = { };

function EventSchedulerBaseEntryMixin:OnEnter()
	self:UpdateTooltip();
	if not self:HasRewardsClaimed() then
		self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.Location:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
	self.Highlight:Show();
end

function EventSchedulerBaseEntryMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
	if not self:HasRewardsClaimed() then
		self.Name:SetTextColor(EVENT_SCHEDULER_NAME_COLOR:GetRGB());
		self.Location:SetTextColor(EVENT_SCHEDULER_LOCATION_COLOR:GetRGB());
	end
	self.Highlight:Hide();
end

function EventSchedulerBaseEntryMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" and upInside then
		if self:HasStarted() then
			OpenMapToEventPoi(self.info.areaPoiID);
		end
	end
end

function EventSchedulerBaseEntryMixin:UpdateTooltip()
	if self.showTimeLeft then
		self.info.secondsLeft = self.eventInfo.endTime - time();
	else
		self.info.secondsLeft = nil;
	end

	AreaPoiUtil.TryShowTooltip(self, "ANCHOR_RIGHT", self.info);
end

function EventSchedulerBaseEntryMixin:HasDisplayName()
	return true;
end

function EventSchedulerBaseEntryMixin:GetDisplayName()
	return self.info.name;
end

function EventSchedulerBaseEntryMixin:HasRewardsClaimed()
	return self.eventInfo.rewardsClaimed;
end

function EventSchedulerBaseEntryMixin:HasStarted()
	return not self.eventInfo.startTime or self.eventInfo.startTime <= time();
end

EventSchedulerOngoingEntryMixin = CreateFromMixins(EventSchedulerBaseEntryMixin);

function EventSchedulerOngoingEntryMixin:Init(data)
	self.info = data.poiInfo;
	self.eventInfo = data.eventInfo;

	self.Name:SetText(self:GetDisplayName());

	local zoneName = C_EventScheduler.GetEventZoneName(self.info.areaPoiID);
	self.Location:SetText(zoneName);

	self.Icon:SetAtlas(self.info.atlasName, TextureKitConstants.UseAtlasSize);

	local hasRewardsClaimed = self:HasRewardsClaimed();
	if hasRewardsClaimed then
		self.Background:SetAtlas("event-scheduler-ongoing-events-card-complete", TextureKitConstants.UseAtlasSize);
		self.Name:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Name:SetWidth(220);
		self.Location:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	else
		self.Background:SetAtlas("event-scheduler-ongoing-events-card-incomplete", TextureKitConstants.UseAtlasSize);
		self.Name:SetTextColor(EVENT_SCHEDULER_NAME_COLOR:GetRGB());
		self.Name:SetWidth(250);
		self.Location:SetTextColor(EVENT_SCHEDULER_LOCATION_COLOR:GetRGB());
	end
	self.CheckIcon:SetShown(hasRewardsClaimed);
end

function EventSchedulerOngoingEntryMixin:OnMouseUp(button, upInside)
	EventSchedulerBaseEntryMixin.OnMouseUp(self, button, upInside);
	if button == "RightButton" and upInside then
		local eventInfo = self.eventInfo;
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("EVENT_SCHEDULER_ONGOING_ENTRY");

			local unused_type, areaPoiID = C_SuperTrack.GetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI);
			if areaPoiID ~= eventInfo.areaPoiID then
				local element = rootDescription:CreateButton(POI_FOCUS, function()
					C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, eventInfo.areaPoiID);
					OpenMapToEventPoi(eventInfo.areaPoiID);
				end);
			else
				rootDescription:CreateButton(POI_REMOVE_FOCUS, function()
					C_SuperTrack.ClearSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI);
				end);
			end
		end);
	end
end

EventSchedulerScheduledEntryMixin = CreateFromMixins(EventSchedulerBaseEntryMixin);

function EventSchedulerScheduledEntryMixin:OnLoad()
	self.StartedAnim:SetScript("OnFinished", function() self:OnStartedAnimFinished(); end);
	self.ExpiredAnim:SetScript("OnFinished", function() self:OnExpiredAnimFinished(); end);
end

function EventSchedulerScheduledEntryMixin:Init(data)
	-- stop any anims, will be restarted by the EventSchedulerAnimationManager after frames are laid out
	if self.eventInfo then
		if self.StartedAnim:IsPlaying() then
			EventSchedulerAnimationManager:UpdateAnimElapsedTime(self.eventInfo.eventKey, AnimType.Started, self.StartedAnim:GetElapsed());
			self.StartedAnim:Stop();
		elseif self.ExpiredAnim:IsPlaying() then
			EventSchedulerAnimationManager:UpdateAnimElapsedTime(self.eventInfo.eventKey, AnimType.Expired, self.ExpiredAnim:GetElapsed());
			self.ExpiredAnim:Stop();
		end
	end

	self.info = data.poiInfo;
	self.eventInfo = data.eventInfo;

	-- data.active also rules out ongoing events, which do not have an active state
	self.showTimeLeft = data.active and ShouldShowTimeLeftInTooltip(self.info);

	if not EventSchedulerAnimationManager:HasAnim(self.eventInfo.eventKey, AnimType.Expired) then
		self:SetAlpha(1);
	end

	self.Name:SetText(self:GetDisplayName());

	local zoneName = C_EventScheduler.GetEventZoneName(self.info.areaPoiID);
	if zoneName then
		self.Location:SetText(EVENT_SCHEDULER_TIME_WITH_LOCATION:format(data.startTimeText, zoneName));
	else
		self.Location:SetText(data.startTimeText);
	end

	self.Icon:SetAtlas(self.info.atlasName, TextureKitConstants.UseAtlasSize);

	self.ReminderIcon:SetShown(self.eventInfo.hasReminder);
	if self.eventInfo.hasReminder then
		self.Name:SetWidth(226);
	else
		self.Name:SetWidth(250);
	end

	self.Background:SetAlpha(data.active and 1 or 0);

	if data.firstOfAnyDay then
		self.Timeline:SetHeight(37);
	else
		self.Timeline:SetHeight(40);
	end

	self.TopDot:SetShown(not data.firstToday and data.firstOfAnyDay);
	self.BottomDotDark:SetShown(data.lastInSection and not data.active);
	self.BottomDotLight:SetShown(data.lastInSection and data.active);
end

function EventSchedulerScheduledEntryMixin:OnMouseUp(button, upInside)
	EventSchedulerBaseEntryMixin.OnMouseUp(self, button, upInside);
	if button == "RightButton" and upInside then
		local eventInfo = self.eventInfo;
		local timeNow = time();
		local timeToEvent = eventInfo.startTime - timeNow;
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("EVENT_SCHEDULER_SCHEDULED_ENTRY");

			local unused_type, areaPoiID = C_SuperTrack.GetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI);
			if areaPoiID ~= eventInfo.areaPoiID then
				local element = rootDescription:CreateButton(POI_FOCUS, function()
					C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, eventInfo.areaPoiID);
					OpenMapToEventPoi(eventInfo.areaPoiID);
				end);
				element:SetEnabled(timeToEvent <= 0);
			else
				rootDescription:CreateButton(POI_REMOVE_FOCUS, function()
					C_SuperTrack.ClearSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI);
				end);
			end

			if eventInfo.hasReminder then
				rootDescription:CreateButton(EVENT_SCHEDULER_CLEAR_REMINDER, function()
					EventSchedulerReminderManager:ClearReminder(eventInfo.eventKey);
				end);
			else
				local element = rootDescription:CreateButton(EVENT_SCHEDULER_SET_REMINDER, function()
					EventSchedulerReminderManager:SetReminder(eventInfo.eventKey);
				end);
				element:SetEnabled(timeToEvent > 0);
			end
		end);
	end
end

function EventSchedulerScheduledEntryMixin:PlayStartedAnim(elapsedTime)
	local reverse = false;
	self.StartedAnim:Play(reverse, elapsedTime);
	local forceNoDuplicates = true;
	PlaySound(SOUNDKIT.UI_EVENT_SCHEDULER_EVENT_ACTIVE, nil, forceNoDuplicates);
end

function EventSchedulerScheduledEntryMixin:OnStartedAnimFinished()
	self.owner:OnAnimationFinished(self.eventInfo.eventKey, AnimType.Started);
end

function EventSchedulerScheduledEntryMixin:PlayExpiredAnim(elapsedTime)
	local reverse = false;
	self.ExpiredAnim:Play(reverse, elapsedTime);
end

function EventSchedulerScheduledEntryMixin:OnExpiredAnimFinished()
	self.owner:OnAnimationFinished(self.eventInfo.eventKey, AnimType.Expired);
end

EventSchedulerBaseLabelMixin = { };

function EventSchedulerBaseLabelMixin:Init(data)
	if data.entryType == EntryType.OngoingHeader then
		self.Label:SetText(EVENT_SCHEDULER_ONGOING_HEADER);
	elseif data.entryType == EntryType.ScheduledHeader then
		self.Label:SetText(EVENT_SCHEDULER_SCHEDULED_HEADER);
		if data.entryCount == 0 then
			self.Timeline:Hide();
		else
			self.Timeline:Show();
			if not SCHEDULED_ENTRY_HEIGHT then
				local templateName = s_templates[EntryType.ScheduledEvent];
				local templateInfo = C_XMLUtil.GetTemplateInfo(templateName);
				SCHEDULED_ENTRY_HEIGHT = templateInfo.height;
			end
			local height;
			local count = data.numTodayEvents;
			if count <= 1 then
				height = SCHEDULED_ENTRY_HEIGHT;
			else
				height = count * SCHEDULED_ENTRY_HEIGHT + (count - 1) * ELEMENT_SPACING;				
			end
			self.Timeline:SetHeight(height + SCHEDULED_HEADER_SPACING);
		end
	elseif data.entryType == EntryType.Date then
		local monthName = CALENDAR_FULLDATE_MONTH_NAMES[data.date.month];
		self.Label:SetFormattedText(EVENT_SCHEDULER_DAY_FORMAT, monthName, data.date.day);
	elseif data.entryType == EntryType.HiddenEventsLabel then
		self.Label:SetFormattedText(EVENT_SCHEDULER_HIDDEN_EVENTS, data.count);
	elseif data.entryType == EntryType.NoEventsLabel then
		self.Label:SetText(EVENT_SCHEDULER_NO_EVENTS);
		self:SetHeight(data.height);
	end
end

EventSchedulerReminderManager = { };

function EventSchedulerReminderManager:SetReminder(eventKey)
	C_EventScheduler.SetReminder(eventKey);
end

function EventSchedulerReminderManager:ClearReminder(eventKey)
	self:ResetWarningForEvent(eventKey);
	C_EventScheduler.ClearReminder(eventKey);
end

function EventSchedulerReminderManager:CanRefresh()
	return not self.blockRefresh;
end

function EventSchedulerReminderManager:SetBlockRefresh(blockRefresh)
	self.blockRefresh = blockRefresh;
end

-- This will keep refreshes from repeating reminders
function EventSchedulerReminderManager:CanDoWarningForEvent(eventKey)
	if not self.warnings then
		self.warnings = { };
	end
	local canWarn = not self.warnings[eventKey];
	self.warnings[eventKey] = true;
	return canWarn;
end

function EventSchedulerReminderManager:ResetWarningForEvent(eventKey)
	if self.warnings then
		self.warnings[eventKey] = nil;
	end
end

function EventSchedulerReminderManager:Refresh()
	if not self:CanRefresh() then
		return;
	end

	if self.timer then
		self.timer:Cancel();
	end

	if not C_EventScheduler.HasSavedReminders() then
		return;
	end

	local scheduledEvents = C_EventScheduler.GetScheduledEvents();
	if not scheduledEvents then
		C_EventScheduler.RequestEvents();
		return;
	end

	self:SetBlockRefresh(true);

--[[
	When to announce events
		If startTime is now or earlier, announce it has started.
		If at SCHEDULED_EVENT_REMINDER_WARNING_SECONDS or less until startTime, announce time left (referred to as warning).
]]--

	local timeNow = time();
	local lowestWaitTime = math.huge;
	local lowestTimeToEvent = math.huge;
	for i, eventInfo in ipairs(scheduledEvents) do
		if eventInfo.hasReminder then
			local timeToEvent = eventInfo.startTime - timeNow;
			if timeToEvent <= 0 then
				self:AnnounceEvent(eventInfo, 0);
				self:ClearReminder(eventInfo.eventKey);
			elseif timeToEvent <= Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_WARNING_SECONDS then
				-- don't bother warning if it's going to start in SCHEDULED_EVENT_REMINDER_DEAD_SECONDS
				if timeToEvent > Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_DEAD_SECONDS then
					-- but if the time is really close to SCHEDULED_EVENT_REMINDER_WARNING_SECONDS, use that for the warning
					-- (so we don't do something like 4 minutes 58 seconds in chat)
					if Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_WARNING_SECONDS - timeToEvent <= Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_DEAD_SECONDS then
						self:AnnounceEvent(eventInfo, Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_WARNING_SECONDS);
					else
						self:AnnounceEvent(eventInfo, timeToEvent);
					end
				end
			else
				timeToEvent = timeToEvent - Constants.EventScheduler.SCHEDULED_EVENT_REMINDER_WARNING_SECONDS;
			end

			if timeToEvent > 0 and timeToEvent < lowestTimeToEvent then
				lowestTimeToEvent = timeToEvent;
			end
		end
	end

	if lowestTimeToEvent < math.huge then	
		self.timer = C_Timer.NewTimer(lowestTimeToEvent, function()
			self:Refresh();
		end);
		-- for debug
		self.timer.runTime = lowestTimeToEvent;
		self.timer.startTime = timeNow;
	else
		self.timer = nil;
	end

	self:SetBlockRefresh(false);
end

function EventSchedulerReminderManager:AnnounceEvent(eventInfo, time)
	if time > 0 and not self:CanDoWarningForEvent(eventInfo.eventKey) then
		return;
	end

	local uiMapID = nil;
	local areaPoiInfo = GetEventPOI(uiMapID, eventInfo.areaPoiID);
	if areaPoiInfo then
		local nameLink = LinkUtil.FormatLink(LinkTypes.EventPOI, "["..areaPoiInfo.name.."]", eventInfo.areaPoiID);
		if time <= 0 then
			ChatFrameUtil.AddSystemMessage(EVENT_SCHEDULER_CHAT_REMINDER_NOW:format(nameLink));
		else
			local timeText = eventSecondsFormatter:Format(time);
			ChatFrameUtil.AddSystemMessage(EVENT_SCHEDULER_CHAT_REMINDER_SOON:format(nameLink, timeText));
		end
		local forceNoDuplicates = true;
		PlaySound(SOUNDKIT.UI_EVENT_SCHEDULER_CHIME, nil, forceNoDuplicates);
	end
end

local function Callback()
	EventSchedulerReminderManager:Refresh();
end
EventUtil.ContinueAfterAllEvents(Callback, "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "FIRST_FRAME_RENDERED");

EventRegistry:RegisterFrameEventAndCallback("EVENT_SCHEDULER_UPDATE", EventSchedulerReminderManager.Refresh, EventSchedulerReminderManager);
