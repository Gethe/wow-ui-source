
UIPanelWindows["ItemUpgradeFrame"] = { area = "left", pushable = 0};

ITEM_UPGRADE_MAX_STATS_SHOWN = 10;


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
	self:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE");

	SetPortraitToTexture(ItemUpgradeFramePortrait, "Interface\\Icons\\Spell_Shaman_SpectralTransformation");
	self.LeftStat[1].BG:Show();
	self.RightStat[1].BG:Show();
	ItemUpgradeFrameTitleText:SetText(ITEM_UPGRADE);
	ItemUpgradeFrameTopTileStreaks:Hide();
	ItemUpgradeFrameBg:Hide();
end

function ItemUpgradeFrame_OnShow(self)
	PlaySound("UI_EtherealWindow_Open");
	ItemUpgradeFrame_Update(self);
	
	ItemUpgradeFrameMoneyFrame:Show();
end

function ItemUpgradeFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	CloseItemUpgrade();

	ClearItemUpgrade();
	HideStatsLeft();
	HideStatsRight();
	ItemUpgradeFrame.LeftItemLevel:Hide();
	ItemUpgradeFrame.RightItemLevel:Hide();
end

function ItemUpgradeFrame_OnEvent(self, event, ...)
	if ( event == "ITEM_UPGRADE_MASTER_SET_ITEM" ) then
		ItemUpgradeFrame_Update(self);
	elseif ( event == "ITEM_UPGRADE_MASTER_UPDATE" ) then
		ItemUpgradeFrame_Update(self);
		self.FinishedGlow.FinishedAnim:Play();
	end
end

function ItemUpgradeFrame_Update(self)
	local icon, name, quality, bound, numCurrUpgrades, numMaxUpgrades, cost, currencyType = GetItemUpgradeItemInfo();

	ItemUpgradeFrameUpgradeButton:Disable();
	
	local ItemUpgradeFrame = ItemUpgradeFrame;
	if icon then
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture(icon);
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("|c"..hex..name.."|r");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText(bound);
		ItemUpgradeFrame.ItemButton.MissingText:Hide();	
		ItemUpgradeFrame.ItemButton.Cost.Amount:SetText(cost);
		local _, _, currencyTexture = GetCurrencyInfo(currencyType);
		ItemUpgradeFrame.ItemButton.Cost.Icon:SetTexture(currencyTexture);
		ItemUpgradeFrame.MissingDescription:Hide();
		ItemUpgradeFrame.MissingFadeOut:Hide();
		ItemUpgradeFrame.TitleTextLeft:Show();
		ItemUpgradeFrame.TitleTextRight:Show();
		ItemUpgradeFrame.HorzBar:Show();

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
		
		ItemUpgradeFrame_UpdateStats(canUpgradeItem);
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
		for _, item in pairs(self.LeftStat) do
			item:Hide();
		end
		for _, item in pairs(self.RightStat) do
			item:Hide();
		end
	end
	
	-- update player's currency
	if ( cost and cost > 0 ) then
		local _, amount, currencyTexture = GetCurrencyInfo(currencyType);
		ItemUpgradeFrameMoneyFrame.Currency.currencyID = currencyType;
		ItemUpgradeFrameMoneyFrame.Currency.icon:SetTexture(currencyTexture);
		ItemUpgradeFrameMoneyFrame.Currency.count:SetText(amount);
		ItemUpgradeFrameMoneyFrame.Currency:Show();
		if ( cost > amount ) then
			ItemUpgradeFrameUpgradeButton:Disable();
			ItemUpgradeFrameMoneyFrame.Currency.count:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			ItemUpgradeFrameMoneyFrame.Currency.count:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		ItemUpgradeFrameMoneyFrame.Currency:Hide();
	end
end

function ItemUpgradeFrame_UpgradeClick(self)
	ItemUpgradeFrameUpgradeButton:Disable();
	UpgradeItem();
	PlaySoundKitID(23291);
end

function ItemUpgradeFrame_AddItemClick(self, button)
	SetItemUpgradeFromCursorItem();
	GameTooltip:Hide();
end

function ItemUpgradeFrame_UpdateStats(setStatsRight)
	local itemLevel		= GetItemUpdateLevel();
	local ilvlInc		= GetItemLevelIncrement();
	
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

	local statsLeft		= {GetItemUpgradeStats(false)};
	local statsRight	= {GetItemUpgradeStats(true)};
	local index = 1;

	for i = 1, #statsLeft, 2 do
		local leftStat, rightStat = ItemUpgradeFrame_GetStatRow(index, true);
		-- Update the left stat text field.
		local name, value = statsLeft[i], statsLeft[i + 1];
		leftStat.ItemLevelText:SetText(value);
		leftStat.ItemText:SetText(name);
		leftStat:Show();
		
		-- Update the right stat text field.
		if ( setStatsRight ) then
			local name, value = statsRight[i], statsRight[i + 1];
			local statInc = statsRight[i + 1] - statsLeft[i + 1];
			rightStat.ItemIncText:SetText(GREEN_FONT_COLOR_CODE.."+"..statInc);
			rightStat.ItemLevelText:SetText(value);
			rightStat.ItemText:SetText(name);
			rightStat:Show();
		else
			rightStat:Hide();
		end
		
		index = index + 1;
	end
	for i = index, #ItemUpgradeFrame.LeftStat do
		ItemUpgradeFrame.LeftStat[i]:Hide();
	end
	for i = index, #ItemUpgradeFrame.RightStat do
		ItemUpgradeFrame.RightStat[i]:Hide();
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
		
		if(mod(index, 2) == 1) then
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
