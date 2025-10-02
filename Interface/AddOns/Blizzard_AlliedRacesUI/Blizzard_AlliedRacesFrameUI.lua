AlliedRacesFrameMixin = { };

function AlliedRacesFrameMixin:UpdatedBannerColor(bannerColor)
	self.Banner:SetVertexColor(bannerColor:GetRGB());
end

function AlliedRacesFrameMixin:SetFrameText(name, description)
	self:SetTitle(name);
	self.RaceInfoFrame.AlliedRacesRaceName:SetText(name);
	self.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetText(description);
end

function AlliedRacesFrameMixin:SetupAbilityPool(index, racialAbility)
	local childFrame = self.RaceInfoFrame.ScrollFrame.Child;
	local abilityButton = self.abilityPool:Acquire();

	if (index == 1) then
		abilityButton:SetPoint("TOPLEFT", childFrame.RacialTraitsLabel, "BOTTOMLEFT", -7, -19);
	else
		abilityButton:SetPoint("TOP", self.lastAbility, "BOTTOM", 0, -9);
	end

	abilityButton.Text:SetText(racialAbility.name);
	abilityButton.Icon:SetTexture(racialAbility.icon);
	abilityButton.abilityName = racialAbility.name;
	abilityButton.abilityDescription = racialAbility.description;
	abilityButton:Show();

	return abilityButton;
end

function AlliedRacesFrameMixin:RacialAbilitiesData(raceID)
	local racialAbilities = C_AlliedRaces.GetAllRacialAbilitiesFromID(raceID);

	if(not racialAbilities) then
		return;
	end

	self.abilityPool:ReleaseAll();
	for i, ability in ipairs(racialAbilities) do
		self.lastAbility = self:SetupAbilityPool(i, ability);
	end
end

function AlliedRacesFrameMixin:LoadRaceData(raceID)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(raceID);

	if( not raceInfo) then
		return;
	end

	self.raceID = raceID;
	self:SetModelSceneBackground(raceInfo.modelBackgroundAtlas);
	if (UnitSex("player") == 2) then
		self:UpdateModel(raceInfo.maleModelID);
		self.ModelScene.AlliedRacesMaleButton:SetChecked(true);
		self.ModelScene.AlliedRacesFemaleButton:SetChecked(false);
		self:SetRaceNameForGender("male");
	else
		self:UpdateModel(raceInfo.femaleModelID);
		self.ModelScene.AlliedRacesMaleButton:SetChecked(false);
		self.ModelScene.AlliedRacesFemaleButton:SetChecked(true);
		self:SetRaceNameForGender("female");
	end
	self.ModelScene.AlliedRacesFemaleButton.FemaleModelID = raceInfo.femaleModelID;
	self.ModelScene.AlliedRacesFemaleButton.raceName = raceInfo.femaleName;
	self.ModelScene.AlliedRacesMaleButton.MaleModelID = raceInfo.maleModelID;
	self.ModelScene.AlliedRacesFemaleButton.raceName = raceInfo.maleName;

	self:SetPortraitAtlasRaw(raceInfo.crestAtlas);
	self:UpdatedBannerColor(raceInfo.bannerColor);
	self:RacialAbilitiesData(raceID);
	self.RaceInfoFrame.ScrollFrame.Child.ObjectivesFrame:SetAchievements(raceInfo.achievementIds);
end

function AlliedRacesFrameMixin:SetRaceNameForGender(gender)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(self.raceID);
	if not raceInfo then
		return;
	end

	local raceName;
	if gender == "female" then
		raceName = raceInfo.femaleName;
	else
		raceName = raceInfo.maleName;
	end

	local fileString = raceInfo.raceFileString;
	fileString = strupper(fileString);

	self:SetFrameText(raceName, _G["RACE_INFO_"..fileString]);
end

function AlliedRacesFrameMixin:OnShow()
	self.Inset:Hide();

	self.ModelScene:SetResetCallback(GenerateClosure(self.OnModelSceneReset, self));
	self.ModelScene.ControlFrame:SetModelScene(self.ModelScene);
