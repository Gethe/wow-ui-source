AdventureMap_QuestChoiceDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AdventureMap_QuestChoiceDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("ADVENTURE_MAP_UPDATE_POIS");
	self:RegisterEvent("ADVENTURE_MAP_QUEST_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
end

function AdventureMap_QuestChoiceDataProviderMixin:OnEvent(event, ...)
	if event == "ADVENTURE_MAP_QUEST_UPDATE" then
		self:RefreshAllData();
	elseif event == "ADVENTURE_MAP_UPDATE_POIS" then
		self:RefreshAllData();
	elseif event == "QUEST_ACCEPTED" then
		if self:GetMap():IsVisible() then
			local questID = ...;
			for pin in self:GetMap():EnumeratePinsByTemplate("AdventureMap_QuestChoicePinTemplate") do
				if pin.questID == questID then
					self:OnQuestAccepted(pin);
					break;
				end
			end
		end
	end
end

function AdventureMap_QuestChoiceDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_QuestChoicePinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_FogPinTemplate");
end

function AdventureMap_QuestChoiceDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	if fromOnShow then
		-- We have to wait until the server sends us quest data before we can continue
		self.playRevealAnims = true;
		return;
	end

	self.pinsByQuestID = {};
	local oldSelectedQuestID = self.selectedQuestID;
	local newSelectedQuestID = nil;
	local newSelectedTextureKit = nil;
	self.selectedQuestID = nil;

	for choiceIndex = 1, C_AdventureMap.GetNumZoneChoices() do
		local questID, textureKit, name, zoneDescription, normalizedX, normalizedY = C_AdventureMap.GetZoneChoiceInfo(choiceIndex);
		if AdventureMap_IsQuestValid(questID, normalizedX, normalizedY) then
			self:AddQuest(questID, textureKit, name, zoneDescription, normalizedX, normalizedY);
			if oldSelectedQuestID == questID then
				newSelectedQuestID = questID;
				newSelectedTextureKit = textureKit;
			end
		end
	end

	self:SelectQuestID(newSelectedQuestID, newSelectedTextureKit);
	if oldSelectedQuestID and not newSelectedQuestID then
		self:GetMap():ZoomOut();
	end

	self.playRevealAnims = false;
end

function AdventureMap_QuestChoiceDataProviderMixin:AddQuest(questID, textureKit, name, zoneDescription, normalizedX, normalizedY)
	local choicePin = self:AddChoicePin(questID, textureKit, name, zoneDescription, normalizedX, normalizedY);
	choicePin.fogPin = self:AddFogPin(questID, normalizedX, normalizedY);
end

function AdventureMap_QuestChoiceDataProviderMixin:AddChoicePin(questID, textureKit, name, zoneDescription, normalizedX, normalizedY)
	local pin = self:GetMap():AcquirePin("AdventureMap_QuestChoicePinTemplate", self.playRevealAnims);
	pin.questID = questID;
	pin.textureKit = textureKit;
	pin.Text:SetText(name);
	pin.zoneDescription = zoneDescription;
	pin:SetPosition(normalizedX, normalizedY);
	pin.owner = self;

	if textureKit == "alliance" then
		pin.Icon:SetAtlas("QuestPortraitIcon-Alliance-small");
		pin.IconHighlight:SetAtlas("QuestPortraitIcon-Alliance-small");

		pin.Icon:SetSize(56, 60);
		pin.IconHighlight:SetSize(56, 60);
		pin.selectedAnimOffset = 0;
	elseif textureKit == "horde" then
		pin.Icon:SetAtlas("QuestPortraitIcon-Horde-small");
		pin.IconHighlight:SetAtlas("QuestPortraitIcon-Horde-small");

		pin.Icon:SetSize(58, 66);
		pin.IconHighlight:SetSize(58, 66);
		pin.selectedAnimOffset = -5;
	else
		pin.Icon:SetAtlas("QuestPortraitIcon-SandboxQuest", true);
		pin.IconHighlight:SetAtlas("QuestPortraitIcon-SandboxQuest", true);
		pin.selectedAnimOffset = 0;
	end

	self.pinsByQuestID[questID] = pin;

	return pin;
end

function AdventureMap_QuestChoiceDataProviderMixin:SelectQuestID(questID, textureKit)
	if self.selectedQuestID ~= questID then
		if self.selectedQuestID then
			local pin = self.pinsByQuestID[self.selectedQuestID];
			pin:SetSelected(false);
		end

		self.selectedQuestID = questID;

		if self.selectedQuestID then
			local pin = self.pinsByQuestID[self.selectedQuestID];
			pin:PanAndZoomTo();
			pin:SetSelected(true);

			local function OnClosedCallback(result)
				if self.selectedQuestID then
					if result == QUEST_CHOICE_DIALOG_RESULT_ACCEPTED then
						self:OnQuestAccepted(self.pinsByQuestID[self.selectedQuestID]);
					elseif result == QUEST_CHOICE_DIALOG_RESULT_DECLINED then
						self:SelectQuestID(nil);
					end
				end
			end

			AdventureMapQuestChoiceDialog:ShowWithQuest(self:GetMap(), pin, questID, OnClosedCallback, .5);

			if textureKit == "alliance" then
				AdventureMapQuestChoiceDialog:SetPortraitAtlas("QuestPortraitIcon-Alliance", 59, 67, 0, 12);
			elseif textureKit == "horde" then
				AdventureMapQuestChoiceDialog:SetPortraitAtlas("QuestPortraitIcon-Horde", 64, 74, 0, 12);
			else
				AdventureMapQuestChoiceDialog:SetPortraitAtlas("QuestPortraitIcon-SandboxQuest", 38, 63, 0, 12);
			end

		else
			AdventureMapQuestChoiceDialog:DeclineQuest(true);
			self:GetMap():ZoomOut();
		end
	end
end

function AdventureMap_QuestChoiceDataProviderMixin:AddFogPin(questID, normalizedX, normalizedY)
	local pin = self:GetMap():AcquirePin("AdventureMap_FogPinTemplate", self.playRevealAnims);
	pin:SetPosition(normalizedX, normalizedY);
	return pin;
end

function AdventureMap_QuestChoiceDataProviderMixin:OnQuestAccepted(pin)
	local fogPin = pin.fogPin;
	fogPin.OnQuestAcceptedAnim:SetScript("OnFinished", function()
		self:GetMap():RemovePin(fogPin);
	end);

	fogPin.OnQuestAcceptedAnim:Play();

	pin.fogPin = nil;
	self:GetMap():ZoomOut();
	self:GetMap():RemovePin(pin);
end

--[[ Quest Choice Pin ]]--
AdventureMap_QuestChoicePinMixin = CreateFromMixins(MapCanvasPinMixin);

function AdventureMap_QuestChoicePinMixin:OnLoad()
	self:SetScalingLimits(1.25, 0.825, 1.275);
end

function AdventureMap_QuestChoicePinMixin:OnAcquired(playAnim)
	self.selectedCurrentOffset = nil;
	self.selectedTargetOffset = 0;
	self.selectedAnimDelay = 0;

	if playAnim then
		self.OnAddAnim:Play();
	end
end

function AdventureMap_QuestChoicePinMixin:OnClick(button)
	if button == "LeftButton" then
		PlaySound(SOUNDKIT.UI_MISSION_MAP_ZOOM);
		self.owner:SelectQuestID(self.questID, self.textureKit);
	end
end

function AdventureMap_QuestChoicePinMixin:OnUpdate(elapsed)
	if self.selectedTargetOffset then
		self.selectedAnimDelay = self.selectedAnimDelay - elapsed;
		if self.selectedAnimDelay > 0 then
			return;
		end

		self.selectedCurrentOffset = FrameDeltaLerp(self.selectedCurrentOffset or 0, self.selectedTargetOffset, .12);
		local percent = -math.cos(math.pi * .5 * (self.selectedCurrentOffset + 1.0));
		self.Icon:SetPoint("CENTER", 0, percent * (132 + self.selectedAnimOffset));

		if math.abs(self.selectedCurrentOffset - self.selectedTargetOffset) < .001 then
			self.selectedTargetOffset = nil;
		end
	end
end

function AdventureMap_QuestChoicePinMixin:SetSelected(selected)
	self.selectedTargetOffset = selected and 1 or 0;
	self.selectedAnimDelay = selected and 0 or .2;
end

function AdventureMap_QuestChoicePinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 20, 0);

	GameTooltip:AddLine(self.Text:GetText(), 1, 1, 1);
	GameTooltip:AddLine(self.zoneDescription, nil, nil, nil, true);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(ADVENTURE_MAP_VIEW_ZONE_TOOLTIP, 0, 1, 0, true);
	GameTooltip:Show();
end

function AdventureMap_QuestChoicePinMixin:OnMouseLeave()
	GameTooltip_Hide();
end

--[[ Fog Pin ]]--
AdventureMap_FogPinMixin = CreateFromMixins(MapCanvasPinMixin);

function AdventureMap_FogPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN);
	self:SetIgnoreGlobalPinScale(true);
	self:SetScale(2.5);
end

function AdventureMap_FogPinMixin:OnAcquired(playAnim)
	if playAnim and not self:GetMap():IsAtMinZoom() then
		self.OnAddAnim:Play();
	end
end

function AdventureMap_FogPinMixin:OnReleased()
	self.OnQuestAcceptedAnim:Stop();
end