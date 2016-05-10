local TOYS_PER_PAGE = 18;

function ToyBox_OnLoad(self)
	self.currentPage = 1;
	self.firstCollectedToyID = 0; -- used to track which toy gets the favorite helpbox
	self.mostRecentCollectedToyID = UIParent.mostRecentCollectedToyID or nil;
	self.newToys = UIParent.newToys or {};

	ToyBox_UpdatePages();
	ToyBox_UpdateProgressBar(self);

	UIDropDownMenu_Initialize(self.toyOptionsMenu, ToyBoxOptionsMenu_Init, "MENU");

	self:RegisterEvent("TOYS_UPDATED");
end

function ToyBox_OnEvent(self, event, itemID, new)
	if ( event == "TOYS_UPDATED" ) then
		if (new) then
			self.mostRecentCollectedToyID = itemID;
			if ( not CollectionsJournal:IsShown() ) then
				CollectionsJournal_SetTab(CollectionsJournal, 3);
			end
		end

		ToyBox_UpdatePages();
		ToyBox_UpdateProgressBar(self);
		ToyBox_UpdateButtons();

		if (new) then
			self.newToys[itemID] = true;
		end
	end
end

function ToyBox_OnShow(self)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX, true);

	if(C_ToyBox.HasFavorites()) then 
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true);
		self.favoriteHelpBox:Hide();
	end

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\Trade_Archaeology_ChestofTinyGlassAnimals");
	C_ToyBox.ForceToyRefilter();

	ToyBox_UpdatePages();	
	ToyBox_UpdateProgressBar(self);
	ToyBox_UpdateButtons();
end

function ToyBox_FindPageForToyID(toyID)
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		if C_ToyBox.GetToyFromIndex(i) == toyID then
			return math.floor((i - 1) / TOYS_PER_PAGE) + 1;
		end
	end

	return nil;
end

function ToyBox_OnMouseWheel(self, value)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING, true);
	self.mousewheelPagingHelpBox:Hide();
	if(value > 0) then
		ToyBoxPrevPageButton_OnClick()		
	else
		ToyBoxNextPageButton_OnClick()
	end
end

function ToyBoxOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.disabled = nil;

	local isFavorite = ToyBox.menuItemID and C_ToyBox.GetIsFavorite(ToyBox.menuItemID);

	if (isFavorite) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.func = function() 
			C_ToyBox.SetIsFavorite(ToyBox.menuItemID, false);
		end
	else
		info.text = BATTLE_PET_FAVORITE;
		info.func = function() 
			C_ToyBox.SetIsFavorite(ToyBox.menuItemID, true);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true);
			ToyBox.favoriteHelpBox:Hide();
		end
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;
	
	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function ToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)	
	ToyBox.menuItemID = itemID;
	ToggleDropDownMenu(1, nil, ToyBox.toyOptionsMenu, anchorTo, offsetX, offsetY);
end

function ToyBox_HideToyDropdown()
	if (UIDropDownMenu_GetCurrentDropDown() == ToyBox.toyOptionsMenu) then
		HideDropDownMenu(1);
	end
end

function ToySpellButton_OnShow(self)
	self:RegisterEvent("TOYS_UPDATED");

	CollectionsSpellButton_OnShow(self);
end

function ToySpellButton_OnHide(self)
	CollectionsSpellButton_OnHide(self);

	self:UnregisterEvent("TOYS_UPDATED");	
end

function ToySpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( GameTooltip:SetToyByItemID(self.itemID) ) then
		self.UpdateTooltip = ToySpellButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end

	if(ToyBox.newToys[self.itemID] ~= nil) then
		ToyBox.newToys[self.itemID] = nil;
		ToySpellButton_UpdateButton(self);
	end
end

function ToySpellButton_OnClick(self, button)
	if ( button ~= "LeftButton" ) then
		if (PlayerHasToy(self.itemID)) then
			ToyBox_ShowToyDropdown(self.itemID, self, 0, 0);
		end
	else
		UseToy(self.itemID);
	end
end

function ToySpellButton_OnModifiedClick(self, button) 
	if ( IsModifiedClick("CHATLINK") ) then
		local itemLink = C_ToyBox.GetToyLink(self.itemID);
		if ( itemLink ) then
			ChatEdit_InsertLink(itemLink);
		end
	end
end

function ToySpellButton_OnDrag(self) 	
	C_ToyBox.PickupToyBoxItem(self.itemID);
end

