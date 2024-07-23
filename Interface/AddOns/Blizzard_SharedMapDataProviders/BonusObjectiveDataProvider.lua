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

	mapCanvas:SetPinTemplateType("BonusObjectivePinTemplate", "Button");
	mapCanvas:SetPinTemplateType("ThreatObjectivePinTemplate", "Button");

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
	self:SetDefaultMapPinScale();
	self.UpdateTooltip = self.OnMouseEnter;
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function BonusObjectivePinMixin:OnAcquired(taskInfo)
	self:SetPosition(taskInfo.x, taskInfo.y);
	self:SetQuestID(taskInfo.questId);
	self.numObjectives = taskInfo.numObjectives;
	self.isQuestStart = taskInfo.isQuestStart;
	self.isCombatAllyQuest = taskInfo.isCombatAllyQuest;
	self.dataProvider = taskInfo.dataProvider;
	self.isSuperTracked = self.questID == C_SuperTrack.GetSuperTrackedQuestID();
	self:UseFrameLevelType(self.isSuperTracked and "PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST" or "PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
	self.Display:ClearAllPoints();
	self.Display:SetPoint("CENTER");
	self:SetSelected(self.isSuperTracked);
	self:SetStyle(self:GetPOIButtonStyle());
	self:UpdateButtonStyle();

	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);

	if not HaveQuestRewardData(self.questID) then
		C_TaskQuest.RequestPreloadRewardData(self.questID);
	end
end

function BonusObjectivePinMixin:GetPOIButtonStyle()
	return POIButtonUtil.Style.BonusObjective;
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

function BonusObjectivePinMixin:DisableInheritedMotionScriptsWarning()
	return true;
end

function BonusObjectivePinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
	POIButtonMixin.OnEnter(self);
	self:OnLegendPinMouseEnter();
end

function BonusObjectivePinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
	POIButtonMixin.OnLeave(self);
	self:OnLegendPinMouseLeave();
end

function BonusObjectivePinMixin:OnMouseDownAction()
	POIButtonMixin.OnMouseDown(self);
end

function BonusObjectivePinMixin:OnMouseUpAction()
	POIButtonMixin.OnMouseUp(self);
end

function BonusObjectivePinMixin:OnMouseClickAction(button)
	POIButtonMixin.OnClick(self, button);
end

--[[ Threat Objective Pin ]]--
ThreatObjectivePinMixin = CreateFromMixins(BonusObjectivePinMixin);

function ThreatObjectivePinMixin:OnLoad()
	self:SetDefaultMapPinScale();
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function ThreatObjectivePinMixin:GetPOIButtonStyle()
	return POIButtonUtil.Style.QuestThreat;
end