ALTERNATE_POWER_INDEX = 10;

ALT_POWER_TYPE_HORIZONTAL 		= 0;
ALT_POWER_TYPE_VERTICAL 		= 1;
ALT_POWER_TYPE_CIRCULAR			= 2;
ALT_POWER_TYPE_PILL				= 3;
--Counter bar uses a different frame
ALT_POWER_TYPE_COUNTER			= 4;

DOUBLE_SIZE_FIST_BAR = 199;

local altPowerBarTextures = {
	frame = 0,
	background = 1,
	fill = 2,
	spark = 3,
	flash = 4,
}

ALT_POWER_TEX_FRAME				= 0;
ALT_POWER_TEX_BACKGROUND		= 1;
ALT_POWER_TEX_FILL				= 2;
ALT_POWER_TEX_SPARK				= 3;
ALT_POWER_TEX_FLASH				= 4;

ALT_POWER_BAR_PLAYER_SIZES = {	--Everything else is scaled off of this
	[ALT_POWER_TYPE_HORIZONTAL]		= {x = 256, y = 64},
	[ALT_POWER_TYPE_VERTICAL]		= {x = 64, y = 128},
	[ALT_POWER_TYPE_CIRCULAR]		= {x = 128, y = 128},
	[ALT_POWER_TYPE_PILL]			= {x = 32, y = 64},	--This is the size of a single pill.
	[ALT_POWER_TYPE_COUNTER]		= {x = 32, y = 32},
	doubleCircular					= {x = 256, y = 256}, --Override for task 55676
}

function UnitPowerBarAlt_Initialize(self, unit, scale, updateAllEvent)
	self.unit = unit;
	self.counterBar.unit = unit;
	self.scale = scale;
	if ( updateAllEvent ) then
		UnitPowerBarAlt_SetUpdateAllEvent(self, updateAllEvent)
	end
	
	self:RegisterEvent("UNIT_POWER_BAR_SHOW");
	self:RegisterEvent("UNIT_POWER_BAR_HIDE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.pillFrames = {};
end

function UnitPowerBarAlt_OnEnter(self)
	local statusFrame = self.statusFrame;
	if ( statusFrame.enabled ) then
		statusFrame:Show();
		UnitPowerBarAltStatus_UpdateText(statusFrame);
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText(self.powerName, 1, 1, 1);
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1);
	GameTooltip:Show();
end

function UnitPowerBarAlt_OnLeave(self)
	UnitPowerBarAltStatus_ToggleFrame(self.statusFrame);
	GameTooltip:Hide();
end

function UnitPowerBarAlt_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	
	if ( event == self.updateAllEvent ) then
		UnitPowerBarAlt_UpdateAll(self);
	elseif ( event == "UNIT_POWER_BAR_SHOW" ) then
		if ( arg1 == self.unit ) then
			UnitPowerBarAlt_UpdateAll(self);
		end
	elseif ( event == "UNIT_POWER_BAR_HIDE" ) then
		if ( arg1 == self.unit ) then
			UnitPowerBarAlt_UpdateAll(self);
		end
	elseif ( event == "UNIT_POWER" ) then
		if ( arg1 == self.unit and arg2 == "ALTERNATE" ) then
			local barType, minPower = UnitAlternatePowerInfo(self.unit);
			local currentPower = UnitPower(self.unit, ALTERNATE_POWER_INDEX);
			
			if ( not barType or barType == ALT_POWER_TYPE_COUNTER ) then
				CounterBar_UpdateCount(self.counterBar, currentPower);
			else
				UnitPowerBarAlt_SetPower(self, currentPower);
			end
		end
	elseif ( event == "UNIT_MAXPOWER" ) then
		if ( arg1 == self.unit and arg2 == "ALTERNATE" ) then
			local barType, minPower = UnitAlternatePowerInfo(self.unit);
			if ( not barType or barType == ALT_POWER_TYPE_COUNTER ) then
				CounterBar_SetUp(self.counterBar);
				return;
			end
			UnitPowerBarAlt_SetMinMaxPower(self, minPower, UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX));
			
			local currentPower = UnitPower(self.unit, ALTERNATE_POWER_INDEX);
			UnitPowerBarAlt_SetPower(self, currentPower, true);
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		UnitPowerBarAlt_UpdateAll(self);
	end
