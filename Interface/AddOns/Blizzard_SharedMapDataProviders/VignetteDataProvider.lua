VignetteDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function VignetteDataProviderMixin:GetPinTemplate()
	return "VignettePinTemplate";
end

function VignetteDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():RegisterCallback("SetBounty", self.SetBounty, self);
	self:GetMap():RegisterCallback("HighlightMapPins.Vignettes", self.ForceHighlightVignettePins, self);
	self:InitializeAllTrackingTables();
end

function VignetteDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():UnregisterCallback("SetBounty", self);
	self:GetMap():UnregisterCallback("HighlightMapPins.Vignettes", self);
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function VignetteDataProviderMixin:SetBounty(bountyQuestID, bountyFactionID, bountyFrameType)
	local changed = (self.bountyFactionID ~= bountyFactionID);
	if changed then
		self.bountyQuestID = bountyQuestID;
		self.bountyFactionID = bountyFactionID;
		self.bountyFrameType = bountyFrameType;
		if self:GetMap() then
			self:RefreshAllData();
		end
	end
end

function VignetteDataProviderMixin:ForceHighlightVignettePins(forcedPinHighlightType)
	if self.forcedPinHighlightType ~= forcedPinHighlightType then
		self.forcedPinHighlightType = forcedPinHighlightType;
		self:OnSuperTrackingChanged();
	end
end

function VignetteDataProviderMixin:GetBountyInfo()
	return self.bountyQuestID, self.bountyFactionID, self.bountyFrameType;
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
	if self.fyrakkFlightPin then
		self.fyrakkFlightPin:Remove();
	end
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
				existingPin:UpdateSupertrackedHighlight();
			else
				vignetteInfo.dataProvider = self;
				local pin = self:GetPin(vignetteGUID, vignetteInfo);
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
		pin:Remove();
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

function VignetteDataProviderMixin:GetPin(vignetteGUID, vignetteInfo)
	if vignetteInfo.type == Enum.VignetteType.FyrakkFlight then
		if self.fyrakkFlightPin then
			self.fyrakkFlightPin:OnAcquired(vignetteGUID, vignetteInfo);
		else
			self.fyrakkFlightPin = self:GetMap():AcquirePin("FyrakkFlightVignettePinTemplate", vignetteGUID, vignetteInfo);
		end
		return self.fyrakkFlightPin;
	else
		local pinTemplate = self:GetPinTemplate();
		-- GetNumActivePinsByTemplate will return the number right now, before this pin is added
		local frameIndex = self:GetMap():GetNumActivePinsByTemplate(pinTemplate) + 1;
		return self:GetMap():AcquirePin(pinTemplate, vignetteGUID, vignetteInfo, frameIndex);
	end
end

SuperTrackableVignettePinMixin = CreateFromMixins(SuperTrackablePinMixin);

function SuperTrackableVignettePinMixin:GetSuperTrackAccessorAPIName()
	return "GetSuperTrackedVignette"; -- override
end

function SuperTrackableVignettePinMixin:GetSuperTrackMutatorAPIName()
	return "SetSuperTrackedVignette"; -- override
end

function SuperTrackableVignettePinMixin:DoesSuperTrackDataMatch(...)
	-- override
	local vignetteGUID = select(1, ...);
	local myVignetteGUID = self:GetSuperTrackData();
	if myVignetteGUID then
		return myVignetteGUID == vignetteGUID;
	end

	return false;
end

function SuperTrackableVignettePinMixin:GetSuperTrackData()
	return self.vignetteGUID;
end

VignettePinMixin = CreateFromMixins(MapCanvasPinMixin, SuperTrackableVignettePinMixin);

function VignettePinMixin:OnLoad()
	self:SetScalingLimits(1, 1.0, 1.2);
end

function VignettePinMixin:OnAcquired(vignetteGUID, vignetteInfo, frameIndex)
	SuperTrackablePinMixin.OnAcquired(self, vignetteInfo, frameIndex);

	self.dataProvider = vignetteInfo.dataProvider;
	self.vignetteGUID = vignetteGUID;
	self.name = vignetteInfo.name;
	self.hasTooltip = vignetteInfo.hasTooltip or vignetteInfo.type == Enum.VignetteType.PvPBounty;
	self.isUnique = vignetteInfo.isUnique;
	self.vignetteID = vignetteInfo.vignetteID;
	self.tooltipWidgetSet = vignetteInfo.tooltipWidgetSet;
	self.iconWidgetSet = vignetteInfo.iconWidgetSet;
	self.vignetteInfo = vignetteInfo;
	
	self:EnableMouseMotion(self.hasTooltip);

	self:ApplyTextures();

	self:UpdateFogOfWar(vignetteInfo);

	self:ApplyCurrentAlpha();

	self:UpdatePosition();
	self:UpdateSupertrackedHighlight();
	self:AddIconWidgets();

	self:SetFrameLevelType(frameIndex);
