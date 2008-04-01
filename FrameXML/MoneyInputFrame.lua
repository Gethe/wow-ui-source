
function MoneyInputFrame_ResetMoney(moneyFrame)
	getglobal(moneyFrame:GetName().."Gold"):SetText("");
	getglobal(moneyFrame:GetName().."Silver"):SetText("");
	getglobal(moneyFrame:GetName().."Copper"):SetText("");
end

function MoneyInputFrame_ClearFocus(moneyFrame)
	getglobal(moneyFrame:GetName().."Gold"):ClearFocus();
	getglobal(moneyFrame:GetName().."Silver"):ClearFocus();
	getglobal(moneyFrame:GetName().."Copper"):ClearFocus();
end

function MoneyInputFrame_GetCopper(moneyFrame)
	local totalCopper = 0;
	local copper = getglobal(moneyFrame:GetName().."Copper"):GetText();
	local silver = getglobal(moneyFrame:GetName().."Silver"):GetText();
	local gold = getglobal(moneyFrame:GetName().."Gold"):GetText();
	
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
	getglobal(moneyFrame:GetName().."Copper"):SetTextColor(r, g, b);
	getglobal(moneyFrame:GetName().."Silver"):SetTextColor(r, g, b);
	getglobal(moneyFrame:GetName().."Gold"):SetTextColor(r, g, b);
end

function MoneyInputFrame_SetCopper(moneyFrame, money)
	local gold = floor(money / (COPPER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	local editbox = nil;

	moneyFrame.expectChanges = 0;
	editbox = getglobal(moneyFrame:GetName().."Copper");
	if ( editbox:GetNumber() ~= copper ) then
		editbox:SetNumber(copper);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
	editbox = getglobal(moneyFrame:GetName().."Silver");
	if ( editbox:GetNumber() ~= silver ) then
		editbox:SetNumber(silver);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
	editbox = getglobal(moneyFrame:GetName().."Gold");
	if ( editbox:GetNumber() ~= gold ) then
		editbox:SetNumber(gold);
		moneyFrame.expectChanges = moneyFrame.expectChanges + 1;
	end
end

function MoneyInputFrame_OnTextChanged(moneyFrame)
	if ( moneyFrame.expectChanges ) then
		if ( moneyFrame.expectChanges > 1 ) then
			moneyFrame.expectChanges = moneyFrame.expectChanges - 1;
			return;
		end
		moneyFrame.expectChanges = nil;
	end
	if ( this:GetParent().onvalueChangedFunc ) then
		this:GetParent().onvalueChangedFunc();
	end
end

function MoneyInputFrame_SetMode(frame, mode)
	local frameName = frame:GetName();
	if ( mode == "compact" ) then
		getglobal(frameName.."Copper"):SetPoint("LEFT", frameName.."Silver", "RIGHT", 13, 0);
		getglobal(frameName.."Silver"):SetPoint("LEFT", frameName.."Gold", "RIGHT", 13, 0);
		getglobal(frameName.."Gold"):SetWidth(56);
	end
end

-- Used to set the frames before the moneyframe when tabbing through
function MoneyInputFrame_SetPreviousFocus(moneyFrame, focus)
	moneyFrame.previousFocus = focus;
end

function MoneyInputFrame_SetNextFocus(moneyFrame, focus)
	moneyFrame.nextFocus = focus;
end

function MoneyInputFrame_SetOnvalueChangedFunc(moneyFrame, func)
	moneyFrame.onvalueChangedFunc = func;
end