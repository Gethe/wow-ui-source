local TIMER_UPDATE_FREQUENCY_SECONDS = 1;

local WIDGET_DEBUG_TEXTURE_SHOW = false;
local WIDGET_DEBUG_TEXTURE_COLOR = CreateColor(0.1, 1.0, 0.1, 0.6);
local WIDGET_CONTAINER_DEBUG_TEXTURE_SHOW = false;
local WIDGET_CONTAINER_DEBUG_TEXTURE_COLOR = CreateColor(1.0, 0.1, 0.1, 0.6);
local WIDGET_DEBUG_CUSTOM_TEXTURE_COLOR = CreateColor(1.0, 1.0, 0.0, 0.6);

UIWidgetHorizontalWidgetContainerMixin = {};

function UIWidgetHorizontalWidgetContainerMixin:OnLoad()
	self.parentWidgetContainer = self:GetParent();
	self.childWidgets = {};
end

function UIWidgetHorizontalWidgetContainerMixin:ResetChildWidgets()
	for _, widgetFrame in ipairs(self.childWidgets) do
		widgetFrame:SetParent(self.parentWidgetContainer);
	end

	self.childWidgets = {};
end

function UIWidgetHorizontalWidgetContainerMixin:AddChildWidget(widgetFrame)
	table.insert(self.childWidgets, widgetFrame);
	widgetFrame:SetParent(self);
end

UIWidgetContainerMixin = {};

local function ResetHorizontalWidgetContainer(framePool, frame)
	frame:ResetChildWidgets();
	FramePool_HideAndClearAnchors(framePool, frame);
end

function UIWidgetContainerMixin:OnLoad()
	self.widgetPools = CreateFramePoolCollection();
	self.horizontalRowContainerPool = CreateFramePool("FRAME", self, "UIWidgetHorizontalWidgetContainerTemplate", ResetHorizontalWidgetContainer);
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
		if self:IsRegisteredForWidgetSet(widgetInfo.widgetSetID) and (not widgetInfo.unit or (widgetInfo.unit == self.attachedUnit)) then
			self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
		end
	end
end

function UIWidgetContainerMixin:MarkDirtyLayout()
	self.dirtyLayout = true;

	-- To optimize performance, only set OnUpdate while marked dirty.
	self:SetScript("OnUpdate", UIWidgetContainerMixin.OnUpdate);
end

function UIWidgetContainerMixin:MarkCleanLayout()
	self.dirtyLayout = false;
	self:SetScript("OnUpdate", nil);
end

function UIWidgetContainerMixin:OnUpdate(elapsed)
	-- Handle layout updates
	if self.dirtyLayout then
		self:UpdateWidgetLayout();
	end
end

