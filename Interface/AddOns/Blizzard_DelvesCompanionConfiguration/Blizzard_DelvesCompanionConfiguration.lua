--! TODO sounds
--! TODO art
--! TODO strings
-- TODO / NOTE when implementing the dashboard, we might not want this frame to be available while player is running a delve.
-- TODO / NOTE ^^^ we should check the "delve progress" world state (partyinfo.cpp / DELVE_COMPLETED_WORLD_STATE_ID) and disable the config button if delve is in progress

-- TODO / NOTE : Some of these are going to be temporary while data is WIP, there's a task open to get this data with a new API
--[[ LOCALS ]]
-- Brann data
local BRANN_TREE_ID = 874;
local BRANN_ROLE_NODE_ID = 99809;
local BRANN_COMBAT_TRINKET_NODE_ID = 99855;
local BRANN_UTILITY_TRINKET_NODE_ID = 99854;
local BRANN_CREATURE_DISPLAY_ID = 115505;
local BRANN_FACTION_ID = 2640;

local COMPANION_CONFIG_ON_SHOW_EVENTS = {
    "TRAIT_SYSTEM_NPC_CLOSED",
    "UPDATE_FACTION",
};

local ConfigSlotType = EnumUtil.MakeEnum(
	"Role",
	"UtilityTrinket",
	"CombatTrinket"
);

local function GetCompanionCurrentLevel()
    return DelvesCompanionConfigurationFrame.companionLevel;
end

local function GetCompanionExperienceInfo()
    return DelvesCompanionConfigurationFrame.companionExperienceInfo;
end

local function GetCompanionInfo()
    return DelvesCompanionConfigurationFrame.companionInfo;
end

local function TrySelectTrait(configID, selectionNodeID, entryID)
    return C_Traits.SetSelection(configID, selectionNodeID, entryID) and C_Traits.IsReadyForCommit() and C_Traits.CommitConfig(configID);
end

local function ShowConfigTooltip(frame, data, offsetX, offsetY)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT", offsetX, offsetY);
    if data.spellID then
        GameTooltip:SetSpellByID(data.spellID);
    elseif data.name and data.description then
        GameTooltip_SetTitle(GameTooltip, data.name);
        GameTooltip_AddNormalLine(GameTooltip, data.description);
    end
    GameTooltip:Show();
end

--[[ Config Frame ]]
DelvesCompanionConfigurationFrameMixin = {};

function DelvesCompanionConfigurationFrameMixin:OnLoad()
    local panelAttributes = {
        area = "left",
		pushable = 2,
		allowOtherPanels = 1,
        whileDead = 0,
	};
	RegisterUIPanel(self, panelAttributes);
end

function DelvesCompanionConfigurationFrameMixin:OnShow()
    self:Refresh();
    FrameUtil.RegisterFrameForEvents(self, COMPANION_CONFIG_ON_SHOW_EVENTS);
end

-- TODO will probably need events to listen to for changes to experience, attributes, etc. later on
function DelvesCompanionConfigurationFrameMixin:OnEvent(event)
    -- TODO this event may change if/when that GameObject changes (see OnHide comment)
    if event == "TRAIT_SYSTEM_NPC_CLOSED" then
        HideUIPanel(self);
    elseif event == "UPDATE_FACTION" then
        self:Refresh();
    end
end

