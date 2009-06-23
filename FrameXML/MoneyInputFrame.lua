
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
	if ( self:GetParent().onValueChangedFunc ) then
		self:GetParent().onValueChangedFunc();
	end
end

function MoneyInputFrame_SetMode(frame, mode)
	local frameName = frame:GetName();
	if ( mode == "compact" ) then
		_G[frameName.."Copper"]:SetPoint("LEFT", frameName.."Silver", "RIGHT", 11, 0);
		_G[frameName.."Silver"]:SetPoint("LEFT", frameName.."Gold", "RIGHT", 22, 0);
		_G[frameName.."Gold"]:SetWidth(56);
	end
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
	else
		moneyFrame.copper.texture:Show();
		moneyFrame.gold.texture:Show();
		moneyFrame.silver.texture:Show();
		moneyFrame.copper.label:Hide();
		moneyFrame.gold.label:Hide();
		moneyFrame.silver.label:Hide();
	end
end
