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
	return CooldownViewerUtil.IsDisabledCategory(self:GetCategory());
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

CooldownViewerSettingsItemMixin = CreateFromMixins(CooldownViewerItemDataMixin, CooldownViewerBaseReorderTargetMixin, CooldownViewerVisualAlertTargetMixin);

function CooldownViewerSettingsItemMixin:RefreshData()
	if not self:IsEmptyCategory() then
		self.Icon:SetTexture(self:GetSpellTexture());
		self:RefreshIconState();
	else
		self.Icon:SetAtlas("cdm-empty");
		self.Icon:SetDesaturated(false);
		self:RefreshAlertTypeOverlay();
	end
end

local function AnchorAlertTypeIcons(overlay)
	local firstAlertIcon = overlay.visibleIcons[1];
	if not firstAlertIcon then
		return;
	end

	local iconWidth = firstAlertIcon:GetWidth();
	local totalIconsWidth = (#overlay.visibleIcons * iconWidth) + ((#overlay.visibleIcons - 1) * 2);
	local overlayWidth = overlay:GetWidth();
	local firstIconOffset = (overlayWidth - totalIconsWidth) / 2;

	local anchor = CreateAnchor("LEFT", overlay, "LEFT", firstIconOffset, 0);
	local clearAllPoints = true;

	for index, icon in ipairs(overlay.visibleIcons) do
		anchor:SetPoint(icon, clearAllPoints);
		anchor:Set("LEFT", icon, "RIGHT", 2, 0);
	end
end

local function AddAlertTypeIcon(index, alertType, overlay)
	local asset = CooldownViewerAlert_GetTypeAtlas(alertType);
	if asset then
		local icon = overlay.icons[index];
		if not icon then
			icon = overlay:CreateTexture(nil, "ARTWORK");
			local size = overlay:GetHeight() - 2;
			icon:SetSize(size, size);

			overlay.icons[index] = icon;
		end

		icon:SetAtlas(asset);
		icon:Show();

		table.insert(overlay.visibleIcons, icon);
	end
end

local function HideAlertTypeIcons(overlay)
	for _, icon in ipairs(overlay.icons) do
		icon:Hide();
	end

	overlay.visibleIcons = {};
end

function CooldownViewerSettingsItemMixin:RefreshAlertTypeOverlay()
	local alertTypes = self:GetAllAlertTypes();
	if alertTypes then
		if not self.AlertTypesOverlay then
			local overlay = CreateFrame("Frame", nil, self);
			self.AlertTypesOverlay = overlay;
			overlay:SetPoint("BOTTOM", self.Icon, "BOTTOM", 0, 2);
			overlay:SetSize(34, 14); -- This used to be programatically determined, but then anchor setup ordering got in the way.

			overlay.BG = overlay:CreateTexture(nil, "BACKGROUND");
			overlay.BG:SetAllPoints(overlay);
			overlay.BG:SetColorTexture(0, 0, 0, 0.7);

			overlay.icons = {};
		end

		HideAlertTypeIcons(self.AlertTypesOverlay);

		for index, alertType in ipairs(alertTypes) do
			AddAlertTypeIcon(index, alertType, self.AlertTypesOverlay);
		end

		AnchorAlertTypeIcons(self.AlertTypesOverlay);

		self.AlertTypesOverlay:Show();
	elseif self.AlertTypesOverlay then
		self.AlertTypesOverlay:Hide();
	end
end

function CooldownViewerSettingsItemMixin:RefreshIconState()
	local info = self:GetCooldownInfo();
	assertsafe(info ~= nil, "Non empty cooldown with invalid info, id: " .. tostring(self:GetCooldownID()));

	self.Icon:SetDesaturated(not info.isKnown or self:IsReorderLocked());
	self:RefreshAlertTypeOverlay();
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
		GameTooltip_SetTitle(tooltip, COOLDOWN_VIEWER_SETTINGS_EMPTY_SLOT_TOOLTIP);
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

function CooldownViewerSettingsItemMixin:PlayAlertSample(alert)
	CooldownViewerAlert_PlayAlert(self, self:GetNameText(), alert);
end

do
	local function GetCooldownItemAlertButtonData(layoutManager, cooldownItem)
		local numAlerts = layoutManager:GetNumAlerts(cooldownItem:GetCooldownID(), Enum.CDMLayoutMode.AccessOnly);
		local maxAlerts = layoutManager:GetMaxNumAlertsPerItem();
		local status = layoutManager:GetAddAlertStatus(cooldownItem:GetCooldownID());

		-- The layout manager doesn't really care about spellcasting info, so it doesn't
		-- check which alert types can be added, that has to be checked by the UI that's about to add them
		if status == Enum.CooldownLayoutStatus.Success then
			if not cooldownItem:CanTriggerAnyAlertType() then
				status = Enum.CooldownLayoutStatus.NoValidAlerts;
			end
		end

		return numAlerts, maxAlerts, status;
	end

	local function GetNewAlertButtonText(numAlerts, maxAlerts, enabled)
		if enabled and numAlerts == 0 then
			return COOLDOWN_VIEWER_SETTINGS_ADD_NEW_ALERT;
		else
			return COOLDOWN_VIEWER_SETTINGS_ADD_ALERT:format(numAlerts, maxAlerts);
		end
	end

	local function AddNewAndClearAlertButtons(layoutManager, cooldownItem, rootDescription)
		local numAlerts, maxAlerts, addAlertStatus = GetCooldownItemAlertButtonData(layoutManager, cooldownItem);
		local addAlertEnabled = addAlertStatus == Enum.CooldownLayoutStatus.Success;
		local text = GetNewAlertButtonText(numAlerts, maxAlerts, addAlertEnabled);
		local newAlertButton = rootDescription:CreateButton(text, function()
			CooldownViewerSettingsEditAlert:DisplayForCooldown(cooldownItem);
		end);

		newAlertButton:SetEnabled(addAlertEnabled);

		if not addAlertEnabled then
			newAlertButton:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
				GameTooltip_AddErrorLine(tooltip, CooldownViewerSettings:GetActionStatusText(Enum.CooldownLayoutAction.AddAlert, addAlertStatus));
			end);
		end

		newAlertButton:AddInitializer(function(button, description, menu)
			local texture = button:AttachTexture();
			texture:SetPoint("LEFT");
			texture:SetAtlas(addAlertEnabled and "editmode-new-layout-plus" or "editmode-new-layout-plus-disabled", true);
			button.fontString:ClearAllPoints();
			button.fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);
		end);

		if numAlerts > 1 then
			local removeAllAlerts = rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_CLEAR_ALL_ALERTS, function()
				cooldownItem:RemoveAllAlerts();
			end);

			removeAllAlerts:AddInitializer(function(button, description, menu)
				local texture = button:AttachTexture();
				texture:SetSize(16, 16);
				texture:SetPoint("LEFT");
				texture:SetTexture([[Interface\Buttons\UI-GroupLoot-Pass-Up]]);
				button.fontString:ClearAllPoints();
				button.fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);
			end);
		end
	end

	local function AddExistingAlertButtons(layoutManager, cooldownItem, rootDescription)
		local alerts = layoutManager:GetAlerts(cooldownItem:GetCooldownID(), Enum.CDMLayoutMode.AccessOnly);
		if not alerts then
			return 0;
		end

		for _, alert in ipairs(alerts) do
			local payloadText = CooldownViewerAlert_GetPayloadText(alert);
			local eventText = CooldownViewerAlert_GetEventText(alert);
			local alertType = CooldownViewerAlert_GetType(alert);
			local alertButton = rootDescription:CreateButton("temp", function()
				cooldownItem:PlayAlertSample(alert);
			end, 1);

			alertButton:AddInitializer(function(button, description, menu)
				local playSampleButton = MenuTemplates.AttachBasicButton(button, 25, 25);
				playSampleButton:SetPoint("TOPLEFT");
				CooldownViewerAlert_SetupTypeButton(playSampleButton, alertType);
				MenuTemplates.SetUtilityButtonTooltipText(playSampleButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_PLAY_SAMPLE);
				MenuTemplates.SetUtilityButtonClickHandler(playSampleButton, function()
					cooldownItem:PlayAlertSample(alert);
				end);

				local payloadFontString = button.fontString;
				payloadFontString:SetFontObject("GameFontNormalLarge");
				payloadFontString:SetSize(0, 0);
				payloadFontString:ClearAllPoints();
				payloadFontString:SetPoint("TOPLEFT", playSampleButton, "TOPRIGHT", 3, 0);
				payloadFontString:SetText(payloadText);

				local eventFontString = button:AttachFontString();
				eventFontString:SetFontObject("GameFontHighlightSmall");
				eventFontString:SetSize(0, 0);
				eventFontString:ClearAllPoints();
				eventFontString:SetPoint("TOPLEFT", payloadFontString, "BOTTOMLEFT", 0, -5);
				eventFontString:SetText(eventText);

				local editButton = MenuTemplates.AttachAutoHideGearButton(button);
				MenuTemplates.SetUtilityButtonTooltipText(editButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_TOOLTIP_EDIT);
				MenuTemplates.SetUtilityButtonAnchor(editButton, MenuVariants.GearButtonAnchor, button);
				MenuTemplates.SetUtilityButtonClickHandler(editButton, function()
					CooldownViewerSettingsEditAlert:DisplayForAlert(cooldownItem, alert);
					menu:Close();
				end);

				local deleteButton = MenuTemplates.AttachAutoHideCancelButton(button);
				MenuTemplates.SetUtilityButtonTooltipText(deleteButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_TOOLTIP_DELETE);
				MenuTemplates.SetUtilityButtonAnchor(deleteButton, MenuVariants.CancelButtonAnchor, editButton);
				MenuTemplates.SetUtilityButtonClickHandler(deleteButton, function()
					cooldownItem:RemoveAlert(alert);
					menu:Close();
				end);
			end);
		end

		return #alerts;
	end

	function CooldownViewerSettingsItemMixin:DisplayContextMenu()
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("MENU_COOLDOWN_SETTINGS_ITEM");

			local layoutManager = CooldownViewerSettings:GetLayoutManager();

			if AddExistingAlertButtons(layoutManager, self, rootDescription) > 0 then
				rootDescription:CreateDivider();
			end

			AddNewAndClearAlertButtons(layoutManager, self, rootDescription);

			rootDescription:CreateDivider();

			-- Display category reassignment
			local menuCategories = CooldownViewerSettings:GetValidAssignmentCategories(self);
			for index, category in ipairs(menuCategories) do
				local changeCategoryButton = rootDescription:CreateButton(category:GetCategoryAssignmentText(), function()
					self:AssignToCategory(category);
				end);

				local changeCategoryStatus = layoutManager:GetCooldownCategoryChangeStatus(self:GetCooldownID(), category:GetCategory());
				local enableChangeCategoryButton = changeCategoryStatus == Enum.CooldownLayoutStatus.Success;
				changeCategoryButton:SetEnabled(enableChangeCategoryButton);

				if not enableChangeCategoryButton  then
					changeCategoryButton:SetTooltip(function(tooltip, elementDescription)
						GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
						GameTooltip_AddErrorLine(tooltip, CooldownViewerSettings:GetActionStatusText(Enum.CooldownLayoutAction.ChangeCategory, changeCategoryStatus));
					end);
				end
			end
		end);
	end
