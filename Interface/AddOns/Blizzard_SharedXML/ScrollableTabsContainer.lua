ScrollableTabsContainerMixin = { };

function ScrollableTabsContainerMixin:OnSizeChanged()
	if self.headIndex then
		self:Update();
		self:TryFitMoreFrames();
	end
end

function ScrollableTabsContainerMixin:Init(template, initializer, controlsUpdateFunc)
	local templateInfo = C_XMLUtil.GetTemplateInfo(template);
	assert(templateInfo and initializer);
	self.framePool = CreateFramePool(templateInfo.type, self.Contents, template);

	self.initializer = initializer;
	self.leftPadding = self.leftPadding or 2;
	self.rightPadding = self.rightPadding or 2;
	self.frameSpacing = self.frameSpacing or 4;
	self.verticalOffset = self.verticalOffset or 0;
	
	self.controlsUpdateFunc = controlsUpdateFunc;
	self.controlWidthLeft = 0;
	self.controlWidthRight = 0;
	
	self.tabs = { };
	
	self.Contents:SetScript("OnMouseWheel", function(frame, delta) self:Scroll(delta * -1); end);
end

function ScrollableTabsContainerMixin:AddTab(tabInfo)
	if not self.headIndex then
		self.headIndex = 1;
	end

	local frame = self.framePool:Acquire();	
	-- anchor now for sizing calculations
	frame:SetPoint("LEFT");
	local t = { tabInfo = tabInfo, frame = frame };
	table.insert(self.tabs, t);

	frame:Show();	
	self.initializer(frame, tabInfo);
	
	self:Update();
end

function ScrollableTabsContainerMixin:RemoveTab(tabInfo)
	for i, tab in ipairs(self.tabs) do
		if tab.tabInfo == tabInfo then
			-- remove tab
			tab.frame:Hide();
			self.framePool:Release(tab.frame);
			table.remove(self.tabs, i);
			-- need adjustment if tab removed is the first visible one ("head") or before it
			if i <= self.headIndex and i ~= 1 then
				self.headIndex = self.headIndex - 1;
			end
			-- update, then check for fit
			self:Update();
			self:TryFitMoreFrames();
			return;
		end
	end
end

function ScrollableTabsContainerMixin:RemoveAllTabs()
	self.framePool:ReleaseAll();
	self.tabs = { };
	self.headIndex = 1;	
	self:Update();
end

function ScrollableTabsContainerMixin:GetAllTabs()
	local info = { };
	for i, tab in ipairs(self.tabs) do
		table.insert(info, tab.tabInfo);
	end
	return info;
end

function ScrollableTabsContainerMixin:GetTabIndex(tabInfo)
	for i, tab in ipairs(self.tabs) do
		if tab.tabInfo == tabInfo then
			return i;
		end
	end
	return nil;
end

function ScrollableTabsContainerMixin:GetNumTabs()
	return #self.tabs;
end

function ScrollableTabsContainerMixin:HasTab(tabInfo)
	return self:GetTabIndex(tabInfo) ~= nil;
end

function ScrollableTabsContainerMixin:GetTab(index)
	local tab = self.tabs[index];
	return tab and tab.frame;
end

