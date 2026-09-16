
-- TODO:: This data is still work-in-progress/temporary. 
local ARMOR_MODEL_SCENE_ID = 420;

-- This is a display template so it doesn't dictate the functionality of the button.
TalentArmorSetMixin = {};

function TalentArmorSetMixin:OnLoad()
	self.ModelScene:SetMouseMotionEnabled(false);
	self.ModelScene:SetMouseClickEnabled(false);
end

function TalentArmorSetMixin:OnRelease()
	TalentDisplayMixin.OnRelease(self);

	self.previousTransmogSetID = nil;
end

function TalentArmorSetMixin:SetAndApplySize(_width, _height)
	-- Overrides TalentDisplayMixin.

	-- Armor set buttons are a fixed size.
end

function TalentArmorSetMixin:ApplyVisualState(visualState)
	-- TODO:: Visual state here is still a work-in-progress.
	local isMaxed = visualState == TalentButtonUtil.BaseVisualState.Maxed;
	local borderAtlas = isMaxed and "transmog-wardrobe-border-current" or "transmog-wardrobe-border-collected";
	self.Border:SetAtlas(borderAtlas, TextureKitConstants.UseAtlasSize);

	local isLocked = visualState == TalentButtonUtil.BaseVisualState.Locked;
	self.OverlayContainer.LockedOverlay:SetShown(isLocked);
	self.OverlayContainer.LockedIcon:SetShown(isLocked);
end

function TalentArmorSetMixin:UpdateNonStateVisuals()
	self:UpdateModelScene();
end

-- TODO:: This is based on AccountStoreTransmogSetCardMixin:UpdateCardDisplay and should be refactored into a shared
-- utility if we decide to continue this pattern.
function TalentArmorSetMixin:UpdateModelScene()
	local itemModifiedAppearanceIDs = self:GetTalentFrame():GetItemModifiedAppearanceIDs(self);
	if #itemModifiedAppearanceIDs == 0 then
		self.ModelScene:Hide();
		return;
	elseif self.previousAppearanceIDs and tCompare(itemModifiedAppearanceIDs, self.previousAppearanceIDs) then
		return;
	end

	self.previousAppearanceIDs = itemModifiedAppearanceIDs;
	self.ModelScene:Show();

	local forceUpdate = false;
	self.ModelScene:SetFromModelSceneID(ARMOR_MODEL_SCENE_ID, forceUpdate);

	-- TODO:: Camera adjustments are still work-in-progress.
	local camera = self.ModelScene:GetActiveCamera();
	camera:SetMinZoomDistance(2.4);
	camera:SetMaxZoomDistance(2.4);
	camera:SetZoomDistance(2.4);
	camera:SetTarget(0, 0, 1.4);

	local function GetPlayerActorName()
		local _, raceFilename = UnitRace("player");
		local playerRaceName = raceFilename:lower();
		local playerGender = UnitSex("player");

		local useNativeForm = true;
		local overrideActorName;
		if playerRaceName == "dracthyr" then
			useNativeForm = false;
			overrideActorName = "dracthyr-alt";
		end

		return playerRaceName and playerRaceName:lower() or overrideActorName, playerGender, useNativeForm;
	end

	local function SetUpPlayerActor()
		local playerRaceName, playerGender, useNativeForm = GetPlayerActorName();
		local flags = select(4, C_ModelInfo.GetModelSceneInfoByID(ARMOR_MODEL_SCENE_ID));
		local sheatheWeapons = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
		local hideWeapons = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
		local autoDress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;
		local overrideActorName = nil;
		local setupItemModifiedAppearanceIDs = nil; -- We set these below.
		SetupPlayerForModelScene(self.ModelScene, overrideActorName, setupItemModifiedAppearanceIDs, sheatheWeapons, autoDress, hideWeapons, useNativeForm, playerRaceName, playerGender);
		local forceAlternateForm = false;
		return self.ModelScene:GetPlayerActor(overrideActorName, forceAlternateForm, playerRaceName, playerGender);
	end

	local playerActor = SetUpPlayerActor();
	for i, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
		playerActor:TryOn(itemModifiedAppearanceID);
	end
end
