
local forceinsecure = forceinsecure;

local ADDON_NAME = ...;
local DEFAULT_SAVED_VARS = { isShown = false, commandHistory = {}, messageHistory = {}, height = 300, fontHeight = 14 };
local SAVED_VARS_VERSION = 3;

local MAX_NUM_COMMAND_HISTORY = 100;
local MAX_NUM_MESSAGE_HISTORY = 1000;

DeveloperConsoleMixin = {};

function DeveloperConsoleMixin:OnLoad()
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("ADDONS_UNLOADING");
	self:RegisterEvent("TOGGLE_CONSOLE");
	self:RegisterEvent("CONSOLE_MESSAGE");
	self:RegisterEvent("CONSOLE_CLEAR");
	self:RegisterEvent("CONSOLE_COLORS_CHANGED");
	self:RegisterEvent("CONSOLE_FONT_SIZE_CHANGED");
	self:RegisterEvent("DEBUG_MENU_TOGGLED");
	self:RegisterEvent("SPELL_SCRIPT_ERROR");

	self.MessageFrame:SetMaxLines(MAX_NUM_MESSAGE_HISTORY);

	self.savedVars = Blizzard_Console_SavedVars;

	self.commandCircularBuffer = CreateCircularBuffer(MAX_NUM_COMMAND_HISTORY);
	self:ResetCommandHistoryIndex();

	self.MessageFrame:SetOnScrollChangedCallback(function(messageFrame, offset)
		messageFrame.ScrollBar:SetValue(messageFrame:GetNumMessages() - offset);
	end);

	self.MessageFrame:SetOnTextCopiedCallback(function(messageFrame, text, numCharsCopied)
		messageFrame.CopyNoticeFrame.Anim:Stop();

		messageFrame.CopyNoticeFrame.Label:SetFormattedText("%s characters copied to clipboard.", BreakUpLargeNumbers(numCharsCopied))
		messageFrame.CopyNoticeFrame:Show();
		messageFrame.CopyNoticeFrame.Anim:Play();
	end);

	self.filterText = "";
end

