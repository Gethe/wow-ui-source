
LFGReadyCheckPopupMixin = {};

function LFGReadyCheckPopupMixin:OnLoad()
	self:RegisterEvent("LFG_READY_CHECK_SHOW");
	self:RegisterEvent("LFG_READY_CHECK_HIDE");
end

function LFGReadyCheckPopupMixin:OnEvent(event, ...)
	if ( event == "LFG_READY_CHECK_SHOW" ) then
		local _, readyCheckBgQueue = GetLFGReadyCheckUpdate();
		local displayName;
		if ( readyCheckBgQueue ) then
			displayName = GetLFGReadyCheckUpdateBattlegroundInfo();
		else
			displayName = UNKNOWN;
		end
		LFGReadyCheckPopup.Text:SetFormattedText(CONFIRM_YOU_ARE_READY, displayName);
		StaticPopupSpecial_Show(LFGReadyCheckPopup);
	elseif ( event == "LFG_READY_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFGReadyCheckPopup);
	end
end

function LFGReadyCheckPopupMixin:OnShow()
	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();
end
