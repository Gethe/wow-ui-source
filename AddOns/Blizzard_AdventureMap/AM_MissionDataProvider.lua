AdventureMap_MissionDataProviderMixin = CreateFromMixins(AdventureMapDataProviderMixin);

function AdventureMap_MissionDataProviderMixin:OnAdded(adventureMap)
	AdventureMapDataProviderMixin.OnAdded(self, adventureMap);

	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self:RegisterEvent("ADVENTURE_MAP_UPDATE_POIS");
end

function AdventureMap_MissionDataProviderMixin:OnEvent(event, ...)
	if event == "GARRISON_MISSION_NPC_OPENED" then
		local followerType = ...;
		if followerType == LE_FOLLOWER_TYPE_GARRISON_7_0 then
			self:RefreshAllData();
		end
	elseif event == "GARRISON_MISSION_LIST_UPDATE" then
		local followerType = ...;
		if followerType == LE_FOLLOWER_TYPE_GARRISON_7_0 then
			self:RefreshAllData();
		end
	elseif event == "GARRISON_MISSION_FINISHED" then
		local followerType, missionID = ...;
		if followerType == LE_FOLLOWER_TYPE_GARRISON_7_0 then
			self:RefreshAllData();
		end
	elseif event == "GARRISON_MISSION_COMPLETE_RESPONSE" then
		self:OnMissionCompleteResponse(...);
	elseif event == "ADVENTURE_MAP_UPDATE_POIS" then
		self:RefreshAllData();
	end
end

function AdventureMap_MissionDataProviderMixin:RemoveAllData()
	self:GetAdventureMap():RemoveAllPinsByTemplate("AdventureMap_MissionPinTemplate");
	self:GetAdventureMap():RemoveAllPinsByTemplate("AdventureMap_MissionRewardPinTemplate");
	self:GetAdventureMap():RemoveLockReason("AdventureMap_MissionUI");
end

