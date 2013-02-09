
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
		elseif ( cvar == "STATUS_TEXT_DISPLAY" ) then
			TextStatusBar_UpdateTextString(self);
		end
	end
end

function TextStatusBar_UpdateTextString(textStatusBar)
	local textString = textStatusBar.TextString;
	if(textString) then
		local value = textStatusBar:GetValue();
		local valueMin, valueMax = textStatusBar:GetMinMaxValues();
		TextStatusBar_UpdateTextStringWithValues(textStatusBar, textString, value, valueMin, valueMax);
	end
end

function TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		statusFrame:Show();
		if ( (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) or statusFrame.forceShow ) then
			textString:Show();
		elseif ( statusFrame.lockShow > 0 and (not statusFrame.forceHideText) ) then
			textString:Show();
		else
			textString:SetText("");
			textString:Hide();
			return;
		end

		local valueDisplay = value;
		local valueMaxDisplay = valueMax;
		if ( statusFrame.capNumericDisplay ) then
			valueDisplay = AbbreviateLargeNumbers(value);
			valueMaxDisplay = AbbreviateLargeNumbers(valueMax);
		else
			valueDisplay = BreakUpLargeNumbers(value);
			valueMaxDisplay = BreakUpLargeNumbers(valueMax);
		end

		local textDisplay = GetCVar("statusTextDisplay");
		if ( value and valueMax > 0 and ( textDisplay ~= "NUMERIC" or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			if ( value == 0 and statusFrame.zeroText ) then
				textString:SetText(statusFrame.zeroText);
				statusFrame.isZero = 1;
				textString:Show();
				return;
			end
			if ( textDisplay == "BOTH" and not statusFrame.showPercentage) then
				valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay .. " / " .. valueMaxDisplay;
				textString:SetText(valueDisplay);
			else
				valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
				if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					textString:SetText(statusFrame.prefix .. " " .. valueDisplay);
				else
					textString:SetText(valueDisplay);
				end
			end
		elseif ( value == 0 and statusFrame.zeroText ) then
			textString:SetText(statusFrame.zeroText);
			statusFrame.isZero = 1;
			textString:Show();
			return;
		else
			statusFrame.isZero = nil;
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix.." "..valueDisplay.." / "..valueMaxDisplay);
			else
				textString:SetText(valueDisplay.." / "..valueMaxDisplay);
			end
		end
	else
		textString:Hide();
		textString:SetText("");
		if ( not statusFrame.alwaysShow ) then
			statusFrame:Hide();
		else
			statusFrame:SetValue(0);
		end
	end
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
