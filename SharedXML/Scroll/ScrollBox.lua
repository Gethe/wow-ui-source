-- Common event definitions as a work-around for derivation problems with CallbackRegistryMixin.
BaseScrollBoxEvents =
{
	"OnAllowScrollChanged",
	"OnSizeChanged",
	"OnScroll",
	"OnLayout",
};

BaseScrollBoxEvents = CopyValuesAsKeys(BaseScrollBoxEvents);

ScrollBoxConstants =
{
	NoScrollInterpolation = true,
	RetainScrollPosition = true,
	AlignBegin = 0,
	AlignCenter = .5,
	AlignEnd = 1,
	AlignNearest = -1,
	ScrollBegin = MathUtil.Epsilon,
	ScrollEnd = (1 - MathUtil.Epsilon),
};

-- ScrollBoxBaseMixin includes CallbackRegistryMixin but the derived mixins are responsible
-- for generating the events.
ScrollBoxBaseMixin = CreateFromMixins(CallbackRegistryMixin, ScrollControllerMixin);

function ScrollBoxBaseMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	ScrollControllerMixin.OnLoad(self);

	self.scrollInternal = GenerateClosure(self.SetScrollPercentageInternal, self);

	local scrollTarget = self:GetScrollTarget();
	scrollTarget:RegisterCallback(BaseScrollBoxEvents.OnSizeChanged, self.OnScrollTargetSizeChanged, self);

	self.Shadows:SetFrameLevel(scrollTarget:GetFrameLevel() + 2);
	self:GetUpperShadowTexture():SetAtlas(self.upperShadow, TextureKitConstants.UseAtlasSize);
	self:GetLowerShadowTexture():SetAtlas(self.lowerShadow, TextureKitConstants.UseAtlasSize);
end

function ScrollBoxBaseMixin:Init(view)
	self:SetView(view);
	self:ScrollToBegin();
end

function ScrollBoxBaseMixin:SetView(view)
	local oldDataProvider = nil;
	local oldView = self:GetView();
	if oldView then
		oldDataProvider = oldView:GetDataProvider();
		oldView:Flush();
	end

	self.view = view;
	view:SetScrollTarget(self:GetScrollTarget());

	local isHorizontal = view:IsHorizontal();
	self:SetHorizontal(isHorizontal);

	local upperShadowTexture = self:GetUpperShadowTexture();
	upperShadowTexture:ClearAllPoints();
	upperShadowTexture:SetPoint("TOPLEFT");
	upperShadowTexture:SetPoint(isHorizontal and "BOTTOMLEFT" or "TOPRIGHT");

	local lowerShadowTexture = self:GetLowerShadowTexture();
	lowerShadowTexture:ClearAllPoints();
	lowerShadowTexture:SetPoint(isHorizontal and "TOPRIGHT" or "BOTTOMLEFT");
	lowerShadowTexture:SetPoint(isHorizontal and "BOTTOMRIGHT" or "BOTTOMRIGHT");

	if oldDataProvider then
		view:SetDataProvider(oldDataProvider);
	end
end

function ScrollBoxBaseMixin:GetView()
	return self.view;
end

function ScrollBoxBaseMixin:GetScrollTarget()
	return self.ScrollTarget;
end

function ScrollBoxBaseMixin:OnSizeChanged(width, height)
	self:Update();

	self:TriggerEvent("OnSizeChanged", width, height, self:GetVisibleExtentPercentage());
end

function ScrollBoxBaseMixin:QueueUpdate()
	self:SetScript("OnUpdate", self.UpdateImmediately);
end

function ScrollBoxBaseMixin:UpdateImmediately()
	self:SetScript("OnUpdate", nil);
	self:FullUpdate();
end

function ScrollBoxBaseMixin:OnScrollTargetSizeChanged(width, height)
	self:QueueUpdate();
end

function ScrollBoxBaseMixin:SetUpdateLocked(locked)
	self.updateLock = locked;
end

function ScrollBoxBaseMixin:IsUpdateLocked()
	return self.updateLock;
end

function ScrollBoxBaseMixin:FullUpdate()
	local oldScrollOffset = self:GetDerivedScrollOffset();

	local recalculate = true;
	self:GetDerivedExtent(recalculate);

	local scrollRange = self:GetDerivedScrollRange();
	if scrollRange > 0 then
		local deltaScrollOffset = (self:GetDerivedScrollOffset() - oldScrollOffset);
		local scrollPercentage = self:GetScrollPercentage() - (deltaScrollOffset / scrollRange);
		self:SetScrollPercentageInternal(scrollPercentage, ScrollBoxConstants.NoScrollInterpolation);
	else
		self:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
	end
	
	self:SetPanExtentPercentage(self:CalculatePanExtentPercentage());

	local forceLayout = true;
	self:Update(forceLayout);

	self:TriggerEvent(BaseScrollBoxEvents.OnLayout);
