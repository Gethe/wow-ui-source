local ERROR_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r
|cffffd200Count:|r|cffffffff %s|r
|cffffd200Stack:|r
|cffffffff%s|r
|cffffd200Locals:|r
|cffffffff%s|r]];

local WARNING_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r
|cffffd200Count:|r|cffffffff %s|r]];

local ExcessiveMessageLimit = 1000;
local ErrorMessageType = 0;
local WarningMessageType = 1;

-- For internal use only.
local shouldHideErrorFramePredicate = nil;
function SetHideErrorFramePredicate(predicate)
	assert(issecure());
	assert(type(predicate) == "function");
	shouldHideErrorFramePredicate = predicate;
end

local function ShouldHideErrorFrame(errorTypeCVar)
	if shouldHideErrorFramePredicate and shouldHideErrorFramePredicate() then
		return true;
	end

	return not GetCVarBool(errorTypeCVar);
end

ScriptErrorsFrameMixin = {};

function ScriptErrorsFrameMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.index = 0;
	self.errorData = {};
	self.seen = {};
	self.messageCount = 0;
	self.messageLimit = 1000;

	AddLuaErrorHandler(function(errorMessage, stack, locals)
		self:DisplayMessageInternal(errorMessage, ErrorMessageType, stack, locals);
	end);

	self:SetScript("OnEvent", function(self, event, ...)
		if event == "LUA_WARNING" then
			local warningMessage = ...;
			self:DisplayMessageInternal(warningMessage, WarningMessageType);
		end
	end);

	self.ScrollFrame.Text:SetScript("OnUpdate", function(self, elapsed)
		ScrollingEdit_OnUpdate(self, elapsed, self.ScrollFrame);
	end);

	self.ScrollFrame.Text:SetScript("OnEditFocusGained", function(self)
		self:HighlightText(0);
	end);

	self.PreviousError:SetScript("OnClick", function()
		self:ShowPrevious();
	end);

	self.NextError:SetScript("OnClick", function()
		self:ShowNext();
	end);

	self:RegisterEvent("LUA_WARNING");
end

function ScriptErrorsFrameMixin:OnShow()
	self:Update();
end

-- For outlier cases where it's necessary to provide the script error frame
-- with a warning message directly. Please avoid if possible.
function ScriptErrorsFrameMixin:Warn(warningMessage)
	self:DisplayMessageInternal(warningMessage, WarningMessageType);
end

function ScriptErrorsFrameMixin:DisplayMessageInternal(message, messageType, stack, locals)
	if messageType == ErrorMessageType then
		self.Title:SetText(LUA_ERROR);
	elseif messageType == WarningMessageType then
		self.Title:SetText(LUA_WARNING);
	end

	stack = stack or "";

	local messageKey = string.format("%s\n%s", message, stack);
	local index = self.seen[messageKey];
	if index then
		local errorData = self.errorData[index];
		errorData.count = errorData.count + 1;
	else
		local errorData = 
		{
			count = 1,
			message = message,
			messageType = messageType,
			time = date(),
			stack = stack,
			locals = locals,
		};
		table.insert(self.errorData, errorData);

		index = #self.errorData;
		self.seen[messageKey] = index;

		PrintToDebugWindow(message);
	end

	if not self:IsShown() and not ShouldHideErrorFrame("scriptErrors") then
		self.index = index;
		self:Show();
	else
		self:Update();
	end

	-- Show a warning if there are too many messages/errors, same handler each time
	self.messageCount = self.messageCount + 1;

	if self.messageCount >= ExcessiveMessageLimit then
		OnExcessiveErrors();
	end
end

function ScriptErrorsFrameMixin:GetEditBox()
	return self.ScrollFrame.Text;
end

function ScriptErrorsFrameMixin:Update()
	local editBox = self:GetEditBox();
	local index = self.index;
	if not index or not self.errorData[index] then
		self.index = #self.errorData;
		index = self.index;
	end

	if index == 0 then
		editBox:SetText("");
		self:UpdateButtons();
		return;
	end

	local errorData = self.errorData[index];
	local messageType = errorData.messageType;
	local text;
	if messageType == WarningMessageType then
		text = WARNING_FORMAT:format(errorData.message, errorData.time, errorData.count);
	elseif messageType == ErrorMessageType then
		text = ERROR_FORMAT:format(errorData.message, errorData.time, errorData.count, errorData.stack, errorData.locals or "<none>");
	end

	local parent = editBox:GetParent();
	local prevText = editBox.text;
	editBox.text = text;
	if prevText ~= text then
		editBox:SetText(text);
		editBox:HighlightText(0);
		editBox:SetCursorPosition(0);
	else
		ScrollingEdit_OnTextChanged(editBox, parent);
	end
	parent:SetVerticalScroll(0);

	self:UpdateButtons();
end

local function GetNavigationButtonEnabledStates(count, index)
	local canNavigateToPrevious = count > 1;
	local canNavigateToNext = count > 1;
	return canNavigateToPrevious, canNavigateToNext;
end

function ScriptErrorsFrameMixin:UpdateButtons()
	local index = self.index;
	local numErrors = self:GetCount();

	local canNavigateToPrevious, canNavigateToNext = GetNavigationButtonEnabledStates(numErrors, index);
	self.PreviousError:SetEnabled(canNavigateToPrevious);
	self.NextError:SetEnabled(canNavigateToNext);

	self.IndexLabel:SetText(("%d / %d"):format(index, numErrors));
end

function ScriptErrorsFrameMixin:GetCount()
	return #self.errorData;
end

function ScriptErrorsFrameMixin:ChangeDisplayedIndex(delta)
	self.index = Wrap(self.index + delta, self:GetCount());
	self:Update();
end

function ScriptErrorsFrameMixin:ShowPrevious()
	self:ChangeDisplayedIndex(-1);
end

function ScriptErrorsFrameMixin:ShowNext()
	self:ChangeDisplayedIndex(1);
end
