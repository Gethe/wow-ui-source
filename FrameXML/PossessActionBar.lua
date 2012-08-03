NUM_POSSESS_SLOTS = 2;
POSSESS_CANCEL_SLOT = 2;

function PossessBar_Update ()
	if ( not MainMenuBar.busy and not UnitHasVehicleUI("player") ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		local needFrameMgrUpdate = false;
		if ( IsPossessBarVisible() ) then
			if ( not PossessBarFrame:IsShown() ) then
				PossessBarFrame:Show();
				needFrameMgrUpdate = true;
			end
			PossessBar_UpdateState();
		elseif ( PossessBarFrame:IsShown() ) then
			PossessBarFrame:Hide();
			needFrameMgrUpdate = true;
		end
		
		if ( needFrameMgrUpdate ) then
			UIParent_ManageFramePositions();
		end
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

