TutorialMainFrameMixin = {};
TutorialMainFrameMixin.States =
{
	Hidden			= "hidden",
	AnimatingIn		= "animatingIn",
	Visible			= "visible",
	AnimatingOut	= "animatingOut",
}

TutorialMainFrameMixin.FramePositions =
{
	Default = 160,
	Low		= -140,
}

-- ------------------------------------------------------------------------------------------------------------
function TutorialMainFrameMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self, "NewPlayerTutorial");

	self:MarkDirty();

	self.NextID = 1;
	self.CurrentID = nil;

	self.Content = nil;
	self.Position = self.FramePositions.Default;
	self.State = self.States.Hidden;
	self.wasShown = false;

	self.Timer = nil;

	self.DesiredContent = nil;
	self.DesiredPosition = nil;

	Dispatcher:RegisterEvent("CINEMATIC_START", self);
	Dispatcher:RegisterEvent("CINEMATIC_STOP", self);
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialMainFrameMixin:CINEMATIC_START()
	if self:IsShown() then
		self.wasShown = true;
		self:Hide();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialMainFrameMixin:CINEMATIC_STOP()
	if self.wasShown then
		self.wasShown = false;
		self:Show();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialMainFrameMixin:ShowTutorial(content, duration, position)
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

function TutorialMainFrameMixin:HideTutorial(id)
	if (self.CurrentID == id) then
		self:_AnimateOut();
		self.DesiredContent = nil;
		self.DesiredPosition = nil;

		if (self.Timer) then
			self.Timer:Cancel();
		end
	end
end

function TutorialMainFrameMixin:_SetContent(content)
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

function TutorialMainFrameMixin:_SetPosition(position)
	position = position or self.DesiredPosition;
	self.DesiredPosition = nil;
	self:SetPoint("CENTER", 0, position);
	self:_AnimateIn();
end

function TutorialMainFrameMixin:_SetDesiredContent(content)
	if (self.State == self.States.Hidden) then
		self:_SetContent(content)
	else
		self.DesiredContent = content;
		self:_AnimateOut();
	end
end

function TutorialMainFrameMixin:_SetDesiredPosition(position)
	if (self.State == self.States.Hidden) then
		self:_SetPosition(position);
	else
		self.DesiredPosition = position;
		self:_AnimateOut();
	end
end

function TutorialMainFrameMixin:_AnimateIn()
	if self.fadeInModelUpdater then
		self.fadeInModelUpdater:Cancel();
	end
	self:Show();
	
	local data = {object = self, alphaStart = 0.0, alphaEnd = 1.0};
	local function Update(data)
		local alphaGain = Lerp(data.alphaStart, data.alphaEnd, 0.1);
		data.object:SetAlpha(Clamp(data.object:GetAlpha() + alphaGain, 0, 1));
	end
	local function IsComplete(data)
		if math.abs(data.object:GetAlpha() - data.alphaEnd) < 0.01 then
			data.object:SetAlpha(data.alphaEnd);
			return true;
		end
		return false;
	end
	local function Finish(data)
		self.State = self.States.Visible;
		data.object.DesiredContent = nil;
		self.fadeInModelUpdater = nil; 
	end
	self.fadeInModelUpdater = CreateObjectUpdater(data, Update, IsComplete, Finish);
end

function TutorialMainFrameMixin:_AnimateOut()
	if self.fadeOutModelUpdater then
		self.fadeOutModelUpdater:Cancel();
	end

	local data = {object = self, alphaStart = 1.0, alphaEnd = 0.0};
	local function Update(data)
		local alphaGain = Lerp(data.alphaStart, data.alphaEnd, 0.1);
		data.object:SetAlpha(Clamp(data.object:GetAlpha() - alphaGain, 0, 1));
	end
	local function IsComplete(data)
		if math.abs(data.object:GetAlpha() - data.alphaEnd) < 0.01 then
			data.object:SetAlpha(data.alphaEnd);
			return true;
		end
		return false;
	end
	local function Finish(data)
		self.State = self.States.Hidden;
		data.object:Hide();
		self.fadeOutModelUpdater = nil;
		if (self.DesiredContent) then
			self:_SetContent();
		end

		if (self.DesiredPosition) then
			self:_SetPosition();
		end
	end
	self.fadeOutModelUpdater = CreateObjectUpdater(data, Update, IsComplete, Finish);
end


-- ------------------------------------------------------------------------------------------------------------
TutorialSingleKeyMixin = CreateFromMixins(TutorialMainFrameMixin);
function TutorialSingleKeyMixin:OnLoad()
	TutorialMainFrameMixin.OnLoad(self);

	self:MarkDirty();
end

function TutorialSingleKeyMixin:SetKeyText(keyText)
	local container = self.ContainerFrame.KeyBind;
	if container then
		local fontString = container.KeyBind;
		if (keyText and (keyText ~= "")) then
			fontString:SetText(keyText);
		end
	end
end

function TutorialSingleKeyMixin:_SetContent(content)
	content = content or self.DesiredContent;
	self.DesiredContent = nil;
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

function TutorialSingleKeyMixin:HideTutorial(id)
	self:_AnimateOut();
	if (self.Timer) then
		self.Timer:Cancel();
	end
end
