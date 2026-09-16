local AddonName = ...;

function Garrison_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleGarrisonBuildingUI()
	if Garrison_LoadUI() then
		GarrisonBuildingUI_ToggleFrame();
	end
end

function ToggleGarrisonMissionUI()
	if Garrison_LoadUI() then
		GarrisonMissionFrame_ToggleFrame();
	end
end

function ShowGarrisonMissionFrameForFollowerType(followerType)
	if followerType == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower then
		return;
	end

	if Garrison_LoadUI() then
		local frameName = GetGarrisonMissionFrameNameForFollowerType(followerType);
		local frame = frameName and _G[frameName];
		if frame then
			frame.followerTypeID = followerType;
			ShowUIPanel(frame);
		end
	end
end

function ShowAdventureMapFrameForFollowerType(followerType)
	if Garrison_LoadUI() then
		local frameName = GetGarrisonMissionFrameNameForFollowerType(followerType);
		local frame = frameName and _G[frameName];
		if frame then
			ShowUIPanel(frame);
		end
	end
end

function HideGarrisonMissionFrames()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		HideUIPanel(GarrisonMissionFrame);
		HideUIPanel(BFAMissionFrame);
		HideUIPanel(CovenantMissionFrame);
	end
end

function ShowGarrisonShipyardFrame(followerTypeID)
	if Garrison_LoadUI() then
		GarrisonShipyardFrame.followerTypeID = followerTypeID;
		ShowUIPanel(GarrisonShipyardFrame);
	end
end

function HideGarrisonShipyardFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		HideUIPanel(GarrisonShipyardFrame);
	end
end

function ShowGarrisonCapacitiveDisplayFrame()
	if Garrison_LoadUI() then
		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
	end
end

function ShowGarrisonRecruiterFrame()
	if Garrison_LoadUI() then
		ShowUIPanel(GarrisonRecruiterFrame);
	end
end

function ToggleCovenantMissionUI()
	if Garrison_LoadUI() then
		ShowUIPanel(CovenantMissionFrame);
	end
end

local function ShowGarrisonMonumentFrame()
	if C_Trophy and C_Trophy.MonumentLoadList then
		C_Trophy.MonumentLoadList();
	end
end

local function RegisterWithPlayerInteractionManager()
	RegisterPlayerInteraction(Enum.PlayerInteractionType.GarrArchitect,
		{
			frame = "GarrisonBuildingFrame",
			loadFunc = Garrison_LoadUI,
		});

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Trophy,
		{
			frame = "GarrisonMonumentFrame",
			loadFunc = Garrison_LoadUI,
			showFunc = ShowGarrisonMonumentFrame,
		});
end

RegisterWithPlayerInteractionManager();
