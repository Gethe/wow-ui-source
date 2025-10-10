HousingDyePaneMixin = {};

function HousingDyePaneMixin:OnLoad()
	ClickToDragMixin.OnLoad(self);
	self.dyeSlotPool = CreateFramePool("FRAME", self.DyeSlotContainer, "HousingDecorDyeSlotTemplate", HousingDecorDyeSlotMixin.Reset);

	local function CloseDyePane()
		-- This will clear the preview dyes and close this pane by deselecting the decor
		C_HousingCustomizeMode.CancelActiveEditing();
		PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_CANCEL);
	end

	self.ButtonFrame.ApplyButton:SetScript("OnClick", function()
		local anyChanges = C_HousingCustomizeMode.CommitDyesForSelectedDecor();
		if anyChanges then
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_APPLY_CHANGED);
		else
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_APPLY_NO_CHANGE);
		end

		DyeSelectionPopout:SetDyeSlotInfo(DyeSelectionPopout.dyeSlotInfo);
		CloseDyePane();
	end);

	self.ButtonFrame.CancelButton:SetScript("OnClick", CloseDyePane);
	self.CloseButton:SetScript("OnClick", CloseDyePane);

	self.dyeCostIcons = {};
	self.dyeCostFramePool = CreateFramePool("FRAME", self.DyeCostContainer, "HousingDyeCostIconTemplate");
end

function HousingDyePaneMixin:OnShow()
	self.currentChannel = nil;
end

function HousingDyePaneMixin:OnHide()
	DyeSelectionPopout:Hide();
end

