local TOYS_PER_PAGE = 18;
local TOY_FANFARE_MODEL_SCENE = 253;

function ToyBox_OnLoad(self)
	self.firstCollectedToyID = 0; -- used to track which toy gets the favorite helpbox
	self.autoPageToCollectedToyID = UIParent.autoPageToCollectedToyID or nil;
	self.newToys = UIParent.newToys or {};
	self.fanfareToys = {};

	self.fanfarePool = CreateFramePool("MODELSCENE", self, "NonInteractableWrappedModelSceneTemplate");

	ToyBox_UpdatePages();
	ToyBox_UpdateProgressBar(self);

	UIDropDownMenu_Initialize(self.toyOptionsMenu, ToyBoxOptionsMenu_Init, "MENU");

	self:RegisterEvent("TOYS_UPDATED");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");

	self.OnPageChanged = function(userAction)
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		ToyBox_UpdateButtons();
		if userAction and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING) then
			local helpTipInfo = {
				text = TOYBOX_MOUSEWHEEL_PAGING_HELP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				hideArrow = true,
				offsetX = 44,
			};
			HelpTip:Show(self, helpTipInfo, self.PagingFrame);
		end
	end
end

function ToyBox_OnEvent(self, event, itemID, new, fanfare)
	if ( event == "TOYS_UPDATED" ) then
		if (new) then
			self.autoPageToCollectedToyID = itemID;
			if ( not CollectionsJournal:IsShown() ) then
				CollectionsJournal_SetTab(CollectionsJournal, 3);
			end
		end

		if fanfare then
			self.fanfareToys[itemID] = true;
		end

		ToyBox_UpdatePages();
		ToyBox_UpdateProgressBar(self);
		ToyBox_UpdateButtons();

		if (new) then
			self.newToys[itemID] = true;
		end
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		ToyBox_UpdateButtons();
	end

end

function ToyBox_OnShow(self)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX, true);

	if(C_ToyBox.HasFavorites()) then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true);
		HelpTip:Hide(self, TOYBOX_FAVORITE_HELP);
	end

	CollectionsJournal:SetPortraitToAsset("Interface\\Icons\\Trade_Archaeology_ChestofTinyGlassAnimals");
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
	HelpTip:Hide(self, TOYBOX_MOUSEWHEEL_PAGING_HELP);
	ToyBox.PagingFrame:OnMouseWheel(value);
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
			HelpTip:Hide(ToyBox, TOYBOX_FAVORITE_HELP);
		end
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	info.text = CANCEL;
	info.func = nil;
	UIDropDownMenu_AddButton(info, level);
end

function ToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
	ToyBox.menuItemID = itemID;
	ToggleDropDownMenu(1, nil, ToyBox.toyOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

	local hasFanfare = ToyBox.fanfareToys[self.itemID] ~= nil;
	local isNew = ToyBox.newToys[self.itemID] ~= nil;
	if( isNew and not hasFanfare ) then
		ToyBox.newToys[self.itemID] = nil;
	end
	ToySpellButton_UpdateButton(self);
end

function ToySpellButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		if ( ToyBox.fanfareToys[self.itemID] ~= nil ) then
			ToyBox.fanfareToys[self.itemID] = false;
			ToyBox.newToys[self.itemID] = nil;

			if ( self.modelScene ) then
				local function OnFinishedCallback()
					C_ToyBoxInfo.ClearFanfare(self.itemID);
					ToySpellButton_UpdateButton(self);
				end
				self.modelScene:StartUnwrapAnimation(OnFinishedCallback);

				ToySpellButton_FadeInIcon(self);
			end
		else
			UseToy(self.itemID);
		end
	elseif ( button == "RightButton" ) then
		if (PlayerHasToy(self.itemID)) then
			ToyBox_ShowToyDropdown(self.itemID, self, 0, 0);
		end
	end
end

function ToySpellButton_FadeInIcon(self)
	self.iconTexture:SetAlpha(0.0);
	self.slotFrameCollected:SetAlpha(0.0);
	self.iconTexture:Show();
	self.slotFrameCollected:Show();

	local function ShowHighlightTexture()
		self.HighlightTexture:Show();
	end
	self.IconFadeIn:SetScript("OnFinished", ShowHighlightTexture);

	self.IconFadeIn:Play();
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
	local itemIndex = (ToyBox.PagingFrame:GetCurrentPage() - 1) * TOYS_PER_PAGE + self:GetID();
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

	local itemID, toyName, icon, isFavorite, hasFanfare = C_ToyBox.GetToyInfo(self.itemID);
	if (itemID == nil) or (toyName == nil) then
		return;
	end

	if ToyBox.fanfareToys[itemID] == nil and hasFanfare then
		ToyBox.fanfareToys[itemID] = true;
		ToyBox.newToys[self.itemID] = true;-- if it has fanfare, we also want to treat it as new
	end

	if string.len(toyName) == 0 then
		toyName = itemID;
	end

	if not ToyBox.newToys[self.itemID] then
		toyNewString:Hide();
		toyNewGlow:Hide();
	else
		toyNewString:Show();
		toyNewGlow:Show();
	end

	iconTexture:SetTexture(icon);
	iconTextureUncollected:SetTexture(icon);
	iconTextureUncollected:SetDesaturated(true);

	if not ToyBox.fanfareToys[itemID] then
		if self.modelScene then
			ToyBox.fanfarePool:Release(self.modelScene);
			self.modelScene = nil;
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

			if (ToyBox.firstCollectedToyID == self.itemID and not HelpTip:IsShowing(ToyBox, TOYBOX_FAVORITE_HELP) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE)) then
				local helpTipInfo = {
					text = TOYBOX_FAVORITE_HELP,
					buttonStyle = HelpTip.ButtonStyle.Close,
					cvarBitfield = "closedInfoFrames",
					bitfieldFlag = LE_FRAME_TUTORIAL_TOYBOX_FAVORITE,
					targetPoint = HelpTip.Point.BottomEdgeCenter,
					alignment = HelpTip.Alignment.Left,
					offsetY = 0,
				};
				HelpTip:Show(ToyBox, helpTipInfo, self);
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

		if (C_ToyBox.GetIsFavorite(itemID)) then
			iconFavoriteTexture:Show();
		else
			iconFavoriteTexture:Hide();
		end		
		CollectionsSpellButton_UpdateCooldown(self);
	else
		-- we are presenting fanfare
		if not self.modelScene then
			self.modelScene = ToyBox.fanfarePool:Acquire();
			self.modelScene:SetParent(self);
			self.modelScene:ClearAllPoints();
			self.modelScene:SetPoint("CENTER");
		end
		if self.modelScene then
			iconTexture:Hide();
			slotFrameCollected:Hide();
			slotFrameUncollected:Hide();
			iconTextureUncollected:Hide();
			toyString:SetTextColor(1, 0.82, 0, 1);
			self.cooldown:Hide();
			self.HighlightTexture:Hide();
			self.modelScene:TransitionToModelSceneID(TOY_FANFARE_MODEL_SCENE, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, true);
			self.modelScene:PrepareForFanfare(true);
			self.modelScene:Show();
		end
	end

	toyString:SetText(toyName);
	toyString:Show();
end

function ToyBox_UpdateButtons()
	HelpTip:Hide(ToyBox, TOYBOX_FAVORITE_HELP);
	for i = 1, TOYS_PER_PAGE do
	    local button = ToyBox.iconsFrame["spellButton"..i];
		ToySpellButton_UpdateButton(button);
	end
end

function ToyBox_UpdatePages()
	local maxPages = 1 + math.floor( math.max((C_ToyBox.GetNumFilteredToys() - 1), 0) / TOYS_PER_PAGE);
	ToyBox.PagingFrame:SetMaxPages(maxPages)
	if ToyBox.autoPageToCollectedToyID then
		local toyPage = ToyBox_FindPageForToyID(ToyBox.autoPageToCollectedToyID);
		if toyPage then
			ToyBox.PagingFrame:SetCurrentPage(toyPage);
		end
		ToyBox.autoPageToCollectedToyID = nil;
	end
