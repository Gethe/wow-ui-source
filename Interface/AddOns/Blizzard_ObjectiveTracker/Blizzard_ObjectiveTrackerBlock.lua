ObjectiveTrackerBlockMixin = CreateFromMixins(ObjectiveTrackerSlidingMixin);

-- Called on frame creation
function ObjectiveTrackerBlockMixin:Init()
	self.usedLines = { };
	self.rightEdgeOffset = 0;
	
	-- Other Keys
	-- parentModule: owning module
	-- used: shown
	-- id: block key
	-- lastRegion: last region added
	-- isHighlighted: moused over	
	-- height

	-- offsetX: override for module.blockOffsetX
	-- fixedWidth: whether it has fixed width
	-- fixedHeight: whether it has fixed height
	-- rightEdgeFrame: the latest frame added to right edge
	-- addedRegions: list of regions added via AddTimer, AddRightEdgeFrame, etc
end

-- Called at the beginning of a layout
function ObjectiveTrackerBlockMixin:Reset()
	self.used = false;
	self.nextBlock = nil;
	if self.rightEdgeOffset then
		if self.HeaderText then
			self.HeaderText:SetPoint("RIGHT", 0, 0);
		end
		self.rightEdgeOffset = 0;
		self.rightEdgeFrame = nil;
	end
	if not self.fixedHeight then
		self.height = 0;
	end
	self.lastRegion = nil;
	self.addedRegions = nil;
	for objectiveKey, line in pairs(self.usedLines) do
		line.used = nil;
	end
end

-- Called when the block is no longer used
function ObjectiveTrackerBlockMixin:Free()
	-- free all the lines
	for _, line in pairs(self.usedLines) do
		self:FreeLine(line);
	end
	table.wipe(self.usedLines);
	
	if self.HeaderText then
		self.HeaderText:SetText("");
	end

	if self.slideInfo then
		self:EndSlide();
	end

	if self.addedRegions then
		for region, isManaged in pairs(self.addedRegions) do
			-- managed means unused ones get freed from module:EndLayout()
			if isManaged then
				region.used = nil;
			else
				region:Hide();
			end
		end
	end
end

function ObjectiveTrackerBlockMixin:OnAddedRegion(region, isManaged)
	if not self.addedRegions then
		self.addedRegions = { };
	end
	self.addedRegions[region] = isManaged;
end

function ObjectiveTrackerBlockMixin:GetLine(objectiveKey, optTemplate)
	local template = optTemplate or self.parentModule.lineTemplate;

	-- first look for existing line
	local line = self:GetExistingLine(objectiveKey);

	-- if existing line is not of the same type, discard it
	if line and line.template ~= template then
		self:FreeLine(line);
		line = nil;
	end
	
	-- acquire a new line if needed
	if not line then
		line = ObjectiveTrackerManager:AcquireFrame(self, template);
		line:SetParent(self);
		line:Show();		
	end
	
	self.usedLines[objectiveKey] = line;
	line.objectiveKey = objectiveKey;
	line.parentBlock = self;
	line.used = true;
	return line;
end

function ObjectiveTrackerBlockMixin:GetExistingLine(objectiveKey)
	return self.usedLines[objectiveKey];
end

function ObjectiveTrackerBlockMixin:FreeUnusedLines()
	for objectiveKey, line in pairs(self.usedLines) do
		if not line.used then
			self:FreeLine(line);
		end
	end
end

function ObjectiveTrackerBlockMixin:FreeLine(line)
	self.usedLines[line.objectiveKey] = nil;
	ObjectiveTrackerManager:ReleaseFrame(line);
	line:Hide();
	if line.OnFree then
		line:OnFree(self);
	end
end

function ObjectiveTrackerBlockMixin:ForEachUsedLine(func)
	for objectiveKey, line in pairs(self.usedLines) do
		if func(line, objectiveKey) then
			return;
		end
	end
end

