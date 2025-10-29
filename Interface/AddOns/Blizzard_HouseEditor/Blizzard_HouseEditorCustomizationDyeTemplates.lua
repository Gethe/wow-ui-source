HousingDyePaneMixin = {};

function HousingDyePaneMixin:OnLoad()
	ClickToDragMixin.OnLoad(self);
	self.dyeSlotPool = CreateFramePool("FRAME", self.DyeSlotContainer, "HousingDecorDyeSlotTemplate", HousingDecorDyeSlotMixin.Reset);

	local function CloseDyePane()
		-- This will clear the preview dyes and close this pane by deselecting the decor
		C_HousingCustomizeMode.CancelActiveEditing();
	end

	self.ButtonFrame.ApplyButton:SetScript("OnClick", function()
		local anyChanges = C_HousingCustomizeMode.CommitDyesForSelectedDecor();
		if anyChanges then
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_APPLY_CHANGED);
		else
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_APPLY_NO_CHANGE);
		end

		DyeSelectionPopout:SetDyeSlotInfo(DyeSelectionPopout.dyeSlotInfo);
		CloseDyePane();
	end);

	self.ButtonFrame.CancelButton:SetScript("OnClick", CloseDyePane);
	self.CloseButton:SetScript("OnClick", CloseDyePane);

	self.dyeCostIcons = {};
	self.dyeCostFramePool = CreateFramePool("FRAME", self.DyeCostContainer, "HousingDyeCostIconTemplate");
end

function HousingDyePaneMixin:OnShow()
	self.currentChannel = nil;
end

function HousingDyePaneMixin:OnHide()
	DyeSelectionPopout:Hide();
	PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_CANCEL);
end

