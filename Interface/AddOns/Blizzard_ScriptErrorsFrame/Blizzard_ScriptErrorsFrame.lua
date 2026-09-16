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
	self.messageCounter = CreateCounter();
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
	locals = locals or "<none>";

	local messageKey = string.format("%s\n%s", message, stack);

	-- If the message key has been formatted with a secret value then we need
	-- to disable duplicate key matching. This prevents two issues:
	--
	--  1. Tainted code that throws a fully secret error message would trigger
	--     a Lua error when indexing 'seen' with a secret value.
	--  2. Untainted code that throws a fully secret error message would brick
	--     the ability for tainted code to throw _any_ error through here as
	--     the 'seen' table gets marked as irrevocably forbidden due to secret
	--     keys.

	local isMessageKeyMatchingAllowed = not issecretvalue(messageKey);
	local index;

	if isMessageKeyMatchingAllowed then
		index = self.seen[messageKey];
	end

	if index then
		local errorData = self:GetErrorData(index);
		errorData.count = errorData.count + 1;
	else
		index = self:AddErrorData(messageType, message, stack, locals);

		if isMessageKeyMatchingAllowed then
			self.seen[messageKey] = index;
		end

		PrintToDebugWindow(message);
	end

	if not self:IsShown() and not ShouldHideErrorFrame("scriptErrors") then
		self:SetDisplayedIndex(index);
		self:Show();
	else
		self:Update();
	end

	-- Show a warning if there are too many messages/errors, same handler each time
	if self.messageCounter() >= ExcessiveMessageLimit then
		OnExcessiveErrors();
	end
end

local function PackageAndAddError(errors, messageType, message, stack, locals)
	-- Message, stack, and local data should be decimal escaped here as we
	-- need to support cases where Lua values dumped in those strings may
	-- contain control characters or byte sequences rejected by EditBoxes
	-- for display (such that the error reporter shows no text at all).
	local errorData = {
		count = 1,
		message = C_StringUtil.EscapeDecimalNonPrintables(message),
		messageType = messageType,
		time = date(),
		stack = C_StringUtil.EscapeDecimalNonPrintables(stack),
		locals = C_StringUtil.EscapeDecimalNonPrintables(locals),
	};

	table.insert(errors, errorData);
	return #errors;
end

local PackageAndAddErrorDelegate = CreateSecureDelegate(PackageAndAddError);

function ScriptErrorsFrameMixin:AddErrorData(messageType, message, stack, locals)
	-- The goal here is to package the incoming message and append it to the
	-- error data table even if we're being invoked from tainted code. This
	-- requires a local secure delegate as opposed to a secure mixin method
	-- as secure mixin methods presently drop their ability to "elevate"
	-- to an untainted state if any input parameter is secret from a tainted
	-- context.

	return PackageAndAddErrorDelegate(self.errorData, messageType, message, stack, locals);
end

function ScriptErrorsFrameMixin:GetErrorData(index)
	return self.errorData[index];
end

function ScriptErrorsFrameMixin:GetEditBox()
	return self.ScrollFrame.Text;
end

function ScriptErrorsFrameMixin:Update()
	local editBox = self:GetEditBox();
	local index = self:GetDisplayedIndex();
	local errorData = self:GetErrorData(index);
	if not index or not errorData then
		self:SetDisplayedIndex(self:GetCount());
		return;  -- Prior call will trigger an update.
	end

	if index == 0 then
		editBox:SetText("");
		self:UpdateButtons();
		return;
	end

	local messageType = errorData.messageType;
	local text;
	if messageType == WarningMessageType then
		text = WARNING_FORMAT:format(errorData.message, errorData.time, errorData.count);
	elseif messageType == ErrorMessageType then
		text = ERROR_FORMAT:format(errorData.message, errorData.time, errorData.count, errorData.stack, errorData.locals);
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
	local index = self:GetDisplayedIndex();
	local numErrors = self:GetCount();

	local canNavigateToPrevious, canNavigateToNext = GetNavigationButtonEnabledStates(numErrors, index);
	self.PreviousError:SetEnabled(canNavigateToPrevious);
	self.NextError:SetEnabled(canNavigateToNext);

	self.IndexLabel:SetText(("%d / %d"):format(index, numErrors));
end

function ScriptErrorsFrameMixin:GetCount()
	return #self.errorData;
end

function ScriptErrorsFrameMixin:GetDisplayedIndex()
	return self.index;
end

function ScriptErrorsFrameMixin:SetDisplayedIndex(index)
	if self.index ~= index then
		self.index = index;

		if self:IsShown() then
			self:Update();
		end
	end
end

function ScriptErrorsFrameMixin:ChangeDisplayedIndex(delta)
	self:SetDisplayedIndex(Wrap(self:GetDisplayedIndex() + delta, self:GetCount()));
end

function ScriptErrorsFrameMixin:ShowPrevious()
	self:ChangeDisplayedIndex(-1);
end

function ScriptErrorsFrameMixin:ShowNext()
	self:ChangeDisplayedIndex(1);
end

-- Some methods on the error frame need to be promoted to secure mixin methods
-- to act as untainted delegates when dealing with errors from tainted code.
--
-- Any method that accepts no parameters or simple scalar values should be 
-- safe to elevate.

ScriptErrorsFrameSecureMixin = {};

function ScriptErrorsFrameSecureMixin:SetDisplayedIndex(index)
	ScriptErrorsFrameMixin.SetDisplayedIndex(self, index);
end

function ScriptErrorsFrameSecureMixin:Update()
	ScriptErrorsFrameMixin.Update(self);
end
