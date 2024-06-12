--! todo art
--! todo sounds

--[[ LOCALS ]]
local MAX_DISPLAYED_BUTTONS = 12;
local LAST_LOCKED_ABILITIES_CVAR = "lastLockedDelvesCompanionAbilities";
local UPDATE_LAST_LOCKED_ABILITIES_DELAY = 0.2; -- 200ms

local COMPANION_ABILITY_LIST_ON_SHOW_EVENTS = {
	"UPDATE_FACTION",
	"QUEST_LOG_UPDATE",
};

-- Update the cvar list of locked abilities, so we know when to show the "new" ability glow
local function UpdateLastLockedAbilities()
	C_Timer.After(UPDATE_LAST_LOCKED_ABILITIES_DELAY, function() 
		local lastLockedAbilities = "";
		local configID = C_Traits.GetConfigIDByTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID);

		-- configID can be nil if player has not set up their companion yet
		if not configID then
			return;
		end

		local nodes = C_Traits.GetTreeNodes(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID);
		for _, node in ipairs(nodes) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, node);
			if nodeInfo and nodeInfo.activeRank < 1 then
				lastLockedAbilities = lastLockedAbilities .. tostring(node) .. " ";
			end
		end
		SetCVar(LAST_LOCKED_ABILITIES_CVAR, lastLockedAbilities);
	end);
end

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

	SetPortraitTextureFromCreatureDisplayID(self:GetPortrait(), Constants.DelvesConsts.BRANN_CREATURE_DISPLAY_ID);
	self:SetTitle(DELVES_COMPANION_ABILITY_LIST_TITLE);
	UpdateLastLockedAbilities();
end

function DelvesCompanionAbilityListFrameMixin:ClearButtons()
	self.buttons = { nodeIDs = {}};
end

function DelvesCompanionAbilityListFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMPANION_ABILITY_LIST_ON_SHOW_EVENTS);
	self:SetConfigID(C_Traits.GetConfigIDByTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID));
	self:SetTalentTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID);
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

		-- Now that the buttons are sorted, check to see what the last locked abilities were. If any
		-- are no longer locked, then give them a glow!
		local lastLockedAbilities = GetCVar(LAST_LOCKED_ABILITIES_CVAR);
		if lastLockedAbilities then
			for _, button in ipairs(self.buttons) do
				if button.locked then
					button.NewGlow:Hide();
				elseif not button.locked and string.find(lastLockedAbilities, tostring(button.nodeID)) then
					button.NewGlow:Show();
					button:SetScript("OnHide", function(button)
						button.NewGlow:Hide();
					end);
				end
			end
		end

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
	if #self.buttons == 0 and #self.DelvesCompanionRoleDropdown.options > 0 then
		self:SetSelection(Constants.DelvesConsts.BRANN_ROLE_NODE_ID, self.DelvesCompanionRoleDropdown.options[1].entryID);
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
				button:SetPoint("TOPLEFT", self.ButtonsParent, "TOPLEFT", 20, -((self.buttonHeight * row) + (10 * row)));
				col = col + 1;
			else
				if prevButton then
					button:SetPoint("LEFT", prevButton, "RIGHT", 35, 0);
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
	UpdateLastLockedAbilities();
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

-- The condition being in the tooltip here would be redundant, since we show it under the ability name
-- So, remove it via override
function DelvesCompanionAbilityListFrameMixin:AddConditionsToTooltip(...)
end

function DelvesCompanionAbilityListFrameMixin:InstantiateTalentButton(nodeID, nodeInfo)
	nodeInfo = nodeInfo or self:GetAndCacheNodeInfo(nodeID);
	-- TODO / NOTE -> Companion paragon trait uses the tiered type, and it is not yet fully implemented. Some changes may be required here when it is ready
	if nodeInfo.type == Enum.TraitNodeType.Single or nodeInfo.type == Enum.TraitNodeType.Tiered then
		local button = TalentFrameBaseMixin.InstantiateTalentButton(self, nodeID, nodeInfo);
		
		if not button then
			return;
		end

		button.index = self:GetIndexFromNodePosition(nodeInfo.posX, nodeInfo.posY);
		button:Hide();
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

