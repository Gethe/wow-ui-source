----------------- Base Room Component Dropdown -----------------
HousingRoomComponentOptionMixin = {};

function HousingRoomComponentOptionMixin:OnLoad()
	if self.labelText then
		self.SwitchLabel:SetText(self.labelText);
	end
end

function HousingRoomComponentOptionMixin:SetRoomComponentInfo(roomComponentInfo)
	local supportsComponent, newLabel = self:GetSupportsComponent(roomComponentInfo);

	if supportsComponent then
		self.roomComponentInfo = roomComponentInfo;
		self.roomGUID = roomComponentInfo.roomGUID;
		self.componentID = roomComponentInfo.componentID;
		if newLabel then
			self.SwitchLabel:SetText(newLabel);
		end

		self:UpdateDropdown();

		self:Show();
	else
		self:ClearRoomComponentInfo();
		self:Hide();
	end
end

function HousingRoomComponentOptionMixin:ClearRoomComponentInfo()
	self.roomComponentInfo = nil;
	self.roomGUID = nil;
	self.componentID = nil;
end

function HousingRoomComponentOptionMixin:AddRecents(rootDescription, AddButton, recentEntries)
	if #recentEntries > 0 then
		rootDescription:CreateTitle(HOUSING_DECOR_CUSTOMIZATION_RECENTLY_USED_SHORT);
		for _, entry in ipairs(recentEntries) do
			AddButton(entry);
		end
		rootDescription:CreateDivider();
	end
end

function HousingRoomComponentOptionMixin:PlaySelectedSound()
	PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_APPLY_ROOM_CHANGE);
end

function HousingRoomComponentOptionMixin:UpdateDropdown()
	-- Required to override
	assert(true);
end

-- Returns whether option supports the passed component, and if it does, an optional component-specific label to use
function HousingRoomComponentOptionMixin:GetSupportsComponent(roomComponentInfo)
	-- Required to override
	assert(true);
end

----------------- Theme Dropdown -----------------

HousingRoomComponentThemeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentThemeMixin:GetSupportsComponent(roomComponentInfo)
	local labelByType = {
		[Enum.HousingRoomComponentType.Ceiling] = HOUSING_DECOR_CUSTOMIZATION_THEME_LABEL_CEILING,
		[Enum.HousingRoomComponentType.Wall] = HOUSING_DECOR_CUSTOMIZATION_THEME_LABEL_WALL,
		[Enum.HousingRoomComponentType.Stairs] = HOUSING_DECOR_CUSTOMIZATION_THEME_LABEL_STAIRS,
	};
	
	local labelForType = labelByType[roomComponentInfo.type];
	if labelForType and TableHasAnyEntries(roomComponentInfo.availableThemeSets) then
		return true, labelForType;
	end

	return false, nil;
end

function HousingRoomComponentThemeMixin:UpdateDropdown()
	local function ThemeFromID(themeSetID)
		local name = C_HousingCustomizeMode.GetThemeSetInfo(themeSetID);
		return name and {id = themeSetID, name = name} or nil;
	end

	local themeSets = {};
	for _, themeSetID in ipairs(self.roomComponentInfo.availableThemeSets) do
		local theme = ThemeFromID(themeSetID);
		if theme then
			table.insert(themeSets, theme);
		end
	end
	--TODO: incporporate ownership when ownership is implemented.
	table.sort(themeSets, function(a, b) return a.name < b.name end);

	local recentThemeSets = {};
	for _, recentThemeSetID in ipairs_reverse(C_HousingCustomizeMode.GetRecentlyUsedThemeSets()) do
		local recentTheme = ThemeFromID(recentThemeSetID);
		if recentTheme then
			table.insert(recentThemeSets, recentTheme);
		end
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(theme)
			return theme.id == self.roomComponentInfo.currentThemeSet;
		end

		local function SetSelected(theme)
			if not IsSelected(theme) then
				self:PlaySelectedSound();
			end

			C_HousingCustomizeMode.ApplyThemeToSelectedRoomComponent(theme.id);
		end

		local function AddButton(theme)
			if theme then
				rootDescription:CreateHighlightRadio(theme.name, IsSelected, SetSelected, theme);
			end
		end

		self:AddRecents(rootDescription, AddButton, recentThemeSets);

		for _, theme in ipairs(themeSets) do
			AddButton(theme)
		end
	end);
end

----------------- Wallpaper Dropdown -----------------

HousingRoomComponentWallpaperMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentWallpaperMixin:GetSupportsComponent(roomComponentInfo)
	local labelByType = {
		[Enum.HousingRoomComponentType.Ceiling] = HOUSING_DECOR_CUSTOMIZATION_WALLPAPER_LABEL_CEILING,
		[Enum.HousingRoomComponentType.Wall] = HOUSING_DECOR_CUSTOMIZATION_WALLPAPER_LABEL_WALL,
		[Enum.HousingRoomComponentType.Floor] = HOUSING_DECOR_CUSTOMIZATION_WALLPAPER_LABEL_FLOOR,
		[Enum.HousingRoomComponentType.Stairs] = HOUSING_DECOR_CUSTOMIZATION_WALLPAPER_LABEL_STAIRS
	};
	
	local labelForType = labelByType[roomComponentInfo.type];
	if labelForType then
		local wallpapers = C_HousingCustomizeMode.GetWallpapersForRoomComponentType(roomComponentInfo.type);
		if wallpapers and #wallpapers > 0 then
			return true, labelForType;
		end
	end

	return false, nil;
end

function HousingRoomComponentWallpaperMixin:UpdateDropdown()
	local wallpapers = C_HousingCustomizeMode.GetWallpapersForRoomComponentType(self.roomComponentInfo.type);

	local wallpapersByID = {};
	for _, wallpaper in ipairs(wallpapers) do
		wallpapersByID[wallpaper.roomComponentTextureRecID] = wallpaper;
	end
	--TODO: incporporate ownership when ownership is implemented.
	table.sort(wallpapers, function(a, b) return a.name < b.name end);

	local recentWallpapers = {};
	for _, recentWallpaperID in ipairs_reverse(C_HousingCustomizeMode.GetRecentlyUsedWallpapers()) do
		table.insert(recentWallpapers, wallpapersByID[recentWallpaperID]);
	end

	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(wallpaper)
			return wallpaper.roomComponentTextureRecID == self.roomComponentInfo.currentRoomComponentTextureRecID;
		end

		local function SetSelected(wallpaper)
			if not IsSelected(wallpaper) then
				self:PlaySelectedSound();
			end

			C_HousingCustomizeMode.ApplyWallpaperToSelectedRoomComponent(wallpaper.roomComponentTextureRecID);
		end

		local function AddButton(wallpaper)
			if wallpaper then
				rootDescription:CreateHighlightRadio(wallpaper.name, IsSelected, SetSelected, wallpaper);
			end
		end

		self:AddRecents(rootDescription, AddButton, recentWallpapers);

		for _, wallpaper in ipairs(wallpapers) do
			AddButton(wallpaper);
		end
	end);
end

----------------- Ceiling Type Dropdown -----------------

HousingRoomComponentCeilingTypeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentCeilingTypeMixin:GetSupportsComponent(roomComponentInfo)
	-- Only supports ceilings, no special labels needed
	-- And only supports ceilings for rooms with a matching vaulted ceiling component
	if roomComponentInfo.type == Enum.HousingRoomComponentType.Ceiling then
		local canVault = C_HousingCustomizeMode.RoomComponentSupportsVariant(roomComponentInfo.componentID, Enum.HousingRoomComponentCeilingType.Vaulted);
		return canVault, nil;
	else
		return false, nil;
	end
end

function HousingRoomComponentCeilingTypeMixin:UpdateDropdown()
	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(ceilingType)
			return ceilingType == self.roomComponentInfo.ceilingType;
		end

		local function SetSelected(ceilingType)
			if not IsSelected(ceilingType) then
				self:PlaySelectedSound();
			end

			C_HousingCustomizeMode.SetRoomComponentCeilingType(self.roomComponentInfo.roomGUID, self.roomComponentInfo.componentID, ceilingType);
		end

		rootDescription:CreateHighlightRadio(HOUSING_DECOR_CUSTOMIZATION_NOT_VAULTED_LABEL, IsSelected, SetSelected, Enum.HousingRoomComponentCeilingType.Flat);
		rootDescription:CreateHighlightRadio(HOUSING_DECOR_CUSTOMIZATION_VAULTED_LABEL, IsSelected, SetSelected, Enum.HousingRoomComponentCeilingType.Vaulted);
	end);
end

----------------- Door Type Dropdown -----------------

HousingRoomComponentDoorTypeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentDoorTypeMixin:GetSupportsComponent(roomComponentInfo)
	-- Only supports walls that are already some kind of door, no special labels needed
	local isDoorComponent = roomComponentInfo.type == Enum.HousingRoomComponentType.Wall and roomComponentInfo.doorType ~= Enum.HousingRoomComponentDoorType.None;
	return isDoorComponent, nil;
end

function HousingRoomComponentDoorTypeMixin:UpdateDropdown()
	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		local function IsSelected(doorType)
			return doorType == self.roomComponentInfo.doorType;
		end

		local function SetSelected(doorType)
			if not IsSelected(doorType) then
				self:PlaySelectedSound();
			end

			C_HousingCustomizeMode.SetRoomComponentDoorType(self.roomComponentInfo.roomGUID, self.roomComponentInfo.componentID, doorType);
		end

		rootDescription:CreateHighlightRadio(HOUSING_DECOR_CUSTOMIZATION_NORMAL_DOOR_LABEL, IsSelected, SetSelected, Enum.HousingRoomComponentDoorType.Doorway);
		rootDescription:CreateHighlightRadio(HOUSING_DECOR_CUSTOMIZATION_WIDE_DOOR_LABEL, IsSelected, SetSelected, Enum.HousingRoomComponentDoorType.Threshold);
	end);
