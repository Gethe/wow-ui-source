PingUtil = {};

function PingUtil.SendMacroPing(type)
	local pingMacroInfo = {
		type = type
	};
	C_Ping.SendMacroPing(pingMacroInfo);
end

function PingUtil.TogglePingTarget()
	if not Settings.GetValue("enablePings") then
		return;
	end

	if Settings.GetValue("pingTarget") == Enum.PingTargetOption.All then
		Settings.SetValue("pingTarget", Enum.PingTargetOption.Environment);
		ActionStatus:DisplayMessage(PING_TARGET_TOGGLED_ENVIRONMENT);
	else
		Settings.SetValue("pingTarget", Enum.PingTargetOption.All);
		ActionStatus:DisplayMessage(PING_TARGET_TOGGLED_ALL);
	end
end
