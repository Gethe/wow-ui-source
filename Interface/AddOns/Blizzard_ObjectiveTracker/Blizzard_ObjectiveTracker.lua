-- Who objects to the ObjectiveTracker...?

OBJECTIVE_TRACKER_ITEM_WIDTH = 33;
OBJECTIVE_TRACKER_HEADER_HEIGHT = 25;
OBJECTIVE_TRACKER_LINE_WIDTH = 248;
OBJECTIVE_TRACKER_HEADER_OFFSET_X = -10;
-- calculated values
OBJECTIVE_TRACKER_DASH_WIDTH = 0;
OBJECTIVE_TRACKER_TEXT_WIDTH = 0;

OBJECTIVE_TRACKER_COLOR = {
	["Normal"] = { r = 0.8, g = 0.8, b = 0.8 },
	["NormalHighlight"] = { r = HIGHLIGHT_FONT_COLOR.r, g = HIGHLIGHT_FONT_COLOR.g, b = HIGHLIGHT_FONT_COLOR.b },
	["Failed"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
	["FailedHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
	["Header"] = { r = 0.75, g = 0.61, b = 0 },
	["HeaderHighlight"] = { r = NORMAL_FONT_COLOR.r, g = NORMAL_FONT_COLOR.g, b = NORMAL_FONT_COLOR.b },
	["Complete"] = { r = 0.6, g = 0.6, b = 0.6 },
	["TimeLeft"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
	["TimeLeftHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
};
	OBJECTIVE_TRACKER_COLOR["Normal"].reverse = OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
	OBJECTIVE_TRACKER_COLOR["NormalHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Normal"];
	OBJECTIVE_TRACKER_COLOR["Failed"].reverse = OBJECTIVE_TRACKER_COLOR["FailedHighlight"];
	OBJECTIVE_TRACKER_COLOR["FailedHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Failed"];
	OBJECTIVE_TRACKER_COLOR["Header"].reverse = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Header"];
	OBJECTIVE_TRACKER_COLOR["TimeLeft"].reverse = OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"];
	OBJECTIVE_TRACKER_COLOR["TimeLeftHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["TimeLeft"];


-- these are generally from events
OBJECTIVE_TRACKER_UPDATE_QUEST						= 0x00001;
OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED				= 0x00002;
OBJECTIVE_TRACKER_UPDATE_TASK_ADDED					= 0x00004;
OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED			= 0x00008;
OBJECTIVE_TRACKER_UPDATE_SCENARIO					= 0x00010;
OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE			= 0x00020;
OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT				= 0x00040;
OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED			= 0x00080;
OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED		= 0x00100;
OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED		= 0x00200;
-- these are for the specific module ONLY!
OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST				= 0x00400;
OBJECTIVE_TRACKER_UPDATE_MODULE_AUTO_QUEST_POPUP	= 0x00800;
OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE		= 0x01000;
OBJECTIVE_TRACKER_UPDATE_MODULE_WORLD_QUEST			= 0x02000;
OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO			= 0x04000;
OBJECTIVE_TRACKER_UPDATE_MODULE_ACHIEVEMENT			= 0x08000;
OBJECTIVE_TRACKER_UPDATE_SCENARIO_SPELLS			= 0x10000;
OBJECTIVE_TRACKER_UPDATE_MODULE_UI_WIDGETS			= 0x20000;
-- special updates
OBJECTIVE_TRACKER_UPDATE_STATIC						= 0x0000;
OBJECTIVE_TRACKER_UPDATE_ALL						= 0xFFFFFFFF;

OBJECTIVE_TRACKER_UPDATE_REASON = OBJECTIVE_TRACKER_UPDATE_ALL;		-- default
OBJECTIVE_TRACKER_UPDATE_ID = 0;

-- speed optimizations
local floor = math.floor;
local min = min;
local band = bit.band;

-- *****************************************************************************************************
-- ***** MODULE STUFF
-- *****************************************************************************************************

--[[
blockTemplate:		template for the blocks - a quest would be a single block
blockType:			type of object
lineTemplate:		template for the lines - a quest objective would be a single line (even if it wordwraps); only FRAME supported
lineSpacing:		spacing between lines; for the first line it'll be the distance from the top of its block
blockOffsetX:		offset from the left edge of the blocksframe 	\__These are both added to a table indexed by blockTemplate.
blockOffsetY:		offset from the block above 					/
fromHeaderOffsetY:	offset from the header for the first block, if there's a header; used instead of blockOffsetY
fromModuleOffsetY:	offset from the previous module
poolCollection:		pool of (potentially) multiple frame types for use in a module
usedBlocks:			table of used blocks; a module should always have its own, this table uses template type so that GetBlock(id) ALWAYS returns
					the correct frame that already exists (for animation purposes)
freelines:			table of free lines; a module needs it own if not using default line template
					there's no table of used lines, that's per block
updateReasonModule:	the update for this module alone
updateReasonEvents: the events which should update the module
=== modules do not need to change these, they're keyed by block & line ===
usedTimerBars:		table of used timer bars
freeTimerBars:		table of free timer bars
=== modules should NOT change these ===
contentsHeight:		the current combined height of all the blocks in the module
contentsAnimHeight: the current combined animation height of all the blocks in the module
oldContentsHeight:	the previous height on the last update
hasSkippedBlocks:	if the module couldn't display all its blocks because of not enough space
--]]

DEFAULT_OBJECTIVE_TRACKER_MODULE = {};

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnLoad(friendlyName, defaultTemplate)
	self.friendlyName = friendlyName or "UnnamedTrackerModule";
	self.blockTemplate = defaultTemplate or "ObjectiveTrackerBlockTemplate";
	self.blockType = "Frame";
	self.lineTemplate = "ObjectiveTrackerLineTemplate";
	self.lineSpacing = 2;
	self.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH;
	self.poolCollection = CreateFramePoolCollection();
	self.usedBlocks = { };
	self.freeLines = { };
	self.fromHeaderOffsetY = -10;
	self.fromModuleOffsetY = -10;
	self.contentsHeight = 0;
	self.contentsAnimHeight = 0;
	self.oldContentsHeight = 0;
	self.hasSkippedBlocks = false;
	self.usedTimerBars = { };
	self.freeTimerBars = { };
	self.usedProgressBars = { };
	self.freeProgressBars = { };
	self.updateReasonModule = 0;
	self.updateReasonEvents = 0;

	self.BlocksFrame = ObjectiveTrackerFrame.BlocksFrame;

	DEFAULT_OBJECTIVE_TRACKER_MODULE.AddBlockOffset(self, self.blockTemplate, 0, -6);
end

function ObjectiveTracker_GetModuleInfoTable(friendlyName, baseModule, defaultTemplate)
	local info = CreateFromMixins(baseModule or DEFAULT_OBJECTIVE_TRACKER_MODULE);
	info:OnLoad(friendlyName, defaultTemplate);
	return info;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:BeginLayout(isStaticReanchor)
	self.topBlock = nil;	-- this is the header or the first block for header-less modules
	self.firstBlock = nil;	-- this is the first non-header block
	self.lastBlock = nil;
	self.oldContentsHeight = self.contentsHeight;
	self.contentsHeight = 0;
	self.contentsAnimHeight = 0;
	self.potentialBlocksAddedThisLayout = 0; -- this isn't a ref count, this is the total number of blocks that the module tried to add.
	-- if it's not a static reanchor, reset whether we've skipped blocks
	if ( not isStaticReanchor ) then
		self.hasSkippedBlocks = false;

		if not self:UsesSharedHeader() and self.Header then
			self.Header:Hide();
		end
	end
	self:MarkBlocksUnused();
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:EndLayout(isStaticReanchor)
	-- isStaticReanchor not used yet
	self.lastBlock = self.BlocksFrame.currentBlock;
	self:FreeUnusedBlocks();
end

-- ***** BLOCKS

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetHeader(block, text, animateReason)
	block.module = self;
	block.isHeader = true;
	block.Text:SetText(text);
	block.animateReason = animateReason or 0;
	self.Header = block;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetSharedHeader(block)
	self.Header = block;
	self.usesSharedHeader = true;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:UsesSharedHeader()
	return self.usesSharedHeader;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetBlock(id, overrideType, overrideTemplate)
	local blockType = overrideType or self.blockType;
	local blockTemplate = overrideTemplate or self.blockTemplate;

	if not self.usedBlocks[blockTemplate] then
		self.usedBlocks[blockTemplate] = {};
	end

	-- first try to return existing block
	local block = self.usedBlocks[blockTemplate][id];

	if not block then
		local pool = self.poolCollection:GetOrCreatePool(blockType, self.BlocksFrame or ObjectiveTrackerFrame.BlocksFrame, blockTemplate);

		local isNewBlock = nil;
		block, isNewBlock = pool:Acquire(blockTemplate);

		if isNewBlock then
			block.blockTemplate = blockTemplate; -- stored so we can use it to free from the lookup later
			block.lines = {};
		end

		self.usedBlocks[blockTemplate][id] = block;
		block.id = id;
		block.module = self;
	end

	block.used = true;
	block.height = 0;
	block.currentLine = nil;

	-- prep lines
	if block.lines then
		for objectiveKey, line in pairs(block.lines) do
			line.used = nil;
		end
	end

	return block;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(id, overrideTemplate)
	local template = overrideTemplate or self.blockTemplate;
	assert(template);
	assert(self.usedBlocks)

	local blocks = self.usedBlocks[template];
	if blocks then
		return blocks[id];
	end

	return nil;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:MarkBlocksUnused()
	for blockTemplate, blockTable in pairs(self.usedBlocks) do
		for blockID, block in pairs(blockTable) do
			block.used = nil;
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeBlock(block)
	-- free all the lines
	for _, line in pairs(block.lines) do
		self:FreeLine(block, line);
	end
	block.lines = { };

	-- free the block
	self.usedBlocks[block.blockTemplate][block.id] = nil;
	self.poolCollection:Release(block);

	-- callback
	if ( self.OnFreeBlock ) then
		self:OnFreeBlock(block);
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeUnusedBlocks()
	for blockTemplate, blockTable in pairs(self.usedBlocks) do
		for blockID, block in pairs(blockTable) do
			if not block.used then
				self:FreeBlock(block);
			end
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetBlockCount()
	local count = 0;
	local modules = self:GetRelatedModules();
	for index, module in ipairs(modules) do
		count = count + (module.potentialBlocksAddedThisLayout or 0);
	end

	return count;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetActiveBlocks(blockTemplate)
	-- By default use the module's preferred block type.
	blockTemplate = blockTemplate or self.blockTemplate;
	if not self.usedBlocks[blockTemplate] then
		self.usedBlocks[blockTemplate] = {};
	end

	return self.usedBlocks[blockTemplate];
end

-- ***** LINES

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeLine(block, line)
	block.lines[line.objectiveKey] = nil;
	-- if the line has a type, the freeLines will be the cache for that type of line, otherwise use the module's default
	local freeLines = (line.type and line.type.freeLines) or self.freeLines;
	tinsert(freeLines, line);
	-- remove timer bar
	if ( line.TimerBar ) then
		self:FreeTimerBar(block, line);
	end
	if ( line.ProgressBar ) then
		self:FreeProgressBar(block, line);
	end
	if ( line.type and self.OnFreeTypedLine ) then
		self:OnFreeTypedLine(line);
	elseif ( self.OnFreeLine ) then
		self:OnFreeLine(line);
	end

	line:Hide();
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeUnusedLines(block)
	for objectiveKey, line in pairs(block.lines) do
		if ( not line.used ) then
			self:FreeLine(block, line);
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetLine(block, objectiveKey, lineType)
	-- first look for existing line
	local line = block.lines[objectiveKey];

	-- if existing line is not of the same type, discard it
	if ( line and line.type ~= lineType ) then
		self:FreeLine(block, line);
		line = nil;
	end

	if ( line ) then
		line.used = true;
		return line;
	end

	local freeLines = (lineType and lineType.freeLines) or self.freeLines;
	local numFreeLines = #freeLines;
	local parent = block.ScrollContents or block;
	if ( numFreeLines > 0 ) then
		-- get a free line
		line = freeLines[numFreeLines];
		tremove(freeLines, numFreeLines);
		line:SetParent(parent);
		line:Show();
	else
		-- create a new line
		line = CreateFrame("Frame", nil, parent, (lineType and lineType.template) or self.lineTemplate);
		line.type = lineType;
	end
	block.lines[objectiveKey] = line;
	line.objectiveKey = objectiveKey;
	line.used = true;
	return line;
end

-- ***** OBJECTIVES
OBJECTIVE_DASH_STYLE_SHOW = 1;
OBJECTIVE_DASH_STYLE_HIDE = 2;
OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE = 3;

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddObjective(block, objectiveKey, text, lineType, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)
	local line = self:GetLine(block, objectiveKey, lineType);
	-- width
	if ( block.lineWidth ~= line.width ) then
		line.Text:SetWidth(block.lineWidth or self.lineWidth);
		line.width = block.lineWidth;	-- default should be nil
	end
	-- dash
	if ( line.Dash ) then
		if ( not dashStyle ) then
			dashStyle = OBJECTIVE_DASH_STYLE_SHOW;
		end
		if ( line.dashStyle ~= dashStyle ) then
			if ( dashStyle == OBJECTIVE_DASH_STYLE_SHOW ) then
				line.Dash:Show();
				line.Dash:SetText(QUEST_DASH);
			elseif ( dashStyle == OBJECTIVE_DASH_STYLE_HIDE ) then
				line.Dash:Hide();
				line.Dash:SetText(QUEST_DASH);
			elseif ( dashStyle == OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE ) then
				line.Dash:Hide();
				line.Dash:SetText(nil);
			else
				error("Invalid dash style: " .. tostring(dashStyle));
			end
			line.dashStyle = dashStyle;
		end
	end

	-- set the text
	local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, block.isHighlighted);
	local height = overrideHeight or textHeight;
	line:SetHeight(height);

	local yOffset;

	if ( adjustForNoText and text == "" ) then
		-- don't change the height
		-- move the line up so the next object ends up in the same position as if there had been no line
		yOffset = height;
	else
		block.height = block.height + height + block.module.lineSpacing;
		yOffset = -block.module.lineSpacing;
	end
	-- anchor the line
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset);
	else
		line:SetPoint("TOPLEFT", 0, yOffset);
	end
	block.currentLine = line;
	return line;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
	if useFullHeight then
		fontString:SetMaxLines(0);
	else
		fontString:SetMaxLines(2);
	end
	fontString:SetText(text);

	local stringHeight = fontString:GetHeight();
	colorStyle = colorStyle or OBJECTIVE_TRACKER_COLOR["Normal"];
	if ( useHighlight and colorStyle.reverse ) then
		colorStyle = colorStyle.reverse;
	end
	if ( fontString.colorStyle ~= colorStyle ) then
		fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
		fontString.colorStyle = colorStyle;
	end
	return stringHeight;
end

-- ***** BLOCK HEADER

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetBlockHeader(block, text)
	local height = self:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"], block.isHighlighted);
	block.height = height;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderEnter(block)
	block.isHighlighted = true;
	if ( block.HeaderText ) then
		local headerColorStyle = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
		block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
		block.HeaderText.colorStyle = headerColorStyle;
	end
	for objectiveKey, line in pairs(block.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if ( colorStyle ) then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["NormalHighlight"].r, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].g, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].b);
			end
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block)
	block.isHighlighted = nil;
	if ( block.HeaderText ) then
		local headerColorStyle = OBJECTIVE_TRACKER_COLOR["Header"];
		block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
		block.HeaderText.colorStyle = headerColorStyle;
	end
	for objectiveKey, line in pairs(block.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if ( colorStyle ) then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["Normal"].r, OBJECTIVE_TRACKER_COLOR["Normal"].g, OBJECTIVE_TRACKER_COLOR["Normal"].b);
			end
		end
	end
