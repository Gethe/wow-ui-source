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
	[AuraContainerSortMethod.AuraInstanceIDOnly] = AuraUtil.AuraInstanceIDOnlyAuraCompare,
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

function AuraContainerUtil.ValidateInboundScriptObject(object, owner, ...)
	if object:IsForbidden() then
		error(string.format("bad object '%s' in function call (must not be an explicitly forbidden object)", object:GetDebugName()));
	end

	local _isProtected, isProtectedExplicitly = object:IsProtected();
	if isProtectedExplicitly then
		error(string.format("bad object '%s' in function call (must not be an explicitly protected object)", object:GetDebugName()));
	end

	if not RegionUtil.IsDescendantOf(object, owner) then
		-- This additionally ensures that the inbound object inherits all
		-- required forbidden aspects that propagate through parent/child
		-- hierarchies.
		error(string.format("bad object '%s' in function call (must be a direct child or indirect descendent of owner)", object:GetDebugName()));
	end

	local function ApplyToForbiddenObject(validationFunc)
		validationFunc(object);
	end

	mapvalues(ApplyToForbiddenObject, ...);
end

function AuraContainerUtil.InitializeInboundScriptObject(object)
	object:AddForbiddenAspects(Enum.ForbiddenAspect.RemoveSecretAspects);
	object:AddForbiddenAspects(Enum.ForbiddenAspect.ChangeParent);
	return object;
end

function AuraContainerUtil.ApplyAccessRestrictions(object, restrictions)
	-- Access restrictions are applied in a deferred manner. If we've begun
	-- signaling the PLAYER_LOGIN event, apply them immediately - else,
	-- wait until PLAYER_ENTERING_WORLD to restrict them.
	--
	-- This allows user addons to set up aura buttons on login and UI reload
	-- and give them ample time to apply configuration through execution of
	-- PLAYER_LOGIN. We use PLAYER_ENTERING_WORLD for deferred restrictions
	-- to avoid racing our event handlers against theirs.
	
	if IsLoggedIn() then
		object:AddAccessRestrictions(restrictions);
		return;
	end

	EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function() object:AddAccessRestrictions(restrictions); end);
end

function AuraContainerUtil.GetDefaultTooltip()
	return AuraButtonTooltip;
end

function AuraContainerUtil.ClearTooltipStyle(tooltip)
	if tooltip.BackdropContainer then
		tooltip.BackdropContainer:SetBackdropBorderColor(1, 1, 1, 1);
		tooltip.BackdropContainer:SetBackdropColor(1, 1, 1, 1);
		tooltip.BackdropContainer:ClearBackdrop();
		tooltip.BackdropContainer:ClearAllPoints();
		tooltip.BackdropContainer:Hide();
	end

	if tooltip.TextureSliceBackground then
		tooltip.TextureSliceBackground:SetDrawLayer("BACKGROUND", 0);
		tooltip.TextureSliceBackground:SetVertexColor(1, 1, 1, 1);
		tooltip.TextureSliceBackground:SetTexture(nil);
		tooltip.TextureSliceBackground:ClearTextureSlice();
		tooltip.TextureSliceBackground:ClearAllPoints();
		tooltip.TextureSliceBackground:Hide();
	end

	-- It's possible for tooltip data to attempt to re-assign and replace
	-- nineslice layouts. We assume this probably won't happen for auras
	-- right now - but, if it does, we clear the anchors of the nineslice
	-- to at least ensure texture slice and backdrop-based styling doesn't
	-- run into issues.

	tooltip.NineSlice:SetBorderColor(1, 1, 1, 1);
	tooltip.NineSlice:SetCenterColor(1, 1, 1, 1);
	tooltip.NineSlice:ClearAllPoints();
	tooltip.NineSlice:Hide();
end

function AuraContainerUtil.SetTooltipNineSlice(options)
	options = C_AuraContainerUtil.ProcessAuraTooltipNineSliceOptions(securecopy(options));

	local tooltip = AuraContainerUtil.GetDefaultTooltip();
	AuraContainerUtil.ClearTooltipStyle(tooltip);

	tooltip.NineSlice:ClearAllPoints();
	tooltip.NineSlice:SetPoint("TOPLEFT", tooltip, options.anchorOffsets.left, options.anchorOffsets.top);
	tooltip.NineSlice:SetPoint("BOTTOMRIGHT", tooltip, options.anchorOffsets.right, options.anchorOffsets.bottom);

	NineSliceUtil.ApplyLayoutByName(tooltip.NineSlice, options.layoutName);

	if options.borderColor then
		tooltip.NineSlice:SetBorderColor(options.borderColor:GetRGBA());
	end

	if options.centerColor then
		tooltip.NineSlice:SetCenterColor(options.centerColor:GetRGBA());
	end

	tooltip.NineSlice:Show();
