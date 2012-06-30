
UIPanelWindows["ItemUpgradeFrame"] = { area = "left", pushable = 0};

ITEM_UPGRADE_MAX_STATS_SHOWN = 8;


function ItemUpgradeFrame_Show()
	ShowUIPanel(ItemUpgradeFrame);
	if(not ItemUpgradeFrame:IsShown()) then
		CloseItemUpgrade();
	end
end

function ItemUpgradeFrame_Hide()
	HideUIPanel(ItemUpgradeFrame);
end

function ItemUpgradeFrame_OnLoad(self)
	self:RegisterEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:RegisterEvent("ITEM_UPGRADE_MASTER_ITEM_CHANGED");

	SetPortraitToTexture(ItemUpgradeFramePortrait, "Interface\\Icons\\PVECurrency-Valor");

	ItemUpgradeFrameTitleText:SetText(ITEM_UPGRADE);
end

function ItemUpgradeFrame_OnShow(self)
	PlaySound("UI_EtherealWindow_Open");
	ItemUpgradeFrame_Update(self);
	
	ItemUpgradeFrameMoneyFrame:Show();
end

function ItemUpgradeFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	CloseItemUpgrade();
end

function ItemUpgradeFrame_OnEvent(self, event, ...)
	if event == "ITEM_UPGRADE_MASTER_SET_ITEM" then
		ItemUpgradeFrame_Update(self);
	end
end

function ItemUpgradeFrame_Update(self)
	local icon, name, quality, bound, numCurrUpgrades, numMaxUpgrades, cost, currencyType = GetItemUpgradeItemInfo();

	ItemUpgradeFrameUpgradeButton:Disable();
	
	if icon then
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture(icon);
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("|c"..hex..name.."|r");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText(bound);
		ItemUpgradeFrame.ItemButton.CurrencyAmount:SetText(cost);
		ItemUpgradeFrame.ItemButton.MissingText:Hide();	
		ItemUpgradeFrame.ItemButton.CurrencyIcon:Show();
		ItemUpgradeFrame.MissingDescription:Hide();
		ItemUpgradeFrame.TitleTextLeft:Show();
		ItemUpgradeFrame.TitleTextRight:Show();
		ItemUpgradeFrame.HorzBar:Show();

		if(numCurrUpgrades and numMaxUpgrades) then
			ItemUpgradeFrame.UpgradeStatus:SetText(numCurrUpgrades.."/"..numMaxUpgrades);
			ItemUpgradeFrame.UpgradeStatus:Show();

			ItemUpgradeFrameUpgradeButton:SetEnabled(numCurrUpgrades < numMaxUpgrades);
		end
		
		ItemUpgradeFrame_UpdateStats();
	else	-- There is no item so hide elements
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText("");
		ItemUpgradeFrame.ItemButton.MissingText:Show();	
		ItemUpgradeFrame.MissingDescription:Show();
		ItemUpgradeFrame.TitleTextLeft:Hide();
		ItemUpgradeFrame.TitleTextRight:Hide();
		ItemUpgradeFrame.UpgradeStatus:Hide();
		ItemUpgradeFrame.HorzBar:Hide();
	end
	
end

function ItemUpgradeFrame_UpgradeClick(self)
end

function ItemUpgradeFrame_AddItemClick(self, button)
	SetItemUpgradeFromCursorItem();
	GameTooltip:Hide();
end

function ItemUpgradeFrame_UpdateStats()
	local itemLevel		= GetItemUpdateLevel();
	local ilvlInc		= GetItemLevelIncrement();
	
	ItemUpgradeFrame.LeftItemLevel.iLvlText:SetText(itemLevel);
	ItemUpgradeFrame.LeftItemLevel.ItemLevelText:SetText(STAT_AVERAGE_ITEM_LEVEL);
	ItemUpgradeFrame.RightItemLevel.incText:SetText(GREEN_FONT_COLOR_CODE.."+"..ilvlInc);
	ItemUpgradeFrame.RightItemLevel.iLvlText:SetText(itemLevel + ilvlInc);
	ItemUpgradeFrame.RightItemLevel.ItemLevelText:SetText(STAT_AVERAGE_ITEM_LEVEL);
	
	ItemUpgradeFrame.LeftItemLevel:Show();
	ItemUpgradeFrame.RightItemLevel:Show();

	local statsLeft		= {GetItemUpgradeStats(false)};
	local statsRight	= {GetItemUpgradeStats(true)};
	local index = 1;
	
	-- KBR_FIXME: need to keep the i outside the loop to disable extra rows
	for i = 1, #statsLeft, 2 do
		leftStat, rightStat = ItemUpgradeFrame_GetStatRow(index, true);
		
		-- Update the left stat text field.
		local name, value = statsLeft[i], statsLeft[i + 1];
		leftStat.ItemLevelText:SetText(value);
		leftStat.ItemText:SetText(name);
		leftStat:Show();
		
		-- Update the right stat text field.
		local name, value = statsRight[i], statsRight[i + 1];
		local statInc = statsRight[i + 1] - statsLeft[i + 1];
		rightStat.ItemIncText:SetText(GREEN_FONT_COLOR_CODE.."+"..statInc);
		rightStat.ItemLevelText:SetText(value);
		rightStat.ItemText:SetText(name);
		rightStat:Show();
		
		index = index + 1;
	end
end

function ItemUpgradeFrame_GetStatRow(index, tryAdd)
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
		
		if(mod(index, 2) == 0) then
			leftStat.BG:Show();
			rightStat.BG:Show();
		end

		ItemUpgradeFrame.LeftStat[index]	= leftStat;
		ItemUpgradeFrame.RightStat[index]	= rightStat;
	end
	
	return leftStat, rightStat;
end

function HideStatsLeft()
	local index = 1;
	local leftStat, _ = ItemUpgradeFrame_GetStatRow(index);
	while leftStat do
		leftStat:Hide();
		index = index + 1;
		leftStat, _ = ItemUpgradeFrame_GetStatRow(index);
	end
end

function HideStatsRight()
	local index = 1;
	local _, rightStat = ItemUpgradeFrame_GetStatRow(index);
	while rightStat do
		rightStat:Hide();
		index = index + 1;
		_, rightStat = ItemUpgradeFrame_GetStatRow(index);
	end
end
