
NUM_STANCE_SLOTS = 10;


-------------------------------------------------------
------- StanceBar (Shapsfit,Auras,Aspects) Code -------
-------------------------------------------------------

function StanceBar_Update ()
	local numForms = GetNumShapeshiftForms();
	local needFrameMgrUpdate = false;
	if ( numForms > 0 and not IsPossessBarVisible()) then
		if ( StanceBarFrame.numForms ~= numForms ) then
			--Setup the Stance bar to display the appropriate number of slots
			if ( numForms == 1 ) then
				StanceBarMiddle:Hide();
				StanceBarRight:SetPoint("LEFT", "StanceBarLeft", "LEFT", 12, 0);
				StanceButton1:SetPoint("BOTTOMLEFT", "StanceBarFrame", "BOTTOMLEFT", 12, 3);
			elseif ( numForms == 2 ) then
				StanceBarMiddle:Hide();
				StanceBarRight:SetPoint("LEFT", "StanceBarLeft", "RIGHT", 0, 0);
			else
				StanceBarMiddle:Show();
				StanceBarMiddle:SetPoint("LEFT", "StanceBarLeft", "RIGHT", 0, 0);
				StanceBarMiddle:SetWidth(37 * (numForms-2));
				StanceBarMiddle:SetTexCoord(0, numForms-2, 0, 1);
				StanceBarRight:SetPoint("LEFT", "StanceBarMiddle", "RIGHT", 0, 0);
			end
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
	local texture, name, isActive, isCastable;
	local button, icon, cooldown;
	local start, duration, enable;
	for i=1, NUM_STANCE_SLOTS do
		button = _G["StanceButton"..i];
		icon = _G["StanceButton"..i.."Icon"];
		if ( i <= numForms ) then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			--Cooldown stuffs
			cooldown = _G["StanceButton"..i.."Cooldown"];
			if ( texture ) then
				cooldown:Show();
			else
				cooldown:Hide();
			end
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			
			if ( isActive ) then
				StanceBarFrame.lastSelected = button:GetID();
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

function StanceBar_Select (id)
	StanceBarFrame.lastSelected = id;
	CastShapeshiftForm(id);
end

