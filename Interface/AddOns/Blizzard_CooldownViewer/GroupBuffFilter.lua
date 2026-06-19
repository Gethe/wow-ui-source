local function GetCurrentHiddenGroupBuffSpellIDs()
	-- Check persistent data first.
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	local layout = layoutManager and layoutManager:GetActiveLayout(Enum.CDMLayoutMode.AccessOnly);
	local hiddenGroupBuffs = layout and CooldownManagerLayout_GetHiddenGroupBuffs(layout);
	if hiddenGroupBuffs then
		return CopyTable(hiddenGroupBuffs);
	end

	-- Fall back to static data.
	local spellIDs = {};
	for _, item in ipairs(C_CooldownViewer.GetGroupBuffItems()) do
		if bit.band(item.flags, Enum.GroupBuffItemFlags.HideByDefault) ~= 0 then
			table.insert(spellIDs, item.spellID);
		end
	end
	return spellIDs;
end

local function GetCurrentVisualAlerts()
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	local layout = layoutManager and layoutManager:GetActiveLayout(Enum.CDMLayoutMode.AccessOnly);
	return (layout and CooldownManagerLayout_GetGroupBuffVisualAlerts(layout)) or {};
end

local function BuildGroupBuffItemLists()
	local hiddenGroupBuffSpellIDs = GetCurrentHiddenGroupBuffSpellIDs();
	local hiddenSet = {};
	for _, spellID in ipairs(hiddenGroupBuffSpellIDs) do
		hiddenSet[spellID] = true;
	end

	local shownBuffs = {};
	local hiddenBuffs = {};
	for _, item in ipairs(C_CooldownViewer.GetGroupBuffItems()) do
		if hiddenSet[item.spellID] then
			table.insert(hiddenBuffs, item);
		else
			table.insert(shownBuffs, item);
		end
	end
	return shownBuffs, hiddenBuffs;
end

local function SyncHiddenGroupBuffs()
	local hiddenGroupBuffSpellIDs = GetCurrentHiddenGroupBuffSpellIDs();
	C_UnitAuras.SetHiddenGroupBuffs(hiddenGroupBuffSpellIDs);
end

local function SyncGroupBuffVisualAlerts()
	local visualAlertsList = {};
	for spellID, visualValue in pairs(GetCurrentVisualAlerts()) do
		table.insert(visualAlertsList, { spellID = spellID, visualValue = visualValue });
	end
	C_UnitAuras.SetGroupBuffVisualAlerts(visualAlertsList);
end

local groupBuffSyncRegistrant = {};
EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
	SyncHiddenGroupBuffs();
	SyncGroupBuffVisualAlerts();
end, groupBuffSyncRegistrant);

GroupBuffFilterItemMixin = CreateFromMixins(CooldownViewerVisualAlertTargetMixin);

function GroupBuffFilterItemMixin:Init(groupBuffItem, section)
	self.groupBuffItem = groupBuffItem;
	self.section = section;
	self.dragLocked = false;
	self:RefreshData();
end

function GroupBuffFilterItemMixin:GetGroupBuffItem()
	return self.groupBuffItem;
end

function GroupBuffFilterItemMixin:GetSection()
	return self.section;
end

function GroupBuffFilterItemMixin:GetIcon()
	return self.Icon;
end

function GroupBuffFilterItemMixin:GetIconID()
	return self.groupBuffItem.iconID;
end

function GroupBuffFilterItemMixin:SetDragLocked(locked)
	self.dragLocked = locked;
	self:RefreshData();
end

function GroupBuffFilterItemMixin:IsDragLocked()
	return self.dragLocked;
end

function GroupBuffFilterItemMixin:GetPickupSound()
	return SOUNDKIT.UI_CURSOR_PICKUP_OBJECT;
end

function GroupBuffFilterItemMixin:RefreshData()
	self:GetIcon():SetTexture(self.groupBuffItem.iconID);
	self:GetIcon():SetDesaturated(not self.groupBuffItem.isKnown or self:IsDragLocked());

	self:RefreshAlertTypeOverlay();
end

function GroupBuffFilterItemMixin:GetVisualAlert()
	return GetCurrentVisualAlerts()[self.groupBuffItem.spellID];
end

function GroupBuffFilterItemMixin:GetAllAlertTypes()
	local hasVisualAlert = self:GetVisualAlert() ~= nil;
	if hasVisualAlert then
		local alertTypes = {Enum.CooldownViewerAlertType.Visual};
		return alertTypes;
	end
