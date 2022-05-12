ScrollBoxViewMixin = CreateFromMixins(ScrollDirectionMixin);

ScrollBoxViewMixin.FrameLevelPolicy =
{
	Ascending = 1,
	Descending = 2,
};

function ScrollBoxViewMixin:GetFrameLevelPolicy()
	return self.frameLevelPolicy or ScrollBoxViewMixin.FrameLevelPolicy.Ascending;
end

function ScrollBoxViewMixin:SetFrameLevelPolicy(frameLevelPolicy)
	self.frameLevelPolicy = frameLevelPolicy;
end

function ScrollBoxViewMixin:Init()
	self.frames = {};
end

function ScrollBoxViewMixin:SetPadding(padding)
	self.padding = padding;
end

function ScrollBoxViewMixin:GetPadding()
	return self.padding;
end

function ScrollBoxViewMixin:SetPanExtent(panExtent)
	self.panExtent = panExtent;
end

function ScrollBoxViewMixin:SetScrollBox(scrollBox)
	self.scrollBox = scrollBox;

	local scrollTarget = scrollBox:GetScrollTarget();
	scrollTarget:ClearAllPoints();
	scrollTarget:SetPoint("TOPLEFT");
	scrollTarget:SetPoint(self:IsHorizontal() and "BOTTOMLEFT" or "TOPRIGHT");
end

function ScrollBoxViewMixin:GetScrollBox()
	return self.scrollBox;
end

function ScrollBoxViewMixin:IsExtentValid()
	return self.extent and self.extent > 1;
end

function ScrollBoxViewMixin:SetExtent(extent)
	self.extent = extent;
end

function ScrollBoxViewMixin:GetScrollTarget()
	return self:GetScrollBox():GetScrollTarget();
end

-- Some views cannot correctly layout or calculate extents until after the scroll target has changed size
-- because they depend on valid scroll target dimensions (grid view). It's also possible for the scroll target rect
-- to be invalidated if the scroll box anchors are changed.
function ScrollBoxViewMixin:RequiresFullUpdateOnScrollTargetSizeChange()
	return false;
end

function ScrollBoxViewMixin:GetFrames()
	return self.frames or {};
end

function ScrollBoxViewMixin:FindFrame(elementData)
	return self:FindFrameByPredicate(function(frame)
		return frame:GetElementData() == elementData;
	end);
end

function ScrollBoxViewMixin:FindFrameByPredicate(predicate)
	for index, frame in ipairs(self:GetFrames()) do
		if predicate(frame) then
			return frame;
		end
	end
	return nil;
end
