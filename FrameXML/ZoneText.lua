
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
	elseif ( pvpType == "combat" ) then
		pvpTextString:SetText(COMBAT_ZONE);
		pvpTextString:SetTextColor(1.0, 0.1, 0.1);
		ZoneTextString:SetTextColor(1.0, 0.1, 0.1);
		SubZoneTextString:SetTextColor(1.0, 0.1, 0.1);
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

function ZoneText_OnLoad(self)
	FadingFrame_OnLoad(self);
	FadingFrame_SetFadeInTime(self, ZoneFadeInDuration);
	FadingFrame_SetHoldTime(self, ZoneHoldDuration);
	FadingFrame_SetFadeOutTime(self, ZoneFadeOutDuration);
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self.zoneText = "";
	ZonePVPType = nil;
end

function ZoneText_OnEvent(self, event, ...)
	local showZoneText = false;	
	local zoneText = GetZoneText();
	if ( (zoneText ~= self.zoneText) or (event == "ZONE_CHANGED_NEW_AREA") ) then
		self.zoneText = zoneText;
		ZoneTextString:SetText( zoneText );
		showZoneText = true;
		SetZoneText( showZoneText );
		FadingFrame_Show( self );
	end
	
	local subzoneText = GetSubZoneText();
	if ( subzoneText == "" and not showZoneText) then
		subzoneText = zoneText;
	end
	SubZoneTextString:SetText( "" );

	if ( subzoneText == zoneText ) then
		showZoneText = false;
		if ( not self:IsShown() ) then
			SubZoneTextString:SetText( subzoneText );
			SetZoneText( showZoneText );
			FadingFrame_Show( SubZoneTextFrame );
		end
	else
		if (self:IsShown()) then
			showZoneText = true;
		end
		SubZoneTextString:SetText( subzoneText );
		SetZoneText( showZoneText );
		FadingFrame_Show( SubZoneTextFrame );
	end
end

function SubZoneText_OnLoad(self)
	FadingFrame_OnLoad(self);
	FadingFrame_SetFadeInTime(self, ZoneFadeInDuration);
	FadingFrame_SetHoldTime(self, ZoneHoldDuration);
	FadingFrame_SetFadeOutTime(self, ZoneFadeOutDuration);
	PVPArenaTextString:SetTextColor(1.0, 0.1, 0.1);
	SetZoneText(true);
	SubZoneTextString:SetText(GetSubZoneText());
end

AUTOFOLLOW_STATUS_FADETIME = 4.0;

function AutoFollowStatus_OnLoad(self)
	self:RegisterEvent("AUTOFOLLOW_BEGIN");
	self:RegisterEvent("AUTOFOLLOW_END");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function AutoFollowStatus_OnEvent(self, event, ...)
	if ( event == "AUTOFOLLOW_BEGIN" ) then
		local arg1 = ...;
		self.unit = arg1;
		self.fadeTime = nil;
		self:SetAlpha(1.0);
		AutoFollowStatusText:SetFormattedText(AUTOFOLLOWSTART,self.unit);
		self:Show();
	end
	if ( event == "AUTOFOLLOW_END" ) then
		self.fadeTime = AUTOFOLLOW_STATUS_FADETIME;
		AutoFollowStatusText:SetFormattedText(AUTOFOLLOWSTOP,self.unit);
		self:Show();
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:Hide();
	end
end

function AutoFollowStatus_OnUpdate(self, elapsed)
	if( self.fadeTime ) then
		if( elapsed >= self.fadeTime ) then
			self:Hide();
		else
			self.fadeTime = self.fadeTime - elapsed;
			local alpha = self.fadeTime / AUTOFOLLOW_STATUS_FADETIME;
			self:SetAlpha(alpha);
		end
	end
end
