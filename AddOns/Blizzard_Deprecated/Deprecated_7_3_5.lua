-- These are functions that were deprecated in 7.3.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if (not IsPublicBuild()) then
	return;
end

-- Soulstone

do
	-- Use C_DeathInfo.GetSelfResurrectOptions instead
	function HasSoulstone()
		local options = GetSortedSelfResurrectOptions();
		return options and options[1] and options[1].name;
	end

	-- Use C_DeathInfo.GetSelfResurrectOptions instead
	function CanUseSoulstone()
		local options = GetSortedSelfResurrectOptions();
		return options and options[1] and options[1].canUse;
	end

	-- Use C_DeathInfo.UseSelfResurrectOption instead
	function UseSoulstone()
		local options = GetSortedSelfResurrectOptions();
		if ( options and options[1] and options[1].canUse ) then
			C_DeathInfo.UseSelfResurrectOption(options[1].optionType, options[1].id);
		end
	end

	function EJ_GetSectionInfo(sectionID)
		local info = C_EncounterJournal.GetSectionInfo(sectionID);
		if info then
			local flag1, flag2, flag3, flag4;
			local flags = C_EncounterJournal.GetSectionIconFlags(sectionID);
			if flags then
				flag1, flag2, flag3, flag4 = unpack(flags);
			end

			return	info.title,
					info.description,
					info.headerType,
					info.abilityIcon,
					info.creatureDisplayID,
					info.siblingSectionID,
					info.firstChildSectionID,
					info.filteredByDifficulty,
					info.link,
					info.startsOpen,
					flag1,
					flag2,
					flag3,
					flag4;
		end
	end
end

