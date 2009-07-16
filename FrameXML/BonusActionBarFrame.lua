BONUSACTIONBAR_SLIDETIME = 0.15;
BONUSACTIONBAR_YPOS = 43;
BONUSACTIONBAR_XPOS = 4;
NUM_BONUS_ACTION_SLOTS = 12;
NUM_SHAPESHIFT_SLOTS = 10;
NUM_POSSESS_SLOTS = 2;
POSSESS_CANCEL_SLOT = 2;

function BonusActionBar_OnLoad (self)
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self.mode = "none";
	self.completed = 1;
	self.lastBonusBar = 1;
	if ( GetBonusBarOffset() > 0 and GetActionBarPage() == 1 ) then
		ShowBonusActionBar();
	end
end

function BonusActionBar_OnEvent (self, event, ...)
	if ( event == "UPDATE_BONUS_ACTIONBAR" ) then
		if ( GetBonusBarOffset() > 0 ) then
			self.lastBonusBar = GetBonusBarOffset();
			ShowBonusActionBar();
		else
			HideBonusActionBar();
		end
	end
end

function BonusActionBar_OnUpdate(self, elapsed)
	local yPos;
	if ( self.slideTimer and (self.slideTimer < self.timeToSlide) ) then
		-- Animating
		self.completed = nil;
		if ( self.mode == "show" ) then
			yPos = (self.slideTimer/self.timeToSlide) * BONUSACTIONBAR_YPOS;
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
			self.state = "showing";
			self:Show();
		elseif ( self.mode == "hide" ) then
			yPos = (1 - (self.slideTimer/self.timeToSlide)) * BONUSACTIONBAR_YPOS;
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, yPos);
			self.state = "hiding";
		end
		self.slideTimer = self.slideTimer + elapsed;
	else
		-- Animation complete
		if ( self.completed == 1 ) then
			return;
		else
			self.completed = 1;
		end
		if ( self.mode == "show" ) then
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, BONUSACTIONBAR_YPOS);
			self.state = "top";
			PlaySound("igBonusBarOpen");
		elseif ( self.mode == "hide" ) then
			self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", BONUSACTIONBAR_XPOS, 0);
			self.state = "bottom";
			self:Hide();
		end
		self.mode = "none";
	end
end

function ShowBonusActionBar (override)
	if (( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) or override) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( (BonusActionBarFrame.mode ~= "show" and BonusActionBarFrame.state ~= "top") or (not UIParent:IsShown())) then
			BonusActionBarFrame:Show();
			if ( BonusActionBarFrame.completed ) then
				BonusActionBarFrame.slideTimer = 0;
			end
			BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
			BonusActionBarFrame.mode = "show";
		end
	end
end

function HideBonusActionBar (override)
	if (( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) or override) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( (BonusActionBarFrame:IsShown()) or (not UIParent:IsShown())) then
			if ( BonusActionBarFrame.completed ) then
				BonusActionBarFrame.slideTimer = 0;
			end
			BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
			BonusActionBarFrame.mode = "hide";
		end
	end
end

function BonusActionButtonUp (id)
	PetActionButtonUp(id);
end

function BonusActionButtonDown (id)
	PetActionButtonDown(id);
end

function ShapeshiftBar_OnLoad (self)
	ShapeshiftBar_Update();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha?? Still Wha...
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
end

function ShapeshiftBar_OnEvent (self, event, ...)
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

function ShapeshiftBar_Update ()
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

function ShapeshiftBar_UpdateState ()
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;
	for i=1, NUM_SHAPESHIFT_SLOTS do
		button = _G["ShapeshiftButton"..i];
		icon = _G["ShapeshiftButton"..i.."Icon"];
		if ( i <= numForms ) then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			--Cooldown stuffs
			cooldown = _G["ShapeshiftButton"..i.."Cooldown"];
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

function ShapeshiftBar_ChangeForm (id)
	ShapeshiftBarFrame.lastSelected = id;
	CastShapeshiftForm(id);
end

function PossessBar_OnLoad (self)
	PossessBar_Update();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
end

function PossessBar_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		PossessBar_Update();
	elseif ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		if ( GetBonusBarOffset() > 0 ) then
			ShowBonusActionBar();
		else
			HideBonusActionBar();
		end
	end
end

function PossessBar_Update (override)
	if ( (not MainMenuBar.busy and not UnitHasVehicleUI("player")) or override ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( IsPossessBarVisible() ) then
			PossessBarFrame:Show();
			ShapeshiftBarFrame:Hide();
			ShowPetActionBar(true);
		else
			PossessBarFrame:Hide();
			if(GetNumShapeshiftForms() > 0) then
				ShapeshiftBarFrame:Show();
				ShowPetActionBar(true);
			end
		end
		PossessBar_UpdateState();
		UIParent_ManageFramePositions();
	end
end

function PossessBar_UpdateState ()
	local texture, name, enabled;
	local button, background, icon, cooldown;

	for i=1, NUM_POSSESS_SLOTS do
		-- Possess Icon
		button = _G["PossessButton"..i];
		background = _G["PossessBackground"..i];
		icon = _G["PossessButton"..i.."Icon"];
		texture, name, enabled = GetPossessInfo(i);
		icon:SetTexture(texture);

		--Cooldown stuffs
		cooldown = _G["PossessButton"..i.."Cooldown"];
		cooldown:Hide();

		button:SetChecked(nil);
		icon:SetVertexColor(1.0, 1.0, 1.0);

		if ( enabled ) then
			button:Show();
			background:Show();
		else
			button:Hide();
			background:Hide();
		end
	end
end

function PossessButton_OnClick (self)
	self:SetChecked(nil);

	local id = self:GetID();
	if ( id == POSSESS_CANCEL_SLOT ) then
		if ( UnitControllingVehicle("player") and CanExitVehicle() ) then
			VehicleExit();
		else
			local texture, name = GetPossessInfo(id);
			CancelUnitBuff("player", name);
		end
	end
end

function PossessButton_OnEnter (self)
	local id = self:GetID();

	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	if ( id == POSSESS_CANCEL_SLOT ) then
		GameTooltip:SetText(CANCEL);
	else
		GameTooltip:SetPossession(id);
	end
end
