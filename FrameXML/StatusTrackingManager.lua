StatusTrackingManagerMixin = { };
local MAX_BARS_VISIBLE = 2;

function StatusTrackingManagerMixin:SetTextLocked(isLocked)
	if ( self.textLocked ~= isLocked ) then
		self.textLocked = isLocked;
		self:UpdateBarVisibility(); 
	end
end

function StatusTrackingManagerMixin:GetNumberVisibleBars()
	local numVisBars = 0; 
	for i, bar in ipairs(self.bars) do
		if (bar:ShouldBeVisible()) then
			numVisBars = numVisBars + 1; 
		end
	end	
	return math.min(MAX_BARS_VISIBLE, numVisBars); 
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
	self.SingleBarSmall:Hide(); 
	self.SingleBarLarge:Hide();
	self.SingleBarSmallUpper:Hide();
	self.SingleBarLargeUpper:Hide();
	for i, bar in ipairs(self.bars) do
		bar:Hide(); 
	end
end

function StatusTrackingManagerMixin:SetInitialBarSize()
	self.barHeight = self.SingleBarLarge:GetHeight();
end 

function StatusTrackingManagerMixin:GetInitialBarHeight()
	return self.barHeight; 
end

-- Sets the bar size depending on whether the bottom right multi-bar is shown. 
-- If the multi-bar is shown, a different texture needs to be displayed that is smaller. 
function StatusTrackingManagerMixin:SetDoubleBarSize(bar, width)
	local textureHeight = self:GetInitialBarHeight(); 
	local statusBarHeight = textureHeight - 4; 
	if( self.largeSize ) then 
		self.SingleBarLargeUpper:SetSize(width, statusBarHeight); 
		self.SingleBarLargeUpper:SetPoint("CENTER", bar, 0, 4);
		self.SingleBarLargeUpper:Show();
		
		self.SingleBarLarge:SetSize(width, statusBarHeight); 
		self.SingleBarLarge:SetPoint("CENTER", bar, 0, -9);
		self.SingleBarLarge:Show(); 
	else		
		self.SingleBarSmallUpper:SetSize(width, statusBarHeight); 
		self.SingleBarSmallUpper:SetPoint("CENTER", bar, 0, 4);
		self.SingleBarSmallUpper:Show(); 
		
		self.SingleBarSmall:SetSize(width, statusBarHeight); 
		self.SingleBarSmall:SetPoint("CENTER", bar, 0, -9);
		self.SingleBarSmall:Show(); 
	end

	local progressWidth = width - self:GetEndCapWidth() * 2;
	bar.StatusBar:SetSize(progressWidth, statusBarHeight);
	bar:SetSize(progressWidth, statusBarHeight);
end

--Same functionality as previous function except shows only one bar. 
function StatusTrackingManagerMixin:SetSingleBarSize(bar, width) 
	local textureHeight = self:GetInitialBarHeight();
	if( self.largeSize ) then  
		self.SingleBarLarge:SetSize(width, textureHeight); 
		self.SingleBarLarge:SetPoint("CENTER", bar, 0, 0);
		self.SingleBarLarge:Show(); 
	else
		self.SingleBarSmall:SetSize(width, textureHeight); 
		self.SingleBarSmall:SetPoint("CENTER", bar, 0, 0);
		self.SingleBarSmall:Show(); 
	end
	local progressWidth = width - self:GetEndCapWidth() * 2;
	bar.StatusBar:SetSize(progressWidth, textureHeight);
	bar:SetSize(progressWidth, textureHeight);
end

function StatusTrackingManagerMixin:LayoutBar(bar, barWidth, isTopBar, isDouble)
	bar:Update(); 
	bar:Show(); 
		
	bar:ClearAllPoints();
	
	if ( isDouble ) then
		if ( isTopBar ) then
			bar:SetPoint("BOTTOM", self:GetParent(), 0, -10);
		else		
			bar:SetPoint("BOTTOM", self:GetParent(), 0, -19);
		end
		self:SetDoubleBarSize(bar, barWidth);
	else 
		bar:SetPoint("BOTTOM", self:GetParent(), 0, -14);
		self:SetSingleBarSize(bar, barWidth);
	end
end

function StatusTrackingManagerMixin:LayoutBars(visBars)
	local width = self:GetParent():GetSize();
	self:HideStatusBars();

	local TOP_BAR = true;
	local IS_DOUBLE = true;
	if ( #visBars > 1 ) then
		self:LayoutBar(visBars[2], width, not TOP_BAR, IS_DOUBLE);
		self:LayoutBar(visBars[1], width, TOP_BAR, IS_DOUBLE);
	elseif( #visBars == 1 ) then 
		self:LayoutBar(visBars[1], width, TOP_BAR, not IS_DOUBLE);
	end 
	self:GetParent():OnStatusBarsUpdated();
	self:UpdateBarTicks();
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
	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED");
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterUnitEvent("UNIT_LEVEL", "player")
	self:SetInitialBarSize();
	self:UpdateBarsShown(); 
end

function StatusTrackingManagerMixin:OnEvent(event)
	if ( event == "CVAR_UPDATE" ) then
		self:UpdateBarVisibility();
	end	
	self:UpdateBarsShown(); 
end

function StatusTrackingManagerMixin:GetEndCapWidth()
	return self.endCapWidth;
end

function StatusTrackingManagerMixin:SetEndCapWidth(width)
	self.endCapWidth = width;
end