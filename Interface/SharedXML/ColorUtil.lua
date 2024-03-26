COLOR_FORMAT_RGBA = "RRGGBBAA";
COLOR_FORMAT_RGB = "RRGGBB";

function ExtractColorValueFromHex(str, index)
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

function CreateColorFromRGBAHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_RGBA then
		local r, g, b, a = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	else
		GMError("CreateColorFromHexString input must be hexadecimal digits in this format: RRGGBBAA.");
	end
end

function CreateColorFromRGBHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_RGB then
		local r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5);
		return CreateColor(r, g, b, 1);
	else
		GMError("CreateColorFromRGBHexString input must be hexadecimal digits in this format: RRGGBB.");
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

RAID_CLASS_COLORS = {};
do
	local classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "MAGE", "ROGUE", "DRUID", "SHAMAN", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER", "EVOKER"};

	for i, className in ipairs(classes) do
		RAID_CLASS_COLORS[className] = C_ClassColor.GetClassColor(className);
	end
end

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
	if(color) then 
		return color:WrapTextInColorCode(text);
	end
end

function GetFactionColor(factionGroupTag)
	return PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroupTag]];
end

function RGBToColorCode(r, g, b)
	return format("|cff%02x%02x%02x", r*255, g*255, b*255);
end

function RGBTableToColorCode(rgbTable)
	return RGBToColorCode(rgbTable.r, rgbTable.g, rgbTable.b);
end
