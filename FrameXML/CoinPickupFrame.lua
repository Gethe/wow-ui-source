COINFRAME_BINDING_CACHE = {}

function OpenCoinPickupFrame(multiplier, maxMoney, parent)
	if ( CoinPickupFrame.owner ) then
		CoinPickupFrame.owner.hasPickup = 0;
	end

	if ( GetCursorMoney() > 0 ) then
		if ( CoinPickupFrame.owner ) then
			MoneyTypeInfo[parent.moneyType].DropFunc(CoinPickupFrame);
			PlaySound("igBackPackCoinSelect");
		end
		CoinPickupFrame:Hide();
		return;
	end

	CoinPickupFrame.multiplier = multiplier;
	CoinPickupFrame.maxMoney = floor(maxMoney / multiplier);
	if ( CoinPickupFrame.maxMoney == 0 ) then
		CoinPickupFrame:Hide();
		return;
	end

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		if ( not CoinPickupFrame.colorBlind ) then
			CoinPickupCopperIcon:Hide();
			CoinPickupSilverIcon:Hide();
			CoinPickupGoldIcon:Hide();
			CoinPickupText:SetPoint("RIGHT", -38, 18);
			CoinPickupFrame.colorBlind = true;
		end
		
		if ( multiplier == 1 ) then
			CoinPickupFrame.symbol = COPPER_AMOUNT_SYMBOL;
		elseif ( multiplier == COPPER_PER_SILVER ) then
			CoinPickupFrame.symbol = SILVER_AMOUNT_SYMBOL;
		elseif ( multiplier == COPPER_PER_GOLD ) then
			CoinPickupFrame.symbol = GOLD_AMOUNT_SYMBOL;
		end
	else
		CoinPickupFrame.symbol = "";
		if ( CoinPickupFrame.colorBlind ) then
			CoinPickupText:SetPoint("RIGHT", -38, 18);
			CoinPickupFrame.colorBlind = nil;
		end
		
		
		if ( multiplier == 1 ) then
			CoinPickupCopperIcon:Show();
		else
			CoinPickupCopperIcon:Hide();
		end

		if ( multiplier == COPPER_PER_SILVER ) then
			CoinPickupSilverIcon:Show();
		else
			CoinPickupSilverIcon:Hide();
		end

		if ( multiplier == (COPPER_PER_GOLD) ) then
			CoinPickupGoldIcon:Show();
		else
			CoinPickupGoldIcon:Hide();
		end
	end
	
	CoinPickupFrame.owner = parent;
	CoinPickupFrame.money = 1;
	CoinPickupFrame.typing = 0;
	CoinPickupText:SetText(CoinPickupFrame.money .. CoinPickupFrame.symbol);
	CoinPickupLeftButton:Disable();
	CoinPickupRightButton:Enable();

	CoinPickupFrame:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 0);
	CoinPickupFrame:Show();
	PlaySound("igBackPackCoinSelect");
end

function UpdateCoinPickupFrame(maxMoney)
	if ( not CoinPickupFrame.multiplier ) then
		return;
	end
	CoinPickupFrame.maxMoney = floor(maxMoney / CoinPickupFrame.multiplier);
	if ( CoinPickupFrame.maxMoney == 0 ) then
		if ( CoinPickupFrame.owner ) then
			CoinPickupFrame.owner.hasPickup = 0;
		end
		CoinPickupFrame:Hide();
		return;
	end

	if ( not CoinPickupFrame.money or not CoinPickupFrame.maxMoney ) then
		-- Failsafe
		return;
	end

	if ( CoinPickupFrame.money > CoinPickupFrame.maxMoney ) then
		CoinPickupFrame.money = CoinPickupFrame.maxMoney;
		CoinPickupText:SetText(CoinPickupFrame.money .. CoinPickupFrame.symbol);
	end

	if ( CoinPickupFrame.money == CoinPickupFrame.maxMoney ) then
		CoinPickupRightButton:Disable();
	else
		CoinPickupRightButton:Enable();
	end

	if ( CoinPickupFrame.money == 1 ) then
		CoinPickupLeftButton:Disable();
	else
		CoinPickupLeftButton:Enable();
	end
end

