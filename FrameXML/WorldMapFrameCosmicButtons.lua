
function WorldMapFrame_IsCosmicMap()
	return GetCurrentMapAreaID() == WORLDMAP_COSMIC_ID;
end

function WorldMapFrame_IsArgusContinentMap()
	return GetCurrentMapAreaID() == WORLDMAP_ARGUS_ID;
end

function WorldMapFrame_IsBrokenIslesContinentMap()
	return GetCurrentMapAreaID() == WORLDMAP_BROKEN_ISLES_ID;
end


local CosmicStyleButtons = {
	{ -- Cosmic map
		Buttons = {
			OutlandButton,
			AzerothButton,
			DraenorButton,
		},
		
		Predicate = WorldMapFrame_IsCosmicMap,
	},
		
	{ -- Broken Isles (Argus button)
		Buttons = {
			BrokenIslesArgusButton,
		},
		
		Predicate = WorldMapFrame_IsBrokenIslesContinentMap,
	},
	
	{ -- Argus continent map
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