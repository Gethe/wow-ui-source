local function VehicleSeatIndicatorDropdown_OnClick()
	EjectPassengerFromSeat(UIDROPDOWNMENU_MENU_VALUE);
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

local function  VehicleSeatIndicatorDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = EJECT_PASSENGER;
	info.func = VehicleSeatIndicatorDropdown_OnClick;
	UIDropDownMenu_AddButton(info);
end

VehicleSeatIndicatorMixin = {};

function VehicleSeatIndicatorMixin:OnLoad()
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA");
	self:RegisterEvent("UNIT_ENTERING_VEHICLE");
	self:RegisterEvent("VEHICLE_PASSENGERS_CHANGED");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_Initialize(self.DropDown, VehicleSeatIndicatorDropdown_Initialize, "MENU");
end

function VehicleSeatIndicatorMixin:OnEvent(event, ...)
	local unitToken = ...;
	if ( event == "UNIT_ENTERED_VEHICLE" and unitToken == "player" ) then
		local vehicleIndicatorID = select(4, ...);
		self:SetupVehicle(vehicleIndicatorID);
	elseif ( event == "PLAYER_GAINS_VEHICLE_DATA" and unitToken == "player" ) then
		local vehicleIndicatorID = select(2, ...);
		self:SetupVehicle(vehicleIndicatorID);
	elseif ( event == "UNIT_ENTERING_VEHICLE" and unitToken == "player" ) then
		self.hasPulsedPlayer = false;
	elseif ( event == "VEHICLE_PASSENGERS_CHANGED" ) then
		self:Update();
	elseif ( (event == "UNIT_EXITED_VEHICLE" and unitToken == "player") or
			 (event == "PLAYER_ENTERING_WORLD" and self.currSkin and UnitVehicleSeatCount("player") == 0 ) or
			 (event == "PLAYER_LOSES_VEHICLE_DATA" and unitToken == "player") ) then
		self:UnloadTextures();
	end
end

function VehicleSeatIndicatorMixin:Update()
	if ( not self.currSkin ) then
		return;
	end
	for _, button in ipairs(self.buttons) do
		if ( button:IsShown() ) then
			local controlType, occupantName = UnitVehicleSeatInfo("player", button.virtualID);
			if ( occupantName ) then
				button.occupantName = occupantName;
				if ( occupantName == UnitName("player") ) then
					button.PlayerIcon:Show();
					button.AllyIcon:Hide();
					if ( not self.hasPulsedPlayer ) then
						button:Pulse();
						self.hasPulsedPlayer = true;
					end
				else
					button.PlayerIcon:Hide();
					button.AllyIcon:Show();
				end
			else
				button.PlayerIcon:Hide();
				button.AllyIcon:Hide();
			end
		end
	end
end

function VehicleSeatIndicatorMixin:HideButtons()
	if not self.buttons then
		return;
	end

	for _, button in ipairs(self.buttons) do
		button:Hide();
	end
end

function VehicleSeatIndicatorMixin:GetButton(index)
	if self.buttons and self.buttons[index] then
		return self.buttons[index];
	end

	return CreateFrame("Button", "VehicleSeatIndicatorButton"..index, self, "VehicleSeatIndicatorButtonTemplate");
end

function VehicleSeatIndicatorMixin:SetupVehicle(vehicleIndicatorID)
	if ( vehicleIndicatorID == self.currSkin ) then
		return;
	end

	if ( vehicleIndicatorID == 0 ) then
		self:UnloadTextures();
		return;
	end

	local backgroundTexture, numSeatIndicators = GetVehicleUIIndicator(vehicleIndicatorID);

	self.currSkin = vehicleIndicatorID;

	self.BackgroundTexture:SetTexture(backgroundTexture);

	--These have been hard-coded in for now. FIXME (need something returned from GetVehicleUIIndicator that gives height/width)
	local totalHeight = 128; --self.BackgroundTexture:GetFileHeight();
	local totalWidth = 128; --self.BackgroundTexture:GetFileWidth();
	self:SetHeight(totalHeight);
	self:SetWidth(totalWidth);
	self:HideButtons();

	for i = 1, numSeatIndicators do
		local virtualSeatIndex, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleIndicatorID, i);
		local button = self:GetButton(i);
		button:SetID(i);
		button.virtualID = virtualSeatIndex;
		button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset*totalWidth, -yOffset*totalHeight);
		button:Show();
	end

	self:UpdateShownState();
	DurabilityFrame:SetAlerts();
	self:Update();

	UIParent_ManageFramePositions();
end

function VehicleSeatIndicatorMixin:UnloadTextures()
	self.BackgroundTexture:SetTexture(nil);
	self.currSkin = nil;
	self:HideButtons();
	self:UpdateShownState();
	DurabilityFrame:SetAlerts();

	UIParent_ManageFramePositions();
end

function VehicleSeatIndicatorMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function VehicleSeatIndicatorMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self.currSkin);
end

VehicleSeatIndicatorButtonMixin = {};

function VehicleSeatIndicatorButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.Highlight:SetAlpha(0.5);
end

function VehicleSeatIndicatorButtonMixin:OnClick(button)
	local seatIndex = self.virtualID;
	if ( button == "RightButton" and CanEjectPassengerFromSeat(seatIndex)) then
		ToggleDropDownMenu(1, seatIndex, VehicleSeatIndicator.DropDown, self:GetName(), 0, -5);
	else
		UnitSwitchToVehicleSeat("player", seatIndex);
	end
end

function VehicleSeatIndicatorButtonMixin:OnEnter()
	if ( not self:IsEnabled() ) then
		return;
	end

	local controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo("player", self.virtualID);
	if (serverName and serverName ~= "") then
		occupantName = format(FULL_PLAYER_NAME, occupantName, serverName);
	end
	local highlight = self.Highlight;

	if ( not UnitUsingVehicle("player") ) then	--UnitUsingVehicle also returns true when we are transitioning between seats in a vehicle.
		highlight:Hide();
		if ( occupantName ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		end
		return;
	end

	if ( not canSwitchSeats or not CanSwitchVehicleSeat() ) then
		highlight:Hide();
		SetCursor(nil);
		if ( occupantName ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		end
	elseif ( controlType == "None" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\vehichleCursor");
		end
	elseif ( controlType == "Root" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\Driver");
		end
	elseif ( controlType == "Child" ) then
		if ( occupantName ) then
			highlight:Hide();
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(occupantName);
		else
			highlight:Show();
			SetCursor("Interface\\CURSOR\\Gunner");
		end
	end
end

function VehicleSeatIndicatorButtonMixin:OnLeave()
	GameTooltip:Hide();
	SetCursor(nil);
end

local function SeatIndicator_PulseFunc(self, elapsed)
	return abs(sin(elapsed*360));
end
local SeatIndicator_PulseTable = {
	totalTime = 2,
	updateFunc = "SetAlpha",
	getPosFunc = SeatIndicator_PulseFunc,
}
function VehicleSeatIndicatorButtonMixin:Pulse()
	local pulseTexture = self.PulseTexture;
	pulseTexture:Show();
	pulseTexture:SetAlpha(0);
	SetUpAnimation(pulseTexture, SeatIndicator_PulseTable, pulseTexture.Hide);
end