function HousingDyePaneMixin:SetDecorInfo(decorInstanceInfo)
	self.decorGUID = decorInstanceInfo.decorGUID;
	self.DecorName:SetText(decorInstanceInfo.name);
	local numDyesToSpend = C_HousingCustomizeMode.GetNumDyesToSpendOnSelectedDecor();
	local numDyesToRemove = C_HousingCustomizeMode.GetNumDyesToRemoveOnSelectedDecor();
	self.DyeRemoveWarning:SetText(numDyesToRemove == 0 and "" or string.format(HOUSING_DECOR_CUSTOMIZATION_REMOVE_DYE_WARNING, numDyesToRemove));

	self.dyeSlotFramesByChannel = {};
	local numDyeSlots = 1;
	for dyeSlotIndex, dyeSlotEntry in ipairs(decorInstanceInfo.dyeSlots) do
		local dyeSlotFrame = self.dyeSlotPool:Acquire();
		dyeSlotFrame.layoutIndex = dyeSlotEntry.orderIndex + 1;

		if numDyeSlots > #self.dyeCostIcons then
			local dyeCostFrame = self.dyeCostFramePool:Acquire();
			table.insert(self.dyeCostIcons, dyeCostFrame);
			local index = #self.dyeCostIcons;
			self.dyeCostIcons[index].layoutIndex = index + 1;
		end

		numDyeSlots = numDyeSlots + 1;

		local function onClickCallback()
			DyeSelectionPopout:SetDyeSlotInfo(dyeSlotEntry);
			DyeSelectionPopout:Show();
			if self.currentChannel ~= dyeSlotEntry.channel then
				PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_OPEN_COLOR_PALETTE);
			end

			if self.currentChannel then
				self.dyeSlotFramesByChannel[self.currentChannel].CurrentSwatch:UpdateSelected(false);
			end
			self.currentChannel = dyeSlotEntry.channel; 
			self.dyeSlotFramesByChannel[self.currentChannel].CurrentSwatch:UpdateSelected(true);
		end
		dyeSlotFrame:SetDyeSlotInfo(dyeSlotEntry, onClickCallback);
		dyeSlotFrame:Show();
		self.dyeSlotFramesByChannel[dyeSlotEntry.channel] = dyeSlotFrame;
	end

	local canAffordDyes = true;
	local dyesToSpend = self:GetPreviewDyeInfos();
	local dyeCounts = {};
	for i, dyeCostIcon in ipairs(self.dyeCostIcons) do
		local dyeInfo = dyesToSpend[i];
		if dyeInfo then
			dyeCounts[dyeInfo.itemID] = (dyeCounts[dyeInfo.itemID] or 0) + 1;

			local dyeIsValid = dyeCounts[dyeInfo.itemID] <= dyeInfo.numOwned;
			if not dyeIsValid then
				canAffordDyes = false;
			end

			dyeCostIcon:Init(dyeInfo.itemID, dyeInfo.numOwned, not dyeIsValid);
		else
			dyeCostIcon:Hide();
		end
	end

	self.DyeCostContainer:SetShown(#dyesToSpend > 0);
	self.DyeCostContainer:Layout();

	self.ButtonFrame.ApplyButton:SetEnabled((numDyesToRemove > 0 or #dyesToSpend > 0) and canAffordDyes);
	self.ButtonFrame.ApplyButton.disabledTooltip = not canAffordDyes and HOUSING_DECOR_DYE_NOT_ENOUGH_DYE or nil;
end

function HousingDyePaneMixin:UpdateDecorInfo(decorInstanceInfo)
	self.dyeSlotPool:ReleaseAll();
	self.DyeSlotContainer:MarkDirty();
	self:SetDecorInfo(decorInstanceInfo);

	if self.currentChannel then
		local currentFrame = self.dyeSlotFramesByChannel[self.currentChannel];
		DyeSelectionPopout:UpdateDyeSlotInfo(currentFrame.dyeSlotInfo);
		currentFrame.CurrentSwatch:UpdateSelected(true);
	end
end

function HousingDyePaneMixin:GetPreviewDyeInfos()
	if not self.ButtonFrame.CurrentDyeIcons then
		return;
	end
	
	local iconString = "";
	local currentDyes = {};
	local currPreviewDyes = C_HousingCustomizeMode.GetPreviewDyesOnSelectedDecor();
	for _i, dyeColorID in ipairs(currPreviewDyes) do
		local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
		if dyeColorInfo and dyeColorInfo.itemID then
			local itemID = dyeColorInfo.itemID;
			local dyeIcon = C_Item.GetItemIconByID(itemID);
			table.insert(currentDyes, {itemID = itemID, numOwned = dyeColorInfo.numOwned,});
		end
	end
	
	return currentDyes;
end

function HousingDyePaneMixin:ClearDecorInfo()
	self.dyeSlotFramesByChannel = nil;
	self.dyeSlotPool:ReleaseAll();
	self.decorGUID = nil;
	self.currentChannel = nil;
end

HousingDecorDyeSlotMixin = {};

function HousingDecorDyeSlotMixin:SetDyeSlotInfo(dyeSlotInfo, onClickCallback)
	self.dyeSlotInfo = dyeSlotInfo;
	local dyeColorCategory = C_DyeColor.GetDyeColorCategoryInfo(dyeSlotInfo.dyeColorCategoryID);

	self.Label:SetText(string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_SLOT_LABEL, self.layoutIndex));
	
	local dyeColorInfo = dyeSlotInfo.dyeColorID and C_DyeColor.GetDyeColorInfo(dyeSlotInfo.dyeColorID);
	local isSelected = false;
	self.CurrentSwatch:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
end

HousingDecorDyeSlotPopoutMixin = {};

function HousingDecorDyeSlotPopoutMixin:OnLoad()
	self.dyeSwatchPool = CreateFramePool("BUTTON", self.DyeSlotScrollBox.Contents.DyeSwatchContainer, "HousingDecorDyeSwatchTemplate", HousingDecorDyeSwatchMixin.Reset);
	self.recentSwatchPool = CreateFramePool("BUTTON", self.DyeSlotScrollBox.Contents.RecentlyUsedFrame.RecentlyUsedContainer, "HousingDecorDyeSwatchTemplate", HousingDecorDyeSwatchMixin.Reset)
	
	local view = CreateScrollBoxLinearView();
	ScrollUtil.InitScrollBoxWithScrollBar(self.DyeSlotScrollBox, self.DyeSlotScrollBar, view);
	view:SetPanExtent(20);
	self.ShowOnlyOwned:SetScript("OnClick", function() 
		if self.dyeSlotInfo then
			self:SetDyeSlotInfo(self.dyeSlotInfo);
		end

		PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_SHOW_ONLY_OWNED_CLICK);
	end);
end

function HousingDecorDyeSlotPopoutMixin:ReinitScrollBox()
	self.DyeSlotScrollBox.Contents.DyeSwatchContainer:MarkDirty();
	self.DyeSlotScrollBox.Contents.RecentlyUsedFrame.RecentlyUsedContainer:MarkDirty();
	C_Timer.After(0, function() self.DyeSlotScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately); end);