function ObjectiveTrackerBlockMixin:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
	if useFullHeight then
		fontString:SetMaxLines(0);
	else
		fontString:SetMaxLines(2);
	end
	fontString:SetHeight(0);	-- force a clear of internals or GetHeight() might return an incorrect value
	fontString:SetText(text);

	local stringHeight = fontString:GetHeight();
	colorStyle = colorStyle or OBJECTIVE_TRACKER_COLOR["Normal"];
	if useHighlight and colorStyle.reverse then
		colorStyle = colorStyle.reverse;
	end
	if fontString.colorStyle ~= colorStyle then
		fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
		fontString.colorStyle = colorStyle;
	end
	return stringHeight;
end

function ObjectiveTrackerBlockMixin:SetHeader(text)
	self.HeaderText:SetPoint("RIGHT", self.rightEdgeOffset, 0);
	local height = self:SetStringText(self.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"], self.isHighlighted);
	self.height = height;
end

function ObjectiveTrackerBlockMixin:AddObjective(objectiveKey, text, template, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)
	local line = self:GetLine(objectiveKey, template);

	line.progressBar = nil;

	-- dash
	if line.Dash then
		if not dashStyle then
			dashStyle = OBJECTIVE_DASH_STYLE_SHOW;
		end
		if line.dashStyle ~= dashStyle then
			if dashStyle == OBJECTIVE_DASH_STYLE_SHOW then
				line.Dash:Show();
				line.Dash:SetText(QUEST_DASH);
			elseif dashStyle == OBJECTIVE_DASH_STYLE_HIDE then
				line.Dash:Hide();
				line.Dash:SetText(QUEST_DASH);
			elseif dashStyle == OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE then
				line.Dash:Hide();
				line.Dash:SetText(nil);
			else
				assertsafe(false, "Invalid dash style: " .. tostring(dashStyle));
			end
			line.dashStyle = dashStyle;
		end
	end

	local lineSpacing = self.parentModule.lineSpacing;
	local offsetY = -lineSpacing;

	-- anchor the line
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offsetY);
	else
		line:SetPoint("TOPLEFT", 0, offsetY);
	end
	line:SetPoint("RIGHT", self.rightEdgeOffset, 0);

	-- set the text
	local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, self.isHighlighted);
	local height = overrideHeight or textHeight;
	line:SetHeight(height);

	self.height = self.height + height + lineSpacing;

	self.lastRegion = line;
	return line;
end

function ObjectiveTrackerBlockMixin:AddCustomRegion(region, optOffsetX, optOffsetY)
	local offsetX = optOffsetX or 0;
	local offsetY = optOffsetY or -self.parentModule.lineSpacing;
	-- anchor the line
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		region:SetPoint("TOP", anchor, "BOTTOM", 0, offsetY);
		region:SetPoint("LEFT", offsetX, 0);
	else
		region:SetPoint("TOPLEFT", offsetX, offsetY);
	end
	
	self.height = self.height + region:GetHeight() - offsetY;
	self.lastRegion = region;
	region:Show();
	local isManaged = false;
	self:OnAddedRegion(region, isManaged);
end

function ObjectiveTrackerBlockMixin:AddTimerBar(duration, startTime)
	local line = self.lastRegion;
	if not line then
		return nil;
	end

	local timerBar = self.parentModule:GetTimerBar(line);

	local lineSpacing = self.parentModule.lineSpacing;
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		timerBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -lineSpacing);
	else
		timerBar:SetPoint("TOPLEFT", 0, -lineSpacing);
	end

	timerBar.Bar:SetMinMaxValues(0, duration);
	timerBar.duration = duration;
	timerBar.startTime = startTime;
	timerBar.parentLine = line;

	self.height = self.height + timerBar.height + lineSpacing;
	self.lastRegion = timerBar;
	local isManaged = true;
	self:OnAddedRegion(timerBar, isManaged);
	return timerBar;
end

