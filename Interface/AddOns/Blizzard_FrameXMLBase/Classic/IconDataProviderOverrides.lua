-- Classic IconDataProvider Overrides
MAX_TALENT_TABS = 3;

function IconDataProviderMixin:FillOutExtraIconsMapWithSpells(extraIconsMap)
	for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells;
		for j = offset, tabEnd - 1 do
			local spellType, ID = GetSpellBookItemInfo(j, "player");
			if spellType ~= "FUTURESPELL" then
				local fileID = GetSpellBookItemTexture(j, "player");
				if fileID ~= nil then
					extraIconsMap[fileID] = true;
				end
			end

			if spellType == "FLYOUT" then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
				if isKnown and (numSlots > 0) then
					for k = 1, numSlots do
						local spellID, overrideSpellID, isSlotKnown = GetFlyoutSlotInfo(ID, k)
						if isSlotKnown then
							local fileID = GetSpellTexture(spellID);
							if fileID ~= nil then
								extraIconsMap[fileID] = true;
							end
						end
					end
				end
			end
		end
	end
end

function IconDataProviderMixin:FillOutExtraIconsMapWithTalents(extraIconsMap)
	if GetSpecializationSystem() == Enum.SpecializationSystem.ChrSpecialization then
		local isInspect = false;
		for specIndex = 1, GetNumSpecGroups(isInspect) do
			for tier = 1, Constants.TalentTierConstants.MAX_TALENT_TIERS do
				for column = 1, Constants.TalentConsts.NumTalentColumns do
					local talentInfoQuery = {};
					talentInfoQuery.tier = tier;
					talentInfoQuery.column = column;
					talentInfoQuery.specializationIndex = specIndex;
					local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
					if talentInfo and talentInfo.icon then
						extraIconsMap[talentInfo.icon] = true;
					end
				end
			end
		end
	elseif GetSpecializationSystem() == Enum.SpecializationSystem.TalentTab then
		for i=1, MAX_TALENT_TABS do
			local numTalents = GetNumTalents(i);
			for j=1, numTalents do
				local talentInfoQuery = {};
				talentInfoQuery.talentIndex = j;
				talentInfoQuery.specializationIndex = i;
				local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
				if talentInfo and talentInfo.icon then
					extraIconsMap[talentInfo.icon] = true;
				end
			end
		end
	else
		-- unsupported SpecializationSystem
	end
end