end

-- ***** TIMER BAR

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddTimerBar(block, line, duration, startTime)
	local timerBar = self.usedTimerBars[block] and self.usedTimerBars[block][line];
	if ( not timerBar ) then
		local numFreeTimerBars = #self.freeTimerBars;
		local parent = block.ScrollContents or block;
		if ( numFreeTimerBars > 0 ) then
			timerBar = self.freeTimerBars[numFreeTimerBars];
			tremove(self.freeTimerBars, numFreeTimerBars);
			timerBar:SetParent(parent);
			timerBar:Show();
		else
			timerBar = CreateFrame("Frame", nil, parent, "ObjectiveTrackerTimerBarTemplate");
			timerBar.Label:SetPoint("LEFT", OBJECTIVE_TRACKER_DASH_WIDTH, 0);
			timerBar.height = timerBar:GetHeight();
		end
		if ( not self.usedTimerBars[block] ) then
			self.usedTimerBars[block] = { };
		end
		self.usedTimerBars[block][line] = timerBar;
		timerBar:Show();
	end
	-- anchor the status bar
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		timerBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -block.module.lineSpacing);
	else
		timerBar:SetPoint("TOPLEFT", 0, -block.module.lineSpacing);
	end

	timerBar.Bar:SetMinMaxValues(0, duration);
	timerBar.duration = duration;
	timerBar.startTime = startTime;
	timerBar.block = block;

	line.TimerBar = timerBar;
	block.height = block.height + timerBar.height + block.module.lineSpacing;
	block.currentLine = timerBar;
	return timerBar;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeTimerBar(block, line)
	local timerBar = line.TimerBar;
	if ( timerBar ) then
		self.usedTimerBars[block][line] = nil;
		tinsert(self.freeTimerBars, timerBar);
		timerBar:Hide();
		line.TimerBar = nil;
	end
