local NO_SPEC_FILTER = 0;
local NO_CLASS_FILTER = 0;
local NO_INV_TYPE_FILTER = 0;

--=================================================================================================================================== 
LootJournalItemsMixin = { };

function LootJournalItemsMixin:OnLoad()
	self:SetView(LOOT_JOURNAL_ITEM_SETS);
	self:RegisterEvent("LOOT_JOURNAL_ITEM_UPDATE");
	local _, _, classID = UnitClass("player");
	local specID = GetSpecializationInfo(GetSpecialization());
	self:SetClassAndSpecFilters(classID, specID);
end

function LootJournalItemsMixin:SetClassAndSpecFilters(classID, specID)
	self.classFilter = classID;
	self.specFilter = specID;
end

function LootJournalItemsMixin:GetClassAndSpecFilters()
	return self.classFilter or NO_CLASS_FILTER, self.specFilter or NO_SPEC_FILTER;
end

function LootJournalItemsMixin:OnEvent(event)
	if ( event == "LOOT_JOURNAL_ITEM_UPDATE" ) then
		self:Refresh();
	end
end

function LootJournalItemsMixin:SetView(view)
	if ( self.view == view ) then
		return;
	end

	self.view = view;
	self.ItemSetsFrame:Show();
end

function LootJournalItemsMixin:GetActiveList()
	return self.ItemSetsFrame;
end

function LootJournalItemsMixin:Refresh()
	self:GetActiveList():Refresh();
end

function LootJournalItemButtonTemplate_OnEnter(self)
	local listFrame = self:GetParent();
	while ( listFrame and not listFrame.ShowItemTooltip ) do
		listFrame = listFrame:GetParent();
	end
	if ( listFrame ) then
		listFrame:ShowItemTooltip(self);
		self:SetScript("OnUpdate", LootJournalItemButton_OnUpdate);
		self.UpdateTooltip = LootJournalItemButtonTemplate_OnEnter;
	end
end

function LootJournalItemButtonTemplate_OnLeave(self)
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();
end

--=================================================================================================================================== 
LootJournalItemSetsMixin = {}

local LJ_ITEMSET_X_OFFSET = 10;
local LJ_ITEMSET_Y_OFFSET = 29;
local LJ_ITEMSET_BUTTON_SPACING = 13;
local LJ_ITEMSET_BOTTOM_BUFFER = 4;

function LootJournalItemSetsMixin:Refresh()
	self.dirty = true;
	local offset = self.scrollBar:GetValue();
	if ( offset == 0 ) then
		self:UpdateList();
	else
		self.scrollBar:SetValue(0);
	end
	if ( self.ClassButton ) then
		self:UpdateClassButtonText();
	end
	if ( self.SlotButton ) then
		self:UpdateSlotButtonText();
	end
end

function LootJournalItemSetsMixin:GetClassAndSpecFilters()
	return self:GetParent():GetClassAndSpecFilters();
end

function LootJournalItemSetsMixin:GetPreviewClassAndSpec()
	local classID, specID = self:GetClassAndSpecFilters();
	if specID == 0 then
		local spec = GetSpecialization();
		if spec and classID == select(3, UnitClass("player")) then
			specID = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"));
		else
			specID = -1;
		end
	end
	return classID, specID;
end

function LootJournalItemSetsMixin:UpdateClassButtonText()
	local text;
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	if classFilter == NO_CLASS_FILTER then
		text = ALL_CLASSES;
	else
		if specFilter == NO_SPEC_FILTER then
			local classInfo = C_CreatureInfo.GetClassInfo(classFilter);
			if not classInfo then
				return;
			end

			text = classInfo.className;
		else
			text = GetSpecializationNameForSpecID(specFilter);
		end
	end
	self.ClassButton:SetText(text);
end

