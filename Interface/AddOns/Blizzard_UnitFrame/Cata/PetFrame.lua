function PetFrame_SetHappiness()
	-- Pet happiness was removed in Cataclysm.
end

function PetFrame_AdjustPoint(self)
	local _, class = UnitClass("player");
	--Death Knights need the Pet frame moved down for their Runes and Druids need it moved down for the secondary power bar.
	if ( class == "DEATHKNIGHT") then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -75);
	elseif ( class == "SHAMAN" or class == "DRUID" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -100);
	elseif ( class == "WARLOCK" ) then
 		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -80);
	elseif ( class == "PALADIN" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90);
	end
end

function RefreshBuffsOrDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar);
end