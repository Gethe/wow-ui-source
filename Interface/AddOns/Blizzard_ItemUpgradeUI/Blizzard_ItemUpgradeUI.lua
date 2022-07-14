
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

	self:SetPortraitToAsset("Interface\\Icons\\inv_hammer_2h_silverhand_b_01");
	self.LeftStat[1].BG:Show();
	self.RightStat[1].BG:Show();

	self.Inset:SetPoint("TOPLEFT", 4, -64);

	self:SetTitle(ITEM_UPGRADE);
end

function ItemUpgradeFrame_OnShow(self)
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	ItemUpgradeFrame_Update();

	self:RegisterEvent("BAG_UPDATE");

	ItemUpgradeFrameMoneyFrame:Show();
end

function ItemUpgradeFrame_OnHide(self)
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	CloseItemUpgrade();

	self:UnregisterEvent("BAG_UPDATE");

	ClearItemUpgrade();
	HideStatsLeft();
	HideStatsRight();
	ItemUpgradeFrame.LeftItemLevel:Hide();
	ItemUpgradeFrame.RightItemLevel:Hide();
end

function ItemUpgradeFrame_OnEvent(self, event, ...)
	if ( event == "ITEM_UPGRADE_MASTER_SET_ITEM" ) then
		self.itemLevel = GetItemUpdateLevel();
		ItemUpgradeFrame_Update();
	elseif ( event == "ITEM_UPGRADE_MASTER_UPDATE" ) then
		ItemUpgradeFrame_Update();
		self.FinishedGlow.FinishedAnim:Play();
		self.ItemUpgradedNotification:Show();
		self.ItemUpgradedNotification.FinishedAnim:Play();
	elseif ( event == "BAG_UPDATE" ) then
		local itemLevel = GetItemUpdateLevel();
		if self.itemLevel and self.itemLevel < itemLevel then
			ItemUpgradeFrame_Update();
			self.FinishedGlow.FinishedAnim:Play();
			self.ItemUpgradedNotification:Show();
			self.ItemUpgradedNotification.FinishedAnim:Play();
		end
	end
end