function DelvesCompanionConfigurationFrameMixin:Refresh()
    local companionRankInfo = C_GossipInfo.GetFriendshipReputationRanks(BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionLevel = companionRankInfo and companionRankInfo.currentLevel or 0;

    local companionRepInfo = C_GossipInfo.GetFriendshipReputation(BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionExperienceInfo = {
        currentExperience = companionRepInfo.standing,
        nextLevelAt = companionRepInfo.nextThreshold,
    };

    local companionFactionInfo = C_Reputation.GetFactionDataByID(BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionInfo = {
        name = companionFactionInfo.name,
        description = companionFactionInfo.description,
    };

    self.CompanionPortraitFrame:Refresh();
    self.CompanionExperienceRingFrame:Refresh();
    self.CompanionLevelFrame:Refresh();
    self.CompanionInfoFrame:Refresh();
end

function DelvesCompanionConfigurationFrameMixin:OnHide()
    -- TODO / NOTE : GameObject we're using to open this frame currently uses gossip, this may need to change in the near future
    C_PlayerInteractionManager.ClearInteraction();
    HideUIPanel(DelvesCompanionSpellbookFrame);
    FrameUtil.UnregisterFrameForEvents(self, COMPANION_CONFIG_ON_SHOW_EVENTS);
end

--[[ Companion Portrait ]]
CompanionPortraitFrameMixin = {};

function CompanionPortraitFrameMixin:Refresh()
    SetPortraitTextureFromCreatureDisplayID(self.Icon, BRANN_CREATURE_DISPLAY_ID);
end

-- TODO placeholder code, this is going to change
function CompanionPortraitFrameMixin:OnEnter()
    local experienceInfo = GetCompanionExperienceInfo();
    local temp_DescriptionString = "[PH] Complete delves with your companion to increase their level!"; --! todo string
    local temp_progressFormatString = "[PH] Current Progress: %s"; --! todo string
    local temp_progressNumbersFormatString = WHITE_FONT_COLOR:WrapTextInColorCode(string.format("%s / %s", experienceInfo.currentExperience, experienceInfo.nextLevelAt)); --! todo string

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -5, -50);
    GameTooltip_AddNormalLine(GameTooltip, temp_DescriptionString); --! todo string
    GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1);
    GameTooltip_AddNormalLine(GameTooltip, string.format(temp_progressFormatString, temp_progressNumbersFormatString)); --! todo string
    GameTooltip:Show();
end

function CompanionPortraitFrameMixin:OnLeave()
    GameTooltip:Hide();
end

--[[ Experience Ring ]]
CompanionExperienceRingFrameMixin = {};

function CompanionExperienceRingFrameMixin:Refresh()
    local experienceInfo = GetCompanionExperienceInfo();
    if experienceInfo and experienceInfo.nextLevelAt and experienceInfo.nextLevelAt ~= 0 then
        CooldownFrame_SetDisplayAsPercentage(self, experienceInfo.currentExperience / experienceInfo.nextLevelAt);
	end
end

--[[ Companion Level ]]
CompanionLevelFrameMixin = {};

function CompanionLevelFrameMixin:Refresh()
    self.CompanionLevel:SetText(GetCompanionCurrentLevel());
end

--[[ Companion Info ]]
CompanionInfoFrameMixin = {};

function CompanionInfoFrameMixin:Refresh()
    local companionInfo = GetCompanionInfo();
    self.CompanionName:SetText(companionInfo.name);
    self.CompanionDescription:SetText(companionInfo.description);
end

--[[ Role and Trinket Slots , Options List ]]
CompanionConfigSlotTemplateMixin = {};

-- TODO need to set border color/rarity, too - hidden for now while design/gameplay set that up
function CompanionConfigSlotTemplateMixin:OnLoad()
    local view = CreateScrollBoxListLinearView(1, 0, 0, 0, 0, 1);
    view:SetElementFactory(function(factory, node) 
        local function Initializer(button)
            button.data = {
                configID = self.configID,
                selectionNodeID = self.selectionNodeID,
                entryID = node.entryID,
                spellID = node.spellID,
                name = node.name,
                description = node.description,
            };

            if node.atlas then
                button.Icon:SetAtlas(node.atlas);
                button.Border:Hide();
            elseif node.textureID then
                button.Icon:SetTexture(node.textureID);
            end
            button.Name:SetText(node.name);

            if node.selected then
                button.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
            else
                button.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB());
            end
        end
        factory("CompanionConfigListButtonTemplate", Initializer);
    end);
    self.OptionsList.ScrollBox:Init(view);

    EventRegistry:RegisterCallback("CompanionConfiguration.ListShown", self.Hide, self.OptionsList);
    EventRegistry:RegisterCallback("CompanionConfigListButton.Commit", self.Refresh, self);
end

function CompanionConfigSlotTemplateMixin:OnShow()
    self.configID = C_Traits.GetConfigIDByTreeID(BRANN_TREE_ID);
    self.selectionNodeID = self:GetSelectionNodeID();
    self:Refresh();
