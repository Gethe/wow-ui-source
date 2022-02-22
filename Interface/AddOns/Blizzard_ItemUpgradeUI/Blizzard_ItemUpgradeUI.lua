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
	self:SetPortraitToAsset("Interface\\Icons\\UI_ItemUpgrade");

	self:SetTitle(ITEM_UPGRADE);

	self.MicaFleckSheenSlide:Play();
	self.IdleGlowSlide:Play();
	self.UpgradeButton.GlowAnim:Play();

	self.UpgradeItemButton.IconBorder:SetSize(58, 58);
	self.UpgradeCostFrame:CreateLabel(ITEM_UPGRADE_COST_LABEL, nil, nil, 5);
	self.Ring:SetPoint("CENTER", self.UpgradeButton, "CENTER", 0, 0);
	
	self.Dropdown = self.ItemInfo.Dropdown;
	UIDropDownMenu_Initialize(self.Dropdown, GenerateClosure(self.InitDropdown, self));
	UIDropDownMenu_SetWidth(self.Dropdown, 95);
end

function ItemUpgradeMixin:OnShow()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	self:Update();

	ItemButtonUtil.OpenAndFilterBags(self);

	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:RegisterEvent("ITEM_UPGRADE_FAILED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function ItemUpgradeMixin:OnHide()
	self:UnregisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:UnregisterEvent("ITEM_UPGRADE_FAILED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");

	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	C_ItemUpgrade.CloseItemUpgrade();
	ItemButtonUtil.CloseFilteredBags(self);
	EquipmentFlyout_Hide(self);
	self.AnimationHolder.UpgradedFlash:Stop();
	self.upgradeAnimationsInProgress = false;
end

function ItemUpgradeMixin:HasReachedTargetUpgradeLevel()
	if not self.targetUpgradeLevel then
		return true;
	end

	local upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();
	return upgradeInfo and upgradeInfo.currUpgrade >= self.targetUpgradeLevel;
end

function ItemUpgradeMixin:UpdateIfTargetReached()
	if self:HasReachedTargetUpgradeLevel() and not self.tooltipReappearTimerInProgress then
		self:Update();
	end
end

function ItemUpgradeMixin:OnEvent(event, ...)
	if event == "ITEM_UPGRADE_MASTER_SET_ITEM" then
		if not self.upgradeAnimationsInProgress then
			self:Update();
		end
		StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	elseif event == "BAG_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdateIfTargetReached();
	elseif event == "ITEM_UPGRADE_FAILED" or event == "DISPLAY_SIZE_CHANGED" then
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
	C_ItemUpgrade.UpgradeItem(self.numUpgradeLevels);
end

function ItemUpgradeMixin:Update(fromDropDown)
	self.upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();

	if not self.upgradeInfo then
		self:UpdateButtonAndArrowStates(true, false);
		self.ItemInfo:Setup(self.upgradeInfo);
		SetItemButtonTexture(self.UpgradeItemButton, nil);
		SetItemButtonQuality(self.UpgradeItemButton, nil);
		self.UpgradeItemButton:SetNormalAtlas("itemupgrade_greenplusicon");
		self.UpgradeItemButton:SetPushedAtlas("itemupgrade_greenplusicon_pressed");
		self.UpgradeItemButton.EmptySlotGlow:Show();
		self.UpgradeItemButton.PulseEmptySlotGlow:Restart();
		self.UpgradeButton:SetDisabledTooltip();
		self.MissingDescription:Show();
		self.LeftItemPreviewFrame:Hide();
		self.RightItemPreviewFrame.ReappearAnim:Stop();
		self.RightItemPreviewFrame:Hide();
		self.UpgradeCostFrame:Hide();
		self.PlayerCurrencies:Hide();
		self.FrameErrorText:Hide();
		self.Arrow:Hide();
		self.upgradeAnimationsInProgress = false;
		self.targetUpgradeLevel = nil;
		return;
	end

	self.UpgradeItemButton:SetNormalTexture(nil);
	self.UpgradeItemButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
	self.UpgradeItemButton.EmptySlotGlow:Hide();
	self.UpgradeItemButton.PulseEmptySlotGlow:Stop();

	if fromDropDown and (fromDropDown >  self.upgradeInfo.currUpgrade) and (fromDropDown <= self.upgradeInfo.maxUpgrade) then
		self.targetUpgradeLevel = fromDropDown;
	else
		self.targetUpgradeLevel = self.upgradeInfo.currUpgrade + 1;
	end
	self.numUpgradeLevels = self.targetUpgradeLevel - self.upgradeInfo.currUpgrade;

	self.currentUpgradeLevelInfo = self.upgradeInfo.upgradeLevelInfos[1] 
	self.targetUpgradeLevelInfo = self.upgradeInfo.upgradeLevelInfos[self.numUpgradeLevels + 1] 

	HideDropDownMenu(1);
	UIDropDownMenu_SetSelectedValue(self.Dropdown, self.targetUpgradeLevel);
	UIDropDownMenu_SetText(self.Dropdown, ITEM_UPGRADE_DROPDOWN_LEVEL_FORMAT:format(self.targetUpgradeLevel));

	self.upgradeInfo.itemQualityColor = ITEM_QUALITY_COLORS[self.upgradeInfo.displayQuality].color;
	self.upgradeInfo.targetQualityColor = self.targetUpgradeLevelInfo and ITEM_QUALITY_COLORS[self.targetUpgradeLevelInfo.displayQuality].color;

	SetItemButtonTexture(self.UpgradeItemButton, self.upgradeInfo.iconID);
	SetItemButtonQuality(self.UpgradeItemButton, self.upgradeInfo.displayQuality);

	self:CalculateTotalCostTable();

	self.MissingDescription:Hide();
	self:PopulatePreviewFrames();
end

function ItemUpgradeMixin:UpdateButtonAndArrowStates(buttonDisabled, canUpgrade)
	self.pendingButtonEnable = false;

	local isReappearAnimPlaying = self.RightItemPreviewFrame.ReappearAnim:IsPlaying();

	if buttonDisabled then
		self.UpgradeButton:SetEnabled(false);
	elseif not isReappearAnimPlaying then
		self.UpgradeButton:SetEnabled(true);
	else
		self.pendingButtonEnable = true;
	end

	if not canUpgrade then
		self.Arrow:Hide();
	elseif not isReappearAnimPlaying then
		self.Arrow.Anim:Restart();
		self.Arrow:Show();
	end
end

function ItemUpgradeMixin:PopulatePreviewFrames()
	local itemMaxedOut =  self.upgradeInfo.currUpgrade >= self.upgradeInfo.maxUpgrade;
	local failureMessage = itemMaxedOut and ITEM_UPGRADE_NO_MORE_UPGRADES or self.targetUpgradeLevelInfo.failureMessage;
	local canUpgradeItem = self.upgradeInfo.itemUpgradeable and not failureMessage;
	local showRightPreview = self.upgradeInfo.itemUpgradeable and not itemMaxedOut;

	local buttonDisabledState = true;

	self.UpgradeButton:SetDisabledTooltip();

	if canUpgradeItem  then
		buttonDisabledState = false;
		self.FrameErrorText:Hide();
	elseif showRightPreview then
		self.FrameErrorText:Hide();
		self.UpgradeButton:SetDisabledTooltip(failureMessage);
	else
		self.FrameErrorText:SetText(failureMessage);
		self.FrameErrorText:Show();
		self.UpgradeButton:SetDisabledTooltip(failureMessage);
	end

	self.ItemInfo:Setup(self.upgradeInfo, showRightPreview);

	self.LeftItemPreviewFrame:GeneratePreviewTooltip(false, nil);
	if showRightPreview then
		self.RightItemPreviewFrame:GeneratePreviewTooltip(true, nil);

		if self.RightItemPreviewFrame:GetHeight() > self.LeftItemPreviewFrame:GetHeight() then
			self.LeftItemPreviewFrame:SetHeight(self.RightItemPreviewFrame:GetHeight());
		end
	else
		self:UpdateButtonAndArrowStates(buttonDisabledState, showRightPreview);
		self.RightItemPreviewFrame.ReappearAnim:Stop();
		self.RightItemPreviewFrame:Hide();
		self.UpgradeCostFrame:Hide();
		self.upgradeAnimationsInProgress = false;

		local checkUpgrade = (self.upgradeInfo.currUpgrade > 1) and self.upgradeInfo.currUpgrade or (self.upgradeInfo.currUpgrade + 1);
		local currentUpgradeCosts = self:GetUpgradeCostTable(checkUpgrade);
		if currentUpgradeCosts then
			self.PlayerCurrencies:Clear();
			for currencyID, currencyCost in pairs(currentUpgradeCosts) do
				self.PlayerCurrencies:AddCurrency(currencyID);
			end
			self.PlayerCurrencies:Show();
		else
			self.PlayerCurrencies:Hide();
		end

		return;
	end

	if self.upgradeAnimationsInProgress then
		self.RightItemPreviewFrame:SetAlpha(0);
		self.RightItemPreviewFrame.ReappearAnim:Play();
	end

	self.UpgradeCostFrame:Clear();
	self.PlayerCurrencies:Clear();

	local currentUpgradeCosts = self:GetUpgradeCostTable();
	for currencyID, currencyCost in pairs(currentUpgradeCosts) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);

		if currencyCost > currencyInfo.quantity then
			buttonDisabledState = true;
			self.UpgradeCostFrame:AddCurrency(currencyID, currencyCost, RED_FONT_COLOR);
		else
			self.UpgradeCostFrame:AddCurrency(currencyID, currencyCost);
		end
		self.PlayerCurrencies:AddCurrency(currencyID);
	end

	self:UpdateButtonAndArrowStates(buttonDisabledState, showRightPreview);

	self.UpgradeCostFrame:Show();
	self.PlayerCurrencies:Show();
