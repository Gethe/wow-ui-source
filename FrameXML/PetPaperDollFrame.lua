NUM_PET_RESISTANCE_TYPES = 5;
NUM_PET_STATS = 5;
NUM_COMPANIONS_PER_PAGE = 12;

function PetPaperDollFrame_OnLoad (self)
	self:RegisterEvent("PET_UI_UPDATE");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("PET_UI_CLOSE");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("UNIT_PET_EXPERIENCE");
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
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("PET_SPELL_POWER_UPDATE");

	PetPaperDollFrameCompanionFrame.mode = "CRITTER";
	PetPaperDollFrameCompanionFrame.idMount = GetCompanionInfo("MOUNT", 1);
	PetPaperDollFrameCompanionFrame.pageMount = 0;
	PetPaperDollFrameCompanionFrame.idCritter = GetCompanionInfo("CRITTER", 1);
	PetPaperDollFrameCompanionFrame.pageCritter = 0;

	PetDamageFrameLabel:SetText(format(STAT_FORMAT, DAMAGE));
	PetAttackPowerFrameLabel:SetText(format(STAT_FORMAT, ATTACK_POWER));
	PetArmorFrameLabel:SetText(format(STAT_FORMAT, ARMOR));
	SetTextStatusBarTextPrefix(PetPaperDollFrameExpBar, XP);
	PetSpellDamageFrameLabel:SetText(format(STAT_FORMAT, SPELL_BONUS));
end

local tabPoints={
	[1]={ point="TOPLEFT", relativeTo="PetPaperDollFrameCompanionFrame", relativePoint="TOPLEFT", xoffset=70, yoffset=-39},
	[2]={ point="LEFT", relativePoint="RIGHT", xoffset=0, yoffset=0},
	[3]={ point="LEFT", relativePoint="RIGHT", xoffset=0, yoffset=0},
}

function PetPaperDollFrame_UpdateIsAvailable()
	if ( (not HasPetUI()) and (GetNumCompanions("CRITTER") == 0) and (GetNumCompanions("MOUNT") == 0) ) then
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

