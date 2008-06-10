
function RaidWarningFrame_OnLoad()
	this:RegisterEvent("CHAT_MSG_RAID_WARNING");
end

function RaidWarningFrame_OnEvent(event, message)
	if ( event == "CHAT_MSG_RAID_WARNING" ) then
		local info = ChatTypeInfo["RAID_WARNING"];
		this:AddMessage(message, info.r, info.g, info.b, 1.0);
		PlaySound("RaidWarning");
	end
end