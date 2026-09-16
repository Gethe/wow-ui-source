NPE_TutorialCallout = {};

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialCallout:Initialize()
	self.FramePool = {};
	self.InUseFrames = {};
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialCallout:Show()
	local frame = self:_GetFrame();

	frame:Show();
	frame.Animator.Anim_Pulse:Play();

	return frame;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialCallout:Hide(frame)
	for i = #self.InUseFrames, 1, -1 do
		local f = self.InUseFrames[i];

		-- hide all frames if no frame is passed
		if ((not frame) or (f == frame)) then
			f:Hide();
			f.Animator.Anim_Pulse:Stop();
			table.insert(self.FramePool, f);
			table.remove(self.InUseFrames, i);
		end
	end

end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialCallout:_GetFrame()
	local frame;

	if (#self.FramePool > 0) then
		frame = table.remove(self.FramePool);
	else
		frame = CreateFrame("frame", nil, UIParent, "NPE_TutorialCallout");
	end

	frame:ClearAllPoints();
	frame:SetSize(0, 0);

	table.insert(self.InUseFrames, frame);
	return frame;
end






-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialCallout:Initialize();