
ManaBarColor = {};
ManaBarColor[0] = { r = 0.00, g = 0.00, b = 1.00, prefix = TEXT(MANA) };
ManaBarColor[1] = { r = 1.00, g = 0.00, b = 0.00, prefix = TEXT(RAGE_POINTS) };
ManaBarColor[2] = { r = 1.00, g = 0.50, b = 0.25, prefix = TEXT(FOCUS_POINTS) };
ManaBarColor[3] = { r = 1.00, g = 1.00, b = 0.00, prefix = TEXT(ENERGY_POINTS) };
ManaBarColor[4] = { r = 0.00, g = 1.00, b = 1.00, prefix = TEXT(HAPPINESS_POINTS) };

function UnitFrame_Initialize(unit, name, portrait, healthbar, healthtext, manabar, manatext)
	this.unit = unit;
	this.name = name;
	this.portrait = portrait;
	this.healthbar = healthbar;
	this.manabar = manabar;
	UnitFrameHealthBar_Initialize(unit, healthbar, healthtext);
	UnitFrameManaBar_Initialize(unit, manabar, manatext);
	UnitFrame_Update();
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this:RegisterEvent("UNIT_DISPLAYPOWER");
end

function UnitFrame_Update()
	this.name:SetText(GetUnitName(this.unit));
	SetPortraitTexture(this.portrait, this.unit);
	UnitFrameHealthBar_Update(this.healthbar, this.unit);
	UnitFrameManaBar_Update(this.manabar, this.unit);
end

function UnitFrame_OnEvent(event)
	if ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == this.unit ) then
			this.name:SetText(GetUnitName(this.unit));
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == this.unit ) then
			SetPortraitTexture(this.portrait, this.unit);
		end
	elseif ( event == "UNIT_DISPLAYPOWER" ) then
		if ( arg1 == this.unit ) then
			UnitFrame_UpdateManaType();
		end
	end
end

