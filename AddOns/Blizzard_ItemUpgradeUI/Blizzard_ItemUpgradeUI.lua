
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
	ItemUpgradeFrame_Update();
	
	ItemUpgradeFrameMoneyFrame:Show();
end

function ItemUpgradeFrame_OnHide(self)
	PlaySound("UI_EtherealWindow_Close");
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	CloseItemUpgrade();

	ClearItemUpgrade();
	HideStatsLeft();
	HideStatsRight();
	ItemUpgradeFrame.LeftItemLevel:Hide();
	ItemUpgradeFrame.RightItemLevel:Hide();
end

function ItemUpgradeFrame_OnEvent(self, event, ...)
	if ( event == "ITEM_UPGRADE_MASTER_SET_ITEM" ) then
		ItemUpgradeFrame_Update();
	elseif ( event == "ITEM_UPGRADE_MASTER_UPDATE" ) then
		ItemUpgradeFrame_Update();
		self.FinishedGlow.FinishedAnim:Play();
		self.ItemUpgradedNotification:Show();
		self.ItemUpgradedNotification.FinishedAnim:Play();
	end
end

function ItemUpgradeFrame_Update()
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
	
	local icon, name, quality, _, _, _, cost, currencyType = GetItemUpgradeItemInfo();
	local r, g, b = GetItemQualityColor(quality); 
	local currencyName, _, currencyTexture = GetCurrencyInfo(currencyType);
	local itemsString = " |T"..currencyTexture..":0:0:0:-1|t "..format(CURRENCY_QUANTITY_TEMPLATE, cost, currencyName);
	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", itemsString, "", {["texture"] = icon, ["name"] = name, 
															["color"] = {r, g, b, 1}, ["link"] = nil});
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

	local statAnchor;
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
	for i = 1, GetNumItemUpgradeEffects() do
		local row = ItemUpgradeFrame_GetEffectRow(i, index + effectIndex);
		if ( effectIndex == 1 ) then
			row:ClearAllPoints();
			if ( index == 1 ) then
				row:SetPoint("TOPRIGHT", ItemUpgradeFrame.HorzBar, 0, -38);
			else
				row:SetPoint("TOPLEFT", statAnchor, "BOTTOMLEFT", 0, -1);
			end
		end
		local leftText, rightText = GetItemUpgradeEffect(i);
		row.LeftText:SetText(leftText);
		
		if ( setStatsRight ) then
			row.RightText:SetText(ItemUpgradeFrame_GetUpgradedEffectString(leftText, rightText));
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
function ItemUpgradeFrame_GetUpgradedEffectString(string1, string2)
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

function ItemUpgradeFrame_GetEffectRow(index, colorIndex)
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
