HonorBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function HonorBarMixin:GetPriority()
	return self.priority; 
end

function HonorBarMixin:ShouldBeVisible()
	local level = UnitLevel("player");
	return level >= MAX_PLAYER_LEVEL and (IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP());
end

function HonorBarMixin:Update()
	local current = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");

	local level = UnitHonorLevel("player");
	local levelmax = GetMaxPlayerHonorLevel();
	
	if ( level == levelmax ) then
		self:SetBarValues(1, 0, 1, level);
	else
		self:SetBarValues(current, 0, maxHonor, level);
	end
	
	HonorExhaustionTick_Update(self.ExhaustionTick);
	
	local exhaustionStateID = GetHonorRestState();
	if ( exhaustionStateID == 1 ) then
		self:SetBarColor(1.0, 0.71, 0);
	else
		self:SetBarColor(1.0, 0.24, 0);
	end
end

function HonorBarMixin:UpdateOverlayFrameText()
	local current = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");

	if ( not current or not maxHonor ) then
		return;
	end

	local level = UnitHonorLevel("player");
	local levelmax = GetMaxPlayerHonorLevel();

	if ( CanPrestige() ) then
		self:SetBarText(PVP_HONOR_PRESTIGE_AVAILABLE);
	elseif ( level == levelmax ) then
		self:SetBarText(MAX_HONOR_LEVEL);
	else
		self:SetBarText(HONOR_BAR:format(current, maxHonor));
	end
end

function HonorBarMixin:OnLoad() 
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self.StatusBar:SetOnAnimatedValueChangedCallback(MainMenuBar_HonorUpdateOverlayFrameText);
	self.StatusBar.OnFinishedCallback = function(...)
		self.StatusBar:OnAnimFinished(...);
		HonorExhaustionTick_Update(self.ExhaustionTick);
	end
	self.priority = 2; 
end

function HonorBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "XP_BAR_TEXT" ) then
			self:UpdateTextVisibility();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "HONOR_XP_UPDATE" or event == "ZONE_CHANGED"
			or event == "ZONE_CHANGED_NEW_AREA" ) then
		self:Update();
	end
end

function HonorBarMixin:UpdateTick() 
	HonorExhaustionTick_Update(self.ExhaustionTick);
end

function HonorBarMixin:OnShow() 
	HonorExhaustionTick_Update(self.ExhaustionTick);
end

function HonorBarMixin:OnEnter()
	self:UpdateOverlayFrameText();
	self:ShowText(); 
	HonorExhaustionTick_Update(self.ExhaustionTick);
end

function HonorBarMixin:OnLeave()
	self:HideText();
end