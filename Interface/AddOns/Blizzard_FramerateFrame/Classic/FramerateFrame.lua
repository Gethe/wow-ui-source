local FRAMERATE_FREQUENCY = 0.25;

function ToggleFramerate(benchmark)
	FramerateText.benchmark = benchmark;
	if ( FramerateFrame:IsShown() ) then
		FramerateFrame:Hide();
	else
		FramerateFrame:Show();
	end
	FramerateFrame.fpsTime = 0;
end

function FramerateFrame_OnShow(self)
	self.fpsTime = 0;
end

function FramerateFrame_OnUpdate(self, elapsed)
	if ( FramerateText:IsShown() ) then
		local timeLeft = self.fpsTime - elapsed
		if ( timeLeft <= 0 ) then
			self.fpsTime = FRAMERATE_FREQUENCY;
			local framerate = GetFramerate();
			FramerateText:SetFormattedText("%.1f", framerate);
		else
			self.fpsTime = timeLeft;
		end
	end
end
