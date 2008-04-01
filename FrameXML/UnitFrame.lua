
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
	this.name:SetText(UnitName(this.unit));
	SetPortraitTexture(this.portrait, this.unit);
	UnitFrameHealthBar_Update(this.healthbar, this.unit);
	UnitFrameManaBar_Update(this.manabar, this.unit);
end

function UnitFrame_OnEvent(event)
	if ( (event == "UNIT_NAME_UPDATE") and (arg1 == this.unit) ) then
		this.name:SetText(UnitName(this.unit));
		return;
	end
	if ( (event == "UNIT_PORTRAIT_UPDATE") and (arg1 == this.unit) ) then
		SetPortraitTexture(this.portrait, this.unit);
		return;
	end
	if ( (event == "UNIT_DISPLAYPOWER") and (arg1 == this.unit) ) then
		UnitFrame_UpdateManaType();
		return;
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
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		if ( this:GetName() == "PlayerFrame" ) then
			GameTooltip_AddNewbieTip(PARTY_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PARTYOPTIONS);
		else
			if ( UnitPlayerControlled("target") and not UnitIsUnit("target", "player") ) then
				GameTooltip_AddNewbieTip(PLAYER_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_PLAYEROPTIONS);
			end
		end
		return;
	end
	
	if ( GameTooltip:SetUnit(this.unit) ) then
		this.updateTooltip = TOOLTIP_UPDATE_TIME;
	else
		this.updateTooltip = nil;
	end

	this.r, this.g, this.b = GameTooltip_UnitColor(this.unit);
	GameTooltip:SetBackdropColor(this.r, this.g, this.b);
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
		GameTooltip:SetBackdropColor(this.r, this.g, this.b);
	else
		this.updateTooltip = nil;
	end
end

function UnitFrame_UpdateManaType()
	local info = ManaBarColor[UnitPowerType(this.unit)];
	this.manabar:SetStatusBarColor(info.r, info.g, info.b);
	--Hack for pets
	if ( this.unit == "pet" and info.prefix ~= HAPPINESS_POINTS ) then
		return;
	end
	-- Update the manabar text if shown in the ui options
	SetTextStatusBarTextPrefix(this.manabar, info.prefix);
	if ( UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"].value == "1" ) then
		TextStatusBar_UpdateTextString(this.manabar);
	end

	-- Setup newbie tooltip
	this.manabar.tooltipTitle = info.prefix;
	this.manabar.tooltipText = getglobal("NEWBIE_TOOLTIP_MANABAR"..UnitPowerType(this.unit));
end

function UnitFrameHealthBar_Initialize(unit, statusbar, statustext)
	statusbar.unit = unit;
	SetTextStatusBarText(statusbar, statustext);
	statusbar:RegisterEvent("UNIT_HEALTH");
	statusbar:RegisterEvent("UNIT_MAXHEALTH");

	-- Setup newbie tooltip
	statusbar.tooltipTitle = HEALTH;
	statusbar.tooltipText = NEWBIE_TOOLTIP_HEALTHBAR;
end

function UnitFrameHealthBar_Update(statusbar, unit)
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
	local cvar = arg1;
	local value = arg2;
	if ( unit == statusbar.unit ) then
		local currValue = UnitMana(unit);
		local maxValue = UnitManaMax(unit);
		statusbar:SetMinMaxValues(0, maxValue);
		statusbar:SetValue(currValue);
	end
	TextStatusBar_OnEvent(cvar, value);
end
