local TIMER_UPDATE_FREQUENCY_SECONDS = 1;

UIWidgetManagerMixin = {}

function UIWidgetManagerMixin:OnLoad()
	self.widgetPools = CreatePoolCollection();

	self.widgetVisTypeInfo = {};
	self.registeredWidgetSetContainers = {};

	self.widgetIdToFrame = {};
	self.widgetSetFrames = {};
	self.timerWidgets = {};

	self.numTimers = 0;

	self.layoutUpdateSetsPending = {};

	self:RegisterEvent("UPDATE_ALL_UI_WIDGETS");
	self:RegisterEvent("UPDATE_UI_WIDGET");
end

function UIWidgetManagerMixin:OnEvent(event, ...)
	if event == "UPDATE_ALL_UI_WIDGETS" then
		self:UpdateAllWidgets();
	elseif event == "UPDATE_UI_WIDGET" then
		self:UpdateWidget(...);
	end
end

function UIWidgetManagerMixin:OnUpdate(elapsed)
	-- Handle layout updates
	if next(self.layoutUpdateSetsPending) then
		-- We have layout updates to do
		-- Make a local copy in case a call to UpdateWidgetSetContainerLayout causes layoutUpdateSetsPending to change
		local pendingList = self.layoutUpdateSetsPending;
		self.layoutUpdateSetsPending = {};

		for setID, _ in pairs(pendingList) do
			self:UpdateWidgetSetContainerLayout(setID);
		end
		
	end
end

function UIWidgetManagerMixin:ReleaseAllWidgets()
	self.widgetPools:ReleaseAll();
end

function UIWidgetManagerMixin:GetWidgetFromPools(templateInfo, parent, resetFunc)
	if templateInfo then
		if not self.widgetPools:GetPool(templateInfo.frameTemplate) then
			self.widgetPools:CreatePool(templateInfo.frameType, parent, templateInfo.frameTemplate, resetFunc);
		end

		return self.widgetPools:Acquire(templateInfo.frameTemplate);
	end
end

function UIWidgetManagerMixin:UpdateTimerList(widgetID, widgetFrame)
	if widgetFrame then
		if not self.timerWidgets[widgetID] then
			-- New timer added
			self.timerWidgets[widgetID] = widgetFrame;

			if not self.ticker then
				self.ticker = C_Timer.NewTicker(TIMER_UPDATE_FREQUENCY_SECONDS, 
					function()
						for id, widget in pairs(self.timerWidgets) do
							self:ProcessWidget(id, widget.widgetSetID, widget.widgetType);
						end
					end);
			end

			self.numTimers = self.numTimers + 1;
		end
	else
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
end

function UIWidgetManagerMixin:CreateWidget(widgetID, widgetSetID, widgetType)
	if self.widgetVisTypeInfo[widgetType] then
		local widgetFrame = self:GetWidgetFromPools(self.widgetVisTypeInfo[widgetType].templateInfo, self.registeredWidgetSetContainers[widgetSetID].widgetContainer, self.registeredWidgetSetContainers[widgetSetID].resetFunc);

		widgetFrame.widgetID = widgetID;
		widgetFrame.widgetSetID = widgetSetID;
		widgetFrame.widgetType = widgetType;
		widgetFrame.hasTimer = false;
		widgetFrame.orderIndex = nil;

		self.widgetIdToFrame[widgetID] = widgetFrame;
		self.widgetSetFrames[widgetSetID][widgetID] = widgetFrame;

		return widgetFrame;
	end
end

function UIWidgetManagerMixin:RemoveWidget(widgetID, widgetSetID)
	local widgetFrame = self.widgetIdToFrame[widgetID];
	if not widgetFrame then
		-- This widget was never created. Nothing to do
		return;
	end

	if widgetFrame.hasTimer then
		self:UpdateTimerList(widgetID, nil);
	end

	self.widgetPools:Release(widgetFrame);
	self.widgetIdToFrame[widgetID] = nil;
	self.widgetSetFrames[widgetSetID][widgetID] = nil;
end

function UIWidgetManagerMixin:IsWidgetTypeSupported(widgetType)
	if self.widgetVisTypeInfo[widgetType] then
		return true;
	else
		return false;
	end
end

local function SortWidgets(a, b)
	if a.orderIndex == b.orderIndex then
		return a.widgetID < b.widgetID;
	else
		return a.orderIndex < b.orderIndex;
	end
end

function UIWidgetManagerMixin:UpdateWidgetSetContainerLayout(widgetSetID)
	if self.registeredWidgetSetContainers[widgetSetID].layoutFunc then
		local sortedWidgets = {};
		for _, widget in pairs(self.widgetSetFrames[widgetSetID]) do
			table.insert(sortedWidgets, widget);
		end

		table.sort(sortedWidgets, SortWidgets);

		self.registeredWidgetSetContainers[widgetSetID].layoutFunc(self.registeredWidgetSetContainers[widgetSetID].widgetContainer, sortedWidgets);
	end
end

function UIWidgetManagerMixin:ScheduleUpdateWidgetSetLayout(widgetSetID)
	-- Layout will be updated next frame in the OnUpdate
	self.layoutUpdateSetsPending[widgetSetID] = true;
