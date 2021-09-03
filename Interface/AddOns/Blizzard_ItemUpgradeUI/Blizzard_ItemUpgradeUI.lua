UIPanelWindows["ItemUpgradeFrame"] = { area = "left", pushable = 0};

function ItemUpgradeFrame_Show()
	ShowUIPanel(ItemUpgradeFrame);
	if not ItemUpgradeFrame:IsShown() then
		C_ItemUpgrade.CloseItemUpgrade();
	end
end

function ItemUpgradeFrame_Hide()
	HideUIPanel(ItemUpgradeFrame);
end

ItemUpgradeMixin = {};

function ItemUpgradeMixin:OnLoad()
	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE");
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");

	self:SetPortraitToAsset("Interface\\Icons\\UI_ItemUpgrade");

	self:SetTitle(ITEM_UPGRADE);

	self.MicaFleckSheenSlide:Play();
	self.IdleGlowSlide:Play();

	self.UpgradeItemButton.IconBorder:SetSize(58, 58);
	self.UpgradeCostFrame:CreateLabel(ITEM_UPGRADE_COST_LABEL, nil, nil, 5);
	
	self.Dropdown = self.ItemInfo.Dropdown;
	UIDropDownMenu_Initialize(self.Dropdown, GenerateClosure(self.InitDropdown, self));
	UIDropDownMenu_SetWidth(self.Dropdown, 95);
end

function ItemUpgradeMixin:OnShow()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	self:Update();
	--TODO: Add function for filtering equipement frame as well as bags
	ItemButtonUtil.OpenAndFilterBags(self);

	self:RegisterEvent("BAG_UPDATE");
end

function ItemUpgradeMixin:OnHide()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	C_ItemUpgrade.CloseItemUpgrade();
	ItemButtonUtil.CloseFilteredBags(self);
	EquipmentFlyout_Hide(self);
	self.UpgradedFlash:Stop();

	self:UnregisterEvent("BAG_UPDATE");
end

function ItemUpgradeMixin:OnEvent(event, ...)
	if event == "ITEM_UPGRADE_MASTER_SET_ITEM" or event == "ITEM_UPGRADE_MASTER_UPDATE" or event == "BAG_UPDATE" then
		self:Update();
	elseif event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		local flyoutSelected = not isRightButton and DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus);
		if not flyoutSelected then
			EquipmentFlyout_Hide();
		end
	end
end

function ItemUpgradeMixin:OnConfirm()
	self:PlayUpgradedCelebration();
	C_ItemUpgrade.UpgradeItem();
end

function ItemUpgradeMixin:Update(fromDropDown)
    local numUpgradeLevels = 1;
	self.upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();

	self.UpgradeButton:SetDisabledState(not self.upgradeInfo);

	if not self.upgradeInfo then
		self.ItemInfo:Setup(self.upgradeInfo);
		SetItemButtonTexture(self.UpgradeItemButton, nil);
		SetItemButtonQuality(self.UpgradeItemButton, nil);
		self.UpgradeItemButton:SetNormalAtlas("itemupgrade_greenplusicon");
		self.UpgradeItemButton:SetPushedAtlas("itemupgrade_greenplusicon_pressed");
		self.UpgradeItemButton.EmptySlotGlow:Show();
		self.UpgradeItemButton.PulseEmptySlotGlow:Restart();
		self.MissingDescription:Show();
		self.LeftItemPreviewFrame:Hide();
		self.RightItemPreviewFrame:Hide();
		self.UpgradeCostFrame:Hide();
		self.PlayerCurrencies:Hide();
		self.FrameErrorText:Hide();
		self.Arrow:Hide();
		return;
	end

	self.UpgradeItemButton:SetNormalTexture(nil);
	self.UpgradeItemButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
	self.UpgradeItemButton.EmptySlotGlow:Hide();
	self.UpgradeItemButton.PulseEmptySlotGlow:Stop();

	if fromDropDown then
		numUpgradeLevels = fromDropDown - self.upgradeInfo.currUpgrade;
		UIDropDownMenu_SetSelectedValue(self.Dropdown, fromDropDown);
		UIDropDownMenu_SetText(self.Dropdown, ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT:format(fromDropDown));
	else
		UIDropDownMenu_SetSelectedValue(self.Dropdown, self.upgradeInfo.currUpgrade + 1);
		UIDropDownMenu_SetText(self.Dropdown, ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT:format(self.upgradeInfo.currUpgrade + 1));
	end

	self.upgradeInfo.itemQualityColor = ITEM_QUALITY_COLORS[self.upgradeInfo.displayQuality].color;

	SetItemButtonTexture(self.UpgradeItemButton, self.upgradeInfo.iconID);
	SetItemButtonQuality(self.UpgradeItemButton, self.upgradeInfo.displayQuality);

	self.MissingDescription:Hide();
	self:PopulatePreviewFrames(numUpgradeLevels);
