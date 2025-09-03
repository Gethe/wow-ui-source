local REORDER_MARKER_BEFORE_TARGET = false;
local REORDER_MARKER_AFTER_TARGET = true;

COOLDOWN_BAR_DEFAULT_COLOR = CreateColor(1, 0.5, 0.25);

StaticPopupDialogs["REVERT_COOLDOWN_LAYOUT_CHANGES"] = {
	text = COOLDOWN_VIEWER_SETTINGS_DIALOG_TEXT_REVERT_CHANGES,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		data:ResetToRestorePoint();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_COOLDOWN_LAYOUT_TO_DEFAULT"] = {
	text = COOLDOWN_VIEWER_SETTINGS_DIALOG_TEXT_RESET_LAYOUT_TO_DEFAULT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		data:ResetCurrentToDefaults();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

CooldownViewerSettingsDraggedItemMixin = {};
function CooldownViewerSettingsDraggedItemMixin:SetToCursor(cooldownItem)
	self.Icon:SetTexture(cooldownItem:GetTextureFileID());
	self:Show();
end

function CooldownViewerSettingsDraggedItemMixin:OnUpdate()
	local topLevel = GetAppropriateTopLevelParent();
	local x, y = GetScaledCursorPositionForFrame(topLevel);
	self:SetPoint("TOPLEFT", topLevel, "BOTTOMLEFT", x, y);
end

local cooldownItemDragCursor;
local function PickupCooldownItemCursor(cooldownItem)
	if not cooldownItemDragCursor then
		cooldownItemDragCursor = CreateFrame("Frame", nil, GetAppropriateTopLevelParent(), "CooldownViewerSettingsDraggedItemTemplate");
	end

	cooldownItemDragCursor:SetToCursor(cooldownItem);
end

local function ClearCooldownItemCursor()
	if cooldownItemDragCursor then
		cooldownItemDragCursor:StopMovingOrSizing();
		cooldownItemDragCursor:Hide();
	end
end

CVarCallbackRegistry:SetCVarCachable("cooldownViewerShowUnlearned");
local function IsShowingUnlearned()
	return CVarCallbackRegistry:GetCVarValueBool("cooldownViewerShowUnlearned");
end

local function SetShowUnlearned(show)
	if show ~= IsShowingUnlearned() then
		SetCVar("cooldownViewerShowUnlearned", show);
		CooldownViewerSettings:RefreshVisibleCategories();
	end
end

local function ToggleSetShowUnlearned()
	SetShowUnlearned(not IsShowingUnlearned());
end

local function MatchesCooldownCategory(cooldownInfo, displayCategory)
	return cooldownInfo.category == displayCategory:GetCategory() and (cooldownInfo.isKnown or IsShowingUnlearned());
end

local CooldownViewerCategoryMixin = {};
function CooldownViewerCategoryMixin:Init(category, title, filter)
	self.category = category;
	self.title = title;
	self.filter = filter;
end

function CooldownViewerCategoryMixin:GetCategory()
	return self.category;
end

function CooldownViewerCategoryMixin:GetTitle()
	return self.title;
end

function CooldownViewerCategoryMixin:ShouldDisplayInfo(info)
	return self.filter(info, self);
end

function CooldownViewerCategoryMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
end

function CooldownViewerCategoryMixin:IsCollapsed()
	return self.isCollapsed;
end

function CooldownViewerCategoryMixin:WillDisableCooldownsAssignedToThisCategory()
	return CooldownViewerUtil_IsDisabledCategory(self:GetCategory());
end

function CooldownViewerCategoryMixin:GetCategoryAssignmentText()
	if self:WillDisableCooldownsAssignedToThisCategory() then
		return COOLDOWN_VIEWER_SETTINGS_ASSIGN_TO_EMPTY_CATEGORY;
	else
		return COOLDOWN_VIEWER_SETTINGS_ASSIGN_TO_CATEGORY:format(self:GetTitle());
	end
end

function CooldownViewerCategoryMixin:GetItemDisplayType()
	if self:GetCategory() == Enum.CooldownViewerCategory.TrackedBar then
		return "bar";
	end

	return "icon";
end

local cooldownCategories = nil;
do
	local function MakeCategory(...)
		return CreateAndInitFromMixin(CooldownViewerCategoryMixin, ...);
	end

	cooldownCategories = {
		MakeCategory(Enum.CooldownViewerCategory.Essential, COOLDOWN_VIEWER_SETTINGS_CATEGORY_ESSENTIAL, MatchesCooldownCategory),
		MakeCategory(Enum.CooldownViewerCategory.Utility, COOLDOWN_VIEWER_SETTINGS_CATEGORY_UTILITY, MatchesCooldownCategory),
		MakeCategory(Enum.CooldownViewerCategory.TrackedBuff, COOLDOWN_VIEWER_SETTINGS_CATEGORY_TRACKED_BUFF, MatchesCooldownCategory),
		MakeCategory(Enum.CooldownViewerCategory.TrackedBar, COOLDOWN_VIEWER_SETTINGS_CATEGORY_TRACKED_BARS, MatchesCooldownCategory),
		MakeCategory(Enum.CooldownViewerCategory.HiddenSpell, COOLDOWN_VIEWER_SETTINGS_CATEGORY_NOT_IN_BAR, MatchesCooldownCategory),
		MakeCategory(Enum.CooldownViewerCategory.HiddenAura, COOLDOWN_VIEWER_SETTINGS_CATEGORY_NOT_IN_BAR, MatchesCooldownCategory),
	};
end

function CreateCategoryObjectLookup()
	local lookup = {};
	for index, object in ipairs(cooldownCategories) do
		lookup[object:GetCategory()] = object;
	end

	return lookup;
end

CooldownViewerBaseReorderTargetMixin = {};

function CooldownViewerBaseReorderTargetMixin:OnEnter()
	EventRegistry:TriggerEvent("CooldownViewerSettings.OnEnterItem", self);
end

function CooldownViewerBaseReorderTargetMixin:GetBestCooldownItemTarget(_mouseX, _mouseY)
	-- This can be overridden in derived mixins
	return self;
end

CooldownViewerSettingsItemMixin = CreateFromMixins(CooldownViewerItemDataMixin, CooldownViewerBaseReorderTargetMixin);

function CooldownViewerSettingsItemMixin:RefreshData()
	if not self:IsEmptyCategory() then
		self.Icon:SetTexture(self:GetSpellTexture());
		self:RefreshIconState();
	else
		self.Icon:SetAtlas("cdm-empty");
		self.Icon:SetDesaturated(false);
	end
end

function CooldownViewerSettingsItemMixin:RefreshIconState()
	local info = self:GetCooldownInfo();
	assertsafe(info ~= nil, "Non empty cooldown with invalid info, id: " .. tostring(self:GetCooldownID()));

	self.Icon:SetDesaturated(not info.isKnown or self:IsReorderLocked());
end

function CooldownViewerSettingsItemMixin:SetOrderIndex(orderIndex)
	self.orderIndex = orderIndex;
end

function CooldownViewerSettingsItemMixin:GetOrderIndex()
	return self.orderIndex;
end

function CooldownViewerSettingsItemMixin:SetTooltipAnchor(tooltip)
	tooltip:SetOwner(self, "ANCHOR_RIGHT");
end

function CooldownViewerSettingsItemMixin:OnDragStart()
	if not self:IsEmptyCategory() then
		PlaySound(SOUNDKIT.UI_CURSOR_PICKUP_OBJECT);
		self:BeginOrderChange();
	end
end

function CooldownViewerSettingsItemMixin:OnMouseUp(button, upInside)
	if self:IsEmptyCategory() then
		return;
	end

	if upInside then
		if button == "LeftButton" then
			local eatNextGlobalMouseUp = button;
			PlaySound(SOUNDKIT.UI_CURSOR_PICKUP_OBJECT);
			self:BeginOrderChange(eatNextGlobalMouseUp);
		elseif button == "RightButton" then
			self:DisplayContextMenu();
		end
	end
end

function CooldownViewerSettingsItemMixin:OnEnter()
	CooldownViewerItemDataMixin.OnEnter(self);
	CooldownViewerBaseReorderTargetMixin.OnEnter(self);
end

function CooldownViewerSettingsItemMixin:RefreshTooltip(...)
	if not self:IsEmptyCategory() then
		CooldownViewerItemDataMixin.RefreshTooltip(self, ...);
	else
		local tooltip = GetAppropriateTooltip();
		GameTooltip_SetTitle(tooltip, "Empty Slot"); -- TODO: Not sure what's going to be displayed here yet.
	end
end

function CooldownViewerSettingsItemMixin:SetReorderLocked(locked)
	self.reorderLocked = locked;
	self:RefreshData();
end

function CooldownViewerSettingsItemMixin:IsReorderLocked()
	return self.reorderLocked;
end

function CooldownViewerSettingsItemMixin:UpdateReorderMarkerPosition(marker, cursorX, _cursorY)
	marker:SetVertical();

	local centerX = self:GetCenter();
	if cursorX < centerX then
		marker:SetPoint("CENTER", self, "LEFT", -4, 0);
		return REORDER_MARKER_BEFORE_TARGET;
	else
		marker:SetPoint("CENTER", self, "RIGHT", 4, 0);
		return REORDER_MARKER_AFTER_TARGET;
	end
end

function CooldownViewerSettingsItemMixin:BeginOrderChange(eatNextGlobalMouseUp)
	EventRegistry:TriggerEvent("CooldownViewerSettings.BeginOrderChange", self, eatNextGlobalMouseUp);
end

function CooldownViewerSettingsItemMixin:DisplayContextMenu()
	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_COOLDOWN_SETTINGS_ITEM");

		local menuCategories = CooldownViewerSettings:GetValidAssignmentCategories(self);
		for index, category in ipairs(menuCategories) do
			rootDescription:CreateButton(category:GetCategoryAssignmentText(), function()
				self:AssignToCategory(category);
			end);
		end
	end);
