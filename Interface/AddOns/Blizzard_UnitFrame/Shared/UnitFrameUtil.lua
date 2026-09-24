-- Utility functions focused on providing secret-safe access to unit frame data and updating unit frame elements.
-- These functions are designed to be usable by both secure and non-secure code

local _addonName, addonTable = ...;

UnitFrameUtil = UnitFrameUtil or {};

-- The PvP indicator's atlas set is game-type specific. Flattened into individual upvalues so no table read happens
-- inside the secure delegates below. These stay nil on Classic, where PvPIndicatorStyle is never set; the PvP
-- indicator delegates are left undefined there.
local HordeIconAtlas;
local AllianceIconAtlas;
local FFAIconAtlas;
local NeutralPrestigePortraitAtlas;
local FactionPrestigePortraitAtlasPrefix;
local SupportsPrestige;
local UsesBackground;

local function GetRawField(tbl, key)
	return securecallfunction(rawget, tbl, key);
end

local function WrapIfSecret(value, isSecret)
	if isSecret then
		return secretwrap(value);
	end

	return value;
end

-- Copied key by key so a caller-supplied map can't run a metamethod when it is later indexed with a secret value.
local function CopyTextureMap(textureMap, keys)
	if not textureMap then
		return nil;
	end

	local copy = {};
	for _, key in ipairs(keys) do
		copy[key] = GetRawField(textureMap, key);
	end

	return copy;
end

local pvpIndicatorTextureMapKeys =
{
	"prestigePortraitNeutral",
	"prestigePortraitHorde",
	"prestigePortraitAlliance",
	"prestigeBadge",
	"pvpIconFreeForAll",
	"pvpIconHorde",
	"pvpIconAlliance",
};

-- Returns unwrapped values, so it must stay internal. Callers are responsible for wrapping anything handed back out.
local function GetPvPIndicatorValues(unitToken, checkMercenary, textureMap)
	-- IMPORTANT: This key set is part of the addon-facing contract and must stay identical across all game types
	local info = {
		prestigePortraitAtlas = "",
		prestigeBadgeFileDataID = 0,
		pvpIconAtlas = "",
		showPrestigePortrait = false,
		showPrestigeBadge = false,
		showPvPIcon = false,
		showPvPBackground = false,
		isFreeForAll = false,
	};

	textureMap = CopyTextureMap(textureMap, pvpIndicatorTextureMapKeys);

	local unitFramePvPContextualDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UnitFramePvPContextualDisabled);
	if (not unitFramePvPContextualDisabled) then
		local factionGroup = UnitFactionGroup(unitToken);

		if (UnitIsPVPFreeForAll(unitToken)) then
			info.isFreeForAll = true;
			local honorRewardInfo = SupportsPrestige and C_PvP.GetHonorRewardInfo(UnitHonorLevel(unitToken)) or nil;

			if (honorRewardInfo) then
				info.prestigePortraitAtlas = (textureMap and textureMap.prestigePortraitNeutral) or NeutralPrestigePortraitAtlas;
				info.prestigeBadgeFileDataID = (textureMap and textureMap.prestigeBadge) or honorRewardInfo.badgeFileDataID;
				info.showPrestigePortrait = true;
				info.showPrestigeBadge = true;
			else
				info.pvpIconAtlas = (textureMap and textureMap.pvpIconFreeForAll) or FFAIconAtlas;
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

			local honorRewardInfo = SupportsPrestige and C_PvP.GetHonorRewardInfo(UnitHonorLevel(unitToken)) or nil;

			if (honorRewardInfo) then
				info.prestigePortraitAtlas = (textureMap and textureMap["prestigePortrait"..factionGroup]) or (FactionPrestigePortraitAtlasPrefix..factionGroup);
				info.prestigeBadgeFileDataID = (textureMap and textureMap.prestigeBadge) or honorRewardInfo.badgeFileDataID;
				info.showPrestigePortrait = true;
				info.showPrestigeBadge = true;
			else
				if (factionGroup == "Horde") then
					info.pvpIconAtlas = (textureMap and textureMap.pvpIconHorde) or HordeIconAtlas;
				elseif (factionGroup == "Alliance") then
					info.pvpIconAtlas = (textureMap and textureMap.pvpIconAlliance) or AllianceIconAtlas;
				end

				info.showPvPIcon = true;
			end
		end
	end

	info.showPvPBackground = UsesBackground and info.showPvPIcon;

	return info;
