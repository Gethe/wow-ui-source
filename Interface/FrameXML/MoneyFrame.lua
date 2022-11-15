
MONEY_ICON_WIDTH = 19;
MONEY_ICON_WIDTH_SMALL = 13;

MONEY_BUTTON_SPACING = -4;
MONEY_BUTTON_SPACING_SMALL = -4;

MONEY_TEXT_VADJUST = 0;

COIN_BUTTON_WIDTH = 32;

MoneyTypeInfo = { };
MoneyTypeInfo["PLAYER"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("TRIAL_STATUS_UPDATE");
	end,
	
	UpdateFunc = function(self)
		return MoneyFrame_UpdateTrialErrorButton(self);
	end,

	PickupFunc = function(self, amount)
		PickupPlayerMoney(amount);
	end,

	DropFunc = function(self)
		DropCursorMoney();
	end,

	collapse = 1,
	canPickup = 1,
	showSmallerCoins = "Backpack"
};
MoneyTypeInfo["STATIC"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
};
MoneyTypeInfo["AUCTION"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = "Backpack",
	fixedWidth = 1,
	collapse = 1,
	truncateSmallCoins = nil,
};
MoneyTypeInfo["PLAYER_TRADE"] = {
	UpdateFunc = function(self)
		return GetPlayerTradeMoney();
	end,

	PickupFunc = function(self, amount)
		PickupTradeMoney(amount);
	end,

	DropFunc = function(self)
		AddTradeMoney();
	end,

	collapse = 1,
	canPickup = 1,
};
MoneyTypeInfo["TARGET_TRADE"] = {
	UpdateFunc = function(self)
		return GetTargetTradeMoney();
	end,

	collapse = 1,
};
MoneyTypeInfo["SEND_MAIL"] = {
	UpdateFunc = function(self)
		return GetSendMailMoney();
	end,

	PickupFunc = function(self, amount)
		PickupSendMailMoney(amount);
	end,

	DropFunc = function(self)
		AddSendMailMoney();
	end,

	collapse = nil,
	canPickup = 1,
	showSmallerCoins = "Backpack",
};
MoneyTypeInfo["SEND_MAIL_COD"] = {
	UpdateFunc = function(self)
		return GetSendMailCOD();
	end,

	PickupFunc = function(self, amount)
		PickupSendMailCOD(amount);
	end,

	DropFunc = function(self)
		AddSendMailCOD();
	end,

	collapse = 1,
	canPickup = 1,
};
MoneyTypeInfo["GUILDBANK"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
	end,

	UpdateFunc = function(self)
		return (GetGuildBankMoney() - GetCursorMoney());
	end,

	PickupFunc = function(self, amount)
		PickupGuildBankMoney(amount);
	end,

	DropFunc = function(self)
		DropCursorMoney();
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["GUILDBANKWITHDRAW"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("GUILDBANK_UPDATE_WITHDRAWMONEY");
	end,

	UpdateFunc = function(self)
		self:GetParent():UpdateWithdrawMoney();
		return nil;
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["GUILD_REPAIR"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["TOOLTIP"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = "Backpack",
	collapse = 1,
	truncateSmallCoins = nil,
};

MoneyTypeInfo["BLACKMARKET"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = nil,
	fixedWidth = 1,
	collapse = 1,
};

function MoneyFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("PLAYER_TRADE_MONEY");
	self:RegisterEvent("TRADE_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_COD_CHANGED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	MoneyFrame_SetType(self, "PLAYER");
end

function SmallMoneyFrame_OnLoad(self, moneyType)
	--If there's a moneyType we'll use the new way of doing things, otherwise do things the old way
	if ( moneyType ) then
		local info = MoneyTypeInfo[moneyType];
		if ( info and info.OnloadFunc ) then
			--This way you can just register for the events that you care about
			--Should write OnloadFunc's for all money frames, but don't have time right now
			info.OnloadFunc(self);
			self.small = 1;
			MoneyFrame_SetType(self, moneyType);
		end
	else
		--The old sucky way of doing things
		self:RegisterEvent("PLAYER_MONEY");
		self:RegisterEvent("PLAYER_TRADE_MONEY");
		self:RegisterEvent("TRADE_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_COD_CHANGED");
		self:RegisterEvent("TRIAL_STATUS_UPDATE");
		self.small = 1;
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
		GameTooltip:SetOwner(copperButton, "ANCHOR_TOPRIGHT", 20, 2);		
		SetTooltipMoney(GameTooltip, moneyFrame.staticMoney, "TOOLTIP", "");
		GameTooltip:Show();
	end
end

function MoneyFrame_OnLeave(moneyFrame)
	if ( moneyFrame.showTooltip ) then
		GameTooltip:Hide();
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

function MoneyFrame_Update(frameName, money, forceShow)
	local frame;
	if ( type(frameName) == "table" ) then
		frame = frameName;
		frameName = frame:GetName();
	else
		frame = _G[frameName];
	end
	
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

function MoneyFrame_UpdateTrialErrorButton(self)
	local money = (GetMoney() - GetCursorMoney() - GetPlayerTradeMoney());
	if self.trialErrorButton then
		local _, rMoney = GetRestrictedAccountData();
		local moneyIsRestricted = GameLimitedMode_IsActive() and money >= rMoney;
		self.trialErrorButton:SetShown(moneyIsRestricted);
	end
	
	return money;
end

function SetMoneyFrameColorByFrame(moneyFrame, color)
	local fontObject;
	if ( moneyFrame.small ) then
		if ( color == "yellow" ) then
			fontObject = NumberFontNormalRightYellow;
		elseif ( color == "red" ) then
			fontObject = NumberFontNormalRightRed;
		elseif ( color == "gray" ) then
			fontObject = NumberFontNormalRightGray;
		else
			fontObject = NumberFontNormalRight;
		end
	else
		if ( color == "yellow"  ) then
			fontObject = NumberFontNormalLargeRightYellow;
		elseif ( color == "red" ) then
			fontObject = NumberFontNormalLargeRightRed;
		elseif ( color == "gray" ) then
			fontObject = NumberFontNormalLargeRightGray;
		else
			fontObject = NumberFontNormalLargeRight;
		end
	end

	local goldButton = moneyFrame.GoldButton;
	local silverButton = moneyFrame.SilverButton;
	local copperButton = moneyFrame.CopperButton;

	goldButton:SetNormalFontObject(fontObject);
	silverButton:SetNormalFontObject(fontObject);
	copperButton:SetNormalFontObject(fontObject);
end

function SetMoneyFrameColor(frameName, color)
	local moneyFrame = _G[frameName];
	if ( not moneyFrame ) then
		return;
	end
	
	SetMoneyFrameColorByFrame(moneyFrame, color);
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

function GetDenominationsFromCopper(money)
	return GetCoinText(money, " ");
end


local TextureType = {
	File = 1,
	Atlas = 2,
};

MoneyDenominationDisplayType = {
	Copper = { TextureType.Atlas, "coin-copper" },
	Silver = { TextureType.Atlas, "coin-silver" },
	Gold = { TextureType.Atlas, "coin-gold" },
	AuctionHouseCopper = { TextureType.Atlas, "coin-copper" },
	AuctionHouseSilver = { TextureType.Atlas, "coin-silver" },
	AuctionHouseGold = { TextureType.Atlas, "coin-gold" },
};

MONEY_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE = {
	[MoneyDenominationDisplayType.Copper] = COPPER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.Silver] = SILVER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.Gold] = GOLD_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseCopper] = COPPER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseSilver] = SILVER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseGold] = GOLD_AMOUNT_SYMBOL,
};

