TabGroupMixin = {};

function TabGroupMixin:OnLoad(...)
	self.isTabGroup = true;
	self.frames = { ... };
end

function TabGroupMixin:AddFrame(frame)
	table.insert(self.frames, frame);
end

function TabGroupMixin:HasFocus()
	return self:GetFocusIndex() ~= nil;
end

function TabGroupMixin:SetFocus()
	-- focusing the first frame/subgroup for now...actually depends on whether or not we were going backwards or forwards through the groups
	local frame = self.frames[1];
	if frame then
		frame:SetFocus();
	end
end

function TabGroupMixin:GetFocusIndex()
	return self.focusIndex or self:DiscoverFocusIndex();
end

function TabGroupMixin:DiscoverFocusIndex()
	self.focusIndex = nil;

	for focusIndex, frame in ipairs(self.frames) do
		if frame:HasFocus() then
			self.focusIndex = focusIndex;
			return focusIndex;
		end
	end
end

function TabGroupMixin:IsValidFocusIndex(focusIndex)
	return focusIndex > 0 and focusIndex <= #self.frames;
end

function TabGroupMixin:WrapFocusIndex(focusIndex)
	if focusIndex == 0 then
		return #self.frames;
	elseif focusIndex > #self.frames then
		return 1;
	end

	return focusIndex;
end

function TabGroupMixin:OnTabPressed(preventFocusWrap)
	local focusIndex = self:GetFocusIndex();

	local frameAtIndex = self.frames[focusIndex];
	if frameAtIndex.isTabGroup then
		if frameAtIndex:OnTabPressed(true) then
			return true;
		end
	end

	local nextFocusIndex = IsShiftKeyDown() and (focusIndex - 1) or (focusIndex + 1);

	if preventFocusWrap and not self:IsValidFocusIndex(nextFocusIndex) then
		return false;
	end

	nextFocusIndex = Wrap(nextFocusIndex, #self.frames);
	self.focusIndex = nextFocusIndex;
	self.frames[nextFocusIndex]:SetFocus();
end

function CreateTabGroup(...)
	local tabGroup = CreateFromMixins(TabGroupMixin);
	tabGroup:OnLoad(...);
	return tabGroup;
end