function PetPaperDollFrame_UpdateTabs()
	if ( not PetPaperDollFrame:IsVisible() ) then
		-- There's no need to run this when the frame isn't shown (i.e. we're zoning), it causes problems with the subtabs (bug 145137)
		PetPaperDollFrame_UpdateIsAvailable(); --But we still need to update the tabs on the CharacterFrame (bug 150500)
		return;
	end
		
	local currVal, currRef = 1, tabPoints[1];

	--PetPaperDollFrameTab1:ClearAllPoints()	--Never moved, just hidden
	PetPaperDollFrameTab2:ClearAllPoints()
	PetPaperDollFrameTab3:ClearAllPoints()
	if ( HasPetUI() ) then
		PetPaperDollFrameTab1:Show();
		PetPaperDollFrameTab1:SetPoint(currRef.point, currRef.relativeTo, currRef.relativePoint, currRef.xoffset, currRef.yoffset)
		currVal = currVal + 1;
		currRef = tabPoints[currVal];
		currRef.relativeTo = PetPaperDollFrameTab1;
	else
		PetPaperDollFrameTab1:Hide();
	end
	
	if ( GetNumCompanions("CRITTER") > 0 ) then
		PetPaperDollFrameTab2:Show();
		PetPaperDollFrameTab2:SetPoint(currRef.point, currRef.relativeTo, currRef.relativePoint, currRef.xoffset, currRef.yoffset);
		currVal = currVal + 1;
		currRef = tabPoints[currVal];
		currRef.relativeTo = PetPaperDollFrameTab2;
	else
		PetPaperDollFrameTab2:Hide();
	end
	
	if ( GetNumCompanions("MOUNT") > 0 ) then
		PetPaperDollFrameTab3:Show();
		PetPaperDollFrameTab3:SetPoint(currRef.point, currRef.relativeTo, currRef.relativePoint, currRef.xoffset, currRef.yoffset);
		currVal = currVal + 1;
	else
		PetPaperDollFrameTab3:Hide();
	end
	
	PetPaperDollFrame_UpdateIsAvailable();
	
	local selectedTab = PanelTemplates_GetSelectedTab(PetPaperDollFrame);
	if ( (not PetPaperDollFrame.selectedTab) or (not PetPaperDollFrame_BeenViewed) or (not _G["PetPaperDollFrameTab"..selectedTab]:IsShown()) ) then
		if ( PetPaperDollFrameTab1:IsShown() ) then
			PetPaperDollFrame_SetTab(1);
		elseif ( PetPaperDollFrameTab2:IsShown() ) then
			PetPaperDollFrame_SetTab(2);
		elseif ( PetPaperDollFrameTab3:IsShown() ) then
			PetPaperDollFrame_SetTab(3);
		else
			if ( PetPaperDollFrame:IsVisible() ) then
				ToggleCharacter("PaperDollFrame");
			end
		end
	end
	
	if ( currVal == 2 ) then --Only 1 tab shown, so no reason to make it visible.
		PetPaperDollFrameTab1:Hide();
		PetPaperDollFrameTab2:Hide();
		PetPaperDollFrameTab3:Hide();
	end
end

function PetPaperDollFrame_OnEvent (self, event, ...)
	local arg1 = ...;
	if ( event == "PET_UI_UPDATE" or event == "PET_UI_CLOSE" or event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") or
		(event == "UNIT_NAME_UPDATE" and arg1 == "pet") ) then
		PetPaperDollFrame_UpdateTabs();
		PetPaperDollFrame_Update();
	elseif ( event == "UNIT_PET_EXPERIENCE" ) then
		PetExpBar_Update();
	elseif ( event == "COMPANION_LEARNED" ) then
		if ( not CharacterFrame:IsVisible() ) then
			SetButtonPulse(CharacterMicroButton, 60, 1);
		end
		if ( not PetPaperDollFrame:IsVisible() ) then
			SetButtonPulse(CharacterFrameTab2, 60, 1);
		end
		PetPaperDollFrame_UpdateTabs();
		--PetPaperDollFrame_UpdateCompanions();	--This is called in SetCompanionPage
		PetPaperDollFrame_SetCompanionPage((PetPaperDollFrameCompanionFrame.mode=="MOUNT") and PetPaperDollFrameCompanionFrame.pageMount or PetPaperDollFrameCompanionFrame.pageCritter);
	elseif ( event == "COMPANION_UNLEARNED" ) then
		local page;
		local numCompanions = GetNumCompanions(PetPaperDollFrameCompanionFrame.mode);
		if ( PetPaperDollFrameCompanionFrame.mode=="MOUNT" ) then
			page = PetPaperDollFrameCompanionFrame.pageMount;
			if ( numCompanions > 0 ) then
				PetPaperDollFrameCompanionFrame.idMount = GetCompanionInfo("MOUNT", 1);
				PetPaperDollFrame_UpdateCompanionPreview();
			else
				PetPaperDollFrameCompanionFrame.idMount = nil;
			end
		else
			page = PetPaperDollFrameCompanionFrame.pageCritter;
			if ( numCompanions > 0 ) then
				PetPaperDollFrameCompanionFrame.idCritter = GetCompanionInfo("CRITTER", 1);
				PetPaperDollFrame_UpdateCompanionPreview()
			else
				PetPaperDollFrameCompanionFrame.idCritter = nil;
			end
		end
		page = min(ceil(numCompanions/NUM_COMPANIONS_PER_PAGE) - 1, page);
		page = max(page, 0);
		PetPaperDollFrame_SetCompanionPage(page);	-- The pages are 0 based to make the mathematical calculations slightly faster.
		PetPaperDollFrame_UpdateTabs();
	elseif ( event == "COMPANION_UPDATE" ) then
		if ( not PetPaperDollFrameCompanionFrame.idMount ) then
			PetPaperDollFrameCompanionFrame.idMount = GetCompanionInfo("MOUNT", 1);
		end
		if ( not PetPaperDollFrameCompanionFrame.idCritter ) then
			PetPaperDollFrameCompanionFrame.idCritter = GetCompanionInfo("CRITTER", 1);
		end
		PetPaperDollFrame_UpdateCompanions();
	elseif ( event == "SPELL_UPDATE_COOLDOWN" ) then
		if ( self:IsVisible() ) then
			PetPaperDollFrame_UpdateCompanionCooldowns();
		end
	elseif( event == "PET_SPELL_POWER_UPDATE" ) then
		PetPaperDollFrame_SetSpellBonusDamage();
	elseif ( (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) then
		PetPaperDollFrame_UpdateCompanions();
	elseif ( arg1 == "pet" ) then
		PetPaperDollFrame_Update();
	end
end

function PetPaperDollFrame_SetTab(id)
	if ( (id == 1) and HasPetUI() ) then	--Pet Tab
		PetPaperDollFrame.selectedTab=1;
		PetPaperDollFramePetFrame:Show();
		PetPaperDollFrameCompanionFrame:Hide();
		PetNameText:SetText(UnitName("pet"));
	elseif ( (id == 2) and (GetNumCompanions("CRITTER") > 0) ) then	--Critter Tab
		PetPaperDollFrame.selectedTab=2;
		PetPaperDollFrameCompanionFrame.mode="CRITTER";
		PetPaperDollFramePetFrame:Hide();
		PetPaperDollFrameCompanionFrame:Show();
		PetPaperDollFrame_SetCompanionPage(PetPaperDollFrameCompanionFrame.pageCritter);
		for i=1,NUM_COMPANIONS_PER_PAGE do
			_G["CompanionButton"..i]:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Companions]])
		end
		PetPaperDollFrame_UpdateCompanions();
		PetPaperDollFrame_UpdateCompanionPreview();
		PetNameText:SetText(COMPANIONS);
	elseif ( (id == 3) and (GetNumCompanions("MOUNT") > 0) ) then	--Mount Tab
		PetPaperDollFrame.selectedTab=3;
		PetPaperDollFrameCompanionFrame.mode="MOUNT";
		PetPaperDollFramePetFrame:Hide();
		PetPaperDollFrameCompanionFrame:Show();
		PetPaperDollFrame_SetCompanionPage(PetPaperDollFrameCompanionFrame.pageMount);
		for i=1,NUM_COMPANIONS_PER_PAGE do
			_G["CompanionButton"..i]:SetDisabledTexture([[Interface\PetPaperDollFrame\UI-PetFrame-Slots-Mounts]]);
		end
		PetPaperDollFrame_UpdateCompanions();
		PetPaperDollFrame_UpdateCompanionPreview();
		PetNameText:SetText(MOUNTS);
	end
	
	for i=1,3 do
		if ( i == id ) then
			PanelTemplates_SelectTab(_G["PetPaperDollFrameTab"..i]);
		else
			PanelTemplates_DeselectTab(_G["PetPaperDollFrameTab"..i]);
		end
	end