end

function GroupBuffFilterItemMixin:OnDragStart()
	PlaySound(self:GetPickupSound());
	self.section:GetFilter():BeginGroupBuffItemDrag(self);
end

function GroupBuffFilterItemMixin:OnMouseUp(button, upInside)
	if not upInside then
		return;
	end

	if button == "LeftButton" then
		PlaySound(self:GetPickupSound());
		local eatNextGlobalMouseUp = true;
		self.section:GetFilter():BeginGroupBuffItemDrag(self, eatNextGlobalMouseUp);
	elseif button == "RightButton" then
		self.section:GetFilter():DisplayContextMenu(self);
	end
end

function GroupBuffFilterItemMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.groupBuffItem.name, 1, 1, 1);
	GameTooltip:Show();
end

function GroupBuffFilterItemMixin:OnLeave()
	GameTooltip_Hide();
end

function GroupBuffFilterItemMixin:MatchesFilter(filterText)
	return filterText == "" or self.groupBuffItem.name:lower():find(filterText, 1, true) ~= nil;
end

function GroupBuffFilterItemMixin:PlayAlertSample()
	local visualValue = GetCurrentVisualAlerts()[self.groupBuffItem.spellID];
	local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Visual, Enum.CooldownViewerAlertEventType.Available, visualValue);
	local soundSubType = "Gameplay SFX";
	CooldownViewerAlert_PlayAlert(self, self.groupBuffItem.name, alert, soundSubType);
end

function GroupBuffFilterItemMixin:ApplyFilter(passesFilter)
	if passesFilter then
		if self.FilterOverlay then
			self.FilterOverlay:Hide();
		end
	else
		if not self.FilterOverlay then
			self.FilterOverlay = self:CreateTexture(nil, "OVERLAY", nil, 7);
			self.FilterOverlay:SetColorTexture(0, 0, 0, 0.8);
			self.FilterOverlay:SetAllPoints(self:GetIcon());
		end
		self.FilterOverlay:Show();
	end
end

GroupBuffFilterEditVisualAlertMixin = CreateFromMixins(CooldownViewerEditAlertBaseMixin);

function GroupBuffFilterEditVisualAlertMixin:OnLoad()
	CooldownViewerEditAlertBaseMixin.OnLoad(self);
	self.PrimaryLabel:SetText(GROUP_BUFF_FILTER_VISUAL_ALERT_DIALOG_LABEL_VISUAL_TYPE);
end

function GroupBuffFilterEditVisualAlertMixin:DisplayForGroupBuffItem(groupBuffItem, isNewAlert)
	self.groupBuffItem = groupBuffItem;
	self:GetIcon():SetTexture(groupBuffItem.iconID);
	self:GetNameLabel():SetText(groupBuffItem.name);
	self.selectedVisual = Enum.VisualAlertType.MarchingAnts;
	self:SetupDropdown();
	self:Display(isNewAlert);
end

function GroupBuffFilterEditVisualAlertMixin:SetupDropdown()
	self.VisualDropdown:SetSelectionText(function(selections)
		return VisualAlert_GetTypeText(self.selectedVisual);
	end);

	self.VisualDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("GROUP_BUFF_FILTER_VISUAL_ALERT_PAYLOAD");

		VisualAlertData_ForEach(function(visualData)
			rootDescription:CreateButton(visualData.text, function()
				self.selectedVisual = visualData.enum;
				self:SetupDropdown();
			end);
		end);
	end);
end

function GroupBuffFilterEditVisualAlertMixin:AddCurrentAlert()
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	assertsafe(layoutManager ~= nil, "The Layout Manager must be set to add visual alerts to group buff items.")

	local newVisualAlerts = CopyTable(GetCurrentVisualAlerts());
	newVisualAlerts[self.groupBuffItem.spellID] = self.selectedVisual;

	layoutManager:WriteGroupBuffVisualAlertsToActiveLayout(newVisualAlerts, Enum.CDMLayoutMode.AllowCreate);
end

GroupBuffFilterSectionMixin = {};

function GroupBuffFilterSectionMixin:OnLoad()
	self.itemPool = CreateFramePool("Frame", self.Container, "GroupBuffFilterItemTemplate");

	self.Header:SetClickHandler(function(_header, button)
		if button == "LeftButton" then
			self:ToggleCollapsed();
		end
	end);

	self.Header:SetTitleColor(false, NORMAL_FONT_COLOR);
	self.Header:SetTitleColor(true, NORMAL_FONT_COLOR);