end

function CompanionConfigSlotTemplateMixin:OnHide()
    self.OptionsList:Hide();
end

function CompanionConfigSlotTemplateMixin:HasActiveEntry()
    return self.selectionNodeInfo.activeEntry and self.selectionNodeInfo.activeEntry.entryID;
end

function CompanionConfigSlotTemplateMixin:HasSelectionAndInfo()
    return self:HasActiveEntry() and self.selectionNodeOptions[self.selectionNodeInfo.activeEntry.entryID];
end

function CompanionConfigSlotTemplateMixin:OnEnter()
    if self:HasSelectionAndInfo() then
        local selection = self.selectionNodeOptions[self.selectionNodeInfo.activeEntry.entryID];

        ShowConfigTooltip(self, {
            spellID = selection.overriddenSpellID or selection.spellID,
            name = selection.name,
            description = selection.description,
        }, 0, -60);
    end

    self.HighlightTexture:Show();
    self.BorderHighlight:Show();
end

function CompanionConfigSlotTemplateMixin:OnLeave()
    GameTooltip:Hide();
    self.HighlightTexture:Hide();
    self.BorderHighlight:Hide();
end

function CompanionConfigSlotTemplateMixin:OnMouseDown()
    if not self:IsEnabled() then
        return;
    end
    
    if self.OptionsList:IsShown() then
        self.OptionsList:Hide();
    else
        EventRegistry:TriggerEvent("CompanionConfiguration.ListShown");
        self.OptionsList:Show();
    end
end

function CompanionConfigSlotTemplateMixin:Refresh()
    self.OptionsList:Hide();
    self:SetEnabled(true);
    self.selectionNodeInfo = C_Traits.GetNodeInfo(self.configID, self.selectionNodeID);
    self.Label:SetText(self:GetSlotLabelText());

    self:BuildSelectionNodeOptions();

    if self.selectionNodeInfo then
        if not self.selectionNodeInfo.isVisible then
            self:SetEnabled(false);
            self.Value:SetText("Locked"); --! todo string
            self.Value:SetTextColor(GRAY_FONT_COLOR:GetRGB());
            self.Label:SetTextColor(GRAY_FONT_COLOR:GetRGB());
            self.Border:SetAtlas("talents-node-pvp-locked"); -- todo art
            self.Texture:SetAtlas(nil);
            self.Texture:SetTexture(nil);
            self.HighlightTexture:SetAtlas(nil);
            self.HighlightTexture:SetTexture(nil);
        elseif self:HasSelectionAndInfo() then
            local selectedEntry = self.selectionNodeOptions[self.selectionNodeInfo.activeEntry.entryID];
            
            self.Value:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
            self.Label:SetTextColor(WHITE_FONT_COLOR:GetRGB());

            self.Value:SetText(selectedEntry.name);
            self.Border:SetAtlas("talents-node-choice-yellow");  -- todo art
            self.BorderHighlight:SetAtlas("talents-node-choice-yellow"); -- todo art
            if selectedEntry.atlas then
                self.Texture:SetAtlas(selectedEntry.atlas);
                self.Texture:SetSize(62, 68);
                self.HighlightTexture:SetAtlas(selectedEntry.atlas);
                self.HighlightTexture:SetSize(62, 68);
            elseif selectedEntry.textureID then
                self.Texture:SetTexture(selectedEntry.textureID);
                self.Texture:SetSize(50, 55);
                self.HighlightTexture:SetTexture(selectedEntry.textureID);
                self.HighlightTexture:SetSize(50, 55);
            end
        else
            self.Value:SetText(GREEN_FONT_COLOR:WrapTextInColorCode("Empty")); --! todo string
            self.Border:SetAtlas("talents-node-pvp-green");  -- todo art
            self.BorderHighlight:SetAtlas("talents-node-pvp-green"); -- todo art
            self.Texture:SetAtlas(nil);
            self.Texture:SetTexture(nil);
            self.HighlightTexture:SetTexture(nil);
        end
    end

    self:PopulateOptionsList();
end