function ToySpellButton_UpdateButton(self)
	local itemIndex = (ToyBox_GetCurrentPage() - 1) * TOYS_PER_PAGE + self:GetID();
	self.itemID = C_ToyBox.GetToyFromIndex(itemIndex);

	local toyString = self.name;
	local toyNewString = self.new;
	local toyNewGlow = self.newGlow;
	local iconTexture = self.iconTexture;
	local iconTextureUncollected = self.iconTextureUncollected;
	local slotFrameCollected = self.slotFrameCollected;
	local slotFrameUncollected = self.slotFrameUncollected;
	local slotFrameUncollectedInnerGlow = self.slotFrameUncollectedInnerGlow;
	local iconFavoriteTexture = self.cooldownWrapper.slotFavorite;

	if (self.itemID == -1) then	
		self:Hide();		
		return;
	end

	self:Show();

	local itemID, toyName, icon = C_ToyBox.GetToyInfo(self.itemID);

	if (itemID == nil or toyName == nil) then
		return;
	end

	if string.len(toyName) == 0 then
		toyName = itemID;
	end

	iconTexture:SetTexture(icon);
	iconTextureUncollected:SetTexture(icon);
	iconTextureUncollected:SetDesaturated(true);
	toyString:SetText(toyName);	
	toyString:Show();

	if (ToyBox.newToys[self.itemID] ~= nil) then
		toyNewString:Show();
		toyNewGlow:Show();
	else
		toyNewString:Hide();
		toyNewGlow:Hide();
	end

	if (C_ToyBox.GetIsFavorite(itemID)) then
		iconFavoriteTexture:Show();
	else
		iconFavoriteTexture:Hide();
	end

	if (PlayerHasToy(self.itemID)) then
		iconTexture:Show();
		iconTextureUncollected:Hide();
		toyString:SetTextColor(1, 0.82, 0, 1);
		toyString:SetShadowColor(0, 0, 0, 1);
		slotFrameCollected:Show();
		slotFrameUncollected:Hide();
		slotFrameUncollectedInnerGlow:Hide();

		if(ToyBox.firstCollectedToyID == 0) then
			ToyBox.firstCollectedToyID = self.itemID;
		end

		if (ToyBox.firstCollectedToyID == self.itemID and not ToyBox.favoriteHelpBox:IsVisible() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE)) then
			ToyBox.favoriteHelpBox:Show();
			ToyBox.favoriteHelpBox:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -5, -20);
		end
	else
		iconTexture:Hide();
		iconTextureUncollected:Show();
		toyString:SetTextColor(0.33, 0.27, 0.20, 1);
		toyString:SetShadowColor(0, 0, 0, 0.33);
		slotFrameCollected:Hide();
		slotFrameUncollected:Show();		
		slotFrameUncollectedInnerGlow:Show();
	end

	CollectionsSpellButton_UpdateCooldown(self);
end

function ToyBox_GetCurrentPage()
	if (ToyBox.currentPage == nil) then ToyBox.currentPage = 1 end;

	return ToyBox.currentPage;
end

function ToyBox_UpdateButtons()
	ToyBox.favoriteHelpBox:Hide();
	for i = 1, TOYS_PER_PAGE do
	    local button = ToyBox.iconsFrame["spellButton"..i];
		ToySpellButton_UpdateButton(button);
	end	
end

function ToyBox_UpdatePages()
	local maxPages = 1 + math.floor( math.max((C_ToyBox.GetNumFilteredToys() - 1), 0) / TOYS_PER_PAGE);
	if ( maxPages == nil or maxPages == 0 ) then
		return;
	end
	if ToyBox.mostRecentCollectedToyID then
		local toyPage = ToyBox_FindPageForToyID(ToyBox.mostRecentCollectedToyID);
		if toyPage then
			ToyBox.currentPage = toyPage;
		end
		ToyBox.mostRecentCollectedToyID = nil;
	end

	if ( ToyBox.currentPage > maxPages ) then
		ToyBox.currentPage = maxPages;
		if ( ToyBox.currentPage == 1 ) then
			ToyBox.navigationFrame.prevPageButton:Disable();
		else
			ToyBox.navigationFrame.prevPageButton:Enable();
		end
		if ( ToyBox.currentPage == maxPages ) then
			ToyBox.navigationFrame.nextPageButton:Disable();
		else
			ToyBox.navigationFrame.nextPageButton:Enable();
		end
	end
	if ( ToyBox.currentPage == 1 ) then
		ToyBox.navigationFrame.prevPageButton:Disable();
	else
		ToyBox.navigationFrame.prevPageButton:Enable();
	end
	if ( ToyBox.currentPage == maxPages ) then
		ToyBox.navigationFrame.nextPageButton:Disable();
	else
		ToyBox.navigationFrame.nextPageButton:Enable();
	end

	ToyBox.navigationFrame.pageText:SetFormattedText(COLLECTION_PAGE_NUMBER, ToyBox.currentPage, maxPages);
