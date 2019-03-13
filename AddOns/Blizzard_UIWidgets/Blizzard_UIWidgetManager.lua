local TIMER_UPDATE_FREQUENCY_SECONDS = 1;

local WIDGET_DEBUG_TEXTURE_SHOW = false;
local WIDGET_DEBUG_TEXTURE_COLOR = CreateColor(0.1, 1.0, 0.1, 0.6);
local WIDGET_CONTAINER_DEBUG_TEXTURE_SHOW = false;
local WIDGET_CONTAINER_DEBUG_TEXTURE_COLOR = CreateColor(1.0, 0.1, 0.1, 0.6);
local WIDGET_DEBUG_CUSTOM_TEXTURE_COLOR = CreateColor(1.0, 1.0, 0.0, 0.6);

UIWidgetContainerMixin = {}

function UIWidgetContainerMixin:OnLoad()
	self.widgetPools = CreateFramePoolCollection();

	if WIDGET_CONTAINER_DEBUG_TEXTURE_SHOW then
		self._debugBGTex = self:CreateTexture()
		self._debugBGTex:SetColorTexture(WIDGET_CONTAINER_DEBUG_TEXTURE_COLOR:GetRGBA());
		self._debugBGTex:SetAllPoints(self);
	end
end

function UIWidgetContainerMixin:OnEvent(event, ...)
	if event == "UPDATE_ALL_UI_WIDGETS" then
		self:ProcessAllWidgets();
	elseif event == "UPDATE_UI_WIDGET" then
		local widgetInfo = ...;
		if widgetInfo.widgetSetID == self.widgetSetID then
			self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
		end
	end
end

function UIWidgetContainerMixin:OnUpdate(elapsed)
	-- Handle layout updates
	if self.dirtyLayout then
		self:UpdateWidgetLayout();
	end
end

