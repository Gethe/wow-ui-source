
NUM_BONUS_ACTION_SLOTS = 12;
NUM_SHAPESHIFT_SLOTS = 10;
NUM_POSSESS_SLOTS = 2;
POSSESS_CANCEL_SLOT = 2;

BONUSACTIONBAR_NUM_TEXTURES = 4;

BonusActionBarTypes =  {

	["default"] = 	{
								showDefaultBar = true,
								width = 506, height = 43,
								buttonX = 5, buttonY = 3, 
								buttonSize = 36,
								buttonSpace = 6,
								numButtons = 12,
								anchorPoint = "BOTTOMLEFT", anchorX = 3, anchorY = 0,
								Texture1 = 	{ 
														width = 253, height = 43, 
														file ="Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf",
														texLeft=0.015625, texRight=1.0, texTop=0.83203125, texBottom=1.0,
													},
								Texture2 = 	{ 
														width = 253, height = 43, 
														file ="Interface\\MainMenuBar\\UI-MainMenuBar-Dwarf",
														texLeft=0.015625, texRight=1.0, texTop=0.83203125, texBottom=1.0,
													},
							},
							
							
	["PlayerActionBarAlt"] = 	{
								width = 686, height = 93,
								xpWidth = 620,
								microBarX = 380, microBarY = 12,
								buttonX = 59, buttonY = 15, 
								buttonSize = 44,
								buttonSpace = 6,
								numButtons = 6,
								anchorPoint = "BOTTOM", anchorX = 0, anchorY = 0,
								Texture1 = 	{ 
														width = 220, height = 83, 
														file ="Interface\\PlayerActionBarAlt\\PlayerActionBarAlt_LEFT",
														texLeft=0.1015625, texRight=1.0, texTop=0.3515625, texBottom=1.0,
													},
								Texture2 = 	{ 
														width = 236, height = 83,
														file ="Interface\\PlayerActionBarAlt\\PlayerActionBarAlt_MID",
														texLeft=0.0, texRight=1.0, texTop=0.3515625, texBottom=1.0,
													},
								Texture3 = 	{ 
														width = 230, height = 83, 
														file ="Interface\\PlayerActionBarAlt\\PlayerActionBarAlt_RIGHT",
														texLeft=0.0, texRight=0.8984375, texTop=0.3515625, texBottom=1.0,
													},
							},
							
	["SingleBarLayout"]= 	{
								width = 686, height = 93,
								xpWidth = 620,
								microBarX = 466, microBarY = 43,
								microTwoRows = true,
								buttonX = 83, buttonY = 20, 
								buttonSize = 42,
								buttonSpace = 18,
								numButtons = 6,
								anchorPoint = "BOTTOM", anchorX = 0, anchorY = 0,
								buttonBg = true,
								Texture4 = 	{ 
														width = 1024, height = 128, 
														texLeft=0.0, texRight=1.0, texTop=0.0, texBottom=1.0,
													},
							}
}







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

function SetupBonusActionBar()
	local barType = GetBonusBarOverrideBarType() or "default";
	local barInfo = BonusActionBarGetBarInfo(barType);
	if not barInfo then
		return;
	end
	
	local texture, textureInfo;
	for i=1,BONUSACTIONBAR_NUM_TEXTURES do
		texture = _G["BonusActionBarFrameTexture"..i];
		textureInfo = barInfo["Texture"..i];
		if textureInfo then
			if textureInfo.file then
				texture:SetTexture(textureInfo.file);
			else
				texture:SetTexture("Interface\\PlayerActionBarAlt\\"..barType);
			end
			texture:SetSize(textureInfo.width, textureInfo.height);
			texture:SetTexCoord(textureInfo.texLeft, textureInfo.texRight, textureInfo.texTop, textureInfo.texBottom);
			texture:Show();
		else
			texture:Hide();
		end
	end
	
	for i=1,NUM_BONUS_ACTION_SLOTS do
		local button = _G["BonusActionButton"..i];
		if  i > barInfo.numButtons then
			button:SetAttribute("statehidden", true);
		else
			button:SetAttribute("statehidden", false);
			button:SetSize(barInfo.buttonSize, barInfo.buttonSize);
		end
		
		if barInfo.buttonBg then
			button.bg:SetTexture("Interface\\PlayerActionBarAlt\\"..barType.."Btn");
			button.bg:Show();
		else
			button.bg:Hide();
		end
		
		if i > 1 and barInfo.buttonSpace then
			button:SetPoint("LEFT", _G["BonusActionButton"..(i-1)], "RIGHT", barInfo.buttonSpace, 0);
		end
	end
			
	if not barInfo.showDefaultBar then
		BonusActionBarFrame:SetParent("UIParent");
	else
		BonusActionBarFrame:SetParent("MainMenuBar");
	end
	
	BonusActionBarFrame:SetSize(barInfo.width, barInfo.height);
	BonusActionBarFrame:ClearAllPoints();
	BonusActionBarFrame:SetPoint(barInfo.anchorPoint, barInfo.anchorX, barInfo.anchorY);
	BonusActionButton1:SetPoint("BOTTOMLEFT",  barInfo.buttonX, barInfo.buttonY);
	BonusActionBarFrame.currentType = barType;
end


function BonusActionBarGetBarInfo(barType)
	if BonusActionBarTypes[barType] then
		return BonusActionBarTypes[barType];
	elseif barType then
		return BonusActionBarTypes["SingleBarLayout"];
	end
