ExpBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function ExpBarMixin:GetPriority()
	return self.priority; 
end

function ExpBarMixin:ShouldBeVisible()
	return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled();
end

function ExpBarMixin:Update() 
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	local level = UnitLevel("player");

	local minBar, maxBar = 0, nextXP;
	
	local isCapped = false;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			isCapped = true;
			self:SetBarValues(1, 0, 1, level);
			self.StatusBar:ProcessChangesInstantly();
			self:SetBarColor(0.58, 0.0, 0.55, 1.0);
		end
	end
	if (not isCapped) then
		self:SetBarValues(currXP, minBar, maxBar, level);
	end

	self.currXP = currXP; 
	self.maxBar = maxBar;

	self:UpdateCurrentText();
end

function ExpBarMixin:UpdateCurrentText()
	local currXP = self.currXP;
	local maxBar = self.maxBar;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rLevel) then
			currXP = UnitTrialXP("player");
		end
	end
	self:SetBarText(XP_STATUS_BAR_TEXT:format(currXP, maxBar)); 
end

function ExpBarMixin:OnLoad()
	TextStatusBar_Initialize(self);
	
	self:Update();

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
	self.priority = 3; 
end

function ExpBarMixin:OnEvent(event, ...) 
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "XP_BAR_TEXT" ) then
			self:UpdateTextVisibility();
		end
	elseif ( event == "PLAYER_XP_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		self:Update();
	end
end

function ExpBarMixin:OnShow()
	self:UpdateTextVisibility();
end

function ExpBarMixin:OnEnter()
	TextStatusBar_UpdateTextString(self);
	self:ShowText(self);
	self:UpdateCurrentText();
	self.ExhaustionTick.timer = 1;
	local label = XPBAR_LABEL;
	
	if ( GameLimitedMode_IsActive() ) then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			local trialXP = UnitTrialXP("player");
			local bankedLevels = UnitTrialBankedLevels("player");
			if (trialXP > 0) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				local text = TRIAL_CAP_BANKED_XP_TOOLTIP;
				if (bankedLevels > 0) then
					text = TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels);
				end
				GameTooltip:SetText(text, nil, nil, nil, nil, true);
				GameTooltip:Show();
				if (IsTrialAccount()) then
					MicroButtonPulse(StoreMicroButton);
				end
				return
			else
				label = label.." "..RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL.."|r";
			end
		end
	end

	self.ExhaustionTick:ExhaustionToolTipText();
end

function ExpBarMixin:OnLeave() 
	self:HideText(); 
	GameTooltip:Hide();
	self.ExhaustionTick.timer = nil;
end

function ExpBarMixin:OnUpdate(elapsed)
	self.ExhaustionTick:OnUpdate(elapsed);
end

function ExpBarMixin:OnValueChanged()
	if ( not self:IsShown() ) then
		return;
	end
	self:Update();
end

function ExpBarMixin:UpdateTick()
	self.ExhaustionTick:UpdateTickPosition();
	self.ExhaustionTick:UpdateExhaustionColor();
end

ExhaustionTickMixin = { }
function ExhaustionTickMixin:ExhaustionToolTipText()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);

	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
	local exhaustionCurrXP, exhaustionMaxXP;
	local exhaustionThreshold = GetXPExhaustion();
	local exhaustionCountdown = nil;
	
	exhaustionStateMultiplier = exhaustionStateMultiplier * 100;
	
	if ( GetTimeToWellRested() ) then
		exhaustionCountdown = GetTimeToWellRested() / 60;
	end
	
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	local percentXP = math.ceil(currXP/nextXP*100);
	local XPText = format( XP_TEXT, BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP );
	local tooltipText = XPText..format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier);
	local append = nil;
	
	if ( IsResting() ) then
		if ( exhaustionThreshold and exhaustionCountdown ) then
			append = format(EXHAUST_TOOLTIP4, exhaustionCountdown);
		end
	elseif ( (exhaustionStateID == 4) or (exhaustionStateID == 5) ) then
		append = EXHAUST_TOOLTIP2;
	end

	if ( append ) then
		tooltipText = tooltipText..append;
	end

	GameTooltip:SetText(tooltipText);
end

function ExhaustionTickMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXHAUSTION");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
end

function ExhaustionTickMixin:UpdateTickPosition()
	local playerCurrXP = UnitXP("player");
	local playerMaxXP = UnitXPMax("player");
	local exhaustionThreshold = GetXPExhaustion();
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
		
	if ( exhaustionStateID and exhaustionStateID >= 3 ) then
		self:SetPoint("CENTER", self:GetParent() , "RIGHT", 0, 0);
	end

	if ( not exhaustionThreshold ) then
		self:Hide();
		self:GetParent().ExhaustionLevelFillBar:Hide();
	else
		local exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * (self:GetParent():GetWidth()), 0);
		self:ClearAllPoints();
		
		if ( exhaustionTickSet > self:GetParent():GetWidth() ) then
			self:Hide();
			self:GetParent().ExhaustionLevelFillBar:Hide();
		else
			self:Show();
			self:SetPoint("CENTER", self:GetParent(), "LEFT", exhaustionTickSet, 2);
			self:GetParent().ExhaustionLevelFillBar:Show();
			self:GetParent().ExhaustionLevelFillBar:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", exhaustionTickSet, 0);
		end
	end

	-- Hide exhaustion tick if player is max level or XP is turned off
	if ( IsPlayerAtEffectiveMaxLevel() or IsXPUserDisabled() ) then
		self:Hide();
	end			
end

function ExhaustionTickMixin:UpdateExhaustionColor()
	local exhaustionStateID = GetRestState();
	if ( exhaustionStateID == 1 ) then
		self:GetParent():SetBarColor(0.0, 0.39, 0.88, 1.0);
		self:GetParent().ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.25);
		self.Highlight:SetVertexColor(0.0, 0.39, 0.88);
	elseif ( exhaustionStateID == 2 ) then
		self:GetParent():SetBarColor(0.58, 0.0, 0.55, 1.0);
		self:GetParent().ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.25);
		self.Highlight:SetVertexColor(0.58, 0.0, 0.55);
	end
end

function ExhaustionTickMixin:OnEvent(event, ...)
	if (IsRestrictedAccount()) then
		local rlevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rlevel) then
			self:GetParent():SetBarColor(0.0, 0.39, 0.88, 1.0);
			self:Hide();
			self:GetParent().ExhaustionLevelFillBar:Hide();
			self:UnregisterAllEvents();	
			return;
		end
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_XP_UPDATE" or event == "UPDATE_EXHAUSTION" or event == "PLAYER_LEVEL_UP" ) then
		self:UpdateTickPosition(); 
	end
	
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_EXHAUSTION" ) then
		self:UpdateExhaustionColor();
	end
	
	if ( not self:IsShown() ) then
		self:Hide();
	end
end

function ExhaustionTickMixin:OnUpdate(elapsed)
	if ( self.timer ) then
		if ( self.timer < 0 ) then
			self:ExhaustionToolTipText();
			self.timer = nil;
		else
			self.timer = self.timer - elapsed;
		end
	end
end