-- Constants
local PET_STABLE_DEFAULT_ACTOR_TAG = "pet";
local CALL_PET_SPELL_IDS = { -- Each "active" pet slot corresponds to a "call pet" spell (with the exception of the secondary pet)
	0883,
	83242,
	83243,
	83244,
	83245,
};
local ANIMAL_COMPANION_NODE_ID = 79947; -- BM talent required for secondary pet slot
local STABLE_FRAME_SWAP_TIMEOUT_SECONDS = 0.3; -- 300ms

local STABLED_PETS_FIRST_SLOT_LUA_INDEX = Constants.PetConsts.STABLED_PETS_FIRST_SLOT_INDEX + 1;
local EXTRA_PET_STABLE_SLOT_LUA_INDEX = Constants.PetConsts.EXTRA_PET_STABLE_SLOT + 1;
local MAX_PET_SLOT_LUA_INDEX = Constants.PetConsts.NUM_PET_SLOTS + 1;

local STABLE_FRAME_ON_LOAD_EVENTS = {
	"PET_STABLE_SHOW",
	"PET_STABLE_CLOSED",
};

local STABLE_FRAME_ON_SHOW_EVENTS = {
	"PET_STABLE_UPDATE",
	"PLAYER_SPECIALIZATION_CHANGED",
	"SPELLS_CHANGED",
	"PET_INFO_UPDATE",
	"PET_STABLE_FAVORITES_UPDATED",
};

local PetSortMode = EnumUtil.MakeEnum(
	"Specialization",
	"Family",
	"Name",
	"NameReverse"
);

local StableTogglePetButton = EnumUtil.MakeEnum(
	"Stable",
	"MakeActive"
);

local backgroundForPetSpec = {
	[STABLE_PET_SPEC_CUNNING] = "hunter-stable-bg-art_cunning",
	[STABLE_PET_SPEC_FEROCITY] = "hunter-stable-bg-art_ferocity",
	[STABLE_PET_SPEC_TENACITY] = "hunter-stable-bg-art_tenacity",
};

local listBackgroundForPetSpec = {
	[STABLE_PET_SPEC_CUNNING] = "pet-list-bg-cunning-default",
	[STABLE_PET_SPEC_FEROCITY] = "pet-list-bg-ferocity-default",
	[STABLE_PET_SPEC_TENACITY] = "pet-list-bg-tenacity-default",
};

local selectedListBackgroundForPetSpec = {
	[STABLE_PET_SPEC_CUNNING] = "pet-list-bg-cunning-active",
	[STABLE_PET_SPEC_FEROCITY] = "pet-list-bg-ferocity-active",
	[STABLE_PET_SPEC_TENACITY] = "pet-list-bg-tenacity-active",
};

-- StableUI local functions
local function GetBackgroundForPetSpecialization(specialization)
	return backgroundForPetSpec[specialization] or nil;
end

local function GetListBackgroundForPetSpecialization(specialization)
	return listBackgroundForPetSpec[specialization];
end

local function GetSelectedListBackgroundForPetSpecialization(specialization)
	return selectedListBackgroundForPetSpec[specialization];
end

local function SetPortraitTextureFromCreatureDisplayIDFlipped(texture, creatureDisplayID)
	SetPortraitTextureFromCreatureDisplayID(texture, creatureDisplayID);
	texture:SetTexCoord(1, 0, 0, 1);
end

local function IsActivePetSlot(slot)
	return slot > 0 and slot < EXTRA_PET_STABLE_SLOT_LUA_INDEX;
end

local function GetSummonedPetStableSlot()
	for i=1, Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS do
		if IsCurrentSpell(CALL_PET_SPELL_IDS[i]) then
			return i;
		end
	end

	return nil;
end

local function GetSummonedPet()
	local summonedPetSlot = GetSummonedPetStableSlot();
	if summonedPetSlot then
		return C_StableInfo.GetStablePetInfo(summonedPetSlot);
	end
end

local function FindFirstPet()
	for i=1, MAX_PET_SLOT_LUA_INDEX do
		local petInfo = C_StableInfo.GetStablePetInfo(i);
		if petInfo then
			return petInfo;
		end
	end
end

local function FindFirstUnusedStableSlot()
	if StableFrame.swapTimeout and (GetTime() < StableFrame.swapTimeout) then
		return;
	end

	local targetSlot = nil;

	for i=STABLED_PETS_FIRST_SLOT_LUA_INDEX, MAX_PET_SLOT_LUA_INDEX do
		local petInfo = C_StableInfo.GetStablePetInfo(i);
		if not petInfo then
			targetSlot = i;
			break;
		end
	end

	if not targetSlot then
		if not C_StableInfo.GetStablePetInfo(EXTRA_PET_STABLE_SLOT_LUA_INDEX) then
			-- If we found no empty slots but the extra pet slot is open use that
			targetSlot = EXTRA_PET_STABLE_SLOT_LUA_INDEX;
		else
			-- Otherwise just swap with the first stable slot
			targetSlot = STABLED_PETS_FIRST_SLOT_LUA_INDEX;
		end
	end

	StableFrame.swapTimeout = GetTime() + STABLE_FRAME_SWAP_TIMEOUT_SECONDS;
	return targetSlot;
end

local function IsActivePetSlotUnlocked(activePetSlot)
	return IsSpellKnown(CALL_PET_SPELL_IDS[activePetSlot]);