end

function CooldownViewerSettingsItemMixin:AssignToCategory(category)
	CooldownViewerSettings:GetDataProvider():SetCooldownToCategory(self:GetCooldownID(), category:GetCategory());
	CooldownViewerSettings:RefreshLayout();
end

function CooldownViewerSettingsItemMixin:CheckCreateFilterOverlay(filterOverlayKey, anchorToRegion)
	local overlay = self[filterOverlayKey];
	if not overlay then
		overlay = self:CreateTexture(nil, "OVERLAY", nil, 7);
		overlay:SetColorTexture(0, 0, 0, 0.8);
		overlay:SetAllPoints(anchorToRegion);
		self[filterOverlayKey] = overlay;
	end

	return overlay;
end

function CooldownViewerSettingsItemMixin:ApplyFilter(passesFilter)
	if passesFilter or self:IsEmptyCategory() then
		if self.FilterOverlay then
			self.FilterOverlay:Hide();
		end
	else
		self:CheckCreateFilterOverlay("FilterOverlay", self.Icon);
		self.FilterOverlay:Show();
	end
end

function CooldownViewerSettingsItemMixin:SetAsCooldown(cooldownID, orderIndex)
	self.emptyCategory = nil;
	self:SetCooldownID(cooldownID);
	self:SetOrderIndex(orderIndex);