function LootJournalItemSetsMixin:ShowItemTooltip(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	-- itemLink may not be available until after a GET_ITEM_INFO_RECEIVED event
	if ( button.itemLink ) then
		local classID, specID = self:GetPreviewClassAndSpec();
		GameTooltip:SetHyperlink(button.itemLink, classID, specID);
	else
		GameTooltip:SetItemByID(button.itemID);
	end
	self.tooltipItemID = button.itemID;
	GameTooltip_ShowCompareItem();
end

function LootJournalItemSetsMixin:CheckItemButtonTooltip(button)
	if ( GameTooltip:GetOwner() == button and self.tooltipItemID ~= button.itemID ) then
		self:ShowItemTooltip(button);
	end
end

function LootJournalItemSetsMixin:GetClassFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return classFilter;
end

function LootJournalItemSetsMixin:GetSpecFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return specFilter;
end

function LootJournalItemSetsMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	if not self.classAndSpecFiltersSet or classFilter ~= newClassFilter or specFilter ~= newSpecFilter then
		-- if choosing just a class without a spec, pick a spec
		if newClassFilter ~= NO_CLASS_FILTER and newSpecFilter == NO_SPEC_FILTER then
			local _, _, classID = UnitClass("player");
			-- if player's class, choose active spec
			-- otherwise use 1st spec
			if classID == newClassFilter then
				newSpecFilter = GetSpecializationInfo(GetSpecialization());
			else
				local sex = UnitSex("player");
				newSpecFilter = GetSpecializationInfoForClassID(newClassFilter, 1, sex);
			end
		end
		self:GetParent():SetClassAndSpecFilters(newClassFilter, newSpecFilter);
		self.scrollBar:SetValue(0);
		self:Refresh();
	end

	CloseDropDownMenus(1);
	self.classAndSpecFiltersSet = true;
end

do
	function LootJournalItemButton_OnUpdate(self)
		if GameTooltip:IsOwned(self) then
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end	
	end

	local function OpenClassFilterDropDown(self, level)
		if level then
			self:GetParent():GetActiveList():OpenClassFilterDropDown(level);
		end
	end

	function LootJournalItemsClassDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenClassFilterDropDown, "MENU");
	end

	local CLASS_DROPDOWN = 1;

	function LootJournalItemSetsMixin:OpenClassFilterDropDown(level)
		local filterClassID = self:GetClassFilter();
		local filterSpecID = self:GetSpecFilter();

		local function SetClassAndSpecFilters(_, classFilter, specFilter)
			self:SetClassAndSpecFilters(classFilter, specFilter);
		end

		local info = UIDropDownMenu_CreateInfo();

		if UIDROPDOWNMENU_MENU_VALUE == CLASS_DROPDOWN then 
			info.text = ALL_CLASSES;
			info.checked = filterClassID == NO_CLASS_FILTER;
			info.arg1 = NO_CLASS_FILTER;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);

			local numClasses = GetNumClasses();
			for i = 1, numClasses do
				local classDisplayName, classTag, classID = GetClassInfo(i);
				info.text = classDisplayName;
				info.checked = filterClassID == classID;
				info.arg1 = classID;
				info.arg2 = NO_SPEC_FILTER;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end
		end

		if level == 1 then 
			info.text = CLASS;
			info.func =  nil;
			info.notCheckable = true;
			info.hasArrow = true;
			info.value = CLASS_DROPDOWN;
			UIDropDownMenu_AddButton(info, level);

			local classDisplayName, classTag, classID;
			if filterClassID ~= NO_CLASS_FILTER then
				classID = filterClassID;
				
				local classInfo = C_CreatureInfo.GetClassInfo(filterClassID);
				if classInfo then
					classDisplayName = classInfo.className;
					classTag = classInfo.classFile;
				end
			else
				classDisplayName, classTag, classID = UnitClass("player");
			end
			info.text = classDisplayName;
			info.notCheckable = true;
			info.arg1 = nil;
			info.arg2 = nil;
			info.func =  nil;
			info.hasArrow = false;
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = nil;
			local sex = UnitSex("player");
			for i = 1, GetNumSpecializationsForClassID(classID) do
				local specID, specName = GetSpecializationInfoForClassID(classID, i, sex);
				info.leftPadding = 10;
				info.text = specName;
				info.checked = filterSpecID == specID;
				info.arg1 = classID;
				info.arg2 = specID;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end

function LootJournalItemSetsMixin:OnLoad()
	local scrollBar = self.scrollBar;
	scrollBar.trackBG:SetAlpha(0.25);
	scrollBar:ClearAllPoints();
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -2, -16);
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -2, 17);

	self.update = LootJournalItemSetsMixin.UpdateList;	
	HybridScrollFrame_CreateButtons(self, "LootJournalItemSetButtonTemplate", LJ_ITEMSET_X_OFFSET, -LJ_ITEMSET_Y_OFFSET, "TOPLEFT", nil, nil, -LJ_ITEMSET_BUTTON_SPACING);