end

function PetPaperDollFrame_FindCompanionIndex(creatureID, mode)
	if ( not mode ) then
		mode = PetPaperDollFrameCompanionFrame.mode;
	end
	if (not creatureID ) then
		creatureID = (PetPaperDollFrameCompanionFrame.mode=="MOUNT") and PetPaperDollFrameCompanionFrame.idMount or PetPaperDollFrameCompanionFrame.idCritter;
	end
	for i=1,GetNumCompanions(mode) do
		if ( GetCompanionInfo(mode, i) == creatureID ) then
			return i;
		end
	end
	return 0
end

function CompanionSummonButton_OnClick()
	local selected = PetPaperDollFrame_FindCompanionIndex();
	local creatureID, creatureName, spellID, icon, active = GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected);
	if ( active ) then
		DismissCompanion(PetPaperDollFrameCompanionFrame.mode);
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		CallCompanion(PetPaperDollFrameCompanionFrame.mode, selected);
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
end

function CompanionButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CompanionButton_OnDrag(self)
	local offset;
	
	if ( PetPaperDollFrameCompanionFrame.mode=="CRITTER" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageCritter or 0)*NUM_COMPANIONS_PER_PAGE;
	elseif ( PetPaperDollFrameCompanionFrame.mode=="MOUNT" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageMount or 0)*NUM_COMPANIONS_PER_PAGE;
	end
	local dragged = self:GetID() + offset;
	PickupCompanion( PetPaperDollFrameCompanionFrame.mode, dragged );
end

