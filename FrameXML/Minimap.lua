MINIMAPPING_TIMER = 5;
MINIMAPPING_FADE_TIMER = 0.5;
CURSOR_OFFSET_X = -7;
CURSOR_OFFSET_Y = -9;

function Minimap_OnLoad()
	MiniMapPing.fadeOut = nil;
	this:SetSequence(0);
	this:RegisterEvent("MINIMAP_PING");
	this:RegisterEvent("MINIMAP_UPDATE_ZOOM");
end

function ToggleMinimap()
	if(Minimap:IsVisible()) then
		PlaySound("igMiniMapClose");
		Minimap:Hide();
	else
		PlaySound("igMiniMapOpen");
		Minimap:Show();
	end
end

function Minimap_Update()
	MinimapZoneText:SetText(GetMinimapZoneText());
	local pvpType, factionName, isArena = GetZonePVPInfo();
	if ( isArena ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		MinimapZoneText:SetTextColor(0.1, 1.0, 0.1);
	elseif ( pvpType == "hostile" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "contested" ) then
		MinimapZoneText:SetTextColor(1.0, 0.7, 0);
	else
		MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	if ( GameTooltip:IsOwned(MinimapZoneTextButton) ) then
		GameTooltip:SetOwner(MinimapZoneTextButton, "ANCHOR_LEFT");
		GameTooltip:AddLine(GetMinimapZoneText(), "", 1.0, 1.0, 1.0);
		if ( (pvpType == "friendly") or (pvpType == "hostile") ) then
			GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), "", 1.0, 1.0, 1.0);
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine(CONTESTED_TERRITORY, "", 1.0, 1.0, 1.0);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, "", 1.0, 1.0, 1.0);
		end
		GameTooltip:Show();
	end
end

function Minimap_OnEvent()
	if ( event == "MINIMAP_PING" ) then
		Minimap_SetPing(arg2, arg3, 1);
		Minimap.timer = MINIMAPPING_TIMER;
	elseif ( event == "MINIMAP_UPDATE_ZOOM" ) then
		MinimapZoomIn:Enable();
		MinimapZoomOut:Enable();
		local zoom = Minimap:GetZoom();
		if ( zoom == (Minimap:GetZoomLevels() - 1) ) then
			MinimapZoomIn:Disable();
		elseif ( zoom == 0 ) then
			MinimapZoomOut:Disable();
		end
	end
end

function Minimap_OnUpdate(elapsed)
	if ( Minimap.timer > 0 ) then
		Minimap.timer = Minimap.timer - elapsed;
		if ( Minimap.timer <= 0 ) then
			MiniMapPing_FadeOut();
		else
			Minimap_SetPing(Minimap:GetPingPosition());
		end
	elseif ( MiniMapPing.fadeOut ) then
		MiniMapPing.fadeOutTimer = MiniMapPing.fadeOutTimer - elapsed;
		if ( MiniMapPing.fadeOutTimer > 0 ) then
			MiniMapPing:SetAlpha(255 * (MiniMapPing.fadeOutTimer/MINIMAPPING_FADE_TIMER))
		else
			MiniMapPing.fadeOut = nil;
			MiniMapPing:Hide();
		end
	end
 end

function Minimap_SetPing(x, y, playSound)
	x = x * Minimap:GetWidth();
	y = y * Minimap:GetHeight();
	
	if ( sqrt(x * x + y * y) < (Minimap:GetWidth() / 2) ) then
		MiniMapPing:SetPoint("CENTER", "Minimap", "CENTER", x, y);
		MiniMapPing:SetAlpha(255);
		MiniMapPing:Show();
		if ( playSound ) then
			PlaySound("MapPing");
		end
	else
		MiniMapPing:Hide();
	end
	
end

function MiniMapPing_FadeOut()
	MiniMapPing.fadeOut = 1;
	MiniMapPing.fadeOutTimer = MINIMAPPING_FADE_TIMER;
end

function Minimap_ZoomInClick()
	MinimapZoomOut:Enable();
	PlaySound("igMiniMapZoomIn");
	Minimap:SetZoom(Minimap:GetZoom() + 1);
	if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
		MinimapZoomIn:Disable();
	end
end

function Minimap_ZoomOutClick()
	MinimapZoomIn:Enable();
	PlaySound("igMiniMapZoomOut");
	Minimap:SetZoom(Minimap:GetZoom() - 1);
	if(Minimap:GetZoom() == 0) then
		MinimapZoomOut:Disable();
	end
end

function Minimap_OnClick()
	local x, y = GetCursorPosition();
	x = x / this:GetScale();
	y = y / this:GetScale();

	local cx, cy = this:GetCenter();
	x = x + CURSOR_OFFSET_X - cx;
	y = y + CURSOR_OFFSET_Y - cy;
	if ( sqrt(x * x + y * y) < (this:GetWidth() / 2) ) then
		Minimap:PingLocation(x, y);
	end
end

function Minimap_ZoomIn()
	MinimapZoomIn:Click();
end

function Minimap_ZoomOut()
	MinimapZoomOut:Click();
end