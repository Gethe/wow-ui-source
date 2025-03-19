
function KeyboardMouseConfirmButton_OnClick()
	TutorialKeyboardMouseFrame_Frame:HideTutorial();
end
-- ------------------------------------------------------------------------------------------------------------


TutorialKeyboardMouseFrameMixin = {};

function TutorialKeyboardMouseFrameMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self, "NewPlayerTutorial");

	self:MarkDirty();

	Dispatcher:RegisterEvent("UI_SCALE_CHANGED", self);
end

function TutorialKeyboardMouseFrameMixin:ShowTutorial(content, duration, position)
	self:_AnimateIn();
end

function TutorialKeyboardMouseFrameMixin:HideTutorial()
	self:_AnimateOut();
end

function TutorialKeyboardMouseFrameMixin:UI_SCALE_CHANGED()
	self:UpdateScale();
end

function TutorialKeyboardMouseFrameMixin:UpdateScale()
	local ratio = self:GetHeight() / UIParent:GetHeight();
	if (ratio > 0.3) then
		self:SetScale(0.3 / ratio);
	else
		self:SetScale(1);
	end
end

function TutorialKeyboardMouseFrameMixin:_AnimateIn()
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
		data.object.DesiredContent = nil;
		self.fadeInModelUpdater = nil; 
	end
	self.fadeInModelUpdater = CreateObjectUpdater(data, Update, IsComplete, Finish);
end

function TutorialKeyboardMouseFrameMixin:_AnimateOut()
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
		data.object:Hide();
		self.fadeOutModelUpdater = nil; 
		EventRegistry:TriggerEvent("TutorialKeyboardMouseFrame.Closed");
	end
	self.fadeOutModelUpdater = CreateObjectUpdater(data, Update, IsComplete, Finish);
end

-- ------------------------------------------------------------------------------------------------------------
TutorialWalkMixin = CreateFromMixins(TutorialMainFrameMixin);
function TutorialWalkMixin:OnLoad()
	TutorialMainFrameMixin.OnLoad(self);
end

function TutorialWalkMixin:SetKeybindings()
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

function TutorialWalkMixin:_SetContent(content)
	self:SetKeybindings();
	self:MarkDirty();
	self.ContainerFrame:MarkDirty();
	self:_AnimateIn();
end

function TutorialWalkMixin:HideTutorial(id)
	self:_AnimateOut();
	if (self.Timer) then
		self.Timer:Cancel();
	end
end