end

function ScrollBoxBaseMixin:Layout()
	local view = self:GetView();
	if view then
		self:SetFrameExtent(self:GetScrollTarget(), view:Layout());
	end
end

function ScrollBoxBaseMixin:SetScrollTargetOffset(offset)
	local view = self:GetView();
	if view then
		local scrollTarget = self:GetScrollTarget();
		if self:IsHorizontal() then
			scrollTarget:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, -self:GetTopPadding());
			scrollTarget:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -offset, self:GetBottomPadding());
		else
			scrollTarget:SetPoint("TOPLEFT", self, "TOPLEFT", self:GetLeftPadding(), offset);
			scrollTarget:SetPoint("TOPRIGHT", self, "TOPRIGHT", -self:GetRightPadding(), offset);
		end

		self:TriggerEvent(BaseScrollBoxEvents.OnScroll, self:GetScrollPercentage(), self:GetVisibleExtentPercentage(), self:GetPanExtentPercentage());
		
		self:SetShadowsShown(self:HasScrollableExtent(), self:GetDerivedScrollOffset() > 0);
	end
end

function ScrollBoxBaseMixin:ScrollInDirection(scrollPercentage, direction)
	ScrollControllerMixin.ScrollInDirection(self, scrollPercentage, direction);

	self:Update();
end

function ScrollBoxBaseMixin:ScrollToBegin(noInterpolation)
	self:SetScrollPercentage(0, noInterpolation);
end

function ScrollBoxBaseMixin:ScrollToEnd(noInterpolation)
	self:SetScrollPercentage(1, noInterpolation);
end

function ScrollBoxBaseMixin:IsAtBegin()
	return ApproximatelyEqual(self:GetScrollPercentage(), 0);
end

function ScrollBoxBaseMixin:IsAtEnd()
	return ApproximatelyEqual(self:GetScrollPercentage(), 1);
end

function ScrollBoxBaseMixin:SetScrollPercentage(scrollPercentage, noInterpolation)
	if not ApproximatelyEqual(self:GetScrollPercentage(), scrollPercentage) then
		if not noInterpolation and self:CanInterpolateScroll() then
			self:Interpolate(scrollPercentage, self.scrollInternal);
		else
			self:SetScrollPercentageInternal(scrollPercentage);
		end
	end
end

function ScrollBoxBaseMixin:SetScrollPercentageInternal(scrollPercentage)
	ScrollControllerMixin.SetScrollPercentage(self, scrollPercentage);

	self:Update();
end

function ScrollBoxBaseMixin:GetVisibleExtentPercentage()
	local extent = self:GetExtent();
	if extent > 0 then
		return self:GetVisibleExtent() / extent;
	end
	return 0;
end

function ScrollBoxBaseMixin:GetPanExtent()
	return self:GetView():GetPanExtent();
end

function ScrollBoxBaseMixin:SetPanExtent(panExtent)
	self:GetView():SetPanExtent(panExtent);
end

function ScrollBoxBaseMixin:GetExtent()
	return self:GetFrameExtent(self:GetScrollTarget());
end

function ScrollBoxBaseMixin:GetVisibleExtent()
	return self:GetFrameExtent(self);
end

function ScrollBoxBaseMixin:GetFrames()
	return self:GetView():GetFrames();
end

function ScrollBoxBaseMixin:GetFrameCount()
	return self:GetView():GetFrameCount();
end

function ScrollBoxBaseMixin:FindFrame(elementData)
	return self:GetView():FindFrame(elementData);
end

function ScrollBoxBaseMixin:FindFrameByPredicate(predicate)
	return self:GetView():FindFrameByPredicate(predicate);
end

function ScrollBoxBaseMixin:ScrollToFrame(frame, alignment, noInterpolation)
	local offset = self:SelectPointComponent(frame);
	local frameExtent = self:GetFrameExtent(frame);
	self:ScrollToOffset(offset, frameExtent, alignment, noInterpolation);
end

function ScrollBoxBaseMixin:CalculatePanExtentPercentage()
	local scrollRange = self:GetDerivedScrollRange();
	if scrollRange > 0 then
		return self:GetPanExtent() / scrollRange;
	end
	return 0;
end

function ScrollBoxBaseMixin:CalculateScrollPercentage()
	local scrollRange = self:GetDerivedScrollRange();
	if scrollRange > 0 then
		return self:GetDerivedScrollOffset() / scrollRange;
	end
	return 0;
