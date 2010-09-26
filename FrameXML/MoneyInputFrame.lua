local popupOwner;

function MoneyInputFrame_ResetMoney(moneyFrame)
	_G[moneyFrame:GetName().."Gold"]:SetText("");
	_G[moneyFrame:GetName().."Silver"]:SetText("");
	_G[moneyFrame:GetName().."Copper"]:SetText("");
end

function MoneyInputFrame_ClearFocus(moneyFrame)
	_G[moneyFrame:GetName().."Gold"]:ClearFocus();
	_G[moneyFrame:GetName().."Silver"]:ClearFocus();
	_G[moneyFrame:GetName().."Copper"]:ClearFocus();
end

function MoneyInputFrame_GetCopper(moneyFrame)
	local totalCopper = 0;
	local copper = _G[moneyFrame:GetName().."Copper"]:GetText();
	local silver = _G[moneyFrame:GetName().."Silver"]:GetText();
	local gold = _G[moneyFrame:GetName().."Gold"]:GetText();
	
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
	_G[moneyFrame:GetName().."Copper"]:SetTextColor(r, g, b);
	_G[moneyFrame:GetName().."Silver"]:SetTextColor(r, g, b);
	_G[moneyFrame:GetName().."Gold"]:SetTextColor(r, g, b);
end

function MoneyInputFrame_SetCopper(moneyFrame, money)
	local gold = floor(money / (COPPER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	local editbox = nil;

	moneyFrame.expectChanges = 0;
	editbox = _G[moneyFrame:GetName().."Copper"];
	if ( editbox:GetNumber() ~= copper ) then
		editbox:SetNumber(copper);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
	editbox = _G[moneyFrame:GetName().."Silver"];
	if ( editbox:GetNumber() ~= silver ) then
		editbox:SetNumber(silver);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
	editbox = _G[moneyFrame:GetName().."Gold"];
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
			moneyFrame.gold:SetWidth(self.normalWidth);
		else
			moneyFrame.gold:SetWidth(self.minWidth);
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
end

function MoneyInputFrame_SetCompact(frame, width, expandOnDigits)
	local goldFrame = frame.gold;
	goldFrame.normalWidth = goldFrame:GetWidth();
	goldFrame.minWidth = width;
	goldFrame.expandOnDigits = expandOnDigits;
	goldFrame:SetWidth(width);
	
	local frameName = frame:GetName();
	local coinFrame;
	-- silver
	coinFrame = CreateFrame("Frame", frameName.."FixedSilver", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", goldFrame, "RIGHT", 2, 0);
	coinFrame.texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	coinFrame.texture:SetTexCoord(0.25, 0.5, 0, 1);
	coinFrame.label:SetText(SILVER_AMOUNT_SYMBOL);
	frame.fixedSilver = coinFrame;
	-- copper
	coinFrame = CreateFrame("Frame", frameName.."FixedCopper", frame, "FixedCoinFrameTemplate");
	coinFrame:SetPoint("LEFT", frame.fixedSilver, "RIGHT", 2, 0);
	coinFrame.texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	coinFrame.texture:SetTexCoord(0.5, 0.75, 0, 1);
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
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
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
end

function MoneyInputFrame_OpenPopup(moneyFrame)
	if ( popupOwner ) then
		popupOwner.hasPickup = 0;
	end
	popupOwner = moneyFrame;
	moneyFrame.hasPickup = 1;
	StaticPopup_Show("PICKUP_MONEY");
end

function MoneyInputFrame_ClosePopup()
	popupOwner = nil;
	StaticPopup_Hide("PICKUP_MONEY");
end

function MoneyInputFrame_PickupPlayerMoney(moneyFrame)
	local copper = MoneyInputFrame_GetCopper(moneyFrame);
	if ( copper > GetMoney() ) then
		UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_MONEY, 1.0, 0.1, 0.1, 1.0);
	else
		PickupPlayerMoney(copper);
	end
end
