BonusObjectiveDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function BonusObjectiveDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("BonusObjectivePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("ThreatObjectivePinTemplate");
end

function BonusObjectiveDataProviderMixin:CancelCallbacks()
	if self.cancelCallbacks then
		for i, callback in ipairs(self.cancelCallbacks) do
			callback();
		end
		self.cancelCallbacks = nil;
	end
end

function BonusObjectiveDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:RegisterEvent("QUEST_LOG_UPDATE");

	self:GetMap():RegisterCallback("SetFocusedQuestID", self.OnSetFocusedQuestID, self);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.OnClearFocusedQuestID, self);
	self:GetMap():RegisterCallback("SetBounty", self.SetBounty, self);
end

function BonusObjectiveDataProviderMixin:SetBounty(bountyQuestID, bountyFactionID, bountyFrameType)
	local changed = self.bountyQuestID ~= bountyQuestID;
	if changed then
		self.bountyQuestID = bountyQuestID;
		self.bountyFactionID = bountyFactionID;
		self.bountyFrameType = bountyFrameType;
		if self:GetMap() then
			self:RefreshAllData();
		end
	end
end

function BonusObjectiveDataProviderMixin:GetBountyInfo()
	return self.bountyQuestID, self.bountyFactionID, self.bountyFrameType;
end

function BonusObjectiveDataProviderMixin:OnSetFocusedQuestID(...)
	self.hidePins = true;
	self:RefreshAllData(...);
end

function BonusObjectiveDataProviderMixin:OnClearFocusedQuestID(...)
	self.hidePins = false;
	self:RefreshAllData(...);
end

function BonusObjectiveDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetFocusedQuestID", self);
	self:GetMap():UnregisterCallback("ClearFocusedQuestID", self);
	self:GetMap():UnregisterCallback("SetBounty", self);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function BonusObjectiveDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

local sortTypeToPinTemplate = {
	[QuestSortType.Threat] = "ThreatObjectivePinTemplate",
	[QuestSortType.BonusObjective] = "BonusObjectivePinTemplate",
};

function BonusObjectiveDataProviderMixin:GetPinTemplateFromTask(taskInfo)
	return sortTypeToPinTemplate[QuestUtils_GetTaskSortType(taskInfo)];
end

function BonusObjectiveDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	if not mapID or self.hidePins then
		return;
	end

	local taskInfo = GetQuestsForPlayerByMapIDCached(mapID);

	if taskInfo and #taskInfo > 0 then
		self:CancelCallbacks();
		self.cancelCallbacks = {};

		for i, info in ipairs(taskInfo) do
			local callback = QuestEventListener:AddCancelableCallback(info.questId, function()
				if MapUtil.ShouldShowTask(mapID, info) then
					local pinTemplate = self:GetPinTemplateFromTask(info);
					if pinTemplate then
						info.dataProvider = self;
						self:GetMap():AcquirePin(pinTemplate, info);
					end
				end
			end);

			tinsert(self.cancelCallbacks, callback);
		end
	end
end

function BonusObjectiveDataProviderMixin:OnHide()
	MapCanvasDataProviderMixin.OnHide(self);
	self:CancelCallbacks();
end

--[[ Bonus Objective Pin ]]--
BonusObjectivePinMixin = CreateFromMixins(MapCanvasPinMixin);

