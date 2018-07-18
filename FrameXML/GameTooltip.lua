
TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
}

TOOLTIP_QUEST_REWARDS_STYLE_CONTRIBUTION = {
	headerText = CONTRIBUTION_REWARD_TOOLTIP_TEXT,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
}

TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY = {
	headerText = PVP_BOUNTY_REWARD_TITLE,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = false,
}

TOOLTIP_QUEST_REWARDS_STYLE_ISLANDS_QUEUE = {
	headerText = ISLAND_QUEUE_REWARD_FOR_WINNING,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 0,
	postHeaderBlankLineCount = 1,
	wrapHeaderText = false,
}

TOOLTIP_QUEST_REWARDS_STYLE_EMISSARY_REWARD = {
	headerText = QUEST_REWARDS,
	headerColor = NORMAL_FONT_COLOR,
	prefixBlankLineCount = 1,
	postHeaderBlankLineCount = 0,
	wrapHeaderText = true,
	emissaryHack = true,
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
	tooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
	tooltip.default = 1;
end

function GameTooltip_SetBasicTooltip(tooltip, text, x, y, wrap)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:ClearAllPoints();
	tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
	local r, g, b = HIGHLIGHT_FONT_COLOR:GetRGB();
	tooltip:SetText(text, r, g, b, 1, wrap);
end

function GameTooltip_AddBlankLinesToTooltip(tooltip, numLines)
	if numLines ~= nil then
		for i = 1, numLines do
			tooltip:AddLine(" ");
		end
	end
end

function GameTooltip_SetTitle(tooltip, text, overrideColor, wrap)
	local titleColor = overrideColor or HIGHLIGHT_FONT_COLOR;
	local r, g, b, a = titleColor:GetRGBA();
	tooltip:SetText(text, r, g, b, a, wrap);
end

function GameTooltip_AddNormalLine(tooltip, text, wrap)
	GameTooltip_AddColoredLine(tooltip, text, NORMAL_FONT_COLOR, wrap);
end

function GameTooltip_AddInstructionLine(tooltip, text, wrap)
	GameTooltip_AddColoredLine(tooltip, text, GREEN_FONT_COLOR, wrap);
end

function GameTooltip_AddColoredLine(tooltip, text, color, wrap)
	local r, g, b = color:GetRGB();
	tooltip:AddLine(text, r, g, b, wrap);
end

function GameTooltip_AddQuestRewardsToTooltip(tooltip, questID, style)
	style = style or TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT;

	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 or GetQuestLogRewardHonor(questID) ) then
		tooltip.ItemTooltip:Hide();
		local showRetrievingData = false;

		GameTooltip_AddBlankLinesToTooltip(tooltip, style.prefixBlankLineCount);
		GameTooltip_AddColoredLine(tooltip, style.headerText, style.headerColor, style.wrapHeaderText);
		GameTooltip_AddBlankLinesToTooltip(tooltip, style.postHeaderBlankLineCount);

		local hasAnySingleLineRewards = false;
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR);
			if (C_PvP.IsWarModeDesired() and C_QuestLog.QuestHasWarModeBonus(questID)) then
				tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_XP);
			end
			hasAnySingleLineRewards = true;
		end
		local artifactXP = GetQuestLogRewardArtifactXP(questID);
		if ( artifactXP > 0 ) then
			GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR);
			hasAnySingleLineRewards = true;
		end
		-- currency
		if not style.emissaryHack then
			local numAddedQuestCurrencies, usingCurrencyContainer = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
			if ( numAddedQuestCurrencies > 0 ) then
				hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
			end
		end
		-- honor
		local honorAmount = GetQuestLogRewardHonor(questID);
		if ( honorAmount > 0 ) then
			GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format("Interface\\ICONS\\Achievement_LegionPVPTier4", honorAmount, HONOR), HIGHLIGHT_FONT_COLOR);
			hasAnySingleLineRewards = true;
		end
		-- money
		local money = GetQuestLogRewardMoney(questID);
		if ( money > 0 ) then
			SetTooltipMoney(tooltip, money, nil);
			if (C_PvP.IsWarModeDesired() and QuestUtils_IsQuestWorldQuest(questID) and C_QuestLog.QuestHasWarModeBonus(questID)) then
				tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE);
			end
			hasAnySingleLineRewards = true;
		end

		-- items
		local numQuestRewards = GetNumQuestLogRewards(questID);
		if numQuestRewards > 0 then
			if not EmbeddedItemTooltip_SetItemByQuestReward(tooltip.ItemTooltip , 1, questID) then  -- Only support one currently
				showRetrievingData = true;
			end

			if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
				GameTooltip_ShowCompareItem(tooltip.ItemTooltip.Tooltip, tooltip.BackdropFrame);
			else
				for i, tooltip in ipairs(tooltip.ItemTooltip.Tooltip.shoppingTooltips) do
					tooltip:Hide();
				end
			end
		end

		-- emissary hack: Only show azerite if nothing else
		-- in the case of double azerite, only show the currency container one
		if style.emissaryHack and not hasAnySingleLineRewards and not tooltip.ItemTooltip:IsShown() then
			local numAddedQuestCurrencies, usingCurrencyContainer = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
			if ( numAddedQuestCurrencies > 0 ) then
				hasAnySingleLineRewards = not usingCurrencyContainer or numAddedQuestCurrencies > 1;
				if usingCurrencyContainer and numAddedQuestCurrencies > 1 then
					EmbeddedItemTooltip_Clear(tooltip.ItemTooltip);
					tooltip.ItemTooltip:Hide();
					tooltip:Show();
				end
			end
		end

		if hasAnySingleLineRewards and tooltip.ItemTooltip:IsShown() then
			GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
			if showRetrievingData then
				GameTooltip_AddColoredLine(tooltip, RETRIEVING_DATA, RED_FONT_COLOR);
			end
		end
	end
