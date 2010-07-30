
HOLYBALL_BAR_NUM = 3;



function HolyBallBar_ToggleHolyBall(self, visible)
	if visible then
		self.activate:Stop();
	else
		self.activate:Play();
	end
end


function HolyBallBar_Update()
	
	local unit = PlayerFrame.unit;
	local j = 1;
	local numHolyBalls = 0;
	local name, rank, texture, count = UnitAura(unit, j, "HELPFUL");
	while name do 
		if name == "Holy Power" then 
			numHolyBalls = count;
			break;
		end
		j=j+1;
		name, rank, texture, count = UnitAura(unit, j, "HELPFUL");
	end



	-- local numHolyBalls = UnitPower( HolyBallBarFrame:GetParent().unit, SHARD_BAR_POWER_INDEX );
	
	for i=1,HOLYBALL_BAR_NUM do
		local holyBall = _G["HolyBallBarFrameHolyBall"..i];
		local isShown = holyBall.activate:IsPlaying();
		local shouldShow = i <= numHolyBalls;
		if isShown ~= shouldShow then 
			HolyBallBar_ToggleHolyBall(holyBall, isShown);
		end
	end
end



function HolyBallBar_OnLoad (self)
	-- Disable rune frame if not a Warlock.
	local _, class = UnitClass("player");	
	if ( class ~= "PALADIN" ) then
		self:Hide();
	end
	--self:RegisterEvent("UNIT_POWER");
	--self:RegisterEvent("PLAYER_ENTERING_WORLD");
	--self:RegisterEvent("UNIT_DISPLAYPOWER");
	
	self:RegisterEvent("UNIT_AURA");
end



function HolyBallBar_OnEvent (self, event, arg1, arg2)
	HolyBallBar_Update();	
end