function AdventureMap_MissionDataProviderMixin:RefreshAllData(fromOnShow)
	if fromOnShow then
		self:RemoveAllData();
		-- We have to wait until the server sends us mission data before we can continue
		self.currentMissions = nil;
		return;
	end

	self:GetAdventureMap():RemoveAllPinsByTemplate("AdventureMap_MissionPinTemplate");
	-- Don't remove rewards, they'll clean themselves up

	local lastMissions = self.currentMissions;
	self.currentMissions = C_Garrison.GetAvailableMissions(LE_FOLLOWER_TYPE_GARRISON_7_0);
	if self.currentMissions then
		local inProgressMissions = C_Garrison.GetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_7_0);
		for i, missionInfo in ipairs(inProgressMissions) do
			self.currentMissions[#self.currentMissions + 1] = missionInfo;
			missionInfo.isComplete = missionInfo.missionEndTime - GetServerTime() <= 0;
		end

		self:CalculateMissionDeltas(lastMissions, self.currentMissions);

		for i, missionInfo in ipairs(self.currentMissions) do
			if not AdventureMap_IsPositionBlockedByZoneChoice(missionInfo.mapPosX, missionInfo.mapPosY) then
				self:AddMissionPin(missionInfo);
			end
		end
	end
end

function AdventureMap_MissionDataProviderMixin:CalculateMissionDeltas(lastMissions, currentMissions)
	if lastMissions then
		for currentMissionIndex = 1, #currentMissions do
			local missionInfo = currentMissions[currentMissionIndex];
			local found = false;
			for lastMissionIndex = 1, #lastMissions do
				local lastMission = lastMissions[lastMissionIndex];

				if missionInfo.missionID == lastMission.missionID then
					found = true;

					if missionInfo.inProgress and not lastMission.inProgress then
						missionInfo.justStarted = true;
					elseif missionInfo.isComplete and not lastMission.isComplete then
						missionInfo.justCompleted = true;
					end
					break;
				end
			end

			if not found then
				missionInfo.newMission = true;
			end
		end
	else
	    for i, missionInfo in ipairs(currentMissions) do
		    missionInfo.newMission = true;
	    end
	end
end

function AdventureMap_MissionDataProviderMixin:AddMissionPin(missionInfo)
	local pin = self:GetAdventureMap():AcquirePin("AdventureMap_MissionPinTemplate");
	pin.dataProvider = self;
	pin:SetupMission(missionInfo);
	pin:SetPosition(missionInfo.mapPosX, missionInfo.mapPosY);
	pin:Show();
end

local ShowGarrisonMission -- TODO_DW for now, just load up 6.0 missions and do some hacks to make it mostly work..
do

	local function SetMissionRegionsShown(shown)
		GarrisonMissionFrame.BackgroundTile:SetShown(shown);

		GarrisonMissionFrame.Top:SetShown(shown);
		GarrisonMissionFrame.Bottom:SetShown(shown);
		GarrisonMissionFrame.Left:SetShown(shown);
		GarrisonMissionFrame.Right:SetShown(shown);

		GarrisonMissionFrame.TopLeftCorner:SetShown(shown);
		GarrisonMissionFrame.TopRightCorner:SetShown(shown);
		GarrisonMissionFrame.BotLeftCorner:SetShown(shown);
		GarrisonMissionFrame.BotRightCorner:SetShown(shown);
		
		GarrisonMissionFrame.TopLeftGarrCorner:SetShown(shown);
		GarrisonMissionFrame.TopRightGarrCorner:SetShown(shown);
		GarrisonMissionFrame.BottomLeftGarrCorner:SetShown(shown);
		GarrisonMissionFrame.BottomRightGarrCorner:SetShown(shown);

		GarrisonMissionFrame.BottomBorder:SetShown(shown);
		GarrisonMissionFrame.LeftBorder:SetShown(shown);
		GarrisonMissionFrame.RightBorder:SetShown(shown);
		GarrisonMissionFrame.TopBorder:SetShown(shown);

		GarrisonMissionFrame.CloseButton:SetShown(shown);
		GarrisonMissionFrame.TitleText:SetShown(shown);

		GarrisonMissionFrameTab1:SetShown(shown);
		GarrisonMissionFrameTab2:SetShown(shown);
	end

	local hasHooked = false;
	local isShownViaAdventureMap = false;
	local isHidePending = false;
	local function TryHooks(dataProvider)
		if hasHooked then return end

		GarrisonMissionFrame:HookScript("OnUpdate", function()
			if isHidePending then
				isHidePending = false;
				GarrisonMissionFrame:Hide();
			end
		end);

		GarrisonMissionFrame:HookScript("OnHide", function() 
			isHidePending = false;
			isShownViaAdventureMap = false; 
			GarrisonMissionFrame:SetParent(UIParent);
			GarrisonFollowerPlacerFrame:SetParent(UIParent);
			GarrisonFollowerPlacerFrame:SetFrameStrata("HIGH");
			SetMissionRegionsShown(true);
			dataProvider:CancelStartMission();
		end);

		GarrisonMissionFrame.MissionTab.MissionPage:HookScript("OnHide", function()
			if isShownViaAdventureMap then
				isHidePending = true;
			end
		end);

		hasHooked = true;
	end

	function ShowGarrisonMission(dataProvider, missionInfo)
		Garrison_LoadUI();
		TryHooks(dataProvider);

		GarrisonMissionFrame:SetParent(dataProvider:GetAdventureMap());
		GarrisonMissionFrame:SetFrameStrata("HIGH");
		GarrisonMissionFrame.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0;
		GarrisonMissionFrame:Show();
		GarrisonMissionFrame:OnClickMission(missionInfo);
		GarrisonMissionFrame:SelectTab(1);

		GarrisonFollowerPlacerFrame:SetParent(dataProvider:GetAdventureMap());
		GarrisonFollowerPlacerFrame:SetFrameStrata("DIALOG");

		SetMissionRegionsShown(false);

		isShownViaAdventureMap = true;
	end
end

function AdventureMap_MissionDataProviderMixin:StartMission(missionInfo)
	ShowGarrisonMission(self, missionInfo);

	self:GetAdventureMap():AddLockReason("AdventureMap_MissionUI");
	AdventureMapQuestChoiceDialog:DeclineQuest(true);
end

function AdventureMap_MissionDataProviderMixin:CancelStartMission()
	self:GetAdventureMap():RemoveLockReason("AdventureMap_MissionUI");
end

function AdventureMap_MissionDataProviderMixin:CompleteMission(missionInfo)
	if not self.completingMissionInfo then
		self.completingMissionInfo = missionInfo;
		PlaySound("UI_Garrison_Mission_Complete_Encounter_Chance");
		C_Garrison.MarkMissionComplete(missionInfo.missionID);
	end
end

function AdventureMap_MissionDataProviderMixin:OnMissionCompleteResponse(missionID, canComplete, succeeded, followerDeaths)
	if self.completingMissionInfo and self.completingMissionInfo.missionID == missionID then
		local missionInfo = self.completingMissionInfo;
		self.completingMissionInfo = nil;

		if succeeded then
			PlaySound("UI_Garrison_CommandTable_MissionSuccess_Stinger");
		end

		C_Garrison.MissionBonusRoll(missionID);

		self:ReleasePinByMissionID(missionID);

		local rewardPin = self:GetAdventureMap():AcquirePin("AdventureMap_MissionRewardPinTemplate");
		rewardPin.dataProvider = self;
		rewardPin:ShowRewards(missionInfo);
		rewardPin:SetPosition(missionInfo.mapPosX, missionInfo.mapPosY);
		rewardPin:Show();
	end
end

function AdventureMap_MissionDataProviderMixin:ReleasePinByMissionID(missionID)
	for pin in self:GetAdventureMap():EnumeratePinsByTemplate("AdventureMap_MissionPinTemplate") do
		if pin.missionInfo.missionID == missionID then
			self:GetAdventureMap():RemovePin(pin);
			break;
		end
	end
end


AdventureMap_MissionPinMixin = CreateFromMixins(AdventureMapPinMixin);

function AdventureMap_MissionPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN);
	self:SetMaxZoomScale(1.0);
