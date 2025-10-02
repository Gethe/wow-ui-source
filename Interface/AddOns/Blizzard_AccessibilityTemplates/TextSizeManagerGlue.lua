TextSizeManager = CreateFromMixins(TextSizeManagerBase);

function TextSizeManager:GetInitialUpdateEvents()
	return "FRAMES_LOADED";
end

TextSizeManager:Init();