function HousingDyePaneMixin:SetDecorInfo(decorInstanceInfo)
	self.decorGUID = decorInstanceInfo.decorGUID;
	self.DecorName:SetText(decorInstanceInfo.name);
	local numDyesToSpend = C_HousingCustomizeMode.GetNumDyesToSpendOnSelectedDecor();
	local numDyesToRemove = C_HousingCustomizeMode.GetNumDyesToRemoveOnSelectedDecor();
	self.DyeRemoveWarning:SetText(numDyesToRemove == 0 and "" or string.format(HOUSING_DECOR_CUSTOMIZATION_REMOVE_DYE_WARNING, numDyesToRemove));

	self.dyeSlotFramesByChannel = {};
	local numDyeSlots = 1;
	for dyeSlotIndex, dyeSlotEntry in ipairs(decorInstanceInfo.dyeSlots) do
		local dyeSlotFrame = self.dyeSlotPool:Acquire();
		dyeSlotFrame.layoutIndex = dyeSlotEntry.orderIndex + 1;

		if numDyeSlots > #self.dyeCostIcons then
			local dyeCostFrame = self.dyeCostFramePool:Acquire();
			table.insert(self.dyeCostIcons, dyeCostFrame);
			local index = #self.dyeCostIcons;
			self.dyeCostIcons[index].layoutIndex = index + 1;
		end

		numDyeSlots = numDyeSlots + 1;

		local function onClickCallback()
			DyeSelectionPopout:SetDyeSlotInfo(dyeSlotEntry);
			DyeSelectionPopout:Show();
			if self.currentChannel then
				self.dyeSlotFramesByChannel[self.currentChannel].CurrentSwatch:UpdateSelected(false);
			end
			self.currentChannel = dyeSlotEntry.channel; 
			self.dyeSlotFramesByChannel[self.currentChannel].CurrentSwatch:UpdateSelected(true);
		end
		dyeSlotFrame:SetDyeSlotInfo(dyeSlotEntry, onClickCallback);
		dyeSlotFrame:Show();
		self.dyeSlotFramesByChannel[dyeSlotEntry.channel] = dyeSlotFrame;
	end

	local canAffordDyes = true;
	local dyesToSpend = self:GetPreviewDyeInfos();
	local dyeCounts = {};
	for i, dyeCostIcon in ipairs(self.dyeCostIcons) do
		local dyeInfo = dyesToSpend[i];
		if dyeInfo then
			dyeCounts[dyeInfo.itemID] = (dyeCounts[dyeInfo.itemID] or 0) + 1;

			local dyeIsValid = dyeCounts[dyeInfo.itemID] <= dyeInfo.numOwned;
			if not dyeIsValid then
				canAffordDyes = false;
			end

			dyeCostIcon:Init(dyeInfo.itemID, dyeInfo.numOwned, not dyeIsValid);
		else
			dyeCostIcon:Hide();
		end
	end

	self.DyeCostContainer:SetShown(#dyesToSpend > 0);
	self.DyeCostContainer:Layout();

	self.ButtonFrame.ApplyButton:SetEnabled((numDyesToRemove > 0 or #dyesToSpend > 0) and canAffordDyes);
	self.ButtonFrame.ApplyButton.disabledTooltip = not canAffordDyes and HOUSING_DECOR_DYE_NOT_ENOUGH_DYE or nil;
end

function HousingDyePaneMixin:UpdateDecorInfo(decorInstanceInfo)
	self.dyeSlotPool:ReleaseAll();
	self.DyeSlotContainer:MarkDirty();
	self:SetDecorInfo(decorInstanceInfo);

	if self.currentChannel then
		local currentFrame = self.dyeSlotFramesByChannel[self.currentChannel];
		DyeSelectionPopout:UpdateDyeSlotInfo(currentFrame.dyeSlotInfo);
		currentFrame.CurrentSwatch:UpdateSelected(true);
	end
end

function HousingDyePaneMixin:GetPreviewDyeInfos()
	if not self.ButtonFrame.CurrentDyeIcons then
		return;
	end
	
	local iconString = "";
	local currentDyes = {};
	local currPreviewDyes = C_HousingCustomizeMode.GetPreviewDyesOnSelectedDecor();
	for _i, dyeColorID in ipairs(currPreviewDyes) do
		local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
		if dyeColorInfo and dyeColorInfo.itemID then
			local itemID = dyeColorInfo.itemID;
			local dyeIcon = C_Item.GetItemIconByID(itemID);
			table.insert(currentDyes, {itemID = itemID, numOwned = dyeColorInfo.numOwned,});
		end
	end
	
	return currentDyes;
end

function HousingDyePaneMixin:ClearDecorInfo()
	self.dyeSlotFramesByChannel = nil;
	self.dyeSlotPool:ReleaseAll();
	self.decorGUID = nil;
	self.currentChannel = nil;
end

HousingDecorDyeSlotMixin = {};

function HousingDecorDyeSlotMixin:SetDyeSlotInfo(dyeSlotInfo, onClickCallback)
	self.dyeSlotInfo = dyeSlotInfo;
	local dyeColorCategory = C_DyeColor.GetDyeColorCategoryInfo(dyeSlotInfo.dyeColorCategoryID);

	self.Label:SetText(string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_SLOT_LABEL, self.layoutIndex));
	
	local dyeColorInfo = dyeSlotInfo.dyeColorID and C_DyeColor.GetDyeColorInfo(dyeSlotInfo.dyeColorID);
	local isSelected = false;
	self.CurrentSwatch:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
end

HousingDecorDyeSlotPopoutMixin = {};

function HousingDecorDyeSlotPopoutMixin:OnLoad()
	self.dyeSwatchPool = CreateFramePool("BUTTON", self.DyeSlotScrollBox.Contents.DyeSwatchContainer, "HousingDecorDyeSwatchTemplate", HousingDecorDyeSwatchMixin.Reset);
	self.recentSwatchPool = CreateFramePool("BUTTON", self.DyeSlotScrollBox.Contents.RecentlyUsedFrame.RecentlyUsedContainer, "HousingDecorDyeSwatchTemplate", HousingDecorDyeSwatchMixin.Reset)
	
	local view = CreateScrollBoxLinearView();
	ScrollUtil.InitScrollBoxWithScrollBar(self.DyeSlotScrollBox, self.DyeSlotScrollBar, view);
	view:SetPanExtent(20);
	self.ShowOnlyOwned:SetScript("OnClick", function() 
		if self.dyeSlotInfo then
			self:SetDyeSlotInfo(self.dyeSlotInfo);
		end
	end);
end

function HousingDecorDyeSlotPopoutMixin:OnShow()
	PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_OPEN_COLOR_PALETTE);
end

function HousingDecorDyeSlotPopoutMixin:ReinitScrollBox()
	self.DyeSlotScrollBox.Contents.DyeSwatchContainer:MarkDirty();
	self.DyeSlotScrollBox.Contents.RecentlyUsedFrame.RecentlyUsedContainer:MarkDirty();
	C_Timer.After(0, function() self.DyeSlotScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately); end);
