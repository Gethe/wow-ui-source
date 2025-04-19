WarbandSceneGlueEntryMixin = CreateFromMixins(WarbandSceneEntryMixin);

function WarbandSceneGlueEntryMixin:OnClick(button)
	self.elementData.collectionsFrame:SelectWarbandScene(self.warbandSceneInfo.warbandSceneID);
end

function WarbandSceneGlueEntryMixin:Init(elementData)
	 WarbandSceneEntryMixin.Init(self, elementData);
	 local isSelected = self.elementData.collectionsFrame:GetSelectedStateForEntry(self.warbandSceneInfo.warbandSceneID);
	 self:SetSelectedState(isSelected);
end

function WarbandSceneGlueEntryMixin:SetSelectedState(isSelected)
	self:SetChecked(isSelected);
	self.HighlightTexture:SetAtlas(isSelected and "campcollection-frame-selected-hover" or "campcollection-frame-hover", TextureKitConstants.IgnoreAtlasSize);

	if isSelected then
		CharacterSelectUI.CollectionsFrame.GlueWarbandSceneJournal.ApplyButton:SetEnabled(self:GetIsOwned());
	end
end


GlueWarbandSceneJounalMixin = {
	ApplyForAllCheckboxWidthBuffer = 25;
};

local WarbandSceneTemplates = {
	["WARBAND_SCENE"] = { template = "WarbandSceneGlueTemplate", initFunc = WarbandSceneGlueEntryMixin.Init },
};

StaticPopupDialogs["CONFIRM_WARBAND_SCENES_APPLY_ALL"] = {
	text = WARBAND_SCENE_COLLECTION_APPLY_ALL_CONFIRM,
	button1 = ACCEPT,
	button2 = CANCEL,
    OnAccept = function ()
		CharacterSelectUI.CollectionsFrame.GlueWarbandSceneJournal:UpdateWarbandScenes();
    end,
	cover = true
};

function GlueWarbandSceneJounalMixin:OnLoad()
	self.IconsFrame.BGCornerTopLeft:Hide();
	self.IconsFrame.BGCornerTopRight:Hide();
	self.IconsFrame.BGCornerBottomLeft:Hide();
	self.IconsFrame.BGCornerBottomRight:Hide();

	self.GroupInfo = {};

	self.GroupDropdown:SetWidth(150);

	self.ApplyButton:SetScript("OnClick", function()
		-- If apply for all checkbox is set, confirm before saving.
		if self.ApplyForAllCheckbox:GetChecked() then
			GlueDialog_Show("CONFIRM_WARBAND_SCENES_APPLY_ALL");
		else
			self:UpdateWarbandScenes();
		end
	end);

	local applyForAllWidth = self.ApplyForAllCheckbox:GetWidth() + self.ApplyForAllCheckbox.Text:GetWidth() + self.ApplyForAllCheckboxWidthBuffer;
	self.ApplyForAllCheckbox:ClearAllPoints();
	self.ApplyForAllCheckbox:SetPoint("LEFT", self.ApplyButton, "LEFT", -applyForAllWidth, -3);

	self.IconsFrame.Icons:SetElementTemplateData(WarbandSceneTemplates);

	-- Initial filters
	self.activeSearchParams = {
		ownedOnly = false
	};

	local function OnCharacterSelectionUpdated()
		self.GroupInfo = CharacterSelectListUtil.GetGroupWarbandSceneInfo();
	end
	EventRegistry:RegisterCallback("CharacterSelectList.OnCharacterSelectionUpdated", OnCharacterSelectionUpdated);

	self:RegisterEvent("WARBAND_SCENE_FAVORITES_UPDATED");
end

