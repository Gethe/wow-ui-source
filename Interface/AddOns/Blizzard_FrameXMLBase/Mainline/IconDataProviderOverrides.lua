-- Mainline IconDataProvider Overrides

function IconDataProviderMixin:FillOutExtraIconsMapWithSpells(extraIconsMap)
	for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
		local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex);
		if skillLineInfo then
			for i = 1, skillLineInfo.numSpellBookItems do
				local spellIndex = skillLineInfo.itemIndexOffset + i;
				local spellType, ID = C_SpellBook.GetSpellBookItemType(spellIndex, Enum.SpellBookSpellBank.Player);
				if spellType ~= "FUTURESPELL" then
					local fileID = C_SpellBook.GetSpellBookItemTexture(spellIndex, Enum.SpellBookSpellBank.Player);
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
								local fileID = C_Spell.GetSpellTexture(spellID);
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
end

function IconDataProviderMixin:FillOutExtraIconsMapWithTalents(extraIconsMap)
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

	for pvpTalentSlot = 1, 3 do
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(pvpTalentSlot);
		if slotInfo ~= nil then
			for i, pvpTalentID in ipairs(slotInfo.availableTalentIDs) do
				local icon = select(3, GetPvpTalentInfoByID(pvpTalentID));
				if icon ~= nil then
					extraIconsMap[icon] = true;
				end
			end
		end
	end
end
