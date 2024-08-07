ObjectiveTrackerModuleState = EnumUtil.MakeEnum(
	"Skipped",			-- module did not try to layout (due to availableHeight being 0)
	"NoObjectives",		-- module has no objectives to show
	"NotShown",			-- module has objectives but there was not enough room to display anything
	"ShownPartially",	-- at least 1 objective is shown
	"ShownFully"		-- all objectives are shown, or header is collapsed and at least 1 objective could have shown
);

local settings = {
	isModule = true,			-- for identification

	-- settings
	blockTemplate = "ObjectiveTrackerBlockTemplate",
	lineTemplate = "ObjectiveTrackerLineTemplate",
	progressBarTemplate = "ObjectiveTrackerProgressBarTemplate",
	headerHeight = 25,			-- how much vertical room the the header takes up (including any spacing from the top of the module)
	fromHeaderOffsetY = -10,	-- the vertial spacing between header and first block
	blockOffsetX = 20,			-- the horizontal spacing for a block from the left side
	fromBlockOffsetY = -10,		-- the vertical spacing between header and first block
	lineSpacing = 4,			-- the vertical spacing between lines
	bottomSpacing = 0,			-- spacing between last block and bottom of module
	rightEdgeFrameSpacing = 0,	-- spacing between rightEdgeFrames, or between one and the lines
	leftMargin = 0,				-- margin for module from left side of container, used at container level
	hasDisplayPriority = false,	-- modules with priority will consume available space first, regardless of their uiOrder
	mustFit = false,			-- modules that must fit will adjust the height of custom-placed containers if needed, overriding the height specified by the user

	-- dynamic
	state = ObjectiveTrackerModuleState.Skipped,
	isDirty = false,			-- whether module needs to update
	isCollapsed = false,		-- whether module is collapsed
	hasTriedBlocks = false,		-- whether the module tried to fit any objectives (could not have tried at all if availableHeight was 0)
	hasSkippedBlocks = false,	-- whether there was not enough room to display all the objectives of the module (can be true if header is collapsed)
	hasContents = false,		-- whether the module should show
	contentsHeight = 0,			-- height as elements are added
	availableHeight = 0,		-- room available for the module to display
	uiOrder = nil,				-- will be assigned by a manager:AssignModulesOrder call
	wasDisplayedLastLayout = false,	-- whether the module was already displayed before the current Update
	
	-- caching
	cachedOrderList,				-- list of block IDs that existed when any block was cached
	cacheIndex,					-- Per layout action, the index of where processing is in the cachedOrderList
	numCachedBlocks = 0,		-- number of cached blocks in cachedOrderList
};

ObjectiveTrackerModuleMixin = CreateFromMixins(ObjectiveTrackerSlidingMixin, settings);

function ObjectiveTrackerModuleMixin:OnLoad()
	self.usedBlocks = { };			-- list of displayed blocks
	
	if self.headerText then
		self:SetHeader(self.headerText);
	end
end

function ObjectiveTrackerModuleMixin:OnEvent(event, ...)
	-- override in your mixin
end

function ObjectiveTrackerModuleMixin:SetContainer(container)
	self.parentContainer = container;
	self:SetParent(container);
	self:ClearAllPoints();
	self:SetPoint("TOPLEFT");

	if not self.init then
		self.init = true;
		-- register events
		if self.events then
			for i, event in ipairs(self.events) do
				self:RegisterEvent(event);
			end
		end
		-- custom init
		self:InitModule();
	end
end

function ObjectiveTrackerModuleMixin:InitModule()
	-- override in your mixin, called the first time the module is added to a container
end

function ObjectiveTrackerModuleMixin:MarkDirty()
	if self.parentContainer then
		self.isDirty = true;
		self.parentContainer:MarkDirty();
	end
end

function ObjectiveTrackerModuleMixin:IsDirty()
	return self.isDirty;
end

function ObjectiveTrackerModuleMixin:HasContents()
	return self.hasContents;
end

function ObjectiveTrackerModuleMixin:IsDisplayable()
	return self.state >= ObjectiveTrackerModuleState.ShownPartially;
