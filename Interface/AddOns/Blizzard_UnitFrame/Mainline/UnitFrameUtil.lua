local function GetUnitPvPIndicatorDisplayInfo(unitToken, checkMercenary)
	local info = {
		prestigePortraitAtlas = "",
		prestigeBadgeFileDataID = 0,
		pvpIconAtlas = "",
		showPrestigePortrait = false,
		showPrestigeBadge = false,
		showPvPIcon = false,
		isFreeForAll = false,
	};

	local unitFramePvPContextualDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UnitFramePvPContextualDisabled);
	if (not unitFramePvPContextualDisabled) then
		local factionGroup = UnitFactionGroup(unitToken);

		if (UnitIsPVPFreeForAll(unitToken)) then
			info.isFreeForAll = true;
			local honorRewardInfo = C_PvP.GetHonorRewardInfo(UnitHonorLevel(unitToken));

			if (honorRewardInfo) then
				info.prestigePortraitAtlas = "honorsystem-portrait-neutral";
				info.prestigeBadgeFileDataID = honorRewardInfo.badgeFileDataID;
				info.showPrestigePortrait = true;
				info.showPrestigeBadge = true;
			else
				info.pvpIconAtlas = "UI-HUD-UnitFrame-Player-PVP-FFAIcon";
				info.showPvPIcon = true;
			end
		elseif (factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unitToken)) then
			if (checkMercenary and UnitIsMercenary(unitToken)) then
				if (factionGroup == "Horde") then
					factionGroup = "Alliance";
				elseif (factionGroup == "Alliance") then
					factionGroup = "Horde";
				end
			end

			local honorRewardInfo = C_PvP.GetHonorRewardInfo(UnitHonorLevel(unitToken));

			if (honorRewardInfo) then
				info.prestigePortraitAtlas = "honorsystem-portrait-"..factionGroup;
				info.prestigeBadgeFileDataID = honorRewardInfo.badgeFileDataID;
				info.showPrestigePortrait = true;
				info.showPrestigeBadge = true;
			else
				if (factionGroup == "Horde") then
					info.pvpIconAtlas = "UI-HUD-UnitFrame-Player-PVP-HordeIcon";
				elseif (factionGroup == "Alliance") then
					info.pvpIconAtlas = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon";
				end

				info.showPvPIcon = true;
			end
		end
	end

	-- IMPORTANT: Values in the info table must be secret-wrapped before being handed back to the (possibly tainted) caller
	if (C_Secrets.ShouldUnitIdentityBeSecret(unitToken)) then
		for key, value in pairs(info) do
			info[key] = secretwrap(value);
		end
	end

	return info;
end

local TextureMetatable = CopyTable(GetTextureMetatable().__index);

local function IsTextureObject(object)
	return object ~= nil and TextureMetatable.IsObjectType(object, "Texture");
end

local function GetUnitPvPIndicatorElement(elements, key)
	return securecallfunction(rawget, elements, key);
end

local function UpdateUnitPvPIndicator(elements, unitToken, checkMercenary)
	local prestigePortrait = GetUnitPvPIndicatorElement(elements, "prestigePortrait");
	local prestigeBadge = GetUnitPvPIndicatorElement(elements, "prestigeBadge");
	local pvpIcon = GetUnitPvPIndicatorElement(elements, "pvpIcon");

	local displayInfo = GetUnitPvPIndicatorDisplayInfo(unitToken, checkMercenary);

	if (IsTextureObject(prestigePortrait)) then
		if (displayInfo.showPrestigePortrait) then
			TextureMetatable.SetAtlas(prestigePortrait, displayInfo.prestigePortraitAtlas, TextureKitConstants.IgnoreAtlasSize);
		end

		TextureMetatable.SetShown(prestigePortrait, displayInfo.showPrestigePortrait);
	end

	if (IsTextureObject(prestigeBadge)) then
		if (displayInfo.showPrestigeBadge) then
			TextureMetatable.SetTexture(prestigeBadge, displayInfo.prestigeBadgeFileDataID);
		end

		TextureMetatable.SetShown(prestigeBadge, displayInfo.showPrestigeBadge);
	end

	if (IsTextureObject(pvpIcon)) then
		if (displayInfo.showPvPIcon) then
			TextureMetatable.SetAtlas(pvpIcon, displayInfo.pvpIconAtlas, TextureKitConstants.UseAtlasSize);
		end

		TextureMetatable.SetShown(pvpIcon, displayInfo.showPvPIcon);
	end
end

UnitFrameUtil = UnitFrameUtil or {};

-- Used by UnitFrameUtil.UpdateUnitPvPIndicator, but can also be called separately (values returned will be secret if the unit's' identity is secret)
UnitFrameUtil.GetUnitPvPIndicatorDisplayInfo = CreateSecureDelegate(GetUnitPvPIndicatorDisplayInfo);

-- Secret-safe API for setting PvP icon/prestige badge textures. Used by TargetFrame.lua/PlayerFrame.lua and also safe for addons to use
UnitFrameUtil.UpdateUnitPvPIndicator = CreateSecureDelegate(UpdateUnitPvPIndicator);