end

function AlliedRacesFrameMixin:SetModelSceneBackground(backgroundAtlas)
	self.ModelScene.ModelBackground:SetAtlas(backgroundAtlas, TextureKitConstants.UseAtlasSize);
end

function AlliedRacesFrameMixin:OnModelSceneReset()
	if self.modelID then
		self:UpdateModel(self.modelID);
	end
end

local ALLIED_RACES_MODEL_SCENE_ID = 727;
local Actor_X_ModelID = {
	[82729] = "lightforgeddraenei",
	[82730] = "lightforgeddraenei-female",
	[87992] = "darkirondwarf",
	[87993] = "darkirondwarf-female",
	[82736] = "voidelf",
	[82735] = "voidelf-female",
	[94370] = "mechagnome",
	[94371] = "mechagnome",
	[94257] = "vulpera",
	[94256] = "vulpera",
	[89631] = "zandalaritroll",
	[89632] = "zandalaritroll",
	[82733] = "highmountaintauren",
	[82731] = "highmountaintauren-female",
	[82708] = "nightborne",
	[82709] = "nightborne",
	[86343] = "magharorc",
	[86342] = "magharorc",
	[121634] = "earthendwarf",
	[121635] = "earthendwarf-female",
};

function AlliedRacesFrameMixin:UpdateModel(modelID)
	self.modelID = modelID;
	local actorTag = Actor_X_ModelID[modelID];
	if not actorTag then
		actorTag = "player";
	end
	self.ModelScene:ClearScene();
	self.ModelScene:TransitionToModelSceneID(ALLIED_RACES_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
	local actor = self.ModelScene:GetActorByTag(actorTag);
	if actor then
		actor:SetModelByCreatureDisplayID(modelID, true);
	end
end

function AlliedRacesFrameMixin:OnLoad()
	self.abilityPool = CreateFramePool("BUTTON", self.RaceInfoFrame.ScrollFrame.Child, "AlliedRaceAbilityTemplate");
	self.TopTileStreaks:Hide();
end

function AlliedRacesFrameMixin:OnHide()
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.AlliedRaceDetailsGiver);
end

--------------------------------------------------
-- ALLIED RACES MODEL SCENE MIXIN
AlliedRacesModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

--------------------------------------------------
-- ALLIED RACES MALE BUTTON MIXIN
AlliedRacesMaleButtonMixin = {};
function AlliedRacesMaleButtonMixin:OnClick()
	local alliedRaceModelFrame = self:GetParent();
	alliedRaceModelFrame.AlliedRacesFemaleButton:SetChecked(false);

	local alliedRaceFrame = alliedRaceModelFrame:GetParent();
	alliedRaceFrame:UpdateModel(self.MaleModelID);
	alliedRaceFrame:SetRaceNameForGender("male");
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

--------------------------------------------------
-- ALLIED RACES FEMALE BUTTON MIXIN
AlliedRacesFemaleButtonMixin = {};
function AlliedRacesFemaleButtonMixin:OnClick()
	local alliedRaceModelFrame = self:GetParent();
	alliedRaceModelFrame.AlliedRacesMaleButton:SetChecked(false);

	local alliedRaceFrame = alliedRaceModelFrame:GetParent();
	alliedRaceFrame:UpdateModel(self.FemaleModelID);
	alliedRaceFrame:SetRaceNameForGender("female");
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
end

--------------------------------------------------
-- ALLIED RACE ABILITY MIXIN
AlliedRaceAbilityMixin = {};
function AlliedRaceAbilityMixin:OnEnter()
	GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 6, 0);
	GameTooltip_SetTitle(GameTooltip, self.abilityName);
	GameTooltip_AddBodyLine(GameTooltip, self.abilityDescription);
	GameTooltip:Show();
end

function AlliedRaceAbilityMixin:OnLeave()
	GameTooltip:Hide();
end