local _, addonTable = ...

local MoneyTypeInfo = addonTable.MoneyTypeInfo;

local COPPER_PER_SILVER = 100;
local SILVER_PER_GOLD = 100;
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

MONEY_INPUT_MAX_GOLD_DIGITS = 6;

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
		message("Invalid money type: "..(type or "INVALID TYPE"));
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
			local texture = CreateMoneyButtonNormalTexture(goldButton, iconWidth);
			texture:SetTexCoord(0, 0.25, 0, 1);
			texture = CreateMoneyButtonNormalTexture(silverButton, iconWidth);
			texture:SetTexCoord(0.25, 0.5, 0, 1);
			texture = CreateMoneyButtonNormalTexture(copperButton, iconWidth);
			texture:SetTexCoord(0.5, 0.75, 0, 1);

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

	-- If not collapsable and not aligning multiple rows and not using maxDisplayWidth, don't need to continue
	if ( not info.collapse and not info.align and not maxDisplayWidth ) then
		return;
	end

	-- If aligning multiple rows, make sure each component width is consistent in each row
	if ( frame.alignGoldWidth and frame.alignGoldWidth > goldButton:GetWidth() ) then
		goldButton:SetWidth(frame.alignGoldWidth);
	end
	if ( frame.alignSilverWidth and frame.alignSilverWidth > silverButton:GetWidth() ) then
		silverButton:SetWidth(frame.alignSilverWidth);
	end
	if ( frame.alignCopperWidth and frame.alignCopperWidth > copperButton:GetWidth() ) then
		copperButton:SetWidth(frame.alignCopperWidth);
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

	-- keep track of money width so it can be used to align multiple rows
	frame.moneyWidth = width;

	-- attach text now that denominations have been computed
	local prefixText = _G[frameName.."PrefixText"];
	if ( prefixText ) then
		if ( prefixText:GetText() and money > 0 ) then
			prefixText:Show();

			-- if aligning multiple rows, make sure the prefix and total money width is consistent in each row
			local alignWidthPad = 0;
			if ( frame.alignMoneyWidth and frame.alignMoneyWidth > width ) then
				alignWidthPad = alignWidthPad + frame.alignMoneyWidth - width;
			end
			if ( frame.alignPrefixWidth and frame.alignPrefixWidth > prefixText:GetWidth() ) then
				alignWidthPad = alignWidthPad + frame.alignPrefixWidth - prefixText:GetWidth();
			end
			copperButton:ClearAllPoints();
			copperButton:SetPoint("RIGHT", frameName.."PrefixText", "RIGHT", alignWidthPad + width, 0);
			width = width + prefixText:GetWidth() + alignWidthPad;
		else
			prefixText:Hide();
		end
	end
	local suffixText = _G[frameName.."SuffixText"];
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

function MoneyFrame_AccumulateAlignmentWidths(frameName, widths)
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
		return;
	end

	if ( not info.align ) then
		return;
	end

	local prefixFrame = _G[frameName.."PrefixText"];
	local goldButton = frame.GoldButton;
	local silverButton = frame.SilverButton;
	local copperButton = frame.CopperButton;

	if (prefixFrame) then
		widths.prefix = math.max(widths.prefix or 0, prefixFrame:GetWidth());
	end
	if (goldButton) then
		widths.gold = math.max(widths.gold or 0, goldButton:GetWidth());
	end
	if (silverButton) then
		widths.silver = math.max(widths.silver or 0, silverButton:GetWidth());
	end
	if (copperButton) then
		widths.copper = math.max(widths.copper or 0, copperButton:GetWidth());
	end
	widths.money = math.max(widths.money or 0, frame.moneyWidth);
end

function MoneyFrame_UpdateAlignment(frameName, widths)
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
		return;
	end

	if ( not info.align ) then
		return;
	end

	frame.alignPrefixWidth = widths.prefix;
	frame.alignGoldWidth = widths.gold;
	frame.alignSilverWidth = widths.silver;
	frame.alignCopperWidth = widths.copper;
	frame.alignMoneyWidth = widths.money;

	local prefixFrame = _G[frameName.."PrefixText"];
	local goldButton = frame.GoldButton;
	local silverButton = frame.SilverButton;
	local copperButton = frame.CopperButton;

	local update = false;

	if ( frame.alignPrefixWidth and frame.alignPrefixWidth > prefixFrame:GetWidth() ) then
		update = true;
	end
	if ( frame.alignGoldWidth and frame.alignGoldWidth > goldButton:GetWidth() ) then
		update = true;
	end
	if ( frame.alignSilverWidth and frame.alignSilverWidth > silverButton:GetWidth() ) then
		update = true;
	end
	if ( frame.alignCopperWidth and frame.alignCopperWidth > copperButton:GetWidth() ) then
		update = true;
	end
	if ( frame.alignMoneyWidth and frame.alignMoneyWidth > frame.moneyWidth ) then
		update = true;
	end

	if ( update ) then
		MoneyFrame_Update(frameName, frame.staticMoney);
	end
end

function MoneyFrame_ResetAlignment(frameName)
	local frame;
	if ( type(frameName) == "table" ) then
		frame = frameName;
		frameName = frame:GetName();
	else
		frame = _G[frameName];
	end

	frame.alignPrefixWidth = nil;
	frame.alignGoldWidth = nil;
	frame.alignSilverWidth = nil;
	frame.alignCopperWidth = nil;
	frame.alignMoneyWidth = nil;
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