function BonusObjectivePinMixin:OnLoad()
	self.UpdateTooltip = self.OnMouseEnter;
	self:SetScalingLimits(1, 0.825, 0.85);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function BonusObjectivePinMixin:OnAcquired(taskInfo)
	self:SetPosition(taskInfo.x, taskInfo.y);
	self.questID = taskInfo.questId;
	self.numObjectives = taskInfo.numObjectives;
	self.isQuestStart = taskInfo.isQuestStart;
	self.isCombatAllyQuest = taskInfo.isCombatAllyQuest;
	self.dataProvider = taskInfo.dataProvider;
	if C_QuestLog.IsQuestCalling(self.questID) then
		self.Texture:SetAtlas("Quest-DailyCampaign-Available", false);
	elseif C_QuestLog.IsImportantQuest(self.questID) then
		self.Texture:SetAtlas("importantavailablequesticon", false);
	elseif taskInfo.isDaily then
		self.Texture:SetAtlas("UI-QuestPoiRecurring-QuestBang", false);
	elseif taskInfo.isMeta then
		self.Texture:SetAtlas("UI-QuestPoiWrapper-QuestBang", false);
	elseif taskInfo.isQuestStart then
		self.Texture:SetAtlas("QuestNormal", false);
	else
		self.Texture:SetAtlas("QuestBonusObjective", false);
	end

	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);

	if taskInfo.isDaily or taskInfo.isQuestStart then
		self:SetScalingLimits(1, 1.0, 1.2);
		self.Texture:SetSize(22, 22);
	else
		self:SetScalingLimits(1, 0.825, 0.85);
		self.Texture:SetSize(30, 30);
	end

	if not HaveQuestRewardData(self.questID) then
		C_TaskQuest.RequestPreloadRewardData(self.questID);
	end
end

function BonusObjectivePinMixin:GetHighlightType() -- override
	local bountyQuestID, bountyFactionID, bountyFrameType = self.dataProvider:GetBountyInfo();
	if bountyFrameType == BountyFrameType.ActivityTracker then
		local questTitle, taskFactionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(self.questID);
		local countsForBounty = (self.questID and bountyQuestID and C_QuestLog.IsQuestCriteriaForBounty(self.questID, bountyQuestID)) or (taskFactionID and taskFactionID == bountyFactionID);
		if countsForBounty then
			return MapPinHighlightType.SupertrackedHighlight;
		end
	end

	return MapPinHighlightType.None;
end

function BonusObjectivePinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function BonusObjectivePinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end

--[[ Threat Objective Pin ]]--
ThreatObjectivePinMixin = CreateFromMixins(MapCanvasPinMixin);

function ThreatObjectivePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.425, 0.425);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function ThreatObjectivePinMixin:OnAcquired(taskInfo)
	local completed, x, y = QuestPOIGetIconInfo(taskInfo.questId);
	if x and y then
		taskInfo.x = x;
		taskInfo.y = y;
	end	

	self:SetPosition(taskInfo.x, taskInfo.y);
	self.questID = taskInfo.questId;
	self.numObjectives = taskInfo.numObjectives;
	self.isThreat = true;

	local isSuperTracked = (taskInfo.questId == C_SuperTrack.GetSuperTrackedQuestID());
	if isSuperTracked then
		self.Texture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
		self.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
	else
		self.Texture:SetTexCoord(0.875, 1, 0.375, 0.5);
		self.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);
	end

	if not HaveQuestRewardData(self.questID) then
		C_TaskQuest.RequestPreloadRewardData(self.questID);
	end

	self.Icon:SetAtlas(QuestUtil.GetThreatPOIIcon(self.questID));
end

function ThreatObjectivePinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function ThreatObjectivePinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end

function ThreatObjectivePinMixin:OnMouseDownAction()
	self.Texture:Hide();
	self.PushedTexture:Show();
	self.Icon:SetPoint("CENTER", 1, -1);
	if self.moveHighlightOnMouseDown then
		self.Highlight:SetPoint("CENTER", 2, -2);
	end
end

function ThreatObjectivePinMixin:OnMouseUpAction()
	self.Texture:Show();
	self.PushedTexture:Hide();
	self.Icon:SetPoint("CENTER", 0, 0);
	if self.moveHighlightOnMouseDown then
		self.Highlight:SetPoint("CENTER", 0, 0);
	end
end

function ThreatObjectivePinMixin:OnMouseClickAction()
	C_SuperTrack.SetSuperTrackedQuestID(self.questID);
end