AdventureMap_MissionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AdventureMap_MissionDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
end

function AdventureMap_MissionDataProviderMixin:OnShow()
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	self:RegisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self:RegisterEvent("ADVENTURE_MAP_UPDATE_POIS");
end

function AdventureMap_MissionDataProviderMixin:OnHide()
	self:UnregisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:UnregisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:UnregisterEvent("GARRISON_MISSION_FINISHED");
	self:UnregisterEvent("GARRISON_MISSION_COMPLETE_RESPONSE");
	self:UnregisterEvent("ADVENTURE_MAP_UPDATE_POIS");
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
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_MissionPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_MissionRewardPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_CombatAllyMissionPinTemplate");
end

function AdventureMap_MissionDataProviderMixin:RefreshAllData(fromOnShow)
	if fromOnShow then
		self:RemoveAllData();
		-- We have to wait until the server sends us mission data before we can continue
		self.currentMissions = nil;
		return;
	end

	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_MissionPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_CombatAllyMissionPinTemplate");
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

		local mapAreaID = self:GetMap():GetMapID();
		for i, missionInfo in ipairs(self.currentMissions) do
			if not AdventureMap_IsPositionBlockedByZoneChoice(mapAreaID, missionInfo.mapPosX, missionInfo.mapPosY) then
				self:AddMissionPin(missionInfo);
			end
		end
		self:GetMap():RefreshInsets();
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
	local pin;
	if (missionInfo.isZoneSupport) then
		pin = self:GetMap():AcquirePin("AdventureMap_CombatAllyMissionPinTemplate");
	else
		pin = self:GetMap():AcquirePin("AdventureMap_MissionPinTemplate");
	end
	pin.dataProvider = self;
	pin:SetupMission(missionInfo);
	pin:SetPosition(missionInfo.mapPosX, missionInfo.mapPosY);
end

local function ShowGarrisonMission(dataProvider, missionInfo)
	local missionFrame = dataProvider:GetMap():GetParent();
	return missionFrame:OnClickMission(missionInfo);
end

function AdventureMap_MissionDataProviderMixin:StartMission(missionInfo)
	AdventureMapQuestChoiceDialog:DeclineQuest(true);
	return ShowGarrisonMission(self, missionInfo);
end

function AdventureMap_MissionDataProviderMixin:CompleteMission(missionInfo)
	if not self.completingMissionInfo then
		self.completingMissionInfo = missionInfo;
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE);
		C_Garrison.MarkMissionComplete(missionInfo.missionID);
	end
end

function AdventureMap_MissionDataProviderMixin:OnMissionCompleteResponse(missionID, canComplete, succeeded, overmaxSucceeded, followerDeaths)
	if self.completingMissionInfo and self.completingMissionInfo.missionID == missionID then
		local missionInfo = self.completingMissionInfo;
		self.completingMissionInfo = nil;

		if succeeded then
			PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_MISSION_SUCCESS_STINGER);
		end

		C_Garrison.MissionBonusRoll(missionID);

		self:ReleasePinByMissionID(missionID);

		local rewardPin = self:GetMap():AcquirePin("AdventureMap_MissionRewardPinTemplate");
		rewardPin.dataProvider = self;
		rewardPin:ShowRewards(missionInfo);
		rewardPin:SetPosition(missionInfo.mapPosX, missionInfo.mapPosY);
	end
end

function AdventureMap_MissionDataProviderMixin:ReleasePinByMissionID(missionID)
	for pin in self:GetMap():EnumeratePinsByTemplate("AdventureMap_MissionPinTemplate") do
		if pin.missionInfo.missionID == missionID then
			self:GetMap():RemovePin(pin);
			break;
		end
	end
end


AdventureMap_MissionPinMixin = CreateFromMixins(MapCanvasPinMixin);

function AdventureMap_MissionPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT);
	self:SetScalingLimits(1.25, 0.825, 1.275);
end

function AdventureMap_MissionPinMixin:OnReleased()
	self.OnNewAnim:Stop();
	self.OnCompleteAnim:Stop();
	self.OnStartAnim:Stop();

	self.missionInfo = nil;
end

