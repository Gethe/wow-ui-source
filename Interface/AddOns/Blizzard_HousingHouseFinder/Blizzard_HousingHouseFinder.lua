HouseFinderFrameMixin = {}

local HouseSettingsFrameShownEvents =
{
	"NEIGHBORHOOD_LIST_UPDATED",
	"HOUSE_FINDER_NEIGHBORHOOD_DATA_RECIEVED",
	"B_NET_NEIGHBORHOOD_LIST_UPDATED",
	"DECLINE_NEIGHBORHOOD_INVITATION_RESPONSE",
};

local SELECTED_NEIGHBORHOOD_ATLAS_PREFIX = "housefinder_list-item-active-";
local SELECTED_NEIGHBORHOOD_HIGHLIGHT_ATLAS_PREFIX = "housefinder_neighborhood-list-item-highlight-";
local NEIGHBORHOOD_BG_ATLAS = "housefinder_neighborhood-list-item-default";
local NEIGHBORHOOD_HIGHLIGHT_ATLAS = "housefinder_neighborhood-list-item-highlight";
local NEIGHBORHOOD_RECCOMENDED_BG_ATLAS = "housefinder_neighborhood-list-item-invite";

function HouseFinderFrameMixin:OnLoad()
	self:SetTitle(HOUSING_HOUSEFINDER_TITLE);
	self:SetPortraitAtlasRaw("housefinder_main-icon");
	self.NeighborhoodListFrame.RefreshButton:SetScript("OnClick", function() self:OnRefreshClicked() end);

	self.neighborhoodButtonPool = CreateFramePool("Button", self.NeighborhoodListFrame.ScrollFrame.NeighborhoodList, "HouseFinderNeighborhoodButtonTemplate");
	self.bnetNeighborhoodButtonPool = CreateFramePool("Button", self.NeighborhoodListFrame.BNetScrollFrame.NeighborhoodList, "HouseFinderNeighborhoodButtonTemplate");

	MapCanvasMixin.OnLoad(self.HouseFinderMapCanvasFrame);
	self.mapDataProvider = CreateFromMixins(HouseFinderMapDataProviderMixin);
	self.HouseFinderMapCanvasFrame:AddDataProvider(self.mapDataProvider);
	self.HouseFinderMapCanvasFrame:SetShouldZoomInstantly(true);

	self.NeighborhoodListFrame:SetScript("OnShow", function() EventRegistry:TriggerEvent("HouseFinder.NeighborhoodListShown"); end);
end

function HouseFinderFrameMixin:OnRefreshClicked()
	if self.NeighborhoodListFrame.BNetScrollFrame:IsShown() then
		self:SearchBnetFriendNeighborhoods();
	else
		C_Housing.HouseFinderRequestNeighborhoods();
		HouseFinderFrame.NeighborhoodListFrame.LoadingSpinnerList:Show();
		HouseFinderFrame.LoadingSpinnerMap:Show();
		HouseFinderFrame.HouseFinderMapCanvasFrame:Hide();
	end

	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_REFRESH);
end

function HouseFinderFrameMixin:PopulateNeighborhoodList(neighborhoodInfoVector)
	self.neighborhoodButtonPool:ReleaseAll();

	for i, neighborhoodInfo in ipairs(neighborhoodInfoVector) do
		local button = self.neighborhoodButtonPool:Acquire();
		button.layoutIndex = i;
		button:Init(neighborhoodInfo, self);
		
		if i == 1 then
			--we do not need to request the first selected neighborhood data, the server provides the data with the neighborhood list
			local shouldRequestNeighborhoodData = false;
			self:SelectNeighborhood(button, shouldRequestNeighborhoodData);
		end
	end
	self.NeighborhoodListFrame.ScrollFrame.NeighborhoodList:Layout();
	self.NeighborhoodListFrame.ScrollFrame:UpdateScrollChildRect();
	self.NeighborhoodListFrame.LoadingSpinnerList:Hide();
	self.hasNeighborhoodList = true;