MoneyDenominationDisplayMixin = {};

function MoneyDenominationDisplayMixin:OnLoad()
	self.amount = 0;
	
	if self.displayType == nil then
		error("A money denomination display needs a type. Add a KeyValue entry, displayType = MoneyDenominationDisplayType.[Copper|Silver|Gold|AuctionHouseCopper|AuctionHouseSilver|AuctionHouseGold].");
		return;
	end

	self:UpdateDisplayType();
end

function MoneyDenominationDisplayMixin:SetDisplayType(displayType)
	self.displayType = displayType;
	self:UpdateDisplayType();
end

function MoneyDenominationDisplayMixin:UpdateDisplayType()
	local textureType, fileOrAtlas, l, r, b, t = unpack(self.displayType);

	if textureType == TextureType.Atlas then
		self.Icon:SetAtlas(fileOrAtlas);
		self.Icon:SetSize(12,14);
	else
		self.Icon:SetTexture(fileOrAtlas);
		self.Icon:SetSize(13,13);
	end

	self.Icon:SetTexCoord(l or 0, r or 1, b or 0, t or 1);
	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:SetFontObject(fontObject)
	self.Text:SetFontObject(fontObject);
	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:GetFontObject()
	return self.Text:GetFontObject();
end

function MoneyDenominationDisplayMixin:SetFontAndIconDisabled(disabled)
	self:SetFontObject(disabled and PriceFontGray or PriceFontWhite);
	self.Icon:SetAlpha(disabled and 0.5 or 1);
end

function MoneyDenominationDisplayMixin:SetFormatter(formatter)
	self.formatter = formatter;
end

function MoneyDenominationDisplayMixin:SetForcedHidden(forcedHidden)
	self.forcedHidden = forcedHidden;
	self:SetShown(self:ShouldBeShown());
end

function MoneyDenominationDisplayMixin:IsForcedHidden()
	return self.forcedHidden;
end

function MoneyDenominationDisplayMixin:SetShowsZeroAmount(showsZeroAmount)
	self.showsZeroAmount = showsZeroAmount;
	self:SetShown(self:ShouldBeShown());