end

function HousingDecorDyeSlotPopoutMixin:UpdateDyeSlotInfo(dyeSlotInfo)
	self.dyeSlotInfo = dyeSlotInfo;

	local function updatePool(pool)
		for dyeSwatchFrame in pool:EnumerateActive() do
			local isSelected = (dyeSwatchFrame.dyeColorInfo and dyeSwatchFrame.dyeColorInfo.ID) == dyeSlotInfo.dyeColorID;
			dyeSwatchFrame:UpdateSelected(isSelected);
		end
	end

	updatePool(self.dyeSwatchPool);
	updatePool(self.recentSwatchPool);

	self:ReinitScrollBox();
end

local function sortDyesBySortOrder()
	return function(a, b)
		return a.sortOrder < b.sortOrder;
	end
end

function HousingDecorDyeSlotPopoutMixin:SetDyeSlotInfo(dyeSlotInfo)
	self.dyeSwatchPool:ReleaseAll();
	self.recentSwatchPool:ReleaseAll();
	self.dyeSlotInfo = dyeSlotInfo;

	local onClickCallback = GenerateClosure(self.OnSwatchClicked, self);

	do --recentSwatchPool
		local dyeColorIDs = C_HousingCustomizeMode.GetRecentlyUsedDyes();
		if #dyeColorIDs == 0 then
			self.DyeSlotScrollBox.Contents.RecentlyUsedFrame:Hide();
		else
			self.DyeSlotScrollBox.Contents.RecentlyUsedFrame:Show();
			for ind, dyeColorID in ipairs(dyeColorIDs) do
				local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
				local dyeSwatchFrame = self.recentSwatchPool:Acquire();
				dyeSwatchFrame.layoutIndex = #dyeColorIDs - ind;
				local isSelected = dyeColorInfo.ID == dyeSlotInfo.dyeColorID;
				dyeSwatchFrame:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
				dyeSwatchFrame:Show();
			end
		end
	end

	do --dyeSwatchPool
		local dyeColorInfos = {};
		local dyeColorIDs = C_DyeColor.GetAllDyeColors();
		local onlyOwned = self.ShowOnlyOwned:GetChecked();
		for _, dyeColorID in ipairs(dyeColorIDs) do
			local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeColorID);
			if dyeColorInfo and not (onlyOwned and dyeColorInfo.numOwned == 0) then
				tinsert(dyeColorInfos, dyeColorInfo);
			end
		end

		table.sort(dyeColorInfos, sortDyesBySortOrder());

		for dyeColorIndex, dyeColorInfo in ipairs(dyeColorInfos) do
			local dyeSwatchFrame = self.dyeSwatchPool:Acquire();
			dyeSwatchFrame.layoutIndex = dyeColorIndex + 1;
			local isSelected = dyeColorInfo.ID == dyeSlotInfo.dyeColorID;
			dyeSwatchFrame:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback);
			dyeSwatchFrame:Show();
		end

		local noDyeFrame = self.dyeSwatchPool:Acquire();
		noDyeFrame.layoutIndex = 1;
		local isSelected = not dyeSlotInfo.dyeColorID;
		noDyeFrame:SetDyeColorInfo(nil, isSelected, onClickCallback);
		noDyeFrame:Show();
	end

	self:ReinitScrollBox();
	
	self.DyeSlotScrollBar:ScrollToBegin();
end