end

function ItemUpgradeMixin:PopulatePreviewFrames(numUpgradeLevels)
	local itemMaxedOut =  self.upgradeInfo.currUpgrade >= self.upgradeInfo.maxUpgrade;
	local failureMessage = not itemMaxedOut and self.upgradeInfo.upgradeLevelInfos[numUpgradeLevels+1].failureMessage;
	local canUpgradeItem = self.upgradeInfo.itemUpgradeable and not itemMaxedOut and not failureMessage;

	if numUpgradeLevels > 1 then
		self.UpgradeButton:SetDisabledState(true);
		self.UpgradeButton:SetDisabledTooltip(ITEM_UPGRADE_FRAME_PREVIEW_RANK_TOOLTIP_ERROR);
	elseif canUpgradeItem  then
		self.UpgradeButton:SetDisabledState(false);
		self.FrameErrorText:Hide();
	elseif failureMessage then
		self.FrameErrorText:SetText(failureMessage);
		self.FrameErrorText:Show();
		self.UpgradeButton:SetDisabledState(true);
		self.UpgradeButton:SetDisabledTooltip(failureMessage);
	else
		self.FrameErrorText:SetText(ITEM_UPGRADE_NO_MORE_UPGRADES);
		self.FrameErrorText:Show();
		self.UpgradeButton:SetDisabledState(true);
		self.UpgradeButton:SetDisabledTooltip(ITEM_UPGRADE_NO_MORE_UPGRADES);
	end

	self.ItemInfo:Setup(self.upgradeInfo, canUpgradeItem);
	self.Arrow:SetPoint("CENTER", self.LeftItemPreviewFrame, "RIGHT", 8, 0);
	self.Arrow:SetShown(canUpgradeItem);

	self.LeftItemPreviewFrame:GeneratePreviewTooltip(false, nil);
	if canUpgradeItem then
		self.RightItemPreviewFrame:GeneratePreviewTooltip(true, nil);

		if self.RightItemPreviewFrame:GetHeight() > self.LeftItemPreviewFrame:GetHeight() then
			self.LeftItemPreviewFrame:SetHeight(self.RightItemPreviewFrame:GetHeight());
		end
	else
		self.RightItemPreviewFrame:Hide();
		self.UpgradeCostFrame:Hide();
		self.PlayerCurrencies:Hide();
		return;
	end

	self.UpgradeCostFrame:Clear();
	self.PlayerCurrencies:Clear();

	local currTotalUpgradeCosts = self:CalculateTotalCostTable(numUpgradeLevels);
	for currencyID, totalCurrencyCost in pairs(currTotalUpgradeCosts) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);

		if (totalCurrencyCost > currencyInfo.quantity) then
			self.UpgradeButton:SetDisabledState(true);
			self.UpgradeButton:SetDisabledTooltip();
			self.UpgradeCostFrame:AddCurrency(currencyID, totalCurrencyCost, RED_FONT_COLOR);
		else
			self.UpgradeCostFrame:AddCurrency(currencyID, totalCurrencyCost);
		end
		self.PlayerCurrencies:AddCurrency(currencyID);
	end

	self.UpgradeCostFrame:Show();
	self.PlayerCurrencies:Show();
end

