
--[[ Optionals:
	headerText - string
	headerColor - color
	wrapHeaderText - bool
	atLeastShowAzerite - bool
	fullItemDescription - bool
	prioritizeCurrencyOverItem - bool
--]]

TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	fullItemDescription = true,
}


TOOLTIP_QUEST_REWARDS_STYLE_NO_HEADER = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_CONTRIBUTION = {
	headerText = CONTRIBUTION_REWARD_TOOLTIP_TEXT,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY = {
	headerText = PVP_BOUNTY_REWARD_TITLE,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_ISLANDS_QUEUE = {
	headerText = ISLAND_QUEUE_REWARD_FOR_WINNING,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_CALLING_REWARD = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_PRIORITIZE_CURRENCY_OVER_ITEM = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	prioritizeCurrencyOverItem = true,
	atLeastShowAzerite = true,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_QUEST_CHOICE = {
	-- Doesn't include a header to allow individual player choice responses to set their own
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	fullItemDescription = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_NONE = {
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
}

function GameTooltip_UnitColor(unit)
	local r, g, b;
	if ( UnitPlayerControlled(unit) ) then
		if ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				--[[
				r = 1.0;
				g = 0.5;
				b = 0.5;
				]]
				--[[
				r = 0.0;
				g = 0.0;
				b = 1.0;
				]]
				r = 1.0;
				g = 1.0;
				b = 1.0;
			else
				r = FACTION_BAR_COLORS[2].r;
				g = FACTION_BAR_COLORS[2].g;
				b = FACTION_BAR_COLORS[2].b;
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			r = FACTION_BAR_COLORS[4].r;
			g = FACTION_BAR_COLORS[4].g;
			b = FACTION_BAR_COLORS[4].b;
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			r = FACTION_BAR_COLORS[6].r;
			g = FACTION_BAR_COLORS[6].g;
			b = FACTION_BAR_COLORS[6].b;
		else
			-- All other players are blue (the usual state on the "blue" server)
			--[[
			r = 0.0;
			g = 0.0;
			b = 1.0;
			]]
			r = 1.0;
			g = 1.0;
			b = 1.0;
		end
	else
		local reaction = UnitReaction(unit, "player");
		if ( reaction ) then
			r = FACTION_BAR_COLORS[reaction].r;
			g = FACTION_BAR_COLORS[reaction].g;
			b = FACTION_BAR_COLORS[reaction].b;
		else
			--[[
			r = 0.0;
			g = 0.0;
			b = 1.0;
			]]
			r = 1.0;
			g = 1.0;
			b = 1.0;
		end
	end
	return r, g, b;
end

function GameTooltip_SetDefaultAnchor(tooltip, parent)
	tooltip:SetOwner(parent, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
end

function GameTooltip_SetBasicTooltip(tooltip, text, x, y, wrap)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:ClearAllPoints();
	tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
	local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();
	tooltip:SetText(text, r, g, b, 1, wrap);
end

function GameTooltip_ShowDisabledTooltip(tooltip, owner, text, tooltipAnchor)
	tooltip:SetOwner(owner, tooltipAnchor);

	local wrap = true;
	GameTooltip_SetTitle(tooltip, text, RED_FONT_COLOR, wrap);

	tooltip:Show();
end

function GameTooltip_AddQuestRewardsToTooltip(tooltip, questID, style)
	style = style or TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT;

	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or
		GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 or GetQuestLogRewardHonor(questID) > 0 or
		GetNumQuestLogRewardSpells(questID) > 0) then
		if tooltip.ItemTooltip then
			tooltip.ItemTooltip:Hide();
		end

		GameTooltip_AddBlankLinesToTooltip(tooltip, style.prefixBlankLineCount);
		if style.headerText and style.headerColor then
			GameTooltip_AddColoredLine(tooltip, style.headerText, style.headerColor, style.wrapHeaderText);
		end
		GameTooltip_AddBlankLinesToTooltip(tooltip, style.postHeaderBlankLineCount);

		local hasAnySingleLineRewards, showRetrievingData = QuestUtils_AddQuestRewardsToTooltip(tooltip, questID, style);

		if hasAnySingleLineRewards and tooltip.ItemTooltip and tooltip.ItemTooltip:IsShown() then
			GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
			if showRetrievingData then
				GameTooltip_AddColoredLine(tooltip, RETRIEVING_DATA, RED_FONT_COLOR);
			end
		end

		GameTooltip_SetTooltipWaitingForData(tooltip, showRetrievingData);
	end
end

function GameTooltip_CheckAddQuestTimeToTooltip(tooltip, questID)
	if C_QuestLog.ShouldDisplayTimeRemaining(questID) then
		GameTooltip_AddQuestTimeToTooltip(tooltip, questID);
	end
end

function GameTooltip_AddQuestTimeToTooltip(tooltip, questID)
	local formattedTime, color, secondsRemaining = WorldMap_GetQuestTimeForTooltip(questID);
	if formattedTime and color then
		GameTooltip_AddColoredLine(tooltip, formattedTime, color);
	end
end

function GameTooltip_CalculatePadding(tooltip)
	local itemWidth, itemHeight, bottomFontStringWidth, bottomFontStringHeight = 0, 0, 0, 0;

	local itemTooltip = tooltip.ItemTooltip;
	local isItemTooltipShown = itemTooltip and itemTooltip:IsShown();
	local isBottomFontStringShown = tooltip.BottomFontString and tooltip.BottomFontString:IsShown();

	if not isItemTooltipShown and not isBottomFontStringShown then
		return;
	end

	if isBottomFontStringShown then
		bottomFontStringWidth, bottomFontStringHeight = tooltip.BottomFontString:GetSize();
		bottomFontStringHeight = bottomFontStringHeight + 7;
		bottomFontStringWidth = bottomFontStringWidth + 20; -- extra width padding for this line
	end

	if itemTooltip then
		if isItemTooltipShown then
			itemWidth, itemHeight = itemTooltip:GetSize();
			itemWidth = itemWidth + 9; -- extra padding for this line
		end

		if isBottomFontStringShown then
			itemTooltip:SetPoint("BOTTOMLEFT", tooltip.BottomFontString, "TOPLEFT", 0, 10);
		else
			itemTooltip:SetPoint("BOTTOMLEFT", 10, 13);
		end
	end

	if tooltip:GetObjectType() ~= "GameTooltip" then
		-- This means that an InternalEmbeddedItemTooltipTemplate was placed inside a frame that is not a Tooltip
		-- Everything below here is only relevant for tooltips
		return;
	end

	local extraWidth = math.max(itemWidth, bottomFontStringWidth);
	local extraHeight = itemHeight + bottomFontStringHeight;

	local oldPaddingWidth, oldPaddingHeight = tooltip:GetPadding();
	local actualTooltipWidth = tooltip:GetWidth() - oldPaddingWidth;
	local paddingWidth = (actualTooltipWidth <= extraWidth) and extraWidth - actualTooltipWidth or 0;

	local paddingHeight = 0;
	if extraHeight > 0 then
		paddingHeight = extraHeight + 5;
	end

	if (math.abs(paddingWidth - oldPaddingWidth) > 0.5) or (math.abs(paddingHeight - oldPaddingHeight) > 0.5) then
		tooltip:SetPadding(paddingWidth, paddingHeight, 0, 0);
	end
end

function GameTooltip_SetBottomText(self, text, lineColor)
	if self.BottomFontString then
		self.BottomFontString:Show();
		self.BottomFontString:SetText(text);
		self.BottomFontString:SetVertexColor(lineColor:GetRGBA());
	end
end

function GameTooltip_OnLoad(self)
	SharedTooltip_OnLoad(self);
	self.needsReset = true;
	self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;
end

function GameTooltip_OnTooltipAddMoney(self, cost, maxcost)
	if( not maxcost ) then --We just have 1 price to display
		SetTooltipMoney(self, cost, nil, string.format("%s:", SELL_PRICE));
	else
		GameTooltip_AddColoredLine(self, ("%s:"):format(SELL_PRICE), HIGHLIGHT_FONT_COLOR);
		local indent = string.rep(" ",4)
		SetTooltipMoney(self, cost, nil, string.format("%s%s:", indent, MINIMUM));
		SetTooltipMoney(self, maxcost, nil, string.format("%s%s:", indent, MAXIMUM));
	end
end

function SetTooltipMoney(frame, money, type, prefixText, suffixText)
	GameTooltip_AddBlankLinesToTooltip(frame, 1);
	local numLines = frame:NumLines();
	if ( not frame.numMoneyFrames ) then
		frame.numMoneyFrames = 0;
	end
	if ( not frame.shownMoneyFrames ) then
		frame.shownMoneyFrames = 0;
	end
	local name = frame:GetName().."MoneyFrame"..frame.shownMoneyFrames+1;
	local moneyFrame = _G[name];
	if ( not moneyFrame ) then
		frame.numMoneyFrames = frame.numMoneyFrames+1;
		moneyFrame = CreateFrame("Frame", name, frame, "TooltipMoneyFrameTemplate");
		name = moneyFrame:GetName();
		MoneyFrame_SetType(moneyFrame, "STATIC");
	end
	_G[name.."PrefixText"]:SetText(prefixText);
	_G[name.."SuffixText"]:SetText(suffixText);
	if ( type ) then
		MoneyFrame_SetType(moneyFrame, type);
	end
	--We still have this variable offset because many AddOns use this function. The money by itself will be unaligned if we do not use this.
	local xOffset;
	if ( prefixText ) then
		xOffset = 4;
	else
		xOffset = 0;
	end
	moneyFrame:SetPoint("LEFT", frame:GetName().."TextLeft"..numLines, "LEFT", xOffset, 0);
	moneyFrame:Show();
	if ( not frame.shownMoneyFrames ) then
		frame.shownMoneyFrames = 1;
	else
		frame.shownMoneyFrames = frame.shownMoneyFrames+1;
	end
	MoneyFrame_Update(moneyFrame:GetName(), money);
	local moneyFrameWidth = moneyFrame:GetWidth();
	if ( frame:GetMinimumWidth() < moneyFrameWidth ) then
		frame:SetMinimumWidth(moneyFrameWidth);
	end
	frame.hasMoney = 1;
end

function GameTooltip_ClearMoney(self)
	if ( not self.shownMoneyFrames ) then
		return;
	end

	local moneyFrame;
	for i=1, self.shownMoneyFrames do
		moneyFrame = _G[self:GetName().."MoneyFrame"..i];
		if(moneyFrame) then
			moneyFrame:Hide();
			MoneyFrame_SetType(moneyFrame, "STATIC");
		end
	end
	self.shownMoneyFrames = nil;
end

GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED = {
	-- Nothing
};

GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background-Azerite",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = true,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = WHITE_FONT_COLOR,

	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = 1;
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
	overlayAtlasBottomYOffset = 2;

	padding = { left = 3, right = 3, top = 3, bottom = 3 },
};

GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background-Corrupted",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Corrupted",
	tile = true,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = WHITE_FONT_COLOR,

	overlayAtlasTop = "Nzoth-tooltip-topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2;

	padding = { left = 3, right = 3, top = 3, bottom = 3 },
};

GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background-Maw",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Maw",
	tile = true,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = WHITE_FONT_COLOR,

	overlayAtlasTop = "Maw-tooltip-topper";
	overlayAtlasTopScale = .75,
	overlayAtlasTopYOffset = -2;

	padding = { left = 3, right = 3, top = 3, bottom = 3 },
};

GAME_TOOLTIP_TEXTUREKIT_BACKDROP_STYLES = {
	["jailerstower"] = GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY;
};

function GameTooltip_OnHide(self)
	self.needsReset = true;
	self.waitingForData = false;
	SharedTooltip_SetBackdropStyle(self, self.IsEmbedded and GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED or TOOLTIP_BACKDROP_STYLE_DEFAULT);
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearStatusBars(self);
	GameTooltip_ClearProgressBars(self);
	GameTooltip_ClearWidgetSet(self);
	if ( self.shoppingTooltips ) then
		for _, frame in pairs(self.shoppingTooltips) do
			frame:Hide();
		end
	end
	self.comparing = false;

	ShoppingTooltip1:Hide();
	ShoppingTooltip2:Hide();
	if (BattlePetTooltip) then
		BattlePetTooltip:Hide();
	end

	if self.ItemTooltip then
		EmbeddedItemTooltip_Hide(self.ItemTooltip);
	end
	self:SetPadding(0, 0, 0, 0);
end

function GameTooltip_CycleSecondaryComparedItem(self)
	GameTooltip_AdvanceSecondaryCompareItem(self);

	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
	if ( shoppingTooltip1:IsShown() ) then
		GameTooltip_ShowCompareItem(self);
	end
end

function GameTooltip_SetTooltipWaitingForData(self, waitingForData)
	if self.waitingForData and not waitingForData then
		self.updateTooltipTimer = 0;
	end

	self.waitingForData = waitingForData;
end

function GameTooltip_IsUpdateNeeded(self, elapsed)
	self.updateTooltipTimer = self.updateTooltipTimer - elapsed;
	if self.updateTooltipTimer > 0 then
		return false;
	end

	self.updateTooltipTimer = TOOLTIP_UPDATE_TIME;
	return true;
end

function GameTooltip_OnUpdate(self, elapsed)
	if not GameTooltip_IsUpdateNeeded(self, elapsed) then
		return;
	end

	local shoppingTooltip1 = self.shoppingTooltips[1];

	if ( not shoppingTooltip1:IsShown() ) then
		self.needsReset = true;
	end

	local owner = self:GetOwner();
	if ( owner and owner.UpdateTooltip ) then
		owner:UpdateTooltip();
	elseif self.UpdateTooltip then
		self:UpdateTooltip();
	end
end

function GameTooltip_HideBattlePetTooltip()
	if BattlePetTooltip then
		BattlePetTooltip:Hide();
	end
end

function GameTooltip_HideShoppingTooltips(self)
	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
	shoppingTooltip1:Hide();
	shoppingTooltip2:Hide()
end

function GameTooltip_OnTooltipSetUnit(self)
	if self:IsUnit("mouseover") then
		_G[self:GetName().."TextLeft1"]:SetTextColor(GameTooltip_UnitColor("mouseover"));
	end
	GameTooltip_HideBattlePetTooltip();
end

function GameTooltip_UpdateStyle(self)
	local backdropStyle = TOOLTIP_BACKDROP_STYLE_DEFAULT;
	local _, itemLink = self:GetItem();
	if itemLink then
		if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) or C_AzeriteItem.IsAzeriteItemByID(itemLink) then
			backdropStyle = GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM;
		elseif IsCorruptedItem(itemLink) then
			backdropStyle = GAME_TOOLTIP_BACKDROP_STYLE_CORRUPTED_ITEM;
		end
	end

	SharedTooltip_SetBackdropStyle(self, backdropStyle);