function ObjectiveTrackerBlockMixin:AddProgressBar(id, lineSpacing)
	local line = self.lastRegion;
	if not line then
		return nil;
	end
	
	local progressBar = self.parentModule:GetProgressBar(line, id);

	lineSpacing = lineSpacing or self.parentModule.lineSpacing;
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		progressBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -lineSpacing);
	else
		progressBar:SetPoint("TOPLEFT", 0, -lineSpacing);
	end
	
	line.progressBar = progressBar;
	progressBar.parentLine = line;

	self.height = self.height + progressBar.height + lineSpacing;
	self.lastRegion = progressBar;
	local isManaged = true;
	self:OnAddedRegion(progressBar, isManaged);
	return progressBar;
end

function ObjectiveTrackerBlockMixin:OnHeaderClick(mouseButton)
	self.parentModule:OnBlockHeaderClick(self, mouseButton);
end

function ObjectiveTrackerBlockMixin:OnHeaderEnter()
	self.isHighlighted = true;
	self:UpdateHighlight();
	self.parentModule:OnBlockHeaderEnter(self);
end

function ObjectiveTrackerBlockMixin:OnHeaderLeave()
	self.isHighlighted = false;
	self:UpdateHighlight();	
	self.parentModule:OnBlockHeaderLeave(self);
end

function ObjectiveTrackerBlockMixin:UpdateHighlight()
	local headerColor, dashColor;
	if self.isHighlighted then
		headerColor = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
		dashColor = OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
	else
		headerColor = OBJECTIVE_TRACKER_COLOR["Header"];
		dashColor = OBJECTIVE_TRACKER_COLOR["Normal"];		
	end

	if self.HeaderText then
		self.HeaderText:SetTextColor(headerColor.r, headerColor.g, headerColor.b);
		self.HeaderText.colorStyle = headerColor;
	end
	
	for objectiveKey, line in pairs(self.usedLines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if colorStyle then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if line.Dash then
				line.Dash:SetTextColor(dashColor.r, dashColor.g, dashColor.b);
			end
		end
	end
end

function ObjectiveTrackerBlockMixin:AdjustSlideAnchor(offsetY)
	self.HeaderText:SetPoint("TOPLEFT", 0, offsetY);
end

function ObjectiveTrackerBlockMixin:AdjustRightEdgeOffset(offset)
	-- this must be done before setting any lines
	assert(not self.lastRegion);
	self.rightEdgeOffset = self.rightEdgeOffset + offset;
end

local function MakeRightEdgeFrameKey(frameKey, instanceKey)
	return frameKey .. instanceKey;
end

function ObjectiveTrackerBlockMixin:AddRightEdgeFrame(settings, identifier, ...)
	local frame = self.parentModule:GetRightEdgeFrame(settings, identifier);

	if self.rightEdgeFrame == frame then
		-- TODO: Fix for real, some event causes the findGroup button to get added twice (could happen for any button)
		-- so it doesn't need to be reanchored another time
		return;
	end

	frame:ClearAllPoints();

	local spacing = self.parentModule.rightEdgeFrameSpacing;
	if self.rightEdgeFrame then
		frame:SetPoint("RIGHT", self.rightEdgeFrame, "LEFT", -spacing, 0);
	else
		frame:SetPoint("TOPRIGHT", self, settings.offsetX, settings.offsetY);
		self:AdjustRightEdgeOffset(settings.offsetX);
	end

	frame:SetUp(identifier, ...);

	self.rightEdgeFrame = frame;
	self:AdjustRightEdgeOffset(-frame:GetWidth() - spacing);
	local isManaged = true;
	self:OnAddedRegion(frame, isManaged);
	return frame;
end

ObjectiveTrackerBlockHeaderMixin = { };

function ObjectiveTrackerBlockHeaderMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ObjectiveTrackerBlockHeaderMixin:OnClick(mouseButton)
	local block = self:GetParent();
	block:OnHeaderClick(mouseButton);
end

function ObjectiveTrackerBlockHeaderMixin:OnEnter()
	local block = self:GetParent();
	block:OnHeaderEnter();
end

function ObjectiveTrackerBlockHeaderMixin:OnLeave()
	local block = self:GetParent();
	block:OnHeaderLeave();
end