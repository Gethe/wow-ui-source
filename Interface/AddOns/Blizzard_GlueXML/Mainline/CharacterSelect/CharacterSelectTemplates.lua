
g_characterSelectToolTrayCollapsed = g_characterSelectToolTrayCollapsed or nil;

CharacterSelectListExpandMixin = {};

function CharacterSelectListExpandMixin:OnLoad()
	ExpandBarMixin.OnLoad(self);

	local expandButton = self.ExpandButton;

	expandButton:ClearAllPoints();
	expandButton:SetPoint("RIGHT", 0, 0);
	expandButton:SetSize(42, 42);

	expandButton.highlightExpandedAtlas = "128-RedButton-ArrowDown-Highlight";
	expandButton.highlightCollapsedAtlas = "128-RedButton-ArrowUpGlow-Highlight";
	expandButton.normalExpandedAtlas = "128-RedButton-ArrowDown";
	expandButton.normalCollapsedAtlas = "128-RedButton-ArrowUpGlow";
	expandButton.pushedExpandedAtlas = "128-RedButton-ArrowDown-Pressed";
	expandButton.pushedCollapsedAtlas = "128-RedButton-ArrowUpGlow-Pressed";
	expandButton.disabledExpandedAtlas = "128-RedButton-ArrowDown-Disabled";
	expandButton.disabledCollapsedAtlas = "128-RedButton-ArrowUpGlow-Disabled";
end


CharacterSelectToolTrayMixin = {};

function CharacterSelectToolTrayMixin:OnLoad()
	self.toolFrames = {};
	self.ExpandBar:SetExpandTarget(self.Container);

	local function OnToggleCallback(isExpanded, isUserInput)
		if isUserInput then
			g_characterSelectToolTrayCollapsed = not isExpanded;
		end
	end

	self.ExpandBar:SetOnToggleCallback(OnToggleCallback);
end

function CharacterSelectToolTrayMixin:RegisterToolFrame(toolFrame, insertAtTop)
	if insertAtTop then
		table.insert(self.toolFrames, 1, toolFrame);
	else
		table.insert(self.toolFrames, toolFrame);
	end

	toolFrame:SetParent(self.Container);
	toolFrame:SetShown(self.ExpandBar:IsExpanded());

	if insertAtTop then
		self:UpdateLayoutIndices();
	else
		local nextLayoutIndex = self.nextLayoutIndex or 1;
		toolFrame.layoutIndex = nextLayoutIndex;
		self.nextLayoutIndex = nextLayoutIndex + 1;
		self.Container:MarkDirty();
	end
end

function CharacterSelectToolTrayMixin:SetToolFrameShown(toolFrame, isEnabled)
	local index = tIndexOf(self.toolFrames, toolFrame);
	if not index then
		assertsafe("Tool frame has not been registered");
		return;
	end

	toolFrame:SetShown(isEnabled);
	self:UpdateLayoutIndices();
end

function CharacterSelectToolTrayMixin:UpdateLayoutIndices()
	local anyActiveToolFrames = false;
	local nextLayoutIndex = 1;
	for i, toolFrame in ipairs(self.toolFrames) do
		if toolFrame:IsShown() then
			anyActiveToolFrames = true;
			toolFrame.layoutIndex = nextLayoutIndex;
			nextLayoutIndex = nextLayoutIndex + 1;
		else
			toolFrame.layoutIndex = nil;
		end
	end

	self.nextLayoutIndex = nextLayoutIndex;
	self.Container:MarkDirty();
	self:SetShown(anyActiveToolFrames);
end

function CharacterSelectToolTrayMixin:SetExpanded(isExpanded, isUserInput)
	self.ExpandBar:SetExpanded(isExpanded, isUserInput);
end
