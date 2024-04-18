
CharacterSelectListExpandMixin = {};

function CharacterSelectListExpandMixin:OnLoad()
	ExpandBarMixin.OnLoad(self);

	self.ExpandButton:ClearAllPoints();
	self.ExpandButton:SetPoint("RIGHT", 0, 0);
	self.ExpandButton:SetSize(46, 46);
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
	local nextLayoutIndex = 1;
	for i, toolFrame in ipairs(self.toolFrames) do
		if toolFrame:IsShown() then
			toolFrame.layoutIndex = nextLayoutIndex;
			nextLayoutIndex = nextLayoutIndex + 1;
		else
			toolFrame.layoutIndex = nil;
		end
	end

	self.nextLayoutIndex = nextLayoutIndex;
	self.Container:MarkDirty();
end

function CharacterSelectToolTrayMixin:SetExpanded(isExpanded, isUserInput)
	self.ExpandBar:SetExpanded(isExpanded, isUserInput);
end
