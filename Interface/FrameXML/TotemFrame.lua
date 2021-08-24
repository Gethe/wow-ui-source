FIRE_TOTEM_SLOT = 1;
EARTH_TOTEM_SLOT = 2;
WATER_TOTEM_SLOT = 3;
AIR_TOTEM_SLOT = 4;

MAX_TOTEMS = 4;

TOTEM_PRIORITIES =
{
	AIR_TOTEM_SLOT,
	WATER_TOTEM_SLOT,
	EARTH_TOTEM_SLOT,
	FIRE_TOTEM_SLOT
};

function TotemFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_TOTEM_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	TotemFrame_Update();
end

function TotemFrame_Update()
	if ( PetFrame and PetFrame:IsShown() ) then
		TotemFrame:Hide();
		return;
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
			button = getglobal("TotemFrameTotem"..buttonIndex);
			button.slot = slot;
			TotemButton_Update(button, startTime, duration, icon);
			buttonIndex = buttonIndex + 1;

			if ( button:IsShown() ) then
				TotemFrame.activeTotems = TotemFrame.activeTotems + 1;
			end
		else
			button = getglobal("TotemFrameTotem"..MAX_TOTEMS - i + buttonIndex);
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
			button = getglobal("TotemFrameTotem"..i);
			if ( button.slot == slot ) then
				local previouslyShown = button:IsShown();
				TotemButton_Update(button, startTime, duration, icon);
				-- check to see if we should be showing or hiding the parent frame
				if ( previouslyShown ) then
					if ( not button:IsShown() ) then
						TotemFrame.activeTotems = TotemFrame.activeTotems - 1;
					end
				else
					if ( button:IsShown() ) then
						TotemFrame.activeTotems = TotemFrame.activeTotems + 1;
					end
				end
				if ( TotemFrame.activeTotems > 0 ) then
					TotemFrame:Show();
				else
					TotemFrame:Hide();
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

function TotemButton_OnUpdate(button, elapsed)
	AuraButton_UpdateDuration(button, GetTotemTimeLeft(button.slot));
	if ( GameTooltip:IsOwned(button) ) then
		GameTooltip:SetTotem(button.slot);
	end
end

function TotemButton_Update(button, startTime, duration, icon)
	local buttonName = button:GetName();
	local buttonIcon = getglobal(buttonName.."IconTexture");
	local buttonDuration = getglobal(buttonName.."Duration");
	button.duration = buttonDuration;
	local buttonCooldown = getglobal(buttonName.."IconCooldown");

	if ( duration > 0 ) then
		buttonIcon:SetTexture(icon);
		buttonIcon:Show();
		CooldownFrame_Set(buttonCooldown, startTime, duration, 1);
		--CooldownFrame_SetTimer(buttonCooldown, startTime, duration, 1);
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
