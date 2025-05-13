CharacterSelectUIMixin = {};

function CharacterSelectUIMixin:OnLoad()
	self.RotationStartX = nil;
	self.RotationConstant = 0.6;
	self.DoubleClickThreshold = 0.3;

	self.inVisibilityDoubleClickThreshold = false;
	self.visibilityState = true;
	local function VisibilityToggleOnClick()
		local visibilityState = not self.VisibilityFramesContainer:IsShown();

		self.visibilityState = visibilityState;

		self.VisibilityFramesContainer:SetShown(visibilityState);

		local buttonArtKit = visibilityState and "128-redbutton-visibilityon" or "128-redbutton-visibilityoff";
		self.VisibilityToggleButton:SetButtonArtKit(buttonArtKit);

		self.VisibilityToggleButton:SetShown(visibilityState);

		SetCharacterSelectUIVisibilityState(visibilityState);
	end
	self.VisibilityToggleButton:SetScript("OnClick", VisibilityToggleOnClick);
end

function CharacterSelectUIMixin:OnUpdate()
    if self.RotationStartX then
        local x = GetCursorPosition();
        local diff = (x - self.RotationStartX) * self.RotationConstant;
        self.RotationStartX = GetCursorPosition();
        SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
    end
end

function CharacterSelectUIMixin:OnMouseDown(button)
    if button == "LeftButton" then
        self.RotationStartX = GetCursorPosition();
    end
end

function CharacterSelectUIMixin:OnMouseUp(button)
	if button == "LeftButton" then
        self.RotationStartX = nil
    end

	-- Visibility toggle logic.
	if self:GetVisibilityState() then
		return;
	end

	local isVisibilityDoubleClick = self.inVisibilityDoubleClickThreshold;
	if not self.inVisibilityDoubleClickThreshold then
		C_Timer.After(self.DoubleClickThreshold, function()
			self.inVisibilityDoubleClickThreshold = false;
		end);
		self.inVisibilityDoubleClickThreshold = true;
	end

	if isVisibilityDoubleClick then
		self:ToggleVisibilityButtonState();
		self.inVisibilityDoubleClickThreshold = false;
	end
end

function CharacterSelectUIMixin:GetVisibilityState()
	return self.visibilityState;
end

function CharacterSelectUIMixin:ToggleVisibilityState()
	self.VisibilityToggleButton:Click();
end

function CharacterSelectUIMixin:ToggleVisibilityButtonState()
	self.VisibilityToggleButton:SetShown(not self.VisibilityToggleButton:IsShown());
end

function CharacterSelectUIMixin:ResetVisibilityState()
	if not self:GetVisibilityState() then
		self:ToggleVisibilityState();
	end
end
