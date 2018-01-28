StatusTrackingManagerMixin = { };

function StatusTrackingManagerMixin:SetTextLocked(isLocked)
	if ( self.textLocked ~= isLocked ) then
		self.textLocked = isLocked;
		self:UpdateBarVisibility(); 
	end
end

function StatusTrackingManagerMixin:GetNumberVisibleBars()
	local numVisBars = 0; 
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			numVisBars = numVisBars + 1; 
		end
	end	
	return numVisBars; 
end

function StatusTrackingManagerMixin:IsTextLocked()
	return self.textLocked;
end	

function StatusTrackingManagerMixin:UpdateBarVisibility()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:UpdateTextVisibility();
		end
	end	
end

function StatusTrackingManagerMixin:AddBarFromTemplate(frameType, template)
	local bar = CreateFrame(frameType, nil, self, template);
	table.insert(self.bars, bar);
	self:UpdateBarsShown();
	
end

function StatusTrackingManagerMixin:SetBarAnimation(Animation)
	for i, bar in ipairs(self.bars) do
		bar.StatusBar:SetDeferAnimationCallback(Animation); 
	end
end

function StatusTrackingManagerMixin:UpdateBarTicks()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:UpdateTick();
		end
	end
end

function StatusTrackingManagerMixin:ShowVisibleBarText()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:ShowText();
		end
	end
end

function StatusTrackingManagerMixin:HideVisibleBarText()
	for i, bar in ipairs(self.bars) do
		if(bar:ShouldBeVisible()) then
			bar:HideText();
		end
	end
end

function StatusTrackingManagerMixin:SetBarSize(largeSize)
	self.largeSize = largeSize; 
	self:UpdateBarsShown(); 
end

function StatusTrackingManagerMixin:UpdateBarsShown()
	local visibleBars = {};
	for i, bar in ipairs(self.bars) do
		if ( bar:ShouldBeVisible() ) then
			table.insert(visibleBars, bar);
		end
	end
		
	table.sort(visibleBars, function(left, right) return left:GetPriority() < right:GetPriority() end);
	self:LayoutBars(visibleBars); 
end

function StatusTrackingManagerMixin:HideStatusBars()
	self.DoubleBarSmall:Hide(); 
	self.SingleBarLarge:Hide();
	self.SingleBarSmall:Hide();
	self.DoubleBarLarge:Hide();
	for i, bar in ipairs(self.bars) do
		bar:Hide(); 
	end
end

-- Sets the bar size depending on whether the bottom right multi-bar is shown. 
-- If the multi-bar is shown, a different texture needs to be displayed that is smaller. 
function StatusTrackingManagerMixin:SetDoubleBarSize(bar, width)
	local statusBarWidth, statusBarHeight = self.DoubleBarLarge:GetSize();

	width = width - self:GetEndCapWidth() * 4;
	local smallBarSeparatorWidth, largeBarSeparatorWidth = self:GetSeparatorWidth();
	if( self.largeSize ) then 
		self.DoubleBarLarge:Show();
		width = width - largeBarSeparatorWidth;
	else
		self.DoubleBarSmall:Show(); 
		width = width - smallBarSeparatorWidth;
	end

	local oneBarWidth = width / 2; -- Since we need two bars to be displayed. 
	bar.StatusBar:SetSize(oneBarWidth, statusBarHeight);  
	bar:SetSize(oneBarWidth, statusBarHeight);
end

--Same functionality as previous function except shows the single bar texture instead of the double. 
function StatusTrackingManagerMixin:SetSingleBarSize(bar, width) 
	local statusBarWidth, statusBarHeight = self.DoubleBarLarge:GetSize();

	width = width - self:GetEndCapWidth() * 2;
	if( self.largeSize ) then 
		self.SingleBarLarge:Show(); 
	else
		self.SingleBarSmall:Show(); 
	end

	bar.StatusBar:SetSize(width, statusBarHeight);  
	bar:SetSize(width, statusBarHeight);
end

function StatusTrackingManagerMixin:LayoutBar(bar, barWidth, leftSide, isDouble)
	bar:Update(); 
	bar:Show(); 
		
	bar:ClearAllPoints();
	if ( leftSide ) then
		bar:SetPoint("LEFT", self:GetParent(), "LEFT", self:GetEndCapWidth(), -20);
	else
		bar:SetPoint("RIGHT", self:GetParent(), "RIGHT", -self:GetEndCapWidth(), -20);
	end
	if ( isDouble ) then
		self:SetDoubleBarSize(bar, barWidth);
	else
		self:SetSingleBarSize(bar, barWidth);
	end
end

function StatusTrackingManagerMixin:LayoutBars(visBars)
	local width = self:GetParent():GetSize();
	self:HideStatusBars();

	local LEFT_SIDE = true;
	local IS_DOUBLE = true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[1], width, LEFT_SIDE, IS_DOUBLE);
		self:LayoutBar(visBars[2], width, not LEFT_SIDE, IS_DOUBLE);
	elseif( #visBars == 1 ) then 
		self:LayoutBar(visBars[1], width, LEFT_SIDE, not IS_DOUBLE);
	end 
	self:GetParent():OnStatusBarsUpdated();
	self:UpdateBarTicks();
end

function StatusTrackingManagerMixin:SetEndCapWidth(Width)
	self.endCapWidth = Width;
end

function StatusTrackingManagerMixin:GetEndCapWidth()
	return self.endCapWidth;
end

function StatusTrackingManagerMixin:SetSeparatorWidth(smallBarSeparatorWidth, largeBarSeparatorWidth)
	self.smallBarSeparatorWidth = smallBarSeparatorWidth;
	self.largeBarSeparatorWidth = largeBarSeparatorWidth;
end

function StatusTrackingManagerMixin:GetSeparatorWidth()
	return self.smallBarSeparatorWidth, self.largeBarSeparatorWidth;
end

function StatusTrackingManagerMixin:OnLoad()
	self.bars = {};
	
	self:RegisterEvent("UPDATE_FACTION");
	self:RegisterEvent("ENABLE_XP_GAIN");
	self:RegisterEvent("DISABLE_XP_GAIN");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ARTIFACT_XP_UPDATE");
	self:RegisterUnitEvent("UNIT_LEVEL", "player")
	self:UpdateBarsShown(); 
end

function StatusTrackingManagerMixin:OnEvent(event)
	if ( event == "CVAR_UPDATE" ) then
		self:UpdateBarVisibility();
	end	
	self:UpdateBarsShown(); 
end