function ScrollableTabsContainerMixin:GetLastTab()
	local tab = self.tabs[#self.tabs];
	return tab and tab.frame;
end

function ScrollableTabsContainerMixin:Scroll(delta)
	if delta == 1 and not self.canScrollRight then
		return;
	end

	if delta ~= 0 then
		self.headIndex = Clamp(self.headIndex + delta, 1, #self.tabs);
		self:Update();
	end
end

function ScrollableTabsContainerMixin:TryFitMoreFrames()
	-- if any frames are scrolled off to the left, check if enough room exists now to make them visible
	if self.headIndex and self.headIndex > 1 then
		local scrollDelta = 0;
		local availableSpace = self:GetRightEdgeMargin();
		for i = self.headIndex - 1, 1, -1 do
			-- if at the first frame, also consider controls width because it can be removed if it all ends up fitting
			if i == 1 then
				availableSpace = availableSpace + self:GetVisibleControlsWidth();
			end			
			local frame = self.tabs[i].frame;
			local width = frame:GetWidth() + self.frameSpacing;
			if width < availableSpace then
				availableSpace = availableSpace - width;
				scrollDelta = scrollDelta - 1;
			else
				break;
			end
		end
		self:Scroll(scrollDelta);
	end
end

function ScrollableTabsContainerMixin:ScrollIntoView(tabInfo)
	local tabIndex = self:GetTabIndex(tabInfo);
	if not tabIndex or tabIndex == self.headIndex then
		-- should already fit as much as possible
		return;
	end

	local scrollDelta = 0;

	if tabIndex < self.headIndex then
		scrollDelta = tabIndex - self.headIndex;
	else
		local tab = self.tabs[tabIndex];
		local margin = self:GetRightEdgeMargin(tab);
		if margin >= 0 then
			-- it already fits
			return;
		end

		for i = self.headIndex, #self.tabs - 1 do
			scrollDelta = scrollDelta + 1;		
			local frame = self.tabs[i].frame;
			local width = frame:GetWidth() + self.frameSpacing;		
			margin = margin + width;
			if margin >= 0 then
				break;
			end
		end
	end

	self:Scroll(scrollDelta);
end

-- distance to the end of container from the tab's right edge
-- defaults to last tab, positive distance is space that might fit more frames, negative distance means frame is not fully visible 
function ScrollableTabsContainerMixin:GetRightEdgeMargin(tab)
	-- default to last tab
	tab = tab or self.tabs[#self.tabs];
	local frame = tab and tab.frame;
	local furthestRight = (frame and frame:GetRight()) or 0;
	local contentsRight = self.Contents:GetRight() or 0;
	return Round(contentsRight - furthestRight);
end

function ScrollableTabsContainerMixin:GetVisibleControlsWidth()
	return self.controlWidthLeft + self.controlWidthRight;
end

function ScrollableTabsContainerMixin:UpdateControls()
	if not self.controlsUpdateFunc then
		return;
	end

	local canScrollLeft = self.headIndex > 1;
	local spaceRight = self:GetRightEdgeMargin();
	-- if it's not possible to scroll left, add the controls space because the controls can be removed to fit the last frame if needed
	if not canScrollLeft then
		spaceRight = spaceRight + self:GetVisibleControlsWidth();
	end
	self.canScrollRight = spaceRight < 0;

	self.controlWidthLeft, self.controlWidthRight = self.controlsUpdateFunc(self, canScrollLeft, self.canScrollRight);
	
	self.Contents:SetPoint("TOPLEFT", self.leftPadding + self.controlWidthLeft, 0);
	self.Contents:SetPoint("BOTTOMRIGHT", -self.rightPadding - self.controlWidthRight, 0);
end

function ScrollableTabsContainerMixin:Update()
	local firstFrameOffset = 0;
	local anchor;
	for i, tab in ipairs(self.tabs) do
		local frame = tab.frame;
		if anchor then
			frame:SetPoint("LEFT", anchor, "RIGHT", self.frameSpacing, 0);
		else
			frame:SetPoint("LEFT", self.Contents, 0, self.verticalOffset);
		end
		if i < self.headIndex then
			firstFrameOffset = firstFrameOffset - frame:GetWidth() - self.frameSpacing;
		end
		anchor = frame;
	end
	
	-- adjust first frame so the head frame is in the first visible position
	if anchor then
		self.tabs[1].frame:SetPoint("LEFT", firstFrameOffset, self.verticalOffset);
	end
	-- adjust contents frame
	self:UpdateControls();
end

function ScrollableTabsContainerMixin:ForEachTab(func)
	for i, tab in ipairs(self.tabs) do
		local frame = tab.frame;
		func(frame, tab.tabInfo);
	end
end