end


-- *****************************************************************************************************
-- ***** PROGRESS BAR
-- *****************************************************************************************************

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddProgressBar(block, line, questID)
	local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line];
	if ( not progressBar ) then
		local numFreeProgressBars = #self.freeProgressBars;
		local parent = block.ScrollContents or block;
		if ( numFreeProgressBars > 0 ) then
			progressBar = self.freeProgressBars[numFreeProgressBars];
			tremove(self.freeProgressBars, numFreeProgressBars);
			progressBar:SetParent(parent);
			progressBar:Show();
		else
			progressBar = CreateFrame("Frame", nil, parent, "ObjectiveTrackerProgressBarTemplate");
			progressBar.height = progressBar:GetHeight();
		end
		if ( not self.usedProgressBars[block] ) then
			self.usedProgressBars[block] = { };
		end
		self.usedProgressBars[block][line] = progressBar;
		progressBar:RegisterEvent("QUEST_LOG_UPDATE");
		progressBar:Show();
		-- initialize to the right values
		progressBar.questID = questID;
		ObjectiveTrackerProgressBar_SetValue(progressBar, GetQuestProgressBarPercent(questID));
	end
	-- anchor the status bar
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		progressBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -block.module.lineSpacing);
	else
		progressBar:SetPoint("TOPLEFT", 0, -block.module.lineSpacing);
	end

	progressBar.block = block;
	progressBar.questID = questID;


	line.ProgressBar = progressBar;
	block.height = block.height + progressBar.height + block.module.lineSpacing;
	block.currentLine = progressBar;
	return progressBar;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeProgressBar(block, line)
	local progressBar = line.ProgressBar;
	if ( progressBar ) then
		self.usedProgressBars[block][line] = nil;
		tinsert(self.freeProgressBars, progressBar);
		progressBar:Hide();
		line.ProgressBar = nil;
		progressBar:UnregisterEvent("QUEST_LOG_UPDATE");
	end