end

----------------- Base Apply All Button -----------------

HousingRoomComponentApplyToAllButtonMixin = CreateFromMixins(UIButtonMixin);

function HousingRoomComponentApplyToAllButtonMixin:OnEnter()
	self.HoverIcon:Show();
	UIButtonMixin.OnEnter(self);
end

function HousingRoomComponentApplyToAllButtonMixin:OnLeave()
	self.HoverIcon:Hide();
	UIButtonMixin.OnLeave(self);
end

----------------- Full Options Pane -----------------

RoomComponentPaneMixin = {};

function RoomComponentPaneMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", function() 
		self:Hide();
	end);

	self.ApplyThemeToRoomButton:SetOnClickHandler(function()
		C_HousingCustomizeMode.ApplyThemeToRoom(self.roomComponentInfo.currentThemeSet);
	end);

	self.ApplyWallpaperToAllWallsButton:SetOnClickHandler(function()
		C_HousingCustomizeMode.ApplyWallpaperToAllWalls(self.roomComponentInfo.currentRoomComponentTextureRecID);
	end);
end

function RoomComponentPaneMixin:OnHide()
	C_HousingCustomizeMode.ClearTargetRoomComponent();
	PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_CANCEL);
end

local supportedComponentTypeLabels = {
	[Enum.HousingRoomComponentType.Wall] = {
		tooltipLabel = HOUSING_DECOR_CUSTOMIZATION_LABEL_WALL,
		editLabel = HOUSING_DECOR_CUSTOMIZATION_OPTIONS_LABEL_WALL,
	},
	[Enum.HousingRoomComponentType.Floor] = {
		tooltipLabel = HOUSING_DECOR_CUSTOMIZATION_LABEL_FLOOR,
		editLabel = HOUSING_DECOR_CUSTOMIZATION_OPTIONS_LABEL_FLOOR,
	},
	[Enum.HousingRoomComponentType.Ceiling] = {
		tooltipLabel = HOUSING_DECOR_CUSTOMIZATION_LABEL_CEILING,
		editLabel = HOUSING_DECOR_CUSTOMIZATION_OPTIONS_LABEL_CEILING,
	},
	[Enum.HousingRoomComponentType.Stairs] = {
		tooltipLabel = HOUSING_DECOR_CUSTOMIZATION_LABEL_STAIRS,
		editLabel = HOUSING_DECOR_CUSTOMIZATION_OPTIONS_LABEL_STAIRS,
	},
};

function RoomComponentPaneMixin:TryGetRoomComponentTooltipLabel(roomComponentInfo)
	local labelInfo = roomComponentInfo and supportedComponentTypeLabels[roomComponentInfo.type] or nil;
	return labelInfo and labelInfo.tooltipLabel or nil;
end

function RoomComponentPaneMixin:SupportsRoomComponent(roomComponentInfo)
	return roomComponentInfo and supportedComponentTypeLabels[roomComponentInfo.type] ~= nil;
end

function RoomComponentPaneMixin:SetRoomComponentInfo(roomComponentInfo)
	local labelInfo = roomComponentInfo and supportedComponentTypeLabels[roomComponentInfo.type] or nil;
	if not labelInfo then
		self:ClearRoomComponentInfo();
		self:Hide();
		return;
	end

	self.HeaderLabel:SetText(labelInfo.editLabel);

	self.roomComponentInfo = roomComponentInfo;
	self.roomGUID = roomComponentInfo.roomGUID;
	self.componentID = roomComponentInfo.componentID;
	self.appliedTheme = roomComponentInfo.currentTheme;

	self:ForEachDropdown(function(dropdown)
		dropdown:SetRoomComponentInfo(roomComponentInfo);
	end);

	self.ApplyThemeToRoomButton:SetShown(self.ThemeDropdown:IsShown());

	local isCustomizingWall = roomComponentInfo.type == Enum.HousingRoomComponentType.Wall;
	self.ApplyWallpaperToAllWallsButton:SetShown(isCustomizingWall);
	self.WallWarning:SetShown(isCustomizingWall);

	self:Layout();
end

function RoomComponentPaneMixin:ForEachDropdown(fn)
	for _,dropdown in ipairs(self.dropdowns) do
		fn(dropdown);
	end
end

function RoomComponentPaneMixin:ClearRoomComponentInfo()
	self.roomComponentInfo = nil;
	self.roomGUID = nil;
	self.componentID = nil;
	self:ForEachDropdown(function(dropdown)
		dropdown:ClearRoomComponentInfo();
	end);
end
