QuestTextContrast = {};

local function GetQuestTextContrastValue(cvarValue)
	return tonumber(cvarValue or GetCVarNumberOrDefault("QuestTextContrast"));
end

function QuestTextContrast.IsEnabled(cvarValue)
	return GetQuestTextContrastValue(cvarValue) > 0;
end

function QuestTextContrast.UseLightText(cvarValue)
	--Use light text when the background is dark
	return GetQuestTextContrastValue(cvarValue) == 4;
end

local questBackgroundAtlas =
{
	[0] = "QuestBG-Parchment",
	[1] = "QuestBG-Parchment-Accessibility",
	[2] = "QuestBG-Parchment-Accessibility2",
	[3] = "QuestBG-Parchment-Accessibility3",
	[4] = "QuestBG-Parchment-Accessibility4",
}

function QuestTextContrast.GetBackgroundAtlas(questTextContrastSetting)
	if questTextContrastSetting ~= nil then
		return questBackgroundAtlas[questTextContrastSetting];
	end

	return questBackgroundAtlas[0];
end

function QuestTextContrast.GetDefaultBackgroundAtlas()
	return QuestTextContrast.GetBackgroundAtlas(GetQuestTextContrastValue());
end

function QuestTextContrast.GetTextureKitBackgroundAtlas(textureKit)
	if textureKit then
		local backgroundAtlas = GetFinalNameFromTextureKit("QuestBG-%s", textureKit);
		local atlasInfo = C_Texture.GetAtlasInfo(backgroundAtlas);
		if atlasInfo then
			return backgroundAtlas;
		end
	end
	
	return QuestTextContrast.GetDefaultBackgroundAtlas();
end

local defaultQuestMapBackgroundTexture =
{
	[0] = "QuestDetailsBackgrounds",
	[1] = "QuestDetailsBackgrounds-Accessibility",
	[2] = "QuestDetailsBackgrounds-Accessibility_Light",
	[3] = "QuestDetailsBackgrounds-Accessibility_Medium",
	[4] = "QuestDetailsBackgrounds-Accessibility_Dark",
}

function QuestTextContrast.GetDefaultDetailsBackgroundAtlas(cvarValue)
	local contrast = GetQuestTextContrastValue(cvarValue);
	if contrast ~= nil then
		return defaultQuestMapBackgroundTexture[contrast];
	end
end