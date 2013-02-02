READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting";
READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready";
READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
READY_CHECK_AFK_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";


--
-- ReadyCheckFrame
--

function ShowReadyCheck(initiator, timeLeft)
	ReadyCheckFrame.initiator = initiator;
	if ( initiator ) then
		ReadyCheckFrame:Show();
		if ( UnitIsUnit("player", initiator) ) then
			ReadyCheckListenerFrame:Hide();
		else
			SetPortraitTexture(ReadyCheckPortrait, initiator);
			local _, _, difficultyID = GetInstanceInfo();
			if ( not difficultyID or difficultyID == 0 ) then
				-- not in an instance, go by current difficulty setting
				if (UnitInRaid("player")) then
					difficultyID = GetRaidDifficultyID();
				else
					difficultyID = GetDungeonDifficultyID();
				end
			end
			local difficultyName, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID);
			if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
				-- the current difficulty might change while inside an instance so show the difficulty on the ready check
				ReadyCheckFrameText:SetFormattedText(READY_CHECK_MESSAGE.."\n"..RAID_DIFFICULTY..": "..difficultyName, initiator);
			else
				ReadyCheckFrameText:SetFormattedText(READY_CHECK_MESSAGE, initiator);
			end
			ReadyCheckListenerFrame:Show();
		end
	end
end

function ReadyCheckFrame_OnLoad(self)
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	
	ReadyCheckFrameYesButton:SetText(GetText("READY", UnitSex("player")));
	ReadyCheckFrameNoButton:SetText(GetText("NOT_READY", UnitSex("player")));
end

function ReadyCheckFrame_OnEvent(self, event, ...)
	if ( event == "READY_CHECK" ) then
		ShowReadyCheck(...);
	elseif ( event == "READY_CHECK_FINISHED" ) then
		local preempted = ...;
		if ( not preempted and self.initiator and not UnitIsUnit("player", self.initiator) ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(READY_CHECK_YOU_WERE_AFK, info.r, info.g, info.b, info.id);
		end
		self:Hide();
	end
end

function ReadyCheckFrame_OnHide(self)
	self.initiator = nil;
end


--
-- ReadyCheck unit frame functions
--

function ReadyCheck_Start(readyCheckFrame)
	readyCheckFrame:SetScript("OnUpdate", nil);

	_G[readyCheckFrame:GetName().."Texture"]:SetTexture(READY_CHECK_WAITING_TEXTURE);
	readyCheckFrame.state = "waiting";
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Confirm(readyCheckFrame, ready)
	readyCheckFrame:SetScript("OnUpdate", nil);

	if ( ready == 1 ) then
		_G[readyCheckFrame:GetName().."Texture"]:SetTexture(READY_CHECK_READY_TEXTURE);
		readyCheckFrame.state = "ready";
	else
		_G[readyCheckFrame:GetName().."Texture"]:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
		readyCheckFrame.state = "notready";
	end
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Finish(readyCheckFrame, finishTime, fadeTime, onFinishFunc, onFinishFuncArg)
	if ( readyCheckFrame.state == "waiting" ) then
		_G[readyCheckFrame:GetName().."Texture"]:SetTexture(READY_CHECK_AFK_TEXTURE);
		readyCheckFrame.state = "afk";
	end
	
	if ( finishTime > 0 ) then
		readyCheckFrame:SetScript("OnUpdate", ReadyCheck_OnUpdate);
		readyCheckFrame.finishedTimer = finishTime;
		if ( fadeTime ) then
			readyCheckFrame.fadeTimer = fadeTime;
		else
			readyCheckFrame.fadeTimer = 1.5;
		end
		readyCheckFrame.onFinishFunc = onFinishFunc;
		readyCheckFrame.onFinishFuncArg = onFinishFuncArg;
	else
		readyCheckFrame:Hide();
		readyCheckFrame.state = nil;
		if ( onFinishFunc ) then
			onFinishFunc(onFinishFuncArg);
		end
	end
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
				readyCheckFrame.onFinishFuncArg = nil;
			end
		end
	end
end
