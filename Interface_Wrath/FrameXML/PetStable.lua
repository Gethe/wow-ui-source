NUM_PET_STABLE_SLOTS = 4;

function PetStable_OnLoad(self)
	self:RegisterEvent("PET_STABLE_SHOW");
	self:RegisterEvent("PET_STABLE_UPDATE");
	self:RegisterEvent("PET_STABLE_UPDATE_PAPERDOLL");
	self:RegisterEvent("PET_STABLE_CLOSED");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("SPELLS_CHANGED");
end

function PetStable_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "PET_STABLE_SHOW" ) then
		ShowUIPanel(self);
		if ( not self:IsVisible() ) then
			ClosePetStables();
			return;
		end

		PetStable_Update();
	elseif ( event == "PET_STABLE_UPDATE" or 
			event == "SPELLS_CHANGED" or 
			(event == "UNIT_PET" and arg1 == "player") or
			(event == "UNIT_NAME_UPDATE" and arg1 == "pet") ) then
		PetStable_Update();
	elseif ( event == "PET_STABLE_UPDATE_PAPERDOLL" ) then
		-- So warlock pets don't show
		if ( UnitExists("pet") and not HasPetUI() ) then
			PetStable_NoPetsAllowed();
			return;
		end
		SetPetStablePaperdoll(PetStableModel);
	elseif ( event == "PET_STABLE_CLOSED" ) then
		HideUIPanel(self);
		StaticPopup_Hide("CONFIRM_BUY_STABLE_SLOT");
	end
end