function CompanionButton_OnClick(self, button)
	local selected, selectedID;
	if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
		selected = PetPaperDollFrame_FindCompanionIndex(PetPaperDollFrameCompanionFrame.idCritter);
		selectedID = PetPaperDollFrameCompanionFrame.idCritter;
	elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
		selected = PetPaperDollFrame_FindCompanionIndex(PetPaperDollFrameCompanionFrame.idMount);
		selectedID = PetPaperDollFrameCompanionFrame.idMount;
	end

	if ( button ~= "LeftButton" or ( selectedID == self.creatureID) ) then
		local offset;
		if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
			offset = (PetPaperDollFrameCompanionFrame.pageCritter or 0) * NUM_COMPANIONS_PER_PAGE;
		elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
			offset = (PetPaperDollFrameCompanionFrame.pageMount or 0) * NUM_COMPANIONS_PER_PAGE;
		end
		local index = self:GetID() + offset;
		if ( self.active ) then
			DismissCompanion(PetPaperDollFrameCompanionFrame.mode);
		else
			CallCompanion(PetPaperDollFrameCompanionFrame.mode, index);
		end
	else
		if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
			PetPaperDollFrameCompanionFrame.idCritter = self.creatureID;
			PetPaperDollFrame_UpdateCompanionPreview();
		elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
			PetPaperDollFrameCompanionFrame.idMount = self.creatureID;
			PetPaperDollFrame_UpdateCompanionPreview();
		end
	end
	
	PetPaperDollFrame_UpdateCompanions();
end

function CompanionButton_OnModifiedClick(self)
	local id = self.spellID;
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink);
		end
	elseif ( IsModifiedClick("PICKUPACTION") ) then
		CompanionButton_OnDrag(self);
	end
	PetPaperDollFrame_UpdateCompanions();	--Set up the highlights again
end
function CompanionButton_OnEnter(self)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	end

	if ( GameTooltip:SetHyperlink("spell:"..self.spellID) ) then
		self.UpdateTooltip = CompanionButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
	
	GameTooltip:Show()
end

function PetPaperDollFrame_SetCompanionPage(num)
	if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
		PetPaperDollFrameCompanionFrame.pageCritter = num;
	elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
		PetPaperDollFrameCompanionFrame.pageMount = num;
	end
	
	num = num + 1;	--For easier usage
	local maxpage = ceil(GetNumCompanions(PetPaperDollFrameCompanionFrame.mode)/NUM_COMPANIONS_PER_PAGE);
	CompanionPageNumber:SetFormattedText(MERCHANT_PAGE_NUMBER,num, maxpage);
	if ( num <= 1 ) then
		CompanionPrevPageButton:Disable();
	else
		CompanionPrevPageButton:Enable();
	end
	if ( num >= maxpage ) then
		CompanionNextPageButton:Disable();
	else
		CompanionNextPageButton:Enable();
	end
	PetPaperDollFrame_UpdateCompanions();
	PetPaperDollFrame_UpdateCompanionCooldowns();
end

function PetPaperDollFrame_UpdateCompanions()
	local button, iconTexture, id;
	local creatureID, creatureName, spellID, icon, active;
	local offset, selected;
	
	if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageCritter or 0)*NUM_COMPANIONS_PER_PAGE;
		selected = PetPaperDollFrame_FindCompanionIndex(PetPaperDollFrameCompanionFrame.idCritter);
	elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageMount or 0)*NUM_COMPANIONS_PER_PAGE;
		selected = PetPaperDollFrame_FindCompanionIndex(PetPaperDollFrameCompanionFrame.idMount);
	end

	for i = 1, NUM_COMPANIONS_PER_PAGE do
		button = _G["CompanionButton"..i];
		id = i + (offset or 0);
		creatureID, creatureName, spellID, icon, active = GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, id);
		button.creatureID = creatureID;
		button.spellID = spellID;
		button.active = active;
		if ( creatureID ) then
			button:SetNormalTexture(icon);
			button:Enable();
		else
			button:Disable();
		end
		if ( (id == selected) and creatureID ) then
			button:SetChecked(true);
		else
			button:SetChecked(false);
		end
		
		if ( active ) then
			_G["CompanionButton"..i.."ActiveTexture"]:Show();
		else
			_G["CompanionButton"..i.."ActiveTexture"]:Hide();
		end
	end
	
	if ( selected > 0 ) then
		creatureID, creatureName, spellID, icon, active = GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected);
		if ( active and creatureID ) then
			CompanionSummonButton:SetText(PetPaperDollFrameCompanionFrame.mode == "MOUNT" and BINDING_NAME_DISMOUNT or PET_DISMISS);
		else
			CompanionSummonButton:SetText(PetPaperDollFrameCompanionFrame.mode == "MOUNT" and MOUNT or SUMMON);
		end
	end