end

function GameTooltip_CalculatePadding(tooltip)
	local itemWidth, itemHeight, bottomFontStringWidth, bottomFontStringHeight = 0, 0, 0, 0;

	if tooltip.ItemTooltip:IsShown() then
		itemWidth, itemHeight = tooltip.ItemTooltip:GetSize();
		itemWidth = itemWidth + 9; -- extra padding for this line
	end

	if tooltip.BottomFontString and tooltip.BottomFontString:IsShown() then
		bottomFontStringWidth, bottomFontStringHeight = tooltip.BottomFontString:GetSize();
		bottomFontStringHeight = bottomFontStringHeight + 7;
		bottomFontStringWidth = bottomFontStringWidth + 20; -- extra width padding for this line
		tooltip.ItemTooltip:SetPoint("BOTTOMLEFT", tooltip.BottomFontString, "TOPLEFT", 0, 10);
	else
		tooltip.ItemTooltip:SetPoint("BOTTOMLEFT", 10, 13);
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

	if(math.abs(paddingWidth - oldPaddingWidth) > 0.5 or math.abs(paddingHeight - oldPaddingHeight) > 0.5) then
		tooltip:SetPadding(paddingWidth, paddingHeight);
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
	self.needsReset = true;
	self.updateTooltip = TOOLTIP_UPDATE_TIME;
	GameTooltip_SetBackdropStyle(self, GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT);
	self:SetClampRectInsets(0, 0, 15, 0);
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

function GameTooltip_InsertFrame(tooltipFrame, frame)
	local textSpacing = 2;
	local textHeight = _G[tooltipFrame:GetName().."TextLeft2"]:GetLineHeight();
	local numLinesNeeded = math.ceil(frame:GetHeight() / (textHeight + textSpacing));
	local currentLine = tooltipFrame:NumLines();
	GameTooltip_AddBlankLinesToTooltip(tooltipFrame, numLinesNeeded);
	frame:SetParent(tooltipFrame);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", tooltipFrame:GetName().."TextLeft"..(currentLine + 1), "TOPLEFT", 0, 0);
	if ( not tooltipFrame.insertedFrames ) then
		tooltipFrame.insertedFrames = { };
	end
	local frameWidth = frame:GetWidth();
	if ( tooltipFrame:GetMinimumWidth() < frameWidth ) then
		tooltipFrame:SetMinimumWidth(frameWidth);
	end
	frame:Show();
	tinsert(tooltipFrame.insertedFrames, frame);
	-- return space taken so inserted frame can resize if needed
	return (numLinesNeeded * textHeight) + (numLinesNeeded - 1) * textSpacing;
end

function GameTooltip_ClearInsertedFrames(self)
	if ( self.insertedFrames ) then
		for i = 1, #self.insertedFrames do
			self.insertedFrames[i]:SetParent(nil);
			self.insertedFrames[i]:Hide();
		end
	end
	self.insertedFrames = nil;
end

GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR,
};

GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED = {
	-- Nothing
};

TOOLTIP_AZERITE_BACKGROUND_COLOR = CreateColor(1, 1, 1);
GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background-Azerite",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border-Azerite",
	tile = true,
	tileEdge = false,
	tileSize = 16,
	edgeSize = 19,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },

	backdropBorderColor = TOOLTIP_DEFAULT_COLOR,
	backdropColor = TOOLTIP_AZERITE_BACKGROUND_COLOR,

	overlayAtlasTop = "AzeriteTooltip-Topper";
	overlayAtlasTopScale = .75,
	overlayAtlasBottom = "AzeriteTooltip-Bottom";
};

