
ExpBarMixin = {};

function ExpBarMixin:GetMaxLevel()
	return GetMaxLevelForPlayerExpansion();
end

function ExpBarMixin:IsCapped()
	if GameLimitedMode_IsBankedXPActive() then
		local restrictedLevel = GameLimitedMode_GetLevelLimit();
		return UnitLevel("player") >= restrictedLevel;
	end

	return false;
end

function ExpBarMixin:GetLevelData()
	local currXP = self:IsCapped() and UnitTrialXP("player") or UnitXP("player");
	local nextXP = UnitXPMax("player");
	local level = UnitLevel("player");
	local bankedLevels = UnitTrialBankedLevels("player");

	return currXP, nextXP, level, bankedLevels;
end

function ExpBarMixin:Update()
	local level;
	self.currXP, self.maxBar, level = self:GetLevelData();
	if self:IsCapped() then
		local isRested = false;
		self:UpdateStatusBarTextures(isRested);

		self:SetBarValues(1, 0, 1, level, self:GetMaxLevel());
	else
		local minBar = 0;
		self:SetBarValues(self.currXP, minBar, self.maxBar, level, self:GetMaxLevel());
	end

	self:UpdateCurrentText();
end

function ExpBarMixin:UpdateCurrentText()
	-- Override me!
end

function ExpBarMixin:OnLoad()
	self.StatusBar:InitializeTextStatusBar();

	self:Update();

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
end

function ExpBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "xpBarText" ) then
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
	self.StatusBar:UpdateTextString();
	self:ShowText();
	self:UpdateCurrentText();

	if GameLimitedMode_IsBankedXPActive() then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			local trialXP = UnitTrialXP("player");
			if trialXP > 0 and IsTrialAccount() then
				MicroButtonPulse(StoreMicroButton);
			end
		end
	end

	self.ExhaustionTick:ExhaustionToolTipText();
end

function ExpBarMixin:OnLeave()
	self:HideText();
	GameTooltip:Hide();
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

function ExpBarMixin:UpdateStatusBarTextures(isRested)
	-- Override me!
end

ExhaustionTickMixin = {};

function ExhaustionTickMixin:ExhaustionToolTipText()
	-- Override me!
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
	local exhaustionStateID = GetRestState();

	if ( exhaustionStateID and exhaustionStateID >= 3 ) then
		self:SetPoint("CENTER", self:GetParent() , "RIGHT", 0, 0);
	end

	if ( not exhaustionThreshold or exhaustionThreshold <= 0 or IsPlayerAtEffectiveMaxLevel() or IsXPUserDisabled() ) then
		-- Hide exhaustion if player has no exhaustion, player is max level, or XP is turned off
		self:Hide();
		self:GetParent().ExhaustionLevelFillBar:Hide();
	else
		local widthRatio = max((playerCurrXP + exhaustionThreshold) / playerMaxXP, 0);
		if (self.hideAtBarEdge) then
			self:SetShown(widthRatio >= 0.01 and widthRatio <= 0.99); -- Hide pip at edges of bar since it doesn't look good at edges
		else
			self:SetShown(true);
		end

		local exhaustionTickSet = max(widthRatio * (self:GetParent():GetWidth()), 0);
		self:ClearAllPoints();

		if ( exhaustionTickSet > self:GetParent():GetWidth() ) then
			self:GetParent().ExhaustionLevelFillBar:Hide();
		else
			self:SetPoint("CENTER", self:GetParent(), "LEFT", exhaustionTickSet, self.yOffset or 0);
			self:GetParent().ExhaustionLevelFillBar:Show();
			self:GetParent().ExhaustionLevelFillBar:SetWidth(exhaustionTickSet);
			self:GetParent().ExhaustionLevelFillBar:SetTexCoord(0, widthRatio, 0, 1);
		end
	end
end

function ExhaustionTickMixin:UpdateExhaustionColor()
	local exhaustionStateID = GetRestState();
	if ( exhaustionStateID == 1 ) then
		local isRested = true;
		self:GetParent():UpdateStatusBarTextures(isRested);
	elseif ( exhaustionStateID == 2 ) then
		local isRested = false;
		self:GetParent():UpdateStatusBarTextures(isRested);
	end
end

function ExhaustionTickMixin:OnEvent(event, ...)
	if (IsRestrictedAccount()) then
		local rlevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rlevel) then
			local isRested = true;
			self:GetParent():UpdateStatusBarTextures(isRested);

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
