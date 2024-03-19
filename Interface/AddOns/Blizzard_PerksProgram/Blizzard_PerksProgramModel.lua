
local DEFAULT_PET_ACTOR_TAG = "pet";
local DEFAULT_MOUNT_ACTOR_TAG = "mount";
local DEFAULT_CAMERA_TAG = "primary";
local DEFAULT_TOY_ACTOR_TAG = "actor";
local DEFAULT_FANFARE_ACTOR_TAG = "fanfare";
local MOUNT_SELF_IDLE_ANIM = 618;
local PET_DEFAULT_ANIM_ID = 23877;
local DEFAULT_CELEBRATE_MODEL_SCENE_ID = 641;

local DefaultInsets = {left=230, right=0, top=100, bottom=0};

local DropShadowSettings = {};
DropShadowSettings["PET_MAIN"] = {targetX=140, targetY=-370, width=400, height=175};
DropShadowSettings["PET_PLAYER"] = {targetX=300, targetY=-275, width=275, height=125};
DropShadowSettings["MOUNT_MAIN"] = {targetX=130, targetY=-330, width=500, height=225};
DropShadowSettings["TRANSMOG_PLAYER"] = {targetX=140, targetY=-350, width=500, height=225};

function PerksProgram_GetPlayerActorLabelTag(useAlternateForm)
	local _, raceFilename = UnitRace("player");
	local playerRaceNameTag = raceFilename:lower();

	local playerGender = UnitSex("player");
	playerGender = (playerGender == 2) and "male" or "female";

	if not playerRaceNameTag or not playerGender then
		return playerRaceNameTag;
	end

	if useAlternateForm then
		playerRaceNameTag = playerRaceNameTag.."-alt";
	end
	local playerRaceGenderNameTag = playerRaceNameTag.."-"..playerGender;
	return playerRaceNameTag, playerRaceGenderNameTag;
end

local function UpdateCameraTargetPositionData(camera, displayData)
	if camera then
		displayData.cameraTargetX = RoundToSignificantDigits(displayData.cameraTargetX, 1);
		displayData.cameraTargetY = RoundToSignificantDigits(displayData.cameraTargetY, 1);
		displayData.cameraTargetZ = RoundToSignificantDigits(displayData.cameraTargetZ, 1);
	end
end

local function SetCameraTargetPosition(camera, targetX, targetY, targetZ)
	if camera then
		local x, y, z = camera:GetTarget();
		x = RoundToSignificantDigits(targetX or x, 1);
		y = RoundToSignificantDigits(targetY or y, 1);
		z = RoundToSignificantDigits(targetZ or z, 1);
		camera:SetTarget(x, y, z);
	end
end

local function UpdateCameraRotationalData(camera, displayData)
	if camera then
		displayData.cameraYaw = RoundToSignificantDigits(displayData.cameraYaw, 1);
		displayData.cameraPitch = RoundToSignificantDigits(displayData.cameraPitch, 1);
		displayData.cameraRoll = RoundToSignificantDigits(displayData.cameraRoll, 1);
	end
end

local function SetCameraRotation(camera, displayData)
	if camera then
		camera:SetYaw(math.rad(displayData.cameraYaw));
		camera:SetPitch(math.rad(displayData.cameraPitch));
		camera:SetRoll(math.rad(displayData.cameraRoll));
	end
end

local function UpdateCameraZoomData(camera, displayData)
	if camera then
		displayData.cameraZoomDistance = RoundToSignificantDigits(displayData.cameraZoomDistance, 1);
		displayData.cameraMinZoomDistance = RoundToSignificantDigits(displayData.cameraMinZoomDistance, 1);
		displayData.cameraMaxZoomDistance = RoundToSignificantDigits(displayData.cameraMaxZoomDistance, 1);
	end
end

local function SetCameraZoom(camera, displayData)
	if camera then
		camera:SetMinZoomDistance(displayData.cameraMinZoomDistance);
		camera:SetMaxZoomDistance(displayData.cameraMaxZoomDistance);
		camera:SetZoomDistance(displayData.cameraZoomDistance);
	end
end

local function UpdateActorPositionalData(actor, displayData)
	if actor then
		displayData.posX = RoundToSignificantDigits(displayData.posX, 1);
		displayData.posY = RoundToSignificantDigits(displayData.posY, 1);
		displayData.posZ = RoundToSignificantDigits(displayData.posZ, 1);
	end
