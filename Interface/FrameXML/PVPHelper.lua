function PVPHelperFrame_OnLoad(self)
	self:RegisterEvent("WARGAME_REQUESTED");
	
	self.timerDelay = 0
end

function PVPHelperFrame_OnEvent(self, event, ...)
	if ( event == "WARGAME_REQUESTED" ) then
		local challengerName, bgName, timeout, tournamentRules = ...;
		PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout, tournamentRules);
	end
end


-------------------------------------------------------------------------
-- PVP PopUp Functions
-------------------------------------------------------------------------

function PVPFramePopup_OnLoad(self)
	self:RegisterEvent("BATTLEFIELD_QUEUE_TIMEOUT");
end


function PVPFramePopup_OnEvent(self, event, ...)
	if event == "BATTLEFIELD_QUEUE_TIMEOUT" then
		if self.type == "WARGAME_REQUESTED" then
			self:Hide();
		end
	end
end


function PVPFramePopup_OnUpdate(self, elasped)
	if self.timeout then
		self.timeout = self.timeout - elasped;
		if self.timeout > 0 then
			self.timer:SetText(SecondsToTime(self.timeout))
		end
	end
end


function PVPFramePopup_SetupPopUp(event, challengerName, bgName, timeout, tournamentRules)
	PVPFramePopup.title:SetFormattedText(WARGAME_CHALLENGED, challengerName, bgName);
	PVPFramePopup.type = event;
	PVPFramePopup.timeout = timeout  - 3;  -- add a 3 second buffer
	SetPortraitToTexture(PVPFramePopup.ringIcon,"Interface\\BattlefieldFrame\\UI-Battlefield-Icon");
	StaticPopupSpecial_Show(PVPFramePopup);
	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();
end



function PVPFramePopup_OnResponse(accepted)
	if PVPFramePopup.type == "WARGAME_REQUESTED" then
		WarGameRespond(accepted)
	end
	
	StaticPopupSpecial_Hide(PVPFramePopup);
end

-------------------------------------------------------------------------
---- PVP Ready Dialog
---------------------------------------------------------------------------

function PVPReadyDialog_OnHide(self)
	self.battlefieldIndex = nil;
end

function PVPReadyDialog_Showing(index)
	return PVPReadyDialog:IsShown() and PVPReadyDialog.activeIndex == index;
end

function PVPReadyDialog_Display(self, index, displayName, isRated, queueType, gameType, role)
	PVPReadyDialog.activeIndex = index;
	
	PVPReadyDialog.text:SetFormattedText(CONFIRM_BATTLEFIELD_ENTRY, displayName, nil);

	PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE);
	StaticPopupSpecial_Show(PVPReadyDialog);
	FlashClientIcon();
end