end

local function GetFirstActivePetSlot()
	local firstActiveSlotID = 1;
	return firstActiveSlotID;
end

local function FindFirstUnusedActivePetSlot()
	for slot=1, Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS do
		if IsActivePetSlotUnlocked(slot) then
			local petInfo = C_StableInfo.GetStablePetInfo(slot);
			if not petInfo then
				return slot;
			end
		end
	end
end

local function GetBeastmasterSecondaryPet()
	return C_StableInfo.GetStablePetInfo(EXTRA_PET_STABLE_SLOT_LUA_INDEX);
end

local function GetSelectedPet()
	return StableFrame.selectedPet;
end

local function SetSelectedPet(pet)
	if pet then
		StableFrame.selectedPet = pet;
	end
end

local function ClearSelectedPetNewSlot()
	StableFrame.selectedPetNewSlot = nil;
end

local function GetStableFilterDropdown()
	return StableFrame.StabledPetList.FilterBar.FilterButton.DropDown;
end

local function ClearPetCursor()
	local cursorType = GetCursorInfo();
	if cursorType == "pet" then
		ClearCursor();
	end
end

StableFrameMixin = {};

function StableFrameMixin:OnLoad()
	local panelAttributes = {
		area = "left",
		pushable = 1,
		allowOtherPanels = 1,
		width = 1040,
		height = 638,
	};
	RegisterUIPanel(self, panelAttributes);

	self:SetPortraitToAsset(self.portraitIcon);
	self:SetTitleFormatted(PET_STABLE_TITLE, UnitName("player"));

	FrameUtil.RegisterFrameForEvents(self, STABLE_FRAME_ON_LOAD_EVENTS);
	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);
	EventRegistry:RegisterCallback("StableFrameMixin.PetSwapRequested", self.OnPetSwapRequested, self);
end

function StableFrameMixin:OnPetSelected(pet)
	if not self.selectedPet or pet.slotID ~= self.selectedPet.slotID then
		self.selectedPet = pet;
		self.PetModelScene:SetPet(self.selectedPet or FindFirstPet());
	end
end

function StableFrameMixin:OnPetSwapRequested(originSlot, destinationSlot, reverseSelectedDisplay)
	if not originSlot or not destinationSlot then
		return;
	end

	C_StableInfo.SetPetSlot(originSlot, destinationSlot);

	-- If we're swapping an active pet for an inactive pet, we should select the new active pet
	-- If we're swapping an active pet for nothing, accept the nil and select the "first" pet like it does by default
	if reverseSelectedDisplay then
		self.selectedPetNewSlot = originSlot;
	else
		self.selectedPetNewSlot = destinationSlot;
	end
end

function StableFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, STABLE_FRAME_ON_SHOW_EVENTS);
	self:Refresh();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function StableFrameMixin:OnHide()
	self.selectedPet = nil;
	FrameUtil.UnregisterFrameForEvents(self, STABLE_FRAME_ON_SHOW_EVENTS);

	ClearPetCursor();
	HelpPlate_Hide();
	C_StableInfo.ClosePetStables();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function StableFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_SPECIALIZATION_CHANGED" then
		self.ActivePetList:Refresh();
	elseif event == "PET_STABLE_SHOW" then
		ShowUIPanel(self);
	elseif event == "PET_STABLE_CLOSED" then
		HideUIPanel(self);
		StaticPopup_Hide("PETRENAMECONFIRM");
	elseif event == "PET_STABLE_UPDATE" or event == "SPELLS_CHANGED" or event == "PET_INFO_UPDATE" then
		self:Refresh();
	end
end

function StableFrameMixin:RefreshSelectedPetData()
	if not self.selectedPet then
		return;
	end

	-- The selected pet may have been moved to a different slot, so after refreshing the data it might turn nil if the slot is empty now.
	-- Check the new slot first, then fall back on the old slot. If nothing is there, we will default to summoned pet or the first pet in the active list
	self.selectedPet = C_StableInfo.GetStablePetInfo(self.selectedPetNewSlot and self.selectedPetNewSlot or self.selectedPet.slotID);
end

function StableFrameMixin:Refresh()
	self.StabledPetList:Refresh();
	self.ActivePetList:Refresh();
	self:SetupPetCounter();

	if self.selectedPet then
		self:RefreshSelectedPetData();
		EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", self.selectedPet or GetSummonedPet() or FindFirstPet());
	end

	if not self.selectedPet then
		EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", GetSummonedPet() or FindFirstPet());
	end

	self.PetModelScene:SetPet(self.selectedPet);
end

function StableFrameMixin:SetupPetCounter()
	local totalStabled = #self.StabledPetList.pets;
	local totalActive = #self.ActivePetList.pets;

	-- Don't count the secondary "bonus" pet twice, if it is slotted
	if totalActive > Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS then
		totalActive = Constants.PetConsts.MAX_SUMMONABLE_HUNTER_PETS;
	end

	local totalNumPets = totalStabled + totalActive;
	local counterText = STABLE_PET_COUNTER:format(totalNumPets, Constants.PetConsts.NUM_PET_SLOTS);
	self.StabledPetList.ListCounter.Count:SetText(counterText);
end

StableTogglePetButtonMixin = {};

