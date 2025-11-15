HousingCornerstoneFrameMixin = {}

local CornerstoneFrameShowingEvents =
{
	"CLOSE_PLOT_CORNERSTONE",
};

function HousingCornerstoneFrameMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);
	self:SetTabSystem(self.TabSystem);
	self.infoTabID = self:AddNamedTab(HOUSING_CORNERSTONE_TAB_INFO, self.InfoFrame);
	self.dropboxTabID = self:AddNamedTab(HOUSING_CORNERSTONE_TAB_DROPBOX, self.DropboxFrame);

	self:UpdateTabs();
end

function HousingCornerstoneFrameMixin:OnEvent(event, ...)
	if event == "CLOSE_PLOT_CORNERSTONE" then
		HideUIPanel(HousingCornerstoneFrame);
	end
end

function HousingCornerstoneFrameMixin:OnShow()
	self.houseInfo = C_HousingNeighborhood.GetCornerstoneHouseInfo();
	FrameUtil.RegisterFrameForEvents(self, CornerstoneFrameShowingEvents);
end

function HousingCornerstoneFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CornerstoneFrameShowingEvents);
end

function HousingCornerstoneFrameMixin:UpdateTabs()
	self.TabSystem:SetTabShown(self.infoTabID, true);
	self.TabSystem:SetTabShown(self.dropboxTabID, true);

	local currentTab = self:GetTab();
	if not currentTab then
		self:SetToDefaultAvailableTab();
	end
end

function HousingCornerstoneFrameMixin:SetToDefaultAvailableTab()
	self:SetTab(self.infoTabID);
end

function HousingCornerstoneFrameMixin:SetTab(tabID)
	TabSystemOwnerMixin.SetTab(self, tabID);
end

--//////////////////////////////Purchase Frame//////////////////////////////////////////
HousingCornerstonePurchaseFrameMixin = {}

local CornerstonePurchaseFrameShowingEvents =
{
	"PLAYER_MONEY",
	"CLOSE_PLOT_CORNERSTONE",
};

local CornerstonePurchaseFrameLifetimeEvents =
{
	"PURCHASE_PLOT_RESULT",
};

function HousingCornerstonePurchaseFrameMixin:OnLoad()
	self.BuyButton:SetScript("OnClick", GenerateClosure(self.OnPurchaseClicked, self));
	FrameUtil.RegisterFrameForEvents(self, CornerstonePurchaseFrameLifetimeEvents);

	SmallMoneyFrame_OnLoad(self.PriceMoneyFrame);
	MoneyFrame_SetType(self.PriceMoneyFrame, "STATIC");

	self.MoneyFrame.GoldButton:EnableMouse(false);
	self.MoneyFrame.SilverButton:EnableMouse(false);
	self.MoneyFrame.CopperButton:EnableMouse(false);
end

function HousingCornerstonePurchaseFrameMixin:OnEvent(event, ...)
	if event == "PURCHASE_PLOT_RESULT" then
		local result = ...;
		if result ~= 0 then
			EventRegistry:RegisterCallback("CinematicFrame.CinematicStopped", self.OnCinematicStopped, self);
		else
			UIErrorsFrame:AddExternalErrorMessage(HOUSING_PURCHASE_PLOT_ERROR);
		end
	elseif event == "PLAYER_MONEY" then
		self:CheckPurchaseEligibility();
	elseif event == "CLOSE_PLOT_CORNERSTONE" then
		HideUIPanel(HousingCornerstonePurchaseFrame);
	end
end

function HousingCornerstonePurchaseFrameMixin:OnCinematicStopped()
	HousingTopBannerFrame:SetBannerText(HOUSING_CORNERSTONE_HOUSE_PURCHASED_TOAST, self.neighborhoodName);
	TopBannerManager_Show(HousingTopBannerFrame);
	EventRegistry:UnregisterCallback("CinematicFrame.CinematicStopped", self);
end

function HousingCornerstonePurchaseFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CornerstonePurchaseFrameShowingEvents);
	self.houseInfo = C_HousingNeighborhood.GetCornerstoneHouseInfo();
	self.neighborhoodInfo = C_HousingNeighborhood.GetCornerstoneNeighborhoodInfo();

	self.PlotText:SetText(string.format(HOUSING_PLOT_NUMBER, self.houseInfo.plotID));

	--Money frame STATIC info does not force show when set to 0, swap to using GUILD_REPAIR which is identical to STATIC except it shows 0 values
	if self.houseInfo.plotCost == 0 then
		MoneyFrame_SetType(self.PriceMoneyFrame, "GUILD_REPAIR");
	else
		MoneyFrame_SetType(self.PriceMoneyFrame, "STATIC");
	end
	MoneyFrame_Update("HousingCornerstonePriceMoneyFrame", self.houseInfo.plotCost);

	self.NeighborhoodText:SetText(self.neighborhoodInfo.neighborhoodName);
	self.NeighborhoodLocationText:SetText(self.neighborhoodInfo.locationName);
	self.NeighborhoodTypeText:SetText(self:GetTypeString());
	if self.neighborhoodInfo.ownerName then
		self.NeighborhoodOwnerText:SetText(self.neighborhoodInfo.ownerName);
		self.NeighborhoodOwnerLabel:Show();
		self.NeighborhoodOwnerText:Show();
	else
		self.NeighborhoodOwnerLabel:Hide();
		self.NeighborhoodOwnerText:Hide();
	end

	self.purchaseMode = C_HousingNeighborhood.GetCornerstonePurchaseMode();
	if self.purchaseMode == Enum.CornerstonePurchaseMode.Move then
		self.BuyButton:SetText(HOUSING_CORNERSTONE_MOVE_BUTTON);
	else
		self.BuyButton:SetText(HOUSING_CORNERSTONE_BUY);
	end
	self:CheckPurchaseEligibility();
	self:CheckMoveCooldown();

	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_FOR_SALE_OPEN);
	self.boughtHouse = false;
end

local moveCooldownTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
moveCooldownTimeFormatter:Init(
	SECONDS_PER_HOUR, 
	SecondsFormatter.Abbreviation.None,
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);
moveCooldownTimeFormatter:SetMinInterval(SecondsFormatter.Interval.Hours);

function HousingCornerstonePurchaseFrameMixin:CheckMoveCooldown()
	local cooldown = C_HousingNeighborhood.GetMoveCooldownTime();
	if cooldown > 0 and self.purchaseMode == Enum.CornerstonePurchaseMode.Move then
		self.BuyButton:Disable();
		self.BuyButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(HousingCornerstonePurchaseFrame.BuyButton, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, HOUSING_CORNERSTONE_MOVE_TOOLTIP);
			GameTooltip_AddHighlightLine(GameTooltip, string.format(HOUSING_CORNERSTONE_MOVE_TOOLTIP_TIME, moveCooldownTimeFormatter:Format(cooldown)));
			GameTooltip:Show();
		end);
		self.BuyButton:SetScript("OnLeave", GameTooltip_Hide);
	else
		--We don't need to re-enable the buy button here, that will be covered in CheckPurchaseEligibility
		self.BuyButton:SetScript("OnEnter", nil);
		self.BuyButton:SetScript("OnLeave", nil);
	end
end

function HousingCornerstonePurchaseFrameMixin:GetTypeString()
	local ownerType = self.neighborhoodInfo.neighborhoodOwnerType;

	if ownerType == Enum.NeighborhoodOwnerType.None then
		return HOUSING_CORNERSTONE_NEIGHBORHOOD_PUBLIC;
	elseif ownerType == Enum.NeighborhoodOwnerType.Guild then
		return HOUSING_CORNERSTONE_NEIGHBORHOOD_GUILD;
	elseif ownerType == Enum.NeighborhoodOwnerType.Charter then
		return HOUSING_CORNERSTONE_NEIGHBORHOOD_CHARTER;
	end
end

