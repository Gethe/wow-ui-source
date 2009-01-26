READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting";
READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready";
READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
READY_CHECK_AFK_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";


function ShowReadyCheck(initiator, timeLeft)
	ReadyCheckFrame:Show();
	ReadyCheckFrame.initiator = initiator;
	if ( UnitIsUnit("player", initiator) ) then
		ReadyCheckFrame:SetScript("OnUpdate", ReadyCheckFrame_OnUpdateInitiator);
		ReadyCheckListenerFrame:Hide();
	else
		ReadyCheckFrame:SetScript("OnUpdate", nil);
		SetPortraitTexture(ReadyCheckPortrait, initiator);
		ReadyCheckFrameText:SetFormattedText(READY_CHECK_MESSAGE, initiator);
		ReadyCheckListenerFrame:Show();
	end
end

function ReadyCheckFrame_OnLoad(self)
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
end

function ReadyCheckFrame_OnEvent(self, event, ...)
	if ( event == "READY_CHECK" ) then
		ShowReadyCheck(...);
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if ( self.initiator ) then
			if ( not UnitIsUnit("player", self.initiator) ) then
				local info = ChatTypeInfo["SYSTEM"];
				DEFAULT_CHAT_FRAME:AddMessage(READY_CHECK_YOU_WERE_AFK, info.r, info.g, info.b, info.id);
				ReadyCheckListenerFrame:Hide();
			end
			self:Hide();
		end
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		if ( GetNumRaidMembers() == 0 ) then
			self:Hide();
		end
	end
end

function ReadyCheckFrame_OnHide(self)
	self.initiator = nil;
end

function ReadyCheckFrame_OnUpdateInitiator(self, elapsed)
	-- This OnUpdate gets called for the ready check initiator, so we can keep checking to see
	-- if the ready check times out. This will also finish the ready check if the time is up.
	CheckReadyCheckTime();
end

function ReadyCheck_Start(readyCheckFrame)
	readyCheckFrame:SetScript("OnUpdate", nil);

	getglobal(readyCheckFrame:GetName().."Texture"):SetTexture(READY_CHECK_WAITING_TEXTURE);
	readyCheckFrame.state = "waiting";
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Confirm(readyCheckFrame, ready)
	readyCheckFrame:SetScript("OnUpdate", nil);

	if ( ready == 1 ) then
		getglobal(readyCheckFrame:GetName().."Texture"):SetTexture(READY_CHECK_READY_TEXTURE);
		readyCheckFrame.state = "ready";
	else
		getglobal(readyCheckFrame:GetName().."Texture"):SetTexture(READY_CHECK_NOT_READY_TEXTURE);
		readyCheckFrame.state = "notready";
	end
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Finish(readyCheckFrame, fadeTime, onFinishFunc, onFinishFuncArg)
	if ( readyCheckFrame.state == "waiting" ) then
		getglobal(readyCheckFrame:GetName().."Texture"):SetTexture(READY_CHECK_AFK_TEXTURE);
		readyCheckFrame.state = "afk";
	end

	readyCheckFrame:SetScript("OnUpdate", ReadyCheck_OnUpdate);
	readyCheckFrame.finishedTimer = 10;
	if ( fadeTime ) then
		readyCheckFrame.fadeTimer = fadeTime;
	else
		readyCheckFrame.fadeTimer = 1.5;
	end
	readyCheckFrame.onFinishFunc = onFinishFunc;
	readyCheckFrame.onFinishFuncArg = onFinishFuncArg;
end

function ReadyCheck_OnUpdate(readyCheckFrame, elapsed)
	if ( readyCheckFrame.finishedTimer ) then
		readyCheckFrame.finishedTimer = readyCheckFrame.finishedTimer - elapsed;
		if ( readyCheckFrame.finishedTimer <= 0 ) then
			readyCheckFrame.finishedTimer = nil;
		end
	elseif ( readyCheckFrame.fadeTimer ) then
		readyCheckFrame.fadeTimer = readyCheckFrame.fadeTimer - elapsed;
		readyCheckFrame:SetAlpha(readyCheckFrame.fadeTimer / 1.5);
		if ( readyCheckFrame.fadeTimer <= 0 ) then
			readyCheckFrame.fadeTimer = nil;
			readyCheckFrame:Hide();
			readyCheckFrame:SetScript("OnUpdate", nil);
			readyCheckFrame.state = nil;
			if ( readyCheckFrame.onFinishFunc ) then
				readyCheckFrame.onFinishFunc(readyCheckFrame.onFinishFuncArg);
				readyCheckFrame.onFinishFunc = nil;
			end
		end
	end
end
