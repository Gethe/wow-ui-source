PETACTIONBAR_SLIDETIME = 0.09;
PETACTIONBAR_YPOS = 98;
PETACTIONBAR_XPOS = 36;
NUM_PET_ACTION_SLOTS = 10;

PET_DEFENSIVE_TEXTURE = "Interface\\Icons\\Ability_Defend";
PET_AGGRESSIVE_TEXTURE = "Interface\\Icons\\Ability_Racial_BloodRage";
PET_PASSIVE_TEXTURE = "Interface\\Icons\\Ability_Seal";
PET_ATTACK_TEXTURE = "Interface\\Icons\\Ability_GhoulFrenzy";
PET_FOLLOW_TEXTURE = "Interface\\Icons\\Ability_Tracking";
PET_WAIT_TEXTURE = "Interface\\Icons\\Spell_Nature_TimeStop";
PET_DISMISS_TEXTURE = "Interface\\Icons\\Spell_Shadow_Teleport";

function PetActionBar_OnLoad()
	this:RegisterEvent("PLAYER_CONTROL_LOST");
	this:RegisterEvent("PLAYER_CONTROL_GAINED");
	this:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED");
	this:RegisterEvent("UNIT_PET");
	this:RegisterEvent("UNIT_FLAGS");
	this:RegisterEvent("UNIT_AURA");
	this:RegisterEvent("PET_BAR_UPDATE");
	this:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
	this:RegisterEvent("PET_BAR_SHOWGRID");
	this:RegisterEvent("PET_BAR_HIDEGRID");
	this.showgrid = 0;
	PetActionBar_Update();
	if ( PetHasActionBar() ) then
		ShowPetActionBar();
		LockPetActionBar();
	end
end

function PetActionBar_OnEvent()
	if ( event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player") ) then
		PetActionBar_Update();
		if ( PetHasActionBar() ) then
			ShowPetActionBar();
			LockPetActionBar();
		else
			UnlockPetActionBar();
			HidePetActionBar();
		end
	elseif ( event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" ) then
		PetActionBar_Update();
	elseif ( (event == "UNIT_FLAGS") or (event == "UNIT_AURA") ) then
		if ( arg1 == "pet" ) then
			PetActionBar_Update();
		end
	elseif ( event =="PET_BAR_UPDATE_COOLDOWN" ) then
		PetActionBar_UpdateCooldowns();
	elseif ( event =="PET_BAR_SHOWGRID" ) then
		PetActionBar_ShowGrid();
	elseif ( event =="PET_BAR_HIDEGRID" ) then
		PetActionBar_HideGrid();
	end
end

function PetActionBarFrame_OnUpdate(elapsed)
	local yPos;
	if ( this.slideTimer and (this.slideTimer < this.timeToSlide) ) then
		this.completed = nil;
		if ( this.mode == "show" ) then
			yPos = (this.slideTimer/this.timeToSlide) * this.yTarget;
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, yPos);
			this.state = "showing";
			this:Show();
		elseif ( this.mode == "hide" ) then
			yPos = (1 - (this.slideTimer/this.timeToSlide)) * this.yTarget;
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, yPos);
			this.state = "hiding";
		end
		this.slideTimer = this.slideTimer + elapsed;
	else
		this.completed = 1;
		if ( this.mode == "show" ) then
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, this.yTarget);
			this.state = "top";
			--Move the chat frame and edit box up a bit
		elseif ( this.mode == "hide" ) then
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", PETACTIONBAR_XPOS, 0);
			this.state = "bottom";
			this:Hide();
			--Move the chat frame and edit box back down to original position
		end
		this.mode = "none";
	end
end

