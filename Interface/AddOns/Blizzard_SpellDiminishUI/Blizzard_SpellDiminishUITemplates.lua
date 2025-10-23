SpellDiminishStatusTrayItemMixin = {};

function SpellDiminishStatusTrayItemMixin:OnLoad()
	self:SetupImmunityIndicator();
end

function SpellDiminishStatusTrayItemMixin:SetupImmunityIndicator()
	-- Keep the immune indicator above the cooldown display
	self.ImmunityIndicator:SetFrameLevel(self.Cooldown:GetFrameLevel() + 1);
end

function SpellDiminishStatusTrayItemMixin:SetCategoryInfo(categoryInfo)
	self.categoryInfo = categoryInfo;
	self.Icon:SetTexture(categoryInfo.icon or "Interface\\Icons\\INV_Misc_QuestionMark");
end

function SpellDiminishStatusTrayItemMixin:GetCategory()
	return self.categoryInfo and self.categoryInfo.category or nil;
end

function SpellDiminishStatusTrayItemMixin:GetCategoryName()
	return self.categoryInfo and self.categoryInfo.name or nil;
end

function SpellDiminishStatusTrayItemMixin:UpdateState(spellDiminishCategoryState)
	self.ImmunityIndicator:SetShown(spellDiminishCategoryState.isImmune);

	CooldownFrame_Set(self.Cooldown, spellDiminishCategoryState.startTime, spellDiminishCategoryState.duration, spellDiminishCategoryState.showCountdown);
end

function SpellDiminishStatusTrayItemMixin:Reset()
	self.ImmunityIndicator:Hide();
	self.Cooldown:SetScript("OnCooldownDone", nil);
	self.isEditModePreview = nil;
end

SpellDiminishStatusTrayMixin = {};

local SpellDiminishStatusTrayEvents = {
	"UNIT_SPELL_DIMINISH_CATEGORY_STATE_UPDATED",
};

function SpellDiminishStatusTrayMixin:OnLoad()
	self:InitializeTrayItemPool();
end

function SpellDiminishStatusTrayMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SpellDiminishStatusTrayEvents);
	self:Layout();

	-- Edge case: You're previewing 2v2 frames and then switch to previewing 3v3 in Edit Mode
	-- The tray for third frame needs to be in edit mode when shown
	if EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive() then
		self:SetIsInEditMode(true);
	end
end

function SpellDiminishStatusTrayMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SpellDiminishStatusTrayEvents);
	self:SetIsInEditMode(false);
	self:RemoveAllTrayItems();
end

function SpellDiminishStatusTrayMixin:OnEvent(event, ...)
	if event == "UNIT_SPELL_DIMINISH_CATEGORY_STATE_UPDATED" then
		local unitToken, spellDiminishCategoryState = ...;
		self:TryUpdateOrAddTrayItem(unitToken, spellDiminishCategoryState);
	end
end

function SpellDiminishStatusTrayMixin:SetUnit(unitToken)
	self.unitToken = unitToken;
end

local function trayItemResetter(trayItemPool, trayItem)
	trayItem:Reset();
	Pool_HideAndClearAnchors(trayItemPool, trayItem);
end;

function SpellDiminishStatusTrayMixin:InitializeTrayItemPool()
	self.trayItemPool = CreateFramePool("FRAME", self, "SpellDiminishStatusTrayItemTemplate", trayItemResetter);
	self.trayItemOrder = {};
	self.activeItemForCategory = {};
end

function SpellDiminishStatusTrayMixin:AddCategoryToOrder(category)
	tInsertUnique(self.trayItemOrder, category);
end

function SpellDiminishStatusTrayMixin:RemoveCategoryFromOrder(category)
	tDeleteItem(self.trayItemOrder, category);
end

function SpellDiminishStatusTrayMixin:GetActiveTrayItemForCategory(category)
	return self.activeItemForCategory[category];
end

function SpellDiminishStatusTrayMixin:TryUpdateOrAddTrayItem(unitToken, spellDiminishCategoryState)
	local isTrackedUnit = self.unitToken and (unitToken == self.unitToken);
	if not isTrackedUnit then
		return;
	end

	if not self:ShouldTrackSpellDiminishCategory(spellDiminishCategoryState.category) then
		return;
	end
	self:UpdateOrAddTrayItem(spellDiminishCategoryState);
end

function SpellDiminishStatusTrayMixin:ShouldTrackSpellDiminishCategory(category)
	return C_SpellDiminish.ShouldTrackSpellDiminishCategory(category, self.spellDiminishRuleset);
end

function SpellDiminishStatusTrayMixin:UpdateOrAddTrayItem(spellDiminishCategoryState)
	local existingTrayItem = self:GetActiveTrayItemForCategory(spellDiminishCategoryState.category);
	if existingTrayItem then
		existingTrayItem:UpdateState(spellDiminishCategoryState);
		return;
	end

	local categoryInfo = C_SpellDiminish.GetSpellDiminishCategoryInfo(spellDiminishCategoryState.category);
	if categoryInfo then
		self:AddNewItemToTray(categoryInfo, spellDiminishCategoryState);
	end
