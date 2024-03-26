GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH = 180;

UNDERBIASED_REASON_NOT_UNDERBIASED = 0;
UNDERBIASED_REASON_ITEMLEVEL = 1;
UNDERBIASED_REASON_LEVEL = 2;
UNDERBIASED_REASON_BOTH = 3;
-------------------------------------------
local GARRISON_FOLLOWER_FLOATING_TOOLTIP = {};

function FloatingGarrisonFollower_Toggle(garrisonFollowerID, quality, level, itemLevel, spec1, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4)
	local followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID);
	local floatingTooltip = FloatingGarrisonFollowerTooltip;
	if (followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
		floatingTooltip = FloatingGarrisonShipyardFollowerTooltip;
	end
	if ( floatingTooltip:IsShown() and
		floatingTooltip.garrisonFollowerID == garrisonFollowerID) then
		floatingTooltip:Hide();
	else
		FloatingGarrisonFollower_Show(floatingTooltip, garrisonFollowerID, followerTypeID, quality, level, itemLevel, spec1, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4);
	end
end

function FloatingGarrisonFollower_Show(floatingTooltip, garrisonFollowerID, followerTypeID, quality, level, itemLevel, spec1, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4)
	if (garrisonFollowerID and garrisonFollowerID > 0) then
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.garrisonFollowerID = garrisonFollowerID;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.followerTypeID = followerTypeID;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.collected = false;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.hyperlink = true;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.name = C_Garrison.GetFollowerNameByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.quality = quality;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.level = level;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.xp = 0;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.levelxp = 0;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.iLevel = itemLevel;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.spec1 = spec1;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability1 = ability1;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability2 = ability2;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability3 = ability3;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability4 = ability4;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait1 = trait1;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait2 = trait2;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait3 = trait3;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait4 = trait4;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.isTroop = C_Garrison.GetFollowerIsTroop(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.autoCombatSpells = GarrAutoCombatUtil.GetFollowerAutoCombatSpells(garrisonFollowerID, level, true --[[ includeAutoAttack ]]);

		if (followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
			GarrisonFollowerTooltipTemplate_SetShipyardFollower(floatingTooltip, GARRISON_FOLLOWER_FLOATING_TOOLTIP);
		else
			GarrisonFollowerTooltipTemplate_SetGarrisonFollower(floatingTooltip, GARRISON_FOLLOWER_FLOATING_TOOLTIP);
		end
		floatingTooltip:Show();
	end
end

function GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltipFrame, data, xpWidth)
	tooltipFrame.garrisonFollowerID = data.garrisonFollowerID;
	tooltipFrame.name = data.name;
	tooltipFrame.Name:SetText(data.name);
	tooltipFrame.ILevel:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, data.iLevel);
	tooltipFrame.PortraitFrame:SetupPortrait(data, false);

	local isAutoCombatant = data.followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower;

	if ( data.spec ) then
		local classSpecName = C_Garrison.GetFollowerClassSpecName(data.garrisonFollowerID);
		tooltipFrame.ClassSpecName:SetText(classSpecName);
		local classSpecAtlas = C_Garrison.GetFollowerClassSpecAtlas(data.spec);
		if (classSpecAtlas) then
			tooltipFrame.Class:SetAtlas(classSpecAtlas);
		else
			tooltipFrame.Class:SetTexture(nil);
		end
	end

	if (not data.collected or data.isTroop) then
		tooltipFrame.ILevel:Hide();
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	elseif (data.isMaxLevel and data.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY[data.followerTypeID]) then
		tooltipFrame.ILevel:Show();
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	else
		tooltipFrame.ILevel:Hide();
		if (data.isMaxLevel) then
			tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_UPGRADE_XP, data.levelxp - data.xp);
		else
			tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_XP, data.levelxp - data.xp);
		end

		if (not xpWidth) then
			xpWidth = GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH;
		end
		tooltipFrame.XPBar:SetWidth(PercentageBetween(data.xp, 0, data.levelxp) * xpWidth);

		tooltipFrame.XPBarBackground:SetPoint("TOPLEFT", tooltipFrame.ClassSpecName, "BOTTOMLEFT", 0, -10);
		tooltipFrame.XPBar:SetPoint("TOPLEFT", tooltipFrame.ClassSpecName, "BOTTOMLEFT", 0, -10);

		if (data.xp == 0) then
			tooltipFrame.XPBar:Hide()
			tooltipFrame.XPBarBackground:Hide();
			tooltipFrame.XP:Hide();
		else
			tooltipFrame.XPBar:Show();
			tooltipFrame.XPBarBackground:Show();
			tooltipFrame.XP:Show();
		end
	end

	tooltipFrame.PortraitFrame:SetShown(not isAutoCombatant);
	tooltipFrame.Class:SetShown(not isAutoCombatant);

	local tooltipFrameHeightBase = isAutoCombatant and 27 or 80;	-- this is the tooltip frame height w/ no abilities/traits being displayed

	if isAutoCombatant then	
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();

		tooltipFrame.Name:SetPoint("TOPLEFT", 16, -15);
		tooltipFrame.ClassSpecName:SetPoint("TOPLEFT", tooltipFrame.Name, "BOTTOMLEFT", 0, -2);

		tooltipFrameHeightBase = tooltipFrameHeightBase + tooltipFrame.Name:GetHeight() + tooltipFrame.ClassSpecName:GetHeight();

		tooltipFrame.XP:SetPoint("TOPLEFT", tooltipFrame.ClassSpecName, "BOTTOMLEFT", 0, -2);
		tooltipFrame.XP:SetJustifyH("LEFT");

		if tooltipFrame.XP:IsShown() then
			tooltipFrameHeightBase = tooltipFrameHeightBase + tooltipFrame.XP:GetHeight() + 2;
		end
	else
		tooltipFrame.Name:SetPoint("TOPLEFT", 66, -10);
		tooltipFrame.ClassSpecName:SetPoint("TOPLEFT", tooltipFrame.Name, "BOTTOMLEFT", 0, -2);
		tooltipFrame.XP:SetPoint("TOPLEFT", tooltipFrame.XPBarBackground, "BOTTOMLEFT", 0, -3);
		tooltipFrame.XP:SetJustifyH("CENTER");
	end

	local abilities = {data.ability1, data.ability2, data.ability3, data.ability4};
	local traits = {data.trait1, data.trait2, data.trait3, data.trait4};
	local specializations = {data.spec1};

	local validAbilities = GarrisonFollowerTooltipTemplate_GetValidAbilities(abilities);
	local abilityCount = #validAbilities;

	local traitCount = 0;
	if (data.trait1 ~= 0 and data.trait1 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait2 ~= 0 and data.trait2 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait3 ~= 0 and data.trait3 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait4 ~= 0 and data.trait4 ~= nil) then traitCount = traitCount + 1 end;

	local validSpecializations = GarrisonFollowerTooltipTemplate_GetValidAbilities(specializations);
	local specializationCount = #validSpecializations;

	local detailed = not data.noAbilityDescriptions;
	
	local abilityTemplate = "GarrisonFollowerAbilityTemplate";

	local abilityOffset = 10;																	-- distance between ability entries
	local abilityFrameHeightBase = 20;															-- ability frame height w/ no description/details being displayed
	local spacingBetweenLabelAndFirstAbility = 8;												-- distance between the "Abilities" label and the first ability below it
	local spacingBetweenNameAndDescription = 4;													-- must match the XML ability template setting
	local spacingBetweenDescriptionAndDetails = 8;												-- must match the XML ability template setting
	local spacingBeforeUnderBiasedString = 10;

	local tooltipFrameHeight = tooltipFrameHeightBase;
	tooltipFrame:SetSize(260, tooltipFrameHeight);

	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
		local qualityColor = data.quality;
		if ( qualityColor == Enum.GarrFollowerQuality.Title ) then
			qualityColor = Enum.GarrFollowerQuality.Epic;
		end
		tooltipFrame.Quality:SetText(_G["ITEM_QUALITY"..qualityColor.."_DESC"]);
		tooltipFrame.Quality:Show();
		tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", 15, -90);
		tooltipFrameHeight = tooltipFrameHeight + 5;
	else
		tooltipFrame.Quality:Hide();
		tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", 15, -85);
	end	
	
	if specializationCount > 0 then
		tooltipFrame.SpecializationLabel:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 15, -tooltipFrameHeightBase -5);
		tooltipFrameHeight = tooltipFrameHeight + tooltipFrame.SpecializationLabel:GetHeight() + abilityOffset;
		tooltipFrame.SpecializationLabel:Show();
	else
		tooltipFrame.SpecializationLabel:Hide();
	end

	for i = 1, #tooltipFrame.Abilities do
		tooltipFrame.Abilities[i]:Hide();
	end

	for i=1, specializationCount do
		if (not tooltipFrame.Abilities[i]) then
			tooltipFrame.Abilities[i] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end		

		if i == 1 then
			tooltipFrame.Abilities[i]:SetPoint("TOPLEFT", tooltipFrame.SpecializationLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Abilities[i]:SetPoint("TOPLEFT", tooltipFrame.Abilities[i-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end
				
		local Ability = tooltipFrame.Abilities[i];
		GarrisonFollowerTooltipTemplate_SetAbility(Ability, validSpecializations[i], detailed, data.followerTypeID);
		Ability.CounterIconBorder:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
		tooltipFrameHeight = tooltipFrameHeight + Ability:GetHeight();
	end

	local includeAutoAttack = true;
	local autoSpells = GarrAutoCombatUtil.GetFollowerAutoCombatSpells(data.garrisonFollowerID, data.level, includeAutoAttack);
	local autoSpellCount = autoSpells and #autoSpells or 0;

	if abilityCount > 0 or autoSpellCount > 0 then 
		if specializationCount > 0 then
			tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", tooltipFrame.Abilities[specializationCount], "BOTTOMLEFT", 0, -abilityOffset);
		else
			tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 15, -tooltipFrameHeightBase -5);
		end

		tooltipFrameHeight = tooltipFrameHeight + tooltipFrame.AbilitiesLabel:GetHeight() + abilityOffset;
		tooltipFrame.AbilitiesLabel:Show();
	else
		tooltipFrame.AbilitiesLabel:Hide();
	end
	
	for abilityIndex=1, abilityCount do
		local effectiveAbilityIndex = abilityIndex + specializationCount;
		if (not tooltipFrame.Abilities[effectiveAbilityIndex]) then
			tooltipFrame.Abilities[effectiveAbilityIndex] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end		

		if abilityIndex == 1 then
			tooltipFrame.Abilities[effectiveAbilityIndex]:SetPoint("TOPLEFT", tooltipFrame.AbilitiesLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Abilities[effectiveAbilityIndex]:SetPoint("TOPLEFT", tooltipFrame.Abilities[effectiveAbilityIndex-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end
				
		local Ability = tooltipFrame.Abilities[effectiveAbilityIndex];
		GarrisonFollowerTooltipTemplate_SetAbility(Ability, validAbilities[abilityIndex], detailed, data.followerTypeID);
		Ability.CounterIconBorder:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
		tooltipFrameHeight = tooltipFrameHeight + Ability:GetHeight();
	end

	for autoSpellIndex = 1, autoSpellCount do
		local effectiveAbilityIndex = specializationCount + abilityCount + autoSpellIndex;
		if (not tooltipFrame.Abilities[effectiveAbilityIndex]) then
			tooltipFrame.Abilities[effectiveAbilityIndex] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end	

		local totalAbilityPlusIndex = abilityCount + autoSpellIndex;

		if  totalAbilityPlusIndex == 1 then
			tooltipFrame.Abilities[effectiveAbilityIndex]:SetPoint("TOPLEFT", tooltipFrame.AbilitiesLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Abilities[effectiveAbilityIndex]:SetPoint("TOPLEFT", tooltipFrame.Abilities[effectiveAbilityIndex-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end
				
		local ability = tooltipFrame.Abilities[effectiveAbilityIndex];
		GarrisonFollowerTooltipTemplate_SetAutoSpell(ability, autoSpells[autoSpellIndex]);
		ability.CounterIconBorder:Hide();
		tooltipFrameHeight = tooltipFrameHeight + ability:GetHeight();
	end
		
	if traitCount > 0 then 
		if (abilityCount + specializationCount) > 0 then
			tooltipFrame.TraitsLabel:SetPoint("TOPLEFT", tooltipFrame.Abilities[abilityCount + specializationCount], "BOTTOMLEFT", 0, -abilityOffset);
		else
			tooltipFrame.TraitsLabel:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 15, -tooltipFrameHeightBase -5);
		end
		tooltipFrame.TraitsLabel:SetText(GarrisonFollowerOptions[data.followerTypeID].strings.TRAITS_LABEL);
		tooltipFrameHeight = tooltipFrameHeight + tooltipFrame.TraitsLabel:GetHeight();
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		tooltipFrame.TraitsLabel:Show();
	else
		tooltipFrame.TraitsLabel:Hide();
	end

	for i = 1, #tooltipFrame.Traits do
		tooltipFrame.Traits[i]:Hide();
	end
	
	for i = 1, traitCount do
		if (not tooltipFrame.Traits[i]) then
			tooltipFrame.Traits[i] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end

		if i== 1 then
			tooltipFrame.Traits[i]:SetPoint("TOPLEFT", tooltipFrame.TraitsLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Traits[i]:SetPoint("TOPLEFT", tooltipFrame.Traits[i-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end

		local Trait = tooltipFrame.Traits[i];

		Trait.Name:SetText(C_Garrison.GetFollowerAbilityName(traits[i]));
		Trait.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(traits[i]));

		Trait:SetHeight(abilityFrameHeightBase);

		-- hide ability only controls
		Trait.CounterIcon:Hide();
		Trait.CounterIconBorder:Hide();

		if detailed then
			Trait.Description:Show();

			local description = C_Garrison.GetFollowerAbilityDescription(traits[i]);
			if string.len(description) == 0 then description = "PH - Description Missing"; end
			Trait.Description:SetText(description);
			
			Trait:SetHeight(Trait:GetHeight() + Trait.Description:GetHeight() + spacingBetweenNameAndDescription);

			local details = ""; --this is not data driven right now, but design may want to add a new field to garrison abilities for this
			if string.len(details) == 0 then
				Trait.Details:Hide();
			else
				Trait.Details:SetText(details);
				Trait.Details:Show();
				Trait:SetHeight(Trait:GetHeight() + Trait.Details:GetHeight() + spacingBetweenDescriptionAndDetails);
			end
		else
			Trait.Description:Hide();
			Trait.Details:Hide();
		end

		Trait:Show();
				
		tooltipFrameHeight = tooltipFrameHeight + Trait:GetHeight();
	end

	if ( not isAutoCombatant and not detailed ) then
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
	end

	if ( data.underBiased ) then
		if ( data.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY[data.followerTypeID] ) then
			tooltipFrame.UnderBiased:SetText(GARRISON_FOLLOWER_BELOW_LEVEL_MAX_XP_TOOLTIP);
		elseif(data.underBiasedReason == UNDERBIASED_REASON_ITEMLEVEL) then
			tooltipFrame.UnderBiased:SetText(GARRISON_FOLLOWER_BELOW_ITEM_LEVEL_TOOLTIP);
		elseif(data.underBiasedReason == UNDERBIASED_REASON_LEVEL) then
			tooltipFrame.UnderBiased:SetText(GARRISON_FOLLOWER_BELOW_LEVEL_TOOLTIP);
		end

		if ( traitCount > 0 ) then
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.Traits[traitCount], "BOTTOMLEFT", 0, -spacingBeforeUnderBiasedString);
		elseif ( abilityCount > 0 ) then
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.Abilities[abilityCount + specializationCount], "BOTTOMLEFT", 0, -spacingBeforeUnderBiasedString);
		elseif ( specializationCount > 0 ) then
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.Abilities[specializationCount], "BOTTOMLEFT", 0, -spacingBeforeUnderBiasedString);
		else
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.AbilitiesLabel, "TOPLEFT", 0, -spacingBeforeUnderBiasedString);
		end
		tooltipFrame.UnderBiased:Show();
		tooltipFrameHeight = tooltipFrameHeight + spacingBeforeUnderBiasedString + tooltipFrame.UnderBiased:GetHeight();
	else
		tooltipFrame.UnderBiased:Hide();
	end

	tooltipFrame:SetSize(260, tooltipFrameHeight + 10);
end

function GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltipFrame, data, xpWidth)
	tooltipFrame.garrisonFollowerID = data.garrisonFollowerID;
	tooltipFrame.name = data.name;
	
	local color = FOLLOWER_QUALITY_COLORS[data.quality];
	tooltipFrame.Name:SetText(data.name);
	tooltipFrame.Name:SetTextColor(color.r, color.g, color.b);
	local bottomWidget = tooltipFrame.Name;
	if ( data.spec ) then
		local classSpecName = C_Garrison.GetFollowerClassSpecName(data.garrisonFollowerID);
		tooltipFrame.ClassSpecName:SetText(classSpecName);
		bottomWidget = tooltipFrame.ClassSpecName;
	end

	local tooltipFrameHeightBase = 40;		-- this is the tooltip frame height w/ no abilities/traits being displayed
	local tooltipFrameHeight = tooltipFrameHeightBase;
	if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
		local qualityColor = data.quality;
		if ( qualityColor == Enum.GarrFollowerQuality.Title ) then
			qualityColor = Enum.GarrFollowerQuality.Epic;
		end
		tooltipFrame.Quality:SetText(_G["ITEM_QUALITY"..qualityColor.."_DESC"]);
		tooltipFrame.Quality:Show();
		tooltipFrameHeight = tooltipFrameHeight + 15;
		tooltipFrame.XPBar:SetPoint("TOPLEFT", 15, -70);
		bottomWidget = tooltipFrame.Quality;
	else
		tooltipFrame.Quality:Hide();
	end

	if (not data.collected) then
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	elseif (data.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY[data.followerTypeID]) then
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	else
		tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_UPGRADE_XP, data.levelxp - data.xp);
		tooltipFrame.XP:Show();
		if (not xpWidth) then
			xpWidth = GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH;
		end
		tooltipFrame.XPBar:SetWidth(PercentageBetween(data.xp, 0, data.levelxp) * xpWidth);
		if (data.xp == 0) then
			tooltipFrame.XPBar:Hide()
		else
			tooltipFrame.XPBar:Show();
		end
		tooltipFrame.XPBarBackground:Show();
		bottomWidget = tooltipFrame.XP;
	end
	
	local properties = { data.trait1,  data.trait2, data.ability1, data.ability2};
	local validProperties = GarrisonFollowerTooltipTemplate_GetValidAbilities(properties);
	local propertyCount = #validProperties;
	local detailed = not data.noAbilityDescriptions;
	
	if (tooltipFrame.XP:IsShown()) then
		tooltipFrameHeight = tooltipFrameHeight + 30;
	end
	tooltipFrame:SetSize(260, tooltipFrameHeight);
	
	local abilityOffset = 10;				-- distance between ability entries
	if propertyCount > 0 then 
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
	end
	
	for i = 1, #tooltipFrame.Properties do
		tooltipFrame.Properties[i]:Hide();
	end

	for i=1, propertyCount do
		local property = tooltipFrame.Properties[i];
		if (i == 1) then
			property:SetPoint("TOPLEFT", bottomWidget, "BOTTOMLEFT", 2, -10);
		end
		GarrisonFollowerTooltipTemplate_SetAbility(property, validProperties[i], detailed, data.followerTypeID);
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		tooltipFrameHeight = tooltipFrameHeight + property:GetHeight();
		
		local abilityCounterFactor = select(4, C_Garrison.GetFollowerAbilityCounterMechanicInfo(properties[i]));
		if ( not abilityCounterFactor or abilityCounterFactor > GARRISON_HIGH_THREAT_VALUE ) then
			property.CounterIconBorder:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
		else
			property.CounterIconBorder:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
		end
	end

	tooltipFrame:SetSize(260, tooltipFrameHeight + 10);
end

function GarrisonFollowerTooltipTemplate_GetValidAbilities(abilities)
	local validAbilities = {};
	for i=1, #abilities do
		if (abilities[i] ~= 0 and abilities[i] ~= nil) then
			local abilityInfo = C_Garrison.GetFollowerAbilityInfo(abilities[i]);
			if (abilityInfo) then
				table.insert(validAbilities, abilityInfo);
			end
		end
	end
	return validAbilities;
end

function GarrisonFollowerTooltipTemplate_SetAbility(Ability, ability, detailed, followerTypeID)
	Ability.Name:SetText(ability.name);
	Ability.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	Ability.Icon:SetTexture(ability.icon);
	Ability.Border:SetShown(ShouldShowFollowerAbilityBorder(followerTypeID, ability));
	Ability:SetHeight(Ability.Name:GetHeight() + 10);	-- ability frame height w/ no description/details being displayed

	local spacingBetweenNameAndDescription = 4;			-- must match the XML ability template setting
	local spacingBetweenDescriptionAndDetails = 8;		-- must match the XML ability template setting

	Ability.Description:Hide();
	Ability.Details:Hide();
	Ability.CounterIcon:Hide();
	Ability.CounterIconBorder:Hide();
	if detailed then
		local description = ability.description;
		if string.len(description) == 0 then description = "PH - Description Missing"; end
	
		Ability.Description:SetText(description);
		Ability.Description:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		Ability.Description:Show();
		Ability:SetHeight(Ability:GetHeight() + Ability.Description:GetHeight() + spacingBetweenNameAndDescription);
		local abilityCounterMechanicID, abilityCounterMechanicName, abilityCounterMechanicIcon = C_Garrison.GetFollowerAbilityCounterMechanicInfo(ability.id);
		if (abilityCounterMechanicName and abilityCounterMechanicIcon and not GarrisonFollowerOptions[followerTypeID].hideCountersInAbilityFrame) then
			Ability.Details:SetFormattedText(GARRISON_ABILITY_COUNTERS_FORMAT, abilityCounterMechanicName);
			Ability.Details:Show();
			Ability:SetHeight(Ability:GetHeight() + Ability.Details:GetHeight() + spacingBetweenDescriptionAndDetails);

			Ability.CounterIcon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Ability.CounterIcon:SetTexture(abilityCounterMechanicIcon);
			Ability.CounterIcon:Show();
			Ability.CounterIconBorder:Show();
		end
	end

	Ability:Show();
end

function GarrisonFollowerTooltipTemplate_SetAutoSpell(frame, autoSpell)
	local spacingBetweenNameAndDescription = 4;	
	
	frame.Name:SetText(autoSpell.name);
	frame.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	frame.Icon:SetTexture(autoSpell.icon);
	frame:SetHeight(frame.Name:GetHeight() + 10);
	frame.Details:Hide();
	frame.CounterIcon:Hide();
	frame.CounterIconBorder:Hide();
	local fullDescription = "";
	if autoSpell.cooldown > 0 then
		fullDescription = COVENANT_MISSIONS_COOLDOWN:format(autoSpell.cooldown) .. "\n";
	end
	fullDescription = fullDescription .. autoSpell.description;
	frame.Description:SetText(fullDescription);
	frame.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	frame.Description:Show();
	frame:SetHeight(frame:GetHeight() + frame.Description:GetHeight() + spacingBetweenNameAndDescription);

	frame:Show();
end

function FloatingGarrisonFollowerAbility_Toggle(garrFollowerAbilityID)
	if ( FloatingGarrisonFollowerAbilityTooltip:IsShown() and
		FloatingGarrisonFollowerAbilityTooltip.garrFollowerAbilityID == garrFollowerAbilityID) then
		FloatingGarrisonFollowerAbilityTooltip:Hide();
	else
		FloatingGarrisonFollowerAbility_Show(garrFollowerAbilityID);
	end
end

function FloatingGarrisonFollowerAbility_Show(garrFollowerAbilityID)
	GarrisonFollowerAbilityTooltipTemplate_SetAbility(FloatingGarrisonFollowerAbilityTooltip, garrFollowerAbilityID, Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower)
end

function GarrisonFollowerAbilityTooltipTemplate_SetAbility(tooltipFrame, garrFollowerAbilityID, followerTypeID)
	if (garrFollowerAbilityID and garrFollowerAbilityID > 0)  then
		tooltipFrame.garrFollowerAbilityID = garrFollowerAbilityID;
		tooltipFrame:Show();
		
		local info = C_Garrison.GetFollowerAbilityInfo(garrFollowerAbilityID);
		tooltipFrame.Name:SetText(info.name);

		if (tooltipFrame.AbilityBorder) then
			tooltipFrame.AbilityBorder:SetShown(ShouldShowFollowerAbilityBorder(followerTypeID, info));
		end

		if (info.icon) then
			tooltipFrame.Icon:SetTexture(info.icon);
			if (tooltipFrame.AbilityBorder and tooltipFrame.AbilityBorder:IsShown()) then
				tooltipFrame.Name:SetPoint("LEFT", tooltipFrame.AbilityBorder, "RIGHT", 2, 0);
			else
				tooltipFrame.Name:SetPoint("LEFT", tooltipFrame.Icon, "RIGHT", 6, 0);
			end
			tooltipFrame.Icon:Show();
		else
			tooltipFrame.Name:SetPoint("LEFT", tooltipFrame.Icon, "LEFT");
			tooltipFrame.Icon:Hide();
		end


		local headerHeight = tooltipFrame.Header and tooltipFrame.Header:GetHeight() or 0;
		tooltipFrame:SetHeight(headerHeight + tooltipFrame.abilityFrameHeightBase + tooltipFrame.Name:GetHeight());
		
		local description = info.description;
		if (tooltipFrame.extraDescriptionText) then
			description = description..tooltipFrame.extraDescriptionText;
		end
		tooltipFrame.Description:Show();
		tooltipFrame.Description:SetText(description);
		tooltipFrame:SetHeight(tooltipFrame:GetHeight() + tooltipFrame.Description:GetHeight() + tooltipFrame.spacingBetweenNameAndDescription);
		
		if (tooltipFrame.CountersLabel) then
			local abilityCounterMechanicID, abilityCounterMechanicName, abilityCounterMechanicIcon, abilityCounterFactor = C_Garrison.GetFollowerAbilityCounterMechanicInfo(garrFollowerAbilityID);
			if (abilityCounterMechanicName and abilityCounterMechanicIcon) then
				tooltipFrame.CountersLabel:Show();
				tooltipFrame.Details:Show();
				tooltipFrame.Details:SetText(abilityCounterMechanicName);
				tooltipFrame:SetHeight(tooltipFrame:GetHeight() + tooltipFrame.Details:GetHeight() + tooltipFrame.CountersLabel:GetHeight() + tooltipFrame.spacingBetweenDescriptionAndDetails * 2);
				tooltipFrame.CounterIcon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				tooltipFrame.CounterIcon:SetTexture(abilityCounterMechanicIcon);
				tooltipFrame.CounterIcon:Show();
				tooltipFrame.CounterIconBorder:Show();
				if ( abilityCounterFactor <= GARRISON_HIGH_THREAT_VALUE and followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat ) then
					tooltipFrame.CounterIconBorder:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
				else
					tooltipFrame.CounterIconBorder:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
				end
				tooltipFrame.Details:SetPoint("TOPLEFT", tooltipFrame.CounterIcon, "TOPRIGHT", 8, -1);
			else
				tooltipFrame.CountersLabel:Hide();
				tooltipFrame.Details:Hide();
				tooltipFrame.CounterIcon:Hide();
				tooltipFrame.CounterIconBorder:Hide();
			end
		end
	end
end

function FloatingGarrisonMission_Toggle(garrMissionID, garrMissionDBID)
	if ( FloatingGarrisonMissionTooltip:IsShown() and
		FloatingGarrisonMissionTooltip.garrMissionID == garrMissionID and
		FloatingGarrisonMissionTooltip.garrMissionDBID == garrMissionDBID) then
		FloatingGarrisonMissionTooltip:Hide();
	else
		FloatingGarrisonMission_Show(garrMissionID, garrMissionDBID);
	end
end

function FloatingGarrisonMission_Show(garrMissionID, garrMissionDBID)
	FloatingGarrisonMissionTooltip:Show();
	FloatingGarrisonMissionTooltip.garrMissionID = garrMissionID;
	FloatingGarrisonMissionTooltip.garrMissionDBID = garrMissionDBID;
	FloatingGarrisonMissionTooltip.Name:SetText(C_Garrison.GetMissionName(garrMissionID));
	local followerTypeID = C_Garrison.GetFollowerTypeByMissionID(garrMissionID);
	if (followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
		FloatingGarrisonMissionTooltip.FollowerRequirement:SetFormattedText(GARRISON_SHIPYARD_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, C_Garrison.GetMissionMaxFollowers(garrMissionID), 1, 1, 1);
	elseif followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower then
		FloatingGarrisonMissionTooltip.FollowerRequirement:SetText(COVENANT_MISSIONS_COVENANT_ADVENTURE, WHITE_FONT_COLOR);
	else
		FloatingGarrisonMissionTooltip.FollowerRequirement:SetFormattedText(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, C_Garrison.GetMissionMaxFollowers(garrMissionID), 1, 1, 1);
	end
	
	local rewards = C_Garrison.GetMissionRewardInfo(garrMissionID, garrMissionDBID);
	local rewardText = "";
	
	local missionFrameHeightBase = 70;
	FloatingGarrisonMissionTooltip:SetHeight(missionFrameHeightBase);

	if (rewards) then
		for id, reward in pairs(rewards) do
			if string.len(rewardText) > 0 then
				rewardText = rewardText.."\n";
			end

			if (reward.quality) then
				rewardText = rewardText..ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE;
			elseif (reward.itemID) then 
				local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(reward.itemID);
				if itemName then
					rewardText = rewardText..ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE;
				else  
					rewardText = RED_FONT_COLOR:GenerateHexColorMarkup()..RETRIEVING_DATA..FONT_COLOR_CODE_CLOSE;
				end
			elseif (reward.followerXP) then
				rewardText = rewardText..reward.title;
			elseif (reward.bonusAbilityID) then
				rewardText = rewardText..reward.name;
			else
				rewardText = rewardText..reward.title;
			end
		end
	else
		rewardText = RED_FONT_COLOR:GenerateHexColorMarkup()..RETRIEVING_DATA..FONT_COLOR_CODE_CLOSE;
	end
	
	FloatingGarrisonMissionTooltip.Rewards:SetText(rewardText, 1, 1, 1);
	FloatingGarrisonMissionTooltip:SetHeight(FloatingGarrisonMissionTooltip:GetHeight() + FloatingGarrisonMissionTooltip.Rewards:GetHeight());
end

function FloatingGarrisonMissionTooltip_OnShow(self)
	self:RegisterEvent("GARRISON_MISSION_REWARD_INFO");
end

function FloatingGarrisonMissionTooltip_OnHide(self)
	self:UnregisterEvent("GARRISON_MISSION_REWARD_INFO");
end

function FloatingGarrisonMissionTooltip_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_REWARD_INFO") then
		local garrMissionID, garrMissionDBID = ...;
		if (garrMissionID == self.garrMissionID and garrMissionDBID == self.garrMissionDBID) then
			FloatingGarrisonMission_Show(self.garrMissionID, self.garrMissionDBID);
		end
	end
end