end

function GameTooltip_OnTooltipSetItem(self)
	if IsModifiedClick("COMPAREITEMS") or (GetCVarBool("alwaysCompareItems") and not self:IsEquippedItem()) then
		GameTooltip_ShowCompareItem(self);
	else
		GameTooltip_HideShoppingTooltips(self);
	end
	GameTooltip_HideBattlePetTooltip();

	GameTooltip_UpdateStyle(self);
end

function GameTooltip_OnTooltipSetShoppingItem(self)
	GameTooltip_UpdateStyle(self);
end

function GameTooltip_OnTooltipSetSpell(self)
	if (not IsModifiedClick("COMPAREITEMS") and not GetCVarBool("alwaysCompareItems")) or not GameTooltip_ShowCompareSpell(self) then
		GameTooltip_HideShoppingTooltips(self);
	end
	GameTooltip_HideBattlePetTooltip();
end

function GameTooltip_InitializeComparisonTooltips(self, anchorFrame)
	if not self then
		self = GameTooltip;
	end

	anchorFrame = anchorFrame or self;

	if self.needsReset then
		self:ResetSecondaryCompareItem();
		GameTooltip_AdvanceSecondaryCompareItem(self);
		self.needsReset = false;
	end

	return self, anchorFrame, unpack(self.shoppingTooltips);