function CompanionConfigSlotTemplateMixin:PopulateOptionsList()
    local activeEntryID = self:HasActiveEntry() and self.selectionNodeInfo.activeEntry.entryID;
    local dataProvider = CreateDataProvider();
    local buttonCount = 0;

    for id, entryInfo in pairs(self.selectionNodeOptions) do
        dataProvider:Insert({
            entryID = id,
            name = entryInfo.name,
            atlas = entryInfo.atlas,
            textureID = entryInfo.textureID,
            selected = activeEntryID == id,
            spellID = entryInfo.spellID,
            description = entryInfo.description,
        });
        buttonCount = buttonCount + 1;
    end
    self.OptionsList.ScrollBox:SetDataProvider(dataProvider);

    local buttonHeight = C_XMLUtil.GetTemplateInfo("CompanionConfigListButtonTemplate").height;
    self.OptionsList:SetHeight(buttonCount * buttonHeight);
end

function CompanionConfigSlotTemplateMixin:GetSlotLabelText()
    if ConfigSlotType[self.type] == ConfigSlotType.Role then
        return "Combat Role"; --! todo string
    elseif ConfigSlotType[self.type] == ConfigSlotType.UtilityTrinket then
        return "Utility Trinket"; --! todo string
    elseif ConfigSlotType[self.type] == ConfigSlotType.CombatTrinket then
        return "Combat Trinket" --! todo string
    else
        return nil;
    end
end

function CompanionConfigSlotTemplateMixin:GetSelectionNodeID()
    if ConfigSlotType[self.type] == ConfigSlotType.Role then
        return BRANN_ROLE_NODE_ID;
    elseif ConfigSlotType[self.type] == ConfigSlotType.UtilityTrinket then
        return BRANN_UTILITY_TRINKET_NODE_ID;
    elseif ConfigSlotType[self.type] == ConfigSlotType.CombatTrinket then
        return BRANN_COMBAT_TRINKET_NODE_ID;
    else
        return nil;
    end
end

function CompanionConfigSlotTemplateMixin:BuildSelectionNodeOptions()
    self.selectionNodeOptions = {};

    if self.selectionNodeInfo and #self.selectionNodeInfo.entryIDs > 0 then
        for _, entryID in ipairs(self.selectionNodeInfo.entryIDs) do
            local entryInfo = C_Traits.GetEntryInfo(self.configID, entryID);
            
            if self.selectionNodeInfo.type == Enum.TraitNodeType.SubTreeSelection then
                local subTreeInfo = C_Traits.GetSubTreeInfo(self.configID, entryInfo.subTreeID);

                self.selectionNodeOptions[entryID] = {
                    name = subTreeInfo.name,
                    atlas = subTreeInfo.iconElementID,
                    description = subTreeInfo.description,
                };
            elseif self.selectionNodeInfo.type == Enum.TraitNodeType.Selection then
                local definitionInfo = C_Traits.GetDefinitionInfo(entryInfo.definitionID);
                local spellID = definitionInfo.overriddenSpellID or definitionInfo.spellID;
                local spell = C_Spell.GetSpellInfo(spellID);

                self.selectionNodeOptions[entryID] = {
                    name = spell.name,
                    textureID = spell.iconID,
                    spellID = spellID,
                };
            end
        end
    end
end

--[[ Config List Button ]]
CompanionConfigListButtonMixin = {};

function CompanionConfigListButtonMixin:OnClick()
    if TrySelectTrait(self.data.configID, self.data.selectionNodeID, self.data.entryID) then
        EventRegistry:TriggerEvent("CompanionConfigListButton.Commit");
    end
end

function CompanionConfigListButtonMixin:OnEnter()
    ShowConfigTooltip(self, self.data, 2, -30);
end

function CompanionConfigListButtonMixin:OnLeave()
    GameTooltip:Hide();
end

--[[ Abilities Button ]]
CompanionConfigShowAbilitiesButtonMixin = {};

function CompanionConfigShowAbilitiesButtonMixin:OnClick()
    if not DelvesCompanionSpellbookFrame:IsShown() then
        ShowUIPanel(DelvesCompanionSpellbookFrame);
    else
        HideUIPanel(DelvesCompanionSpellbookFrame);
    end
end