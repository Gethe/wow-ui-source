local _, addonTable = ...

local MoneyTypeInfo = addonTable.MoneyTypeInfo;

local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

function MoneyFrame_OnLoadMoneyType(self, moneyType)
	moneyType = moneyType or self.moneyType;

	--If there's a moneyType we'll use the new way of doing things, otherwise do things the old way
	if moneyType then
		local info = MoneyTypeInfo[moneyType];
		if info then
			--This way you can just register for the events that you care about
			if info.OnloadFunc then
				info.OnloadFunc(self);
			end

			MoneyFrame_SetType(self, moneyType);
			return true;
		end
	end

	return false;
end

function MoneyFrame_OnLoad (self, moneyType)
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("ACCOUNT_MONEY");
	self:RegisterEvent("PLAYER_TRADE_MONEY");
	self:RegisterEvent("TRADE_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_COD_CHANGED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	MoneyFrame_OnLoadMoneyType(self, moneyType or "PLAYER");
end

function SmallMoneyFrame_OnLoad(self, moneyType)
	if not MoneyFrame_OnLoadMoneyType(self, moneyType) then
		--The old sucky way of doing things
		self:RegisterEvent("PLAYER_MONEY");
		self:RegisterEvent("ACCOUNT_MONEY");
		self:RegisterEvent("PLAYER_TRADE_MONEY");
		self:RegisterEvent("TRADE_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_COD_CHANGED");
		self:RegisterEvent("TRIAL_STATUS_UPDATE");
		MoneyFrame_SetType(self, "PLAYER");
	end
end

function MoneyFrame_OnEvent (self, event, ...)
	if ( not self.info or not self:IsVisible() ) then
		return;
	end

	local moneyType = self.moneyType;

	if ( event == "PLAYER_MONEY" and moneyType == "PLAYER" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "ACCOUNT_MONEY" and moneyType == "ACCOUNT" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "TRIAL_STATUS_UPDATE" and moneyType == "PLAYER" ) then
		MoneyFrame_UpdateTrialErrorButton(self);
	elseif ( event == "PLAYER_TRADE_MONEY" and (moneyType == "PLAYER" or moneyType == "PLAYER_TRADE") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "TRADE_MONEY_CHANGED" and moneyType == "TARGET_TRADE" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "SEND_MAIL_MONEY_CHANGED" and (moneyType == "PLAYER" or moneyType == "SEND_MAIL") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "SEND_MAIL_COD_CHANGED" and (moneyType == "PLAYER" or moneyType == "SEND_MAIL_COD") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "GUILDBANK_UPDATE_MONEY" and moneyType == "GUILDBANK" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "GUILDBANK_UPDATE_WITHDRAWMONEY" and moneyType == "GUILDBANKWITHDRAW" ) then
		MoneyFrame_UpdateMoney(self);
	end
end

function MoneyFrame_OnEnter(moneyFrame)
	if ( moneyFrame.showTooltip ) then
		local copperButton = moneyFrame.CopperButton;
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(copperButton, "ANCHOR_TOPRIGHT", 20, 2);
		SetTooltipMoney(tooltip, moneyFrame.staticMoney, "TOOLTIP", "");
		tooltip:Show();
	end
end

function MoneyFrame_OnLeave(moneyFrame)
	if ( moneyFrame.showTooltip ) then
		local tooltip = GetAppropriateTooltip();
		tooltip:Hide();
	end
end

function MoneyFrame_OnHide(self)
	if self.hasPickup == 1 then
		MoneyInputFrame_ClosePopup();
		self.hasPickup = 0;
	end
end

function MoneyFrame_SetType(self, type)
	local info = MoneyTypeInfo[type];
	if ( not info ) then
		message("Invalid money type: "..type);
		return;
	end
	self.info = info;
	self.moneyType = type;

	local goldButton = self.GoldButton;
	local silverButton = self.SilverButton;
	local copperButton = self.CopperButton;
	if ( info.canPickup ) then
		goldButton:EnableMouse(true);
		silverButton:EnableMouse(true);
		copperButton:EnableMouse(true);
	else
		goldButton:EnableMouse(false);
		silverButton:EnableMouse(false);
		copperButton:EnableMouse(false);
	end
end

function MoneyFrame_SetMaxDisplayWidth(moneyFrame, width)
	moneyFrame.maxDisplayWidth = width;
end

-- Update the money shown in a money frame
function MoneyFrame_UpdateMoney(moneyFrame)
	assert(moneyFrame);

	if ( moneyFrame.info ) then
		local money = moneyFrame.info.UpdateFunc(moneyFrame);
		if ( money ) then
			MoneyFrame_Update(moneyFrame, money);
		end
	else
		message("Error moneyType not set");
	end
end

local function InitCoinButton(button, atlas, iconWidth)
	if not button or not atlas then
		return;
	end
	local texture = button:CreateTexture();
	texture:SetAtlas(atlas, true);
	texture:SetWidth(iconWidth);
	texture:SetHeight(iconWidth);
	texture:SetPoint("RIGHT");
	button:SetNormalTexture(texture);
end

function MoneyFrame_SetDisplayForced(frame, forceShow)
	frame.forceShow = forceShow;
end

local function GetMoneyFrame(frameOrName)
	local argType = type(frameOrName);
	if argType == "table" then
		return frameOrName;
	elseif argType == "string" then
		return _G[frameOrName];
	end

	return nil;
end

function MoneyFrame_Update(frameName, money, forceShow)
	local frame = GetMoneyFrame(frameName);
	forceShow = forceShow or frame.forceShow;

	local info = frame.info;
	if ( not info ) then
		message("Error moneyType not set");
	end

	-- Breakdown the money into denominations
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local goldDisplay = BreakUpLargeNumbers(gold);
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	local goldButton = frame.GoldButton;
	local silverButton = frame.SilverButton;
	local copperButton = frame.CopperButton;

	local iconWidth = MONEY_ICON_WIDTH;
	local spacing = MONEY_BUTTON_SPACING;
	if ( frame.small ) then
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		spacing = MONEY_BUTTON_SPACING_SMALL;
	end

	local maxDisplayWidth = frame.maxDisplayWidth;

	-- Set values for each denomination
	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
		if ( not frame.colorblind or not frame.vadjust or frame.vadjust ~= MONEY_TEXT_VADJUST ) then
			frame.colorblind = true;
			frame.vadjust = MONEY_TEXT_VADJUST;
			goldButton:ClearNormalTexture();
			silverButton:ClearNormalTexture();
			copperButton:ClearNormalTexture();
			goldButton.Text:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			silverButton.Text:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			copperButton.Text:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
		end
		goldButton:SetText(goldDisplay .. GOLD_AMOUNT_SYMBOL);
		goldButton:SetWidth(goldButton:GetTextWidth());
		goldButton:Show();
		silverButton:SetText(silver .. SILVER_AMOUNT_SYMBOL);
		silverButton:SetWidth(silverButton:GetTextWidth());
		silverButton:Show();
		copperButton:SetText(copper .. COPPER_AMOUNT_SYMBOL);
		copperButton:SetWidth(copperButton:GetTextWidth());
		copperButton:Show();
	else
		if ( frame.colorblind or not frame.vadjust or frame.vadjust ~= MONEY_TEXT_VADJUST ) then
			frame.colorblind = nil;
			frame.vadjust = MONEY_TEXT_VADJUST;

			InitCoinButton(goldButton, "coin-gold", iconWidth);
			InitCoinButton(silverButton, "coin-silver", iconWidth);
			InitCoinButton(copperButton, "coin-copper", iconWidth);

			goldButton.Text:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			silverButton.Text:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			copperButton.Text:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
		end
		goldButton:SetText(goldDisplay);
		goldButton:SetWidth(goldButton:GetTextWidth() + iconWidth);
		goldButton:Show();
		silverButton:SetText(silver);
		silverButton:SetWidth(silverButton:GetTextWidth() + iconWidth);
		silverButton:Show();
		copperButton:SetText(copper);
		copperButton:SetWidth(copperButton:GetTextWidth() + iconWidth);
		copperButton:Show();
	end

	-- Store how much money the frame is displaying
	frame.staticMoney = money;
	frame.showTooltip = nil;

	-- If not collapsable or not using maxDisplayWidth don't need to continue
	if ( not info.collapse and not maxDisplayWidth ) then
		return;
	end

	local width = iconWidth;

	local showLowerDenominations, truncateCopper;
	if ( gold > 0 ) then
		width = width + goldButton:GetWidth();
		if ( info.showSmallerCoins ) then
			showLowerDenominations = 1;
		end
		if ( info.truncateSmallCoins ) then
			truncateCopper = 1;
		end
	else
		goldButton:Hide();
	end

	goldButton:ClearAllPoints();
	local hideSilver = true;
	if ( silver > 0 or showLowerDenominations ) then
		hideSilver = false;
		-- Exception if showLowerDenominations and fixedWidth
		if ( showLowerDenominations and info.fixedWidth ) then
			silverButton:SetWidth(COIN_BUTTON_WIDTH);
		end

		local silverWidth = silverButton:GetWidth();
		goldButton:SetPoint("RIGHT", silverButton, "LEFT", spacing, 0);
		if ( goldButton:IsShown() ) then
			silverWidth = silverWidth - spacing;
		end
		if ( info.showSmallerCoins ) then
			showLowerDenominations = 1;
		end
		-- hide silver if not enough room
		if ( maxDisplayWidth and (width + silverWidth) > maxDisplayWidth ) then
			hideSilver = true;
			frame.showTooltip = true;
		else
			width = width + silverWidth;
		end
	end
	if ( hideSilver ) then
		silverButton:Hide();
		goldButton:SetPoint("RIGHT", silverButton,	"RIGHT", 0, 0);
	end

	copper = FormatDisplayCopper(info.checkGoldThreshold, gold, silver, copper);

	-- Used if we're not showing lower denominations
	silverButton:ClearAllPoints();
	local hideCopper = true;
	if ( (copper > 0 or showLowerDenominations or info.showSmallerCoins == "Backpack" or forceShow) and not truncateCopper) then
		hideCopper = false;
		-- Exception if showLowerDenominations and fixedWidth
		if ( showLowerDenominations and info.fixedWidth ) then
			copperButton:SetWidth(COIN_BUTTON_WIDTH);
		end

		local copperWidth = copperButton:GetWidth();
		silverButton:SetPoint("RIGHT", copperButton, "LEFT", spacing, 0);
		if ( silverButton:IsShown() or goldButton:IsShown() ) then
			copperWidth = copperWidth - spacing;
		end
		-- hide copper if not enough room
		if ( maxDisplayWidth and (width + copperWidth) > maxDisplayWidth ) then
			hideCopper = true;
			frame.showTooltip = true;
		else
			width = width + copperWidth;
		end
	end
	if ( hideCopper ) then
		copperButton:Hide();
		silverButton:SetPoint("RIGHT", copperButton, "RIGHT", 0, 0);
	end

	-- make sure the copper button is in the right place
	copperButton:ClearAllPoints();
	copperButton:SetPoint("RIGHT", frame, "RIGHT", -13, 0);

	-- attach text now that denominations have been computed
	local prefixText = frame.PrefixText;
	if ( prefixText ) then
		if ( prefixText:GetText() and money > 0 ) then
			prefixText:Show();
			copperButton:ClearAllPoints();
			copperButton:SetPoint("RIGHT", prefixText, "RIGHT", width, 0);
			width = width + prefixText:GetWidth();
		else
			prefixText:Hide();
		end
	end
	local suffixText = frame.SuffixText;
	if ( suffixText ) then
		if ( suffixText:GetText() and money > 0 ) then
			suffixText:Show();
			suffixText:ClearAllPoints();
			suffixText:SetPoint("LEFT", copperButton, "RIGHT", 0, 0);
			width = width + suffixText:GetWidth();
		else
			suffixText:Hide();
		end
	end

	frame:SetWidth(width);

	-- check if we need to toggle mouse events for the currency buttons to present tooltip
	-- the events are always enabled if info.canPickup is true
	if ( maxDisplayWidth and not info.canPickup ) then
		local mouseEnabled = goldButton:IsMouseEnabled();
		if ( frame.showTooltip and not mouseEnabled ) then
			goldButton:EnableMouse(true);
			silverButton:EnableMouse(true);
			copperButton:EnableMouse(true);
		elseif ( not frame.showTooltip and mouseEnabled ) then
			goldButton:EnableMouse(false);
			silverButton:EnableMouse(false);
			copperButton:EnableMouse(false);
		end
	end
end

function AltCurrencyFrame_Update(frameName, texture, cost, canAfford)
	local iconWidth;
	local button = _G[frameName];
	local buttonTexture = _G[frameName.."Texture"];
	button:SetText(cost);
	buttonTexture:SetTexture(texture);
	local fontColor = HIGHLIGHT_FONT_COLOR;
	if (canAfford == false) then
		fontColor = DISABLED_FONT_COLOR;
	end
	button.Text:SetTextColor(fontColor.r, fontColor.g, fontColor.b);
	if ( button.pointType == HONOR_POINTS ) then
		iconWidth = 24;
		buttonTexture:SetPoint("LEFT", _G[frameName.."Text"], "RIGHT", -1, -6);
	else
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		buttonTexture:SetPoint("LEFT", _G[frameName.."Text"], "RIGHT", 0, 0);
	end
	buttonTexture:SetWidth(iconWidth);
	buttonTexture:SetHeight(iconWidth);
	button:SetWidth(button:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
end

function SmallDenominationTemplate_OnEnter(self)
	if not C_Glue.IsOnGlueScreen() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetMerchantCostItem(self.index, self.item);
	end
end

function SmallDenominationTemplate_OnLeave(self)
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
	ResetCursor();
end