-- compare 2 strings finding numeric differences
-- return the text of the 2nd string with (+x) in front of each number that is higher than in the 1st string
function ItemUpgradeMixin:GetTrinketUpgradeText(string1, string2)
	local output = "";
	local index2 = 1;	-- where we're at in string2

	local start1, end1, substring1 = string.find(string1, "([%d,%.]+)");
	local start2, end2, substring2 = string.find(string2, "([%d,%.]+)");
	while start1 and start2 do
		output = output .. string.sub(string2, index2, start2 - 1);
		if substring1 ~= substring2 then
			-- need to remove , and . because of locale
			local temp1 = gsub(substring1, "[,%.]", "");
			local temp2 = gsub(substring2, "[,%.]", "");
			local number1 = tonumber(temp1);
			local number2 = tonumber(temp2);
			if ( number1 and number2 and number2 > number1 ) then		-- if 2nd number isn't larger then something is wrong
				local diff = number2 - number1;
				output = output..GREEN_FONT_COLOR_CODE..string.format(ITEM_UPGRADE_BONUS_FORMAT, diff)..FONT_COLOR_CODE_CLOSE;
			end
		end
		output = output..substring2;
		index2 = end2 + 1;

		start1, end1, substring1 = string.find(string1, "([%d,%.]+)", end1 + 1);
		start2, end2, substring2 = string.find(string2, "([%d,%.]+)", end2 + 1);
	end
	output = output .. string.sub(string2, index2, string.len(string2));
	return output;
end

function ItemUpgradeMixin:CalculateTotalCostTable(numUpgradeLevels)
	local currTotalUpgradeCosts = {};

	for upgradeIndex = 1, numUpgradeLevels+1 do
		local upgradeLevel = self.upgradeInfo.upgradeLevelInfos[upgradeIndex];
		if not upgradeLevel then
			return;
		end

		for _, levelCost in ipairs(upgradeLevel.costsToUpgrade) do
			if not currTotalUpgradeCosts[levelCost.currencyID] then
				currTotalUpgradeCosts[levelCost.currencyID] = 0;
			end
			currTotalUpgradeCosts[levelCost.currencyID] = currTotalUpgradeCosts[levelCost.currencyID] + levelCost.cost; 
		end
	end
	return currTotalUpgradeCosts;
end

