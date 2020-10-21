NPE_TutorialMainFrameMixin = {};

NPE_TutorialMainFrameMixin.States =
{
	Hidden			= "hidden",
	AnimatingIn		= "animatingIn",
	Visible			= "visible",
	AnimatingOut	= "animatingOut",
}

NPE_TutorialMainFrameMixin.FramePositions =
{
	Default = 160,
	Low		= -140,
}

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrameMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self, "NewPlayerTutorial");

	self:MarkDirty();

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
function NPE_TutorialMainFrameMixin:CINEMATIC_START()
	self:Hide();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrameMixin:CINEMATIC_STOP()
	self:Show();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialMainFrameMixin:ShowTutorial(content, duration, position)
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

function NPE_TutorialMainFrameMixin:HideTutorial(id)
	if (self.CurrentID == id) then
		self:_AnimateOut();
		self.DesiredContent = nil;
		self.DesiredPosition = nil;

		if (self.Timer) then
			self.Timer:Cancel();
		end
	end
end

function NPE_TutorialMainFrameMixin:_HookUpdate()
	if (not self.IsUpdating) then
		self:SetScript("OnUpdate", self.UpdateAnimation);
		self.IsUpdating = true;
	end
end

function NPE_TutorialMainFrameMixin:_UnhookUpdate()
	if (self.IsUpdating) then
		self:SetScript("OnUpdate", ResizeLayoutMixin.OnUpdate);
		self.IsUpdating = false;
	end
end

function NPE_TutorialMainFrameMixin:_SetContent(content)
	content = content or self.DesiredContent;
	self.DesiredContent = nil;

	local icon = self.ContainerFrame.Icon;
	local text = self.ContainerFrame.Text;

	if content.text then
		text:SetSize(0, 0);
		text:SetText(content.text);
		text:SetWidth(text:GetStringWidth());
		text:SetHeight(text:GetStringHeight());
		text:ClearAllPoints();
		text:SetPoint("LEFT", self.ContainerFrame.Icon, "RIGHT", "25", "0");
	end

	if content.icon then
		icon:SetAtlas(content.icon, true);
		icon:Show();
	else
		icon:SetAtlas(nil);
		icon:Hide();
		text:ClearAllPoints();
		text:SetPoint("CENTER");
	end
	self.ContainerFrame:MarkDirty();
	self:_AnimateIn();
end

function NPE_TutorialMainFrameMixin:_SetPosition(position)
	position = position or self.DesiredPosition;
	self.DesiredPosition = nil;
	self:SetPoint("CENTER", 0, position);
	self:_AnimateIn();
end

function NPE_TutorialMainFrameMixin:_SetDesiredContent(content)
	if (self.State == self.States.Hidden) then
		self:_SetContent(content)
	else
		self.DesiredContent = content;
		self:_AnimateOut();
	end
end

function NPE_TutorialMainFrameMixin:_SetDesiredPosition(position)
	if (self.State == self.States.Hidden) then
		self:_SetPosition(position);
	else
		self.DesiredPosition = position;
		self:_AnimateOut();
	end
end

local fadeInTime = 0.25;
local fadeOutTime = 0.25;
function NPE_TutorialMainFrameMixin:UpdateAnimation(elapsed)
	ResizeLayoutMixin.OnUpdate(self, elapsed);
	local currentAlpha = self:GetAlpha();

	if (currentAlpha < self.DesiredAlpha) then
		self.State = self.States.AnimatingIn;
	elseif (currentAlpha > self.DesiredAlpha) then
		self.State = self.States.AnimatingOut;
	end

	self.elapsedTime = self.elapsedTime and self.elapsedTime + elapsed or 0;

	if (self.State == self.States.AnimatingOut) then
		self.Alpha = 1 - math.min(1, (self.elapsedTime / fadeOutTime));
		if (self.Alpha == 0) then
			self.elapsedTime = nil;
			self.State = self.States.Hidden;
		end
	elseif (self.State == self.States.AnimatingIn) then
		self.Alpha = math.min(1, (self.elapsedTime / fadeInTime));
		if (self.Alpha == 1) then
			self.elapsedTime = nil;
			self.State = self.States.Visible;
		end
	else
		error("ERROR - NPE Tutorial Main Frame updating but not animating");
	end
	self:SetAlpha(self.Alpha);

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

function NPE_TutorialMainFrameMixin:_AnimateIn()
	if (self:GetAlpha() < 1) then
		self.DesiredAlpha = 1;
		self:_HookUpdate();
	else
		self.State = self.States.Visible;
		self.DesiredContent = nil;
		self:_UnhookUpdate();
	end
end

function NPE_TutorialMainFrameMixin:_AnimateOut()
	if (self:GetAlpha() > 0) then
		self.DesiredAlpha = 0;
		self:_HookUpdate();
	else
		self.State = self.States.Hidden;
		self.DesiredAlpha = nil;
		self:_UnhookUpdate();
	end
end


-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialSingleKeyMixin = CreateFromMixins(NPE_TutorialMainFrameMixin);
function NPE_TutorialSingleKeyMixin:OnLoad()
	NPE_TutorialMainFrameMixin.OnLoad(self);

	self:MarkDirty();
end

function NPE_TutorialSingleKeyMixin:SetKeyText(keyText)
	local container = self.ContainerFrame.KeyBind;
	if container then
		local fontString = container.KeyBind;
		if (keyText and (keyText ~= "")) then
			fontString:SetText(keyText);
		end
	end
end

function NPE_TutorialSingleKeyMixin:_SetContent(content)
	self:SetKeyText(content.keyText);

	local text = self.ContainerFrame.Text;
	if content.text then
		text:SetSize(0, 0);
		text:SetText(content.text);
		text:SetWidth(text:GetStringWidth());
		text:SetHeight(text:GetStringHeight());
		text:ClearAllPoints();
		text:SetPoint("LEFT", self.ContainerFrame.KeyBind, "RIGHT", 20, 0);
	end

	self.ContainerFrame:MarkDirty();
	self:_AnimateIn();
end

function NPE_TutorialSingleKeyMixin:HideTutorial(id)
	self:_AnimateOut();
	if (self.Timer) then
		self.Timer:Cancel();
	end
end


-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialWalkMixin = CreateFromMixins(NPE_TutorialMainFrameMixin);
function NPE_TutorialWalkMixin:OnLoad()
	NPE_TutorialMainFrameMixin.OnLoad(self);
end

function NPE_TutorialWalkMixin:SetKeybindings()
	local binds = {
		"MOVEFORWARD",
		"TURNLEFT",
		"MOVEBACKWARD",
		"TURNRIGHT",
	}

	for i, v in pairs(binds) do
		local container = self.ContainerFrame[v];
		if container then
			local fontString = container.KeyBind;
			local key = GetBindingKey(v);
			local bindingText;
			if key == "LEFT" then
				bindingText = NPEV2_LEFT_ARROW;
			elseif key == "RIGHT" then
				bindingText = NPEV2_RIGHT_ARROW;
			elseif key ~= "" then
				bindingText = GetBindingText(key, 1);
			else
				fontString:SetText("");
			end

			if (bindingText and (bindingText ~= "")) then
				fontString:SetText(bindingText);
			end
		end
	end
end

function NPE_TutorialWalkMixin:_SetContent(content)
	self:SetKeybindings();
	self:MarkDirty();
	self.ContainerFrame:MarkDirty();
	self:_AnimateIn();
end

function NPE_TutorialWalkMixin:HideTutorial(id)
	self:_AnimateOut();
	if (self.Timer) then
		self.Timer:Cancel();
	end
end