end

local function SetActorPosition(actor, posX, posY, posZ)
	if actor then
		local x, y, z = actor:GetPosition();
		x = RoundToSignificantDigits(posX or x, 1);
		y = RoundToSignificantDigits(posY or y, 1);
		z = RoundToSignificantDigits(posZ or z, 1);
		actor:SetPosition(x, y, z);
	end
end

local function UpdateActorRotationalData(actor, displayData)
	if actor then
		displayData.yaw = RoundToSignificantDigits(displayData.yaw, 1);
		displayData.pitch = RoundToSignificantDigits(displayData.pitch, 1);
		displayData.roll = RoundToSignificantDigits(displayData.roll, 1);
	end
end

local function SetActorRotation(actor, displayData)
	if actor then
		actor:SetYaw(math.rad(displayData.yaw));
		actor:SetPitch(math.rad(displayData.pitch));
		actor:SetRoll(math.rad(displayData.roll));
	end
end

local function PerksTryOn(actor, itemModifiedAppearanceID, allowOffHand)
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

local function SetupPlayerModelScene(modelScene, itemModifiedAppearanceID, hasSubItems, sheatheWeapon, autodress, hideWeapon, forceSceneChange)
	if not modelScene then
		return;
	end

	modelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);

	local useAlternateForm = not PerksProgramFrame:GetUseNativeForm();
	local playerRaceNameTag, playerRaceGenderNameTag = PerksProgram_GetPlayerActorLabelTag(useAlternateForm);
	local actor = modelScene:GetPlayerActor(playerRaceGenderNameTag);
	if not actor then
		actor = modelScene:GetPlayerActor(playerRaceNameTag);
	end

	if actor then
		local useNativeForm = PerksProgramFrame:GetUseNativeForm();
		if forceSceneChange or useNativeForm ~= modelScene.useNativeForm then
			modelScene.useNativeForm = useNativeForm;
			local holdBowString = true;
			actor:SetModelByUnit("player", sheatheWeapon, autodress, hideWeapon, useNativeForm, holdBowString);
		else
			if autodress then
				actor:Dress();
			else
				actor:Undress();
			end
		end
		actor.dressed = autodress;

		if not hasSubItems and itemModifiedAppearanceID then
			PerksTryOn(actor, itemModifiedAppearanceID);
		end
		actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
		return actor;
	end	
	return nil
end

local function SetAnimations(actor, displayData)
	if displayData.animationKitID then
		local maintain = true;
		actor:PlayAnimationKit(displayData.animationKitID, maintain);
	elseif displayData.animation and displayData.animation > 0 then
		actor:SetAnimation(displayData.animation, displayData.animationVariation, displayData.animSpeed);
	end
end

local function SetSpellVisualKit(actor, displayData)
	if displayData.spellVisualKitID then
		actor:SetSpellVisualKit(displayData.spellVisualKitID);
	end
end

local function UpdateModelSceneWithDisplayData(actor, camera, displayData, perksVendorCategoryID)
	if not displayData then
		return;
	end

	if camera then
		UpdateCameraTargetPositionData(camera, displayData);
		SetCameraTargetPosition(camera, displayData.cameraTargetX, displayData.cameraTargetY, displayData.cameraTargetZ);

		UpdateCameraRotationalData(camera, displayData);
		SetCameraRotation(camera, displayData);

		UpdateCameraZoomData(camera, displayData);
		SetCameraZoom(camera, displayData);
	end

	if actor then
		actor:SetSheathed(displayData.sheatheWeapon, displayData.hideWeapon);
		actor:SetAutoDress(displayData.autodress);

		UpdateActorPositionalData(actor, displayData);
		local isTransmog =  perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset;
		if isTransmog then 
			local hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
			local useNativeForm = PerksProgramFrame:GetUseNativeForm();

			local x, y, z = displayData.posX, displayData.posY, displayData.posZ;
			if hasAlternateForm and not useNativeForm then
				x, y, z = displayData.alternateFormData.posX, displayData.alternateFormData.posY, displayData.alternateFormData.posZ;
			end
			SetActorPosition(actor, x, y, z);
		else
			SetActorPosition(actor, displayData.posX, displayData.posY, displayData.posZ);
		end

		UpdateActorRotationalData(actor, displayData);
		SetActorRotation(actor, displayData);

		actor:SetSpellVisualKit(nil);
		actor:StopAnimationKit();
		actor:SetAnimation(0, 0, 1.0);
		SetAnimations(actor, displayData);
		SetSpellVisualKit(actor, displayData);
	end