function DefaultWidgetLayout(widgetContainerFrame, sortedWidgets, skipContainerLayout)
	local horizontalRowContainer = nil; 

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll();
	local widgetContainerFrameLevel = widgetContainerFrame:GetFrameLevel();
	local horizontalRowAnchorPoint = widgetContainerFrame.horizontalRowAnchorPoint or widgetContainerFrame.verticalAnchorPoint;
	local horizontalRowRelativePoint = widgetContainerFrame.horizontalRowRelativePoint or widgetContainerFrame.verticalRelativePoint;

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints();

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == Enum.UIWidgetSetLayoutDirection.Vertical;
		local widgetSetUsesOverlapLayout = widgetContainerFrame.widgetSetLayoutDirection == Enum.UIWidgetSetLayoutDirection.Overlap;

		local widgetUsesVertical = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Vertical;
		local widgetUsesOverlapLayout = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Overlap;

		local useOverlapLayout = widgetUsesOverlapLayout or (widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Default and widgetSetUsesOverlapLayout);
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.Default and widgetSetUsesVertical);

		if useOverlapLayout then
			-- This widget uses overlap layout

			if index == 1 then
				-- But this is the first widget in the set, so just anchor it to the widget container
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame);
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, widgetContainerFrame);
				end
			else
				-- This is not the first widget in the set, so anchor it so it overlaps the previous widget
				local relative = sortedWidgets[index - 1];
				if widgetSetUsesVertical then
					-- Overlap it vertically
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalAnchorPoint, 0, 0);
				else
					-- Overlap it horizontally
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalAnchorPoint, 0, 0);
				end
			end

			widgetFrame:SetParent(widgetContainerFrame);
			widgetFrame:SetFrameLevel(widgetContainerFrameLevel + index);
		elseif useVerticalLayout then 
			-- This widget uses vertical layout

			if index == 1 then
				-- This is the first widget in the set, so just anchor it to the widget container
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame);
			else
				-- This is not the first widget in the set, so anchor it to the previous widget (or the horizontalRowContainer if that exists)
				local relative = horizontalRowContainer or sortedWidgets[index - 1];
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset);

				if horizontalRowContainer then
					-- This widget is vertical, so horizontalRowContainer is done. Call layout on it and clear horizontalRowContainer
					horizontalRowContainer:Layout(); 
					horizontalRowContainer = nil;
				end
			end

			widgetFrame:SetParent(widgetContainerFrame);
			widgetFrame:SetFrameLevel(widgetContainerFrameLevel + index);
		else
			-- This widget uses horizontal layout

			local forceNewRow = widgetFrame.layoutDirection == Enum.UIWidgetLayoutDirection.HorizontalForceNewRow;
			local needNewRowContainer = not horizontalRowContainer or forceNewRow;
			if needNewRowContainer then 
				-- We either don't have a horizontalRowContainer or this widget has requested a new row be started
				if horizontalRowContainer then 
					horizontalRowContainer:Layout(); 
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire();
				newHorizontalRowContainer:Show(); 

				if index == 1 then
					-- This is the first widget in the set, so just anchor it to the widget container
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint);
				else 
					-- This is not the first widget in the set, so anchor it to the previous widget (or the horizontalRowContainer if that exists)
					local relative = horizontalRowContainer or sortedWidgets[index - 1];
					newHorizontalRowContainer:SetPoint(horizontalRowAnchorPoint, relative, horizontalRowRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset);
				end
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, newHorizontalRowContainer);
				newHorizontalRowContainer:AddChildWidget(widgetFrame);
				widgetFrame:SetFrameLevel(widgetContainerFrameLevel + index);

				-- The old horizontalRowContainer is no longer needed for anchoring, so set it to newHorizontalRowContainer
				horizontalRowContainer = newHorizontalRowContainer;
			else
				-- horizontalRowContainer already existed, so we just keep going in it, anchoring to the previous widget
				local relative = sortedWidgets[index - 1];
				horizontalRowContainer:AddChildWidget(widgetFrame);
				widgetFrame:SetFrameLevel(widgetContainerFrameLevel + index);
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0);
			end
		end
	end

	if horizontalRowContainer then 
		horizontalRowContainer:Layout(); 
	end

	if not skipContainerLayout then
		widgetContainerFrame:Layout();
	end
end

function UIWidgetContainerMixin:SetAttachedUnitAndType(attachedUnitInfo)
	if type(attachedUnitInfo) == "table" then
		self.attachedUnit = attachedUnitInfo.unit;
		self.attachedUnitIsGuid = attachedUnitInfo.isGuid;
	elseif attachedUnitInfo then
		self.attachedUnit = attachedUnitInfo;
		self.attachedUnitIsGuid = false;
	else
		self.attachedUnit = nil;
		self.attachedUnitIsGuid = nil;
	end
end