end

function GameTooltip_AnchorComparisonTooltips(self, anchorFrame, shoppingTooltip1, shoppingTooltip2, primaryItemShown, secondaryItemShown)
	local sideAnchorFrame = anchorFrame;
	if anchorFrame.IsEmbedded then
		sideAnchorFrame = anchorFrame:GetParent():GetParent();
	end

	local leftPos = sideAnchorFrame:GetLeft();
	local rightPos = sideAnchorFrame:GetRight();

	local selfLeftPos = self:GetLeft();
	local selfRightPos = self:GetRight();

	-- if we get the Left, we have the Right
	if ( leftPos and selfLeftPos) then
		leftPos = math.min(selfLeftPos, leftPos);-- get the left most bound
		rightPos = math.max(selfRightPos, rightPos);-- get the right most bound
	else
		leftPos = leftPos or selfLeftPos or 0;
		rightPos = rightPos or selfRightPos or 0;
	end

	-- sometimes the sideAnchorFrame is an actual tooltip, and sometimes it's a script region, so make sure we're getting the actual anchor type
	local anchorType = sideAnchorFrame.GetAnchorType and sideAnchorFrame:GetAnchorType() or self:GetAnchorType();

	local totalWidth = 0;
	if ( primaryItemShown  ) then
		totalWidth = totalWidth + shoppingTooltip1:GetWidth();
	end
	if ( secondaryItemShown  ) then
		totalWidth = totalWidth + shoppingTooltip2:GetWidth();
	end

	local rightDist = 0;
	local screenWidth = GetScreenWidth();
	rightDist = screenWidth - rightPos;

	-- find correct side
	local side;
	if ( anchorType and (totalWidth < leftPos) and (anchorType == "ANCHOR_LEFT" or anchorType == "ANCHOR_TOPLEFT" or anchorType == "ANCHOR_BOTTOMLEFT") ) then
		side = "left";
	elseif ( anchorType and (totalWidth < rightDist) and (anchorType == "ANCHOR_RIGHT" or anchorType == "ANCHOR_TOPRIGHT" or anchorType == "ANCHOR_BOTTOMRIGHT") ) then
		side = "right";
	elseif ( rightDist < leftPos ) then
		side = "left";
	else
		side = "right";
	end

	-- see if we should slide the tooltip
	if ( totalWidth > 0 and (anchorType and anchorType ~= "ANCHOR_PRESERVE") ) then --we never slide a tooltip with a preserved anchor
		local slideAmount = 0;
		if ( (side == "left") and (totalWidth > leftPos) ) then
			slideAmount = totalWidth - leftPos;
		elseif ( (side == "right") and (rightPos + totalWidth) >  screenWidth ) then
			slideAmount = screenWidth - (rightPos + totalWidth);
		end

		if (slideAmount ~= 0) then -- if we calculated a slideAmount, we need to slide
			if ( sideAnchorFrame.SetAnchorType ) then
				sideAnchorFrame:SetAnchorType(anchorType, slideAmount, 0);
			else
				self:SetAnchorType(anchorType, slideAmount, 0);
			end
		end
	end

	if ( secondaryItemShown ) then
		shoppingTooltip2:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip2:ClearAllPoints();
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();

		shoppingTooltip1:SetPoint("TOP", anchorFrame, 0, -10);
		shoppingTooltip2:SetPoint("TOP", anchorFrame, 0, -10);
		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("RIGHT", sideAnchorFrame, "LEFT");
		else
			shoppingTooltip2:SetPoint("LEFT", sideAnchorFrame, "RIGHT");
		end

		if ( side and side == "left" ) then
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT");
		else
			shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip2, "TOPRIGHT");
		end
	else
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();

		shoppingTooltip1:SetPoint("TOP", anchorFrame, 0, -10);
		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("RIGHT", sideAnchorFrame, "LEFT");
		else
			shoppingTooltip1:SetPoint("LEFT", sideAnchorFrame, "RIGHT");
		end

		shoppingTooltip2:Hide();
	end
