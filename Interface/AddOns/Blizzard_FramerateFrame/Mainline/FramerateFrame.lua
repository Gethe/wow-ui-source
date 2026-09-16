local FRAMERATE_FREQUENCY = 0.25;

FramerateFrameMixin = {};

function FramerateFrameMixin:OnLoad()
	-- Overridden by certain flavors.
end

function FramerateFrameMixin:OnUpdate(elapsed)
	local timeLeft = self.fpsTime - elapsed
	if timeLeft <= 0 then
		self.fpsTime = FRAMERATE_FREQUENCY;
		local framerate = GetFramerate();
		local isCpuBound = IsCpuBound();
		if (isCpuBound == nil or FPS_COUNTER_CPU_BOUND == nil or FPS_COUNTER_GPU_BOUND == nil) then
			self.FramerateText:SetFormattedText("%.1f", framerate);
		else
			self.FramerateText:SetFormattedText(isCpuBound and FPS_COUNTER_CPU_BOUND or FPS_COUNTER_GPU_BOUND, framerate);
		end
		self:Layout();
	else
		self.fpsTime = timeLeft;
	end
end

function FramerateFrameMixin:OnShow()
	self.fpsTime = 0;
end

function FramerateFrameMixin:Toggle()
	self:SetShown(not self:IsShown());
end

function FramerateFrameMixin:BeginBenchmark()
	self.benchmark = true;
	self:Show();
end

function FramerateFrameMixin:EndBenchmark()
	self.benchmark = nil;
	self:Hide();
end

function FramerateFrameMixin:UpdatePosition(microMenuPosition, isMenuHorizontal, isDefaultPosition)
	-- Mainline positions the FramerateFrame relative to the MicroMenu,
	-- so this function can be overridden to accomplish that.
	-- (But by default, it does nothing and is just here for safe compatability!)
end
