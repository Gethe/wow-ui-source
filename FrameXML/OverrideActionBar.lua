

local textureList =  {
	"_BG",
	"EndCapL",
	"EndCapR",
	"_Boader",
	"Divider1",
	"Divider2",
	"Divider3",
	"ExitBG",
	"MicroBGL",
	"MicroBGR",
	"_MicroBGMid",
	"ButtonBGL",
	"ButtonBGR",
	"_ButtonBGMid",
	"_XpMid",
	"XpL",
	"XpR",
	"PitchOverlay",
	"PitchButtonBG",
	"PitchBG",
	"PitchMarker",
	"PitchUpUp",
	"PitchUpDown",
	"PitchUpHighlight",
	"PitchDownUp",
	"PitchDownDown",
	"PitchDownHighlight",
	"LeaveUp",
	"LeaveDown",
	"LeaveHighlight",
	"HealthBarBG",
	"HealthBarOverlay",
	"PowerBarBG",
	"PowerBarOverlay",
};

local MAX_ALT_SPELLBUTTONS = 6;

function OverrideActionBar_OnLoad(self)

	--Setup the XP bar
	local divWidth = self._XpMid:GetWidth()/19;
	local xpos = 6;	
	for i=1,19 do
		local texture = self:CreateTexture("OverrideActionBarXpDiv"..i, "BACKGROUND", nil, 2);
		texture:SetSize(7, 14);
		texture:SetTexCoord(0.2773438, 0.2910156, 0.390625, 0.4179688);
		self["XpDiv"..i] = texture;
		textureList[#textureList + 1] = "XpDiv"..i;
		texture:SetPoint("LEFT", self.XpMid, "LEFT", floor(xpos), 10);
		xpos = xpos + divWidth
	end
	
	--Add Leave Button Textures
	self["LeaveUp"] = self.LeaveButton:GetNormalTexture();
	self["LeaveDown"] = self.LeaveButton:GetPushedTexture();
	self["LeaveHighlight"] = self.LeaveButton:GetHighlightTexture();
	
	--Add PitchUp button Textures
	self["PitchUpUp"] = self.PitchUpButton:GetNormalTexture();
	self["PitchUpDown"] = self.PitchUpButton:GetPushedTexture();
	self["PitchUpHighlight"] = self.PitchUpButton:GetHighlightTexture();
	
	--Add PitchDown button Textures
	self["PitchDownUp"] = self.PitchDownButton:GetNormalTexture();
	self["PitchDownDown"] = self.PitchDownButton:GetPushedTexture();
	self["PitchDownHighlight"] = self.PitchDownButton:GetHighlightTexture();
	self:RegisterEvent("VEHICLE_ANGLE_UPDATE");
end


function OverrideActionBar_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "VEHICLE_ANGLE_UPDATE" ) then
		OverrideActionBar_SetPitchValue(arg1);
	end
end

function OverrideActionBar_SetSkin(skin)
	local textureFile = skin;
	for _,tex in pairs(textureList) do
		OverrideActionBar[tex]:SetTexture(textureFile, strsub(tex, 1, 1) == "_", strsub(tex, 1, 1) == "|");
	end
end


function OverrideActionBar_CalcSize()
	local width, xpWidth, anchor, buttonAnchor;
	local hasPitch = IsVehicleAimAngleAdjustable();
	local hasExit =  CanExitVehicle();
	OverrideActionBar.pitchFrame:Hide();
	OverrideActionBar.leaveFrame:Hide();
	
	if hasExit and hasPitch then
		width, xpWidth, anchor, buttonAnchor = 1020, 580, 103, -234;
		OverrideActionBar.pitchFrame:Show();
		OverrideActionBar.leaveFrame:Show();
	elseif hasPitch then
		width, xpWidth, anchor, buttonAnchor = 945, 500, 145, -192;
		OverrideActionBar.pitchFrame:Show();
	elseif hasExit then
		width, xpWidth, anchor, buttonAnchor = 930, 490, 60, -277;
		OverrideActionBar.leaveFrame:Show();
	else
		width, xpWidth, anchor, buttonAnchor = 860, 460, 100, -237;
	end
	
	OverrideActionBar:SetWidth(width);
	OverrideActionBar._XpMid:SetWidth(xpWidth);
	OverrideActionBar.xpBar:SetWidth(xpWidth+16);
	OverrideActionBar.Divider2:SetPoint("BOTTOM", anchor, 0);
	OverrideActionBar.SpellButton1:SetPoint("BOTTOM", buttonAnchor, 17);

	
	local divWidth = OverrideActionBar._XpMid:GetWidth()/19;
	local xpos = divWidth-15;	
	for i=1,19 do
		local texture = OverrideActionBar["XpDiv"..i];
		texture:SetPoint("LEFT", OverrideActionBar._XpMid, "LEFT", floor(xpos), 10);
		xpos = xpos + divWidth;
	end
	ExpBar_Update();
	
	UnitFrameHealthBar_Update(OverrideActionBarHealthBar, "vehicle");
	UnitFrameManaBar_Update(OverrideActionBarPowerBar, "vehicle");
end


function OverrideActionBar_GetMicroButtonAnchor()
	local hasExit, hasPitch = OverrideActionBar.leaveFrame:IsShown(),  OverrideActionBar.pitchFrame:IsShown();
	local x, y = 544 , 41;
	if hasExit and hasPitch then
		x = 628;
	elseif hasPitch then
		x = 632;
	elseif hasExit then
		x = 540;
	end
	return x,y
end


function OverrideActionBar_Leave(self)
	VehicleExit();
end


function OverrideActionBar_StatusBars_ShowTooltip(self)
	if ( GetMouseFocus() == self ) then
		local value = self:GetValue();
		local _, valueMax = self:GetMinMaxValues();
		if ( valueMax > 0 ) then
			local text = format("%s/%s (%s%%)", BreakUpLargeNumbers(value), BreakUpLargeNumbers(valueMax), tostring(math.ceil((value / valueMax) * 100)));
			GameTooltip:SetOwner(self, self.tooltipAnchorPoint);
			if ( self.prefix ) then
				GameTooltip:AddLine(self.prefix);
			end
			GameTooltip:AddLine(text, 1.0,1.0,1.0 );
			GameTooltip:Show();
		end
	end
end


function OverrideActionBar_SetPitchValue(pitch)
	OverrideActionBar.pitchFrame.PitchMarker:SetPoint("CENTER", OverrideActionBar.pitchFrame.PitchOverlay, "BOTTOM", 0, pitch * (OverrideActionBar.pitchFrame.PitchOverlay:GetHeight() - 35) + 14);
end


function OverrideActionBar_Setup(skin, barIndex)
	OverrideActionBar_SetSkin(skin);
	OverrideActionBar_CalcSize();
	OverrideActionBar:SetAttribute("actionpage", barIndex);
	
	for k=1,MAX_ALT_SPELLBUTTONS do
		local button = OverrideActionBar["SpellButton"..k];
		ActionButton_UpdateAction(button);
		local _, spellID = GetActionInfo(button.action);
		if spellID and spellID > 0 then
			button:SetAttribute("statehidden", false);
			button:Show();
		else
			button:SetAttribute("statehidden", true);
			button:Hide();
		end
	end
	
	if HasVehicleActionBar() then
		OverrideActionBarHealthBar:Show();
		OverrideActionBarPowerBar:Show();
	else
		OverrideActionBarHealthBar:Hide();
		OverrideActionBarPowerBar:Hide();
	end
	
	ExpBar_Update();
end

