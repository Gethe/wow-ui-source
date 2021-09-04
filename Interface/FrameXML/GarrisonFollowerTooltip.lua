         
function GarrisonFollowerTooltip_Show(garrisonFollowerID, collected, quality, level, xp, levelxp, itemLevel, spec1, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, noAbilityDescriptions, underBiased, underBiasedReason, tooltipFrame, xpWidth)
	local data = {};
	data.garrisonFollowerID = garrisonFollowerID;
	data.followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID);
	data.collected = collected;
	data.hyperlink = false;
	data.name = C_Garrison.GetFollowerNameByID(garrisonFollowerID);
	data.spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID);
	data.portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID);
	data.quality = quality;
	data.level = level;
	data.xp = xp;
	data.levelxp = levelxp;
	data.iLevel = itemLevel;
	data.spec1 = spec1;
	data.ability1 = ability1;
	data.ability2 = ability2;
	data.ability3 = ability3;
	data.ability4 = ability4;
	data.trait1 = trait1;
	data.trait2 = trait2;
	data.trait3 = trait3;
	data.trait4 = trait4;
	data.isTroop = C_Garrison.GetFollowerIsTroop(garrisonFollowerID);
	data.noAbilityDescriptions = noAbilityDescriptions;
	data.underBiased = underBiased;
	data.underBiasedReason = underBiasedReason;
	GarrisonFollowerTooltip_ShowWithData(data, tooltipFrame);
end

function GarrisonFollowerTooltip_ShowWithData(data, tooltipFrame)
	if (not tooltipFrame) then
		if (data.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2) then
			tooltipFrame = GarrisonShipyardFollowerTooltip;
		else
			tooltipFrame = GarrisonFollowerTooltip;
		end
	end

	if (data.followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_2) then
		GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltipFrame, data, xpWidth);
	else
		GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltipFrame, data, xpWidth);
	end
	tooltipFrame:Show();
end

function GarrisonFollowerTooltipTemplate_BuildDefaultDataForID(garrFollowerID)
	local link = C_Garrison.GetFollowerLinkByID(garrFollowerID);
	local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, spec1 = strsplit(":", link);
	garrisonFollowerID = tonumber(garrisonFollowerID);

	return {
		garrisonFollowerID = garrisonFollowerID,
		followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID),
		collected = false,
		hyperlink = false,
		name = C_Garrison.GetFollowerNameByID(garrisonFollowerID),
		spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID),
		portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID),
		quality = tonumber(quality),
		level = tonumber(level),
		xp = 0,
		levelxp = 0,
		iLevel = tonumber(itemLevel),
		spec1 = tonumber(spec1),
		ability1 = tonumber(ability1),
		ability2 = tonumber(ability2),
		ability3 = tonumber(ability3),
		ability4 = tonumber(ability4),
		trait1 = tonumber(trait1),
		trait2 = tonumber(trait2),
		trait3 = tonumber(trait3),
		trait4 = tonumber(trait4),
		isTroop = C_Garrison.GetFollowerIsTroop(garrisonFollowerID),
	};
end


function GarrisonFollowerAbilityTooltip_Show(tooltip, garrFollowerAbilityID, followerTypeID)
	GarrisonFollowerAbilityTooltipTemplate_SetAbility(tooltip, garrFollowerAbilityID, followerTypeID);
	tooltip:Show();
end

function ShowGarrisonFollowerAbilityTooltip(frame, garrFollowerAbilityID, followerTypeID)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].abilityTooltipFrame];

	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT");
	GarrisonFollowerAbilityTooltip_Show(tooltip, garrFollowerAbilityID, followerTypeID);

end

function HideGarrisonFollowerAbilityTooltip(followerTypeID)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].abilityTooltipFrame];
	tooltip:Hide();
end

function ShowGarrisonFollowerAbilityTooltipWithExtraDescriptionText(frame, garrFollowerAbilityID, followerTypeID, extraText)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].abilityTooltipFrame];
	tooltip.extraDescriptionText = extraText;

	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT");
	GarrisonFollowerAbilityTooltip_Show(tooltip, garrFollowerAbilityID, followerTypeID);

end

function HideGarrisonFollowerAbilityTooltipWithExtraDescriptionText(followerTypeID)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].abilityTooltipFrame];
	tooltip.extraDescriptionText = nil;
	tooltip:Hide();
end

function ShowGarrisonFollowerMissionAbilityTooltip(frame, garrFollowerAbilityID, followerTypeID)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].missionAbilityTooltipFrame];

	tooltip:ClearAllPoints();
	tooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT");
	GarrisonFollowerAbilityTooltip_Show(tooltip, garrFollowerAbilityID, followerTypeID);

end

function HideGarrisonFollowerMissionAbilityTooltip(followerTypeID)
	local tooltip = _G[GarrisonFollowerOptions[followerTypeID].missionAbilityTooltipFrame];
	tooltip:Hide();
end