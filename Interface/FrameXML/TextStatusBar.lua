--[[
--------------------------- Frame Settings --------------------------------
	pauseUpdates [boolean] - If true, prevents updating of text values and causes bar to hide unless <alwaysShow> is true
	alwaysShow [boolean] - Force show the bar even when max value is 0 or <pauseUpdates> is true
	forceShow [boolean] - Force show text despite current <cvar> or lock settings
	cvar [string] - Name of the cvar that controls whether this bar's text should display, only used if <textLockable> is also true
	textLockable [boolean] - Determines whether text can be kept visible based on current value of <cvar>
	forceHideText [boolean] - Prevents text from being shown by calling ShowTextStatusBarText; Does not prevent showing via <forceShow> or <cvar + textLockable>

	powerToken [string] - If not set or value is "MANA", the "BOTH" status text setting shows both numeric and % values, otherwise BOTH shows only numeric
	showNumeric [boolean] - If true, forces text to show numeric values despite current status text setting; Supercedes <showPercentage>
	showPercentage [boolean] - If true, forces text to show percentage values despite current status text setting; Does not function if <showNumeric> is also true

	zeroText [string] - Text to show if current value is 0
	prefix [string] - Prefix text to display before value numbers; Shown if <alwaysPrefix> is true OR <cvar + textLockable> are disabled
	alwaysPrefix [boolean] - Force show prefix text even if <cvar + textLockable> are enabled
	capNumericDisplay [boolean] - If true, uses AbbreviateLargeNumbers for both value and max value text; Not used if <numericDisplayTransformFunc> is provided
	numericDisplayTransformFunc [function(value, valueMax)] - Function for custom formatting of value and max value for numeric text display; Return resulting (valueText, valueMaxText)
]]

function TextStatusBar_Initialize(self)
	self:RegisterEvent("CVAR_UPDATE");
	self.lockShow = 0;

	local function OnStatusTextSettingChanged()
		TextStatusBar_UpdateTextString(self);
	end

	Settings.SetOnValueChangedCallback("PROXY_STATUS_TEXT", OnStatusTextSettingChanged);
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
		if ( self.cvar and cvar == self.cvar ) then
			if ( self.TextString ) then
				if ( (value == "1" and self.textLockable) or self.forceShow ) then
					self.TextString:Show();
				elseif ( self.lockShow == 0 ) then
					self.TextString:Hide();
				end
			end
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
	if( statusFrame.LeftText and statusFrame.RightText ) then
		statusFrame.LeftText:SetText("");
		statusFrame.RightText:SetText("");
		statusFrame.LeftText:Hide();
		statusFrame.RightText:Hide();
	end
	
	-- Max value is valid and updates aren't paused
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

		-- If custom text transform func provided, use that
		if ( statusFrame.numericDisplayTransformFunc ) then
			valueDisplay, valueMaxDisplay = statusFrame.numericDisplayTransformFunc(value, valueMax);
		-- Otherwise just the usual large number handling
		else
			if ( statusFrame.capNumericDisplay ) then
				valueDisplay = AbbreviateLargeNumbers(value);
				valueMaxDisplay = AbbreviateLargeNumbers(valueMax);
			else
				valueDisplay = BreakUpLargeNumbers(value);
				valueMaxDisplay = BreakUpLargeNumbers(valueMax);
			end
		end

		local textDisplay = GetCVar("statusTextDisplay");
		-- Display settings include showing the value as a percentage
		if ( value and valueMax > 0 and ( (textDisplay ~= "NUMERIC" and textDisplay ~= "NONE") or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			-- Display zero text
			if ( value == 0 and statusFrame.zeroText ) then
				textString:SetText(statusFrame.zeroText);
				statusFrame.isZero = 1;
				textString:Show();
			-- Numeric + Percentage
			elseif ( textDisplay == "BOTH" and not statusFrame.showPercentage) then
				if( statusFrame.LeftText and statusFrame.RightText ) then
					-- Only display percentage on left if displaying mana or a non-power value (legacy behavior that should eventually be revisited)
					if(not statusFrame.powerToken or statusFrame.powerToken == "MANA") then
						statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%");
						statusFrame.LeftText:Show();
					end
					statusFrame.RightText:SetText(valueDisplay);
					statusFrame.RightText:Show();
					textString:Hide();
				else
					valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay .. " / " .. valueMaxDisplay;
				end
				textString:SetText(valueDisplay);
			-- Percentage Only
			else
				valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
				if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					textString:SetText(statusFrame.prefix .. " " .. valueDisplay);
				else
					textString:SetText(valueDisplay);
				end
			end
		-- Display zero text
		elseif ( value == 0 and statusFrame.zeroText ) then
			textString:SetText(statusFrame.zeroText);
			statusFrame.isZero = 1;
			textString:Show();
			return;
		-- Numeric only
		else
			statusFrame.isZero = nil;
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix.." "..valueDisplay.." / "..valueMaxDisplay);
			else
				textString:SetText(valueDisplay.." / "..valueMaxDisplay);
			end
		end
	-- Max value is invalid or updates are paused
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