end

function ObjectiveTrackerModuleMixin:IsFullyDisplayable()
	return self.state == ObjectiveTrackerModuleState.ShownFully;
end

function ObjectiveTrackerModuleMixin:IsComplete()
	return self.state == ObjectiveTrackerModuleState.NoObjectives or self:IsFullyDisplayable();
end

function ObjectiveTrackerModuleMixin:IsTruncated()
	return self.state == ObjectiveTrackerModuleState.NotShown or self.state == ObjectiveTrackerModuleState.ShownPartially;
end

function ObjectiveTrackerModuleMixin:GetContentsHeight()
	return self:IsDisplayable() and self.contentsHeight or 0;
end

function ObjectiveTrackerModuleMixin:SetHeader(text)
	self.Header.Text:SetText(text);
end

-- returns heightUsed, isTruncated
function ObjectiveTrackerModuleMixin:Update(availableHeight, dirtyUpdate)
	if not self:CanUpdate() then
		return self:GetContentsHeight(), self:IsTruncated();
	end

	-- if it's a dirty update but this module isn't dirty, it's one or more other modules that need updating
	if dirtyUpdate and not self:IsDirty() then
		-- so no need to do anything if the module is complete
		if self:IsComplete() and self.contentsHeight <= availableHeight and not self:IsCollapsed() then
			local isTruncated = false;
			return self:GetContentsHeight(), isTruncated;
		end
	end

	self:BeginLayout();
	
	-- add objectives and update the state
	if availableHeight > 0 then
		self.availableHeight = availableHeight;
		self:LayoutContents();
		self:CheckCachedBlocks();
		if self.hasContents then
			if self.hasSkippedBlocks and not self:IsCollapsed() then
				self.state = ObjectiveTrackerModuleState.ShownPartially;
			else
				self.state = ObjectiveTrackerModuleState.ShownFully;
			end
		else
			if self.hasTriedBlocks then
				self.state = ObjectiveTrackerModuleState.NotShown;
			else
				self.state = ObjectiveTrackerModuleState.NoObjectives;
			end
		end
	end

	self:EndLayout();
	
	return self:GetContentsHeight(), self:IsTruncated();
end

function ObjectiveTrackerModuleMixin:BeginLayout()
	-- must run before self.firstBlock is cleared
	self:UpdateCachedOrderList();

	self.wasDisplayedLastLayout = self:IsDisplayable();
	self.isDirty = false;
	self.hasTriedBlocks = false;
	self.hasSkippedBlocks = false;
	self.hasContents = false;

	self.lastBlock = nil;
	self.firstBlock = nil;
	self.contentsHeight = self.headerHeight or 0;

	self:MarkBlocksUnused();
	self:MarkTimerBarsUnused();
	self:MarkProgressBarsUnused();
	self:MarkRightEdgeFramesUnused();

	self.state = ObjectiveTrackerModuleState.Skipped;
end

function ObjectiveTrackerModuleMixin:CanUpdate()
	-- override in your mixin
	return true;
end

function ObjectiveTrackerModuleMixin:LayoutContents()
	-- override in your mixin
	-- must return soon as a LayoutBlock fails
end

function ObjectiveTrackerModuleMixin:EndLayout()
	self:FreeUnusedBlocks();
	self:FreeUnusedTimerBars();
	self:FreeUnusedProgressBars();
	self:FreeUnusedRightEdgeFrames();
	if self:IsDisplayable() and not self.parentContainer:IsCollapsed() then
		self.lastBlock = self.lastBlock;
		self:UpdateHeight();
		self:Show();
		if not self.wasDisplayedLastLayout then
			self.Header:PlayAddAnimation();
		end
	else
		self:Hide();
	end
	self:ClearFanfares();
end

function ObjectiveTrackerModuleMixin:HasSkippedBlocks()
	return self.hasSkippedBlocks;
end