function DefaultWidgetLayout(widgetContainerFrame, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 1;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP", widgetContainerFrame, "TOP", 0, 0);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, 0);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight();

		local widgetWidth = widgetFrame:GetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
	end

	widgetContainerFrame:SetHeight(math.max(widgetsHeight, 1));
	widgetContainerFrame:SetWidth(maxWidgetWidth);
end

-- widgetLayoutFunction should take 2 arguments (this widget container and a sequence containing all widgetFrames belonging to that widgetSet, sorted by orderIndex). It can update the layout of the widgets & widgetContainer as it sees fit. 
--		IMPORTANT: widgetLayoutFunction is called every time any widget in this container is shown, hidden or re-ordered. If nil is passed DefaultWidgetLayout is used
-- widgetInitFunction should take 1 argument (the widgetFrame). It should do anything needed for initialization of widgets by the registering system. It is called only once, when a widget is initialized (when entering a new map/area/subarea/phase)
-- Either can be nil if your system doesn't need that functionaility
--
-- Calling RegisterForWidgetSet on a container that is already registered to a different WidgetSet will cause the old WidgetSet to get unregistered and the new one to take its place
-- Calling RegisterForWidgetSet with a nil widgetSetID is the same as just calling UnregisterForWidgetSet
function UIWidgetContainerMixin:RegisterForWidgetSet(widgetSetID, widgetLayoutFunction, widgetInitFunction)
	if self.widgetSetID then
		-- We are already registered to a WidgetSet
		if self.widgetSetID == widgetSetID then
			-- And it's the same WidgetSet we are trying to register again...nothing to do
			return;
		else
			-- We are already registered for a different WidgetSet...unregister it
			self:UnregisterForWidgetSet();
		end
	end

	if not widgetSetID then
		return;
	end

	self.widgetSetID = widgetSetID;
	self.layoutFunc = widgetLayoutFunction or DefaultWidgetLayout;
	self.initFunc = widgetInitFunction;
	self.widgetFrames = {};
	self.timerWidgets = {};
	self.numTimers = 0;

	self:ProcessAllWidgets();

	if self.showAndHideOnWidgetSetRegistration then
		self:Show();
	end

	self:RegisterEvent("UPDATE_ALL_UI_WIDGETS");
	self:RegisterEvent("UPDATE_UI_WIDGET");

	UIWidgetManager:OnWidgetContainerRegistered(self);
end

function UIWidgetContainerMixin:UnregisterForWidgetSet()
	if not self.widgetSetID then
		-- We are not registered to a WidgetSet...nothing to do
		return;
	end

	-- Remove all widgets from this widget container
	self:RemoveAllWidgets();
	self:UpdateWidgetLayout();

	-- And clear everything else
	self.widgetSetID = nil;
	self.layoutFunc = nil;
	self.initFunc = nil;
	self.dirtyLayout = nil;

	if self.showAndHideOnWidgetSetRegistration then
		self:Hide();
	end

	self:UnregisterEvent("UPDATE_ALL_UI_WIDGETS");
	self:UnregisterEvent("UPDATE_UI_WIDGET");

	UIWidgetManager:OnWidgetContainerUnregistered(self);
end

function UIWidgetContainerMixin:RegisterTimerWidget(widgetID, widgetFrame)
	if not self.timerWidgets[widgetID] then
		-- New timer added
		self.timerWidgets[widgetID] = widgetFrame;

		if not self.ticker then
			self.ticker = C_Timer.NewTicker(TIMER_UPDATE_FREQUENCY_SECONDS, 
				function()
					for id, widget in pairs(self.timerWidgets) do
						self:ProcessWidget(id, widget.widgetType);
					end
				end);
		end

		self.numTimers = self.numTimers + 1;
	end
end

function UIWidgetContainerMixin:UnregisterTimerWidget(widgetID)
	if self.timerWidgets[widgetID] then
		-- Existing timer removed
		self.timerWidgets[widgetID] = nil;

		self.numTimers = self.numTimers - 1;

		if self.numTimers == 0 and self.ticker then
			self.ticker:Cancel();
			self.ticker = nil;
		end
	end
end

function UIWidgetContainerMixin:GatherWidgetsByWidgetTag(widgetArray, widgetTag)
	for _, widgetFrame in pairs(self.widgetFrames) do
		if widgetTag == widgetFrame.widgetTag then
			table.insert(widgetArray, widgetFrame);
		end
	end
end

function UIWidgetContainerMixin:RemoveAllWidgets()
	self.widgetFrames = {};
	self.timerWidgets = {};
	self.numTimers = 0;

	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end

	self.widgetPools:ReleaseAll();
end

function UIWidgetContainerMixin:RemoveWidget(widgetID)
	local widgetFrame = self.widgetFrames[widgetID];
	if not widgetFrame then
		-- This widget was never created. Nothing to do
		return;
	end

	-- If this is a widget with a timer, remove it from the timer list
	if widgetFrame.hasTimer then
		self:UnregisterTimerWidget(widgetID);
	end

	self.widgetPools:Release(widgetFrame);
	self.widgetFrames[widgetID] = nil;

	-- The layout is dirty
	self.dirtyLayout = true;
end

local function ResetWidget(pool, widgetFrame)
	widgetFrame:OnReset();
end

function UIWidgetContainerMixin:GetWidgetFromPools(templateInfo)
	if templateInfo then
		if not self.widgetPools:GetPool(templateInfo.frameTemplate) then
			self.widgetPools:CreatePool(templateInfo.frameType, self, templateInfo.frameTemplate, ResetWidget);
		end

		local widgetFrame = self.widgetPools:Acquire(templateInfo.frameTemplate);
		widgetFrame:SetParent(self);
		return widgetFrame;
	end
end

function UIWidgetContainerMixin:CreateWidget(widgetID, widgetType, widgetTypeInfo, widgetInfo)
	local widgetFrame = self:GetWidgetFromPools(widgetTypeInfo.templateInfo);

	widgetFrame.widgetID = widgetID;
	widgetFrame.widgetSetID = self.widgetSetID;
	widgetFrame.widgetType = widgetType;
	widgetFrame.hasTimer = widgetInfo.hasTimer;
	widgetFrame.orderIndex = widgetInfo.orderIndex;
	widgetFrame.widgetTag = widgetInfo.widgetTag;
	widgetFrame:EnableMouse(true);

	-- If this is a widget with a timer, add it from the timer list
	if widgetFrame.hasTimer then
		self:RegisterTimerWidget(widgetID, widgetFrame);
	end

	-- If there is an init function, run it
	if self.initFunc then
		self.initFunc(widgetFrame);
	end

	self.widgetFrames[widgetID] = widgetFrame;

	return widgetFrame;
end

function UIWidgetContainerMixin:ProcessWidget(widgetID, widgetType)
	local widgetTypeInfo = UIWidgetManager:GetWidgetTypeInfo(widgetType);
	if not widgetTypeInfo then
		-- This WidgetType is not supported (nothing called RegisterWidgetVisTypeTemplate for it)
		return;
	end

	local widgetInfo = widgetTypeInfo.visInfoDataFunction(widgetID);

	local widgetFrame = self.widgetFrames[widgetID];
	local widgetAlreadyExisted = (widgetFrame ~= nil);

	local oldOrderIndex;
	local isNewWidget = false;

	if widgetAlreadyExisted then
		-- Widget already existed
		if not widgetInfo then
			-- widgetInfo is nil, indicating it should no longer be shown...remove it
			self:RemoveWidget(widgetID);
			return;
		end

		-- Otherwise the widget should still show...save the current orderIndex so we can determine if it changes after Setup is run
		oldOrderIndex = widgetFrame.orderIndex;
	else
		-- Widget did not already exist
		if widgetInfo then
			-- And it should be shown...create it
			widgetFrame = self:CreateWidget(widgetID, widgetType, widgetTypeInfo, widgetInfo);
			isNewWidget = true;
		else
			-- Widget should not be shown. It didn't already exist so there is nothing to do
			return;
		end
	end

	-- Ok we are now SURE that this widget should be shown and we have a frame for it

	-- Run the Setup function on the widget (could change the orderIndex)
	widgetFrame:Setup(widgetInfo);

	if WIDGET_DEBUG_TEXTURE_SHOW then
		if not widgetFrame._debugBGTex then
			widgetFrame._debugBGTex = widgetFrame:CreateTexture()
			widgetFrame._debugBGTex:SetColorTexture(WIDGET_DEBUG_TEXTURE_COLOR:GetRGBA());
			widgetFrame._debugBGTex:SetAllPoints(widgetFrame);
		end

		if widgetFrame.CustomDebugSetup then
			widgetFrame:CustomDebugSetup(WIDGET_DEBUG_CUSTOM_TEXTURE_COLOR);
		end
	end

	if isNewWidget and widgetFrame.OnAcquired then
		widgetFrame:OnAcquired(widgetInfo)
	end

	-- Determine if the order index changed
	if oldOrderIndex ~= widgetFrame.orderIndex then
		-- Either this is a new widget (oldOrderIndex would be nil) or the orderIndex changed on this widget...the layout is dirty
		self.dirtyLayout = true;
	end
end

function UIWidgetContainerMixin:ProcessAllWidgets()
	self:RemoveAllWidgets();

	local setWidgets = C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID);
	for _, widgetInfo in ipairs(setWidgets) do
		self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
	end

	self:UpdateWidgetLayout();
