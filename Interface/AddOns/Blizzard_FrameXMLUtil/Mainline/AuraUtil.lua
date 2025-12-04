do

	local _, classFilename = UnitClass("player");
	if ( classFilename == "PALADIN" ) then
		AuraUtil.IsPriorityDebuff = function(spellId)
			local isForbearance = (spellId == 25771);	-- Forbearance
			if isForbearance then
				return true;
			else
				return securecallfunction(AuraUtil.CheckIsPriorityAura, spellId);
			end
		end
	else
		AuraUtil.IsPriorityDebuff = function(spellId)
			return securecallfunction(AuraUtil.CheckIsPriorityAura, spellId);
		end
	end

end
