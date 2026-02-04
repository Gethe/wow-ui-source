EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(_owner, isInitialLogin, _isUIReload)
	if isInitialLogin then
		ChatFrameUtil.AddSystemMessage(ONLINE_SAFETY_NOTICE);
	end
end);
