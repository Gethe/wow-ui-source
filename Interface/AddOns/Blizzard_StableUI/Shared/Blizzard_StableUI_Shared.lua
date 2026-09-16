

local PET_STABLE_DEFAULT_ACTOR_TAG = "pet";

local backgroundForPetSpec = {
	[STABLE_PET_SPEC_CUNNING] = "hunter-stable-bg-art_cunning",
	[STABLE_PET_SPEC_FEROCITY] = "hunter-stable-bg-art_ferocity",
	[STABLE_PET_SPEC_TENACITY] = "hunter-stable-bg-art_tenacity",
};

local function GetBackgroundForPetSpecialization(specialization)
	return backgroundForPetSpec[specialization] or nil;
end

StableUtils = {};

function StableUtils.ClearPetCursor()
	local cursorType = GetCursorInfo();
	if cursorType == "pet" then
		ClearCursor();
	end
end


StablePetModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

function StablePetModelSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);
	self.ControlFrame:SetModelScene(self);
end

function StablePetModelSceneMixin:OnMouseDown(mouseButton)
	ModelSceneMixin.OnMouseDown(self, mouseButton);
	if mouseButton == "RightButton" then
		StableUtils.ClearPetCursor();
	end
end

function StablePetModelSceneMixin:SetPet(pet)
	if not pet then
		return;
	end

	self:UpdatePetModel(pet);
	self:UpdateBackgroundForPet(pet);
	if self.PetInfo then
		self.PetInfo:SetPet(pet);
	end
end

function StablePetModelSceneMixin:UpdatePetModel(pet)
	if not pet then
		return;
	end

	local forceSceneChange = true;
	self:TransitionToModelSceneID(pet.uiModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	local actor = self:GetActorByTag(PET_STABLE_DEFAULT_ACTOR_TAG);
	if actor then
		actor:Hide();
		actor:SetOnModelLoadedCallback(GenerateClosure(self.OnModelLoaded, actor));
		actor:SetModelByCreatureDisplayID(pet.displayID);
	end
end

function StablePetModelSceneMixin:OnModelLoaded(actor)
	actor:Show();
end

function StablePetModelSceneMixin:UpdateBackgroundForPet(pet)
	local background = GetBackgroundForPetSpecialization(pet.specialization);
	if background then
		self.Background:SetAtlas(background, TextureKitConstants.UseAtlasSize);
	end
end
