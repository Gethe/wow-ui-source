function MinigameFrame_OnEvent(self, event, ...)
	local gameType = GetMinigameType();
	if ( not gameType ) then
		return;
	end
	if ( event == "START_MINIGAME" ) then
		ShowUIPanel(self);
		getglobal(gameType.."Frame"):Show();
	elseif ( event == "MINIGAME_UPDATE" ) then
		local updateFunc = getglobal(gameType.."_Update");
		if ( updateFunc ) then
			updateFunc();
		end
	end
end

function MinigameFrame_Update()
	GetMinigameState();
end