end

function CooldownViewerSettingsItemMixin:SetAsEmptyCategory(category)
	self.emptyCategory = category;
	self:ClearCooldownID();
	self:SetOrderIndex(1);

	self:RefreshData();
end

function CooldownViewerSettingsItemMixin:IsEmptyCategory()
	return self:GetEmptyCategory() ~= nil;
end

function CooldownViewerSettingsItemMixin:GetEmptyCategory()
	return self.emptyCategory;
end

function CooldownViewerSettingsItemMixin:GetTextureFileID()
	return self.Icon:GetTextureFileID();
end

CooldownViewerSettingsBarItemMixin = CreateFromMixins(CooldownViewerSettingsItemMixin);

function CooldownViewerSettingsBarItemMixin:RefreshData()
	CooldownViewerSettingsItemMixin.RefreshData(self);

	if not self:IsEmptyCategory() then
		self.Bar.Name:SetText(self:GetNameText());
		self.Bar.FillTexture:SetAlpha(1);
	else
		self.Bar.Name:SetText("");
		self.Bar.FillTexture:SetAlpha(0);
	end
end

function CooldownViewerSettingsBarItemMixin:RefreshIconState()
	CooldownViewerSettingsItemMixin.RefreshIconState(self);

	local info = self:GetCooldownInfo();
	local isDisabled = not info.isKnown or self:IsReorderLocked();
	self.Bar.FillTexture:SetVertexColor((isDisabled and DISABLED_FONT_COLOR or COOLDOWN_BAR_DEFAULT_COLOR):GetRGB());
end

function CooldownViewerSettingsBarItemMixin:ApplyFilter(passesFilter)
	CooldownViewerSettingsItemMixin.ApplyFilter(self, passesFilter);

	if passesFilter or self:IsEmptyCategory() then
		if self.BarFilterOverlay then
			self.BarFilterOverlay:Hide();
		end
	else
		self:CheckCreateFilterOverlay("BarFilterOverlay", self.Bar);
		self.BarFilterOverlay:Show();
	end
end

function CooldownViewerSettingsBarItemMixin:UpdateReorderMarkerPosition(marker, _cursorX, cursorY)
	marker:SetHorizontal();

	local _, centerY = self:GetCenter();
	if cursorY < centerY then
		marker:SetPoint("CENTER", self, "BOTTOM", 0, -5);
		return REORDER_MARKER_AFTER_TARGET;
	else
		marker:SetPoint("CENTER", self, "TOP", 0, 5);
		return REORDER_MARKER_BEFORE_TARGET;
	end
end

CooldownViewerContainerReorderTargetMixin = CreateFromMixins(CooldownViewerBaseReorderTargetMixin);

function CooldownViewerContainerReorderTargetMixin:GetBestCooldownItemTarget(cursorX, cursorY)
	return self:GetNearestItemToCursorWeighted(cursorX, cursorY);
end