end

function PetPaperDollFrame_UpdateCompanionCooldowns()
	local offset;
	if ( PetPaperDollFrameCompanionFrame.mode == "CRITTER" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageCritter or 0)*NUM_COMPANIONS_PER_PAGE;
	elseif ( PetPaperDollFrameCompanionFrame.mode == "MOUNT" ) then
		offset = (PetPaperDollFrameCompanionFrame.pageMount or 0)*NUM_COMPANIONS_PER_PAGE;
	end
	for i = 1, NUM_COMPANIONS_PER_PAGE do
		local button = _G["CompanionButton"..i];
		local cooldown = _G[button:GetName().."Cooldown"];
		if ( button.creatureID ) then
			local start, duration, enable = GetCompanionCooldown(PetPaperDollFrameCompanionFrame.mode, offset + button:GetID());
			if ( start and duration and enable ) then
				CooldownFrame_SetTimer(cooldown, start, duration, enable);
			end
		else
			cooldown:Hide();
		end
	end
end

function PetPaperDollFrame_UpdateCompanionPreview()
	local selected = PetPaperDollFrame_FindCompanionIndex();
	
	if (selected > 0) then
		local creatureID, creatureName = GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected);
		CompanionModelFrame:SetCreature(creatureID);
		CompanionSelectedName:SetText(creatureName);
	end
end

PetPaperDollFrame_BeenViewed = false;
function PetPaperDollFrame_OnShow(self)
	if ( self:IsVisible() ) then
		PetPaperDollFrame_BeenViewed = true;
	end
	SetButtonPulse(CharacterFrameTab2, 0, 1);	--Stop the button pulse
	CharacterNameText:Hide();
	PetNameText:Show();
	PetPaperDollFrame_Update();
	PetPaperDollFrame_UpdateTabs();
end

function PetPaperDollFrame_OnHide()
	CharacterNameText:Show();
	PetNameText:Hide();
end

function PetPaperDollFrame_Update()
	local hasPetUI, canGainXP = HasPetUI();
	if ( not hasPetUI ) then
		return;
	end
	PetModelFrame:SetUnit("pet");
	if ( UnitCreatureFamily("pet") ) then
		PetLevelText:SetFormattedText(UNIT_TYPE_LEVEL_TEMPLATE,UnitLevel("pet"),UnitCreatureFamily("pet"));
	end
	if ( PetPaperDollFramePetFrame:IsShown() ) then
		PetNameText:SetText(UnitName("pet"));
	end
	PetExpBar_Update();
	PetPaperDollFrame_SetResistances();
	PetPaperDollFrame_SetStats();
	PaperDollFrame_SetDamage(PetDamageFrame, "Pet");
	PaperDollFrame_SetArmor(PetArmorFrame, "Pet");
	PaperDollFrame_SetAttackPower(PetAttackPowerFrame, "Pet");
	PetPaperDollFrame_SetSpellBonusDamage();

	if ( canGainXP ) then
		PetPaperDollPetInfo:Show();
	else
		PetPaperDollPetInfo:Hide();
	end
end

