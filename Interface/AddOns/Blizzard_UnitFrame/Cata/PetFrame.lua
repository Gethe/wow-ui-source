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
		if ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) then
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90);
		else
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -80);
		end
	elseif ( class == "PALADIN" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90);
	elseif ( class == "PRIEST" ) then
		if ClassicExpansionAtLeast(LE_EXPANSION_MISTS_OF_PANDARIA) then
			self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90);
		end
	elseif ( class == "MONK" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 90, -100);
	end
end

function RefreshBuffsOrDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar);
end
