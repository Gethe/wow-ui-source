local GARRISON_FOLLOWER_TOOLTIP = {};
         
function GarrisonFollowerTooltip_Show(garrisonFollowerID, collected, quality, level, xp, levelxp, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4, noAbilityDescriptions, underBiased, tooltipFrame, xpWidth)
	GARRISON_FOLLOWER_TOOLTIP.garrisonFollowerID = garrisonFollowerID;
	GARRISON_FOLLOWER_TOOLTIP.followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID);
	GARRISON_FOLLOWER_TOOLTIP.collected = collected;
	GARRISON_FOLLOWER_TOOLTIP.hyperlink = false;
	GARRISON_FOLLOWER_TOOLTIP.displayID = C_Garrison.GetFollowerDisplayIDByID(garrisonFollowerID);
	GARRISON_FOLLOWER_TOOLTIP.name = C_Garrison.GetFollowerNameByID(garrisonFollowerID);
	GARRISON_FOLLOWER_TOOLTIP.spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID);
	GARRISON_FOLLOWER_TOOLTIP.portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID);
	GARRISON_FOLLOWER_TOOLTIP.quality = quality;
	GARRISON_FOLLOWER_TOOLTIP.level = level;
	GARRISON_FOLLOWER_TOOLTIP.xp = xp;
	GARRISON_FOLLOWER_TOOLTIP.levelxp = levelxp;
	GARRISON_FOLLOWER_TOOLTIP.itemLevel = itemLevel;
	GARRISON_FOLLOWER_TOOLTIP.ability1 = ability1;
	GARRISON_FOLLOWER_TOOLTIP.ability2 = ability2;
	GARRISON_FOLLOWER_TOOLTIP.ability3 = ability3;
	GARRISON_FOLLOWER_TOOLTIP.ability4 = ability4;
	GARRISON_FOLLOWER_TOOLTIP.trait1 = trait1;
	GARRISON_FOLLOWER_TOOLTIP.trait2 = trait2;
	GARRISON_FOLLOWER_TOOLTIP.trait3 = trait3;
	GARRISON_FOLLOWER_TOOLTIP.trait4 = trait4;
	GARRISON_FOLLOWER_TOOLTIP.noAbilityDescriptions = noAbilityDescriptions;
	GARRISON_FOLLOWER_TOOLTIP.underBiased = underBiased;

	if (not tooltipFrame) then
		tooltipFrame = GarrisonFollowerTooltip;
		if (GARRISON_FOLLOWER_TOOLTIP.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			tooltipFrame = GarrisonShipyardFollowerTooltip;
		end
	end

	if (GARRISON_FOLLOWER_TOOLTIP.followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
		GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltipFrame, GARRISON_FOLLOWER_TOOLTIP, xpWidth);
	else
		GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltipFrame, GARRISON_FOLLOWER_TOOLTIP, xpWidth);
	end
	tooltipFrame:Show();
end


function GarrisonFollowerAbilityTooltip_Show(garrFollowerAbilityID, followerTypeID)
	GarrisonFollowerAbilityTooltipTemplate_SetAbility(GarrisonFollowerAbilityTooltip, garrFollowerAbilityID, followerTypeID);
	GarrisonFollowerAbilityTooltip:Show();
end

function ShowGarrisonFollowerAbilityTooltip(frame, garrFollowerAbilityID, followerTypeID)
	if (GarrisonFollowerOptions[followerTypeID].useAbilityTooltipStyleWithoutCounters) then
		GameTooltip:SetOwner(frame, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT");

		local icon = C_Garrison.GetFollowerAbilityIcon(garrFollowerAbilityID);
		local name = C_Garrison.GetFollowerAbilityName(garrFollowerAbilityID);
		local description = C_Garrison.GetFollowerAbilityDescription(garrFollowerAbilityID);

		local str = "|T"..icon..":24:24|t "..name;
		GameTooltip:AddLine(str, 1, 1, 1);
		GameTooltip:AddLine(description, nil, nil, nil, true);
		GameTooltip:Show();
	else
		GarrisonFollowerAbilityTooltip:ClearAllPoints();
		GarrisonFollowerAbilityTooltip:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT");
		GarrisonFollowerAbilityTooltip_Show(garrFollowerAbilityID, followerTypeID);
	end
end

function HideGarrisonFollowerAbilityTooltip()
	GarrisonFollowerAbilityTooltip:Hide();
	GameTooltip:Hide();
end