end

function HouseFinderFrameMixin:PopulateBNetNeighborhoodList(neighborhoodInfoVector)
	self.bnetNeighborhoodButtonPool:ReleaseAll();
	if #neighborhoodInfoVector <= 0 then
		self.LoadingSpinnerMap:Hide();
		self.NeighborhoodListFrame.BNetScrollFrame.NotFoundText:Show();
	end

	for i, neighborhoodInfo in ipairs(neighborhoodInfoVector) do
		local button = self.bnetNeighborhoodButtonPool:Acquire();
		button.layoutIndex = i;
		button:Init(neighborhoodInfo, self);
		
		if i == 1 then
			--we do not need to request the first selected neighborhood data, the server provides the data with the neighborhood list
			local shouldRequestNeighborhoodData = false;
			self:SelectNeighborhood(button, shouldRequestNeighborhoodData);
		end
	end
	self.NeighborhoodListFrame.BNetScrollFrame.NeighborhoodList:Layout();
	self.NeighborhoodListFrame.BNetScrollFrame:UpdateScrollChildRect();
	self.NeighborhoodListFrame.LoadingSpinnerList:Hide();
	self.NeighborhoodListFrame.BNetScrollFrame:Show();
end

function HouseFinderFrameMixin:SelectNeighborhood(button, shouldRequestInfo)
	if self.selectedNeighborhoodButton then
		self.selectedNeighborhoodButton:Deselect();
	end
	self.selectedNeighborhoodButton = button;
	self.selectedNeighborhoodButton:Select();

	self.mapID = C_Housing.GetUIMapIDForNeighborhood(button.neighborhoodInfo.neighborhoodGUID)
	if (self.mapID ~= nil) then
		self.HouseFinderMapCanvasFrame:SetMapID(self.mapID);
	end

	if shouldRequestInfo then
		C_Housing.RequestHouseFinderNeighborhoodData(button.neighborhoodInfo.neighborhoodGUID);
		self.LoadingSpinnerMap:Show();
		self.HouseFinderMapCanvasFrame:Hide();
	end

	if button.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.CharterInvite then
		self.HouseFinderNotificationBanner.NotificationText:SetText(HOUSING_HOUSEFINDER_CHARTER_INVITE);
		self.HouseFinderNotificationBanner.background:SetAtlas("housefinder-messaging-gold");
		self.HouseFinderNotificationBanner:Show();
	elseif button.neighborhoodInfo.neighborhoodOwnerType == Enum.NeighborhoodOwnerType.None and not C_Housing.DoesFactionMatchNeighborhood(button.neighborhoodInfo.neighborhoodGUID) then
		self.HouseFinderNotificationBanner.NotificationText:SetText(HOUSING_HOUSEFINDER_WRONG_FACTION);
		self.HouseFinderNotificationBanner.background:SetAtlas("housefinder-messaging-red");
		self.HouseFinderNotificationBanner:Show();
	elseif button.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.PartySync then
		self.HouseFinderNotificationBanner.NotificationText:SetText(HOUSING_HOUSEFINDER_PARTY_LEADER);
		self.HouseFinderNotificationBanner.background:SetAtlas("housefinder-messaging-gold");
		self.HouseFinderNotificationBanner:Show();
	else
		self.HouseFinderNotificationBanner:Hide();
	end
end

