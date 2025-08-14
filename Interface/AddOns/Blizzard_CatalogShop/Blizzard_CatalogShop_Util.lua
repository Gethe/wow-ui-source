----------------------------------------------------------------------------------
-- Local Helpers
---------------------------------------------------------------------------------
local function UpdateCamera(camera, cameraDisplayData)
	if camera and cameraDisplayData then
		local x, y, z = camera:GetTarget();
		x = RoundToSignificantDigits(cameraDisplayData.targetX or x, 1);
		y = RoundToSignificantDigits(cameraDisplayData.targetY or y, 1);
		z = RoundToSignificantDigits(cameraDisplayData.targetZ or z, 1);
		camera:SetTarget(x, y, z);

		camera:SetYaw(math.rad(cameraDisplayData.yaw));
		camera:SetPitch(math.rad(cameraDisplayData.pitch));
		camera:SetRoll(math.rad(cameraDisplayData.roll));

		camera:SetMinZoomDistance(cameraDisplayData.minZoomDistance);
		camera:SetMaxZoomDistance(cameraDisplayData.maxZoomDistance);
		camera:SetZoomDistance(cameraDisplayData.zoomDistance);
	end
end

local function SetAnimations(actor, actorDisplayInfoData, overrideAnimations)
	if overrideAnimations then
		return;
	end

	if not actor or actorDisplayInfoData then
		return;
	end

	if actorDisplayInfoData.animationKitID then
		local maintain = true;
		actor:PlayAnimationKit(actorDisplayInfoData.animationKitID, maintain);
	elseif actorDisplayInfoData.animation and actorDisplayInfoData.animation > 0 then
		actor:SetAnimation(actorDisplayInfoData.animation, actorDisplayInfoData.animationVariation, actorDisplayInfoData.animSpeed);
	end
end

local function GetDefaultCameraDisplayData()
	local displayData = {};
	displayData.modelSceneCameraID = 0;
	displayData.scriptTag = "";

	displayData.targetX = 0;
	displayData.targetY = 0;
	displayData.targetZ = 0;

	displayData.yaw = 0;
	displayData.pitch = 0;
	displayData.roll = 0;

	displayData.zoomDistance = 8;
	displayData.minZoomDistance = 1;
	displayData.maxZoomDistance = 99;

	displayData.zoomedTargetOffset = nil;

	displayData.zoomedYawOffset = 0;
	displayData.zoomedPitchOffset = 0;
	displayData.zoomedRollOffset = 0;
	displayData.flags = 0;
	displayData.readableTag = "";
	return displayData;
end

local function ConvertCameraInfoToDisplayData(cameraInfo)
	if not cameraInfo then
		return;
	end

	local displayData = {};
	displayData.modelSceneCameraID = cameraInfo.modelSceneCameraID;
	displayData.scriptTag = cameraInfo.scriptTag;

	displayData.targetX = RoundToSignificantDigits(cameraInfo.target.x + .01, 2);
	displayData.targetY = RoundToSignificantDigits(cameraInfo.target.y + .01, 2);
	displayData.targetZ = RoundToSignificantDigits(cameraInfo.target.z + .01, 2);

	displayData.yaw = math.floor(math.deg(cameraInfo.yaw) + .01);
	displayData.pitch = math.floor(math.deg(cameraInfo.pitch) + .01);
	displayData.roll = math.floor(math.deg(cameraInfo.roll) + .01);

	displayData.zoomDistance = RoundToSignificantDigits(cameraInfo.zoomDistance + .01, 2);
	displayData.minZoomDistance = RoundToSignificantDigits(cameraInfo.minZoomDistance + .01, 2);
	displayData.maxZoomDistance = RoundToSignificantDigits(cameraInfo.maxZoomDistance + .01, 2);

	displayData.zoomedTargetOffset = cameraInfo.zoomedTargetOffset;

	displayData.zoomedYawOffset = math.floor(math.deg(cameraInfo.zoomedYawOffset) + .01);
	displayData.zoomedPitchOffset = math.floor(math.deg(cameraInfo.zoomedPitchOffset) + .01);
	displayData.zoomedRollOffset = math.floor(math.deg(cameraInfo.zoomedRollOffset) + .01);
	displayData.flags = cameraInfo.flags;
	displayData.readableTag = "";
	return displayData;
end

local function GetDefaultActorDisplayInfoDisplayData()
	local actorDisplayInfo = {};
	actorDisplayInfo.animationKitID = nil;
	actorDisplayInfo.animation = nil;
	actorDisplayInfo.animationVariation = 0;
	actorDisplayInfo.animSpeed = 1;
	actorDisplayInfo.spellVisualKitID = nil;
	actorDisplayInfo.alpha = 1;
	actorDisplayInfo.scale = 1;
	return actorDisplayInfo;
end

local function GetDefaultActorDisplayData(flags)
	local displayData = {};
	displayData.modelActorID = nil;
	displayData.scriptTag = "";

	displayData.autoDress = true;
	displayData.hideWeapon = false;
	displayData.sheatheWeapon = true;

	displayData.useCenterForOriginX = false;
	displayData.useCenterForOriginY = false;
	displayData.useCenterForOriginZ = false;

	displayData.actorX = 0;
	displayData.actorY = 0;
	displayData.actorZ = 0;

	displayData.yaw = 0;
	displayData.pitch = 0;
	displayData.roll = 0;

	displayData.normalizeScaleAggressiveness = 0;
	displayData.readableTag = "";

	displayData.modelActorDisplayID = 0;

	displayData.actorDisplayInfoData = GetDefaultActorDisplayInfoDisplayData();

	return displayData;
