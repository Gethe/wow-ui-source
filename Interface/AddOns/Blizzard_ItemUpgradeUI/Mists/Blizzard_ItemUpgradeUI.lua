
UIPanelWindows["ItemUpgradeFrame"] = { area = "left", pushable = 0};

ITEM_UPGRADE_MAX_STATS_SHOWN = 10;

ItemUpgradeMixin = {};
ItemUpgradeUpgradeButtonMixin = {};
ItemUpgradeCurrencyMixin = {};
ItemUpgradeItemMixin = {};

function ItemUpgradeFrame_Show()
	ShowUIPanel(ItemUpgradeFrame);
	if(not ItemUpgradeFrame:IsShown()) then
		C_ItemUpgrade.CloseItemUpgrade();
	end
end

function ItemUpgradeFrame_Hide()
	HideUIPanel(ItemUpgradeFrame);
end

function ItemUpgradeMixin:OnLoad()
	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE");

	ItemUpgradeFramePortrait:SetPortraitToAsset("Interface\\Icons\\Spell_Shaman_SpectralTransformation");
	self.LeftStat[1].BG:Show();
	self.RightStat[1].BG:Show();
	ItemUpgradeFrameTitleText:SetText(ITEM_UPGRADE);
	ItemUpgradeFrameTopTileStreaks:Hide();
	ItemUpgradeFrameBg:Hide();
end

function ItemUpgradeMixin:OnShow()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	self:Update();
	
	ItemUpgradeFrameMoneyFrame:Show();

	OpenAllBags();
end

function ItemUpgradeMixin:OnHide()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	C_ItemUpgrade.CloseItemUpgrade();

	C_ItemUpgrade.ClearItemUpgrade();
	self:HideStatsLeft();
	self:HideStatsRight();
	ItemUpgradeFrame.LeftItemLevel:Hide();
	ItemUpgradeFrame.RightItemLevel:Hide();
end

function ItemUpgradeMixin:OnEvent(event, ...)
	if ( event == "ITEM_UPGRADE_MASTER_SET_ITEM" ) then
		self:Update();
	elseif ( event == "ITEM_UPGRADE_MASTER_UPDATE" ) then
		self:Update();
		self.FinishedGlow.FinishedAnim:Play();
		self.ItemUpgradedNotification:Show();
		self.ItemUpgradedNotification.FinishedAnim:Play();
	end
end

function ItemUpgradeFrame_GetUpgradeInfo(info, afterUpgrade)
	local itemUpgradeInfo = info or C_ItemUpgrade.GetItemUpgradeItemInfo();

	if not itemUpgradeInfo then
		return;
	end

	local numCurrUpgrades = itemUpgradeInfo.currUpgrade;
	local numMaxUpgrades = itemUpgradeInfo.maxUpgrade;
	
	local index = numCurrUpgrades + 1; -- Zero-indexed to add 1

	if afterUpgrade then
		index = index + 1;
	end

	return itemUpgradeInfo.upgradeLevelInfos[index];
end

