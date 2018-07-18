StatusTrackingBarMixin = { } 

function StatusTrackingBarMixin:GetPriority()
	return self.priority; 
end

--Override this in your bar.lua function 
function StatusTrackingBarMixin:Update()
	error("Implement an update function on your bar");
end

--Override this to update the bar tick (if the bar has one) 
--Called when the bar is resized (RightBottomBar enabled/disabled)
function StatusTrackingBarMixin:UpdateTick()

end

function StatusTrackingBarMixin:UpdateAll()
	self:Update(); 	
	self:UpdateTick();
	self:UpdateTextVisibility(); 
end	

function StatusTrackingBarMixin:SetBarText(barText) 
	self.OverlayFrame.Text:SetText(barText); 
end

function StatusTrackingBarMixin:ShowText() 
	self:SetTextLocked(true);
end

function StatusTrackingBarMixin:HideText() 
	self:SetTextLocked(false);
end

function StatusTrackingBarMixin:SetBarValues(currentValue, minBar, maxBar, level) 
	self.StatusBar:SetAnimatedValues(currentValue, minBar, maxBar, level); 
end

function StatusTrackingBarMixin:SetBarColor(r, g, b)
	self.StatusBar:SetStatusBarColor(r, g, b);
	self.StatusBar:SetAnimatedTextureColors(r, g, b);
end

function StatusTrackingBarMixin:ShouldBarTextBeDisplayed()
	return GetCVarBool("xpBarText") or self.textLocked or self:GetParent():IsTextLocked();
end

function StatusTrackingBarMixin:SetTextLocked(locked)
	if ( self.textLocked ~= locked ) then
		self.textLocked = locked;
		self:UpdateTextVisibility();
	end
end

function StatusTrackingBarMixin:UpdateTextVisibility()
	self.OverlayFrame.Text:SetShown(self:ShouldBarTextBeDisplayed()); 
end