function ObjectiveTrackerModuleMixin:UpdateHeight()
	local heightModifier = 0;
	if self.heightModifiers then
		for key, height in pairs(self.heightModifiers) do
			heightModifier = heightModifier + height;
		end
	end
	self:SetHeight(self.contentsHeight + self.bottomSpacing + heightModifier);
end

function ObjectiveTrackerModuleMixin:SetHeightModifier(key, height)
	if not self.heightModifiers then
		self.heightModifiers = { };
	end
	self.heightModifiers[key] = height;
	self:UpdateHeight();
end

function ObjectiveTrackerModuleMixin:ClearHeightModifier(key)
	if self.heightModifiers then
		self.heightModifiers[key] = nil;
	end
	self:UpdateHeight();
end

function ObjectiveTrackerModuleMixin:AcquireFrame(template)
	local frame, isNew = ObjectiveTrackerManager:AcquireFrame(self, template);
	frame:SetParent(self.ContentsFrame);
	return frame, isNew;
end

function ObjectiveTrackerModuleMixin:GetBlock(id, optTemplate)
	local template = optTemplate or self.blockTemplate;
	if not self.usedBlocks[template] then
		self.usedBlocks[template] = {};
	end

	-- first try to return existing block
	local wasAlreadyActive = true;
	local block = self.usedBlocks[template][id];

	if not block then
		local isNew;
		block, isNew = self:AcquireFrame(template);
		block.parentModule = self;
		if isNew then
			block:Init();
		end
		self.usedBlocks[template][id] = block;
		block.id = id;
		wasAlreadyActive = false;
	end

	block:Reset();

	-- anchor it first so measurements are correct
	self:AnchorBlock(block);

	return block, wasAlreadyActive;
end

function ObjectiveTrackerModuleMixin:GetExistingBlock(id, optTemplate)
	local template = optTemplate or self.blockTemplate;

	local blocks = self.usedBlocks[template];
	if blocks then
		return blocks[id];
	end

	return nil;
end

function ObjectiveTrackerModuleMixin:MarkBlocksUnused()
	for template, blocks in pairs(self.usedBlocks) do
		for blockID, block in pairs(blocks) do
			block.used = nil;
		end
	end
end

function ObjectiveTrackerModuleMixin:FreeUnusedBlocks()
	for template, blocks in pairs(self.usedBlocks) do
		for blockID, block in pairs(blocks) do
			if not block.used then
				self:FreeBlock(block);
			end
		end
	end
end

function ObjectiveTrackerModuleMixin:FreeBlock(block)
	local fromFreeBlock = true;
	self:RemoveBlockFromCache(block, fromFreeBlock);
	block:Free();
	self.usedBlocks[block.template][block.id] = nil;
	ObjectiveTrackerManager:ReleaseFrame(block);
	self:OnFreeBlock(block);
end

function ObjectiveTrackerModuleMixin:OnFreeBlock(block)
	-- override in your mixin
end

function ObjectiveTrackerModuleMixin:ForceRemoveBlock(block)
	block.used = nil;
	self:FreeBlock(block);
	self:MarkDirty();
end

-- returns anchorFrame, offsetY, relativePoint
function ObjectiveTrackerModuleMixin:GetNextBlockAnchoring()
	if self.lastBlock then
		return self.lastBlock, self.fromBlockOffsetY, "BOTTOM";
	else
		return self.ContentsFrame, self.fromHeaderOffsetY, "TOP";
	end
end

function ObjectiveTrackerModuleMixin:LayoutBlock(block)
	if not block.cached then
		self:CheckCachedBlocks(block);
	end

	block:SetHeight(block.height);
	if self:AddBlock(block) then
		block.used = true;
		block:Show();
		if block.FreeUnusedLines then
			block:FreeUnusedLines();
		end
		if block.OnLayout then
			block:OnLayout();
		end
		return true;
	else
		return false;
	end
end

function ObjectiveTrackerModuleMixin:AddBlock(block)
	self.hasTriedBlocks = true;

	local blockAdded = false;
	if self:CanFitBlock(block) then
		blockAdded = self:InternalAddBlock(block);
	end

	if not blockAdded then
		self.hasSkippedBlocks = true;
	end

	return blockAdded;
