MAX_FOCUS_DEBUFFS = 8;

function FocusFrame_OnLoad (self)
	self.statusCounter = 0;
	self.statusSign = -1;
	self.unitHPPercent = 1;

	FocusFrame.debuffTotal = 0;

	self:RegisterForDrag("LeftButton");
	FocusFrame_Update(self);
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterEvent("UNIT_HEALTH");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_FACTION");
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");

	local frameLevel = FocusFrameTextureFrame:GetFrameLevel();
	FocusFrameHealthBar:SetFrameLevel(frameLevel-1);
	FocusFrameManaBar:SetFrameLevel(frameLevel-1);
	FocusFrameSpellBar:SetFrameLevel(frameLevel-1);

	local showmenu = function()
		ToggleDropDownMenu(1, nil, FocusFrameDropDown, "FocusFrame", 120, 10);
	end
	SecureUnitButton_OnLoad(self, "focus", showmenu);
end

function FocusFrame_Update (self)
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not UnitExists("focus") ) then
		self:Hide();
	else
		self:Show();

		-- Moved here to avoid taint from functions below
		TargetofFocus_Update();

		UnitFrame_Update(self);
		FocusFrame_CheckFaction(self);
		FocusFrame_UpdateAuras(self);
		FocusPortrait:SetAlpha(1.0);
	end
end

function FocusFrame_OnEvent (self, event, ...)
	UnitFrame_OnEvent(self, event, ...);

	local arg1 = ...;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		FocusFrame_Update(self);
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		-- Moved here to avoid taint from functions below
		FocusFrame_Update(self);
		FocusFrame_UpdateRaidTargetIcon(self);
		CloseDropDownMenus();

		if ( UnitExists("focus") ) then
			if ( UnitIsEnemy("focus", "player") ) then
				PlaySound("igCreatureAggroSelect");
			elseif ( UnitIsFriend("player", "focus") ) then
				PlaySound("igCharacterNPCSelect");
			else
				PlaySound("igCreatureNeutralSelect");
			end
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( arg1 == "focus" or arg1 == "player" ) then
			FocusFrame_CheckFaction(self);
		end
	elseif ( event == "UNIT_AURA" ) then
		if ( arg1 == "focus" ) then
			FocusFrame_UpdateAuras(self);
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		TargetofFocus_Update();
		FocusFrame_CheckFaction(self);
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		FocusFrame_UpdateRaidTargetIcon(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		FocusFrame_SetFullSize(GetCVarBool("fullSizeFocusFrame"));
	end
end

function FocusFrame_OnHide (self)
	PlaySound("INTERFACESOUND_LOSTTARGETUNIT");
	CloseDropDownMenus();
end

function FocusFrame_CheckFaction (self)
	if ( not UnitPlayerControlled("focus") and UnitIsTapped("focus") and not UnitIsTappedByPlayer("focus") and not UnitIsTappedByAllThreatList("focus") ) then
		FocusFrameNameBackground:SetVertexColor(0.5, 0.5, 0.5);
		FocusPortrait:SetVertexColor(0.5, 0.5, 0.5);
	else
		FocusFrameNameBackground:SetVertexColor(UnitSelectionColor("focus"));
		FocusPortrait:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function FocusFrame_OnUpdate (self, elapsed)
	if ( TargetofFocusFrame:IsShown() ~= UnitExists("focus-target") ) then
		TargetofFocus_Update();
	end
end

function FocusFrame_UpdateAuras (self)
	RefreshDebuffs(self, "focus", MAX_FOCUS_DEBUFFS);
end

function FocusFrame_HealthUpdate (self, elapsed, unit)
	if ( UnitIsPlayer(unit) ) then
		if ( (self.unitHPPercent > 0) and (self.unitHPPercent <= 0.2) ) then
			local alpha = 255;
			local counter = self.statusCounter + elapsed;
			local sign    = self.statusSign;
	
			if ( counter > 0.5 ) then
				sign = -sign;
				self.statusSign = sign;
			end
			counter = mod(counter, 0.5);
			self.statusCounter = counter;
	
			if ( sign == 1 ) then
				alpha = (127  + (counter * 256)) / 255;
			else
				alpha = (255 - (counter * 256)) / 255;
			end
			FocusPortrait:SetAlpha(alpha);
		end
	end
end

function FocusHealthCheck (self)
	if ( UnitIsPlayer("focus") ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = self:GetMinMaxValues();
		unitCurrHP = self:GetValue();
		self:GetParent().unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("focus") ) then
			FocusPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("focus") ) then
			FocusPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (self:GetParent().unitHPPercent > 0) and (self:GetParent().unitHPPercent <= 0.2) ) then
			FocusPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			FocusPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end

function FocusFrameDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, FocusFrameDropDown_Initialize, "MENU");
end

function FocusFrameDropDown_Initialize (self)
	UnitPopup_ShowMenu(self, "FOCUS", "focus", SET_FOCUS);
end

function FocusFrame_UpdateRaidTargetIcon (self)
	local index = GetRaidTargetIndex("focus");
	if ( index ) then
		SetRaidTargetIconTexture(FocusRaidTargetIcon, index);
		FocusRaidTargetIcon:Show();
	else
		FocusRaidTargetIcon:Hide();
	end
end

function TargetofFocus_OnLoad (self)
	local frameLevel = FocusFrame:GetFrameLevel();
	TargetofFocusFrame:SetFrameLevel(frameLevel-1);

	UnitFrame_Initialize(self, "focus-target", TargetofFocusName, TargetofFocusPortrait,
		TargetofFocusHealthBar, TargetofFocusHealthBarText,
		TargetofFocusManaBar, TargetofFocusFrameManaBarText,
		TargetofFocusThreatIndicator, "player");
	SetTextStatusBarTextZeroText(TargetofFocusHealthBar, DEAD);
	self:RegisterEvent("UNIT_AURA");

	SecureUnitButton_OnLoad(self, "focus-target");
end

function TargetofFocus_Update (self, elapsed)
	if ( not self ) then
		self = TargetofFocusFrame;
	end

	local show;
	if ( SHOW_TARGET_OF_TARGET == "1" and UnitExists("focus") and UnitExists("focus-target") and --[[( not UnitIsUnit(PlayerFrame.unit, "focus") ) and ]]( UnitHealth("focus") > 0 ) ) then
		if ( ( SHOW_TARGET_OF_TARGET_STATE == "5" ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "4" and ( (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "3" and ( (GetNumRaidMembers() == 0) and (GetNumPartyMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "2" and ( (GetNumPartyMembers() > 0) and (GetNumRaidMembers() == 0) ) ) or
		     ( SHOW_TARGET_OF_TARGET_STATE == "1" and ( GetNumRaidMembers() > 0 ) ) ) then
			show = true;
		end
	end

	if ( show ) then
		if ( not TargetofFocusFrame:IsShown() ) then
			TargetofFocusFrame:Show();
			Focus_Spellbar_AdjustPosition();
		end
		UnitFrame_Update(self);
		TargetofFocus_CheckDead();
		TargetofFocusHealthCheck();
		RefreshDebuffs(TargetofFocusFrame, "focus-target");
	else
		if ( TargetofFocusFrame:IsShown() ) then
			TargetofFocusFrame:Hide();
			Focus_Spellbar_AdjustPosition();
		end
	end
end

function TargetofFocus_CheckDead ()
	if ( (UnitHealth("focus-target") <= 0) and UnitIsConnected("focus-target") ) then
		TargetofFocusBackground:SetAlpha(0.9);
		TargetofFocusDeadText:Show();
	else
		TargetofFocusBackground:SetAlpha(1);
		TargetofFocusDeadText:Hide();
	end
end

function TargetofFocusHealthCheck ()
	if ( UnitIsPlayer("focus-target") ) then
		local unitHPMin, unitHPMax, unitCurrHP;
		unitHPMin, unitHPMax = TargetofFocusHealthBar:GetMinMaxValues();
		unitCurrHP = TargetofFocusHealthBar:GetValue();
		TargetofFocusFrame.unitHPPercent = unitCurrHP / unitHPMax;
		if ( UnitIsDead("focus-target") ) then
			TargetofFocusPortrait:SetVertexColor(0.35, 0.35, 0.35, 1.0);
		elseif ( UnitIsGhost("focus-target") ) then
			TargetofFocusPortrait:SetVertexColor(0.2, 0.2, 0.75, 1.0);
		elseif ( (TargetofFocusFrame.unitHPPercent > 0) and (TargetofFocusFrame.unitHPPercent <= 0.2) ) then
			TargetofFocusPortrait:SetVertexColor(1.0, 0.0, 0.0);
		else
			TargetofFocusPortrait:SetVertexColor(1.0, 1.0, 1.0, 1.0);
		end
	end
end


function SetFocusSpellbarAspect()
	local frameText = _G[FocusFrameSpellBar:GetName().."Text"];
	if ( frameText ) then
		frameText:SetFontObject(SystemFont_Shadow_Small);
		frameText:ClearAllPoints();
		frameText:SetPoint("TOP", FocusFrameSpellBar, "TOP", 0, 4);
	end

	local frameBorder = _G[FocusFrameSpellBar:GetName().."Border"];
	if ( frameBorder ) then
		frameBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
		frameBorder:SetWidth(177);
		frameBorder:SetHeight(49);
		frameBorder:ClearAllPoints();
		frameBorder:SetPoint("TOP", FocusFrameSpellBar, "TOP", 0, 20);
	end

	local frameBorderShield = _G[FocusFrameSpellBar:GetName().."BorderShield"];
	if ( frameBorderShield ) then
		--frameBorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-FocusShield");
		frameBorderShield:SetWidth(177);
		frameBorderShield:SetHeight(49);
		frameBorderShield:ClearAllPoints();
		frameBorderShield:SetPoint("TOP", FocusFrameSpellBar, "TOP", -6, 20);
	end
	
	local frameFlash = _G[FocusFrameSpellBar:GetName().."Flash"];
	if ( frameFlash ) then
		frameFlash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
		frameFlash:SetWidth(177);
		frameFlash:SetHeight(49);
		frameFlash:ClearAllPoints();
		frameFlash:SetPoint("TOP", FocusFrameSpellBar, "TOP", -2, 20);
	end
end

function Focus_Spellbar_OnLoad (self)
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	
	CastingBarFrame_OnLoad(self, "focus", false, false);

	local barIcon = _G[self:GetName().."Icon"];
	barIcon:Show();
	barIcon:ClearAllPoints();
	barIcon:SetPoint("RIGHT", self:GetName(), "LEFT", -5, 0);

	SetFocusSpellbarAspect();
	self.showShield = true;
	
	_G[self:GetName().."Text"]:SetWidth(130);
	-- check to see if the castbar should be shown
	if ( GetCVar("showTargetCastbar") == "0") then
		self.showCastbar = false;	
	end
end

function Focus_Spellbar_OnEvent (self, event, ...)
	local arg1 = ...
	
	--	Check for target specific events
	if ( (event == "VARIABLES_LOADED") or ((event == "CVAR_UPDATE") and (arg1 == "SHOW_TARGET_CASTBAR")) ) then
		if ( GetCVar("showTargetCastbar") == "0") then
			self.showCastbar = false;
		else
			self.showCastbar = true;
		end
		
		if ( not self.showCastbar ) then
			self:Hide();
		elseif ( self.casting or self.channeling ) then
			self:Show();
		end
		return;
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		-- check if the new target is casting a spell
		local nameChannel  = UnitChannelInfo(self.unit);
		local nameSpell  = UnitCastingInfo(self.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = "focus";
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = "focus";
		else
			self.casting = nil;
			self.channeling = nil;
			self:SetMinMaxValues(0, 0);
			self:SetValue(0);
			self:Hide();
			return;
		end
		-- The position depends on the classification of the target
		Focus_Spellbar_AdjustPosition();
	end
	CastingBarFrame_OnEvent(self, event, arg1, select(2, ...));
end

function Focus_Spellbar_AdjustPosition ()
	local yPos = 3;
	if ( FocusFrame.debuffTotal > 4 ) then
		yPos = 25;
	elseif ( TargetofFocusFrame:IsShown() ) then
		yPos = 30;
	elseif ( FocusFrame.debuffTotal > 0 ) then
		yPos = 15
	end
	FocusFrameSpellBar:SetPoint("BOTTOM", "FocusFrame", "BOTTOM", 20, -yPos);
end

FOCUS_FRAME_LOCKED = true;
function FocusFrame_IsLocked()
	return FOCUS_FRAME_LOCKED;
end
function FocusFrame_SetLock(locked)
	FOCUS_FRAME_LOCKED = locked;
end

function FocusFrame_OnDragStart(self, button)
	FOCUS_FRAME_MOVING = false;
	if ( not FOCUS_FRAME_LOCKED ) then
		local cursorX, cursorY = GetCursorPosition();
		self:SetFrameStrata("DIALOG");
		self:StartMoving();
		FOCUS_FRAME_MOVING = true;
	end
end

function FocusFrame_OnDragStop(self)
	if ( not FOCUS_FRAME_LOCKED and FOCUS_FRAME_MOVING ) then
		self:StopMovingOrSizing();
		self:SetFrameStrata("BACKGROUND");
		ValidateFramePosition(self, 25);
		FOCUS_FRAME_MOVING = false;
	end
end


--------Support for a full-size Focus Frame---------
local dimsAndAnchors = {setDims = true, numAnchorsToCopy = 1};	--This way we don't have to have duplicate tables...
local justAnchors = { setDims = false, numAnchorsToCopy = 1};
local framesToDuplicate = {
	["Frame"] = {
		setDims = true,
		numAnchorsToCopy = 0,
	},
	["FrameFlash"] = dimsAndAnchors,
	["FrameBackground"] = dimsAndAnchors,
	["FrameNameBackground"] = dimsAndAnchors,
	["Portrait"] = dimsAndAnchors,
	["Name"] = dimsAndAnchors,
	["FrameHealthBarText"] = justAnchors,
	["FrameManaBarText"] = justAnchors,
	["RaidTargetIcon"] = dimsAndAnchors,
	["FrameHealthBar"] = dimsAndAnchors,
	["FrameManaBar"] = dimsAndAnchors,
	["FrameNumericalThreat"] = dimsAndAnchors,
}
-- temp fixes to focus frame
TargetPortrait = TargetFramePortrait;
TargetFrameManaBarText = TargetFrameTextureFrameManaBarText;
TargetFrameHealthBarText = TargetFrameTextureFrameHealthBarText;
TargetRaidTargetIcon = TargetFrameTextureFrameRaidTargetIcon;
TargetName = TargetFrameTextureFrameName;

function FocusFrame_SetFullSize(fullSize)
	if ( fullSize and not FocusFrame.fullSize) then	--It copies the TargetFrame. That way we don't have to explicitly maintain a bunch of alternate coordinates.
		FocusFrame.fullSize = true;
		for name, value in pairs(framesToDuplicate) do
			local frame = _G["Focus"..name];
			local equivFrame = _G["Target"..name];
			if ( value.setDims ) then
				--Save off the old dimensions so that we can set them back later (the or stops it from overwriting if there are already values)
				frame.oldHeight = frame.oldHeight or frame:GetHeight();
				frame.oldWidth = frame.oldWidth or frame:GetWidth();
				
				frame:SetHeight(equivFrame:GetHeight());
				frame:SetWidth(equivFrame:GetWidth());
			end
			if ( value.numAnchorsToCopy > 0 ) then
				frame.oldAnchors = frame.oldAnchors or {};
				for i=1, frame:GetNumPoints() do
					frame.oldAnchors[i] = frame.oldAnchors[i] or {frame:GetPoint(i)};
				end
				frame:ClearAllPoints();
				for i=1, value.numAnchorsToCopy do
					local point, relativeTo, relativePoint, xOffset, yOffset = equivFrame:GetPoint(i);
					relativeTo = string.gsub(relativeTo:GetName(), "Target", "Focus", 1);
					frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
				end
			end
		end
		
		for i=1, MAX_FOCUS_DEBUFFS do
			_G["FocusFrameDebuff"..i]:SetHeight(21);
			_G["FocusFrameDebuff"..i]:SetWidth(21);
		end
		
		TargetofFocusFrame:SetPoint("BOTTOMRIGHT", -35, -10);
		
		FocusFrameFlash:SetTexture("Interface\\TargetingFrame\\UI-FocusFrame-Large-Flash");
		FocusFrameFlash:SetTexCoord(0.0, 0.945, 0.0, 0.73125);
		
		FocusFrameTextureFrameSmall:Hide();
		FocusFrameTextureFrameFullSize:Show();
	elseif ( not fullSize and FocusFrame.fullSize ) then
		FocusFrame.fullSize = false;
		for name, value in pairs(framesToDuplicate) do
			local frame = _G["Focus"..name];
			if ( frame.oldHeight ) then
				frame:SetHeight(frame.oldHeight);
			end
			if ( frame.oldWidth ) then
				frame:SetWidth(frame.oldWidth);
			end
			
			if ( frame.oldAnchors ) then
				frame:ClearAllPoints();
				for i=1, #frame.oldAnchors do
					frame:SetPoint(unpack(frame.oldAnchors[i]));
				end
			end
		end
		
		for i=1, MAX_FOCUS_DEBUFFS do
			_G["FocusFrameDebuff"..i]:SetHeight(15);
			_G["FocusFrameDebuff"..i]:SetWidth(15);
		end
		
		TargetofFocusFrame:SetPoint("BOTTOMRIGHT", 14, -9);
		
		FocusFrameFlash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");
		FocusFrameFlash:SetTexCoord(0.55078125, 0, 0.400390625, 0.52734375);
		
		FocusFrameTextureFrameSmall:Show();
		FocusFrameTextureFrameFullSize:Hide();
	end
end