end

function AuraContainerUtil.SetTooltipTextureSlice(options)
	options = C_AuraContainerUtil.ProcessAuraTooltipTextureSliceOptions(securecopy(options));

	local tooltip = AuraContainerUtil.GetDefaultTooltip();
	AuraContainerUtil.ClearTooltipStyle(tooltip);

	if not tooltip.TextureSliceBackground then
		tooltip.TextureSliceBackground = tooltip:CreateTexture(nil, "BACKGROUND");
	end

	tooltip.TextureSliceBackground:ClearAllPoints();
	tooltip.TextureSliceBackground:SetPoint("TOPLEFT", tooltip, options.anchorOffsets.left, options.anchorOffsets.top);
	tooltip.TextureSliceBackground:SetPoint("BOTTOMRIGHT", tooltip, options.anchorOffsets.right, options.anchorOffsets.bottom);
	tooltip.TextureSliceBackground:ClearTextureSlice();

	if not CheckSetAtlas(tooltip.TextureSliceBackground, options.asset) then
		tooltip.TextureSliceBackground:SetTexture(options.asset);
	end

	if options.sliceMargins then
		tooltip.TextureSliceBackground:SetTextureSliceMargins(options.sliceMargins.left, options.sliceMargins.top, options.sliceMargins.right, options.sliceMargins.bottom);
	end

	if options.sliceMode then
		tooltip.TextureSliceBackground:SetTextureSliceMode(options.sliceMode);
	end

	if options.color then
		tooltip.TextureSliceBackground:SetVertexColor(options.color:GetRGBA());
	end

	if options.drawLayer then
		tooltip.TextureSliceBackground:SetDrawLayer(options.drawLayer, options.drawLayerSublevel);
	end

	tooltip.TextureSliceBackground:Show();
end

function AuraContainerUtil.SetTooltipBackdrop(options)
	options = C_AuraContainerUtil.ProcessAuraTooltipBackdropOptions(securecopy(options));

	if not options.backdropInfo.bgFile and not options.backdropInfo.edgeFile then
		error("expected a non-nil value for either bgFile or edgeFile");
		return;
	end

	local tooltip = AuraContainerUtil.GetDefaultTooltip();
	AuraContainerUtil.ClearTooltipStyle(tooltip);

	if not tooltip.BackdropContainer then
		tooltip.BackdropContainer = CreateFrame("Frame", nil, tooltip, "BackdropTemplate");
		tooltip.BackdropContainer:SetUsingParentLevel(true);
	end

	tooltip.BackdropContainer:ClearAllPoints();
	tooltip.BackdropContainer:SetPoint("TOPLEFT", tooltip, options.anchorOffsets.left, options.anchorOffsets.top);
	tooltip.BackdropContainer:SetPoint("BOTTOMRIGHT", tooltip, options.anchorOffsets.right, options.anchorOffsets.bottom);
	tooltip.BackdropContainer:SetBackdrop(options.backdropInfo);

	if options.borderColor then
		tooltip.BackdropContainer:SetBackdropBorderColor(options.borderColor:GetRGBA());
	end

	if options.centerColor then
		tooltip.BackdropContainer:SetBackdropColor(options.centerColor:GetRGBA());
	end

	tooltip.BackdropContainer:Show();
end

-- Export some utilities for the inbound secure delegate interface.
local _addonName, addonTable = ...;
addonTable.InboundSetTooltipNineSlice = CreateSecureDelegate(AuraContainerUtil.SetTooltipNineSlice);
addonTable.InboundSetTooltipTextureSlice = CreateSecureDelegate(AuraContainerUtil.SetTooltipTextureSlice);
addonTable.InboundSetTooltipBackdrop = CreateSecureDelegate(AuraContainerUtil.SetTooltipBackdrop);