end

function VignettePinMixin:ApplyTextures()
	local atlasName = self.vignetteInfo.atlasName;

	self.Texture:SetAtlas(atlasName, true);
	self.HighlightTexture:SetAtlas(atlasName, true);

	local sizeX, sizeY = self.Texture:GetSize();
	self.HighlightTexture:SetSize(sizeX, sizeY);
	
	self:SetSize(sizeX, sizeY);
end

function VignettePinMixin:SetFrameLevelType(frameIndex)
	self:UseFrameLevelType("PIN_FRAME_LEVEL_VIGNETTE", frameIndex);
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
	if self.vignetteInfo.rewardQuestID and (self.vignetteInfo.rewardQuestID > 0) then
		return self.vignetteInfo.rewardQuestID;
	else
		return nil;
	end
end

function VignettePinMixin:UpdateFogOfWar(vignetteInfo)
	self.Texture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or 0);
	self.Texture:SetAlpha(vignetteInfo.inFogOfWar and .55 or 1);

	self.HighlightTexture:SetDesaturation(vignetteInfo.inFogOfWar and 1 or .75);
end

function VignettePinMixin:OnCanvasScaleChanged() -- override
	local position = C_VignetteInfo.GetVignettePosition(self.vignetteGUID, self:GetMap():GetMapID());
	-- Do not update things that could show the pin, if we have no valid position on the map.
	if position then
		self:ApplyCurrentScale();
		-- vignettes can get hid in UpdatePosition if they're unique and not the best unique
		-- ApplyCurrentAlpha below will make them shown again, until UpdatePosition runs again
		-- store the shown state for unique vignettes and restore it after ApplyCurrentAlpha
		local shown;
		if self:IsUnique() then
			shown = self:IsShown();
		end
		self:ApplyCurrentAlpha();
		if shown ~= nil then
			self:SetShown(shown);
		end
	end
end

function VignettePinMixin:UpdatePosition(bestUniqueVignette)
	local showPin = false;
	local position = C_VignetteInfo.GetVignettePosition(self.vignetteGUID, self:GetMap():GetMapID());
	if position then
		self:SetPosition(position:GetXY());
		showPin = self:GetAlpha() > 0.05 and (not self:IsUnique() or bestUniqueVignette);
	end

	self:SetShown(showPin);
end

function VignettePinMixin:ShouldUseForcedHighlightType()
	return self.dataProvider.forcedPinHighlightType and (self:GetVignetteType() == Enum.VignetteType.Normal);
end

function VignettePinMixin:GetHighlightType() -- override
	if self:ShouldUseForcedHighlightType() then
		return self.dataProvider.forcedPinHighlightType;
	end

	if (self:GetVignetteType() == Enum.VignetteType.Treasure) and QuestSuperTracking_ShouldHighlightTreasures(self:GetMap():GetMapID()) then
		return MapPinHighlightType.SupertrackedHighlight;
	end

	local rewardQuestID = self:GetRewardQuestID();
	if rewardQuestID then
		local _, bountyFactionID, bountyFrameType = self.dataProvider:GetBountyInfo();
		if bountyFrameType == BountyFrameType.ActivityTracker then
			-- Is this vignette for a task quest?
			local _, taskFactionID = C_TaskQuest.GetQuestInfoByQuestID(rewardQuestID);
			if taskFactionID and (taskFactionID == bountyFactionID) then
				return MapPinHighlightType.SupertrackedHighlight;
			-- Is it for a standard quest?
			elseif C_QuestLog.DoesQuestAwardReputationWithFaction(rewardQuestID, bountyFactionID) then
				return MapPinHighlightType.SupertrackedHighlight;
			end
		end
	end

	return MapPinHighlightType.None;
end

function VignettePinMixin:UpdateSupertrackedHighlight()
	MapPinHighlight_CheckHighlightPin(self:GetHighlightType(), self, self.Texture);
end

