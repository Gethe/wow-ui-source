
QuestBlobDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function QuestBlobDataProviderMixin:SetShowWorldQuests(showWorldQuests)
	self.showWorldQuests = showWorldQuests;
	if self.pin then
		self.pin:Refresh();
	end
end

function QuestBlobDataProviderMixin:IsShowingWorldQuests()
	return not not self.showWorldQuests;
end

function QuestBlobDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("QuestBlobPinTemplate", "QuestPOIFrame");

	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("QuestBlobPinTemplate");
	pin.dataProvider = self;
	pin:SetPosition(0.5, 0.5);
	self.pin = pin;

	self:GetMap():RegisterCallback("SetHighlightedQuestID", self.OnSetHighlightedQuestID, self);
	self:GetMap():RegisterCallback("ClearHighlightedQuestID", self.OnClearHighlightedQuestID, self);
	self:GetMap():RegisterCallback("SetFocusedQuestID",self.OnSetFocusedQuestID, self);
	self:GetMap():RegisterCallback("ClearFocusedQuestID", self.OnClearFocusedQuestID, self);
	self:GetMap():RegisterCallback("SetHighlightedQuestPOI", self.OnSetHighlightedQuestPOI, self);
	self:GetMap():RegisterCallback("ClearHighlightedQuestPOI", self.OnClearHighlightedQuestPOI, self);
end

function QuestBlobDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetHighlightedQuestID", self);
	self:GetMap():UnregisterCallback("ClearHighlightedQuestID", self);
	self:GetMap():UnregisterCallback("SetFocusedQuestID", self);
	self:GetMap():UnregisterCallback("ClearFocusedQuestID", self);
	self:GetMap():UnregisterCallback("SetHighlightedQuestPOI", self);
	self:GetMap():UnregisterCallback("ClearHighlightedQuestPOI", self);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function QuestBlobDataProviderMixin:OnSetHighlightedQuestID(...)
	self.pin:SetHighlightedQuestID(...);
end

function QuestBlobDataProviderMixin:OnClearHighlightedQuestID(...)
	self.pin:ClearHighlightedQuestID(...);
end

function QuestBlobDataProviderMixin:OnSetFocusedQuestID(...)
	self.pin:SetFocusedQuestID(...);
end

function QuestBlobDataProviderMixin:OnClearFocusedQuestID(...)
	self.pin:ClearFocusedQuestID(...);
end

function QuestBlobDataProviderMixin:OnSetHighlightedQuestPOI(...)
	self.pin:SetHighlightedQuestPOI(...);
end

function QuestBlobDataProviderMixin:OnClearHighlightedQuestPOI(...)
	self.pin:ClearHighlightedQuestPOI(...);
end

function QuestBlobDataProviderMixin:OnMapChanged()
	self.pin:OnMapChanged();
end

--[[ Quest Blob Pin ]]--
QuestBlobPinMixin = CreateFromMixins(MapCanvasPinMixin);

function QuestBlobPinMixin:OnLoad()
	self:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(1.0);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_QUEST_BLOB");
	self.questID = 0;
end

function QuestBlobPinMixin:OnShow()
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:SetQuestID(C_SuperTrack.GetSuperTrackedQuestID());
end

function QuestBlobPinMixin:OnHide()
	self:UnregisterEvent("SUPER_TRACKING_CHANGED");
end

function QuestBlobPinMixin:OnEvent(event, ...)
	if event == "SUPER_TRACKING_CHANGED" then
		self:SetQuestID(C_SuperTrack.GetSuperTrackedQuestID());
	end
end

function QuestBlobPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
end

function QuestBlobPinMixin:OnCanvasScaleChanged()
	-- need to wait until end of the frame to update
	self:MarkDirty();
end

function QuestBlobPinMixin:MarkDirty()
	self.dirty = true;
end

function QuestBlobPinMixin:SetQuestID(questID)
	self.questID = questID;
	self:Refresh();
end

function QuestBlobPinMixin:OnUpdate()
	if self.dirty then
		self.dirty = nil;
		self:Refresh();
	end

	self:UpdateTooltip();
end

function QuestBlobPinMixin:TryDrawQuest(questID)
	if questID and questID > 0 and (self.dataProvider:IsShowingWorldQuests() or not QuestUtils_IsQuestWorldQuest(questID)) and (C_QuestLog.IsThreatQuest(questID) or not QuestUtils_IsQuestBonusObjective(questID)) then
		self:DrawBlob(questID, true);
	end
end

function QuestBlobPinMixin:Refresh()
	self:DrawNone();
	if not self.mapAllowsBlobs or not GetCVarBool("questPOI") then
		return;
	end

	if not self.focusedQuestID then
		self:TryDrawQuest(self.questID);
	end

	self:TryDrawQuest(self.highlightedQuestID);
	self:TryDrawQuest(self.focusedQuestID);
end

function QuestBlobPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	local mapInfo = C_Map.GetMapInfo(mapID);
	self.mapAllowsBlobs = MapUtil.ShouldMapTypeShowQuests(mapInfo.mapType);
	self:SetMapID(mapID);
	self:Refresh();
end

function QuestBlobPinMixin:SetHighlightedQuestID(questID)
	self.highlightedQuestID = questID;
	self:Refresh();
end

function QuestBlobPinMixin:ClearHighlightedQuestID()
	self.highlightedQuestID = nil;
	self:Refresh();
end

function QuestBlobPinMixin:SetFocusedQuestID(questID)
	self.focusedQuestID = questID;
	self:Refresh();
end

function QuestBlobPinMixin:ClearFocusedQuestID()
	self.focusedQuestID = nil;
	self:Refresh();
end

function QuestBlobPinMixin:SetHighlightedQuestPOI(questID)
	self.highlightedQuestPOI = questID;
	self:Refresh();
end

function QuestBlobPinMixin:ClearHighlightedQuestPOI()
	self.highlightedQuestPOI = nil;
	self:Refresh();
end

function QuestBlobPinMixin:UpdateTooltip()
	if self.highlightedQuestPOI then
		return;
	end

	local mouseX, mouseY = self:GetMap():GetNormalizedCursorPosition();
	local questID, numPOITooltips = self:UpdateMouseOverTooltip(mouseX, mouseY);
	local questLogIndex = questID and C_QuestLog.GetLogIndexForQuestID(questID);
	if not questLogIndex then
		self:OnMouseLeave();
		return;
	end

	local gameTooltipOwner = GameTooltip:GetOwner();
	if gameTooltipOwner and gameTooltipOwner ~= self then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);

	local title = C_QuestLog.GetTitleForQuestID(questID);
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex);

	if C_QuestLog.IsThreatQuest(questID) then
		local skipSetOwner = true;
		TaskPOI_OnEnter(self, skipSetOwner);
		return;
	end

	GameTooltip:SetText(title);
	QuestUtils_AddQuestTypeToTooltip(GameTooltip, questID, NORMAL_FONT_COLOR);

	for i = 1, numObjectives do
		local text, objectiveType, finished;

		if numPOITooltips == numObjectives then
			local questPOIIndex = self:GetTooltipIndex(i);
			text, objectiveType, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex);
		else
			text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
		end

		if text and not finished then
			GameTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
		end
	end
	GameTooltip:Show();
end

function QuestBlobPinMixin:OnMouseEnter()
	self:UpdateTooltip();
end

function QuestBlobPinMixin:OnMouseLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end