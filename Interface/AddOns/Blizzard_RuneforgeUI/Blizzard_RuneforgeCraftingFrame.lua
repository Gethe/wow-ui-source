
RuneforgeCraftingFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RuneforgeCraftingFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function RuneforgeCraftingFrameMixin:OnLoad()
	self.flyoutSettings = {
		customFlyoutOnUpdate = nop,
		hasPopouts = true,
		parent = self:GetParent(),
		anchorX = 20,
		anchorY = -8,
		useItemLocation = true,
		hideFlyoutHighlight = true,
		alwaysHideOnClick = true,
	};

	local function SelectFlyoutItemButtonCallback(flyoutButton)
		self:SetItem(flyoutButton:GetItemLocation());
	end

	local function UpgradeItemValidation(itemLocation)
		return self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(itemLocation);
	end

	local function UpgradeItemSelectFlyoutItemButtonCallback(flyoutButton)
		self:SetUpgradeItem(flyoutButton:GetItemLocation());
	end

	local function CreateSettingsTable(filterFunction, selectionCallback, customBackground)
		return { filterFunction = filterFunction, selectionCallback = selectionCallback, customBackground = customBackground, };
	end

	self.flyoutTypeToSettings = {
		[RuneforgeUtil.FlyoutType.BaseItem] = CreateSettingsTable(C_LegendaryCrafting.IsValidRuneforgeBaseItem, SelectFlyoutItemButtonCallback, [[Interface\PaperDollInfoFrame\UI-GearManager-RuneCarving-Flyout]]),
		[RuneforgeUtil.FlyoutType.Legendary] = CreateSettingsTable(RuneforgeUtil.IsUpgradeableRuneforgeLegendary, SelectFlyoutItemButtonCallback, [[Interface\PaperDollInfoFrame\UI-GearManager-RuneCarvingUpgrade-Flyout]]),
		[RuneforgeUtil.FlyoutType.UpgradeItem] = CreateSettingsTable(UpgradeItemValidation, UpgradeItemSelectFlyoutItemButtonCallback, [[Interface\PaperDollInfoFrame\UI-GearManager-RuneCarving-Flyout]]),
	};
end

function RuneforgeCraftingFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self:RegisterRefreshMethod(self.Refresh);

	self:Refresh();
end

function RuneforgeCraftingFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, RuneforgeCraftingFrameEvents);

	self.PowerFrame:Hide();

	self.AnimWrapper.CrossFadeToBackground:Stop();
	self.AnimWrapper.CrossFadeToRuneLitBackground:Stop();
	self.AnimWrapper.Background:SetAlpha(1);
	self.AnimWrapper.RuneLitBackground:SetAlpha(0);
	
	self:UnregisterRefreshMethod();
end

function RuneforgeCraftingFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		if isRightButton or (not DoesAncestryInclude(self.PowerFrame, mouseFocus) and mouseFocus ~= self.PowerSlot) then
			self.PowerFrame:Hide();
		end

		if isRightButton or (not DoesAncestryInclude(self.ModifierFrame, mouseFocus)) then
			self.ModifierFrame:CloseSelector();
		end

		local flyoutSelected = not isRightButton and DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus);
		if not flyoutSelected then
			EquipmentFlyout_Hide();
		end

		if not flyoutSelected and (not DoesAncestryInclude(self.BaseItemSlot, mouseFocus)) then
			self.BaseItemSlot:SetSelectingItem(nil);
		end
	end
end

function RuneforgeCraftingFrameMixin:ShowFlyout(button, flyoutType)
	if flyoutType == nil then
		flyoutType = self:IsRuneforgeUpgrading() and RuneforgeUtil.FlyoutType.Legendary or RuneforgeUtil.FlyoutType.BaseItem;
	end

	self:SetDynamicFlyoutSettings(flyoutType);
	EquipmentFlyout_Show(button);
	PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_SELECTION_SUB_WINDOW);
end