function HouseFinderFrameMixin:OnEvent(event, ...)
	if event == "NEIGHBORHOOD_LIST_UPDATED" then
		local result, neighborhoodInfos = ...
		if result == Enum.HousingResult.Success then
			self:PopulateNeighborhoodList(neighborhoodInfos);
		else
			UIErrorsFrame:AddExternalErrorMessage(HOUSING_NEIGHBORHOOD_SEARCH_ERROR);
			self.NeighborhoodListFrame.LoadingSpinnerList:Hide();
			self.LoadingSpinnerMap:Hide();
		end
	elseif event == "B_NET_NEIGHBORHOOD_LIST_UPDATED" then
		local result, neighborhoodInfos = ...
		self.pendingFriendSearch = false;
		if result == Enum.HousingResult.Success then
			self:PopulateBNetNeighborhoodList(neighborhoodInfos);
		else
			UIErrorsFrame:AddExternalErrorMessage(HOUSING_NEIGHBORHOOD_SEARCH_ERROR);
			self.NeighborhoodListFrame.LoadingSpinnerList:Hide();
			self.LoadingSpinnerMap:Hide();
		end
	elseif event == "HOUSE_FINDER_NEIGHBORHOOD_DATA_RECIEVED" then
		local mapPlotData = ...;
		self.mapDataProvider:SetHouseMapData(mapPlotData);
		self.LoadingSpinnerMap:Hide();

		if self.mapID ~= nil then
			self.HouseFinderMapCanvasFrame:Show();
			MapCanvasMixin.OnShow(self.HouseFinderMapCanvasFrame);
		else
			UIErrorsFrame:AddExternalErrorMessage(HOUSING_NEIGHBORHOOD_MAP_ERROR);
		end

		if self.HouseFinderMapCanvasFrame:HasZoomLevels() then
			self.HouseFinderMapCanvasFrame:ResetZoom();
		end
	elseif event == "DECLINE_NEIGHBORHOOD_INVITATION_RESPONSE" then
		local success = ...;
		if success then
			local nextNeighborhood = self.neighborhoodButtonPool:GetNextActive(self.pendingDeclineInviteNeighborhoodButton);
			self.neighborhoodButtonPool:Release(self.pendingDeclineInviteNeighborhoodButton);
			self:SelectNeighborhood(nextNeighborhood, true); --select new first button and request data for map
			self.NeighborhoodListFrame.ScrollFrame.NeighborhoodList:Layout();
		else
			self.pendingDeclineInviteNeighborhoodButton:FailCancelInvite();
		end
		self.pendingDeclineInviteNeighborhoodButton = nil;
	end
end

function HouseFinderFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HouseSettingsFrameShownEvents);
	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_OPEN);

	if not self.hasNeighborhoodList then
		C_Housing.HouseFinderRequestNeighborhoods();
	end
end

function HouseFinderFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseSettingsFrameShownEvents);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.OpenHouseFinder);

	self:ShowNeighborhoodList();
	if not HousingDashboardFrame or not HousingDashboardFrame:IsShown() then
		PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_CLOSE);
	end
end

function HouseFinderFrameMixin:SelectPlot(mapPin, plotInfo)
	-- We want the tooltip to clip in the map frame but not scale with the map pin/canvas.
	self.SelectedPlotTooltip:SetIgnoreParentScale(true);
	self.SelectedPlotTooltip:SetScale(self:GetEffectiveScale());
	self.SelectedPlotTooltip:SetParent(mapPin);

	self.SelectedPlotTooltip:SetPoint("BOTTOM", mapPin, "TOP", 0, -8);
	self.SelectedPlotTooltip:SetPlotInfo(plotInfo);
	self.SelectedPlotTooltip:Show();
	self.PlotInfoFrame:Init(plotInfo, self.selectedNeighborhoodButton.neighborhoodInfo);
	self.PlotInfoFrame:Show();
	self.NeighborhoodListFrame:Hide();

	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_PLOT_SELECT);
end

function HouseFinderFrameMixin:ShowNeighborhoodList()
	self.PlotInfoFrame:Hide();
	self.NeighborhoodListFrame:Show();
	self.mapDataProvider:SetSelectedPin(nil);
	self.SelectedPlotTooltip:Hide();
end

function HouseFinderFrameMixin:TryBnetFriendSearch()
	local searchBox = self.NeighborhoodListFrame.BNetFriendSearchBox;
	local bnetID = searchBox:GetBnetID();
	if bnetID then
		return C_Housing.SearchBNetFriendNeighborhoodsByID(bnetID);
	end

	return C_Housing.SearchBNetFriendNeighborhoods(searchBox:GetText());