end

PerksProgramAlteredFormButtonMixin = CreateFromMixins(SelectableButtonMixin);
function PerksProgramAlteredFormButtonMixin:OnLoad()
	RingedMaskedButtonMixin.OnLoad(self);
	SelectableButtonMixin.OnLoad(self);
end

function PerksProgramAlteredFormButtonMixin:OnSelected(newSelected)
	self:SetChecked(newSelected);
	self:UpdateHighlightTexture();
end

function PerksProgramAlteredFormButtonMixin:SetupAlteredFormButton(data, isNativeForm)
	self.isNativeForm = isNativeForm;
	self:SetIconAtlas(data.createScreenIconAtlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(CHARACTER_FORM:format(data.name));
end

function PerksProgramAlteredFormButtonMixin:GetAppropriateTooltip()
	return PerksProgramFrame.PerksProgramTooltip;
end

function PerksProgramAlteredFormButtonMixin:OnClick()
	SelectableButtonMixin.OnClick(self);
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
end		

----------------------------------------------------------------------------------
-- PerksProgramModelSceneContainerFrameMixin
----------------------------------------------------------------------------------
PerksProgramModelSceneContainerFrameMixin = {};
function PerksProgramModelSceneContainerFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.OnItemSetSelectionUpdated", self.OnItemSetSelectionUpdated, self);

	self.hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
	if self.hasAlternateForm then
		local characterInfo = C_PlayerInfo.GetPlayerCharacterData();
		if characterInfo then
			self.NormalFormButton:SetupAlteredFormButton(characterInfo, true);
			self.AlteredFormButton:SetupAlteredFormButton(characterInfo.alternateFormRaceData, false);

			self.buttonGroup = CreateRadioButtonGroup();
			self.buttonGroup:AddButton(self.NormalFormButton);
			self.buttonGroup:AddButton(self.AlteredFormButton);
			local defaultIndex = 1;
			self.buttonGroup:SelectAtIndex(defaultIndex);
			self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnFormSelected, self);
		end
	end
	self:UpdateFormButtonVisibility();
end

function PerksProgramModelSceneContainerFrameMixin:OnFormSelected(button, buttonIndex)
	EventRegistry:TriggerEvent("PerksProgram.OnFormChanged", button.isNativeForm);
end

local CelebrationSpellVisualID = 173390;
local CelebrationCreatureID = 27823;
function PerksProgramModelSceneContainerFrameMixin:Init()
	EventRegistry:RegisterCallback("PerksProgramProductsFrame.OnProductSelected", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductCategoryChanged", self.OnProductCategoryChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnDisplayDataChanged", self.OnDisplayDataChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFormChanged", self.OnFormChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnPlayerPreviewToggled", self.OnPlayerPreviewToggled, self);
	EventRegistry:RegisterCallback("PerksProgram.OnPlayerHideArmorToggled", self.OnPlayerHideArmorToggled, self);
	EventRegistry:RegisterCallback("PerksProgram.CelebratePurchase", self.OnCelebratePurchase, self);

	self.CelebrateModelScene:TransitionToModelSceneID(DEFAULT_CELEBRATE_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	self.CelebrateModelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);
	local fanfareActor = self.CelebrateModelScene:GetActorByTag(DEFAULT_FANFARE_ACTOR_TAG);
	fanfareActor:SetModelByCreatureDisplayID(CelebrationCreatureID);
	self.CelebrateModelScene:Hide();

	-- init the player model scene by defaults
	local data = nil;
	local modelSceneID = PerksProgramFrame:GetDefaultModelSceneID(Enum.PerksVendorCategoryType.Transmog);
	local forceSceneChange = true;
	self:SetupModelSceneForTransmogs(data, modelSceneID, forceSceneChange);
end

