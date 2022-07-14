
function KeyboardMouseConfirmButton_OnClick()
	NPE_TutorialKeyboardMouseFrame_Frame:HideTutorial();
end
-- ------------------------------------------------------------------------------------------------------------


NPE_TutorialKeyboardMouseFrameMixin = {};

function NPE_TutorialKeyboardMouseFrameMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self, "NewPlayerTutorial");

	self:MarkDirty();
	self.Alpha = 0;
	self.State = NPE_TutorialMainFrameMixin.States.Hidden;
	self.IsUpdating = false;
	self.DesiredAlpha = nil;

	Dispatcher:RegisterEvent("UI_SCALE_CHANGED", self);
	Dispatcher:RegisterEvent("CINEMATIC_START", self);
	Dispatcher:RegisterEvent("CINEMATIC_STOP", self);
end

function NPE_TutorialKeyboardMouseFrameMixin:CINEMATIC_START()
	self:Hide();
end

function NPE_TutorialKeyboardMouseFrameMixin:CINEMATIC_STOP()
	self:Show();
end

function NPE_TutorialKeyboardMouseFrameMixin:ShowTutorial(content, duration, position)
	self:_AnimateIn();
end

function NPE_TutorialKeyboardMouseFrameMixin:HideTutorial()
	self:_AnimateOut();
end

function NPE_TutorialKeyboardMouseFrameMixin:UI_SCALE_CHANGED()
	if (NewPlayerExperience:GetIsActive()) then
		self:UpdateScale();
	end
end

function NPE_TutorialKeyboardMouseFrameMixin:UpdateScale()
	local ratio = self:GetHeight() / UIParent:GetHeight();
	if (ratio > 0.3) then
		self:SetScale(0.3 / ratio);
	else
		self:SetScale(1);
	end
end

function NPE_TutorialKeyboardMouseFrameMixin:_AnimateIn()
	if (self:GetAlpha() < 1) then
		self.DesiredAlpha = 1;
		self:_HookUpdate();
	else
		self.State = NPE_TutorialMainFrameMixin.States.Visible;
		self.DesiredContent = nil;
		self:_UnhookUpdate();
	end
end

function NPE_TutorialKeyboardMouseFrameMixin:_AnimateOut()
	if (self:GetAlpha() > 0) then
		self.DesiredAlpha = 0;
		self:_HookUpdate();
	else
		self.State = NPE_TutorialMainFrameMixin.States.Hidden;
		self.DesiredAlpha = nil;
		self:_UnhookUpdate();
	end
end

local fadeInTime = 0.25;
local fadeOutTime = 0.25;
function NPE_TutorialKeyboardMouseFrameMixin:UpdateAnimation(elapsed)
	local currentAlpha = self:GetAlpha();

	if (currentAlpha < self.DesiredAlpha) then
		self.State = NPE_TutorialMainFrameMixin.States.AnimatingIn;
	elseif (currentAlpha > self.DesiredAlpha) then
		self.State = NPE_TutorialMainFrameMixin.States.AnimatingOut;
	end

	self.elapsedTime = self.elapsedTime and self.elapsedTime + elapsed or 0;

	if (self.State == NPE_TutorialMainFrameMixin.States.AnimatingOut) then
		self.Alpha = 1 - math.min(1, (self.elapsedTime / fadeOutTime));
		if (self.Alpha == 0) then
			self.elapsedTime = nil;
			self.State = NPE_TutorialMainFrameMixin.States.Hidden;
		end
	elseif (self.State == NPE_TutorialMainFrameMixin.States.AnimatingIn) then
		self.Alpha = math.min(1, (self.elapsedTime / fadeInTime));
		if (self.Alpha == 1) then
			self.elapsedTime = nil;
			self.State = NPE_TutorialMainFrameMixin.States.Visible;
		end
	else
		error("ERROR - NPE Tutorial Main Frame updating but not animating");
	end
	self:SetAlpha(self.Alpha);

	-- When an animation is complete
	if (self.State == NPE_TutorialMainFrameMixin.States.Hidden) then
		self:_UnhookUpdate();
		self:Hide();
		EventRegistry:TriggerEvent("NPE_TutorialKeyboardMouseFrame.Closed");
	elseif  (self.State == NPE_TutorialMainFrameMixin.States.Visible) then
		self:_UnhookUpdate();
	end
end

function NPE_TutorialKeyboardMouseFrameMixin:_HookUpdate()
	if (not self.IsUpdating) then
		self:SetScript("OnUpdate", self.UpdateAnimation);
		self.IsUpdating = true;
	end
end

function NPE_TutorialKeyboardMouseFrameMixin:_UnhookUpdate()
	if (self.IsUpdating) then
		self:SetScript("OnUpdate", ResizeLayoutMixin.OnUpdate);
		self.IsUpdating = false;
	end
end