end

function HousingDecorDyeSlotPopoutMixin:UpdateDyeSlotInfo(dyeSlotInfo)
	self.dyeSlotInfo = dyeSlotInfo;

	local function updatePool(pool)
		for dyeSwatchFrame in pool:EnumerateActive() do
			local isSelected = (dyeSwatchFrame.dyeColorInfo and dyeSwatchFrame.dyeColorInfo.ID) == dyeSlotInfo.dyeColorID;
			dyeSwatchFrame:UpdateSelected(isSelected);
		end
	end

	updatePool(self.dyeSwatchPool);
	updatePool(self.recentSwatchPool);

	self:ReinitScrollBox();
end

local function sortDyesBy(channel)
	return function(a, b)
		local aHSV = {a.swatchColorStart:GetHSL()};
		local bHSV = {b.swatchColorStart:GetHSL()};

		return aHSV[channel] > bHSV[channel];
	end
end

--not used but we may use something like this in the future.
--sortDyesByChunks({0.3, 0.7}, 2, 1) will sort into 3 chunks based on saturation, and within each chunk by hue.
local function sortDyesByChunks(chunks, chunkChannel, elseChannel)
	local function getChunk(v)
		for i, thresh in ipairs(chunks) do
			if v < thresh then
				return i;
			end
		end
		return #chunks + 1;
	end
	return function(a, b)
		local aHSV = {a.swatchColorStart:GetHSL()};
		local bHSV = {b.swatchColorStart:GetHSL()};

		local aChunk = getChunk(aHSV[chunkChannel]);
		local bChunk = getChunk(bHSV[chunkChannel]);

		if aChunk == bChunk then
			return aHSV[elseChannel] > bHSV[elseChannel];
		else
			return aChunk > bChunk;
		end
	end
end

function HousingDecorDyeSlotPopoutMixin:SetDyeSlotInfo(dyeSlotInfo)
	self.dyeSwatchPool:ReleaseAll();
	self.recentSwatchPool:ReleaseAll();
	self.dyeSlotInfo = dyeSlotInfo;

	local onClickCallback = GenerateClosure(self.OnSwatchClicked, self);

	do --recentSwatchPool
		local dyeColorIDs = C_HousingCustomizeMode.GetRecentlyUsedDyes();
		if #dyeColorIDs == 0 then
			self.DyeSlotScrollBox.Contents.RecentlyUsedFrame:Hide();
		else
			self.DyeSlotScrollBox.Contents.RecentlyUsedFrame:Show();
			for ind, dyeColorID in ipairs(dyeColorIDs) do
				local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
				local dyeSwatchFrame = self.recentSwatchPool:Acquire();
				dyeSwatchFrame.layoutIndex = #dyeColorIDs - ind;
				local isSelected = dyeColorInfo.ID == dyeSlotInfo.dyeColorID;
				dyeSwatchFrame:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
				dyeSwatchFrame:Show();
			end
		end
	end

	do --dyeSwatchPool
		local dyeColorInfos = {};
		local dyeColorIDs = C_DyeColor.GetAllDyeColors();
		local onlyOwned = self.ShowOnlyOwned:GetChecked();
		for _, dyeColorID in ipairs(dyeColorIDs) do
			local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
			if dyeColorInfo and not (onlyOwned and dyeColorInfo.numOwned == 0) then
				tinsert(dyeColorInfos, dyeColorInfo);
			end
		end

		table.sort(dyeColorInfos, sortDyesBy(1)); --sort by hue

		for dyeColorIndex, dyeColorInfo in ipairs(dyeColorInfos) do
			local dyeSwatchFrame = self.dyeSwatchPool:Acquire();
			dyeSwatchFrame.layoutIndex = dyeColorIndex + 1;
			local isSelected = dyeColorInfo.ID == dyeSlotInfo.dyeColorID;
			dyeSwatchFrame:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
			dyeSwatchFrame:Show();
		end

		local noDyeFrame = self.dyeSwatchPool:Acquire();
		noDyeFrame.layoutIndex = 1;
		local isSelected = not dyeSlotInfo.dyeColorID;
		noDyeFrame:SetDyeColorInfo(nil, isSelected, onClickCallback);
		noDyeFrame:Show();
	end

	self:ReinitScrollBox();
	
	self.DyeSlotScrollBar:ScrollToBegin();