end

function AdventureMap_MissionPinMixin:OnReleased()
	self.OnNewAnim:Stop();
	self.OnCompleteAnim:Stop();
	self.OnStartAnim:Stop();

	self.missionInfo = nil;
end

function AdventureMap_MissionPinMixin:OnCanvasScaleChanged()
	AdventureMapPinMixin.OnCanvasScaleChanged(self);
	if self.Model:IsShown() then
		self.Model:RefreshCamera();
	end
end

function AdventureMap_MissionPinMixin:SetupMission(missionInfo)
	self.missionInfo = missionInfo;

	if self.missionInfo.isComplete then
		self.Icon:Hide();
		self.IconHighlight:SetTexture(nil);
		self.Model:Show();
		self.PortraitFrame:Hide();

		self.Status:Show();
		self.StatusBackground:Show();

		self:UpdateStatusLabel();
	elseif self.missionInfo.inProgress then
		-- Just choose the first follower for now
		local portraitData = C_Garrison.GetFollowerPortraitIconID(self.missionInfo.followers[1]);
		self.Icon:SetTexture(portraitData);
		self.Icon:SetSize(35, 35);
		self.Icon:Show();
		self.IconHighlight:SetTexture(portraitData);
		self.IconHighlight:SetSize(35, 35);

		self.PortraitFrame:Show();
		self.Model:Hide();

		self.Status:Show();
		self.StatusBackground:Show();

		self:UpdateStatusLabel();
	else
		self.Icon:SetAtlas("AdventureMapIcon-MissionCombat", true);
		self.IconHighlight:SetAtlas("AdventureMapIcon-MissionCombat", true);
		self.Icon:Show();
		self.Model:Hide();
		self.PortraitFrame:Hide();
		self.Status:Hide();
		self.StatusBackground:Hide();
	end

	if self:GetAdventureMap():IsZoomedIn() then
		if self.missionInfo.newMission then
			self.OnNewAnim:Play();
		elseif self.missionInfo.justCompleted then
			self.OnCompleteAnim:Play();
		elseif self.missionInfo.justStarted then
			self.OnStartAnim:Play();
		end
	end
end

function AdventureMap_MissionPinMixin:UpdateStatusLabel()
	if self.missionInfo.isComplete then
		self.Status:SetText(COMPLETE);
		self.Status:SetVertexColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	elseif self.missionInfo.inProgress then
		local timeLeftSec = self.missionInfo.missionEndTime - GetServerTime();
		if timeLeftSec > 0 then
			self.Status:SetText(SecondsToTime(timeLeftSec, false, false, 1));
		else
			self.Status:SetText(SECONDS_ABBR:format(0));
		end
		self.Status:SetVertexColor(.0117, .921, 1.0);
	end
