ALTERNATE_POWER_INDEX = 10;

ALT_POWER_TYPE_HORIZONTAL = 0;
ALT_POWER_TYPE_VERTICAL 	= 1;
ALT_POWER_TYPE_CIRCULAR		= 2;
ALT_POWER_TYPE_PILL				= 3;

local altPowerBarTextures = {
	frame = 0,
	background = 1,
	fill = 2,
	spark = 3,
	flash = 4,
}

ALT_POWER_TEX_FRAME				= 0;
ALT_POWER_TEX_BACKGROUND	= 1;
ALT_POWER_TEX_FILL					= 2;
ALT_POWER_TEX_SPARK				= 3;
ALT_POWER_TEX_FLASH				= 4;

ALT_POWER_BAR_PLAYER_SIZES = {	--Everything else is scaled off of this
	[ALT_POWER_TYPE_HORIZONTAL]	= {x = 256, y = 64},
	[ALT_POWER_TYPE_VERTICAL]		= {x = 64, y = 128},
	[ALT_POWER_TYPE_CIRCULAR]		= {x = 128, y = 128},
	[ALT_POWER_TYPE_PILL]				= {x = 32, y = 64},	--This is the size of a single pill.
}

function UnitPowerBarAlt_Initialize(self, unit, scale, updateAllEvent)
	self.unit = unit;
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
	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip:SetText(self.powerName, 1, 1, 1);
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1);
	GameTooltip:Show();
end

function UnitPowerBarAlt_OnLeave(self)
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
			local currentPower = UnitPower(self.unit, ALTERNATE_POWER_INDEX);
			UnitPowerBarAlt_SetPower(self, currentPower);
		end
	elseif ( event == "UNIT_MAXPOWER" ) then
		if ( arg1 == self.unit and arg2 == "ALTERNATE" ) then
			local barType, minPower = UnitAlternatePowerInfo(self.unit);
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
function UnitPowerBarAlt_OnUpdate(self, elapsed)
	if ( self.smooth and self.value ~= self.displayedValue ) then
		local minPerSecond = max(minPerSecond, 1/self.range);	--Make sure we're moving at least 1 unit/second (will only matter if our maximum power is 3 or less);
		
		local diff = self.displayedValue - self.value;
		local diffRatio = diff / self.range;
		local change = self.range * ((minPerSecond/abs(diffRatio) + maxPerSecond - minPerSecond) * diffRatio) * elapsed;
		if ( abs(change) > abs(diff) or abs(diffRatio) < 0.01 ) then
			UnitPowerBarAlt_SetDisplayedPower(self, self.value);
		else
			UnitPowerBarAlt_SetDisplayedPower(self, self.displayedValue - change);
		end
	end
end

function UnitPowerBarAlt_ApplyTextures(frame, unit)
	for textureName, textureIndex in pairs(altPowerBarTextures) do
		local texture = frame[textureName];
		local texturePath, r, g, b = UnitAlternatePowerTextureInfo(unit, textureIndex);
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
	for i=1, #self.pillFrames do
		self.pillFrames[i]:Hide();
	end
end

function UnitPowerBarAlt_SetUp(self)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip = UnitAlternatePowerInfo(self.unit);
	self.startInset = startInset;
	self.endInset = endInset;
	self.smooth = smooth;
	self.powerName = powerName;
	self.powerTooltip = powerTooltip;
	
	local sizeInfo = ALT_POWER_BAR_PLAYER_SIZES[barType];
	self:SetSize(sizeInfo.x * self.scale, sizeInfo.y * self.scale);
	
	UnitPowerBarAlt_HideTextures(self);	--It's up to the SetUp functions to show textures they need.
	UnitPowerBarAlt_HidePills(self);
	
	if ( barType == ALT_POWER_TYPE_HORIZONTAL ) then
		UnitPowerBarAlt_Horizontal_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_VERTICAL ) then
		UnitPowerBarAlt_Vertical_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_CIRCULAR ) then
		UnitPowerBarAlt_Circular_SetUp(self);
	elseif ( barType == ALT_POWER_TYPE_PILL ) then
		UnitPowerBarAlt_Pill_SetUp(self);
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
	
	self:RegisterEvent("UNIT_POWER");
	self:RegisterEvent("UNIT_MAXPOWER");
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
		
		local maxPower = UnitPowerMax(self.unit, ALTERNATE_POWER_INDEX);
		UnitPowerBarAlt_SetMinMaxPower(self, minPower, maxPower);
		
		local currentPower = UnitPower(self.unit, ALTERNATE_POWER_INDEX);
		UnitPowerBarAlt_SetPower(self, currentPower, true);
		
		self:Show();
	else
		UnitPowerBarAlt_TearDown(self);
		self:Hide();
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