local function IsElementDataItemInfo(elementData)
	return elementData.isItemInfo;
end

----------------------------------------------------------------------------------
-- PerksProgramProductsFrameMixin
----------------------------------------------------------------------------------
PerksProgramProductsFrameMixin = {};
function PerksProgramProductsFrameMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH");
	self:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_REFUND_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_SET_FROZEN_ITEM");
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
	EventRegistry:RegisterCallback("PerksProgram.SortFieldSet", self.SortFieldSet, self);
	EventRegistry:RegisterCallback("PerksProgram.AllDataRefresh", self.AllDataRefresh, self);

	local faction = UnitFactionGroup("player");
	if faction and (PLAYER_FACTION_GROUP[faction] == "Horde") then 		
		self.LeftBackgroundOverlay:SetAtlas("perks-gradient-orgrimmar-left");
		self.RightBackgroundOverlay:SetAtlas("perks-gradient-orgrimmar-right");
	else
		self.LeftBackgroundOverlay:SetAtlas("perks-gradient-stormwind-left");
		self.RightBackgroundOverlay:SetAtlas("perks-gradient-stormwind-right");
	end

	self.FrozenProductContainer = self.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenProductContainer;
end

function PerksProgramProductsFrameMixin:Init()
	local scrollContainer = self.ProductsScrollBoxContainer;

	local DefaultPad = 5;
	local DefaultSpacing = 1;

	local function InitializeHeader(frame, headerInfo)
		frame.Text:SetText(headerInfo.uiGroupInfo.name);
	end

	local function InitializeButton(frame, itemInfo)
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(itemInfo);

		frame:Init(function() self:OnProductButtonDragStart(itemInfo) end);
		frame:SetItemInfo(itemInfo);
		frame:SetSelected(isSelected);
		frame:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
		end);
	end

	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
	view:SetElementFactory(function(factory, elementData)
		if elementData.isHeaderInfo then
			factory("PerksProgramProductHeaderTemplate", InitializeHeader);
		elseif elementData.isItemInfo then
			factory("PerksProgramProductButtonTemplate", InitializeButton);
		end
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollContainer.ScrollBox, scrollContainer.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		if selected then
			self:OnProductSelected(elementData);
		end

		local button = scrollContainer.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;
	scrollContainer.selectionBehavior = ScrollUtil.AddSelectionBehavior(scrollContainer.ScrollBox);
	scrollContainer.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFilterChanged", self.OnFilterChanged, self);

	self.FrozenProductContainer:Init(function(itemInfo) self:OnProductSelected(itemInfo) end);
end

function PerksProgramProductsFrameMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH" or event == "PERKS_PROGRAM_PURCHASE_SUCCESS" or event == "PERKS_PROGRAM_REFUND_SUCCESS" then
		local vendorItemID = ...;

		local vendorItemInfo = PerksProgramFrame:GetVendorItemInfo(vendorItemID);
		if event == "PERKS_PROGRAM_REFUND_SUCCESS" then
			vendorItemInfo.purchased = false;
		end

		-- Make sure to update scroll box data since they won't receive the events sent below to update shown frames
		local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
		local _, foundElementData = scrollBox:FindByPredicate(function(elementData)
			return elementData.perksVendorItemID == vendorItemID;
		end);
		if foundElementData then
			SetTablePairsToTable(foundElementData, vendorItemInfo);
			foundElementData.isPurchasePending = vendorItemInfo.isPurchasePending;
		end

		EventRegistry:TriggerEvent("PerksProgram.OnProductPurchasedStateChange", vendorItemInfo);
		EventRegistry:TriggerEvent("PerksProgram.OnProductInfoChanged", vendorItemInfo);

		if event == "PERKS_PROGRAM_PURCHASE_SUCCESS" then
			EventRegistry:TriggerEvent("PerksProgram.CelebratePurchase", vendorItemInfo);
		end
	elseif event == "PERKS_PROGRAM_SET_FROZEN_ITEM" then
		self:UpdateProducts();
	end
end

local INTERVAL_UPDATE_SECONDS_TIME = 15.0;
local currentInterval = 0.0;
function PerksProgramProductsFrameMixin:OnUpdate(deltaTime)
	currentInterval = currentInterval + deltaTime;
	if currentInterval >= INTERVAL_UPDATE_SECONDS_TIME then
		local dataProvider = self.ProductsScrollBoxContainer.ScrollBox:GetDataProvider();
		dataProvider:ForEach(function(elementData)
			if elementData.isItemInfo then
				elementData.timeRemaining = C_PerksProgram.GetTimeRemaining(elementData.perksVendorItemID);
			end
		end);
		self.ProductsScrollBoxContainer.ScrollBox:ForEachFrame(function(itemFrame, elementData)
			if elementData.isItemInfo then
				itemFrame:UpdateTimeRemainingText();
			end
		end);
		currentInterval = 0.0;
	end
end

function PerksProgramProductsFrameMixin:OnProductButtonDragStart(itemInfo)
	if itemInfo and not itemInfo.purchased then
		self:TrySelectProduct(itemInfo);
		C_PerksProgram.PickupPerksVendorItem(itemInfo.perksVendorItemID);
	end
end

function PerksProgramProductsFrameMixin:OnProductSelected(productItemInfo)
	self.selectedProductInfo = productItemInfo;

	-- Make sure only 1 product appears selected at a time
	if productItemInfo.isFrozen then
		self.ProductsScrollBoxContainer.selectionBehavior:ClearSelections();
	else
		self.FrozenProductContainer:SetSelected(false);
	end

	EventRegistry:TriggerEvent("PerksProgramProductsFrame.OnProductSelected", productItemInfo);
	EventRegistry:TriggerEvent("PerksProgram.OnProductCategoryChanged", productItemInfo.perksVendorCategoryID);

	if not self.silenceSelectionSounds then
		PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_SELECT);
	end
