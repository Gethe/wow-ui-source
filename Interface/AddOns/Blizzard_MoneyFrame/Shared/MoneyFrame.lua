local _, addonTable = ...

local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

MONEY_ICON_WIDTH = 19;
MONEY_ICON_WIDTH_SMALL = 13;

MONEY_BUTTON_SPACING = -4;
MONEY_BUTTON_SPACING_SMALL = -4;

MONEY_TEXT_VADJUST = 0;

COIN_BUTTON_WIDTH = 32;

local MoneyTypeInfo = { };
addonTable.MoneyTypeInfo = MoneyTypeInfo;

function GetMoneyTypeInfoField(moneyType, field)
	return MoneyTypeInfo[moneyType][field];
end

function AddMoneyTypeInfo(moneyType, info)
	if MoneyTypeInfo[moneyType] then
		-- Prevent overwriting existing types
		return;
	end

	MoneyTypeInfo[moneyType] = info;
end

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
MoneyTypeInfo["ACCOUNT"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("ACCOUNT_MONEY");
	end,

	UpdateFunc = function(self)
		return C_Bank.FetchDepositedMoney(Enum.BankType.Account);
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};
MoneyTypeInfo["STATIC"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
};
MoneyTypeInfo["QUEST_REWARDS"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
	checkGoldThreshold = 1,
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
MoneyTypeInfo["AUCTION_TOOLTIP"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = "Backpack",
	fixedWidth = 1,
	collapse = 1,
	align = 1,
	truncateSmallCoins = nil,
};
local GetPlayerTradeMoney = GetPlayerTradeMoney;
MoneyTypeInfo["PLAYER_TRADE"] = {
	UpdateFunc = function(self)
		return GetPlayerTradeMoney();
	end,

	PickupFunc = function(self, amount)
		PickupTradeMoney(amount);
	end,

	DropFunc = function(self)
		C_TradeInfo.AddTradeMoney();
	end,

	collapse = 1,
	canPickup = 1,
};
local GetTargetTradeMoney = GetTargetTradeMoney;
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

MoneyTypeInfo["GUILDBANKCASHFLOW"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("GUILDBANKLOG_UPDATE");
	end,
	UpdateFunc = function(self)
		GuildBankFrame_UpdateCashFlowMoney();
		return nil;
	end,
	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["REFORGE"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

function MoneyFrame_UpdateTrialErrorButton(self)
	local money = (GetMoney() - GetCursorMoney() - GetPlayerTradeMoney());
	if self.trialErrorButton then
		local _, rMoney = GetRestrictedAccountData();
		local moneyIsRestricted = GameLimitedMode_IsActive() and money >= rMoney;
		self.trialErrorButton:SetShown(moneyIsRestricted);
	end

	return money;
end

local MONEY_FRAME_FONT_SMALL = true;
local MONEY_FRAME_FONT_LARGE = false;
local MONEY_FRAME_FONT_USER_SCALED = true;
local MONEY_FRAME_FONT_FIXED_SCALE = false;

local moneyFrameFonts =
{
	[MONEY_FRAME_FONT_SMALL] =
	{
		[MONEY_FRAME_FONT_USER_SCALED] =
		{
			["yellow"] = UserScaledFontNumberNormalRightYellow,
			["red"] = UserScaledFontNumberNormalRightRed,
			["gray"] = UserScaledFontNumberNormalRightGray,
			["default"] = UserScaledFontNumberNormalRight,
		},

		[MONEY_FRAME_FONT_FIXED_SCALE] =
		{
			["yellow"] = NumberFontNormalRightYellow,
			["red"] = NumberFontNormalRightRed,
			["gray"] = NumberFontNormalRightGray,
			["default"] = NumberFontNormalRight,
		},
	},

	[MONEY_FRAME_FONT_LARGE] =
	{
		-- Not yet supported.
		[MONEY_FRAME_FONT_USER_SCALED] =
		{
			["yellow"] = NumberFontNormalLargeRightYellow,
			["red"] = NumberFontNormalLargeRightRed,
			["gray"] = NumberFontNormalLargeRightGray,
			["default"] = NumberFontNormalLargeRight,
		},

		[MONEY_FRAME_FONT_FIXED_SCALE] =
		{
			["yellow"] = NumberFontNormalLargeRightYellow,
			["red"] = NumberFontNormalLargeRightRed,
			["gray"] = NumberFontNormalLargeRightGray,
			["default"] = NumberFontNormalLargeRight,
		},
	},
};

local function GetMoneyFrameFont(moneyFrame, color)
	local isSmall = moneyFrame.small ~= nil and moneyFrame.small ~= false and moneyFrame.small ~= 0;
	local isUserScaled = moneyFrame.isUserScaled ~= nil and moneyFrame.isUserScaled ~= false and moneyFrame.isUserScaled ~= 0;
	local fonts = moneyFrameFonts[isSmall][isUserScaled];
	local font = fonts[color];
	return font or fonts.default;
end

function SetMoneyFrameColorByFrame(moneyFrame, color)
	local fontObject = GetMoneyFrameFont(moneyFrame, color);
	moneyFrame.GoldButton:SetNormalFontObject(fontObject);
	moneyFrame.SilverButton:SetNormalFontObject(fontObject);
	moneyFrame.CopperButton:SetNormalFontObject(fontObject);
end

function SetMoneyFrameColor(frameName, color)
	local moneyFrame = _G[frameName];
	if ( not moneyFrame ) then
		return;
	end
	
	SetMoneyFrameColorByFrame(moneyFrame, color);
end

function GetDenominationsFromCopper(money)
	return C_CurrencyInfo.GetCoinText(money, " ");
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

	if ( self.useAuctionHouseCopperValue) then
		self.hideCopper = not C_AuctionHouse.SupportsCopperValues();
	end

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

	if(moneyFrame.PrefixText and moneyFrame.SuffixText) then
		moneyFrame.PrefixText:SetText(prefixText);
		moneyFrame.SuffixText:SetText(suffixText);
	elseif (_G[name.."PrefixText"] and _G[name.."SuffixText"]) then
		_G[name.."PrefixText"]:SetText(prefixText);
		_G[name.."SuffixText"]:SetText(suffixText);
	end
	
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
