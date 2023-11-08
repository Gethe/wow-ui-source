ToolWindowOwnerMixin = {};

function ToolWindowOwnerMixin:MoveToNewWindow(title, width, height, minWidth, minHeight)
	local window = CreateWindow();
	if not window then
		return false;
	end

	-- Setup window visual
	window:SetTitle(title);

	if width and height then
		window:SetSize(width, height);
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
