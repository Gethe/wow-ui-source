DeveloperConsoleAutoCompleteMixin = {};

function DeveloperConsoleAutoCompleteMixin:OnLoad()
	self:MarkDirty();
	self.maxResults = 20;

	self.entryPool = CreateFramePool("FRAME", self, "DeveloperConsoleAutoCompleteEntryTemplate");
end

function DeveloperConsoleAutoCompleteMixin:OnAvailableHeightChanged()
	self.heightDirty = true;
end

function DeveloperConsoleAutoCompleteMixin:SetText(text, cursorPosition)
	if self.text ~= text or self.cursorPosition ~= cursorPosition then
		if self.text ~= text and self:GetSelectedText() ~= text then
			self.text = text;
			self.forceHidden = nil;
			self:MarkDirty();
			self:ClearEntryIndex(true);
		end

		self:SetShown(self:ShouldTextBeVisible(text, cursorPosition));
	end
end

function DeveloperConsoleAutoCompleteMixin:ShouldTextBeVisible(text, cursorPosition)
	if self.forceHidden then
		return false;
	end

	if text and #text > 0 then
		return cursorPosition >= 0 and cursorPosition <= #text + 1;
	end

	return false;
end

function DeveloperConsoleAutoCompleteMixin:ForceHide()
	self.forceHidden = true;
	self:Hide();
end

function DeveloperConsoleAutoCompleteMixin:GetSelectedText()
	local entry = self:GetEntryAtIndex(self:GetEntryIndex());
	if entry then
		return entry.commandInfo.command;
	end
	return "";
end

function DeveloperConsoleAutoCompleteMixin:NextEntry()
	return self:SetEntryIndex(self:GetEntryIndex() + 1);
end

function DeveloperConsoleAutoCompleteMixin:PreviousEntry()
	return self:SetEntryIndex(self:GetEntryIndex() - 1);
end

function DeveloperConsoleAutoCompleteMixin:GetNumEntries()
	return self.entryByIndex and #self.entryByIndex or 0;
end

function DeveloperConsoleAutoCompleteMixin:GetEntryAtIndex(entryIndex)
	return self.entryByIndex and self.entryByIndex[entryIndex] or nil;
end

function DeveloperConsoleAutoCompleteMixin:ClearEntryIndex(dontSignalParent)
	if self:HasUserChosenEntryIndex() then
		local oldEntry = self:GetEntryAtIndex(self:GetEntryIndex());
		if oldEntry then
			oldEntry.Selected:Hide();
		end

		self.entryIndex = nil;

		local entry = self:GetEntryAtIndex(entryIndex);
		if entry then
			entry.Selected:Show();
		end

		if not dontSignalParent and entry then
			self:GetParent():SetAutoCompleteText(entry.commandInfo.command, true);
		end
	end
end

function DeveloperConsoleAutoCompleteMixin:SetEntryIndex(entryIndex, dontSignalParent)
	local numEntries = self:GetNumEntries();
	if numEntries == 0 then
		return false;
	end

	entryIndex = (entryIndex - 1) % self:GetNumEntries() + 1;
	if entryIndex ~= self:GetEntryIndex() or not self:HasUserChosenEntryIndex() then
		local oldEntry = self:GetEntryAtIndex(self:GetEntryIndex());
		if oldEntry then
			oldEntry.Selected:Hide();
		end

		local entry = self:GetEntryAtIndex(entryIndex);
		if entry then
			entry.Selected:Show();
		end

		self.entryIndex = entryIndex;

		if not dontSignalParent and entry then
			self:GetParent():SetAutoCompleteText(entry.commandInfo.command, true);
		end
		return true;
	end
	return false;
end

function DeveloperConsoleAutoCompleteMixin:GetEntryIndex()
	return self.entryIndex or 1;
end

function DeveloperConsoleAutoCompleteMixin:HasUserChosenEntryIndex()
	return self.entryIndex ~= nil;
end

function DeveloperConsoleAutoCompleteMixin:MarkDirty()
	self.dirty = true;
end

function DeveloperConsoleAutoCompleteMixin:CalculateMaxEntriesToDisplay()
	local ENTRY_SIZE = 15;
	local parentHeight = self:GetParent():GetHeight() + self:GetParent():CalculateAnchorOffset();
	if parentHeight then
		local spaceLeft = 768 - parentHeight;
		return Clamp(math.floor(spaceLeft / ENTRY_SIZE) - 1, 1, self.maxResults);
	end
	
	return self.maxResults;
end

function DeveloperConsoleAutoCompleteMixin:OnUpdate()
	if not self.dirty and not self.workingCoroutine then
		if self.heightDirty then
			self:DisplayResults();
			self.heightDirty = false;
		end
		return;
	end

	if self.dirty and self.workingCoroutine then
		self:CancelSearch();
	end

	if self.workingCoroutine then
		self:ResumeWork();

		if coroutine.status(self.workingCoroutine) == "dead" then
			self.workingCoroutine = nil;
		end

		self:DisplayResults();
		self.heightDirty = false;
	else
		self:StartSearch();
	end

	self.dirty = false;