CooldownViewerSettingsCategoryMixin = CreateFromMixins(CooldownViewerContainerReorderTargetMixin);

function CooldownViewerSettingsCategoryMixin:OnLoad()
	self.itemPool = CreateFramePool("Frame", self.Container, self:GetItemTemplate());

	self.Header:SetClickHandler(function(_header, button)
		if button == "LeftButton" then
			self:ToggleCollapsed();
		end
	end);

	self.Header:SetTitleColor(false, NORMAL_FONT_COLOR);
	self.Header:SetTitleColor(true, NORMAL_FONT_COLOR);
	self:SetupGridLayoutParams();
end

function CooldownViewerSettingsCategoryMixin:GetItemTemplate()
	return "CooldownViewerSettingsItemTemplate";
end

function CooldownViewerSettingsCategoryMixin:SetupGridLayoutParams()
	local container = self.Container;
	container.childXPadding = 8;
	container.childYPadding = 8;
	container.isHorizontal = true;
	container.stride = 7;
	container.layoutFramesGoingRight = true;
	container.layoutFramesGoingUp = false;
	container.alwaysUpdateLayout = true;
end

function CooldownViewerSettingsCategoryMixin:Init(categoryObj)
	self.categoryObj = categoryObj;
	self.Header:SetHeaderText(categoryObj:GetTitle());
end

function CooldownViewerSettingsCategoryMixin:GetCategoryObject()
	return self.categoryObj;
end

function CooldownViewerSettingsCategoryMixin:ShouldDisplayInfo(info)
	return self:GetCategoryObject():ShouldDisplayInfo(info);
end

function CooldownViewerSettingsCategoryMixin:SetCollapsed(collapsed)
	self:GetCategoryObject():SetCollapsed(collapsed);
	self.Header:UpdateCollapsedState(collapsed);
	self.Container:SetShown(not collapsed);
	self:Layout();
end

function CooldownViewerSettingsCategoryMixin:ToggleCollapsed()
	self:SetCollapsed(not self:IsCollapsed());
end

function CooldownViewerSettingsCategoryMixin:IsCollapsed()
	return self:GetCategoryObject():IsCollapsed();
end

function CooldownViewerSettingsCategoryMixin:RefreshLayout()
	self.itemPool:ReleaseAll();

	local dataProvider = CooldownViewerSettings:GetDataProvider();
	for index, cooldownID in ipairs(dataProvider:GetOrderedCooldownIDs()) do
		local info = dataProvider:GetCooldownInfoForID(cooldownID);
		if self:ShouldDisplayInfo(info) then
			local item = self.itemPool:Acquire();
			item.layoutIndex = index;

			item:SetAsCooldown(cooldownID, index);
			item:Show();
		end
	end

	if not self:IsDisplayingAnyItems() then
		local emptyItem = self.itemPool:Acquire();
		emptyItem.layoutIndex = 1;
		emptyItem:SetAsEmptyCategory(self:GetCategoryObject());
		emptyItem:Show();
	end

	self.Container:Layout();
	self:ApplyFilter();
end

function CooldownViewerSettingsCategoryMixin:GetNearestItemToCursorWeighted(cursorX, cursorY)
	local nearestItem = nil;
	local nearestVertical = math.huge;
	local nearestHorizontal = math.huge;

	for item in self.itemPool:EnumerateActive() do
		local itemLeft, itemRight, itemBottom, itemTop = RegionUtil.GetSides(item);
		local itemCenterX = (itemLeft + itemRight) / 2;
		local itemCenterY = (itemBottom + itemTop) / 2;
		local horizontalDistance = math.abs(itemCenterX - cursorX);
		local verticalDistance = math.abs(itemCenterY - cursorY);
		if cursorY > itemBottom and cursorY < itemTop then
			verticalDistance = 0;
		end

		if verticalDistance < nearestVertical or (nearestVertical == verticalDistance and horizontalDistance < nearestHorizontal) then
			nearestItem = item;
			nearestVertical = verticalDistance;
			nearestHorizontal = horizontalDistance;
		end
	end

	return nearestItem;
end

function CooldownViewerSettingsCategoryMixin:ApplyFilter()
	local viewerSettings = CooldownViewerSettings;
	local filterText = viewerSettings:GetFilterText();

	for item in self.itemPool:EnumerateActive() do
		item:ApplyFilter(viewerSettings:DoesCooldownMatchTextFilter(item, filterText));
	end
end

function CooldownViewerSettingsCategoryMixin:IsDisplayingAnyItems()
	return self.itemPool:GetNumActive() > 0;
end

CooldownViewerSettingsBarCategoryMixin = CreateFromMixins(CooldownViewerSettingsCategoryMixin);

function CooldownViewerSettingsBarCategoryMixin:GetItemTemplate()
	return  "CooldownViewerSettingsBarItemTemplate";
end

