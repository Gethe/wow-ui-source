
function TotemFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	local _, class = UnitClass("player");
	if ( class == "DEATHKNIGHT" ) then
		self:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 65, -55);
	end
end

function TotemFrame_Update()
	local _, class = UnitClass("player");
	if ( PetFrame and PetFrame:IsShown() ) then
		if ( class == "DEATHKNIGHT" ) then
			TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 28, -75);
		elseif ( class == "SHAMAN" ) then
			--Nothing!
		else
			TotemFrame:Hide();
			return;
		end
	elseif ( class == "DEATHKNIGHT" ) then
		TotemFrame:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 65, -55);
	end

	local haveTotem, name, startTime, duration, icon;
	local slot;
	local button;
	local buttonIndex = 1;
	TotemFrame.activeTotems = 0;
	for i=1, MAX_TOTEMS do
		slot = TOTEM_PRIORITIES[i];
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
end

function TotemFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		TotemFrame_Update();
	elseif ( event == "PLAYER_TOTEM_UPDATE" ) then
		local slot = ...;
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
				return;
			end
		end

		-- The assumption is that we have gained a totem that we did not previously have
		-- so the totem buttons have to be reordered. It's easier to just do a full update
		-- rather than sorting the buttons since there aren't that many.
		TotemFrame_Update();
	end
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
