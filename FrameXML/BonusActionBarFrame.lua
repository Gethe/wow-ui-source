BONUSACTIONBAR_SLIDETIME = 0.15;
BONUSACTIONBAR_YPOS = 43;
BONUSACTIONBAR_XPOS = 4;
NUM_BONUS_ACTION_SLOTS = 12;
NUM_SHAPESHIFT_SLOTS = 10;

function BonusActionBar_OnLoad()
	this:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	this:RegisterEvent("ACTIONBAR_SHOWGRID");
	this:RegisterEvent("ACTIONBAR_HIDEGRID");
	if ( GetBonusBarOffset() > 0 and CURRENT_ACTIONBAR_PAGE == 1 ) then
		ShowBonusActionBar();
	end
	this:SetFrameLevel(this:GetFrameLevel() + 2);
	this.mode = "none";
	this.completed = 1;
	this.lastBonusBar = 1;
end

function BonusActionBar_OnEvent()
	if ( event == "UPDATE_BONUS_ACTIONBAR" ) then
		if ( GetBonusBarOffset() > 0 ) then
			this.lastBonusBar = GetBonusBarOffset();
			UnlockPetActionBar();
			HidePetActionBar();
			ShowBonusActionBar();
		else
			HideBonusActionBar();
			if ( PetHasActionBar() ) then
				ShowPetActionBar();
				LockPetActionBar();
			end
		end
	end
end

function BonusActionBar_OnUpdate(elapsed)
	local yPos;
	if ( this.slideTimer and (this.slideTimer < this.timeToSlide) ) then
		-- Animating
		this.completed = nil;
		if ( this.mode == "show" ) then
			yPos = (this.slideTimer/this.timeToSlide) * this.yTarget;
			this:SetPoint("TOPLEFT", this:GetParent():GetName(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
			this.state = "showing";
			this:Show();
		elseif ( this.mode == "hide" ) then
			yPos = (1 - (this.slideTimer/this.timeToSlide)) * this.yTarget;
			this:SetPoint("TOPLEFT", this:GetParent():GetName(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
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
			this:SetPoint("TOPLEFT", this:GetParent():GetName(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, this.yTarget);
			this.state = "top";
			PlaySound("igBonusBarOpen");
		elseif ( this.mode == "hide" ) then
			this:SetPoint("TOPLEFT", this:GetParent():GetName(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, 0);
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
		BonusActionBarFrame.yTarget = BONUSACTIONBAR_YPOS;
		BonusActionBarFrame.mode = "show";
	end
end

function HideBonusActionBar()
	if ( BonusActionBarFrame:IsVisible() ) then
		BonusActionBar_SetButtonTransitionState(1);
		if ( BonusActionBarFrame.completed ) then
			BonusActionBarFrame.slideTimer = 0;
		end
		BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
		BonusActionBarFrame.yTarget = BONUSACTIONBAR_YPOS;
		BonusActionBarFrame.mode = "hide";
	end
	
end

function BonusActionButton_OnEvent()
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys();
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
	for i=1, NUM_BONUS_ACTION_SLOTS, 1 do
		button = getglobal("BonusActionButton"..i);
		icon = getglobal("BonusActionButton"..i.."Icon");
		button.inTransition = state;
		if ( state ) then
			icon:SetTexture(button.texture);
			if ( button.texture ) then
				icon:Show();
				button:Show();
			end
		end
	end
end

function ShapeshiftBar_Update()
	local numForms = GetNumShapeshiftForms();
	local fileName, name, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;

	if ( numForms > 0 ) then
		--Setup the shapeshift bar to display the appropriate number of slots
		if ( numForms == 1 ) then
			ShapeshiftBarMiddle:Hide();
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarLeft", "LEFT", 12, 0);
		elseif ( numForms == 2 ) then
			ShapeshiftBarMiddle:Hide();
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarLeft", "RIGHT", 0, 0);
		else
			ShapeshiftBarMiddle:Show();
			ShapeshiftBarMiddle:SetPoint("LEFT", "ShapeshiftBarLeft", "RIGHT", 0, 0);
			ShapeshiftBarMiddle:SetWidth(38 * (numForms-2));
			ShapeshiftBarMiddle:SetTexCoord(0, numForms-2, 0, 1);
			ShapeshiftBarRight:SetPoint("LEFT", "ShapeshiftBarMiddle", "RIGHT", 0, 0);
		end
		
		ShapeshiftBarFrame:Show();
		--Move the chat frame and edit box up a bit
		FCF_UpdateDockPosition();
		--Move the casting bar up
		CastingBarFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 83);
	else
		ShapeshiftBarFrame:Hide();
		if ( not PetHasActionBar() ) then
			--Move the chat frame and edit box back down to original position
			FCF_UpdateDockPosition();
			--Move the casting bar back down
			CastingBarFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60);
		end
	end
	
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