function StableTogglePetButtonMixin:OnLoad()
	self:RegisterEvent("UNIT_PET");
	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);
	self.mode = StableTogglePetButton.Stable;
end

function StableTogglePetButtonMixin:OnEvent(event)
	if event == "UNIT_PET" then
		local pet = self:GetParent().selectedPet;
		if(pet) then
			self:OnPetSelected(pet);
		end
	end
end

function StableTogglePetButtonMixin:OnPetSelected(pet)
	if not pet then
		return;
	end

	local isActivePet = pet and IsActivePetSlot(pet.slotID);
	self.mode = isActivePet and StableTogglePetButton.Stable or StableTogglePetButton.MakeActive;
	self:SetText(isActivePet and STABLE_PET_BUTTON_LABEL or MAKE_ACTIVE_PET_BUTTON_LABEL);
end

function StableTogglePetButtonMixin:OnClick()
	ClearPetCursor();
	local selectedSlot = GetSelectedPet().slotID;
	local destinationSlot;
	if self.mode == StableTogglePetButton.Stable then
		destinationSlot = FindFirstUnusedStableSlot();
	elseif self.mode == StableTogglePetButton.MakeActive then
		destinationSlot = FindFirstUnusedActivePetSlot() or GetFirstActivePetSlot();
	end

	EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", selectedSlot, destinationSlot);
end

StableReleasePetButtonMixin = {};

function StableReleasePetButtonMixin:OnClick()
	ClearPetCursor();
	local selectedPet = GetSelectedPet();
	local summonedPet = GetSummonedPet();
	StaticPopup_Show("RELEASE_PET", nil, nil, {selectedPetNumber = selectedPet and selectedPet.petNumber, summonedPetNumber = summonedPet and summonedPet.petNumber});
end

StablePetFavoriteButtonMixin = {};

function StablePetFavoriteButtonMixin:IsFavorited()
	return C_StableInfo.IsPetFavorite(self:GetParent().petData.slotID);
end

function StablePetFavoriteButtonMixin:OnClick()
	ClearPetCursor();
	self:ToggleFavorited();
end

function StablePetFavoriteButtonMixin:SetFavorited(favorited)
	ClearSelectedPetNewSlot();
	local slotID = self:GetParent().petData.slotID;
	C_StableInfo.SetPetFavorite(slotID, favorited);
	self:RefreshVisuals();
end

function StablePetFavoriteButtonMixin:ToggleFavorited()
	self:SetFavorited(not self:IsFavorited());
end

function StablePetFavoriteButtonMixin:RefreshVisuals()
	self:SetNormalAtlas(self:IsFavorited() and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off", TextureKitConstants.UseAtlasSize);
	self:SetHighlightAtlas(self:IsFavorited() and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off");
end

StableActivePetListMixin = {};

function StableActivePetListMixin:GetPet(activePetSlot)
	return self.pets[activePetSlot];
end

function StableActivePetListMixin:Refresh()
	self.pets = C_StableInfo.GetActivePetList();

	for i, petButton in ipairs(self.PetButtons) do
		local slottedPet = nil;
		for p, pet in ipairs(self.pets) do
			if pet.slotID == i then
				slottedPet = pet;
				break;
			end
		end

		local slotUnlocked = IsActivePetSlotUnlocked(i);
		if slottedPet then
			petButton:SetEnabled(slotUnlocked);
			petButton:SetPet(slottedPet);
		else
			petButton:SetEnabled(slotUnlocked);
			petButton:SetPet(nil);
		end
		petButton:SetLocked(not slotUnlocked);
	end
	self.BeastMasterSecondaryPetButton:SetPet(GetBeastmasterSecondaryPet());
	self.BeastMasterSecondaryPetButton:Refresh();
end

StablePetNameBoxMixin = {};

function StablePetNameBoxMixin:SetPet(petData)
	self.Name:SetText(petData.name);
	local nameWidth = self.Name:GetStringWidth();
	self:SetWidth(nameWidth);
end

StablePetNameEditButtonMixin = {};

function StablePetNameEditButtonMixin:OnClick()
	ClearPetCursor();
	local selectedPet = GetSelectedPet();

	if selectedPet then 
		StaticPopup_Show("RENAME_PET", nil, nil, {petNumber = selectedPet.petNumber});
		ClearSelectedPetNewSlot();
		SetSelectedPet(selectedPet);
	end
end

StableStabledPetButtonTemplateMixin = {};

function StableStabledPetButtonTemplateMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown", "RightButtonUp");
	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);
	EventRegistry:RegisterCallback("PET_STABLE_FAVORITES_UPDATED", self.OnFavoritesUpdated, self);
end

function StableStabledPetButtonTemplateMixin:OnPetSelected(pet)
	self.isSelected = pet.slotID == self.petData.slotID;

	if self.isSelected then
		self.Portrait.Border:SetAtlas("pet-list_active-ring");
	else
		self.Portrait.Border:SetAtlas("pet-list_default-ring");
	end

	self.Selected:SetShown(self.isSelected);
end

function StableStabledPetButtonTemplateMixin:OnFavoritesUpdated()
	self:RefreshFavoriteIcon();
end

function StableStabledPetButtonTemplateMixin:RefreshFavoriteIcon()
	self.Portrait.FavoriteIcon:SetShown(self.petData and C_StableInfo.IsPetFavorite(self.petData.slotID));
end

function StableStabledPetButtonTemplateMixin:OnDragStart()
	C_StableInfo.PickupStablePet(self.petData.slotID);
end

function StableStabledPetButtonTemplateMixin:OnReceiveDrag()
	local cursorType, petSlotID = GetCursorInfo();
	local petData = self.petData;
	self:StablePet(petSlotID, self.petData and self.petData.slotID or FindFirstUnusedStableSlot());
end

function StableStabledPetButtonTemplateMixin:StablePet(originSlot, destSlot)
	EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", originSlot, destSlot, true);
	ClearPetCursor();
end

function StableStabledPetButtonTemplateMixin:SetPet(petData)
	self.petData = petData;
	if not self.petData then
		return;
	end
	
	SetPortraitTextureFromCreatureDisplayIDFlipped(self.Portrait.Icon, self.petData.displayID);
	self.Name:SetText(petData.name);
	self.Type:SetText(petData.familyName);
	self:RefreshFavoriteIcon();
end

function StableStabledPetButtonTemplateMixin:OnClick(mouseButton)
	local cursorType, petSlotID = GetCursorInfo();

	if mouseButton == "RightButton" then
		local destSlot = FindFirstUnusedActivePetSlot();
		if destSlot and self.petData then
			EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", self.petData.slotID, destSlot);
		end
	elseif mouseButton == "LeftButton" and cursorType == "pet" then
		if self.petData and petSlotID then
			ClearCursor();
			EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", self.petData.slotID, petSlotID);
		end
	elseif mouseButton == "LeftButton" then
		EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", self.petData);
	end
end

StableSearchBoxMixin = {};

function StableSearchBoxMixin:GetSearchString()
	return self:GetText();
end

function StableSearchBoxMixin:StartSearch()
	StableFrame.StabledPetList.searchString = self:GetSearchString();
	StableFrame.StabledPetList:Refresh();
end

function StableSearchBoxMixin:OnEnterPressed()
	EditBox_ClearFocus(self);
	self:StartSearch();
end

function StableSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);
	self:StartSearch();
