-------------------------------------------------------
------- StanceBar (Shapsfit,Auras,Aspects) Code -------
-------------------------------------------------------
StanceBarMixin = {};

function StanceBarMixin:OnLoad()
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
end

function StanceBarMixin:OnEvent(event)
	if(event == "UPDATE_SHAPESHIFT_COOLDOWN") then
		self:UpdateState();
	end
end

function StanceBarMixin:ShouldShow()
	return self.numForms > 0
		and not IsPossessBarVisible()
		and ActionBarController_GetCurrentActionBarState() ~= LE_ACTIONBAR_STATE_OVERRIDE;
end

function StanceBarMixin:Update()
	self.numForms = GetNumShapeshiftForms();
	self.numButtonsShowable = self.numForms or self.numButtons;
	if ( self.numForms > 0) then
		self:UpdateState();
	end

	-- Don't update shown if action bars are busy
	-- This is often related to vehicle bars or pet battles
	if not ActionBarBusy() then
		self:SetShown(self:ShouldShow());
	end
end

function StanceBarMixin:UpdateState()
	local numForms = GetNumShapeshiftForms();
	local texture, isActive, isCastable;
	local icon, cooldown;
	local start, duration, enable;

	for i, button in pairs(self.actionButtons) do
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
				self.lastSelected = button:GetID();
				button:SetChecked(true);
			else
				button:SetChecked(false);
			end

			if ( isCastable ) then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end

	self:UpdateShownButtons();
end

function StanceBarMixin:Select(id)
	self.lastSelected = id;
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
		StanceBar:Select(self:GetID());
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

-- Used by action bar template
function StanceButtonMixin:HasAction()
    return GetShapeshiftFormInfo(self.index);
end