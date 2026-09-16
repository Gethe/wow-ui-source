
function MoneyInputFrame_SetCopperShown(moneyFrame, shown)
	moneyFrame.copper:SetShown(shown);
	moneyFrame:SetWidth(shown and 176 or 126);
end

LargeMoneyInputBoxMixin = {};

function LargeMoneyInputBoxMixin:OnLoad()
	self:SetFontObject("PriceFont");

	if self.iconAtlas then
		self.Icon:SetAtlas(self.iconAtlas);
	end

	local colorblindMode = CVarCallbackRegistry:GetCVarValueBool("colorblindMode");
	if colorblindMode then
		local denomination = MONEY_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE[self.displayType];
		self.Text:SetText(denomination);
	end

	self.Icon:SetShown(not colorblindMode);
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

LargeMoneyInputFrameMixin = {};

function LargeMoneyInputFrameMixin:OnLoad()
	if ( self.useAuctionHouseCopperValue) then
		self.hideCopper = not C_AuctionHouse.SupportsCopperValues();
	end

	if MONEY_INPUT_MAX_GOLD_DIGITS then
		self.GoldBox:SetMaxLetters(MONEY_INPUT_MAX_GOLD_DIGITS);
	end

	if self.hideCopper then
		self.CopperBox:Hide();
		self.SilverBox:ClearAllPoints();
		self.SilverBox:SetPoint("RIGHT", self.CopperBox, "RIGHT");

		self.GoldBox.nextEditBox = self.SilverBox;
		self.SilverBox.previousEditBox = self.GoldBox;
		self.SilverBox.nextEditBox = self.nextEditBox;
	else
		self.GoldBox.nextEditBox = self.SilverBox;
		self.SilverBox.previousEditBox = self.GoldBox;
		self.SilverBox.nextEditBox = self.CopperBox;
		self.CopperBox.previousEditBox = self.GoldBox;
		self.CopperBox.nextEditBox = self.nextEditBox;
	end
end

function LargeMoneyInputFrameMixin:SetNextEditBox(nextEditBox)
	if ( self.useAuctionHouseCopperValue) then
		self.hideCopper = not C_AuctionHouse.SupportsCopperValues();
	end

	if self.hideCopper then
		self.SilverBox.nextEditBox = nextEditBox or self.GoldBox;

		if nextEditBox then
			nextEditBox.previousEditBox = self.SilverBox;
		end
	else
		self.CopperBox.nextEditBox = nextEditBox or self.GoldBox;

		if nextEditBox then
			nextEditBox.previousEditBox = self.CopperBox;
		end
	end
end

function LargeMoneyInputFrameMixin:Clear()
	self.CopperBox:Clear();
	self.SilverBox:Clear();
	self.GoldBox:Clear();
end

function LargeMoneyInputFrameMixin:SetEnabled(enabled)
	self.CopperBox:SetEnabled(enabled);
	self.SilverBox:SetEnabled(enabled);
	self.GoldBox:SetEnabled(enabled);
end

function LargeMoneyInputFrameMixin:SetAmount(amount)
	self.CopperBox:SetAmount(amount % COPPER_PER_SILVER);
	self.SilverBox:SetAmount(math.floor((amount % COPPER_PER_GOLD) / COPPER_PER_SILVER));
	self.GoldBox:SetAmount(math.floor(amount / COPPER_PER_GOLD));
end

function LargeMoneyInputFrameMixin:GetAmount()
	return self.CopperBox:GetAmount() + (self.SilverBox:GetAmount() * COPPER_PER_SILVER) + (self.GoldBox:GetAmount() * COPPER_PER_GOLD);
end

function LargeMoneyInputFrameMixin:SetOnValueChangedCallback(callback)
	self.onValueChangedCallback = callback;
end

function LargeMoneyInputFrameMixin:OnAmountChanged(callback)
	if self.onValueChangedCallback then
		self.onValueChangedCallback();
	end
end