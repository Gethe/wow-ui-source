
local AspectRatios = {};

AspectRatios[Enum.CameraModeAspectRatio.Default] = {x = 0, y = 0};
AspectRatios[Enum.CameraModeAspectRatio.LegacyLetterbox] = {x = 16, y = 9};
AspectRatios[Enum.CameraModeAspectRatio.HighDefinition_16_X_9] = {x = 16, y = 9};
AspectRatios[Enum.CameraModeAspectRatio.Cinemascope_2_Dot_4_X_1] = {x = 2.4, y = 1};

local DefaultAspectRatio = {x = 16, y = 9};

function CinematicFrame_OnDisplaySizeChanged(self)
	-- called when the display changes and when the cinematic camera wants to 
	-- either adjust the aspect ratio or add the legacy letterbox
	if self.forcedAspectRatio == Enum.CameraModeAspectRatio.LegacyLetterbox then
		local width = CinematicFrame:GetWidth();
		local height = CinematicFrame:GetHeight();

		local viewableHeight = width * DefaultAspectRatio.y / DefaultAspectRatio.x;
		local halfDiff = math.max(math.floor((height - viewableHeight) / 2.0), 0);

		WorldFrame:ClearAllPoints();
		WorldFrame:SetPoint("TOPLEFT", nil, "TOPLEFT", 0, -halfDiff);
		WorldFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, halfDiff);

		local blackBarHeight = math.max(halfDiff, 40);
		UpperBlackBar:SetHeight( blackBarHeight );
		LowerBlackBar:SetHeight( blackBarHeight );
			
		UpperBlackBar:SetShown(true);
		LowerBlackBar:SetShown(true);
	else
		UpperBlackBar:SetShown(false);
		LowerBlackBar:SetShown(false);

		local height, width, actualRatio;
		local requestedRatio = AspectRatios[self.forcedAspectRatio];
		if requestedRatio then
			height = requestedRatio.y * WorldFrame:GetWidth() / requestedRatio.x;
			width = requestedRatio.x * WorldFrame:GetHeight() / requestedRatio.y;
			actualRatio = requestedRatio.x / requestedRatio.y;
		else
			height = DefaultAspectRatio.y * WorldFrame:GetWidth() / DefaultAspectRatio.x;
			width = DefaultAspectRatio.x * WorldFrame:GetHeight() / DefaultAspectRatio.y;
			actualRatio = DefaultAspectRatio.x / DefaultAspectRatio.y;
		end
		local physicalWidth, physicalHeight = GetPhysicalScreenSize();
		local screenRatio = physicalWidth / physicalHeight;

		WorldFrame:ClearAllPoints();
		if actualRatio > screenRatio then -- letterbox
			WorldFrame:SetHeight(1);
			WorldFrame:SetPoint("LEFT", nil, "LEFT", 0, 0);
			WorldFrame:SetPoint("RIGHT", nil, "RIGHT", 0, 0);
			WorldFrame:SetHeight(height);
		elseif actualRatio < screenRatio then --pillarbox
			WorldFrame:SetWidth(1);
			WorldFrame:SetPoint("TOP", nil, "TOP", 0, 0);
			WorldFrame:SetPoint("BOTTOM", nil, "BOTTOM", 0, 0);
			WorldFrame:SetWidth(width);				
		else -- perfect match
			WorldFrame:SetAllPoints();
		end
	end
end

function CinematicFrame_OnLoad(self)
	self.forcedAspectRatio = Enum.CameraModeAspectRatio.LegacyLetterbox;

	self:RegisterEvent("CINEMATIC_START");
	self:RegisterEvent("CINEMATIC_STOP");
	self:RegisterEvent("HIDE_SUBTITLE");

	--For subtitles. We only support say/yell right now.
	self:RegisterEvent("CHAT_MSG_SAY");
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY");
	self:RegisterEvent("CHAT_MSG_YELL");
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function CinematicFrame_OnHide(self)
	WorldFrame:SetAllPoints(nil);
end

function CinematicFrame_OnEvent(self, event, ...)	
	if ( event == "CINEMATIC_START" ) then
		local canBeCancelled, forcedAspectRatio = ...;
		EventRegistry:TriggerEvent("CinematicFrame.CinematicStarting");
		for i=1, #self.Subtitles do
			self.Subtitles[i]:SetText("");
			self.Subtitles[i]:Hide();
		end

		self.isRealCinematic = canBeCancelled;	--If it isn't real, it's a vehicle cinematic

		self.forcedAspectRatio = forcedAspectRatio;
		CinematicFrame_OnDisplaySizeChanged(self);

		self.closeDialog:Hide();
		ShowUIPanel(self, 1);
		RaidNotice_Clear(self.raidBossEmoteFrame);

		LowHealthFrame:EvaluateVisibleState();
	elseif ( event == "CINEMATIC_STOP" ) then
		HideUIPanel(self);
		RaidNotice_Clear(RaidBossEmoteFrame);	--Clear the normal boss emote frame. If there are any messages left over from the cinematic, we don't want to show them.

		LowHealthFrame:EvaluateVisibleState();

		MovieFrame_OnCinematicStopped();
		EventRegistry:TriggerEvent("CinematicFrame.CinematicStopped");
	elseif ( event == "CHAT_MSG_SAY" or event == "CHAT_MSG_MONSTER_SAY" or
		event == "CHAT_MSG_YELL" or event == "CHAT_MSG_MONSTER_YELL" ) then
		local message, sender, lang, channel, target, flag, zone, localid, name, instanceId, lineId, guidString, bnId, isMobile, isSubtitle, hideSenderInLetterbox = ...;
		if ( isSubtitle ) then
			local body;
			if (hideSenderInLetterbox) then
				body = message;
			elseif ( lang ~= "" and lang ~= GetDefaultLanguage() ) then
				local languageHeader = "["..lang.."]";
				body = format(SUBTITLE_FORMAT, sender, languageHeader..message);
			else
				body = format(SUBTITLE_FORMAT, sender, message);
			end

			local chatType = string.match(event, "CHAT_MSG_(.*)");
			CinematicFrame_AddSubtitle(chatType, body);
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED") then
		if (self:IsShown()) then
			CinematicFrame_OnDisplaySizeChanged(self);
		end
	elseif ( event == "HIDE_SUBTITLE") then
		CinematicFrame_HideSubtitle(self)
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

function CinematicFrame_HideSubtitle(self)
	for i=1, #self.Subtitles do
		self.Subtitles[i]:SetText("");
		self.Subtitles[i]:Hide();
	end
end

function CinematicFrame_OnKeyDown(self, key)
	local keybind = GetBindingFromClick(key);
	if ( keybind == "TOGGLEGAMEMENU" ) then
		if ( self.isRealCinematic and IsGMClient() ) then
			StopCinematic();
		elseif ( self.isRealCinematic ) then
			self.closeDialog:Show();
		elseif ( IsInCinematicScene() ) then
			if ( CanCancelScene() ) then
				self.closeDialog:Show();
			end
		elseif ( CanExitVehicle() ) then	--If it's not a real cinematic, we can cancel it by leaving the vehicle.
			self.closeDialog:Show();
		end
	elseif ( keybind == "SCREENSHOT" or keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" ) then
		RunBinding(keybind);
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
