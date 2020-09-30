
-- TODO:: Currently we're use a base-level scroll frame with no hybrid scroll behavior. Ideally we
-- should refactor this to use more frame re-use like a hybrid scroll frame. Inherited frames should
-- not rely on the current behavior.


GridListElementMixin = {};

function GridListElementMixin:GetList()
	local scrollChild = self:GetParent();
	return scrollChild:GetParent();
end


GridListMixin = {};

function GridListMixin:OnLoad()
	ScrollFrame_OnLoad(self);
end

function GridListMixin:SetLayout(layout)
	if self.layout ~= nil then
		return;
	end

	self.layout = layout;
end

function GridListMixin:CanInitialize()
	return true;
end

function GridListMixin:InitializeList()
	-- Elements are generated on demand.
	self.elements = {};
end

function GridListMixin:GetNumElementFrames()
	return #self.elements;
end

function GridListMixin:GetElementFrame(frameIndex)
	return self.elements[frameIndex];
end

function GridListMixin:GetListOffset()
	-- This is using a non-hybrid scroll frame, so right now there's no separate offset other than the scroll bar.
	return 0;
end

function GridListMixin:ResetDisplay()
	ScrollFrame_SetScrollOffset(self, 0);
end

function GridListMixin:CanDisplay()
	if self.layout == nil then
		return false, "Templated list layout not set. Use GridListMixin:SetLayout.";
	end

	return TemplatedListMixin.CanDisplay(self);
end

function GridListMixin:RefreshListDisplay()
	if not self:IsVisible() then
		return;
	end

	local template = self:GetElementTemplate();
	local function GridListFactoryFunction(index)
		if index > #self.elements then
			local newFrame = CreateFrame("BUTTON", nil, self.ScrollChild, template);

			-- Because these are created on demand, they need to be initialized here instead of the usual initialization pass.
			newFrame:InitElement(self:GetElementInitializationArgs());

			table.insert(self.elements, newFrame);
		end

		return self.elements[index];
	end

	local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self.ScrollChild, "TOPLEFT");
	AnchorUtil.GridLayoutFactoryByCount(GridListFactoryFunction, self.getNumResultsFunction(), initialAnchor, self.layout);

	TemplatedListMixin.RefreshListDisplay(self);
end