end

function ObjectiveTrackerModuleMixin:CanFitBlock(block)
	local anchorFrame, offsetY = self:GetNextBlockAnchoring();
	local height = block.height - offsetY;
	return (self.contentsHeight + height) <= self.availableHeight;
end

function ObjectiveTrackerModuleMixin:InternalAddBlock(block)
	-- If this got called, something will show for certain
	self.hasContents = true;

	-- If module is collapsed, don't actually add the block and end the layout. The reason IsCollapsed is only checked now and not before
	-- trying to add any objectives is to fix a bug with the prior implementation:
	--	Have 2 modules, A & B
	--	Collapse B
	--	Track some more in A so that B is pushed down near the bottom but its header still shows
	--  Expand B
	--  --> B disappears because there is not enough room for the header and its first objective
	if self:IsCollapsed() then
		return false;
	end

	local offsetY = self:AnchorBlock(block);
	if self.lastBlock then
		self.lastBlock.nextBlock = block;
	end
	self.lastBlock = block;
	if not self.firstBlock then
		self.firstBlock = block;
	end

	self.contentsHeight = self.contentsHeight + block.height - offsetY;

	return true;
end

function ObjectiveTrackerModuleMixin:AnchorBlock(block)
	block:ClearAllPoints();
	local anchorFrame, offsetY, relativePoint = self:GetNextBlockAnchoring();
	block:SetPoint("TOP", anchorFrame, relativePoint, 0, offsetY);
	block:SetPoint("LEFT", block.offsetX or self.blockOffsetX, 0);
	if not block.fixedWidth then
		block:SetPoint("RIGHT");
	end

	return offsetY;
end

function ObjectiveTrackerModuleMixin:GetLastBlock()
	return self.lastBlock or self.Header;
end

function ObjectiveTrackerModuleMixin:OnBlockHeaderClick(block, mouseButton)
	-- override in your mixin
end

function ObjectiveTrackerModuleMixin:OnBlockHeaderEnter(block)
	-- override in your mixin
end

function ObjectiveTrackerModuleMixin:OnBlockHeaderLeave(block)
	-- override in your mixin
end

function ObjectiveTrackerModuleMixin:GetContentsHeight()
	if self:IsDisplayable() then
		return self.contentsHeight;
	else
		return 0;
	end
end

function ObjectiveTrackerModuleMixin:ToggleCollapsed()
	self:SetCollapsed(not self:IsCollapsed());
end

function ObjectiveTrackerModuleMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
	self.ContentsFrame:SetShown(not collapsed);
	-- update the header
	self.Header:SetCollapsed(collapsed);
	-- update contents
	self:MarkDirty();
end

function ObjectiveTrackerModuleMixin:IsCollapsed()
	return self.isCollapsed;
end

function ObjectiveTrackerModuleMixin:GetContextMenuParent()
	return ObjectiveTrackerManager:GetContainerForModule(self);
end

function ObjectiveTrackerModuleMixin:GetTimerBar(key)
	if not self.usedTimerBars then
		self.usedTimerBars = { };
	end

	local timerBar = self.usedTimerBars[key];
	if not timerBar then
		timerBar = self:AcquireFrame("ObjectiveTrackerTimerBarTemplate");
		self.usedTimerBars[key] = timerBar;

		-- store the height since it's fixed
		if not timerBar.height then
			timerBar.height = timerBar:GetHeight();
		end

		timerBar:Show();
	end

	timerBar.used = true;
	return timerBar;
end

function ObjectiveTrackerModuleMixin:MarkTimerBarsUnused()
	if self.usedTimerBars then
		for key, timerBar in pairs(self.usedTimerBars) do
			timerBar.used = nil;
		end
	end
end

function ObjectiveTrackerModuleMixin:FreeUnusedTimerBars()
	if self.usedTimerBars then
		for key, timerBar in pairs(self.usedTimerBars) do
			if not timerBar.used then
				self.usedTimerBars[key] = nil;
				ObjectiveTrackerManager:ReleaseFrame(timerBar);
			end
		end
	end
