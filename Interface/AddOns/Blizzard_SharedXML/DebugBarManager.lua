DebugBarManager = { };

local debugBars = { };

function DebugBarManager:AddBar(debugBar, priority)
	assert(debugBar and debugBar.GetDebugBarDisplayProperties, "Must have GetDebugBarDisplayProperties function");

	local debugBarInfo = { bar = debugBar, priority = priority or 0 };
	table.insert(debugBars, debugBarInfo);

	self:UpdateAnchors();
end

local sortFunc = function(lhs, rhs)
	if lhs.isAboveWorldFrame ~= rhs.isAboveWorldFrame then
		return lhs.isAboveWorldFrame;
	end
	if lhs.priority ~= rhs.priority then
		return lhs.priority > rhs.priority;
	end
	-- tie breaker
	return tostring(lhs.bar) < tostring(rhs.bar);
end

function DebugBarManager:GetScreenScale()
	if IsOnGlueScreen() then
		return PixelUtil.GetPixelToUIUnitFactor();
	else
		return UIParent:GetScale();
	end
end

function DebugBarManager:GetInternalBarsHeight()
	local debugMenuHeight = DebugMenu and DebugMenu.IsVisible() and DebugMenu.GetMenuHeight() or 0;
	local revealTimeTrackHeight = C_Reveal and C_Reveal:IsCapturing() and C_Reveal:GetTimeTrackHeight() or 0;
	return debugMenuHeight + revealTimeTrackHeight;
end

function DebugBarManager:GetScaledInternalBarsHeight()
	return self:GetInternalBarsHeight() * self:GetScreenScale();
end

function DebugBarManager:CalculatePositions()
	for i, debugBarInfo in ipairs(debugBars) do
		local isShown, isAboveWorldFrame = debugBarInfo.bar:GetDebugBarDisplayProperties();
		debugBarInfo.isShown = isShown;
		debugBarInfo.isAboveWorldFrame = isAboveWorldFrame;
	end

	table.sort(debugBars, sortFunc);

	local scale = self:GetScreenScale();
	scale = math.min(scale, 1);
	local internalHeight = self:GetInternalBarsHeight();
	local addedHeight = 0;
	local aboveWorldFrameHeight = 0;

	for i, debugBarInfo in ipairs(debugBars) do
		if debugBarInfo.isShown then
			debugBarInfo.bar:SetScale(scale);
			debugBarInfo.bar:ClearAllPoints();
			debugBarInfo.bar:SetPoint("TOPLEFT", 0, -internalHeight - addedHeight);
			debugBarInfo.bar:SetPoint("TOPRIGHT", 0, -internalHeight - addedHeight);
			local height = debugBarInfo.bar:GetHeight();
			addedHeight = addedHeight + height;
			if debugBarInfo.isAboveWorldFrame then
				aboveWorldFrameHeight = aboveWorldFrameHeight + height;
			end
		end
	end

	if WorldFrame then
		if aboveWorldFrameHeight > 0 then
			local offset = internalHeight + aboveWorldFrameHeight;
			WorldFrame:SetPoint("TOPLEFT", 0, -offset * scale);
		else
			WorldFrame:SetPoint("TOPLEFT");
		end
	end

	self.totalHeight = internalHeight + addedHeight;
end

function DebugBarManager:GetTotalHeight()
	if not self.totalHeight then
		self:CalculatePositions();
	end
	return self.totalHeight;
end

function DebugBarManager:UpdateAnchors()
	self:CalculatePositions();
	if UpdateUIParentPosition then
		UpdateUIParentPosition();
	end
	if DeveloperConsole then
		DeveloperConsole:UpdateAnchors();
	end
end

do
	if DebugMenu or C_Reveal then
		EventRegistry:RegisterFrameEvent("UI_SCALE_CHANGED");
		EventRegistry:RegisterCallback("UI_SCALE_CHANGED", DebugBarManager.UpdateAnchors, DebugBarManager);
		EventRegistry:RegisterFrameEvent("DISPLAY_SIZE_CHANGED");
		EventRegistry:RegisterCallback("DISPLAY_SIZE_CHANGED", DebugBarManager.UpdateAnchors, DebugBarManager);
		if IsOnGlueScreen() then
			local watcherFrame = CreateFrame("FRAME");
			watcherFrame:SetScript("OnUpdate", function() DebugBarManager:UpdateAnchors(); end);
		else
			if C_EventUtils.IsEventValid("DEBUG_MENU_TOGGLED") then
				EventRegistry:RegisterFrameEvent("DEBUG_MENU_TOGGLED");
				EventRegistry:RegisterCallback("DEBUG_MENU_TOGGLED", DebugBarManager.UpdateAnchors, DebugBarManager);
			end
			if C_EventUtils.IsEventValid("REVEAL_CAPTURE_TOGGLED") then
				EventRegistry:RegisterFrameEvent("REVEAL_CAPTURE_TOGGLED");
				EventRegistry:RegisterCallback("REVEAL_CAPTURE_TOGGLED", DebugBarManager.UpdateAnchors, DebugBarManager);
			end
		end
	end
end