end

function CooldownViewerSettingsItemMixin:GetAllAlertTypes()
	local alerts = CooldownViewerSettings:GetLayoutManager():GetAlerts(self:GetCooldownID(), Enum.CDMLayoutMode.AccessOnly);
	if alerts and #alerts > 0 then
		local alertTypes = {};
		for _, alert in ipairs(alerts) do
			alertTypes[CooldownViewerAlert_GetType(alert)] = true;
		end

		return tInvertToArray(alertTypes);
	end

	return nil;
end

function CooldownViewerSettingsItemMixin:RemoveAlert(alert)
	CooldownViewerSettings:GetLayoutManager():RemoveAlert(self:GetCooldownID(), alert);
	self:RefreshAlertTypeOverlay();
end

function CooldownViewerSettingsItemMixin:RemoveAllAlerts()
	CooldownViewerSettings:GetLayoutManager():RemoveAllAlerts(self:GetCooldownID());
	self:RefreshAlertTypeOverlay();
end

function CooldownViewerSettingsItemMixin:AssignToCategory(category)
	local status = CooldownViewerSettings:GetDataProvider():SetCooldownToCategory(self:GetCooldownID(), category:GetCategory());
	CooldownViewerSettings:CheckDisplayActionStatus(Enum.CooldownLayoutAction.ChangeCategory, status);
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

	local forceSet = true;
	self:SetCooldownID(cooldownID, forceSet);
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

