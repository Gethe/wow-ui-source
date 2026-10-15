CollectionsJournalTabMixin = CreateFromMixins(SidePanelTabButtonMixin);

function CollectionsJournalTabMixin:OnLoad()
	SidePanelTabButtonMixin.OnLoad(self);

	self:SetCustomOnMouseUpHandler(function(tab, button, upInside)
		if button == "LeftButton" and upInside then
			CollectionsJournal_ClickTab(self);
		end
	end);
end

function CollectionsJournalMixin:SetupTabs()
	for i, tab in ipairs(self.TabContainer.Tabs) do
		tab.Icon:SetTexture(self.TABS_DATA[i].icon);
	end
end

-- Start tab (LargeSideTabButtonTemplate) wrapper OVERRIDES --

function CollectionsJournal_SetTab_Internal(tabContainer, selectedTabID)
	if not tabContainer.Tabs then
		return;
	end

	for _, tab in ipairs(tabContainer.Tabs) do
		local isSelected = tab:GetID() == selectedTabID;
		tab:SetChecked(isSelected);
		if isSelected then
			tabContainer.selectedTab = selectedTabID;
		end
	end
end

function CollectionsJournal_GetTab_Internal(tabContainer)
	return tabContainer.selectedTab;
end

function CollectionsJournal_ShowTab_Internal(tabContainer, tabID)
	local tab = tabContainer.Tabs[tabID];
	tab:Show();
end

function CollectionsJournal_HideTab_Internal(tabContainer, tabID)
	local tab = tabContainer.Tabs[tabID];
	tab:Hide();
end

function CollectionsJournal_SetNumTabs_Internal(tabContainer, tab)
end

-- End tab (LargeSideTabButtonTemplate) wrapper OVERRIDES --