function CoinPickupFrame_OnChar(self, text)
	if ( text < "0" or text > "9" ) then
		return;
	end

	if ( self.typing == 0 ) then
		self.typing = 1;
		self.money = 0;
	end

	local money = (self.money * 10) + text;
	if ( money == self.money ) then
		if( self.money == 0 ) then
			self.money = 1;
		end
		return;
	end

	if ( money <= self.maxMoney ) then
		self.money = money;
		CoinPickupText:SetText(money .. CoinPickupFrame.symbol);
		if ( money == self.maxMoney ) then
			CoinPickupRightButton:Disable();
		else
			CoinPickupRightButton:Enable();
		end
		if ( money == 1 ) then
			CoinPickupLeftButton:Disable();
		else
			CoinPickupLeftButton:Enable();
		end
	elseif ( money == 0 ) then
		self.money = 1;
	end
end

function CoinPickupFrame_OnKeyDown(self, key)
	if ( key == "BACKSPACE" or key == "DELETE" ) then
		if ( self.typing == 0 or self.money == 1 ) then
			return;
		end

		self.money = floor(self.money / 10);
		if ( self.money <= 1 ) then
			self.money = 1;
			self.typing = 0;
			CoinPickupLeftButton:Disable();
		else
			CoinPickupLeftButton:Enable();
		end
		CoinPickupText:SetText(self.money .. self.symbol);
		if ( self.money == self.maxMoney ) then
			CoinPickupRightButton:Disable();
		else
			CoinPickupRightButton:Enable();
		end
	elseif ( key == "ENTER" ) then
		CoinPickupFrameOkay_Click();
	elseif ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		CoinPickupFrameCancel_Click();
	elseif ( key == "LEFT" or key == "DOWN" ) then
		CoinPickupFrameLeft_Click();
	elseif ( key == "RIGHT" or key == "UP" ) then
		CoinPickupFrameRight_Click();
	elseif ( not ( tonumber(key) ) and GetBindingAction(key) ) then
		--Running bindings not used by the CoinPickup frame allows players to retain control of their characters.
		RunBinding(GetBindingAction(key));
	end
	
	COINFRAME_BINDING_CACHE[key] = true;
end

function CoinPickupFrame_OnKeyUp(self, key)
	if ( not ( tonumber(key) ) and GetBindingAction(key) ) then
		--If we don't run the up bindings as well, interesting things happen (like you never stop moving)
		RunBinding(GetBindingAction(key), "up");
	end
	
	COINFRAME_BINDING_CACHE[key] = nil;
end

function CoinPickupFrameLeft_Click()
	if ( CoinPickupFrame.money == 1 ) then
		return;
	end

	CoinPickupFrame.money = CoinPickupFrame.money - 1;
	CoinPickupText:SetText(CoinPickupFrame.money .. CoinPickupFrame.symbol);
	if ( CoinPickupFrame.money == 1 ) then
		CoinPickupLeftButton:Disable();
	end
	CoinPickupRightButton:Enable();
end

function CoinPickupFrameRight_Click()
	if ( CoinPickupFrame.money == CoinPickupFrame.maxMoney ) then
		return;
	end

	CoinPickupFrame.money = CoinPickupFrame.money + 1;
	CoinPickupText:SetText(CoinPickupFrame.money .. CoinPickupFrame.symbol);
	if ( CoinPickupFrame.money == CoinPickupFrame.maxMoney ) then
		CoinPickupRightButton:Disable();
	end
	CoinPickupLeftButton:Enable();
end

function CoinPickupFrameOkay_Click()
	if ( (CoinPickupFrame.money > 0) and CoinPickupFrame.owner ) then
		MoneyTypeInfo[CoinPickupFrame.owner.moneyType].PickupFunc(CoinPickupFrame, CoinPickupFrame.money * CoinPickupFrame.multiplier);
	end
	CoinPickupFrame:Hide();
	PlaySound("igBackPackCoinOK");
end

function CoinPickupFrameCancel_Click()
	CoinPickupFrame:Hide();
	PlaySound("igBackPackCoinCancel");
end

function CoinPickupFrame_OnHide()
	if ( CoinPickupFrame.owner ) then
		CoinPickupFrame.owner.hasPickup = 0;
	end
	
	for key in next, COINFRAME_BINDING_CACHE do
		if ( GetBindingAction(key) ) then
			RunBinding(GetBindingAction(key), "up");
		end
		COINFRAME_BINDING_CACHE[key] = nil;
	end
	
	PlaySound("MONEYFRAMECLOSE");
end