--TODO: Fill in global strings when we decide what errors to show to players
local CantPurchaseReasonStrings = {
	[Enum.PurchaseHouseDisabledReason.WrongFaction] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.WrongGuild] = HOUSING_CORNERSTONE_NOT_IN_GUILD,
	[Enum.PurchaseHouseDisabledReason.NotInvited] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.NoExpansion] = HOUSING_CORNERSTONE_MIDNIGHT_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.Reserved] = ERR_HOUSING_RESULT_PLOT_RESERVED,
	[Enum.PurchaseHouseDisabledReason.GuildLockout] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.CharterLockout] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.MaxHouses] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
	[Enum.PurchaseHouseDisabledReason.NoGameTimeRemaining] = HOUSING_CORNERSTONE_GENERIC_PERMISSION,
};

function HousingCornerstonePurchaseFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CornerstonePurchaseFrameShowingEvents);

	if self.boughtHouse == false then
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_FOR_SALE_CLOSE);
	end
end

function HousingCornerstonePurchaseFrameMixin:CheckPurchaseEligibility()
	local canBuy = true;
	if GetMoney() >= self.houseInfo.plotCost then
		SetMoneyFrameColor("HousingCornerstonePriceMoneyFrame", "gold");
	else
		SetMoneyFrameColor("HousingCornerstonePriceMoneyFrame", "red")
		self.BuyButton:Disable();
		self.ErrorText:SetText(HOUSING_CORNERSTONE_CANT_AFFORD);
		self.ErrorText:Show();
		canBuy = false;
	end
	
	local cantPurchaseReason = C_HousingNeighborhood.HasPermissionToPurchase();
	if cantPurchaseReason ~= Enum.PurchaseHouseDisabledReason.None then
		self.BuyButton:Disable();
		self.ErrorText:SetText(CantPurchaseReasonStrings[cantPurchaseReason]);
		self.ErrorText:Show();
		canBuy = false;
	end

	if canBuy then
		self.BuyButton:Enable();
		self.ErrorText:Hide();
	end
	
end

StaticPopupDialogs["HOUSING_PURCHASE_PLOT_CONFIRMATION"] = {
	text = HOUSING_PURCHASE_PLOT_CONFIRMATION_TEXT,
	button1 = HOUSING_PURCHASE_PLOT_BUY,
	button2 = HOUSING_PURCHASE_PLOT_CANCEL,
	OnAccept = function(self)
		HousingCornerstonePurchaseFrame:OnConfirmPurchase();
	end,
	OnCancel = function (self)
		self:Hide();
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_FOR_SALE_BUY_CANCEL);
	end,
	hideOnEscape = 1
};

function HousingCornerstonePurchaseFrameMixin:OnPurchaseClicked()
	if self.purchaseMode == Enum.CornerstonePurchaseMode.Basic then
		StaticPopup_Show("HOUSING_PURCHASE_PLOT_CONFIRMATION");
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_FOR_SALE_BUY);
	elseif self.purchaseMode == Enum.CornerstonePurchaseMode.Import then
		StaticPopupSpecial_Show(ImportHouseConfirmationDialog);
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_BUTTONS);
	elseif self.purchaseMode == Enum.CornerstonePurchaseMode.Move then
		StaticPopupSpecial_Show(MoveHouseConfirmationDialog);
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_MOVE);
	end
end

function HousingCornerstonePurchaseFrameMixin:OnConfirmPurchase()
	if self.purchaseMode == Enum.CornerstonePurchaseMode.Move then
		C_HousingNeighborhood.TryMoveHouse();
	else
		C_HousingNeighborhood.TryPurchasePlot();
	end
	self.boughtHouse = true;
	HideUIPanel(HousingCornerstonePurchaseFrame);

	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_FOR_SALE_BUY_CONFIRM);
end

function HousingCornerstonePurchaseFrameMixin:OnNeighborhoodInfoUpdated(neighborhoodInfo)
	self.neighborhoodName = neighborhoodInfo.neighborhoodName;
	self.NeighborhoodText:SetText(self.neighborhoodName);
	self:CheckPurchaseEligibility();
end

--//////////////////////////////Shared Visitor Frame//////////////////////////////////////////
HousingCornerstoneVisitorFrameSharedMixin = {};

