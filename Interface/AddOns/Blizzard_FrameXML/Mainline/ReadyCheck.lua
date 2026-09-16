READY_CHECK_WAITING_TEXTURE = "UI-LFG-PendingMark";
READY_CHECK_READY_TEXTURE = "UI-LFG-ReadyMark";
READY_CHECK_NOT_READY_TEXTURE = "UI-LFG-DeclineMark";
READY_CHECK_AFK_TEXTURE = "UI-LFG-DeclineMark";

-- Smaller icons that do not have a background shadow
READY_CHECK_WAITING_TEXTURE_RAID = "UI-LFG-PendingMark-Raid";
READY_CHECK_READY_TEXTURE_RAID = "UI-LFG-ReadyMark-Raid";
READY_CHECK_NOT_READY_TEXTURE_RAID = "UI-LFG-DeclineMark-Raid";
READY_CHECK_AFK_TEXTURE_RAID = "UI-LFG-DeclineMark-Raid";

-- For compatibility in LFGFrame with Classic
READY_CHECK_WAITING_ATLAS = READY_CHECK_WAITING_TEXTURE;
READY_CHECK_READY_ATLAS = READY_CHECK_READY_TEXTURE;
READY_CHECK_NOT_READY_ATLAS = READY_CHECK_NOT_READY_TEXTURE;
READY_CHECK_AFK_ATLAS = READY_CHECK_AFK_TEXTURE;


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
			ReadyCheckListenerFrame:Display(initiator);
		end
	end
end

function ReadyCheckFrame_OnLoad(self)
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("GROUP_LEFT");

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
	elseif ( event == "GROUP_LEFT" ) then
		self:Hide();
	end
end

function ReadyCheckFrame_OnHide(self)
	self.initiator = nil;
end

ReadyCheckListenerFrameMixin = {};

function ReadyCheckListenerFrameMixin:OnLoad()
	self:RegisterForTransitions();
	NineSliceUtil.UpdateCornerCropping(self, self:GetHeight());
end

function ReadyCheckListenerFrameMixin:OnShow()
	PlaySound(SOUNDKIT.READY_CHECK);
	FlashClientIcon();

	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:HandlePopupShown(self);
	end
end

function ReadyCheckListenerFrameMixin:OnHide()
	if self.binding then
		self:DeactivateBinding();
	end

	if InputUtil.IsGamepadUIEnabled() then
		GamepadMode.FrameControlsManager:HandlePopupHide(self);
	end
end

function ReadyCheckListenerFrameMixin:Display(initiator)
	SetPortraitTexture(self.PortraitContainer.Portrait, initiator);
	local _, _, difficultyID = GetInstanceInfo();
	if ( not difficultyID or difficultyID == 0 ) then
		-- Not in an instance, go by current difficulty setting.
		if (UnitInRaid("player")) then
			difficultyID = GetRaidDifficultyID();
		else
			difficultyID = GetDungeonDifficultyID();
		end
	end
	local readyCheckTxt = READY_CHECK_MESSAGE;
	if difficultyID then
		local difficultyName, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID);
		if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
			-- The current difficulty might change while inside an instance so show the difficulty on the ready check
			readyCheckTxt = READY_CHECK_MESSAGE.."\n"..RAID_DIFFICULTY..": "..difficultyName;
		end
	end
	self.Text:SetFormattedText(readyCheckTxt, initiator);
	self:Show();
end

function ReadyCheckListenerFrameMixin:FocusGamepad()
	self:ActivateBinding();
end

function ReadyCheckListenerFrameMixin:UnfocusGamepad()
	self:DeactivateBinding();
end

function ReadyCheckListenerFrameMixin:ActivateBinding()
	GamepadMode.SetGamepadIconShown(self.yesIcon, true);
	GamepadMode.SetGamepadIconShown(self.noIcon, true);
	GamepadMode.ActivateBindingGroup(self.binding);
end

function ReadyCheckListenerFrameMixin:DeactivateBinding()
	GamepadMode.DeactivateBindingGroup(self.binding);
	GamepadMode.SetGamepadIconShown(self.yesIcon, false);
	GamepadMode.SetGamepadIconShown(self.noIcon, false);