end

-- compare 2 strings finding numeric differences
-- return the text of the 2nd string with (+x) after each number that is higher than in the 1st string
function ItemUpgradeMixin:GetTrinketUpgradeText(string1, string2)
	local output = "";
	local index2 = 1;	-- where we're at in string2

	local start1, end1, substring1 = string.find(string1, "([%d,%.]+)");
	local start2, end2, substring2 = string.find(string2, "([%d,%.]+)");
	while start1 and start2 do
		output = output..string.sub(string2, index2, start2 - 1);
		
		local diff;
		if substring1 ~= substring2 then
			-- need to remove , and . because of locale
			local temp1 = gsub(substring1, "[,%.]", "");
			local temp2 = gsub(substring2, "[,%.]", "");
			local number1 = tonumber(temp1);
			local number2 = tonumber(temp2);
			if number1 and number2 and number2 > number1 then
				diff = number2 - number1;
			end
		end

		if diff then
			output = output..ITEM_UPGRADE_BONUS_FORMAT_COLORIZED:format(substring2, diff);
		else
			output = output..substring2;
		end

		index2 = end2 + 1;

		start1, end1, substring1 = string.find(string1, "([%d,%.]+)", end1 + 1);
		start2, end2, substring2 = string.find(string2, "([%d,%.]+)", end2 + 1);
	end
	output = output .. string.sub(string2, index2, string.len(string2));
	return output;