end

-- This function returns true if the widget set layout function needs to be run.
-- This occurs if we create a widget, remove a widget or the orderIndex changes on an existing widget
function UIWidgetManagerMixin:ProcessWidget(widgetID, widgetSetID, widgetType)
	if self:IsWidgetTypeSupported(widgetType) and self.registeredWidgetSetContainers[widgetSetID] then
		local widgetFrame = self.widgetIdToFrame[widgetID];
		local widgetAlreadyExisted = (widgetFrame ~= nil);

		local oldOrderIndex;
		local isNewWidget = false;

		local widgetInfo = self.widgetVisTypeInfo[widgetType].visInfoDataFunction(widgetID);

		if widgetAlreadyExisted then
			-- Widget already existed
			if not widgetInfo then
				-- widgetInfo is nil, indicating it should no longer be shown...remove it and return true (indicating that the set needs to have the layout function run)
				self:RemoveWidget(widgetID, widgetSetID);
				return true;
			end

			-- Otherwise the widget should still show...save the current orderIndex so we can determine if it changes after Setup is run
			oldOrderIndex = widgetFrame.orderIndex;
		else
			-- Widget did not already exist
			if widgetInfo then
				-- And it should be shown...create it
				widgetFrame = self:CreateWidget(widgetID, widgetSetID, widgetType);

				-- If this is a widget with a timer, update the timer list
				if widgetInfo.hasTimer then
					self:UpdateTimerList(widgetID, widgetFrame);
				end

				-- If there is an init function, run it
				if self.registeredWidgetSetContainers[widgetSetID].initFunc then
					self.registeredWidgetSetContainers[widgetSetID].initFunc(widgetFrame);
				end

				isNewWidget = true;
			else
				-- Widget should not be shown. It didn't already exist so there is nothing to do. Return false (indicating that the set does NOT need to have the layout function run)
				return false;
			end
		end

		-- Ok we are now SURE that this widget should be shown and we have a frame for it

		-- Run the Setup function on the widget (could change the orderIndex)
		widgetFrame:Setup(widgetInfo);

		if isNewWidget and widgetFrame.OnAcquired then
			widgetFrame:OnAcquired(widgetInfo)
		end

		-- Determine if the order index changed
		if oldOrderIndex ~= widgetFrame.orderIndex then
			-- Either this is a new widget (oldOrderIndex would be nil) or the orderIndex changed on this widget...we need to re-layout
			return true;
		end
	end

	return false;
end

function UIWidgetManagerMixin:ProcessWidgetSet(widgetSetID)
	local setWidgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
	for _, widgetInfo in ipairs(setWidgets) do
		self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetSetID, widgetInfo.widgetType);
	end

	self:UpdateWidgetSetContainerLayout(widgetSetID);
end

function UIWidgetManagerMixin:UpdateWidget(widgetInfo)
	local updateLayout = self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetSetID, widgetInfo.widgetType);

	if updateLayout then
		self:ScheduleUpdateWidgetSetLayout(widgetInfo.widgetSetID);
	end
end

function UIWidgetManagerMixin:UpdateAllWidgets()
	self.widgetIdToFrame = {};
	self.timerWidgets = {};

	self:ReleaseAllWidgets();

	-- Re-process any widgets in currently registered containers
	for widgetSetID, _ in pairs(self.registeredWidgetSetContainers) do
		self.widgetSetFrames[widgetSetID] = {};
		self:ProcessWidgetSet(widgetSetID);
	end
end

-- widgetContainer will be used as the parent for all widgets created within that system. It can be nil if you want, and parenting can be done in widgetInitFunction or widgetLayoutFunction instead 
-- widgetLayoutFunction should take 2 arguments (the widget container passed in above and a sequence containing all widgetFrames belonging to that widgetSet, sorted by orderIndex). It can update the layout of the widgets & widgetContainer as it sees fit. 
--		IMPORTANT: widgetLayoutFunction is called every time any widget in this container is shown, hidden or re-ordered
-- widgetInitFunction should take 1 argument (the widgetFrame). It should do anything needed for initialization of widgets by the registering system. It is called only once, when a widget is initialized (when entering a new map/area/subarea/phase)
-- widgetResetFunction should take 2 arguments (the framePool and the widgetFrame). It should do anything needed for resetting the widgets when they get hidden. If nil is passed, FramePool_HideAndClearAnchors is used
-- Any or all of them can be nil if your system doesn't need that functionaility (although at the very least widgetLayoutFunction should be set in almost all circumstances)
function UIWidgetManagerMixin:RegisterWidgetSetContainer(widgetSetID, widgetContainer, widgetLayoutFunction, widgetInitFunction, widgetResetFunction)
	if self.registeredWidgetSetContainers[widgetSetID] then
		-- Someone already registered for this set, so do nothing
		return;
	end

	self.registeredWidgetSetContainers[widgetSetID] = { widgetContainer = widgetContainer, layoutFunc = widgetLayoutFunction, initFunc = widgetInitFunction, resetFunc = widgetResetFunction };
	self.widgetSetFrames[widgetSetID] = {};

	self:ProcessWidgetSet(widgetSetID);
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