function CooldownViewerSettingsBarItemMixin:GetAlertTargetFrame()
	return self.AlertTarget;
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

function CooldownViewerSettingsMixin:GetExtraPanelWidth()
	return 50;
end

function CooldownViewerSettingsMixin:OnLoad()
	RegisterUIPanel(self, { area = "left", pushable = 1, extraWidth = self:GetExtraPanelWidth(), whileDead = 1});

	self:SetTitle(COOLDOWN_VIEWER_SETTINGS_TITLE);
	self.categoryObjects = CreateCategoryObjectLookup();
	self.categoryPool = CreateFramePoolCollection();
	self.categoryPool:CreatePool("Frame", self.CooldownScroll.Content, "CooldownViewerSettingsCategoryTemplate");
	self.categoryPool:CreatePool("Frame", self.CooldownScroll.Content, "CooldownViewerSettingsBarCategoryTemplate");

	self:SetLayoutManager(CreateFromMixins(CooldownViewerLayoutManagerMixin));
	self:SetDataProvider(CreateFromMixins(CooldownViewerSettingsDataProviderMixin));
	self:SetSerializer(CreateFromMixins(CooldownViewerDataStoreSerializationMixin));

	self:SetupTabs();
	self:SetupEventHandlers();
	self:SetupSettingsMenu();
	self:SetupPanelButtons();
	self:SetupScrollFrame();
	self:SetupEventEditFrame();
	self:SetupLayoutManagerDialog();
	self:SetupAlerts();

	local function LoadCooldownSettings()
		local manager = self:GetLayoutManager();
		local dataProvider = self:GetDataProvider();
		local serializer = self:GetSerializer();

		manager:Init(dataProvider, serializer);
		serializer:Init(manager);
		dataProvider:Init(manager);

		-- Just loaded, there's nothing that could be pending.
		-- Doing this here because it's always the last step in the load process
		manager:SetHasPendingChanges(false);
	end

	EventUtil.ContinueAfterAllEvents(LoadCooldownSettings, "VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "COOLDOWN_VIEWER_DATA_LOADED");
end

function CooldownViewerSettingsMixin:GetDataProvider()
	return self.dataProvider;
end

function CooldownViewerSettingsMixin:SetDataProvider(provider)
	self.dataProvider = provider;
end

function CooldownViewerSettingsMixin:GetLayoutManager()
	return self.layoutManager;
end

function CooldownViewerSettingsMixin:SetLayoutManager(manager)
	self.layoutManager = manager;
end

function CooldownViewerSettingsMixin:GetSerializer()
	return self.dataSerialization;
end

function CooldownViewerSettingsMixin:SetSerializer(serializer)
	self.dataSerialization = serializer;
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
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.OnDataChanged", self.RefreshLayout);
	self:AddDynamicEventMethod(EventRegistry, "CooldownViewerSettings.OnPendingChanges", self.UpdateSaveButtonStates);
end

function CooldownViewerSettingsMixin:SetupSettingsMenu()
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

function CooldownViewerSettingsMixin:CreateNewLayoutFromDialog(dialog)
	self:SaveCurrentLayout(); -- Auto-save the current layout if the user makes a new layout

	local layoutName = dialog:GetEditBoxText();
	local layoutInfo = dialog:GetLayoutInfo();

	if layoutInfo then
		self:ImportLayoutFromDialog(dialog);
	else
		local newLayout, status = self:GetLayoutManager():AddLayout(layoutName, CooldownViewerUtil.GetCurrentClassAndSpecTag());
		self:CheckDisplayActionStatus(Enum.CooldownLayoutAction.AddLayout, status, layoutName);

		if newLayout then
			self:SetActiveLayoutByID(CooldownManagerLayout_GetID(newLayout));
		end
	end
end

function CooldownViewerSettingsMixin:RenameLayoutFromDialog(dialog)
	self:GetLayoutManager():RenameLayout(dialog:GetLayoutIndex(), dialog:GetEditBoxText());
	self:SaveCurrentLayout();
end

function CooldownViewerSettingsMixin:DeleteLayoutFromDialog(dialog)
	self:GetLayoutManager():RemoveLayout(dialog:GetLayoutIndex());
	self:GetDataProvider():SwitchToBestLayoutForSpec();
	self:SaveCurrentLayout();
end

function CooldownViewerSettingsMixin:ImportLayoutFromDialog(dialog)
	self:GetLayoutManager():ImportLayout(dialog:GetEditBoxText(), dialog:GetLayoutInfo());
end

function CooldownViewerSettingsMixin:CopyLayoutToClipboard(layout)
	if layout then
		local layoutName = CooldownManagerLayout_GetName(layout);
		if self:GetLayoutManager():CopyLayoutToClipboard(layout) then
			ChatFrameUtil.DisplaySystemMessageInPrimary(COOLDOWN_VIEWER_SETTINGS_COPY_TO_CLIPBOARD_NOTICE:format(layoutName));
		end
	end
end

function CooldownViewerSettingsMixin:IsCharacterSpecificLayout(layout)
	return (layout.layoutType == Enum.EditModeLayoutType.Character);
end

function CooldownViewerSettingsMixin:GetLayoutName(layout)
	return layout.layoutName;
end

function CooldownViewerSettingsMixin:ValidateLayoutNameFromDialog(dialog)
	local editBoxText = dialog:GetEditBoxText();

	local hasValidInput = UserInputNonEmpty(editBoxText);
	if not hasValidInput then
		return false, COOLDOWN_VIEWER_SETTINGS_ERROR_ENTER_NAME;
	end

	if not self:GetLayoutManager():IsValidLayoutName(editBoxText) then
		return false, COOLDOWN_VIEWER_SETTINGS_ERROR_ENTER_NAME; -- TODO: Add custom string for this?
	end

	return true;
end

function CooldownViewerSettingsMixin:CanCreateNewLayoutFromDialog(dialog)
	local manager = self:GetLayoutManager();
	if manager:AreLayoutsFullyMaxed() then
		local maxLayoutsErrorText = COOLDOWN_VIEWER_SETTINGS_ERROR_MAX_LAYOUTS:format(manager:GetMaxLayoutsForType(Enum.CooldownLayoutType.Character), manager:GetMaxLayoutsForType(Enum.CooldownLayoutType.Account));
		return false, maxLayoutsErrorText;
	end

	local layoutType = dialog:GetDesiredLayoutType();
	if manager:AreLayoutsOfTypeMaxed(layoutType) then
		if layoutType == Enum.CooldownLayoutType.Character then
			local maxCharLayoutsErrorText = COOLDOWN_VIEWER_SETTINGS_ERROR_MAX_CHAR_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType);

			return false, maxCharLayoutsErrorText;
		else
			local maxAccountLayoutsErrorText = COOLDOWN_VIEWER_SETTINGS_ERROR_MAX_ACCOUNT_LAYOUTS:format(Constants.EditModeConsts.EditModeMaxLayoutsPerType);
			return false, maxAccountLayoutsErrorText;
		end
	end

	return self:ValidateLayoutNameFromDialog(dialog);