end

function UnitPowerBarAlt_SetUpdateAllEvent(self, event)
	self.updateAllEvent = event;
	self:RegisterEvent(event);
end

local maxPerSecond = 0.7;
local minPerSecond = 0.3;
function GetSmoothProgressChange(value, displayedValue, range, elapsed)
	local minPerSecond = max(minPerSecond, 1/range);	--Make sure we're moving at least 1 unit/second (will only matter if our maximum power is 3 or less);
	
	local diff = displayedValue - value;
	local diffRatio = diff / range;
	local change = range * ((minPerSecond/abs(diffRatio) + maxPerSecond - minPerSecond) * diffRatio) * elapsed;
	if ( abs(change) > abs(diff) or abs(diffRatio) < 0.01 ) then
		return value;
	else
		return displayedValue - change;
	end
end

function UnitPowerBarAlt_OnUpdate(self, elapsed)
	if ( self.smooth and  self.value and self.displayedValue and self.value ~= self.displayedValue ) then
		UnitPowerBarAlt_SetDisplayedPower(self, GetSmoothProgressChange(self.value, self.displayedValue, self.range, elapsed));
	end
end

function UnitPowerBarAlt_ApplyTextures(frame, unit)
	for textureName, textureIndex in pairs(altPowerBarTextures) do
		local texture = frame[textureName];
		local texturePath, r, g, b = UnitAlternatePowerTextureInfo(unit, textureIndex, frame.timerIndex);
		texture:SetTexture(texturePath);
		texture:SetVertexColor(r, g, b);
	end
end

function UnitPowerBarAlt_HideTextures(frame)
	frame.flashAnim:Stop();
	frame.flashOutAnim:Stop();
	for textureName, textureIndex in pairs(altPowerBarTextures) do
		local texture = frame[textureName];
		texture:SetTexture(nil);
		texture:Hide();
	end
end

function UnitPowerBarAlt_HidePills(self)
	if ( self.pillFrames ) then
		for i=1, #self.pillFrames do
			self.pillFrames[i]:Hide();
		end
	end
end

function UnitPowerBarAlt_SetUp(self, barID)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip, costString;
	if ( barID ) then
		barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip, costString = GetAlternatePowerInfoByID(barID);
	else
		barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip, costString, barID = UnitAlternatePowerInfo(self.unit);
	end
	
	self.startInset = startInset;
	self.endInset = endInset;
	self.smooth = smooth;
	self.powerName = powerName;
	self.powerTooltip = powerTooltip;
	
	local sizeInfo = ALT_POWER_BAR_PLAYER_SIZES[barType];
	if ( barID == DOUBLE_SIZE_FIST_BAR and self.scale == 1 ) then --Double the player's own power bar for task 55676
		sizeInfo = ALT_POWER_BAR_PLAYER_SIZES.doubleCircular;
	end
	self:SetSize(sizeInfo.x * self.scale, sizeInfo.y * self.scale);
	
	UnitPowerBarAlt_HideTextures(self);	--It's up to the SetUp functions to show textures they need.
	UnitPowerBarAlt_HidePills(self);

	if ( barType == ALT_POWER_TYPE_PILL or barType == ALT_POWER_TYPE_COUNTER ) then
		self.statusFrame:Hide();
		self.statusFrame.enabled = false;
	else
		self.statusFrame.enabled = true;
		UnitPowerBarAltStatus_ToggleFrame(self.statusFrame);
	end

	if ( barType == ALT_POWER_TYPE_HORIZONTAL ) then
		UnitPowerBarAlt_Horizontal_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_VERTICAL ) then
		UnitPowerBarAlt_Vertical_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_CIRCULAR ) then
		UnitPowerBarAlt_Circular_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_PILL ) then
		UnitPowerBarAlt_Pill_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_COUNTER ) then
		self.counterBar:Show();
		CounterBar_SetUp(self.counterBar);
	else
		error("Currently unhandled bar type: "..(barType or "nil"));
	end
	
	if ( opaqueSpark ) then
		self.spark:SetBlendMode("BLEND");
	else
		self.spark:SetBlendMode("ADD");
	end
	
	if ( opaqueFlash ) then
		self.flash:SetBlendMode("BLEND");
	else
		self.flash:SetBlendMode("ADD");
	end
	
	self:RegisterUnitEvent("UNIT_POWER", self.unit);
	self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit);
