ToolWindowOwnerMixin = {};

function ToolWindowOwnerMixin:MoveToNewWindow(title, width, height, minWidth, minHeight, topMost)
	local popupStyle = true; -- No window title bar or window borders
	local window = CreateWindow(popupStyle, topMost); -- topMost sets "Always on top", must be set at window creation time. defaults to false
	if not window then
		return false;
	end

	-- Setup window visual
	window:SetTitle(title);

	-- FIXME: The size passed to SetWindowSize will be overwritten by SetMinSize because
	-- the desired size is unretrievable until the view event pump updates the actual window rect.
	if width and height then
		window:SetWindowSize(width, height);
	end

	if minWidth and minHeight then
		window:SetMinSize(minWidth, minHeight);
	end

	-- Move to window
	self:SetWindow(window);
	self:SetAllPoints(window);

	-- Setup various callbacks to redirect actions to affect window
	self.onCloseCallback = function(closeButton)
		local parent = closeButton:GetParent();
		local window = parent and parent:GetWindow();
		if window then
			window:Close();
		end

		return true;
	end

	self.onDragStartCallback = function()
		window:StartMoving();
		return false;
	end

	self.onDragStopCallback = function()
		window:StopMovingOrSizing();
		return false;
	end

	self.onResizeStartCallback = function()
		window:StartSizing();
		return false;
	end

	self.onResizeStopCallback = function()
		window:StopMovingOrSizing();
		return false;
	end

	return true;
end

function ToolWindowOwnerMixin:SetMinSize(minWidth, minHeight)
	local window = self:GetWindow();
	if not window then
		return;
	end

	if minWidth and minHeight then
		window:SetMinSize(minWidth, minHeight);
	end
end

function ToolWindowOwnerMixin:SetWindowFocus()
	local window = self:GetWindow();
	if not window then
		return;
	end

	window:SetFocus();
end

function ToolWindowOwnerMixin:IsTopmost()
	local window = self:GetWindow();
	if not window then
		return;
	end

	return window:IsTopmost();
end

function ToolWindowOwnerMixin:SetTopmost(topmost)
	local window = self:GetWindow();
	if not window then
		return;
	end

	window:SetTopmost(topmost);
end

function ToolWindowOwnerMixin:MoveToMainWindow()
	local window = self:GetWindow();
	if not window then
		return;
	end

	self.onCloseCallback = nil;
	self.onDragStartCallback = nil;
	self.onDragStopCallback = nil;
	self.onResizeStartCallback = nil;
	self.onResizeStopCallback = nil;
	self:SetWindow(nil);
	window:Close();
end
