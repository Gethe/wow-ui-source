BONUSACTIONBAR_SLIDETIME = 0.15;
BONUSACTIONBAR_YPOS = 43;
BONUSACTIONBAR_XPOS = 4;
NUM_BONUS_ACTION_SLOTS = 12;
NUM_SHAPESHIFT_SLOTS = 10;
NUM_POSSESS_SLOTS = 2;

function BonusActionBar_OnLoad()
	this:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	this:RegisterEvent("ACTIONBAR_SHOWGRID");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	this:SetFrameLevel(this:GetFrameLevel() + 2);
	this.mode = "none";
	this.completed = 1;
	this.lastBonusBar = 1;
	if ( GetBonusBarOffset() > 0 and GetActionBarPage() == 1 ) then
		ShowBonusActionBar();
	end
end

function BonusActionBar_OnEvent()
	if ( event == "UPDATE_BONUS_ACTIONBAR" ) then
		if ( GetBonusBarOffset() > 0 ) then
			this.lastBonusBar = GetBonusBarOffset();
			--UnlockPetActionBar();
			--HidePetActionBar();
			ShowBonusActionBar();
		else
			HideBonusActionBar();
			--if ( PetHasActionBar() ) then
			--	ShowPetActionBar();
			--	LockPetActionBar();
			--end
		end
	end
end

function BonusActionBar_OnUpdate(elapsed)
	local yPos;
	if ( this.slideTimer and (this.slideTimer < this.timeToSlide) ) then
		-- Animating
		this.completed = nil;
		if ( this.mode == "show" ) then
			yPos = (this.slideTimer/this.timeToSlide) * BONUSACTIONBAR_YPOS;
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
			this.state = "showing";
			this:Show();
		elseif ( this.mode == "hide" ) then
			yPos = (1 - (this.slideTimer/this.timeToSlide)) * BONUSACTIONBAR_YPOS;
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
			this.state = "hiding";
		end
		this.slideTimer = this.slideTimer + elapsed;
	else
		-- Animation complete
		if ( this.completed == 1 ) then
			return;
		else
			this.completed = 1;
		end
		BonusActionBar_SetButtonTransitionState(nil);
		if ( this.mode == "show" ) then
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, BONUSACTIONBAR_YPOS);
			this.state = "top";
			PlaySound("igBonusBarOpen");
		elseif ( this.mode == "hide" ) then
			this:SetPoint("TOPLEFT", this:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, 0);
			this.state = "bottom";
			this:Hide();
		end
		this.mode = "none";
	end
end

function ShowBonusActionBar()
	BonusActionBar_SetButtonTransitionState(nil);
	if ( BonusActionBarFrame.mode ~= "show" and BonusActionBarFrame.state ~= "top") then
		BonusActionBarFrame:Show();
		if ( BonusActionBarFrame.completed ) then
			BonusActionBarFrame.slideTimer = 0;
		end
		BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
		BonusActionBarFrame.mode = "show";
	end
end

function HideBonusActionBar()
	if ( BonusActionBarFrame:IsShown() ) then
		BonusActionBar_SetButtonTransitionState(1);
		if ( BonusActionBarFrame.completed ) then
			BonusActionBarFrame.slideTimer = 0;
		end
		BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
		BonusActionBarFrame.mode = "hide";
	end
	
end

function BonusActionButtonUp(id)
	PetActionButtonUp(id);
end

function BonusActionButtonDown(id)
	PetActionButtonDown(id);
end

function BonusActionBar_SetButtonTransitionState(state)
	local button, icon;
	local _this = this;
	for i=1, NUM_BONUS_ACTION_SLOTS, 1 do
		button = getglobal("BonusActionButton"..i);
		icon = getglobal("BonusActionButton"..i.."Icon");
		button.inTransition = state;
		if ( button.needsUpdate ) then
			this = button;
			securecall("ActionButton_Update");
			button.needsUpdate = nil;
		end
	end
	this = _this;
end

function ShapeshiftBar_OnLoad()
	ShapeshiftBar_Update();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	this:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha??
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	this:RegisterEvent("SPELL_UPDATE_USABLE");
	this:RegisterEvent("PLAYER_AURAS_CHANGED");
	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
end

