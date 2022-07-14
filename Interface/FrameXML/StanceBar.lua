
NUM_STANCE_SLOTS = 10;


-------------------------------------------------------
------- StanceBar (Shapsfit,Auras,Aspects) Code -------
-------------------------------------------------------

function StanceBar_OnLoad(self)
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
end

function StanceBar_OnEvent(self, event)
	if(event == "UPDATE_SHAPESHIFT_COOLDOWN") then
		StanceBar_UpdateState();
	end
end

function StanceBar_Update()
	local numForms = GetNumShapeshiftForms();
	local needFrameMgrUpdate = false;
	if ( numForms > 0 and not IsPossessBarVisible()) then
		if ( StanceBarFrame.numForms ~= numForms ) then
			StanceBarFrame.numForms = numForms;
			needFrameMgrUpdate = true;
		end
		
		if ( not StanceBarFrame:IsShown() ) then
			StanceBarFrame:Show();
			needFrameMgrUpdate = true;
		end
		StanceBar_UpdateState();
	elseif (StanceBarFrame:IsShown() ) then
		StanceBarFrame:Hide();
		needFrameMgrUpdate = true;
		StanceBarFrame.numForms = nil;
	end
	
	if ( needFrameMgrUpdate ) then
		UIParent_ManageFramePositions();
	end
end

function StanceBar_UpdateState ()
	local numForms = GetNumShapeshiftForms();
	local texture, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;
	local numStancesShown = 1; 
	for i=1, NUM_STANCE_SLOTS do
		button = StanceBarFrame.StanceButtons[i];
		icon = button.icon;
		if ( i <= numForms ) then
			texture, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			--Cooldown stuffs
			cooldown = button.cooldown;
			if ( texture ) then
				cooldown:Show();
			else
				cooldown:Hide();
			end
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_Set(cooldown, start, duration, enable);
			
			if ( isActive ) then
				StanceBarFrame.lastSelected = button:GetID();
				button:SetChecked(true);
			else
				button:SetChecked(false);
			end

			if ( isCastable ) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end

			button:Show();
			numStancesShown = numStancesShown + 1; 
		else
			button:Hide();
		end
	end
	local frameWidth = 29 * numStancesShown;
	StanceBarFrame:SetWidth(frameWidth);
end

function StanceBar_Select(id)
	StanceBarFrame.lastSelected = id;
	CastShapeshiftForm(id);
end

StanceButtonMixin = {}

function StanceButtonMixin:OnLoad()
	self.cooldown:SetSwipeColor(0, 0, 0);
	self:RegisterForClicks("AnyUp");
end

function StanceButtonMixin:OnClick()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		self:SetChecked(not self:GetChecked());
		StanceBar_Select(self:GetID());
	end
end

function StanceButtonMixin:OnEnter()
	if ( GetCVarBool("UberTooltips") or KeybindFrames_InQuickKeybindMode() ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	GameTooltip:SetShapeshift(self:GetID());
	self.UpdateTooltip = self.OnEnter;
end

function StanceButtonMixin:OnLeave()
	GameTooltip_Hide();
end