end

function PerksProgramProductsFrameMixin:OnProductSelectedAfterModel(data)
	C_PerksProgram.ItemSelectedTelemetry(data.perksVendorItemID);
end

local function SetDefaultActorDisplayData(displayData)
	displayData.actorID = 0;
	displayData.actorScriptTag = "";
	displayData.posX = 0;
	displayData.posY = 0;
	displayData.posZ = 0;
	displayData.yaw = 0;
	displayData.pitch = 0;
	displayData.roll = 0;
	displayData.normalizedScale = 0;
	displayData.alternateFormData = {};
end

local function SetDefaultCameraData(displayData)
	displayData.cameraID = 0;
	displayData.cameraScriptTag = "";
	displayData.cameraTargetX = 0;
	displayData.cameraTargetY = 0;
	displayData.cameraTargetZ = 0;
	displayData.cameraYaw = 0;
	displayData.cameraPitch = 0;
	displayData.cameraRoll = 0;
	displayData.cameraZoomDistance = 7.5;
	displayData.cameraMinZoomDistance = 0;
	displayData.cameraMaxZoomDistance = 99;
end

local function SetActorDisplayData(data, actorInfo, alternateFormActorInfo)
	data.actorScriptTag = actorInfo.scriptTag;
	data.posX = RoundToSignificantDigits(actorInfo.position.x, 1);
	data.posY = RoundToSignificantDigits(actorInfo.position.y, 1);
	data.posZ = RoundToSignificantDigits(actorInfo.position.z, 1);
	data.normalizedScale = actorInfo.normalizeScaleAggressiveness;

	data.alternateFormData = {};
	data.alternateFormData.actorScriptTag = alternateFormActorInfo.scriptTag;
	data.alternateFormData.posX = RoundToSignificantDigits(alternateFormActorInfo.position.x, 1);
	data.alternateFormData.posY = RoundToSignificantDigits(alternateFormActorInfo.position.y, 1);
	data.alternateFormData.posZ = RoundToSignificantDigits(alternateFormActorInfo.position.z, 1);
	data.alternateFormData.normalizedScale = alternateFormActorInfo.normalizeScaleAggressiveness;