function PerksProgramModelSceneContainerFrameMixin:OnProductSelected(data, forceSceneChange)
	local oldData = self.currentData;
	self.currentData = data;

	local dataHasChanged = not oldData or oldData.perksVendorItemID ~= data.perksVendorItemID;
	local shouldSetupModelScene = forceSceneChange or dataHasChanged;

	if shouldSetupModelScene then
		local categoryID = self.currentData.perksVendorCategoryID;
		local defaultModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(categoryID);

		local hideArmor = not(self.currentData.displayData.autodress);
		local hideArmorSetting = PerksProgramFrame:GetHideArmorSetting();
		if hideArmorSetting ~= nil then
			hideArmor = hideArmorSetting;
			PerksProgramFrame:SetHideArmorSetting(hideArmor);
		end

		if categoryID == Enum.PerksVendorCategoryType.Mount then
			forceSceneChange = forceSceneChange or not(self.previousMainModelSceneID == defaultModelSceneID);
			self:SetupModelSceneForMounts(self.currentData, defaultModelSceneID, forceSceneChange);		
			self.previousMainModelSceneID = defaultModelSceneID;
		elseif categoryID == Enum.PerksVendorCategoryType.Pet then
			forceSceneChange = forceSceneChange or not(self.previousMainModelSceneID == defaultModelSceneID);
			self:SetupModelSceneForPets(self.currentData, defaultModelSceneID, forceSceneChange);	
			self.previousMainModelSceneID = defaultModelSceneID;
		elseif categoryID == Enum.PerksVendorCategoryType.Toy then
			forceSceneChange = forceSceneChange or not(self.previousMainModelSceneID == defaultModelSceneID);
			self:SetupModelSceneForToys(self.currentData, defaultModelSceneID, forceSceneChange);
			self.previousMainModelSceneID = defaultModelSceneID;
		elseif categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset then
			forceSceneChange = true;
			self:SetupModelSceneForTransmogs(self.currentData, defaultModelSceneID, forceSceneChange);
		end
	end

	EventRegistry:TriggerEvent("PerksProgramFrame.PerksProductSelected", self.currentData.perksVendorCategoryID);
	EventRegistry:TriggerEvent("PerksProgramModel.OnProductSelectedAfterModel", self.currentData);
end

function PerksProgramModelSceneContainerFrameMixin:UpdateFormButtonVisibility(optionalPerksVendorCategoryID)
	local showFormButtons = false;
	if self.hasAlternateForm then		
		if optionalPerksVendorCategoryID == Enum.PerksVendorCategoryType.Mount or
			optionalPerksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or 
			optionalPerksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset or 
			optionalPerksVendorCategoryID == Enum.PerksVendorCategoryType.Pet then
			showFormButtons = true;
		end
	end
	self.NormalFormButton:SetShown(showFormButtons);
	self.AlteredFormButton:SetShown(showFormButtons);
end

function PerksProgramModelSceneContainerFrameMixin:OnProductCategoryChanged(perksVendorCategoryID)
	self:UpdateFormButtonVisibility(perksVendorCategoryID)
end

function PerksProgramModelSceneContainerFrameMixin:OnFormChanged(useNativeForm)
	PerksProgramFrame:SetUseNativeForm(useNativeForm);
	if self.currentData then
		local forceSceneChange = true;
		self:OnProductSelected(self.currentData, forceSceneChange);
	end
end

function PerksProgramModelSceneContainerFrameMixin:OnPlayerPreviewToggled()
	if self.currentData then
		local forceSceneChange = true;
		self:OnProductSelected(self.currentData, forceSceneChange);
	end
end

function PerksProgramModelSceneContainerFrameMixin:OnPlayerHideArmorToggled()
	if self.currentData then
		local forceSceneChange = true;
		self:OnProductSelected(self.currentData, forceSceneChange);
	end
end

function PerksProgramModelSceneContainerFrameMixin:OnCelebratePurchase(purchasedItemInfo)
	if self.CelebrateTimer then
		self.CelebrateTimer:Cancel();
		self.CelebrateModelScene:Hide();
		self.CelebrateTimer = nil;
	end
	local fanfareActor = self.CelebrateModelScene:GetActorByTag(DEFAULT_FANFARE_ACTOR_TAG);

	if fanfareActor then
		self.CelebrateModelScene:Show();
		fanfareActor:SetSpellVisualKit(CelebrationSpellVisualID, true);

		self.CelebrateTimer = C_Timer.NewTimer(5,
		function()
			fanfareActor:SetSpellVisualKit(nil);
			self.CelebrateModelScene:Hide();
			self.CelebrateTimer = nil;
		end);
	end
end

local function FlagsChanged(data)
	if (data["autodress"] ~= nil) or (data["sheatheWeapon"] ~= nil) or (data["hideWeapon"] ~= nil) then 		
		return true;
	end
	return false;
end