function GameTooltip_SetBackdropStyle(self, style)
	self:SetBackdrop(style);
	self:SetBackdropBorderColor((style.backdropBorderColor or TOOLTIP_DEFAULT_COLOR):GetRGB());
	self:SetBackdropColor((style.backdropColor or TOOLTIP_DEFAULT_BACKGROUND_COLOR):GetRGB());

	if self.TopOverlay then
		if style.overlayAtlasTop then
			self.TopOverlay:SetAtlas(style.overlayAtlasTop, true);
			self.TopOverlay:SetScale(style.overlayAtlasTopScale or 1.0);
			self.TopOverlay:Show();
		else
			self.TopOverlay:Hide();
		end
	end

	if self.BottomOverlay then
		if style.overlayAtlasBottom then
			self.BottomOverlay:SetAtlas(style.overlayAtlasBottom, true);
			self.BottomOverlay:SetScale(style.overlayAtlasBottomScale or 1.0);
			self.BottomOverlay:Show();
		else
			self.BottomOverlay:Hide();
		end
	end
end

function GameTooltip_OnHide(self)
	self.needsReset = true;
	GameTooltip_SetBackdropStyle(self, self.IsEmbedded and GAME_TOOLTIP_BACKDROP_STYLE_EMBEDDED or GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT);
	self.default = nil;
	self.overrideComparisonAnchorFrame = nil;
	self.overrideComparisonAnchorSide = nil;
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
end

function GameTooltip_CycleSecondaryComparedItem(self)
	GameTooltip_AdvanceSecondaryCompareItem(self);

	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
	if ( shoppingTooltip1:IsShown() ) then
		GameTooltip_ShowCompareItem(self);
	end
end

function GameTooltip_OnUpdate(self, elapsed)
	if self.recalculatePadding then
		self.recalculatePadding = nil;
		GameTooltip_CalculatePadding(self);
	end

	-- Only update every TOOLTIP_UPDATE_TIME seconds
	self.updateTooltip = self.updateTooltip - elapsed;
	if ( self.updateTooltip > 0 ) then
		return;
	end
	self.updateTooltip = TOOLTIP_UPDATE_TIME;

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

function GameTooltip_AddNewbieTip(frame, normalText, r, g, b, newbieText, noNormalText)
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, frame);
		if ( normalText ) then
			GameTooltip_SetTitle(GameTooltip, normalText, CreateColor(r, g, b, 1));
			GameTooltip_AddNormalLine(GameTooltip, newbieText, true);
		else
			GameTooltip_SetTitle(GameTooltip, newbieText, CreateColor(r, g, b, 1), true);
		end
		GameTooltip:Show();
	else
		if ( not noNormalText ) then
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
			GameTooltip:SetText(normalText, r, g, b);
		end
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
	local _, itemLink = self:GetItem();
	if itemLink and (C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemLink) or C_AzeriteItem.IsAzeriteItemByID(itemLink)) then
		GameTooltip_SetBackdropStyle(self, GAME_TOOLTIP_BACKDROP_STYLE_AZERITE_ITEM);
	else
		GameTooltip_SetBackdropStyle(self, GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT);
	end
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

	if not anchorFrame then
		anchorFrame = self.overrideComparisonAnchorFrame or self;
	end

	if self.needsReset then
		self:ResetSecondaryCompareItem();
		GameTooltip_AdvanceSecondaryCompareItem(self);
		self.needsReset = false;
	end

	return self, anchorFrame, unpack(self.shoppingTooltips);
end

function GameTooltip_AnchorComparisonTooltips(self, anchorFrame, shoppingTooltip1, shoppingTooltip2, primaryItemShown, secondaryItemShown)
	local leftPos = anchorFrame:GetLeft();
	local rightPos = anchorFrame:GetRight();

	local side;
	local anchorType = self:GetAnchorType();
	local totalWidth = 0;
	if ( primaryItemShown  ) then
		totalWidth = totalWidth + shoppingTooltip1:GetWidth();
	end
	if ( secondaryItemShown  ) then
		totalWidth = totalWidth + shoppingTooltip2:GetWidth();
	end
	if ( self.overrideComparisonAnchorSide ) then
		side = self.overrideComparisonAnchorSide;
	else
		-- find correct side
		local rightDist = 0;
		if ( not rightPos ) then
			rightPos = 0;
		end
		if ( not leftPos ) then
			leftPos = 0;
		end

		rightDist = GetScreenWidth() - rightPos;

		if ( anchorType and totalWidth < leftPos and (anchorType == "ANCHOR_LEFT" or anchorType == "ANCHOR_TOPLEFT" or anchorType == "ANCHOR_BOTTOMLEFT") ) then
			side = "left";
		elseif ( anchorType and totalWidth < rightDist and (anchorType == "ANCHOR_RIGHT" or anchorType == "ANCHOR_TOPRIGHT" or anchorType == "ANCHOR_BOTTOMRIGHT") ) then
			side = "right";
		elseif ( rightDist < leftPos ) then
			side = "left";
		else
			side = "right";
		end
	end

	-- see if we should slide the tooltip
	if ( anchorType and anchorType ~= "ANCHOR_PRESERVE" ) then
		if ( (side == "left") and (totalWidth > leftPos) ) then
			self:SetAnchorType(anchorType, (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			self:SetAnchorType(anchorType, -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	if ( secondaryItemShown ) then
		shoppingTooltip2:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip2:ClearAllPoints();
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();

		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", 0, -10);
		else
			shoppingTooltip2:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 0, -10);
		end

		if ( side and side == "left" ) then
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT");
		else
			shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip2, "TOPRIGHT");
		end
	else
		shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip1:ClearAllPoints();

		if ( side and side == "left" ) then
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", 0, -10);
		else
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 0, -10);
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
	progressBar:Show();
	GameTooltip_InsertFrame(self, progressBar);
