TOTEM_PRIORITIES =
{
	AIR_TOTEM_SLOT,
	WATER_TOTEM_SLOT,
	EARTH_TOTEM_SLOT,
	FIRE_TOTEM_SLOT
};

TotemFrameMixin = {};

function TotemFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");	

	local _, class = UnitClass("player");
	if ( class == "DEATHKNIGHT" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 65, -55);
	end

	self:Update();
end

function TotemFrameMixin:OnShow()
	PlayerFrame_AdjustAttachments();
end

function TotemFrameMixin:OnHide()
	PlayerFrame_AdjustAttachments();
end

function TotemFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_TOTEM_UPDATE" ) then
		local slot = ...;
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot);
		local button;
		for i=1, MAX_TOTEMS do
			button = getglobal("TotemFrameTotem"..i);
			if ( button.slot == slot ) then
				local previouslyShown = button:IsShown();
				button:Update(startTime, duration, icon);
				-- if we have no active totems then we need to hide the whole frame, otherwise show it
				if ( previouslyShown ) then
					if ( not button:IsShown() ) then
						self.activeTotems = self.activeTotems - 1;
					end
				else
					if ( button:IsShown() ) then
						self.activeTotems = self.activeTotems + 1;
					end
				end
				if ( self.activeTotems > 0 ) then
					self:Show();
				else
					self:Hide();
				end
				return;
			end
		end
	end
	self:Update();
end

function TotemFrameMixin:Update()
	self:UpdateClassSpecificLayout();

	local haveTotem, name, startTime, duration, icon;
	local slot;
	local button;
	local buttonIndex = 1;
	self.activeTotems = 0;

	local priorities = TOTEM_PRIORITIES;
	if(GetClassicExpansionLevel() >= LE_EXPANSION_CATACLYSM) then
		local _, class = UnitClass("player");
		if (class == "SHAMAN") then
			priorities = SHAMAN_TOTEM_PRIORITIES;
		else
			priorities = STANDARD_TOTEM_PRIORITIES;	
		end
	end

	for i=1, MAX_TOTEMS do
		slot = priorities[i];
		haveTotem, name, startTime, duration, icon = GetTotemInfo(slot);
		if ( haveTotem ) then
			button = getglobal("TotemFrameTotem"..buttonIndex);
			button.slot = slot;
			button:Update(startTime, duration, icon);
			buttonIndex = buttonIndex + 1;

			if ( button:IsShown() ) then
				self.activeTotems = self.activeTotems + 1;
			end
		else
			button = getglobal("TotemFrameTotem"..MAX_TOTEMS - i + buttonIndex);
			button.slot = 0;

			button:Hide();
		end
	end
	if ( self.activeTotems > 0 ) then
		self:Show();
	else
		self:Hide();
	end
	PlayerFrame_AdjustAttachments();
end

TotemButtonMixin = {};

function TotemButtonMixin:OnLoad()
	self.duration:SetPoint("TOP", self, "BOTTOM", 0, TOTEM_BUTTON_DURATION_TEXT_VERTICAL_OFFSET);

	self:RegisterForClicks("RightButtonUp");
end

function TotemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetTotem(self.slot);
end

function TotemButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function TotemButtonMixin:OnClick(mouseButton)
	if (mouseButton == "RightButton") then
		DestroyTotem(self.slot);
	end
end

function TotemButtonMixin:OnUpdate(elapsed)
	AuraButton_UpdateDuration(self, GetTotemTimeLeft(self.slot));
	if (GameTooltip:IsOwned(self)) then
		GameTooltip:SetTotem(self.slot);
	end
end

function TotemButtonMixin:Update(startTime, duration, icon)
	if (duration > 0) then
		self.icon.texture:SetTexture(icon);
		self.icon.texture:Show();
		CooldownFrame_Set(self.icon.cooldown, startTime, duration, 1);
		self.icon.cooldown:Show();
		self:SetScript(
			"OnUpdate",
			function()
				self:OnUpdate();
			end);
		self:Show();
	else
		self.icon.texture:Hide();
		self.duration:Hide();
		self.icon.cooldown:Hide();
		self:SetScript("OnUpdate", nil);
		self:Hide();
	end
end