end

function GroupBuffFilterSectionMixin:Init(title, isShown, filter)
	self.isShown = isShown;
	self.filter = filter;
	self.Header:SetHeaderText(title);
	self:SetCollapsed(false);
end

function GroupBuffFilterSectionMixin:GetFilter()
	return self.filter;
end

function GroupBuffFilterSectionMixin:IsShownSection()
	return self.isShown;
end

function GroupBuffFilterSectionMixin:SetCollapsed(collapsed)
	self.Header:UpdateCollapsedState(collapsed);
	self.Container:SetShown(not collapsed);
	self.isCollapsed = collapsed;
	self:Layout();
end

function GroupBuffFilterSectionMixin:ToggleCollapsed()
	self:SetCollapsed(not self.isCollapsed);
end

function GroupBuffFilterSectionMixin:RefreshLayout(groupBuffItems)
	self.itemPool:ReleaseAll();

	for index, groupBuffItem in ipairs(groupBuffItems) do
		local item = self.itemPool:Acquire();
		item.layoutIndex = index;
		item:Init(groupBuffItem, self);
		item:Show();
	end

	self.Container:Layout();
	self:ApplyFilter();
	self:Layout();
end

function GroupBuffFilterSectionMixin:ApplyFilter()
	local filterText = self.filter:GetFilterText();

	for item in self.itemPool:EnumerateActive() do
		item:ApplyFilter(item:MatchesFilter(filterText));
	end
end

GroupBuffFilterMixin = {};

function GroupBuffFilterMixin:OnLoad()
	self.filterText = "";

	self.shownSection = CreateFrame("Frame", nil, self.Scroll.Content, "GroupBuffFilterSectionTemplate");
	self.shownSection:Init(GROUP_BUFF_FILTER_SECTION_SHOWN, true, self);
	self.shownSection:SetPoint("TOPLEFT", self.Scroll.Content, "TOPLEFT", 0, 0);
	self.shownSection:Show();

	self.hiddenSection = CreateFrame("Frame", nil, self.Scroll.Content, "GroupBuffFilterSectionTemplate");
	self.hiddenSection:Init(GROUP_BUFF_FILTER_SECTION_HIDDEN, false, self);
	self.hiddenSection:SetPoint("TOPLEFT", self.shownSection, "BOTTOMLEFT", 0, -18);
	self.hiddenSection:Show();
end

function GroupBuffFilterMixin:OnEvent(event)
	if event == "GLOBAL_MOUSE_UP" then
		if self.eatNextGlobalMouseUp then
			self.eatNextGlobalMouseUp = nil;
			return;
		end

		PlaySound(self:GetDropSound());

		self:EndGroupBuffItemDrag();
	end
end

function GroupBuffFilterMixin:GetDropSound()
	return SOUNDKIT.UI_CURSOR_DROP_OBJECT;
end

function GroupBuffFilterMixin:Refresh()
	local shownBuffItems, hiddenBuffItems = BuildGroupBuffItemLists();
	self.shownSection:RefreshLayout(shownBuffItems);
	self.hiddenSection:RefreshLayout(hiddenBuffItems);
end

-- Only used by tests when mocking C_CooldownViewer.GetGroupBuffItems()
function GroupBuffFilterMixin:ForceSync()
	SyncHiddenGroupBuffs();
	SyncGroupBuffVisualAlerts();
	self:Refresh();
end

function GroupBuffFilterMixin:GetFilterText()
	return self.filterText;
end

function GroupBuffFilterMixin:ApplyFilter(filterText)
	self.filterText = filterText or "";
	self.shownSection:ApplyFilter();
	self.hiddenSection:ApplyFilter();
end

function GroupBuffFilterMixin:BeginGroupBuffItemDrag(item, eatNextGlobalMouseUp)
	if self.dragItem then
		return;
	end

	self.dragItem = item;
	self.eatNextGlobalMouseUp = eatNextGlobalMouseUp;
	CooldownViewerDraggedItem_Pickup(item:GetIconID());
	item:SetDragLocked(true);
	self:RegisterEvent("GLOBAL_MOUSE_UP");
end

function GroupBuffFilterMixin:EndGroupBuffItemDrag()
	local sourceItem = self.dragItem;
	if not sourceItem then
		return;
	end

	local sourceSection = sourceItem:GetSection();
	local targetSection = nil;
	if InputUtil.IsMouseOver(self.shownSection) then
		targetSection = self.shownSection;
	elseif InputUtil.IsMouseOver(self.hiddenSection) then
		targetSection = self.hiddenSection;
	end

	if targetSection and targetSection ~= sourceSection then
		self:MoveGroupBuffItem(sourceItem:GetGroupBuffItem(), sourceSection, targetSection);
	end

	self:CancelGroupBuffItemDrag();