end

local function GetDefaultActorInfo(modelSceneID, playerRaceName, playerRaceNameActorTag)
	local _, _, defaultActorIDs = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
	if #defaultActorIDs > 0 then
		local returnActorInfo;
		for i, defaultActorID in ipairs(defaultActorIDs) do
			local tempActorInfo = C_ModelInfo.GetModelSceneActorInfoByID(defaultActorID);
			
			if tempActorInfo.scriptTag == playerRaceNameActorTag then
				return tempActorInfo;
			end

			if tempActorInfo.scriptTag == playerRaceName then
				returnActorInfo = tempActorInfo;
			end
		end

		return returnActorInfo;
	end
end

function PerksProgram_TranslateDisplayInfo(perksVendorCategoryID, displayInfo)
	local newData = {};
	local modelSceneID = displayInfo.overrideModelSceneID or displayInfo.defaultModelSceneID;
	if modelSceneID then
		local _, cameraIDs, actorIDs, flags = C_ModelInfo.GetModelSceneInfoByID(modelSceneID);
		
		newData.sheatheWeapon = bit.band(flags, Enum.UIModelSceneFlags.SheatheWeapon) == Enum.UIModelSceneFlags.SheatheWeapon;
		newData.hideWeapon = bit.band(flags, Enum.UIModelSceneFlags.HideWeapon) == Enum.UIModelSceneFlags.HideWeapon;
		newData.autodress = bit.band(flags, Enum.UIModelSceneFlags.Autodress) == Enum.UIModelSceneFlags.Autodress;

		if actorIDs and #actorIDs > 0 then
			local actorInfo;
			actorInfo = C_ModelInfo.GetModelSceneActorInfoByID(actorIDs[1]);
			local actorDisplayInfo = actorInfo.modelActorDisplayID and C_ModelInfo.GetModelSceneActorDisplayInfoByID(actorInfo.modelActorDisplayID);

			newData.modelActorDisplayID = actorInfo.modelActorDisplayID;
			if actorDisplayInfo then
				newData.animationKitID = actorDisplayInfo.animationKitID;
				newData.animation = actorDisplayInfo.animation;
				newData.animationVariation = actorDisplayInfo.animationVariation;
				newData.animSpeed = actorDisplayInfo.animSpeed;
				newData.spellVisualKitID = actorDisplayInfo.spellVisualKitID;
			end
			
			local isTransmog = perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset;
			if isTransmog then -- transmogs need to try and find the default actor for their race and gender				
				displayInfo.defaultModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(perksVendorCategoryID);

				local useAlternateForm = false;
				local playerRaceName, playerRaceNameActorTag = PerksProgram_GetPlayerActorLabelTag(useAlternateForm);
				local defaultActorInfo = GetDefaultActorInfo(displayInfo.defaultModelSceneID, playerRaceName, playerRaceNameActorTag);
				if not defaultActorInfo then
					defaultActorInfo = actorInfo;
				end

				local alternateFormActorInfo;
				local hasAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
				if hasAlternateForm then
					useAlternateForm = true;
					playerRaceName, playerRaceNameActorTag = PerksProgram_GetPlayerActorLabelTag(useAlternateForm);
					alternateFormActorInfo = GetDefaultActorInfo(displayInfo.defaultModelSceneID, playerRaceName, playerRaceNameActorTag);
				end
				if not alternateFormActorInfo then
					alternateFormActorInfo = actorInfo;
				end
				SetActorDisplayData(newData, defaultActorInfo, alternateFormActorInfo);
			else
				SetActorDisplayData(newData, actorInfo, actorInfo);
			end
			newData.actorID = actorInfo.modelActorID;
			newData.yaw = RoundToSignificantDigits(math.deg(actorInfo.yaw), 1);
			newData.pitch = RoundToSignificantDigits(math.deg(actorInfo.pitch), 1);
			newData.roll = RoundToSignificantDigits(math.deg(actorInfo.roll), 1);
		else
			SetDefaultActorDisplayData(newData);
		end

		if cameraIDs and #cameraIDs > 0 then
			local cameraInfo = C_ModelInfo.GetModelSceneCameraInfoByID(cameraIDs[1]);
			newData.cameraID = cameraInfo.modelSceneCameraID;
			newData.cameraScriptTag = cameraInfo.scriptTag;
			newData.cameraTargetX = RoundToSignificantDigits(cameraInfo.target.x, 1);
			newData.cameraTargetY = RoundToSignificantDigits(cameraInfo.target.y, 1);
			newData.cameraTargetZ = RoundToSignificantDigits(cameraInfo.target.z, 1);
			newData.cameraYaw = RoundToSignificantDigits(math.deg(cameraInfo.yaw), 1);
			newData.cameraPitch = RoundToSignificantDigits(math.deg(cameraInfo.pitch), 1);
			newData.cameraRoll = RoundToSignificantDigits(math.deg(cameraInfo.roll), 1);
			newData.cameraZoomDistance = cameraInfo.zoomDistance;
			newData.cameraMinZoomDistance = cameraInfo.minZoomDistance;
			newData.cameraMaxZoomDistance = cameraInfo.maxZoomDistance;
		else
			SetDefaultCameraData(newData);
		end
	else
		SetDefaultActorDisplayData(newData);
		SetDefaultCameraData(newData);
	end
	newData.defaultModelSceneID = displayInfo.defaultModelSceneID;
	newData.overrideModelSceneID = displayInfo.overrideModelSceneID;
	newData.selectedModelSceneID = modelSceneID;
	newData.creatureDisplayInfoID = displayInfo.creatureDisplayInfoID;
	newData.mainHandItemModifiedAppearanceID = displayInfo.mainHandItemModifiedAppearanceID;
	newData.offHandItemModifiedAppearanceID = displayInfo.offHandItemModifiedAppearanceID;
	return newData;
