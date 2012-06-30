


local numVehicleIndicatorButtons = 0;
function VehicleSeatIndicator_SetUpVehicle(vehicleIndicatorID)
	if ( vehicleIndicatorID == VehicleSeatIndicator.currSkin ) then
		return;
	end
	
	if ( vehicleIndicatorID == 0 ) then
		VehicleSeatIndicator_UnloadTextures();
		return;
	end
	
	local backgroundTexture, numSeatIndicators = GetVehicleUIIndicator(vehicleIndicatorID);
	
	VehicleSeatIndicator.currSkin = vehicleIndicatorID;
	
	VehicleSeatIndicatorBackgroundTexture:SetTexture(backgroundTexture);
	
	--These have been hard-coded in for now. FIXME (need something returned from GetVehicleUIIndicator that gives height/width)
	local totalHeight = 128; --VehicleSeatIndicatorBackgroundTexture:GetFileHeight();
	local totalWidth = 128; --VehicleSeatIndicatorBackgroundTexture:GetFileWidth();
	VehicleSeatIndicator:SetHeight(totalHeight);
	VehicleSeatIndicator:SetWidth(totalWidth);
	
	for i=1, numSeatIndicators do
		local button;
		if ( i > numVehicleIndicatorButtons ) then
			button = CreateFrame("Button", "VehicleSeatIndicatorButton"..i, VehicleSeatIndicator, "VehicleSeatIndicatorButtonTemplate");
			button:SetID(i)
			numVehicleIndicatorButtons = i;
		else
			button = _G["VehicleSeatIndicatorButton"..i];
		end
		
		local virtualSeatIndex, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleIndicatorID, i);
		
		button.virtualID = virtualSeatIndex;
		button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset*totalWidth, -yOffset*totalHeight);
		button:Show();
	end	
	
	for i=numSeatIndicators+1, numVehicleIndicatorButtons do
		local button = _G["VehicleSeatIndicatorButton"..i];
		button:Hide();
	end
	
	VehicleSeatIndicator:Show();
	DurabilityFrame_SetAlerts();
	VehicleSeatIndicator_Update();
	
	UIParent_ManageFramePositions();
end

function VehicleSeatIndicator_UnloadTextures()
	VehicleSeatIndicatorBackgroundTexture:SetTexture(nil);
	VehicleSeatIndicator:Hide()
	VehicleSeatIndicator.currSkin = nil;
	DurabilityFrame_SetAlerts();
	
	UIParent_ManageFramePositions();
end

local function SeatIndicator_PulseFunc(self, elapsed)
	return abs(sin(elapsed*360));
end

local SeatIndicator_PulseTable = {
	totalTime = 2,
	updateFunc = "SetAlpha",
	getPosFunc = SeatIndicator_PulseFunc,
}

function SeatIndicator_Pulse(self, isPlayer)
	self:Show();
	self:SetAlpha(0);
	SetUpAnimation(self, SeatIndicator_PulseTable, self.Hide);
end

function VehicleSeatIndicator_OnLoad(self)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA");
	self:RegisterEvent("UNIT_ENTERING_VEHICLE");
	self:RegisterEvent("VEHICLE_PASSENGERS_CHANGED");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_Initialize( VehicleSeatIndicatorDropDown, VehicleSeatIndicatorDropDown_Initialize, "MENU");
end

function VehicleSeatIndicator_OnEvent(self, event, ...)
	local arg1, arg2, _, _, _, arg6 = ...;
	if ( event == "UNIT_ENTERED_VEHICLE" and arg1 == "player" ) then
		VehicleSeatIndicator_SetUpVehicle(arg6);
	elseif ( event == "PLAYER_GAINS_VEHICLE_DATA" and arg1 == "player" ) then
		VehicleSeatIndicator_SetUpVehicle(arg2);
	elseif ( event == "UNIT_ENTERING_VEHICLE" and arg1 == "player" ) then
		self.hasPulsedPlayer = false;
	elseif ( event == "VEHICLE_PASSENGERS_CHANGED" ) then
		VehicleSeatIndicator_Update();
	elseif ( (event == "UNIT_EXITED_VEHICLE" and arg1 == "player") or
	(event == "PLAYER_ENTERING_WORLD" and VehicleSeatIndicator.currSkin and UnitVehicleSeatCount("player") == 0 ) or
	(event == "PLAYER_LOSES_VEHICLE_DATA" and arg1 == "player") ) then
		VehicleSeatIndicator_UnloadTextures();
	end
end
function VehicleSeatIndicator_Update()
	if ( not VehicleSeatIndicator.currSkin ) then
		return;
	end
	for i=1, numVehicleIndicatorButtons do
		local button = _G["VehicleSeatIndicatorButton"..i];
		if ( button:IsShown() ) then
			local controlType, occupantName = UnitVehicleSeatInfo("player", button.virtualID);
			if ( occupantName ) then
				button.occupantName = occupantName;
				if ( occupantName == UnitName("player") ) then
					_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Show();
					_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Hide();
					if ( not VehicleSeatIndicator.hasPulsedPlayer ) then
						SeatIndicator_Pulse(_G["VehicleSeatIndicatorButton"..i.."PulseTexture"], true);
						VehicleSeatIndicator.hasPulsedPlayer = true;
					end
				else
					_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Hide();
					_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Show();
				end
			else
				_G["VehicleSeatIndicatorButton"..i.."PlayerIcon"]:Hide();
				_G["VehicleSeatIndicatorButton"..i.."AllyIcon"]:Hide();
			end
		end
	end
end

function VehicleSeatIndicatorButton_OnClick(self, button)
	local seatIndex = self.virtualID;
	if ( button == "RightButton" and CanEjectPassengerFromSeat(seatIndex)) then
		ToggleDropDownMenu(1, seatIndex, VehicleSeatIndicatorDropDown, self:GetName(), 0, -5);
	else
		UnitSwitchToVehicleSeat("player", seatIndex);
	end
end

function VehicleSeatIndicatorButton_OnEnter(self)
	if ( not self:IsEnabled() ) then
		return;
	end
	
	local controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo("player", self.virtualID);
	local highlight = _G[self:GetName().."Highlight"]
	
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

function VehicleSeatIndicatorButton_OnLeave(self)
	GameTooltip:Hide();
	SetCursor(nil);
end

function VehicleSeatIndicatorDropDown_OnClick()
	EjectPassengerFromSeat(UIDROPDOWNMENU_MENU_VALUE);
	PlaySound("UChatScrollButton");
end

function VehicleSeatIndicatorDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = EJECT_PASSENGER;
	info.func = VehicleSeatIndicatorDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end