end

function ScrollBoxBaseMixin:HasScrollableExtent()
	return WithinRangeExclusive(self:GetVisibleExtentPercentage(), 0, 1);
end

function ScrollBoxBaseMixin:SetScrollAllowed(allowScroll)
	local oldAllowScroll = self:IsScrollAllowed();
	ScrollControllerMixin.SetScrollAllowed(self, allowScroll);

	self:Update();

	if oldAllowScroll ~= allowScroll then
		self:TriggerEvent(BaseScrollBoxEvents.OnAllowScrollChanged, allowScroll);
	end
end

function ScrollBoxBaseMixin:GetDerivedScrollRange()
	return math.max(0, self:GetDerivedExtent() - self:GetVisibleExtent());
end

function ScrollBoxBaseMixin:GetDerivedScrollOffset()
	return self:GetDerivedScrollRange() * self:GetScrollPercentage();
end

function ScrollBoxBaseMixin:SetAlignmentOverlapIgnored(ignored)
	self.alignmentOverlapIgnored = ignored;
end

function ScrollBoxBaseMixin:IsAlignmentOverlapIgnored()
	return self.alignmentOverlapIgnored;
end

function ScrollBoxBaseMixin:SanitizeAlignment(alignment, extent)
	if not self:IsAlignmentOverlapIgnored() and extent > self:GetVisibleExtent() then
		return 0;
	end
	
	local centered = .5;
	return alignment and Saturate(alignment) or centered;
end

function ScrollBoxBaseMixin:ScrollToOffset(offset, frameExtent, alignment, noInterpolation)
	alignment = self:SanitizeAlignment(alignment, frameExtent);
	local alignedOffset = offset + (frameExtent * alignment) - (self:GetVisibleExtent() * alignment);
	local scrollRange = self:GetDerivedScrollRange();
	if scrollRange > 0 then
		local scrollPercentage = alignedOffset / scrollRange;
		self:SetScrollPercentage(scrollPercentage, noInterpolation);
	end
end

function ScrollBoxBaseMixin:GetVisibleExtentPercentage()
	local extent = self:GetDerivedExtent();
	if extent > 0 then
		return self:GetVisibleExtent() / extent;
	end
	return 0;
end

function ScrollBoxBaseMixin:GetDerivedExtent(recalculate)
	local view = self:GetView();
	if view then
		return view:GetExtent(recalculate, self);
	end
	return 0;
end

function ScrollBoxBaseMixin:SetPadding(padding)
	self:GetView():SetPadding(padding);
end

function ScrollBoxBaseMixin:GetPadding()
	local view = self:GetView();
	if view then
		return view:GetPadding()
	end
	return nil;
end

function ScrollBoxBaseMixin:GetLeftPadding()
	local padding = self:GetPadding();
	if padding then
		return padding:GetLeft();
	end
	return 0;
end

function ScrollBoxBaseMixin:GetTopPadding()
	local padding = self:GetPadding();
	if padding then
		return padding:GetTop();
	end
	return 0;
end

function ScrollBoxBaseMixin:GetRightPadding()
	local padding = self:GetPadding();
	if padding then
		return padding:GetRight();
	end
	return 0;
end

function ScrollBoxBaseMixin:GetBottomPadding()
	local padding = self:GetPadding();
	if padding then
		return padding:GetBottom();
	end
	return 0;
end

function ScrollBoxBaseMixin:GetUpperPadding()
	if self:IsHorizontal() then
		return self:GetLeftPadding();
	else
		return self:GetTopPadding();
	end
end

function ScrollBoxBaseMixin:GetLowerPadding()
	if self:IsHorizontal() then
		return self:GetRightPadding();
	else
		return self:GetBottomPadding();
	end
end

function ScrollBoxBaseMixin:GetLowerShadowTexture(atlas)
	return self.Shadows.Lower;
end

function ScrollBoxBaseMixin:GetUpperShadowTexture(atlas)
	return self.Shadows.Upper;
end

function ScrollBoxBaseMixin:SetLowerShadowAtlas(atlas, useAtlasSize)
	self:GetLowerShadowTexture():SetAtlas(atlas, useAtlasSize);
end

function ScrollBoxBaseMixin:SetUpperShadowAtlas(atlas, useAtlasSize)
	self:GetUpperShadowTexture():SetAtlas(atlas, useAtlasSize);
end

function ScrollBoxBaseMixin:SetShadowsShown(showLower, showUpper)
	self:GetLowerShadowTexture():SetShown(showLower);
	self:GetUpperShadowTexture():SetShown(showUpper);
end

