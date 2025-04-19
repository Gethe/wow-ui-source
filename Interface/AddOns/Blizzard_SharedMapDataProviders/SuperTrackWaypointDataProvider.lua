SuperTrackWaypointDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function SuperTrackWaypointDataProviderMixin:OnShow()
	self:RegisterEvent("SUPER_TRACKING_PATH_UPDATED");
end

function SuperTrackWaypointDataProviderMixin:OnHide()
	self:UnregisterEvent("SUPER_TRACKING_PATH_UPDATED");
end

function SuperTrackWaypointDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData();
end

function SuperTrackWaypointDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("SuperTrackWaypointPinTemplate");
end

do
	local function ShouldShowSuperTrackedWaypoint()
		-- QuestDataProviderMixin already has a way to handle waypoints, and needs to keep doing that because
		-- it adds waypoints for quests that aren't supertracked (e.g. when details are shown)
		local supertrackedQuestID = QuestSuperTracking_GetSuperTrackedQuestID();
		return not supertrackedQuestID or QuestUtils_IsQuestWorldQuest(supertrackedQuestID);
	end

	function SuperTrackWaypointDataProviderMixin:RefreshAllData(fromOnShow)
		self:RemoveAllData();

		if ShouldShowSuperTrackedWaypoint() then
			local mapID = self:GetMap():GetMapID();
			local x, y, waypointText = C_SuperTrack.GetNextWaypointForMap(mapID);
			if x and y then
				self.pin = self:GetMap():AcquirePin("SuperTrackWaypointPinTemplate", x, y, waypointText);
			end
		end
	end
end

SuperTrackWaypointPinMixin = CreateFromMixins(MapCanvasPinMixin);

function SuperTrackWaypointPinMixin:DisableInheritedMotionScriptsWarning()
	return true;
end

function SuperTrackWaypointPinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
end

function SuperTrackWaypointPinMixin:OnAcquired(x, y, waypointText)
	self.waypointText = waypointText;
	self:SetPosition(x, y);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_SUPER_TRACKED_CONTENT");

	self:SetSelected(true);
	self:SetStyle(POIButtonUtil.Style.Waypoint);
	self:UpdateButtonStyle();
end

function SuperTrackWaypointPinMixin:OnMouseClickAction(mouseButton)
	if mouseButton == "LeftButton" then
		C_SuperTrack.ClearAllSuperTracked();
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_SUPER_TRACK_OFF);
	end
end

function SuperTrackWaypointPinMixin:OnMouseEnter()
	local name, description = C_SuperTrack.GetSuperTrackedItemName();
	if name then
		-- NOTE: Non-standard usage of tooltip coloring to exactly match what quests are doing.
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT", -16, -4);
		tooltip:SetText(name);

		if description then
			GameTooltip_AddNormalLine(tooltip, description);
		end

		if self.waypointText then
			GameTooltip_AddColoredLine(tooltip, QUEST_DASH..self.waypointText, HIGHLIGHT_FONT_COLOR);
		end

		tooltip:Show();
	end
end

function SuperTrackWaypointPinMixin:OnMouseLeave()
	GetAppropriateTooltip():Hide();
end