function ItemUpgradeMixin:Update()
	local itemUpgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();
	local nextUpgradeInfo = nil;
	local upgradeCost = nil;

	ItemUpgradeFrameUpgradeButton:Disable();
	
	local ItemUpgradeFrame = ItemUpgradeFrame;
	if itemUpgradeInfo then

		local numCurrUpgrades = itemUpgradeInfo.currUpgrade;
		local numMaxUpgrades = itemUpgradeInfo.maxUpgrade;

		nextUpgradeInfo = ItemUpgradeFrame_GetUpgradeInfo(itemUpgradeInfo, true);

		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture(itemUpgradeInfo.iconID);
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = C_Item.GetItemQualityColor(itemUpgradeInfo.displayQuality);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("|c"..hex..itemUpgradeInfo.name.."|r");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText(itemUpgradeInfo.customUpgradeString or "");
		ItemUpgradeFrame.ItemButton.MissingText:Hide();	
		ItemUpgradeFrame.MissingDescription:Hide();
		ItemUpgradeFrame.MissingFadeOut:Hide();
		ItemUpgradeFrame.TitleTextLeft:Show();
		ItemUpgradeFrame.TitleTextRight:Show();
		ItemUpgradeFrame.HorzBar:Show();

		if nextUpgradeInfo then
			upgradeCost = nextUpgradeInfo.currencyCostsToUpgrade[1];
			ItemUpgradeFrame.ItemButton.Cost.Amount:SetText(upgradeCost.cost);
			local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(upgradeCost.currencyID);
			ItemUpgradeFrame.ItemButton.Cost.Icon:SetTexture(currencyInfo.icon);
			ItemUpgradeFrame.ItemButton.Cost.currencyID = upgradeCost.currencyID;
		end

		local canUpgradeItem = false;
		if(numCurrUpgrades and numMaxUpgrades) then
			ItemUpgradeFrame.UpgradeStatus:SetText(numCurrUpgrades.."/"..numMaxUpgrades);
			ItemUpgradeFrame.UpgradeStatus:Show();
			if ( numCurrUpgrades < numMaxUpgrades ) then
				ItemUpgradeFrame.UpgradeStatus:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				canUpgradeItem = true;
			else
				ItemUpgradeFrame.UpgradeStatus:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);			
			end
			ItemUpgradeFrameUpgradeButton:SetEnabled(numCurrUpgrades < numMaxUpgrades);
		end
		if ( canUpgradeItem ) then
			ItemUpgradeFrame.ItemButton.Cost.Amount:Show();
			ItemUpgradeFrame.ItemButton.Cost.Icon:Show();
			ItemUpgradeFrame.NoMoreUpgrades:Hide();
		else
			ItemUpgradeFrame.ItemButton.Cost.Icon:Hide();
			ItemUpgradeFrame.ItemButton.Cost.Amount:Hide();
			ItemUpgradeFrame.NoMoreUpgrades:Show();
		end
		
		self:UpdateStats(canUpgradeItem);
	else	-- There is no item so hide elements
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText("");
		ItemUpgradeFrame.ItemButton.MissingText:Show();	
		ItemUpgradeFrame.ItemButton.Cost.Icon:Hide();
		ItemUpgradeFrame.ItemButton.Cost.Amount:Hide();
		ItemUpgradeFrame.MissingDescription:Show();
		ItemUpgradeFrame.MissingFadeOut:Show();
		ItemUpgradeFrame.TitleTextLeft:Hide();
		ItemUpgradeFrame.TitleTextRight:Hide();
		ItemUpgradeFrame.UpgradeStatus:Hide();
		ItemUpgradeFrame.HorzBar:Hide();
		ItemUpgradeFrame.LeftItemLevel:Hide();
		ItemUpgradeFrame.RightItemLevel:Hide();
		ItemUpgradeFrame.NoMoreUpgrades:Hide();
		for _, item in pairs(ItemUpgradeFrame.LeftStat) do
			item:Hide();
		end
		for _, item in pairs(ItemUpgradeFrame.RightStat) do
			item:Hide();
		end
		for _, item in pairs(ItemUpgradeFrame.EffectRow) do
			item:Hide();
		end
	end
	
	-- update player's currency
	if nextUpgradeInfo then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(upgradeCost.currencyID);

		ItemUpgradeFrameMoneyFrame.Currency.currencyID = upgradeCost.currencyID;
		ItemUpgradeFrameMoneyFrame.Currency.icon:SetTexture(currencyInfo.iconFileID);
		ItemUpgradeFrameMoneyFrame.Currency.count:SetText(currencyInfo.quantity);
		ItemUpgradeFrameMoneyFrame.Currency:Show();
		if ( upgradeCost.cost > currencyInfo.quantity ) then
			ItemUpgradeFrameUpgradeButton:Disable();
			ItemUpgradeFrameMoneyFrame.Currency.count:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			ItemUpgradeFrameMoneyFrame.Currency.count:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		ItemUpgradeFrameMoneyFrame.Currency:Hide();
	end
end