function ShapeshiftBar_OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORMS" ) then
		ShapeshiftBar_Update();
	elseif ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		if ( GetBonusBarOffset() > 0 ) then
			ShowBonusActionBar();
		else
			HideBonusActionBar();
		end
	else
		ShapeshiftBar_UpdateState();
	end
end

function ShapeshiftBar_Update()
	local numForms = GetNumShapeshiftForms();
	if ( numForms > 0 ) then
		--Setup the shapeshift bar to display the appropriate number of slots
		if ( numForms == 1 ) then
			ShapeshiftBarMiddle:Hide();
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarLeft", "LEFT", 12, 0);
			ShapeshiftButton1:SetPoint("BOTTOMLEFT", "ShapeshiftBarFrame", "BOTTOMLEFT", 12, 3);

		elseif ( numForms == 2 ) then
			ShapeshiftBarMiddle:Hide();
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarLeft", "RIGHT", 0, 0);
		else
			ShapeshiftBarMiddle:Show();
			ShapeshiftBarMiddle:SetPoint("LEFT", "ShapeshiftBarLeft", "RIGHT", 0, 0);
			ShapeshiftBarMiddle:SetWidth(37 * (numForms-2));
			ShapeshiftBarMiddle:SetTexCoord(0, numForms-2, 0, 1);
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarMiddle", "RIGHT", 0, 0);
		end
		
		ShapeshiftBarFrame:Show();
	else
		ShapeshiftBarFrame:Hide();
	end
	ShapeshiftBar_UpdateState();
	UIParent_ManageFramePositions();
end

function ShapeshiftBar_UpdateState()
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;
	for i=1, NUM_SHAPESHIFT_SLOTS do
		button = getglobal("ShapeshiftButton"..i);
		icon = getglobal("ShapeshiftButton"..i.."Icon");
		if ( i <= numForms ) then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			--Cooldown stuffs
			cooldown = getglobal("ShapeshiftButton"..i.."Cooldown");
			if ( texture ) then
				cooldown:Show();
			else
				cooldown:Hide();
			end
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			
			if ( isActive ) then
				ShapeshiftBarFrame.lastSelected = button:GetID();
				button:SetChecked(1);
			else
				button:SetChecked(0);
			end

			if ( isCastable ) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end

			button:Show();
		else
			button:Hide();
		end
	end
end

function ShapeshiftBar_ChangeForm(id)
	ShapeshiftBarFrame.lastSelected = id;
	local check = 1;
	CastShapeshiftForm(id);
end

function PossessBar_OnLoad()
	PossessBar_Update();
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	this:RegisterEvent("PLAYER_AURAS_CHANGED");
	this:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
end

function PossessBar_OnEvent()
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		PossessBar_Update();
	elseif ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		if ( GetBonusBarOffset() > 0 ) then
			ShowBonusActionBar();
		else
			HideBonusActionBar();
		end
	else
		PossessBar_UpdateState();
	end
end

function PossessBar_Update()
	if ( IsPossessBarVisible() ) then
		PossessBarFrame:Show();
		ShapeshiftBarFrame:Hide();
	else
		PossessBarFrame:Hide();
		if(GetNumShapeshiftForms() > 0) then
			ShapeshiftBarFrame:Show();
		end
	end
	PossessBar_UpdateState();
	UIParent_ManageFramePositions();
end

function PossessBar_UpdateState()
	local texture, name;
	local button, icon, cooldown;

	for i=1, NUM_POSSESS_SLOTS do
		-- Possess Icon
		button = getglobal("PossessButton"..i);
		icon = getglobal("PossessButton"..i.."Icon");
		texture, name = GetPossessInfo(i);
		icon:SetTexture(texture);
		
		--Cooldown stuffs
		cooldown = getglobal("PossessButton"..i.."Cooldown");
		cooldown:Hide();
		
		button:SetChecked(0);
		icon:SetVertexColor(1.0, 1.0, 1.0);

		button:Show();
	end
end

function PossessBar_Clicked(id)
	local button = getglobal("PossessButton"..id);
	button:SetChecked(0);
	
	if (id == 2) then
		local texture, name = GetPossessInfo(1);
		CancelPlayerBuff(name);
	end
end

function PossessBar_OnEnter(id)
	local button = getglobal("PossessButton"..id);
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, this);
	else
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    end
    
    if ( id == 2 ) then
		GameTooltip:SetText(CANCEL);
    else
		GameTooltip:SetPossession(this:GetID());
	end
end