end

function MoneyDenominationDisplayMixin:ShowsZeroAmount()
	return self.showsZeroAmount;
end

function MoneyDenominationDisplayMixin:ShouldBeShown()
	return not self:IsForcedHidden() and self.amount ~= nil and (self.amount > 0 or self:ShowsZeroAmount());
end

function MoneyDenominationDisplayMixin:SetAmount(amount)
	self.amount = amount;

	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
	if not shouldBeShown then
		return;
	end

	local amountText = amount;
	if self.formatter then
		amountText = self.formatter(amount);
	end

	local colorblindMode = CVarCallbackRegistry:GetCVarValueBool("colorblindMode");
	if colorblindMode then
		amountText = amountText..MONEY_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE[self.displayType];
	end

	self.Text:SetText(amountText);
	self.Icon:SetShown(not colorblindMode);

	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:UpdateWidth()
	local iconWidth = self.Icon:IsShown() and self.Icon:GetWidth() or 0;
	local iconSpacing = 2;
	self.Text:SetPoint("RIGHT", -(iconWidth + iconSpacing), 0);
	self:SetWidth(self.Text:GetStringWidth() + iconWidth + iconSpacing);
end


MoneyDisplayFrameMixin = {};

local DENOMINATION_DISPLAY_WIDTH = 36; -- Space for two characters and an anchor offset.

function MoneyDisplayFrameMixin:OnLoad()
	self.CopperDisplay:SetShowsZeroAmount(true);
	self.SilverDisplay:SetShowsZeroAmount(true);
	self.GoldDisplay:SetShowsZeroAmount(self.alwaysShowGold);
	self.GoldDisplay:SetFormatter(BreakUpLargeNumbers);

	if self.hideCopper then
		self.CopperDisplay:SetForcedHidden(true);
	end

	if self.useAuctionHouseIcons then
		self.CopperDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseCopper);
		self.SilverDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseSilver);
		self.GoldDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseGold);
	end

	self:UpdateAnchoring();
end

function MoneyDisplayFrameMixin:SetFontAndIconDisabled(disabled)
	self.CopperDisplay:SetFontAndIconDisabled(disabled);
	self.SilverDisplay:SetFontAndIconDisabled(disabled);
	self.GoldDisplay:SetFontAndIconDisabled(disabled);

	if self.resizeToFit then
		self:UpdateWidth();
	end
end

function MoneyDisplayFrameMixin:SetFontObject(fontObject)
	self.CopperDisplay:SetFontObject(fontObject);
	self.SilverDisplay:SetFontObject(fontObject);
	self.GoldDisplay:SetFontObject(fontObject);

	if self.resizeToFit then
		self:UpdateWidth();
	end
end

function MoneyDisplayFrameMixin:GetFontObject()
	return self.CopperDisplay:GetFontObject();
end

function MoneyDisplayFrameMixin:UpdateAnchoring()
	self.CopperDisplay:ClearAllPoints();
	self.SilverDisplay:ClearAllPoints();
	self.GoldDisplay:ClearAllPoints();

	if self.leftAlign then
		self.GoldDisplay:SetPoint("LEFT");

		if self.GoldDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", self.GoldDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("LEFT", self.GoldDisplay, "LEFT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.CopperDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.CopperDisplay:SetPoint("LEFT", self.SilverDisplay, "LEFT");
		end
	else
		self.CopperDisplay:SetPoint("RIGHT");

		if self.CopperDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("RIGHT", self.CopperDisplay, "RIGHT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT");
		end
	end
end

function MoneyDisplayFrameMixin:SetAmount(rawCopper)
	self.rawCopper = rawCopper;
	
	local gold = floor(rawCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((rawCopper - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(rawCopper, COPPER_PER_SILVER);
	self.GoldDisplay:SetAmount(gold);
	self.SilverDisplay:SetAmount(silver);
	self.CopperDisplay:SetAmount(copper);

	if self.resizeToFit then
		self:UpdateWidth();
	else
		self:UpdateAnchoring();
	end
end

function MoneyDisplayFrameMixin:UpdateWidth()
	local width = 0;
	local goldDisplayed = self.GoldDisplay:IsShown()
	if goldDisplayed then
		width = width + self.GoldDisplay:GetWidth();
	end

	local silverDisplayed = self.SilverDisplay:IsShown();
	if silverDisplayed then
		if goldDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.SilverDisplay:GetWidth();
		end
	end

	if self.CopperDisplay:IsShown() then
		if goldDisplayed or silverDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.CopperDisplay:GetWidth();
		end
	end

	self:SetWidth(width);
end

function MoneyDisplayFrameMixin:GetAmount()
	return self.rawCopper;
end

function MoneyDisplayFrameMixin:SetResizeToFit(resizeToFit)
	self.resizeToFit = resizeToFit;
end