function ItemUpgradeMixin:InitDropdown()
	if not self.upgradeInfo then
		return;
	end

	local currUpgradeLevel = self.upgradeInfo.currUpgrade;
	local maxUpgradeLevel = self.upgradeInfo.maxUpgrade;

	local info = UIDropDownMenu_CreateInfo();
	for i = currUpgradeLevel + 1, maxUpgradeLevel do
		info.text = ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT:format(i);
		info.value = i;
		info.notCheckable = true;
		info.minWidth = 120;
		info.func = function() UIDropDownMenu_SetSelectedValue(ItemUpgradeFrame.Dropdown, i); 
							   ItemUpgradeFrame:Update(i); end;

		local costTable = ItemUpgradeFrame:CalculateTotalCostTable(i - currUpgradeLevel);
		local currencyTable = {};

		for currencyID, totalCurrencyCost in pairs(costTable) do
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
			if totalCurrencyCost > currencyInfo.quantity then
				currencyTable[#currencyTable + 1] = GetCurrencyString(currencyID, totalCurrencyCost, RED_FONT_COLOR_CODE);
			else
				currencyTable[#currencyTable + 1] = GetCurrencyString(currencyID, totalCurrencyCost);
			end
		end

		info.tooltipOnButton = 1;
		info.tooltipWhileDisabled = 1;
		info.tooltipTitle = table.concat(currencyTable, " ");
		UIDropDownMenu_AddButton(info);
	end
end

local upgradedSoundKits = {
	[Enum.ItemQuality.Rare] = SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED_RARE,
	[Enum.ItemQuality.Epic] = SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED_EPIC,
};

function ItemUpgradeMixin:PlayUpgradedSound()
	if self.upgradeInfo then
		local soundKit = upgradedSoundKits[self.upgradeInfo.displayQuality] or SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED;
		PlaySound(soundKit);
	end
end

function ItemUpgradeMixin:PlayUpgradedCelebration()
	self.LeftItemPreviewFrame.UpgradedAnim:Restart();
	self.RightItemPreviewFrame.UpgradedAnim:Restart();
	self.UpgradedFlash:Restart();
	self:PlayUpgradedSound();
end

ItemUpgradeButtonMixin = {};

function ItemUpgradeButtonMixin:OnClick()
	self:SetDisabledState(true);
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;
	local costTable = ItemUpgradeFrame:CalculateTotalCostTable(1);
	local currencyTable = {};
	for currencyID, totalCurrencyCost in pairs(costTable) do
		currencyTable[#currencyTable + 1] = GetCurrencyString(currencyID, totalCurrencyCost);
	end

	local data = {
		texture = upgradeInfo.iconID,
		name = upgradeInfo.name,
		color = {upgradeInfo.itemQualityColor:GetRGBA()},
		link = C_ItemUpgrade.GetItemHyperlink(),
	};

	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", table.concat(currencyTable, " "), "", data);
end

ItemUpgradePreviewMixin = {};

function ItemUpgradePreviewMixin:OnShow()
	if self.UpgradedAnim then
		self.UpgradedAnim:Stop();
		self.GlowAnimatedPieces:SetAlpha(0);
		self.GlowNineSlice:SetAlpha(0);
	end
end

function ItemUpgradePreviewMixin:OnEnter()
	if self.truncated then
		ItemUpgradeFrame.ItemHoverPreviewFrame:GeneratePreviewTooltip(self.isUpgrade, self);
	end
end

function ItemUpgradePreviewMixin:OnLeave()
	ItemUpgradeFrame.ItemHoverPreviewFrame:Hide();
end

--When changed will edit the max height a tooltip with the ItemUpgradePreviewMixin 
--will get before text starts to get truncated and a hover tooltip is shown
MAX_TOOLTIP_TRUNCATION_HEIGHT = 230;

function ItemUpgradePreviewMixin:GeneratePreviewTooltip(isUpgrade, parentFrame)
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;
	local itemLevel = C_ItemUpgrade.GetItemUpdateLevel();
	local numUpgradeLevels = UIDropDownMenu_GetSelectedValue(ItemUpgradeFrame.Dropdown) - upgradeInfo.currUpgrade;

	if parentFrame then
		self:SetOwner(parentFrame, "ANCHOR_NONE");
		self:SetPoint("LEFT", parentFrame, "RIGHT", 0, 0);
	else
		self:SetOwner(ItemUpgradeFrame, "ANCHOR_PRESERVE");
	end

	self:SetMinimumWidth(220, true);
	self:SetCustomLineSpacing(5);

	GameTooltip_AddDisabledLine(self, isUpgrade and ITEM_UPGRADE_NEXT_UPGRADE or ITEM_UPGRADE_CURRENT);
	GameTooltip_AddColoredLine(self, upgradeInfo.name, upgradeInfo.itemQualityColor);
	self:ApplyColorToGlowNiceSlice(upgradeInfo.itemQualityColor);

	if isUpgrade then
		local ilvlInc = C_ItemUpgrade.GetItemLevelIncrement(numUpgradeLevels);
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_ITEM_LEVEL_BONUS_STAT_FORMAT:format(itemLevel + ilvlInc, ilvlInc), false);
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:format(upgradeInfo.currUpgrade + numUpgradeLevels, upgradeInfo.maxUpgrade), false);
	else
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_ITEM_LEVEL_STAT_FORMAT:format(itemLevel), false);
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:format(upgradeInfo.currUpgrade, upgradeInfo.maxUpgrade), false);
	end

	-- Stats ----------------------------------------------------------------------------------------------
	local stats	= isUpgrade and upgradeInfo.upgradeLevelInfos[numUpgradeLevels + 1].levelStats or upgradeInfo.upgradeLevelInfos[1].levelStats;
	for _, statLine in ipairs(stats) do
		if statLine.active then
			GameTooltip_AddHighlightLine(self, statLine.displayString, false);
		end
	end

	--Trinket Text -----------------------------------------------------------------------------------------
	local text, upgradeText = C_ItemUpgrade.GetItemUpgradeEffect(1, numUpgradeLevels);
	if isUpgrade and upgradeText then
		text = ItemUpgradeFrame:GetTrinketUpgradeText(text, upgradeText);
	end

	if text then
		GameTooltip_AddBlankLineToTooltip(self);

		if not parentFrame then
			local bigText = isUpgrade and ItemUpgradeFrame.RightPreviewBigText or ItemUpgradeFrame.LeftPreviewBigText;
		
			--Temp to force calc height
			self:SetPadding(self:GetPadding());
			bigText:ClearAllPoints();
			bigText:SetPoint("TOP", self, "TOP", 0, 0);
			bigText:SetHeight(0);
			bigText:SetText(text);
		
			local maxHeight = MAX_TOOLTIP_TRUNCATION_HEIGHT - self:GetHeight();
			if bigText:GetStringHeight() > maxHeight then
				bigText:SetHeight(maxHeight);
				self.truncated = true;
			else
				self.truncated = false;
			end

			--Used to truncate the tooltipHeight down to fit the text in an effort to solve
			--spacing problem caused by the custom line spacing
			local actualTooltipHeight = self:GetHeight() + bigText:GetHeight() + 12;
			GameTooltip_InsertFrame(self, bigText);
			self:Show();
			self:SetHeight(actualTooltipHeight);
		else
			GameTooltip_AddHighlightLine(self, text, true);
		end
	end

	self:Show();