function CooldownViewerSettingsBarCategoryMixin:SetupGridLayoutParams()
	local container = self.Container;
	container.childXPadding = 0;
	container.childYPadding = 10;
	container.isHorizontal = true;
	container.stride = 1;
	container.layoutFramesGoingRight = true;
	container.layoutFramesGoingUp = false;
	container.alwaysUpdateLayout = true;
end

CooldownViewerSettingsContentMixin = {};

CooldownViewerSettingsMixin = {};

function CooldownViewerSettingsMixin:OnLoad()
	RegisterUIPanel(self, { area = "left", pushable = 1, extraWidth = 20, whileDead = 1});

	self:SetTitle(COOLDOWN_VIEWER_SETTINGS_TITLE);
	self.categoryObjects = CreateCategoryObjectLookup();
	self.categoryPool = CreateFramePoolCollection();
	self.categoryPool:CreatePool("Frame", self.CooldownScroll.Content, "CooldownViewerSettingsCategoryTemplate");
	self.categoryPool:CreatePool("Frame", self.CooldownScroll.Content, "CooldownViewerSettingsBarCategoryTemplate");

	self:SetupTabs();
	self:SetupEventHandlers();
	self:SetupDropdownMenu();
	self:SetupPanelButtons();
	self:SetupScrollFrame();

	self.layoutManager = CreateFromMixins(CooldownViewerLayoutManagerMixin);
	self.dataSerialization = CreateFromMixins(CooldownViewerDataStoreSerializationMixin);
	self.dataProvider = CreateFromMixins(CooldownViewerSettingsDataProviderMixin);

	local function LoadCooldownSettings()
		self.layoutManager:Init(self.dataProvider, self.dataSerialization);
		self.dataSerialization:Init(self.layoutManager);
		self.dataProvider:Init(self.layoutManager);

		EventRegistry:TriggerEvent("CooldownViewerSettings.OnSettingsLoaded", self);
	end

	EventUtil.ContinueAfterAllEvents(LoadCooldownSettings, "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD");
end

function CooldownViewerSettingsMixin:GetDataProvider()
	return self.dataProvider;
end

function CooldownViewerSettingsMixin:GetLayoutManager()
	return self.layoutManager;
end

function CooldownViewerSettingsMixin:SetupTabs()
	local function TabHandler(tab, button, upInside)
		if button == "LeftButton" and upInside then
			self:SetDisplayMode(tab.displayMode);
		end
	end

	for i, tabButton in ipairs(self.TabButtons) do
		tabButton:SetCustomOnMouseUpHandler(TabHandler);
	end
end

function CooldownViewerSettingsMixin:SetupEventHandlers()
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.BeginOrderChange", self.BeginOrderChange);
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.OnEnterItem", self.OnEnterItem);
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.OnSpecChanged", self.RefreshLayout);
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.OnPendingChanges", self.UpdateSaveButtonStates);
end

function CooldownViewerSettingsMixin:SetupDropdownMenu()
	self.SettingsDropdown:SetupMenu(function(owner, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_SETTINGS_MENU");

		rootDescription:CreateCheckbox(COOLDOWN_VIEWER_SETTINGS_SHOW_UNLEARNED, IsShowingUnlearned, ToggleSetShowUnlearned);

		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_RESET_LAYOUT_TO_DEFAULT, function()
			StaticPopup_Show("RESET_COOLDOWN_LAYOUT_TO_DEFAULT", nil, nil, self);
		end);

		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_SHOW_OPTIONS, function()
			CooldownViewerSettings:ShowOptionsPanel();
		end);

		EditModeManagerFrame:CreateEnterEditModeMenuButton(rootDescription, HUD_EDIT_MODE_MENU);
	end);
end

function CooldownViewerSettingsMixin:SetupPanelButtons()
	self.UndoButton:SetOnClickHandler(function(_layoutButton, _button, _isDown)
		StaticPopup_Show("REVERT_COOLDOWN_LAYOUT_CHANGES", nil, nil, self);
	end);

	self.UndoButton:SetCustomTextFormatter(function(button, enabled, highlight)
		return COOLDOWN_VIEWER_SETTINGS_BUTTON_REVERT_CHANGES .. " " .. CreateAtlasMarkup(enabled and "common-icon-undo" or "common-icon-undo-disable");
	end);
end

function CooldownViewerSettingsMixin:SetupScrollFrame()
	local originalHandler = self.CooldownScroll:GetScript("OnScrollRangeChanged");
	self.CooldownScroll:SetScript("OnScrollRangeChanged", function(scrollFrame, horizontalRange, verticalRange)
		if originalHandler then
			originalHandler(scrollFrame, horizontalRange, verticalRange);
		end

		self:CheckAddScrollFramePadding();
	end);
end

