WaypointDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function WaypointDataProviderMixin:GetPinTemplate()
	return "WaypointPinTemplate";
end

function WaypointDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
end

function WaypointDataProviderMixin:OnEvent(event, ...)
	if event == "SUPER_TRACKED_QUEST_CHANGED" then
		self:RefreshAllData();
	end
end

function WaypointDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WaypointDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	if not mapID then
		return;
	end

	if not GetCVarBool("questPOI") then
		return;
	end
	
	local superTrackedQuestID = GetSuperTrackedQuestID();
	if not superTrackedQuestID then
		return;
	end
	
	local x, y = C_QuestLog.GetNextWaypointForMap(GetSuperTrackedQuestID(), mapID);
	if x and y then
		self:AddQuest(superTrackedQuestID, x, y);
	end
end

function WaypointDataProviderMixin:AddQuest(questID, x, y)
	local pin = self:GetMap():AcquirePin(self:GetPinTemplate());
	pin.questID = questID;
	pin:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	pin:SetPosition(x, y);
	return pin;
end

--[[ Pin ]]--
WaypointPinMixin = CreateFromMixins(MapCanvasPinMixin);

function WaypointPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.4125, 0.4125);

	self.UpdateTooltip = self.OnMouseEnter;
end

function WaypointPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 5, 2);
	
	local waypointTitle = C_QuestLog.GetNextWaypointText(self.questID);
	GameTooltip_SetTitle(GameTooltip, waypointTitle, GREEN_FONT_COLOR);
	
	GameTooltip_AddColoredLine(GameTooltip, WAYPOINT_BEST_ROUTE_TOOLTIP, HIGHLIGHT_FONT_COLOR);
	
	local questLogIndex = GetQuestLogIndexByID(self.questID);
	local questTitle = GetQuestLogTitle(questLogIndex);
	GameTooltip_AddNormalLine(GameTooltip, questTitle);

	GameTooltip:Show();
end

function WaypointPinMixin:OnMouseLeave()
	GameTooltip:Hide();
end

function WaypointPinMixin:OnMouseDown()
	self.Texture:Hide();
	self.PushedTexture:Show();
	self.Icon:SetPoint("CENTER", 2, -2);
end

function WaypointPinMixin:OnMouseUp()
	self.Texture:Show();
	self.PushedTexture:Hide();
	self.Icon:SetPoint("CENTER", 0, 0);
end