end

function ItemUpgradePreviewMixin:ApplyColorToGlowNiceSlice(color)
	if self.GlowNineSlice then
		for _, region in enumerate_regions(self.GlowNineSlice) do
			region:SetVertexColor(color:GetRGBA());
		end
	end
end

ItemUpgradeSlotMixin = {};

function ItemUpgradeSlotMixin:OnLoad()
	local function SetUpgradeableItemCallback(button)
		local location = button:GetItemLocation();
		C_ItemUpgrade.SetItemUpgradeFromLocation(location);
	end

	-- itemSlot is required by the API, but unused in this context.
	local function GetUpgradeableItemsCallback(itemSlot, resultsTable)
		self:GetItemUpgradeItemsCallBack(resultsTable);
	end

	--Using parent for the API
	self:GetParent().flyoutSettings = {
		customFlyoutOnUpdate = nop,
		hasPopouts = true,
		parent = self:GetParent():GetParent(),
		anchorX = 20,
		anchorY = -8,
		useItemLocation = true,
		hideFlyoutHighlight = true,
		alwaysHideOnClick = true,
		getItemsFunc = GetUpgradeableItemsCallback,
		onClickFunc = SetUpgradeableItemCallback,
		filterFunction = C_ItemUpgrade.CanUpgradeItem,
	};
end

function ItemUpgradeSlotMixin:GetItemUpgradeItemsCallBack(resultsTable)
	local function ItemLocationCallback(itemLocation)
		if C_ItemUpgrade.CanUpgradeItem(itemLocation) then
			resultsTable[itemLocation] = C_Item.GetItemLink(itemLocation);
		end
	end

	ContainerFrameUtil_IteratePlayerInventory(ItemLocationCallback);

	for i = EQUIPPED_FIRST, EQUIPPED_LAST do
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(i);
		if C_Item.DoesItemExist(itemLocation) then
			ItemLocationCallback(itemLocation);
		end
	end
end

function ItemUpgradeSlotMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetUpgradeItem();
	GameTooltip:Show();
end

function ItemUpgradeSlotMixin:OnLeave()
	GameTooltip:Hide();
end

function ItemUpgradeSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		C_ItemUpgrade.ClearItemUpgrade();
		return;
	end

	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem then
		if C_ItemUpgrade.CanUpgradeItem(cursorItem) then
			C_ItemUpgrade.SetItemUpgradeFromCursorItem();
			ClearCursor();
		end
	else
		EquipmentFlyout_Show(self);
	end
end

function ItemUpgradeSlotMixin:OnDrag()
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem then
		C_ItemUpgrade.SetItemUpgradeFromCursorItem();
		GameTooltip:Hide();
	end
end

ItemUpgradeItemInfoMixin = {};

function ItemUpgradeItemInfoMixin:Setup(upgradeInfo, canUpgrade)
	if not upgradeInfo then
		self.MissingItemText:Show();
		self.ItemName:Hide();
		self.UpgradeTo:Hide();
		self.Dropdown:Hide();
	else
		self.MissingItemText:Hide();

		self.ItemName:SetText(upgradeInfo.itemQualityColor:WrapTextInColorCode(upgradeInfo.name));
		self.ItemName:Show();

		self.UpgradeTo:SetShown(canUpgrade);
		self.Dropdown:SetShown(canUpgrade);
	end

	self:Layout();
end