end

local function PerksProgramProducts_PassFilterCheck(vendorItemInfo)
	if not vendorItemInfo then
		return false;
	end

	if not PerksProgramFrame:GetFilterState(vendorItemInfo.perksVendorCategoryID) then
		return false;
	end

	local useableRequired = PerksProgramFrame:GetFilterState("useable");
	if useableRequired then -- a useable is check is required
		local isUseable = C_PlayerInfo.CanUseItem(vendorItemInfo.itemID);
		if not isUseable then
			return false;
		end
	end

	local itemCollected = vendorItemInfo.purchased;

	local includeCollected = PerksProgramFrame:GetFilterState("collected");
	if includeCollected and itemCollected then
		return true;
	end

	local includeUncollected = PerksProgramFrame:GetFilterState("uncollected");
	if includeUncollected and not itemCollected then
		return true;
	end

	return false;
end

local function ProductSortComparator(lhs, rhs)
	local lhsGroupID = lhs.uiGroupInfo.ID;
	local rhsGroupID = rhs.uiGroupInfo.ID;
	local lhsGroupPriority = lhs.uiGroupInfo.priority;
	local rhsGroupPriority = rhs.uiGroupInfo.priority;

	-- If we have 2 different groups with the same priority then fallback on IDs for comparing which group goes first
	if (lhsGroupID ~= rhsGroupID) and (lhsGroupPriority == rhsGroupPriority) then
		lhsGroupPriority = lhsGroupID;
		rhsGroupPriority = rhsGroupID;
	end

	-- If we have 2 things with the same priority 
	-- Give headers higher priority than items under that header
	if lhsGroupPriority == rhsGroupPriority then
		lhsGroupPriority = lhs.isHeaderInfo and (lhsGroupPriority + 1) or lhsGroupPriority;
		rhsGroupPriority = rhs.isHeaderInfo and (rhsGroupPriority + 1) or rhsGroupPriority;
	end

	-- If entries have varrying group priorities or If both entries are headers
	-- Then prioritize the entry with the higher group priority
	if (lhsGroupPriority ~= rhsGroupPriority) or (lhs.isHeaderInfo and rhs.isHeaderInfo) then
		return lhsGroupPriority > rhsGroupPriority;
	end

	-- Past this point we know the two entries are both items in the same group
	local sortField = PerksProgramFrame:GetSortField();
	local lhsValue = lhs[sortField];
	local rhsValue = rhs[sortField];

	local sortByPrice = sortField == "price";
	local sortByTimeRemaining = sortField == "timeRemaining";

	if sortByPrice or sortByTimeRemaining then
		local huge = math.max(lhsValue, rhsValue) + 1000;
		local function GetSortValue(itemInfo, baseValue)
			if itemInfo.isPurchasePending then
				return sortByPrice and -1 or (huge - 2);
			elseif itemInfo.refundable then
				return sortByPrice and -2 or (huge - 1);
			elseif itemInfo.purchased then
				return sortByPrice and -3 or huge;
			else
				return baseValue;
			end
		end
		lhsValue = GetSortValue(lhs, lhsValue);
		rhsValue = GetSortValue(rhs, rhsValue);
	end

	if sortByTimeRemaining then
		-- Convert values to the largest different time value we actually care to compare
		local lhsTime = ConvertSecondsToUnits(lhsValue);
		local rhsTime = ConvertSecondsToUnits(rhsValue);
		if lhsTime.days ~= rhsTime.days then
			lhsValue = lhsTime.days;
			rhsValue = rhsTime.days;
		elseif lhsTime.hours ~= rhsTime.hours then
			lhsValue = lhsTime.hours;
			rhsValue = rhsTime.hours;
		else
			-- The smallest we want to compare against is mintutes since thats the lowest we show in UI
			lhsValue = lhsTime.minutes;
			rhsValue = rhsTime.minutes;
		end
	end

	local sortAscending = PerksProgramFrame:GetSortAscending();

	-- Fallback to sorting by name if our sortfield turns out to be equivalent
	if lhsValue == rhsValue then
		sortField = "name";
		sortAscending = PerksProgramFrame:GetDefaultSortAscending(sortField);
		lhsValue = lhs.name;
		rhsValue = rhs.name;
	end

	if sortAscending then
		return lhsValue < rhsValue;
	end

	return  lhsValue > rhsValue;
