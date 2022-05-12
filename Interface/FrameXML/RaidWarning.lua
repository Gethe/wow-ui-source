RAID_NOTICE_DEFAULT_HOLD_TIME = 10.0;
RAID_NOTICE_FADE_IN_TIME = 0.2;
RAID_NOTICE_FADE_OUT_TIME = 3.0;


function RaidNotice_FadeInit( slotFrame )
	FadingFrame_OnLoad(slotFrame);
	FadingFrame_SetFadeInTime(slotFrame, RAID_NOTICE_FADE_IN_TIME);
	FadingFrame_SetHoldTime(slotFrame, RAID_NOTICE_FADE_IN_TIME);
	FadingFrame_SetFadeOutTime(slotFrame, RAID_NOTICE_FADE_OUT_TIME);
end

function RaidNotice_AddMessage( noticeFrame, textString, colorInfo, displayTime )
	if ( not textString ) then
		return;
	end
	
	if (not displayTime or displayTime == 0) then
		displayTime = RAID_NOTICE_DEFAULT_HOLD_TIME;
	else
		displayTime = displayTime - RAID_NOTICE_FADE_OUT_TIME;
		displayTime = max(displayTime, 1.0);
	end
	
	noticeFrame:Show();
	if ( not noticeFrame.slot1:IsShown() ) then
		noticeFrame.slot1_text = textString;
		RaidNotice_SetSlot( noticeFrame.slot1, noticeFrame.slot1_text, colorInfo, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"], displayTime );
		noticeFrame.slot1.scrollTime = 0;
	else
		if ( noticeFrame.slot2:IsShown() and FadingFrame_GetRemainingTime(noticeFrame.slot2) > FadingFrame_GetRemainingTime(noticeFrame.slot1)) then
			noticeFrame.slot1_text = noticeFrame.slot2_text;
			local r2, g2, b2 = noticeFrame.slot2:GetTextColor();
			local slot2Color = { r = r2, g = g2, b = b2 };
			RaidNotice_SetSlot( noticeFrame.slot1, noticeFrame.slot1_text, slot2Color, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"] );
			noticeFrame.slot1.scrollTime = noticeFrame.slot2.scrollTime;
			FadingFrame_CopyTimes(noticeFrame.slot2, noticeFrame.slot1);
		end

		noticeFrame.slot2_text = textString;
		RaidNotice_SetSlot( noticeFrame.slot2, noticeFrame.slot2_text, colorInfo, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"], displayTime );
		noticeFrame.slot2.scrollTime = 0;
	end
end

function RaidNotice_SetSlot( slotFrame, textString, colorInfo, minHeight, displayTime )
	slotFrame:SetText( textString );
	slotFrame:SetTextColor( colorInfo.r, colorInfo.g, colorInfo.b, 1.0 )
	slotFrame:SetTextHeight(minHeight);
	FadingFrame_SetHoldTime(slotFrame, displayTime or RAID_NOTICE_DEFAULT_HOLD_TIME );
	FadingFrame_Show( slotFrame );
end

function RaidNotice_OnUpdate( noticeFrame, elapsedTime )
	local inUse = false;
	if ( noticeFrame.slot1:IsShown() ) then
		RaidNotice_UpdateSlot( noticeFrame.slot1, noticeFrame.timings, elapsedTime, true );
		inUse = true;
	end

	if ( noticeFrame.slot2:IsShown() ) then
		RaidNotice_UpdateSlot( noticeFrame.slot2, noticeFrame.timings, elapsedTime, true );
		inUse = true;
	end
	
	if ( not inUse ) then
		noticeFrame:Hide();
	end
end

function RaidNotice_Clear( noticeFrame )
	RaidNotice_ClearSlot(noticeFrame.slot1);
	RaidNotice_ClearSlot(noticeFrame.slot2);
end

function RaidNotice_ClearSlot( slotFrame )
	slotFrame.scrollTime = nil;
	slotFrame:Hide();
end

function RaidNotice_UpdateSlot( slotFrame, timings, elapsedTime, hasFading )
	if ( slotFrame.scrollTime ) then
		slotFrame.scrollTime = slotFrame.scrollTime + elapsedTime;
		if ( slotFrame.scrollTime <= timings["RAID_NOTICE_SCALE_UP_TIME"] ) then
			slotFrame:SetTextHeight(floor(timings["RAID_NOTICE_MIN_HEIGHT"]+((timings["RAID_NOTICE_MAX_HEIGHT"]-timings["RAID_NOTICE_MIN_HEIGHT"])*slotFrame.scrollTime/timings["RAID_NOTICE_SCALE_UP_TIME"])));			
		elseif ( slotFrame.scrollTime <= timings["RAID_NOTICE_SCALE_DOWN_TIME"] ) then
			slotFrame:SetTextHeight(floor(timings["RAID_NOTICE_MAX_HEIGHT"] - ((timings["RAID_NOTICE_MAX_HEIGHT"]-timings["RAID_NOTICE_MIN_HEIGHT"])*(slotFrame.scrollTime - timings["RAID_NOTICE_SCALE_UP_TIME"])/(timings["RAID_NOTICE_SCALE_DOWN_TIME"] - timings["RAID_NOTICE_SCALE_UP_TIME"]))));
		else
			slotFrame:SetTextHeight(timings["RAID_NOTICE_MIN_HEIGHT"]);
			slotFrame.scrollTime = nil;
		end
	end
	if ( hasFading ) then
		FadingFrame_OnUpdate(slotFrame);
	end
end





-----------  RAID WARNING 
function RaidWarningFrame_OnLoad(self)
	self:RegisterEvent("CHAT_MSG_RAID_WARNING");
	self.slot1 = RaidWarningFrameSlot1;
	self.slot2 = RaidWarningFrameSlot2;
	RaidNotice_FadeInit( self.slot1 );
	RaidNotice_FadeInit( self.slot2 );
	self.timings = { };
	self.timings["RAID_NOTICE_MIN_HEIGHT"] = 20.0;
	self.timings["RAID_NOTICE_MAX_HEIGHT"] = 30.0;
	self.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0.2;
	self.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.4;
end

function RaidWarningFrame_OnEvent(self, event, message)
	if ( event == "CHAT_MSG_RAID_WARNING" ) then
		message = ChatFrame_ReplaceIconAndGroupExpressions(message);
		
		RaidNotice_AddMessage( self, message, ChatTypeInfo["RAID_WARNING"] );
		PlaySound(SOUNDKIT.RAID_WARNING);
	end
end


-----------  BOSS EMOTE 
function RaidBossEmoteFrame_OnLoad(self)
	RaidNotice_FadeInit(self.slot1);
	RaidNotice_FadeInit(self.slot2);
	self.timings = { };
	self.timings["RAID_NOTICE_MIN_HEIGHT"] = 20.0;
	self.timings["RAID_NOTICE_MAX_HEIGHT"] = 30.0;
	self.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0.2;
	self.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.4;
	
	self:RegisterEvent("RAID_BOSS_EMOTE");
	self:RegisterEvent("RAID_BOSS_WHISPER");
	self:RegisterEvent("CLEAR_BOSS_EMOTES");
end

function RaidBossEmoteFrame_OnEvent(self, event, ...)
	if (event == "RAID_BOSS_EMOTE" or event == "RAID_BOSS_WHISPER") then
		local text, playerName, displayTime, playSound = ...;
		local body = format(text, playerName, playerName);	--No need for pflag, monsters can't be afk, dnd, or GMs.
		local info = ChatTypeInfo[event];
		RaidNotice_AddMessage( self, body, info, displayTime );
--		RaidNotice_AddMessage( RaidBossEmoteFrame, "This is a TEST of the MESSAGE!", ChatTypeInfo["RAID_BOSS_EMOTE"] );
		if ( playSound ) then
			if ( event == "RAID_BOSS_WHISPER" ) then
				PlaySound(SOUNDKIT.UI_RAID_BOSS_WHISPER_WARNING);
			else
				PlaySound(SOUNDKIT.RAID_BOSS_EMOTE_WARNING);
			end
		end
	elseif ( event == "CLEAR_BOSS_EMOTES" ) then
		RaidNotice_Clear(self);
	end
end
