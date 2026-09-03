local AddonName = ...;

function AzeriteEssenceUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function OpenAzeriteEssenceUIFromItemLocation(itemLocation)
	if AzeriteEssenceUI_LoadUI() then
		AzeriteEssenceUI:TryShow();
	end
end

local function ShowAzeriteEssenceUI()
	if AzeriteEssenceUI:TryShow() and AzeriteEssenceUI:ShouldOpenBagsOnShow() then
		OpenAllBags(AzeriteEssenceUI);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "AzeriteEssenceUI",
		loadFunc = AzeriteEssenceUI_LoadUI,
		showFunc = ShowAzeriteEssenceUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.AzeriteForge, frameInfo);
end

RegisterWithPlayerInteractionManager();
