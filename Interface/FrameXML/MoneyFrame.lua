
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

MoneyTypeInfo["BLACKMARKET"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = nil,
	fixedWidth = 1,
	collapse = 1,
};

function MoneyFrame_OnLoad(self)
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
	elseif ( event == "GUILDBANKLOG_UPDATE" and moneyType == "GUILDBANKCASHFLOW" ) then
		MoneyFrame_UpdateMoney(self);
	end
end

function MoneyFrame_OnEnter(moneyFrame)
	if ( moneyFrame.showTooltip ) then
		GameTooltip:SetOwner(_G[moneyFrame:GetName().."CopperButton"], "ANCHOR_TOPRIGHT", 20, 2);		
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
		message("Invalid money type: "..(type or "INVALID TYPE"));
		return;
	end
	self.info = info;
	self.moneyType = type;
	local frameName = self:GetName();
	if ( info.canPickup ) then
		_G[frameName.."GoldButton"]:EnableMouse(true);
		_G[frameName.."SilverButton"]:EnableMouse(true);
		_G[frameName.."CopperButton"]:EnableMouse(true);
	else
		_G[frameName.."GoldButton"]:EnableMouse(false);
		_G[frameName.."SilverButton"]:EnableMouse(false);
		_G[frameName.."CopperButton"]:EnableMouse(false);
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
			MoneyFrame_Update(moneyFrame:GetName(), money);
		end
	else
		message("Error moneyType not set");
	end
end

local function CreateMoneyButtonNormalTexture (button, iconWidth)
	local texture = button:CreateTexture();
	texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	texture:SetWidth(iconWidth);
	texture:SetHeight(iconWidth);
	texture:SetPoint("RIGHT", -1, 1);
	button:SetNormalTexture(texture);
	
	return texture;
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
	local goldDisplay = gold;
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	local goldButton = _G[frameName.."GoldButton"];
	local silverButton = _G[frameName.."SilverButton"];
	local copperButton = _G[frameName.."CopperButton"];

	local iconWidth = MONEY_ICON_WIDTH;
	local spacing = MONEY_BUTTON_SPACING;
	if ( frame.small ) then
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		spacing = MONEY_BUTTON_SPACING_SMALL;
	end

	local maxDisplayWidth = frame.maxDisplayWidth;
	
	-- Set values for each denomination
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		if ( not frame.colorblind or not frame.vadjust or frame.vadjust ~= MONEY_TEXT_VADJUST ) then
			frame.colorblind = true;
			frame.vadjust = MONEY_TEXT_VADJUST;
			goldButton:SetNormalTexture("");
			silverButton:SetNormalTexture("");
			copperButton:SetNormalTexture("");
			_G[frameName.."GoldButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			_G[frameName.."SilverButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			_G[frameName.."CopperButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
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
			local texture = CreateMoneyButtonNormalTexture(goldButton, iconWidth);
			texture:SetTexCoord(0, 0.25, 0, 1);
			texture = CreateMoneyButtonNormalTexture(silverButton, iconWidth);
			texture:SetTexCoord(0.25, 0.5, 0, 1);
			texture = CreateMoneyButtonNormalTexture(copperButton, iconWidth);
			texture:SetTexCoord(0.5, 0.75, 0, 1);
			_G[frameName.."GoldButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			_G[frameName.."SilverButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			_G[frameName.."CopperButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
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
		goldButton:SetPoint("RIGHT", frameName.."SilverButton", "LEFT", spacing, 0);
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
		goldButton:SetPoint("RIGHT", frameName.."SilverButton",	"RIGHT", 0, 0);
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
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "LEFT", spacing, 0);
		if ( silverButton:IsShown() or goldButton:IsShown() ) then
			copperWidth = copperWidth - spacing;
		end
		-- hide copper if not enough room
		--if ( maxDisplayWidth and (width + copperWidth) > maxDisplayWidth ) then
		if ( false ) then
			hideCopper = true;
			frame.showTooltip = true;
		else
			width = width + copperWidth;
		end
	end
	if ( hideCopper ) then
		copperButton:Hide();
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "RIGHT", 0, 0);
	end

	-- make sure the copper button is in the right place
	copperButton:ClearAllPoints();
	copperButton:SetPoint("RIGHT", frameName, "RIGHT", -13, 0);

	-- attach text now that denominations have been computed
	local prefixText = _G[frameName.."PrefixText"];
	if ( prefixText ) then
		if ( prefixText:GetText() and money > 0 ) then
			prefixText:Show();
			copperButton:ClearAllPoints();
			copperButton:SetPoint("RIGHT", frameName.."PrefixText", "RIGHT", width, 0);
			width = width + prefixText:GetWidth();
		else
			prefixText:Hide();
		end
	end
	local suffixText = _G[frameName.."SuffixText"];
	if ( suffixText ) then
		if ( suffixText:GetText() and money > 0 ) then
			suffixText:Show();
			suffixText:ClearAllPoints();
			suffixText:SetPoint("LEFT", frameName.."CopperButton", "RIGHT", 0, 0);
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

function SetMoneyFrameColor(frameName, color)
	local moneyFrame = _G[frameName];
	if ( not moneyFrame ) then
		return;
	end
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
	
	local goldButton = _G[frameName.."GoldButton"];
	local silverButton = _G[frameName.."SilverButton"];
	local copperButton = _G[frameName.."CopperButton"];

	goldButton:SetNormalFontObject(fontObject);
	silverButton:SetNormalFontObject(fontObject);
	copperButton:SetNormalFontObject(fontObject);
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

	if ( texture == HONOR_POINT_TEXTURES[1] or texture == HONOR_POINT_TEXTURES[2] ) then
		iconWidth = 24;
		buttonTexture:SetPoint("LEFT", _G[frameName.."Text"], "RIGHT", -3, -5);
	else
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		buttonTexture:SetPoint("LEFT", _G[frameName.."Text"], "RIGHT", -1, 1);
	end
	buttonTexture:SetWidth(iconWidth);
	buttonTexture:SetHeight(iconWidth);
	button:SetWidth(button:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
end

function GetDenominationsFromCopper(money)
	return GetCoinText(money, " ");
end


