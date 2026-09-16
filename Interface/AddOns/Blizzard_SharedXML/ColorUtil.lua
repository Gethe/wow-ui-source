COLOR_FORMAT_RGBA = "RRGGBBAA";
COLOR_FORMAT_RGB = "RRGGBB";
COLOR_FORMAT_ARGB = "AARRGGBB";
FONT_COLOR_CODE_CLOSE = "|r";

function ExtractColorValueFromHex(str, index)
	return tonumber(str:sub(index, index + 1), 16) / 255;
end

function CreateColorFromHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_ARGB then
		local a, r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	end

	assertsafe(false, "CreateColorFromHexString input must be hexadecimal digits in this format: %s.", COLOR_FORMAT_ARGB);
	return nil;
end

function CreateColorFromRGBAHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_RGBA then
		local r, g, b, a = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5), ExtractColorValueFromHex(hexColor, 7);
		return CreateColor(r, g, b, a);
	end

	assertsafe(false, "CreateColorFromHexString input must be hexadecimal digits in this format: %s", COLOR_FORMAT_RGBA);
	return nil;
end

function CreateColorFromRGBHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_RGB then
		local r, g, b = ExtractColorValueFromHex(hexColor, 1), ExtractColorValueFromHex(hexColor, 3), ExtractColorValueFromHex(hexColor, 5);
		return CreateColor(r, g, b, 1);
	end

	assertsafe(false, "CreateColorFromRGBHexString input must be hexadecimal digits in this format: %s", COLOR_FORMAT_RGB);
	return nil;
end

function CreateColorFromBestRGBHexString(hexColor)
	if #hexColor == #COLOR_FORMAT_RGBA then
		return CreateColorFromRGBAHexString(hexColor);
	elseif #hexColor == #COLOR_FORMAT_RGB then
		return CreateColorFromRGBHexString(hexColor);
	end

	assertsafe(false, "CreateColorFromBestRGBHexString input must be hexadecimal digits in either of these formats: %s / %s", COLOR_FORMAT_RGBA, COLOR_FORMAT_RGB);
	return nil;
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

function IsRGBAEqualToColor(r, g, b, a, color)
	return (color.r == r) and (color.g == g) and (color.b == b) and (color.a == a);
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
	return color and color:WrapTextInColorCode(text) or text;
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