function AdventureMap_MissionPinMixin:OnCanvasScaleChanged()
	MapCanvasPinMixin.OnCanvasScaleChanged(self);
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
		local atlas;
		if (self.missionInfo.typePrefix) then
			atlas = self.missionInfo.typePrefix .. "-Map";
		else
			atlas = "AdventureMapIcon-MissionCombat";
		end
		self.Icon:SetAtlas(atlas, true);
		self.IconHighlight:SetAtlas(atlas, true);
		self.Icon:Show();
		self.Model:Hide();
		self.PortraitFrame:Hide();
		self.Status:Hide();
		self.StatusBackground:Hide();
	end

	if not self:GetMap():IsAtMinZoom() then
		if self.missionInfo.newMission then
			self.OnNewAnim:Play();
		elseif self.missionInfo.justCompleted then
			self.OnCompleteAnim:Play();
		elseif self.missionInfo.justStarted then
			self.OnStartAnim:Play();
		end
	end

	self:GetMap():SetAreaTableIDAvailableForInsets(missionInfo.areaID);
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
		self.Status:SetVertexColor(1.0, 1.0, 1.0);
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
			local started = self.dataProvider:StartMission(self.missionInfo);
			if started and self.missionInfo.isZoneSupport then

				local subViewLeft = (self:GetMap().ZoneSupportMissionPage.ZoneArea:GetLeft() - self:GetMap().ScrollContainer:GetLeft()) / self:GetMap().ScrollContainer:GetWidth();
				local subViewRight = (self:GetMap().ZoneSupportMissionPage.ZoneArea:GetRight() - self:GetMap().ScrollContainer:GetLeft()) / self:GetMap().ScrollContainer:GetWidth();
				local subViewTop = (self:GetMap().ZoneSupportMissionPage.ZoneArea:GetTop() - self:GetMap().ScrollContainer:GetBottom()) / self:GetMap().ScrollContainer:GetHeight();
				local subViewBottom = (self:GetMap().ZoneSupportMissionPage.ZoneArea:GetBottom() - self:GetMap().ScrollContainer:GetBottom()) / self:GetMap().ScrollContainer:GetHeight();

				-- these coordinates were chosen so the continent is visually centered in the subview.
				local left, right, top, bottom = 0.28, 0.68, 0.15, 0.55;
				local scale, centerX, centerY = self:GetMap():CalculateZoomScaleAndPositionForAreaInViewRect(left, right, top, bottom, subViewLeft, subViewRight, subViewTop, subViewBottom);

				self:GetMap():SetMaxZoom(scale);
				self:GetMap():PanAndZoomTo(centerX, centerY);
			end
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


AdventureMap_CombatAllyMissionPinMixin = CreateFromMixins(MapCanvasPinMixin,AdventureMap_MissionPinMixin);

function AdventureMap_CombatAllyMissionPinMixin:OnReleased()

	self.missionInfo = nil;

end

function AdventureMap_CombatAllyMissionPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT);
	self:SetScalingLimits(1.25, 0.9625, 1.275);
end

function AdventureMap_CombatAllyMissionPinMixin:OnCanvasScaleChanged()
	MapCanvasPinMixin.OnCanvasScaleChanged(self);
end

function AdventureMap_CombatAllyMissionPinMixin:SetupMission(missionInfo)
	self.missionInfo = missionInfo;

	if self.missionInfo.inProgress then
		local portraitData = C_Garrison.GetFollowerPortraitIconID(self.missionInfo.followers[1]);
		self.Icon:SetTexture(portraitData);
		self.Icon:Show();
		self.IconHighlight:SetTexture(portraitData);

		self.Status:Show();
		self.StatusBackground:Show();

		local spellID = C_Garrison.GetFollowerZoneSupportAbilities(self.missionInfo.followers[1]);
		local _, _, spellTexture = GetSpellInfo(spellID);
		self.Ability:SetTexture(spellTexture);
		self.Ability:Show();

		self:UpdateStatusLabel();
	else
		self.Icon:SetAtlas("AdventureMap-combatally-empty", false);
		self.IconHighlight:SetAtlas("AdventureMap-combatally-empty", false);
		self.Icon:Show();

		self.Status:Hide();
		self.StatusBackground:Hide();
		self.Ability:Hide();

	end
	self.LabelBackground:SetWidth(self.Label:GetWidth() + 15);
	self.LabelBackground:Show();
end

AdventureMap_MissionRewardPinMixin = CreateFromMixins(MapCanvasPinMixin);

function AdventureMap_MissionRewardPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_OUT);
	self:SetScalingLimits(1.25, 0.825, 1.275);
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
	self:GetMap():RemovePin(self);
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
		self:GetMap():RemovePin(self);
	end
end

function AdventureMap_MissionRewardPinMixin:OnCanvasScaleChanged()
	MapCanvasPinMixin.OnCanvasScaleChanged(self);
	if self.pendingFadeOut and self:GetMap():IsZoomingOut() then
		self.pendingFadeOut = false;
		self.FadeOutAnim:Play();
	end
end