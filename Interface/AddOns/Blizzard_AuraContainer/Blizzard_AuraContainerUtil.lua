AuraContainerUtil = {};

function AuraContainerUtil.ShouldIncludeAuraForFilterString(unitToken, auraData, filterString)
	if auraData.isPrivate then
		return not C_UnitAurasPrivate.IsPrivateAuraFilteredOutByInstanceID(unitToken, auraData.auraInstanceID, filterString);
	end

	return not C_UnitAuras.IsAuraFilteredOutByInstanceID(unitToken, auraData.auraInstanceID, filterString);
end

function AuraContainerUtil.CanApplyIdentityCandidateFilters(unitToken, auraData)
	-- We don't want to permit certain types of filters based on the type
	-- of aura being evaluated and the reaction of the unit to the player;
	-- for example, it shouldn't be possible to filter out debuffs on player
	-- targets because that would allow for extremely specific displays of
	-- exact text ("Move now!") if encounter-specific debuffs are applied to
	-- the player.
	--
	-- Spells flagged as never-secret are exempt from this restriction; this
	-- allows noisy debuffs (Exhaustion/Sated) to be filtered out on friendly
	-- units.

	if auraData.spellId and C_Secrets.GetSpellAuraSecrecy(auraData.spellId) == Enum.SecrecyLevel.NeverSecret then
		return true;
	end

	if auraData.isHarmful and UnitCanAssist("player", unitToken) then
		return false;
	end

	if auraData.isHelpful and not UnitCanAssist("player", unitToken) then
		return false;
	end

	return true;
end

function AuraContainerUtil.DoesAuraPassCandidateFilters(unitToken, auraData, candidateFilters)
	if candidateFilters == nil then
		return true;
	end

	if AuraContainerUtil.CanApplyIdentityCandidateFilters(unitToken, auraData) then
		if candidateFilters.excludeSpellIDs ~= nil then
			if candidateFilters.excludeSpellIDs[auraData.spellId] then
				return false;
			end
		end

		if candidateFilters.includeSpellIDs ~= nil then
			if not candidateFilters.includeSpellIDs[auraData.spellId] then
				return false;
			end
		end
	end

	if candidateFilters.processedAuraType ~= nil and auraData.processedAuraType ~= candidateFilters.processedAuraType then
		return false;
	end

	if candidateFilters.excludeDispelTypes ~= nil then
		if candidateFilters.excludeDispelTypes[auraData.dispelName] then
			return false;
		end
	end

	if candidateFilters.includeDispelTypes ~= nil then
		if not candidateFilters.includeDispelTypes[auraData.dispelName] then
			return false;
		end
	end

	if (candidateFilters.canApplyAura ~= nil) and (auraData.canApplyAura ~= candidateFilters.canApplyAura) then
		return false;
	end

	if (candidateFilters.isBossAura ~= nil) and (auraData.isBossAura ~= candidateFilters.isBossAura) then
		return false;
	end

	if candidateFilters.isBossOrRoleAura ~= nil and ((auraData.isBossAura or AuraUtil.IsRoleAura(auraData)) ~= candidateFilters.isBossOrRoleAura) then
		return false;
	end

	if (candidateFilters.isFromPlayerOrPlayerPet ~= nil) and (auraData.isFromPlayerOrPlayerPet ~= candidateFilters.isFromPlayerOrPlayerPet) then
		return false;
	end

	if (candidateFilters.isRoleAura ~= nil) and (AuraUtil.IsRoleAura(auraData) ~= candidateFilters.isRoleAura) then
		return false;
	end

	if (candidateFilters.isPriorityAura ~= nil) and (AuraUtil.IsPriorityDebuff(auraData.spellId) ~= candidateFilters.isPriorityAura) then
		return false;
	end

	if (candidateFilters.isStealable ~= nil) and (auraData.isStealable ~= candidateFilters.isStealable) then
		return false;
	end

	if (candidateFilters.maxDuration ~= nil) then
		-- Max duration filters implicitly always filter out permanent auras.
		if auraData.duration > candidateFilters.maxDuration or auraData.duration == 0 then
			return false;
		end
	end

	if (candidateFilters.nameplateShowAll ~= nil) and (auraData.nameplateShowAll ~= candidateFilters.nameplateShowAll) then
		return false;
	end

	if (candidateFilters.nameplateShowPersonal ~= nil) and (auraData.nameplateShowPersonal ~= candidateFilters.nameplateShowPersonal) then
		return false;
	end

	return true;
end

local AuraContainerSortComparators =
{
	[AuraContainerSortMethod.Default] = AuraUtil.DefaultAuraCompare,
	[AuraContainerSortMethod.BigDefensive] = AuraUtil.BigDefensiveAuraCompare,
	[AuraContainerSortMethod.UnitFrameDebuff] = AuraUtil.UnitFrameDebuffComparator,
	[AuraContainerSortMethod.ImportantOnly] = AuraUtil.ImportantOnlyAuraCompare,
	[AuraContainerSortMethod.Expiration] = AuraUtil.ExpirationAuraCompare,
	[AuraContainerSortMethod.ExpirationOnly] = AuraUtil.ExpirationOnlyAuraCompare,
	[AuraContainerSortMethod.Name] = AuraUtil.NameAuraCompare,
	[AuraContainerSortMethod.NameOnly] = AuraUtil.NameOnlyAuraCompare,
};