end

function LootJournalItemSetsMixin:OnShow()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	if not self.init then
		self.init = true;
		self:Refresh();
	end
end

function LootJournalItemSetsMixin:OnHide()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
end

function LootJournalItemSetsMixin:OnEvent(event, ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		for i = 1, #self.buttons do
			local itemButtons = self.buttons[i].ItemButtons;
			for j = 1, #itemButtons do
				if ( itemButtons[j].itemID == itemID ) then
					self:ConfigureItemButton(itemButtons[j]);
					return;
				end
			end
		end
	end
end

function LootJournalItemSetsMixin:ConfigureItemButton(button)
	local _, itemLink, itemQuality = GetItemInfo(button.itemID);
	button.itemLink = itemLink;
	itemQuality = itemQuality or Enum.ItemQuality.Epic;	-- sets are most likely rare
	if ( itemQuality == Enum.ItemQuality.Uncommon ) then
		button.Border:SetAtlas("loottab-set-itemborder-green", true);
	elseif ( itemQuality == Enum.ItemQuality.Rare ) then
		button.Border:SetAtlas("loottab-set-itemborder-blue", true);
	elseif ( itemQuality == Enum.ItemQuality.Epic ) then
		button.Border:SetAtlas("loottab-set-itemborder-purple", true);
	end
	button:GetParent().SetName:SetTextColor(GetItemQualityColor(itemQuality));
	self:CheckItemButtonTooltip(button);
end

function SortItemSetItems(entry1, entry2)
	local order1 = EJ_GetInvTypeSortOrder(entry1.invType);
	local order2 = EJ_GetInvTypeSortOrder(entry2.invType);
	if ( order1 ~= order2 ) then
		return order1 < order2;
	end
	if ( entry1.itemID and entry2.itemID ) then
		return entry1.itemID < entry2.itemID;
	end
	return true;
end

function LootJournalItemSetsMixin:UpdateList()
	if ( self.dirty ) then
		self.itemSets = C_LootJournal.GetItemSets(self:GetClassAndSpecFilters());
		self.dirty = nil;

		local SortItemSets = function(set1, set2)
			if ( set1.itemLevel ~= set2.itemLevel ) then
				return set1.itemLevel > set2.itemLevel;
			end
			local strCmpResult = strcmputf8i(set1.name, set2.name);
			if ( strCmpResult ~= 0 ) then
				return strCmpResult < 0;
			end
			return set1.setID > set2.setID;
		end
		table.sort(self.itemSets, SortItemSets);
	end

	local buttons = self.buttons;
	local offset = HybridScrollFrame_GetOffset(self);

	for i = 1, #buttons do
		local button = buttons[i];
		local index = offset + i;
		if ( index <= #self.itemSets ) then
			button:Show();
			button.SetName:SetText(self.itemSets[index].name);
			button.ItemLevel:SetFormattedText(ITEM_LEVEL, self.itemSets[index].itemLevel);
			local items = C_LootJournal.GetItemSetItems(self.itemSets[index].setID);
			table.sort(items, SortItemSetItems);
			for j = 1, #items do
				local itemButton = button.ItemButtons[j];
				if ( not itemButton ) then
					itemButton = CreateFrame("BUTTON", nil, button, "LootJournalItemSetItemButtonTemplate");
					itemButton:SetPoint("LEFT", button.ItemButtons[j-1], "RIGHT", 5, 0);
				end
				itemButton.Icon:SetTexture(items[j].icon);
				itemButton.itemID = items[j].itemID;
				itemButton:Show();
				self:ConfigureItemButton(itemButton);
			end
			for j = #items + 1, #button.ItemButtons do
				button.ItemButtons[j].itemID = nil;
				button.ItemButtons[j]:Hide();
			end
		else
			button:Hide();
		end
	end

	local totalHeight = #self.itemSets * buttons[1]:GetHeight() + (#self.itemSets - 1) * LJ_ITEMSET_BUTTON_SPACING + LJ_ITEMSET_Y_OFFSET + LJ_ITEMSET_BOTTOM_BUFFER;
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end