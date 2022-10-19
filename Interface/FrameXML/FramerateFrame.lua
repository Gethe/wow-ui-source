function ToggleFramerate(benchmark)
	FramerateText.benchmark = benchmark;
	if ( FramerateText:IsShown() ) then
		FramerateLabel:Hide();
		FramerateText:Hide();
	else
		FramerateLabel:Show();
		FramerateText:Show();
	end
	FramerateFrame.fpsTime = 0;
end

FramerateDisplayMixin = {};

function FramerateDisplayMixin:OnShow()
	EventRegistry:RegisterCallback("QueueStatusButton.OnShow", self.UpdateAnchor, self);
	EventRegistry:RegisterCallback("QueueStatusButton.OnHide", self.UpdateAnchor, self);
end

function FramerateDisplayMixin:OnUpdate(elapsed)
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

function FramerateDisplayMixin:UpdateAnchor()
	FramerateText:ClearAllPoints();
	if (QueueStatusButton and QueueStatusButton:IsShown()) then
		FramerateText:SetPoint("BOTTOMRIGHT", QueueStatusButton, "BOTTOMLEFT", -5, 5);
	else
		FramerateText:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, "BOTTOMLEFT", -5, 5);
	end
end

function FramerateDisplayMixin:OnHide()
	EventRegistry:UnregisterCallback("QueueStatusButton.OnShow", self.UpdateAnchor, self);
	EventRegistry:UnregisterCallback("QueueStatusButton.OnHide", self.UpdateAnchor, self);
end