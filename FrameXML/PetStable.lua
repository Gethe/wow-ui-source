NUM_PET_STABLE_SLOTS = 10;
NUM_PET_STABLE_PAGES = 2;
NUM_PET_ACTIVE_SLOTS = 5;

local CALL_PET_SPELL_IDS = {
	0883,
	83242,
	83243,
	83244,
	83245,
};

function PetStable_OnLoad(self)
	self:RegisterEvent("PET_STABLE_SHOW");
	self:RegisterEvent("PET_STABLE_UPDATE");
	self:RegisterEvent("PET_STABLE_UPDATE_PAPERDOLL");
	self:RegisterEvent("PET_STABLE_CLOSED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("SPELLS_CHANGED");
	
	-- Set portrait
	SetPortraitToTexture(PetStableFramePortrait, "Interface\\Icons\\ability_physical_taunt");

	self.TitleText:SetFormattedText(PET_STABLE_TITLE, UnitName("player"));
	ButtonFrameTemplate_HideButtonBar(self);
	self.Inset:ClearAllPoints();
	self.Inset:SetPoint("TOPLEFT", 91, PANEL_INSET_TOP_OFFSET-2);
	self.Inset:SetPoint("BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, 126);
	self.LeftInset:SetPoint("TOPLEFT", PANEL_INSET_LEFT_OFFSET, PANEL_INSET_ATTIC_OFFSET+4);
	self.LeftInset:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 91, PANEL_INSET_BOTTOM_OFFSET);
	self.LeftInset.Bg:Hide();
	self.BottomInset:SetPoint("TOPLEFT", self.Inset, "BOTTOMLEFT", 0, 0);
	self.BottomInset:SetPoint("BOTTOMRIGHT", PANEL_INSET_RIGHT_OFFSET, PANEL_INSET_BOTTOM_OFFSET);
	self.BottomInset.Bg:Hide();
	self.page = 1;
	self.selectedPet = nil;
end

function PetStable_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "PET_STABLE_SHOW" ) then
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			ClosePetStables();
			return;
		end

		PetStable_Update(true);
	elseif ( event == "PET_STABLE_UPDATE" or event == "SPELLS_CHANGED") then
		PetStable_Update(true);
	elseif (event == "UNIT_NAME_UPDATE" and arg1 == "pet") then
		PetStable_Update(false);
	elseif ( event == "PET_STABLE_UPDATE_PAPERDOLL" ) then
		-- So warlock pets don't show
		if ( UnitExists("pet") and not HasPetUI() ) then
			PetStable_NoPetsAllowed();
			return;
		end
		if (PetStableFrame.selectedPet) then
			SetPetStablePaperdoll(PetStableModel, PetStableFrame.selectedPet);
		else
			PetStableModel:Hide();
		end
	elseif ( event == "PET_STABLE_CLOSED" ) then
		HideUIPanel(self);
		StaticPopup_Hide("CONFIRM_BUY_STABLE_SLOT");
	end
end

function PetStable_UpdateSlot(button, petSlot)

	local icon, name, level, family, talent = GetStablePetInfo(petSlot);
	
	button.petSlot = petSlot;
	SetItemButtonTexture(button, icon);

	if ( icon and level and family and talent) then
		button.tooltip = name;
		button.tooltipSubtext = format(STABLE_PET_INFO_TOOLTIP_TEXT, level, family, talent);
	else
		button.tooltip = EMPTY_STABLE_SLOT;
		button.tooltipSubtext = "";
	end
	
	if (button.PetName) then
		button.PetName:SetText(name);
	end
	
	if ( GameTooltip:IsOwned(button) ) then
		button:GetScript("OnEnter")(button);
	end
	
	if (PetStableFrame.selectedPet and PetStableFrame.selectedPet == button.petSlot) then
		button.Checked:Show();
	else
		button.Checked:Hide();
	end
end

function PetStable_SetSelectedPetInfo(icon, name, level, family, talent)
	if ( family and talent) then
		PetStableTypeText:SetFormattedText(STABLE_PET_INFO_TEXT, family, talent);
	else
		PetStableTypeText:SetText("");
	end
	
	if (level) then
		PetStableLevelText:SetFormattedText(UNIT_LEVEL_TEMPLATE, level);
	else
		PetStableLevelText:SetText("");
	end
	
	if ( name ) then
		PetStableNameText:SetText(name);
	else
		PetStableNameText:SetText("");
	end
	
	PetStableSelectedPetIcon:SetTexture(icon);
end

function PetStable_GetPetSlot(buttonID, active)
	if (active) then
		return buttonID;
	else
		return NUM_PET_ACTIVE_SLOTS + (PetStableFrame.page-1)*NUM_PET_STABLE_SLOTS + buttonID;
	end
end