end

function CooldownViewerSettingsMixin:CanRenameLayoutFromDialog(dialog)
	return self:ValidateLayoutNameFromDialog(dialog);
end

function CooldownViewerSettingsMixin:CanImportFromDialog(dialog)
	local isEnabled, disabledTooltip = self:CanCreateNewLayoutFromDialog(dialog);
	if not isEnabled then
		return isEnabled, disabledTooltip;
	end

	if not dialog:GetLayoutInfo() then
		return false, COOLDOWN_VIEWER_SETTINGS_ERROR_ENTER_IMPORT_STRING_AND_NAME;
	end

	return true;
end

function CooldownViewerSettingsMixin:SetupLayoutManagerDropdown()
	self.LayoutDropdown:SetWidth(220);

	local layoutManager = self:GetLayoutManager();

	local function IsSelected(index)
		return layoutManager:GetActiveLayoutID() == index;
	end

	local function SetSelected(index)
		self:CheckSaveCurrentLayout();
		self:SetActiveLayoutByID(index);
	end

	local function IsStarterSelected()
		return layoutManager:GetActiveLayoutID() == nil;
	end

	local function SetStarterSelected()
		self:UseDefaultLayout();
	end

	self.LayoutDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COOLDOWN_SETTINGS_LAYOUTS");

		local lastLayoutType = nil;
		local addedCharacterSpecificHeader = false;
		for layoutID, layoutInfo in layoutManager:EnumerateLayouts() do
			local index = CooldownManagerLayout_GetID(layoutInfo);
			local layoutType = CooldownManagerLayout_GetType(layoutInfo);
			local layoutName = CooldownManagerLayout_GetName(layoutInfo);

			if layoutType == Enum.CooldownLayoutType.Character and not addedCharacterSpecificHeader then
				addedCharacterSpecificHeader = true;
				local characterName = GetClassColoredTextForUnit("player", COOLDOWN_VIEWER_SETTINGS_CHARACTER_LAYOUTS_HEADER:format(UnitNameUnmodified("player")));
				rootDescription:CreateTitle(characterName);
			end

			if lastLayoutType and lastLayoutType ~= layoutType then
				rootDescription:CreateDivider();
			end

			lastLayoutType = layoutType;

			local isUserLayout = layoutType == Enum.CooldownLayoutType.Account or layoutType == Enum.CooldownLayoutType.Character;
			local layoutButton = rootDescription:CreateRadio(layoutName, IsSelected, SetSelected, index);

			local canActivateLayout = layoutManager:CanActivateLayout(layoutInfo);
			layoutButton:SetEnabled(canActivateLayout);
			if not canActivateLayout then
				layoutButton:SetTooltip(function(tooltip, elementDescription)
					GameTooltip_SetTitle(tooltip, COOLDOWN_VIEWER_SETTINGS_ERROR_CANNOT_SWITCH_TO_LAYOUT);

					local whoIsItFor = CooldownViewerUtil.GetClassAndSpecTagText(CooldownManagerLayout_GetClassAndSpecTag(layoutInfo)) or UNKNOWN;
					if whoIsItFor then
						GameTooltip_AddErrorLine(tooltip, COOLDOWN_VIEWER_SETTINGS_ERROR_CANNOT_SWITCH_TO_LAYOUT_TOOLTIP_LINE:format(layoutName, whoIsItFor));
					end
				end);
			end

			if isUserLayout then
				-- Copy layout
				local copyLayoutButton = layoutButton:CreateButton(COOLDOWN_VIEWER_SETTINGS_COPY_LAYOUT, function()
					CooldownViewerLayoutDialog:ShowNewLayoutDialog(layoutManager:CopyLayout(layoutInfo));
				end);

				local copyLayoutDisableOnMaxLayouts = true;
				local copyLayoutDisableOnActiveChanges = false;
				EditModeLayoutManagerUtil.SetElementDescriptionEnabledState(copyLayoutButton, copyLayoutDisableOnMaxLayouts, copyLayoutDisableOnActiveChanges, layoutManager);

				-- Rename layout
				layoutButton:CreateButton(COOLDOWN_VIEWER_SETTINGS_RENAME_LAYOUT, function()
					CooldownViewerLayoutDialog:ShowRenameLayoutDialog(layoutID, layoutInfo);
				end);

				layoutButton:DeactivateSubmenu();

				layoutButton:AddInitializer(function(button, description, menu)
					local settingsButton = MenuTemplates.AttachAutoHideGearButton(button);
					MenuTemplates.SetUtilityButtonLockedEnabledState(settingsButton, true);
					MenuTemplates.SetUtilityButtonTooltipText(settingsButton, COOLDOWN_VIEWER_SETTINGS_RENAME_OR_COPY_LAYOUT);
					MenuTemplates.SetUtilityButtonAnchor(settingsButton, MenuVariants.GearButtonAnchor, button);
					MenuTemplates.SetUtilityButtonClickHandler(settingsButton, function()
						description:ForceOpenSubmenu();
					end);

					local deleteLayoutButton = MenuTemplates.AttachAutoHideCancelButton(button);
					MenuTemplates.SetUtilityButtonLockedEnabledState(deleteLayoutButton, true);
					MenuTemplates.SetUtilityButtonTooltipText(deleteLayoutButton, COOLDOWN_VIEWER_SETTINGS_DELETE_LAYOUT);
					MenuTemplates.SetUtilityButtonAnchor(deleteLayoutButton, MenuVariants.CancelButtonAnchor, settingsButton);
					MenuTemplates.SetUtilityButtonClickHandler(deleteLayoutButton, function()
						CooldownViewerLayoutDialog:ShowDeleteLayoutDialog(layoutID, layoutInfo);
						menu:Close();
					end);
				end);
			end
		end

		-- Only add the initial divider if layouts existed.
		if lastLayoutType then
			rootDescription:CreateDivider();
		end

		-- use starter layout
		rootDescription:CreateRadio(BLUE_FONT_COLOR:WrapTextInColorCode(COOLDOWN_VIEWER_SETTINGS_USE_STARTER_LAYOUT), IsStarterSelected, SetStarterSelected, 0);

		-- new layout
		local newLayoutDisableOnMaxLayouts = true;
		local newLayoutDisableOnActiveChanges = false;
		local disabled = EditModeLayoutManagerUtil.GetDisableReason(newLayoutDisableOnMaxLayouts, newLayoutDisableOnActiveChanges, layoutManager) ~= nil;
		local newLayoutButton = rootDescription:CreateButton(EditModeLayoutManagerUtil.GetNewLayoutText(disabled), function()
			CooldownViewerLayoutDialog:ShowNewLayoutDialog();
		end);
		EditModeLayoutManagerUtil.SetElementDescriptionEnabledState(newLayoutButton, newLayoutDisableOnMaxLayouts, newLayoutDisableOnActiveChanges, layoutManager);

		-- import layout
		local importLayoutDisableOnMaxLayouts = true;
		local importLayoutDisableOnActiveChanges = false;
		local importLayoutButton = rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT, function()
			CooldownViewerImportLayoutDialog:ShowImportLayoutDialog();
		end);
		EditModeLayoutManagerUtil.SetElementDescriptionEnabledState(importLayoutButton, importLayoutDisableOnMaxLayouts, importLayoutDisableOnActiveChanges, layoutManager);

		-- share
		local copyLayoutButton = rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_COPY_TO_CLIPBOARD, function()
			self:CopyLayoutToClipboard(layoutManager:GetActiveLayout());
		end);

		local canCopyLayout = layoutManager:GetActiveLayout() ~= nil;
		copyLayoutButton:SetEnabled(canCopyLayout);

		if not canCopyLayout then
			copyLayoutButton:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_SetTitle(tooltip, COOLDOWN_VIEWER_SETTINGS_ERROR_CANNOT_COPY_DEFAULT_LAYOUT);
				GameTooltip_AddErrorLine(tooltip, COOLDOWN_VIEWER_SETTINGS_ERROR_CANNOT_COPY_DEFAULT_LAYOUT_LINE);
			end);
		end
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