end

function ObjectiveTrackerModuleMixin:GetProgressBar(key, ...)
	if not self.usedProgressBars then
		self.usedProgressBars = { };
	end

	local progressBar = self.usedProgressBars[key];
	local isNew = not progressBar;
	if not progressBar then
		progressBar = self:AcquireFrame(self.progressBarTemplate);
		self.usedProgressBars[key] = progressBar;

		-- store the height since it's fixed
		if not progressBar.height then
			progressBar.height = progressBar:GetHeight();
		end

		progressBar:Show();
	end

	progressBar.used = true;
	if progressBar.OnGet then
		progressBar:OnGet(isNew, ...);
	end
	return progressBar;
end

function ObjectiveTrackerModuleMixin:MarkProgressBarsUnused()
	if self.usedProgressBars then
		for key, progressBar in pairs(self.usedProgressBars) do
			progressBar.used = nil;
		end
	end
end

function ObjectiveTrackerModuleMixin:FreeUnusedProgressBars()
	if self.usedProgressBars then
		for key, progressBar in pairs(self.usedProgressBars) do
			if not progressBar.used then
				self.usedProgressBars[key] = nil;
				if progressBar.OnFree then
					progressBar:OnFree();
				end
				ObjectiveTrackerManager:ReleaseFrame(progressBar);
			end
		end
	end
end

local function MakeRightEdgeFrameKey(settings, identifier)
	return tostring(settings) .. identifier;
end

function ObjectiveTrackerModuleMixin:GetRightEdgeFrame(settings, identifier)
	if not self.usedRightEdgeFrames then
		self.usedRightEdgeFrames = { };
	end

	local key = MakeRightEdgeFrameKey(settings, identifier);
	local frame = self.usedRightEdgeFrames[key];
	if not frame then
		frame = self:AcquireFrame(settings.template);
		frame:Show();
		self.usedRightEdgeFrames[key] = frame;
	end

	frame.used = true;
	return frame;
end

function ObjectiveTrackerModuleMixin:MarkRightEdgeFramesUnused()
	if self.usedRightEdgeFrames then
		for key, frame in pairs(self.usedRightEdgeFrames) do
			frame.used = nil;
		end
	end
end

function ObjectiveTrackerModuleMixin:FreeUnusedRightEdgeFrames()
	if self.usedRightEdgeFrames then
		for key, frame in pairs(self.usedRightEdgeFrames) do
			if not frame.used then
				self.usedRightEdgeFrames[key] = nil;
				ObjectiveTrackerManager:ReleaseFrame(frame);
			end
		end
	end
end

function ObjectiveTrackerModuleMixin:AdjustSlideAnchor(offsetY)
	-- Slide might have been cancelled by an update, firstBlock would be cleared out
	if self.firstBlock then
		self.firstBlock:SetPoint("TOP", self.ContentsFrame, "TOP", 0, offsetY + self.fromHeaderOffsetY);
	end
end

function ObjectiveTrackerModuleMixin:SetNeedsFanfare(key)
	if key then
		if not self.fanfares then
			self.fanfares = { };
		end
		self.fanfares[key] = true;
	end
end

function ObjectiveTrackerModuleMixin:NeedsFanfare(key)
	return self.fanfares and self.fanfares[key];
end

function ObjectiveTrackerModuleMixin:ClearFanfares()
	self.fanfares = nil;
end

function ObjectiveTrackerModuleMixin:ForceExpand()
	if self:IsCollapsed() then
		self:ToggleCollapsed();
	end
	if self.parentContainer then
		self.parentContainer:ForceExpand();
	end
	self:MarkDirty();
end