end

function GameTooltip_ShowCompareSpell(self, anchorFrame)
	local azeritePowerID, owningItemLink = self:GetAzeritePowerID();
	if not azeritePowerID or not owningItemLink then
		return false;
	end

	local owningItemSource = AzeriteEmpoweredItemDataSource:CreateFromFromItemLink(owningItemLink);
	local sourceItem = owningItemSource:GetItem();
	if not sourceItem:IsItemDataCached() then
		-- We'll try again later
		return false;
	end

	local equippedItemLocation = ItemLocation:CreateFromEquipmentSlot(sourceItem:GetInventoryType());
	if not C_Item.DoesItemExist(equippedItemLocation) or not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(equippedItemLocation) then
		return false;
	end

	local equippedItemSource = AzeriteEmpoweredItemDataSource:CreateFromItemLocation(equippedItemLocation);
	local equippedItem = equippedItemSource:GetItem(equippedItemLocation);
	if not equippedItem:IsItemDataCached() then
		-- We'll try again later
		return false;
	end

	local powerTierIndex = AzeriteUtil.FindAzeritePowerTier(owningItemSource, azeritePowerID);
	if not powerTierIndex then
		return false;
	end

	local comparisonPowerID = AzeriteUtil.GetSelectedAzeritePowerInTier(equippedItemSource, powerTierIndex);
	if not comparisonPowerID then
		return false;
	end

	local tooltip, anchorFrame, shoppingTooltip1, shoppingTooltip2 = GameTooltip_InitializeComparisonTooltips(self, anchorFrame);

	local itemID = equippedItem:GetItemID();
	local itemLevel = equippedItem:GetCurrentItemLevel();
	shoppingTooltip1:SetAzeritePower(itemID, itemLevel, comparisonPowerID);

	local primaryItemShown = true;
	local secondaryItemShown = false;
	GameTooltip_AnchorComparisonTooltips(tooltip, anchorFrame, shoppingTooltip1, shoppingTooltip2, primaryItemShown, secondaryItemShown);

	shoppingTooltip1:SetCompareAzeritePower(itemID, itemLevel, comparisonPowerID);
	shoppingTooltip1:Show();

	return true;
