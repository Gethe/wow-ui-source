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

local InstructionLineHeight = 22;
local InstructionTextureWidth = 256;
local InstructionTextureHeight = 512;
local InstructionTexCoordHeight = InstructionLineHeight/InstructionTextureHeight;

function LocaleUtil.CreateTextureInfoForInstructions(locale)
	local top = InstructionTexCoordHeight * InstructionLineIndices[locale];
	local bottom = top + InstructionTexCoordHeight;
	local iconInfo =
	{
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = top,
		tCoordBottom = bottom,
		tSizeX = InstructionTextureWidth,
		tSizeY = InstructionLineHeight,
	};
	return iconInfo;
end

function LocaleUtil.ContainInstructionForLocale(locale)
	return locale and InstructionLineIndices[locale];
end

function LocaleUtil.GetInstructionTexCoordHeight()
	return InstructionTexCoordHeight;
end

function LocaleUtil.GetInstructionTexture()
	return "Interface\\Common\\Lang-Regions";
end