end

local function SortWidgets(a, b)
	if a.orderIndex == b.orderIndex then
		return a.widgetID < b.widgetID;
	else
		return a.orderIndex < b.orderIndex;
	end
end

function UIWidgetContainerMixin:UpdateWidgetLayout()
	local sortedWidgets = {};
	for _, widget in pairs(self.widgetFrames) do
		table.insert(sortedWidgets, widget);
	end

	table.sort(sortedWidgets, SortWidgets);

	self:layoutFunc(sortedWidgets);
	self.dirtyLayout = false;
end

UIWidgetManagerMixin = {};

function UIWidgetManagerMixin:OnLoad()
	self.widgetVisTypeInfo = {};
	self.registeredWidgetContainers = {};
end

function UIWidgetManagerMixin:OnWidgetContainerRegistered(widgetContainer)
	self.registeredWidgetContainers[widgetContainer] = true;
end

function UIWidgetManagerMixin:OnWidgetContainerUnregistered(widgetContainer)
	self.registeredWidgetContainers[widgetContainer] = nil;
end

function UIWidgetManagerMixin:GetWidgetTypeInfo(widgetType)
	return self.widgetVisTypeInfo[widgetType];
end

-- templateInfo should be a table that contains 2 entries (frameType and frameTemplate)
-- visInfoDataFunction should be a function that gets the widget visInfo object. It should return this visInfo object. If something in the data indicates the widget should not show it should return nil.
function UIWidgetManagerMixin:RegisterWidgetVisTypeTemplate(visType, templateInfo, visInfoDataFunction)
	if not visType or not templateInfo or not templateInfo.frameType or not templateInfo.frameTemplate or not visInfoDataFunction then
		-- All these things are required
		return;
	end

	if self.widgetVisTypeInfo[visType] then
		-- Someone already registered for this visType, so do nothing
		return;
	end

	self.widgetVisTypeInfo[visType] = { templateInfo = templateInfo, visInfoDataFunction = visInfoDataFunction };
end

-- This function will return an enumerator for all currently-visible widgets that are flagged with the passed widgetTag.
-- Example use:
-- for index, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag("myTag") do
--    -- YOUR CODE
-- end
function UIWidgetManagerMixin:EnumerateWidgetsByWidgetTag(widgetTag)
	local widgetFrames = {};
	for widgetContainer in pairs(self.registeredWidgetContainers) do
		widgetContainer:GatherWidgetsByWidgetTag(widgetFrames, widgetTag);
	end

	return pairs(widgetFrames);
end