end

function HouseFinderFrameMixin:SearchBnetFriendNeighborhoods()
	if self:TryBnetFriendSearch() then
		if self.pendingFriendSearch then
			return;
		end
		self.pendingFriendSearch = true;
		self.NeighborhoodListFrame.LoadingSpinnerList:Show();
		self.LoadingSpinnerMap:Show();
		self.HouseFinderMapCanvasFrame:Hide();
		self.NeighborhoodListFrame.ScrollFrame:Hide();

		local displayText = self.NeighborhoodListFrame.BNetFriendSearchBox:GetSearchDisplayText();
		self.NeighborhoodListFrame.BNetScrollFrame.SearchDescriptionText:SetText(string.format(HOUSEFINDER_SEARCH_DESCRIPTION, displayText));
		self.NeighborhoodListFrame.BNetScrollFrame.NotFoundText:Hide();
	else
		self.NeighborhoodListFrame.ScrollFrame:Hide();
		self.NeighborhoodListFrame.BNetScrollFrame.SearchDescriptionText:SetText(string.format(HOUSEFINDER_SEARCH_DESCRIPTION_FAILED, displayText));
		self.HouseFinderMapCanvasFrame:Hide();
		self:PopulateBNetNeighborhoodList({});
	end
	self.NeighborhoodListFrame.BNetFriendSearchBox:UpdateState();
end

function HouseFinderFrameMixin:ClearBnetFriendSearch()
	if self.pendingFriendSearch then
		return false;
	end

	local wasSearchShown = self.NeighborhoodListFrame.BNetScrollFrame:IsShown();
	self.NeighborhoodListFrame.BNetScrollFrame:Hide();
	self.NeighborhoodListFrame.ScrollFrame:Show();

	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_CLEAR_BN_SEARCH);

	if wasSearchShown then
		local shouldRequestNeighborhoodData = true;
		--select first neighborhood in non bnet search list
		for button in self.neighborhoodButtonPool:EnumerateActive() do
			if button.layoutIndex == 1 then
				self:SelectNeighborhood(button, shouldRequestNeighborhoodData);
				return;
			end;
		end
	end
end

function HouseFinderFrameMixin:SetPendingNeighborhoodInviteToDecline(neighborhoodButton)
	self.pendingDeclineInviteNeighborhoodButton = neighborhoodButton;
end

HouseFinderBNetFriendSearchBoxMixin = {};

function HouseFinderBNetFriendSearchBoxMixin:OnLoad()
	local template = AUTOCOMPLETE_LIST.HOUSE_FINDER;
	AutoCompleteEditBox_SetAutoCompleteSource(self, GetAutoCompleteResults, template.include, template.exclude);

	local function HouseFinderAutoComplete(_editBox, fullText, nameInfo, _ambiguatedName)
		self.autoCompleteBnetID = nameInfo.bnetID;
		self.AutoCompleteText:SetText(fullText);
		self:ClearFocus();
		self:SetText("");
		self:UpdateState();
		self:RefreshSearch();
		return true;
	end

	AutoCompleteEditBox_SetCustomAutoCompleteFunction(self, HouseFinderAutoComplete);

	self.ClearButton:SetScript("OnClick", GenerateClosure(self.OnClearButtonClicked, self));
end

function HouseFinderBNetFriendSearchBoxMixin:OnClearButtonClicked()
	self.autoCompleteBnetID = nil;
	self:SetText("");
	HouseFinderFrame:ClearBnetFriendSearch();
	self:UpdateState();
end

function HouseFinderBNetFriendSearchBoxMixin:OnEnterPressed()
	if not AutoCompleteEditBox_OnEnterPressed(self) then
		self:RefreshSearch();
	end
end

function HouseFinderBNetFriendSearchBoxMixin:OnEscapePressed()
	self:ClearFocus();
end