end

function ItemUpgradeMixin:CalculateTotalCostTable()
	self.upgradeCosts = {};

	for _, upgradeLevelInfo in ipairs(self.upgradeInfo.upgradeLevelInfos) do
		local previousRank = upgradeLevelInfo.upgradeLevel - 1;

		local levelCostTable;
		if previousRank > self.upgradeInfo.currUpgrade and self.upgradeCosts[previousRank] then
			levelCostTable = CopyTable(self.upgradeCosts[previousRank], true);
		else
			levelCostTable = {};
		end

		for _, levelCost in ipairs(upgradeLevelInfo.costsToUpgrade) do
			local currentCost = levelCostTable[levelCost.currencyID] or 0;
			levelCostTable[levelCost.currencyID] = currentCost + levelCost.cost; 
		end

		self.upgradeCosts[upgradeLevelInfo.upgradeLevel] = levelCostTable;
	end
end

function ItemUpgradeMixin:GetUpgradeCostTable(upgradeLevel)
	return self.upgradeCosts[upgradeLevel or self.targetUpgradeLevel];
end

function ItemUpgradeMixin:GetUpgradeCostString(upgradeLevel)
	local currencyStringTable = {};
	local checkQuantity = (upgradeLevel ~= nil);

	local costTable = self:GetUpgradeCostTable(upgradeLevel);
	for currencyID, currencyCost in pairs(costTable) do
		local hasEnough = true;
		if checkQuantity then
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
			hasEnough = currencyCost <= currencyInfo.quantity
		end

		if not hasEnough then
			table.insert(currencyStringTable, GetCurrencyString(currencyID, currencyCost, RED_FONT_COLOR_CODE));
		else
			table.insert(currencyStringTable, GetCurrencyString(currencyID, currencyCost));
		end
	end

	return table.concat(currencyStringTable, " ");
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
		info.func = function() UIDropDownMenu_SetSelectedValue(ItemUpgradeFrame.Dropdown, i); ItemUpgradeFrame:Update(i); end;

		info.tooltipOnButton = 1;
		info.tooltipWhileDisabled = 1;
		info.tooltipTitle = ItemUpgradeFrame:GetUpgradeCostString(i);

		UIDropDownMenu_AddButton(info);
	end