end


function ShowBonusActionBar (force)
	if (( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) or force) then	--Don't change while we're animating out MainMenuBar for vehicle UI

		local barType = GetBonusBarOverrideBarType() or "default";
		local barInfo = BonusActionBarGetBarInfo(barType);
	
		local shownFrame = MainMenuBar;
		if not BonusActionBarFrame:IsShown() then
			SetupBonusActionBar();
		elseif not MainMenuBar:IsShown() then
			shownFrame = BonusActionBarFrame;
		end
		
		if not barInfo.showDefaultBar then
			shownFrame.nextAnimBar = BonusActionBarFrame;
			shownFrame.barToShow = BonusActionBarFrame;
			shownFrame.animOut = true;
			BonusActionBarFrame.xpWidth = barInfo.xpWidth;
			BonusActionBarFrame.microBarParent = BonusActionBarFrame;
			BonusActionBarFrame.microBarX = barInfo.microBarX;
			BonusActionBarFrame.microBarY = barInfo.microBarY;
			BonusActionBarFrame.microTwoRows = barInfo.microTwoRows;
			shownFrame.slideout:Play(); -- Slide bar out
		else
			if shownFrame == MainMenuBar then --Bar only
				BonusActionBarFrame.nextAnimBar = nil;
				BonusActionBarFrame.animOut = false;
				shownFrame.barToShow = nil;
				if ( not BonusActionBarFrame:IsShown() ) then
					BonusActionBarFrame.slideout:Play(true); -- Slide bar in
				end
			else
				shownFrame.nextAnimBar = MainMenuBar;
				shownFrame.barToShow = BonusActionBarFrame;
				shownFrame.animOut = true;
				MainMenuBar.xpWidth = EXP_DEFAULT_WIDTH;
				MainMenuBar.microBarParent = MainMenuBarArtFrame;
				MainMenuBar.microBarX = 552;
				MainMenuBar.microBarY = 2;
				shownFrame.slideout:Play(); -- Slide bar out
			end
		end		
	end
end

function HideBonusActionBar (force)
	if ( BonusActionBarFrame:IsShown() and (( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) or force) ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		
		local oldbarInfo = BonusActionBarGetBarInfo(BonusActionBarFrame.currentType);
		if not oldbarInfo then return end
		
		if not oldbarInfo.showDefaultBar then
			BonusActionBarFrame.nextAnimBar = MainMenuBar;
			BonusActionBarFrame.barToShow = MainMenuBar;
			BonusActionBarFrame.animOut = true;
			
			MainMenuBar.xpWidth = EXP_DEFAULT_WIDTH;
			MainMenuBar.microBarParent = MainMenuBarArtFrame;
			MainMenuBar.microBarX = 552;
			MainMenuBar.microBarY = 2;
			
			BonusActionBarFrame.slideout:Play(); -- Slide main bar out
		else
			--Bar only
			BonusActionBarFrame.nextAnimBar = nil;
			BonusActionBarFrame.barToShow = nil;
			BonusActionBarFrame.animOut = true;
			BonusActionBarFrame.slideout:Play(); -- Slide main bar out
		end
	end
end



function ActionBar_AnimTransitionFinished(self)
	if  MainMenuBar.busy or UnitHasVehicleUI("player") then
		BonusActionBarFrame:Hide();
		return;
	end

	if self.animOut then
		self:Hide();
		if self.nextAnimBar then
			self.nextAnimBar.animOut = false;

			if self ~= self.nextAnimBar then
				if self.nextAnimBar.xpWidth then
					MainMenuExpBar:SetParent(self.nextAnimBar);
					MainMenuExpBar_SetWidth(self.nextAnimBar.xpWidth);
					MainMenuExpBar:SetPoint("TOP", self.nextAnimBar, 0, 0);
				end
				if self.nextAnimBar.microBarX then
					CharacterMicroButton:ClearAllPoints();
					UpdateMicroButtonsParent(self.nextAnimBar.microBarParent);
					CharacterMicroButton:SetPoint("BOTTOMLEFT", self.nextAnimBar.microBarX, self.nextAnimBar.microBarY);
					GuildMicroButton:ClearAllPoints();
					if self.nextAnimBar.microTwoRows then
						GuildMicroButton:SetPoint("TOPLEFT", CharacterMicroButton, "BOTTOMLEFT", 0, 22);
					else
						GuildMicroButton:SetPoint("BOTTOMLEFT", QuestLogMicroButton, "BOTTOMRIGHT", -3, 0);
					end
					UpdateMicroButtons();
				end
			end
			
			local barType = GetBonusBarOverrideBarType() or "default";
			if BonusActionBarFrame.currentType ~= barType then
				SetupBonusActionBar();
			end;
			self.nextAnimBar.slideout:Play(true); -- Slide bar in
			if self.barToShow then
				self.barToShow:Show();
			end
		end
	else
		self.xpWidth = nil;
		PlaySound("igBonusBarOpen");
	end
end


function BonusActionButtonUp (id)
	PetActionButtonUp(id);
end

function BonusActionButtonDown (id)
	PetActionButtonDown(id);
end




---------------------------------------------------------------------
----- ShapeshiftBar (StanceBar) Code ----------------------
----- ShapeshiftBar (StanceBar) Code ----------------------
---------------------------------------------------------------------



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