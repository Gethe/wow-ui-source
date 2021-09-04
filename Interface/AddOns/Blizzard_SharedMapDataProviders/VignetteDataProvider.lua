VignetteDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function VignetteDataProviderMixin:GetPinTemplate()
	return "VignettePinTemplate";
end

function VignetteDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:InitializeAllTrackingTables();
end

function VignetteDataProviderMixin:OnShow()
	self:RegisterEvent("VIGNETTES_UPDATED");
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
	self.ticker = C_Timer.NewTicker(0, function() self:UpdatePinPositions() end);
end

function VignetteDataProviderMixin:OnHide()
	self:UnregisterEvent("VIGNETTES_UPDATED");
	EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end
end

function VignetteDataProviderMixin:OnEvent(event, ...)
	if event == "VIGNETTES_UPDATED" then
		self:RefreshAllData();
	end
end

function VignetteDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate(self:GetPinTemplate());
	self:InitializeAllTrackingTables();
end

function VignetteDataProviderMixin:InitializeAllTrackingTables()
	self.vignetteGuidsToPins = {};
	self.uniqueVignettesGUIDs = {};
	self.uniqueVignettesPins = {};
end

function VignetteDataProviderMixin:RefreshAllData(fromOnShow)
	local mapInfo = C_Map.GetMapInfo(self:GetMap():GetMapID());
	if FlagsUtil.IsSet(mapInfo.flags, Enum.UIMapFlag.HideVignettes) then
		self:RemoveAllData();
		return;
	end

	local pinsToRemove = {};
	for vignetteGUID, pin in pairs(self.vignetteGuidsToPins) do
		pinsToRemove[vignetteGUID] = pin;
	end

	local pinTemplate = self:GetPinTemplate();
	local vignetteGUIDs = C_VignetteInfo.GetVignettes();
	for i, vignetteGUID in ipairs(vignetteGUIDs) do
		local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID);
		if self:ShouldShowVignette(vignetteInfo) then
			local existingPin = pinsToRemove[vignetteGUID];
			if existingPin then
				pinsToRemove[vignetteGUID] = nil;
				existingPin:UpdateFogOfWar(vignetteInfo);
			else
				local pin = self:GetMap():AcquirePin(pinTemplate, vignetteGUID, vignetteInfo, self:GetMap():GetNumActivePinsByTemplate(pinTemplate));
				pin.dataProvider = self;
				self.vignetteGuidsToPins[vignetteGUID] = pin;
				if pin:IsUnique() then
					self:AddUniquePin(pin);
				end
			end
		end
	end

	for vignetteGUID, pin in pairs(pinsToRemove) do
		if pin:IsUnique() then
			self:RemoveUniquePin(pin);
		end
		self:GetMap():RemovePin(pin);
		self.vignetteGuidsToPins[vignetteGUID] = nil;
	end
end

function VignetteDataProviderMixin:ShouldShowVignette(vignetteInfo)
	return vignetteInfo and vignetteInfo.onWorldMap;
end

function VignetteDataProviderMixin:OnSuperTrackingChanged()
	local template = self:GetPinTemplate();
	for pin in self:GetMap():EnumeratePinsByTemplate(template) do
		pin:UpdateSupertrackedHighlight();
	end
end

function VignetteDataProviderMixin:OnMapChanged()
	self:RefreshAllData();
end

function VignetteDataProviderMixin:UpdatePinPositions()
	for vignetteGUID, pin in pairs(self.vignetteGuidsToPins) do
		if not pin:IsUnique() then
			pin:UpdatePosition();
		end
	end

	for vignetteID, vignettesGUIDs in pairs(self.uniqueVignettesGUIDs) do
		local bestVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignettesGUIDs);
		for vignetteIndex, pin in ipairs(self.uniqueVignettesPins[vignetteID]) do
			pin:UpdatePosition(vignetteIndex == bestVignetteIndex);
		end
	end
end

function VignetteDataProviderMixin:AddUniquePin(pin)
	local vignetteID = pin:GetVignetteID();
	if not self.uniqueVignettesGUIDs[vignetteID] then
		self.uniqueVignettesGUIDs[vignetteID] = {};
		self.uniqueVignettesPins[vignetteID] = {};
	end

	table.insert(self.uniqueVignettesGUIDs[vignetteID], pin:GetVignetteGUID());
	table.insert(self.uniqueVignettesPins[vignetteID], pin);
end

function VignetteDataProviderMixin:RemoveUniquePin(pin)
	local vignetteID = pin:GetVignetteID();
	local uniquePins = self.uniqueVignettesPins[vignetteID];
	if uniquePins then
		for i, uniquePin in ipairs(uniquePins) do
			if uniquePin == pin then
				table.remove(uniquePins, i);
				if #uniquePins == 0 then
					self.uniqueVignettesPins[vignetteID] = nil;
					self.uniqueVignettesGUIDs[vignetteID] = nil
				else
					table.remove(self.uniqueVignettesGUIDs[vignetteID], i);
				end

				return;
			end
		end
	end
end

--[[ Pin ]]--
VignettePinMixin = CreateFromMixins(MapCanvasPinMixin);

function VignettePinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
end