end

function PerksProgramProductsFrameMixin:UpdateProducts(resetSelection)
	local previouslySelectedProduct = self:GetSelectedProduct();

	local scrollContainer = self.ProductsScrollBoxContainer;
	scrollContainer.selectionBehavior:ClearSelections();

	local dataProvider = CreateDataProvider();
	local frozenItemInfo = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	local groupInfos = {};
	local numGroupInfos = 0;

	local function addItemToDataProvider(perksVendorID)
		local itemInfo = PerksProgramFrame:GetVendorItemInfo(perksVendorID);
		if not itemInfo then
			return;
		end

		-- Don't add items which are being filtered out
		if not PerksProgramProducts_PassFilterCheck(itemInfo) then
			return;
		end

		-- Don't add frozen item to item list
		-- It has it's own section of the UI it goes into
		if frozenItemInfo and frozenItemInfo.perksVendorItemID == itemInfo.perksVendorItemID then
			return;
		end

		-- Don't add items which don't have group info
		if not itemInfo.uiGroupInfo then
			return;
		end

		dataProvider:Insert(itemInfo);

		-- Don't add duplicate group infos
		if not groupInfos[itemInfo.uiGroupInfo.ID] then
			groupInfos[itemInfo.uiGroupInfo.ID] = itemInfo.uiGroupInfo;
			numGroupInfos = numGroupInfos + 1;
		end
	end

	local function addHeaderToDataProvider(groupInfo)
		local headerInfo = {};
		headerInfo.isHeaderInfo = true;
		headerInfo.uiGroupInfo = groupInfo;
		dataProvider:Insert(headerInfo);
	end

	-- Add all other items
	for _, vendorItemID in ipairs(PerksProgramFrame.vendorItemIDs) do
		addItemToDataProvider(vendorItemID);
	end

	-- Only add group headers if there is more than 1 group
	if numGroupInfos > 1 then
		for _, groupInfo in pairs(groupInfos) do
			addHeaderToDataProvider(groupInfo);
		end
	end

	dataProvider:SetSortComparator(ProductSortComparator);
	scrollContainer.ScrollBox:SetDataProvider(dataProvider);

	-- Update Frozen Product Button
	if frozenItemInfo then
		self.FrozenProductContainer:SetItemInfo(frozenItemInfo);
	else
		self.FrozenProductContainer:ClearItemInfo();
	end
	self.FrozenProductContainer:SetSelected(false);

	-- Try to preserve selection. If not select first product
	self.silenceSelectionSounds = true;
	if resetSelection or not previouslySelectedProduct or not self:TrySelectProduct(previouslySelectedProduct) then
		self:SelectFirstProduct();
	end
	self.silenceSelectionSounds = false;