function CooldownViewerSettingsMixin:SetupEventEditFrame()
	CooldownViewerSettingsEditAlert:SetOwner(self);
end

function CooldownViewerSettingsMixin:SetupLayoutManagerDialog()
	CooldownViewerLayoutDialog:SetLayoutManager(self:GetLayoutManager());
	CooldownViewerLayoutDialog:SetModeData({
		newLayout = {
			title = COOLDOWN_VIEWER_SETTINGS_NAME_LAYOUT_DIALOG_TITLE,
			acceptText = SAVE,
			cancelText = CANCEL,
			disabledAcceptTooltip = COOLDOWN_VIEWER_SETTINGS_ERROR_ENTER_NAME,
			needsEditbox = true,
			needsCharacterSpecific = false, -- TODO: Will enable account layouts later
			onCancelEvent = nil,
			onAcceptCallback = function(_layoutManager, dialog)
				return self:CreateNewLayoutFromDialog(dialog);
			end,
			updateAcceptCallback = function(_layoutManager, dialog)
				return self:CanCreateNewLayoutFromDialog(dialog);
			end,
		},

		renameLayout = {
			title = COOLDOWN_VIEWER_SETTINGS_RENAME_LAYOUT_DIALOG_TITLE,
			acceptText = SAVE,
			cancelText = CANCEL,
			disabledAcceptTooltip = nil,
			needsEditbox = true,
			useLayoutNameForEditBox = true,
			needsCharacterSpecific = false, -- Account specific doesn't apply to this dialog
			onAcceptCallback = function(_layoutManager, dialog)
				return self:RenameLayoutFromDialog(dialog);
			end,
			updateAcceptCallback = function(_layoutManager, dialog)
				return self:ValidateLayoutNameFromDialog(dialog);
			end,
		},

		deleteLayout = {
			title = COOLDOWN_VIEWER_SETTINGS_DELETE_LAYOUT_DIALOG_TITLE,
			acceptText = YES,
			cancelText = NO,
			disabledAcceptTooltip = nil,
			needsEditbox = false,
			needsCharacterSpecific = false,
			onAcceptCallback = function(_layoutManager, dialog)
				return self:DeleteLayoutFromDialog(dialog);
			end,
			updateAcceptCallback = function() return true; end,
		},
	});

	CooldownViewerImportLayoutDialog:SetLayoutManager(self:GetLayoutManager());
	CooldownViewerImportLayoutDialog:SetModeData({
		importLayout = {
			title = COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT_DIALOG_TITLE,
			importEditBoxLabel = COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT_DIALOG_EDIT_BOX_LABEL,
			nameEditBoxLabel = COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT_LINK_DIALOG_EDIT_BOX_LABEL,
			instructionsLabel = COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT_INSTRUCTIONS,
			acceptText = COOLDOWN_VIEWER_SETTINGS_IMPORT_LAYOUT,
			cancelText = CANCEL,
			disabledAcceptTooltip = COOLDOWN_VIEWER_SETTINGS_ERROR_ENTER_IMPORT_STRING_AND_NAME,
			needsCharacterSpecific = false, -- TODO: Will enable account layouts later

			onAcceptCallback = function(_layoutManager, dialog)
				self:ImportLayoutFromDialog(dialog);
			end,

			onCancelCallback = function(_layoutManager, dialog)
				dialog:DeleteImportedLayouts();
			end,

			updateAcceptCallback = function(_layoutManager, dialog)
				return self:CanImportFromDialog(dialog);
			end,
		},
	});