function PetActionBar_Update()
	local petActionButton, petActionIcon;
	local petActionsUsable = GetPetActionsUsable();
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		petActionButton = getglobal("PetActionButton"..i);
		petActionIcon = getglobal("PetActionButton"..i.."Icon");
		petAutoCastableTexture = getglobal("PetActionButton"..i.."AutoCastable");
		petAutoCastModel = getglobal("PetActionButton"..i.."AutoCast");
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i);
		if ( not isToken ) then
			petActionIcon:SetTexture(texture);
			petActionButton.tooltipName = name;
		else
			petActionIcon:SetTexture(getglobal(texture));
			petActionButton.tooltipName = TEXT(getglobal(name));
		end
		petActionButton.isToken = isToken;
		petActionButton.tooltipSubtext = subtext;
		if ( isActive ) then
			petActionButton:SetChecked(1);
		else
			petActionButton:SetChecked(0);
		end
		if ( autoCastAllowed ) then
			petAutoCastableTexture:Show();
		else
			petAutoCastableTexture:Hide();
		end
		if ( autoCastEnabled ) then
			petAutoCastModel:Show();
		else
			petAutoCastModel:Hide();
		end
		if ( name ) then
			petActionButton:Show();
		else
			if ( PetActionBarFrame.showgrid == 0 ) then
				petActionButton:Hide();
			end
		end
		if ( texture ) then
			if ( petActionsUsable ) then
				SetDesaturation(petActionIcon, nil);
			else
				SetDesaturation(petActionIcon, 1);
			end
			petActionIcon:Show();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
		else
			petActionIcon:Hide();
			petActionButton:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		end
	end
	PetActionBar_UpdateCooldowns();
	if ( not PetHasActionBar() ) then
		--ControlReleased();
		HidePetActionBar();
	end
end

function PetActionBar_UpdateCooldowns()
	local cooldown;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		cooldown = getglobal("PetActionButton"..i.."Cooldown");
		local start, duration, enable = GetPetActionCooldown(i);
		CooldownFrame_SetTimer(cooldown, start, duration, enable);
	end
end

function ShowPetActionBar()
	UIParent_ManageFramePositions();
	if ( PetHasActionBar() and PetActionBarFrame.showgrid == 0 and (PetActionBarFrame.mode ~= "show") and not PetActionBarFrame.locked and not PetActionBarFrame.ctrlPressed ) then
		PetActionBarFrame:Show();
		if ( PetActionBarFrame.completed ) then
			PetActionBarFrame.slideTimer = 0;
		end
		PetActionBarFrame.timeToSlide = PETACTIONBAR_SLIDETIME;
		PetActionBarFrame.yTarget = PETACTIONBAR_YPOS;
		PetActionBarFrame.mode = "show";

		-- Rare case
		if ( GetNumShapeshiftForms() > 0 ) then
			PETACTIONBAR_XPOS = getglobal("ShapeshiftButton"..GetNumShapeshiftForms()):GetRight() +20;
		else
			PETACTIONBAR_XPOS = 36
		end
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:Raise();
		end
	end
end

function HidePetActionBar()
	if ( PetActionBarFrame.showgrid == 0 and PetActionBarFrame:IsShown() and not PetActionBarFrame.locked and not PetActionBarFrame.ctrlPressed ) then
		if ( PetActionBarFrame.completed ) then
			PetActionBarFrame.slideTimer = 0;
		end
		PetActionBarFrame.timeToSlide = PETACTIONBAR_SLIDETIME;
		PetActionBarFrame.yTarget = PETACTIONBAR_YPOS;
		PetActionBarFrame.mode = "hide";
	end
end

function PetActionBar_ShowGrid()
	ShowPetActionBar();
	PetActionBarFrame.showgrid = PetActionBarFrame.showgrid + 1;
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		getglobal("PetActionButton"..i):Show();
	end
end

function PetActionBar_HideGrid()
	if ( PetActionBarFrame.showgrid > 0 ) then
		PetActionBarFrame.showgrid = PetActionBarFrame.showgrid - 1;
	end
	if ( PetActionBarFrame.showgrid == 0 ) then
		HidePetActionBar();
		local name;
		for i=1, NUM_PET_ACTION_SLOTS, 1 do
			name = GetPetActionInfo(i);
			if ( not name ) then
				getglobal("PetActionButton"..i):Hide();
			end
			
		end
	end
	