function HouseFinderBNetFriendSearchBoxMixin:OnTextChanged(userInput)
	AutoCompleteEditBox_OnTextChanged(self, userInput);

	if userInput then
		self.autoCompleteBnetID = nil;
		self:UpdateState();
	end
end

function HouseFinderBNetFriendSearchBoxMixin:OnEditFocusGained()
	self:UpdateState();
end

function HouseFinderBNetFriendSearchBoxMixin:OnEditFocusLost()
	AutoCompleteEditBox_OnEditFocusLost(self);
	self:UpdateState();
end

function HouseFinderBNetFriendSearchBoxMixin:RefreshSearch()
	HouseFinderFrame:SearchBnetFriendNeighborhoods();
end

function HouseFinderBNetFriendSearchBoxMixin:UpdateState()
	local hasBnetAutoComplete = self.autoCompleteBnetID ~= nil;
	local showBnetAutoComplete = hasBnetAutoComplete and (not self:HasFocus());
	self.AutoCompleteText:SetShown(showBnetAutoComplete);

	local hasText = self:GetText() ~= "";
	self.FillText:SetShown(not hasText and not showBnetAutoComplete);
	self.ClearButton:SetShown(not HouseFinderFrame.NeighborhoodListFrame.ScrollFrame:IsShown());
end

function HouseFinderBNetFriendSearchBoxMixin:HasStickyFocus()
	return self.ClearButton:IsMouseOver();
end

function HouseFinderBNetFriendSearchBoxMixin:GetSearchDisplayText()
	return ((self.autoCompleteBnetID ~= nil) and self.AutoCompleteText:GetText()) or self:GetText();
end

function HouseFinderBNetFriendSearchBoxMixin:GetBnetID()
	return self.autoCompleteBnetID;
end

HouseFinderPlotInfoFrameMixin = {}

local HouseFinderPlotInfoShownEvents =
{
	"HOUSE_RESERVATION_RESPONSE_RECIEVED"
};

function HouseFinderPlotInfoFrameMixin:OnLoad()
	self.BackButton:SetScript("OnClick", self.OnBackClicked);
	self.VisitHouseButton:SetScript("OnClick", GenerateClosure(self.OnVisitClicked, self));
	SmallMoneyFrame_OnLoad(self.PriceMoneyFrame);
	MoneyFrame_SetType(self.PriceMoneyFrame, "STATIC");
end

function HouseFinderPlotInfoFrameMixin:OnEvent(event, ...)
	if event == "HOUSE_RESERVATION_RESPONSE_RECIEVED" then
		local result = ...;
		self.LoadingSpinnerVisitButton:Hide();
		if result == Enum.HousingResult.Success then
			self.VisitHouseButton:Enable();
			HideUIPanel(HouseFinderFrame);
		else
			self.ReservationError:Show();
		end
	end
end

function HouseFinderPlotInfoFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, HouseFinderPlotInfoShownEvents);
	self.LoadingSpinnerVisitButton:Hide();

	local visible = true;
	EventRegistry:TriggerEvent("HouseFinder.PlotInfoFrameVisibilityUpdated", visible);
end

function HouseFinderPlotInfoFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseFinderPlotInfoShownEvents);

	local visible = false;
	EventRegistry:TriggerEvent("HouseFinder.PlotInfoFrameVisibilityUpdated", visible);
end