end

function AdventureMap_MissionPinMixin:OnUpdate()
	if self.missionInfo.inProgress then
		self:UpdateStatusLabel();
	end
end

function AdventureMap_MissionPinMixin:OnClick(button)
	if button == "LeftButton" then
		if self.missionInfo.isComplete then
			self.dataProvider:CompleteMission(self.missionInfo);
		elseif self.missionInfo.inProgress then
			-- Nothing currently
		else
			self.dataProvider:StartMission(self.missionInfo);
		end
	end
end

function AdventureMap_MissionPinMixin:OnMouseEnter()
	AdventureMap_MissionPinTooltip:ClearAllPoints();
	AdventureMap_MissionPinTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -10, -10);
	AdventureMap_MissionPinTooltip:SetMissionInfo(self.missionInfo);
end

function AdventureMap_MissionPinMixin:OnMouseLeave()
	AdventureMap_MissionPinTooltip:Hide();
end


AdventureMap_MissionRewardPinMixin = CreateFromMixins(AdventureMapPinMixin);

function AdventureMap_MissionRewardPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN);
	self:SetMaxZoomScale(1.0);
end

function AdventureMap_MissionRewardPinMixin:ShowRewards(missionInfo)
	local numRewards = missionInfo.numRewards;
	local index = 1;
	for id, reward in pairs(missionInfo.rewards) do
		local rewardFrame = self.Rewards[index];
		if rewardFrame then
			rewardFrame.id = id;
			rewardFrame.Icon:Show();
			rewardFrame.BG:Show();
			rewardFrame.Name:Show();
			rewardFrame.shouldPlayAnim = not rewardFrame:IsShown();

			GarrisonMissionPage_SetReward(rewardFrame, reward);
		end
		index = index + 1;
	end
	for i = numRewards + 1, #self.Rewards do
		self.Rewards[i]:Hide();
	end

	local currencyMultipliers, goldMultiplier = select(8, C_Garrison.GetPartyMissionInfo(missionInfo.missionID));
	GarrisonMissionPage_UpdateRewardQuantities(self, currencyMultipliers, goldMultiplier);

	self.FadeInAnim:Play();
end

function AdventureMap_MissionRewardPinMixin:OnFadeInFinished()
	for i, rewardFrame in ipairs(self.Rewards) do
		if rewardFrame:IsShown() and rewardFrame.shouldPlayAnim then
			rewardFrame.Anim:Play();
		end
	end

	self.pendingFadeOut = true;
	C_Timer.After(5, function() self:CheckFadeOut(); end);
end

function AdventureMap_MissionRewardPinMixin:CheckFadeOut()
	if not self.pendingFadeOut then
		return;
	end

	for i, rewardFrame in ipairs(self.Rewards) do
		if rewardFrame:IsShown() and rewardFrame:IsMouseOver() then
			C_Timer.After(5, function() self:CheckFadeOut(); end);
			return; -- Don't fade while mouse is over
		end
	end

	self.pendingFadeOut = false;
	self.FadeOutAnim:Play();
end

function AdventureMap_MissionRewardPinMixin:OnFadeOutFinished()
	self:GetAdventureMap():RemovePin(self);
end

function AdventureMap_MissionRewardPinMixin:OnReleased()
	self.FadeInAnim:Stop();
	self.FadeOutAnim:Stop();
	self.pendingFadeOut = false;

	for i, rewardFrame in ipairs(self.Rewards) do
		rewardFrame:Hide();
	end
end

function AdventureMap_MissionRewardPinMixin:OnClick(button)
	if button == "RightButton" then
		self:GetAdventureMap():RemovePin(self);
	end
end

function AdventureMap_MissionRewardPinMixin:OnCanvasScaleChanged()
	AdventureMapPinMixin.OnCanvasScaleChanged(self);
	if self.pendingFadeOut and self:GetAdventureMap():IsZoomingOut() then
		self.pendingFadeOut = false;
		self.FadeOutAnim:Play();
	end
end