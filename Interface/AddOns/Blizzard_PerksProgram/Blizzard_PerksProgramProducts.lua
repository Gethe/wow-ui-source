
----------------------------------------------------------------------------------
-- PerksProgramProductsFrameMixin
----------------------------------------------------------------------------------
PerksProgramProductsFrameMixin = {};
function PerksProgramProductsFrameMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH");
	self:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_REFUND_SUCCESS");
	self:RegisterEvent("PERKS_PROGRAM_SET_FROZEN_ITEM");
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
	EventRegistry:RegisterCallback("PerksProgram.SortFieldSet", self.SortFieldSet, self);
	EventRegistry:RegisterCallback("PerksProgram.AllDataRefresh", self.AllDataRefresh, self);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	self.currencyIconMarkup = CreateTextureMarkup(currencyInfo.iconFileID, 64, 64, 20, 20, 0, 1, 0, 1, 0, 0);

	local faction = UnitFactionGroup("player");
	if faction and (PLAYER_FACTION_GROUP[faction] == "Horde") then 		
		self.LeftBackgroundOverlay:SetAtlas("perks-gradient-orgrimmar-left");
		self.RightBackgroundOverlay:SetAtlas("perks-gradient-orgrimmar-right");
	else 
		self.LeftBackgroundOverlay:SetAtlas("perks-gradient-stormwind-left");
		self.RightBackgroundOverlay:SetAtlas("perks-gradient-stormwind-right");
	end
end

function PerksProgramProductsFrameMixin:Init()
	local scrollContainer = self.ProductsScrollBoxContainer;

	local ButtonHeight = 35;
	local DefaultPad = 0;
	local DefaultSpacing = 1;

	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
	view:SetElementInitializer("PerksProgramProductButtonTemplate", function(button, elementData)
		local isSelected = scrollContainer.selectionBehavior:IsElementDataSelected(elementData);
		PerksProgramFrame.playerCurrencyAmount = C_PerksProgram.GetCurrencyAmount();
		button:Init(elementData, self.currencyIconMarkup, isSelected, PerksProgramFrame.playerCurrencyAmount);
		button:SetScript("OnClick", function(button, buttonName)
			scrollContainer.selectionBehavior:ToggleSelect(button);
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(scrollContainer.ScrollBox, scrollContainer.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		local button = scrollContainer.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelection(selected);
		end
		if selected then
			EventRegistry:TriggerEvent("PerksProgramProductsFrame.OnProductSelected", elementData);
			EventRegistry:TriggerEvent("PerksProgram.OnProductCategoryChanged", elementData.perksVendorCategoryID);

			if not PerksProgramFrame.ProductsFrame.silenceSelectionSounds then
				PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_SELECT);
			end
		end
	end;
	scrollContainer.selectionBehavior = ScrollUtil.AddSelectionBehavior(scrollContainer.ScrollBox);
	scrollContainer.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFilterChanged", self.OnFilterChanged, self);
end

function PerksProgramProductsFrameMixin:ClearFrozenItemInProductList()
	local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
	local dataIndex, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.isFrozen == true;
	end);
	if foundElementData then
		foundElementData.isFrozen = false;
		local itemFrame = scrollBox:FindFrame(foundElementData);
		if itemFrame then
			local isSelected = self.ProductsScrollBoxContainer.selectionBehavior:IsElementDataSelected(foundElementData);
			itemFrame:Init(foundElementData, self.currencyIconMarkup, isSelected);
		end
	end
end

function PerksProgramProductsFrameMixin:SetFrozenItemInProductList(frozenVendorItemID)
	local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;

	local dataIndex, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.perksVendorItemID == frozenVendorItemID;
	end);
	if foundElementData then
		foundElementData.isFrozen = true;
		local itemFrame = scrollBox:FindFrame(foundElementData);
		if itemFrame then
			local isSelected = self.ProductsScrollBoxContainer.selectionBehavior:IsElementDataSelected(foundElementData);
			itemFrame:Init(foundElementData, self.currencyIconMarkup, isSelected);
		end
	end
end

function PerksProgramProductsFrameMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH" or event == "PERKS_PROGRAM_PURCHASE_SUCCESS" or event == "PERKS_PROGRAM_REFUND_SUCCESS" or event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		local vendorItemID = ...;
		local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
		local dataIndex, foundElementData = scrollBox:FindByPredicate(function(elementData)
			return elementData.perksVendorItemID == vendorItemID;
		end);

		local playCelebration = false;
		if dataIndex then
			local vendorItemInfo = C_PerksProgram.GetVendorItemInfo(vendorItemID);
			if(event == "PERKS_PROGRAM_PURCHASE_SUCCESS") then
				foundElementData.purchased = true;
				foundElementData.refundable = true;
				playCelebration = true;
				EventRegistry:TriggerEvent("PerksProgram.CelebratePurchase", vendorItemInfo);
			elseif(event == "PERKS_PROGRAM_REFUND_SUCCESS") then
				foundElementData.purchased = false;
				foundElementData.refundable = false;
			else
				foundElementData.purchased = vendorItemInfo.purchased;
				foundElementData.refundable = vendorItemInfo.refundable;
			end
			foundElementData.name = vendorItemInfo.name;
			foundElementData.description = vendorItemInfo.description;
			EventRegistry:TriggerEvent("PerksProgram.OnProductPurchasedStateChange", foundElementData);
		end
		PerksProgramFrame.playerCurrencyAmount = C_PerksProgram.GetCurrencyAmount();
		scrollBox:ForEachFrame(function(itemFrame, elementData)
			local isSelected = self.ProductsScrollBoxContainer.selectionBehavior:IsElementDataSelected(elementData);
			itemFrame:Init(elementData, self.currencyIconMarkup, isSelected, PerksProgramFrame.playerCurrencyAmount);		
		end);
		if playCelebration then
			local itemFrame = scrollBox:FindFrame(foundElementData);
			if itemFrame then
				itemFrame.CelebrateAnimation:Show();
				itemFrame.CelebrateAnimation.AlphaInAnimation:Play();
			end
		end
	elseif event == "PERKS_PROGRAM_SET_FROZEN_ITEM" then
		local dataProvider = self.ProductsScrollBoxContainer.ScrollBox:GetDataProvider();
		if dataProvider:GetSize() ~= 0 then
			local frozenVendorItemID = ...;
			self:ClearFrozenItemInProductList();
			if frozenVendorItemID > 0 then 
				self:SetFrozenItemInProductList(frozenVendorItemID);
			end
		 end
		 self:UpdateProducts();

		 self.silenceSelectionSounds = true;
		 self.ProductsScrollBoxContainer.selectionBehavior:SelectFirstElementData();
		 self.silenceSelectionSounds = false;
	end
end

local INTERVAL_UPDATE_SECONDS_TIME = 15.0;
local currentInterval = 0.0;
function PerksProgramProductsFrameMixin:OnUpdate(deltaTime)
	currentInterval = currentInterval + deltaTime;
	if currentInterval >= INTERVAL_UPDATE_SECONDS_TIME then
		local dataProvider = self.ProductsScrollBoxContainer.ScrollBox:GetDataProvider();
		dataProvider:ForEach(function(elementData)
			elementData.timeRemaining = C_PerksProgram.GetTimeRemaining(elementData.perksVendorItemID);
		end);
		self.ProductsScrollBoxContainer.ScrollBox:ForEachFrame(function(itemFrame, elementData)
			local endTime = elementData.isFrozen and "" or PerksProgramFrame:FormatTimeLeft(elementData.timeRemaining, PerksProgramFrame.TimeLeftListFormatter);
			itemFrame.ContentsContainer.TimeRemaining:SetText(endTime);
			itemFrame.ContentsContainer.FrozenIcon:SetShown(elementData.isFrozen);
		end);
		currentInterval = 0.0;
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
		for i, defaultActorID in ipairs(defaultActorIDs) do
			local tempActorInfo = C_ModelInfo.GetModelSceneActorInfoByID(defaultActorID);
			if tempActorInfo.scriptTag == playerRaceNameActorTag or tempActorInfo.scriptTag == playerRaceName then
				return tempActorInfo;
			end
		end
	end
end

function PerksProgram_TranslateDisplayInfo(perksVendorCategoryID, displayInfo)
	local newData = {};
	local modelSceneID = displayInfo.overrideModelSceneID or displayInfo.defaultModelSceneID;
	local creatureDisplayInfoID = displayInfo.creatureDisplayInfoID;
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
	newData.creatureDisplayInfoID = creatureDisplayInfoID;
	return newData;
end

local function BuildVendorItemInfo(vendorItemInfo)
	local perksVendorCategoryID = vendorItemInfo.perksVendorCategoryID;
	local displayInfo = C_PerksProgram.GetPerksProgramItemDisplayInfo(vendorItemInfo.perksVendorItemID);
	displayInfo.defaultModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(perksVendorCategoryID);
	vendorItemInfo.displayData = PerksProgram_TranslateDisplayInfo(perksVendorCategoryID, displayInfo);

	if perksVendorCategoryID == Enum.PerksVendorCategoryType.Mount then
		vendorItemInfo.creatureDisplays = C_MountJournal.GetAllCreatureDisplayIDsForMountID(vendorItemInfo.mountID);
	end
end