end

local function GetCommandTypeDisplayName(commandInfo)
	if commandInfo.commandType == Enum.ConsoleCommandType.Cvar then
		return "CVar", CreateColor(.3, .5, 1.0);
	end

	if commandInfo.commandType == Enum.ConsoleCommandType.Script then
		return "Script", CreateColor(0.5, 1.0, .3);
	end

	return "Command", CreateColor(1.0, .5, .3);
end

local function GetCommandCategoryDisplayName(commandInfo)
	if commandInfo.category == Enum.ConsoleCategory.Debug then
		return "Debug";
	elseif commandInfo.category == Enum.ConsoleCategory.Graphics then
		return "Graphics";
	elseif commandInfo.category == Enum.ConsoleCategory.Console then
		return "Console";
	elseif commandInfo.category == Enum.ConsoleCategory.Combat then
		return "Combat";
	elseif commandInfo.category == Enum.ConsoleCategory.Game then
		return "Game";
	elseif commandInfo.category == Enum.ConsoleCategory.Net then
		return "Net";
	elseif commandInfo.category == Enum.ConsoleCategory.Sound then
		return "Sound";
	elseif commandInfo.category == Enum.ConsoleCategory.Gm then
		return "GM";
	end

	if commandInfo.commandType == Enum.ConsoleCommandType.Cvar then
		return "Debug";
	end

	if commandInfo.commandType == Enum.ConsoleCommandType.Script then
		return "Script";
	end

	return nil;
end

function DeveloperConsoleAutoCompleteMixin:DisplayResults()
	if #self.bestResults == 0 then
		if not self.workingCoroutine then
			for i, element in ipairs(self.BackgroundElements) do
				element:Hide();
			end
			self.entryPool:ReleaseAll();
			self.entryByIndex = {};
		end
		return;
	end

	self.entryPool:ReleaseAll();
	self.entryByIndex = {};

	local maxEntriesToDisplay = self:CalculateMaxEntriesToDisplay();
	local previous;
	for i, commandInfo in ipairs(self.bestResults) do
		local entry = self.entryPool:Acquire();
		if i == 1 then
			self.Background:SetPoint("TOPLEFT", entry, "TOPLEFT", -2, 2);
			entry:SetPoint("TOPLEFT", self, "TOPLEFT");
		else
			entry:SetPoint("TOPLEFT", previous, "BOTTOMLEFT");
		end
		entry.commandInfo = commandInfo;
		entry.index = i;

		entry.Text:SetText(commandInfo.command);

		do
			local commandTypeName, commandTypeColor = GetCommandTypeDisplayName(commandInfo);
			entry.Type:SetText(commandTypeName);
			entry.Type:SetTextColor(commandTypeColor:GetRGB());
		end

		entry.Help:SetText(commandInfo.help or "");

		if commandInfo.commandType == Enum.ConsoleCommandType.Cvar then
			local value, defaultValue, server, character = GetCVarInfo(commandInfo.command);

			entry.Value:SetText(value);
			local color = value == defaultValue and GREEN_FONT_COLOR or RED_FONT_COLOR;
			entry.Value:SetTextColor(color:GetRGB());
			entry.Value:Show();
		else
			entry.Value:Hide();
		end

		entry.Selected:SetShown(i == self:GetEntryIndex());
		entry:Show();

		self.entryByIndex[i] = entry;

		previous = entry;

		if i >= maxEntriesToDisplay then
			break;
		end
	end

	for i, element in ipairs(self.BackgroundElements) do
		element:Show();
	end
	self.Background:SetPoint("BOTTOMRIGHT", previous, "BOTTOMRIGHT", 2, -2);
end

function DeveloperConsoleAutoCompleteMixin:OnEntryClicked(entry)
	self:SetEntryIndex(entry.index);
end

local function SetEntryTooltip(tooltip, entry, text)
	tooltip.Text:SetText(text:trim());
	tooltip.Text:SetWidth(math.min(300, tooltip.Text:GetStringWidth()));

	tooltip:SetPoint("TOPLEFT", entry, "TOPRIGHT", 5, 0);
	tooltip:Show();
	tooltip:SetWidth(tooltip.Text:GetWrappedWidth() + 5);
	tooltip:SetHeight(tooltip.Text:GetStringHeight());
end