function CooldownViewerSettingsMixin:IsReordering()
	return self:GetReorderSourceItem() ~= nil;
end

function CooldownViewerSettingsMixin:BeginOrderChange(cooldownItem, eatNextGlobalMouseUp)
	if self:IsReordering() then
		return;
	end

	self:SetReorderSourceItem(cooldownItem);
	self:SetReorderTarget(cooldownItem);
	self.reorderOffset = 0;
	self.eatNextGlobalMouseUp = eatNextGlobalMouseUp;

	cooldownItem:SetReorderLocked(true);
	PickupCooldownItemCursor(cooldownItem);

	self:SetScript("OnUpdate", self.OnUpdate);

	self:RegisterEvent("GLOBAL_MOUSE_UP");
end

function CooldownViewerSettingsMixin:EndOrderChange()
	local sourceItem = self:GetReorderSourceItem();
	local targetItem = self:GetReorderTargetItem();
	if sourceItem ~= targetItem then
		if targetItem:IsEmptyCategory() then
			self:GetDataProvider():SetCooldownToCategory(sourceItem:GetCooldownID(), targetItem:GetEmptyCategory():GetCategory());
		else
			self:GetDataProvider():ChangeOrderIndex(sourceItem:GetOrderIndex(), targetItem:GetOrderIndex(), self.reorderOffset);
		end
	end

	self:CancelOrderChange();
	self:RefreshLayout();
end

function CooldownViewerSettingsMixin:CancelOrderChange(cooldownItem, ...)
	self:GetReorderSourceItem():SetReorderLocked(false);
	self.ReorderMarker:Hide();
	self:ClearReorderTargets();

	ClearCooldownItemCursor();

	self:SetScript("OnUpdate", nil);

	self:UnregisterEvent("GLOBAL_MOUSE_UP");
end

function CooldownViewerSettingsMixin:OnEnterItem(cooldownItem)
	self:SetReorderTarget(cooldownItem);
end

function CooldownViewerSettingsMixin:SetReorderTarget(cooldownItem)
	if self:IsReordering() then
		self.reorderTarget = cooldownItem;
	end
end

function CooldownViewerSettingsMixin:GetReorderTarget()
	return self.reorderTarget;
end

function CooldownViewerSettingsMixin:SetReorderTargetItem(item)
	if self:IsReordering() then
		self.reorderTargetItem = item;
	end
end

function CooldownViewerSettingsMixin:GetReorderTargetItem()
	return self.reorderTargetItem;
end

function CooldownViewerSettingsMixin:SetReorderSourceItem(item)
	self.reorderSourceItem = item;
end

function CooldownViewerSettingsMixin:GetReorderSourceItem()
	return self.reorderSourceItem;
end

function CooldownViewerSettingsMixin:ClearReorderTargets()
	self.reorderTarget = nil;
	self.reorderTargetItem = nil;
	self.reorderSourceItem = nil;
end

function CooldownViewerSettingsMixin:OnUpdate(_elapsed)
	assertsafe(self:IsReordering());
	self:UpdateReorderMarker();
end

function CooldownViewerSettingsMixin:UpdateReorderMarker()
	local target = self:GetReorderTarget();
	self.ReorderMarker:SetShown(target ~= nil);

	if not target then
		return;
	end

	local cursorX, cursorY = GetCursorPosition();
	local scale = GetAppropriateTopLevelParent():GetScale();
	cursorX, cursorY = cursorX / scale, cursorY / scale;

	-- TODO: This needs to handle dragging over collapsed headers where there are no item targets, but there's still enough info to know to change categories.
	-- For now just leaving the marker alone...
	local cooldownItemTarget = target:GetBestCooldownItemTarget(cursorX, cursorY);
	self:SetReorderTargetItem(cooldownItemTarget);
	if cooldownItemTarget then
		self.ReorderMarker:ClearAllPoints();
		local isMarkerAfterTarget = cooldownItemTarget:UpdateReorderMarkerPosition(self.ReorderMarker, cursorX, cursorY);
		if isMarkerAfterTarget then
			self.reorderOffset = 1;
		else
			self.reorderOffset = 0;
		end
	end
end

function CooldownViewerSettingsMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_UP" then
		local button = ...;
		self:OnGlobalMouseUp(button);
	end
end

function CooldownViewerSettingsMixin:OnGlobalMouseUp(button)
	if self.eatNextGlobalMouseUp == button then
		self.eatNextGlobalMouseUp = nil;
	else
		PlaySound(SOUNDKIT.UI_CURSOR_DROP_OBJECT);

		if button == "LeftButton" then
			self:EndOrderChange();
		elseif button == "RightButton" then
			self:CancelOrderChange();
		end
	end
end

