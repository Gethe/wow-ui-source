
ZoneFadeInDuration = 0.5;
ZoneHoldDuration = 1.0;
ZoneFadeOutDuration = 2.0;
ZonePVPType = nil;

function SetZoneText(showZone)
	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
	PVPArenaTextString:SetText("");
	PVPInfoTextString:SetText("");
	local pvpTextString = PVPInfoTextString;
	if ( isSubZonePvP ) then
		pvpTextString = PVPArenaTextString;
	end

	if ( pvpType == "sanctuary" ) then
		pvpTextString:SetText(SANCTUARY_TERRITORY);
		pvpTextString:SetTextColor(0.41, 0.8, 0.94);
		ZoneTextString:SetTextColor(0.41, 0.8, 0.94);
		SubZoneTextString:SetTextColor(0.41, 0.8, 0.94);
	elseif ( pvpType == "arena" ) then
		pvpTextString:SetText(FREE_FOR_ALL_TERRITORY);
		pvpTextString:SetTextColor(1.0, 0.1, 0.1);
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1);
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		pvpTextString:SetFormattedText(FACTION_CONTROLLED_TERRITORY, factionName);
		pvpTextString:SetTextColor(0.1, 1.0, 0.1);
		ZoneTextString:SetTextColor(0.1, 1.0, 0.1);
		SubZoneTextString:SetTextColor(0.1, 1.0, 0.1);
	elseif ( pvpType == "hostile" ) then
		pvpTextString:SetFormattedText(FACTION_CONTROLLED_TERRITORY, factionName);
		pvpTextString:SetTextColor(1.0, 0.1, 0.1);
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1);
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "contested" ) then
		pvpTextString:SetText(CONTESTED_TERRITORY);
		pvpTextString:SetTextColor(1.0, 0.7, 0);
		ZoneTextString:SetTextColor(1.0, 0.7, 0);
		SubZoneTextString:SetTextColor(1.0, 0.7, 0);
	else
		ZoneTextString:SetTextColor(1.0, 0.9294, 0.7607);
		SubZoneTextString:SetTextColor(1.0, 0.9294, 0.7607);
	end

	if ( ZonePVPType ~= pvpType ) then
		ZonePVPType = pvpType;
--				FadingFrame_Show(ZoneTextFrame);
	elseif ( not showZone ) then
		PVPInfoTextString:SetText("");
		SubZoneTextString:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, 0);
	end

	if ( PVPInfoTextString:GetText() == "" ) then
		SubZoneTextString:SetPoint("TOP", "ZoneTextString", "BOTTOM", 0, 0);
	else
		SubZoneTextString:SetPoint("TOP", "PVPInfoTextString", "BOTTOM", 0, 0);
	end
end

function ZoneText_OnLoad()
	FadingFrame_OnLoad();
	FadingFrame_SetFadeInTime(ZoneTextFrame, ZoneFadeInDuration);
	FadingFrame_SetHoldTime(ZoneTextFrame, ZoneHoldDuration);
	FadingFrame_SetFadeOutTime(ZoneTextFrame, ZoneFadeOutDuration);
	ZoneTextFrame:RegisterEvent("ZONE_CHANGED");
	ZoneTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
	ZoneTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	ZoneTextFrame.zoneText = "";
	ZonePVPType = nil;
end

function ZoneText_OnEvent()
	local showZoneText = false;	
	local zoneText = GetZoneText();
	if ( (zoneText ~= ZoneTextFrame.zoneText) or (event == "ZONE_CHANGED_NEW_AREA") ) then
		ZoneTextFrame.zoneText = zoneText;
		ZoneTextString:SetText( zoneText );
		showZoneText = true;
		SetZoneText( showZoneText );
		FadingFrame_Show( ZoneTextFrame );
	end
	
	local subzoneText = GetSubZoneText();
	if ( subzoneText == "" and not showZoneText) then
		subzoneText = zoneText;
	end
	SubZoneTextString:SetText( "" );

	if ( subzoneText == zoneText ) then
		showZoneText = false;
		if ( not ZoneTextFrame:IsShown() ) then
			SubZoneTextString:SetText( subzoneText );
			SetZoneText( showZoneText );
			FadingFrame_Show( SubZoneTextFrame );
		end
	else
		if (ZoneTextFrame:IsShown()) then
			showZoneText = true;
		end
		SubZoneTextString:SetText( subzoneText );
		SetZoneText( showZoneText );
		FadingFrame_Show( SubZoneTextFrame );
	end
end

function SubZoneText_OnLoad()
	FadingFrame_OnLoad();
	FadingFrame_SetFadeInTime(SubZoneTextFrame, ZoneFadeInDuration);
	FadingFrame_SetHoldTime(SubZoneTextFrame, ZoneHoldDuration);
	FadingFrame_SetFadeOutTime(SubZoneTextFrame, ZoneFadeOutDuration);
	PVPArenaTextString:SetTextColor(1.0, 0.1, 0.1);
	SetZoneText(true);
	SubZoneTextString:SetText(GetSubZoneText());
end

AUTOFOLLOW_STATUS_FADETIME = 4.0;

function AutoFollowStatus_OnLoad()
	this:RegisterEvent("AUTOFOLLOW_BEGIN");
	this:RegisterEvent("AUTOFOLLOW_END");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function AutoFollowStatus_OnEvent(event)
	if ( event == "AUTOFOLLOW_BEGIN" ) then
		this.unit = arg1;
		this.fadeTime = nil;
		this:SetAlpha(1.0);
		AutoFollowStatusText:SetFormattedText(AUTOFOLLOWSTART,this.unit);
		this:Show();
	end
	if ( event == "AUTOFOLLOW_END" ) then
		this.fadeTime = AUTOFOLLOW_STATUS_FADETIME;
		AutoFollowStatusText:SetFormattedText(AUTOFOLLOWSTOP,this.unit);
		this:Show();
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this:Hide();
	end
end

function AutoFollowStatus_OnUpdate(elapsed)
	if( this.fadeTime ) then
		if( elapsed >= this.fadeTime ) then
			this:Hide();
		else
			this.fadeTime = this.fadeTime - elapsed;
			local alpha = this.fadeTime / AUTOFOLLOW_STATUS_FADETIME;
			this:SetAlpha(alpha);
		end
	end
end
