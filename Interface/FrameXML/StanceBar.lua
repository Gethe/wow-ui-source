-------------------------------------------------------
------- StanceBar (Shapsfit,Auras,Aspects) Code -------
-------------------------------------------------------
StanceBarMixin = {};

function StanceBarMixin:OnLoad()
	self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
end

function StanceBarMixin:OnEvent(event)
	if(event == "UPDATE_SHAPESHIFT_COOLDOWN") then
		self:UpdateState();
	end
end

function StanceBarMixin:Update()
	local numForms = GetNumShapeshiftForms();
	local needFrameMgrUpdate = false;
	if ( numForms > 0 and not IsPossessBarVisible()) then
		if ( self.numForms ~= numForms ) then
			self.numForms = numForms;
			needFrameMgrUpdate = true;
		end

		if ( not self:IsShown() ) then
			self:Show();
			needFrameMgrUpdate = true;
		end
		self:UpdateState();
	elseif (self:IsShown() ) then
		self:Hide();
		needFrameMgrUpdate = true;
		self.numForms = nil;
	end

	if ( needFrameMgrUpdate ) then
		UIParent_ManageFramePositions();
	end
end

function StanceBarMixin:UpdateState()
	local numForms = GetNumShapeshiftForms();
	local texture, isActive, isCastable;
	local icon, cooldown;
	local start, duration, enable;
	self.numShowingButtons = 0;

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

			self.numShowingButtons = self.numShowingButtons + 1;
		end
	end

	self:UpdateShownButtons();
	self:UpdateGridLayout();
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
function StanceButtonMixin:GetShowGrid()
	return true;
end

-- Used by action bar template
function StanceButtonMixin:SetShowGrid()
end