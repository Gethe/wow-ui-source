AdventureMap_QuestOfferDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AdventureMap_QuestOfferDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);

	self:RegisterEvent("ADVENTURE_MAP_UPDATE_POIS");
	self:RegisterEvent("ADVENTURE_MAP_QUEST_UPDATE");
	self:RegisterEvent("QUEST_ACCEPTED");
end

function AdventureMap_QuestOfferDataProviderMixin:OnEvent(event, ...)
	if event == "ADVENTURE_MAP_QUEST_UPDATE" then
		self:RefreshAllData();
	elseif event == "ADVENTURE_MAP_UPDATE_POIS" then
		self:RefreshAllData();
	elseif event == "QUEST_ACCEPTED" then
		if self:GetMap():IsVisible() then
			local questID = ...;
			for pin in self:GetMap():EnumeratePinsByTemplate("AdventureMap_QuestOfferPinTemplate") do
				if pin.questID == questID then
					self:OnQuestAccepted(pin);
					break;
				end
			end
		end
	end
end

function AdventureMap_QuestOfferDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AdventureMap_QuestOfferPinTemplate");
	self:GetMap():ReleaseAreaTriggers("AdventureMap_QuestOffer");

	self.offerAreaTrigger = nil;
	self.currentOfferPin = nil;
end

function AdventureMap_QuestOfferDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	if fromOnShow then
		-- We have to wait until the server sends us quest data before we can continue
		self.playRevealAnims = true;
		return;
	end

	local mapAreaID = self:GetMap():GetMapID();
	for offerIndex = 1, C_AdventureMap.GetNumQuestOffers() do
		local questID, isTrivial, frequency, isLegendary, title, description, normalizedX, normalizedY, insetIndex = C_AdventureMap.GetQuestOfferInfo(offerIndex);
		if AdventureMap_IsQuestValid(questID, normalizedX, normalizedY) and not AdventureMap_IsPositionBlockedByZoneChoice(mapAreaID, normalizedX, normalizedY, insetIndex) then
			self:AddQuest(questID, isTrivial, frequency, isLegendary, title, description, normalizedX, normalizedY, insetIndex);
		end
	end

	self.playRevealAnims = false;
end

local function DetermineAtlas(isTrivial, frequency, isLegendary)
	if frequency == Enum.QuestFrequency.Daily or frequency == Enum.QuestFrequency.Weekly then
		return "AdventureMapIcon-DailyQuest";
	end

	return "AdventureMapIcon-Quest";
end

function AdventureMap_QuestOfferDataProviderMixin:AddQuest(questID, isTrivial, frequency, isLegendary, title, description, normalizedX, normalizedY, insetIndex)
	local pin = self:GetMap():AcquirePin("AdventureMap_QuestOfferPinTemplate", self.playRevealAnims);
	pin.dataProvider = self;
	pin.questID = questID;

	pin.title = title;
	pin.description = description;

	local iconAtlas = DetermineAtlas(isTrivial, frequency, isLegendary);
	pin.Icon:SetAtlas(iconAtlas, true);
	pin.IconHighlight:SetAtlas(iconAtlas, true);

	pin:SetPosition(normalizedX, normalizedY, insetIndex);
end

function AdventureMap_QuestOfferDataProviderMixin:OnQuestAccepted(pin)
	self:GetMap():RemovePin(pin);
end

local function OnQuestPinAreaEnclosedChanged(areaTrigger, areaEnclosed)
	areaTrigger.owner:OnQuestPinAreaEnclosedChanged(areaEnclosed);
end

function AdventureMap_QuestOfferDataProviderMixin:OnQuestPinAreaEnclosedChanged(areaEnclosed)
	if self.currentOfferPin then
		if not areaEnclosed then
			AdventureMapQuestChoiceDialog:DeclineQuest(true);
		end
	end
end

function AdventureMap_QuestOfferDataProviderMixin:OnQuestOfferPinClicked(pin)
	local function OnClosedCallback(result)
		self:GetMap():ReleaseAreaTriggers("AdventureMap_QuestOffer");

		self.offerAreaTrigger = nil;
		self.currentOfferPin = nil;
	end

	AdventureMapQuestChoiceDialog:ShowWithQuest(self:GetMap(), pin, pin.questID, OnClosedCallback, 0);
	AdventureMapQuestChoiceDialog:SetPortraitAtlas("FXAM-QuestBang", nil, nil, 0, 7);

	if not self.offerAreaTrigger then
		self.offerAreaTrigger = self:GetMap():AcquireAreaTrigger("AdventureMap_QuestOffer");
		self.offerAreaTrigger.owner = self;
		self:GetMap():SetAreaTriggerEnclosedCallback(self.offerAreaTrigger, OnQuestPinAreaEnclosedChanged);
	end

	local normalizedX, normalizedY = pin:GetGlobalPosition();
	self.offerAreaTrigger:Reset();
	self.offerAreaTrigger:SetCenter(normalizedX, normalizedY);
	self.offerAreaTrigger:Stretch(.1, .1);

	self.offerAreaTrigger.pin = pin;

	self.currentOfferPin = pin;
end

function AdventureMap_QuestOfferDataProviderMixin:OnCanvasScaleChanged()
	MapCanvasDataProviderMixin.OnCanvasScaleChanged(self);
	if self.currentOfferPin and self:GetMap():IsZoomingOut() then
		AdventureMapQuestChoiceDialog:DeclineQuest(true);
	end
end

--[[ Quest Offer Pin ]]--
AdventureMap_QuestOfferPinMixin = CreateFromMixins(MapCanvasPinMixin);

function AdventureMap_QuestOfferPinMixin:OnLoad()
	self:SetAlphaStyle(AM_PIN_ALPHA_STYLE_VISIBLE_WHEN_ZOOMED_IN);
	self:SetScalingLimits(1.25, 0.825, 1.275);
end

function AdventureMap_QuestOfferPinMixin:OnAcquired(playAnim)
	if playAnim then
		self.OnAddAnim:Play();
	end
end

function AdventureMap_QuestOfferPinMixin:OnClick(button)
	if button == "LeftButton" then
		self:PanAndZoomTo();
		self.dataProvider:OnQuestOfferPinClicked(self);
	end
end

function AdventureMap_QuestOfferPinMixin:OnMouseEnter()
	GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 20, 0);

	GameTooltip:AddLine(self.title, 1, 1, 1);
	GameTooltip:AddLine(self.description, nil, nil, nil, true);
	GameTooltip:Show();
end

function AdventureMap_QuestOfferPinMixin:OnMouseLeave()
	GameTooltip_Hide();
end