-- widgetLayoutFunction should take 2 arguments (this widget container and a sequence containing all widgetFrames belonging to that widgetSet, sorted by orderIndex). It can update the layout of the widgets & widgetContainer as it sees fit. 
--		IMPORTANT: widgetLayoutFunction is called every time any widget in this container is shown, hidden or re-ordered. If nil is passed DefaultWidgetLayout is used
-- widgetInitFunction should take 1 argument (the widgetFrame). It should do anything needed for initialization of widgets by the registering system. It is called only once, when a widget is initialized (when entering a new map/area/subarea/phase)
-- Either can be nil if your system doesn't need that functionaility
-- attachedUnitInfo is only used if this widget container is attached to a particular unit (it is displayed in a nameplate or in the player choice UI), and causes UnitAura data sources to look at the attached unit
--
-- Calling RegisterForWidgetSet on a container that is already registered to a different WidgetSet will cause the old WidgetSet to get unregistered and the new one to take its place
-- Calling RegisterForWidgetSet with a nil widgetSetID is the same as just calling UnregisterForWidgetSet
function UIWidgetContainerMixin:RegisterForWidgetSet(widgetSetID, widgetLayoutFunction, widgetInitFunction, attachedUnitInfo)
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

	local widgetSetInfo = C_UIWidgetManager.GetWidgetSetInfo(widgetSetID);
	if not widgetSetInfo then
		return;
	end

	self.widgetSetID = widgetSetID;
	self.layoutFunc = widgetLayoutFunction or DefaultWidgetLayout;
	self.initFunc = widgetInitFunction;
	self.widgetFrames = {};
	self.timerWidgets = {};
	self.numTimers = 0;
	self.numWidgetsShowing = 0;
	self:SetAttachedUnitAndType(attachedUnitInfo)

	self.widgetSetLayoutDirection = self.forceWidgetSetLayoutDirection or widgetSetInfo.layoutDirection;
	self.verticalAnchorYOffset = -widgetSetInfo.verticalPadding;

	if self.attachedUnit then
		C_UIWidgetManager.RegisterUnitForWidgetUpdates(self.attachedUnit, self.attachedUnitIsGuid);
	end

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

	if self.attachedUnit then
		if UIWidgetManager.processingUnit == self.attachedUnit then
			UIWidgetManager.processingUnit = nil;
		end

		C_UIWidgetManager.UnregisterUnitForWidgetUpdates(self.attachedUnit, self.attachedUnitIsGuid);

		self:SetAttachedUnitAndType(nil);
	end

	self:UnregisterEvent("UPDATE_ALL_UI_WIDGETS");
	self:UnregisterEvent("UPDATE_UI_WIDGET");

	UIWidgetManager:OnWidgetContainerUnregistered(self);
end

-- Pass in nil to check if we are registered to any widget set
function UIWidgetContainerMixin:IsRegisteredForWidgetSet(widgetSetID)
	if widgetSetID then
		return self.widgetSetID == widgetSetID;
	else
		return self.widgetSetID ~= nil;
	end
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

-- Mark all currently shown widgets to be removed
function UIWidgetContainerMixin:MarkAllWidgetsForRemoval()
	for _, widgetFrame in pairs(self.widgetFrames) do
		widgetFrame.markedForRemove = true;
	end
end

-- Go through all widgets in this container and call AnimOut on any that are marked for removal. This will cause them to animate out and RemoveWidget will be called once that is done.
function UIWidgetContainerMixin:AnimateOutAllMarkedWidgets()
	for _, widgetFrame in pairs(self.widgetFrames) do
		if widgetFrame.markedForRemove then
			widgetFrame:AnimOut();
		end
	end
end

