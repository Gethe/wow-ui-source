----------------- Collection Container -----------------
HousingBlueprintCollectionMixin = {};

local CollectionWhileShownEvents = {
	"HOUSING_BLUEPRINT_COLLECTION_RECEIVED",
	"HOUSING_BLUEPRINT_COLLECTION_FAILURE",
	"HOUSING_BLUEPRINT_RENAME_SUCCESS",
	"HOUSING_BLUEPRINT_DELETE_SUCCESS",
	"HOUSING_BLUEPRINT_DELETE_FAILURE",
	"HOUSE_RESET_FAILED",
	"HOUSE_RESET_COMPLETED",
};

local ResetScopeAllMask = bit.band(Enum.HousingHouseScope.Interior, Enum.HousingHouseScope.Exterior);
function HousingBlueprintCollectionMixin:OnLoad()
	self.ResetButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_BLUEPRINT_COLLECTIONS_RESET");

		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_RESET_INTERIOR, function()
			self:OnResetClicked(Enum.HousingHouseScope.Interior);
		end);
		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_RESET_EXTERIOR, function()
			self:OnResetClicked(Enum.HousingHouseScope.Exterior);
		end);
		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_RESET_ALL, function()
			self:OnResetClicked(ResetScopeAllMask);
		end);
	end);
	self.ResetButton:SetScript("OnEnter", function()
		self.ResetButton.HoverIcon:Show();
		GameTooltip:SetOwner(self.ResetButton, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, HOUSING_BLUEPRINT_COLLECTION_RESET_TOOLTIP);
		GameTooltip:Show();
	end);
	self.ResetButton:SetScript("OnLeave", function()
		self.ResetButton.HoverIcon:Hide();
		GameTooltip:Hide();
	end);
	self.ResetButton:Layout();
	
	self.SlotCountText:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.ResetButton, "ANCHOR_BOTTOM");
		GameTooltip_SetTitle(GameTooltip, HOUSING_BLUEPRINT_COLLECTION_COUNT_TOOLTIP);
		GameTooltip:Show();
	end);
	self.SlotCountText:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	local childElementIndent, elementSpacing = 10, 3;
	local view = CreateScrollBoxListTreeListView(childElementIndent, self.topPadding, self.bottomPadding, self.leftPadding, self.rightPadding, elementSpacing);
	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.entries then
			local function GroupInitializer(frame, node)
				frame:Init(node);
			end
			factory("HousingBlueprintCollectionGroupTemplate", GroupInitializer);
		elseif elementData.shareCode then
			local function EntryInitializer(frame, node)
				frame:Init(node);
			end
			factory("HousingBlueprintCollectionEntryTemplate", EntryInitializer);
		end
	end);
	view:SetFrameFactoryResetter(function(pool, frame, new)
		if not new then
			frame.Reset(pool, frame);
		end
	end);
	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		if elementData.entries then
			return 36;
		elseif elementData.shareCode then
			return 20;
		end
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function HousingBlueprintCollectionMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_COLLECTION_RECEIVED" then
		local collectionInfo = ...;
		self:OnCollectionReceived(collectionInfo);
	elseif event == "HOUSING_BLUEPRINT_COLLECTION_FAILURE" then
		local result = ...;
		self:OnCollectionFailure(result);
	elseif event == "HOUSING_BLUEPRINT_RENAME_SUCCESS" or event == "HOUSING_BLUEPRINT_DELETE_SUCCESS" then
		self:RequestNewData();
	elseif event == "HOUSING_BLUEPRINT_DELETE_FAILURE" then
		local result = ...;
		self:OnDeleteFailure(result);
	end
end

function HousingBlueprintCollectionMixin:OnShow()
	self:RequestNewData();
	FrameUtil.RegisterFrameForEvents(self, CollectionWhileShownEvents);
end

function HousingBlueprintCollectionMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CollectionWhileShownEvents);
end

function HousingBlueprintCollectionMixin:RequestNewData()
	C_HousingBlueprint.RequestBlueprintCollection();
end

function HousingBlueprintCollectionMixin:ClearData()
	self.ScrollBox:RemoveDataProvider();
end

local function SortEntriesByTime(nodeA, nodeB)
	local elementA = nodeA:GetData();
	local elementB = nodeB:GetData();
	return elementA.creationTime < elementB.creationTime;
end