end

function PetActionButtonDown(id)
	local button = getglobal("PetActionButton"..id);
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function PetActionButtonUp(id)
	local button = getglobal("PetActionButton"..id);
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		CastPetAction(id);
	end
end

function PetActionButton_OnLoad()
	this:RegisterForDrag("LeftButton", "RightButton");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("UPDATE_BINDINGS");
	getglobal(this:GetName().."Cooldown"):SetScale(1);
	getglobal(this:GetName().."Cooldown"):ClearAllPoints();
	getglobal(this:GetName().."Cooldown"):SetWidth(33);
	getglobal(this:GetName().."Cooldown"):SetHeight(33);
	getglobal(this:GetName().."Cooldown"):SetPoint("CENTER", this, "CENTER", -2, -1);
	PetActionButton_SetHotkeys();
end

function PetActionButton_OnEvent()
	if ( event == "UPDATE_BINDINGS" ) then
		PetActionButton_SetHotkeys();
		return;
	end
end

function PetActionButton_OnClick(button)
	this:SetChecked(0);
	if ( IsShiftKeyDown() ) then
		PickupPetAction(this:GetID());
	else
		if ( button == "LeftButton" ) then
			if ( IsPetAttackActive(this:GetID()) ) then
				PetStopAttack();
			else
				CastPetAction(this:GetID());
			end
		else
			TogglePetAutocast(this:GetID());
		end
	end
end

function PetActionButton_OnDragStart()
	if ( LOCK_ACTIONBAR ~= "1" ) then
		this:SetChecked(0);
		PickupPetAction(this:GetID());
		PetActionBar_Update();
	end
end

function PetActionButton_OnReceiveDrag()
	if ( LOCK_ACTIONBAR ~= "1" ) then
		this:SetChecked(0);
		PickupPetAction(this:GetID());
		PetActionBar_Update();
	end
end

function PetActionButton_OnEnter()
	if ( not this.tooltipName ) then
		return;
	end
	local uber = GetCVar("UberTooltips");
	if ( this.isToken or (uber == "0") ) then
		if ( uber == "0" ) then
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, this);
		end
		GameTooltip:SetText(this.tooltipName..NORMAL_FONT_COLOR_CODE.." ("..GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..this:GetID()), "KEY_")..")"..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0);
		if ( this.tooltipSubtext ) then
			GameTooltip:AddLine(this.tooltipSubtext, "", 0.5, 0.5, 0.5);
		end
		GameTooltip:Show();
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
		GameTooltip:SetPetAction(this:GetID());
	end
end

function PetActionButton_OnLeave()
	GameTooltip:Hide();
end

function PetActionButton_SetHotkeys()
	local binding = GetBindingText(GetBindingKey("BONUSACTIONBUTTON"..this:GetID()), 1);
	local bindingSuffix = gsub(binding, ".*%-", "");
	local hotkey = getglobal(this:GetName().."HotKey");
	if ( bindingSuffix == this:GetID() ) then
		hotkey:SetText(this:GetID());
	else
		hotkey:SetText("");
	end
end

function PetActionButton_StartFlash()
	this.flashing = 1;
	this.flashtime = 0;
	ActionButton_UpdateState();
end

function PetActionButton_StopFlash()
	this.flashing = 0;
	getglobal(this:GetName().."Flash"):Hide();
	ActionButton_UpdateState();
end

function LockPetActionBar()
	PetActionBarFrame.locked = 1;
end

function UnlockPetActionBar()
	PetActionBarFrame.locked = nil;
end

--function ControlPressed()
--	ShowPetActionBar();
--	PetActionBarFrame.ctrlPressed = 1;
--end

--function ControlReleased()
--	PetActionBarFrame.ctrlPressed = nil;
--	HidePetActionBar();
--end