function PerksProgramModelSceneContainerFrameMixin:OnDisplayDataChanged(data, dataChanged)
	local modelSceneChanged = dataChanged and dataChanged["selectedModelSceneID"] ~= nil or false;
	local actorDisplayChanged = dataChanged and dataChanged["modelActorDisplayID"] ~= nil or false;
	if FlagsChanged(dataChanged) or modelSceneChanged then
		local forceSceneChange = dataChanged["autodress"] ~= nil;
		self:OnProductSelected(data, forceSceneChange);
		return;
	end

	local actorDisplayInfo = dataChanged["modelActorDisplayID"] and C_ModelInfo.GetModelSceneActorDisplayInfoByID(dataChanged["modelActorDisplayID"]);
	data.modelActorDisplayID = dataChanged["modelActorDisplayID"];
	if actorDisplayInfo then
		data.displayData.animationKitID = actorDisplayInfo.animationKitID;
		data.displayData.animation = actorDisplayInfo.animation;
		data.displayData.animationVariation = actorDisplayInfo.animationVariation;
		data.displayData.animSpeed = actorDisplayInfo.animSpeed;
		data.displayData.spellVisualKitID = actorDisplayInfo.spellVisualKitID;
	end

	local categoryID = data.perksVendorCategoryID;
	local actor, modelScene;
	if categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset then
		modelScene = self.PlayerModelScene;
		local useAlternateForm = not PerksProgramFrame:GetUseNativeForm();
		local playerRaceNameTag, playerRaceGenderNameTag = PerksProgram_GetPlayerActorLabelTag(useAlternateForm);
		actor = modelScene:GetPlayerActor(playerRaceGenderNameTag);
		if not actor then
			actor = modelScene:GetPlayerActor(playerRaceNameTag);
		end
	elseif categoryID == Enum.PerksVendorCategoryType.Pet then
		modelScene = self.MainModelScene;
		actor = modelScene:GetActorByTag(DEFAULT_PET_ACTOR_TAG);
	elseif categoryID == Enum.PerksVendorCategoryType.Mount then
		modelScene = self.MainModelScene;
		actor = modelScene:GetActorByTag(DEFAULT_MOUNT_ACTOR_TAG);
	elseif categoryID == Enum.PerksVendorCategoryType.Toy then
		modelScene = self.MainModelScene;
		actor = modelScene:GetActorByTag(DEFAULT_TOY_ACTOR_TAG);
	end
	local camera = modelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
	UpdateModelSceneWithDisplayData(actor, camera, data.displayData, categoryID);
end

local function UpdateDropShadow(texture, dropShadowSettings)
	if texture then
		local point, parent, relativePoint, x, y = texture:GetPoint();
		texture:SetPoint(point, parent, relativePoint, dropShadowSettings.targetX, dropShadowSettings.targetY);
		texture:SetSize(dropShadowSettings.width, dropShadowSettings.height);
	end
end

function PerksProgramModelSceneContainerFrameMixin:OnItemSetSelectionUpdated(data, perksVendorCategoryID, selectedItems)
	-- IMPORTANT: if we ever want this tech to be used for mounts, pets, and toys in the future, more work needs to be done
	if perksVendorCategoryID == Enum.PerksVendorCategoryType.Mount then
		local overrideCreatureDisplayInfoID = data.creatureDisplays[1];
		local modelSceneID = nil;
		local forceSceneChange = false;
		self:SetupModelSceneForMounts(data, modelSceneID, forceSceneChange, overrideCreatureDisplayInfoID);
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Pet then
		-- not yet
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Toy then
		-- not yet
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset then
		if selectedItems then
			self.selectedItems = selectedItems;
			self.firstDress = false;
			self:PlayerTryOnOverrideSet(selectedItems);
		end
	end
end

