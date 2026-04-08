do

	local _, classFilename = UnitClass("player");
	if ( classFilename == "PALADIN" ) then
		AuraUtil.IsPriorityDebuff = function(spellId)
			local isForbearance = (spellId == 25771);	-- Forbearance
			return isForbearance or securecallfunction(AuraUtil.CheckIsPriorityAura, spellId);
		end
	elseif ( classFilename == "PRIEST" ) then
		AuraUtil.IsPriorityDebuff = function(spellId)
			local isWeakenedSoul = (spellId == 6788);	-- Weakened Soul
			return isWeakenedSoul or securecallfunction(AuraUtil.CheckIsPriorityAura, spellId);
		end
	else
		AuraUtil.IsPriorityDebuff = function(spellId)
			return securecallfunction(AuraUtil.CheckIsPriorityAura, spellId);
		end
	end

end