function HousingCornerstoneVisitorFrameSharedMixin:OnLoad()
	self.GearDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:CreateButton(HOUSING_CORNERSTONE_REPORT, GenerateClosure(self.OnReportClicked, self));
	end);
end

function HousingCornerstoneVisitorFrameSharedMixin:OnReportClicked()
	if self.houseInfo then
		local reportInfo = ReportInfo:CreateDecorReportInfo(Enum.ReportType.HousingDecor, self.houseInfo.plotID, self.houseInfo.neighborhoodGUID);
		ReportFrame:InitiateReport(reportInfo, self.houseInfo.ownerName, nil, --[[isBnetReport]] false, --[[sendReportWithoutDialog]] false);
	end
end

--//////////////////////////////Visitor Frame//////////////////////////////////////////
HousingCornerstoneVisitorFrameMixin = CreateFromMixins(HousingCornerstoneVisitorFrameSharedMixin);

local CornerstoneVisitorFrameShowingEvents =
{
	"CLOSE_PLOT_CORNERSTONE",
};

function HousingCornerstoneVisitorFrameMixin:OnEvent(event, ...)
	if event == "CLOSE_PLOT_CORNERSTONE" then
		HideUIPanel(HousingCornerstoneVisitorFrame);
	end
end

function HousingCornerstoneVisitorFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CornerstoneVisitorFrameShowingEvents);
	self.houseInfo = C_HousingNeighborhood.GetCornerstoneHouseInfo();
	self.neighborhoodInfo = C_HousingNeighborhood.GetCornerstoneNeighborhoodInfo();

	self.HouseNameText:SetText(self.houseInfo.houseName);
	self.OwnerText:SetText(self.houseInfo.ownerName);
	self.PlotText:SetText(string.format(HOUSING_PLOT_NUMBER, self.houseInfo.plotID));
	self.NeighborhoodText:SetText(self.neighborhoodInfo.neighborhoodName);

	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_OWNED_OPEN);
end

function HousingCornerstoneVisitorFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CornerstoneVisitorFrameShowingEvents);
	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_OWNED_CLOSE);
end

--//////////////////////////////House Info Frame//////////////////////////////////////////
HousingCornerstoneHouseInfoFrameMixin = CreateFromMixins(HousingCornerstoneVisitorFrameSharedMixin);

local CornerstoneHouseInfoFrameEvents =
{
	"CURRENT_HOUSE_INFO_RECIEVED",
	"CURRENT_HOUSE_INFO_UPDATED",
};

function HousingCornerstoneHouseInfoFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CornerstoneHouseInfoFrameEvents);
	C_Housing.RequestCurrentHouseInfo();
	self:UpdateHouseInfo();
end

function HousingCornerstoneHouseInfoFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CornerstoneHouseInfoFrameEvents);
	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_OWNED_CLOSE);
end

function HousingCornerstoneHouseInfoFrameMixin:OnEvent(event, ...)
	if (event == "CURRENT_HOUSE_INFO_RECIEVED") or (event == "CURRENT_HOUSE_INFO_UPDATED") then
		self:UpdateHouseInfo();
	end
end

local function HasData(houseInfo)
	if not houseInfo then
		return false;
	end

	if not houseInfo.houseName or houseInfo.houseName == "" then
		return false;
	end

	if not houseInfo.ownerName or houseInfo.ownerName == "" then
		return false;
	end

	if houseInfo.plotID < 0 then
		return false;
	end

	if not houseInfo.neighborhoodName or houseInfo.neighborhoodName == "" then
		return false;
	end

	return true;
end

function HousingCornerstoneHouseInfoFrameMixin:UpdateHouseInfo()
	local houseInfo = C_Housing.GetCurrentHouseInfo();
	self.houseInfo = houseInfo;

	local hasData = HasData(houseInfo);
	self.LoadingSpinner:SetShown(not hasData);
	self.GearDropdown:SetShown(hasData);
	self.Header:SetShown(hasData);
	self.HouseNameText:SetShown(hasData);
	self.OwnerLabel:SetShown(hasData);
	self.OwnerText:SetShown(hasData);
	self.LocationLabel:SetShown(hasData);
	self.PlotText:SetShown(hasData);
	self.NeighborhoodLabel:SetShown(hasData);
	self.NeighborhoodText:SetShown(hasData);

	if hasData then
		self.HouseNameText:SetText(houseInfo.houseName);
		self.OwnerText:SetText(houseInfo.ownerName);
		self.PlotText:SetText(string.format(HOUSING_PLOT_NUMBER, houseInfo.plotID));
		self.NeighborhoodText:SetText(houseInfo.neighborhoodName);
	end

	PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_OWNED_OPEN);
