local popupOwner;

function MoneyInputFrame_SetEnabled(moneyFrame, enabled)
	moneyFrame.gold:SetEnabled(enabled);
	moneyFrame.silver:SetEnabled(enabled);
	moneyFrame.copper:SetEnabled(enabled);
end

function MoneyInputFrame_ResetMoney(moneyFrame)
	moneyFrame.gold:SetText("");
	moneyFrame.silver:SetText("");
	moneyFrame.copper:SetText("");
end

function MoneyInputFrame_ClearFocus(moneyFrame)
	moneyFrame.gold:ClearFocus();
	moneyFrame.silver:ClearFocus();
	moneyFrame.copper:ClearFocus();
end

function MoneyInputFrame_SetGoldOnly(moneyFrame, set)
	if ( set ) then
		moneyFrame.goldOnly = true;
	else
		moneyFrame.goldOnly = nil;
	end
end

function MoneyInputFrame_GetCopper(moneyFrame)
	local totalCopper = 0;
	local copper = moneyFrame.copper:GetText();
	local silver = moneyFrame.silver:GetText();
	local gold = moneyFrame.gold:GetText();

	if ( copper ~= "" ) then
		totalCopper = totalCopper + copper;
	end
	if ( silver ~= "" ) then
		totalCopper = totalCopper + (silver * COPPER_PER_SILVER);
	end
	if ( gold ~= "" ) then
		totalCopper = totalCopper + (gold * COPPER_PER_GOLD);
	end
	return totalCopper;
end

function MoneyInputFrame_SetTextColor(moneyFrame, r, g, b)
	moneyFrame.copper:SetTextColor(r, g, b);
	moneyFrame.silver:SetTextColor(r, g, b);
	moneyFrame.gold:SetTextColor(r, g, b);
end

