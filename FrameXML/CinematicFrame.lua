
function CinematicFrame_OnLoad(self)
	self:RegisterEvent("CINEMATIC_START");
	self:RegisterEvent("CINEMATIC_STOP");

	--For subtitles. We only support say/yell right now.
	self:RegisterEvent("CHAT_MSG_SAY");
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY");
	self:RegisterEvent("CHAT_MSG_YELL");
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL");

	local width = GetScreenWidth();
	local height = GetScreenHeight();
	
	if ( width / height > 4 / 3) then
		local desiredHeight = width / 2;
		if ( desiredHeight > height ) then
			desiredHeight = height;
		end
		
		local blackBarHeight = ( height - desiredHeight ) / 2;

		UpperBlackBar:SetHeight( blackBarHeight );
		UpperBlackBar:SetWidth( width );
		LowerBlackBar:SetHeight( blackBarHeight );
		LowerBlackBar:SetWidth( width );
	end
end

function CinematicFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "CINEMATIC_START" ) then
		for i=1, #self.Subtitles do
			self.Subtitles[i]:SetText("");
			self.Subtitles[i]:Hide();
		end
		self.isRealCinematic = arg1;	--If it isn't real, it's a vehicle cinematic
		self.closeDialog:Hide();
		ShowUIPanel(self, 1);
		RaidNotice_Clear(self.raidBossEmoteFrame);
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);
		RaidNotice_Clear(RaidBossEmoteFrame);	--Clear the normal boss emote frame. If there are any messages left over from the cinematic, we don't want to show them.
	elseif ( event == "CHAT_MSG_SAY" or event == "CHAT_MSG_MONSTER_SAY" or
		event == "CHAT_MSG_YELL" or event == "CHAT_MSG_MONSTER_YELL" ) then
		local message, sender, lang, channel, target, flag, zone, localid, name, instanceId, lineId, guidString, bnId, isMobile, isSubtitle = ...;
		if ( isSubtitle ) then
			local body;
			if ( lang ~= "" and lang ~= GetDefaultLanguage() ) then
				local languageHeader = "["..lang.."]";
				body = format(SUBTITLE_FORMAT, sender, languageHeader..message);
			else
				body = format(SUBTITLE_FORMAT, sender, message);
			end
				
			local chatType = string.match(event, "CHAT_MSG_(.*)");
			CinematicFrame_AddSubtitle(chatType, body);
		end
	end
end

function CinematicFrame_AddSubtitle(chatType, body)
	local fontString = nil;
	for i=1, #CinematicFrame.Subtitles do
		if ( not CinematicFrame.Subtitles[i]:IsShown() ) then
			fontString = CinematicFrame.Subtitles[i];
			break;
		end
	end

	if ( not fontString ) then
		--Scroll everything up. 
		for i=1, #CinematicFrame.Subtitles - 1 do
			CinematicFrame.Subtitles[i]:SetText(CinematicFrame.Subtitles[i + 1]:GetText());
		end
		fontString = CinematicFrame.Subtitles[#CinematicFrame.Subtitles];
	end

	fontString:SetText(body);
	fontString:Show();
end

function CinematicFrame_OnKeyDown(self, key)
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		if ( self.isRealCinematic and IsGMClient() ) then
			StopCinematic();
		elseif ( self.isRealCinematic or CanExitVehicle() or CanCancelScene() ) then	--If it's not a real cinematic, we can cancel it by leaving the vehicle.
			self.closeDialog:Show();
		end
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	end
end

function CinematicFrame_CancelCinematic()
	if ( CinematicFrame.isRealCinematic ) then
		StopCinematic();
	elseif ( CanCancelScene() ) then
		CancelScene();
	else
		VehicleExit();
	end
end