function CooldownViewerSettingsMixin:OnShow()
	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);

	CallbackRegistrantMixin.OnShow(self);
	self:GetDataProvider():IncrementShowCount();

	if self.displayMode then
		self:RefreshLayout();
	else
		self:SetDisplayMode("spells");
	end

	EventRegistry:TriggerEvent("CooldownViewerSettings.OnShow", self);

	if not self:GetLayoutManager():HasPendingChanges() then
		self:GetLayoutManager():CreateRestorePoint();
	end

	self:UpdateSaveButtonStates();
end

function CooldownViewerSettingsMixin:OnHide()
	self:SaveCurrentLayout();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);

	CallbackRegistrantMixin.OnHide(self);
	self:GetDataProvider():DecrementShowCount();
	EditModeManagerFrame:ShowIfActive();
	EventRegistry:TriggerEvent("CooldownViewerSettings.OnHide", self);
end

function CooldownViewerSettingsMixin:SetCurrentCategories(categories)
	self.currentCategories = {};

	if categories then
		for index, category in ipairs(categories) do
			table.insert(self.currentCategories, self.categoryObjects[category]);
		end
	end

	self:RefreshLayout();
end

function CooldownViewerSettingsMixin:RefreshLayout()
	self:GetDataProvider():CheckBuildDisplayData();
	self:ClearDisplayCategories();
	self:RemoveScrollFramePadding();

	if self.currentCategories then
		for index, category in ipairs(self.currentCategories) do
			self:AddCategory(category);
		end
	end

	self:SetPortraitToSpecIcon();
end

local displayModeToCategories =
{
	["spells"] = { Enum.CooldownViewerCategory.Essential, Enum.CooldownViewerCategory.Utility, Enum.CooldownViewerCategory.HiddenSpell },
	["auras"] = { Enum.CooldownViewerCategory.TrackedBuff, Enum.CooldownViewerCategory.TrackedBar, Enum.CooldownViewerCategory.HiddenAura },
};

function CooldownViewerSettingsMixin:SetDisplayMode(displayMode)
	if displayMode == self.displayMode then
		return;
	end

	self.displayMode = displayMode;

	for i, frame in ipairs(self.TabButtons) do
		frame:SetChecked(frame.displayMode == displayMode);
	end

	local categories = displayModeToCategories[displayMode];
	assertsafe(type(categories) == "table", "Add missing category data for displayMode: " .. tostring(displayMode)); -- Should never have an invalid category being used.
	self:SetCurrentCategories(categories);
end

function CooldownViewerSettingsMixin:ClearDisplayCategories()
	self.categoryPool:ReleaseAll();
	self.previousCategory = nil;
end

function CooldownViewerSettingsMixin:GetCategoryTemplate(category)
	if category:GetItemDisplayType() == "bar" then
		return "CooldownViewerSettingsBarCategoryTemplate";
	end

	return "CooldownViewerSettingsCategoryTemplate";
end

function CooldownViewerSettingsMixin:AddCategory(category)
	local categoryDisplay = self.categoryPool:Acquire(self:GetCategoryTemplate(category));
	categoryDisplay:Init(category);
	if self.previousCategory then
		categoryDisplay:SetPoint("TOPLEFT", self.previousCategory, "BOTTOMLEFT", 0, -18);
	else
		categoryDisplay:SetPoint("TOPLEFT", categoryDisplay:GetParent(), "TOPLEFT", 0, 0);
	end

	categoryDisplay:RefreshLayout();
	categoryDisplay:SetCollapsed(category:IsCollapsed());
	categoryDisplay:Show();

	self.previousCategory = categoryDisplay;
end

function CooldownViewerSettingsMixin:CheckAddScrollFramePadding()
	self:RemoveScrollFramePadding();

	local needsScrollPadding = self.previousCategory and self.CooldownScroll:GetVerticalScrollRange() > 0;

	if needsScrollPadding then
		if not self.scrollFramePadding then
			self.scrollFramePadding = CreateFrame("Frame", nil, self.CooldownScroll.Content);
			self.scrollFramePadding:SetHeight(18);
		end

		self.scrollFramePadding:ClearAllPoints();
		self.scrollFramePadding:SetPoint("TOPLEFT", self.previousCategory, "BOTTOMLEFT");
		self.scrollFramePadding:SetPoint("TOPRIGHT", self.previousCategory, "BOTTOMRIGHT");
	end

	if self.scrollFramePadding then
		self.scrollFramePadding:SetShown(needsScrollPadding);
	end
end

function CooldownViewerSettingsMixin:RemoveScrollFramePadding()
	if self.scrollFramePadding then
		self.scrollFramePadding:Hide();
	end
end

function CooldownViewerSettingsMixin:ApplyFilter()
	for categoryDisplay in self.categoryPool:EnumerateActive() do
		categoryDisplay:ApplyFilter();
	end
end

