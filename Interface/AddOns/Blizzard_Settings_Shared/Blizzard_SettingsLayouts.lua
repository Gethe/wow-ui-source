SettingsLayoutMixin = {};

SettingsLayoutMixin.LayoutType = EnumUtil.MakeEnum("Vertical", "Canvas");

function SettingsLayoutMixin:Init(layoutType)
	self.layoutType = layoutType;
end

function SettingsLayoutMixin:GetLayoutType()
	return self.layoutType;
end

function SettingsLayoutMixin:IsVerticalLayout()
	return self:GetLayoutType() == SettingsLayoutMixin.LayoutType.Vertical;
end

local SettingsVerticalLayoutMixin = CreateFromMixins(SettingsLayoutMixin);

function SettingsVerticalLayoutMixin:Init()
	SettingsLayoutMixin.Init(self, SettingsLayoutMixin.LayoutType.Vertical)
	
	self.initializers = {};
end

function SettingsVerticalLayoutMixin:GetInitializers()
	return self.initializers;
end

function SettingsVerticalLayoutMixin:IsEmpty()
	return #self.initializers == 0;
end

function SettingsVerticalLayoutMixin:AddInitializer(initializer)
	table.insert(self.initializers, initializer);
	return initializer;
end

function SettingsVerticalLayoutMixin:AddMirroredInitializer(initializer)
	if not initializer then
		-- If initializer is nil it probably means the base setting doesn't exist in this game mode
		return;
	end

	initializer:SetSearchIgnoredInLayout(self);
	return self:AddInitializer(initializer);
end

function SettingsVerticalLayoutMixin:EnumerateInitializers()
	local iterator, tbl, index = next, self.initializers, nil;
	local function Iterator(_, index)
		return securecallfunction(iterator, tbl, index);
	end

	return Iterator, nil, index;
end

function CreateVerticalLayout()
	return CreateAndInitFromMixin(SettingsVerticalLayoutMixin);
end

local SettingsCanvasLayoutMixin = CreateFromMixins(SettingsLayoutMixin);

function SettingsCanvasLayoutMixin:Init(frame)
	SettingsLayoutMixin.Init(self, SettingsLayoutMixin.LayoutType.Canvas);
	self.frame = frame;
	self.anchorPoints = {};
end

function SettingsCanvasLayoutMixin:GetFrame()
	return self.frame;
end

function SettingsCanvasLayoutMixin:AddAnchorPoint(p, x, y)
	table.insert(self.anchorPoints, {p=p, x=x, y=y});
end

function SettingsCanvasLayoutMixin:GetAnchorPoints()
	return self.anchorPoints;
end

function CreateCanvasLayout(frame)
	return CreateAndInitFromMixin(SettingsCanvasLayoutMixin, frame);
end