function ItemUpgradeFrame_Update()
	local icon, name, quality, bound, numCurrUpgrades, numMaxUpgrades, cost, currencyType, failureMessage = GetItemUpgradeItemInfo();

	ItemUpgradeFrameUpgradeButton:Disable();

	local ItemUpgradeFrame = ItemUpgradeFrame;
	if ( icon ) then
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture(icon);
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 1, 0, 1);
		local _, _, _, hex = GetItemQualityColor(quality);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("|c"..hex..name.."|r");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText(bound);
		ItemUpgradeFrame.TextFrame.MissingText:Hide();
		ItemUpgradeFrame.MissingDescription:Hide();
		ItemUpgradeFrame.TitleTextLeft:Show();
		ItemUpgradeFrame.TitleTextRight:Show();
		ItemUpgradeFrame.HorzBar:Show();

		if ( numCurrUpgrades and numMaxUpgrades ) then
			local canUpgradeItem = false;
			ItemUpgradeFrame.UpgradeStatus:SetText(numCurrUpgrades.."/"..numMaxUpgrades);
			ItemUpgradeFrame.UpgradeStatus:Show();
			if ( numCurrUpgrades < numMaxUpgrades ) then
				ItemUpgradeFrame.UpgradeStatus:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				canUpgradeItem = true;
				if ( not failureMessage ) then
					ItemUpgradeFrameUpgradeButton:Enable();
				end
			else
				ItemUpgradeFrame.UpgradeStatus:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			end

			if ( failureMessage ) then
				ItemUpgradeFrame.FeedbackMessage:SetText(failureMessage);
				ItemUpgradeFrame.FeedbackMessage:Show();
				canUpgradeItem = false;
			elseif ( canUpgradeItem )  then
				ItemUpgradeFrame.FeedbackMessage:Hide();
			else
				ItemUpgradeFrame.FeedbackMessage:SetText(ITEM_UPGRADE_NO_MORE_UPGRADES);
				ItemUpgradeFrame.FeedbackMessage:Show();
				ItemUpgradeFrame.UpgradeStatus:Hide();
			end
			ItemUpgradeFrame_UpdateStats(canUpgradeItem);
		end
	else	-- There is no item so hide elements
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexture("Interface\\BUTTONS\\UI-Slot-Background");
		ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord( 0, 0.640625, 0, 0.640625);
		ItemUpgradeFrame.ItemButton.ItemName:SetText("");
		ItemUpgradeFrame.ItemButton.BoundStatus:SetText("");
		ItemUpgradeFrame.TextFrame.MissingText:Show();
		ItemUpgradeFrame.MissingDescription:Show();
		ItemUpgradeFrame.TitleTextLeft:Hide();
		ItemUpgradeFrame.TitleTextRight:Hide();
		ItemUpgradeFrame.UpgradeStatus:Hide();
		ItemUpgradeFrame.HorzBar:Hide();
		ItemUpgradeFrame.LeftItemLevel:Hide();
		ItemUpgradeFrame.RightItemLevel:Hide();
		ItemUpgradeFrame.FeedbackMessage:Hide();
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
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyType);
		local amount = currencyInfo.quantity;
		local currencyTexture = currencyInfo.iconFileID;
		ItemUpgradeFrameMoneyFrame.Currency.currencyID = currencyType;
		ItemUpgradeFrameMoneyFrame.Currency.icon:SetTexture(currencyTexture);
		ItemUpgradeFrameMoneyFrame.Currency.count:SetText(cost);
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
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyType);
	local currencyName = currencyInfo.name;
	local currencyTexture = currencyInfo.iconFileID;
	local itemsString = " |T"..currencyTexture..":0:0:0:-1|t "..format(CURRENCY_QUANTITY_TEMPLATE, cost, currencyName);
	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", itemsString, "", {["texture"] = icon, ["name"] = name,
															["color"] = {r, g, b, 1}, ["link"] = C_ItemUpgrade.GetItemHyperlink()});
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
		ItemUpgradeFrame.RightItemLevel.incText:SetText(GREEN_FONT_COLOR_CODE.."+"..ilvlInc..FONT_COLOR_CODE_CLOSE);
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
	for i = 1, #statsLeft, 3 do
		local leftStat, rightStat = ItemUpgradeFrame_GetStatRow(index, true);
		-- Update the left stat text field.
		local name, value, active = statsLeft[i], statsLeft[i + 1], statsLeft[i + 2];
		if (active) then
			leftStat.ItemLevelText:SetText(value);
			leftStat.ItemText:SetText(name);
		else
			leftStat.ItemLevelText:SetText(GRAY_FONT_COLOR_CODE..value..FONT_COLOR_CODE_CLOSE);
			leftStat.ItemText:SetText(GRAY_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
		end
		leftStat:Show();

		-- Update the right stat text field.
		if ( setStatsRight ) then
			local name, value, active = statsRight[i], statsRight[i + 1], statsRight[i + 2];
			local statInc = statsRight[i + 1] - statsLeft[i + 1];
			if (active) then
				rightStat.ItemIncText:SetText(GREEN_FONT_COLOR_CODE.."+"..statInc..FONT_COLOR_CODE_CLOSE);
				rightStat.ItemLevelText:SetText(value);
				rightStat.ItemText:SetText(name);
			else
				rightStat.ItemIncText:SetText(GRAY_FONT_COLOR_CODE.."+"..statInc..FONT_COLOR_CODE_CLOSE);
				rightStat.ItemLevelText:SetText(GRAY_FONT_COLOR_CODE..value..FONT_COLOR_CODE_CLOSE);
				rightStat.ItemText:SetText(GRAY_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE);
			end
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
		local row = ItemUpgradeFrame_GetEffectRow(i, index + effectIndex, setStatsRight);
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

		leftStat.BG:SetShown(mod(index, 2) == 1);
		rightStat.BG:SetShown(mod(index, 2) == 1);

		ItemUpgradeFrame.LeftStat[index]	= leftStat;
		ItemUpgradeFrame.RightStat[index]	= rightStat;
	end

	return leftStat, rightStat;
end

function ItemUpgradeFrame_GetEffectRow(index, colorIndex, showRight)
	local row = ItemUpgradeFrame.EffectRow[index];
	if ( not row ) then
		row = CreateFrame("FRAME", nil, ItemUpgradeFrame, "ItemUpgradeEffectRowTemplate");
		if ( index > 1 ) then
			row:SetPoint("TOP", ItemUpgradeFrame.EffectRow[index - 1], "BOTTOM", 0, -1);
		end
		ItemUpgradeFrame.EffectRow[index] = row;
	end
	row.LeftBg:SetShown(mod(colorIndex, 2) == 0);
	row.RightBg:SetShown(showRight and mod(colorIndex, 2) == 0);
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
