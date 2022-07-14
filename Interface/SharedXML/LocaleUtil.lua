local InstructionLineIndices = 
{
	deDE = 0,
	enGB = 1,
	enUS = 2,
	esES = 3,
	frFR = 4,
	koKR = 5,
	zhCN = 6,
	zhTW = 7,
	enCN = 8,
	enTW = 9,
	esMX = 10,
	ruRU = 11,
	ptBR = 12,
	ptPT = 13,
	itIT = 14,
};

LocaleUtil = {};

function LocaleUtil.CreateTextureInfoForInstructions(locale)
	local lineHeight = 22;
	local textureWidth = 256;
	local textureHeight = 512;
	local v = lineHeight / textureHeight;
	local top = v * InstructionLineIndices[locale];
	local bottom = top + v;
	local iconInfo =
	{
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = top,
		tCoordBottom = bottom,
		tSizeX = textureWidth,
		tSizeY = lineHeight,
	};
	return iconInfo;
end

function LocaleUtil.ContainInstructionForLocale(locale)
	return locale and InstructionLineIndices[locale];
end

function LocaleUtil.GetInstructionTexture()
	return "Interface\\Common\\Lang-Regions";
end