-- MOUNTS
function PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForMounts(data, modelSceneID, forceSceneChange, overrideCreatureDisplayInfoID)
	local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(data.mountID);
	local defaultCreatureDisplayID, descriptionText, sourceText, isSelfMount, _, _, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(data.mountID);

	if not defaultCreatureDisplayID then
		error("PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForMounts : invalid creatureDisplayID")
		return;
	end
	local creatureDisplayID = overrideCreatureDisplayInfoID or defaultCreatureDisplayID;

	if forceSceneChange then
		self.MainModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	end

	local actor = self.MainModelScene:GetActorByTag(DEFAULT_MOUNT_ACTOR_TAG);
	if actor then
		actor:SetModelByCreatureDisplayID(creatureDisplayID);

		if (isSelfMount) then
			actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
			actor:SetAnimation(MOUNT_SELF_IDLE_ANIM);
		else
			actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.Anim);
			actor:SetAnimation(0);
		end
		local showPlayer = not PerksProgramFrame:GetTogglePlayerSetting();
		if not disablePlayerMountPreview and not showPlayer then
			disablePlayerMountPreview = true;
		end
		local useNativeForm = PerksProgramFrame:GetUseNativeForm();
		self.MainModelScene:AttachPlayerToMount(actor, animID, isSelfMount, disablePlayerMountPreview, spellVisualKitID, useNativeForm);

		local camera = self.MainModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
		UpdateModelSceneWithDisplayData(actor, camera, data.displayData, data.perksVendorCategoryID);
	end
	
	UpdateDropShadow(self.MainModelScene.dropShadow, DropShadowSettings["MOUNT_MAIN"]);
	self.MainModelScene:Show();
	self.ToyOverlayFrame:Hide();
	self.PlayerModelScene:Hide();
	EventRegistry:TriggerEvent("PerksProgram.OnModelSceneChanged", self.MainModelScene);
end

-- PETS
function PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForPets(data, modelSceneID, forceSceneChange)	
	local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique, _, displayID, desiredScale = C_PetJournal.GetPetInfoBySpeciesID(data.speciesID);
	if not displayID then
		error("PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForPets : invalid displayID")
		return;
	end

	if forceSceneChange then
		self.MainModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	end

	local actor = self.MainModelScene:GetActorByTag(DEFAULT_PET_ACTOR_TAG);
	if actor then
		local playerData = nil;
		local forcePlayerSceneChange = true;
		local playerModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(Enum.PerksVendorCategoryType.Transmog);
		self:SetupModelSceneForTransmogs(playerData, playerModelSceneID, forcePlayerSceneChange);

		if self.playerActor then
			local playerCamera = self.PlayerModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
			playerCamera:SetYaw(math.rad(150));

			local currentX, currentY, currentZ= self.playerActor:GetPosition();
			local x = currentX - 2;
			local y = currentY + 2.2;
			SetActorPosition(self.playerActor, x, y, currentZ);
		end

		self.MainModelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);
		actor:SetModelByCreatureDisplayID(displayID);
		actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);
		data.displayData.animationKitID = PET_DEFAULT_ANIM_ID;
		data.displayData.desiredScale = desiredScale;
		actor:SetRequestedScale(desiredScale);
						
		local camera = self.MainModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
		UpdateModelSceneWithDisplayData(actor, camera, data.displayData, data.perksVendorCategoryID);
	end

	UpdateDropShadow(self.MainModelScene.dropShadow, DropShadowSettings["PET_MAIN"]);
	UpdateDropShadow(self.PlayerModelScene.dropShadow, DropShadowSettings["PET_PLAYER"]);
	self.ToyOverlayFrame:Hide();
	self.MainModelScene:Show();
	self.PlayerModelScene:Show();
	EventRegistry:TriggerEvent("PerksProgram.OnModelSceneChanged", self.MainModelScene);
end



