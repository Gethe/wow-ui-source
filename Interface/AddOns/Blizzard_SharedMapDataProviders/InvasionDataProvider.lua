InvasionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function InvasionDataProviderMixin:OnShow()
	self:RegisterEvent("QUEST_LOG_UPDATE");
end

function InvasionDataProviderMixin:OnHide()
	self:UnregisterEvent("QUEST_LOG_UPDATE");
end

function InvasionDataProviderMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:RefreshAllData();
	end
end

function InvasionDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("InvasionPinTemplate");
end

function InvasionDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	local mapID = self:GetMap():GetMapID();
	local invasionID = C_InvasionInfo.GetInvasionForUiMapID(mapID);

	if invasionID then
		local invasionInfo = C_InvasionInfo.GetInvasionInfo(invasionID);
		if invasionInfo then
			self:GetMap():AcquirePin("InvasionPinTemplate", invasionInfo);
		end
	end
end

--[[ Pin ]]--
InvasionPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_INVASION");

function InvasionPinMixin:OnAcquired(invasionInfo)
	BaseMapPoiPinMixin.OnAcquired(self, invasionInfo);

	self.invasionID = invasionInfo.invasionID;
end

function InvasionPinMixin:OnMouseEnter()
	local invasionInfo = C_InvasionInfo.GetInvasionInfo(self.invasionID);
	local timeLeftMinutes = C_InvasionInfo.GetInvasionTimeLeft(self.invasionID);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(invasionInfo.name, HIGHLIGHT_FONT_COLOR:GetRGB());

	if timeLeftMinutes and timeLeftMinutes > 0 then
		local timeString = SecondsToTime(timeLeftMinutes * 60);
		GameTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), NORMAL_FONT_COLOR:GetRGB());
	end

	if invasionInfo.rewardQuestID then
		if not HaveQuestData(invasionInfo.rewardQuestID) then
			GameTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
		else
			GameTooltip_AddQuestRewardsToTooltip(GameTooltip, invasionInfo.rewardQuestID);
		end
	end

	GameTooltip:Show();
end

function InvasionPinMixin:OnMouseLeave()
	GameTooltip:Hide();
end