function ItemUpgradeUpgradeButtonMixin:UpgradeClick()
	ItemUpgradeFrameUpgradeButton:Disable();

	local upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();
	local nextUpgrade = ItemUpgradeFrame_GetUpgradeInfo(upgradeInfo, true);
	local upgradeCost = nextUpgrade.currencyCostsToUpgrade[1];

	local icon = upgradeInfo.iconID;
	
	local r, g, b = C_Item.GetItemQualityColor(nextUpgrade.displayQuality);
	
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(upgradeCost.currencyID);
	local itemsString = " |T"..currencyInfo.iconFileID..":0:0:0:-1|t "..format(CURRENCY_QUANTITY_TEMPLATE, upgradeCost.cost, currencyInfo.name);

	local data = {
		texture = icon,
		name = upgradeInfo.name,
		color = {r, g, b, 1},
		link = C_ItemUpgrade.GetItemHyperlink(),
	};

	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", itemsString, "", data);
end

function ItemUpgradeItemMixin:AddItemClick(button)
	C_ItemUpgrade.SetItemUpgradeFromCursorItem();
	GameTooltip:Hide();
end

function ItemUpgradeMixin:UpdateStats(setStatsRight)

	local itemInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();

	if not itemInfo then
		return;
	end

	local currentUpgradeInfo = ItemUpgradeFrame_GetUpgradeInfo(itemInfo, false);
	local nextUpgradeInfo = ItemUpgradeFrame_GetUpgradeInfo(itemInfo, true);

	if not currentUpgradeInfo then
		return;
	end

	local itemLevel	= currentUpgradeInfo.upgradeLevel + currentUpgradeInfo.itemLevelIncrement;
	local ilvlInc = nextUpgradeInfo and nextUpgradeInfo.itemLevelIncrement;
	
	ItemUpgradeFrame.LeftItemLevel.iLvlText:SetText(itemLevel);
	ItemUpgradeFrame.LeftItemLevel.ItemLevelText:SetText(ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL);
	ItemUpgradeFrame.LeftItemLevel:Show();
	
	if ( setStatsRight ) then
		ItemUpgradeFrame.RightItemLevel.incText:SetText(GREEN_FONT_COLOR_CODE.."+"..ilvlInc);
		ItemUpgradeFrame.RightItemLevel.iLvlText:SetText(itemLevel + ilvlInc);
		ItemUpgradeFrame.RightItemLevel.ItemLevelText:SetText(ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL);
		ItemUpgradeFrame.RightItemLevel:Show();
	else
		ItemUpgradeFrame.RightItemLevel:Hide();
	end

	local statsLeft	= currentUpgradeInfo.levelStats;
	local statsRight = (nextUpgradeInfo and nextUpgradeInfo.levelStats) or {};
	local index = 1;

	local statAnchor;
	for i = 1, #statsLeft do
		local leftStat, rightStat = self:GetStatRow(index, true);
		-- Update the left stat text field.
		local name, value = statsLeft[i].displayString, statsLeft[i].statValue
		leftStat.ItemLevelText:SetText(value);
		leftStat.ItemText:SetText(name);
		leftStat:Show();
		
		-- Update the right stat text field.
		if ( setStatsRight ) then
			local nameNew, valueNew = statsRight[i].displayString, statsRight[i].statValue
			local statInc = valueNew - value;
			rightStat.ItemIncText:SetText(GREEN_FONT_COLOR_CODE.."+"..statInc);
			rightStat.ItemLevelText:SetText(valueNew);
			rightStat.ItemText:SetText(nameNew);
			rightStat:Show();
		else
			rightStat:Hide();
		end
		
		index = index + 1;
		statAnchor = leftStat;
	end

	for i = index, #ItemUpgradeFrame.LeftStat do
		ItemUpgradeFrame.LeftStat[i]:Hide();
	end
	for i = index, #ItemUpgradeFrame.RightStat do
		ItemUpgradeFrame.RightStat[i]:Hide();
	end

	-- effects
	local effectIndex = 1;
	for i = 1, C_ItemUpgrade.GetNumItemUpgradeEffects() do
		local row = self:GetEffectRow(i, index + effectIndex);
		if ( effectIndex == 1 ) then
			row:ClearAllPoints();
			if ( index == 1 ) then
				row:SetPoint("TOPRIGHT", ItemUpgradeFrame.HorzBar, 0, -38);
			else
				row:SetPoint("TOPLEFT", statAnchor, "BOTTOMLEFT", 0, -1);
			end
		end
		local leftText, rightText = C_ItemUpgrade.GetItemUpgradeEffect(i);
		row.LeftText:SetText(leftText);
		
		if ( setStatsRight ) then
			row.RightText:SetText(self:GetUpgradedEffectString(leftText, rightText));
			row.RightText:Show();
		else
			row.RightText:Hide();
		end
		
		local height = max(row.LeftText:GetHeight(), row.RightText:GetHeight());
		row:SetHeight(height + 3);
		row:Show();
		effectIndex = effectIndex + 1;
	end
	for i = effectIndex, #ItemUpgradeFrame.EffectRow do
		ItemUpgradeFrame.EffectRow[i]:Hide();
	end