end

-- Returns an info table (whose members may be secret, depending on the unit and context) that contains the states needed to set the PvP indicator elements of a unit frame.
local function GetUnitPvPIndicatorDisplayInfo(unitToken, checkMercenary, textureMap)
	local info = GetPvPIndicatorValues(unitToken, checkMercenary, textureMap);

	-- IMPORTANT: Values in the info table must be secret-wrapped before being handed back to the (possibly tainted) caller
	if (C_Secrets.ShouldUnitIdentityBeSecret(unitToken)) then
		for key, value in pairs(info) do
			info[key] = secretwrap(value);
		end
	end

	return info;
end

local TextureMetatable = CopyTable(GetTextureMetatable().__index);
local FontStringMetatable = CopyTable(GetFontStringMetatable().__index);

local function IsTextureObject(object)
	return object ~= nil and TextureMetatable.IsObjectType(object, "Texture");
end

local function IsFontStringObject(object)
	return object ~= nil and FontStringMetatable.IsObjectType(object, "FontString");
end

-- Returns true when an atlas was applied, since an atlas supplies its own tex coords and callers must not overwrite them.
local function SetTextureOrAtlas(texture, value, isSecret, useAtlasSize)
	local appliedValue = WrapIfSecret(value, isSecret);

	if (type(value) == "string" and C_Texture.GetAtlasInfo(value)) then
		TextureMetatable.SetAtlas(texture, appliedValue, useAtlasSize);
		return true;
	end

	TextureMetatable.SetTexture(texture, appliedValue);
	return false;
end

-- Sets the textures in the elements table, using the info returned by GetUnitPvPIndicatorDisplayInfo.
-- The elements table can contain the following keys: prestigePortrait, prestigeBadge, pvpIcon, pvpBackground.
local function UpdateUnitPvPIndicator(elements, unitToken, checkMercenary, textureMap)
	local prestigePortrait = GetRawField(elements, "prestigePortrait");
	local prestigeBadge = GetRawField(elements, "prestigeBadge");
	local pvpIcon = GetRawField(elements, "pvpIcon");
	local pvpBackground = GetRawField(elements, "pvpBackground");

	local info = GetPvPIndicatorValues(unitToken, checkMercenary, textureMap);
	local isSecret = C_Secrets.ShouldUnitIdentityBeSecret(unitToken);

	if (IsTextureObject(prestigePortrait)) then
		if (info.showPrestigePortrait) then
			SetTextureOrAtlas(prestigePortrait, info.prestigePortraitAtlas, isSecret, TextureKitConstants.IgnoreAtlasSize);
		end

		TextureMetatable.SetShown(prestigePortrait, WrapIfSecret(info.showPrestigePortrait, isSecret));
	end

	if (IsTextureObject(prestigeBadge)) then
		if (info.showPrestigeBadge) then
			SetTextureOrAtlas(prestigeBadge, info.prestigeBadgeFileDataID, isSecret, TextureKitConstants.IgnoreAtlasSize);
		end

		TextureMetatable.SetShown(prestigeBadge, WrapIfSecret(info.showPrestigeBadge, isSecret));
	end

	if (IsTextureObject(pvpIcon)) then
		if (info.showPvPIcon) then
			SetTextureOrAtlas(pvpIcon, info.pvpIconAtlas, isSecret, TextureKitConstants.UseAtlasSize);
		end

		TextureMetatable.SetShown(pvpIcon, WrapIfSecret(info.showPvPIcon, isSecret));
	end

	if (IsTextureObject(pvpBackground)) then
		TextureMetatable.SetShown(pvpBackground, WrapIfSecret(info.showPvPBackground, isSecret));
	end
end