end

function HousingDecorDyeSlotPopoutMixin.Reset(framePool, self)
	self.dyeSlotInfo = nil;
	self.dyeSwatchPool:ReleaseAll();
	self.recentSwatchPool:ReleaseAll();
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingDecorDyeSlotPopoutMixin:OnSwatchClicked(dyeSwatch)
	local selectedColorID = nil;
	if not dyeSwatch.isSelected then
		selectedColorID = dyeSwatch.dyeColorInfo and dyeSwatch.dyeColorInfo.ID;
	end

	C_HousingCustomizeMode.ApplyDyeToSelectedDecor(self.dyeSlotInfo.ID, selectedColorID);
end

HousingDecorDyeSwatchMixin = {};

function HousingDecorDyeSwatchMixin:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback)
	self.dyeColorInfo = dyeColorInfo;
	self.onClickCallback = onClickCallback;
	if dyeColorInfo and dyeColorInfo.swatchColorStart and dyeColorInfo.swatchColorEnd then
		self.SwatchEmpty:Hide();
		self.SwatchStart:SetVertexColor(dyeColorInfo.swatchColorStart:GetRGB());
		self.SwatchEnd:SetVertexColor(dyeColorInfo.swatchColorEnd:GetRGB());
		self.SwatchStart:Show();
		self.SwatchEnd:Show();
		self.Highlight:Show();
	else
		self.SwatchStart:Hide();
		self.SwatchEnd:Hide();
		self.Highlight:Hide();
		self.SwatchEmpty:Show();
	end

	self:UpdateSelected(isSelected);
end

function HousingDecorDyeSwatchMixin:UpdateSelected(isSelected)
	self.isSelected = isSelected;
	self.SelectedBorder:SetShown(isSelected);
end

function HousingDecorDyeSwatchMixin.Reset(framePool, self)
	self.dyeColorInfo = nil;
	self.isSelected = false;
	self.onClickCallback = nil;
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingDecorDyeSwatchMixin:OnEnter()
	if self.dyeColorInfo then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_AddHighlightLine(GameTooltip, self.dyeColorInfo.name);
		GameTooltip_AddNormalLine(GameTooltip, string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED, self.dyeColorInfo.numOwned))
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DECOR_CUSTOMIZATION_DEFAULT_COLOR);
		GameTooltip:Show();
	end

	if not self.isCurrentSwatch then
		PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_HOVER);
	end
end

function HousingDecorDyeSwatchMixin:OnLeave()
	GameTooltip:Hide();
end

function HousingDecorDyeSwatchMixin:OnClick()
	if self.onClickCallback then
		self.onClickCallback(self);

		if not self.isCurrentSwatch then
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_SELECT);
		end
	end
end

HousingRoomComponentOptionMixin = {};

function HousingRoomComponentOptionMixin:SetRoomComponentInfo(roomComponentInfo)
	self.roomComponentInfo = roomComponentInfo;
	self.roomGUID = roomComponentInfo.roomGUID;
	self.componentID = roomComponentInfo.componentID;
	self:UpdateDropdown();