end

local function ObjectiveTracker_SetModulesCollapsed(collapsed, modules)
	for index, module in ipairs(modules) do
		module.collapsed = collapsed;
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetRelatedModules()
	-- Default implementation, most single/shared modules can be found this way
	-- NOTE: This actually inserts self as well, since the header matches, that's fine.
	local modules = {};
	local header = self.Header;
	for index, module in ipairs(ObjectiveTrackerFrame.MODULES) do
		if module.Header == header then
			table.insert(modules, module);
		end
	end

	return modules;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetCollapsed(collapsed)
	ObjectiveTracker_SetModulesCollapsed(collapsed, self:GetRelatedModules());

	if self.Header and self.Header.MinimizeButton then
		self.Header.MinimizeButton:SetCollapsed(collapsed);
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:IsCollapsed()
	return self.collapsed;
end

-- *****************************************************************************************************
-- ***** MODULE/BLOCK CUSTOMIZATION
-- *****************************************************************************************************

local function ObjectiveTracker_AddCustomizationData(module, customizationKey, template, data)
	if not module[customizationKey] then
		module[customizationKey] = {};
	end

	module[customizationKey][template] = data;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddButtonOffsets(template, offsets)
	ObjectiveTracker_AddCustomizationData(self, "buttonOffsets", template, offsets);
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddBlockOffset(template, x, y)
	ObjectiveTracker_AddCustomizationData(self, "blockOffset", template, { x or 0, y or 0 });
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddPaddingBetweenButtons(template, padding)
	ObjectiveTracker_AddCustomizationData(self, "paddingBetweenButtons", template, padding);
end

local function GetBlockTemplate(block)
	return block.blockTemplate or block.module.blockTemplate;
end

function ObjectiveTracker_GetButtonOffsets(block, offsetTag)
	local offsets = block.module.buttonOffsets;
	if offsets then
		return unpack(offsets[GetBlockTemplate(block)][offsetTag]);
	end

	return 0, 0;
end

function ObjectiveTracker_GetBlockOffset(block)
	local offset = block.module.blockOffset;
	if offset then
		return unpack(offset[GetBlockTemplate(block)]);
	end

	return 0, 0;
end

function ObjectiveTracker_GetPaddingBetweenButtons(block)
	local padding = block.module.paddingBetweenButtons;
	if padding then
		return padding[GetBlockTemplate(block)];
	end

	return 0;
end

-- *****************************************************************************************************
-- ***** BLOCK HEADER HANDLERS
-- *****************************************************************************************************

function ObjectiveTrackerBlockHeader_OnLoad(self)

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.GetDebugReportInfo = ObjectiveTrackerBlockHeader_GetDebugReportInfo;
end

function ObjectiveTrackerBlockHeader_OnClick(self, mouseButton)
	local block = self:GetParent();
	block.module:OnBlockHeaderClick(block, mouseButton);
end

function ObjectiveTrackerBlockHeader_OnEnter(self)
	local block = self:GetParent();
	block.module:OnBlockHeaderEnter(block);
end

function ObjectiveTrackerBlockHeader_OnLeave(self)
	local block = self:GetParent();
	block.module:OnBlockHeaderLeave(block);
end

function ObjectiveTrackerBlockHeader_GetDebugReportInfo(self)
	local block = self:GetParent();

	if block.module.GetDebugReportInfo then
		return block.module:GetDebugReportInfo(block);
	end

	return nil;
end

-- *****************************************************************************************************
-- ***** OBJECTIVE TRACKER LINES
-- *****************************************************************************************************

function ObjectiveTrackerCheckLine_OnHide(self)
	self.Glow.Anim:Stop();
	self.Sheen.Anim:Stop();
end

-- *****************************************************************************************************
-- ***** TIMER BARS
-- *****************************************************************************************************

function ObjectiveTrackerTimerBar_OnUpdate(self, elapsed)
	local timeNow = GetTime();
	local timeRemaining = self.duration - (timeNow - self.startTime);
	self.Bar:SetValue(timeRemaining);
	if ( timeRemaining < 0 ) then
		-- hold at 0 for a moment
		if ( timeRemaining > -1 ) then
			timeRemaining = 0;
		else
			ObjectiveTracker_Update(self.block.module.updateReasonModule);
			return;
		end
	end
	self.Label:SetText(SecondsToClock(timeRemaining));
	self.Label:SetTextColor(ObjectiveTrackerTimerBar_GetTextColor(self.duration, self.duration - timeRemaining));
end

function ObjectiveTrackerTimerBar_GetTextColor(duration, elapsed)
	local START_PERCENTAGE_YELLOW = .66
	local START_PERCENTAGE_RED = .33

	local percentageLeft = 1 - ( elapsed / duration )
	if ( percentageLeft > START_PERCENTAGE_YELLOW ) then
		return 1, 1, 1;
	elseif ( percentageLeft > START_PERCENTAGE_RED ) then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

-- *****************************************************************************************************
-- ***** PROGRESS BARS
-- *****************************************************************************************************
function ObjectiveTrackerProgressBar_SetValue(self, percent)
	self.Bar:SetValue(percent);
	self.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
end

function ObjectiveTrackerProgressBar_OnEvent(self)
	ObjectiveTrackerProgressBar_SetValue(self, GetQuestProgressBarPercent(self.questID));
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function ObjectiveTracker_OnLoad(self)
	DEFAULT_OBJECTIVE_TRACKER_MODULE.OnLoad(self, "DEFAULT_OBJECTIVE_TRACKER_MODULE");

	-- create a line so we can get some measurements
	local line = CreateFrame("Frame", nil, self, self.lineTemplate);
	line.Text:SetText("Double line|ntest");
	-- reuse it
	tinsert(self.freeLines, line);
	-- get measurements
	OBJECTIVE_TRACKER_DASH_WIDTH = line.Dash:GetWidth();
	OBJECTIVE_TRACKER_TEXT_WIDTH = OBJECTIVE_TRACKER_LINE_WIDTH - OBJECTIVE_TRACKER_DASH_WIDTH - 12;
	line.Text:SetWidth(OBJECTIVE_TRACKER_TEXT_WIDTH);

	local frameLevel = self.BlocksFrame:GetFrameLevel();
	self.HeaderMenu:SetFrameLevel(frameLevel + 2);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_Initialize(self.BlockDropDown, nil, "MENU");
	QuestPOI_Initialize(self.BlocksFrame, function(self) self:SetScale(0.9); self:RegisterForClicks("LeftButtonUp", "RightButtonUp"); end );