end

function CooldownViewerSettingsMixin:SetupAlerts()
	for _index, visualAlertData in pairs(CooldownViewerVisualData) do
		CooldownViewerVisualAlertsManager:RegisterAlert(visualAlertData.enum, visualAlertData.animTemplate);
	end
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
			local status = self:GetDataProvider():SetCooldownToCategory(sourceItem:GetCooldownID(), targetItem:GetEmptyCategory():GetCategory());
			self:CheckDisplayActionStatus(Enum.CooldownLayoutAction.ChangeCategory, status);
		else
			local status = self:GetDataProvider():ChangeOrderIndex(sourceItem:GetOrderIndex(), targetItem:GetOrderIndex(), self.reorderOffset);
			self:CheckDisplayActionStatus(Enum.CooldownLayoutAction.ChangeOrder, status);
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
	assertsafe(item:GetCooldownInfo() ~= nil, "Source cooldown must have valid info, id: " .. tostring(item:GetCooldownID()));
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
	self:CheckSaveCurrentLayout();
	self:GetLayoutManager():DestroyRestorePoint();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);

	CallbackRegistrantMixin.OnHide(self);
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
	self:SetupLayoutManagerDropdown();
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

local function RunDataProviderCallbackThatRequiresSaveAndRefresh(settings, callback)
	callback();
	settings:SaveCurrentLayout();
	settings:RefreshLayout();
