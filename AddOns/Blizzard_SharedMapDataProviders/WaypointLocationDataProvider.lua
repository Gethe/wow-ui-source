WaypointLocationDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WaypointLocationDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	-- canvas handlers
	local priority = 90;
	self.onCanvasClickHandler = self.onCanvasClickHandler or function(mapCanvas, button, cursorX, cursorY) return self:OnCanvasClickHandler(button, cursorX, cursorY) end;
	mapCanvas:AddCanvasClickHandler(self.onCanvasClickHandler, priority);
	self.onPinMouseActionHandler = self.onPinMouseActionHandler or function(mapCanvas, mouseAction, button) return self:OnPinMouseActionHandler(mouseAction, button) end;
	mapCanvas:AddGlobalPinMouseActionHandler(self.onPinMouseActionHandler, priority);	
	self.cursorHandler = self.cursorHandler or
		function()
			if self:CanPlacePin() then
				return "MAP_PIN_CURSOR";
			end
		end
	;
	mapCanvas:AddCursorHandler(self.cursorHandler, priority);
	
	self:GetMap():RegisterCallback("WaypointLocationToggleUpdate", self.OnWayPointLocationToggleUpdate, self);
end

function WaypointLocationDataProviderMixin:OnRemoved(mapCanvas)
	mapCanvas:RemoveCursorHandler(self.cursorHandler);
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end
	
function WaypointLocationDataProviderMixin:OnShow()
	self:RegisterEvent("USER_WAYPOINT_UPDATED");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
end

function WaypointLocationDataProviderMixin:OnHide()
	self:UnregisterEvent("USER_WAYPOINT_UPDATED");
	self:UnregisterEvent("SUPER_TRACKING_CHANGED");
end

function WaypointLocationDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

function WaypointLocationDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("WaypointLocationPinTemplate");
	self.pin = nil;
end

function WaypointLocationDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	local mapID = self:GetMap():GetMapID();
	local posVector = C_Map.GetUserWaypointPositionForMap(mapID);
	if posVector then
		self.pin = self:GetMap():AcquirePin("WaypointLocationPinTemplate");
		self.pin:SetPosition(posVector:GetXY());
	end
end

function WaypointLocationDataProviderMixin:OnCanvasClickHandler(button, cursorX, cursorY)
	if self:CanPlacePin() then
		self:HandleClick();
		return true;
	end
	return false;
end

function WaypointLocationDataProviderMixin:OnPinMouseActionHandler(mouseAction, button)
	if button ~= "LeftButton" or mouseAction == MapCanvasMixin.MouseAction.Up or not self:CanPlacePin() then
		return false;
	end

	if mouseAction == MapCanvasMixin.MouseAction.Click then
		self:HandleClick();
	end
	-- do nothing on MapCanvasMixin.MouseAction.Down
	return true;
end

function WaypointLocationDataProviderMixin:HandleClick()
	if self.pin and self.pin:IsMouseOver() then
		C_Map.ClearUserWaypoint();
		C_SuperTrack.SetSuperTrackedUserWaypoint(false);
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_REMOVE);
	else
		local mapID = self:GetMap():GetMapID();
		if C_Map.CanSetUserWaypointOnMap(mapID) then
			if self.toggleActive then
				PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CLICK_TO_PLACE);
			else
				PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CONTROL_CLICK);
			end
			local scrollContainer = self:GetMap().ScrollContainer;
			local cursorX, cursorY = scrollContainer:NormalizeUIPosition(scrollContainer:GetCursorPosition());
			local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, cursorX, cursorY);
			C_Map.SetUserWaypoint(uiMapPoint);
			C_SuperTrack.SetSuperTrackedUserWaypoint(false);
		else
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, RED_FONT_COLOR:GetRGBA());
		end
	end
end

function WaypointLocationDataProviderMixin:OnWayPointLocationToggleUpdate(isActive)
	self.toggleActive = isActive;
end

function WaypointLocationDataProviderMixin:CanPlacePin()
	return self.toggleActive or IsControlKeyDown();
end

WaypointLocationPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WaypointLocationPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
end

function WaypointLocationPinMixin:OnAcquired()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_WAYPOINT_LOCATION");
	if C_SuperTrack.IsSuperTrackingUserWaypoint() then
		self.Icon:SetAtlas("Waypoint-MapPin-Tracked");
	else
		self.Icon:SetAtlas("Waypoint-MapPin-Untracked");
	end
end

function WaypointLocationPinMixin:OnMouseDownAction()
	self.Icon:SetPoint("CENTER", 2, -2);
end

function WaypointLocationPinMixin:OnMouseUpAction()
	self.Icon:SetPoint("CENTER", 0, 0);
end

function WaypointLocationPinMixin:OnMouseClickAction(mouseButton)
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(C_Map.GetUserWaypointHyperlink());
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CHAT_SHARE);
	elseif mouseButton == "LeftButton" then
		C_SuperTrack.SetSuperTrackedUserWaypoint(not C_SuperTrack.IsSuperTrackingUserWaypoint());
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK);
	end
end

function WaypointLocationPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4);
	GameTooltip_SetTitle(GameTooltip, MAP_PIN_SHARING);
	GameTooltip_AddNormalLine(GameTooltip, MAP_PIN_SHARING_TOOLTIP);
	GameTooltip_AddColoredLine(GameTooltip, MAP_PIN_REMOVE, GREEN_FONT_COLOR);
	GameTooltip:Show();
end

function WaypointLocationPinMixin:OnMouseLeave()
	GameTooltip:Hide();
end