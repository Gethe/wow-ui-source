--[[
--------------------------- Frame Settings --------------------------------
	pauseUpdates [boolean] - If true, prevents updating of text values and causes bar to hide unless <alwaysShow> is true
	alwaysShow [boolean] - Force show the bar even when max value is 0 or <pauseUpdates> is true
	forceShow [boolean] - Force show text despite current <cvar> or lock settings
	cvar [string] - Name of the cvar that controls whether this bar's text should display, only used if <textLockable> is also true
	textLockable [boolean] - Determines whether text can be kept visible based on current value of <cvar>
	forceHideText [boolean] - Prevents text from being shown by calling ShowStatusBarText; Does not prevent showing via <forceShow> or <cvar + textLockable>

	powerToken [string] - If not set or value is "MANA", the "BOTH" status text setting shows both numeric and % values, otherwise BOTH shows only numeric
	showNumeric [boolean] - If true, forces text to "NUMERIC" mode despite current status text setting; Supercedes <showPercentage>; Often externally set as a temporary override
	showPercentage [boolean] - If true, forces text to "PERCENT" mode despite current status text setting; Does not function if <showNumeric> is also true; Often externally set as a temporary override
	disablePercentages [boolean] - If true, forces text to show only non-percentage numeric values even when in "BOTH" or "PERCENT" mode

	zeroText [string] - Text to show if current value is 0
	prefix [string] - Prefix text to display before value numbers; Shown if <alwaysPrefix> is true OR <cvar + textLockable> are disabled
	alwaysPrefix [boolean] - Force show prefix text even if <cvar + textLockable> are enabled
	capNumericDisplay [boolean] - If true, uses AbbreviateLargeNumbers for both value and max value text; Not used if <numericDisplayTransformFunc> is provided
	numericDisplayTransformFunc [function(value, valueMax)] - Function for custom formatting of value and max value for numeric text display; Return resulting (valueText, valueMaxText)
]]

STATUS_TEXT_DISPLAY_MODE = {
	NUMERIC = "NUMERIC",
	PERCENT = "PERCENT",
	BOTH = "BOTH",
	NONE = "NONE",
};

TextStatusBarMixin = {};

function TextStatusBarMixin:InitializeTextStatusBar()
	self:RegisterEvent("CVAR_UPDATE");
	self.lockShow = 0;

	local function OnStatusTextSettingChanged()
		self:UpdateTextString();
	end

	Settings.SetOnValueChangedCallback("PROXY_STATUS_TEXT", OnStatusTextSettingChanged);

	if ( self.Spark ) then
		self.Spark:Initialize(self);
	end
end

function TextStatusBarMixin:SetBarText(text, leftText, rightText)
	if ( not text ) then
		return
	end
	self.TextString = text;

	if( leftText ) then
		self.LeftText = leftText;
	end
	
	if ( rightText) then
		self.RightText = rightText;
	end
end

function TextStatusBarMixin:TextStatusBarOnEvent(event, ...)
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
			self:UpdateTextString();
		end
	end
end

function TextStatusBarMixin:UpdateTextString()
	local textString = self.TextString;
	if(textString) then
		local value = self:GetValue();
		local valueMin, valueMax = self:GetMinMaxValues();
		self:UpdateTextStringWithValues(textString, value, valueMin, valueMax);
	end
end

