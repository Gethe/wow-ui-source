NUM_PET_RESISTANCE_TYPES = 5;
NUM_PET_STATS = 5;

PETPAPERDOLL_STATCATEGORY_DEFAULTORDER = {
	"GENERAL",
	"MELEE",
	"SPELL",
	"DEFENSE",
};

function PetPaperDollFrame_OnLoad (self)
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_UI_CLOSE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("UNIT_RESISTANCES");
	self:RegisterEvent("UNIT_STATS");
	self:RegisterEvent("UNIT_DAMAGE");
	self:RegisterEvent("UNIT_RANGEDDAMAGE");
	self:RegisterEvent("UNIT_ATTACK_SPEED");
	self:RegisterEvent("UNIT_ATTACK_POWER");
	self:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
	self:RegisterEvent("UNIT_DEFENSE");
	self:RegisterEvent("UNIT_ATTACK");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PET_SPELL_POWER_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
end

function PetPaperDollFrame_UpdateIsAvailable()
	if ( (not HasPetUI()) ) then
		PetPaperDollFrame.hidden = true;
		CharacterFrameTab2:Hide();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "LEFT", 0, 0);
		if ( PetPaperDollFrame:IsVisible() ) then --We have the pet frame selected, but nothing to show on it
			ToggleCharacter("PaperDollFrame");
		end
	else
		PetPaperDollFrame.hidden = false;
		CharacterFrameTab2:Show();
		CharacterFrameTab3:SetPoint("LEFT", "CharacterFrameTab2", "RIGHT", -16, 0);
	end
end

-- This makes sure the update only happens once at the end of the frame
function PetPaperDollFrame_QueuedUpdate(self)
	self:SetScript("OnUpdate", nil);
	PetPaperDollFrame_Update();
end

function PetPaperDollFrame_OnEvent (self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "PET_UI_UPDATE" or event == "PET_UI_CLOSE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") or
		(event == "UNIT_NAME_UPDATE" and arg1 == "pet") ) then
		if (self:IsVisible()) then
			self:SetScript("OnUpdate", PetPaperDollFrame_QueuedUpdate);
		else
			PetPaperDollFrame_UpdateIsAvailable();
		end
	elseif( event == "PET_SPELL_POWER_UPDATE" ) then
		if (self:IsVisible()) then
			self:SetScript("OnUpdate", PetPaperDollFrame_QueuedUpdate);
		end
	elseif (event == "VARIABLES_LOADED") then
		if (self:IsVisible()) then
			if (GetCVar("characterFrameCollapsed") ~= "0") then
				CharacterFrame_Collapse();
			else
				CharacterFrame_Expand();
			end
			PaperDoll_InitStatCategories(PETPAPERDOLL_STATCATEGORY_DEFAULTORDER, "petStatCategoryOrder", "petStatCategoriesCollapsed", "pet");
		end
		PetPaperDollFrame_UpdateIsAvailable();
	elseif ( arg1 == "pet" ) then
		if (self:IsVisible()) then
			self:SetScript("OnUpdate", PetPaperDollFrame_QueuedUpdate);
		else
			PetPaperDollFrame_UpdateIsAvailable();
		end
	end
end

PetPaperDollFrame_BeenViewed = false;
function PetPaperDollFrame_OnShow(self)
	if ( self:IsVisible() ) then
		PetPaperDollFrame_BeenViewed = true;
	end
	SetButtonPulse(CharacterFrameTab2, 0, 1);	--Stop the button pulse
	
	if (GetCVar("characterFrameCollapsed") ~= "0") then
		CharacterFrame_Collapse();
	else
		CharacterFrame_Expand();
	end
	CharacterFrameExpandButton:Show();
	CharacterFrameExpandButton.collapseTooltip = PET_STATS_COLLAPSE_TOOLTIP;
	CharacterFrameExpandButton.expandTooltip = PET_STATS_EXPAND_TOOLTIP;
	
	local hasPetUI, canGainXP = HasPetUI();
	if ( hasPetUI ) then --We've already decided that we're going to be hidden, but it hasn't happened yet.
		PaperDoll_InitStatCategories(PETPAPERDOLL_STATCATEGORY_DEFAULTORDER, "petStatCategoryOrder", "petStatCategoriesCollapsed", "pet");
	end
	
	PetPaperDollFrame_Update();
end

function PetPaperDollFrame_OnHide()
	CharacterFrame_Collapse();
	CharacterFrameExpandButton:Hide();
end

function PetPaperDollFrame_Update()
	local hasPetUI, canGainXP = HasPetUI();
	PetPaperDollFrame_UpdateIsAvailable();
	if ( not hasPetUI ) then
		return;
	end
	PetModelFrame:SetUnit("pet");
	if ( UnitCreatureFamily("pet") ) then
		PetLevelText:SetFormattedText(UNIT_TYPE_LEVEL_TEMPLATE,UnitLevel("pet"),UnitCreatureFamily("pet"));
	end
	CharacterFrameTitleText:SetText(UnitName("pet"));
	PaperDollFrame_UpdateStats();
	
	local _, playerClass = UnitClass("player");
	if (playerClass == "HUNTER") then
		PetPaperDollPetModelBg:Show();
		PetPaperDollPetModelBg:SetTexture("Interface\\PetPaperDollFrame\\PetStatsBG-Hunter");
	elseif (playerClass == "WARLOCK") then
		PetPaperDollPetModelBg:Show();
		PetPaperDollPetModelBg:SetTexture("Interface\\PetPaperDollFrame\\PetStatsBG-Warlock");
	elseif (playerClass == "MAGE") then
		PetPaperDollPetModelBg:Show();
		PetPaperDollPetModelBg:SetTexture("Interface\\PetPaperDollFrame\\PetStatsBG-Mage");
	elseif (playerClass == "DEATHKNIGHT") then
		PetPaperDollPetModelBg:Show();
		PetPaperDollPetModelBg:SetTexture("Interface\\PetPaperDollFrame\\PetStatsBG-DeathKnight");
	else
		PetPaperDollPetModelBg:Hide();
	end

	if ( canGainXP ) then
		PetPaperDollPetInfo:Show();
	else
		PetPaperDollPetInfo:Hide();
	end
end