end


function UnitPowerBarAlt_TearDown(self)
	self.fill:SetTexCoord(0, 1, 0, 1);
	
	self.displayedValue = nil;
	
	self:UnregisterEvent("UNIT_POWER");
	self:UnregisterEvent("UNIT_MAXPOWER");
end

function UnitPowerBarAlt_UpdateAll(self)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid = UnitAlternatePowerInfo(self.unit);
	if ( barType and (not hideFromOthers or self.isPlayerBar) ) then
		UnitPowerBarAlt_TearDown(self);
		UnitPowerBarAlt_SetUp(self);

		local currentPower = UnitPower(self.unit, ALTERNATE_POWER_INDEX);
		if ( barType ~= ALT_POWER_TYPE_COUNTER ) then
			local maxPower = UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX);
			UnitPowerBarAlt_SetMinMaxPower(self, minPower, maxPower);
			
			UnitPowerBarAlt_SetPower(self, currentPower, true);
		else
			CounterBar_SetUp(self.counterBar);
			CounterBar_UpdateCount(self.counterBar, currentPower, true);
		end
		self:Show();
	else
		UnitPowerBarAlt_TearDown(self);
		self:Hide();
		self.counterBar:Hide();
	end
end

function UnitPowerBarAlt_OnFlashPlay(self)
	self:GetParent().flash:SetAlpha(0);
end

function UnitPowerBarAlt_OnFlashFinished(self)
	self:GetParent().flash:SetAlpha(1);
end

function UnitPowerBarAlt_OnFlashOutFinished(self)
	self:GetParent().flash:Hide();
end

function UnitPowerBarAlt_SetPower(self, value, instantUpdate)
	self.value = value;
	if ( not self.smooth or instantUpdate or not self.displayedValue ) then
		UnitPowerBarAlt_SetDisplayedPower(self, value);
	end
	
	if ( value == self.maxPower ) then
		if ( instantUpdate ) then
			self.flash:Show();
			self.flash:SetAlpha(1);
		elseif ( not self.flash:IsShown() ) then
			self.flash:Show();
			self.flashAnim:Play();
		elseif ( not self.flashAnim:IsPlaying() ) then
			self.flash:SetAlpha(1);
		end
		self.flashOutAnim:Stop();
	else
		self.flashAnim:Stop();
		if ( instantUpdate ) then
			self.flash:Hide();
		elseif ( self.flash:IsShown() and not self.flashOutAnim:IsPlaying() ) then
			self.flashOutAnim:Play();
		end
	end
end

function UnitPowerBarAlt_SetDisplayedPower(self, value)
	self.displayedValue = value;
	UnitPowerBarAltStatus_UpdateText(self.statusFrame);
	self:UpdateFill();
end

function UnitPowerBarAlt_SetMinMaxPower(self, minPower, maxPower)
	self.range = maxPower - minPower;
	self.maxPower = maxPower;
	self.minPower = minPower;
	self:UpdateFill();
end