end

function GameTooltip_ShowCompareItem(self, anchorFrame)
	local tooltip, anchorFrame, shoppingTooltip1, shoppingTooltip2 = GameTooltip_InitializeComparisonTooltips(self, anchorFrame);

	local primaryItemShown, secondaryItemShown = shoppingTooltip1:SetCompareItem(shoppingTooltip2, tooltip);

	GameTooltip_AnchorComparisonTooltips(tooltip, anchorFrame, shoppingTooltip1, shoppingTooltip2, primaryItemShown, secondaryItemShown);

	-- We have to call this again because :SetOwner clears the tooltip.
	shoppingTooltip1:SetCompareItem(shoppingTooltip2, tooltip);
	shoppingTooltip1:Show();
end

function GameTooltip_AdvanceSecondaryCompareItem(self)
	if ( not self ) then
		self = GameTooltip;
	end

	if ( GetCVarBool("allowCompareWithToggle") ) then
		self:AdvanceSecondaryCompareItem();
	end
end

function GameTooltip_ClearStatusBars(self)
	if self.statusBarPool then
		self.statusBarPool:ReleaseAll();
	end
end

function GameTooltip_ShowStatusBar(self, min, max, value, text)
	if not self.statusBarPool then
		self.statusBarPool = CreateFramePool("STATUSBAR", self, "TooltipStatusBarTemplate");
	else
		GameTooltip_ClearStatusBars(self);
	end
	GameTooltip_AddStatusBar(self, min, max, value, text);
