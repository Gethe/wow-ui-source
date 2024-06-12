local BATTLE_PET_TOOLTIP = {};

function BattlePetToolTip_UnpackBattlePetLink(battlePetLink)
	local linkType, linkOptions, name = LinkUtil.ExtractLink(battlePetLink);
	if linkType ~= "battlepet" then
		return nil;
	end

	local speciesID, level, breedQuality, maxHealth, power, speed = strsplit(":", linkOptions);
	return tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name;
end

function BattlePetToolTip_ShowLink(battlePetLink)
	local speciesID, level, breedQuality, maxHealth, power, speed, name = BattlePetToolTip_UnpackBattlePetLink(battlePetLink);
	if speciesID == nil then
		return false;
	end

	BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
	return true;
end

function BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, customName)
	if (speciesID and speciesID > 0) then
		local name, icon, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		BATTLE_PET_TOOLTIP.speciesID = speciesID;
		BATTLE_PET_TOOLTIP.name = name;
		BATTLE_PET_TOOLTIP.level = level;
		BATTLE_PET_TOOLTIP.breedQuality = breedQuality;
		BATTLE_PET_TOOLTIP.petType = petType;
		BATTLE_PET_TOOLTIP.maxHealth = maxHealth;
		BATTLE_PET_TOOLTIP.power = power;
		BATTLE_PET_TOOLTIP.speed = speed;
		if (customName ~= BATTLE_PET_TOOLTIP.name) then
			BATTLE_PET_TOOLTIP.customName = customName;
		else
			BATTLE_PET_TOOLTIP.customName = nil;
		end

		BattlePetTooltipTemplate_SetBattlePet(BattlePetTooltip, BATTLE_PET_TOOLTIP);

		local owned = C_PetJournal.GetOwnedBattlePetString(speciesID);
		BattlePetTooltip.Owned:SetText(owned);
		if(owned == nil) then
			BattlePetTooltip:SetSize(260,122);
		else
			BattlePetTooltip:SetSize(260,136);
		end

		BattlePetTooltip:Show();

		BattlePetTooltip:ClearAllPoints();
		BattlePetTooltip:SetPoint(GameTooltip:GetPoint(1));
	end
end