--Horizontal Status Bar
function UnitPowerBarAlt_Horizontal_SetUp(self)
	UnitPowerBarAlt_ApplyTextures(self, self.unit);
	
	self.frame:Show();
	self.background:Show();
	self.fill:Show();
	self.spark:Show();
	
	self.spark:ClearAllPoints();
	self.spark:SetHeight(self:GetHeight());
	self.spark:SetWidth(self:GetHeight()/8);
	self.spark:SetPoint("LEFT", self.fill, "RIGHT", -3 * self.scale, 0);
	
	self.fill:ClearAllPoints();
	self.fill:SetPoint("TOPLEFT");
	self.fill:SetPoint("BOTTOMLEFT");
	self.fill:SetWidth(self:GetWidth());
	
	self.UpdateFill = UnitPowerBarAlt_Horizontal_UpdateFill;
end

function UnitPowerBarAlt_Horizontal_UpdateFill(self)
	if ( not self.range or self.range == 0 or not self.displayedValue ) then
		return;
	end
	local ratio = self.displayedValue / self.range;
	local fillAmount = self.startInset + ratio * ((1 - self.endInset) - self.startInset);
	self.fill:SetWidth(max(self:GetWidth() * fillAmount, 1));
	self.fill:SetTexCoord(0, fillAmount, 0, 1);
end

--Vertical Status Bar
function UnitPowerBarAlt_Vertical_SetUp(self)
	UnitPowerBarAlt_ApplyTextures(self, self.unit);
	
	self.frame:Show();
	self.background:Show();
	self.fill:Show();
	self.spark:Show();
	
	self.spark:ClearAllPoints();
	self.spark:SetHeight(self:GetHeight()/8);
	self.spark:SetWidth(self:GetWidth());
	self.spark:SetPoint("BOTTOM", self.fill, "TOP", 0, -4 * self.scale);
	
	self.fill:ClearAllPoints();
	self.fill:SetPoint("BOTTOMLEFT");
	self.fill:SetPoint("BOTTOMRIGHT");
	self.fill:SetHeight(self:GetHeight());
	
	self.UpdateFill = UnitPowerBarAlt_Vertical_UpdateFill;
end

function UnitPowerBarAlt_Vertical_UpdateFill(self)
	if ( not self.range or self.range == 0 or not self.displayedValue ) then
		return;
	end
	local ratio = self.displayedValue / self.range;
	local fillAmount = self.startInset + ratio * ((1 - self.endInset) - self.startInset);
	self.fill:SetHeight(max(self:GetHeight() * fillAmount, 1));
	self.fill:SetTexCoord(0, 1, 1 - fillAmount, 1);
end

--Circular Bar
function UnitPowerBarAlt_Circular_SetUp(self)
	UnitPowerBarAlt_ApplyTextures(self, self.unit);
	
	self.frame:Show();
	self.background:Show();
	self.fill:Show();
	
	self.fill:ClearAllPoints();
	self.fill:SetPoint("CENTER");
	self.fill:SetSize(self:GetWidth(), self:GetHeight());
	
	self.UpdateFill = UnitPowerBarAlt_Circular_UpdateFill;
end

function UnitPowerBarAlt_Circular_UpdateFill(self)
	if ( not self.range or self.range == 0 or not self.displayedValue ) then
		return;
	end
	local ratio = self.displayedValue / self.range;
	local height, width = self:GetHeight() * ratio, self:GetWidth() * ratio;
	height = max(height, 1);
	width = max(width, 1);
	self.fill:SetSize(width, height);
end

--Pill Bar
function UnitPowerBarAlt_Pill_SetUp(self)
	--UnitPowerBarAlt_ApplyTextures(self, self.unit);	--For Pills, we apply the textures to the individual pill frames.
	local sizeInfo = ALT_POWER_BAR_PLAYER_SIZES[ALT_POWER_TYPE_PILL];
	for i = 1, #self.pillFrames do
		local pillFrame = self.pillFrames[i];
		UnitPowerBarAlt_ApplyTextures(pillFrame, self.unit);
		pillFrame:SetHeight(self:GetHeight());
		pillFrame:SetWidth(sizeInfo.x * self.scale);
	end
	
	self.UpdateFill = UnitPowerBarAlt_Pill_UpdateFill;