end

function HousingRoomComponentOptionMixin:UpdateRoomComponentInfo(roomComponentInfo)
	self.roomComponentInfo = roomComponentInfo;
	self:UpdateDropdown();
end

function HousingRoomComponentOptionMixin:AddRecents(rootDescription, AddButton, IDs)
	if #IDs > 0 then
		rootDescription:CreateTitle(HOUSING_DECOR_CUSTOMIZATION_RECENTLY_USED_SHORT);
		for _, ID in ipairs_reverse(IDs) do
			AddButton(ID);
		end
		rootDescription:CreateDivider();
	end
end

function HousingRoomComponentOptionMixin:PlaySelectedSound()
	PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_APPLY_ROOM_CHANGE);
end

HousingRoomComponentThemeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentThemeMixin:UpdateDropdown()
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

		local function ThemeFromID(themeSetID)
			local name = C_HousingCustomizeMode.GetThemeSetInfo(themeSetID);
			if name then
				return {id = themeSetID, name = name};
			end
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

		local function AddButton(theme)
			if theme then
				rootDescription:CreateHighlightRadio(theme.name, IsSelected, SetSelected, theme);
			end
		end

		self:AddRecents(rootDescription, function(themeSetID) AddButton(ThemeFromID(themeSetID)) end, C_HousingCustomizeMode.GetRecentlyUsedThemeSets());

		for _, theme in ipairs(themeSets) do
			AddButton(theme)
		end
	end);
end

HousingRoomComponentWallpaperMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

function HousingRoomComponentWallpaperMixin:UpdateDropdown()
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

		local type = self.roomComponentInfo.type;
		local wallpapers = C_HousingCustomizeMode.GetWallpapersForRoomComponentType(type);

		local wallpapersByID = {};
		for _, wallpaper in ipairs(wallpapers) do
			wallpapersByID[wallpaper.roomComponentTextureRecID] = wallpaper;
		end

		--TODO: incporporate ownership when ownership is implemented.
		table.sort(wallpapers, function(a, b) return a.name < b.name end);

		local function AddButton(wallpaper)
			if wallpaper then
				rootDescription:CreateHighlightRadio(wallpaper.name, IsSelected, SetSelected, wallpaper);
			end
		end
		
		local function AddFromID(wallpaperID)
			AddButton(wallpapersByID[wallpaperID]);
		end

		self:AddRecents(rootDescription, AddFromID, C_HousingCustomizeMode.GetRecentlyUsedWallpapers());

		for _, wallpaper in ipairs(wallpapers) do
			AddButton(wallpaper);
		end
	end);
end

HousingRoomComponentCeilingTypeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

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

HousingRoomComponentDoorTypeMixin = CreateFromMixins(HousingRoomComponentOptionMixin);

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


RoomComponentPaneMixin = {};

function RoomComponentPaneMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", function() 
		self:Hide();
	end);

	self.ApplyThemeToRoomButton:SetScript("OnClick", function()
		C_HousingCustomizeMode.ApplyThemeToRoom(self.roomComponentInfo.currentThemeSet);
	end);

	self.ApplyWallpaperToAllWallsButton:SetScript("OnClick", function()
		C_HousingCustomizeMode.ApplyWallpaperToAllWalls(self.roomComponentInfo.currentRoomComponentTextureRecID);
	end);
end

function RoomComponentPaneMixin:OnHide()
	C_HousingCustomizeMode.ClearTargetRoomComponent();
end

