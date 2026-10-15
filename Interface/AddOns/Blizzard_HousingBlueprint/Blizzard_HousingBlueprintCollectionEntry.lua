HousingBlueprintCollectionEntryMixin = {};

function HousingBlueprintCollectionEntryMixin:Init(node, owner)
	self.blueprintInfo = node:GetData();
	self.owner = owner;
	if self.blueprintInfo.isAutoSave then
		-- Auto saves are all named the same thing, so stick their creation data to the end
		local dateTimeStr = self:GetDateTimeStr(--[[excludeTime=]]true);
		self.Text:SetText(self.blueprintInfo.name.." "..dateTimeStr);
	else
		self.Text:SetText(self.blueprintInfo.name);
	end
	self:UpdateStateVisuals();
end

function HousingBlueprintCollectionEntryMixin.Reset(pool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self.blueprintInfo = nil;
	self.HighlightBackground:Hide();
	self.contextMenuIsOpen = false;
	self.owner = nil;
end

function HousingBlueprintCollectionEntryMixin:GetDateTimeStr(excludeTime)
	if not self.blueprintInfo then
		return nil;
	end
	local creationDate = date("*t", self.blueprintInfo.creationTime);
	local dateStr = FormatShortDate(creationDate.day, creationDate.month, creationDate.year);
	if excludeTime then
		return dateStr;
	end

	local timeStr = GameTime_GetFormattedTime(creationDate.hour, creationDate.min, true);
	return dateStr.." "..timeStr;
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
			if not ChatFrameUtil.InsertLink(blueprintLink) then
				ChatFrameUtil.OpenChat(blueprintLink);
			end
		elseif self.owner then
			self.owner:OnBlueprintEntryClicked(self.blueprintInfo);
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
	
	local dateTimeStr = self:GetDateTimeStr(--[[excludeTime=]]false);
	GameTooltip_AddNormalLine(tooltip, HOUSING_BLUEPRINT_COLLECTION_TIMESTAMP_FMT:format(dateTimeStr));
	GameTooltip_AddInstructionLine(tooltip, HOUSING_BLUEPRINT_CHATLINK_INSTRUCTION);

	GameTooltip:Show();
	self:UpdateStateVisuals();
end

function HousingBlueprintCollectionEntryMixin:OnLeave()
	GameTooltip:Hide();
	self:UpdateStateVisuals();
end

function HousingBlueprintCollectionEntryMixin:ShowContextMenu()
	if not self.blueprintInfo then
		return;
	end

	MenuUtil.CreateContextMenu(self, function(self, rootDescription)
		local shouldShowImport, importDisabledTooltip = false, nil;
		if self.owner then
			shouldShowImport, importDisabledTooltip = self.owner:ShouldShowContextImportOption(self.blueprintInfo);
		end
		local menuParams = {
			shouldShowImport = shouldShowImport,
			importDisabledTooltip = importDisabledTooltip,
			onDeleteConfirm = function() self:OnDeleteConfirmed(); end,
			onStateChange = function() self:UpdateStateVisuals(); end,
			onMenuOpenChanged = function(isMenuOpen) self.contextMenuIsOpen = isMenuOpen; self:UpdateStateVisuals(); end,
		};
		HousingBlueprintUtils.CreateBlueprintInfoContextMenu(rootDescription, self.blueprintInfo, menuParams)
	end);
end

function HousingBlueprintCollectionEntryMixin:OnDeleteConfirmed()
	if self.blueprintInfo and not self.blueprintInfo.isAutoSave then
		C_HousingBlueprint.DeleteBlueprint(self.blueprintInfo.blueprintID);
	end
end

function HousingBlueprintCollectionEntryMixin:UpdateStateVisuals()
	local isSelected = self:IsSelected();
	local isHovered = self:IsHovered();

	local textColor = isSelected and NORMAL_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	self.Text:SetTextColor(textColor:GetRGB());

	self.HighlightBackground:SetShown(isHovered);
end

function HousingBlueprintCollectionEntryMixin:IsSelected()
	if not self.blueprintInfo then
		return false;
	end

	-- If this blueprint is open in Import or Rename frame, show selected
	if HousingBlueprintImportFrame:IsShowingBlueprint(self.blueprintInfo.shareCode) or HousingBlueprintRenameFrame:IsShowingBlueprint(self.blueprintInfo.shareCode) then
		return true;
	end

	if HousingDashboardFrame and HousingDashboardFrame:IsShown() and HousingDashboardFrame.CollectionContent:IsBlueprintSelected(self.blueprintInfo.shareCode) then
		return true;
	end

	-- If Delete confirmation for this blueprint is open, show selected
	local dialogName, dialog = StaticPopup_Visible("CONFIRM_BLUEPRINT_DELETE");
	if dialog and dialog.data and dialog.data.shareCode == self.blueprintInfo.shareCode then
		return true;
	end

	-- If this is a room blueprint and is currently selected for door selection in layout mode, show selected
	if self.blueprintInfo.blueprintType == Enum.HousingBlueprintType.Room then
		local roomID, blueprintCode = C_HousingLayout.GetSelectedBlueprintFloorplan();
		if blueprintCode and blueprintCode == self.blueprintInfo.shareCode then
			return true;
		end
	end

	return false;
end

function HousingBlueprintCollectionEntryMixin:IsHovered()
	if not self.blueprintInfo then
		return false;
	end

	return GameTooltip:GetOwner() == self or self.contextMenuIsOpen;
end

function HousingBlueprintCollectionEntryMixin:GetDebugName()
	if self.blueprintInfo then
		return self.blueprintInfo.name;
	end
	return "Unused Entry";
end