end

function UnitPowerBarAlt_Pill_UpdateFill(self)
	if ( not self.range or self.range == 0 or not self.displayedValue ) then
		return;
	end
	
	for i=1, self.range do
		local pillVal = self.minPower + i;
		local pillFrame = self.pillFrames[i];
		if ( not pillFrame ) then
			pillFrame = UnitPowerBarAlt_Pill_CreatePillFrame(self);
		end
		if ( pillVal <= self.displayedValue ) then
			pillFrame.flashAway:Stop();
			pillFrame.fill:SetAlpha(1);
			pillFrame.flash:SetAlpha(0);
			if ( pillFrame:IsShown() and not pillFrame.fill:IsShown()) then
				pillFrame.flashAnim:Play();
			end
			pillFrame.fill:Show();
		else
			if ( pillFrame:IsShown() ) then
				if ( pillFrame.fill:IsShown() and not pillFrame.flashAway:IsPlaying() ) then
					pillFrame.flashAnim:Stop();
					pillFrame.fill:SetAlpha(1);
					pillFrame.flash:SetAlpha(0);
					pillFrame.flashAway:Play();
				end
			else
				pillFrame.fill:Hide();
			end
		end
		if ( pillVal == floor(self.displayedValue) ) then
			pillFrame.spark:Show();
		else
			pillFrame.spark:Hide();
		end
		
		pillFrame:Show();
	end
	for i=self.range + 1, #self.pillFrames do
		local pillFrame = self.pillFrames[i];
		pillFrame:Hide();
	end
	self:SetWidth(self.range * ALT_POWER_BAR_PLAYER_SIZES[ALT_POWER_TYPE_PILL].x * self.scale);
end

function UnitPowerBarAlt_Pill_CreatePillFrame(self)
	local sizeInfo = ALT_POWER_BAR_PLAYER_SIZES[ALT_POWER_TYPE_PILL];
	local pillIndex = #self.pillFrames + 1;
	local pillFrame = CreateFrame("Frame", self:GetName().."Pill"..pillIndex, self, "UnitPowerBarAltPillTemplate");
	
	if ( pillIndex == 1 ) then
		pillFrame:SetPoint("LEFT", self, "LEFT", 0, 0);
	else
		pillFrame:SetPoint("LEFT", self.pillFrames[pillIndex - 1], "RIGHT", 0, 0);
	end
	
	UnitPowerBarAlt_ApplyTextures(pillFrame, self.unit);
	
	pillFrame.flash:SetAlpha(0);
	
	pillFrame:SetHeight(self:GetHeight());
	pillFrame:SetWidth(sizeInfo.x * self.scale);
	
	tinsert(self.pillFrames, pillFrame);
	return pillFrame;
end

function UnitPowerBarAlt_Pill_OnFlashAwayFinished(self)
	local pill = self:GetParent();
	pill.fill:Hide();
end

-- status text functions
-- self = statusFrame
function UnitPowerBarAltStatus_UpdateText(self)
	local powerBar = self:GetParent();
	if ( powerBar.displayedValue and self:IsShown() ) then
		TextStatusBar_UpdateTextStringWithValues(self, self.text, floor(powerBar.displayedValue), powerBar.minPower, powerBar.maxPower);
	end
end

function UnitPowerBarAltStatus_OnEvent(self, event, ...)
	-- self = status frame
	local cvar, value = ...;
	local doUpdate = false;
	if ( self.cvar and cvar == self.cvarLabel ) then
		UnitPowerBarAltStatus_ToggleFrame(self);
	elseif ( cvar == "STATUS_TEXT_DISPLAY" ) then
		UnitPowerBarAltStatus_UpdateText(self);
	end
