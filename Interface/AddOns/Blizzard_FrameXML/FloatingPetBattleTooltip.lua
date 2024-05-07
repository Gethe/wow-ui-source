local PET_BATTLE_FLOATING_ABILITY_TOOLTIP = SharedPetBattleAbilityTooltip_GetInfoTable();

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:GetAbilityID()
	return self.abilityID;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:IsInBattle()
	return false;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:GetHealth(target)
	self:EnsureTarget(target);
	return self.maxHealth;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:GetMaxHealth(target)
	self:EnsureTarget(target);
	return self.maxHealth;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:GetAttackStat(target)
	self:EnsureTarget(target);
	return self.power;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:GetSpeedStat(target)
	self:EnsureTarget(target);
	return self.speed;
end

function PET_BATTLE_FLOATING_ABILITY_TOOLTIP:EnsureTarget(target)
	--We support both abilities and auras in floating tooltips, so we have
	--to support all tokens, but we don't actually do anything with them.
	--
	--If we ever do anything with the targets, we'll have to put code in this function.
end

function FloatingPetBattleAbility_Show(abilityID, maxHealth, power, speed)
	if ( abilityID and abilityID > 0 ) then
		PET_BATTLE_FLOATING_ABILITY_TOOLTIP.abilityID = abilityID;
		PET_BATTLE_FLOATING_ABILITY_TOOLTIP.maxHealth = maxHealth;
		PET_BATTLE_FLOATING_ABILITY_TOOLTIP.power = power;
		PET_BATTLE_FLOATING_ABILITY_TOOLTIP.speed = speed;
		SharedPetBattleAbilityTooltip_SetAbility(FloatingPetBattleAbilityTooltip, PET_BATTLE_FLOATING_ABILITY_TOOLTIP);
		FloatingPetBattleAbilityTooltip:Show();
	end
end

-------------------------------------------
local BATTLE_PET_FLOATING_TOOLTIP = {};

function FloatingBattlePet_Toggle(speciesID, level, breedQuality, maxHealth, power, speed, customName, bPetID)
	if ( FloatingBattlePetTooltip:IsShown() and
		FloatingBattlePetTooltip.battlePetID == bPetID and FloatingBattlePetTooltip.speciesID == speciesID ) then
		FloatingBattlePetTooltip:Hide();
	else
		FloatingBattlePet_Show(speciesID, level, breedQuality, maxHealth, power, speed, customName, bPetID);
	end
end

function FloatingBattlePet_Show(speciesID, level, breedQuality, maxHealth, power, speed, customName, bPetID)
	if (speciesID and speciesID > 0) then
		local name, icon, petType = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
		BATTLE_PET_FLOATING_TOOLTIP.speciesID = speciesID;
		BATTLE_PET_FLOATING_TOOLTIP.name = name;
		BATTLE_PET_FLOATING_TOOLTIP.level = level;
		BATTLE_PET_FLOATING_TOOLTIP.breedQuality = breedQuality;
		BATTLE_PET_FLOATING_TOOLTIP.petType = petType;
		BATTLE_PET_FLOATING_TOOLTIP.maxHealth = maxHealth;
		BATTLE_PET_FLOATING_TOOLTIP.power = power;
		BATTLE_PET_FLOATING_TOOLTIP.speed = speed;
		BATTLE_PET_FLOATING_TOOLTIP.battlePetID = bPetID;
		if (customName ~= BATTLE_PET_FLOATING_TOOLTIP.name) then
			BATTLE_PET_FLOATING_TOOLTIP.customName = customName;
		else
			BATTLE_PET_FLOATING_TOOLTIP.customName = nil;
		end

		BattlePetTooltipTemplate_SetBattlePet(FloatingBattlePetTooltip, BATTLE_PET_FLOATING_TOOLTIP);

		local owned = C_PetJournal.GetOwnedBattlePetString(speciesID);
		FloatingBattlePetTooltip.Owned:SetText(owned);
		if(owned == nil) then
			FloatingBattlePetTooltip:SetSize(260,150);
			FloatingBattlePetTooltip.Delimiter:ClearAllPoints();
			FloatingBattlePetTooltip.Delimiter:SetPoint("TOPLEFT",FloatingBattlePetTooltip.SpeedTexture,"BOTTOMLEFT",-6,-5);
		else
			FloatingBattlePetTooltip:SetSize(260,164);
			FloatingBattlePetTooltip.Delimiter:ClearAllPoints();
			FloatingBattlePetTooltip.Delimiter:SetPoint("TOPLEFT",FloatingBattlePetTooltip.SpeedTexture,"BOTTOMLEFT",-6,-19);
		end

		FloatingBattlePetTooltip:Show();
	end
end

function BattlePetTooltip_OnLoad(self)
	local subLayer = 0;
	self.linePool = CreateFontStringPool(self, "ARTWORK", subLayer, "GameTooltipText");
	self.AddLine = BattlePetTooltipTemplate_AddTextLine;
end

function BattlePetTooltipTemplate_SetBattlePet(tooltipFrame, data)
	tooltipFrame.battlePetID = data.battlePetID;
	tooltipFrame.speciesID = data.speciesID; -- For the button
	tooltipFrame.Name:SetText(data.name);
	if (data.breedQuality ~= -1) then
		tooltipFrame.Name:SetTextColor(ITEM_QUALITY_COLORS[data.breedQuality].r, ITEM_QUALITY_COLORS[data.breedQuality].g, ITEM_QUALITY_COLORS[data.breedQuality].b);
	else
		tooltipFrame.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	tooltipFrame.PetType:SetText(_G["BATTLE_PET_NAME_"..data.petType]);
	tooltipFrame.Level:SetFormattedText(BATTLE_PET_CAGE_TOOLTIP_LEVEL, data.level);
	tooltipFrame.Health:SetText(data.maxHealth);
	tooltipFrame.Power:SetText(data.power);
	tooltipFrame.Speed:SetText(data.speed);
	tooltipFrame.PetTypeTexture:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[data.petType]);

	tooltipFrame.linePool:ReleaseAll();
	tooltipFrame.textLineAnchor = nil;
end

local LinePadding = 2;
function BattlePetTooltipTemplate_AddTextLine(self, text, r, g, b, wrap)
	if not r then
		r, g, b = NORMAL_FONT_COLOR:GetRGB();
	end
	
	local anchor = self.textLineAnchor;
	if not anchor then
		if self.JournalClick and self.JournalClick:IsShown() then
			anchor = self.JournalClick;
		elseif self.Owned:IsShown() and self.Owned:GetText() ~= nil then
			anchor = self.Owned;
		else
			anchor = self.SpeedTexture;
		end
	end

	local line = self.linePool:Acquire();
	line:SetText(text);
	line:SetTextColor(r, g, b);
	line:SetPoint("TOP", anchor, "BOTTOM", 0, -LinePadding);
	line:SetPoint("LEFT", self.Name, "LEFT");

	if wrap then
		line:SetPoint("RIGHT", self, "RIGHT");
	end

	line:Show();

	self.textLineAnchor = line;

	self:SetHeight(self:GetHeight() + line:GetHeight() + LinePadding);
end

function BattlePetTooltipJournalClick_OnClick(self)
	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
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