function VignettePinMixin:OnAcquired(vignetteGUID, vignetteInfo, frameLevelCount)
	self.vignetteGUID = vignetteGUID;
	self.name = vignetteInfo.name;
	self.hasTooltip = vignetteInfo.hasTooltip or vignetteInfo.type == Enum.VignetteType.PvPBounty;
	self.isUnique = vignetteInfo.isUnique;
	self.vignetteID = vignetteInfo.vignetteID;
	self.widgetSetID = vignetteInfo.widgetSetID;

	self:EnableMouse(self.hasTooltip);

	self.vignetteInfo = vignetteInfo;

	self.Texture:SetAtlas(vignetteInfo.atlasName, true);
	self.HighlightTexture:SetAtlas(vignetteInfo.atlasName, true);

	local sizeX, sizeY = self.Texture:GetSize();
	self.HighlightTexture:SetSize(sizeX, sizeY);

	self:UpdateFogOfWar(vignetteInfo);

	self:SetSize(sizeX, sizeY);

	self.ShowAnim:Play();

	self:UpdatePosition();
	self:UpdateSupertrackedHighlight();

	self:UseFrameLevelType("PIN_FRAME_LEVEL_VIGNETTE", frameLevelCount);
end

function VignettePinMixin:OnReleased()
	self.ShowAnim:Stop();
end

function VignettePinMixin:IsUnique()
	return self.isUnique;
end

function VignettePinMixin:GetVignetteID()
	return self.vignetteID;
end

function VignettePinMixin:GetVignetteGUID()
	return self.vignetteGUID;
end

function VignettePinMixin:GetObjectGUID()
	return self.vignetteInfo.objectGUID;
end

function VignettePinMixin:GetVignetteType()
	return self.vignetteInfo.type;
end

function VignettePinMixin:GetVignetteName()
	return self.name;
end

function VignettePinMixin:GetRewardQuestID()
	return self.vignetteInfo.rewardQuestID;
end

function VignettePinMixin:UpdateFogOfWar(vignetteInfo)
	self.Texture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or 0);
	self.Texture:SetAlpha(vignetteInfo.inFogOfWar and .55 or 1);

	self.HighlightTexture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or .75);
end

function VignettePinMixin:UpdatePosition(bestUniqueVignette)
	if self:IsUnique() and not bestUniqueVignette then
		self:Hide();
		return;
	end

	local position = C_VignetteInfo.GetVignettePosition(self.vignetteGUID, self:GetMap():GetMapID());
	if position then
		self:SetPosition(position:GetXY());
		self:Show();
	else
		self:Hide();
	end
end

function VignettePinMixin:UpdateSupertrackedHighlight()
	local highlight = (self:GetVignetteType() == Enum.VignetteType.Treasure) and QuestSuperTracking_ShouldHighlightTreasures(self:GetMap():GetMapID());
	MapPinHighlight_CheckHighlightPin(highlight, self, self.Texture);
end

function VignettePinMixin:OnMouseEnter()
	if self.hasTooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		self.UpdateTooltip = self.OnMouseEnter;

		local hasValidTooltip = false;

		if self:GetVignetteType() == Enum.VignetteType.Normal or self:GetVignetteType() == Enum.VignetteType.Treasure then
			hasValidTooltip = self:DisplayNormalTooltip();
		elseif self:GetVignetteType() == Enum.VignetteType.PvPBounty then
			hasValidTooltip = self:DisplayPvpBountyTooltip();
		elseif self:GetVignetteType() == Enum.VignetteType.Torghast then
			hasValidTooltip = self:DisplayTorghastTooltip();
		end

		if hasValidTooltip and self.widgetSetID then
			GameTooltip_AddWidgetSet(GameTooltip, self.widgetSetID, self:GetWidgetSetVerticalPadding());
		elseif not hasValidTooltip then
			GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA);
		end

		GameTooltip:Show();
	end
end

function VignettePinMixin:OnMouseLeave()
	GameTooltip:Hide();
end

function VignettePinMixin:DisplayNormalTooltip()
	GameTooltip_SetTitle(GameTooltip, self:GetVignetteName());
	return true;
end

function VignettePinMixin:DisplayPvpBountyTooltip()
	local player = PlayerLocation:CreateFromGUID(self:GetObjectGUID());
	local class = select(3, C_PlayerInfo.GetClass(player));
	local race = C_PlayerInfo.GetRace(player);
	local name = C_PlayerInfo.GetName(player);

	if race and class and name then
		local classInfo = C_CreatureInfo.GetClassInfo(class);
		local factionInfo = C_CreatureInfo.GetFactionInfo(race);

		GameTooltip_SetTitle(GameTooltip, name, GetClassColorObj(classInfo.classFile));
		GameTooltip_AddColoredLine(GameTooltip, factionInfo.name, GetFactionColor(factionInfo.groupTag));
		GameTooltip_AddQuestRewardsToTooltip(GameTooltip, self:GetRewardQuestID(), TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY);

		return true;
	end

	return false;
end

function VignettePinMixin:DisplayTorghastTooltip()
	SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
	GameTooltip_SetTitle(GameTooltip, self:GetVignetteName());
	return true;
end

function VignettePinMixin:GetWidgetSetVerticalPadding()
	if self:GetVignetteType() == Enum.VignetteType.Torghast then
		return 0;
	else
		return 10;
	end
end