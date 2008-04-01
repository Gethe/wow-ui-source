NUM_PET_STABLE_SLOTS = 2;

function PetStable_OnLoad()
	this:RegisterEvent("PET_STABLE_SHOW");
	this:RegisterEvent("PET_STABLE_UPDATE");
	this:RegisterEvent("PET_STABLE_UPDATE_PAPERDOLL");
	this:RegisterEvent("PET_STABLE_CLOSED");
	this:RegisterEvent("PLAYER_PET_CHANGED");
end

function PetStable_OnEvent()
	if ( event == "PET_STABLE_SHOW" ) then
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			ClosePetStables();
			return;
		end

		PetStable_Update();
	elseif ( event == "PET_STABLE_UPDATE" or event == "PLAYER_PET_CHANGED" ) then
		PetStable_Update();
	elseif ( event == "PET_STABLE_UPDATE_PAPERDOLL" ) then
		-- So warlock pets don't show
		if ( UnitExists("pet") and not HasPetUI() ) then
			PetStable_NoPetsAllowed();
			return;
		end
		SetPetStablePaperdoll("PetStableModel");
	elseif ( event == "PET_STABLE_CLOSED" ) then
		HideUIPanel(this);
	end
end

function PetStable_Update()
	-- Set stablemaster portrait
	SetPortraitTexture(PetStableFramePortrait, "npc");
	
	-- So warlock pets don't show
	if ( UnitExists("pet") and not HasPetUI() ) then
		PetStable_NoPetsAllowed();
		return;
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
	local numPets = GetNumStablePets();
	
	local button;
	local icon, name, level, family, loyalty;
	for i=1, NUM_PET_STABLE_SLOTS do
		button = getglobal("PetStableStabledPet"..i);
		background = getglobal("PetStableStabledPet"..i.."Background");
		icon, name, level, family, loyalty = GetStablePetInfo(i);
		SetItemButtonTexture(button, icon);
		if ( i <= GetNumStableSlots() ) then
			background:SetVertexColor(1.0,1.0,1.0);
			button:Enable();
			if ( icon ) then
				button.tooltip = name;
				button.tooltipSubtext = format(TEXT(UNIT_LEVEL_TEMPLATE),level).." "..family;
			else
				button.tooltip = EMPTY_STABLE_SLOT;
				button.tooltipSubtext = "";
			end
			if ( i == selectedPet ) then
				if ( icon ) then
					button:SetChecked(1);
					PetStableLevelText:SetText(name.." "..format(TEXT(UNIT_LEVEL_TEMPLATE),level).." "..family);
					PetStableLoyaltyText:SetText(loyalty);
					SetPetStablePaperdoll("PetStableModel");
					PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(i)));
					if ( not PetStableModel:IsShown() ) then
						PetStableModel:Show();
					end
				else
					button:SetChecked(nil);
					PetStableLevelText:SetText("");
					PetStableLoyaltyText:SetText("");
					PetStableModel:Hide();
				end
				
			else
				button:SetChecked(nil);
			end
			if ( GameTooltip:IsOwned(button) ) then
				GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
				GameTooltip:SetText(button.tooltip);
				GameTooltip:AddLine(button.tooltipSubtext, "", 1.0, 1.0, 1.0);
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
			local family = UnitCreatureFamily("pet");
			if ( not family ) then
				family = "";
			end
			PetStableLevelText:SetText(UnitName("pet").." "..format(TEXT(UNIT_LEVEL_TEMPLATE),UnitLevel("pet")).." "..family);
			PetStableLoyaltyText:SetText(GetPetLoyalty());
			SetPetStablePaperdoll("PetStableModel");
			if ( not PetStableModel:IsShown() ) then
				PetStableModel:Show();
			end
			if ( GetPetFoodTypes() ) then
				PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetPetFoodTypes()));
			end
		elseif ( GetStablePetInfo(0) ) then
			-- If pet doesn't exist it might be dismissed, so check stable slot 0 for current pet info
			PetStableCurrentPet:SetChecked(1);
			icon, name, level, family, loyalty = GetStablePetInfo(0);
			PetStableLevelText:SetText(name.." "..format(TEXT(UNIT_LEVEL_TEMPLATE),level).." "..family);
			PetStableLoyaltyText:SetText(loyalty);
			SetPetStablePaperdoll("PetStableModel");
			if ( not PetStableModel:IsShown() ) then
				PetStableModel:Show();
			end
			if ( GetStablePetFoodTypes(0) ) then
				PetStablePetInfo.tooltip = format(PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(0)));
			end
		else
			PetStableCurrentPet:SetChecked(nil);
			PetStableLevelText:SetText("");
			PetStableLoyaltyText:SetText("");
			PetStableModel:Hide();
		end
	else
		PetStableCurrentPet:SetChecked(nil);
	end
	-- Set tooltip and icon info
	if ( GetPetIcon() ) then
		SetItemButtonTexture(PetStableCurrentPet, GetPetIcon());
		PetStableCurrentPet.tooltip = UnitName("pet");
		PetStableCurrentPet.tooltipSubtext = format(TEXT(UNIT_LEVEL_TEMPLATE),UnitLevel("pet")).." "..UnitCreatureFamily("pet");
	elseif ( GetStablePetInfo(0) ) then
		icon, name, level, family, loyalty = GetStablePetInfo(0);
		SetItemButtonTexture(PetStableCurrentPet, icon);
		PetStableCurrentPet.tooltip = name;
		PetStableCurrentPet.tooltipSubtext = format(TEXT(UNIT_LEVEL_TEMPLATE),level).." "..family;
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
 		PetStableLoyaltyText:SetText("");
 	end
	
	-- Enable, disable, or hide purchase button
	PetStablePurchaseButton:Show();
	if ( GetNumStableSlots() == NUM_PET_STABLE_SLOTS ) then
		PetStablePurchaseButton:Hide();
		PetStableCostLabel:Hide();
		PetStableCostMoneyFrame:Hide();
		PetStableSlotText:Hide();
	elseif ( GetMoney() >= GetNextStableSlotCost() ) then
		PetStablePurchaseButton:Enable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		PetStablePurchaseButton:Disable();
		PetStableCostLabel:Show();
		PetStableCostMoneyFrame:Show();
		SetMoneyFrameColor("PetStableCostMoneyFrame", RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	end
end

function PetStable_NoPetsAllowed()
	for i=1, NUM_PET_STABLE_SLOTS do
		button = getglobal("PetStableStabledPet"..i);
		button.tooltip = EMPTY_STABLE_SLOT;
		button:SetChecked(nil);
	end
	
	PetStableCurrentPet:SetChecked(nil);
	PetStableLevelText:SetText("");
	PetStableLoyaltyText:SetText("");
	PetStableModel:Hide();
	SetItemButtonTexture(PetStableCurrentPet, "");
	PetStableCurrentPet.tooltip = EMPTY_STABLE_SLOT;
	PetStableCurrentPet:SetChecked(nil);
	PetStablePurchaseButton:Hide();
	PetStableCostLabel:Hide();
	PetStableCostMoneyFrame:Hide();
	PetStableSlotText:Hide();
end