end

function ToyBox_UpdateProgressBar(self)
	local maxProgress = C_ToyBox.GetNumTotalDisplayedToys();
	local currentProgress = C_ToyBox.GetNumLearnedDisplayedToys();

	self.progressBar:SetMinMaxValues(0, maxProgress);
	self.progressBar:SetValue(currentProgress);

	self.progressBar.text:SetFormattedText(TOY_PROGRESS_FORMAT, currentProgress, maxProgress);
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

function ToyBoxUpdateFilteredInformation()
	ToyBox.firstCollectedToyID = 0;
	ToyBox_UpdatePages();
	ToyBox_UpdateButtons();
end

function ToyBoxFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	if level == 1 then
		info.text = COLLECTED;
		info.func = function(_, _, _, value)
						C_ToyBox.SetCollectedShown(value);
						ToyBoxUpdateFilteredInformation();
					end
		info.checked = C_ToyBox.GetCollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = NOT_COLLECTED;
		info.func = function(_, _, _, value)
						C_ToyBox.SetUncollectedShown(value);
						ToyBoxUpdateFilteredInformation();
					end
		info.checked = C_ToyBox.GetUncollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.text = PET_JOURNAL_FILTER_USABLE_ONLY;
		info.func = function(_, _, _, value)
						C_ToyBox.SetUnusableShown(not value);
						ToyBoxUpdateFilteredInformation();
					end
		info.checked = not C_ToyBox.GetUnusableShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.checked = nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = SOURCES;
		info.value = 1;
		UIDropDownMenu_AddButton(info, level);

		info.text = EXPANSION_FILTER_TEXT;
		info.value = 2;
		UIDropDownMenu_AddButton(info, level);
	else
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL;
			info.func = function()
							C_ToyBox.SetAllSourceTypeFilters(true);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBoxUpdateFilteredInformation();
						end
			UIDropDownMenu_AddButton(info, level);

			info.text = UNCHECK_ALL;
			info.func = function()
							C_ToyBox.SetAllSourceTypeFilters(false);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBoxUpdateFilteredInformation();
						end
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = false;
			local numSources = C_PetJournal.GetNumPetSources();
			for i=1,numSources do
				if (i == 1 or i == 2 or i == 3 or i == 4 or i == 7 or i == 8) then -- Drop/Quest/Vendor/Profession/WorldEvent/Promotion
					info.text = _G["BATTLE_PET_SOURCE_"..i];
					info.func = function(_, _, _, value)
								C_ToyBox.SetSourceTypeFilter(i, value);
								ToyBoxUpdateFilteredInformation();
							end
					info.checked = function() return not C_ToyBox.IsSourceTypeFilterChecked(i) end;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
		if UIDROPDOWNMENU_MENU_VALUE == 2 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL;
			info.func = function()
							C_ToyBox.SetAllExpansionTypeFilters(true);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBoxUpdateFilteredInformation();
						end
			UIDropDownMenu_AddButton(info, level);

			info.text = UNCHECK_ALL;
			info.func = function()
							C_ToyBox.SetAllExpansionTypeFilters(false);
							UIDropDownMenu_Refresh(ToyBoxFilterDropDown, 1, 2);
							ToyBoxUpdateFilteredInformation();
						end
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = false;
			local numExpansions = GetNumExpansions();
			for i=1,numExpansions do
				info.text = _G["EXPANSION_NAME"..i-1]; --Since the global strings for expansion are 0 - Max Expansion
				info.func = function(_, _, _, value)
							C_ToyBox.SetExpansionTypeFilter(i, value);
							ToyBoxUpdateFilteredInformation();
						end
				info.checked = function() return not C_ToyBox.IsExpansionTypeFilterChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end
