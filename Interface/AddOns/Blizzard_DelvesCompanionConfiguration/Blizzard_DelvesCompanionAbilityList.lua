--! todo art
--! todo sounds

-- TODO / NOTE : Some of these are going to be temporary while data is WIP, there's a task open to get this data with a new API
--[[ LOCALS ]]
-- Brann data
local BRANN_TREE_ID = 874;
local BRANN_ROLE_NODE_ID = 99809;
local BRANN_CREATURE_DISPLAY_ID = 115505;
local BRANN_DPS_SUBTREE_ID = 29;
local BRANN_HEALER_SUBTREE_ID = 30;

-- Frame constants
local ROLE_DROPDOWN_WIDTH = 150;
local MAX_DISPLAYED_BUTTONS = 12;

local COMPANION_ABILITY_LIST_ON_SHOW_EVENTS = {
	"UPDATE_FACTION",
	"QUEST_LOG_UPDATE",
};

--[[ Ability List Frame ]]
DelvesCompanionAbilityListFrameMixin = {};

function DelvesCompanionAbilityListFrameMixin:OnLoad()
	local panelAttributes = {
		area = "left",
		pushable = 3,
		allowOtherPanels = 1,
		whileDead = 0,
	};
	RegisterUIPanel(self, panelAttributes);
	TalentFrameBaseMixin.OnLoad(self);
	self.DelvesCompanionAbilityListPagingControls:Init();
	self:ClearButtons();

	SetPortraitTextureFromCreatureDisplayID(self:GetPortrait(), BRANN_CREATURE_DISPLAY_ID); -- TODO art, not sure what we're planning for this yet
	self:SetTitle(DELVES_COMPANION_ABILITY_LIST_TITLE);
end

function DelvesCompanionAbilityListFrameMixin:ClearButtons()
	self.buttons = { nodeIDs = {}};
end

function DelvesCompanionAbilityListFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMPANION_ABILITY_LIST_ON_SHOW_EVENTS);
	self:SetConfigID(C_Traits.GetConfigIDByTreeID(BRANN_TREE_ID));
	self:SetTalentTreeID(BRANN_TREE_ID);
	TalentFrameBaseMixin.OnShow(self);
	self.DelvesCompanionAbilityListPagingControls:SetCurrentPage(1);
	self:Refresh();
end

