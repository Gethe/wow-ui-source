
TotemFrameMixin = { }; 

function TotemFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");	
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED"); 
	self.totemPool = CreateFramePool("BUTTON", self, "TotemButtonTemplate");
end

function TotemFrameMixin:Update()
	local _, class = UnitClass("player");
	local priorities = STANDARD_TOTEM_PRIORITIES;
	if (class == "SHAMAN") then
		priorities = SHAMAN_TOTEM_PRIORITIES;
	end	

	local haveTotem, name, startTime, duration, icon;
	local slot;
	local button;
	self.activeTotems = 0;
	self.totemPool:ReleaseAll(); 
	for i=1, MAX_TOTEMS do
		slot = priorities[i];
		haveTotem, name, startTime, duration, icon = GetTotemInfo(slot);
		if ( haveTotem ) then
			button = self.totemPool:Acquire();
			button.layoutIndex = i; 
			button.slot = slot;
			button:Update(startTime, duration, icon);

			if ( button:IsShown() ) then
				self.activeTotems = self.activeTotems + 1;
			end
		end
	end
	self:Layout(); 
	if ( self.activeTotems > 0 ) then
		self:Show();
	else
		self:Hide();
	end
	PlayerFrame_AdjustAttachments();
end

function TotemFrameMixin:OnEvent(event, ...)
	self:Update();
end

TotemButtonMixin = { }; 
function TotemButtonMixin:OnClick(mouseButton)
	local cannotDismiss = GetTotemCannotDismiss(self.slot)
	if ( not cannotDismiss ) then
		if ( mouseButton == "RightButton" and self.slot > 0 ) then
			DestroyTotem(self.slot);
		end
	end
end

function TotemButtonMixin:OnLoad()
	self:RegisterForClicks("RightButtonUp");
end

function TotemButtonMixin:OnUpdate(elapsed)
	AuraButtonMixin.UpdateDuration(self, GetTotemTimeLeft(self.slot));
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTotem(self.slot);
	end
end

function TotemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetTotem(self.slot);
end

function TotemButtonMixin:Update(startTime, duration, icon)
	local buttonIcon = self.Icon.Texture;
	local buttonDuration = self.Duration;
	local buttonCooldown = self.Icon.Cooldown;

	if ( duration > 0 ) then
		buttonIcon:SetTexture(icon);
		buttonIcon:Show();
		CooldownFrame_Set(buttonCooldown, startTime, duration, true);
		buttonCooldown:Show();
		self:SetScript("OnUpdate", self.OnUpdate);
		self:Show();
	else
		buttonIcon:Hide();
		buttonDuration:Hide();
		buttonCooldown:Hide();
		self:SetScript("OnUpdate", nil);
		self:Hide();
	end
end