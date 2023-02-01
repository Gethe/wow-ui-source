NUM_POSSESS_SLOTS = 2;
POSSESS_CANCEL_SLOT = 2;

PossessActionBarMixin = {};

function PossessActionBarMixin:PossessActionBar_OnLoad()
	self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
end

function PossessActionBarMixin:Update()
	if ( not MainMenuBar.busy and not UnitHasVehicleUI("player") ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( IsPossessBarVisible() ) then
			if ( not self:IsShown() ) then
				self:Show();
			end

			self:UpdateState();
		elseif ( self:IsShown() ) then
			self:Hide();
		end
	end
end

function PossessActionBarMixin:UpdateState()
	local texture, spellID, enabled;
	local button, icon, cooldown;

	for i=1, NUM_POSSESS_SLOTS do
		-- Possess Icon
		button = self.actionButtons[i];
		icon = button.icon;
		texture, spellID, enabled = GetPossessInfo(i);
		icon:SetTexture(texture);

		--Cooldown stuffs
		cooldown = button.cooldown;
		cooldown:Hide();

		button:SetChecked(false);
		button:Enable();
		icon:SetVertexColor(1.0, 1.0, 1.0);
		icon:SetDesaturated(false);
	end

	self:UpdateShownButtons();
end

PossessButtonMixin = {};

function PossessButtonMixin:OnLoad()
	self.cooldown:SetSwipeColor(0, 0, 0);
end

function PossessButtonMixin:OnClick()
	self:SetChecked(false);

	local id = self:GetID();
	if ( id == POSSESS_CANCEL_SLOT ) then
		if ( UnitOnTaxi("player") ) then
			TaxiRequestEarlyLanding();

			-- Show that the request for landing has been received.
			local icon = self.icon;
			icon:SetDesaturated(true);
			self:SetChecked(true);
			self:Disable();
		elseif ( UnitControllingVehicle("player") and CanExitVehicle() ) then
			VehicleExit();
		else
			CancelPetPossess();
		end
	end
end

function PossessButtonMixin:OnEnter()
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

function PossessButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function PossessButtonMixin:HasAction()
	local texture, spellID, enabled = GetPossessInfo(self.index);
	return enabled;
end