end

function GameTooltip_AddStatusBar(self, min, max, value, text)
	GameTooltip_AddBlankLinesToTooltip(self, 1);
	local numLines = self:NumLines();
	local statusBar = self.statusBarPool:Acquire();
	if ( not text ) then
		text = "";
	end
	statusBar.Text:SetText(text);
	statusBar:SetMinMaxValues(min, max);
	statusBar:SetValue(value);
	statusBar:Show();
	statusBar:SetPoint("LEFT", self:GetName().."TextLeft"..numLines, "LEFT", 0, -2);
	statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0);
	statusBar:Show();
	self:SetMinimumWidth(140);
end

function GameTooltip_ClearProgressBars(self)
	if self.progressBarPool then
		self.progressBarPool:ReleaseAll();
	end
end

function GameTooltip_ShowProgressBar(self, min, max, value, text)
	if not self.progressBarPool then
		self.progressBarPool = CreateFramePool("FRAME", self, "TooltipProgressBarTemplate");
	else
		GameTooltip_ClearProgressBars(self);
	end
	GameTooltip_AddProgressBar(self, min, max, value, text);
end

function GameTooltip_AddProgressBar(self, min, max, value, text)
	local progressBar = self.progressBarPool:Acquire();
	progressBar.Bar.Label:SetText(text);
	progressBar.Bar:SetMinMaxValues(min, max);
	progressBar.Bar:SetValue(value);
	progressBar:SetAlpha(1);
	GameTooltip_InsertFrame(self, progressBar);
end

function GameTooltip_ShowHyperlink(self, hyperlinkString, classID, specID, clearTooltip)
	local questRewardID = ExtractQuestRewardID(hyperlinkString);
	if questRewardID then
		-- quest reward hyperlinks are handled in lua
		GameTooltip_AddQuestRewardsToTooltip(self, questRewardID, TOOLTIP_QUEST_REWARDS_STYLE_NO_HEADER);
	else
		self:SetHyperlink(hyperlinkString, classID, specID, clearTooltip);
	end
end

local function WidgetLayout(widgetContainer, sortedWidgets)
	DefaultWidgetLayout(widgetContainer, sortedWidgets);
	widgetContainer.shownWidgetCount = #sortedWidgets;
end

function GameTooltip_AddWidgetSet(self, widgetSetID, verticalPadding)
	if not widgetSetID then
		return;
	end

	if not self.widgetContainer then
		self.widgetContainer = CreateFrame("FRAME", nil, self, "UIWidgetContainerTemplate");
		self.widgetContainer.verticalAnchorPoint = "TOPLEFT";
		self.widgetContainer.verticalRelativePoint = "BOTTOMLEFT";
		self.widgetContainer.showAndHideOnWidgetSetRegistration = false;
		self.widgetContainer.disableWidgetTooltips = true;
		self.widgetContainer:Hide();
	end

	self.widgetContainer:RegisterForWidgetSet(widgetSetID, WidgetLayout);

	if self.widgetContainer.shownWidgetCount > 0 then
		GameTooltip_InsertFrame(self, self.widgetContainer, verticalPadding);
	end
end

function GameTooltip_ClearWidgetSet(self)
	if self.widgetContainer then
		self.widgetContainer:UnregisterForWidgetSet();
	end
end

function GameTooltip_Hide()
	-- Used for XML OnLeave handlers
	GameTooltip:Hide();
	GameTooltip_HideBattlePetTooltip();
end

function GameTooltip_HideResetCursor()
	GameTooltip:Hide();
	ResetCursor();
end

