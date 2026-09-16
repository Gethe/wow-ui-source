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

local DEBUFF_DISPLAY_INFO = AuraUtil.GetDebuffDisplayInfoTable();
function AuraUtil.SetAuraBorderAtlas(borderRegion, dispelType, showDispelType)
	local info = DEBUFF_DISPLAY_INFO[dispelType] or DEBUFF_DISPLAY_INFO["None"];
	local atlas = showDispelType and info.dispelAtlas or info.basicAtlas;
	borderRegion:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
end