function DelvesCompanionAbilityListFrameMixin:Refresh(ignoreDropdown, ignoreLoadTree)
	if not ignoreLoadTree then
		self:ClearButtons();
		self:LoadTalentTree();
	else
		-- If we're not (re)loading the talent tree, hide all the buttons, since we're going to 
		-- update the display soon
		for _, button in ipairs(self.buttons) do 
			button:Hide();
		end
	end

	if self.buttons then
		table.sort(self.buttons, function(a, b) 
			return a.index < b.index;
		end);

		self.ButtonsParent:ClearAllPoints();
		self.ButtonsParent:SetPoint("TOPLEFT", self.CompanionAbilityListBackground, "TOPLEFT", 0, -25);
		self.ButtonsParent:SetPoint("BOTTOMRIGHT", self.CompanionAbilityListBackground, "BOTTOMRIGHT");
	
		self:UpdatePaginatedButtonDisplay();
	end

	self.DelvesCompanionAbilityListPagingControls:SetMaxPages(math.max(math.ceil(#self.buttons / MAX_DISPLAYED_BUTTONS), 1));
	self.DelvesCompanionAbilityListPagingControls:Refresh();

	if not ignoreDropdown then
		self.DelvesCompanionRoleDropdown:Refresh();
	end
	
	-- If the ability list is opened and a player has not selected Brann's role yet, refresh with the first option selected instead
	-- so that we show *something*
	if #self.buttons == 0 and #self.DelvesCompanionRoleDropdown.dropdownOptions > 0 then
		self:SetSelection(BRANN_ROLE_NODE_ID, self.DelvesCompanionRoleDropdown.dropdownOptions[1].entryID);
		self:Refresh(true);
		self:RollbackConfig(self, true);
	end
end

function DelvesCompanionAbilityListFrameMixin:UpdatePaginatedButtonDisplay()
	self.buttonHeight = self.buttonHeight or C_XMLUtil.GetTemplateInfo(self:GetTemplateForTalentType()).height;
	local prevButton = nil;
	local numShownButtons = 0;
	local row = 0;
	local col = 1;

	-- +1 so that we either start at 1, or one-past the last page, so we don't display duplicates
	local startIndex = ((self.DelvesCompanionAbilityListPagingControls.currentPage - 1) * MAX_DISPLAYED_BUTTONS) + 1;
	for i = startIndex, #self.buttons, 1 do
		local button = self.buttons[i];

		if button and numShownButtons < MAX_DISPLAYED_BUTTONS then
			button:ClearAllPoints();
			
			-- NOTE: Only supporting 2 columns of buttons, if that ever incrases this logic would need to change
			-- to anchor buttons 3..MAX to the prevButton - not using a constant here so that this note is seen.
			if (col % 2) ~= 0 then
				button:SetPoint("TOPLEFT", self.ButtonsParent, "TOPLEFT", 25, -((self.buttonHeight * row) + (10 * row)));
				col = col + 1;
			else
				if prevButton then
					button:SetPoint("LEFT", prevButton, "RIGHT", 50, 0);
					col = 1;
					row = row + 1;
				end
			end
			
			button:Show();
			numShownButtons = numShownButtons + 1;
			prevButton = button;
		end
	end
end

function DelvesCompanionAbilityListFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMPANION_ABILITY_LIST_ON_SHOW_EVENTS);
	TalentFrameBaseMixin.OnHide(self);

	-- We set the selection with the dropdown to preview abilities, but we don't want to save that selection, so roll it back
	-- and mark the tree as dirty so it refreshes properly on reopen
	self:RollbackConfig(true);
	self:MarkTreeDirty();
end

function DelvesCompanionAbilityListFrameMixin:OnEvent(event, ...)
	if not self:IsShown() then
		return;
	end

	if event == "TRAIT_CONFIG_UPDATED" then
		TalentFrameBaseMixin.OnEvent(self, event, ...);
		self.DelvesCompanionAbilityListPagingControls:SetCurrentPage(1);
		self:Refresh();
	elseif event == "UPDATE_FACTION" or event == "QUEST_LOG_UPDATE" then
		self:Refresh();
	end
end

function DelvesCompanionAbilityListFrameMixin:OnUpdate(...)
	TalentFrameBaseMixin.OnUpdate(self, ...);
end

--[[ Ability List Frame: SharedTalentFrame overrides and utilities ]]
function DelvesCompanionAbilityListFrameMixin:GetTemplateForTalentType(...)
	return "DelvesCompanionAbilityTemplate";
end

function DelvesCompanionAbilityListFrameMixin:InstantiateTalentButton(nodeID, nodeInfo)
	nodeInfo = nodeInfo or self:GetAndCacheNodeInfo(nodeID);
	-- TODO / NOTE -> Companion paragon trait uses the tiered type, and it is not yet fully implemented. Some changes may be required here when it is ready
	if nodeInfo.type == Enum.TraitNodeType.Single or nodeInfo.type == Enum.TraitNodeType.Tiered then
		local button = TalentFrameBaseMixin.InstantiateTalentButton(self, nodeID, nodeInfo);
		
		if not button then
			return;
		end

		button:Hide();
		button.index = self:GetIndexFromNodePosition(nodeInfo.posX, nodeInfo.posY);
		button:InitAdditionalElements();
		local buttonElementsExist = button.Name:GetText() and button.Icon:GetTexture();
		if nodeInfo.subTreeActive and buttonElementsExist then
			if not self.buttons.nodeIDs[button.nodeID] then
				tinsert(self.buttons, button);
				self.buttons.nodeIDs[button.nodeID] = true;
			end
		end
	else
		-- Ignore selection and subtree selection nodes in this frame
		return;
	end
end

--[[ Ability Template ]]
DelvesCompanionAbilityMixin = CreateFromMixins(TalentDisplayMixin);

function DelvesCompanionAbilityMixin:InitAdditionalElements()
	self.Name:SetText(self:GetName());

	if not self:HasProgress() then
		local conditionText = "";
		if #self.nodeInfo.conditionIDs > 0 then
			local conditionInfo = self:GetTalentFrame():GetAndCacheCondInfo(self.nodeInfo.conditionIDs[1], true);
			conditionText = conditionInfo.tooltipText;
		end

		self.Icon:SetDesaturated(true);
		self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		self.UnlockCondition:SetText(conditionText);
		self.Rank:SetText("");
	else
		self.Icon:SetDesaturated(false);
		self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.UnlockCondition:SetText("");
		if self.nodeInfo.maxRanks > 1 then
			self.Rank:SetText(DELVES_ABILITY_RANK_LABEL:format(self.nodeInfo.currentRank));
		end
	end
end

--[[ Ability Template: SharedTalentButton Overrides ]]
function DelvesCompanionAbilityMixin:GetButtonSize()
	return self:GetSize();
end

-- Do nothing, don't want to change the size we've already set in XML
function DelvesCompanionAbilityMixin:SetAndApplySize()
end

-- Do nothing, we aren't using a state border right now
function DelvesCompanionAbilityMixin:UpdateStateBorder()
end

--[[ Role Dropdown ]]
DelvesCompanionRoleDropdownMixin = {};

function DelvesCompanionRoleDropdownMixin:OnLoad()
	self.selectedOption = nil;
end

function DelvesCompanionRoleDropdownMixin:OnShow()
	UIDropDownMenu_SetWidth(self, ROLE_DROPDOWN_WIDTH);
	UIDropDownMenu_JustifyText(self, "LEFT");
end

function DelvesCompanionRoleDropdownMixin:Refresh()
	local abilityListFrame = self:GetParent();

	self:PopulateDropdownOptions();
	
	for idx, option in ipairs(self.dropdownOptions) do
		if option.active then 
			self.selectedOption = idx;
		end
	end

	UIDropDownMenu_Initialize(self, function() 
		for idx, option in ipairs(self.dropdownOptions) do
			local button = {};

			local iconSize = 16;
			local text = option.name;
			if option.dropdownIconAtlas then
				text = DELVES_ABILITY_LIST_DROPDOWN_OPTION_LABEL:format(CreateAtlasMarkup(option.dropdownIconAtlas, iconSize, iconSize), option.name);
			end

			button.text = text;
			button.value = idx;
			button.func = function()
				if button.value == self.selectedOption then return end;
				if not option.active then
					abilityListFrame:SetSelection(BRANN_ROLE_NODE_ID, option.entryID);
				end
				abilityListFrame:Refresh(true);
				abilityListFrame:RollbackConfig(self, true);
				UIDropDownMenu_SetSelectedValue(self, idx);
				self.selectedOption = idx;
			end;
			button.minWidth = ROLE_DROPDOWN_WIDTH;

			if self.selectedOption then
				button.checked = self.selectedOption == idx;
			else
				button.checked = option.active;
				self.selectedOption = idx;
			end

			UIDropDownMenu_AddButton(button);
		end
	end);

	UIDropDownMenu_SetSelectedValue(self, self.selectedOption);
end

function DelvesCompanionRoleDropdownMixin:PopulateDropdownOptions()
	self.dropdownOptions = {};
	local abilityListFrame = self:GetParent();
	local roleNode = abilityListFrame:GetAndCacheNodeInfo(BRANN_ROLE_NODE_ID);

	for _, entryID in ipairs(roleNode.entryIDs) do
		local entryInfo = abilityListFrame:GetAndCacheEntryInfo(entryID);
		local subTreeInfo = abilityListFrame:GetAndCacheSubTreeInfo(entryInfo.subTreeID);

		local dropdownIconAtlas = nil;
		if entryInfo.subTreeID == BRANN_DPS_SUBTREE_ID then
			dropdownIconAtlas = "roleicon-tiny-dps";
		elseif entryInfo.subTreeID == BRANN_HEALER_SUBTREE_ID then
			dropdownIconAtlas = "roleicon-tiny-healer";
		end

		tinsert(self.dropdownOptions, {
			active = subTreeInfo.isActive,
			name = subTreeInfo.name,
			dropdownIconAtlas = dropdownIconAtlas,
			entryID = entryID,
		});
	end
end

DelvesCompanionAbilityListPagingControlsMixin = {};

function DelvesCompanionAbilityListPagingControlsMixin:Init()
	self.maxPages = 1;
	self.currentPage = 1;

	self.NextPageButton:SetScript("OnClick", function()
		self.currentPage = Clamp(self.currentPage + 1, 1, self.maxPages);
		self:GetParent():Refresh(true, true);
	end);

	self.PrevPageButton:SetScript("OnClick", function()
		self.currentPage = Clamp(self.currentPage - 1, 1, self.maxPages);
		self:GetParent():Refresh(true, true);
	end);
end

function DelvesCompanionAbilityListPagingControlsMixin:SetMaxPages(maxPages)
	self.maxPages = maxPages;
end

function DelvesCompanionAbilityListPagingControlsMixin:SetCurrentPage(page)
	self.currentPage = page;
end

function DelvesCompanionAbilityListPagingControlsMixin:Refresh()
	self.PageText:SetText(DELVES_ABILITY_LIST_CURRENT_PAGE:format(self.currentPage, self.maxPages));
	self.NextPageButton:SetEnabled(self.maxPages > 1 and self.currentPage < self.maxPages);
	self.PrevPageButton:SetEnabled(self.currentPage > 1);
end