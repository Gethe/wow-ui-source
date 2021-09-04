NPE_TutorialMainFrame = {};

NPE_TutorialMainFrame.States =
{
	Hidden			= "hidden",
	AnimatingIn		= "animatingIn",
	Visible			= "visible",
	AnimatingOut	= "animatingOut",
}

NPE_TutorialMainFrame.FramePositions =
{
	Default = 160,
	Low		= -140,
}

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrame:Initialize(frame)
	self.Frame = frame;

	self.NextID = 1;
	self.CurrentID = nil;

	self.Content = nil;
	self.Position = self.FramePositions.Default;
	self.Alpha = 0;
	self.State = self.States.Hidden;
	self.IsUpdating = false;

	self.Timer = nil;

	self.DesiredContent = nil;
	self.DesiredAlpha = nil;
	self.DesiredPosition = nil;

	Dispatcher:RegisterEvent("CINEMATIC_START", self);
	Dispatcher:RegisterEvent("CINEMATIC_STOP", self);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrame:CINEMATIC_START()
	self.Frame:Hide();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrame:CINEMATIC_STOP()
	self.Frame:Show();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrame:Show(content, duration, position)
	self:_SetDesiredContent(content);
	self:_SetDesiredPosition(position or self.FramePositions.Default);

	self.CurrentID = self.NextID;
	self.NextID = self.NextID + 1;

	if (self.Timer) then
		self.Timer:Cancel();
	end

	if (duration and (duration > 0)) then
		self.Timer = C_Timer.NewTimer(duration, function() self:Hide(self.CurrentID) end);
	end

	return self.CurrentID;
end

function NPE_TutorialMainFrame:Hide(id)
	if (self.CurrentID == id) then
		self:_AnimateOut();
		self.DesiredContent = nil;
		self.DesiredPosition = nil;

		if (self.Timer) then
			self.Timer:Cancel();
		end
	end
end

function NPE_TutorialMainFrame:_HookUpdate()
	if (not self.IsUpdating) then
		Dispatcher:RegisterEvent("OnUpdate", self);
		self.IsUpdating = true;
	end
end

function NPE_TutorialMainFrame:_UnhookUpdate()
	if (self.IsUpdating) then
		Dispatcher:UnregisterEvent("OnUpdate", self);
		self.IsUpdating = false;
	end
end

function NPE_TutorialMainFrame:_SetContent(content)
	content = content or self.DesiredContent;
	self.DesiredContent = nil;
	self.Frame.Text:SetText(content);
	self:_AnimateIn();
end

function NPE_TutorialMainFrame:_SetPosition(position)
	position = position or self.DesiredPosition;
	self.DesiredPosition = nil;
	self.Frame:SetPoint("CENTER", 0, position);
	self:_AnimateIn();
end

function NPE_TutorialMainFrame:_SetDesiredContent(content)
	if (self.State == self.States.Hidden) then
		self:_SetContent(content)
	else
		self.DesiredContent = content;
		self:_AnimateOut();
	end
end

function NPE_TutorialMainFrame:_SetDesiredPosition(position)
	if (self.State == self.States.Hidden) then
		self:_SetPosition(position);
	else
		self.DesiredPosition = position;
		self:_AnimateOut();
	end
end

function NPE_TutorialMainFrame:OnUpdate(elapsed)
	local currentAlpha = self.Frame:GetAlpha();

	if (currentAlpha < self.DesiredAlpha) then
		self.State = self.States.AnimatingIn;
	elseif (currentAlpha > self.DesiredAlpha) then
		self.State = self.States.AnimatingOut;
	end

	local newAlpha;

	if (self.State == self.States.AnimatingOut) then
		newAlpha = math.max(0, self.Alpha - elapsed);

		if (newAlpha == 0) then
			self.State = self.States.Hidden;
		end
	elseif (self.State == self.States.AnimatingIn) then
		newAlpha = math.min(1, self.Alpha + elapsed);

		if (newAlpha == 1) then
			self.State = self.States.Visible;
		end
	else
		error("ERROR - NPE Tutorial Main Frame updating but not animating");
	end

	self.Alpha = newAlpha;
	self.Frame:SetAlpha(newAlpha);

	-- When an animation is complete
	if ((self.State == self.States.Hidden) or (self.State == self.States.Visible)) then
		local unhook = true;

		if (self.State == self.States.Hidden) then
			if (self.DesiredContent) then
				self:_SetContent();
				unhook = false;
			end

			if (self.DesiredPosition) then
				self:_SetPosition();
				unhook = false;
			end
		end

		if (unhook) then
			self:_UnhookUpdate();
		end
	end
end

function NPE_TutorialMainFrame:_AnimateIn()
	if (self.Frame:GetAlpha() < 1) then
		self.DesiredAlpha = 1;
		self:_HookUpdate();
	else
		self.State = self.States.Visible;
		self.DesiredContent = nil;
		self:_UnhookUpdate();
	end
end

function NPE_TutorialMainFrame:_AnimateOut()
	if (self.Frame:GetAlpha() > 0) then
		self.DesiredAlpha = 0;
		self:_HookUpdate();
	else
		self.State = self.States.Hidden;
		self.DesiredAlpha = nil;
		self:_UnhookUpdate();
	end
end