end

function UnitPowerBarAltStatus_ToggleFrame(self)
	-- self = status frame
	if ( self.enabled and GetCVarBool(self.cvar) ) then
		self:Show();
		UnitPowerBarAltStatus_UpdateText(self);
	else
		self:Hide();
	end
end


---------------------------------
------- Counter Bar Code --------
---------------------------------
local COUNTERBAR_CHANGE_TIME = 0.2;
local COUNTERBAR_MAX_DIGIT = 7;
local COUNTERBAR_COLUMNS = 8;
local COUNTERBAR_ROWS = 2;
local COUNTERBAR_NUMBER_WIDTH = 16;
local COUNTERBAR_NUMBER_HEIGHT = 32;
local COUNTERBAR_LEADING_ZERO_INDEX = 11;
local COUNTERBAR_SLASH_INDEX = 10;



function CounterBar_SetUp(self)
	local useFactional, animNumbers, barType = UnitAlternatePowerCounterInfo(self.unit);

	local maxValue = UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX);
	CounterBar_SetStyle(self, useFactional, animNumbers, maxValue);
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:Show();
end


function CounterBar_SetStyle(self, useFactional, animNumbers, maxValue)
	
	local texturePath, r, g, b;
	--Set Textures
	texturePath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 5, self.timerIndex);
	for i=1,COUNTERBAR_MAX_DIGIT do
		local digitFrame = self["digit"..i];
		digitFrame.number:SetTexture(texturePath);
		digitFrame.number:SetVertexColor(r, g, b);
		digitFrame.numberMask:SetTexture(texturePath);
		digitFrame.numberMask:SetVertexColor(r, g, b);
		digitFrame:Show();
	end
	
	
	texturePath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 0, self.timerIndex);
	self.BG:SetTexture(texturePath, true, false);
	self.BG:SetVertexColor(r, g, b);
	self.BGL:SetTexture(texturePath);
	self.BGL:SetVertexColor(r, g, b);
	self.BGR:SetTexture(texturePath);
	self.BGR:SetVertexColor(r, g, b);
	self.artTop:SetTexture(texturePath);
	self.artTop:SetVertexColor(r, g, b);
	self.artBottom:SetTexture(texturePath);
	self.artBottom:SetVertexColor(r, g, b);
	
	--Set Initial State
	local maxDigits = ceil(log10(maxValue));
	local startIndex = 1;
	if useFactional then
		local count = maxValue;
		for i=1,maxDigits+1 do
			local digitFrame = self["digit"..i];
			local digit = CounterBar_GetDigit(count);
			count = floor(count/10);
			if digit == COUNTERBAR_LEADING_ZERO_INDEX then
				digit = COUNTERBAR_SLASH_INDEX;
			end
			local l,r,t,b = CounterBar_GetNumberCoord(digit);
			digitFrame.number:SetTexCoord(l,r,t,b);
			digitFrame.numberMask:Hide();
		end
		startIndex = startIndex + maxDigits + 1;
	end
	
	for i=startIndex+maxDigits,COUNTERBAR_MAX_DIGIT do
		self["digit"..i]:Hide();
	end
	
	self:SetWidth((startIndex+maxDigits-1)*COUNTERBAR_NUMBER_WIDTH);
	self.count = 0;
	self.maxValue = maxValue;
	self.fractional = useFactional;
	self.startIndex = startIndex;
	CounterBar_SetNumbers(self);
end


function CounterBar_GetNumberCoord(digit)
	local l,r,t,b;
	l = (1/COUNTERBAR_COLUMNS) * mod(digit,COUNTERBAR_COLUMNS);
	r = l + (1/COUNTERBAR_COLUMNS);
	t = (1/COUNTERBAR_ROWS) * floor(digit/COUNTERBAR_COLUMNS);
	b = t + (1/COUNTERBAR_ROWS);
	return l,r,t,b;
end