ScrollBoxListMixin = CreateFromMixins(ScrollBoxBaseMixin);

ScrollBoxListMixin:GenerateCallbackEvents(
	{
		BaseScrollBoxEvents.OnScroll,
		BaseScrollBoxEvents.OnSizeChanged,
		BaseScrollBoxEvents.OnAllowScrollChanged,
		BaseScrollBoxEvents.OnLayout,
		"OnAcquiredFrame",
		"OnReleasedFrame",
		"OnDataRangeChanged",
	}
);

function ScrollBoxListMixin:Init(view)
	self:Flush();

	ScrollBoxBaseMixin.Init(self, view);
end

function ScrollBoxListMixin:SetView(view)
	local oldView = self:GetView();
	if oldView then
		oldView:UnregisterCallback(ScrollBoxListViewMixin.Event.OnDataChanged, self);
		oldView:UnregisterCallback(ScrollBoxListViewMixin.Event.OnAcquiredFrame, self);
		oldView:UnregisterCallback(ScrollBoxListViewMixin.Event.OnReleasedFrame, self);
	end

	ScrollBoxBaseMixin.SetView(self, view);

	view:RegisterCallback(ScrollBoxListViewMixin.Event.OnDataChanged, self.OnViewDataChanged, self);
	view:RegisterCallback(ScrollBoxListViewMixin.Event.OnAcquiredFrame, self.OnViewAcquiredFrame, self);
	view:RegisterCallback(ScrollBoxListViewMixin.Event.OnReleasedFrame, self.OnViewReleasedFrame, self);
end

function ScrollBoxListMixin:Flush()
	local view = self:GetView();
	if view then
		view:Flush();
	end
end

function ScrollBoxListMixin:ForEachFrame(func)
	self:GetView():ForEachFrame(func);
end

function ScrollBoxListMixin:EnumerateFrames()
	return self:GetView():EnumerateFrames();
end

function ScrollBoxListMixin:FindElementDataByPredicate(predicate)
	return self:GetView():FindElementDataByPredicate(predicate);
end

function ScrollBoxListMixin:FindElementDataIndexByPredicate(predicate)
	return self:GetView():FindElementDataIndexByPredicate(predicate);
end

function ScrollBoxListMixin:FindByPredicate(predicate)
	return self:GetView():FindByPredicate(predicate);
end

function ScrollBoxListMixin:Find(index)
	return self:GetView():Find(index);
end

function ScrollBoxListMixin:FindIndex(elementData)
	return self:GetView():FindIndex(elementData);
end

function ScrollBoxListMixin:InsertElementData(...)
	self:GetView():InsertElementData(...);
end

function ScrollBoxListMixin:InsertElementDataTable(tbl)
	self:GetView():InsertElementDataTable(tbl);
end

function ScrollBoxListMixin:InsertElementDataTableRange(tbl, indexBegin, indexEnd)
	self:GetView():InsertElementDataTableRange(tbl, indexBegin, indexEnd);
end

function ScrollBoxListMixin:ContainsElementDataByPredicate(predicate)
	return self:GetView():ContainsElementDataByPredicate(predicate);
end

function ScrollBoxListMixin:GetDataProvider()
	return self:GetView():GetDataProvider();
end

function ScrollBoxListMixin:HasDataProvider()
	return self:GetView():HasDataProvider();
end

function ScrollBoxListMixin:ClearDataProvider()
	self:GetView():ClearDataProvider();
end

function ScrollBoxListMixin:GetDataIndexBegin()
	return self:GetView():GetDataIndexBegin();
end

function ScrollBoxListMixin:GetDataIndexEnd()
	return self:GetView():GetDataIndexEnd();
end

function ScrollBoxListMixin:IsVirtualized()
	return self:GetView():IsVirtualized();
end

function ScrollBoxListMixin:GetElementExtent(dataIndex)
	return self:GetView():GetElementExtent(self, dataIndex);
end

function ScrollBoxListMixin:GetExtentUntil(dataIndex)
	return self:GetView():GetExtentUntil(self, dataIndex);
end

function ScrollBoxListMixin:SetDataProvider(dataProvider, retainScrollPosition)
	local view = self:GetView();
	if not view then
		error("A view is required before assigning the data provider.");
	end

	view:SetDataProvider(dataProvider);

	if not retainScrollPosition then
		self:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
	end
end

function ScrollBoxListMixin:GetDataProviderSize()
	local view = self:GetView();
	if view then
		return view:GetDataProviderSize();
	end
	return 0;
end

function ScrollBoxListMixin:OnViewDataChanged()
	self:UpdateImmediately();
end

function ScrollBoxListMixin:Rebuild()
	self:GetView():Rebuild();
