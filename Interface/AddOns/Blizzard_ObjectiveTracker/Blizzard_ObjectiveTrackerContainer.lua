local settings = {
	-- KeyValues
	-- topModulePadding (0)		: padding between top of the container and the first module, affects contents height
	-- bottomModulePadding (10)	: spacing between last module and the background
	-- moduleSpacing (10)	: spacing between modules
	-- headerText ("")		: text for container's header, if it has one

	-- dynamic
	isCollapsed = false,	-- whether the container is collapsed, not showing any modules	
	needsSorting = false,	-- will be set to true whenever a module is added or removed
	init = false,			-- when a container is first added, it will run Init()
};

ObjectiveTrackerContainerMixin = CreateFromMixins(DirtiableMixin, settings);

function ObjectiveTrackerContainerMixin:OnSizeChanged()
	self:Update();
end

function ObjectiveTrackerContainerMixin:OnShow()
	UIParentManagedFrameMixin.OnShow(self);
	self:UpdateHeight();
end

function ObjectiveTrackerContainerMixin:OnAdded(backgroundAlpha)
	if not self.init then
		self.init = true;
		self:Init();
	end
	self:SetBackgroundAlpha(backgroundAlpha);
end

function ObjectiveTrackerContainerMixin:Init()
	if self.Header then
		self.Header.Text:SetText(self.headerText);
	end
end

function ObjectiveTrackerContainerMixin:GetAvailableHeight()
	return self:GetHeight() - self.topModulePadding;
end

function ObjectiveTrackerContainerMixin:Update(dirtyUpdate)
	if not self.modules then
		return;
	end

	if self.needsSorting then
		table.sort(self.modules, function(lhs, rhs)
			return lhs.uiOrder < rhs.uiOrder;
		end);
		self.needsSorting = false;
	end

	local prevModule = nil;
	local availableHeight = self:GetAvailableHeight();
	local contentsHeight = 0;
	
	-- first update the modules with priority
	for i, module in ipairs(self.modules) do
		if module.hasDisplayPriority then
			local heightUsed, isTruncated = module:Update(availableHeight, dirtyUpdate);
			if isTruncated then
				availableHeight = 0;
			elseif heightUsed > 0 then
				availableHeight = availableHeight - heightUsed;
			end
		end
	end

	for i, module in ipairs(self.modules) do
		if not module.hasDisplayPriority then
			module:Update(availableHeight, dirtyUpdate);
		end
		local heightUsed = module:GetContentsHeight();
		if heightUsed > 0 then
			if not module.hasDisplayPriority then
				availableHeight = availableHeight - heightUsed;
			end
			module:ClearAllPoints();
			if prevModule then
				module:SetPoint("TOP", prevModule, "BOTTOM", 0, -self.moduleSpacing);
				module:SetPoint("LEFT", self, "LEFT", module.leftMargin, 0);
				contentsHeight = contentsHeight + heightUsed + self.moduleSpacing;
			else
				module:SetPoint("TOP", 0, -self.topModulePadding);
				module:SetPoint("LEFT", self, "LEFT", module.leftMargin, 0);
				contentsHeight = contentsHeight + heightUsed;
			end
			prevModule = module;
		end
		if module:IsTruncated() then
			availableHeight = 0;
		end
	end

	if prevModule then
		self.NineSlice:SetPoint("BOTTOM", prevModule, "BOTTOM", 0, -self.bottomModulePadding);
		self.NineSlice:Show();
		local wasShown = self.Header:IsShown();
		self:Show();
	else
		self:Hide();
	end

	if self:IsInDefaultPosition() then
		UIParent_ManageFramePositions();
	end	
end

function ObjectiveTrackerContainerMixin:AddModule(module)
	-- init on first module added
	if not self.modules then
		self.modules = { };
		local dirtyUpdate = true;
		self:SetDirtyMethod(GenerateClosure(self.Update, self, dirtyUpdate));
	end

	if self:HasModule(module) then
		return;
	end

	table.insert(self.modules, module);
	self.needsSorting = true;
	module:SetContainer(self);
	self:MarkDirty();
end

function ObjectiveTrackerContainerMixin:RemoveModule(module)
	if self:HasModule(module) then
		tDeleteItem(self.modules, module);
		self.needsSorting = true;
		self:MarkDirty();
	end
end

function ObjectiveTrackerContainerMixin:HasModule(module)
	return tContains(self.modules, module);
end

function ObjectiveTrackerContainerMixin:GetHeightToModule(targetModule)
	if not self:HasModule(targetModule) then
		return 0;
	end

	local height = self.topModulePadding;

	for i, module in ipairs(self.modules) do
		if module == targetModule then
			break;
		end
		local moduleHeight = module:GetContentsHeight();
		if moduleHeight > 0 and height > 0 then
			height = height + self.moduleSpacing;
		end
		height = height + moduleHeight;
	end

	return height;
end

function ObjectiveTrackerContainerMixin:SetBackgroundAlpha(alpha)
	self.NineSlice:SetAlpha(alpha);
end

function ObjectiveTrackerContainerMixin:ToggleCollapsed()
	self:SetCollapsed(not self:IsCollapsed());
end

function ObjectiveTrackerContainerMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
	-- update the header
	self.Header:SetCollapsed(collapsed);
	-- update contents
	self:Update();
end

function ObjectiveTrackerContainerMixin:IsCollapsed()
	return self.isCollapsed;
end

function ObjectiveTrackerContainerMixin:UpdateHeight()
	if not self:IsInDefaultPosition() then
		local height = 0;
		if self.modules then
			for i, module in ipairs(self.modules) do
				if module.mustFit then
					height = height + module:GetContentsHeight();
				end
			end
		end

		local newHeight = math.max(self.editModeHeight or 800, height);
		self:SetHeight(newHeight);
		return;
	end

	local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(1);
	if offsetY then
		local parentHeight = self:GetParent():GetHeight();
		local setHeight = parentHeight + offsetY;
		setHeight = math.max(setHeight, 20);
		self:SetHeight(setHeight);
	end
end

function ObjectiveTrackerContainerMixin:ForceExpand()
	if self:IsCollapsed() then
		self:ToggleCollapsed();
	end
end

-- *****************************************************************************************************
-- ***** HEADER
-- *****************************************************************************************************

ObjectiveTrackerContainerHeaderMixin = {};

function ObjectiveTrackerContainerHeaderMixin:OnLoad()
	self.MinimizeButton:SetScript("OnClick", GenerateClosure(self.OnToggle, self));
	local collapsed = false;
	self:SetCollapsed(collapsed);
end

function ObjectiveTrackerContainerHeaderMixin:OnToggle()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	-- container is in charge of state
	local container = self:GetParent();
	container:ToggleCollapsed();
end

function ObjectiveTrackerContainerHeaderMixin:SetCollapsed(collapsed)
	local normalTexture = self.MinimizeButton:GetNormalTexture();
	local pushedTexture = self.MinimizeButton:GetPushedTexture();

	if collapsed then
		normalTexture:SetAtlas("ui-questtrackerbutton-expand-all", true);
		pushedTexture:SetAtlas("ui-questtrackerbutton-expand-all-pressed", true);
	else
		normalTexture:SetAtlas("ui-questtrackerbutton-collapse-all", true);
		pushedTexture:SetAtlas("ui-questtrackerbutton-collapse-all-pressed", true);
	end
end