end

local function WidgetLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 0;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOPLEFT", widgetContainer, "TOPLEFT", 0, -10);
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOPLEFT", relative, "BOTTOMLEFT", 0, -10);
		end

		widgetsHeight = widgetsHeight + widgetFrame:GetHeight() + 10;

		local widgetWidth = widgetFrame:GetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end

		widgetFrame:EnableMouse(false);
	end

	widgetContainer:SetHeight(widgetsHeight);
	widgetContainer:SetWidth(maxWidgetWidth);
end

function GameTooltip_AddWidgetSet(self, widgetSetID)
	if self.widgetSetID == widgetSetID then
		GameTooltip_InsertFrame(self, self.widgetContainer);
		return;
	end

	GameTooltip_ClearWidgetSet(self);

	if widgetSetID then
		if not self.widgetContainer then
			self.widgetContainer = CreateFrame("FRAME", nil, self);
		else
			self.widgetContainer:SetParent(self);
		end

		UIWidgetManager:RegisterWidgetSetContainer(widgetSetID, self.widgetContainer, WidgetLayout);
		GameTooltip_InsertFrame(self, self.widgetContainer);
	end

	self.widgetSetID = widgetSetID;
end

function GameTooltip_ClearWidgetSet(self)
	if self.widgetSetID then
		UIWidgetManager:UnregisterWidgetSetContainer(self.widgetSetID, self.widgetContainer);
		self.widgetSetID = nil;
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

function EmbeddedItemTooltip_UpdateSize(self)
	local itemTooltipExtraBorderHeight = 22;
	if ( self.Tooltip:IsShown() ) then
		local width = self.Tooltip:GetWidth() + self.Icon:GetWidth();
		local height = math.max(self.Tooltip:GetHeight() - itemTooltipExtraBorderHeight, self.Icon:GetHeight());
		self:SetSize(width, height);
	elseif ( self.FollowerTooltip:IsShown() ) then
		self:SetSize(self.FollowerTooltip:GetSize());
	end
end

function EmbeddedItemTooltip_OnTooltipSetItem(self)
	if (self.itemID and not self.itemTextureSet) then
		local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(self.itemID);
		if (itemTexture) then
			self.Icon:SetTexture(itemTexture);
		end
	end
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

function EmbeddedItemTooltip_SetItemByID(self, id)
	self.itemID = id;
	self.spellID = nil;
	local itemName, _, quality, _, _, _, _, _, _, itemTexture = GetItemInfo(id);
	self:Show();
	EmbeddedItemTooltip_PrepareForItem(self);
	self.Tooltip:SetOwner(self, "ANCHOR_NONE");
	self.Tooltip:SetItemByID(id);
	SetItemButtonQuality(self, quality, id);
	SetItemButtonCount(self, 1);
	self.Icon:SetTexture(itemTexture);
	self.itemTextureSet = (itemTexture ~= nil);
	self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
	EmbeddedItemTooltip_UpdateSize(self);
end

function EmbeddedItemTooltip_SetItemByQuestReward(self, questLogIndex, questID)
	local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(questLogIndex, questID);
	if itemName and itemTexture then
		self.itemID = itemID;
		self.spellID = nil;

		self:Show();
		EmbeddedItemTooltip_PrepareForItem(self);
		self.Tooltip:SetOwner(self, "ANCHOR_NONE");
		self.Tooltip:SetQuestLogItem("reward", questLogIndex, questID);
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
		SetItemButtonQuality(self, LE_ITEM_QUALITY_COMMON);
		SetItemButtonCount(self, 0);
		self.Icon:SetTexture(texture);
		self.Tooltip:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 0, 10);
		EmbeddedItemTooltip_UpdateSize(self);
		return true;
	end
	return false;
end

function EmbeddedItemTooltip_SetCurrencyByID(self, currencyID, quantity)
	local name, _, texture, _, _, _, _, quality = GetCurrencyInfo(currencyID);
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