function AuraContainerUtil.GetAuraSortComparator(sortMethod, sortDirection)
	local auraComparator = AuraContainerSortComparators[sortMethod];
	assert(auraComparator ~= nil, "sortMethod must have a comparator.");

	if sortDirection == AuraContainerSortDirection.Reverse then
		return function(auraA, auraB)
			-- Reverse direction is implemented by swapping comparison operands.
			return auraComparator(auraB, auraA);
		end;
	end

	return auraComparator;
end

function AuraContainerUtil.GetItemEnchantmentInventorySlot(itemEnchantmentSlot)
	return AuraContainerItemEnchantmentToInventorySlot[itemEnchantmentSlot];
end

function AuraContainerUtil.GetItemEnchantmentInfo(itemEnchantmentSlot)
	local inventorySlot = AuraContainerUtil.GetItemEnchantmentInventorySlot(itemEnchantmentSlot);

	if inventorySlot ~= nil then
		return C_PaperDollInfo.GetTemporaryEnchantmentInfo(inventorySlot);
	end

	return nil;
end

function AuraContainerUtil.GetItemEnchantmentSortOrder(itemEnchantment)
	return AuraContainerItemEnchantmentSortOrder[itemEnchantment:GetItemEnchantmentSlot()] or math.huge;
end

function AuraContainerUtil.GetItemEnchantmentDurationSortValue(itemEnchantment)
	if not itemEnchantment:HasExpirationTime() then
		return math.huge;
	end

	return itemEnchantment:GetRemainingTimeMs() or math.huge;
end

function AuraContainerUtil.CompareItemEnchantmentsBySlot(leftItemEnchantment, rightItemEnchantment)
	local leftSortOrder = AuraContainerUtil.GetItemEnchantmentSortOrder(leftItemEnchantment);
	local rightSortOrder = AuraContainerUtil.GetItemEnchantmentSortOrder(rightItemEnchantment);

	if leftSortOrder ~= rightSortOrder then
		return leftSortOrder < rightSortOrder;
	end

	return leftItemEnchantment:GetItemEnchantmentSlot() < rightItemEnchantment:GetItemEnchantmentSlot();
end

function AuraContainerUtil.CompareItemEnchantmentsByDuration(leftItemEnchantment, rightItemEnchantment)
	local leftDuration = AuraContainerUtil.GetItemEnchantmentDurationSortValue(leftItemEnchantment);
	local rightDuration = AuraContainerUtil.GetItemEnchantmentDurationSortValue(rightItemEnchantment);

	if leftDuration ~= rightDuration then
		return leftDuration < rightDuration;
	end

	return AuraContainerUtil.CompareItemEnchantmentsBySlot(leftItemEnchantment, rightItemEnchantment);
end

local ItemEnchantmentSortComparators =
{
	[AuraContainerItemEnchantmentSortMethod.Slot] = AuraContainerUtil.CompareItemEnchantmentsBySlot,
	[AuraContainerItemEnchantmentSortMethod.Duration] = AuraContainerUtil.CompareItemEnchantmentsByDuration,
};

function AuraContainerUtil.GetItemEnchantmentSortComparator(sortMethod, sortDirection)
	local comparator = ItemEnchantmentSortComparators[sortMethod];
	assert(comparator ~= nil, "sortMethod must have an item enchantment comparator.");

	if sortDirection == AuraContainerSortDirection.Reverse then
		return function(leftItemEnchantment, rightItemEnchantment)
			return comparator(rightItemEnchantment, leftItemEnchantment);
		end;
	end

	return comparator;
end

function AuraContainerUtil.SetIconTextureForAura(_auraButton, texture, auraData)
	local icon;

	if auraData then
		if auraData.icon then
			icon = auraData.icon;
		elseif auraData.inventorySlot then
			icon = GetInventoryItemTexture("player", auraData.inventorySlot);
		end
	end

	if not icon then
		icon = QUESTION_MARK_ICON;
	end

	texture:SetTexture(secretwrap(icon));
end

function AuraContainerUtil.SetSpellNameForAura(auraButton, fontString, auraData)
	local name;

	if auraData then
		if auraData.name then
			name = auraData.name;
		elseif auraData.inventorySlot then
			-- Sparse lookups may fail for inventory slot names in rare cases.
			local item = Item:CreateFromEquipmentSlot(auraData.inventorySlot);
			name = item:GetItemName();

			if name == nil then
				item:ContinueWithCancelOnItemLoad(function() auraButton:UpdateAuraDisplay(); end);
			end
		end
	end

	if not name then
		name = "";
	end

	fontString:SetText(secretwrap(name));
end
