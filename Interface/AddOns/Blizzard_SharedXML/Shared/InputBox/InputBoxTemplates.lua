
function InputBoxInstructions_OnTextChanged(self)
	self.Instructions:SetShown(self:GetText() == "")
end

function InputBoxInstructions_UpdateColorForEnabledState(self, color)
	if color then
		self:SetTextColor(color:GetRGBA());
	end
end

function InputBoxInstructions_OnDisable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.disabledColor);
end

function InputBoxInstructions_OnEnable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.enabledColor);
end

function SearchBoxTemplate_OnLoad(self)
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self:SetTextInsets(16, 20, 0, 0);
	self.Instructions:SetText(self.instructionText);
	self.Instructions:ClearAllPoints();
	self.Instructions:SetPoint("TOPLEFT", self, "TOPLEFT", 16, 0);
	self.Instructions:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 0);
end

function SearchBoxTemplate_OnEditFocusLost(self)
	if ( self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	end
end

function SearchBoxTemplate_OnEditFocusGained(self)
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
	self.clearButton:Show();
end

function SearchBoxTemplate_OnTextChanged(self)
	if ( not self:HasFocus() and self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	else
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.clearButton:Show();
	end
	InputBoxInstructions_OnTextChanged(self);
end

function SearchBoxTemplate_ClearText(self)
	self:SetText("");
	self:ClearFocus();
end

function SearchBoxTemplateClearButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	SearchBoxTemplate_ClearText(self:GetParent());
end

ClearButtonMixin = {};
function ClearButtonMixin:OnEnter()
	self.texture:SetAlpha(1.0);
end

function ClearButtonMixin:OnLeave()
	self.texture:SetAlpha(0.5);
end

function ClearButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);
	end
end

function ClearButtonMixin:OnMouseUp()
	self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3);
end

function ClearButtonMixin:OnClick()
	SearchBoxTemplateClearButton_OnClick(self);
end

NumericInputBoxMixin = {};

function NumericInputBoxMixin:OnTextChanged(isUserInput)
	self.valueChangedCallback(self:GetNumber(), isUserInput);
end

function NumericInputBoxMixin:OnEditFocusLost()
	EditBox_ClearHighlight(self);

	self.valueFinalizedCallback(self:GetNumber());
end

function NumericInputBoxMixin:SetOnValueChangedCallback(valueChangedCallback)
	self.valueChangedCallback = valueChangedCallback;
end

function NumericInputBoxMixin:SetOnValueFinalizedCallback(valueFinalizedCallback)
	self.valueFinalizedCallback = valueFinalizedCallback;
end

NumericInputSpinnerMixin = {};

-- "public"
function NumericInputSpinnerMixin:SetValue(value)
	local newValue = Clamp(value, self.min or -math.huge, self.max or math.huge);
	local clampIfExceededRange = self.clampIfInputExceedsRange and (value ~= newValue);
	local changed = newValue ~= self.currentValue;
	if clampIfExceededRange or changed then
		self.currentValue = newValue;
		self:SetNumber(newValue);

		if self.highlightIfInputExceedsRange and clampIfExceededRange then
			self:HighlightText();
		end

		if changed and self.onValueChangedCallback then
			self.onValueChangedCallback(self, self:GetNumber());
		end
	end
end

function NumericInputSpinnerMixin:SetMinMaxValues(min, max)
	if self.min ~= min or self.max ~= max then
		self.min = min;
		self.max = max;

		self:SetValue(self:GetValue());
	end
end

function NumericInputSpinnerMixin:GetValue()
	return self.currentValue or self.min or 0;
end

function NumericInputSpinnerMixin:SetOnValueChangedCallback(onValueChangedCallback)
	self.onValueChangedCallback = onValueChangedCallback;
end

function NumericInputSpinnerMixin:Increment(amount)
	self:SetValue(self:GetValue() + (amount or 1));
end

function NumericInputSpinnerMixin:Decrement(amount)
	self:SetValue(self:GetValue() - (amount or 1));
end

