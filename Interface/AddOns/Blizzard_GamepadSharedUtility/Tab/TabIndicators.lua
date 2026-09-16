
GamepadTabIndicatorsMixin = {};

function GamepadTabIndicatorsMixin:OnLoad()
	self.tabs = {};
	self.visibleTabs = {};
	self.currentIndex = 0;

	self.bindings = GamepadMode.CreateBindingGroup("TabIndicatorBindings");
	self.bindings:AddButtonBinding(GAMEPAD_SHOULDER_LEFT, self.LeftTabButton:GetName());
	self.bindings:AddButtonBinding(GAMEPAD_SHOULDER_RIGHT, self.RightTabButton:GetName());

	self.LeftTabButton:SetInputKey(GAMEPAD_SHOULDER_LEFT);
	self.RightTabButton:SetInputKey(GAMEPAD_SHOULDER_RIGHT);
end

function GamepadTabIndicatorsMixin:OnShow()
	self:UpdateTabVisibility();
	GamepadMode.ActivateBindingGroup(self.bindings);
end

function GamepadTabIndicatorsMixin:OnHide()
	GamepadMode.DeactivateBindingGroup(self.bindings);
end

function GamepadTabIndicatorsMixin:SetUpTabs(inTabs, reverse)
	if not reverse then
		for _ , tab in ipairs(inTabs) do
			SmartNavigation_MarkFrameIgnored(tab);
			table.insert(self.tabs, tab);
		end
	else
		for i = #inTabs, 1, -1 do
			SmartNavigation_MarkFrameIgnored(inTabs[i]);
			table.insert(self.tabs, inTabs[i]);
		end
	end

	self:UpdateTabVisibility();
end

function GamepadTabIndicatorsMixin:UpdateTabVisibility()
	table.wipe(self.visibleTabs);

	self.currentIndex = 1;
	local activeIndex = 1;
	if (InGlue()) then
		activeIndex = GlueTemplates_GetSelectedTab(self:GetParent());
	else
		activeIndex = PanelTemplates_GetSelectedTab(self:GetParent());
	end

	for _ , tab in ipairs(self.tabs) do
		if tab:IsVisible() then
			table.insert(self.visibleTabs, tab);

			if (tab:GetID() == activeIndex) then
				self.currentIndex = #self.visibleTabs;
			end
		end
	end

	local maxTabs = #self.visibleTabs;
	if maxTabs > 0 then
		local firstTab = self.visibleTabs[1];
		local lastTab = self.visibleTabs[maxTabs];

		self.LeftTabButton:ClearAllPoints();
		self.RightTabButton:ClearAllPoints();
		if self.isVertical then
			self.LeftTabButton:SetPoint("BOTTOM", firstTab, "TOP", 0, 0);
			self.RightTabButton:SetPoint("TOP", lastTab, "BOTTOM", 0, 0);
		else
			self.LeftTabButton:SetPoint("RIGHT", firstTab, "LEFT", 0, 0);
			self.RightTabButton:SetPoint("LEFT", lastTab, "RIGHT", 0, 0);
		end
		self.LeftTabButton:Show();
		self.RightTabButton:Show();
	else
		self.LeftTabButton:Hide();
		self.RightTabButton:Hide();
	end

	self:UpdateTabIndicators();
end

function GamepadTabIndicatorsMixin:SetCurrentIndex(inIndex)
	self.currentIndex = inIndex;
end

function GamepadTabIndicatorsMixin:ClickCurrentTab()
	if self.currentIndex > 0 then
		local tabButton = self.visibleTabs[self.currentIndex];
		if tabButton.Click then
			tabButton:Click();
		else
			tabButton:MouseDown();
			tabButton:MouseUp();
		end
	end
end

function GamepadTabIndicatorsMixin:Tab(inOffset)
	local maxTabs = #self.visibleTabs;
	if maxTabs == 0 then
		return;
	end

	local oldIndex = self.currentIndex;
	local newIndex = self.currentIndex + inOffset;

	-- Skip over disabled tabs
	while newIndex ~= oldIndex do
		if newIndex > maxTabs or newIndex < 1 then
			self:UpdateTabIndicators();
			return;
		end

		if (self.visibleTabs[newIndex].isDisabled) then
			if inOffset > 0 then
				newIndex = newIndex + 1;
			else
				newIndex = newIndex - 1;
			end
		else
			break;
		end
	end

	self.currentIndex = newIndex;
	self:UpdateTabIndicators();

	self:ClickCurrentTab();
end

function GamepadTabIndicatorsMixin:GetNumTabs()
	return #self.tabs;
end

function GamepadTabIndicatorsMixin:UpdateTabIndicators()
	local lastLeft = true;
	local lastRight = true;
	for i = self.currentIndex - 1, 1, -1 do
		if not self.visibleTabs[i].isDisabled then
			lastLeft = false;
			break;
		end
	end
	for i = self.currentIndex + 1, #self.visibleTabs, 1 do
		if not self.visibleTabs[i].isDisabled then
			lastRight = false;
			break;
		end
	end
	if lastLeft or self.isLocked then
		self.LeftTabButton:SetDisabled();
	else
		self.LeftTabButton:SetPressable();
	end
	if lastRight or self.isLocked then
		self.RightTabButton:SetDisabled();
	else
		self.RightTabButton:SetPressable();
	end
end

function GamepadTabIndicatorsMixin:LockTabs(isLocked)
	self.isLocked = isLocked;
	self:UpdateTabVisibility();
end

GamepadTabIndicatorButtonMixin = {};

function GamepadTabIndicatorButtonMixin:OnClick(button, down)
	if down then
		local gamepadTabIndicators = self:GetParent();
		if not gamepadTabIndicators.isLocked then
			gamepadTabIndicators:Tab(self.offset);
		end
	end
end