end

--//////////////////////////////moving confirmation dialog//////////////////////////////////////////
MoveHouseConfirmationDialogMixin = {}

function MoveHouseConfirmationDialogMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self.PriceMoneyFrameOriginal);
	MoneyFrame_SetType(self.PriceMoneyFrameOriginal, "STATIC");

	SmallMoneyFrame_OnLoad(self.PriceMoneyFrameDiscount);
	MoneyFrame_SetType(self.PriceMoneyFrameDiscount, "STATIC");

	self.ConfirmButton:SetText(HOUSING_PURCHASE_PLOT_BUY);
	self.CancelButton:SetText(HOUSING_PURCHASE_PLOT_CANCEL);

	self.ConfirmButton:SetScript("OnClick", function()
		HousingCornerstonePurchaseFrame:OnConfirmPurchase();
		StaticPopupSpecial_Hide(self);
	end);

	self.CancelButton:SetScript("OnClick", function()
		StaticPopupSpecial_Hide(self);
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_MOVE_CANCEL);
	end);
end

function MoveHouseConfirmationDialogMixin:OnShow()
	local discountPrice = C_HousingNeighborhood.GetDiscountedMovePrice();

	--Money frame STATIC info does not force show when set to 0, swap to using GUILD_REPAIR which is identical to STATIC except it shows 0 values
	if discountPrice == 0 then
		MoneyFrame_SetType(self.PriceMoneyFrameDiscount, "GUILD_REPAIR");
	else
		MoneyFrame_SetType(self.PriceMoneyFrameDiscount, "STATIC");
	end

	--Handle negative values in case the refund from old house is more than the cost of the new house
	if discountPrice < 0 then
		discountPrice = math.abs(discountPrice);
		MoneyFrame_Update(self.PriceMoneyFrameOriginal, discountPrice);
		self.PriceMoneyFrameDiscount:Hide();
		self.PriceLabel:SetText(HOUSING_CORNERSTONE_REFUND);
		self.OriginalStrikethrough:Hide();
	else
		MoneyFrame_Update(self.PriceMoneyFrameOriginal, HousingCornerstonePurchaseFrame.houseInfo.plotCost);
		MoneyFrame_Update(self.PriceMoneyFrameDiscount, discountPrice);
		self.PriceMoneyFrameDiscount:Show();
		self.PriceLabel:SetText(HOUSING_CORNERSTONE_PRICE);
		self.OriginalStrikethrough:Show();
	end

	self.HouseToMoveText:SetText(C_HousingNeighborhood.GetPreviousHouseIdentifier());
end

--//////////////////////////////re-use old house confirmation dialog//////////////////////////////////////////
ImportHouseConfirmationDialogMixin = {}

function ImportHouseConfirmationDialogMixin:OnLoad()
	self.ConfirmButton:SetText(HOUSING_PURCHASE_PLOT_BUY);
	self.CancelButton:SetText(HOUSING_PURCHASE_PLOT_CANCEL);

	self.ConfirmButton:SetScript("OnClick", function()
		HousingCornerstonePurchaseFrame:OnConfirmPurchase();
		StaticPopupSpecial_Hide(self);
	end);

	self.CancelButton:SetScript("OnClick", function()
		StaticPopupSpecial_Hide(self);
		PlaySound(SOUNDKIT.HOUSING_CORNERSTONE_BUTTONS);
	end);
end

function ImportHouseConfirmationDialogMixin:OnShow()
	self.HouseToImportText:SetText(C_HousingNeighborhood.GetPreviousHouseIdentifier());
end
