
function WorldMapFrame_IsCosmicMap()
	return GetCurrentMapContinent() == WORLDMAP_COSMIC_ID and GetCurrentMapAreaID() == WORLDMAP_COSMIC_MAP_AREA_ID;
end

function WorldMapFrame_IsMaelstromContinentMap()
	return GetCurrentMapContinent() == WORLDMAP_MAELSTROM_ID and GetCurrentMapZone() == 0;
end

function WorldMapFrame_IsArgusContinentMap()
	return GetCurrentMapContinent() == WORLDMAP_ARGUS_ID and GetCurrentMapZone() == 0;
end

local CosmicStyleButtons = {
	{
		Buttons = {
			OutlandButton,
			AzerothButton,
			DraenorButton,
		},
		
		Predicate = WorldMapFrame_IsCosmicMap,
	},
	
	{
		Buttons = {
			DeepholmButton,
			KezanButton,
			LostIslesButton,
			TheMaelstromButton,
		},
		
		Predicate = WorldMapFrame_IsMaelstromContinentMap,
	},	
	
	{
		Buttons = {
			KrokuunButton,
			MacAreeButton,
			AntoranWastesButton,
		},
		
		Predicate = WorldMapFrame_IsArgusContinentMap,
	},
};
	
function WorldMapFrame_UpdateCosmicButtons()
	for i, cosmicGroup in ipairs(CosmicStyleButtons) do
		local shouldShow = cosmicGroup.Predicate();
		for j, cosmicButton in ipairs(cosmicGroup.Buttons) do
			cosmicButton:SetShown(shouldShow);
		end
	end
end