end

StableActivePetButtonTemplateMixin = {};

function StableActivePetButtonTemplateMixin:SetLocked(locked)
	self.Lock:SetShown(locked);
	self:SetDesaturated(locked);
	self.locked = locked;
end

function StableActivePetButtonTemplateMixin:SetDesaturated(desaturate)
	self.Border:SetDesaturated(desaturate);
	self.Icon:SetDesaturated(desaturate);
end

function StableActivePetButtonTemplateMixin:SetPet(petData)
	self.petData = petData;
	if not self.petData then
		self:Reset();
	else
		SetPortraitTextureFromCreatureDisplayIDFlipped(self.Icon, self.petData.displayID);
	end

	if GameTooltip:GetOwner() == self then
		self:RefreshTooltip();
	end
end

function StableActivePetButtonTemplateMixin:Reset()
	self.Icon:SetTexture(nil);
end

function StableActivePetButtonTemplateMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown", "RightButtonUp")
	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);
end

function StableActivePetButtonTemplateMixin:OnPetSelected(pet)
	self.isSelected = self.petData and self.petData.slotID == pet.slotID;
	self.Highlight:SetShown(self.isSelected);
end

function StableActivePetButtonTemplateMixin:OnHide()
	self.isSelected = false;
	self.Highlight:SetShown(false);
end

function StableActivePetButtonTemplateMixin:OnClick(mouseButton)
	if mouseButton == "RightButton" then
		if self.petData then
			EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", self.petData.slotID, FindFirstUnusedStableSlot(), true);
			EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", FindFirstPet());
		end
		return;
	end

	local cursorType = GetCursorInfo();
	if cursorType == "pet" then
		self:TryAcceptPetSwap();
		return;
	end

	if self.petData then
		self:TryAcceptPetSwap();
		EventRegistry:TriggerEvent("StableFrameMixin.PetSelected", self.petData);
	end
end

function StableActivePetButtonTemplateMixin:RefreshTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -20, -15);
	if self.locked and not self.isSecondarySlot then
		GameTooltip_SetTitle(GameTooltip, RED_FONT_COLOR:WrapTextInColorCode(PET_STABLE_SLOT_LOCKED));
		local nextCallPetSpellID = CALL_PET_SPELL_IDS[self:GetID()];
		local spellName = GetSpellInfo(nextCallPetSpellID);
		if (spellName and spellName ~= "") then
			GameTooltip_AddHighlightLine(GameTooltip, PET_STABLE_SLOT_LOCKED_TOOLTIP:format(spellName));
		end
	elseif not self:IsEnabled() and self.disabledTooltip then
		GameTooltip_AddErrorLine(GameTooltip, self.disabledTooltip);
	elseif self.petData then
		GameTooltip_AddHighlightLine(GameTooltip, self.petData.name);
		if self.petData.slotID == GetSummonedPetStableSlot() then
			GameTooltip_AddNormalLine(GameTooltip, STABLE_SUMMONED_PET_LABEL);
		end
	end
	GameTooltip:Show();
end

function StableActivePetButtonTemplateMixin:OnEnter()
	if self:IsEnabled() then
		self.Highlight:Show();
	end

	self:RefreshTooltip();
end

function StableActivePetButtonTemplateMixin:OnLeave()
	if not self.isSelected then
		self.Highlight:Hide();
	end
	GameTooltip_Hide();
