
function RaidNotice_FadeInit( slotFrame )
	FadingFrame_OnLoad(slotFrame);
	FadingFrame_SetFadeInTime(slotFrame, 0.2);
	FadingFrame_SetHoldTime(slotFrame, 10.0);
	FadingFrame_SetFadeOutTime(slotFrame, 3.0);
end

function RaidNotice_AddMessage( noticeFrame, textString, colorInfo )
	if ( not noticeFrame or not noticeFrame.slot1 or not noticeFrame.slot2 or not textString ) then
		return;
	end

	noticeFrame:Show();
	if ( not noticeFrame.slot1:IsShown() ) then
		noticeFrame.slot1_text = textString;
		RaidNotice_SetSlot( noticeFrame.slot1, noticeFrame.slot1_text, colorInfo, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"] );
		noticeFrame.slot1.scrollTime = 0;
	else
		if ( noticeFrame.slot2:IsShown() ) then
			noticeFrame.slot1_text = noticeFrame.slot2_text;
			RaidNotice_SetSlot( noticeFrame.slot1, noticeFrame.slot1_text, colorInfo, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"] );
			noticeFrame.slot1.scrollTime = noticeFrame.slot2.scrollTime;
		end

		noticeFrame.slot2_text = textString;
		RaidNotice_SetSlot( noticeFrame.slot2, noticeFrame.slot2_text, colorInfo, noticeFrame.timings["RAID_NOTICE_MIN_HEIGHT"] );
		noticeFrame.slot2.scrollTime = 0;
	end
end

function RaidNotice_SetSlot( slotFrame, textString, colorInfo, minHeight )
	slotFrame:SetText( textString );
	slotFrame:SetTextColor( colorInfo.r, colorInfo.g, colorInfo.b, 1.0 )
	slotFrame:SetTextHeight(minHeight);
	FadingFrame_Show( slotFrame );
end

local RaidNotice_unused = false;
function RaidNotice_OnUpdate( noticeFrame, elapsedTime )
	if ( not noticeFrame or not noticeFrame.slot1 or not noticeFrame.slot2 ) then
		return;
	end

	RaidNotice_unused = true;
	if ( noticeFrame.slot1:IsShown() ) then
		RaidNotice_UpdateSlot( noticeFrame.slot1, noticeFrame.timings, elapsedTime );
		RaidNotice_unused = false;
	end

	if ( noticeFrame.slot2:IsShown() ) then
		RaidNotice_UpdateSlot( noticeFrame.slot2, noticeFrame.timings, elapsedTime );
		RaidNotice_unused = false;
	end
	
	if ( RaidNotice_unused ) then
		noticeFrame:Hide();
	end
end

function RaidNotice_UpdateSlot( slotFrame, timings, elapsedTime )
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
	FadingFrame_OnUpdate(slotFrame);
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
		
		--Task 21207: Add the ability to link raid icons to other players
		local term;
		for tag in string.gmatch(message, "%b{}") do
			term = strlower(string.gsub(tag, "[{}]", ""));
			if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
				-- Using 0 as the height to make the texture match the font height
				message = string.gsub(message, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
			end
		end		
		
		RaidNotice_AddMessage( self, message, ChatTypeInfo["RAID_WARNING"] );
		PlaySound("RaidWarning");
	end
end


-----------  BOSS EMOTE 
function RaidBossEmoteFrame_OnLoad(self)
	self.slot1 = RaidBossEmoteFrameSlot1;
	self.slot2 = RaidBossEmoteFrameSlot2;
	RaidNotice_FadeInit(self.slot1);
	RaidNotice_FadeInit(self.slot2);
	self.timings = { };
	self.timings["RAID_NOTICE_MIN_HEIGHT"] = 20.0;
	self.timings["RAID_NOTICE_MAX_HEIGHT"] = 30.0;
	self.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0.2;
	self.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.4;
	
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER");
end

function RaidBossEmoteFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( strsub(event,10,18) == "RAID_BOSS" ) then
		local mtype = strsub(event,10);
		local body = format(_G["CHAT_"..mtype.."_GET"]..arg1, arg2, arg2);	--No need for pflag, monsters can't be afk, dnd, or GMs.
		local info = ChatTypeInfo[mtype];
		RaidNotice_AddMessage( RaidBossEmoteFrame, body, info );
--		RaidNotice_AddMessage( RaidBossEmoteFrame, "This is a TEST of the MESSAGE!", ChatTypeInfo["RAID_BOSS_EMOTE"] );
		PlaySound("RaidBossEmoteWarning");
	end
end