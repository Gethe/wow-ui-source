SHADOW_ORBS_SHOW_LEVEL = 10;
PRIEST_BAR_NUM_ORBS = 3;

function PriestBarFrame_OnLoad(self)
	local _, class = UnitClass("player");
	if ( class == "PRIEST" ) then
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
		if ( UnitLevel("player") < SHADOW_ORBS_SHOW_LEVEL ) then
			self:RegisterEvent("PLAYER_LEVEL_UP");
		else
			self.hasReqLevel = true;
			self:RegisterEvent("PLAYER_TALENT_UPDATE");
		end
		PriestBarFrame_CheckAndShow(self);
	end
end

function PriestBarFrame_OnEvent(self, event, arg1, arg2)
	if ( (event == "UNIT_POWER_FREQUENT") and (arg1 == self:GetParent().unit) ) then
		if ( arg2 == "SHADOW_ORBS" ) then
			PriestBar_Update();
		end
	elseif ( event == "UNIT_DISPLAYPOWER" ) then
		PriestBar_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		PriestBar_Update();
	elseif ( event == "PLAYER_TALENT_UPDATE" ) then
		PriestBarFrame_CheckAndShow(self);
	elseif( event ==  "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if ( level >= SHADOW_ORBS_SHOW_LEVEL ) then
			self.hasReqLevel = true;
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			-- have to watch out for spec changes
			self:RegisterEvent("PLAYER_TALENT_UPDATE");
			-- clear spec to force reevaluation
			self.spec = nil;
			PriestBarFrame_CheckAndShow(self, true);
		end
	end
end

-- this function might be called to reshow the power bar, like after leaving a vehicle
function PriestBarFrame_CheckAndShow(self)
	self = self or PriestBarFrame;
	-- check spec
	local spec = GetSpecialization();
	if ( spec == SPEC_PRIEST_SHADOW ) then
		if ( self.hasReqLevel ) then
			local adjustAttachments;
			if ( spec ~= self.spec ) then
				self:RegisterEvent("PLAYER_ENTERING_WORLD");
				self:RegisterEvent("UNIT_DISPLAYPOWER");
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", "vehicle");
				self:SetAlpha(0);
				self.showAnim:Play();
				adjustAttachments = true;
			end
			self:Show();
			if ( adjustAttachments ) then
				PlayerFrame_AdjustAttachments();
			end
			PriestBar_Update();
		end
	else
		-- undo previous spec
		if ( self.spec == SPEC_PRIEST_SHADOW ) then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
			self:UnregisterEvent("UNIT_DISPLAYPOWER");
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:Hide();
			PlayerFrame_AdjustAttachments();
		end
	end
	self.spec = spec;
end

function PriestBar_Update()
	local numOrbs = UnitPower( PriestBarFrame:GetParent().unit, SPELL_POWER_SHADOW_ORBS );
	for i = 1, PRIEST_BAR_NUM_ORBS do
		local orb = _G["PriestBarFrameOrb"..i];
		local shouldShow = i <= numOrbs;
		PriestBar_SetOrb(orb, shouldShow);
	end
end

function PriestBar_SetOrb(self, active)
	if ( active ) then
		if (self.animOut:IsPlaying()) then
			self.animOut:Stop();
		end
		
		if (not self.active and not self.animIn:IsPlaying()) then
			self.animIn:Play();
			self.active = true;
		end
	else
		if (self.animIn:IsPlaying()) then
			self.animIn:Stop();
		end
		
		if (self.active and not self.animOut:IsPlaying()) then
			self.animOut:Play();
			self.active = false;
		end
	end
end