end

function GroupBuffFilterMixin:CancelGroupBuffItemDrag()
	self.dragItem:SetDragLocked(false);
	self.dragItem = nil;
	self.eatNextGlobalMouseUp = nil;
	CooldownViewerDraggedItem_Clear();
	self:UnregisterEvent("GLOBAL_MOUSE_UP");
end

function GroupBuffFilterMixin:MoveGroupBuffItem(groupBuffItem, fromSection, toSection)
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	assertsafe(layoutManager ~= nil, "The Layout Manager must be set to move group buff items.")

	local hiddenGroupBuffSpellIDs = GetCurrentHiddenGroupBuffSpellIDs();

	if toSection:IsShownSection() then
		for i, spellID in ipairs(hiddenGroupBuffSpellIDs) do
			if spellID == groupBuffItem.spellID then
				table.remove(hiddenGroupBuffSpellIDs, i);
				break;
			end
		end
	else
		table.insert(hiddenGroupBuffSpellIDs, groupBuffItem.spellID);
	end

	layoutManager:WriteHiddenGroupBuffsToActiveLayout(hiddenGroupBuffSpellIDs, Enum.CDMLayoutMode.AllowCreate);
end

function GroupBuffFilterMixin:RemoveVisualAlert(groupBuffItem)
	local layoutManager = CooldownViewerSettings:GetLayoutManager();
	assertsafe(layoutManager ~= nil, "The Layout Manager must be set to remove visual alerts from group buff items.")

	local newVisualAlerts = CopyTable(GetCurrentVisualAlerts());
	newVisualAlerts[groupBuffItem.spellID] = nil;

	layoutManager:WriteGroupBuffVisualAlertsToActiveLayout(newVisualAlerts, Enum.CDMLayoutMode.AllowCreate);
end

function GroupBuffFilterMixin:IsGroupBuffHidden(groupBuffItem)
	local hiddenGroupBuffSpellIDs = GetCurrentHiddenGroupBuffSpellIDs();
	for _, spellID in ipairs(hiddenGroupBuffSpellIDs) do
		if spellID == groupBuffItem.spellID then
			return true;
		end
	end
	return false;
end

function GroupBuffFilterMixin:DisplayContextMenu(item)
	local groupBuffItem = item:GetGroupBuffItem();
	local section = item:GetSection();

	MenuUtil.CreateContextMenu(item, function(owner, rootDescription)
		rootDescription:SetTag("MENU_GROUP_BUFF_FILTER_ITEM");

		local existingVisual = item:GetVisualAlert();
		if existingVisual then
			local payloadText = VisualAlert_GetTypeText(existingVisual);
			CooldownViewerContextMenu_AddAlertEntryButton(rootDescription, Enum.CooldownViewerAlertType.Visual, payloadText, COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AURA_APPLIED,
				function()
					GroupBuffFilterEditVisualAlert:DisplayForGroupBuffItem(groupBuffItem, false);
				end,
				function()
					self:RemoveVisualAlert(groupBuffItem);
				end,
				function()
					item:PlayAlertSample();
				end
			);
		else
			local isEnabled = true;
			local disabledTooltipCallback = nil;
			CooldownViewerContextMenu_AddNewAlertButton(rootDescription, GROUP_BUFF_FILTER_NEW_VISUAL_ALERT, isEnabled,
				function()
					GroupBuffFilterEditVisualAlert:DisplayForGroupBuffItem(groupBuffItem, true);
				end,
				disabledTooltipCallback
			);
		end

		rootDescription:CreateDivider();

		if section:IsShownSection() then
			local moveSectionButton = rootDescription:CreateButton(GROUP_BUFF_FILTER_MOVE_TO_HIDDEN, function()
				self:MoveGroupBuffItem(groupBuffItem, section, self.hiddenSection);
			end);
			moveSectionButton.isMoveSectionButton = true;
		else
			local moveSectionButton = rootDescription:CreateButton(GROUP_BUFF_FILTER_MOVE_TO_SHOWN, function()
				self:MoveGroupBuffItem(groupBuffItem, section, self.shownSection);
			end);
			moveSectionButton.isMoveSectionButton = true;
		end
	end);
end
