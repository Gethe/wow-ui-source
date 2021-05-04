CommentatorEventAlertsMixin = {};

function CommentatorEventAlertsMixin:OnLoad()
	RaidNotice_FadeInit(self.slot1);
	RaidNotice_FadeInit(self.slot2);
	self.timings = { };
	self.timings["RAID_NOTICE_MIN_HEIGHT"] = 20.0;
	self.timings["RAID_NOTICE_MAX_HEIGHT"] = 25.0;
	self.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0.2;
	self.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.4;
	
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE");
	self:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE");
end

function CommentatorEventAlertsMixin:OnEvent(event, ...)
	if (event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" or event == "CHAT_MSG_BG_SYSTEM_HORDE") then
		local text = ...;
		local info = ChatTypeInfo["BG_SYSTEM_NEUTRAL"]
		if (event == "CHAT_MSG_BG_SYSTEM_ALLIANCE") then
			info = ChatTypeInfo["BG_SYSTEM_ALLIANCE"]; 
		elseif (event == "CHAT_MSG_BG_SYSTEM_HORDE") then
			info = ChatTypeInfo["BG_SYSTEM_HORDE"]
		end
		local displayTime = 5;
		RaidNotice_AddMessage(self, text, info, displayTime );
	end
end