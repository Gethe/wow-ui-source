function SpellBookFrameMixin:OnShow()
	self:OnShowBase();

	PlayerSpellsFrame:UpdateSize();

	self.BookCornerFlipbook:Hide();
end

function SpellBookFrameMixin:SetupSettingsDropdown()
	self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupHidePassivesCheckbox(rootDescription);
		if not InputUtil.IsGamepadUIEnabled() then
			self:SetupUseFlyoutsCheckbox(rootDescription);
		end

		local _, className = UnitClass("player");
		if ( className ~= "ROGUE" and className ~= "WARRIOR" ) then
			self:SetupAllRanksCheckbox(rootDescription);
		end

		if (InputUtil.IsGamepadUIEnabled()) then
			-- Add compact view toggle checkbox to the menu for gamepad.
			rootDescription:CreateDivider();

			local function IsSelected()
				return self:GetParent().MaximizeMinimizeButton:IsMinimized();
			end

			local function SetSelected()
				local isMinimized = IsSelected();

				if (isMinimized) then
					self:GetParent().MaximizeMinimizeButton:Maximize();
				else
					self:GetParent().MaximizeMinimizeButton:Minimize();
				end
			end

			local checkbox = rootDescription:CreateCheckbox(SPELLBOOK_COMPACT_VIEW, IsSelected, SetSelected);
			checkbox:SetResponse(MenuResponse.Close);
		end
	end);
end

function SpellBookFrameMixin:CreateCategoryMixins()
	self.categoryMixins = {};
	self:RemoveAllTabs();
	for skillLineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
		local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(skillLineIndex);
		if skillLineInfo and not skillLineInfo.shouldHide then
			local categoryMixin = CreateAndInitFromMixin(SpellBookSingleSkillLineCategoryMixin, self, skillLineIndex);
			table.insert(self.categoryMixins, categoryMixin);

			local tabID = self:AddIconTab(categoryMixin:GetIcon());
			categoryMixin:SetTabID(tabID);
			self.CategoryTabSystem:GetTabButton(tabID):SetTooltipText(skillLineInfo.name);
		end
	end

	local petCategoryMixin = CreateAndInitFromMixin(SpellBookPetCategoryMixin, self);
	petCategoryMixin.showHeader = true;
	table.insert(self.categoryMixins, petCategoryMixin);
	local petTabID = self:AddIconTab(GetPetIcon());
	petCategoryMixin:SetTabID(petTabID);
	self.CategoryTabSystem:GetTabButton(petTabID):SetTooltipText(petCategoryMixin:GetName());

	local transmogCategoryMixin = CreateAndInitFromMixin(SpellBookTransmogCategoryMixin, self);
	table.insert(self.categoryMixins, transmogCategoryMixin);
	local spellInfo = C_Spell.GetSpellInfo(Constants.TransmogOutfitDataConsts.CLEAR_TRANSMOG_OUTFIT_MANUAL_SPELL_ID);
	local iconID = spellInfo.iconID;
	local transmogTabID = self:AddIconTab(iconID);
	transmogCategoryMixin:SetTabID(transmogTabID);
	self.CategoryTabSystem:GetTabButton(transmogTabID):SetTooltipText(transmogCategoryMixin:GetName());
end

function SpellBookFrameMixin:HandleSpellsChanged()
	self:MarkSpellDataDirty();
end

function SpellBookFrameMixin:OnPagingButtonEnter()
	-- no-op in Camelot
end

function SpellBookFrameMixin:OnPagingButtonLeave()
	-- no-op in Camelot
end