end

function StableActivePetButtonTemplateMixin:OnDragStart()
	if self.petData then
		C_StableInfo.PickupStablePet(self.petData.slotID);
	end
end

function StableActivePetButtonTemplateMixin:OnReceiveDrag()
	self:TryAcceptPetSwap();
end

function StableActivePetButtonTemplateMixin:TryAcceptPetSwap()
	local cursorType, petSlotID = GetCursorInfo();
	if (cursorType ~= "pet") then
		return;
	end

	EventRegistry:TriggerEvent("StableFrameMixin.PetSwapRequested", petSlotID, self:GetID());
	ClearPetCursor();
end

StableBeastMasterSecondaryPetButtonMixin = CreateFromMixins(StableActivePetButtonTemplateMixin);

function StableBeastMasterSecondaryPetButtonMixin:OnShow()
	self:Refresh();
	self:RegisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED");
	self.isSecondarySlot = true;
end

function StableBeastMasterSecondaryPetButtonMixin:OnHide()
	self:UnregisterEvent("ACTIVE_COMBAT_CONFIG_CHANGED");
end

function StableBeastMasterSecondaryPetButtonMixin:OnEvent(event, ...)
	if event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
		self:Refresh();
	end
end

function StableBeastMasterSecondaryPetButtonMixin:Refresh()
	local configID = C_ClassTalents.GetActiveConfigID();
	local animalCompanionTalentInfo = configID and C_Traits.GetNodeInfo(configID, ANIMAL_COMPANION_NODE_ID);
	local knowsAnimalCompanion = animalCompanionTalentInfo and animalCompanionTalentInfo.ranksPurchased > 0;
	self:SetEnabled(knowsAnimalCompanion);
	self:SetDesaturated(not knowsAnimalCompanion);
	self:SetLocked(not knowsAnimalCompanion);
	self:SetPet(knowsAnimalCompanion and GetBeastmasterSecondaryPet() or nil);
	self.disabledTooltip = STABLE_SECONDARY_PET_DISABLED;
end

StablePetInfoMixin = {};

function StablePetInfoMixin:SetPet(petData)
	self.petData = petData;
	self.NameBox:SetPet(petData);
	self.Specialization:SetText(STABLE_PET_INFO_SPECIALIZATION_TYPE_LABEL:format(petData.specialization, petData.type));
	self.Exotic:SetText(petData.isExotic and STABLE_EXOTIC_TYPE_LABEL or nil);

	local petIconMarkup = CreateSimpleTextureMarkup(petData.icon or QUESTION_MARK_ICON, 16, 16);
	local petFamilyString = petIconMarkup .. " " .. petData.familyName;
	self.Type:SetText(STABLE_PET_INFO_FAMILY_LABEL:format(petFamilyString));

	self.FavoriteButton:RefreshVisuals();
end

StablePetTypeStringMixin = {};

function StablePetTypeStringMixin:GetPetInfoFrame()
	return self:GetParent();
end

function StablePetTypeStringMixin:OnEnter()
	local petInfoFrame = self:GetPetInfoFrame();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, STABLE_PET_INFO_TYPE_TOOLTIP_FAMILY:format(petInfoFrame.petData.familyName));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	local dietString = PET_DIET_TEMPLATE:format(table.concat(C_StableInfo.GetStablePetFoodTypes(petInfoFrame.petData.slotID), LIST_DELIMITER));
	GameTooltip_AddHighlightLine(GameTooltip, dietString);
	GameTooltip:Show();
end

function StablePetTypeStringMixin:OnLeave()
	GameTooltip_Hide();
end

StabledPetListCategoryMixin = {};

function StabledPetListCategoryMixin:OnEnter()
	self.Label:SetFontObject(GameFontHighlight_NoShadow);
end

function StabledPetListCategoryMixin:OnLeave()
	self.Label:SetFontObject(GameFontNormal_NoShadow);
end

function StabledPetListCategoryMixin:SetCollapseState(collapsed)
	local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse";
	self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

StableStabledPetListMixin = {};