end

function SpellDiminishStatusTrayMixin:AddNewItemToTray(categoryInfo, spellDiminishCategoryState)
	local newTrayItem = self:CreateTrayItemForCategory(categoryInfo);
	newTrayItem:UpdateState(spellDiminishCategoryState);
	self:RefreshTrayLayout();
end

function SpellDiminishStatusTrayMixin:CreateTrayItemForCategory(categoryInfo)
	local newTrayItem = self.trayItemPool:Acquire();
	self:AddCategoryToOrder(categoryInfo.category);
	self.activeItemForCategory[categoryInfo.category] = newTrayItem;

	newTrayItem.Cooldown:SetScript("OnCooldownDone", GenerateClosure(self.OnTrayItemCooldownDone, self, newTrayItem));

	newTrayItem:SetCategoryInfo(categoryInfo);
	newTrayItem:Show();
	return newTrayItem;
end

function SpellDiminishStatusTrayMixin:OnTrayItemCooldownDone(trayItem)
	if not trayItem then
		return;
	end

	local category = trayItem:GetCategory();
	self.trayItemPool:Release(trayItem);
	self:RemoveCategoryFromOrder(category);
	self.activeItemForCategory[category] = nil;
	self:RefreshTrayLayout();
end

function SpellDiminishStatusTrayMixin:RefreshTrayLayout()
	self:UpdateTrayItemAnchoring();
	self:Layout();
end

function SpellDiminishStatusTrayMixin:RemoveAllTrayItems()
	self.trayItemPool:ReleaseAll();
	table.wipe(self.trayItemOrder);
	table.wipe(self.activeItemForCategory);
	self:Layout();
end

function SpellDiminishStatusTrayMixin:UpdateTrayItemAnchoring()
	local previousTrayItem = nil;
	for index, category in ipairs(self.trayItemOrder) do
		local trayItem = self:GetActiveTrayItemForCategory(category);
		if trayItem then
			if not previousTrayItem then
				self:AnchorFirstTrayItem(trayItem);
			else
				self:AnchorNextTrayItem(trayItem, previousTrayItem);
			end
			previousTrayItem = trayItem;
		end
	end
end

function SpellDiminishStatusTrayMixin:AnchorFirstTrayItem(trayItem)
	trayItem:SetPoint("LEFT", self, "LEFT", 2, 0);
end

function SpellDiminishStatusTrayMixin:AnchorNextTrayItem(trayItem, previousTrayItem)
	trayItem:SetPoint("LEFT", previousTrayItem, "RIGHT", 2, 0);
end

function SpellDiminishStatusTrayMixin:UpdateShownState()
	self:SetShown(C_CVar.GetCVarBool("spellDiminishPVPEnemiesEnabled"));
end

function SpellDiminishStatusTrayMixin:SetIsInEditMode(isInEditMode)
	if self.isInEditMode == isInEditMode then
		return;
	end

	self.isInEditMode = isInEditMode;
	if isInEditMode then
		self:PopulateEditModePreviewItems();
	else
		self:ClearEditModePreviewItems();
	end
end

function SpellDiminishStatusTrayMixin:IsInEditMode()
	return self.isInEditMode;
end

function SpellDiminishStatusTrayMixin:PopulateEditModePreviewItems()
	for index, realCategoryInfo in ipairs(C_SpellDiminish.GetAllSpellDiminishCategories(self.spellDiminishRuleset)) do
		local category = realCategoryInfo.category;		
		-- Double check that we aren't already displaying a real item for this category somehow (edit mode during combat?)
		if not self:GetActiveTrayItemForCategory(category) then
			self:AddCategoryToOrder(category);

			local trayItem = self.trayItemPool:Acquire();
			self.activeItemForCategory[category] = trayItem;
			trayItem.isEditModePreview = true;

			local overrideCategoryInfo = { name = realCategoryInfo.name, category = realCategoryInfo.category, icon = "Interface\\Icons\\INV_Misc_QuestionMark" };
			trayItem:SetCategoryInfo(overrideCategoryInfo);

			trayItem:Show();
		end
	end

	self:RefreshTrayLayout();
end

function SpellDiminishStatusTrayMixin:ClearEditModePreviewItems()
	for _index, categoryInfo in ipairs(C_SpellDiminish.GetAllSpellDiminishCategories(self.spellDiminishRuleset)) do
		local trayItem = self:GetActiveTrayItemForCategory(categoryInfo.category);
		if trayItem and trayItem.isEditModePreview then
			self.trayItemPool:Release(trayItem);
			self:RemoveCategoryFromOrder(categoryInfo.category);
			self.activeItemForCategory[categoryInfo.category] = nil;
		end
	end

	self:RefreshTrayLayout();
end