function GlueWarbandSceneJounalMixin:OnShow()
	self.GroupInfo = CharacterSelectListUtil.GetGroupWarbandSceneInfo();

	self.ApplyForAllCheckbox:SetChecked(false);
	self.ApplyForAllCheckbox:SetShown(#self.GroupInfo > 1);

	self:SetupJournalDropdown();
	self:SetupJournalEntries();
end

function GlueWarbandSceneJounalMixin:OnEvent(event, ...)
	if event == "WARBAND_SCENE_FAVORITES_UPDATED" then
		self:SetupJournalEntries();
	end
end

function GlueWarbandSceneJounalMixin:SetupJournalDropdown()
	local function SetSelectedGroupInfo(groupID, warbandSceneID)
		self.selectedGroupInfo = {
			groupID = groupID,
			warbandSceneID = warbandSceneID
		}
	end

	local function IsSelected(index)
		return self.selectedGroupInfo and self.selectedGroupInfo.groupID == self.GroupInfo[index].groupID;
	end

	local function SetSelected(index)
		SetSelectedGroupInfo(self.GroupInfo[index].groupID, self.GroupInfo[index].warbandSceneID);

		if self.selectedGroupInfo then
			self.IconsFrame.Icons:GoToElementByPredicate(function(elementData)
				return elementData.warbandSceneID == self.selectedGroupInfo.warbandSceneID;
			end);

			-- Update selected states.
			self:SelectWarbandScene(self.selectedGroupInfo.warbandSceneID);
		end
	end

	-- Set initial selected dropdown entry based on current selected character. If they are in a group use that, if they are not select first entry.
	local selectedCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	local selectedElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(selectedCharacterID, elementData);
	end);

	self.selectedGroupInfo = nil;
	for _, groupInfo in ipairs(self.GroupInfo) do
		if self.selectedGroupInfo == nil then
			SetSelectedGroupInfo(groupInfo.groupID, groupInfo.warbandSceneID);
		end

		if selectedElementData and selectedElementData.isGroup and selectedElementData.groupID == groupInfo.groupID then
			SetSelectedGroupInfo(groupInfo.groupID, groupInfo.warbandSceneID);
			break;
		end
	end

	self.GroupDropdown:SetupMenu(function(region, rootDescription)
		rootDescription:SetTag("MENU_WARBAND_SCENE_GROUPS");

		for index, groupInfo in ipairs(self.GroupInfo) do
			rootDescription:CreateRadio(groupInfo.name, IsSelected, SetSelected, index);
		end
	end);
end

function GlueWarbandSceneJounalMixin:SetupJournalEntries()
	local entries = C_WarbandScene.SearchWarbandSceneEntries(self.activeSearchParams);
	local retainCurrentPage = true;
	self:SetJournalEntries(entries, retainCurrentPage);

	if self.selectedGroupInfo then
		self.IconsFrame.Icons:GoToElementByPredicate(function(elementData)
			return elementData.warbandSceneID == self.selectedGroupInfo.warbandSceneID;
		end);
	end
end

function GlueWarbandSceneJounalMixin:SetJournalEntries(entries, retainCurrentPage)
	local journalElements = {};

	-- In Glues, we have a 'Random' entry that shows first.
	local randomEntryElement = {
		templateKey = "WARBAND_SCENE",
		warbandSceneID = C_WarbandScene.GetRandomEntryID(),
		collectionsFrame = self
	};
	table.insert(journalElements, randomEntryElement);

	for _, entryID in ipairs(entries) do
		local element = {
			templateKey = "WARBAND_SCENE",
			warbandSceneID = entryID,
			collectionsFrame = self
		};
		table.insert(journalElements, element);
	end

	local journalData = {{elements = journalElements}};
	local dataProvider = CreateDataProvider(journalData);
	self.IconsFrame.Icons:SetDataProvider(dataProvider, retainCurrentPage);
end

function GlueWarbandSceneJounalMixin:UpdateWarbandScenes()
	if not self.selectedGroupInfo then
		return;
	end

	-- Only attempt to update things if the current scene is different (either on the selected group, or for all groups if applyForAllGroups)
	local applyForAllGroups = self.ApplyForAllCheckbox:GetChecked();
	local validToUpdate = false;
	for _, groupInfo in ipairs(self.GroupInfo) do
		if applyForAllGroups and self.selectedGroupInfo.warbandSceneID ~= groupInfo.warbandSceneID then
			validToUpdate = true;
			break;
		elseif not applyForAllGroups and self.selectedGroupInfo.groupID == groupInfo.groupID and self.selectedGroupInfo.warbandSceneID ~= groupInfo.warbandSceneID then
			validToUpdate = true;
			break;
		end
	end

	if not validToUpdate then
		return;
	end

	-- Save any moves before we update, so characters are in current positions for the scene update call.
	-- We save off the pending action to run after things finish updating.
	CharacterSelectListUtil.SaveCharacterOrder();
	CharacterSelectCharacterFrame:SetPendingGroupSceneUpdate(self.selectedGroupInfo.groupID, self.selectedGroupInfo.warbandSceneID, applyForAllGroups);
	CharacterSelectListUtil.GetCharacterListUpdate();
end

function GlueWarbandSceneJounalMixin:SelectWarbandScene(warbandSceneID)
	if not self.selectedGroupInfo then
		return;
	end

	self.selectedGroupInfo.warbandSceneID = warbandSceneID;

	for _, frame in ipairs(self.IconsFrame.Icons:GetFrames()) do
		local elementData = frame:GetElementData();
		local isSelected = self:GetSelectedStateForEntry(elementData.warbandSceneID);
		frame:SetSelectedState(isSelected);
	end
end

function GlueWarbandSceneJounalMixin:GetSelectedStateForEntry(warbandSceneID)
	return self.selectedGroupInfo and self.selectedGroupInfo.warbandSceneID == warbandSceneID;
end