end

local function ConvertActorInfoToDisplayData(actorInfo, modelSceneFlags)
	local displayData = {};
	displayData.modelActorID = actorInfo.modelActorID;
	displayData.scriptTag = actorInfo.scriptTag;

	displayData.autoDress = bit.band(modelSceneFlags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
	displayData.hideWeapon = bit.band(modelSceneFlags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
	displayData.sheatheWeapon = bit.band(modelSceneFlags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
	displayData.noCameraSpin = bit.band(modelSceneFlags, Enum.UIModelSceneFlags.NoCameraSpin) == Enum.UIModelSceneFlags.NoCameraSpin;

	displayData.useCenterForOriginX = actorInfo.useCenterForOriginX;
	displayData.useCenterForOriginY = actorInfo.useCenterForOriginY;
	displayData.useCenterForOriginZ = actorInfo.useCenterForOriginZ;

	displayData.actorX = RoundToSignificantDigits(actorInfo.position.x + .01, 2);
	displayData.actorY = RoundToSignificantDigits(actorInfo.position.y + .01, 2);
	displayData.actorZ = RoundToSignificantDigits(actorInfo.position.z + .01, 2);

	displayData.yaw = math.floor(math.deg(actorInfo.yaw) + .01);
	displayData.pitch = math.floor(math.deg(actorInfo.pitch) + .01);
	displayData.roll = math.floor(math.deg(actorInfo.roll) + .01);

	displayData.normalizeScaleAggressiveness = actorInfo.normalizeScaleAggressiveness or 0;
	displayData.readableTag = "";

	displayData.modelActorDisplayID = actorInfo.modelActorDisplayID;
	if C_Glue.IsOnGlueScreen() then
		displayData.actorDisplayInfoData = GetDefaultActorDisplayInfoDisplayData();
	else
		local actorDisplayInfoData = actorInfo.modelActorDisplayID and C_ModelInfo.GetModelSceneActorDisplayInfoByID(actorInfo.modelActorDisplayID);
		local actorDisplayData = {};
		actorDisplayData.animationKitID = actorDisplayInfoData.animationKitID;
		actorDisplayData.animation = actorDisplayInfoData.animation;
		actorDisplayData.animationVariation = actorDisplayInfoData.animationVariation;
		actorDisplayData.animSpeed = actorDisplayInfoData.animSpeed;
		actorDisplayData.spellVisualKitID = actorDisplayInfoData.spellVisualKitID;
		actorDisplayData.alpha = actorDisplayInfoData.alpha;
		actorDisplayData.scale = actorDisplayInfoData.scale;
		displayData.actorDisplayInfoData = actorDisplayData;
	end
	return displayData;
end

local function GetFlagsDisplayData(flags)
	local flagsData = {};
	flagsData.flags = flags;
	flagsData.sheatheWeapon = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
	flagsData.hideWeapon = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
	flagsData.autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
	flagsData.noCameraSpin = bit.band(flags, Enum.UIModelSceneFlags.NoCameraSpin) == Enum.UIModelSceneFlags.NoCameraSpin;
	return flagsData;
end

local function GetDefaultFlagsDisplayData()
	local flagsData = {};
	flagsData.flags = 0;
	flagsData.sheatheWeapon = true;
	flagsData.hideWeapon = false;
	flagsData.autoDress = true;
	flagsData.noCameraSpin = false;
	return flagsData;
end

local function GetDefaultActorInfo(modelSceneID, playerRaceName, playerRaceNameActorTag)
	local _, _, defaultActorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
	if #defaultActorIDs > 0 then
		local returnActorInfo;
		for i, defaultActorID in ipairs(defaultActorIDs) do
			local tempActorInfo = C_ModelInfo.GetModelSceneActorInfoByID(defaultActorID);
			
			if tempActorInfo.scriptTag == playerRaceNameActorTag then
				return tempActorInfo;
			end

			if tempActorInfo.scriptTag == playerRaceName then
				returnActorInfo = tempActorInfo;
			end
		end
		return returnActorInfo;
	end
end

--[[

CatalogShopUtil is a system for taking relevant product info and "flattening" it into a single "display data" table.  There is an auto tools system
used by the UI team and it can only work with a single flat table.  

]]
CatalogShopUtil = {};
function CatalogShopUtil.GetPlayerActorLabelTag(useAlternateForm)
	local playerGender;
	local playerRaceNameTag;
	local playerRaceGenderNameTag;

	if C_Glue.IsOnGlueScreen() then
		local characterGuid = GetCharacterGUID(GetCharacterSelection());
		if characterGuid then
			local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
			playerRaceNameTag = basicCharacterInfo.raceFilename;
			playerGender = basicCharacterInfo.genderEnum;
		end
	else
		local _, raceFilename = UnitRace("player");
		playerRaceNameTag = raceFilename;
		playerGender = UnitSex("player");
		playerGender = (playerGender == 2) and "male" or "female";
	end

	if not playerRaceNameTag or not playerGender then
		return playerRaceNameTag;
	end
	playerRaceNameTag = playerRaceNameTag:lower();
	if useAlternateForm then
		playerRaceNameTag = playerRaceNameTag.."-alt";
	end
	playerRaceGenderNameTag = playerRaceNameTag.."-"..playerGender;
	return playerRaceNameTag, playerRaceGenderNameTag;
end

function CatalogShopUtil.CreateDefaultProductDisplayData()
	local newDisplayData = {};
	newDisplayData.actorDisplayBucket = {};
	newDisplayData.flagsData = GetDefaultFlagsDisplayData();
	newDisplayData.cameraDisplayData = GetDefaultCameraDisplayData();
	local actorDisplayData = GetDefaultActorDisplayData(newDisplayData.flagsData.flags);
	table.insert(newDisplayData.actorDisplayBucket, actorDisplayData);
	return newDisplayData;
end

function CatalogShopUtil.ExtractProductInfoForDisplayData(productInfo)
	local data = {};
	if productInfo then
		data.productCardType = productInfo.productType;
		data.creatureDisplayInfoID = productInfo.creatureDisplayInfoIDs and productInfo.creatureDisplayInfoIDs[1] or nil;	-- RNM : Currently only grabbing first or nil (#CAROUSEL)
		data.spellVisualID = productInfo.spellVisualIDs and productInfo.spellVisualIDs[1] or nil;	-- RNM : Currently only grabbing first or nil
		data.itemModifiedAppearanceIDs = productInfo.itemModifiedAppearanceIDs;
		data.mainHandItemModifiedAppearanceID = productInfo.mainHandItemModifiedAppearanceID;
		data.offHandItemModifiedAppearanceID = productInfo.offHandItemModifiedAppearanceID;
	end
	return data
end

function CatalogShopUtil.TranslateProductInfoToProductDisplayData(productInfo, defaultModelSceneID, overrideModelSceneID)
	local selectedModelSceneID = overrideModelSceneID or defaultModelSceneID;
	if not selectedModelSceneID then
		error("CatalogShopUtil.TranslateDisplayInfo : invalid modelSceneID")
		return CatalogShopUtil.CreateDefaultProductDisplayData();
	end

	local newDisplayData = {};

	local _, cameraIDs, actorIDs, flags = C_ModelInfo.GetModelSceneInfoByID(defaultModelSceneID);
	local _, overrideCameraIDs, overrideActorIDs, overrideFlags;
	if overrideModelSceneID then
		_, overrideCameraIDs, overrideActorIDs, overrideFlags = C_ModelInfo.GetModelSceneInfoByID(overrideModelSceneID);
	end

	-- GET FLAGS DATA
	if flags then
		newDisplayData.flagsData = GetFlagsDisplayData(flags);
	else
		newDisplayData.flagsData = GetDefaultFlagsDisplayData();
	end

	-- GET OVERRIDE FLAGS DATA
	if overrideFlags then
		newDisplayData.overrideFlagsData = GetFlagsDisplayData(overrideFlags);
	else
		newDisplayData.overrideFlagsData = nil;
	end

	-- GET REGULAR CAMERA
	if cameraIDs and #cameraIDs > 0 then
		local cameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(cameraIDs[1]);
		newDisplayData.cameraDisplayData = ConvertCameraInfoToDisplayData(cameraInfo);
	else
		newDisplayData.cameraDisplayData = GetDefaultCameraDisplayData();
	end

	-- GET OVERRIDE CAMERA
	if overrideCameraIDs and #overrideCameraIDs > 0 then
		local cameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(overrideCameraIDs[1]);
		newDisplayData.overrideCameraDisplayData = ConvertCameraInfoToDisplayData(cameraInfo);
	else
		newDisplayData.overrideCameraDisplayData = nil;
	end

	-- GET REGULAR ACTORS
	if actorIDs and #actorIDs > 0 then
		local currentFlags = newDisplayData.flagsData.flags;
		newDisplayData.actorDisplayBucket = {};
		for _, actorID in ipairs(actorIDs) do
			local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(actorID);
			if actorInfo then
				local actorDisplayData = ConvertActorInfoToDisplayData(actorInfo, currentFlags);

				if not C_Glue.IsOnGlueScreen() then
					local hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
					local cardType = productInfo.productType;
					if hasAlternateForm and cardType == "Transmog" then
						local useAlternateForm = true;
						local playerRaceName, playerRaceNameActorTag = CatalogShopUtil.GetPlayerActorLabelTag(useAlternateForm);
						local alternateFormActorInfo = GetDefaultActorInfo(productInfo.defaultPreviewModelSceneID, playerRaceName, playerRaceNameActorTag);
						actorDisplayData.alternateFormDisplayData = ConvertActorInfoToDisplayData(alternateFormActorInfo, currentFlags);
					end
				end
				table.insert(newDisplayData.actorDisplayBucket, actorDisplayData);
			end
		end
	end

	-- GET OVERRIDE ACTOR
	if overrideActorIDs and #overrideActorIDs > 0 then
		local currentFlags = newDisplayData.overrideFlagsData.flags;
		newDisplayData.overrideActorDisplayBucket = {};
		local actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(overrideActorIDs[1]); -- only one override actor
		if actorInfo then
			local actorDisplayData = ConvertActorInfoToDisplayData(actorInfo, currentFlags);

			if not C_Glue.IsOnGlueScreen() then
				local hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
				local cardType = productInfo.productType;
				if hasAlternateForm and cardType == "Transmog" then
					local useAlternateForm = true;
					local playerRaceName, playerRaceNameActorTag = CatalogShopUtil.GetPlayerActorLabelTag(useAlternateForm);
					local alternateFormActorInfo = GetDefaultActorInfo(productInfo.defaultPreviewModelSceneID, playerRaceName, playerRaceNameActorTag);
					actorDisplayData.alternateFormDisplayData = ConvertActorInfoToDisplayData(alternateFormActorInfo, currentFlags);
				end
			end
			table.insert(newDisplayData.overrideActorDisplayBucket, actorDisplayData);
		end
	end

	newDisplayData.defaultModelSceneID = defaultModelSceneID;
	newDisplayData.overrideModelSceneID = overrideModelSceneID;
	newDisplayData.selectedModelSceneID = selectedModelSceneID;

	local productData = CatalogShopUtil.ExtractProductInfoForDisplayData(productInfo);
	newDisplayData.productCardType = productData.productCardType or nil;
	newDisplayData.creatureDisplayInfoID = productData.creatureDisplayInfoID or nil;
	newDisplayData.spellVisualID = productData.spellVisualID or nil;
	newDisplayData.itemModifiedAppearanceIDs = productData.itemModifiedAppearanceIDs or nil;
	newDisplayData.mainHandItemModifiedAppearanceID = productData.mainHandItemModifiedAppearanceID or nil;
	newDisplayData.offHandItemModifiedAppearanceID = productData.offHandItemModifiedAppearanceID or nil;

	return newDisplayData;
end

-- BUNDLES
function CatalogShopUtil.SetupModelSceneForBundle(modelScene, modelSceneID, displayData, modelLoadedCB, forceHidePlayer)
-- This is for displaying the contents of a bundle in a single model scene. We are expecting a naming convention ('tag'+numeral. ) -- > continue this documentation
-- We derive context from the actor script tag within the modelScene

	local forceSceneChange = true;
	modelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	forceSceneChange = false;		-- When adding the child products to the model scene we never want to forceSceneChange

	-- Create the actor tags for bundle child products based on their type and displayOrder
		-- Sort the bundle children by their displayOrder
		-- iterate over all children, while tracking the last instance # of each type of child.
		-- build the actor tag string by concatenating the type and the instance number (e.g. "mount1", "transmog1", "mount2", etc.)
		-- add "player-rider1" (player-rider is a tag for mount type)
	table.sort(displayData.bundleChildrenDisplayData, function(lhs, rhs)
		return (lhs.displayOrder < rhs.displayOrder);
	end);
	local nextPet = 1;
	local nextMount = 1;
	local nextToy = 1;
	local nextMog = 1;
	for _, childDisplayData in ipairs(displayData.bundleChildrenDisplayData) do
		if childDisplayData.productCardType == CatalogShopConstants.ProductCardType.Pet then
			childDisplayData.modelSceneTag = CatalogShopConstants.DefaultActorTag.Pet .. tostring(nextPet);
			nextPet = nextPet + 1;
		elseif childDisplayData.productCardType == CatalogShopConstants.ProductCardType.Mount then
			childDisplayData.modelSceneTag = CatalogShopConstants.DefaultActorTag.Mount .. tostring(nextMount);
			-- RNMTODO : Look for transmog-rider#
			local riderTag = "player-rider" .. tostring(nextMount);
			local playerRiderActor = modelScene:GetActorByTag(riderTag);
			childDisplayData.mountRiderTag = nil;
			childDisplayData.showRider = false;
			if playerRiderActor then
				childDisplayData.showRider = true;
				childDisplayData.mountRiderTag = riderTag;
			end
			nextMount = nextMount + 1;
		elseif childDisplayData.productCardType == CatalogShopConstants.ProductCardType.Toy then
			childDisplayData.modelSceneTag = CatalogShopConstants.DefaultActorTag.Toy .. tostring(nextToy);
			nextToy = nextToy + 1;
		elseif childDisplayData.productCardType == CatalogShopConstants.ProductCardType.Transmog then
			childDisplayData.modelSceneTag = CatalogShopConstants.DefaultActorTag.Transmog .. tostring(nextMog);
			nextMog = nextMog + 1;
		end
	end

	local modelSceneChanged = true;		-- For now this should always be true (special case for Bundles)

	local function FindChildDisplayDataMatchingTag(tag)
		for _, childDisplayData in ipairs(displayData.bundleChildrenDisplayData) do
			if childDisplayData.modelSceneTag == tag then
				return childDisplayData;
			end
		end
		return nil;
	end

	-- Set up the bundle model scene for each child based on what the model scene asks for.
		-- For each tag in the model scene, find it in our bundleChildrenDisplayData
		-- If found, update the model scene with the information in that childDisplayData
	local lastFoundTag = nil;
	for tag, _actor in pairs(modelScene.tagToActor) do
		local foundChildDisplayData = FindChildDisplayDataMatchingTag(tag);
		if foundChildDisplayData then
			lastFoundTag = tag;
			if foundChildDisplayData.productCardType == CatalogShopConstants.ProductCardType.Mount then
				local _modelSceneId = nil;
				local shouldHidePlayer = forceHidePlayer or not foundChildDisplayData.showRider;
				CatalogShopUtil.SetupModelSceneForMounts(modelScene, _modelSceneId, foundChildDisplayData, modelLoadedCB, forceSceneChange, shouldHidePlayer, tag, foundChildDisplayData.mountRiderTag);
			elseif foundChildDisplayData.productCardType == CatalogShopConstants.ProductCardType.Pet then
				local _modelSceneId = nil;
				CatalogShopUtil.SetupModelSceneForPets(modelScene, _modelSceneId, foundChildDisplayData, modelLoadedCB, forceSceneChange, tag);
			elseif foundChildDisplayData.productCardType == CatalogShopConstants.ProductCardType.Transmog then
				local _modelSceneId = nil;
				local _preserveCurrentView = false;
				CatalogShopUtil.SetupModelSceneForTransmogsForBundles(modelScene, _modelSceneId, foundChildDisplayData, modelLoadedCB, forceSceneChange, preserveCurrentView);
			end
		end
	end

	-- Calling update model scene on the bundle to pick up camera changes
	-- RNM : Only update the camera. All model data was updated in modelScene by child products (see above). The bundle displayData is only for the camera in the modelScene.
	CatalogShopUtil.UpdateModelSceneCameraOnlyWithDisplayData(modelScene, displayData);

	-- Trigger updates
	if modelSceneChanged then
		EventRegistry:TriggerEvent("CatalogShop.OnModelSceneChanged", modelScene);
	end

	-- Return the modelSceneTag associated with the model scene (if any)
	return lastFoundTag;
end

-- MOUNTS
function CatalogShopUtil.SetupModelSceneForMounts(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, forceHidePlayer, optionalMountTag, optionalRiderTag)
	if not displayData then
		error("CatalogShopUtil.SetupModelSceneForMounts : invalid displayData")
		return;
	end

	local mountTag = optionalMountTag or CatalogShopConstants.DefaultActorTag.Mount;
	local creatureDisplayID = displayData.creatureDisplayInfoID;
	if creatureDisplayID then
		if forceSceneChange then
			modelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
		end

		local actor = modelScene:GetActorByTag(mountTag);
		if actor then
			if modelLoadedCB then
				actor:SetOnModelLoadedCallback(GenerateClosure(modelLoadedCB, modelScene, actor));
			end
			actor:SetModelByCreatureDisplayID(creatureDisplayID);

			if (isSelfMount) then
				actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
				actor:SetAnimation(CatalogShopConstants.DefaultAnimID.MountSelfIdle);
			else
				actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim);
				actor:SetAnimation(0);
			end
			local showPlayer = forceHidePlayer == nil or not forceHidePlayer; -- fetch this instead
			local useNativeForm = CatalogShopFrame:GetUseNativeForm();
			--local useNativeForm = true; -- fetch this

			local isSelfMount = false;
			local disablePlayerMountPreview = false; -- some mounts are flagged to not show the player on the mount - this is static data we need to fetch
			local spellVisualInfo = C_CatalogShop.GetSpellVisualInfoForMount(displayData.spellVisualID);
			local spellVisualKitID = spellVisualInfo and spellVisualInfo.spellVisualKitID or nil;
			local animID = spellVisualInfo and spellVisualInfo.animID or nil;

			--local defaultCreatureDisplayID, descriptionText, sourceText, isSelfMount, _, _, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(data.mountID);
			-- RNM : This would be nice to skip if it's a card
			if (showPlayer) then
				modelScene:AttachPlayerToMount(actor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, useNativeForm, optionalRiderTag);
			end

			local tryUseOverrideAnim = true;
			CatalogShopUtil.UpdateModelSceneWithDisplayData(modelScene, displayData, tryUseOverrideAnim);
		end
	end
	EventRegistry:TriggerEvent("CatalogShop.OnModelSceneChanged", modelScene);
end

-- DEFAULT PLAYER
function CatalogShopUtil.SetupModelSceneForPlayer(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, optionalData)
	CatalogShopUtil.SetupModelSceneForTransmogs(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange);

	if modelScene.CachedPlayerActor then
		if optionalData then
			if optionalData.yaw then
				local playerCamera = modelScene:GetCameraByTag(CatalogShopConstants.DefaultCameraTag.Primary);
				playerCamera:SetYaw(math.rad(optionalData.yaw));
			end

			if optionalData.Offset then
				local currentX, currentY, currentZ= modelScene.CachedPlayerActor:GetPosition();
				local x = currentX + optionalData.Offset.x;
				local y = currentY + optionalData.Offset.y;
				local z = currentY + optionalData.Offset.z;
				modelScene.CachedPlayerActor:SetPosition(x, y, z);
			end
		end
	end
end

-- GETTING PLAYER WHILE INGAME
function CatalogShopUtil.SetupPlayerModelSceneForInGame(playerData, modelLoadedCB)
	if not playerData then
		return;
	end
		
	local actor = nil;
	if playerData.overrideActorName then
		actor = playerData.modelScene:GetPlayerActor(playerData.overrideActorName);
	else
		local useAlternateForm = false or (not playerData.useNativeForm);
		local playerRaceNameTag, playerRaceGenderNameTag = CatalogShopUtil.GetPlayerActorLabelTag(useAlternateForm);
		actor = playerData.modelScene:GetPlayerActor(playerRaceGenderNameTag);
		if not actor then
			actor = playerData.modelScene:GetPlayerActor(playerRaceNameTag);
		end
	end
	if not actor then
		error("CatalogShopUtil.SetupPlayerModelSceneForInGame : invalid actor")
		return nil;
	end
	if modelLoadedCB then
		actor:SetOnModelLoadedCallback(GenerateClosure(modelLoadedCB, playerData.modelScene, actor));
	end

	if playerData.forceSceneChange or playerData.useNativeForm ~= playerData.modelScene.useNativeForm then
		playerData.modelScene.useNativeForm = useNativeForm;
		local holdBowString = true;
		actor:SetModelByUnit("player", playerData.sheatheWeapon, playerData.autoDress, playerData.hideWeapon, playerData.useNativeForm, holdBowString);
	else
		if playerData.autoDress then
			actor:Dress();
		else
			actor:Undress();
		end
	end
	actor.dressed = playerData.autoDress;

	if playerData.itemModifiedAppearanceIDs then
		for i, itemModifiedAppearanceID in ipairs(playerData.itemModifiedAppearanceIDs) do
			CatalogShopUtil.CatalogShopTryOn(actor, itemModifiedAppearanceID);
			--actor:TryOn(itemModifiedAppearanceID);
		end
	end
	actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
	return actor;
end

-- GETTING PLAYER WHILE AT GLUES
function CatalogShopUtil.SetupPlayerModelSceneForGlues(playerData, modelLoadedCB)
	if not playerData then
		return;
	end

	--local actor = playerData.modelScene:GetPlayerActor(playerData.overrideActorName, forceAlternateForm);
	local actor = nil;
	if playerData.overrideActorName then
		actor = playerData.modelScene:GetPlayerActor(playerData.overrideActorName);
	else
		local useAlternateForm = false or (not playerData.useNativeForm);
		local playerRaceNameTag, playerRaceGenderNameTag = CatalogShopUtil.GetPlayerActorLabelTag(useAlternateForm);
		actor = playerData.modelScene:GetPlayerActor(playerRaceGenderNameTag);
		if not actor then
			actor = playerData.modelScene:GetPlayerActor(playerRaceNameTag);
		end
	end

	if not actor then
		error("CatalogShopUtil.SetupPlayerModelSceneForGlues : invalid actor")
		return nil;
	end
	if modelLoadedCB then
		actor:SetOnModelLoadedCallback(GenerateClosure(modelLoadedCB, playerData.modelScene, actor));
	end

	local characterIndex = nil;  -- defaults to selected character.
	actor:SetPlayerModelFromGlues(characterIndex, playerData.sheatheWeapon, playerData.autoDress, playerData.hideWeapon, playerData.useNativeForm);
	if playerData.itemModifiedAppearanceIDs then
		for i, itemModifiedAppearanceID in ipairs(playerData.itemModifiedAppearanceIDs) do
			actor:TryOn(itemModifiedAppearanceID);
		end
	end
	actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
	return actor;
end

function CatalogShopUtil.SetupModelSceneForTransmogs(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView)
	if modelScene.CachedPlayerActor then
		modelScene.CachedPlayerActor:ClearModel();
	end
	CatalogShopUtil.SetupModelSceneForTransmogsInternal(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView);
end

function CatalogShopUtil.SetupModelSceneForTransmogsForBundles(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView)
	CatalogShopUtil.SetupModelSceneForTransmogsInternal(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView);
end

-- TRANSMOGS
function CatalogShopUtil.SetupModelSceneForTransmogsInternal(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, preserveCurrentView)
	if forceSceneChange then
		modelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	end

	local hideWeapon, sheatheWeapon, autoDress = false, true, true;
	local useNativeForm = CatalogShopFrame:GetUseNativeForm();

	--local itemModifiedAppearanceID;
	local itemModifiedAppearanceIDs;

	local actorDisplayData = nil;
	if displayData then
		if displayData.overrideActorDisplayBucket and #displayData.overrideActorDisplayBucket > 0 then
			actorDisplayData = displayData.overrideActorDisplayBucket[1];
		elseif displayData.actorDisplayBucket and #displayData.actorDisplayBucket > 0 then
			actorDisplayData = displayData.actorDisplayBucket[1];
		end
	end

	--local actorDisplayData = displayData.overrideActorDisplayBucket[1] or displayData.actorDisplayBucket[1] or nil;
	if actorDisplayData then

		hideWeapon = actorDisplayData.hideWeapon;
		sheatheWeapon = actorDisplayData.sheatheWeapon;

		local hideArmorSetting = CatalogShopFrame:GetHideArmorSetting();
		if hideArmorSetting == nil then
			autoDress = actorDisplayData.autoDress;
		else
			autoDress = not(hideArmorSetting);
		end
		--itemModifiedAppearanceID = displayData.itemModifiedAppearanceID;
		itemModifiedAppearanceIDs = displayData.itemModifiedAppearanceIDs;
	end	
	
	local hasSubItems = data and data.hasSubItems or nil; -- not valid yet
	local overrideActorName = displayData.modelSceneTag;
	local playerData = CatalogShopUtil.TranslatePlayerModelData(modelScene, overrideActorName, itemModifiedAppearanceIDs, hasSubItems, sheatheWeapon, autoDress, hideWeapon, useNativeForm, forceSceneChange);
	
	if C_Glue.IsOnGlueScreen() then
		modelScene.CachedPlayerActor = CatalogShopUtil.SetupPlayerModelSceneForGlues(playerData, modelLoadedCB);
	else
		modelScene.CachedPlayerActor = CatalogShopUtil.SetupPlayerModelSceneForInGame(playerData, modelLoadedCB);
	end

	if displayData and not preserveCurrentView then
		local tryOverrideAttackAnimations = false;
		CatalogShopUtil.UpdateModelSceneWithDisplayData(modelScene, displayData, tryOverrideAttackAnimations);
	end
	EventRegistry:TriggerEvent("CatalogShop.OnModelSceneChanged", modelScene);
end

-- PETS
function CatalogShopUtil.SetupModelSceneForPets(modelScene, modelSceneID, displayData, modelLoadedCB, forceSceneChange, optionalPetTag)
	if not displayData then
		error("CatalogShopUtil.SetupModelSceneForPets : invalid displayData")
		return;
	end

	local petTag = optionalPetTag or CatalogShopConstants.DefaultActorTag.Pet;
	local creatureDisplayID = displayData.creatureDisplayInfoID;
	if creatureDisplayID then
		if forceSceneChange then
			modelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
		end

		local actor = modelScene:GetActorByTag(petTag);
		if actor then
			if modelLoadedCB then
				actor:SetOnModelLoadedCallback(GenerateClosure(modelLoadedCB, modelScene, actor));
			end
			actor:SetModelByCreatureDisplayID(creatureDisplayID);
			actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
			displayData.animationKitID = CatalogShopConstants.DefaultAnimID.PetDefault;
			displayData.desiredScale = 0.35; -- TODO - FIX THIS, we neeed this data from BattlePetSpecies record
			actor:SetRequestedScale(displayData.desiredScale);
						
			local tryUseOverrideAnim = true;
			CatalogShopUtil.UpdateModelSceneWithDisplayData(modelScene, displayData, tryUseOverrideAnim);
		end
	end
	EventRegistry:TriggerEvent("CatalogShop.OnModelSceneChanged", modelScene);
end

function CatalogShopUtil.CatalogShopTryOn(actor, itemModifiedAppearanceID, allowOffHand)
	local itemID = C_TransmogCollection.GetSourceItemID(itemModifiedAppearanceID);
	local invType = select(4, C_Item.GetItemInfoInstant(itemID));

	local isEquippedInOffhand = invType == "INVTYPE_SHIELD"
							or invType == "INVTYPE_WEAPONOFFHAND"
							or invType == "INVTYPE_HOLDABLE";

	local isTwoHandWeapon = invType == "INVTYPE_2HWEAPON"
						or invType == "INVTYPE_RANGED"
						or invType == "INVTYPE_RANGEDRIGHT"
						or invType == "INVTYPE_THROWN";

	local isEquippedInHand = isEquippedInOffhand
						or isTwoHandWeapon
						or invType == "INVTYPE_WEAPON"
						or invType == "INVTYPE_WEAPONMAINHAND";

	if isEquippedInHand then
		local itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(itemModifiedAppearanceID);

		-- Never show player's equipped weapons when trying on weapons
		if isTwoHanded or (not allowOffHand and not isEquippedInOffHand) then
			actor:UndressSlot(INVSLOT_MAINHAND);
			actor:UndressSlot(INVSLOT_OFFHAND);
		end

		-- Since we are manually setting the 2 items in each hand, reset the actors sense of what hand to put stuff into
		actor:ResetNextHandSlot();

		-- actor:SetItemTransmogInfo will automatically handle whether the player can dual wield
		-- If the player can dual wield 1 handed weapons, we will always preview the same weapon appearing in both hands

		-- Only equip 2-hand weapons into 1 slot regardless of whether player can dual wield 2-handed weapons (Titan Grip)
		if not isTwoHandWeapon then
			actor:SetItemTransmogInfo(itemTransmogInfo, INVSLOT_OFFHAND, true);
		end

		-- If the weapon is an off-hand, then only equip it in the off-hand slot
		if not isEquippedInOffhand then
			actor:SetItemTransmogInfo(itemTransmogInfo, INVSLOT_MAINHAND, true);
		end
	else
		actor:TryOn(itemModifiedAppearanceID);
	end
end

function CatalogShopUtil.UpdateActorWithDisplayData(actor, actorDisplayData, isPlayerTransmogScene, tryUseOverrideAnim)
	if not actorDisplayData then
		return;
	end

	actor:SetSheathed(actorDisplayData.sheatheWeapon, actorDisplayData.hideWeapon);
	actor:SetAutoDress(actorDisplayData.autoDress);

	if isPlayerTransmogScene then
		--[[  Transmogs have some unique fixups that are required ]]--
		local hasAlternateForm = false;
		if not C_Glue.IsOnGlueScreen() then
			hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
		end
		local useNativeForm = CatalogShopFrame:GetUseNativeForm();

		local x, y, z = actorDisplayData.actorX, actorDisplayData.actorY, actorDisplayData.actorZ;
		if hasAlternateForm and not useNativeForm then
			x, y, z = actorDisplayData.alternateFormData.posX, actorDisplayData.alternateFormData.posY, actorDisplayData.alternateFormData.posZ;
		end
		actor:SetPosition(x, y, z);

		local actorDisplayInfoData = actorDisplayData.actorDisplayInfoData;
		actor:SetSpellVisualKit(nil);
		actor:StopAnimationKit();
		actor:SetAnimation(0, 0, 1.0);
		if tryUseOverrideAnim then
			SetAnimations(actor, actorDisplayInfoData);
		end		
		actor:SetSpellVisualKit(actorDisplayInfoData.spellVisualKitID or actorDisplayData.spellVisualID);
	else
		local x, y, z = actorDisplayData.actorX, actorDisplayData.actorY, actorDisplayData.actorZ;
		actor:SetPosition(x, y, z);
	end

	actor:SetYaw(math.rad(actorDisplayData.yaw));
	actor:SetPitch(math.rad(actorDisplayData.pitch));
	actor:SetRoll(math.rad(actorDisplayData.roll));
end

function CatalogShopUtil.UpdateModelSceneCameraOnlyWithDisplayData(modelScene, displayData)
	if not displayData then
		return;
	end

	-- APPLY CAMERA DISPLAY DATA
	local camera;
	local cameraDisplayData = displayData.cameraDisplayData;
	if cameraDisplayData then
		camera = modelScene:GetCameraByTag(cameraDisplayData.scriptTag);
		if camera then
			UpdateCamera(camera, cameraDisplayData);
		end
	end

	-- APPLY OVERRIDE CAMERA DISPLAY DATA
	local overrideCameraDisplayData = displayData.overrideCameraDisplayData;
	if camera and overrideCameraDisplayData then
		if camera then
			UpdateCamera(camera, overrideCameraDisplayData);
		end
	end
end

function CatalogShopUtil.UpdateModelSceneWithDisplayData(modelScene, displayData, tryUseOverrideAnim)
	if not displayData then
		return;
	end

	-- APPLY CAMERA DISPLAY DATA
	local camera;
	local cameraDisplayData = displayData.cameraDisplayData;
	if cameraDisplayData then
		camera = modelScene:GetCameraByTag(cameraDisplayData.scriptTag);
		if camera then
			UpdateCamera(camera, cameraDisplayData);
		end
	end

	-- APPLY OVERRIDE CAMERA DISPLAY DATA
	local overrideCameraDisplayData = displayData.overrideCameraDisplayData;
	if camera and overrideCameraDisplayData then
		if camera then
			UpdateCamera(camera, overrideCameraDisplayData);
		end
	end

	-- APPLY CHANGES TO ACTOR
	local productCardType = displayData.productCardType;
	local isTransmogScene = false;
	local actor;
	local modelSceneTag = displayData.modelSceneTag or nil;

	if modelSceneTag == nil then
		if productCardType == CatalogShopConstants.ProductCardType.Mount then
			modelSceneTag = CatalogShopConstants.DefaultActorTag.Mount;
		elseif productCardType == CatalogShopConstants.ProductCardType.Pet then
			modelSceneTag = CatalogShopConstants.DefaultActorTag.Pet;
		end
	end

	if productCardType == CatalogShopConstants.ProductCardType.Transmog then
		actor = modelScene.CachedPlayerActor;
		isTransmogScene = true;
	elseif modelSceneTag ~= nil then
		actor = modelScene:GetActorByTag(modelSceneTag);
	end

	local overrideActorDiplayData = displayData.overrideActorDisplayBucket and displayData.overrideActorDisplayBucket[1] or nil;
	if actor then
		CatalogShopUtil.UpdateActorWithDisplayData(actor, actorDisplayData, isTransmogScene, tryUseOverrideAnim)
		if overrideActorDiplayData then
			CatalogShopUtil.UpdateActorWithDisplayData(actor, overrideActorDiplayData, isTransmogScene, tryUseOverrideAnim)
		end
	else
		-- TODO we have something else, maybe a bundle?
		local actorDisplayBucket = displayData.actorDisplayBucket;
		for i, actorDisplayData in ipairs(actorDisplayBucket) do
			actor = modelScene:GetActorByTag(actorDisplayData.scriptTag);
			if actor then
				CatalogShopUtil.UpdateActorWithDisplayData(actor, actorDisplayData, isTransmogScene, tryUseOverrideAnim)
				if overrideActorDiplayData then
					CatalogShopUtil.UpdateActorWithDisplayData(actor, overrideActorDiplayData, isTransmogScene, tryUseOverrideAnim)
				end
			end
		end
	end
end

function CatalogShopUtil.TranslatePlayerModelData(modelScene, overrideActorName, itemModifiedAppearanceIDs, hasSubItems, sheatheWeapon, autoDress, hideWeapon, useNativeForm, forceSceneChange)
	local returnTable = { modelScene = modelScene, overrideActorName = overrideActorName, itemModifiedAppearanceIDs = itemModifiedAppearanceIDs,
						hasSubItems = hasSubItems, sheatheWeapon = sheatheWeapon, autoDress = autoDress, hideWeapon = hideWeapon,
						useNativeForm = useNativeForm, forceSceneChange = forceSceneChange };
	return returnTable;
end

-- This is copied from WowTokenUI.lua
function CatalogShopUtil.GetSecureMoneyString(money, separateThousands, forceColorBlind)
	local goldString, silverString, copperString;
	local floor = math.floor;

	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = money % COPPER_PER_SILVER;

	if ( (not C_Glue.IsOnGlueScreen() and GetCVar("colorblindMode") == "1" ) or forceColorBlind ) then
		if (separateThousands) then
			goldString = formatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL;
		else
			goldString = gold..GOLD_AMOUNT_SYMBOL;
		end
		silverString = silver..SILVER_AMOUNT_SYMBOL;
		copperString = copper..COPPER_AMOUNT_SYMBOL;
	else
		if (separateThousands) then
			goldString = string.format(GOLD_AMOUNT_TEXTURE_STRING, formatLargeNumber(gold), 0, 0);
		else
			goldString = string.format(GOLD_AMOUNT_TEXTURE, gold, 0, 0);
		end
		silverString = string.format(SILVER_AMOUNT_TEXTURE, silver, 0, 0);
		copperString = string.format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
	end

	local moneyString = "";
	local separator = "";
	if ( gold > 0 ) then
		moneyString = goldString;
		separator = " ";
	end
	if ( silver > 0 ) then
		moneyString = moneyString..separator..silverString;
		separator = " ";
	end
	if ( copper > 0 or moneyString == "" ) then
		moneyString = moneyString..separator..copperString;
	end

	return moneyString;
end

function CatalogShopUtil.GetDescriptionText(productInfo, displayInfo)
	local cardType = displayInfo.productType;

	-- TODO: Investigate alternative text for some types (WOW11-138782)
	if cardType == CatalogShopConstants.ProductCardType.Pet
		or cardType == CatalogShopConstants.ProductCardType.Mount
		or cardType == CatalogShopConstants.ProductCardType.Toy
		or cardType == CatalogShopConstants.ProductCardType.Transmog
		or cardType == CatalogShopConstants.ProductCardType.Token then
		return displayInfo.itemDescription;
	else
		return productInfo.description;
	end
end

function CatalogShopUtil.SetServicesContainerIcon(icon, displayInfo)
	-- Prefer texture kit if set.
	if displayInfo.iconTextureKit then
		local formattedIcon = ("%s-large"):format(displayInfo.iconTextureKit);
		icon:SetAtlas(formattedIcon);
	elseif displayInfo.iconFileDataID then
		SetPortraitToTexture(icon, displayInfo.iconFileDataID);
	end
end

function CatalogShopUtil.SetAlternateProductIcon(icon, displayInfo)
	if displayInfo.otherProductImageAtlasName then
		icon:SetAtlas(displayInfo.otherProductImageAtlasName);
	end
end