end

function ReadyCheckListenerFrameMixin:SetupGamepad()
	self.useCustomNavigation = true;
	self.skipGamepadAutoFocus = true;
	self.binding = GamepadMode.CreateBindingGroup("ReadyCheckBindings");
	self.binding:BlockEverything();
	self.binding:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, function() self.YesButton:Click() end, GAMEPAD_BUTTON_ANY_DOWN_OR_UP);
	self.binding:AddFunctionBinding(GAMEPAD_FACE_RIGHT, function() self.NoButton:Click() end, GAMEPAD_BUTTON_ANY_DOWN_OR_UP);

	self.yesIcon = GamepadMode.AddGamepadIconToButton(self.YesButton, GAMEPAD_FACE_BOTTOM);
	self.noIcon = GamepadMode.AddGamepadIconToButton(self.NoButton, GAMEPAD_FACE_RIGHT);

	GamepadMode.SetGamepadIconShown(self.yesIcon, false);
	GamepadMode.SetGamepadIconShown(self.noIcon, false);

	-- Changing the FrameGlow's anchors since the ReadyCheckFrame has slightly different proportions than other PortraitFrameTemplate layout types.
	self.FrameGlow:ClearAllPoints();
	self.FrameGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -20, 24);
	self.FrameGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 16, -18);
end

function ReadyCheckListenerFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
end

--
-- ReadyCheck unit frame functions
--

local function GetBestReadyCheckIconForFrame(readyCheckFrame)
	local readyCheckState = readyCheckFrame.state;
	if readyCheckState == "ready" then
		return readyCheckFrame.useRaidIcons and READY_CHECK_READY_TEXTURE_RAID or READY_CHECK_READY_TEXTURE;
	elseif readyCheckState == "notready" then
		return readyCheckFrame.useRaidIcons and READY_CHECK_NOT_READY_TEXTURE_RAID or READY_CHECK_NOT_READY_TEXTURE
	elseif readyCheckState == "waiting" then
		return readyCheckFrame.useRaidIcons and READY_CHECK_WAITING_TEXTURE_RAID or READY_CHECK_WAITING_TEXTURE;
	elseif readyCheckState == "afk" then
		return readyCheckFrame.useRaidIcons and READY_CHECK_AFK_TEXTURE_RAID or READY_CHECK_AFK_TEXTURE;
	end

	return readyCheckFrame.useRaidIcons and READY_CHECK_WAITING_TEXTURE_RAID or READY_CHECK_WAITING_TEXTURE;
end

function ReadyCheck_Start(readyCheckFrame)
	readyCheckFrame:SetScript("OnUpdate", nil);

	readyCheckFrame.state = "waiting";
	readyCheckFrame.Texture:SetAtlas(GetBestReadyCheckIconForFrame(readyCheckFrame), TextureKitConstants.UseAtlasSize);
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Confirm(readyCheckFrame, ready)
	readyCheckFrame:SetScript("OnUpdate", nil);

	if ( ready == 1 ) then
		readyCheckFrame.state = "ready";
		readyCheckFrame.Texture:SetAtlas(GetBestReadyCheckIconForFrame(readyCheckFrame), TextureKitConstants.UseAtlasSize);
	else
		readyCheckFrame.state = "notready";
		readyCheckFrame.Texture:SetAtlas(GetBestReadyCheckIconForFrame(readyCheckFrame), TextureKitConstants.UseAtlasSize);
	end
	readyCheckFrame:SetAlpha(1);
	readyCheckFrame:Show();
end

function ReadyCheck_Finish(readyCheckFrame, finishTime, fadeTime, onFinishFunc, onFinishFuncArg)
	if ( readyCheckFrame.state == "waiting" ) then
		readyCheckFrame.state = "afk";
		readyCheckFrame.Texture:SetAtlas(GetBestReadyCheckIconForFrame(readyCheckFrame), TextureKitConstants.UseAtlasSize);
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
		if ( readyCheckFrame.fadeTimer > 0 ) then
			readyCheckFrame:SetAlpha(readyCheckFrame.fadeTimer / 1.5);
		else
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