function StableStabledPetListMixin:OnLoad()
	local indent = 0;
	local topPadding = 10;
	local bottomPadding = 25;
	local leftPadding = 10;
	local rightPadding = 5;
	local elementSpacing = 15;
	local view = CreateScrollBoxListTreeListView(indent, topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	view:SetElementFactory(function(factory, node)
		local data = node:GetData();

		if data.categoryInfo then
			local function Initializer(button)
				data.button = button;
				button.Label:SetText(data.categoryInfo.displayName);
				button:SetCollapseState(node:IsCollapsed());

				button:SetScript("OnClick", function(button)
					node:ToggleCollapsed();
					button:SetCollapseState(node:IsCollapsed());
					self.collapsedCategories[data.categoryInfo.displayName] = node:IsCollapsed() or nil;
				end);
			end
			factory("StableStabledPetListCategoryButtonTemplate", Initializer);
		else
			local function Initializer(button)
				local selectedPet = GetSelectedPet();
				local isSelected = selectedPet and selectedPet.slotID == data.slotID;
				local listBackground = GetListBackgroundForPetSpecialization(data.specialization);

				if isSelected then
					button.Portrait.Border:SetAtlas("pet-list_active-ring");
				else
					button.Portrait.Border:SetAtlas("pet-list_default-ring");
				end

				button.Selected:SetAtlas(GetSelectedListBackgroundForPetSpecialization(data.specialization));
				button.Background:SetAtlas(listBackground);
				button.Highlight:SetAtlas(listBackground);

				button.Selected:SetShown(isSelected);
				button:SetPet(data);
				button:Show();
			end
			factory("StableStabledPetButtonTemplate", Initializer);
		end
	end);

	EventRegistry:RegisterCallback("PET_STABLE_FAVORITES_UPDATED", self.Refresh, self);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function StableStabledPetListMixin:OnShow()
	self.sortMode = tonumber(GetCVar("petStableSort")) or PetSortMode.Specialization;
	self.showExoticOnly = GetCVarBool("petStableShowExoticOnly") or false;
	self.collapsedCategories = {};

	self.ScrollBox:ScrollToBegin();
	StableFilterButton_UpdateVisibility();
end

function StableStabledPetListMixin:SetSortMode(mode)
	self.collapsedCategories = {};

	local defaultMode = PetSortMode.Name;
	self.sortMode = mode or defaultMode;
	SetCVar("petStableSort", self.sortMode);
	self:UpdateDisplayedPets();
end

function StableStabledPetListMixin:GetSortMode()
	return self.sortMode;
end

function StableStabledPetListMixin:ToggleShowExoticOnly()
	self.showExoticOnly = not self.showExoticOnly;
	SetCVar("petStableShowExoticOnly", self.showExoticOnly and 1 or 0);
	self:UpdateDisplayedPets();
end

function StableStabledPetListMixin:GetShowExoticOnly()
	return self.showExoticOnly;
end

function StableStabledPetListMixin:SetSearchString(string)
	self.searchString = string;
end

function StableStabledPetListMixin:Refresh()
	self.pets = C_StableInfo.GetStabledPetList();
	self:UpdateDisplayedPets();

	-- If category was collapsed before, keep it collapased
	local dataProvider = self.ScrollBox:GetDataProvider();
	local validSortMode = self.sortMode == PetSortMode.Specialization or self.sortMode == PetSortMode.Family;
	if dataProvider and validSortMode then
		for _, node in ipairs(dataProvider:GetRootNode().nodes) do
			local data = node:GetData();
			if data.categoryInfo and self.collapsedCategories[data.categoryInfo.displayName] == true and not node:IsCollapsed() then
				node:SetCollapsed(true);
				if data.button then
					data.button:SetCollapseState(true);
				end
			end
		end
	end
end

function StableStabledPetListMixin:BuildListCategories()
	local favoritesSortOrder = 0;
	local nonFavoritesSortOrder = 1;
	local defaultSortOrder = 2;

	local categories = { 
		-- Use sort order to enforce a sort that should happen after the default alphabetical sort. 
		favorites = {displayName = FAVORITES, sortOrder = favoritesSortOrder},
		nonfavorites = {displayName = STABLE_PET_UNCATEGORIZED, sortOrder = nonFavoritesSortOrder}, -- nonfavorites is only displayed when sort mode is alphabetical or reverse alphabetical
	};

	if self.sortMode == PetSortMode.Specialization then
		for i, pet in ipairs(C_StableInfo.GetStabledPetList()) do
			categories[pet.specialization] = {displayName = pet.specialization, sortOrder = defaultSortOrder};
		end
	elseif self.sortMode == PetSortMode.Family then
		for i, pet in ipairs(C_StableInfo.GetStabledPetList()) do 
			categories[pet.familyName] = {displayName = pet.familyName, sortOrder = defaultSortOrder};
		end
	end
	
	return categories;
end

local function PetNameSort(pet1, pet2)
	return strcmputf8i(pet1.name, pet2.name) < 0;
end

local function PetNameReverseSort(pet1, pet2)
	return strcmputf8i(pet1.name, pet2.name) > 0;
end

local sortFunctions = {
	[PetSortMode.Name] = PetNameSort,
	[PetSortMode.NameReverse] = PetNameReverseSort,
}

function StableStabledPetListMixin:UpdateDisplayedPets()
	local data = self:BuildListCategories();
	local dataProvider = CreateTreeDataProvider();
	local isNameSortMode = self.sortMode == PetSortMode.Name or self.sortMode == PetSortMode.NameReverse;

	-- Put data in a shape dataProvider expects
	for i, pet in ipairs(self.pets) do
		if (self.showExoticOnly and pet.isExotic) or (not self.showExoticOnly) then
			if self:PetPassesSearch(pet) then
				-- Name sort modes don't have categories, it is just a flat list
				if C_StableInfo.IsPetFavorite(pet.slotID) then
					tinsert(data.favorites, pet);
				elseif isNameSortMode then
					tinsert(data.nonfavorites, pet);
				-- When a sort mode has categories, put pets into those cateogry "buckets"
				elseif self.sortMode == PetSortMode.Specialization then
					tinsert(data[pet.specialization], pet);
				elseif self.sortMode == PetSortMode.Family then
					tinsert(data[pet.familyName], pet);
				end
			end
		end
	end

	if isNameSortMode then
		table.sort(data.favorites, sortFunctions[self.sortMode]);
		table.sort(data.nonfavorites, sortFunctions[self.sortMode]);
	end

	-- Insert into dataProvider
	for category in pairs(data) do
		if(#data[category] > 0) then
			local categorySubtree = dataProvider:Insert({categoryInfo = {displayName = data[category].displayName, sortOrder = data[category].sortOrder or defaultSortOrder}});
			for i, pet in ipairs(data[category]) do
				categorySubtree:Insert(pet);
			end
		end
	end

	-- Sort first by sort order (only used to pin favorites to the top currently), then sort by category name.
	-- If alphabetically sorting pets, favorites/nonfavorites will have already been sorted and this will just handle sortOrder
	dataProvider:SetSortComparator(function(a, b)
		aData = a.data;
		bData = b.data;
		if(aData.categoryInfo and bData.categoryInfo) then
			if aData.categoryInfo.sortOrder < bData.categoryInfo.sortOrder then
				return true;
			elseif aData.categoryInfo.sortOrder > bData.categoryInfo.sortOrder then
				return false;
			elseif aData.categoryInfo.sortOrder == bData.categoryInfo.sortOrder then
				return strcmputf8i(aData.categoryInfo.displayName, bData.categoryInfo.displayName) < 0;
			end
		end
	end);

	dataProvider:Sort();
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function StableStabledPetListMixin:PetPassesSearch(pet)
	if not self.searchString or self.searchString == "" then
		return true;
	end

	local foundPet = false;
	local petName = string.lower(pet.name);
	local petFamily = string.lower(pet.familyName);
	local petSpec = string.lower(pet.specialization);
	local petType = string.lower(pet.type);
	local searchString = string.lower(self.searchString);

	-- pet name, family, and spec
	if string.find(petName, searchString) or string.find(petFamily, searchString) or string.find(petSpec, searchString) or string.find(petType, searchString) then
		foundPet = true;
	end

	-- pet abilities
	for i, abilityID in ipairs(pet.abilities) do
		local abilityName = GetSpellInfo(abilityID);
		if string.find(string.lower(abilityName), searchString) then
			foundPet = true;
		end
	end

	return foundPet;
end

StableFilterButtonMixin = {};

function StableFilterButtonMixin:OnClick()
	local dropDownLevel, value = 1, nil;
	ToggleDropDownMenu(dropDownLevel, value, self.DropDown, self, 100, 25);
end

StableFilterDropDownMixin = {};

function StableFilterDropDownMixin:OnLoad()
	UIDropDownMenu_Initialize(self, self.InitializeDropDown, "MENU");
end

function StableFilterDropDownMixin:OnShow()
	StableFilterButton_UpdateVisibility();
end

function StableFilterDropDownMixin:GetStabledPetList()
	return self:GetParent():GetParent():GetParent();
end

function StableFilterDropDownMixin:SetStabledPetListSortMode(mode)
	self:GetStabledPetList():SetSortMode(mode);
end

function StableFilterDropDownMixin:GetStabledPetListSortMode()
	return self:GetStabledPetList():GetSortMode();
end

function StableFilterDropDownMixin:SetStabledPetListShowExoticOnly()
	self:GetStabledPetList():ToggleShowExoticOnly();
end

function StableFilterDropDownMixin:GetStabledPetListShowExoticOnly()
	return self:GetStabledPetList():GetShowExoticOnly();
end

function StableFilterButton_ResetFilters()
	local filterDropdown = GetStableFilterDropdown();

	if filterDropdown:GetStabledPetListShowExoticOnly() == true then
		filterDropdown:SetStabledPetListShowExoticOnly();
	end
	filterDropdown:SetStabledPetListSortMode(PetSortMode.Specialization);
	StableFrame.StabledPetList.FilterBar.FilterButton.ResetButton:Hide();
end

function StableFilterButton_UsingDefaultFilters()
	local filterDropdown = GetStableFilterDropdown();
	return filterDropdown:GetStabledPetListShowExoticOnly() == false and filterDropdown:GetStabledPetListSortMode() == PetSortMode.Specialization;
end

function StableFilterButton_UpdateVisibility()
	StableFrame.StabledPetList.FilterBar.FilterButton.ResetButton:SetShown(not StableFilterButton_UsingDefaultFilters());
end

function StableFilterDropDownMixin:InitializeDropDown(level)
	local filterSystem = {
		onUpdate = StableFilterButton_UpdateVisibility,
		filters = {
			{ type = FilterComponent.Title, text = STABLE_FILTER_LABEL_TYPE, },
			{ type = FilterComponent.Checkbox,
			text = STABLE_EXOTIC_TYPE_LABEL, 
			set=function() self:SetStabledPetListShowExoticOnly() end, 
			isSet=function() return self:GetStabledPetListShowExoticOnly() == true; end, 
			hideMenuOnClick = false,
		  	},
			{ type = FilterComponent.Submenu, text = STABLE_FILTER_SORT_BY_LABEL, value = 1, childrenInfo = {
				filters = {
					{ type = FilterComponent.Radio,
						text = STABLE_SORT_SPECIALIZATION_LABEL, 
						set=function() self:SetStabledPetListSortMode(PetSortMode.Specialization) end, 
						isSet=function() return self:GetStabledPetListSortMode() == PetSortMode.Specialization; end, 
						hideMenuOnClick = false,
					},
					{ type = FilterComponent.Radio, 
						text = STABLE_SORT_TYPE_LABEL,
						set=function() self:SetStabledPetListSortMode(PetSortMode.Family) end,
						isSet=function() return self:GetStabledPetListSortMode() == PetSortMode.Family; end, 
						hideMenuOnClick = false,
					},
					{ type = FilterComponent.Radio,
						text = STABLE_SORT_NAME_LABEL, 
						set=function() self:SetStabledPetListSortMode(PetSortMode.Name) end, 
						isSet=function() return self:GetStabledPetListSortMode() == PetSortMode.Name; end, 
						hideMenuOnClick = false,
					},
					{ type = FilterComponent.Radio,
						text = STABLE_SORT_NAME_REVERSE_LABEL, 
						set=function() self:SetStabledPetListSortMode(PetSortMode.NameReverse) end, 
						isSet=function() return self:GetStabledPetListSortMode() == PetSortMode.NameReverse; end, 
						hideMenuOnClick = false,
					},
				}
			}},
		},
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

StableFrame_HelpPlate = {
	FramePos = { x = 0,	y = -22 },
	FrameSize = { width = 1040, height = 638 },
	[1] = { ButtonPos = { x = -18,	y = -45}, HighLightBox = { x = 0, y = -62, width = 328, height = 555 }, ToolTipDir = "RIGHT", ToolTipText = STABLE_HELP_STABLED_PETS },
	[2] = { ButtonPos = { x = 425,	y = -520 }, HighLightBox = { x = 327, y = -519, width = 531, height = 98 }, ToolTipDir = "UP", ToolTipText = STABLE_HELP_ACTIVE_PETS },
	[3] = { ButtonPos = { x = 885,	y = -520 }, HighLightBox = { x = 856, y = -519, width = 183, height = 98 }, ToolTipDir = "UP", ToolTipText = STABLE_HELP_SECONDARY_PET },
}

function StableFrameMixin:ToggleHelpPlates()
	if StableFrame_HelpPlate and not HelpPlate_IsShowing(StableFrame_HelpPlate) then
		HelpPlate_Show(StableFrame_HelpPlate, self, self.MainHelpButton);
	else
		local userToggled = true;
		HelpPlate_Hide(userToggled);
	end
end

StableTutorialButtonMixin = {};

function StableTutorialButtonMixin:OnClick()
	self:GetParent():ToggleHelpPlates();
end

StablePetModelSceneMixin = CreateFromMixins(PanningModelSceneMixin);

function StablePetModelSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);
	self.ControlFrame:SetModelScene(self);
end

function StablePetModelSceneMixin:OnMouseDown(mouseButton)
	ModelSceneMixin.OnMouseDown(self, mouseButton);
	if mouseButton == "RightButton" then
		ClearPetCursor();
	end
end

function StablePetModelSceneMixin:SetPet(pet)
	if not pet then
		return;
	end

	self:UpdatePetModel(pet);
	self:UpdateBackgroundForPet(pet);
	self.PetInfo:SetPet(pet);
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
	self.Background:SetAtlas(GetBackgroundForPetSpecialization(pet.specialization), TextureKitConstants.UseAtlasSize);
end

StablePetAbilityMixin = {};

function StablePetAbilityMixin:Initialize(spellID)
	self.spellID = spellID;
	if not self.spellID then
		self.Icon:SetTexture(QUESTION_MARK_ICON);
		self.Name:SetText("");
		self:Hide();
		return;
	end

	local spellName, spellRank, spellIcon, spellCastTime, spellMinRange, spellMaxRange, _, spellOriginalIcon = GetSpellInfo(spellID);
	self.Icon:SetTexture(spellIcon);
	self.Name:SetText(spellName);

	local padding = 10;
	self:SetWidth(self.Name:GetWidth() + self.Icon:GetWidth() + padding);
	self:Show();
end

function StablePetAbilityMixin:OnEnter()
	if not self.spellID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local spell = Spell:CreateFromSpellID(self.spellID);
	spell:ContinueWithCancelOnSpellLoad(function()
		if GameTooltip:GetOwner() == self then	
			GameTooltip:SetSpellByID(self.spellID, true, true);
			GameTooltip:Show();
		end
	end);
end

function StablePetAbilityMixin:OnLeave()
	GameTooltip:Hide();
end

StablePetAbilitiesListMixin = {};

function StablePetAbilitiesListMixin:OnLoad()
	EventRegistry:RegisterCallback("StableFrameMixin.PetSelected", self.OnPetSelected, self);

	local function AbilityResetter(framePool, frame)
		frame.spellID = nil;
		frame.Icon:SetTexture(QUESTION_MARK_ICON);
		frame.Name:SetText("");
		frame:ClearAllPoints();
		frame:Hide();
	end

	self.abilityPool = CreateFramePool("FRAME", self, "StablePetAbilityTemplate", AbilityResetter);
end

function StablePetAbilitiesListMixin:OnPetSelected(pet)
	if not pet or not pet.abilities then
		return;
	end

	self.abilityPool:ReleaseAll();

	local lastAbility;
	for index, abilityID in ipairs(pet.abilities) do
		local ability = self.abilityPool:Acquire();
		ability:Initialize(abilityID);

		local isFirstAbility = index == 1;
		if isFirstAbility then
			ability:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -4);
		else
			ability:SetPoint("TOPLEFT", lastAbility, "BOTTOMLEFT", 0, -4);
		end

		lastAbility = ability;
	end

	self:Layout();
end