function HousingDecorDyeSlotPopoutMixin.Reset(framePool, self)
	self.dyeSlotInfo = nil;
	self.dyeSwatchPool:ReleaseAll();
	self.recentSwatchPool:ReleaseAll();
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingDecorDyeSlotPopoutMixin:OnSwatchClicked(dyeSwatch)
	local selectedColorID = nil;
	if not dyeSwatch.isSelected then
		selectedColorID = dyeSwatch.dyeColorInfo and dyeSwatch.dyeColorInfo.ID;
	end

	C_HousingCustomizeMode.ApplyDyeToSelectedDecor(self.dyeSlotInfo.ID, selectedColorID);
end

HousingDecorDyeSwatchMixin = {};

function HousingDecorDyeSwatchMixin:SetDyeColorInfo(dyeColorInfo, isSelected, onClickCallback)
	self.dyeColorInfo = dyeColorInfo;
	self.onClickCallback = onClickCallback;
	if dyeColorInfo and dyeColorInfo.swatchColorStart and dyeColorInfo.swatchColorEnd then
		self.SwatchEmpty:Hide();
		self.SwatchStart:SetVertexColor(dyeColorInfo.swatchColorStart:GetRGB());
		self.SwatchEnd:SetVertexColor(dyeColorInfo.swatchColorEnd:GetRGB());
		self.SwatchStart:Show();
		self.SwatchEnd:Show();
		self.Highlight:Show();
	else
		self.SwatchStart:Hide();
		self.SwatchEnd:Hide();
		self.Highlight:Hide();
		self.SwatchEmpty:Show();
	end

	self:UpdateSelected(isSelected);
end

function HousingDecorDyeSwatchMixin:UpdateSelected(isSelected)
	self.isSelected = isSelected;
	self.SelectedBorder:SetShown(isSelected);
end

function HousingDecorDyeSwatchMixin.Reset(framePool, self)
	self.dyeColorInfo = nil;
	self.isSelected = false;
	self.onClickCallback = nil;
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingDecorDyeSwatchMixin:OnEnter()
	if self.dyeColorInfo then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_AddHighlightLine(GameTooltip, self.dyeColorInfo.name);
		GameTooltip_AddNormalLine(GameTooltip, string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED, self.dyeColorInfo.numOwned))
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DECOR_CUSTOMIZATION_DEFAULT_COLOR);
		GameTooltip:Show();
	end

	if not self.isCurrentSwatch then
		PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_HOVER);
	end
end

function HousingDecorDyeSwatchMixin:OnLeave()
	GameTooltip:Hide();
end

function HousingDecorDyeSwatchMixin:OnClick()
	if self.onClickCallback then
		self.onClickCallback(self);

		if not self.isCurrentSwatch then
			PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_SELECT);
		end
	end
end

HousingDyeCostIconMixin = {};

function HousingDyeCostIconMixin:Init(itemID, numOwned, unowned)
	self.itemID = itemID;
	self.numOwned = numOwned;
	self.coloredItemName = nil;

	if not itemID then
		self:Hide();
		return;
	end

	if not self.continuableContainer then
		self.continuableContainer = ContinuableContainer:Create();
	else
		self.continuableContainer:Cancel();
	end

	local item = Item:CreateFromItemID(self.itemID);
	self.continuableContainer:AddContinuable(item);

	self.continuableContainer:ContinueOnLoad(function()
		local itemIcon = item:GetItemIcon();
		local qualityColor = item:GetItemQualityColor().color;
		self.coloredItemName = qualityColor:WrapTextInColorCode(item:GetItemName());

		self.DyeIcon:SetTexture(itemIcon);
		local iconTint = unowned and DIM_RED_FONT_COLOR or WHITE_FONT_COLOR
		self.DyeIcon:SetVertexColor(iconTint:GetRGBA());
		self:Show();

		self:GetParent():MarkDirty();
	end);
end

function HousingDyeCostIconMixin:OnEnter()
	local tooltipMinWidth = 120;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.coloredItemName, nil, true);
	GameTooltip_AddColoredLine(GameTooltip, HOUSING_DYE_TOOLTIP_DESCRIPTION, BRIGHTBLUE_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddLine(string.format(HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED, self.numOwned));
	GameTooltip:SetMinimumWidth(tooltipMinWidth);
	GameTooltip:Show();
end

function HousingDyeCostIconMixin:OnLeave()
	GameTooltip_Hide();
end
