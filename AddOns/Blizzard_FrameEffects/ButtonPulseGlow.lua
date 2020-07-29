ButtonPulseGlow = {};

function ButtonPulseGlow:Show(button)
	if not self.framePool then
		self.framePool = CreateFramePool("FRAME", nil, "ButtonPulseGlowTemplate");
	end

	local frame = self:GetExisting(button);
	if frame then
		return;
	end

	frame = self.framePool:Acquire();
	frame.button = button;
	frame:SetParent(button);
	frame:ClearAllPoints();
	frame:SetFrameStrata("DIALOG");
	frame:SetPoint("LEFT", button, -12, 0);
	frame:SetPoint("RIGHT", button, 12, 0);
	UIFrameFlash(frame, 1, 1, -1);
end

function ButtonPulseGlow:Hide(button)
	local frame = self:GetExisting(button);
	if frame then
		UIFrameFlashStop(frame);
		self.framePool:Release(frame);
	end
end

function ButtonPulseGlow:SetShown(button, shown)
	if shown then
		self:Show(button);
	else
		self:Hide(button);
	end
end

function ButtonPulseGlow:GetExisting(button)
	if not self.framePool then
		return;
	end
	for frame in self.framePool:EnumerateActive() do
		if frame.button == button then
			return frame;
		end
	end
end