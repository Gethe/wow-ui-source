
PagedListMixin = CreateFromMixins(CallbackRegistryMixin);

PagedListMixin:GenerateCallbackEvents(
{
	"ListRefreshed",
});

function PagedListMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
end

function PagedListMixin:OnMouseWheel(delta)
	self:ChangePage((delta > 0) and -1 or 1);
end

function PagedListMixin:SetLayout(layout, numElements)
	self.layout = layout;
	self.numElements = numElements;

	if self:IsInitialized() then
		self:LayoutList();
	end
end

function PagedListMixin:CanInitialize()
	return (self.layout ~= nil) and (self.numElements ~= nil);
end

function PagedListMixin:InitializeList()
	self.page = 1;
	self.elements = {};
	self:LayoutList();
end

function PagedListMixin:LayoutList()
	local template = self:GetElementTemplate();
	local function PagedListFactoryFunction(index)
		if index <= #self.elements then
			return self.elements[index];
		end

		local newFrame = CreateFrame("BUTTON", nil, self, template);
		table.insert(self.elements, newFrame);
		return newFrame;
	end

	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT");
	AnchorUtil.GridLayoutFactoryByCount(PagedListFactoryFunction, self.numElements, initialAnchor, self.layout);
end

function PagedListMixin:GetNumElementFrames()
	return #self.elements;
end

function PagedListMixin:GetElementFrame(frameIndex)
	return self.elements[frameIndex];
end

function PagedListMixin:GetListOffset()
	return self:GetNumElementFrames() * (self:GetPage() - 1);
end

function PagedListMixin:ResetDisplay()
	self:SetPage(1);
end

function PagedListMixin:SetPage(pageIndex)
	self.page = pageIndex;
	self:RefreshListDisplay();
end

function PagedListMixin:GetPage()
	return self.page;
end

function PagedListMixin:GetLastPage()
	return math.ceil(self.getNumResultsFunction() / self:GetNumElementFrames());
end

function PagedListMixin:ChangePage(pageAdjustment)
	local currentPage = self:GetPage();
	local lastPage = self:GetLastPage();
	local newPage = Clamp(currentPage + pageAdjustment, 1, lastPage);
	if newPage ~= currentPage then
		self:SetPage(newPage);
	end
end

function PagedListMixin:CanDisplay()
	if (self.layout == nil) or (self.numElements == nil) then
		return false, "Templated list layout not set. Use PagedListMixin:SetLayout.";
	end

	return TemplatedListMixin.CanDisplay(self);
end

function PagedListMixin:RefreshListDisplay()
	TemplatedListMixin.RefreshListDisplay(self);

	self:TriggerEvent(PagedListMixin.Event.ListRefreshed);
end


PagedListControlButtonMixin = {};

function PagedListControlButtonMixin:OnClick()
	self:GetParent():ChangePage(self.pageAdjustment);
end

function PagedListControlButtonMixin:OnMouseWheel(...)
	self:GetParent():OnMouseWheel(...);
end


PagedListControlMixin = {};

function PagedListControlMixin:OnShow()
	self.pagedList:RegisterCallback(PagedListMixin.Event.ListRefreshed, self.OnListRefreshed, self);
	self:RefreshPaging();
end

function PagedListControlMixin:OnHide()
	self.pagedList:UnregisterCallback(PagedListMixin.Event.ListRefreshed, self);
end

function PagedListControlMixin:OnMouseWheel(...)
	self:GetPagedList():OnMouseWheel(...);
end

function PagedListControlMixin:SetPagedList(pagedList)
	if self.pagedList ~= nil then
		return;
	end

	self.pagedList = pagedList;
end

function PagedListControlMixin:GetPagedList()
	return self.pagedList;
end

function PagedListControlMixin:OnListRefreshed()
	self:RefreshPaging();
end

function PagedListControlMixin:RefreshPaging()
	local pagedList = self:GetPagedList();
	local currentPage = pagedList:GetPage();
	local lastPage = pagedList:GetLastPage();

	self.ForwardButton:SetEnabled(currentPage ~= lastPage);
	self.BackwardButton:SetEnabled(currentPage ~= 1);

	-- Hide the control with alpha so we stay registered for event callbacks.
	local shouldBeHidden = not self.alwaysShow and (lastPage == 1);
	self:SetAlpha(shouldBeHidden and 0 or 1);
	if shouldBeHidden then
		return;
	end

	self.PageText:SetText(PAGED_LIST_PAGING_FORMAT:format(currentPage, lastPage));

	self:MarkDirty();
end

function PagedListControlMixin:ChangePage(pageAdjustment)
	self:GetPagedList():ChangePage(pageAdjustment);
end
