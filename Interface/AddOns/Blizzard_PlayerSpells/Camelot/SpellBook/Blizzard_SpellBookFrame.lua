-- Keep these in sync with spellbook page template widths.
-- If changed, update XML on:
--   - PagedSpellsView1Template Size x
--   - PagedSpellsView2Template Size x
local MKB_VIEW_WIDTH = 448;
local GAMEPAD_VIEW_WIDTH = 490;
local MKB_COLUMNS_PER_ROW = 2;
local GAMEPAD_COLUMNS_PER_ROW = 2;

-- Keep these in sync with spellbook frame and top bar XML key values.
-- If changed, update XML on:
--   - SpellBookFrame KeyValue minimizedWidth
--   - SpellBookFrame KeyValue maximizedWidth
--   - SpellBookFrame Size x
--   - SpellBookTopBarTemplate Size x
--   - SpellBookFrameTemplate KeyValue topBarFullWidth
local MKB_SPELLBOOK_MIN_WIDTH = 574;
local MKB_SPELLBOOK_MAX_WIDTH = 1148;
local MKB_TOPBAR_FULL_WIDTH = 1150;

local GAMEPAD_SPELLBOOK_MIN_WIDTH = 706;
local GAMEPAD_SPELLBOOK_MAX_WIDTH = 1512;
local GAMEPAD_TOPBAR_FULL_WIDTH = 1514;

function SpellBookFrameMixin:ApplyInputModeSizing()
	local useGamepadSizing = InputUtil.IsGamepadUIEnabled();
	self.PagedSpellsFrame.columnsPerRow = useGamepadSizing and GAMEPAD_COLUMNS_PER_ROW or MKB_COLUMNS_PER_ROW;

	local viewWidth = useGamepadSizing and GAMEPAD_VIEW_WIDTH or MKB_VIEW_WIDTH;
	for _, viewFrame in ipairs(self.PagedSpellsFrame.ViewFrames) do
		viewFrame:SetWidth(viewWidth);
	end

	self.minimizedWidth = useGamepadSizing and GAMEPAD_SPELLBOOK_MIN_WIDTH or MKB_SPELLBOOK_MIN_WIDTH;
	self.maximizedWidth = useGamepadSizing and GAMEPAD_SPELLBOOK_MAX_WIDTH or MKB_SPELLBOOK_MAX_WIDTH;
	self.topBarFullWidth = useGamepadSizing and GAMEPAD_TOPBAR_FULL_WIDTH or MKB_TOPBAR_FULL_WIDTH;

	local currentWidth = self.isMinimized and self.minimizedWidth or self.maximizedWidth;
	self.TopBar:SetWidth(currentWidth);
	self.TopBar:SetTexCoord(0, currentWidth / self.topBarFullWidth, 0, 1);
end

local BaseOnLoad = SpellBookFrameMixin.OnLoad;
function SpellBookFrameMixin:OnLoad()
	BaseOnLoad(self);
	self:ApplyInputModeSizing();
end

function SpellBookFrameMixin:OnShow()
	self:ApplyInputModeSizing();
	self:OnShowBase();

	PlayerSpellsFrame:UpdateSize();

	self.BookCornerFlipbook:Hide();
end

local BaseUpdateAttic = SpellBookFrameMixin.UpdateAttic;
function SpellBookFrameMixin:UpdateAttic()
	BaseUpdateAttic(self);

	if not AssistedCombatManager:HasActionSpell() then
		self.SettingsDropdown:ClearAllPoints();
		self.SettingsDropdown:SetPoint("TOPRIGHT", -20, self.SettingsDropdown.yOffset);
		self:ResizeSearchBox();
	end
end

local SEARCH_BOX_WIDTH_OFFSET = 10;
local GAMEPAD_SEARCH_BOX_WIDTH_OFFSET = 60;
local BaseResizeSearchBox = SpellBookFrameMixin.ResizeSearchBox;
function SpellBookFrameMixin:ResizeSearchBox()
	BaseResizeSearchBox(self);

	local widthOffset = InputUtil.IsGamepadUIEnabled() and SEARCH_BOX_WIDTH_OFFSET or GAMEPAD_SEARCH_BOX_WIDTH_OFFSET;
	self.SearchBox:SetWidth(math.max(1, self.SearchBox:GetWidth() - widthOffset));
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
