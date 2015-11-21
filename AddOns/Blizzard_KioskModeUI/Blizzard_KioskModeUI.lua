local DemonHunterQuestID = 38729;
--local TimeAllowed = 15 * 60;
local Timeout = 30;
local MaxLevel = 10; -- For new characters

function KioskModeController_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function KioskModeController_OnEvent(self, event)
	if (event == "PLAYER_ENTERING_WORLD") then
		local classFile = select(2, UnitClass("player"));
		if (classFile == "DEMONHUNTER") then
			SetCVar("showTutorials", 0);
		end
	end
end

function KioskThankYouForPlayingFrame_OnLoad(self)
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("UNIT_LEVEL");

	--self.timer = C_Timer.NewTimer(TimeAllowed, function () self:Show() end);
end

function KioskThankYouForPlayingFrame_Disable()
	--KioskThankYouForPlayingFrame.timer:Cancel();
	KioskThankYouForPlayingFrame:UnregisterEvent("QUEST_TURNED_IN");
	KioskThankYouForPlayingFrame:UnregisterEvent("UNIT_LEVEL");
	if (KioskThankYouForPlayingFrame.logoutTimer) then
		KioskThankYouForPlayingFrame.logoutTimer:Cancel();
	end
	KioskThankYouForPlayingFrame:Hide();
	DEFAULT_CHAT_FRAME:AddMessage("Kiosk Mode play session end conditions disabled.");
end

function KioskThankYouForPlayingFrame_OnEvent(self, event, ...)
	if (event == "QUEST_TURNED_IN") then
		if (select(2, UnitClass("player")) == "DEMONHUNTER") then
			local questID = ...;
			if (questID == DemonHunterQuestID) then
				self:Show();
			end
		end
	elseif (event == "UNIT_LEVEL") then
		if (select(2, UnitClass("player")) ~= "DEMONHUNTER") then
			if (UnitLevel("player") >= MaxLevel) then
				self:Show();
			end
		end
	end
end

function KioskThankYouForPlayingFrame_OnShow()
	KioskThankYouForPlayingFrame.logoutTimer = C_Timer.NewTimer(Timeout, function()
		ForceLogout();
	end);
end
