

local textureList =  {
	"_BG",
	"EndCapL",
	"EndCapR",
	"_Border",
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
local xpBarTextureList = {
	"XpMid",
	"XpL",
	"XpR",
}

local MAX_ALT_SPELLBUTTONS = 6;

OverrideActionBarMixin = {};

function OverrideActionBarMixin:OnLoad()
	-- Overriding is shown so that it returns false if the frame is animating out as well
	self.IsShownBase = self.IsShown;
	self.IsShown = self.IsShownOverride;

	--Setup the XP bar
	local divWidth = self.xpBar.XpMid:GetWidth()/19;
	local xpos = 6;	
	for i=1,19 do
		local texture = self.xpBar:CreateTexture("OverrideActionBarXpDiv"..i, "ARTWORK", nil, 2);
		texture:SetSize(7, 14);
		texture:SetTexCoord(0.2773438, 0.2910156, 0.390625, 0.4179688);
		self.xpBar["XpDiv"..i] = texture;
		xpBarTextureList[#xpBarTextureList + 1] = "XpDiv"..i;
		xpos = xpos + divWidth;
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
	self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player");
	self:RegisterUnitEvent("UNIT_ENTERING_VEHICLE", "player");
	self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player");
end


function OverrideActionBarMixin:OnEvent(event, ...)
	local arg1 = ...;
	if ( event == "VEHICLE_ANGLE_UPDATE" ) then
		self:SetPitchValue(arg1);
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		self:UpdateXpBar(arg1);
	elseif ( event == "PLAYER_XP_UPDATE" ) then
		self:UpdateXpBar();
	elseif ( event == "UNIT_ENTERED_VEHICLE" ) then
		self:UpdateSkin();
	elseif ( event == "UNIT_ENTERING_VEHICLE" ) then
		self.HasExit, self.HasPitch = select(6, ...);
	elseif ( event == "UNIT_EXITED_VEHICLE") then
		self.HasExit = nil;
		self.HasPitch = nil;
		if GetOverrideBarSkin() then
			self:CalcSize();
		end
	end
end

function OverrideActionBarMixin:OnShow()
	if EditModeManagerFrame:IsEditModeActive() then
		HideUIPanel(EditModeManagerFrame);
	end

	self:UpdateMicroButtons();

	UIParentBottomManagedFrameContainer:UpdateManagedFramesAlphaState();
	UIParentRightManagedFrameContainer:UpdateManagedFramesAlphaState();

	EditModeManagerFrame:BlockEnteringEditMode(self);
	EditModeManagerFrame:UpdateBottomActionBarPositions();
end

function OverrideActionBarMixin:OnHide()
	UIParentBottomManagedFrameContainer:UpdateManagedFramesAlphaState();
	UIParentRightManagedFrameContainer:UpdateManagedFramesAlphaState();

	UIParent_ManageFramePositions();

	EditModeManagerFrame:UnblockEnteringEditMode(self);
end

function OverrideActionBarMixin:UpdateMicroButtons()
	if ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_OVERRIDE then
		local anchorX, anchorY = self:GetMicroButtonAnchor();
		OverrideMicroMenuPosition(self, "BOTTOMLEFT", self, "BOTTOMLEFT", anchorX, anchorY, true);
	end
end

function OverrideActionBarMixin:UpdateSkin()
	-- For now, a vehicle has precedence over override bars (hopefully designers make it so these never conflict)
	if ( HasVehicleActionBar() ) then
		self:Setup(UnitVehicleSkin("player"), GetVehicleBarIndex());
		self:UpdateMicroButtons();
	else
		self:Setup(GetOverrideBarSkin(), GetOverrideBarIndex());
	end
end

function OverrideActionBarMixin:SetSkin(skin)
	local textureFile = skin;
	for _,tex in pairs(textureList) do
		self[tex]:SetTexture(textureFile, strsub(tex, 1, 1) == "_", strsub(tex, 1, 1) == "|");
	end
	for _,tex in pairs(xpBarTextureList) do
		self.xpBar[tex]:SetTexture(textureFile, strsub(tex, 1, 1) == "_", strsub(tex, 1, 1) == "|");
	end
end


function OverrideActionBarMixin:CalcSize()
	local width, xpWidth, anchor, buttonAnchor;
	self.pitchFrame:Hide();
	self.leaveFrame:Hide();

	if self.HasExit and self.HasPitch then
		width, xpWidth, anchor, buttonAnchor = 1020, 580, 103, -234;
		self.pitchFrame:Show();
		self.leaveFrame:Show();
	elseif self.HasPitch then
		width, xpWidth, anchor, buttonAnchor = 945, 500, 145, -192;
		self.pitchFrame:Show();
	elseif self.HasExit then
		width, xpWidth, anchor, buttonAnchor = 930, 490, 60, -277;
		self.leaveFrame:Show();
	else
		width, xpWidth, anchor, buttonAnchor = 860, 460, 100, -237;
	end

	self:SetWidth(width);
	self.xpBar.XpMid:SetWidth(xpWidth);
	self.xpBar:SetWidth(xpWidth+16);
	self.Divider2:SetPoint("BOTTOM", anchor, 0);
	self.SpellButton1:SetPoint("BOTTOM", buttonAnchor, 17);

	local divWidth = self.xpBar.XpMid:GetWidth()/19;
	local xpos = divWidth-15;
	for i=1,19 do
		local texture = self.xpBar["XpDiv"..i];
		texture:SetPoint("LEFT", self.xpBar.XpMid, "LEFT", floor(xpos), 10);
		xpos = xpos + divWidth;
	end
	self:UpdateXpBar();

	UnitFrameHealthBar_Update(OverrideActionBarHealthBar, "vehicle");
	UnitFrameManaBar_Update(OverrideActionBarPowerBar, "vehicle");
end


function OverrideActionBarMixin:GetMicroButtonAnchor()
	local x, y = 648, 14;
	if self.HasExit and self.HasPitch then
		x = 746;
	elseif self.HasPitch then
		x = 749;
	elseif self.HasExit then
		x = 643;
	end
	return x,y
end


function OverrideActionBarMixin:Leave()
	self:UnregisterEvent("PLAYER_LEVEL_UP");
	self:UnregisterEvent("PLAYER_XP_UPDATE");
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


function OverrideActionBarMixin:SetPitchValue(pitch)
	self.pitchFrame.PitchMarker:SetPoint("CENTER", self.pitchFrame.PitchOverlay, "BOTTOM", 0, pitch * (self.pitchFrame.PitchOverlay:GetHeight() - 35) + 14);
end

function OverrideActionBarMixin:Setup(skin, barIndex)
	self:SetSkin(skin);
	self:CalcSize();
	self:SetAttribute("actionpage", barIndex);

	for k=1,MAX_ALT_SPELLBUTTONS do
		local button = self["SpellButton"..k];
		button:UpdateAction();
		button:Update();
		local _, spellID = GetActionInfo(button.action);
		if spellID and spellID > 0 then
			button:SetAttribute("statehidden", false);
			button:Show();
		else
			button:SetAttribute("statehidden", true);
			button:Hide();
		end
	end

	local shouldShowHealthBar;
	local shouldShowManaBar;
	--vehicles always show both bars, override bars check their flags
	if HasVehicleActionBar() then
		shouldShowHealthBar = true;
		shouldShowManaBar = true;
	else
		shouldShowHealthBar = C_ActionBar.ShouldOverrideBarShowHealthBar();
		shouldShowManaBar = C_ActionBar.ShouldOverrideBarShowManaBar();
	end

	if shouldShowHealthBar then
		OverrideActionBarHealthBar:Show();
	else
		OverrideActionBarHealthBar:Hide();
	end

	if shouldShowManaBar then
		OverrideActionBarPowerBar:Show();
	else
		OverrideActionBarPowerBar:Hide();
	end

	self:RegisterEvent("PLAYER_LEVEL_UP");	
	self:RegisterEvent("PLAYER_XP_UPDATE");

	self:UpdateXpBar();
end

function OverrideActionBarMixin:UpdateXpBar(newLevel)
	local level = newLevel or UnitLevel("player");
	if ( IsLevelAtEffectiveMaxLevel(level) or IsXPUserDisabled() ) then
		self.xpBar:Hide();
	else
		local currXP = UnitXP("player");
		local nextXP = UnitXPMax("player");
		self.xpBar:Show();
		self.xpBar:SetMinMaxValues(min(0, currXP), nextXP);
		self.xpBar:SetValue(currXP);
	end
end

function OverrideActionBarMixin:IsShownOverride()
	return self:IsShownBase() and (not self.slideOut:IsPlaying() or self.slideOut:IsReverse());
end