function GameTooltip_AddQuest(self, questID)
	local questID = self.questID or questID;
	if ( not HaveQuestData(questID) ) then
		GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA, RED_FONT_COLOR);
		GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
		GameTooltip:Show();
		return;
	end

	local widgetSetAdded = false;
	local widgetSetID = C_TaskQuest.GetUIWidgetSetIDFromQuestID(questID);

	local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID);
	if ( self.worldQuest or C_QuestLog.IsWorldQuest(questID)) then
		self.worldQuest = true;
		local tagInfo = C_QuestLog.GetQuestTagInfo(self.questID);
		local quality = tagInfo and tagInfo.quality or Enum.WorldQuestQuality.Common;
		local color = WORLD_QUEST_QUALITY_COLORS[quality].color;
		GameTooltip_SetTitle(GameTooltip, title, color);
		QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);

		local factionName = factionID and GetFactionInfoByID(factionID);
		if (factionName) then
			local reputationYieldsRewards = (not capped) or C_Reputation.IsFactionParagon(factionID);
			if (reputationYieldsRewards) then
				GameTooltip:AddLine(factionName);
			else
				GameTooltip:AddLine(factionName, GRAY_FONT_COLOR:GetRGB());
			end
		end

		GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);
	elseif ( self.isThreat or C_QuestLog.IsThreatQuest(questID)) then
		GameTooltip_SetTitle(GameTooltip, title);
		GameTooltip_AddQuestTimeToTooltip(GameTooltip, questID);
	else
		GameTooltip_SetTitle(GameTooltip, title);
	end

	if (self.isCombatAllyQuest or C_QuestLog.GetQuestType(questID) == Enum.QuestTag.CombatAlly) then
		GameTooltip_AddColoredLine(GameTooltip, AVAILABLE_FOLLOWER_QUEST, HIGHLIGHT_FONT_COLOR, true);
		GameTooltip_AddColoredLine(GameTooltip, GRANTS_FOLLOWER_XP, GREEN_FONT_COLOR, true);
	elseif (self.isQuestStart) then
		GameTooltip_AddColoredLine(GameTooltip, AVAILABLE_QUEST, HIGHLIGHT_FONT_COLOR, true);
	else
		local questDescription = "";
		local questCompleted = C_QuestLog.IsComplete(questID);

		if (questCompleted and self.shouldShowObjectivesAsStatusBar) then
			questDescription = QUEST_WATCH_QUEST_READY;
			GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
		elseif (not questCompleted and self.shouldShowObjectivesAsStatusBar) then
			local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
			if (questLogIndex) then 
				questDescription = select(2, GetQuestLogQuestText(questLogIndex));
				GameTooltip_AddColoredLine(GameTooltip, QUEST_DASH .. questDescription, HIGHLIGHT_FONT_COLOR);
			end
		end
		local numObjectives = self.numbObjectives or C_QuestLog.GetNumQuestObjectives(questID);
		for objectiveIndex = 1, numObjectives do
			local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, objectiveIndex, false);
			local showObjective = not (finished and self.isThreat);
			if showObjective then
				if(self.shouldShowObjectivesAsStatusBar) then
					local percent = math.floor((numFulfilled/numRequired) * 100);
					GameTooltip_ShowProgressBar(GameTooltip, 0, numRequired, numFulfilled, PERCENTAGE_STRING:format(percent));
				elseif ( objectiveText and #objectiveText > 0 ) then
					local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
					GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
				end
			end
		end
		local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, 1, false);
		if (objectiveType == "progressbar") then
			local percent = C_TaskQuest.GetQuestProgressBarInfo(questID);
			local showObjective = not (finished and self.isThreat);
			if ( percent  and showObjective ) then
				GameTooltip_ShowProgressBar(GameTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent));
			end
		end

		if (widgetSetID) then
			widgetSetAdded = true;
			GameTooltip_AddWidgetSet(GameTooltip, widgetSetID);
		end

		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, self.questRewardTooltipStyle or TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT);

		if ( self.worldQuest and GameTooltip.AddDebugWorldQuestInfo ) then
			GameTooltip:AddDebugWorldQuestInfo(questID);
		end
	end


	if (not widgetSetAdded and widgetSetID) then
		GameTooltip_AddWidgetSet(GameTooltip, widgetSetID);
	end

	GameTooltip:Show();
end

function EmbeddedItemTooltip_UpdateSize(self)
	local itemTooltipExtraBorderHeight = 22;
	if ( self.Tooltip:IsShown() ) then
		local width = self.Tooltip:GetWidth() + self.Icon:GetWidth();
		local height = math.max(self.Tooltip:GetHeight() - itemTooltipExtraBorderHeight, self.Icon:GetHeight());
		self:SetSize(width, height);
	elseif ( self.FollowerTooltip:IsShown() ) then
		self:SetSize(self.FollowerTooltip:GetSize());
	end

	GameTooltip_CalculatePadding(self:GetParent());
end