end

function PerksProgramProductsFrameMixin:SortFieldSet()
	local dataProvider = self.ProductsScrollBoxContainer.ScrollBox:GetDataProvider();
	dataProvider:Sort();
end

function PerksProgramProductsFrameMixin:OnFilterChanged()
	self:UpdateProducts();
end

function PerksProgramProductsFrameMixin:GetSelectedProduct()
	return self.selectedProductInfo;
end

function PerksProgramProductsFrameMixin:SelectFirstProduct()
	self.ProductsScrollBoxContainer.selectionBehavior:SelectFirstElementData(IsElementDataItemInfo);
end

function PerksProgramProductsFrameMixin:SelectNextProduct()
	if self.FrozenProductContainer:IsSelected() then
		return;
	end

	local scrollContainer = self.ProductsScrollBoxContainer;
	local selectedElementData, index = scrollContainer.selectionBehavior:SelectNextElementData(IsElementDataItemInfo);
	if selectedElementData then
		self.ProductsScrollBoxContainer.ScrollBox:ScrollToNearest(index);
	end
end

function PerksProgramProductsFrameMixin:SelectPreviousProduct()
	if self.FrozenProductContainer:IsSelected() then
		return;
	end

	local scrollContainer = self.ProductsScrollBoxContainer;
	local selectedElementData, index = scrollContainer.selectionBehavior:SelectPreviousElementData(IsElementDataItemInfo);
	if selectedElementData then
		self.ProductsScrollBoxContainer.ScrollBox:ScrollToNearest(index);
	end
end

function PerksProgramProductsFrameMixin:AllDataRefresh(resetSelection)
	self:UpdateProducts(resetSelection);
end

function PerksProgramProductsFrameMixin:OnShow()
	local resetSelection = true;
	self:AllDataRefresh(resetSelection);
end

function PerksProgramProductsFrameMixin:TrySelectProduct(itemInfo)
	local frozenProductItemInfo = self.FrozenProductContainer:GetItemInfo();
	if frozenProductItemInfo and frozenProductItemInfo.perksVendorItemID == itemInfo.perksVendorItemID then
		self.FrozenProductContainer:SetSelected(true);
		return true;
	end

	local scrollContainer = self.ProductsScrollBoxContainer;
	local scrollBox = scrollContainer.ScrollBox;
	local _, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.perksVendorItemID == itemInfo.perksVendorItemID;
	end);
	if foundElementData then
		scrollContainer.selectionBehavior:SelectElementData(foundElementData);
		return true;
	end

	return false;
end

----------------------------------------------------------------------------------
-- PerksProgramCurrencyFrameMixin
----------------------------------------------------------------------------------
PerksProgramCurrencyFrameMixin = {};
function PerksProgramCurrencyFrameMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");
	self:RegisterEvent("CHEST_REWARDS_UPDATED_FROM_SERVER");

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
	self:UpdateCurrencyAmount();
	self.Icon:SetTexture(currencyInfo.iconFileID);

	self.GlowSpin:ClearAllPoints();
	self.GlowSpin:SetSize(128, 128);
	self.GlowSpin:SetPoint("CENTER", self.Icon, "CENTER", 0, 0);

	self.GlowPulse:ClearAllPoints();
	self.GlowPulse:SetSize(70, 70);
	self.GlowPulse:SetPoint("CENTER", self.Icon, "CENTER", 0, 0);
