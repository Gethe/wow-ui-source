local ERROR_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r
|cffffd200Count:|r|cffffffff %s|r
|cffffd200Stack:|r
|cffffffff%s|r
|cffffd200Locals:|r
|cffffffff%s|r]];

local WARNING_AS_ERROR_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r
|cffffd200Count:|r|cffffffff %s|r]];

local WARNING_FORMAT = "Lua Warning:\n"..WARNING_AS_ERROR_FORMAT;
local INDEX_ORDER_FORMAT = "%d / %d"

local MESSAGE_TYPE_ERROR = 0;
local MESSAGE_TYPE_WARNING = 1;

function message(text, force)
	if ( force or not BasicMessageDialog:IsShown()) then
		BasicMessageDialog.Text:SetText(text);
		BasicMessageDialog:Show();
	end
end

ScriptErrorsFrameMixin = {};

function ScriptErrorsFrameMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.index = 0;
	self.seen = {};
	self.order = {};
	self.count = {};
	self.messages = {};
	self.times = {};
	self.locals = {};
	self.warnType = {};
	self.messageCount = 0;
	self.messageLimit = 1000;

	local function ShouldHideErrorFrame(errorTypeCVar)
		if GetCVarBool("developerLog_enabled") then
			return true;
		end

		return not GetCVarBool(errorTypeCVar);
	end

	local function DisplayMessage(errorTypeCVar, warnType, msg, messageType, stack, locals)
		local hideErrorFrame = ShouldHideErrorFrame(errorTypeCVar);
		self:DisplayMessage(msg, warnType, hideErrorFrame, messageType, stack, locals);
	end

	AddLuaErrorHandler(function(errorMessage, stack, locals)
		local cvarName = "scriptErrors";
		local warnType = false;
		DisplayMessage(cvarName, warnType, errorMessage, MESSAGE_TYPE_ERROR, stack, locals);
	end);
	
	AddLuaWarningHandler(function(warnType, warningMessage, stack, locals)
		local cvarName = (warnType == LUA_WARNING_TREAT_AS_ERROR) and "scriptErrors" or "scriptWarnings";
		DisplayMessage(cvarName, warnType, warningMessage, MESSAGE_TYPE_WARNING, stack, locals);
	end);
end

function ScriptErrorsFrameMixin:OnShow()
	self:Update();
end

function ScriptErrorsFrameMixin:DisplayMessageInternal(msg, warnType, keepHidden, locals, stack, msgKey)
	local index = self.seen[msgKey];
	if ( index ) then
		self.count[index] = self.count[index] + 1;
		self.messages[index] = msg;
		self.times[index] = date();
		self.locals[index] = locals;
	else
		tinsert(self.order, stack);
		index = #self.order;
		self.count[index] = 1;
		self.messages[index] = msg;
		self.times[index] = date();
		self.seen[msgKey] = index;
		self.locals[index] = locals;
		self.warnType[index] = (warnType or false); --Use false instead of nil

		PrintToDebugWindow(msg);
	end

	if ( not self:IsShown() and not keepHidden ) then
		self.index = index;
		self:Show();
	else
		self:Update();
	end
end

function ScriptErrorsFrameMixin:DisplayMessage(msg, warnType, keepHidden, messageType, stack, locals)
	self:UpdateTitle(messageType);

	if messageType == MESSAGE_TYPE_ERROR then
		self:OnError(msg, warnType, keepHidden, stack, locals);
	elseif messageType == MESSAGE_TYPE_WARNING then
		self:OnWarning(msg, warnType, keepHidden, stack, locals);
	end

	-- Show a warning if there are too many messages/errors, same handler each time
	self.messageCount = self.messageCount + 1;

	if ( self.messageCount == self.messageLimit ) then
		OnExcessiveErrors();
	end
end

function ScriptErrorsFrameMixin:OnError(msg, warnType, keepHidden, stack, locals)
	local msgKey = msg.."\n"..stack;
	self:DisplayMessageInternal(msg, warnType, keepHidden, locals, stack, msgKey);
end

function ScriptErrorsFrameMixin:OnWarning(msg, warnType, keepHidden, stack, locals)
	local msgKey = msg;
	self:DisplayMessageInternal(msg, warnType, keepHidden, locals, stack, msgKey);
end

function ScriptErrorsFrameMixin:UpdateTitle(messageType)
	if messageType == MESSAGE_TYPE_ERROR then
		self.Title:SetText(LUA_ERROR);
	elseif messageType == MESSAGE_TYPE_WARNING then
		self.Title:SetText(LUA_WARNING);
	end
end

function ScriptErrorsFrameMixin:GetEditBox()
	return self.ScrollFrame.Text;
end

function ScriptErrorsFrameMixin:Update()
	local editBox = self:GetEditBox();
	local index = self.index;
	if ( not index or not self.order[index] ) then
		index = #self.order;
		self.index = index;
	end

	if ( index == 0 ) then
		editBox:SetText("");
		self:UpdateButtons();
		return;
	end

	local warnType = self.warnType[index];

	local text;
	if ( warnType ) then
		local warnFormat = WARNING_FORMAT;
		if ( warnType == LUA_WARNING_TREAT_AS_ERROR ) then
			warnFormat = WARNING_AS_ERROR_FORMAT;
		end

		text = warnFormat:format(self.messages[index], self.times[index], self.count[index]);
	else
		text = ERROR_FORMAT:format(self.messages[index], self.times[index], self.count[index], self.order[index], self.locals[index] or "<none>");
	end

	local parent = editBox:GetParent();
	local prevText = editBox.text;
	editBox.text = text;
	if ( prevText ~= text ) then
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
	-- Returns indicate whether navigation for "previous" and "next" should be enabled, respectively.
	if count > 1 then
		return index > 1, index < count;
	end

	return false, false;
end

function ScriptErrorsFrameMixin:UpdateButtons()
	local index = self.index;
	local numErrors = self:GetCount();

	local previousEnabled, nextEnabled = GetNavigationButtonEnabledStates(numErrors, index);
	self.PreviousError:SetEnabled(previousEnabled);
	self.NextError:SetEnabled(nextEnabled);

	self.IndexLabel:SetText(INDEX_ORDER_FORMAT:format(index, numErrors));
end

function ScriptErrorsFrameMixin:GetCount()
	return #self.order;
end

function ScriptErrorsFrameMixin:ChangeDisplayedIndex(delta)
	self.index = Clamp(self.index + delta, 0, self:GetCount());
	self:Update();
end

function ScriptErrorsFrameMixin:ShowPrevious()
	self:ChangeDisplayedIndex(-1);
end

function ScriptErrorsFrameMixin:ShowNext()
	self:ChangeDisplayedIndex(1);
end