local function PerksProgramProducts_PassFilterCheck(vendorItemInfo)
	if not vendorItemInfo then
		return false;
	end

	if not PerksProgramFrame:GetFilterState(vendorItemInfo.perksVendorCategoryID) then
		return false;
	end

	local collectedRequired = PerksProgramFrame:GetFilterState("collected");
	local uncollectedRequired = PerksProgramFrame:GetFilterState("uncollected");
	local useableRequired = PerksProgramFrame:GetFilterState("useable");
	local itemCollected = vendorItemInfo.purchased;

	if useableRequired then -- a useable is check is required
		local isUseable = C_PlayerInfo.CanUseItem(vendorItemInfo.itemID);
		if not isUseable then
			return false;
		end
	end

	if collectedRequired and not itemCollected and not uncollectedRequired then
		return false;
	end

	if uncollectedRequired and itemCollected and not collectedRequired then
		return false;
	end
	return true;
end

function PerksProgramProductsFrameMixin:UpdateProducts()
	local scrollContainer = self.ProductsScrollBoxContainer;
	scrollContainer.selectionBehavior:ClearSelections();
	local dataProvider = CreateDataProvider();

	local frozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();	
	local frozenVendorItemInList = false;

	for i, vendorItemID in ipairs(PerksProgramFrame.vendorItemIDs) do
		local vendorItemInfo = C_PerksProgram.GetVendorItemInfo(vendorItemID);
		if PerksProgramProducts_PassFilterCheck(vendorItemInfo) then			
			BuildVendorItemInfo(vendorItemInfo);

			if frozenVendorItemInfo and frozenVendorItemInfo.perksVendorItemID == vendorItemID then
				vendorItemInfo.isFrozen = true;
				frozenVendorItemInList = true;
			end
			dataProvider:Insert(vendorItemInfo);
		end
	end

	if frozenVendorItemInfo and not frozenVendorItemInList then		
		local categoryID = frozenVendorItemInfo.perksVendorCategoryID;
		if PerksProgramFrame:GetFilterState(categoryID) then
			frozenVendorItemInfo.isFrozen = true;
			BuildVendorItemInfo(frozenVendorItemInfo);
			if PerksProgramProducts_PassFilterCheck(frozenVendorItemInfo) then
				dataProvider:Insert(frozenVendorItemInfo);
			end
		end
	end

	local function SortComparator(lhs, rhs)
		-- Frozen items are always first.
		if lhs.isFrozen then
			return true;
		elseif rhs.isFrozen then
			return false;
		end

		local sortField = PerksProgramFrame:GetSortField();
		local sortAscending = PerksProgramFrame:GetSortAscending();
		if sortAscending then
			return lhs[sortField] < rhs[sortField];
		else
			return lhs[sortField] > rhs[sortField];
		end
	end
	dataProvider:SetSortComparator(SortComparator);
	scrollContainer.ScrollBox:SetDataProvider(dataProvider);
end

function PerksProgramProductsFrameMixin:SortFieldSet()
	local dataProvider = self.ProductsScrollBoxContainer.ScrollBox:GetDataProvider();
	dataProvider:Sort();
end

function PerksProgramProductsFrameMixin:OnFilterChanged()
	self:UpdateProducts();
	self.ProductsScrollBoxContainer.selectionBehavior:SelectFirstElementData();
end

function PerksProgramProductsFrameMixin:GetSelectedProducts()
	local scrollContainer = self.ProductsScrollBoxContainer;	
	return scrollContainer.selectionBehavior:GetFirstSelectedElementData();
end

function PerksProgramProductsFrameMixin:SelectNextProduct()
	local scrollContainer = self.ProductsScrollBoxContainer;	
	local selectedElementData, index = scrollContainer.selectionBehavior:SelectNextElementData();
	if selectedElementData then
		self.ProductsScrollBoxContainer.ScrollBox:ScrollToNearest(index);
	end
end

function PerksProgramProductsFrameMixin:SelectPreviousProduct()
	local scrollContainer = self.ProductsScrollBoxContainer;
	local selectedElementData, index = scrollContainer.selectionBehavior:SelectPreviousElementData();
	if selectedElementData then
		self.ProductsScrollBoxContainer.ScrollBox:ScrollToNearest(index);
	end
end

function PerksProgramProductsFrameMixin:AllDataRefresh()
	self:UpdateProducts();
	self.silenceSelectionSounds = true;
	self.ProductsScrollBoxContainer.selectionBehavior:SelectFirstElementData();
	self.silenceSelectionSounds = false;
end

function PerksProgramProductsFrameMixin:OnShow()
	self:AllDataRefresh();
end

function PerksProgramProductsFrameMixin:GetElementData(perksVendorItemID)
	local scrollBox = self.ProductsScrollBoxContainer.ScrollBox;
	local dataIndex, foundElementData = scrollBox:FindByPredicate(function(elementData)
		return elementData.perksVendorItemID == perksVendorItemID;
	end);

	return foundElementData;
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
		self.pendingRewards = C_PerksProgram.GetPendingChestRewards();
		local hasPendingRewards = self.pendingRewards and #self.pendingRewards > 0;
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

	if HasTenderToRetrieve(self.pendingRewards) then
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