function DeveloperConsoleMixin:RestoreMessageHistory()
	local messageHistory = self.savedVars.messageHistory;
	if #messageHistory > 0 then
		self.savedVars.messageHistory = {};

		local numElements = math.min(MAX_NUM_MESSAGE_HISTORY, #messageHistory);

		for i = (#messageHistory - numElements) + 1, #messageHistory do
			local message, colorType = unpack(messageHistory[i]);
			local color = C_Console.GetColorFromType(colorType);
			local r, g, b = color:GetRGB();
			self:AddMessageInternal(message, r, g, b, colorType);
			table.insert(self.savedVars.messageHistory, messageHistory[i]);
		end

		local sides = ("-"):rep(50);
		local previousSessionLine = ("%s Previous Session %s"):format(sides, sides);

		self:AddMessage(previousSessionLine, Enum.ConsoleColorType.DefaultColor);
	end
end

function DeveloperConsoleMixin:RestoreCommandHistory()
	local commandHistory = self.savedVars.commandHistory;
	if #commandHistory > 0 then
		self.savedVars.commandHistory = {};

		self.commandCircularBuffer:Clear();
		self:ResetCommandHistoryIndex();

		local numElements = math.min(MAX_NUM_COMMAND_HISTORY, #commandHistory);

		for i = (#commandHistory - numElements) + 1, #commandHistory do
			self.commandCircularBuffer:PushFront(commandHistory[i]);
			table.insert(self.savedVars.commandHistory, commandHistory[i]);
		end
	end
end

function DeveloperConsoleMixin:OnEvent(event, ...)
	if event == "ADDON_LOADED" then
		if ADDON_NAME == ... then
			if not Blizzard_Console_SavedVars or not Blizzard_Console_SavedVars.version then
				Blizzard_Console_SavedVars = CopyTable(DEFAULT_SAVED_VARS);
			elseif Blizzard_Console_SavedVars.version < SAVED_VARS_VERSION then
				if Blizzard_Console_SavedVars.version < 3 then
					Blizzard_Console_SavedVars.fontHeight = DEFAULT_SAVED_VARS.fontHeight;
				end
			end
			Blizzard_Console_SavedVars.version = SAVED_VARS_VERSION;

			self.savedVars = Blizzard_Console_SavedVars;

			if self.savedVars.isShown and not GetCVarBool("useNewConsole") then
				self.savedVars.isShown = false;
			end

			self:RestoreMessageHistory();
			self:RestoreCommandHistory();
			self:SetShown(self.savedVars.isShown);
			self:SetHeight(self.savedVars.height);
			self:SetFontHeight(self.savedVars.fontHeight);
			self:UpdateAnchors();
		end
	elseif event == "ADDONS_UNLOADING" then
		local closingClient = ...;
		if closingClient then
			self.savedVars.isShown = false;
		end
	elseif event == "TOGGLE_CONSOLE" then
		local shownRequested = ...;
		self:Toggle(shownRequested);
	elseif event == "CONSOLE_MESSAGE" then
		local message, colorType = ...;

		self:AddMessage(message, colorType);
	elseif event == "CONSOLE_CLEAR" then
		self:Clear();
	elseif event == "CONSOLE_COLORS_CHANGED" then
		self:RefreshMessageFrame();
	elseif event == "CONSOLE_FONT_SIZE_CHANGED" then
		local fontHeight = C_Console.GetFontHeight();
		self:SetFontHeight(fontHeight);
	elseif event == "DEBUG_MENU_TOGGLED" then
		self:UpdateAnchors();
	elseif event == "SPELL_SCRIPT_ERROR" then
		local spellID, scriptID, lastEditUser, errorMessage, callStack = ...;
		self:AddMessage(errorMessage, Enum.ConsoleColorType.ErrorColor);
	end
end

function DeveloperConsoleMixin:AddMessage(message, colorType)
	if not colorType then
		colorType = Enum.ConsoleColorType.DefaultColor;
	end
	local color = C_Console.GetColorFromType(colorType);
	local r, g, b = color:GetRGB();

	self:AddMessageInternal(message, r, g, b, colorType);

	table.insert(self.savedVars.messageHistory, { message, colorType });
	self:UpdateScrollbar();
end

function DeveloperConsoleMixin:AddMessageInternal(message, r, g, b, colorType)
	for line in message:gmatch("[^\r\n]+") do
		self.MessageFrame:AddMessage(line, r, g, b, colorType);
	end
end

function DeveloperConsoleMixin:Clear()
	self.savedVars.messageHistory = {};
	self.MessageFrame:Clear();
end

function DeveloperConsoleMixin:SetFontHeight(fontHeight)
	do
		local fontFile, _, fontFlags = self.EditBox:GetFont();
		self.EditBox:SetFont(fontFile, fontHeight, fontFlags);
	end

	do
		local fontFile, _, fontFlags = self.MessageFrame:GetFont();
		self.MessageFrame:SetFont(fontFile, fontHeight - 2, fontFlags);
	end

	self.savedVars.fontHeight = fontHeight;
	C_Console.SetFontHeight(fontHeight);
end

function DeveloperConsoleMixin:RefreshMessageFrame()
	self.MessageFrame:Clear();

	local messageHistory = self.savedVars.messageHistory;
	for i, messageInfo in ipairs(messageHistory) do
		local message, colorType = unpack(messageInfo);
		local color = C_Console.GetColorFromType(colorType);
		local r, g, b = color:GetRGB();

		self:AddMessageInternal(message, r, g, b, colorType);
	end
end

function DeveloperConsoleMixin:CalculateAnchorOffset()
	if DebugMenu and DebugMenu.IsVisible() then
		return DebugMenu.GetMenuHeight();
	end
	return 0;
end

function DeveloperConsoleMixin:UpdateAnchors()
	local offset = self:CalculateAnchorOffset();
	self:SetPoint("TOPLEFT", 0, -offset);
	self:SetPoint("TOPRIGHT", 0, -offset);

	self:ValidateHeight();
	self.AutoComplete:OnAvailableHeightChanged();
end

function DeveloperConsoleMixin:OnMouseWheel(delta)
	if IsControlKeyDown() then
		delta = delta * self.MessageFrame:GetPagingScrollAmount();
	elseif IsShiftKeyDown() then
		delta = delta * 10;
	end

	self.MessageFrame:ScrollByAmount(delta);
end

function DeveloperConsoleMixin:Toggle(shownRequested)
	if shownRequested == nil then -- toggle
		shownRequested = not self.savedVars.isShown;
	end

	if shownRequested ~= self.savedVars.isShown then
		self.savedVars.isShown = shownRequested;

		if shownRequested then
			self:Show();
		else
			self.EditBox:ClearFocus();
			self.MessageFrame.CopyNoticeFrame.Anim:Stop();
			self.MessageFrame.CopyNoticeFrame:Hide()
		end

		self.Anim.Translation:SetOffset(0, self.savedVars.height);
		self.Anim:Play(shownRequested);
	end
end

function DeveloperConsoleMixin:OnEscapePressed()
	if self.AutoComplete:IsShown() then
		self.AutoComplete:ForceHide();
		return;
	end
	if self.EditBox:GetText() and #self.EditBox:GetText() > 0 then
		self.EditBox:SetText("");
		return;
	end

	self:Toggle(false);
end

function DeveloperConsoleMixin:ShouldEditBoxTakeFocus()
	if not self.savedVars.isShown then
		return false;
	end

	if self.Filters.EditBox:HasFocus() then
		return false;
	end

	if ScriptErrorsFrame:GetEditBox():HasFocus() then
		return false;
	end

	return true;
end

function DeveloperConsoleMixin:OnEditBoxUpdate()
	if self:ShouldEditBoxTakeFocus() then
		self.EditBox:SetFocus();
	end
end

function DeveloperConsoleMixin:UpdateScrollbar()
	local numMessages = self.MessageFrame:GetNumMessages();
	self.MessageFrame.ScrollBar:SetMinMaxValues(1, numMessages);
	self.MessageFrame.ScrollBar:SetValue(numMessages - self.MessageFrame:GetScrollOffset());
end

function DeveloperConsoleMixin:ValidateHeight(newHeight)
	local screenHeight = 768;
	local newHeight = Clamp(newHeight or self:GetHeight(), screenHeight * .1 + self.EditBox:GetHeight(), screenHeight * .85 - self:CalculateAnchorOffset());
	self:SetHeight(newHeight);
	if self.savedVars.height ~= newHeight then
		self.savedVars.height = newHeight;
		self.AutoComplete:OnAvailableHeightChanged();
	end
end

function DeveloperConsoleMixin:StartDragResizing()
	local startX, startY = GetCursorPosition();
	local startHeight = self:GetHeight();

	self.resizingTicker = C_Timer.NewTicker(0, function()
		local x, y = GetCursorPosition();
		self:ValidateHeight(startHeight + (startY - y));

		if not IsMouseButtonDown() then -- possible to get into this state when another window steals focus, should look at detecting that at the input level
			self:StopDragResizing();
		end
	end);
end

function DeveloperConsoleMixin:StopDragResizing()
	if self.resizingTicker then
		self.resizingTicker:Cancel();
		self.resizingTicker = nil;
	end
end

function DeveloperConsoleMixin:SetExecuteCommandOverrideFunction(func)
	assert((func == nil) or (type(func) == 'function'), "param 'func' must be nil or a function");
	self.ExecuteCommandOverrideFunc = func;
end

function DeveloperConsoleMixin:CheckExecuteOverrideCommand(text)
	if self.ExecuteCommandOverrideFunc then
		return self.ExecuteCommandOverrideFunc(text);
	end

	-- First return indicates override success, second is whether or not to add command history.
	return false, true;
end

function DeveloperConsoleMixin:ExecuteCommand(text)
	forceinsecure(); -- Just to be safe

	self:AddMessage(("> %s"):format(text:gsub("\n", " > ")), Enum.ConsoleColorType.InputColor);

	local overrideSuccessful, addToCommandHistory = self:CheckExecuteOverrideCommand(text);

	if not overrideSuccessful then
		ConsoleExec(text, true);
	end

	if addToCommandHistory then
		self:AddToCommandHistory(text);
		self:ResetCommandHistoryIndex();
	end
end

function DeveloperConsoleMixin:AddToCommandHistory(text)
	if self.commandCircularBuffer:GetEntryAtIndex(1) ~= text then
		self.commandCircularBuffer:PushFront(text);
		table.insert(self.savedVars.commandHistory, text);
	end
end

function DeveloperConsoleMixin:InsertLinkedCommand(text)
	self.EditBox:Insert(text);
end

function DeveloperConsoleMixin:OnEditBoxTextChanged(text)
	self:ValidateHeight();

	if self.ignoreNextTextChange then
		self.ignoreNextTextChange = nil;
		return;
	end

	local commandText, startPosition = self:FindBestEditCommand();
	self.AutoComplete:SetText(commandText, self.EditBox:GetCursorPosition() - (startPosition - 1));
end

function DeveloperConsoleMixin:OnEditBoxCursorChanged(text)
	if self.ignoreNextTextChange then
		return;
	end
	self:OnEditBoxTextChanged(text);
end

function DeveloperConsoleMixin:OnEditBoxArrowPressed(key)
	if key == "UP" then
		if self:GetCommandHistoryIndex() + 1 <= self.commandCircularBuffer:GetNumElements() then
			self:SetCommandHistoryIndex(self:GetCommandHistoryIndex() + 1);
			self.EditBox:SetText(self.commandCircularBuffer:GetEntryAtIndex(self:GetCommandHistoryIndex()));
		end
	elseif key == "DOWN" then
		if self:GetCommandHistoryIndex() - 1 > 0 then
			self:SetCommandHistoryIndex(self:GetCommandHistoryIndex() - 1);
			self.EditBox:SetText(self.commandCircularBuffer:GetEntryAtIndex(self:GetCommandHistoryIndex()));
		end
	end
end

function DeveloperConsoleMixin:OnEditBoxPageUpPressed()
	self.MessageFrame:PageUp();
end

function DeveloperConsoleMixin:OnEditBoxPageDownPressed()
	self.MessageFrame:PageDown();
end

function DeveloperConsoleMixin:OnEditBoxTabPressed()
	if IsControlKeyDown() then
		C_Console.PrintAllMatchingCommands((self:FindBestEditCommand()));
	else
		self.AutoComplete:FinishWork();
		if IsShiftKeyDown() then
			if self.AutoComplete:PreviousEntry() then
				return;
			end
		else
			if self.AutoComplete:GetSelectedText() == self:FindBestEditCommand() then
				if self.AutoComplete:NextEntry() then
					return;
				end
			end
		end

		self:SetAutoCompleteText(self.AutoComplete:GetSelectedText(), true);
	end
end

do
	local function Matches(pattern, text)
		if #pattern == 0 then
			return true;
		end
		return text:lower():match(pattern);
	end

	function DeveloperConsoleMixin:OnFilterEditBoxTextChanged(text)
		if self.filterText == text then
			return;
		end
		self.filterText = text;

		self.MessageFrame:Clear();
		text = text:lower();

		self.filteringCoroutine = coroutine.create(function()
			local numMessages = #self.savedVars.messageHistory;
			self.Filters.ProgressBar:SetMinMaxSmoothedValue(0, numMessages);
			self.Filters.ProgressBar:ResetSmoothedValue(0);
			self.Filters.ProgressBar.FadeAnim:Play();
			for i = numMessages, 1, -1 do
				self:CheckFilterCoroutineYield();
				self.Filters.ProgressBar:SetSmoothedValue(numMessages - i + 1);

				local messageInfo = self.savedVars.messageHistory[i];

				local success, matched = pcall(Matches, text, messageInfo[1]);
				if success and matched then
					local message, colorType = unpack(messageInfo);
					local color = C_Console.GetColorFromType(colorType);
					local r, g, b = color:GetRGB();
					self.MessageFrame:BackFillMessage(message, r, g, b, colorType);
					self:UpdateScrollbar();
				end
			end
		end);

		local extendTime = true;
		self:StepFilteringCoroutine(extendTime);
	end
end

function DeveloperConsoleMixin:OnUpdate()
	self:StepFilteringCoroutine();
end

function DeveloperConsoleMixin:StepFilteringCoroutine(extendedTime)
	if self.filteringCoroutine then
		local TIME_PER_FRAME_SEC = 0.0015;
		local EXTENDED_TIME_PER_FRAME_SEC = TIME_PER_FRAME_SEC * 10;
		self.filteringCoroutineEndTime = GetTimePreciseSec() + (extendedTime and EXTENDED_TIME_PER_FRAME_SEC or TIME_PER_FRAME_SEC);

		coroutine.resume(self.filteringCoroutine);
		if coroutine.status(self.filteringCoroutine) == "dead" then
			self.filteringCoroutine = nil;
			self.Filters.ProgressBar.FadeAnim:Play(true);
		end
	end
end

function DeveloperConsoleMixin:CheckFilterCoroutineYield()
	if GetTimePreciseSec() > self.filteringCoroutineEndTime then
		return coroutine.yield();
	end
end

function DeveloperConsoleMixin:SetAutoCompleteText(newCommand, keepAutoComplete)
	local startPosition, endPosition, text = self:FindBestEditCommandPositions();
	local currentText = self.EditBox:GetText();
	local newTextStart = currentText:sub(1, startPosition - 1);
	local newTextEnd = currentText:sub(endPosition + 1);
	local commandArguments = text:match("^%S+%s+(.+)") or "";
	local newText = newTextStart .. newCommand .. " " .. commandArguments .. newTextEnd;

	self.ignoreNextTextChange = keepAutoComplete;
	self.EditBox:SetText(newText);
	self.EditBox:SetCursorPosition(startPosition + #newCommand + 1 + #commandArguments);
end

function DeveloperConsoleMixin:FindBestEditCommandPositions()
	local cursorPosition = self.EditBox:GetCursorPosition();

	local startPosition = 0;
	local currentText = self.EditBox:GetText();
	local text, rest = currentText:match("^(.-)\n(.*)$");
	while text do
		local endPosition = startPosition + #text;
		if cursorPosition >= startPosition and cursorPosition <= endPosition then
			return startPosition + 1, endPosition, text;
		end
		startPosition = endPosition + 1;
		if not rest then
			break;
		end
		text, rest = rest:match("^(.-)\n(.*)$");
	end

	return startPosition + 1, #currentText, currentText:sub(startPosition + 1);
end

function DeveloperConsoleMixin:FindBestEditCommand()
	local startPosition, endPosition, text = self:FindBestEditCommandPositions();
	return text:match("^(%S+)") or text, startPosition, endPosition, text;
end

function DeveloperConsoleMixin:ResetCommandHistoryIndex()
	self.commandHistoryIndex = nil;
end

function DeveloperConsoleMixin:GetCommandHistoryIndex()
	return self.commandHistoryIndex or 0;
end

function DeveloperConsoleMixin:SetCommandHistoryIndex(commandHistoryIndex)
	self.commandHistoryIndex = commandHistoryIndex;
end

function DeveloperConsoleMixin:HasSetCommandHistoryIndex()
	return self.commandHistoryIndex ~= nil;
end

function BlizzardConsoleMessageFrame_OnHyperlinkClick(self, link, text, button)
	local command = link:sub(2);
	if IsShiftKeyDown() then
		self:GetParent():InsertLinkedCommand(command);
	else
		forceinsecure();
		ConsoleExec(command, true);
		if button == "RightButton" then
			self:GetParent():AddToCommandHistory(command);
			self:GetParent():ResetCommandHistoryIndex();
		end
	end
end