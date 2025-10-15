DamageMeterWindowMixin = {};

local DamageMeterWindowListEvents = {
	--"DAMAGE_METER_LIST_UPDATE",
};

function DamageMeterWindowMixin:OnLoad()
	self:InitializeScrollBox();
	self:InitializeTrackedStatDropdown();
	self:InitializeSettingsDropdown();
end

function DamageMeterWindowMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DamageMeterWindowListEvents);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterWindowMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DamageMeterWindowListEvents);
end

function DamageMeterWindowMixin:OnEvent(event, ...)
	if event == "DAMAGE_METER_LIST_UPDATE" then
		self:Refresh(ScrollBoxConstants.RetainScrollPosition);
	end
end

function DamageMeterWindowMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterEntryTemplate", function(frame, elementData)
		frame:Init(elementData);

		frame:SetScript("OnClick", function(button, mouseButtonName)
			if mouseButtonName == "LeftButton" then
				self:ShowBreakdownFrame(elementData);
			end
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function DamageMeterWindowMixin:InitializeTrackedStatDropdown()
	local function GetCategories()
		local categoryList =
		{
			{ name = "Damage"; types = {"Damage Done", "DPS"}; },
			{ name = "Healing"; types = {"Healing Done", "HPS"}; },
		};
		return categoryList;
	end

	local categoryList = GetCategories();

	local function IsSelected(option)
		return self:GetTrackedStat() == option;
	end

	local function SetSelected(option)
		self:SetTrackedStat(option);
	end

	self.TrackedStatDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_TRACKED_TYPE");

		for _i, categoryData in ipairs(categoryList) do
			local categorySubmenu = rootDescription:CreateButton(categoryData.name);

			for _j, typeData in ipairs(categoryData.types) do
				categorySubmenu:CreateRadio(typeData, IsSelected, SetSelected, typeData);
			end
		end
	end);
end

function DamageMeterWindowMixin:InitializeSettingsDropdown()
	local function IsCreateNewWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanCreateNewWindowFrame();
	end

	local function IsDeleteWindowFrameEnabled()
		return self:GetDamageMeterOwner():CanDeleteWindowFrame(self);
	end

	self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_DAMAGE_METER_WINDOW_SETTINGS");

		rootDescription:CreateButton("PH - Settings", function(...)
			Settings.OpenToCategory(Settings.ADVANCED_OPTIONS_CATEGORY_ID);
		end);

		rootDescription:CreateButton("PH - Edit Mode", function(...)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ShowUIPanel(EditModeManagerFrame);
		end);

		local createNewWindowFrameButton = rootDescription:CreateButton("PH - Create New Window", function(...)
			self:GetDamageMeterOwner():CreateNewWindowFrame();
		end);
		createNewWindowFrameButton:SetEnabled(IsCreateNewWindowFrameEnabled);

		local deleteWindowFrameButton = rootDescription:CreateButton("PH - Delete Window", function(...)
			self:GetDamageMeterOwner():DeleteWindowFrame(self);
		end);
		deleteWindowFrameButton:SetEnabled(IsDeleteWindowFrameEnabled)
	end);
end

function DamageMeterWindowMixin:GetEntryList()
	local entryList =
	{
		{texture = 135987; maxValue = 100; value = 100; },
		{texture = 132864; maxValue = 100; value = 80; }
	};
	return entryList;
end

function DamageMeterWindowMixin:BuildDataProvider()
	local entryList = self:GetEntryList();

	local dataProvider = CreateDataProvider();
	for i, entryData in ipairs(entryList) do
		entryData.index = i;
		dataProvider:Insert(entryData);
	end

	return dataProvider;
end

function DamageMeterWindowMixin:Refresh(retainScrollPosition)
	self.ScrollBox:SetDataProvider(self:BuildDataProvider(), retainScrollPosition);
end

function DamageMeterWindowMixin:SetDamageMeterOwner(damageMeterOwner, windowFrameIndex)
	self.damageMeterOwner = damageMeterOwner;
	self.windowFrameIndex = windowFrameIndex;
end

function DamageMeterWindowMixin:GetDamageMeterOwner()
	return self.damageMeterOwner;
end

function DamageMeterWindowMixin:GetWindowFrameIndex()
	return self.windowFrameIndex;
end

function DamageMeterWindowMixin:SetTrackedStat(trackedStat)
	self.trackedStat = trackedStat;
end

function DamageMeterWindowMixin:GetTrackedStat()
	return self.trackedStat;
end

function DamageMeterWindowMixin:RefreshLayout()

end

function DamageMeterWindowMixin:ShowBreakdownFrame(elementData)
	self.UnitBreakdownFrame:SetTrackedData(self:GetTrackedStat(), elementData.unit);
	self.UnitBreakdownFrame:AnchorToWindow(self);
	self.UnitBreakdownFrame:Show();
end