function HousingBlueprintCollectionMixin:OnCollectionReceived(collectionInfo)
	if not collectionInfo or not collectionInfo.groups then
		self:ClearData();
		return;
	end

	local dataProvider = CreateTreeDataProvider();
	local numPlayerMadeBlueprints = 0;
	local numAutoBlueprints = 0;

	local affectChildren = false;
	local skipSort = false;
	for _, group in ipairs(collectionInfo.groups) do
		local groupNode = dataProvider:Insert(group);
		groupNode:SetSortComparator(SortEntriesByTime, affectChildren, skipSort);

		for _, entry in ipairs(group.entries) do
			if entry.isAutoSave then
				numAutoBlueprints = numAutoBlueprints + 1;
			else
				numPlayerMadeBlueprints = numPlayerMadeBlueprints + 1;
			end

			groupNode:Insert(entry);
		end
	end

	local maxBlueprints = Constants.HousingConsts.HOUSING_BLUEPRINTS_MAX_PER_BNET_ACCOUNT;
	self.SlotCountText:SetText(HOUSING_BLUEPRINT_COLLECTION_COUNT_FMT:format(numPlayerMadeBlueprints, maxBlueprints))
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function HousingBlueprintCollectionMixin:OnCollectionFailure(result)
	local resultText = HousingResultToErrorText[result];
	local errorText = HOUSING_BLUEPRINT_COLLECTION_ERROR;
	if resultText then
		errorText = HOUSING_BLUEPRINT_COLLECTION_ERROR_FMT:format(resultText);
	end
	UIErrorsFrame:AddExternalErrorMessage(errorText);
end

function HousingBlueprintCollectionMixin:OnDeleteFailure(result)
	local resultText = HousingResultToErrorText[result];
	local errorText = ERR_HOUSING_BLUEPRINT_DELETE_FAILED;
	if resultText then
		errorText = ERR_HOUSING_BLUEPRINT_DELETE_FAILED_FMT:format(resultText);
	end
	UIErrorsFrame:AddExternalErrorMessage(errorText);
end

local ResetStringsByScope = {
	[ResetScopeAllMask] = { title = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_TITLE_ALL, subText = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_SUBTEXT_ALL },
	[Enum.HousingHouseScope.Interior] = { title = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_TITLE_INTERIOR, subText = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_SUBTEXT_INTERIOR },
	[Enum.HousingHouseScope.Exterior] = { title = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_TITLE_EXTERIOR, subText = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_SUBTEXT_EXTERIOR },
};
function HousingBlueprintCollectionMixin:OnResetClicked(scopeFlags)
	local confirmationStrings = ResetStringsByScope[scopeFlags];
	if not confirmationStrings then
		-- No handled scope, no reset
		return;
	end

	local finalSubText = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_SUBTEXT_FINAL:format(HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_STRING);
	local fullSubText = confirmationStrings.subText..finalSubText;
	local popupData = {
		resetScope = scopeFlags,
		owner = self,
		confirmationString = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRMATION_STRING,
		subText = fullSubText,
	};
	StaticPopup_Show("CONFIRM_RESET_HOUSE", confirmationStrings.title, nil, popupData);
end

function HousingBlueprintCollectionMixin:OnResetConfirmed(scopeFlags)
	if not scopeFlags then
		return;
	end

	C_Housing.ResetHouse(scopeFlags);
end

----------------- Collection Group -----------------
HousingBlueprintCollectionGroupMixin = {};

function HousingBlueprintCollectionGroupMixin:OnLoad()
	self.Header:SetClickHandler(function(_header, button)
		if button == "LeftButton" then
			self:ToggleCollapsed();
		end
	end);

	self.Header:SetTitleColor(false, NORMAL_FONT_COLOR);
	self.Header:SetTitleColor(true, NORMAL_FONT_COLOR);
end

function HousingBlueprintCollectionGroupMixin:Init(node)
	self.groupData = node:GetData();
	self.node = node;
	self.Header:SetHeaderText(self.groupData.name);
	self:SetCollapsed(node:IsCollapsed());
end