function MoneyInputFrame_SetCopper(moneyFrame, money)
	local gold = floor(money / (COPPER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	local editbox = nil;

	moneyFrame.expectChanges = 0;
	if ( moneyFrame.goldOnly) then
		moneyFrame.copper:Hide();
		moneyFrame.silver:Hide();
	else
		editbox = moneyFrame.copper;
		if ( editbox:GetNumber() ~= copper ) then
			editbox:SetNumber(copper);
			moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
		end
		editbox = moneyFrame.silver;
		if ( editbox:GetNumber() ~= silver ) then
			editbox:SetNumber(silver);
			moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
		end
	end
	editbox = moneyFrame.gold;
	if ( editbox:GetNumber() ~= gold ) then
		editbox:SetNumber(gold);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
end

function MoneyInputFrame_OnTextChanged(self)
	local moneyFrame = self:GetParent();
	if ( moneyFrame.expectChanges ) then
		if ( moneyFrame.expectChanges > 1 ) then
			moneyFrame.expectChanges = moneyFrame.expectChanges - 1;
			return;
		end
		moneyFrame.expectChanges = nil;
	end
	if ( self.expandOnDigits ) then
		if ( strlen(self:GetText()) >= self.expandOnDigits ) then
			moneyFrame.fixedSilver:Show();
			moneyFrame.fixedSilver.amount:SetText(moneyFrame.silver:GetNumber());
			moneyFrame.silver:Hide();
			moneyFrame.fixedCopper:Show();
			moneyFrame.fixedCopper.amount:SetText(moneyFrame.copper:GetNumber());
			moneyFrame.copper:Hide();
			moneyFrame.gold:SetDesiredWidth(self.baseWidth);
		else
			moneyFrame.gold:SetDesiredWidth(self.minWidth);
			moneyFrame.silver:Show();
			moneyFrame.fixedSilver:Hide();
			moneyFrame.copper:Show();
			moneyFrame.fixedCopper:Hide();
		end
	end
	if ( self.darkenOnDigits ) then
		if ( strlen(self:GetText()) >= self.darkenOnDigits ) then
			self.texture:SetAlpha(0.2);
			self.label:SetAlpha(0.2);
		else
			self.texture:SetAlpha(1);
			self.label:SetAlpha(1);
		end
	end
	if ( moneyFrame.onValueChangedFunc ) then
		moneyFrame.onValueChangedFunc();
	end
	if ( moneyFrame.goldOnly ) then
		moneyFrame.silver:Hide();
		moneyFrame.copper:Hide();
		if ( self.expandOnDigits ) then
			moneyFrame.fixedSilver:Hide();
			moneyFrame.fixedCopper:Hide();
		end
	end
end

function MoneyInputFrame_SetCompact(frame, width, expandOnDigits, smallDenominationWidth)
	if smallDenominationWidth then
		frame.silver:SetWidth(smallDenominationWidth);
		frame.silver.baseWidth = smallDenominationWidth;

		frame.copper:SetWidth(smallDenominationWidth);
		frame.copper.baseWidth = smallDenominationWidth;
	end

	local goldFrame = frame.gold;
	goldFrame.minWidth = width;
	goldFrame.expandOnDigits = expandOnDigits;
	goldFrame:SetDesiredWidth(width);
	if ( frame.goldOnly ) then
		return;
	end

	local frameName = frame:GetName();
	local coinFrame;
	-- silver
	coinFrame = CreateFrame("Frame", frameName.."FixedSilver", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", goldFrame, "RIGHT", 2, 0);
	coinFrame.texture:SetAtlas("coin-silver");
	coinFrame.label:SetText(SILVER_AMOUNT_SYMBOL);
	frame.fixedSilver = coinFrame;
	-- copper
	coinFrame = CreateFrame("Frame", frameName.."FixedCopper", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", frame.fixedSilver, "RIGHT", 2, 0);
	coinFrame.texture:SetAtlas("coin-copper");
	coinFrame.label:SetText(COPPER_AMOUNT_SYMBOL);
	frame.fixedCopper = coinFrame;
end

-- Used to set the frames before the moneyframe when tabbing through
function MoneyInputFrame_SetPreviousFocus(moneyFrame, focus)
	moneyFrame.previousFocus = focus;
end

function MoneyInputFrame_SetNextFocus(moneyFrame, focus)
	moneyFrame.nextFocus = focus;
end

function MoneyInputFrame_SetOnValueChangedFunc(moneyFrame, func)
	moneyFrame.onValueChangedFunc = func;
end

function MoneyInputFrame_OnShow(moneyFrame)
	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
		moneyFrame.copper.texture:Hide();
		moneyFrame.gold.texture:Hide();
		moneyFrame.silver.texture:Hide();
		moneyFrame.copper.label:Show();
		moneyFrame.gold.label:Show();
		moneyFrame.silver.label:Show();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Hide();
			moneyFrame.fixedCopper.texture:Hide();
			moneyFrame.fixedSilver.label:Show();
			moneyFrame.fixedCopper.label:Show();
		end
	else
		moneyFrame.copper.texture:Show();
		moneyFrame.gold.texture:Show();
		moneyFrame.silver.texture:Show();
		moneyFrame.copper.label:Hide();
		moneyFrame.gold.label:Hide();
		moneyFrame.silver.label:Hide();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Show();
			moneyFrame.fixedCopper.texture:Show();
			moneyFrame.fixedSilver.label:Hide();
			moneyFrame.fixedCopper.label:Hide();
		end
	end
	if ( moneyFrame.goldOnly ) then
		moneyFrame.copper.texture:Hide();
		moneyFrame.silver.texture:Hide();
		moneyFrame.copper.label:Hide();
		moneyFrame.silver.label:Hide();
		if ( moneyFrame.gold.expandOnDigits ) then
			moneyFrame.fixedSilver.texture:Hide();
			moneyFrame.fixedCopper.texture:Hide();
			moneyFrame.fixedSilver.label:Hide();
			moneyFrame.fixedCopper.label:Hide();
		end
	end
end

function MoneyInputFrame_OpenPopup(moneyFrame)
	if moneyFrame.showCurrencyTracking then
		if CharacterFrame then
			CharacterFrame:ToggleTokenFrame();
		end
		return;
	end

	if ( popupOwner ) then
		popupOwner.hasPickup = 0;
	end
	if(moneyFrame and moneyFrame.info.canPickup) then
		popupOwner = moneyFrame;
		moneyFrame.hasPickup = 1;
		StaticPopup_Show("PICKUP_MONEY");
	end
end

function MoneyInputFrame_ClosePopup()
	popupOwner = nil;
	StaticPopup_Hide("PICKUP_MONEY");
end

function MoneyInputFrame_PickupPlayerMoney(moneyFrame)
	local copper = MoneyInputFrame_GetCopper(moneyFrame);
	if ( copper > GetMoney() ) then
		if UIErrorsFrame then
			UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_MONEY, 1.0, 0.1, 0.1, 1.0);
		end
	else
		PickupPlayerMoney(copper);
	end
end

LargeMoneyInputBoxMixin = {};

function LargeMoneyInputBoxMixin:OnLoad()
	self:SetFontObject("PriceFont");

	if self.iconAtlas then
		self.Icon:SetAtlas(self.iconAtlas);
	end
end

function LargeMoneyInputBoxMixin:Clear()
	self:SetText("");
end

function LargeMoneyInputBoxMixin:SetAmount(amount)
	self:SetNumber(amount);
end

function LargeMoneyInputBoxMixin:GetAmount()
	return self:GetNumber() or 0;
end

function LargeMoneyInputBoxMixin:OnTextChanged()
	self:GetParent():OnAmountChanged();
end

function MoneyFrameEditBoxGold_OnTabPressed(self)
	local moneyFrame = self:GetParent();
	if IsShiftKeyDown() and moneyFrame.previousFocus then
		moneyFrame.previousFocus:SetFocus();
	else
		moneyFrame.silver:SetFocus();
	end
end

function MoneyFrameEditBoxGold_OnEnterPressed(self)
	self:GetParent().silver:SetFocus();
end

function MoneyFrameEditBoxSilver_OnTabPressed(self)
	local moneyFrame = self:GetParent();
	if IsShiftKeyDown() or not moneyFrame.copper:IsShown() then
		moneyFrame.gold:SetFocus();
	else
		moneyFrame.copper:SetFocus();
	end
end

function MoneyFrameEditBoxSilver_OnEnterPressed(self)
	local moneyFrame = self:GetParent();
	if not moneyFrame.copper:IsShown() then
		moneyFrame.gold:SetFocus();
	else
		moneyFrame.copper:SetFocus();
	end
end

function MoneyFrameEditBoxCopper_OnTabPressed(self)
	local moneyFrame = self:GetParent();
	if IsShiftKeyDown() then
		moneyFrame.silver:SetFocus();
	else
		if moneyFrame.nextFocus then
			moneyFrame.nextFocus:SetFocus();
		else
			self:ClearFocus();
		end
	end
end

function MoneyFrameEditBoxCopper_OnEnterPressed(self)
	local moneyFrame = self:GetParent();
	if moneyFrame.nextFocus then
		moneyFrame.nextFocus:SetFocus();
	else
		self:ClearFocus();
	end
end

MoneyFrameEditBoxMixin = {};

function MoneyFrameEditBoxMixin:OnLoad()
	self.texture:SetAtlas(self.coinAtlas);
	self.label:SetText(self.coinSymbol);
end

function MoneyFrameEditBoxMixin:SetIsUserScaled()
	if self.isUserScaled then
		return;
	end

	self.isUserScaled = true;
	self.label:SetFontObject(UserScaledFontGameHighlightRight);
	self:SetFontObject(UserScaledChatFontNormal);

	Mixin(self, UserScaledElementMixin);
	Mixin(self.texture, UserScaledElementMixin);

	local scale = TextSizeManager:GetScale();
	self:OnTextScaleUpdated(scale, self);
	self.texture:OnTextScaleUpdated(scale, self.texture);

	TextSizeManager:RegisterObject(self);
	TextSizeManager:RegisterObject(self.texture);
end

function MoneyFrameEditBoxMixin:SetDesiredWidth(width)
	-- NOTE: This acts as a passthrough to SetWidth until the frame becomes user-scaled, at which point the UserScaledElement method overrides.
	self:SetWidth(width);
end

MoneyInputFrameMixin = {};

function MoneyInputFrameMixin:SetIsUserScaled()
	if self.isUserScaled then
		return;
	end

	self.isUserScaled = true;
	self.gold:SetIsUserScaled();
	self.silver:SetIsUserScaled();
	self.copper:SetIsUserScaled();

	Mixin(self, UserScaledElementMixin);

	self:OnTextScaleUpdated(TextSizeManager:GetScale(), self);
	TextSizeManager:RegisterObject(self);
end
