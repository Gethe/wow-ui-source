READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting";
READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready";
READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
READY_CHECK_AFK_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";


function ShowReadyCheck(initiator, timeLeft)
	local name, leader;
	for i=1, MAX_RAID_MEMBERS do
		name = GetRaidRosterInfo(i);
		if ( name and name == initiator) then
			leader = "raid"..i;
			break;
		end
	end
	if ( not leader ) then
		leader = "party"..GetPartyLeaderIndex();
		name = UnitName(leader);
	end
	SetPortraitTexture(ReadyCheckPortrait, leader);
	ReadyCheckFrameText:SetFormattedText(READY_CHECK_MESSAGE, initiator);
	ReadyCheckFrame.initiator = initiator;
	ReadyCheckFrame.timer = timeLeft;
	if ( not ReadyCheckFrame:IsShown() ) then
		ReadyCheckFrame:Show();
		PlaySound("ReadyCheck");
	end
end

function ReadyCheckFrame_OnUpdate(elapsed)
	if ( not ReadyCheckFrame.timer ) then
		return;
	end

	ReadyCheckFrame.timer = ReadyCheckFrame.timer - elapsed;
	if ( ReadyCheckFrame.timer < 0 ) then
		-- Timed out
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(READY_CHECK_YOU_WERE_AFK, info.r, info.g, info.b, info.id);
		ReadyCheckFrame.timer = nil;
		ReadyCheckFrame:Hide();
	end

	if ( GetReadyCheckTimeLeft() == 0 ) then
		-- most likely the raid leadership changed, which resets the ready check
		ReadyCheckFrame.timer = nil;
		ReadyCheckFrame:Hide();
		return;
	end
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