local roles = {"TANK", "HEALER", "DAMAGER"};
local frameToRole = {};
local function GetUnitFrameRole(roleCacheKey, unit)
	local role = UnitGroupRolesAssigned(unit);
	if EditModeManagerFrame:IsEditModeActive() and role == "NONE" then
		if not frameToRole[roleCacheKey] then
			frameToRole[roleCacheKey] = roles[math.random(#roles)];
		end

		return frameToRole[roleCacheKey];
	end

	return role;
end

local raidRoleAtlases =
{
	["MAINTANK"] = "RaidFrame-Icon-MainTank",
	["MAINASSIST"] = "RaidFrame-Icon-MainAssist",
};

local function GetUnitFrameRaidRole(unit)
	local raidID = UnitInRaid(unit);
	if raidID then
		return select(10, GetRaidRosterInfo(raidID));
	end

	return nil;
end

local roleIconTextureMapKeys = {"VEHICLE", "MAINTANK", "MAINASSIST", "TANK", "HEALER", "DAMAGER"};

-- Returns unwrapped values, so it must stay internal. Callers are responsible for wrapping anything handed back out.
local function GetRoleIconValues(unitToken, optionTable, roleCacheKey, iconSize)
	local info = {
		roleIconTexture = "",
		showRoleIcon = false,
		iconWidth = 1,
	};

	local textureMap = CopyTextureMap(GetRawField(optionTable, "textureMap"), roleIconTextureMapKeys);

	local roleIconTexture;
	if (UnitInVehicle(unitToken) and UnitHasVehicleUI(unitToken)) then
		roleIconTexture = (textureMap and textureMap.VEHICLE) or "RaidFrame-Icon-Vehicle";
	else
		if GetRawField(optionTable, "displayRaidRoleIcon") then
			local raidRole = GetUnitFrameRaidRole(unitToken);
			if raidRole then
				roleIconTexture = (textureMap and textureMap[raidRole]) or raidRoleAtlases[raidRole];
			end
		end

		if not roleIconTexture then
			local role = GetUnitFrameRole(roleCacheKey, unitToken);
			if GetRawField(optionTable, "displayRoleIcon") and role and role ~= "NONE" then
				roleIconTexture = (textureMap and textureMap[role]) or GetMicroIconForRole(role);
			end
		end
	end

	if roleIconTexture then
		info.roleIconTexture = roleIconTexture;
		info.showRoleIcon = true;
		info.iconWidth = iconSize or 1;
	end

	return info;
end

local function GetUnitRoleIconDisplayInfo(unitToken, options)
	options = options or {};
	local info = GetRoleIconValues(unitToken, options, unitToken, GetRawField(options, "iconSize"));

	-- IMPORTANT: These must be secret-wrapped or the branch chosen above is readable back off the texture via GetTexture/IsShown/GetWidth
	if (C_Secrets.ShouldUnitIdentityBeSecret(unitToken)) then
		for key, value in pairs(info) do
			info[key] = secretwrap(value);
		end
	end

	return info;
end

local function UpdateUnitFrameRoleIcon(frame)
	local roleIcon = GetRawField(frame, "roleIcon");
	if not IsTextureObject(roleIcon) then
		return;
	end

	local unitToken = GetRawField(frame, "unit");
	local optionTable = GetRawField(frame, "optionTable") or {};
	local iconSize = TextureMetatable.GetHeight(roleIcon);	--We keep the height so that it carries from the set up, but we decrease the width to 1 to allow room for things anchored to the role (e.g. name).

	local info = GetRoleIconValues(unitToken, optionTable, frame, iconSize);
	local isSecret = C_Secrets.ShouldUnitIdentityBeSecret(unitToken);

	if (info.showRoleIcon) then
		SetTextureOrAtlas(roleIcon, info.roleIconTexture, isSecret);
	end

	TextureMetatable.SetShown(roleIcon, WrapIfSecret(info.showRoleIcon, isSecret));
	-- Always passing the possibly-secret width ensures the texture is marked as holding secrets even on the hidden branch
	TextureMetatable.SetSize(roleIcon, WrapIfSecret(info.iconWidth, isSecret), iconSize);
end

local arenaSpecTextureMapKeys = {"TANK", "HEALER", "DAMAGER"};

local ROLE_ICON_TEXTURE = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES";

local useClassColorsCvarName = "pvpFramesDisplayClassColor";
CVarCallbackRegistry:SetCVarCachable(useClassColorsCvarName);

local function GetUseClassColors()
	return CVarCallbackRegistry:GetCVarValueBool(useClassColorsCvarName);
end

-- Returns unwrapped values, including the role, so it must stay internal: handing a caller the raw role would let them
-- index a table of their own with it and recover the branch that was taken.
local function GetArenaSpecValues(arenaIndex, textureMap)
	local info = {
		hasSpec = false,
		specName = "",
		className = "",
		specIcon = 0,
		roleIconTexture = "",
		usesDefaultRoleIconTexture = false,
		showRoleIcon = false,
		barColorR = 1,
		barColorG = 0,
		barColorB = 0,
	};

	local specID, gender = GetArenaOpponentSpec(arenaIndex);
	if specID and specID > 0 then
		local _, specName, _, specIcon, role, class, className = GetSpecializationInfoByID(specID, gender);

		info.hasSpec = true;
		info.specName = specName or "";
		info.className = className or "";
		info.specIcon = specIcon or 0;

		if role and (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
			local customRoleIconTexture = textureMap and textureMap[role];
			info.role = role;
			info.roleIconTexture = customRoleIconTexture or ROLE_ICON_TEXTURE;
			info.usesDefaultRoleIconTexture = not customRoleIconTexture;
			info.showRoleIcon = true;
		end

		if GetUseClassColors() and class then
			local classColor = RAID_CLASS_COLORS[class];
			if classColor then
				info.barColorR, info.barColorG, info.barColorB = classColor.r, classColor.g, classColor.b;
			end
		end
	end

	return info;
end

local function ShouldArenaOpponentSpecBeSecret()
	return C_Secrets.HasSecretRestrictions();
end

local function GetArenaOpponentSpecDisplayInfo(arenaIndex, textureMap)
	local info = GetArenaSpecValues(arenaIndex, CopyTextureMap(textureMap, arenaSpecTextureMapKeys));
	info.role = nil;

	-- IMPORTANT: These must be secret-wrapped or the branch chosen above is readable back off whatever the caller applies them to
	if (ShouldArenaOpponentSpecBeSecret()) then
		for key, value in pairs(info) do
			info[key] = secretwrap(value);
		end
	end

	return info;
end

local function UpdateArenaOpponentSpecDisplay(elements, arenaIndex, textureMap)
	local specNameText = GetRawField(elements, "specNameText");
	local classNameText = GetRawField(elements, "classNameText");
	local specPortrait = GetRawField(elements, "specPortrait");
	local roleIcon = GetRawField(elements, "roleIcon");
	local barTexture = GetRawField(elements, "barTexture");

	local info = GetArenaSpecValues(arenaIndex, CopyTextureMap(textureMap, arenaSpecTextureMapKeys));
	local isSecret = ShouldArenaOpponentSpecBeSecret();

	if IsFontStringObject(specNameText) then
		FontStringMetatable.SetText(specNameText, WrapIfSecret(info.specName, isSecret));
	end

	if IsFontStringObject(classNameText) then
		FontStringMetatable.SetText(classNameText, WrapIfSecret(info.className, isSecret));
	end

	if IsTextureObject(specPortrait) then
		TextureMetatable.SetTexture(specPortrait, WrapIfSecret(info.specIcon, isSecret));
	end

	if IsTextureObject(roleIcon) then
		-- Setting the possibly-secret texture first marks the whole texture, which seals the tex coords and size that follow.
		local appliedAtlas = SetTextureOrAtlas(roleIcon, info.roleIconTexture, isSecret);
		if info.showRoleIcon then
			if info.usesDefaultRoleIconTexture then
				-- The default texture is a shared sprite sheet, so it has to be cropped down to this role's cell.
				TextureMetatable.SetTexCoord(roleIcon, GetTexCoordsForOldRoleSmallCircle(info.role));
			elseif not appliedAtlas then
				-- A caller-supplied texture is whole, so clear any crop a previous update left behind.
				TextureMetatable.SetTexCoord(roleIcon, 0, 1, 0, 1);
			end

			TextureMetatable.SetSize(roleIcon, 12, 12);
		else
			TextureMetatable.SetSize(roleIcon, 1, 12);
		end

		TextureMetatable.SetShown(roleIcon, WrapIfSecret(info.showRoleIcon, isSecret));
	end

	if IsTextureObject(barTexture) then
		TextureMetatable.SetVertexColor(barTexture, WrapIfSecret(info.barColorR, isSecret), WrapIfSecret(info.barColorG, isSecret), WrapIfSecret(info.barColorB, isSecret));
	end

	return WrapIfSecret(info.hasSpec, isSecret);
end

local function UpdateArenaOpponentSpecDisplayName(nameText, arenaIndex, preferredName)
	if not IsFontStringObject(nameText) then
		return;
	end

	local info = GetArenaSpecValues(arenaIndex);
	local name = preferredName;
	if not name or name == "" then
		name = (info.specName ~= "" and info.specName) or info.className;
	end

	if (ShouldArenaOpponentSpecBeSecret()) then
		name = secretwrap(name);
	end

	FontStringMetatable.SetText(nameText, name);
end

-- The PvP indicator depends on mainline-only honor/prestige APIs and atlases, so it is left undefined on Classic rather than failing inside the delegate.
if (C_PvP and C_PvP.GetHonorRewardInfo) then
	local style = addonTable.PvPIndicatorStyle;
	HordeIconAtlas = style.hordeIconAtlas;
	AllianceIconAtlas = style.allianceIconAtlas;
	FFAIconAtlas = style.ffaIconAtlas;
	NeutralPrestigePortraitAtlas = style.neutralPrestigePortraitAtlas;
	FactionPrestigePortraitAtlasPrefix = style.factionPrestigePortraitAtlasPrefix;
	SupportsPrestige = style.supportsPrestige;
	UsesBackground = style.usesBackground;

	-- Used by UnitFrameUtil.UpdateUnitPvPIndicator, but can also be called separately (values returned will be secret if the unit's identity is secret).
	-- textureMap may replace any of prestigePortraitNeutral/prestigePortraitHorde/prestigePortraitAlliance/prestigeBadge/pvpIconFreeForAll/pvpIconHorde/pvpIconAlliance,
	-- with either an atlas name or a plain texture path/file ID.
	UnitFrameUtil.GetUnitPvPIndicatorDisplayInfo = CreateSecureDelegate(GetUnitPvPIndicatorDisplayInfo);

	-- Secret-safe API for setting PvP icon/prestige badge/prestige background textures, accepting the same optional textureMap. Used by TargetFrame.lua/PlayerFrame.lua and also safe for addons to use
	UnitFrameUtil.UpdateUnitPvPIndicator = CreateSecureDelegate(UpdateUnitPvPIndicator);
end

-- Secret-safe API for setting the compact-unit-frame role icon (vehicle/raid MT-MA/assigned role). Used by CompactUnitFrame.lua and also safe for addons to use
UnitFrameUtil.UpdateUnitFrameRoleIcon = CreateSecureDelegate(UpdateUnitFrameRoleIcon);

-- Returns possibly-secret roleIconTexture/showRoleIcon for callers that draw the role icon themselves. options may set
-- displayRoleIcon, displayRaidRoleIcon, iconSize, and a textureMap keyed by VEHICLE/MAINTANK/MAINASSIST/TANK/HEALER/DAMAGER,
-- whose values may be either an atlas name or a plain texture path/file ID.
-- Tainted callers must apply showRoleIcon with SetAlphaFromBoolean; SetShown does not accept secret arguments from tainted execution.
UnitFrameUtil.GetUnitRoleIconDisplayInfo = CreateSecureDelegate(GetUnitRoleIconDisplayInfo);

-- GetArenaOpponentSpec always returns secrets, so these wrap the spec/class/role display decisions addons would otherwise have to branch on themselves.
if (GetArenaOpponentSpec and GetSpecializationInfoByID) then
	-- Returns possibly-secret hasSpec/specName/className/specIcon/roleIconTexture/usesDefaultRoleIconTexture/showRoleIcon/barColorR/G/B.
	-- textureMap may replace the role icon texture, keyed by TANK/HEALER/DAMAGER, with either an atlas name or a plain texture path/file ID.
	-- usesDefaultRoleIconTexture reports whether roleIconTexture is the shared role sprite sheet, which has to be cropped rather than drawn whole.
	UnitFrameUtil.GetArenaOpponentSpecDisplayInfo = CreateSecureDelegate(GetArenaOpponentSpecDisplayInfo);

	-- Applies the same values to an elements table of { specNameText, classNameText, specPortrait, roleIcon, barTexture }, returning the possibly-secret hasSpec.
	UnitFrameUtil.UpdateArenaOpponentSpecDisplay = CreateSecureDelegate(UpdateArenaOpponentSpecDisplay);

	-- Sets a font string to preferredName, falling back to the possibly-secret spec or class name.
	UnitFrameUtil.UpdateArenaOpponentSpecDisplayName = CreateSecureDelegate(UpdateArenaOpponentSpecDisplayName);
end
