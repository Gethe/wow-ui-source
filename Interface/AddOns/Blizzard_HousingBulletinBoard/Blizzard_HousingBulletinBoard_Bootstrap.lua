local AddonName = ...;

function HousingBulletinBoardFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function ShowRenameNeighborhoodDialog()
	StaticPopupSpecial_Show(NeighborhoodChangeNameDialog);
end

local function RegisterWithPlayerInteractionManager()
	RegisterPlayerInteraction(Enum.PlayerInteractionType.HousingBulletinBoard,
		{
			frame = "HousingBulletinBoardFrame",
			loadFunc = HousingBulletinBoardFrame_LoadUI,
		});

	RegisterPlayerInteraction(Enum.PlayerInteractionType.RenameNeighborhood,
		{
			frame = "NeighborhoodChangeNameDialog",
			loadFunc = HousingBulletinBoardFrame_LoadUI,
			showFunc = ShowRenameNeighborhoodDialog,
		});

	AddPlayerInteractionConditions(Enum.PlayerInteractionType.RenameNeighborhood,
		{
			showCondition = function()
				if not C_HousingNeighborhood.IsNeighborhoodManager() then
					UIErrorsFrame:AddExternalErrorMessage(ERR_HOUSING_RESULT_PERMISSION_DENIED);
					C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.RenameNeighborhood);
					return false;
				end

				return true;
			end,
		});
end

RegisterWithPlayerInteractionManager();