function TextStatusBarMixin:UpdateTextStringWithValues(textString, value, valueMin, valueMax)
	if( self.LeftText and self.RightText ) then
		self.LeftText:SetText("");
		self.RightText:SetText("");
		self.LeftText:Hide();
		self.RightText:Hide();
	end
	
	-- Max value is valid and updates aren't paused
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( self.pauseUpdates ) ) then
		self:Show();
		
		if ( (self.cvar and GetCVar(self.cvar) == "1" and self.textLockable) or self.forceShow ) then
			textString:Show();
		elseif ( self.lockShow > 0 and (not self.forceHideText) ) then
			textString:Show();
		else
			textString:SetText("");
			textString:Hide();
			return;
		end

		-- Display zero text
		if ( value == 0 and self.zeroText ) then
			textString:SetText(self.zeroText);
			self.isZero = 1;
			textString:Show();
			return;
		end

		self.isZero = nil;

		local valueDisplay = value;
		local valueMaxDisplay = valueMax;

		-- If custom text transform func provided, use that
		if ( self.numericDisplayTransformFunc ) then
			valueDisplay, valueMaxDisplay = self.numericDisplayTransformFunc(value, valueMax);
		-- Otherwise just the usual large number handling
		else
			if ( self.capNumericDisplay ) then
				valueDisplay = AbbreviateLargeNumbers(value);
				valueMaxDisplay = AbbreviateLargeNumbers(valueMax);
			else
				valueDisplay = BreakUpLargeNumbers(value);
				valueMaxDisplay = BreakUpLargeNumbers(valueMax);
			end
		end

		local shouldUsePrefix = self.prefix and (self.alwaysPrefix or not (self.cvar and GetCVar(self.cvar) == "1" and self.textLockable) );

		local displayMode = GetCVar("statusTextDisplay");
		-- Evaluate display mode overrides in priority order
		if ( self.showNumeric ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.NUMERIC;
		elseif ( self.showPercentage ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.PERCENT;
		end

		-- If percent-only mode and percentages disabled, fall back on numeric-only
		if ( self.disablePercentages and displayMode == STATUS_TEXT_DISPLAY_MODE.PERCENT ) then
			displayMode = STATUS_TEXT_DISPLAY_MODE.NUMERIC;
		end

		-- Numeric only
		if ( valueMax <= 0 or displayMode == STATUS_TEXT_DISPLAY_MODE.NUMERIC or displayMode == STATUS_TEXT_DISPLAY_MODE.NONE) then
			if ( shouldUsePrefix ) then
				textString:SetText(self.prefix.." "..valueDisplay.." / "..valueMaxDisplay);
			else
				textString:SetText(valueDisplay.." / "..valueMaxDisplay);
			end
		-- Numeric + Percentage
		elseif ( displayMode == STATUS_TEXT_DISPLAY_MODE.BOTH ) then
			if ( self.LeftText and self.RightText ) then
				-- Unless explicitly disabled, only display percentage on left if displaying mana or a non-power value (legacy behavior that should eventually be revisited)
				if ( not self.disablePercentages and (not self.powerToken or self.powerToken == "MANA") ) then
					self.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%");
					self.LeftText:Show();
				end
				self.RightText:SetText(valueDisplay);
				self.RightText:Show();
				textString:Hide();
			else
				valueDisplay = valueDisplay .. " / " .. valueMaxDisplay;
				if ( not self.disablePercentages ) then
					valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay;
				end
			end
			textString:SetText(valueDisplay);
		-- Percentage Only
		elseif ( displayMode == STATUS_TEXT_DISPLAY_MODE.PERCENT ) then
			valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
			if ( shouldUsePrefix ) then
				textString:SetText(self.prefix .. " " .. valueDisplay);
			else
				textString:SetText(valueDisplay);
			end
		end
	-- Max value is invalid or updates are paused
	else
		textString:Hide();
		textString:SetText("");
		if ( not self.alwaysShow ) then
			self:Hide();
		else
			self:SetValue(0);
		end
	end
end

function TextStatusBarMixin:OnStatusBarEnter()
	self:ShowStatusBarText();
	self:UpdateTextString();
end

function TextStatusBarMixin:OnStatusBarLeave()
	self:HideStatusBarText();
	GameTooltip:Hide();
end

function TextStatusBarMixin:OnStatusBarValueChanged()
	self:UpdateTextString();
	if ( self.Spark ) then
		self.Spark:OnBarValuesUpdated(self);
	end
end

function TextStatusBarMixin:OnStatusBarMinMaxChanged(min, max)
	if ( self.Spark ) then
		self.Spark:OnBarValuesUpdated(self);
	end
end

function TextStatusBarMixin:SetBarTextPrefix(prefix)
	if ( self.TextString ) then
		self.prefix = prefix;
	end
end

function TextStatusBarMixin:SetBarTextZeroText(zeroText)
	if ( self.TextString ) then
		self.zeroText = zeroText;
	end
end

function TextStatusBarMixin:ShowStatusBarText()
	if ( self and self.TextString ) then
		if ( not self.lockShow ) then
			self.lockShow = 0;
		end
		if ( not self.forceHideText ) then
			self.TextString:Show();
		end
		self.lockShow = self.lockShow + 1;
		self:UpdateTextString();
	end
end

function TextStatusBarMixin:HideStatusBarText()
	if ( self and self.TextString ) then
		if ( not self.lockShow ) then
			self.lockShow = 0;
		end
		if ( self.lockShow > 0 ) then
			self.lockShow = self.lockShow - 1;
		end
		if ( self.lockShow > 0 or self.isZero == 1) then
			self.TextString:Show();
		elseif ( (self.cvar and GetCVar(self.cvar) == "1" and self.textLockable) or self.forceShow ) then
			self.TextString:Show();
		else
			self.TextString:Hide();
		end
		self:UpdateTextString();
	end
end


-- Optional spark frame, shows at the end of a TextStatusBar's fill texture
-- Essentially an endcap whose position follows current fill amount
TextStatusBarSparkMixin = {};

function TextStatusBarSparkMixin:Initialize(statusBar)
	self.statusBar = statusBar;
end

--[[
visualInfo settings:
	atlas: [string] -- Name of the atlas to use for the spark
	xOffset: [number] -- Optional, x anchor offset from the RIGHT edge of the fill bar
	barHeight: [number] -- Fill bar height the spark was designed for; Used for adjusting the spark's scale to fit the bar's actual current height
	showAtMax: [bool] -- If true, spark stays visible when bar is at maximum fill, otherwise it's hidden
]]
function TextStatusBarSparkMixin:SetVisuals(visualInfo)
	if ( visualInfo and visualInfo.atlas ) then
		self.visualInfo = visualInfo;
		self.isActive = true;

		local xOffset = visualInfo.xOffset or 0;
		local statusBarTexture = self.statusBar:GetStatusBarTexture();

		self:ClearAllPoints();
		self:SetPoint("RIGHT", statusBarTexture, "RIGHT", xOffset, 0);
		self:SetAtlas(visualInfo.atlas, TextureKitConstants.UseAtlasSize);

		self:UpdateSize();
		self:UpdateShown();
	else
		self.visualInfo = nil;
		self.isActive = false;
		self:Hide();
	end
end

function TextStatusBarSparkMixin:GetIsActive()
	return self.isActive;
end

function TextStatusBarSparkMixin:OnBarValuesUpdated()
	if ( self.isActive ) then
		self:UpdateShown();
	end
end

function TextStatusBarSparkMixin:UpdateShown()
	if ( not self.isActive or self.isForceHidden ) then
		self:Hide();
		return;
	end

	local currentValue = self.statusBar:GetValue();
	local minValue, maxValue = self.statusBar:GetMinMaxValues();

	self:SetShown(currentValue > minValue and (currentValue < maxValue or self.visualInfo.showAtMax));
end

function TextStatusBarSparkMixin:UpdateSize()
	if ( not self.isActive ) then
		return;
	end
	
	local newScale = 1;
	if( self.visualInfo.barHeight ) then
		local statusBarTexture = self.statusBar:GetStatusBarTexture();
		local barHeight = statusBarTexture:GetHeight();
		local heightMultiplier = barHeight / self.visualInfo.barHeight;
		if heightMultiplier > 0 then
			newScale = heightMultiplier;
		end
	end

	self:SetScale(newScale);
end