function HouseFinderPlotInfoFrameMixin:Init(plotInfo, neighborhoodInfo)
	self.plotInfo = plotInfo;
	self.neighborhoodGUID = neighborhoodInfo.neighborhoodGUID;
	local bgAtlasPrefix = "housing-dashboard-bg-";
	local bgAtlasSuffix = C_Housing.GetNeighborhoodTextureSuffix(neighborhoodInfo.neighborhoodGUID);
	if bgAtlasSuffix then
		self.Background:SetAtlas(bgAtlasPrefix .. bgAtlasSuffix);
	end
	self.PlotLabel:SetText(string.format(HOUSING_PLOT_NUMBER, plotInfo.plotID));
	MoneyFrame_Update(self.PriceMoneyFrame, plotInfo.plotCost);
	self.VisitHouseButton:Enable();
	self.ReservationError:Hide();
	self.NeighborhoodText:SetText(neighborhoodInfo.neighborhoodName);
	self.TypeText:SetText(NeighborhoodTypeStrings[neighborhoodInfo.neighborhoodOwnerType]);
	if neighborhoodInfo.neighborhoodOwnerType == Enum.NeighborhoodOwnerType.None then
		self.OwnerText:Hide();
		self.OwnerLabel:Hide();
	else
		self.OwnerText:SetText(neighborhoodInfo.ownerName);
		self.OwnerText:Show();
		self.OwnerLabel:Show();
	end
	self.LocationText:SetText(neighborhoodInfo.locationName);
end

function HouseFinderPlotInfoFrameMixin:OnBackClicked()
	HouseFinderFrame:ShowNeighborhoodList();
	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_BACK_WHILE_PLOT_SELECTED);
end

function HouseFinderPlotInfoFrameMixin:OnVisitClicked()
	C_Housing.HouseFinderRequestReservationAndPort(self.neighborhoodGUID, self.plotInfo.plotID);
	self.VisitHouseButton:Disable();
	self.LoadingSpinnerVisitButton:Show();
	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_VISIT_HOUSE_BUTTON);
end

HouseFinderNeighborhoodButtonMixin = {}

function HouseFinderNeighborhoodButtonMixin:Init(neighborhoodInfo, houseFinderFrame)
	self.neighborhoodInfo = neighborhoodInfo;
	self.NeighborhoodName:SetText(neighborhoodInfo.neighborhoodName);
	self.NeighborhoodType:SetText(NeighborhoodTypeStrings[neighborhoodInfo.neighborhoodOwnerType]);
	if neighborhoodInfo.ownerName then
		self.TypeSpacer:Show();
		self.NeighborhoodOwner:SetText(neighborhoodInfo.ownerName);
	else
		self.TypeSpacer:Hide();
		self.NeighborhoodOwner:SetText("");
	end
	self.houseFinderFrame = houseFinderFrame;
	self.LoadingSpinner:Hide();
	if self.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.CharterInvite then
		self.SuggestionIcon:Show();
		self.SuggestionIcon:SetAtlas("housing-neighborhood-invite-icon");
		self.NeighborhoodName:SetPoint("LEFT", 30, 7);
		self.DeclineInviteButton:SetNeighborhoodButton(self);
		self.DeclineInviteButton:Show();
		self.GuildIcon:Hide();
	elseif self.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.PartySync then
		self.SuggestionIcon:Show();
		self.SuggestionIcon:SetAtlas("housefinder_neighborhood-party-sync-icon");
		self.NeighborhoodName:SetPoint("LEFT", 30, 7);
		self.DeclineInviteButton:Hide();
		self.GuildIcon:Hide();
	elseif self.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.Guild and self:UpdateGuildIcon() then
		self.GuildIcon:Show();
		self.NeighborhoodName:SetPoint("LEFT", 30, 7);
		self.DeclineInviteButton:Hide();
		self.SuggestionIcon:Hide();
	else
		self.NeighborhoodName:SetPoint("LEFT", 15, 7);
		self.DeclineInviteButton:Hide();
		self.SuggestionIcon:Hide();
		self.GuildIcon:Hide();
	end
	self:Deselect();
	self:Show();

end

function HouseFinderNeighborhoodButtonMixin:OnEnter()
	PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_NEIGHBORHOOD_HOVER);
end

function HouseFinderNeighborhoodButtonMixin:OnLeave()

end

function HouseFinderNeighborhoodButtonMixin:OnClick()
	if self.houseFinderFrame then
		local shouldRequestNeighborhoodData = true;
		self.houseFinderFrame:SelectNeighborhood(self, shouldRequestNeighborhoodData);
		PlaySound(SOUNDKIT.HOUSING_HOUSE_FINDER_NEIGHBORHOOD_SELECT);
	end
