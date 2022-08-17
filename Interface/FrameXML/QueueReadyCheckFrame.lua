
function QueueReadyCheckFrame_OnLoad(self)
	self:RegisterEvent("LFG_READY_CHECK_SHOW");
	self:RegisterEvent("LFG_READY_CHECK_HIDE");
	self:RegisterEvent("LFG_READY_CHECK_PLAYER_IS_READY");
end

function QueueReadyCheckFrame_OnEvent(self, event, ...)
	if ( event == "LFG_READY_CHECK_SHOW" ) then
		QueueReadyCheckPopup.Text:SetText(READY_CHECK_RATED_ARENA);
		StaticPopupSpecial_Show(QueueReadyCheckPopup);
	elseif ( event == "LFG_READY_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(QueueReadyCheckPopup);
	elseif ( event == "LFG_READY_CHECK_PLAYER_IS_READY" ) then
		local player = ...;
		ChatFrame_DisplaySystemMessageInPrimary(string.format(LFG_READY_CHECK_PLAYER_IS_READY, player));
	end
end
