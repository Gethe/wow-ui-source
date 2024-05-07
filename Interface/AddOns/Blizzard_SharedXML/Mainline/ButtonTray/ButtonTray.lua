
BaseButtonTrayMixin = {};

function BaseButtonTrayMixin:OnLoad()
	self:SetFramePoolSetup(self.templateType, self.buttonTemplate);
end

function BaseButtonTrayMixin:SetFramePoolSetup(templateType, buttonTemplate)
	if self.buttonPool then
		self.buttonPool:ReleaseAll();
	end

	self.buttonPool = CreateFramePool(templateType, self, buttonTemplate);
end

function BaseButtonTrayMixin:SetButtonSetup(setupCallback)
	self.buttonSetup = setupCallback;
end

function BaseButtonTrayMixin:AddControl(label, controlCallback, ...)
	if self.buttonSetup ~= nil then
		local newButton = self.buttonPool:Acquire();
		self.buttonSetup(newButton, label, controlCallback, ...);
		newButton:Show();
		return newButton;
	end

	return nil;
end

function BaseButtonTrayMixin:EnumerateControls()
	return self.buttonPool:EnumerateActive();
end


HorizontalButtonTrayMixin = {};

function HorizontalButtonTrayMixin:OnLoad()
	BaseButtonTrayMixin.OnLoad(self);
	self.nextLayoutIndex = 1;
end

function HorizontalButtonTrayMixin:AddControl(label, controlCallback, ...)
	local newButton = BaseButtonTrayMixin.AddControl(self, label, controlCallback, ...);

	if newButton ~= nil then
		newButton.spacing = self.spacing;
		newButton.layoutIndex = self.nextLayoutIndex;
		self.nextLayoutIndex = self.nextLayoutIndex + 1;
		self:MarkDirty();
	end
end


GridButtonTrayMixin = {};

function GridButtonTrayMixin:OnLoad()
	BaseButtonTrayMixin.OnLoad(self);
	self.controls = {};
	self.previousWidth = self:GetWidth();
end

function GridButtonTrayMixin:OnSizeChanged()
	local newWidth = self:GetWidth();
	if newWidth < 2 then
		-- A rather stupid looking early out, but this solves some indirectly circular resize dependencies
		-- with ToolsControlDashboard stuff.
		return;
	end

	local widthEpsilon = 0.1;
	if ApproximatelyEqual(self.previousWidth, newWidth, widthEpsilon) then
		return;
	end

	self.previousWidth = newWidth;
	self:MarkTrayLayoutDirty();
end

function GridButtonTrayMixin:MarkTrayLayoutDirty()
	if self.isTrayLayoutDirty == nil then
		self.isTrayLayoutDirty = true;

		RunNextFrame(GenerateClosure(self.UpdateTrayLayout, self));
	end
end

function GridButtonTrayMixin:IsTrayLayoutDirty()
	return self.isTrayLayoutDirty
end

function GridButtonTrayMixin:AddControl(label, controlCallback, ...)
	local control = BaseButtonTrayMixin.AddControl(self, label, controlCallback, ...);
	if control ~= nil then
		table.insert(self.controls, control);
		self:MarkTrayLayoutDirty();
	end

	return control;
end

function GridButtonTrayMixin:UpdateTrayLayout()
	local layout = GridLayoutUtil.CreateNaturalGridLayout(self.baseWidth or self:GetWidth(), self.xPadding, self.yPadding);

	GridLayoutUtil.ApplyGridLayout(self.controls, AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT"), layout);

	self.isTrayLayoutDirty = nil;

	self:MarkDirty();
end