end

local RED_TEXT_CURRENCY_THRESHOLD = 0;
function PerksProgramCurrencyFrameMixin:UpdateCurrencyAmount()
	self.currencyAmount = C_PerksProgram.GetCurrencyAmount();
	local color = (self.currencyAmount >= RED_TEXT_CURRENCY_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = color:WrapTextInColorCode(self.currencyAmount);
	self.Text:SetText(text);
end

function PerksProgramCurrencyFrameMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		local vendorItemID = ...;
		self:UpdateCurrencyAmount();
	elseif event == "CHEST_REWARDS_UPDATED_FROM_SERVER" then
		self.pendingChestRewards = C_PerksProgram.GetPendingChestRewards();
		local hasPendingRewards = self.pendingChestRewards and #self.pendingChestRewards > 0;
		self:UpdateCurrencyIcon(hasPendingRewards);
	end
end

function PerksProgramCurrencyFrameMixin:UpdateCurrencyIcon(hasPendingRewards)
	if hasPendingRewards then
		self.GlowSpin.SpinAnim:Play();
		self.GlowPulse.PulseAnim:Play();
		self.GlowSpin:Show();
		self.GlowPulse:Show();
	else
		self.GlowSpin.SpinAnim:Stop();
		self.GlowPulse.PulseAnim:Stop();
		self.GlowSpin:Hide();
		self.GlowPulse:Hide();
	end
end

local function HasTenderToRetrieve(pendingRewards)
	if not pendingRewards then
		return false;
	end

	for i, pendingReward in ipairs(pendingRewards) do
		local hasTender = pendingReward.rewardAmount and pendingReward.rewardAmount > 0;
		if hasTender then		
			return true;
		end
	end
	return false;
end

local function PerksActivitiesHasUnearned()
	local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();

	local earnedThresholdAmount = 0;
	for _, activityInfo in pairs(activitiesInfo.activities) do
		if activityInfo.completed then
			earnedThresholdAmount = earnedThresholdAmount + activityInfo.thresholdContributionAmount;
		end
	end

	local totalThresholdAmount = 0;
	for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
		totalThresholdAmount = math.max(totalThresholdAmount, thresholdInfo.requiredContributionAmount);
	end

	return earnedThresholdAmount < totalThresholdAmount;
end

function PerksProgramCurrencyFrameMixin:OnEnter()
	self.tooltip:SetOwner(self.Icon, "ANCHOR_BOTTOMRIGHT", 0, 0);
	self.tooltip:SetCurrencyByID(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);

	if self.currencyAmount < 0 then
		GameTooltip_AddNormalLine(self.tooltip, PERKS_PROGRAM_NEGATIVE_TENDER);
	end

	if HasTenderToRetrieve(self.pendingChestRewards) then
		GameTooltip_AddBlankLineToTooltip(self.tooltip);
		GameTooltip_AddNormalLine(self.tooltip, PERKS_PROGRAM_UNCOLLECTED_TENDER);
	end

	if PerksActivitiesHasUnearned() then
		GameTooltip_AddBlankLineToTooltip(self.tooltip);
		GameTooltip_AddNormalLine(self.tooltip, PERKS_PROGRAM_ACTIVITIES_UNEARNED);
	end
	self.tooltip:Show();
end

function PerksProgramCurrencyFrameMixin:OnLeave()
	self.tooltip:Hide();
end

----------------------------------------------------------------------------------
-- Frozen product container
----------------------------------------------------------------------------------
FrozenProductContainerMixin = {};

function FrozenProductContainerMixin:OnLoad()
	-- Override the product button's methods so they run through this frame first so even internal calls will go through us
	self.ProductButton.SetItemInfo = function(frame, itemInfo) self:SetItemInfo(itemInfo) end;
	self.ProductButton.SetupFreezeDraggedItem = function(frame) self:SetupFreezeDraggedItem() end;
	self.ProductButton.FreezeDraggedItem = function(frame) self:FreezeDraggedItem() end;

	-- Resize button stuff to better fit the bigger button
	local productIcon = self.ProductButton.ContentsContainer.Icon;
	productIcon:SetSize(64, 64);
	productIcon:ClearAllPoints();
	productIcon:SetPoint("LEFT", productIcon:GetParent(), "LEFT", 32, 0);

	local iconMask = self.ProductButton.ContentsContainer.IconMask;
	iconMask:SetSize(95, 95);

	local productLabel = self.ProductButton.ContentsContainer.Label;
	productLabel:SetSize(233, 45);

	local celebrationAnim = self.ProductButton.CelebrateAnimation;
	celebrationAnim.Highlight:SetSize(526, 84);
	celebrationAnim.Border:SetSize(526, 84);
	celebrationAnim.IconGlow:SetSize(94, 94);
	celebrationAnim.IconGlow:ClearAllPoints();
	celebrationAnim.IconGlow:SetPoint("CENTER", productIcon, "CENTER");
	celebrationAnim.Spark:SetSize(36, 22);
	celebrationAnim.Spark:ClearAllPoints();
	celebrationAnim.Spark:SetPoint("CENTER", celebrationAnim, "CENTER", -270, 40);
	celebrationAnim.Lines:SetSize(340, 80);
	celebrationAnim.Lines:ClearAllPoints();
	celebrationAnim.Lines:SetPoint("CENTER", celebrationAnim, "CENTER", -92, 0);
	celebrationAnim.Glow:SetHeight(84);
	celebrationAnim.GlowMask:SetSize(622, 879);
	celebrationAnim.GlowMask:ClearAllPoints();
	celebrationAnim.GlowMask:SetPoint("CENTER", celebrationAnim, "CENTER", -92, 0);
	celebrationAnim.HighlightMask:SetSize(526, 879);
end

function FrozenProductContainerMixin:Init(onSelectedCallback)
	self.ProductButton:Init(onSelectedCallback);
end

function FrozenProductContainerMixin:SetItemInfo(itemInfo)
	PerksProgramFrozenProductButtonMixin.SetItemInfo(self.ProductButton, itemInfo);

	self:ShowFreezeBG(not self.ProductButton.isPendingFreezeItem);
end

function FrozenProductContainerMixin:ClearItemInfo()
	if self:GetItemInfo() then
		self.UnfreezeAnim:Restart();
	end

	self.ProductButton:ClearItemInfo();
end

function FrozenProductContainerMixin:GetItemInfo()
	return self.ProductButton:GetItemInfo();
end

function FrozenProductContainerMixin:SetSelected(selected)
	return self.ProductButton:SetSelected(selected);
end

function FrozenProductContainerMixin:IsSelected()
	return self.ProductButton:IsSelected();
end

function FrozenProductContainerMixin:SetupFreezeDraggedItem()
	-- User could trigger an override while the freeze anims are still playing out.
	self.ConfirmedBackgroundFreezeAnim:Stop();

	PerksProgramFrozenProductButtonMixin.SetupFreezeDraggedItem(self.ProductButton);

	-- Only show pending freeze anim if we are still asking the player if they want to freeze the item
	if StaticPopup_Visible("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM") then
		self.PendingFreezeAnim:Restart();
	end
end

function FrozenProductContainerMixin:FreezeDraggedItem()
	PerksProgramFrozenProductButtonMixin.FreezeDraggedItem(self.ProductButton);

	self.ConfirmedBackgroundFreezeAnim:Restart();
end

-- Only pieces that stay visible once the related animation would be complete.
function FrozenProductContainerMixin:ShowFreezeBG(show)
	self.FrostBG:SetAlpha(show and .35 or 0);
	self.FrostLabelBG:SetAlpha(show and .22 or 0);
end
