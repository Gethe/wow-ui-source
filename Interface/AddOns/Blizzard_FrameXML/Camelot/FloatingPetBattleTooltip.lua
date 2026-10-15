local BATTLE_PET_FLOATING_TOOLTIP = {};

function FloatingBattlePet_Toggle(speciesID, level, breedQuality, maxHealth, power, speed, customName, bPetID)
	if ( FloatingBattlePetTooltip:IsShown() and
		FloatingBattlePetTooltip.battlePetID == bPetID and FloatingBattlePetTooltip.speciesID == speciesID ) then
		FloatingBattlePetTooltip:Hide();
	else
		FloatingBattlePet_Show(speciesID, breedQuality, customName, bPetID);
	end
end

function FloatingBattlePet_Show(speciesID, breedQuality, customName, bPetID)
	if (speciesID and speciesID > 0) then
		local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		BATTLE_PET_FLOATING_TOOLTIP.speciesID = speciesID;
		BATTLE_PET_FLOATING_TOOLTIP.name = name;
		BATTLE_PET_FLOATING_TOOLTIP.breedQuality = breedQuality;
		BATTLE_PET_FLOATING_TOOLTIP.battlePetID = bPetID;
		if (customName ~= BATTLE_PET_FLOATING_TOOLTIP.name) then
			BATTLE_PET_FLOATING_TOOLTIP.customName = customName;
		else
			BATTLE_PET_FLOATING_TOOLTIP.customName = nil;
		end

		BattlePetTooltipTemplate_SetBattlePet(FloatingBattlePetTooltip, BATTLE_PET_FLOATING_TOOLTIP);

		FloatingBattlePetTooltip:Show();
	end
end

function BattlePetTooltip_OnLoad(self)
	local subLayer = 0;
	self.linePool = CreateFontStringPool(self, "ARTWORK", subLayer, "GameTooltipText");
end

function BattlePetTooltipTemplate_SetBattlePet(tooltipFrame, data)
	tooltipFrame.battlePetID = data.battlePetID;
	tooltipFrame.speciesID = data.speciesID; -- For the button
	tooltipFrame.Name:SetText(data.name);
	if (data.breedQuality ~= -1) then
		local colorData = ColorManager.GetColorDataForItemQuality(data.breedQuality);
		if colorData then
			tooltipFrame.Name:SetTextColor(colorData.r, colorData.g, colorData.b);
		end
	else
		tooltipFrame.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	tooltipFrame.linePool:ReleaseAll();
	tooltipFrame.textLineAnchor = nil;
end

function BattlePetTooltipJournalClick_OnClick(self)
	if DISALLOW_FRAME_TOGGLING then
		return;
	end

	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
	if CollectionsJournal then
		local battlePetID = self:GetParent().battlePetID;
		if ( battlePetID ) then
			local speciesID = C_PetJournal.GetPetInfoByPetID(battlePetID);
			if ( speciesID and speciesID == self:GetParent().speciesID ) then
				PetJournal_SelectPet(PetJournal, battlePetID);
				return;
			end
		end
		PetJournal_SelectSpecies(PetJournal, self:GetParent().speciesID);
	end
end

