ClassResourceOverlayParent = {};

function ClassResourceOverlayParent:OnShow()
	UIParent_ManageFramePositions();
end

function ClassResourceOverlayParent:OnHide()
	UIParent_ManageFramePositions();
end

function ClassResourceOverlayParent:SetClassResourceOverlay(overlay, show)
	self:SetSize(overlay:GetSize());
	self:SetShown(show);
	overlay:SetShown(show);
end

	
ClassResourceOverlay = {};

function ClassResourceOverlay:OnLoad()
	--[[ 
		Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
		a UpdatePower() mixin function that handles UI changes for whenever the power display changes
	self.class = "PALADIN";
	self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerToken = "HOLY_POWER";
	]]--
	
	self:Setup();
end

function ClassResourceOverlay:OnEvent(event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" and arg1 == "player" and self.powerToken == arg2 ) then
		self:UpdatePower();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdatePower();
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
	else
		return false;
	end
	return true;
end

function ClassResourceOverlay:MatchesClass()
	local _, myclass = UnitClass("player");
	return myclass == self.class;
end

function ClassResourceOverlay:MatchesSpec()
	if ( not self.spec ) then
		return true;
	end
	local myspec = GetSpecialization();
	return myspec == self.spec;
end
	
function ClassResourceOverlay:Setup()
	local spec = GetSpecialization();
	local showBar = false;
	
	if ( self:MatchesClass() ) then
		if ( self:MatchesSpec() ) then
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");	
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end
		
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end
	self:GetParent():SetClassResourceOverlay(self, showBar);
	return showBar;
end
