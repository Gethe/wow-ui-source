-- Artifact and Heirloom qualities are not used in Camelot.
function ColorblindOverrides.ShouldShowItemQuality(quality)
	return quality ~= Enum.ItemQuality.Artifact and quality ~= Enum.ItemQuality.Heirloom;
end