function VignettePinMixin:OnMouseEnter()
	if self.hasTooltip then
		local verticalPadding = nil;

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		self.UpdateTooltip = self.OnMouseEnter;

		local waitingForData, titleAdded = false, false;

		if self:GetVignetteType() == Enum.VignetteType.Normal or self:GetVignetteType() == Enum.VignetteType.Treasure then
			titleAdded = self:DisplayNormalTooltip();
		elseif self:GetVignetteType() == Enum.VignetteType.PvPBounty then
			titleAdded = self:DisplayPvpBountyTooltip();
			waitingForData = not titleAdded;
		elseif self:GetVignetteType() == Enum.VignetteType.Torghast then
			titleAdded = self:DisplayTorghastTooltip();
		end

		if not waitingForData and self.tooltipWidgetSet then
			local overflow = GameTooltip_AddWidgetSet(GameTooltip, self.tooltipWidgetSet, titleAdded and self.vignetteInfo.addPaddingAboveTooltipWidgets and 10);
			if overflow then
				verticalPadding = -overflow;
			end
		elseif waitingForData then
			GameTooltip_SetTitle(GameTooltip, RETRIEVING_DATA);
		end

		GameTooltip:Show();
		-- need to set padding after Show or else there will be a flicker
		if verticalPadding then
			GameTooltip:SetPadding(0, verticalPadding);
		end
	end
    self:OnLegendPinMouseEnter();
end

function VignettePinMixin:OnMouseLeave()
	GameTooltip:Hide();
    self:OnLegendPinMouseLeave();
end

function VignettePinMixin:DisplayNormalTooltip()
	local vignetteName = self:GetVignetteName();
	if vignetteName ~= "" then
		GameTooltip_SetTitle(GameTooltip, vignetteName);
		return true;
	end
	return false;
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
		local rewardQuestID = self:GetRewardQuestID();
		if rewardQuestID then
			GameTooltip_AddQuestRewardsToTooltip(GameTooltip, self:GetRewardQuestID(), TOOLTIP_QUEST_REWARDS_STYLE_PVP_BOUNTY);
		end

		return true;
	end

	return false;
end

function VignettePinMixin:DisplayTorghastTooltip()
	SharedTooltip_SetBackdropStyle(GameTooltip, GAME_TOOLTIP_BACKDROP_STYLE_RUNEFORGE_LEGENDARY);
	return self:DisplayNormalTooltip();
end

function VignettePinMixin:Remove()
	self:GetMap():RemovePin(self);
end

--[[ Fyakk Flight Pin ]]--

FyrakkFlightVignettePinMixin = CreateFromMixins(VignettePinMixin);

function FyrakkFlightVignettePinMixin:OnLoad()
	-- set up rotation vectors
	for i, texture in ipairs(self.Textures) do
		-- all have a CENTER point only
		local _, _, _, x, y = texture:GetPoint(1);
		local w, h = texture:GetSize();
		texture.rotationVector = CreateVector2D(0.5 - (x / w), 0.5 - (y / h));
	end
	
	self.Anim:Play();
	
	VignettePinMixin.OnLoad(self);
end
		
function FyrakkFlightVignettePinMixin:ApplyTextures()
	-- fixed textures
end

function FyrakkFlightVignettePinMixin:UpdateFogOfWar(vignetteInfo)
	-- doesn't need fog of war
end

function FyrakkFlightVignettePinMixin:SetFrameLevelType()
	-- set it at the top of vignette range
	self:UseFrameLevelTypeFromRangeTop("PIN_FRAME_LEVEL_VIGNETTE");
end

function FyrakkFlightVignettePinMixin:UpdatePosition()
	local showPin = false;
	local position, facing = C_VignetteInfo.GetVignettePosition(self.vignetteGUID, self:GetMap():GetMapID());
	if position then
		self:SetPosition(position:GetXY());
		if facing then
			for i, texture in ipairs(self.Textures) do
				texture:SetRotation(facing, texture.rotationVector);
			end
		end
		showPin = true;
	end

	self:SetShown(showPin);
end

function FyrakkFlightVignettePinMixin:Remove()
	self:Hide();
end

function FyrakkFlightVignettePinMixin:UpdateSuperTrackTextureAnchors()
	if self:IsSuperTracked() and not self.isAnchored then
		self.isAnchored = true;

		self.SuperTrackGlow:ClearAllPoints();
		self.SuperTrackGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -50, 50);
		self.SuperTrackGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 50, -50);

		self.SuperTrackMarker:ClearAllPoints();		
		self.SuperTrackMarker:SetPoint("CENTER", self, "BOTTOMRIGHT", 0, -15);
	end
end