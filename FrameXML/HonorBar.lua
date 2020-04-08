HonorBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function HonorBarMixin:GetPriority()
	return self.priority; 
end

function HonorBarMixin:ShouldBeVisible()
	return IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP();
end

function HonorBarMixin:Update()
	local current = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");

	local level = UnitHonorLevel("player");
	

	self:SetBarValues(current, 0, maxHonor, level);
	
	
	self:SetBarColor(1.0, 0.24, 0);
end

function HonorBarMixin:UpdateOverlayFrameText()
	local current = UnitHonor("player");
	local maxHonor = UnitHonorMax("player");

	if ( not current or not maxHonor ) then
		return;
	end

	self:SetBarText(HONOR_BAR:format(current, maxHonor));
end

function HonorBarMixin:OnLoad() 
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("HONOR_XP_UPDATE");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self.StatusBar:SetOnAnimatedValueChangedCallback(function() self:UpdateOverlayFrameText() end);
	self.StatusBar.OnFinishedCallback = function(...)
		self.StatusBar:OnAnimFinished(...);
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
	return;
end

function HonorBarMixin:OnShow() 
	return;
end

function HonorBarMixin:OnEnter()
	self:UpdateOverlayFrameText();
	self:ShowText(); 
	return;
end

function HonorBarMixin:OnLeave()
	self:HideText();
end