function DeveloperConsoleAutoCompleteMixin:OnEntryEnter(entry)
	local textTable = {};

	if entry.Text:IsTruncated() then
		table.insert(textTable, entry.commandInfo.command);
	end

	local commandCategoryName = GetCommandCategoryDisplayName(entry.commandInfo);
	if commandCategoryName then
		table.insert(textTable, BATTLENET_FONT_COLOR:WrapTextInColorCode(("%s Category"):format(commandCategoryName)));
	else
		table.insert(textTable, BATTLENET_FONT_COLOR:WrapTextInColorCode("Uncategorized"));
	end

	if entry.commandInfo.commandType == Enum.ConsoleCommandType.Cvar then
		local value, defaultValue, server, character = GetCVarInfo(entry.commandInfo.command);

		table.insert(textTable, ("Current: %q"):format(value or ""));
		table.insert(textTable, ("Default: %q"):format(defaultValue or ""));

		table.insert(textTable, ("Is Server Stored: %s"):format(server and GREEN_FONT_COLOR:WrapTextInColorCode("true") or RED_FONT_COLOR:WrapTextInColorCode("false")));
		table.insert(textTable, ("Is Per Character: %s"):format(character and GREEN_FONT_COLOR:WrapTextInColorCode("true") or RED_FONT_COLOR:WrapTextInColorCode("false")));
	end

	if entry.Help:IsTruncated() then
		table.insert(textTable, entry.commandInfo.help);
	end
	
	if entry.commandInfo.scriptContents then
		table.insert(textTable, entry.commandInfo.scriptContents);
	end

	if #textTable > 0 then
		SetEntryTooltip(self.Tooltip, entry, table.concat(textTable, "\n"));
	end
end

function DeveloperConsoleAutoCompleteMixin:OnEntryLeave(entry)
	self.Tooltip:Hide();
end

function DeveloperConsoleAutoCompleteMixin:StartSearch()
	assert(self.workingCoroutine == nil);

	self.workingCoroutine = coroutine.create(function() local text = self.text; self:StepAutoCompleteSearchCoroutine(text); end);
	self.bestResults = {};
end

function DeveloperConsoleAutoCompleteMixin:CancelSearch()
	assert(self.workingCoroutine ~= nil);
	assert(self.workingCoroutine ~= coroutine.running());

	self.workingCoroutine = nil;
end

-- Coroutine functions --
local TIME_PER_FRAME_SEC = 0.015;
function DeveloperConsoleAutoCompleteMixin:ResumeWork()
	self.workEndTime = GetTimePreciseSec() + TIME_PER_FRAME_SEC;
	coroutine.resume(self.workingCoroutine);
end

function DeveloperConsoleAutoCompleteMixin:FinishWork()
	self.workEndTime = nil;
	if self.workingCoroutine then
		coroutine.resume(self.workingCoroutine);
		self.workingCoroutine = nil;

		self:DisplayResults();
		self.heightDirty = false;
	end
end

function DeveloperConsoleAutoCompleteMixin:CheckYield()
	if self.workEndTime and GetTimePreciseSec() > self.workEndTime then
		return coroutine.yield();
	end
end

local function ScoreStrings(searchText, otherString)
	-- lower is better

	local subStringStartIndex, subStringEndIndex = otherString:find(searchText, 1, true);
	local hasSubString = not not subStringStartIndex;

	local editDistance = CalculateStringEditDistance(searchText, otherString);
	if not hasSubString and editDistance == math.max(#searchText, #otherString) then
		return 100; -- not even close
	end
	
	local subStringScore = hasSubString and -#searchText * 10 or 0;
	local startOfMatchScore = hasSubString and ClampedPercentageBetween(subStringStartIndex, 15, 1) * -2 * #searchText or 0;

	return editDistance + subStringScore + startOfMatchScore;
end

local function BinaryInsert(t, value)
	local startIndex = 1;
	local endIndex = #t;
	local midIndex = 1;
	local preInsert = true;

	while startIndex <= endIndex do
		midIndex = math.floor((startIndex + endIndex) / 2);

		if value.score < t[midIndex].score then
			endIndex = midIndex - 1;
			preInsert = true;
		else
			startIndex = midIndex + 1;
			preInsert = false;
		end
	end

	table.insert(t, midIndex + (preInsert and 0 or 1), value);
end

function DeveloperConsoleAutoCompleteMixin:StepAutoCompleteSearchCoroutine(searchText)
	local consoleCommands = C_Console.GetAllCommands();

	local lowerSearchText = searchText:lower();
	for i, commandInfo in ipairs(consoleCommands) do
		self:CheckYield();
		commandInfo.score = ScoreStrings(lowerSearchText, commandInfo.command:lower());
	end

	for i, commandInfo in ipairs(consoleCommands) do
		self:CheckYield();

		if commandInfo.score < #searchText / 2 then
			BinaryInsert(self.bestResults, commandInfo);
			if #self.bestResults > self.maxResults then
				self.bestResults[#self.bestResults] = nil;
			end
		end
	end
end