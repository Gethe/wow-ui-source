
ScrollListLineMixin = {};

function ScrollListLineMixin:InitLine(...)
	-- Override in your mixin.
end

function ScrollListLineMixin:UpdateDisplay()
	-- Override in your mixin.
end

function ScrollListLineMixin:OnSelected()
	-- Override in your mixin.
end

function ScrollListLineMixin:OnEnter()
	-- Override in your mixin.
end

function ScrollListLineMixin:OnLeave()
	-- Override in your mixin.
end

function ScrollListLineMixin:Populate(listIndex)
	self.listIndex = listIndex;
	self:UpdateDisplay();
end

function ScrollListLineMixin:OnClick()
	self:GetScrollList():SetSelectedListIndex(self.listIndex);
	self:OnSelected();
end

function ScrollListLineMixin:IsSelected()
	return self:GetListIndex() == self:GetScrollList():GetSelectedListIndex();
end

function ScrollListLineMixin:GetListIndex()
	return self.listIndex;
end

function ScrollListLineMixin:GetScrollList()
	local scrollFrame = self:GetParent():GetParent();
	return scrollFrame:GetParent();
end


ScrollListMixin = {};

-- The lineTemplate should only be set once. Any subsequent attempts will fail.
function ScrollListMixin:SetLineTemplate(lineTemplate, ...)
	if self.lineTemplate ~= nil then
		return;
	end

	self.lineTemplate = lineTemplate;
	self.lineTemplateInitArgs = {...};
end

function ScrollListMixin:SetGetNumResultsFunction(getNumResultsFunction)
	self.getNumResultsFunction = getNumResultsFunction;
	self:Reset();
end

function ScrollListMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function ScrollListMixin:SetRefreshCallback(refreshCallback)
	self.refreshCallback = refreshCallback;
end

function ScrollListMixin:GetSelectedHighlight()
	return self.ScrollFrame.ArtOverlay.SelectedHighlight;
end

function ScrollListMixin:OnShow()
	self:Init();
	self:RefreshScrollFrame();
end

function ScrollListMixin:Init()
	if self.isInitialized or self.lineTemplate == nil then
		return;
	end

	self.ScrollFrame.update = function()
		self:RefreshScrollFrame();
	end;

	HybridScrollFrame_CreateButtons(self.ScrollFrame, self.lineTemplate, 0, 0);
	for i, button in ipairs(self.ScrollFrame.buttons) do
		button:InitLine(unpack(self.lineTemplateInitArgs));
	end

	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

	self.isInitialized = true;

	self:UpdatedSelectedHighlight();
end

function ScrollListMixin:UpdatedSelectedHighlight()
	local selectedHighlight = self:GetSelectedHighlight();
	selectedHighlight:ClearAllPoints();
	selectedHighlight:Hide();

	if self.isInitialized and self.selectedListIndex ~= nil then
		local buttonOffset = self.selectedListIndex - self:GetScrollOffset();
		local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
		if buttonOffset >= 1 and buttonOffset < #buttons then
			local button = buttons[buttonOffset];
			selectedHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", 4, 0);
			selectedHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
			selectedHighlight:Show();
		end
	end
end

function ScrollListMixin:SetSelectedListIndex(listIndex, skipUpdates)
	local sameIndex = selectedListIndex == listIndex;
	self.selectedListIndex = listIndex;

	if not skipUpdates then
		if self.selectionCallback then
			self.selectionCallback(listIndex);
		end
	end

	if sameIndex or skipUpdates then
		return;
	end

	self:UpdatedSelectedHighlight();

	self:RefreshScrollFrame();
end

function ScrollListMixin:GetSelectedListIndex()
	return self.selectedListIndex;
end

function ScrollListMixin:Reset()
	if self.isInitialized then
		self.ScrollFrame.scrollBar:SetValue(0);
	end
end

function ScrollListMixin:GetScrollOffset()
	return HybridScrollFrame_GetOffset(self.ScrollFrame);
end

function ScrollListMixin:RefreshScrollFrame()
	if not self:IsVisible() then
		return;
	end

	if self.lineTemplate == nil then
		error("Scroll list lineTemplate not set. Use ScrollListMixin:SetLineTemplate.");
		return;
	end

	if self.getNumResultsFunction == nil then
		error("Scroll list getNumResultsFunction not set. Use ScrollListMixin:SetGetNumResultsFunction.");
		return;
	end

	if not self.isInitialized then
		error("Scroll list has not been initialized. This should generally happen in OnShow.");
		return;
	end

	local numResults = self.getNumResultsFunction();
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	local buttonCount = #buttons;
	
	local offset = self:GetScrollOffset();
	local lastDisplayedOffset = 0;

	for i = 1, buttonCount do
		local listIndex = offset + i;
		local button = buttons[i];

		if listIndex <= numResults then
			button:Populate(listIndex);
			button:Show();
			lastDisplayedOffset = i;
		else
			button:Hide();
		end		
	end
	
	local numDisplayed = math.min(buttonCount, numResults);
	local buttonHeight = buttons[1]:GetHeight();
	local displayedHeight = numDisplayed * buttonHeight;
	local totalHeight = numResults * buttonHeight;
	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight);

	self:UpdatedSelectedHighlight();

	if self.refreshCallback ~= nil then
		self.refreshCallback(lastDisplayedOffset);
	end
end