function UnitFrame_OnEnter()
	if ( SpellIsTargeting() ) then
		if ( SpellCanTargetUnit(this.unit) ) then
			SetCursor("CAST_CURSOR");
		else
			SetCursor("CAST_ERROR_CURSOR");
		end
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, this);
	-- If showing newbie tips then only show the explanation
	if ( SHOW_NEWBIE_TIPS == "1" and this:GetName() ~= "PartyMemberFrame1" and this:GetName() ~= "PartyMemberFrame2" and this:GetName() ~= "PartyMemberFrame3" and this:GetName() ~= "PartyMemberFrame4") then
		if ( this:GetName() == "PlayerFrame" ) then
			GameTooltip_AddNewbieTip(PARTY_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PARTYOPTIONS);
			return;
		elseif ( UnitPlayerControlled("target") and not UnitIsUnit("target", "player") and not UnitIsUnit("target", "pet") ) then
			GameTooltip_AddNewbieTip(PLAYER_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PLAYEROPTIONS);
			return;
		end
	end
	
	if ( GameTooltip:SetUnit(this.unit) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end

	this.r, this.g, this.b = GameTooltip_UnitColor(this.unit);
	--GameTooltip:SetBackdropColor(this.r, this.g, this.b);
	GameTooltipTextLeft1:SetTextColor(this.r, this.g, this.b);
end

function UnitFrame_OnLeave()
	if ( SpellIsTargeting() ) then
		SetCursor("CAST_ERROR_CURSOR");
	end
	this.updateTooltip = nil;
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:Hide();
	else
		GameTooltip:FadeOut();	
	end
end

function UnitFrame_OnUpdate(elapsed)
	if ( not this.updateTooltip ) then
		return;
	end

	this.updateTooltip = this.updateTooltip - elapsed;
	if ( this.updateTooltip > 0 ) then
		return;
	end

	if ( GameTooltip:IsOwned(this) ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		if ( GameTooltip:SetUnit(this.unit) ) then
			this.updateTooltip = TOOLTIP_UPDATE_TIME;
		else
			this.updateTooltip = nil;
		end
		--GameTooltip:SetBackdropColor(this.r, this.g, this.b);
		GameTooltipTextLeft1:SetTextColor(this.r, this.g, this.b);
	else
		this.updateTooltip = nil;
	end
end

function UnitFrame_UpdateManaType(unitFrame)
	if ( not unitFrame ) then
		unitFrame = this;
	end
	if ( not unitFrame.manabar ) then
		return;
	end
	local info = ManaBarColor[UnitPowerType(unitFrame.unit)];
	unitFrame.manabar:SetStatusBarColor(info.r, info.g, info.b);
	--Hack for pets
	if ( unitFrame.unit == "pet" and info.prefix ~= HAPPINESS_POINTS ) then
		return;
	end
	-- Update the manabar text if shown in the ui options
	SetTextStatusBarTextPrefix(unitFrame.manabar, info.prefix);
	if ( GetCVar("statusBarText") == "1" ) then
		TextStatusBar_UpdateTextString(unitFrame.manabar);
	end

	-- Setup newbie tooltip
	if ( unitFrame:GetName() == "PlayerFrame" ) then
		unitFrame.manabar.tooltipTitle = info.prefix;
		unitFrame.manabar.tooltipText = getglobal("NEWBIE_TOOLTIP_MANABAR"..UnitPowerType(unitFrame.unit));
	else
		unitFrame.manabar.tooltipTitle = nil;
		unitFrame.manabar.tooltipText = nil;
	end
end

function UnitFrameHealthBar_Initialize(unit, statusbar, statustext)
	if ( not statusbar ) then
		return;
	end
	statusbar.unit = unit;
	SetTextStatusBarText(statusbar, statustext);
	statusbar:RegisterEvent("UNIT_HEALTH");
	statusbar:RegisterEvent("UNIT_MAXHEALTH");

	-- Setup newbie tooltip
	if ( this and (this:GetName() == "PlayerFrame") ) then
		statusbar.tooltipTitle = HEALTH;
		statusbar.tooltipText = NEWBIE_TOOLTIP_HEALTHBAR;
	else
		statusbar.tooltipTitle = nil;
		statusbar.tooltipText = nil;
	end
end

function UnitFrameHealthBar_Update(statusbar, unit)
	if ( not statusbar ) then
		return;
	end
	local cvar = arg1;
	local value = arg2;
	
	if ( unit == statusbar.unit ) then
		local currValue = UnitHealth(unit);
		local maxValue = UnitHealthMax(unit);
		statusbar:SetMinMaxValues(0, maxValue);
		statusbar:SetValue(currValue);
	end
	TextStatusBar_OnEvent(cvar, value);
end

function UnitFrameHealthBar_OnValueChanged(value)
	TextStatusBar_OnValueChanged();
	HealthBar_OnValueChanged(value);
end

function UnitFrameManaBar_Initialize(unit, statusbar, statustext)
	if ( not statusbar ) then
		return;
	end
	statusbar.unit = unit;
	SetTextStatusBarText(statusbar, statustext);
	statusbar:RegisterEvent("UNIT_MANA");
	statusbar:RegisterEvent("UNIT_RAGE");
	statusbar:RegisterEvent("UNIT_FOCUS");
	statusbar:RegisterEvent("UNIT_ENERGY");
	statusbar:RegisterEvent("UNIT_HAPPINESS");
	statusbar:RegisterEvent("UNIT_MAXMANA");
	statusbar:RegisterEvent("UNIT_MAXRAGE");
	statusbar:RegisterEvent("UNIT_MAXFOCUS");
	statusbar:RegisterEvent("UNIT_MAXENERGY");
	statusbar:RegisterEvent("UNIT_MAXHAPPINESS");
	statusbar:RegisterEvent("UNIT_DISPLAYPOWER");
end

function UnitFrameManaBar_Update(statusbar, unit)
	if ( not statusbar ) then
		return;
	end
	local cvar = arg1;
	local value = arg2;
	
	if ( unit == statusbar.unit ) then
		local maxValue = UnitManaMax(unit);
		statusbar:SetMinMaxValues(0, maxValue);
		-- If disconnected
		if ( not UnitIsConnected(unit) ) then
			statusbar:SetValue(maxValue);
			statusbar:SetStatusBarColor(0.5, 0.5, 0.5);
		else
			local currValue = UnitMana(unit);
			statusbar:SetValue(currValue);
			UnitFrame_UpdateManaType(statusbar:GetParent());
		end
	end
	TextStatusBar_OnEvent(cvar, value);
end

function GetUnitName(unit, showServerName)
	local name, server = UnitName(unit);
	if ( server ) then
		if ( showServerName ) then
			return name.." - "..server;
		else
			return name..FOREIGN_SERVER_LABEL;
		end
	else
		return name;
	end
end