function DelvesCompanionAbilityListFrameMixin:OnMouseWheel(direction)
	local pagingControls = self.DelvesCompanionAbilityListPagingControls;

	local currentPage = pagingControls.currentPage or 1;
	local maxPages = pagingControls.maxPages or 1;

	if direction > 0 and currentPage > 1 then
		self.DelvesCompanionAbilityListPagingControls:SetCurrentPage(currentPage - 1);
	elseif direction < 0 and currentPage < maxPages then
		self.DelvesCompanionAbilityListPagingControls:SetCurrentPage(currentPage + 1);
	end

	self:Refresh(true, true);
end

--[[ Ability Template ]]
DelvesCompanionAbilityMixin = CreateFromMixins(TalentDisplayMixin);

function DelvesCompanionAbilityMixin:InitAdditionalElements()
	self.Name:SetText(self:GetName());

	if not self:HasProgress() then
		self.locked = true;
		local conditionText = "";
		for _, conditionID in ipairs(self.nodeInfo.conditionIDs) do
			local conditionInfo = self:GetTalentFrame():GetAndCacheCondInfo(conditionID, true);
			if conditionInfo.tooltipText then
				conditionText = conditionInfo.tooltipText;
				break;
			end
		end

		self.Icon:SetDesaturated(true);
		self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		self.UnlockCondition:SetText(conditionText);
		self.Rank:SetText("");
	else
		self.locked = false;
		self.Icon:SetDesaturated(false);
		self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.UnlockCondition:SetText("");
		if self.nodeInfo.maxRanks > 1 then
			self.Rank:SetText(DELVES_ABILITY_RANK_LABEL:format(self.nodeInfo.currentRank));
		else
			self.Rank:SetText("");
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

function DelvesCompanionAbilityMixin:SetTooltipInternal()
	TalentDisplayMixin.SetTooltipInternal(self, self.nodeInfo.maxRanks <= 1);
end

--[[ Role Dropdown ]]
DelvesCompanionRoleDropdownMixin = {};

function DelvesCompanionRoleDropdownMixin:OnLoad()
	WowStyle1DropdownMixin.OnLoad(self);

	self:SetWidth(150);
	
	self.selectedEntryID = nil;
	end

local function GetRoleOptionText(option)
	if option.iconAtlas then
			local iconSize = 16;
		local fmt = CreateAtlasMarkup(option.iconAtlas, iconSize, iconSize);
		return DELVES_ABILITY_LIST_DROPDOWN_OPTION_LABEL:format(fmt, option.name);
			end
	return option.name;
				end

local function GetRoleIconAtlas(entryInfo)
	if entryInfo.subTreeID == Constants.DelvesConsts.BRANN_DPS_SUBTREE_ID then
		return "roleicon-tiny-dps";
	elseif entryInfo.subTreeID == Constants.DelvesConsts.BRANN_HEALER_SUBTREE_ID then
		return "roleicon-tiny-healer";
			end
	return nil;
		end

function DelvesCompanionRoleDropdownMixin:Refresh()
	local abilityListFrame = self:GetParent();
	local roleNode = abilityListFrame:GetAndCacheNodeInfo(Constants.DelvesConsts.BRANN_ROLE_NODE_ID);

	self.options = {};
	for idx, entryID in ipairs(roleNode.entryIDs) do
		local entryInfo = abilityListFrame:GetAndCacheEntryInfo(entryID);
		local subTreeInfo = abilityListFrame:GetAndCacheSubTreeInfo(entryInfo.subTreeID);
		local isActive = subTreeInfo.isActive;
		if isActive then
			self.selectedEntryID = entryID;
		end

		tinsert(self.options, {
			isActive = isActive,
			name = subTreeInfo.name,
			iconAtlas = GetRoleIconAtlas(entryInfo),
			entryID = entryID,
		});
	end

	local function IsSelected(option)
		return self.selectedEntryID == option.entryID;
	end

	local function SetSelected(option)
		if self.selectedEntryID ~= option.entryID then 
			self.selectedEntryID = option.entryID;

			if not option.isActive then
				abilityListFrame:SetSelection(Constants.DelvesConsts.BRANN_ROLE_NODE_ID, option.entryID);
			end

			abilityListFrame:Refresh(true);
			abilityListFrame:RollbackConfig(self, true);
		end
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_DELVES_ABILITY_LIST");

		for idx, option in ipairs(self.options) do
			local text = GetRoleOptionText(option);
			rootDescription:CreateRadio(text, IsSelected, SetSelected, option);
		end
	end);
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