end

function HouseFinderNeighborhoodButtonMixin:Select()
	local selectedAtlasSuffix = C_Housing.GetNeighborhoodTextureSuffix(self.neighborhoodInfo.neighborhoodGUID);
	if selectedAtlasSuffix then
		self.ButtonBackground:SetAtlas(SELECTED_NEIGHBORHOOD_ATLAS_PREFIX .. selectedAtlasSuffix);
		self:SetHighlightAtlas(SELECTED_NEIGHBORHOOD_HIGHLIGHT_ATLAS_PREFIX .. selectedAtlasSuffix);
	end
end

function HouseFinderNeighborhoodButtonMixin:Deselect()
	if self.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.None or self.neighborhoodInfo.suggestionReason == Enum.HouseFinderSuggestionReason.Random then
		self.ButtonBackground:SetAtlas(NEIGHBORHOOD_BG_ATLAS);
	else
		self.ButtonBackground:SetAtlas(NEIGHBORHOOD_RECCOMENDED_BG_ATLAS);
	end
	self:SetHighlightAtlas(NEIGHBORHOOD_HIGHLIGHT_ATLAS);
end

function HouseFinderNeighborhoodButtonMixin:TryCancelInvite()
	HouseFinderFrame:SetPendingNeighborhoodInviteToDecline(self);
	self.LoadingSpinner:Show();
	self.DeclineInviteButton:Hide();
	C_Housing.HouseFinderDeclineNeighborhoodInvitation();
end

function HouseFinderNeighborhoodButtonMixin:FailCancelInvite()
	self.LoadingSpinner:Hide();
	self.DeclineInviteButton:Show();
end

function HouseFinderNeighborhoodButtonMixin:UpdateGuildIcon()
	local emblemFilename = select(10, GetGuildLogoInfo());
	local tabardInfo = C_GuildInfo.GetGuildTabardInfo("player");
	local hasTabard = emblemFilename and tabardInfo;

	if hasTabard then
		local color = tabardInfo.backgroundColor;
		self.GuildIcon.TabardBG:SetVertexColor(color.r, color.g, color.b);
		SetSmallGuildTabardTextures("player", self.GuildIcon.Emblem);
		SetSmallGuildTabardTextures("player", self.GuildIcon.HighlightEmblem);
	end

	return hasTabard;
end

DeclineInviteButtonMixin = {}

function DeclineInviteButtonMixin:SetNeighborhoodButton(neighborhoodButton)
	self.neighborhoodButton = neighborhoodButton;
end

function DeclineInviteButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip_AddNormalLine(GameTooltip, HOUSING_HOUSEFINDER_CANCEL_INVITATION_CONFIRM);
	GameTooltip:Show();
end

function DeclineInviteButtonMixin:OnLeave()
	GameTooltip:Hide();
end

StaticPopupDialogs["HOUSING_HOUSEFINDER_CANCEL_INVITATION"] = {
	text = HOUSING_HOUSEFINDER_CANCEL_INVITATION,
	button1 = HOUSING_HOUSEFINDER_CANCEL_INVITATION_CONFIRM,
	button2 = HOUSING_HOUSEFINDER_CANCEL_INVITATION_CANCEL,
	OnAccept = function(self, neighborhoodButton)
		neighborhoodButton:TryCancelInvite();
	end,
	hideOnEscape = 1
};

function DeclineInviteButtonMixin:OnClick()
	StaticPopup_Show("HOUSING_HOUSEFINDER_CANCEL_INVITATION", nil, nil, self.neighborhoodButton);
end

function DeclineInviteButtonMixin:OnMouseDown()
	self:SetPoint("TOPRIGHT", -9, -11);
end

function DeclineInviteButtonMixin:OnMouseUp()
	self:SetPoint("TOPRIGHT", -10, -10);
end
