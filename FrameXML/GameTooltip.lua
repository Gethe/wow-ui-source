
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

function GameTooltip_SetBasicTooltip(tooltip, text, x, y)
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:ClearAllPoints();
	tooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y);
	tooltip:SetText(text, HIGHLIGHT_FONT_COLOR:GetRGB());
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
	local r, g, b, a = color:GetRGBA();
	tooltip:AddLine(text, r, g, b, a, wrap);
end

function GameTooltip_AddQuestRewardsToTooltip(tooltip, questID, style)
	if ( not style ) then
		style = TOOLTIP_QUEST_REWARDS_STYLE_DEFAULT;
	end
	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 or GetQuestLogRewardHonor(questID) ) then
		GameTooltip_AddBlankLinesToTooltip(tooltip, style.prefixBlankLineCount);
		GameTooltip_AddColoredLine(tooltip, style.headerText, style.headerColor, style.wrapHeaderText);
		GameTooltip_AddBlankLinesToTooltip(tooltip, style.postHeaderBlankLineCount);

		local hasAnySingleLineRewards = false;
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			GameTooltip_AddColoredLine(tooltip, BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR);
			if (C_PvP.IsWarModeDesired()) then 
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
		local numAddedQuestCurrencies = QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, tooltip.ItemTooltip);
		if ( numAddedQuestCurrencies > 0 ) then
			hasAnySingleLineRewards = true;
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
			if (C_PvP.IsWarModeDesired() and QuestUtils_IsQuestWorldQuest(questID)) then 
				tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE);
			end
			hasAnySingleLineRewards = true;
		end

		-- items
		local numQuestRewards = GetNumQuestLogRewards(questID);
		if numQuestRewards > 0 then
			if ( hasAnySingleLineRewards ) then
				GameTooltip_AddBlankLinesToTooltip(tooltip, 1);
			end

			if not EmbeddedItemTooltip_SetItemByQuestReward(tooltip.ItemTooltip, 1, questID) then  -- Only support one currently
				GameTooltip_AddColoredLine(tooltip, RETRIEVING_DATA, RED_FONT_COLOR);
			end

			if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
				GameTooltip_ShowCompareItem(tooltip.ItemTooltip.Tooltip, tooltip.BackdropFrame);
			else
				for i, tooltip in ipairs(tooltip.ItemTooltip.Tooltip.shoppingTooltips) do
					tooltip:Hide();
				end
			end
		end
	end
end

function GameTooltip_CalculatePadding(tooltip)
	if tooltip.ItemTooltip:IsShown() then
		local oldPaddingWidth, oldPaddingHeight = tooltip:GetPadding();
		local tooltipWidth = tooltip:GetWidth() - oldPaddingWidth;
		local itemTooltipWidth = tooltip.ItemTooltip:GetWidth();
		if tooltipWidth > itemTooltipWidth + 6 then
			paddingWidth = 0;
		else
			paddingWidth = itemTooltipWidth - tooltipWidth + 9;
		end
		paddingHeight = tooltip.ItemTooltip:GetHeight() + 5;
		if(math.abs(paddingWidth - oldPaddingWidth) > 0.5 or math.abs(paddingHeight - oldPaddingHeight) > 0.5) then
			tooltip:SetPadding(paddingWidth, paddingHeight);
		end
	end
end

function GameTooltip_OnLoad(self)
	self.needsReset = true;
	self.updateTooltip = TOOLTIP_UPDATE_TIME;
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.statusBar2 = _G[self:GetName().."StatusBar2"];
	self.statusBar2Text = _G[self:GetName().."StatusBar2Text"];
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

function GameTooltip_ClearStatusBars(self)
	if ( not self.shownStatusBars ) then
		return;
	end
	local statusBar;
	for i=1, self.shownStatusBars do
		statusBar = _G[self:GetName().."StatusBar"..i];
		if ( statusBar ) then
			statusBar:Hide();
		end
	end
	self.shownStatusBars = 0;
end

function GameTooltip_OnHide(self)
	self.needsReset = true;
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.default = nil;
	self.overrideComparisonAnchorFrame = nil;
	self.overrideComparisonAnchorSide = nil;
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearStatusBars(self);
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

function GameTooltip_ShowCompareItem(self, anchorFrame)
	if ( not self ) then
		self = GameTooltip;
	end

	if( not anchorFrame ) then
		anchorFrame = self.overrideComparisonAnchorFrame or self;
	end

	if ( self.needsReset ) then
		self:ResetSecondaryCompareItem();
		GameTooltip_AdvanceSecondaryCompareItem(self);
		self.needsReset = false;
	end

	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);

	local primaryItemShown, secondaryItemShown = shoppingTooltip1:SetCompareItem(shoppingTooltip2, self);

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

	-- We have to call this again because :SetOwner clears the tooltip.
	shoppingTooltip1:SetCompareItem(shoppingTooltip2, self);
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

function GameTooltip_ShowStatusBar(self, min, max, value, text)
	GameTooltip_AddBlankLinesToTooltip(self, 1);
	local numLines = self:NumLines();
	if ( not self.numStatusBars ) then
		self.numStatusBars = 0;
	end
	if ( not self.shownStatusBars ) then
		self.shownStatusBars = 0;
	end
	local index = self.shownStatusBars+1;
	local name = self:GetName().."StatusBar"..index;
	local statusBar = _G[name];
	if ( not statusBar ) then
		self.numStatusBars = self.numStatusBars+1;
		statusBar = CreateFrame("StatusBar", name, self, "TooltipStatusBarTemplate");
	end
	if ( not text ) then
		text = "";
	end
	_G[name.."Text"]:SetText(text);
	statusBar:SetMinMaxValues(min, max);
	statusBar:SetValue(value);
	statusBar:Show();
	statusBar:SetPoint("LEFT", self:GetName().."TextLeft"..numLines, "LEFT", 0, -2);
	statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0);
	statusBar:Show();
	self.shownStatusBars = index;
	self:SetMinimumWidth(140);
end

local function WidgetLayout(widgetContainer, sortedWidgets)
	local widgetsHeight = 0;
	local maxWidgetWidth = 0;

	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP");
			widgetsHeight = widgetsHeight + widgetFrame:GetHeight();
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM", 0, -10);
			widgetsHeight = widgetsHeight + widgetFrame:GetHeight() + 10;
		end

		local widgetWidth = widgetFrame:GetWidth();
		if widgetWidth > maxWidgetWidth then
			maxWidgetWidth = widgetWidth;
		end
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
			self.widgetContainer = CreateFrame("FRAME");
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
	BattlePetTooltip:Hide();
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