end

-- compare 2 strings finding numeric differences
-- return the text of the 2nd string with (+x) in front of each number that is higher than in the 1st string
function ItemUpgradeMixin:GetUpgradedEffectString(string1, string2)
	local output = "";
	local index2 = 1;	-- where we're at in string2

	local start1, end1, substring1 = string.find(string1, "([%d,%.]+)");
	local start2, end2, substring2 = string.find(string2, "([%d,%.]+)");
	while start1 and start2 do
		output = output .. string.sub(string2, index2, start2 - 1);
		if ( substring1 ~= substring2 ) then
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

function ItemUpgradeMixin:GetStatRow(index, tryAdd)
	local leftStat, rightStat;
	leftStat	= ItemUpgradeFrame.LeftStat[index];
	rightStat	= ItemUpgradeFrame.RightStat[index];
	
	if(tryAdd and not leftStat) then
		if(index > ITEM_UPGRADE_MAX_STATS_SHOWN) then
			return;
		end
		leftStat	= CreateFrame("FRAME", nil, ItemUpgradeFrame, "ItemUpgradeStatTemplateLeft");
		leftStat:SetPoint("TOP", ItemUpgradeFrame.LeftStat[index - 1], "BOTTOM", 0, -1);
		rightStat	= CreateFrame("FRAME", nil, ItemUpgradeFrame, "ItemUpgradeStatTemplateRight");
		rightStat:SetPoint("TOP", ItemUpgradeFrame.RightStat[index - 1], "BOTTOM", 0, -1);
		
		if(mod(index, 2) == 1) then
			leftStat.BG:Show();
			rightStat.BG:Show();
		end

		ItemUpgradeFrame.LeftStat[index]	= leftStat;
		ItemUpgradeFrame.RightStat[index]	= rightStat;
	end
	
	return leftStat, rightStat;
end

function ItemUpgradeMixin:GetEffectRow(index, colorIndex)
	local row = ItemUpgradeFrame.EffectRow[index];
	if ( not row ) then
		row = CreateFrame("FRAME", nil, ItemUpgradeFrame, "ItemUpgradeEffectRowTemplate");
		if ( index > 1 ) then
			row:SetPoint("TOP", ItemUpgradeFrame.EffectRow[index - 1], "BOTTOM", 0, -1);
		end
		ItemUpgradeFrame.EffectRow[index] = row;
	end
	if(mod(colorIndex, 2) == 0) then
		row.LeftBg:Show();
		row.RightBg:Show();
	end
	return row;
end

function ItemUpgradeMixin:HideStatsLeft()
	local index = 1;
	local leftStat, _ = self:GetStatRow(index);
	while leftStat do
		leftStat:Hide();
		index = index + 1;
		leftStat, _ = self:GetStatRow(index);
	end
end

function ItemUpgradeMixin:HideStatsRight()
	local index = 1;
	local _, rightStat = self:GetStatRow(index);
	while rightStat do
		rightStat:Hide();
		index = index + 1;
		_, rightStat = self:GetStatRow(index);
	end
end

function ItemUpgradeCurrencyMixin:OnHover()
	if self.currencyID then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetCurrencyByID(self.currencyID);
	end
end