function RuneforgeCraftingFrameMixin:SetDynamicFlyoutSettings(flyoutType)
	local settings = self.flyoutTypeToSettings[flyoutType];
	local filterFunction = settings.filterFunction;

	-- itemSlot is required by the API, but unused in this context.
	local function GetRuneforgeLegendariesCallback(itemSlot, resultsTable)
		self:GetRuneforgeFlyoutItemsCallback(filterFunction, resultsTable);
	end

	local flyoutSettings = self.flyoutSettings;
	flyoutSettings.getItemsFunc = GetRuneforgeLegendariesCallback;
	flyoutSettings.onClickFunc = settings.selectionCallback;
	flyoutSettings.customBackground = settings.customBackground;
end

function RuneforgeCraftingFrameMixin:SetUpgradeItem(item)
	self.UpgradeItemSlot:SetItem(item);
	StaticPopup_Hide("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT");
end

function RuneforgeCraftingFrameMixin:SetItem(item, autoSelectSlot)
	if item == nil then
		self.BaseItemSlot:SetItem(item);
	elseif self:IsRuneforgeUpgrading() then
		if autoSelectSlot and (self:GetItem() ~= nil) then
			if self:GetRuneforgeFrame():IsUpgradeItemValidForRuneforgeLegendary(item) then
				self:SetUpgradeItem(item);
			end
		elseif RuneforgeUtil.IsUpgradeableRuneforgeLegendary(item) then
			self.BaseItemSlot:SetItem(item);
		end
	else
		if C_LegendaryCrafting.IsValidRuneforgeBaseItem(item) then
			self.BaseItemSlot:SetItem(item);
		end
	end

	return false;
end

function RuneforgeCraftingFrameMixin:GetItem()
	return self.BaseItemSlot:GetItem();
end

function RuneforgeCraftingFrameMixin:GetUpgradeItem()
	return self.UpgradeItemSlot:GetItem();
end

function RuneforgeCraftingFrameMixin:SetPowerID(powerID)
	return self.PowerSlot:SetPowerID(powerID);
end

function RuneforgeCraftingFrameMixin:GetPowerID()
	return self.PowerSlot:GetPowerID();
end

function RuneforgeCraftingFrameMixin:GetModifiers()
	return self.ModifierFrame:GetModifiers();
end

function RuneforgeCraftingFrameMixin:TogglePowerList()
	if self.PowerFrame:IsShown() then
		self.PowerFrame:Hide();
	else
		PlaySound(SOUNDKIT.UI_RUNECARVING_OPEN_SELECTION_SUB_WINDOW);
		self.PowerFrame:OpenPowerList(self:GetRuneforgeFrame():GetPowers());
		self.PowerFrame:Show();
	end
end

function RuneforgeCraftingFrameMixin:Refresh()
	local hasItem = self:GetItem() ~= nil;
	local isUpgrading = self:IsRuneforgeUpgrading();
	local backgroundAtlas = isUpgrading and "runecarving-frame-upgrade-center-lit" or "runecarving-frame-center-lit";
	self.AnimWrapper.Background:SetAtlas(backgroundAtlas, TextureKitConstants.UseAtlasSize);

	if hasItem and (self.AnimWrapper.RuneLitBackground:GetAlpha() ~= 1.0) then
		self.AnimWrapper.CrossFadeToBackground:Stop();
		self.AnimWrapper.CrossFadeToRuneLitBackground:Play();
	elseif not hasItem and (self.AnimWrapper.Background:GetAlpha() ~= 1.0) then
		self.AnimWrapper.CrossFadeToRuneLitBackground:Stop();
		self.AnimWrapper.CrossFadeToBackground:Play();
	end

	self:GetRuneforgeFrame():SetRunesShown(hasItem);
	self.UpgradeItemSlot:SetShown(hasItem and isUpgrading);

	-- Stop any in-progress action on any refresh.
	StaticPopup_Hide("CONFIRM_RUNEFORGE_LEGENDARY_CRAFT");
	SpellStopCasting();
end

function RuneforgeCraftingFrameMixin:GetRuneforgeFlyoutItemsCallback(filterFunction, resultsTable)
	local function ItemLocationCallback(itemLocation)
		if filterFunction(itemLocation) then
			resultsTable[itemLocation] = C_Item.GetItemLink(itemLocation);
		end
	end

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);
end

function RuneforgeCraftingFrameMixin:GetRuneforgeFrame()
	return self:GetParent();
end