-- Removes all widgets from this container immediately (don't animate them out)
function UIWidgetContainerMixin:RemoveAllWidgets()
	self.widgetFrames = {};
	self.timerWidgets = {};
	self.numTimers = 0;
	self.numWidgetsShowing = 0;

	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end

	self.widgetPools:ReleaseAll();
end

-- This is called AFTER the widget is done animating out. The widgetFrame is actually released back to the pool and hidden.
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
	self:MarkDirtyLayout();
end

local function ResetWidget(pool, widgetFrame)
	widgetFrame:OnReset();
end

function UIWidgetContainerMixin:GetWidgetFromPools(templateInfo)
	if templateInfo then
		self.widgetPools:CreatePoolIfNeeded(templateInfo.frameType, self, templateInfo.frameTemplate, ResetWidget);

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
	widgetFrame.inAnimType = widgetInfo.inAnimType;
	widgetFrame.outAnimType = widgetInfo.outAnimType;
	widgetFrame.layoutDirection = widgetInfo.layoutDirection; 
	widgetFrame.modelSceneLayer = widgetInfo.modelSceneLayer;
	widgetFrame.scriptedAnimationEffectID = widgetInfo.scriptedAnimationEffectID;
	widgetFrame.markedForRemove = nil;

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

	UIWidgetManager:UpdateProcessingUnit(self.attachedUnit, self.attachedUnitIsGuid);

	local widgetInfo = widgetTypeInfo.visInfoDataFunction(widgetID);

	local widgetFrame = self.widgetFrames[widgetID];
	local widgetAlreadyExisted = (widgetFrame ~= nil);

	local oldOrderIndex;
	local oldLayoutDirection;
	local isNewWidget = false;

	if widgetAlreadyExisted then
		-- Widget already existed
		if not widgetInfo then
			-- widgetInfo is nil, indicating it should no longer be shown...animate it out (RemoveWidget will be called once that is done)
			widgetFrame:AnimOut();
			widgetFrame.markedForRemove = nil;
			return;
		end

		-- Otherwise the widget should still show...save the current orderIndex and layoutDirection so we can determine if they change after Setup is run
		oldOrderIndex = widgetFrame.orderIndex;
		oldLayoutDirection = widgetFrame.layoutDirection;

		-- Remove markedForRemove because it is still showing
		widgetFrame.markedForRemove = nil;
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

	-- Run the Setup function on the widget (could change the orderIndex and/or layoutDirection)
	widgetFrame:Setup(widgetInfo, self);
	if isNewWidget then 
		--Only Apply the effects when the widget is first added.
		widgetFrame:ApplyEffects(widgetInfo); 
	end		
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

	-- Determine if we need to run layout again
	local needsLayout = (oldOrderIndex ~= widgetFrame.orderIndex) or (oldLayoutDirection ~= widgetFrame.layoutDirection);
	if needsLayout then
		-- Either this is a new widget or either orderIndex or layoutDirection changed. In either case layout needs to be run
		self:MarkDirtyLayout();
	end
end

function UIWidgetContainerMixin:ProcessAllWidgets()
	-- First mark all widgets for removal
	self:MarkAllWidgetsForRemoval();

	-- Add any new widgets and unmark any existing widgets that are still shown
	local setWidgets = C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID);
	for _, widgetInfo in ipairs(setWidgets) do
		self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
	end

	-- Animate out any widgets that are still marked for removal
	self:AnimateOutAllMarkedWidgets();

	-- Force call UpdateWidgetLayout because some containers rely on it being called right away
	self:UpdateWidgetLayout();
end

local function SortWidgets(a, b)
	if a.orderIndex == b.orderIndex then
		return a.widgetID < b.widgetID;
	else
		return a.orderIndex < b.orderIndex;
	end
end

function UIWidgetContainerMixin:GetNumWidgetsShowing()
	return self.numWidgetsShowing or 0;
end

function UIWidgetContainerMixin:HasAnyWidgetsShowing()
	return (self:GetNumWidgetsShowing() > 0);
end

function UIWidgetContainerMixin:UpdateWidgetLayout()
	if not self:IsRegisteredForWidgetSet() then
		-- We aren't registered for a widget set, nothing to layout
		self:MarkCleanLayout();
		return;
	end

	local sortedWidgets = {};
	for _, widget in pairs(self.widgetFrames) do
		table.insert(sortedWidgets, widget);
	end

	table.sort(sortedWidgets, SortWidgets);

	self.numWidgetsShowing = #sortedWidgets;
	self:layoutFunc(sortedWidgets);
	self:MarkCleanLayout();
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

function UIWidgetManagerMixin:UpdateProcessingUnit(attachedUnit, attachedUnitIsGuid)
	if self.processingUnit ~= attachedUnit then
		if attachedUnitIsGuid then
			C_UIWidgetManager.SetProcessingUnitGuid(attachedUnit);
		else
			C_UIWidgetManager.SetProcessingUnit(attachedUnit);
		end

		self.processingUnit = attachedUnit;
	end
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