function NumericInputSpinnerMixin:SetEnabled(enable)
	self.IncrementButton:SetEnabled(enable);
	self.DecrementButton:SetEnabled(enable);
	GetEditBoxMetatable().__index.SetEnabled(self, enable);
end

function NumericInputSpinnerMixin:Enable()
	self:SetEnabled(true)
end

function NumericInputSpinnerMixin:Disable()
	self:SetEnabled(false)
end

-- "private"
function NumericInputSpinnerMixin:OnTextChanged()
	self:SetValue(self:GetNumber());
end

local MAX_TIME_BETWEEN_CHANGES_SEC = .5;
local MIN_TIME_BETWEEN_CHANGES_SEC = .075;
local TIME_TO_REACH_MAX_SEC = 3;

function NumericInputSpinnerMixin:StartIncrement()
	self.incrementing = true;
	self.startTime = GetTime();
	self.nextUpdate = MAX_TIME_BETWEEN_CHANGES_SEC;
	self:SetScript("OnUpdate", self.OnUpdate);
	self:Increment();
	self:ClearFocus();
end

function NumericInputSpinnerMixin:EndIncrement()
	self:SetScript("OnUpdate", nil);
end

function NumericInputSpinnerMixin:StartDecrement()
	self.incrementing = false;
	self.startTime = GetTime();
	self.nextUpdate = MAX_TIME_BETWEEN_CHANGES_SEC;
	self:SetScript("OnUpdate", self.OnUpdate);
	self:Decrement();
	self:ClearFocus();
end

function NumericInputSpinnerMixin:EndDecrement()
	self:SetScript("OnUpdate", nil);
end

function NumericInputSpinnerMixin:OnUpdate(elapsed)
	self.nextUpdate = self.nextUpdate - elapsed;
	if self.nextUpdate <= 0 then
		if self.incrementing then
			self:Increment();
		else
			self:Decrement();
		end

		local totalElapsed = GetTime() - self.startTime;

		local nextUpdateDelta = Lerp(MAX_TIME_BETWEEN_CHANGES_SEC, MIN_TIME_BETWEEN_CHANGES_SEC, Saturate(totalElapsed / TIME_TO_REACH_MAX_SEC));
		self.nextUpdate = self.nextUpdate + nextUpdateDelta;
	end
end

LevelRangeFrameMixin = {};

function LevelRangeFrameMixin:OnLoad()
	self.MinLevel.nextEditBox = self.MaxLevel;
	self.MaxLevel.nextEditBox = self.MinLevel;

	local function OnTextChanged(...)
		self:OnLevelRangeChanged();
	end
	self.MinLevel:SetScript("OnTextChanged", OnTextChanged);
	self.MaxLevel:SetScript("OnTextChanged", OnTextChanged);
end

function LevelRangeFrameMixin:OnHide()
	self:FixLevelRange();
end

function LevelRangeFrameMixin:SetLevelRangeChangedCallback(levelRangeChangedCallback)
	self.levelRangeChangedCallback = levelRangeChangedCallback;
end

function LevelRangeFrameMixin:OnLevelRangeChanged()
	if self.levelRangeChangedCallback then
		local minLevel, maxLevel = self:GetLevelRange();
		self.levelRangeChangedCallback(minLevel, maxLevel);
	end
end

function LevelRangeFrameMixin:FixLevelRange()
	local maxLevel = self.MaxLevel:GetNumber();
	if maxLevel == 0 then
		return;
	end

	local minLevel = self.MinLevel:GetNumber();
	if minLevel > maxLevel then
		self:SetMinLevel(maxLevel);
	end
end

function LevelRangeFrameMixin:SetMinLevel(minLevel)
	self.MinLevel:SetNumber(minLevel);
end

function LevelRangeFrameMixin:SetMaxLevel(maxLevel)
	self.MaxLevel:SetNumber(maxLevel);
end

function LevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("");
	self.MaxLevel:SetText("");
end

function LevelRangeFrameMixin:GetLevelRange()
	return self.MinLevel:GetNumber(), self.MaxLevel:GetNumber();
end
