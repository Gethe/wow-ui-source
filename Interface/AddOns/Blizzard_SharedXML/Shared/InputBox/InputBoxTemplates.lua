function EditBox_OnTabPressed(self)
	if ( self.previousEditBox and IsShiftKeyDown() ) then
		self.previousEditBox:SetFocus();
	elseif ( self.nextEditBox ) then
		self.nextEditBox:SetFocus();
	end
end

function EditBox_ClearFocus(self)
	self:ClearFocus();
end

function EditBox_HighlightText(self)
	self:HighlightText();
end

function EditBox_ClearHighlight(self)
	self:HighlightText(0, 0);
end

function ScrollingEdit_OnTextChanged(self, scrollFrame)
	-- force an update when the text changes
	self.handleCursorChange = true;
	ScrollingEdit_OnUpdate(self, 0, scrollFrame);
end

function ScrollingEdit_OnLoad(self)
	ScrollingEdit_SetCursorOffsets(self, 0, 0);
end

function ScrollingEdit_SetCursorOffsets(self, offset, height)
	self.cursorOffset = offset;
	self.cursorHeight = height;
end

function ScrollingEdit_OnCursorChanged(self, x, y, w, h)
	ScrollingEdit_SetCursorOffsets(self, y, h);
	self.handleCursorChange = true;
end

-- NOTE: If your edit box never shows partial lines of text, then this function will not work when you use
-- your mouse to move the edit cursor. You need the edit box to cut lines of text so that you can use your
-- mouse to highlight those partially-seen lines; otherwise you won't be able to use the mouse to move the
-- cursor above or below the current scroll area of the edit box.
function ScrollingEdit_OnUpdate(self, elapsed, scrollFrame)
	local height, range, scroll, cursorOffset;
	if ( self.handleCursorChange ) then
		if ( not scrollFrame ) then
			scrollFrame = self:GetParent();
		end
		height = scrollFrame:GetHeight();
		range = scrollFrame:GetVerticalScrollRange();

		if ( math.floor(height) <= 0 or math.floor(range) <= 0 ) then
			--Frame has no area, nothing to calculate.
			return;
		end

		scroll = scrollFrame:GetVerticalScroll();
		cursorOffset = -self.cursorOffset;

		while ( cursorOffset < scroll ) do
			scroll = (scroll - (height / 2));
			if ( scroll < 0 ) then
				scroll = 0;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end

		while ( (cursorOffset + self.cursorHeight) > (scroll + height) and scroll < range ) do
			scroll = (scroll + (height / 2));
			if ( scroll > range ) then
				scroll = range;
			end
			scrollFrame:SetVerticalScroll(scroll);
		end

		self.handleCursorChange = false;
	end
end

function InputScrollFrame_OnLoad(self)
	self.scrollBarX = -10;
	self.scrollBarTopY = -1;
	self.scrollBarBottomY = -3;
	self.scrollBarHideIfUnscrollable = true;

	ScrollFrame_OnLoad(self);

	self.EditBox:SetWidth(self:GetWidth() - 18);
	self.EditBox:SetMaxLetters(self.maxLetters);
	InputScrollFrame_SetInstructions(self, self.instructions);
	self.EditBox.Instructions:SetWidth(self:GetWidth());
	self.CharCount:SetShown(not self.hideCharCount);
end

function InputScrollFrame_SetInstructions(self, instructions)
	self.EditBox.Instructions:SetText(instructions);
end

function InputScrollFrame_OnMouseDown(self)
	self.EditBox:SetFocus();
end

InputScrollFrame_OnTabPressed = EditBox_OnTabPressed;

function InputScrollFrame_OnTextChanged(self, _isUserChange)
	local scrollFrame = self:GetParent();
	ScrollingEdit_OnTextChanged(self, scrollFrame);
	self.Instructions:SetShown(self:GetText() == "");

	scrollFrame.CharCount:SetText(self:GetMaxLetters() - self:GetNumLetters());

	if scrollFrame.ScrollBar then
		if ( scrollFrame.ScrollBar:IsShown() ) then
			scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", -17, 0);
		else
			scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", 0, 0);
		end
	end
end

function InputScrollFrame_OnUpdate(self, elapsed)
	ScrollingEdit_OnUpdate(self, elapsed, self:GetParent());
end

function InputScrollFrame_OnEscapePressed(self)
	self:ClearFocus();
end

function InputBoxInstructions_OnTextChanged(self)
	self.Instructions:SetShown(self:GetText() == "");
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

function InputBoxInstructions_OnEnter(self)
	if self.showTooltipForTruncatedInstructions then
		InputBoxInstructions_ShowTooltipIfTruncated(self);
	end
end

function InputBoxInstructions_OnLeave(self)
	if self.showTooltipForTruncatedInstructions then
		-- Note: Some inheritors of this template may have a special version of GetAppropriateTooltip (Ex. CatalogShopMixin:GetAppropriateTooltip)
		-- If this functionality is desired then this probably needs to be overridden
		GetAppropriateTooltip():Hide();
	end
end

function InputBoxInstructions_ShowTooltipIfTruncated(self)
	if not self.Instructions:IsShown() or not self.Instructions:IsTruncated() then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
	local text = self.Instructions:GetText();
	GameTooltip_AddHighlightLine(tooltip, text);
	tooltip:Show();
end

function SearchBoxTemplate_OnLoad(self)
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self.Instructions:SetText(self.instructionText);
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
	self.Icon:SetAlpha(1.0);
end

function ClearButtonMixin:OnLeave()
	self.Icon:SetAlpha(0.5);
end

function ClearButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);
	end
end

function ClearButtonMixin:OnMouseUp()
	self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -3);
end

function ClearButtonMixin:OnClick()
	SearchBoxTemplateClearButton_OnClick(self);
end

function ClearButtonMixin:NarrationGetName()
	return NARRATION_OBJECT_CLEAR_BUTTON;
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
