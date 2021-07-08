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
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:RegisterEvent("QUEST_LOG_UPDATE");

	self:GetMap():RegisterCallback("SetFocusedQuestID", self.OnSetFocusedQuestID, self);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.OnClearFocusedQuestID, self);
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

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function BonusObjectiveDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
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
				if MapUtil.ShouldShowTask(mapID, info) and not QuestUtils_IsQuestWorldQuest(info.questId) then
					if C_QuestLog.IsThreatQuest(info.questId) then
						local completed, x, y = QuestPOIGetIconInfo(info.questId);
						if x and y then
							info.x = x;
							info.y = y;
						end
						local pin = self:GetMap():AcquirePin("ThreatObjectivePinTemplate", info);
						local iconAtlas = QuestUtil.GetThreatPOIIcon(info.questId);
						pin.Icon:SetAtlas(iconAtlas);
					else
						self:GetMap():AcquirePin("BonusObjectivePinTemplate", info);
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
	self:SetScalingLimits(1, 0.825, 0.85);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function BonusObjectivePinMixin:OnAcquired(taskInfo)
	self:SetPosition(taskInfo.x, taskInfo.y);
	self.questID = taskInfo.questId;
	self.numObjectives = taskInfo.numObjectives;
	self.isQuestStart = taskInfo.isQuestStart;
	self.isCombatAllyQuest = taskInfo.isCombatAllyQuest;
	self.UpdateTooltip = nil;
	if C_QuestLog.IsQuestCalling(self.questID) then
		self.Texture:SetAtlas("Quest-DailyCampaign-Available", false);
		self.UpdateTooltip = self.OnMouseEnter;
	elseif taskInfo.isDaily then
		self.Texture:SetAtlas("QuestDaily", false);
	elseif taskInfo.isQuestStart then
		self.Texture:SetAtlas("QuestNormal", false);
	else
		self.Texture:SetAtlas("QuestBonusObjective", false);
	end

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

function BonusObjectivePinMixin:OnMouseEnter()
	TaskPOI_OnEnter(self);
end

function BonusObjectivePinMixin:OnMouseLeave()
	TaskPOI_OnLeave(self);
end

ThreatObjectivePinMixin = CreateFromMixins(MapCanvasPinMixin);

function ThreatObjectivePinMixin:OnLoad()
	self:SetScalingLimits(1, 0.425, 0.425);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
end

function ThreatObjectivePinMixin:OnAcquired(taskInfo)
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