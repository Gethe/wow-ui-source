--! todo art
--! todo strings
--! todo sounds

--! TODO / NOTE : Usage of traits here is going to be refactored, a bunch of this is placeholder

-- TODO / NOTE : Some of these are going to be temporary while data is WIP, there's a task open to get this data with a new API
--[[ LOCALS ]]
-- Brann data
local BRANN_TREE_ID = 874;
local BRANN_ROLE_NODE_ID = 99809;
local BRANN_CREATURE_DISPLAY_ID = 115505;

local COMPANION_SPELLBOOK_ON_SHOW_EVENTS = {
	"UPDATE_FACTION",
	"QUEST_LOG_UPDATE",
};

local ROLE_DROPDOWN_WIDTH = 150;

local function GetRolesAndAbilities()
	return DelvesCompanionSpellbookFrame.rolesAndAbilities;
end

--[[ Spellbook Frame ]]
DelvesCompanionSpellbookFrameMixin = {};

function DelvesCompanionSpellbookFrameMixin:OnLoad()
	local panelAttributes = {
		area = "left",
		pushable = 2,
		allowOtherPanels = 1,
		whileDead = 0,
	};
	RegisterUIPanel(self, panelAttributes);

	EventRegistry:RegisterCallback("CompanionConfigListButton.Commit", self.Refresh, self);

	SetPortraitTextureFromCreatureDisplayID(self:GetPortrait(), BRANN_CREATURE_DISPLAY_ID); -- TODO art, not sure what we're planning for this yet
	self:SetTitle("Delve Companion Abilities"); --! TODO string
end

function DelvesCompanionSpellbookFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMPANION_SPELLBOOK_ON_SHOW_EVENTS);
	self.configID = C_Traits.GetConfigIDByTreeID(BRANN_TREE_ID);
	self:Refresh();
end

function DelvesCompanionSpellbookFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMPANION_SPELLBOOK_ON_SHOW_EVENTS);
end

function DelvesCompanionSpellbookFrameMixin:OnEvent(event)
	if event == "UPDATE_FACTION" or "QUEST_LOG_UPDATE" then
		self:Refresh();
	end
end

function DelvesCompanionSpellbookFrameMixin:Refresh()
	if self:IsShown() then
		self.roleNodeInfo = C_Traits.GetNodeInfo(self.configID, BRANN_ROLE_NODE_ID);
		self:BuildTreeNodeSpellInfos();
		self:BuildRolesAndAbilities();
		self:RefreshPaginatedAbilityList();
		self.DelvesCompanionSpellbookRoleDropdown:Refresh();
	end
end

-- Iterate over all tree nodes for companion, get their subtrees and definitions (spell info), and put into table.
-- Will be used to build `abilities` property of self.roleAndAbiltiies
function DelvesCompanionSpellbookFrameMixin:BuildTreeNodeSpellInfos()
	local treeNodes = C_Traits.GetTreeNodes(BRANN_TREE_ID);
	self.treeNodeSpellInfos = {};

	for _, nodeID in pairs(treeNodes) do
		local node = {};
		local nodeInfo = C_Traits.GetNodeInfo(self.configID, nodeID);

		-- Delve traits should only have one condition, if there are any, grab the first
		node.conditionText = "";
		if #nodeInfo.conditionIDs > 0 then
			local conditionInfo = C_Traits.GetConditionInfo(self.configID, nodeInfo.conditionIDs[1], true);
			node.conditionText = conditionInfo.tooltipText;
		end

		node.subTreeID = nodeInfo.subTreeID;
		node.unlocked = nodeInfo.activeRank > 0;

		for _, entryID in pairs(nodeInfo.entryIDs) do
			local entryInfo = C_Traits.GetEntryInfo(self.configID, entryID);
			node.orderIndex = C_Traits.GetOrderIndexByNodeEntryID(entryID);

			if entryInfo.definitionID then
				local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID);
				local spellID = definitionInfo.overriddenSpellID or definitionInfo.spellID;
				node.spell = spellID and C_Spell.GetSpellInfo(spellID);
				break;
			end
		end

		if node.subTreeID and node.spell then
			tinsert(self.treeNodeSpellInfos, node);
		end
	end

	table.sort(self.treeNodeSpellInfos, function(a, b)
		return a.orderIndex < b.orderIndex;
	end);
end

