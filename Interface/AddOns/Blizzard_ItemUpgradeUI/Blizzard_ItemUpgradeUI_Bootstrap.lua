local AddonName = ...;

function ItemUpgrade_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowItemUpgradeFrame()
	if ItemUpgrade_LoadUI() then
		ItemUpgradeFrame_Show();
	end
end

function HideItemUpgradeFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) and ItemUpgradeFrame_Hide then
		ItemUpgradeFrame_Hide();
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ItemUpgradeFrame",
		loadFunc = ItemUpgrade_LoadUI,
		showFunc = ShowItemUpgradeFrame,
		hideFunc = HideItemUpgradeFrame,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ItemUpgrade, frameInfo);
end

RegisterWithPlayerInteractionManager();