function HousingBlueprintCollectionGroupMixin.Reset(pool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.groupData = nil;
	self.node = nil;
end

function HousingBlueprintCollectionGroupMixin:ToggleCollapsed()
	self:SetCollapsed(not self:IsCollapsed());
end

function HousingBlueprintCollectionGroupMixin:SetCollapsed(collapsed)
	if self.node then
		self.node:SetCollapsed(collapsed);
	end

	self.Header:UpdateCollapsedState(collapsed);
end

function HousingBlueprintCollectionGroupMixin:IsCollapsed()
	return self.node and self.node:IsCollapsed();
end

function HousingBlueprintCollectionGroupMixin:GetDebugName()
	if self.groupData then
		return self.groupData.name;
	end
	return "Unused Group";
end

----------------- Collection Entry -----------------
HousingBlueprintCollectionEntryMixin = {};

function HousingBlueprintCollectionEntryMixin:Init(node)
	self.blueprintInfo = node:GetData();
	if self.blueprintInfo.isAutoSave then
		-- Auto saves are all named the same thing, so stick their creation data to the end
		local dateTimeStr = self:GetDateTimeStr();
		self.Text:SetText(self.blueprintInfo.name.." "..dateTimeStr);
	else
		self.Text:SetText(self.blueprintInfo.name);
	end
end

function HousingBlueprintCollectionEntryMixin.Reset(pool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.blueprintInfo = nil;
	self.SelectedBackground:Hide();
	self.HighlightBackground:Hide();
end

function HousingBlueprintCollectionEntryMixin:GetDateTimeStr()
	if not self.blueprintInfo then
		return nil;
	end
	local creationDate = date("*t", self.blueprintInfo.creationTime);
	return FormatShortDate(creationDate.day, creationDate.month, creationDate.year);
end

function HousingBlueprintCollectionEntryMixin:OnClick(button)
	if not self.blueprintInfo then
		return;
	end

	if button == "RightButton" then
		self:ShowContextMenu();
	else
		if IsModifiedClick("CHATLINK") then
			local blueprintLink = C_HousingBlueprint.GetBlueprintHyperlink(self.blueprintInfo.shareCode);
			ChatFrameUtil.InsertLink(blueprintLink);
		elseif self.blueprintInfo.blueprintType ~= Enum.HousingBlueprintType.Room then -- TODO: Implement room import flow
			HousingFramesUtil.ShowBlueprintImport(self.blueprintInfo.shareCode);
		end
	end
end

function HousingBlueprintCollectionEntryMixin:OnEnter()
	if not self.blueprintInfo then
		return;
	end
	self.HighlightBackground:Show();

	local tooltip = GameTooltip;
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip_SetTitle(tooltip, self.blueprintInfo.name);
	local typeString = HousingBlueprintTypeStrings[self.blueprintInfo.blueprintType];
	if typeString then
		GameTooltip_AddHighlightLine(tooltip, typeString);
	end
	
	local dateTimeStr = self:GetDateTimeStr();
	GameTooltip_AddNormalLine(tooltip, HOUSING_BLUEPRINT_COLLECTION_TIMESTAMP_FMT:format(dateTimeStr));

	-- TODO: REMOVE THIS once room import flow implemented
	if self.blueprintInfo.blueprintType == Enum.HousingBlueprintType.Room then
		GameTooltip_AddErrorLine(tooltip, "Room Import not yet implemented");
	end

	GameTooltip:Show();
end

function HousingBlueprintCollectionEntryMixin:OnLeave()
	self.HighlightBackground:Hide();
	GameTooltip:Hide();
end

function HousingBlueprintCollectionEntryMixin:ShowContextMenu()
	if not self.blueprintInfo then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_BLUEPRINT_ENTRY");
		
		rootDescription:AddMenuAcquiredCallback(function(menuFrame)
			self.SelectedBackground:Show();
		end);
		rootDescription:AddMenuReleasedCallback(function(menuFrame, closeReason)
			self.SelectedBackground:Hide();
		end);

		if self.blueprintInfo.isAutoSave then
			rootDescription:CreateTitle(HOUSING_BLUEPRINT_COLLECTION_READONLY_BACKUP);
			return;			
		end

		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_COPY, function()
			CopyToClipboard(self.blueprintInfo.shareCode);
			ChatFrameUtil.DisplaySystemMessageInPrimary(HOUSING_BLUEPRINT_EXPORT_CLIPBOARD_CONFIRMATION);
		end);
		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_RENAME, function()
			HousingBlueprintRenameFrame:ShowForBlueprint(self.blueprintInfo);
		end);
		rootDescription:CreateButton(HOUSING_BLUEPRINT_COLLECTION_DELETE, function()
			local popupData = {
				owner = self,
				confirmationString = HOUSING_BLUEPRINT_DELETE_CONFIRMATION_STRING,
			};
			StaticPopup_Show("CONFIRM_BLUEPRINT_DELETE", HOUSING_BLUEPRINT_DELETE_CONFIRMATION_STRING, nil, popupData);
		end);
	end);
end

function HousingBlueprintCollectionEntryMixin:OnDeleteConfirmed()
	C_HousingBlueprint.DeleteBlueprint(self.blueprintInfo.blueprintID);
end

function HousingBlueprintCollectionEntryMixin:GetDebugName()
	if self.blueprintInfo then
		return self.blueprintInfo.name;
	end
	return "Unused Entry";
end

----------------- Static Popups -----------------
StaticPopupDialogs["CONFIRM_BLUEPRINT_DELETE"] = {
	text = HOUSING_BLUEPRINT_DELETE_CONFIRMATION_TEXT,
	button1 = HOUSING_BLUEPRINT_DELETE_CONFIRM,
	button2 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	showAlert = 1,


	OnAccept = function(dialog, data)
		data.owner:OnDeleteConfirmed();
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			data.owner:OnDeleteConfirmed();
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};

StaticPopupDialogs["CONFIRM_RESET_HOUSE"] = {
	text = "%s",
	subText = "",
	normalSizedSubText = true,
	button1 = HOUSING_BLUEPRINT_COLLECTION_RESET_CONFIRM,
	button2 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,

	OnAccept = function(dialog, data)
		data.owner:OnResetConfirmed(data.resetScope);
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
		if (data.subText) then
			dialog.SubText:SetText(data.subText);
		end
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			data.owner:OnResetConfirmed(data.resetScope);
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, data.confirmationString);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};