end

function ScrollBoxListMixin:OnViewAcquiredFrame(frame, elementData, new)
	self:TriggerEvent(ScrollBoxListMixin.Event.OnAcquiredFrame, frame, elementData, new);
end

function ScrollBoxListMixin:OnViewReleasedFrame(frame, oldElementData)
	self:TriggerEvent(ScrollBoxListMixin.Event.OnReleasedFrame, frame, oldElementData);
end

function ScrollBoxListMixin:IsAcquireLocked()
	local view = self:GetView();
	return view and view:IsAcquireLocked();
end

function ScrollBoxListMixin:FullUpdate()
	if not self:IsAcquireLocked() then
		ScrollBoxBaseMixin.FullUpdate(self);
	end
end

function ScrollBoxListMixin:Update(forceLayout)
	if self:IsUpdateLocked() or self:IsAcquireLocked() then
		return;
	end
	self:SetUpdateLocked(true);

	local view = self:GetView();
	if view then
		local changed = view:ValidateDataRange(self);
		if changed or forceLayout then
			self:Layout();
		end

		self:SetScrollTargetOffset(self:GetDerivedScrollOffset() - view:GetDataScrollOffset(self));
		self:SetPanExtentPercentage(self:CalculatePanExtentPercentage());
		
		if changed then
			self:TriggerEvent(ScrollBoxListMixin.Event.OnDataRangeChanged);
		end
	end

	self:SetUpdateLocked(false);
end

function ScrollBoxListMixin:ScrollToNearest(dataIndex, noInterpolation)
	local scrollOffset = self:GetDerivedScrollOffset();
	if self:GetExtentUntil(dataIndex) > (scrollOffset + self:GetVisibleExtent()) then
		return self:ScrollToElementDataIndex(dataIndex, ScrollBoxConstants.AlignEnd, noInterpolation);
	elseif self:GetExtentUntil(dataIndex) < scrollOffset then
		return self:ScrollToElementDataIndex(dataIndex, ScrollBoxConstants.AlignBegin, noInterpolation);
	end
	return nil;
end

function ScrollBoxListMixin:ScrollToElementDataIndex(dataIndex, alignment, noInterpolation)
	if alignment == ScrollBoxConstants.AlignNearest then
		return self:ScrollToNearest(dataIndex, noInterpolation);
	else
		local elementData = self:Find(dataIndex);
		if elementData then
			local extent = self:GetExtentUntil(dataIndex);
			local elementExtent = self:GetElementExtent(dataIndex);
			self:ScrollToOffset(extent, elementExtent, alignment, noInterpolation);
			return elementData;
		end
	end
	return nil;
end

function ScrollBoxListMixin:ScrollToElementData(elementData, alignment, noInterpolation)
	local dataIndex = self:FindIndex(elementData);
	if dataIndex then
		return self:ScrollToElementDataIndex(dataIndex, alignment, noInterpolation);
	end
	return nil;
end

function ScrollBoxListMixin:ScrollToElementDataByPredicate(predicate, alignment, noInterpolation)
	if alignment == ScrollBoxConstants.AlignNearest then
		local dataIndex, elementData = self:FindByPredicate(predicate);
		if dataIndex then
			return self:ScrollToNearest(dataIndex, noInterpolation);
		end
	else
		local dataIndex = self:FindElementDataIndexByPredicate(predicate);
		if dataIndex then
			return self:ScrollToElementDataIndex(dataIndex, alignment, noInterpolation);
		end
	end
	
	return nil;
end

ScrollBoxMixin = CreateFromMixins(ScrollBoxBaseMixin);

ScrollBoxMixin:GenerateCallbackEvents(
	{
		BaseScrollBoxEvents.OnScroll,
		BaseScrollBoxEvents.OnSizeChanged,
		BaseScrollBoxEvents.OnAllowScrollChanged,
		BaseScrollBoxEvents.OnLayout,
	}
);

function ScrollBoxMixin:OnLoad()
	ScrollBoxBaseMixin.OnLoad(self);

	if not self.panExtent then
		-- Intended to function, but be apparent it's untuned.
		self.panExtent = 3;
	end
end

function ScrollBoxMixin:SetView(view)
	ScrollBoxBaseMixin.SetView(self, view);
	
	view:ReparentScrollChildren(self:GetChildren());
end

function ScrollBoxMixin:Update(forceLayout)
	if self:IsUpdateLocked() then
		return;
	end
	self:SetUpdateLocked(true);

	if forceLayout then
		self:Layout();
	end

	self:SetScrollTargetOffset(self:GetDerivedScrollOffset());

	self:SetUpdateLocked(false);
end