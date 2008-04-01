
function OpenCoinPickupFrame(multiplier, maxMoney, parent)
	if ( CoinPickupFrame.owner ) then
		CoinPickupFrame.owner.hasPickup = 0;
	end

	if ( GetCursorMoney() > 0 ) then
		if ( CoinPickupFrame.owner ) then
			MoneyTypeInfo[parent.moneyType].DropFunc();
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

	CoinPickupFrame.owner = parent;
	CoinPickupFrame.money = 1;
	CoinPickupFrame.typing = 0;
	CoinPickupText:SetText(CoinPickupFrame.money);
	CoinPickupLeftButton:Disable();
	CoinPickupRightButton:Enable();

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

	CoinPickupFrame:SetPoint("BOTTOMRIGHT", parent:GetName(), "TOPRIGHT", 0, 0);
	CoinPickupFrame:Show();
	PlaySound("igBackPackCoinSelect");
end

function UpdateCoinPickupFrame(maxMoney)
	CoinPickupFrame.maxMoney = floor(maxMoney / CoinPickupFrame.multiplier);
	if ( CoinPickupFrame.maxMoney == 0 ) then
		if ( CoinPickupFrame.owner ) then
			CoinPickupFrame.owner.hasPickup = 0;
		end
		CoinPickupFrame:Hide();
		return;
	end

	if ( CoinPickupFrame.money > CoinPickupFrame.maxMoney ) then
		CoinPickupFrame.money = CoinPickupFrame.maxMoney;
		CoinPickupText:SetText(CoinPickupFrame.money);
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

function CoinPickupFrame_OnChar()
	if ( arg1 < "0" or arg1 > "9" ) then
		return;
	end

	if ( this.typing == 0 ) then
		this.typing = 1;
		this.money = 0;
	end

	local money = (this.money * 10) + arg1;
	if ( money == this.money ) then
		if( this.money == 0 ) then
			this.money = 1;
		end
		return;
	end

	if ( money <= this.maxMoney ) then
		this.money = money;
		CoinPickupText:SetText(money);
		if ( money == this.maxMoney ) then
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
		this.money = 1;
	end
end

function CoinPickupFrame_OnKeyDown()
	if ( arg1 == "BACKSPACE" or arg1 == "DELETE" ) then
		if ( this.typing == 0 or this.money == 1 ) then
			return;
		end

		this.money = floor(this.money / 10);
		if ( this.money <= 1 ) then
			this.money = 1;
			this.typing = 0;
			CoinPickupLeftButton:Disable();
		else
			CoinPickupLeftButton:Enable();
		end
		CoinPickupText:SetText(this.money);
		if ( this.money == this.maxMoney ) then
			CoinPickupRightButton:Disable();
		else
			CoinPickupRightButton:Enable();
		end
	elseif ( arg1 == "ENTER" ) then
		CoinPickupFrameOkay_Click();
	elseif ( arg1 == "ESCAPE" ) then
		CoinPickupFrameCancel_Click();
	elseif ( arg1 == "LEFT" or arg1 == "DOWN" ) then
		CoinPickupFrameLeft_Click();
	elseif ( arg1 == "RIGHT" or arg1 == "UP" ) then
		CoinPickupFrameRight_Click();
	end
end

function CoinPickupFrameLeft_Click()
	if ( CoinPickupFrame.money == 1 ) then
		return;
	end

	CoinPickupFrame.money = CoinPickupFrame.money - 1;
	CoinPickupText:SetText(CoinPickupFrame.money);
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
	CoinPickupText:SetText(CoinPickupFrame.money);
	if ( CoinPickupFrame.money == CoinPickupFrame.maxMoney ) then
		CoinPickupRightButton:Disable();
	end
	CoinPickupLeftButton:Enable();
end

function CoinPickupFrameOkay_Click()
	if ( (CoinPickupFrame.money > 0) and CoinPickupFrame.owner ) then
		MoneyTypeInfo[CoinPickupFrame.owner.moneyType].PickupFunc(CoinPickupFrame.money * CoinPickupFrame.multiplier);
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
end
