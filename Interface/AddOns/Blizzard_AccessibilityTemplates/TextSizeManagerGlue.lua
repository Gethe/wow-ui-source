TextSizeManager = CreateFromMixins(TextSizeManagerBase);

function TextSizeManager:GetInitialUpdateEvents()
	return "FRAMES_LOADED";
end

function TextSizeManager:GetReadCVarName()
	return "userFontScaleGlue";
end

TextSizeManager:Init();
