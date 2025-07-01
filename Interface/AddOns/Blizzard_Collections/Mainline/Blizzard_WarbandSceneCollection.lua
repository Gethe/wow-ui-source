WarbandSceneJounalMixin = {};

local WarbandSceneTemplates = {
	["WARBAND_SCENE"] = { template = "WarbandSceneTemplate", initFunc = WarbandSceneEntryMixin.Init },
};

function WarbandSceneJounalMixin:OnLoad()
	self.IconsFrame.BGCornerTopLeft:Hide();
	self.IconsFrame.BGCornerTopRight:Hide();

	local icons = self.IconsFrame.Icons;
	icons:SetElementTemplateData(WarbandSceneTemplates);
	icons:SetPagingControls(icons.Controls.PagingControls);
	icons.Controls.PagingControls:SetOverridePagedContentFrame(icons);

	local showOwned = icons.Controls.ShowOwned;
	showOwned:SetWidth(showOwned.Checkbox:GetWidth() + showOwned.Text:GetWidth() + showOwned.Text.anchorSpacing);

	showOwned.Checkbox:SetScript("OnClick", function()
		self.activeSearchParams.ownedOnly = not self.activeSearchParams.ownedOnly;

		local entries = C_WarbandScene.SearchWarbandSceneEntries(self.activeSearchParams);
		local retainCurrentPage = true;
		self:SetJournalEntries(entries, retainCurrentPage);
	end);

	-- Initial filters
	self.activeSearchParams = {
		ownedOnly = false
	};

	self:RegisterEvent("WARBAND_SCENE_FAVORITES_UPDATED");
end

function WarbandSceneJounalMixin:OnShow()
	CollectionsJournal:SetPortraitAtlasRaw("campcollection-icon-camp");
	self:SetupJournalEntries();
end

function WarbandSceneJounalMixin:OnEvent(event, ...)
	if event == "WARBAND_SCENE_FAVORITES_UPDATED" then
		self:SetupJournalEntries();
	end
end

function WarbandSceneJounalMixin:SetupJournalEntries()
	local entries = C_WarbandScene.SearchWarbandSceneEntries(self.activeSearchParams);
	local retainCurrentPage = true;
	self:SetJournalEntries(entries, retainCurrentPage);
end

function WarbandSceneJounalMixin:SetJournalEntries(entries, retainCurrentPage)
	local journalElements = {};
	for _, entryID in ipairs(entries) do
		local element = {
			templateKey = "WARBAND_SCENE",
			warbandSceneID = entryID
		};
		table.insert(journalElements, element);
	end

	local journalData = {{elements = journalElements}};
	local dataProvider = CreateDataProvider(journalData);
	self.IconsFrame.Icons:SetDataProvider(dataProvider, retainCurrentPage);
end