end

function ToyBox_UpdateProgressBar(self)
	local maxProgress = C_ToyBox.GetNumTotalDisplayedToys();
	local currentProgress = C_ToyBox.GetNumLearnedDisplayedToys();

	self.progressBar:SetMinMaxValues(0, maxProgress);
	self.progressBar:SetValue(currentProgress);

	self.progressBar.text:SetFormattedText(TOY_PROGRESS_FORMAT, currentProgress, maxProgress);
end

function ToyBoxPrevPageButton_OnClick()
	if (ToyBox.currentPage > 1) then
		PlaySound("igAbiliityPageTurn");
		ToyBox.currentPage = math.max(1, ToyBox.currentPage - 1);
		ToyBox_UpdatePages();
		ToyBox_UpdateButtons();
	end
end

function ToyBoxNextPageButton_OnClick()
	local maxPages = 1 + math.floor( math.max((C_ToyBox.GetNumFilteredToys() - 1), 0) / TOYS_PER_PAGE);
	if (ToyBox.currentPage < maxPages) then
		-- show the mousewheel tip after the player's advanced a few pages
		if(ToyBox.currentPage > 2) then
			if(not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING) and GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE)) then
				ToyBox.mousewheelPagingHelpBox:Show();
			end
		end

		PlaySound("igAbiliityPageTurn");
		ToyBox.currentPage = ToyBox.currentPage + 1;
		ToyBox_UpdatePages();
		ToyBox_UpdateButtons();
	end
end

function ToyBox_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	local oldText = ToyBox.searchString;
	ToyBox.searchString = self:GetText();

	if ( oldText ~= ToyBox.searchString ) then		
		ToyBox.firstCollectedToyID = 0;
		C_ToyBox.SetFilterString(ToyBox.searchString);
		ToyBox_UpdatePages();
		ToyBox_UpdateButtons();
	end
end

function ToyBoxFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, ToyBoxFilterDropDown_Initialize, "MENU");
end

function ToyBoxFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;	

	if level == 1 then
		info.text = COLLECTED
		info.func = function(_, _, _, value)
						ToyBox.firstCollectedToyID = 0;
						C_ToyBox.SetCollectedShown(value);
						ToyBox_UpdatePages();
						ToyBox_UpdateButtons();
					end 
		info.checked = C_ToyBox.GetCollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
						ToyBox.firstCollectedToyID = 0;
						C_ToyBox.SetUncollectedShown(value);
						ToyBox_UpdatePages();
						ToyBox_UpdateButtons();
					end 
		info.checked = C_ToyBox.GetUncollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = SOURCES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
	else
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;				
		
			info.text = CHECK_ALL
			info.func = function()
							ToyBox.firstCollectedToyID = 0;
							C_ToyBox.SetAllSourceTypeFilters(true);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBox_UpdatePages();
							ToyBox_UpdateButtons();
						end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = UNCHECK_ALL
			info.func = function()
							ToyBox.firstCollectedToyID = 0;
							C_ToyBox.SetAllSourceTypeFilters(false);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBox_UpdatePages();
							ToyBox_UpdateButtons();
						end
			UIDropDownMenu_AddButton(info, level)
		
			info.notCheckable = false;
			local numSources = C_PetJournal.GetNumPetSources();
			for i=1,numSources do
				if (i == 1 or i == 2 or i == 3 or i == 4 or i == 7 or i == 8) then -- Drop/Quest/Vendor/Profession/WorldEvent/Promotion
					info.text = _G["BATTLE_PET_SOURCE_"..i];
					info.func = function(_, _, _, value)
								ToyBox.firstCollectedToyID = 0;
								C_ToyBox.SetSourceTypeFilter(i, value);
								ToyBox_UpdatePages();
								ToyBox_UpdateButtons();
							end
					info.checked = function() return not C_ToyBox.IsSourceTypeFilterChecked(i) end;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
	end
end
