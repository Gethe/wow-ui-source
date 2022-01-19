local function ExtractColorValueFromHex(str, index)
	return tonumber(str:sub(index, index + 1), 16) / 255;
end

function CreateColorFromHexString(hexColor)
	if #hexColor == 8 then
		local a, r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	else
		GMError("CreateColorFromHexString input must be hexadecimal digits in this format: AARRGGBB.");
	end
end

function CreateColorFromBytes(r, g, b, a)
	return CreateColor(r / 255, g / 255, b / 255, a / 255);
end

function AreColorsEqual(left, right)
	if left and right then
		return left:IsEqualTo(right);
	end
	return left == right;
end

RAID_CLASS_COLORS = {
	["HUNTER"] = CreateColor(0.67, 0.83, 0.45),
	["WARLOCK"] = CreateColor(0.53, 0.53, 0.93),
	["PRIEST"] = CreateColor(1.0, 1.0, 1.0),
	["PALADIN"] = CreateColor(0.96, 0.55, 0.73),
	["MAGE"] = CreateColor(0.25, 0.78, 0.92),
	["ROGUE"] = CreateColor(1.0, 0.96, 0.41),
	["DRUID"] = CreateColor(1.0, 0.49, 0.04),
	["SHAMAN"] = CreateColor(0.0, 0.44, 0.87),
	["WARRIOR"] = CreateColor(0.78, 0.61, 0.43),
	["DEATHKNIGHT"] = CreateColor(0.77, 0.12 , 0.23),
	["MONK"] = CreateColor(0.0, 1.00 , 0.59),
	["DEMONHUNTER"] = CreateColor(0.64, 0.19, 0.79),
};

for k, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor();
end

function GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
		return color.r, color.g, color.b, color.colorStr;
	end

	return 1, 1, 1, "ffffffff";
end

function GetClassColorObj(classFilename)
	-- TODO: Remove this, convert everything that's using GetClassColor to use the object instead, then begin using that again
	return RAID_CLASS_COLORS[classFilename];
end

function GetClassColoredTextForUnit(unit, text)
	local classFilename = select(2, UnitClass(unit));
	local color = GetClassColorObj(classFilename);
	return color:WrapTextInColorCode(text);
end

function GetFactionColor(factionGroupTag)
	return PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroupTag]];
end