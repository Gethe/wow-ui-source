TextSizeManager = CreateFromMixins(TextSizeManagerBase);

function TextSizeManager:GetInitialUpdateEvents()
	return "VARIABLES_LOADED";
end

TextSizeManager:Init();