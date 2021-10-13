
TemplatedListElementMixin = {};

function TemplatedListElementMixin:InitElement(...)
	-- Override in your mixin.
end

function TemplatedListElementMixin:UpdateDisplay()
	-- Override in your mixin.
	assert("Your templated list element must define a display method");
end

function TemplatedListElementMixin:OnSelected()
	-- Override in your mixin.
end

function TemplatedListElementMixin:OnEnter()
	-- Override in your mixin.
end

function TemplatedListElementMixin:OnLeave()
	-- Override in your mixin.
end

function TemplatedListElementMixin:Populate(listIndex)
	self.listIndex = listIndex;
	self:UpdateDisplay();
end

function TemplatedListElementMixin:OnClick()
	self:GetList():SetSelectedListIndex(self.listIndex);
	self:OnSelected();
end

function TemplatedListElementMixin:IsSelected()
	return self:GetListIndex() == self:GetList():GetSelectedListIndex();
end

function TemplatedListElementMixin:GetListIndex()
	return self.listIndex;
end

function TemplatedListElementMixin:GetList()
	return self:GetParent();
end


TemplatedListMixin = {};

function TemplatedListMixin:SetElementTemplate(elementTemplate, ...)
	if self.elementTemplate ~= nil then
		assert("You cannot change the element template once it is set, as the necessary frames may have already been created from the old template.");
		return;
	end

	self.elementTemplate = elementTemplate;
	self.elementTemplateInitArgs = SafePack(...);
end

function TemplatedListMixin:SetGetNumResultsFunction(getNumResultsFunction)
	self.getNumResultsFunction = getNumResultsFunction;
	self:ResetList();
end

function TemplatedListMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function TemplatedListMixin:SetRefreshCallback(refreshCallback)
	self.refreshCallback = refreshCallback;
end

function TemplatedListMixin:GetSelectedHighlight()
	return self.ArtOverlay.SelectedHighlight;
end

function TemplatedListMixin:OnShow()
	self:CheckListInitialization();
	self:RefreshListDisplay();
end

function TemplatedListMixin:IsInitialized()
	return self.isInitialized;
end

function TemplatedListMixin:CheckListInitialization()
	if self.isInitialized or (self:GetElementTemplate() == nil) or not self:CanInitialize() then
		return;
	end

	self:InitializeList();
	self:InitializeElements();
	
	self.isInitialized = true;
end

function TemplatedListMixin:GetElementTemplate()
	return self.elementTemplate;
end

function TemplatedListMixin:GetElementInitializationArgs()
	return SafeUnpack(self.elementTemplateInitArgs);
end

function TemplatedListMixin:InitializeElements()
	-- We use a local sub-function to capture the variadic parameters and avoid unpacking multiple times.
	local function InitializeAllElementFrames(...)
		for i = 1, self:GetNumElementFrames() do
			self:GetElementFrame(i):InitElement(...);
		end
	end

	InitializeAllElementFrames(self:GetElementInitializationArgs());
end

function TemplatedListMixin:UpdatedSelectedHighlight()
	local selectedHighlight = self:GetSelectedHighlight();
	selectedHighlight:ClearAllPoints();
	selectedHighlight:Hide();

	local selectedListIndex = self:GetSelectedListIndex();
	if self.isInitialized and selectedListIndex ~= nil then
		local elementOffset = selectedListIndex - self:GetListOffset();
		if elementOffset >= 1 and elementOffset <= self:GetNumElementFrames() then
			local elementFrame = self:GetElementFrame(elementOffset);
			self:AttachHighlightToElementFrame(selectedHighlight, elementFrame);
		end
	end
end

function TemplatedListMixin:AttachHighlightToElementFrame(selectedHighlight, elementFrame)
	local elementFrame = self:GetElementFrame(elementOffset);
	selectedHighlight:SetPoint("CENTER", elementFrame, "CENTER", 0, 0);
	selectedHighlight:Show();
end

function TemplatedListMixin:SetSelectedListIndex(listIndex, skipUpdates)
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

	self:RefreshListDisplay();
end

function TemplatedListMixin:GetSelectedListIndex()
	return self.selectedListIndex;
end

function TemplatedListMixin:ResetList()
	if self.isInitialized then
		self:ResetDisplay();
	end
end

function TemplatedListMixin:CanDisplay()
	if self.elementTemplate == nil then
		return false, "Templated list elementTemplate not set. Use TemplatedListMixin:SetElementTemplate.";
	end

	if self.getNumResultsFunction == nil then
		return false, "Templated list getNumResultsFunction not set. Use TemplatedListMixin:SetGetNumResultsFunction.";
	end

	if not self.isInitialized then
		return false, "Templated list has not been initialized. This should generally happen in OnShow.";
	end

	return true, nil;
end

function TemplatedListMixin:RefreshListDisplay()
	if not self:IsVisible() then
		return;
	end

	local canDisplay, displayError = self:CanDisplay();
	if not canDisplay then
		error(displayError);
		return;
	end

	local numResults = self.getNumResultsFunction();
	local lastDisplayedOffset = self:DisplayList(numResults);
	
	self:UpdatedSelectedHighlight();

	if self.refreshCallback ~= nil then
		self.refreshCallback(lastDisplayedOffset);
	end
end

function TemplatedListMixin:DisplayList(numResults)
	local listOffset = self:GetListOffset();
	local numElementFrames = self:GetNumElementFrames();
	local lastDisplayedOffset = 0;

	for i = 1, numElementFrames do
		local listIndex = listOffset + i;
		local elementFrame = self:GetElementFrame(i);

		if listIndex <= numResults then
			elementFrame:Populate(listIndex);
			elementFrame:Show();
			lastDisplayedOffset = i;
		else
			elementFrame:Hide();
		end
	end
	
	return lastDisplayedOffset;
end

function TemplatedListMixin:EnumerateElementFrames()
	local numElementFrames = self:GetNumElementFrames();
	local elementFrameIndex = 0;
	local function ElementFrameIterator()
		elementFrameIndex = elementFrameIndex + 1;

		if elementFrameIndex > numElementFrames then
			return nil;
		end

		return self:GetElementFrame(elementFrameIndex);
	end

	return ElementFrameIterator;
end

function TemplatedListMixin:CanInitialize()
	return true; -- May be implemented by derived mixins.
end

function TemplatedListMixin:InitializeList()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function TemplatedListMixin:GetNumElementFrames()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function TemplatedListMixin:GetElementFrame(frameIndex)
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function TemplatedListMixin:GetListOffset()
	-- Implemented by derived mixins.
	error("This must be implemented for a templated list to function.");
end

function TemplatedListMixin:ResetDisplay()
	-- Implemented by derived mixins.
end