function EmbeddedItemTooltip_OnTooltipSetItem(self)
	if (self.itemID and not self.itemTextureSet) then
		local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(self.itemID);
		if (itemTexture) then
			self.Icon:SetTexture(itemTexture);
		end
	end
end

function EmbeddedItemTooltip_Hide(self)
	self:Hide();
	GameTooltip_CalculatePadding(self:GetParent());
end

function EmbeddedItemTooltip_Clear(self)
	self.Icon:Hide();
	self.IconBorder:Hide();
	self.Tooltip:Hide();
	self.FollowerTooltip:Hide();
end

function EmbeddedItemTooltip_PrepareForItem(self)
	EmbeddedItemTooltip_Clear(self);
	self.Icon:Show();
	self.IconBorder:Show();
	self.Tooltip:Show();
end

function EmbeddedItemTooltip_PrepareForSpell(self)
	EmbeddedItemTooltip_Clear(self);
	self.Icon:Show();
	self.Tooltip:Show();
end

function EmbeddedItemTooltip_PrepareForFollower(self)
	EmbeddedItemTooltip_Clear(self);
	self.FollowerTooltip:Show();
end

function EmbeddedItemTooltip_SetItemByID(self, id, count)
	self.itemID = id;
	self.spellID = nil;
	local itemName, _, quality, _, _, _, _, _, _, itemTexture = GetItemInfo(id);
	self:Show();
	EmbeddedItemTooltip_PrepareForItem(self);
	self.Tooltip:SetOwner(self, "ANCHOR_NONE");
	self.Tooltip:SetItemByID(id);
	SetItemButtonQuality(self, quality, id);
	SetItemButtonCount(self, count or 1);
	self.Icon:SetTexture(itemTexture);
	self.itemTextureSet = (itemTexture ~= nil);
	self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
	EmbeddedItemTooltip_UpdateSize(self);
end

function EmbeddedItemTooltip_SetItemByQuestReward(self, questLogIndex, questID, rewardType)
	if not questLogIndex then
		return false;
	end

	rewardType = rewardType or "reward";
	local getterFunc;
	if rewardType == "choice" then
		getterFunc = GetQuestLogChoiceInfo;
	else
		getterFunc = GetQuestLogRewardInfo;
	end

	local itemName, itemTexture, quantity, quality, isUsable, itemID = getterFunc(questLogIndex, questID);
	if itemName and itemTexture then
		self.itemID = itemID;
		self.spellID = nil;

		self:Show();
		EmbeddedItemTooltip_PrepareForItem(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetQuestLogItem(rewardType, questLogIndex, questID);
		SetItemButtonQuality(self, quality, itemID);
		SetItemButtonCount(self, quantity);
		self.Icon:SetTexture(itemTexture);
		self.itemTextureSet = (itemTexture ~= nil);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);

		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetSpellByQuestReward(self, rewardIndex, questID)
	local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, genericUnlock, spellID = GetQuestLogRewardSpell(rewardIndex, questID);
	if garrFollowerID then
		self:Show();
		EmbeddedItemTooltip_PrepareForFollower(self);
		local data = GarrisonFollowerTooltipTemplate_BuildDefaultDataForID(garrFollowerID);
		GarrisonFollowerTooltipTemplate_SetGarrisonFollower(self.FollowerTooltip, data);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	elseif name and texture then
		self.itemID = nil;
		self.spellID = spellID;

		self:Show();
		EmbeddedItemTooltip_PrepareForSpell(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetQuestLogRewardSpell(rewardIndex, questID);
		SetItemButtonQuality(self, Enum.ItemQuality.Common);
		SetItemButtonCount(self, 0);
		self.Icon:SetTexture(texture);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetSpellWithTextureByID(self, spellID, texture)
	if texture then
		self.itemID = nil;
		self.spellID = spellID;

		self:Show();
		EmbeddedItemTooltip_PrepareForSpell(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:AddSpellByID(spellID);
		SetItemButtonQuality(self, Enum.ItemQuality.Common);
		SetItemButtonCount(self, 0);
		self.Icon:SetTexture(texture);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetCurrencyByID(self, currencyID, quantity)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	local name = currencyInfo.name;
	local texture = currencyInfo.iconFileID;
	local quality = currencyInfo.quality;
	if name and texture then
		self.itemID = nil;
		self.spellID = nil;
		self.itemTextureSet = false;
		EmbeddedItemTooltip_PrepareForItem(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);

		local displayQuantity;
		name, texture, displayQuantity, quality = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, texture, quality);
		self.Tooltip:SetCurrencyByID(currencyID, quantity);
		SetItemButtonQuality(self, quality, currencyID);
		self.Icon:SetTexture(texture);
		SetItemButtonCount(self, displayQuantity);

		self:Show();
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end