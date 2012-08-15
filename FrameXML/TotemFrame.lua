
function TotemFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");	

	local _, class = UnitClass("player");
	if ( class == "DEATHKNIGHT" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 65, -55);
	elseif ( class == "WARLOCK" ) then
		TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
	end
end

function TotemFrame_Update()
	local _, class = UnitClass("player");
	local priorities = STANDARD_TOTEM_PRIORITIES;
	if (class == "SHAMAN") then
		priorities = SHAMAN_TOTEM_PRIORITIES;
	end
	
	local hasPet = PetFrame and PetFrame:IsShown();
	if ( class == "PALADIN" or class == "DEATHKNIGHT"  ) then
		if ( hasPet ) then
			TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
		else
			TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 67, -63);
		end
	elseif ( class == "DRUID" ) then
		local form  = GetShapeshiftFormID();
		if ( form == MOONKIN_FORM or not form ) then
			if ( GetSpecialization() == 1 ) then
				TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 115, -88);
			else
				TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 99, 38);
			end
		elseif ( form == BEAR_FORM or form == CAT_FORM ) then
			TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 99, -78);
		else
			TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 99, 38);
		end
	elseif ( class == "MONK" ) then
		TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
	elseif ( class == "MAGE" ) then
		TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 50, -75);
	elseif ( hasPet  and class ~= "SHAMAN" and class ~= "WARLOCK" ) then
		TotemFrame:Hide();
		return;
	end

	local haveTotem, name, startTime, duration, icon;
	local slot;
	local button;
	local buttonIndex = 1;
	TotemFrame.activeTotems = 0;
	for i=1, MAX_TOTEMS do
		slot = priorities[i];
		haveTotem, name, startTime, duration, icon = GetTotemInfo(slot);
		if ( haveTotem ) then
			button = _G["TotemFrameTotem"..buttonIndex];
			button.slot = slot;
			TotemButton_Update(button, startTime, duration, icon);

			if ( button:IsShown() ) then
				TotemFrame.activeTotems = TotemFrame.activeTotems + 1;
			end

			buttonIndex = buttonIndex + 1;
		else
			button = _G["TotemFrameTotem"..MAX_TOTEMS - i + buttonIndex];
			button.slot = 0;
			button:Hide();
		end
	end
	if ( TotemFrame.activeTotems > 0 ) then
		TotemFrame:Show();
	else
		TotemFrame:Hide();
	end
	TotemFrame_AdjustPetFrame();
	PlayerFrame_AdjustAttachments();
end

function TotemFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_TOTEM_UPDATE" ) then
		local slot = ...;
		if ( slot <= MAX_TOTEMS ) then
			local haveTotem, name, startTime, duration, icon = GetTotemInfo(slot);
			local button;
			for i=1, MAX_TOTEMS do
				button = _G["TotemFrameTotem"..i];
				if ( button.slot == slot ) then
					local previouslyShown = button:IsShown();
					TotemButton_Update(button, startTime, duration, icon);
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
					TotemFrame_AdjustPetFrame();
					return;
				end
			end
		end
	end
	TotemFrame_Update();
end

function TotemButton_OnClick(self, mouseButton)
	if ( mouseButton == "RightButton" ) then
		DestroyTotem(self.slot);
	end
end

function TotemButton_OnLoad(self)
	self:RegisterForClicks("RightButtonUp");
end

function TotemButton_OnUpdate(button, elapsed)
	AuraButton_UpdateDuration(button, GetTotemTimeLeft(button.slot));
	if ( GameTooltip:IsOwned(button) ) then
		GameTooltip:SetTotem(button.slot);
	end
end

function TotemButton_Update(button, startTime, duration, icon)
	local buttonName = button:GetName();
	local buttonIcon = _G[buttonName.."IconTexture"];
	local buttonDuration = _G[buttonName.."Duration"];
	local buttonCooldown = _G[buttonName.."IconCooldown"];

	if ( duration > 0 ) then
		buttonIcon:SetTexture(icon);
		buttonIcon:Show();
		CooldownFrame_SetTimer(buttonCooldown, startTime, duration, 1);
		buttonCooldown:Show();
		button:SetScript("OnUpdate", TotemButton_OnUpdate);
		button:Show();
	else
		buttonIcon:Hide();
		buttonDuration:Hide();
		buttonCooldown:Hide();
		button:SetScript("OnUpdate", nil);
		button:Hide();
	end
end

function TotemFrame_AdjustPetFrame()
	local _, class = UnitClass("player");
	if ( class == "WARLOCK" ) then
		if ( PetFrame and PetFrame:IsShown() and TotemFrameTotem2:IsShown() ) then
			PetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 93, -90);
		else
			PetFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 60, -90);
		end
	end
end