end

local upgradedSoundKits = {
	[Enum.ItemQuality.Rare] = SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED_RARE,
	[Enum.ItemQuality.Epic] = SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED_EPIC,
};

local tooltipReappearWaitTime = 1.5;

function ItemUpgradeMixin:PlayUpgradedCelebration()
	self.upgradeAnimationsInProgress = true;

	self.LeftItemPreviewFrame:GeneratePreviewTooltip(true, nil);
	self.ItemInfo.ItemName:SetText(self.upgradeInfo.targetQualityColor:WrapTextInColorCode(self.upgradeInfo.name));
	SetItemButtonQuality(self.UpgradeItemButton, self.targetUpgradeLevelInfo.displayQuality);

	self.LeftItemPreviewFrame.UpgradedAnim:Restart();
	self.RightItemPreviewFrame:SetAlpha(0);
	self.Arrow:Hide();
	self.AnimationHolder.UpgradedFlash:Restart();

	local soundKit = upgradedSoundKits[self.targetUpgradeLevelInfo.displayQuality] or SOUNDKIT.UI_ITEM_UPGRADE_UI_ITEM_UPGRADED;
	PlaySound(soundKit);

	self.tooltipReappearTimerInProgress = true;
	C_Timer.After(tooltipReappearWaitTime, GenerateClosure(self.OnTooltipReappearTimerComplete, self));
end

function ItemUpgradeMixin:OnTooltipReappearTimerComplete()
	self.tooltipReappearTimerInProgress = false;
	self:UpdateIfTargetReached();
end

function ItemUpgradeMixin:OnTooltipReappearComplete()
	self.Arrow.Anim:Restart();
	self.Arrow:Show();

	if self.pendingButtonEnable then
		self.UpgradeButton:SetEnabled(true);
	end

	self.upgradeAnimationsInProgress = false;
end

ItemUpgradeButtonMixin = {};

function ItemUpgradeButtonMixin:OnClick()
	self:SetEnabled(false);
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;

	local function StaticPopupItemOnEnter(itemFrame)
		GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetUpgradeItem();
		GameTooltip:Show();
	end

	local data = {
		texture = upgradeInfo.iconID,
		name = upgradeInfo.name,
		color = {upgradeInfo.itemQualityColor:GetRGBA()},
		link = C_ItemUpgrade.GetItemHyperlink(),
		itemFrameOnEnter = StaticPopupItemOnEnter,
	};

	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", ItemUpgradeFrame:GetUpgradeCostString(), "", data);
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

local MAX_TOOLTIP_TRUNCATION_HEIGHT = 245;
local TOOLTIP_MIN_WIDTH = 230.4;
local TOOLTIP_LINE_HEIGHT = 17;
local TOOLTIP_LINE_SPACING = 5;