end

function ObjectiveTracker_Initialize(self)
	self.MODULES = {	SCENARIO_CONTENT_TRACKER_MODULE,
						UI_WIDGET_TRACKER_MODULE,
						BONUS_OBJECTIVE_TRACKER_MODULE,
						WORLD_QUEST_TRACKER_MODULE,
						CAMPAIGN_QUEST_TRACKER_MODULE,
						QUEST_TRACKER_MODULE,
						ACHIEVEMENT_TRACKER_MODULE,
	};
	self.MODULES_UI_ORDER = {	SCENARIO_CONTENT_TRACKER_MODULE,
								UI_WIDGET_TRACKER_MODULE,
								CAMPAIGN_QUEST_TRACKER_MODULE,
								QUEST_TRACKER_MODULE,
								BONUS_OBJECTIVE_TRACKER_MODULE,
								WORLD_QUEST_TRACKER_MODULE,
								ACHIEVEMENT_TRACKER_MODULE,
	};

	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_AUTOCOMPLETE");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE");
	self:RegisterEvent("SCENARIO_SPELL_UPDATE");
	self:RegisterEvent("SCENARIO_BONUS_VISIBILITY_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("WAYPOINT_UPDATE");
	self.watchMoneyReasons = 0;

	WorldMapFrame:RegisterCallback("SetFocusedQuestID", ObjectiveTracker_OnFocusedQuestChanged, self);
	WorldMapFrame:RegisterCallback("ClearFocusedQuestID", ObjectiveTracker_OnFocusedQuestChanged, self);

	QuestSuperTracking_Initialize();

	self.initialized = true;
end

function ObjectiveTracker_OnFocusedQuestChanged(self)
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
end

function ObjectiveTracker_OnEvent(self, event, ...)
	if ( event == "QUEST_LOG_UPDATE" ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
	elseif ( event == "TRACKED_ACHIEVEMENT_UPDATE" ) then
		AchievementObjectiveTracker_OnAchievementUpdate(...);
	elseif ( event == "QUEST_ACCEPTED" ) then
		local questID = ...;
		if ( not C_QuestLog.IsQuestBounty(questID) ) then
			if ( C_QuestLog.IsQuestTask(questID) ) then
				if ( QuestUtils_IsQuestWorldQuest(questID) ) then
					ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_WORLD_QUEST_ADDED, questID);
				else
					ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_TASK_ADDED, questID);
				end
			else
				if ( AUTO_QUEST_WATCH == "1" and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES ) then
					C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Automatic);
					QuestSuperTracking_OnQuestTracked(questID);
				end
			end
		end
	elseif ( event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" ) then
		local achievementID, added = ...;
		if ( added ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED, achievementID);
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT);
		end
	elseif ( event == "QUEST_WATCH_LIST_CHANGED" ) then
		local questID, added = ...;
		if ( added ) then
			if ( not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID) ) then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED, questID);
			end
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
		end
	elseif ( event == "QUEST_POI_UPDATE" ) then
		QuestPOIUpdateIcons();
		if ( GetCVar("trackQuestSorting") == "proximity" ) then
			C_QuestLog.SortQuestWatches();
		end
		-- C_QuestLog.SortQuestWatches might not trigger a QUEST_WATCH_LIST_CHANGED due to unique signals, so force an update
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
		QuestSuperTracking_OnPOIUpdate();
	elseif ( event == "SCENARIO_CRITERIA_UPDATE" ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO);
	elseif ( event == "SCENARIO_SPELL_UPDATE" ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO_SPELLS);
	elseif ( event == "SCENARIO_BONUS_VISIBILITY_UPDATE") then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE);
	elseif ( event == "SUPER_TRACKING_CHANGED" ) then
		ObjectiveTracker_UpdateSuperTrackedQuest(self);
	elseif ( event == "ZONE_CHANGED" ) then
		local lastMapID = C_Map.GetBestMapForUnit("player");
		if ( lastMapID ~= self.lastMapID ) then
			C_QuestLog.SortQuestWatches();
			self.lastMapID = lastMapID;
		end
	elseif ( event == "QUEST_AUTOCOMPLETE" ) then
		local questId = ...;
		AutoQuestPopupTracker_AddPopUp(questId, "COMPLETE");
	elseif ( event == "SCENARIO_UPDATE" ) then
		local newStage = ...;
		if ( newStage ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE);
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO);
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		C_QuestLog.SortQuestWatches();
	elseif ( event == "QUEST_TURNED_IN" ) then
		local questID, xp, money = ...;
		if ( C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) ) then
			BonusObjectiveTracker_OnTaskCompleted(...);
		end
	elseif ( event == "PLAYER_MONEY" and self.watchMoneyReasons > 0 ) then
		ObjectiveTracker_Update(self.watchMoneyReasons);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( not self.initialized ) then
			ObjectiveTracker_Initialize(self);
		end
		ObjectiveTracker_Update();

		if not QuestSuperTracking_IsSuperTrackedQuestValid() then
			QuestSuperTracking_ChooseClosestQuest();
		end

		self.lastMapID = C_Map.GetBestMapForUnit("player");
	elseif ( event == "CVAR_UPDATE" ) then
		local arg1 =...;
		if ( arg1 == "QUEST_POI" ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		ObjectiveTracker_Update();
	elseif ( event == "WAYPOINT_UPDATE" ) then
		ObjectiveTracker_Update();
	end
end

function ObjectiveTracker_OnSizeChanged(self)
	ObjectiveTracker_Update();
end

function ObjectiveTracker_OnUpdate(self)
	if self.isUpdateDirty then
		ObjectiveTracker_Update();
	end
end

function ObjectiveTrackerHeader_OnAnimFinished(self)
	local header = self:GetParent();
	header.animating = nil;
end

ObjectiveTrackerHeaderMixin = {};

function ObjectiveTrackerHeaderMixin:OnLoad()
	self.height = OBJECTIVE_TRACKER_HEADER_HEIGHT;
	self.Text:SetFontObjectsToTry(GameFontNormalMed2, SystemFont_Shadow_Med1);
end

function ObjectiveTrackerHeaderMixin:PlayAddAnimation()
	self.animating = true;
	self.HeaderOpenAnim:Restart();
end

-- *****************************************************************************************************
-- ***** BUTTONS
-- *****************************************************************************************************

ObjectiveTrackerMinimizeButtonMixin = {};

function ObjectiveTrackerMinimizeButtonMixin:OnLoad()
	local collapsed = false;
	self:SetAtlases(collapsed);
end

function ObjectiveTrackerMinimizeButtonMixin:SetAtlases(collapsed)
	local normalTexture = self:GetNormalTexture();
	local pushedTexture = self:GetPushedTexture();

	if self.buttonType == "module" then
		if collapsed then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Expand-Section", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Expand-Section-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Collapse-Section", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Collapse-Section-Pressed", true);
		end
	else
		if collapsed then
			normalTexture:SetAtlas("UI-QuestTrackerButton-Expand-All", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Expand-All-Pressed", true);
		else
			normalTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All", true);
			pushedTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All-Pressed", true);
		end
	end
end

function ObjectiveTrackerMinimizeButtonMixin:SetCollapsed(collapsed)
	self:SetAtlases(collapsed);
end

function ObjectiveTracker_MinimizeButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if ( ObjectiveTrackerFrame.collapsed ) then
		ObjectiveTracker_Expand();
	else
		ObjectiveTracker_Collapse();
	end
	ObjectiveTracker_Update();
end

function ObjectiveTracker_MinimizeModuleButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local module = self:GetParent().module;
	module:SetCollapsed(not module:IsCollapsed());
	ObjectiveTracker_Update(0, nil, module);
end

function ObjectiveTracker_Collapse()
	ObjectiveTrackerFrame.collapsed = true;
	ObjectiveTrackerFrame.BlocksFrame:Hide();
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetCollapsed(true);
	ObjectiveTrackerFrame.HeaderMenu.Title:Show();
end

function ObjectiveTracker_Expand()
	ObjectiveTrackerFrame.collapsed = nil;
	ObjectiveTrackerFrame.BlocksFrame:Show();
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetCollapsed(false);
	ObjectiveTrackerFrame.HeaderMenu.Title:Hide();
end

function ObjectiveTracker_ToggleDropDown(frame, handlerFunc)
	local dropDown = ObjectiveTrackerBlockDropDown;
	if ( dropDown.activeFrame ~= frame ) then
		CloseDropDownMenus();
	end
	dropDown.activeFrame = frame;
	dropDown.initialize = handlerFunc;
	ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

-- *****************************************************************************************************
-- ***** BLOCK CONTROL
-- *****************************************************************************************************

local function AnchorBlock(block, anchorBlock, checkFit)
	local module = block.module;
	local blocksFrame = module.BlocksFrame;
	local offsetX, offsetY = ObjectiveTracker_GetBlockOffset(block);
	block:ClearAllPoints();
	if ( anchorBlock ) then
		if ( anchorBlock.isHeader ) then
			offsetY = module.fromHeaderOffsetY;
		end
		-- check if the block can fit
		if ( checkFit and (blocksFrame.contentsHeight + block.height - offsetY > blocksFrame.maxHeight) ) then
			return;
		end
		if ( block.isHeader ) then
			offsetY = offsetY + anchorBlock.module.fromModuleOffsetY;
			block:SetPoint("LEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, 0);
		else
			block:SetPoint("LEFT", offsetX, 0);
		end
		block:SetPoint("TOP", anchorBlock, "BOTTOM", 0, offsetY);
	else
		offsetY = 0;
		-- check if the block can fit
		if ( checkFit and (blocksFrame.contentsHeight + block.height > blocksFrame.maxHeight) ) then
			return;
		end
		-- if the blocks frame is a scrollframe, attach to its scrollchild
		if ( block.isHeader ) then
			block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, offsetY);
		else
			block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", offsetX, offsetY);
		end
	end
	return offsetY;
end

local function InternalAddBlock(block)
	local module = block.module or DEFAULT_OBJECTIVE_TRACKER_MODULE;
	local blocksFrame = module.BlocksFrame;
	block.nextBlock = nil;

	-- This doesn't take fit into account, it just assumes that there's content to be added, so the potential count
	-- should increase (this is related to showing the collapse buttons on the headers, see Reorder)
	-- NOTE: Never count headers as added blocks
	if not block.isHeader then
		module.potentialBlocksAddedThisLayout = (module.potentialBlocksAddedThisLayout or 0) + 1;
	end

	-- Only allow headers to be added if the module is collapsed.
	if not block.isHeader and module:IsCollapsed() then
		return false;
	end

	local offsetY = AnchorBlock(block, blocksFrame.currentBlock, true);
	if ( not offsetY ) then
		return false;
	end

	if ( not module.topBlock ) then
		module.topBlock = block;
	end
	if ( not module.firstBlock and not block.isHeader ) then
		module.firstBlock = block;
	end
	if ( blocksFrame.currentBlock ) then
		blocksFrame.currentBlock.nextBlock = block;
	end
	blocksFrame.currentBlock = block;
	blocksFrame.contentsHeight = blocksFrame.contentsHeight + block.height - offsetY;
	module.contentsAnimHeight = module.contentsAnimHeight + block.height;
	module.contentsHeight = module.contentsHeight + block.height - offsetY;
	return true;
end

function ObjectiveTracker_AddHeader(header, isStaticReanchor)
	if InternalAddBlock(header) then
		header.added = true;
		header:Show();
		return true;
	end

	return false;
end

function ObjectiveTracker_AddBlock(block)
	local header = block.module.Header;
	local blockAdded = false;

	-- if there's no header or it's been added, just add the block...
	if not header or header.added then
		blockAdded = InternalAddBlock(block);
	elseif ObjectiveTracker_CanFitBlock(block, header) then
		-- try to add header and maybe block
		if ObjectiveTracker_AddHeader(header) then
			blockAdded = InternalAddBlock(block);
		end
	end

	if not blockAdded then
		block.module.hasSkippedBlocks = true;
	end

	return blockAdded;
end

function ObjectiveTracker_CanFitBlock(block, header)
	local module = block.module;
	local blocksFrame = module.BlocksFrame;
	local offsetY;
	if ( not blocksFrame.currentBlock ) then
		offsetY = 0;
	elseif ( blocksFrame.currentBlock.isHeader ) then
		offsetY = module.fromHeaderOffsetY;
	else
		offsetY = select(2, ObjectiveTracker_GetBlockOffset(block));
	end

	local totalHeight;
	if header then
		totalHeight = header.height - offsetY + block.height - module.fromHeaderOffsetY;
	else
		totalHeight = block.height - offsetY;
	end
	return (blocksFrame.contentsHeight + totalHeight) <= blocksFrame.maxHeight;
end

-- ***** SLIDING

function ObjectiveTracker_SlideBlock(block, slideData)
	block.slideData = slideData;
	if ( slideData.startDelay ) then
		block.slideTime = -slideData.startDelay;
	else
		block.slideTime = 0;
	end
	block.slideHeight = slideData.startHeight;
	block:SetHeight(slideData.startHeight);
	block:SetScript("OnUpdate", ObjectiveTracker_OnSlideBlockUpdate);
end

function ObjectiveTracker_EndSlideBlock(block)
	block:SetScript("OnUpdate", nil);
	if ( block.slideData ) then
		block:SetHeight(block.slideData.endHeight);
		if ( block.slideData.scroll ) then
			block:SetVerticalScroll(0);
		end
	end
	block.slidingAction = nil;
end

function ObjectiveTracker_OnSlideBlockUpdate(block, elapsed)
	local slideData = block.slideData;

	block.slideTime = block.slideTime + elapsed;
	if ( block.slideTime <= 0 ) then
		return;
	end

	local height = floor(slideData.startHeight + (slideData.endHeight - slideData.startHeight) * (min(block.slideTime, slideData.duration) / slideData.duration));
	if ( height ~= block.slideHeight ) then
		block.slideHeight = height;
		block:SetHeight(height);
		if ( slideData.scroll ) then
			block:UpdateScrollChildRect();
			-- scrolling means the bottom of the content comes in first or leaves last
			if (slideData.expanding) then
				block:SetVerticalScroll(0);
			else
				block:SetVerticalScroll(max(slideData.endHeight, slideData.startHeight) - height);
			end
		end
	end

	if ( block.slideTime >= slideData.duration + (slideData.endDelay or 0) ) then
		block:SetScript("OnUpdate", nil);
		if ( slideData.onFinishFunc ) then
			slideData.onFinishFunc(block);
		end
	end
end

function ObjectiveTracker_CancelSlideBlock(block)
	block:SetScript("OnUpdate", nil);
	local slideData = block.slideData;
	if( slideData ) then
		block:SetHeight(slideData.startHeight);
		if ( slideData.scroll ) then
			block:UpdateScrollChildRect();
			-- scrolling means the bottom of the content comes in first or leaves last
			block:SetVerticalScroll(0);
		end
	end
end

-- ***** UPDATE

function DEFAULT_OBJECTIVE_TRACKER_MODULE:StaticReanchorCheckAddHeaderOnly()
	if self:IsCollapsed() and not self.Header.added and self:GetBlockCount() > 0 then
		ObjectiveTracker_AddHeader(self.Header, true); -- the header was marked as not being added, make sure to add it again...
		return true;
	end

	return false;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:StaticReanchor()
	-- If this module is collapsed, don't process anything, it will result in the entire module being hidden, since just the header
	-- is showing, there's nothing to update.
	if self:StaticReanchorCheckAddHeaderOnly() then
		return;
	end

	local block = self.firstBlock;
	self:BeginLayout(true);
	while ( block ) do
		if ( block.module == self ) then
			local nextBlock = block.nextBlock;
			if ( ObjectiveTracker_AddBlock(block) ) then
				block.used = true;
				block:Show();
				block = nextBlock;
			else
				-- a prior module reduced the previously available space
				block.used = false;
				block:Hide();
				break;
			end
		else
			break;
		end
	end
	self:EndLayout(true);
end

local function GetRelatedModulesForUpdate(module)
	if module then
		return tInvert(module:GetRelatedModules())
	end

	return nil;
end

local function IsRelatedModuleForUpdate(module, moduleLookup)
	if moduleLookup then
		return moduleLookup[module] ~= nil;
	end

	return false;
end

local function ObjectiveTracker_GetVisibleHeaders()
	local headers = {};
	for index, module in ipairs(ObjectiveTrackerFrame.MODULES) do
		local header = module.Header;
		if header.added and header:IsVisible() then
			headers[header] = true;
		end
	end

	return headers;
end

local function ObjectiveTracker_AnimateHeaders(previouslyVisibleHeaders)
	local currentHeaders = ObjectiveTracker_GetVisibleHeaders();
	for header, isVisible in pairs(currentHeaders) do
		if isVisible and not previouslyVisibleHeaders[header] then
			header:PlayAddAnimation();
		end
	end
end

function ObjectiveTracker_UpdateSuperTrackedQuest(self)
	local questID = C_SuperTrack.GetSuperTrackedQuestID();
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED, questID);
	QuestPOI_SelectButtonByQuestID(self.BlocksFrame, questID);
end

function ObjectiveTracker_Update(reason, id, moduleWhoseCollapseChanged)
	local tracker = ObjectiveTrackerFrame;
	if tracker.isUpdating then
		-- Trying to update while we're already updating, try again next frame
		tracker.isUpdateDirty = true;
		return;
	end
	tracker.isUpdating = true;

	if ( not tracker.initialized ) then
		tracker.isUpdating = false;
		return;
	end

	tracker.BlocksFrame.maxHeight = ObjectiveTrackerFrame.BlocksFrame:GetHeight();
	if ( tracker.BlocksFrame.maxHeight == 0 ) then
		tracker.isUpdating = false;
		return;
	end

	tracker.isUpdateDirty = false;

	OBJECTIVE_TRACKER_UPDATE_REASON = reason or OBJECTIVE_TRACKER_UPDATE_ALL;
	OBJECTIVE_TRACKER_UPDATE_ID = id;

	tracker.BlocksFrame.currentBlock = nil;
	tracker.BlocksFrame.contentsHeight = 0;

	-- Gather existing headers, only newly added ones will animate
	local currentHeaders = ObjectiveTracker_GetVisibleHeaders();

	-- mark headers unused
	for index, module in ipairs(tracker.MODULES) do
		if module.Header then
			module.Header.added = nil;
		end
	end

	-- These can be nil, it's fine, trust the API.
	local relatedModules = GetRelatedModulesForUpdate(moduleWhoseCollapseChanged);

	-- run module updates
	local gotMoreRoomThisPass = false;
	for i = 1, #tracker.MODULES do
		local module = tracker.MODULES[i];
		if IsRelatedModuleForUpdate(moduleWhoseCollapseChanged, relatedModules) or (band(OBJECTIVE_TRACKER_UPDATE_REASON, module.updateReasonModule + module.updateReasonEvents) > 0) then
			-- run a full update on this module
			module:Update();
			-- check if it's now taking up less space, using subtraction because of floats
			if ( module.oldContentsHeight - module.contentsHeight >= 1 ) then
				-- it is taking up less space, might have freed room for other modules
				gotMoreRoomThisPass = true;
			end
		else
			-- this module's contents have not have changed
			-- but if we got more room and this module has unshown content, do a full update
			-- also do a full update if the header is animating since the module does not technically have any blocks at that point
			if ( (module.hasSkippedBlocks and gotMoreRoomThisPass) or (module.Header and module.Header.animating) ) then
				module:Update();
			else
				module:StaticReanchor();
			end
		end
	end

	ObjectiveTracker_ReorderModules();
	ObjectiveTracker_UpdatePOIs();
	ObjectiveTracker_AnimateHeaders(currentHeaders);

	-- hide unused headers
	for i = 1, #tracker.MODULES do
		ObjectiveTracker_CheckAndHideHeader(tracker.MODULES[i].Header);
	end

	if ( tracker.BlocksFrame.currentBlock ) then
		tracker.HeaderMenu:Show();
	else
		tracker.HeaderMenu:Hide();
	end

	tracker.BlocksFrame.currentBlock = nil;
	tracker.isUpdating = false;
end

function ObjectiveTracker_CheckAndHideHeader(moduleHeader)
	if ( moduleHeader and not moduleHeader.added and moduleHeader:IsShown() ) then
		moduleHeader:Hide();
		if ( moduleHeader.animating ) then
			moduleHeader.animating = nil;
			moduleHeader.HeaderOpenAnim:Stop();
		end
	end
end

function ObjectiveTracker_WatchMoney(watchMoney, reason)
	if ( watchMoney ) then
		if ( band(ObjectiveTrackerFrame.watchMoneyReasons, reason) == 0 ) then
			ObjectiveTrackerFrame.watchMoneyReasons = ObjectiveTrackerFrame.watchMoneyReasons + reason;
		end
	else
		if ( band(ObjectiveTrackerFrame.watchMoneyReasons, reason) > 0 ) then
			ObjectiveTrackerFrame.watchMoneyReasons = ObjectiveTrackerFrame.watchMoneyReasons - reason;
		end
	end
end

local function ObjectiveTracker_CountVisibleModules()
	local count = 0;
	local seen = {};
	for index, module in ipairs(ObjectiveTrackerFrame.MODULES) do
		local header = module.Header;
		if header and not seen[header] then
			seen[header] = true;

			if header:IsVisible() and module:GetBlockCount() > 0 then -- testing out the whole active block count concept....
				count = count + 1;
			end
		end
	end

	return count;
end

function ObjectiveTracker_ReorderModules()
	local visibleCount = ObjectiveTracker_CountVisibleModules();
	local showAllModuleMinimizeButtons = visibleCount > 1;
	local detachIndex = nil;
	local anchorBlock = nil;

	local header = ObjectiveTrackerFrame.HeaderMenu;
	header:ClearAllPoints();

	for index, module in ipairs(ObjectiveTrackerFrame.MODULES_UI_ORDER) do
		local topBlock = module.topBlock;
		if topBlock then
			if module:UsesSharedHeader() then
				AnchorBlock(topBlock, module.Header);

				local containingModule = module.Header.module;
				if containingModule and containingModule.firstBlock then
					containingModule.firstBlock:ClearAllPoints();
					AnchorBlock(containingModule.firstBlock, module.lastBlock);
				end
			else
				AnchorBlock(topBlock, anchorBlock);
				anchorBlock = module.lastBlock;
			end

			if header then
				header:SetPoint("RIGHT", module.Header, "RIGHT", 0, 0);
				header = nil;
			end

			-- Side-step annoying "uncollapse" issue by allowing a collapsed module to continue showing its minimize button even if
			-- it's the only remaining visible module
			local shouldShowThisModuleMinimizeButton = showAllModuleMinimizeButtons or module:IsCollapsed();

			module.Header.MinimizeButton:SetShown(shouldShowThisModuleMinimizeButton);
			if shouldShowThisModuleMinimizeButton then
				module.Header.MinimizeButton:SetPoint("RIGHT", module.Header, "RIGHT", -21, 0);
			end
		end
	end
end

function ObjectiveTracker_UpdatePOIs()
	if not ObjectiveTrackerFrame.MODULES then
		return;
	end

	local blocksFrame = ObjectiveTrackerFrame.BlocksFrame;
	QuestPOI_ResetUsage(blocksFrame);

	local showPOIs = GetCVarBool("questPOI");
	if ( not showPOIs ) then
		QuestPOI_HideUnusedButtons(blocksFrame);
		return;
	end

	local numPOINumeric = 0; -- This is tied to the QuestPOI system, it must be maintained across tracker instances.
	for i, module in ipairs(ObjectiveTrackerFrame.MODULES) do
		if module.UpdatePOIs then
			numPOINumeric = module:UpdatePOIs(numPOINumeric);
		end
	end

	QuestPOI_SelectButtonByQuestID(blocksFrame, C_SuperTrack.GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(blocksFrame);
end

QuestHeaderMixin = {};

function QuestHeaderMixin:OnShow()
	self:RegisterEvent("QUEST_SESSION_JOINED");
	self:RegisterEvent("QUEST_SESSION_LEFT");
	self:UpdateHeader();
end

function QuestHeaderMixin:OnHide()
	self:UnregisterEvent("QUEST_SESSION_JOINED");
	self:UnregisterEvent("QUEST_SESSION_LEFT");
end

function QuestHeaderMixin:OnEvent()
	self:UpdateHeader();
end

function QuestHeaderMixin:UpdateHeader()
	if C_QuestSession.HasJoined() then
		self.Text:SetText(TRACKER_HEADER_PARTY_QUESTS);
	else
		self.Text:SetText(TRACKER_HEADER_QUESTS);
	end
end