function RoomComponentPaneMixin:SetRoomComponentInfo(roomComponentInfo)
	self.roomComponentInfo = roomComponentInfo;
	self.roomGUID = roomComponentInfo.roomGUID;
	self.componentID = roomComponentInfo.componentID;
	self.appliedTheme = roomComponentInfo.currentTheme;

	local type = roomComponentInfo.type;
	if type == Enum.HousingRoomComponentType.Ceiling then
		self.WallWarning:Hide();
		self.CeilingTypeDropdown:Show();
		self.ThemeDropdown:Show();
		self.ApplyThemeToRoomButton:Show();
		self.WallpaperDropdown:Show();
		self.ApplyWallpaperToAllWallsButton:Hide();
		self.DoorTypeDropdown:Hide();
	elseif type == Enum.HousingRoomComponentType.Wall then
		self.WallWarning:Show();
		self.CeilingTypeDropdown:Hide();
		self.ThemeDropdown:Show();
		self.ApplyThemeToRoomButton:Show();
		self.WallpaperDropdown:Show();
		self.ApplyWallpaperToAllWallsButton:Show();
		self.DoorTypeDropdown:SetShown(roomComponentInfo.doorType ~= Enum.HousingRoomComponentDoorType.None);
	elseif type == Enum.HousingRoomComponentType.Floor then
		self.WallWarning:Hide();
		self.CeilingTypeDropdown:Hide();
		self.ThemeDropdown:Hide();
		self.ApplyThemeToRoomButton:Hide();
		self.WallpaperDropdown:Show();
		self.ApplyWallpaperToAllWallsButton:Hide();
		self.DoorTypeDropdown:Hide();
	else
		self:Hide();
		return;
	end

	self:ForEachDropdown(function(dropdown)
		dropdown:SetRoomComponentInfo(roomComponentInfo);
		local textKey =
			type == Enum.HousingRoomComponentType.Ceiling and "LabelText_Ceiling" or
			type == Enum.HousingRoomComponentType.Wall and "LabelText_Wall" or
			"LabelText_Floor";
		dropdown.SwitchLabel:SetText(dropdown[textKey]);
	end);
end

function RoomComponentPaneMixin:UpdateRoomComponentInfo(roomComponentInfo)
	self.roomComponentInfo = roomComponentInfo;
	self:ForEachDropdown(function(dropdown)
		dropdown:UpdateRoomComponentInfo(roomComponentInfo);
	end);
end

function RoomComponentPaneMixin:ForEachDropdown(fn)
	for _,dropdown in ipairs(self.dropdowns) do
		if dropdown:IsShown() then
			fn(dropdown);
		end
	end
end

function RoomComponentPaneMixin:ClearRoomComponentInfo()
	self.roomComponentInfo = nil;
	self.roomGUID = nil;
	self.componentID = nil;
end

HousingDyeCostIconMixin = {};

function HousingDyeCostIconMixin:Init(itemID, numOwned, unowned)
	self.itemID = itemID;
	self.numOwned = numOwned;
	self.coloredItemName = nil;

	if not itemID then
		self:Hide();
		return;
	end

	if not self.continuableContainer then
		self.continuableContainer = ContinuableContainer:Create();
	else
		self.continuableContainer:Cancel();
	end

	local item = Item:CreateFromItemID(self.itemID);
	self.continuableContainer:AddContinuable(item);

	self.continuableContainer:ContinueOnLoad(function()
		local itemIcon = item:GetItemIcon();
		local qualityColor = item:GetItemQualityColor().color;
		self.coloredItemName = qualityColor:WrapTextInColorCode(item:GetItemName());

		self.DyeIcon:SetTexture(itemIcon);
		local iconTint = unowned and DIM_RED_FONT_COLOR or WHITE_FONT_COLOR
		self.DyeIcon:SetVertexColor(iconTint:GetRGBA());
		self:Show();

		self:GetParent():MarkDirty();
	end);
end

function HousingDyeCostIconMixin:OnEnter()
	local tooltipMinWidth = 120;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.coloredItemName, nil, true);
	GameTooltip_AddColoredLine(GameTooltip, HOUSING_DYE_TOOLTIP_DESCRIPTION, BRIGHTBLUE_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddLine(string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED, self.numOwned));
	GameTooltip:SetMinimumWidth(tooltipMinWidth);
	GameTooltip:Show();
end

function HousingDyeCostIconMixin:OnLeave()
	GameTooltip_Hide();
end