function PetPaperDollFrame_SetResistances()
	local resistance;
	local positive;
	local negative;
	local base;
	local index;
	local text;
	local frame;
	for i=1, NUM_PET_RESISTANCE_TYPES, 1 do
		index = i + 1;
		if ( i == NUM_PET_RESISTANCE_TYPES ) then
			index = 1;
		end
		text = _G["PetMagicResText"..i];
		frame = _G["PetMagicResFrame"..i];
		
		base, resistance, positive, negative = UnitResistance("pet", frame:GetID());

		frame.tooltip = _G["RESISTANCE"..frame:GetID().."_NAME"];
	
		-- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
		if( resistance < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		elseif( resistance == 0 ) then
			text:SetText(resistance);
		else
			text:SetText(GREEN_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
		end

		if ( positive ~= 0 or negative ~= 0 ) then
			-- Otherwise build up the formula
			frame.tooltip = frame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
			if( positive > 0 ) then
				frame.tooltip = frame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
			end
			if( negative < 0 ) then
				frame.tooltip = frame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
			end
			frame.tooltip = frame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
		end
	end
end

function PetPaperDollFrame_SetStats()
	for i=1, NUM_PET_STATS, 1 do
		local label = _G["PetStatFrame"..i.."Label"];
		local text = _G["PetStatFrame"..i.."StatText"];
		local frame = _G["PetStatFrame"..i];
		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		label:SetText(format(STAT_FORMAT, _G["SPELL_STAT"..i.."_NAME"]));
		stat, effectiveStat, posBuff, negBuff = UnitStat("pet", i);
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, _G["SPELL_STAT"..i.."_NAME"]).." ";

		if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
			text:SetText(effectiveStat);
			frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
		else 
			tooltipText = tooltipText..effectiveStat;
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 ) then
				tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( negBuff < 0 ) then
				tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
			end
			frame.tooltip = tooltipText;

			-- If there are any negative buffs then show the main number in red even if there are
			-- positive buffs. Otherwise show in green.
			if ( negBuff < 0 ) then
				text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			else
				text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			end
		end
		
		-- Second tooltip line
		frame.tooltip2 = _G["DEFAULT_STAT"..i.."_TOOLTIP"];
		if ( i == 1 ) then
			local attackPower = effectiveStat-20;
			frame.tooltip2 = format(frame.tooltip2, attackPower);
		elseif ( i == 2 ) then
			local newLineIndex = strfind(frame.tooltip2, "|n")+1;
			frame.tooltip2 = strsub(frame.tooltip2, 1, newLineIndex);
			frame.tooltip2 = format(frame.tooltip2, GetCritChanceFromAgility("pet"));
		elseif ( i == 3 ) then
			local expectedHealthGain = (((stat - posBuff - negBuff)-20)*10+20)*GetUnitHealthModifier("pet");
			local realHealthGain = ((effectiveStat-20)*10+20)*GetUnitHealthModifier("pet");
			local healthGain = (realHealthGain - expectedHealthGain)*GetUnitMaxHealthModifier("pet");
			frame.tooltip2 = format(frame.tooltip2, healthGain);
		elseif ( i == 4 ) then
			if ( UnitHasMana("pet") ) then
				local manaGain = ((effectiveStat-20)*15+20)*GetUnitPowerModifier("pet");
				frame.tooltip2 = format(frame.tooltip2, manaGain, GetSpellCritChanceFromIntellect("pet"));
			else
				local newLineIndex = strfind(frame.tooltip2, "|n")+2;
				frame.tooltip2 = strsub(frame.tooltip2, newLineIndex);
				frame.tooltip2 = format(frame.tooltip2, GetSpellCritChanceFromIntellect("pet"));
			end
		elseif ( i == 5 ) then
			frame.tooltip2 = format(frame.tooltip2, GetUnitHealthRegenRateFromSpirit("pet"));
			if ( UnitHasMana("pet") ) then
				frame.tooltip2 = frame.tooltip2.."\n"..format(MANA_REGEN_FROM_SPIRIT, GetUnitManaRegenRateFromSpirit("pet"));
			end
		end
	end
end

function PetPaperDollFrame_SetSpellBonusDamage()
	local spellDamageBonus = GetPetSpellBonusDamage();
	local spellDamageBonusText = format("%d",spellDamageBonus);

	PetSpellDamageFrameLabel:SetText(format(STAT_FORMAT, SPELL_BONUS));
	if ( spellDamageBonus > 0 ) then
		spellDamageBonusText = GREEN_FONT_COLOR_CODE.."+"..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
	elseif( spellDamageBonus < 0 ) then
		spellDamageBonusText = RED_FONT_COLOR_CODE..spellDamageBonusText..FONT_COLOR_CODE_CLOSE;
	end

	PetSpellDamageFrameStatText:SetText(spellDamageBonusText);
	PetSpellDamageFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPELL_BONUS)..FONT_COLOR_CODE_CLOSE.." "..spellDamageBonusText;
	PetSpellDamageFrame.tooltip2 = DEFAULT_STATSPELLBONUS_TOOLTIP;

	PetSpellDamageFrame:Show();
end

function PetExpBar_Update()
	local currXP, nextXP = GetPetExperience();
	PetPaperDollFrameExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	PetPaperDollFrameExpBar:SetValue(currXP);
end
