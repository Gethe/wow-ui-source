
function TextStatusBar_Initialize(self)
	self:RegisterEvent("CVAR_UPDATE");
	self.lockShow = 0;
end

function SetTextStatusBarText(bar, text)
	if ( not bar or not text ) then
		return
	end
	bar.TextString = text;
end

function TextStatusBar_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		local cvar, value = ...;
		if ( self.cvar and cvar == self.cvarLabel ) then
			if ( self.TextString ) then
				if ( (value == "1" and self.textLockable) or self.forceShow ) then
					self.TextString:Show();
				elseif ( self.lockShow == 0 ) then
					self.TextString:Hide();
				end
			end
			TextStatusBar_UpdateTextString(self);
		elseif ( cvar == "STATUS_TEXT_PERCENT" ) then
			TextStatusBar_UpdateTextString(self);
		end
	end
end

function TextStatusBar_UpdateTextString(textStatusBar)
	local textString = textStatusBar.TextString;
	if(textString) then
		local value = textStatusBar:GetValue();
		local valueMin, valueMax = textStatusBar:GetMinMaxValues();

		if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( textStatusBar.pauseUpdates ) ) then
			textStatusBar:Show();
			if ( value and valueMax > 0 and ( GetCVarBool("statusTextPercentage") or textStatusBar.showPercentage ) and not textStatusBar.showNumeric) then
				if ( value == 0 and textStatusBar.zeroText ) then
					textString:SetText(textStatusBar.zeroText);
					textStatusBar.isZero = 1;
					textString:Show();
					return;
				end
				value = tostring(math.ceil((value / valueMax) * 100)) .. "%";
				if ( textStatusBar.prefix and (textStatusBar.alwaysPrefix or not (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
					textString:SetText(textStatusBar.prefix .. " " .. value);
				else
					textString:SetText(value);
				end
			elseif ( value == 0 and textStatusBar.zeroText ) then
				textString:SetText(textStatusBar.zeroText);
				textStatusBar.isZero = 1;
				textString:Show();
				return;
			else
				textStatusBar.isZero = nil;
				if ( textStatusBar.capNumericDisplay ) then
					value = TextStatusBar_CapDisplayOfNumericValue(value);
					valueMax = TextStatusBar_CapDisplayOfNumericValue(valueMax);
				end
				if ( textStatusBar.prefix and (textStatusBar.alwaysPrefix or not (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) ) ) then
					textString:SetText(textStatusBar.prefix.." "..value.." / "..valueMax);
				else
					textString:SetText(value.." / "..valueMax);
				end
			end
			
			if ( (textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) or textStatusBar.forceShow ) then
				textString:Show();
			elseif ( textStatusBar.lockShow > 0 and (not textStatusBar.forceHideText) ) then
				textString:Show();
			else
				textString:Hide();
			end
		else
			textString:Hide();
			textString:SetText("");
			if ( not textStatusBar.alwaysShow ) then
				textStatusBar:Hide();
			else
				textStatusBar:SetValue(0);
			end
		end
	end
end

function TextStatusBar_CapDisplayOfNumericValue(value)
	local strLen = strlen(value);
	local retString = value;
	if ( strLen > 8 ) then
		retString = string.sub(value, 1, -7)..SECOND_NUMBER_CAP;
	elseif ( strLen > 5 ) then
		retString = string.sub(value, 1, -4)..FIRST_NUMBER_CAP;
	end
	return retString;
end

function TextStatusBar_OnValueChanged(self)
	TextStatusBar_UpdateTextString(self);
end

function SetTextStatusBarTextPrefix(bar, prefix)
	if ( bar and bar.TextString ) then
		bar.prefix = prefix;
	end
end

function SetTextStatusBarTextZeroText(bar, zeroText)
	if ( bar and bar.TextString ) then
		bar.zeroText = zeroText;
	end
end

function ShowTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		if ( not bar.forceHideText ) then
			bar.TextString:Show();
		end
		bar.lockShow = bar.lockShow + 1;
		TextStatusBar_UpdateTextString(bar);
	end
end

function HideTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		if ( bar.lockShow > 0 ) then
			bar.lockShow = bar.lockShow - 1;
		end
		if ( bar.lockShow > 0 or bar.isZero == 1) then
			bar.TextString:Show();
		elseif ( (bar.cvar and GetCVar(bar.cvar) == "1" and bar.textLockable) or bar.forceShow ) then
			bar.TextString:Show();
		else
			bar.TextString:Hide();
		end
		TextStatusBar_UpdateTextString(bar);
	end
end
