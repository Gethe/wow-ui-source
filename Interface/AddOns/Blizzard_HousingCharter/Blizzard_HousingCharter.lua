HousingCharterMixin = {}

local HousingCharterFrameShowingEvents =
{
	"OPEN_NEIGHBORHOOD_CHARTER",
	"PLAYER_TARGET_CHANGED",
	"ADD_NEIGHBORHOOD_CHARTER_SIGNATURE"
};

function HousingCharterMixin:OnLoad()

	self.signaturePool = CreateFramePool("Frame", self.SignaturesFrame, "HousingCharterSignatureTemplate");

	self.RequestButton:SetScript("OnClick", GenerateClosure(self.OnRequestClicked, self));
	self.SettingsButton:SetScript("OnClick", GenerateClosure(self.OnSettingsClicked, self));
	self.CloseButton:SetScript("OnClick", GenerateClosure(self.OnCloseClicked, self));
end

function HousingCharterMixin:OnRequestClicked()
	C_Housing.OnRequestSignatureClicked();
	PlaySound(SOUNDKIT.HOUSING_CHARTER_BUTTON);
end

function HousingCharterMixin:OnSettingsClicked()
	if not HousingCreateNeighborhoodCharterFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCreateNeighborhood");
	end
	HousingCreateNeighborhoodCharterFrame:SetCharterInfo(self.neighborhoodInfo.neighborhoodName);
	ShowUIPanel(HousingCreateNeighborhoodCharterFrame);
	PlaySound(SOUNDKIT.HOUSING_CHARTER_BUTTON);
end

function HousingCharterMixin:OnCloseClicked()
	HideUIPanel(self);
	PlaySound(SOUNDKIT.HOUSING_CHARTER_BUTTON);
end

function HousingCharterMixin:OnEvent(event, ...)
	if event == "OPEN_NEIGHBORHOOD_CHARTER" then
		local neighborhoodInfo, signatures, numSignaturesRequired = ...;
		self:SetCharterInfo(neighborhoodInfo, signatures, numSignaturesRequired);
		self:UpdateSettingsButton();
	elseif event == "PLAYER_TARGET_CHANGED" then
		self:UpdateRequestButton();
	elseif event == "ADD_NEIGHBORHOOD_CHARTER_SIGNATURE" then
		local signature = ...;
		self:AddSignature(signature);
		self:UpdateSettingsButton();
	end
end

function HousingCharterMixin:OnShow()
	self:UpdateRequestButton();
	self:UpdateSettingsButton();
	FrameUtil.RegisterFrameForEvents(self, HousingCharterFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CHARTER_OPEN);
end

function HousingCharterMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HousingCharterFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CHARTER_CLOSE);
end

function HousingCharterMixin:UpdateRequestButton()
	if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("player", "target") then
		self.RequestButton:Enable()
	else
		self.RequestButton:Disable()
	end
end

function HousingCharterMixin:AddSignature(signature)
	for signatureFrame in self.signaturePool:EnumerateActive() do
		if not signatureFrame.signed then
			signatureFrame.PlayerNameText:SetText(signature);
			return;
		end
	end
end

function HousingCharterMixin:UpdateSettingsButton()
	self.SettingsButton:SetEnabled(C_Housing.CanEditCharter());
end

function HousingCharterMixin:SetCharterInfo(neighborhoodInfo, signatures, numSignaturesRequired)
	self.signaturePool:ReleaseAll();
	self.neighborhoodInfo = neighborhoodInfo;

	self.LocationText:SetText(neighborhoodInfo.locationName);
	self.NeighborhoodNameText:SetText(neighborhoodInfo.neighborhoodName);

	local signatureFrames = {};
	for i, signature in ipairs(signatures) do
		local signatureFrame = self.signaturePool:Acquire();
		signatureFrame.PlayerNameText:SetText(signature);
		signatureFrame.layoutIndex = i;
		signatureFrame.signed = true;
		signatureFrame:Show();
		table.insert(signatureFrames, signatureFrame);
	end
	for n = #signatures, numSignaturesRequired-1 do
		local signatureFrame = self.signaturePool:Acquire();
		signatureFrame.PlayerNameText:SetText(HOUSING_CHARTER_UNSIGNED);
		signatureFrame.layoutIndex = i;
		signatureFrame.signed = false;
		signatureFrame:Show();
		table.insert(signatureFrames, signatureFrame);
	end

	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, 2, 0, 0);
	local anchor = CreateAnchor("TOPLEFT", self.SignaturesFrame, "TOPLEFT", 25, -15);
	AnchorUtil.GridLayout(signatureFrames, anchor, layout);
end

--//////////////////////////////////////////////////////
HousingCharterRequestSignatureFrameMixin = {}

function HousingCharterRequestSignatureFrameMixin:OnLoad()
	self:SetTitle(HOUSING_CREATENEIGHBORHOOD_CHARTER);

	self.ConfirmButton:SetScript("OnClick", function()
		C_Housing.OnSignCharterClicked(self.neighborhoodInfo.ownerGUID);
		StaticPopupSpecial_Hide(HousingCharterRequestSignatureDialog);
		PlaySound(SOUNDKIT.HOUSING_CHARTER_REQUEST_SIGN);
	end);
	self.CancelButton:SetScript("OnClick", function()
		StaticPopupSpecial_Hide(HousingCharterRequestSignatureDialog);
		PlaySound(SOUNDKIT.HOUSING_CHARTER_REQUEST_DECLINE);
	end);
end

function HousingCharterRequestSignatureFrameMixin:SetNeighborhoodInfo(neighborhoodInfo)
	self.neighborhoodInfo = neighborhoodInfo;
	if neighborhoodInfo.ownerName then
		self.DescriptionText:SetText(string.format(HOUSING_CHARTER_REQUEST_DESCRIPTION, neighborhoodInfo.ownerName, neighborhoodInfo.ownerName));
	end
	if neighborhoodInfo.locationName then
		self.LocationText:SetText(string.format(HOUSING_CHARTER_REQUEST_LOCATION, neighborhoodInfo.locationName));
	end

	self.NeighborhoodNameText:SetText(string.format(HOUSING_CHARTER_REQUEST_NAME, neighborhoodInfo.neighborhoodName));
end
