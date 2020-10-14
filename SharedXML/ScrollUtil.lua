ScrollUtil = {};

function ScrollUtil.Init(scrollBar, scrollBox, scrollValue, elementExtent)
	local onScrollBoxScroll = function(o, scrollValue)
		scrollBar:SetScrollValue(scrollValue);
	end;
	scrollBox:RegisterCallback("OnScroll", onScrollBoxScroll, scrollBar);
	
	local onSizeChanged = function(o, extentVisibleRatio)
		scrollBar:SetExtentVisibleRatio(extentVisibleRatio);
	end;
	scrollBox:RegisterCallback("OnSizeChanged", onSizeChanged, scrollBar);
	
	local onScrollBarScroll = function(o, scrollValue)
		scrollBox:SetScrollValue(scrollValue);
	end;
	scrollBar:RegisterCallback("OnScroll", onScrollBarScroll, scrollBox);

	if scrollValue then
		scrollValue = Clamp(scrollValue, 0, 1);
	else
		scrollValue = 0;
	end

	scrollBox:Init(scrollValue, elementExtent);
	scrollBar:Init(scrollValue, scrollBox:GetExtentVisibleRatio(), scrollBox:CalculateStepExtent());
end

ScrollBarButtonScriptsMixin = {};

function ScrollBarButtonScriptsMixin:OnEnter()
	if self:IsEnabled() then
		self.Enter:Show();
	end
end

function ScrollBarButtonScriptsMixin:OnLeave()
	self.Enter:Hide();
end

function ScrollBarButtonScriptsMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Down:Show();
	end
end

function ScrollBarButtonScriptsMixin:OnMouseUp()
	self.Down:Hide();
end