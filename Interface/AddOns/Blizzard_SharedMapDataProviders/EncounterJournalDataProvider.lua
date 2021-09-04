
EncounterJournalDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function EncounterJournalDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	mapCanvas:SetPinTemplateType("EncounterJournalPinTemplate", "BUTTON");
end

function EncounterJournalDataProviderMixin:OnShow()
	self:RegisterEvent("PORTRAITS_UPDATED");
end

function EncounterJournalDataProviderMixin:OnHide()
	self:UnregisterEvent("PORTRAITS_UPDATED");
end

function EncounterJournalDataProviderMixin:OnEvent(event, ...)
	if event == "PORTRAITS_UPDATED" then
		self:RefreshAllData();
	end
end

function EncounterJournalDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("EncounterJournalPinTemplate");
end

function EncounterJournalDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	
	if CanShowEncounterJournal() then
		local mapEncounters = C_EncounterJournal.GetEncountersOnMap(self:GetMap():GetMapID());
		for index, mapEncounterInfo in ipairs(mapEncounters) do
			local bossPin = self:GetMap():AcquirePin("EncounterJournalPinTemplate", mapEncounterInfo.encounterID);
			bossPin:SetPosition(mapEncounterInfo.mapX, mapEncounterInfo.mapY);
		end
	end
end

--[[ Pin ]]--
EncounterJournalPinMixin = CreateFromMixins(MapCanvasPinMixin);

function EncounterJournalPinMixin:OnLoad()
	self:SetScalingLimits(1, 0.7, 1.3);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ENCOUNTER");
end

function EncounterJournalPinMixin:OnAcquired(encounterID)
	self.encounterID = encounterID;
	self:Refresh();
end

function EncounterJournalPinMixin:Refresh()
	local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(self.encounterID);
	self.instanceID = instanceID;
	self.tooltipTitle = name;
	self.tooltipText = description;
	local displayInfo = select(4, EJ_GetCreatureInfo(1, self.encounterID));
	self.displayInfo = displayInfo;
	if displayInfo then
		SetPortraitTextureFromCreatureDisplayID(self.Background, displayInfo);
		self.Background:Show();
	else
		self.Background:Hide();
	end
	
	local complete = C_EncounterJournal.IsEncounterComplete(encounterID);
	self.DefeatedOpacity:SetShown(complete);
	self.DefeatedOverlay:SetShown(complete);
	self.Background:SetDesaturation(complete and 0.7 or 0);
end

function EncounterJournalPinMixin:OnMouseEnter()
	if self.tooltipTitle then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip_SetTitle(GameTooltip, self.tooltipTitle);
		
		if C_EncounterJournal.IsEncounterComplete(self.encounterID) then
			GameTooltip_AddColoredLine(GameTooltip, DUNGEON_ENCOUNTER_DEFEATED, RED_FONT_COLOR);
		end
		
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText, true);
		GameTooltip:Show();
	end
end

function EncounterJournalPinMixin:OnMouseLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function EncounterJournalPinMixin:OnMouseClickAction()
	EncounterJournal_LoadUI();
	EncounterJournal_OpenJournal(nil, self.instanceID, self.encounterID);
end