-- TOYS
function PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForToys(data, modelSceneID, forceSceneChange)
	if forceSceneChange then
		self.MainModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	end
	local creatureDisplayID = data.displayData.creatureDisplayInfoID;
	if creatureDisplayID then -- UI Model Scene Toy Display
		local actor = self.MainModelScene:GetActorByTag(DEFAULT_TOY_ACTOR_TAG);
		if actor then
			local playerData = nil;
			local forcePlayerSceneChange = true;
			local playerModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(Enum.PerksVendorCategoryType.Transmog);
			self:SetupModelSceneForTransmogs(playerData, playerModelSceneID, forcePlayerSceneChange);

			if self.playerActor then
				local playerCamera = self.PlayerModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
				playerCamera:SetYaw(math.rad(150));

				local currentX, currentY, currentZ= self.playerActor:GetPosition();
				local x = currentX - 2;
				local y = currentY + 2.2;
				SetActorPosition(self.playerActor, x, y, currentZ);
			end

			self.MainModelScene:SetViewInsets(DefaultInsets.left, DefaultInsets.right, DefaultInsets.top, DefaultInsets.bottom);
			actor:SetModelByCreatureDisplayID(creatureDisplayID);
			actor:SetAnimationBlendOperation(Enum.ModelBlendOperation.None);

			local function tryOnHandItem(appeanceID, slot)
				if (appeanceID) then
					local itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(appeanceID);
					actor:SetItemTransmogInfo(itemTransmogInfo, slot, true);
				end
			end
			tryOnHandItem(data.displayData.mainHandItemModifiedAppearanceID, INVSLOT_MAINHAND);
			tryOnHandItem(data.displayData.offHandItemModifiedAppearanceID, INVSLOT_OFFHAND);

			local camera = self.MainModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
			UpdateModelSceneWithDisplayData(actor, camera, data.displayData, data.perksVendorCategoryID);
		end

		UpdateDropShadow(self.MainModelScene.dropShadow, DropShadowSettings["PET_MAIN"]);
		UpdateDropShadow(self.PlayerModelScene.dropShadow, DropShadowSettings["PET_PLAYER"]);
		self.ToyOverlayFrame:Hide();
		self.MainModelScene:Show();
		self.PlayerModelScene:Show();
		EventRegistry:TriggerEvent("PerksProgram.OnModelSceneChanged", self.MainModelScene);
	else -- default Toy Display		
		local iconTexture = C_Item.GetItemIconByID(data.itemID);
		self.ToyOverlayFrame.Icon:SetTexture(iconTexture);
		self.ToyOverlayFrame:Show();
		self.MainModelScene:Hide();
		self.PlayerModelScene:Hide();
		local noModelScene;
		EventRegistry:TriggerEvent("PerksProgram.OnModelSceneChanged", noModelScene);
	end
end

-- TRANSMOGS
function PerksProgramModelSceneContainerFrameMixin:PlayerTryOnOverride(overrideItemModifiedAppearanceID)
	if self.playerActor and overrideItemModifiedAppearanceID then
		PerksTryOn(self.playerActor, overrideItemModifiedAppearanceID);
	end
end

function PerksProgramModelSceneContainerFrameMixin:UpdateSelectedSet()
	self:PlayerTryOnOverrideSet(self.selectedItems);
end

function PerksProgramModelSceneContainerFrameMixin:PlayerTryOnOverrideSet(selectedItems)
	if self.playerActor.dressed then
		self.playerActor:Undress();
		self.playerActor:Dress();
		self.playerActor:UndressSlot(INVSLOT_MAINHAND);
		self.playerActor:UndressSlot(INVSLOT_OFFHAND);
	else
		self.playerActor:Undress();
	end

	if self.playerActor and selectedItems then
		for index, overrideItemModifiedAppearanceID in ipairs(selectedItems) do
			PerksTryOn(self.playerActor, overrideItemModifiedAppearanceID, true);
		end
	end
end

function PerksProgramModelSceneContainerFrameMixin:SetupModelSceneForTransmogs(data, modelSceneID, forceSceneChange)
	if forceSceneChange then
		self.PlayerModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
	end

	if self.playerActor then
		self.playerActor:ClearModel();
	end

	local hideWeapon, sheatheWeapon, autodress = false, true, true;
	local displayData = data and data.displayData;
	if displayData then
		hideWeapon = displayData.hideWeapon;
		sheatheWeapon = displayData.sheatheWeapon;
		local hideArmorSetting = PerksProgramFrame:GetHideArmorSetting();
		if hideArmorSetting == nil then
			autodress = displayData.autodress;
		else
			autodress = not(hideArmorSetting);
		end
	end
	local itemModifiedAppearanceID = data and data.itemModifiedAppearanceID;
	self.playerActor = SetupPlayerModelScene(self.PlayerModelScene, itemModifiedAppearanceID, data and #data.subItems > 0, sheatheWeapon, autodress, hideWeapon, forceSceneChange);

	if displayData then
		local camera = self.PlayerModelScene:GetCameraByTag(DEFAULT_CAMERA_TAG);
		UpdateModelSceneWithDisplayData(self.playerActor, camera, displayData, data.perksVendorCategoryID);
	end
	UpdateDropShadow(self.PlayerModelScene.dropShadow, DropShadowSettings["TRANSMOG_PLAYER"]);
	self.ToyOverlayFrame:Hide();
	self.MainModelScene:Hide();
	self.PlayerModelScene:Show();
	EventRegistry:TriggerEvent("PerksProgram.OnModelSceneChanged", self.PlayerModelScene);
end