-- Cached Blocks
-- These are blocks temporarily cached so they can still be displayed even after their backing information is gone (quest untracked, turned in, etc).
-- Caching will also automatically expire if a block's .used is cleared, for example from minimizing the module, or from something else being tracked
-- 		pushing the cached block out of the visible area.
-- An individual module only needs to call AddBlockToCache and RemoveBlockFromCache.
-- At the beginning of a layout, the cachedOrderList is built if there are any cached blocks. This list is built from all existing blocks in the module,
-- 		and contains either IDs of non-cached blocks or the cached blocks themselves.
-- Then during the layout, before adding any block the list is checked to see if any cached blocks need to be inserted before this upcoming block.
-- Finally, one more check is done at the end of the layout, for any remaining cached blocks.

function ObjectiveTrackerModuleMixin:AddBlockToCache(block)
	if not block.cached then
		block.cached = true;
		self.numCachedBlocks = self.numCachedBlocks + 1;
	end
end

function ObjectiveTrackerModuleMixin:RemoveBlockFromCache(block, fromFreeBlock)
	if block.cached then
		block.cached = false;
		self.numCachedBlocks = self.numCachedBlocks - 1;
		assert(self.numCachedBlocks >= 0);
		if not fromFreeBlock then
			self:MarkDirty();
		end
	end
end

function ObjectiveTrackerModuleMixin:UpdateCachedOrderList()
	if self.numCachedBlocks == 0 then
		self.cachedOrderList = nil;
		return;
	end

	self.cachedOrderList = { };
	self.cacheIndex = 1;
	local block = self.firstBlock;
	while block do
		if block.cached then
			table.insert(self.cachedOrderList, block);
		else
			-- ID is more unique than blocks
			table.insert(self.cachedOrderList, block.id);
		end
		block = block.nextBlock;
	end
end

function ObjectiveTrackerModuleMixin:CheckCachedBlocks(upcomingBlock)
	if not self.cachedOrderList then
		return;
	end

	local numItems = #self.cachedOrderList;	
	local targetBlockID = upcomingBlock and upcomingBlock.id;
	-- If this block's id is not in the remainder of the list, don't insert any cached blocks before it.
	if targetBlockID then
		local found = false;
		for i = self.cacheIndex, numItems do
			if self.cachedOrderList[i] == targetBlockID then
				found = true;
				break;
			end
		end
		if not found then
			return;
		end
	end

	-- Go through the list starting at the cacheIndex until the targetBlockID is found.
	-- Add any cached blocks encountered to the layout.
	for i = self.cacheIndex, numItems do	
		local cacheItem = self.cachedOrderList[i];
		local isCachedBlock = type(cacheItem) == "table";
		if isCachedBlock then
			-- Possible for a block to be cached while still added by a module
			-- Ignore it if already used
			if not cacheItem.used then
				if not self:LayoutBlock(cacheItem) then
					-- Cached block could not fit, done for this layout pass
					break;
				end
			end
		elseif cacheItem == targetBlockID then
			-- Found the upcoming block, done for this call
			self.cacheIndex = i + 1;
			return;
		end
	end

	-- All the cached blocks that could be added have been added by now
	self.cacheIndex = numItems + 1;
end

-- *****************************************************************************************************
-- ***** HEADER
-- *****************************************************************************************************

ObjectiveTrackerModuleHeaderMixin = {};

function ObjectiveTrackerModuleHeaderMixin:OnLoad()
	self.MinimizeButton:SetScript("OnClick", GenerateClosure(self.OnToggle, self));
	local collapsed = false;
	self:SetCollapsed(collapsed);
end

function ObjectiveTrackerModuleHeaderMixin:PlayAddAnimation()
	self.AddAnim:Restart();
end

function ObjectiveTrackerModuleHeaderMixin:OnToggle()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	-- module is in charge of state
	local module = self:GetParent();
	module:ToggleCollapsed();
end

function ObjectiveTrackerModuleHeaderMixin:SetCollapsed(collapsed)
	local normalTexture = self.MinimizeButton:GetNormalTexture();
	local pushedTexture = self.MinimizeButton:GetPushedTexture();

	if collapsed then
		normalTexture:SetAtlas("ui-questtrackerbutton-secondary-expand", true);
		pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-expand-pressed", true);
	else
		normalTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse", true);
		pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse-pressed", true);
	end
end