-- Organize relevant information about a role from BRANN_ROLE_NODE_ID's selection(s) into a table, keyed by role.
function DelvesCompanionSpellbookFrameMixin:BuildRolesAndAbilities()
	self.rolesAndAbilities = {};

	for _, entryID in ipairs(self.roleNodeInfo.entryIDs) do
		local entryInfo = C_Traits.GetEntryInfo(self.configID, entryID);
		local subTreeInfo = C_Traits.GetSubTreeInfo(self.configID, entryInfo.subTreeID);

		local subTreeAbilities = {};
		for _, nodeSpellInfo in pairs(self.treeNodeSpellInfos) do
			if nodeSpellInfo.subTreeID == entryInfo.subTreeID then
				nodeSpellInfo.templateKey = "ABILITY";
				tinsert(subTreeAbilities, nodeSpellInfo);
			end
		end

		local atlasTiny = nil;
		if string.find(string.lower(subTreeInfo.iconElementID), "dps") then
			atlasTiny = "roleicon-tiny-dps";
		elseif string.find(string.lower(subTreeInfo.iconElementID), "healer") then
			atlasTiny = "roleicon-tiny-healer";
		end

		tinsert(self.rolesAndAbilities, {
			active = self.roleNodeInfo.activeEntry and self.roleNodeInfo.activeEntry.entryID == entryID,
			name = subTreeInfo.name,
			atlas = subTreeInfo.iconElementID,
			atlasTiny = atlasTiny, -- for the uidropdown icon
			description = subTreeInfo.description,
			elements = subTreeAbilities, -- named elements, since PagedContentFrame expects it
		});
	end
end

function DelvesCompanionSpellbookFrameMixin:RefreshPaginatedAbilityList()
	local template = {
		["ABILITY"] = {
			template = "DelvesCompanionSpellbookAbilityTemplate",
			initFunc = DelvesCompanionSpellbookAbilityTemplateMixin.Init,
		}
	};

	for _, role in ipairs(self.rolesAndAbilities) do
		if role.active then
			self.activeRole = role;
			break;
		end
	end

	self.DelvesCompanionSpellbookPagedCellSizeGrid:SetElementTemplateData(template);
	local dataProvider = CreateDataProvider({self.activeRole});
	self.DelvesCompanionSpellbookPagedCellSizeGrid:SetDataProvider(dataProvider);
end

function DelvesCompanionSpellbookFrameMixin:SetAbilityListToRole(role)
	local dataProvider = CreateDataProvider(role);
	self.DelvesCompanionSpellbookPagedCellSizeGrid:SetDataProvider(dataProvider);
end

--[[ Ability Template ]]
DelvesCompanionSpellbookAbilityTemplateMixin = {};

function DelvesCompanionSpellbookAbilityTemplateMixin:Init(data)
	if data and data.spell then
		self.spell = data.spell;
		self.Texture:SetTexture(self.spell.iconID);
		self.Name:SetText(self.spell.name);

		if not data.unlocked then
			self.Texture:SetDesaturated(true);
			self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
			self.UnlockCondition:SetText(data.conditionText);
		else
			self.Texture:SetDesaturated(false);
			self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			self.UnlockCondition:SetText("");
		end
	end
end

function DelvesCompanionSpellbookAbilityTemplateMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -175, -20);
	GameTooltip:SetSpellByID(self.spell.spellID);
    GameTooltip:Show();
end

function DelvesCompanionSpellbookAbilityTemplateMixin:OnLeave()
	GameTooltip:Hide()
end

--[[ Role Dropdown ]]
DelvesCompanionSpellbookRoleDropdownMixin = {};

function DelvesCompanionSpellbookRoleDropdownMixin:OnShow()
	UIDropDownMenu_SetWidth(self, ROLE_DROPDOWN_WIDTH);
	UIDropDownMenu_JustifyText(self, "LEFT");
end

function DelvesCompanionSpellbookRoleDropdownMixin:Refresh()
	self.selected = nil;
	local rolesAndAbilities = GetRolesAndAbilities();
	
	for idx, roleAndAbilityInfo in ipairs(rolesAndAbilities) do
		if roleAndAbilityInfo.active then 
			self.selected = idx;
		end
	end

	UIDropDownMenu_Initialize(self, function() 
		for idx, roleAndAbilityInfo in ipairs(rolesAndAbilities) do
			local button = {};

			local iconSize = 16;
			local text = roleAndAbilityInfo.name;
			if roleAndAbilityInfo.atlasTiny then
				text = string.format("%s %s", CreateAtlasMarkup(roleAndAbilityInfo.atlasTiny, iconSize, iconSize), roleAndAbilityInfo.name); --! todo string
			end

			button.text = text;
			button.value = idx;
			button.func = function() 
				self:GetParent():SetAbilityListToRole({roleAndAbilityInfo});
				UIDropDownMenu_SetSelectedValue(self, idx);
				self.selected = idx;
			end;
			button.minWidth = ROLE_DROPDOWN_WIDTH;

			if self.selected then
				button.checked = self.selected == idx;
			else
				button.checked = roleAndAbilityInfo.active;
				self.selected = idx;
			end

			UIDropDownMenu_AddButton(button);
		end
	end);

	UIDropDownMenu_SetSelectedValue(self, self.selected);
end