function CounterBar_GetDigit(count, isFirstDigit)
	local digit;
	if count > 0 or isFirstDigit then
		digit = mod(count, 10);
	else
		digit = COUNTERBAR_LEADING_ZERO_INDEX;
	end
	return digit;
end


function CounterBar_SetNumbers(self)
	local l,r,t,b;
	local count = self.count;
	for i=self.startIndex,COUNTERBAR_MAX_DIGIT do
		local digitFrame = self["digit"..i];
		local digit = CounterBar_GetDigit(count, i==1);
		count = floor(count/10);
		
		l,r,t,b = CounterBar_GetNumberCoord(digit);
		digitFrame.number:SetTexCoord(l,r,t,b);
		digitFrame.numberMask:Hide();
	end
end


function CounterBar_UpdateCount(self, newCount, ignoreAnim)
	local count1 = self.count;
	local count2 = min(newCount, self.maxValue);
	if count1 == count2 then
		return;
	end
	
	if ignoreAnim then
		self.count = newCount;
		CounterBar_SetNumbers(self)
		return;
	end
	
	
	self.animUp = count1 < count2;
	for i=self.startIndex,COUNTERBAR_MAX_DIGIT do
		local digitFrame = self["digit"..i];
		local digit1, digit2 = CounterBar_GetDigit(count1), CounterBar_GetDigit(count2);
		count1, count2 = floor(count1/10), floor(count2/10);
		if digit1 ~= digit2 then
			digitFrame.numberMask:SetHeight(0);
			digitFrame.animTime = COUNTERBAR_CHANGE_TIME;
			digitFrame.numberMask:ClearAllPoints()
			local l,r,t,b = CounterBar_GetNumberCoord(digit2);
			if self.animUp then
				digitFrame.numberMask:SetPoint("BOTTOM", 0 ,0);
				digitFrame.numberMask:SetTexCoord(l,r,t,t);
			else
				digitFrame.numberMask:SetPoint("TOP", 0 ,0);
				digitFrame.numberMask:SetTexCoord(l,r,b,b);
			end
			digitFrame.numberMask:Show();
		end
	end
	
	self.lastOnUpdate = self:GetScript("OnUpdate");
	self:SetScript("OnUpdate", CounterBar_OnUpdate);
	self.count = newCount;
end


function CounterBar_OnUpdate(self, elapsed)
	local updatingNumbers = false
	local l, t, _, b, r;

	for i=1,COUNTERBAR_MAX_DIGIT do
		local digitFrame = self["digit"..i];
		if digitFrame.animTime and digitFrame.animTime > 0 then
			local delta = (elapsed/COUNTERBAR_CHANGE_TIME) * (1/COUNTERBAR_ROWS);
			local deltaT, deltaB = 0, 0;
			if not self.animUp then
				deltaT = -delta;
				delta = -delta;
			else
				deltaB = delta;
			end
			
			--Number shift
			l, t, _, b, r = digitFrame.number:GetTexCoord();
			digitFrame.number:SetTexCoord(l,r,t+delta,b+delta);
			
			--Mask Shift
			l, t, _, b, r = digitFrame.numberMask:GetTexCoord();
			digitFrame.numberMask:SetTexCoord(l,r,t+deltaT,b+deltaB);
			digitFrame.numberMask:SetHeight(COUNTERBAR_NUMBER_HEIGHT * (1.0 - digitFrame.animTime/COUNTERBAR_CHANGE_TIME));
			
			digitFrame.animTime = digitFrame.animTime - elapsed
			updatingNumbers = true;
		end
	end
	
	if not updatingNumbers then
		self:SetScript("OnUpdate", self.lastOnUpdate); -- nil or PlayerBuffTimer_OnUpdate for timers
		CounterBar_SetNumbers(self)
	end
end




---------------------------------
-------- Buff Timer Code --------
---------------------------------
local PlayerBuffTimers = {}
local numBuffTimers = 0;