end

function CooldownViewerSettingsMixin:ResetCurrentToDefaults()
	RunDataProviderCallbackThatRequiresSaveAndRefresh(self, function() self:GetDataProvider():ResetCurrentToDefaults(); end);
end

function CooldownViewerSettingsMixin:UseDefaultLayout()
	RunDataProviderCallbackThatRequiresSaveAndRefresh(self, function() self:GetDataProvider():UseDefaultLayout(); end);
end

function CooldownViewerSettingsMixin:SetActiveLayoutByID(layoutID)
	RunDataProviderCallbackThatRequiresSaveAndRefresh(self, function() self:GetDataProvider():SetActiveLayoutByID(layoutID); end);
end

function CooldownViewerSettingsMixin:ResetToRestorePoint()
	RunDataProviderCallbackThatRequiresSaveAndRefresh(self, function() self:GetDataProvider():ResetToRestorePoint(); end);
end

function CooldownViewerSettingsMixin:SaveCurrentLayout()
	local layoutManager = self:GetLayoutManager();

	local savedSomething, isVerboseChange = layoutManager:SaveLayouts();

	-- If the user is actually editing layouts then we should create a restore point now, but
	-- if the settings frame is hidden, like with a rename dialog or a spec change, don't create
	-- a restore point since the user won't even expect a restore point to exist when they open
	-- the layout editing frame the next time.
	if self:IsShown() then
		layoutManager:CreateRestorePoint();
	end

	if savedSomething and isVerboseChange then
		UIErrorsFrame:AddExternalWarningMessage(COOLDOWN_VIEWER_SETTINGS_LAYOUT_SAVED_MESSAGE);
	end