function CooldownViewerSettingsMixin:RefreshVisibleCategories()
	for categoryDisplay in self.categoryPool:EnumerateActive() do
		categoryDisplay:RefreshLayout();
		categoryDisplay:MarkDirty();
	end
end

function CooldownViewerSettingsMixin:GetValidAssignmentCategories(cooldownItem)
	local validAssignments = {};

	local info = self:GetDataProvider():GetCooldownInfoForID(cooldownItem:GetCooldownID());
	if self.currentCategories then
		for index, category in ipairs(self.currentCategories) do
			if category:GetCategory() ~= info.category then
				table.insert(validAssignments, category);
			end
		end
	end

	return validAssignments;
end

function CooldownViewerSettingsMixin:SetFilterText(filterText)
	local lowerFilterText = filterText:lower();
	if self.filterText ~= lowerFilterText then
		self.filterText = lowerFilterText;
		self:ApplyFilter();
	end
end

function CooldownViewerSettingsMixin:GetFilterText()
	return self.filterText;
end

local cooldownIDToTextFilterEntries = {};
local function GetCooldownTextFilterEntry(cooldownItem)
	local cooldownID = cooldownItem:GetCooldownID();
	if cooldownID then
		local entry = cooldownIDToTextFilterEntries[cooldownID];
		if not entry then
			local spellID = cooldownItem:GetSpellID();
			local spellName = spellID and C_Spell.GetSpellName(cooldownItem:GetSpellID());
			if spellName then
				entry = { name = spellName:lower() };
			end

			cooldownIDToTextFilterEntries[cooldownID] = entry;
		end

		return entry;
	end

	return nil;
end

function CooldownViewerSettingsMixin:DoesCooldownMatchTextFilter(cooldownItem, textFilter)
	if textFilter and #textFilter > 1 then
		local filterEntry = GetCooldownTextFilterEntry(cooldownItem);
		if filterEntry then
			return string.find(filterEntry.name, textFilter, 1, true) ~= nil;
		end
	end

	return true;
end

function CooldownViewerSettingsMixin:ShowUIPanel(fromEditMode)
	if fromEditMode then
		EditModeManagerFrame:CheckHideAndLockEditMode();
	end

	ShowUIPanel(self);
end

function CooldownViewerSettingsMixin:TogglePanel()
	if self:IsVisible() then
		HideUIPanel(self);
	else
		self:ShowUIPanel();
	end
end

function CooldownViewerSettingsMixin:UpdateFromUserChange()
	self:SaveCurrentLayout();
	self:RefreshLayout();
end

function CooldownViewerSettingsMixin:ResetCurrentToDefaults()
	self:GetDataProvider():ResetCurrentToDefaults();
	self:UpdateFromUserChange();
end

function CooldownViewerSettingsMixin:UseDefaultLayout()
	self:GetDataProvider():UseDefaultLayout();
	self:UpdateFromUserChange();
end

function CooldownViewerSettingsMixin:SetActiveLayoutName(layoutName)
	self:GetDataProvider():SetActiveLayoutName(layoutName);
	self:UpdateFromUserChange();
end

function CooldownViewerSettingsMixin:ResetToRestorePoint()
	self:GetDataProvider():ResetToRestorePoint();
	self:UpdateFromUserChange();
end

function CooldownViewerSettingsMixin:SaveCurrentLayout()
	local layoutManager = self:GetLayoutManager();
	local savedSomething = layoutManager:SaveLayouts();
	layoutManager:CreateRestorePoint();

	if savedSomething then
		UIErrorsFrame:AddExternalWarningMessage(COOLDOWN_VIEWER_SETTINGS_LAYOUT_SAVED_MESSAGE);
	end
end

function CooldownViewerSettingsMixin:UpdateSaveButtonStates()
	local hasPendingChanges = self:GetLayoutManager():HasPendingChanges();
	self.UndoButton:SetEnabled(hasPendingChanges);
end

function CooldownViewerSettingsMixin:ShowOptionsPanel(fromEditMode)
	if fromEditMode then
		EditModeManagerFrame:CheckHideAndLockEditMode();
	end

	Settings.OpenToCategory(Settings.ADVANCED_OPTIONS_CATEGORY_ID);
end

CooldownViewerSettingsSearchBoxMixin = {}

function CooldownViewerSettingsSearchBoxMixin:CooldownViewerSettingsSearch_OnTextChanged(_userChange)
	CooldownViewerSettings:SetFilterText(self:GetText());
end


CooldownViewerSettingsReorderMarkerMixin = {};

function CooldownViewerSettingsReorderMarkerMixin:SetHorizontal()
	self.Texture:SetAtlas("cdm-horizontal", true);
end

function CooldownViewerSettingsReorderMarkerMixin:SetVertical()
	self.Texture:SetAtlas("CDM-vertical", true);
end