function PlayerBuffTimerManager_OnLoad(self)
	self:RegisterEvent("UNIT_POWER_BAR_TIMER_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.unit = "player"
end


function PlayerBuffTimerManager_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( arg1 == self.unit and event == "UNIT_POWER_BAR_TIMER_UPDATE" ) then
		PlayerBuffTimerManager_UpdateTimers(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		PlayerBuffTimerManager_UpdateTimers(self);
	end
end


function PlayerBuffTimerManager_GetTimer(barType)
	local timerFrame;
	local isCounter = barType == ALT_POWER_TYPE_COUNTER;
	
	for i=1,numBuffTimers do
		local frame = _G["BuffTimer"..i];
		if ( frame and not frame:IsShown() and frame.isCounter == isCounter ) then
			timerFrame = frame;
			break;
		end
	end
	
	if ( not timerFrame ) then
		numBuffTimers = numBuffTimers + 1;
		if ( isCounter ) then
			timerFrame = CreateFrame("Frame", "BuffTimer"..numBuffTimers, UIParent, "UnitPowerBarAltCounterTemplate");
			timerFrame.isCounter = true;
			
		else
			timerFrame = CreateFrame("Frame", "BuffTimer"..numBuffTimers, UIParent, "UnitPowerBarAltTemplate");
			timerFrame.isCounter = false;
			timerFrame.scale = 1.0;
		end
		timerFrame.unit = "player"
		timerFrame:SetScript("OnEvent", nil);
	end
	
	timerFrame:SetScript("OnUpdate", PlayerBuffTimer_OnUpdate);
	return timerFrame;
end


function PlayerBuffTimer_OnUpdate(self, elapsed)
	local timeLeft = self.timerExpiration - GetTime();
	if ( timeLeft <= 0 ) then
		self:SetScript("OnUpdate", nil);
		timeLeft = 0;
	end
	
	if ( self.isCounter ) then
		CounterBar_UpdateCount(self, floor(timeLeft));
	else
		UnitPowerBarAlt_SetPower(self, timeLeft, true);
	end
end


function PlayerBuffTimerManager_UpdateTimers(self)
	for _, timer in pairs(PlayerBuffTimers) do
		timer.flagForHide = true;
	end

	local index = 1;
	local anchorFrame = PlayerPowerBarAlt;
	local duration, expiration, barID, auraID = UnitPowerBarTimerInfo("player", index);
	while ( barID ) do
		if ( not PlayerBuffTimers[auraID] ) then -- this timer is new. add it
			local barType = GetAlternatePowerInfoByID(barID);
			local timer = PlayerBuffTimerManager_GetTimer(barType);
			timer.timerIndex = index;
			if ( timer.isCounter ) then
				CounterBar_SetStyle(timer, useFactional, animNumbers, duration);
			else
				UnitPowerBarAlt_TearDown(timer);
				UnitPowerBarAlt_SetUp(timer, barID);
				UnitPowerBarAlt_SetMinMaxPower(timer, 0, duration);
				UnitPowerBarAlt_SetPower(timer, duration, true);
			end
			
			timer.timerExpiration = expiration;
			timer:Show();
			PlayerBuffTimers[auraID] = timer;
		end

		
		PlayerBuffTimers[auraID]:SetPoint("BOTTOM", anchorFrame, "TOP", 0, 32);
		anchorFrame = PlayerBuffTimers[auraID];
		PlayerBuffTimers[auraID].flagForHide = false;
		PlayerBuffTimers[auraID].timerIndex = index;
		index = index + 1;
		duration, expiration, barID, auraID = UnitPowerBarTimerInfo("player", index);
	end
	
	for auraID, timer in pairs(PlayerBuffTimers) do
		if ( timer.flagForHide ) then
			PlayerBuffTimers[auraID] = nil;
			if ( not timer.isCounter ) then
				UnitPowerBarAlt_TearDown(timer);
			end
			timer:Hide();
		end
	end
end



