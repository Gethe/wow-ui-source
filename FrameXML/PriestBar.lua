SHADOW_ORBS_SHOW_LEVEL = 10;
PRIEST_BAR_NUM_LARGE_ORBS = 3;
PRIEST_BAR_NUM_SMALL_ORBS = 5;
SHADOW_ORB_MINOR_TALENT_ID = 157217

function PriestBarFrame_OnLoad(self)
	local _, class = UnitClass("player");
	if (false and class == "PRIEST" ) then -- TODO: Task 86565, remove Shadow Orbs, this part takes care of the UI
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 2);
		if ( UnitLevel("player") < SHADOW_ORBS_SHOW_LEVEL ) then
			self:RegisterEvent("PLAYER_LEVEL_UP");
		else
			self.hasReqLevel = true;
			self:RegisterEvent("PLAYER_TALENT_UPDATE");
			self:RegisterEvent("SPELLS_CHANGED");
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
	elseif ( event == "PLAYER_TALENT_UPDATE" or event == "SPELLS_CHANGED" ) then
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
				self.ShowAnim:Play();
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
	if (IsSpellKnown(SHADOW_ORB_MINOR_TALENT_ID)) then
		PriestBarFrame.Holder:SetAtlas("shadoworbs-small-Frame", true);
		for i = 1, PRIEST_BAR_NUM_LARGE_ORBS do
			local orb = PriestBarFrame.LargeOrbs[i];
			if (orb) then
				orb:Hide();
			end
		end
		for i = 1, PRIEST_BAR_NUM_SMALL_ORBS do
			local orb = PriestBarFrame.SmallOrbs[i];
			if (not orb) then
				orb = CreateFrame("Frame", nil, PriestBarFrame, "ShadowOrbSmallTemplate");
				orb:ClearAllPoints();
				orb:SetPoint("LEFT", PriestBarFrame.SmallOrbs[i-1], "RIGHT", -15, 0);
			end
			orb:Show();
			local shouldShow = i <= numOrbs;
			PriestBar_SetOrb(orb, shouldShow);
		end
	else
		PriestBarFrame.Holder:SetAtlas("shadoworbs-large-Frame", true);
		for i = 1, PRIEST_BAR_NUM_SMALL_ORBS do
			local orb = PriestBarFrame.SmallOrbs[i];
			if (orb) then
				orb:Hide();
			end
		end
		for i = 1, PRIEST_BAR_NUM_LARGE_ORBS do
			local orb = PriestBarFrame.LargeOrbs[i];
			if (not orb) then
				orb = CreateFrame("Frame", nil, PriestBarFrame, "ShadowOrbLargeTemplate");
				orb:ClearAllPoints();
				orb:SetPoint("LEFT", PriestBarFrame.LargeOrbs[i-1], "RIGHT", -5, 0);
			end
			orb:Show();
			local shouldShow = i <= numOrbs;
			PriestBar_SetOrb(orb, shouldShow);
		end
	end
end

function PriestBar_SetOrb(self, active)
	if ( active ) then
		if (self.AnimOut:IsPlaying()) then
			self.AnimOut:Stop();
		end
		
		if (not self.active and not self.AnimIn:IsPlaying()) then
			self.AnimIn:Play();
			self.active = true;
		end
	else
		if (self.AnimIn:IsPlaying()) then
			self.AnimIn:Stop();
		end
		
		if (self.active and not self.AnimOut:IsPlaying()) then
			self.AnimOut:Play();
			self.active = false;
		end
	end
end