end

function CooldownViewerSettingsMixin:CheckSaveCurrentLayout()
	local layoutManager = self:GetLayoutManager();
	if layoutManager:HasPendingChanges() then
		local activeLayout = layoutManager:GetActiveLayout();
		if activeLayout and CooldownManagerLayout_IsDefaultLayout(activeLayout) then
			-- This will show the rename dialog, but allow the new layout to be selected
			-- If the user doesn't complete the rename that's fine, the default layout will continue to have its default name.
			CooldownViewerLayoutDialog:ShowRenameLayoutDialog(CooldownManagerLayout_GetID(activeLayout), activeLayout);
			CooldownManagerLayout_SetIsDefault(activeLayout, false);
		end

		-- Always save layouts when selecting non-default layouts.
		self:SaveCurrentLayout();
	end
end

function CooldownViewerSettingsMixin:UpdateSaveButtonStates()
	self.UndoButton:SetEnabled(self:GetLayoutManager():CanUseRestorePoint());
end

local statusCodeToText =
{
	[Enum.CooldownLayoutStatus.InvalidLayoutName] = COOLDOWN_VIEWER_SETTINGS_ERROR_INVALID_LAYOUT_NAME,
	[Enum.CooldownLayoutStatus.TooManyLayouts] = COOLDOWN_VIEWER_SETTINGS_ADD_ALERT_TOOLTIP_DISABLED_MAXED_LAYOUTS,
	[Enum.CooldownLayoutStatus.AttemptToModifyDefaultLayoutWouldCreateTooManyLayouts] = COOLDOWN_VIEWER_SETTINGS_ERROR_TOO_MANY_LAYOUTS_TO_AUTO_MAKE_NEW_LAYOUT,
	[Enum.CooldownLayoutStatus.TooManyAlerts] = COOLDOWN_VIEWER_SETTINGS_ADD_ALERT_TOOLTIP_DISABLED_TOO_MANY,
	[Enum.CooldownLayoutStatus.NoValidAlerts] = COOLDOWN_VIEWER_SETTINGS_ADD_ALERT_TOOLTIP_DISABLED_NO_VALID,
}

local actionCodeToText =
{
	[Enum.CooldownLayoutAction.ChangeOrder] = COOLDOWN_VIEWER_SETTINGS_ACTION_CHANGE_ORDER_INDEX,
	[Enum.CooldownLayoutAction.ChangeCategory] = COOLDOWN_VIEWER_SETTINGS_ACTION_CHANGE_CATEGORY,
	[Enum.CooldownLayoutAction.AddLayout] = COOLDOWN_VIEWER_SETTINGS_ACTION_ADD_LAYOUT,
	[Enum.CooldownLayoutAction.AddAlert] = COOLDOWN_VIEWER_SETTINGS_ACTION_ADD_ALERT,
}

function CooldownViewerSettingsMixin:GetActionStatusText(action, status, ...)
	local actionEntry = actionCodeToText[action];
	local statusEntry = statusCodeToText[status];
	if actionEntry and statusEntry then
		return actionEntry:format(statusEntry:format(...));
	end
end

function CooldownViewerSettingsMixin:CheckDisplayActionStatus(action, status, ...)
	if status ~= Enum.CooldownLayoutStatus.Success then
		ChatFrameUtil.DisplaySystemMessageInPrimary(self:GetActionStatusText(action, status, ...));
	end
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