function PetStable_Update(updateModel)
	-- So warlock pets don't show
	local hasPetUI, isHunterPet = HasPetUI();
	if ( UnitExists("pet") and hasPetUI and not isHunterPet ) then
		PetStable_NoPetsAllowed();
		for i =1, NUM_PET_ACTIVE_SLOTS do
			_G["PetStableActivePet"..i]:Disable();
		end
		return;
	else
		for i =1, NUM_PET_ACTIVE_SLOTS do
			_G["PetStableActivePet"..i]:Enable();
		end
	end
	
	-- If no selected pet, try to set one
	if (PetStableFrame.selectedPet and not GetStablePetInfo(PetStableFrame.selectedPet)) then
		PetStableFrame.selectedPet = nil;
	end
	
	if ( not PetStableFrame.selectedPet ) then
		for i=1, NUM_PET_ACTIVE_SLOTS do
			local petSlot = PetStable_GetPetSlot(i, true);
			if ( GetStablePetInfo(petSlot) ) then
				PetStableFrame.selectedPet = petSlot;
				updateModel = true;
				break;
			end 
		end
		
		if ( not PetStableFrame.selectedPet) then
			for i=1, NUM_PET_STABLE_SLOTS do
				local petSlot = PetStable_GetPetSlot(i, false);
				if ( GetStablePetInfo(petSlot) ) then
					PetStableFrame.selectedPet = petSlot;
					updateModel = true;
					break;
				end 
			end
		end
	end

	-- Set slot statuseses
	for i=1, NUM_PET_STABLE_SLOTS do
		local button = _G["PetStableStabledPet"..i];
		local petSlot = PetStable_GetPetSlot(i, false);
		PetStable_UpdateSlot(button, petSlot);
	end

	-- Active slots
	for i=1, NUM_PET_ACTIVE_SLOTS do
		local button = _G["PetStableActivePet"..i];
		local petSlot = PetStable_GetPetSlot(i, true);
		PetStable_UpdateSlot(button, petSlot);
		if (IsSpellKnown(CALL_PET_SPELL_IDS[i]) or GetStablePetInfo(petSlot)) then
			button:Enable();
			button.Background:SetDesaturated(nil);
			button.Border:SetDesaturated(nil);
			button.LockIcon:Hide();
		else
			button:Disable();
			button.Background:SetDesaturated(1);
			button.Border:SetDesaturated(1);
			button.LockIcon:Show();
		end
	end
	
 	if ( PetStableFrame.selectedPet ) then
		-- Update selected pet display
		PetStableModel:Show();
		if (updateModel) then
			SetPetStablePaperdoll(PetStableModel, PetStableFrame.selectedPet);
		end
		local icon, name, level, family, talent = GetStablePetInfo(PetStableFrame.selectedPet);
		PetStable_SetSelectedPetInfo(icon, name, level, family, talent);
		
		if ( GetStablePetFoodTypes(PetStableFrame.selectedPet) ) then
			PetStableDiet.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(PetStableFrame.selectedPet)));
			PetStableDiet:Show();
		else
			PetStableDiet:Hide();
		end
	else
 		-- If no selected pet clear everything out
 		PetStableModel:Hide();
 		PetStable_SetSelectedPetInfo();
		PetStableDiet.tooltip = nil;
		PetStableDiet:Hide();
 	end
	
	-- Select correct page
	if (PetStableFrame.page == 1) then
		PetStablePrevPageButton:Disable();
	else
		PetStablePrevPageButton:Enable();
	end
	if (PetStableFrame.page == NUM_PET_STABLE_PAGES) then
		PetStableNextPageButton:Disable();
	else
		PetStableNextPageButton:Enable();
	end
	PetStableCurrentPage:SetFormattedText(MERCHANT_PAGE_NUMBER, PetStableFrame.page, NUM_PET_STABLE_PAGES);
end

function PetStable_PrevPage()
	local page = PetStableFrame.page-1;
	if (page ~= PetStableFrame.page and page > 0 and page <= NUM_PET_STABLE_PAGES) then
		PetStableFrame.page = page;
		PetStable_Update(false);
	end
end

function PetStable_NextPage()
	local page = PetStableFrame.page+1;
	if (page ~= PetStableFrame.page and page > 0 and page <= NUM_PET_STABLE_PAGES) then
		PetStableFrame.page = page;
		PetStable_Update(false);
	end
end

function PetStable_NoPetsAllowed()
	local button;
	for i=1, NUM_PET_STABLE_SLOTS do
		button = _G["PetStableStabledPet"..i];
		button.tooltip = EMPTY_STABLE_SLOT;
		button.Checked:Hide();
	end

	for i =1, NUM_PET_ACTIVE_SLOTS do
		button = _G["PetStableActivePet"..i];
		button.Checked:Hide();
		button.tooltip = EMPTY_STABLE_SLOT;
		SetItemButtonTexture(button, "");
	end	
	
	PetStable_SetSelectedPetInfo();
	PetStableModel:Hide();
end

function PetStableSlot_Lock_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(LOCKED);
	local spellName = GetSpellInfo(CALL_PET_SPELL_IDS[self:GetParent():GetID()]);
	if (spellName and spellName ~= "") then
		GameTooltip:AddLine(format(PET_STABLE_SLOT_LOCKED_TOOLTIP, spellName), 1.0, 1.0, 1.0);
	end
	GameTooltip:Show();
end