function ItemUpgradePreviewMixin:GeneratePreviewTooltip(isUpgrade, parentFrame)
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;
	local currentItemLevel, isPvpItemLevel = C_ItemUpgrade.GetItemUpgradeCurrentLevel();
	local numUpgradeLevels = ItemUpgradeFrame.numUpgradeLevels;
	local upgradeLevelInfo = isUpgrade and ItemUpgradeFrame.targetUpgradeLevelInfo or ItemUpgradeFrame.currentUpgradeLevelInfo;

	if parentFrame then
		self:SetOwner(parentFrame, "ANCHOR_NONE");
		self:SetPoint("LEFT", parentFrame, "RIGHT", 0, 0);
	else
		self:SetOwner(ItemUpgradeFrame, "ANCHOR_PRESERVE");
	end

	self:SetMinimumWidth(TOOLTIP_MIN_WIDTH, true);
	self:SetCustomLineSpacing(TOOLTIP_LINE_SPACING);

	local itemQualityColor = isUpgrade and upgradeInfo.targetQualityColor or upgradeInfo.itemQualityColor;

	GameTooltip_AddDisabledLine(self, isUpgrade and ITEM_UPGRADE_NEXT_UPGRADE or ITEM_UPGRADE_CURRENT);
	GameTooltip_AddColoredLine(self, upgradeInfo.name, itemQualityColor);
	self:ApplyColorToGlowNiceSlice(itemQualityColor);

	if isUpgrade and not parentFrame then
		ItemUpgradeFrame.Ring:SetVertexColor(itemQualityColor:GetRGB());
	end

	local itemLevelUpgraded = isUpgrade and (upgradeLevelInfo.itemLevelIncrement > 0);
	if itemLevelUpgraded then
		local itemLevelFormatString = isPvpItemLevel and ITEM_UPGRADE_PVP_ITEM_LEVEL_BONUS_STAT_FORMAT or ITEM_UPGRADE_ITEM_LEVEL_BONUS_STAT_FORMAT;
		GameTooltip_AddNormalLine(self, itemLevelFormatString:format(currentItemLevel + upgradeLevelInfo.itemLevelIncrement, upgradeLevelInfo.itemLevelIncrement), false);
	else
		local itemLevelFormatString = isPvpItemLevel and ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT or ITEM_UPGRADE_ITEM_LEVEL_STAT_FORMAT;
		GameTooltip_AddNormalLine(self, itemLevelFormatString:format(currentItemLevel), false);
	end

	if isUpgrade then
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:format(upgradeInfo.currUpgrade + numUpgradeLevels, upgradeInfo.maxUpgrade), false);
	else
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:format(upgradeInfo.currUpgrade, upgradeInfo.maxUpgrade), false);
	end

	-- Stats ----------------------------------------------------------------------------------------------
	for _, statLine in ipairs(upgradeLevelInfo.levelStats) do
		if statLine.active then
			GameTooltip_AddHighlightLine(self, statLine.displayString, false);
		end
	end

	--Effect Text -----------------------------------------------------------------------------------------
	local effectText = nil;
	for index = 1, C_ItemUpgrade.GetNumItemUpgradeEffects() do
		local originalText, upgradeText = C_ItemUpgrade.GetItemUpgradeEffect(index, numUpgradeLevels);
		if isUpgrade and upgradeText then
			effectText = ItemUpgradeFrame:GetTrinketUpgradeText(originalText, upgradeText);
			break; 
		elseif originalText then 
			effectText = originalText;
			break; 
		end
	end 

	local pvpItemLevel, newPvpItemLevel = C_ItemUpgrade.GetItemUpgradePvpItemLevelDeltaValues(numUpgradeLevels);
	local pvpItemLevelText = pvpItemLevel and PVP_ITEM_LEVEL_TOOLTIP:format(isUpgrade and newPvpItemLevel or pvpItemLevel);

	local bigText;
	if not parentFrame then
		bigText = isUpgrade and ItemUpgradeFrame.RightPreviewBigText or ItemUpgradeFrame.LeftPreviewBigText;
		bigText:Hide();
	end

	if effectText or pvpItemLevelText then
		GameTooltip_AddBlankLineToTooltip(self);
	end

	self.truncated = false;
	self:SetPadding(0, 6);	-- This needs to be done after the above lines are set in order to get an accurate tooltip height below

	if effectText then
		if bigText then
			bigText:ClearAllPoints();
			bigText:SetPoint("TOP", self, "TOP", 0, 0);
			bigText:SetHeight(0);

			local maxTextHeight = MAX_TOOLTIP_TRUNCATION_HEIGHT - self:GetHeight();
			if pvpItemLevelText then
				-- There will be an extra line at the end, so deduct that from the available height
				bigText:SetText(pvpItemLevelText);
				maxTextHeight = maxTextHeight - bigText:GetStringHeight() - TOOLTIP_LINE_HEIGHT - TOOLTIP_LINE_SPACING;
			end

			bigText:SetHeight(0);
			bigText:SetText(effectText);

			if bigText:GetStringHeight() > maxTextHeight then
				self.truncated = true;
				bigText:SetHeight(maxTextHeight);

				local truncatedHeight = bigText:GetStringHeight();
				local usedHeight = GameTooltip_InsertFrame(self, bigText);
				local extraHeight = usedHeight - truncatedHeight;

				if not pvpItemLevelText and extraHeight > 0 then
					self:SetPadding(0, 6 - extraHeight);
				end
			else
				GameTooltip_AddHighlightLine(self, effectText, true);

				if pvpItemLevelText then
					GameTooltip_AddBlankLineToTooltip(self);
				end
			end
		else
			GameTooltip_AddHighlightLine(self, effectText, true);
		end
	end

	if pvpItemLevelText then
		GameTooltip_AddInstructionLine(self, pvpItemLevelText, true);
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

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);
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