function PetStable_Update()
	-- Set stablemaster portrait
	if(IsAtStableMaster()) then
		SetPortraitTexture(PetStableFramePortrait, "npc");
	else
		SetPortraitTexture(PetStableFramePortrait, "player");
	end;
	
	-- So warlock pets don't show
	local _, playerClass = UnitClass("player")
	local hasPetUI, isHunterPet = HasPetUI();
	if ( playerClass ~= "HUNTER" or (UnitExists("pet") and hasPetUI and not isHunterPet) ) then
		PetStable_NoPetsAllowed();
		PetStableCurrentPet:Disable();
		return;
	else
		PetStableCurrentPet:Enable();
	end
	
	-- If no selected pet try to set one
	local selectedPet = GetSelectedStablePet();
	if ( selectedPet == -1 ) then
		if ( GetPetIcon() ) then
			selectedPet = 0;
			ClickStablePet(0);
		else
			for i=0, NUM_PET_STABLE_SLOTS do
				if ( GetStablePetInfo(i) ) then
					selectedPet = i;
					ClickStablePet(i);
					break;
				end 
			end
		end
	end

	-- Set slot cost
	MoneyFrame_Update("PetStableCostMoneyFrame", GetNextStableSlotCost());	

	-- Set slot statuseses
	local numSlots = GetNumStableSlots();
	local numPets = C_StableInfo.GetNumStablePets();
	
	local icon, name, level, family, talent;
	for i=1, NUM_PET_STABLE_SLOTS do
		local button = _G["PetStableStabledPet"..i];
		local background = _G["PetStableStabledPet"..i.."Background"];
		icon, name, level, family, talent = GetStablePetInfo(i);
		SetItemButtonTexture(button, icon);
		if ( i <= GetNumStableSlots() ) then
			background:SetVertexColor(1.0,1.0,1.0);
			button:Enable();
			if ( icon ) then
				button.tooltip = name;
				button.tooltipSubtext = format(STABLE_PET_INFO_TOOLTIP_TEXT, level, family, talent);
			else
				button.tooltip = EMPTY_STABLE_SLOT;
				button.tooltipSubtext = "";
			end
			if ( i == selectedPet ) then
				if ( icon ) then
					button:SetChecked(1);
					PetStableLevelText:SetFormattedText(STABLE_PET_INFO_TEXT, name, level, family, talent);
					SetPetStablePaperdoll(PetStableModel);
					PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(i)));
					if ( not PetStableModel:IsShown() ) then
						PetStableModel:Show();
					end
				else
					button:SetChecked(nil);
					PetStableLevelText:SetText("");
					PetStableModel:Hide();
				end
				
			else
				button:SetChecked(nil);
			end
			if ( GameTooltip:IsOwned(button) ) then
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
				GameTooltip:SetText(button.tooltip);
				GameTooltip:AddLine(button.tooltipSubtext, 1.0, 1.0, 1.0);
				GameTooltip:Show();
			end
		else
			background:SetVertexColor(1.0,0.1,0.1);
			button:Disable();
		end
	end

	-- Current pet slot
	if ( selectedPet == 0 ) then
		if ( UnitExists("pet") ) then
			PetStableCurrentPet:SetChecked(1);
			name = UnitName("pet") or "";
			level = UnitLevel("pet");
			family = UnitCreatureFamily("pet") or "";
			talent = GetPetTalentTree() or "";
			PetStableLevelText:SetFormattedText(STABLE_PET_INFO_TEXT, name, level, family, talent);
			SetPetStablePaperdoll(PetStableModel);
			if ( not PetStableModel:IsShown() ) then
				PetStableModel:Show();
			end
			if ( GetPetFoodTypes() ) then
				PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetPetFoodTypes()));
			end
		elseif ( GetStablePetInfo(0) ) then
			-- If pet doesn't exist it might be dismissed, so check stable slot 0 for current pet info
			PetStableCurrentPet:SetChecked(1);
			icon, name, level, family, talent = GetStablePetInfo(0);
			PetStableLevelText:SetFormattedText(STABLE_PET_INFO_TEXT, name, level, family, talent);
			SetPetStablePaperdoll(PetStableModel);
			if ( not PetStableModel:IsShown() ) then
				PetStableModel:Show();
			end
			if ( GetStablePetFoodTypes(0) ) then
				PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(0)));
			end
		else
			PetStableCurrentPet:SetChecked(nil);
			PetStableLevelText:SetText("");
			PetStableModel:Hide();
		end
	else
		PetStableCurrentPet:SetChecked(nil);
	end
	-- Set tooltip and icon info
	if ( GetPetIcon() ) then
		SetItemButtonTexture(PetStableCurrentPet, GetPetIcon());
		name = UnitName("pet") or "";
		level = UnitLevel("pet");
		family = UnitCreatureFamily("pet") or "";
		talent = GetPetTalentTree() or "";
		PetStableCurrentPet.tooltip = name;
		PetStableCurrentPet.tooltipSubtext = format(STABLE_PET_INFO_TOOLTIP_TEXT, level, family, talent);
	elseif ( GetStablePetInfo(0) ) then
		icon, name, level, family, talent = GetStablePetInfo(0);
		SetItemButtonTexture(PetStableCurrentPet, icon);
		PetStableCurrentPet.tooltip = name;
		PetStableCurrentPet.tooltipSubtext = format(STABLE_PET_INFO_TOOLTIP_TEXT, level, family, talent);
	else
		SetItemButtonTexture(PetStableCurrentPet, "");
		PetStableCurrentPet.tooltip = EMPTY_STABLE_SLOT;
		PetStableCurrentPet.tooltipSubtext = "";
		PetStableCurrentPet:SetChecked(nil);
	end
	if ( GameTooltip:IsOwned(PetStableCurrentPet) ) then
		GameTooltip:SetOwner(PetStableCurrentPet, "ANCHOR_RIGHT");
		GameTooltip:SetText(PetStableCurrentPet.tooltip);
		GameTooltip:AddLine(PetStableCurrentPet.tooltipSubtext, "", 1.0, 1.0, 1.0);
		GameTooltip:Show();
	end
	
	-- If no selected pet clear everything out
 	if ( selectedPet == -1 ) then
 		-- no pet
 		PetStableModel:Hide();
 		PetStableLevelText:SetText("");
 	end
	
	-- Enable, disable, or hide purchase button
	PetStablePurchaseButton:Show();
	if ( GetNumStableSlots() == NUM_PET_STABLE_SLOTS  or (not IsAtStableMaster())) then
		PetStablePurchaseButton:Hide();
		PetStableCostLabel:Hide();
		PetStableCostMoneyFrame:Hide();
		PetStableSlotText:Hide();
	elseif ( GetMoney() >= GetNextStableSlotCost() ) then
		PetStablePurchaseButton:Enable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		PetStableSlotText:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		PetStablePurchaseButton:Disable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		PetStableSlotText:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end
end

function PetStable_NoPetsAllowed()
	local button;
	for i=1, NUM_PET_STABLE_SLOTS do
		button = _G["PetStableStabledPet"..i];
		button.tooltip = EMPTY_STABLE_SLOT;
		button:SetChecked(nil);
	end
	
	PetStableCurrentPet:SetChecked(nil);
	PetStableLevelText:SetText("");
	PetStableModel:Hide();
	SetItemButtonTexture(PetStableCurrentPet, "");
	PetStableCurrentPet.tooltip = EMPTY_STABLE_SLOT;
	PetStableCurrentPet:SetChecked(nil);
	PetStablePurchaseButton:Hide();
	PetStableCostLabel:Hide();
	PetStableCostMoneyFrame:Hide();
	PetStableSlotText:Hide();
end