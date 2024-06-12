--! TODO sounds
--! TODO art

--[[ LOCALS ]]
-- NOTE: This creature is used to open the companion config panel, but may be changed to a gameobject in the near future
local DELVES_SUPPLIES_CREATURE_ID = 207283;
local DELVES_SUPPLIES_MAX_DISTANCE = 10;

local SET_SEEN_CURIOS_DELAY = 0.2; -- 200ms
local REFRESH_SEEN_CURIOS_DELAY = 0.5 -- 500ms

local COMPANION_CONFIG_ON_SHOW_EVENTS = {
    "TRAIT_SYSTEM_NPC_CLOSED",
    "UPDATE_FACTION",
    "QUEST_LOG_UPDATE",
    "UNIT_SPELLCAST_SUCCEEDED",
};

local borderColorForRarity = {
    [Enum.CurioRarity.Uncommon] = UNCOMMON_GREEN_COLOR,
    [Enum.CurioRarity.Rare] = RARE_BLUE_COLOR,
    [Enum.CurioRarity.Epic] = EPIC_PURPLE_COLOR,
};

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
        local isPet = false;
        local showSubtext = true;
        GameTooltip:SetSpellByID(data.spellID, isPet, showSubtext);
    elseif data.name and data.description then
        GameTooltip_SetTitle(GameTooltip, data.name);
        GameTooltip_AddNormalLine(GameTooltip, data.description);
    end
    GameTooltip:Show();
end

local function AcknowledgeUnseenCurios()
    DelvesCompanionConfigurationFrame.unseenCuriosAcknowledged = true;
end

local function UnacknowledgeUnseenCurios()
    DelvesCompanionConfigurationFrame.unseenCuriosAcknowledged = false;
end

local function UnseenCuriosAcknowledged()
    return DelvesCompanionConfigurationFrame.unseenCuriosAcknowledged;
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
    self.unseenCuriosAcknowledged = false;
end

function DelvesCompanionConfigurationFrameMixin:OnShow()
    AcknowledgeUnseenCurios();
    self:Refresh();
    FrameUtil.RegisterFrameForEvents(self, COMPANION_CONFIG_ON_SHOW_EVENTS);
end

function DelvesCompanionConfigurationFrameMixin:OnEvent(event)
    -- TODO this event may change if/when that GameObject changes (see OnHide comment)
    if self:IsShown() then
        if event == "TRAIT_SYSTEM_NPC_CLOSED" then
            HideUIPanel(self);
        elseif event == "UPDATE_FACTION" then
            self:Refresh();
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            C_Timer.After(REFRESH_SEEN_CURIOS_DELAY, function()
                UnacknowledgeUnseenCurios();
                self.CompanionCombatTrinketSlot:Refresh();
                self.CompanionUtilityTrinketSlot:Refresh();
            end);
        end
    end
end

function DelvesCompanionConfigurationFrameMixin:Refresh()
    local companionRankInfo = C_GossipInfo.GetFriendshipReputationRanks(Constants.DelvesConsts.BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionLevel = companionRankInfo and companionRankInfo.currentLevel or 0;

    local companionRepInfo = C_GossipInfo.GetFriendshipReputation(Constants.DelvesConsts.BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionExperienceInfo = {
        currentExperience = companionRepInfo.standing - companionRepInfo.reactionThreshold,
        nextLevelAt = companionRepInfo.nextThreshold - companionRepInfo.reactionThreshold,
    };

    local companionFactionInfo = C_Reputation.GetFactionDataByID(Constants.DelvesConsts.BRANN_FACTION_ID);
    DelvesCompanionConfigurationFrame.companionInfo = {
        name = companionFactionInfo.name,
        description = companionFactionInfo.description,
    };

    self.CompanionPortraitFrame:Refresh();
    self.CompanionExperienceRingFrame:Refresh();
    self.CompanionLevelFrame:Refresh();
    self.CompanionInfoFrame:Refresh();
end

-- TODO / NOTE : GameObject we're using to open this frame currently uses gossip, ClearInteraction call may need to be removed in the near future
function DelvesCompanionConfigurationFrameMixin:OnHide()
    UnacknowledgeUnseenCurios();
    C_PlayerInteractionManager.ClearInteraction();
    FrameUtil.UnregisterFrameForEvents(self, COMPANION_CONFIG_ON_SHOW_EVENTS);
end

--[[ Companion Portrait ]]
CompanionPortraitFrameMixin = {};

function CompanionPortraitFrameMixin:Refresh()
    SetPortraitTextureFromCreatureDisplayID(self.Icon, Constants.DelvesConsts.BRANN_CREATURE_DISPLAY_ID);
end

function CompanionPortraitFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -5, -50);
	GameTooltip_AddWidgetSet(GameTooltip, Constants.DelvesConsts.DELVE_COMPANION_TOOLTIP_WIDGET_SET_ID);
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
                isUnseen = node.isUnseen,
            };

            if node.atlas then
                button.Icon:SetAtlas(node.atlas);
                button.Border:Hide();
            elseif node.textureID then
                button.Icon:SetTexture(node.textureID);
            end
            button.Name:SetText(node.name);
            button.selected = node.selected;

            if node.borderColor then
                button.Border:SetVertexColor(node.borderColor:GetRGB());
            else
                button.Border:SetVertexColor(1, 1, 1);
            end
        end
        factory("CompanionConfigListButtonTemplate", Initializer);
    end);
    self.OptionsList.ScrollBox:Init(view);

    EventRegistry:RegisterCallback("CompanionConfiguration.ListShown", self.Hide, self.OptionsList);
    EventRegistry:RegisterCallback("CompanionConfigListButton.Commit", self.Refresh, self);

    self.selectionNodeID = self:GetSelectionNodeID();

    self:SetSeenCurios();
end

function CompanionConfigSlotTemplateMixin:SetSeenCurios()
    C_Timer.After(SET_SEEN_CURIOS_DELAY, function()
        self.configID = C_Traits.GetConfigIDByTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID);
        
        if not self.configID or not self.type then
            return;
        end

        local type = Enum.CompanionConfigSlotTypes[self.type];

        self.selectionNodeInfo = C_Traits.GetNodeInfo(self.configID, self.selectionNodeID);

        if #C_DelvesUI.GetUnseenCuriosBySlotType(type, self.selectionNodeInfo.entryIDs) > 0 and not UnseenCuriosAcknowledged() then
            return;
        end

        C_DelvesUI.SaveSeenCuriosBySlotType(type, self.selectionNodeInfo.entryIDs);
    end);
end

function CompanionConfigSlotTemplateMixin:OnShow()
    self.configID = self.configID or C_Traits.GetConfigIDByTreeID(Constants.DelvesConsts.BRANN_TRAIT_TREE_ID);
    self.NewLabel:Hide();
    self.NewGlowHighlight:Hide();
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
        
        if self.NewLabel:IsShown() then
            self.NewLabel:Hide();
            self.NewGlowHighlight:Hide();
        end
    else
        EventRegistry:TriggerEvent("CompanionConfiguration.ListShown");
        self.OptionsList:Show();
    end
end

function CompanionConfigSlotTemplateMixin:Refresh(keepOptionsListOpen)
    if not keepOptionsListOpen then
        self.OptionsList:Hide();
    end

    self:SetEnabled(true);
    self.selectionNodeInfo = C_Traits.GetNodeInfo(self.configID, self.selectionNodeID);
    self.Label:SetText(self:GetSlotLabelText());

    self:BuildSelectionNodeOptions();
    self.unseenCurios = C_DelvesUI.GetUnseenCuriosBySlotType(Enum.CompanionConfigSlotTypes[self.type], self.selectionNodeInfo.entryIDs);
    local hasUnseenCurios = #self.unseenCurios > 0;

    if self.selectionNodeInfo then
        if not self.selectionNodeInfo.isVisible then

            local lockedText = DELVES_CURIO_LOCKED;
            for _, conditionID in ipairs(self.selectionNodeInfo.conditionIDs) do
                local conditionInfo = C_Traits.GetConditionInfo(self.configID, conditionID, true);
                if conditionInfo.tooltipText then
                    lockedText = conditionInfo.tooltipText;
                    break;
                end
            end

            self:SetEnabled(false);
            self.Value:SetText(lockedText);
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
            self.Border:SetAtlas("talents-node-choice-yellow");
            self.BorderHighlight:SetAtlas("talents-node-choice-yellow");
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

            if hasUnseenCurios then
                self.NewLabel:Show();
                self.NewGlowHighlight:Show();
                self.NewGlowHighlightAnimIn:Play();
            end
        else
            self.Label:SetTextColor(WHITE_FONT_COLOR:GetRGB());
            self.Value:SetText(GREEN_FONT_COLOR:WrapTextInColorCode(DELVES_CURIO_SLOT_EMPTY));
            self.Border:SetAtlas("talents-node-pvp-green");
            self.BorderHighlight:SetAtlas("talents-node-pvp-green");
            self.Texture:SetAtlas(nil);
            self.Texture:SetTexture(nil);
            self.HighlightTexture:SetTexture(nil);

            if hasUnseenCurios then
                self.NewLabel:Show();
                self.NewGlowHighlight:Show();
                self.NewGlowHighlightAnimIn:Play();
            end
        end
    end

    self:PopulateOptionsList();
    self:SetSeenCurios();
end

function CompanionConfigSlotTemplateMixin:PopulateOptionsList()
    local activeEntryID = self:HasActiveEntry() and self.selectionNodeInfo.activeEntry.entryID;
    local dataProvider = CreateDataProvider();
    local buttonCount = 0;

    for id, entryInfo in pairs(self.selectionNodeOptions) do
        local isUnseen = false;
        for _, unseenID in ipairs(self.unseenCurios) do
            if id == unseenID then
                isUnseen = true;
                break;
            end
        end

        local additionalEntryInfo = C_Traits.GetEntryInfo(self.configID, id);
        local selectedEntryRarity = Enum.CurioRarity.Common;

        if additionalEntryInfo then
            for _, conditionID in ipairs(additionalEntryInfo.conditionIDs) do
                local conditionInfo = C_Traits.GetConditionInfo(self.configID, conditionID, true);
                if conditionInfo and conditionInfo.traitCondAccountElementID then
                    selectedEntryRarity = C_DelvesUI.GetCurioRarityByTraitCondAccountElementID(conditionInfo.traitCondAccountElementID);
                end
            end
        end

        dataProvider:Insert({
            entryID = id,
            name = entryInfo.name,
            atlas = entryInfo.atlas,
            textureID = entryInfo.textureID,
            selected = activeEntryID == id,
            spellID = entryInfo.spellID,
            description = entryInfo.description,
            isUnseen = isUnseen,
            borderColor = borderColorForRarity[selectedEntryRarity],
        });
        buttonCount = buttonCount + 1;
    end
    self.OptionsList.ScrollBox:SetDataProvider(dataProvider);

    local buttonHeight = C_XMLUtil.GetTemplateInfo("CompanionConfigListButtonTemplate").height;
    self.OptionsList:SetHeight(buttonCount * buttonHeight);
end

function CompanionConfigSlotTemplateMixin:GetSlotLabelText()
    if Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Role then
        return DELVES_CONFIG_SLOT_LABEL_COMBAT_ROLE;
    elseif Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Utility then
        return DELVES_CONFIG_SLOT_UTILITY_CURIO;
    elseif Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Combat then
        return DELVES_CONFIG_SLOT_COMBAT_CURIO;
    else
        return nil;
    end
end

function CompanionConfigSlotTemplateMixin:GetSelectionNodeID()
    if Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Role then
        return Constants.DelvesConsts.BRANN_ROLE_NODE_ID;
    elseif Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Utility then
        return Constants.DelvesConsts.BRANN_UTILITY_TRINKET_NODE_ID;
    elseif Enum.CompanionConfigSlotTypes[self.type] == Enum.CompanionConfigSlotTypes.Combat then
        return Constants.DelvesConsts.BRANN_COMBAT_TRINKET_NODE_ID;
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

CompanionConfigSlotOptionsListMixin = {};

function CompanionConfigSlotOptionsListMixin:OnHide()
    local slot = self:GetParent();

    if slot.NewLabel:IsShown() then
        slot.NewLabel:Hide();
        slot.NewGlowHighlight:Hide();
    end
end

--[[ Config List Button ]]
CompanionConfigListButtonMixin = {};

function CompanionConfigListButtonMixin:OnClick()
    local _, _, distance = ClosestUnitPosition(DELVES_SUPPLIES_CREATURE_ID);
    local delveInProgress = C_PartyInfo.IsDelveInProgress();
    local playerMustInteractWithSupplies = delveInProgress and distance > DELVES_SUPPLIES_MAX_DISTANCE;

    if UnitAffectingCombat("player") then
        UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_IN_COMBAT);
    elseif playerMustInteractWithSupplies then
        UIErrorsFrame:AddExternalErrorMessage(DELVES_ERR_MUST_USE_SUPPLIES);
    else
        if TrySelectTrait(self.data.configID, self.data.selectionNodeID, self.data.entryID) then
            EventRegistry:TriggerEvent("CompanionConfigListButton.Commit");
        else
            UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
        end
    end
end

function CompanionConfigListButtonMixin:OnEnter()
    ShowConfigTooltip(self, self.data, 2, -30);
end

function CompanionConfigListButtonMixin:HideNewGlowIfShown()
    if self.NewGlow:IsShown() then
        self.Name:SetShadowColor(0, 0, 0, 0);
        self.NewGlow:Hide();
        if self.selected then
            self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
        else
            self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB());
        end
    end
end

function CompanionConfigListButtonMixin:OnLeave()
    GameTooltip:Hide();
    if self.data.isUnseen then
        self.data.isUnseen = false;
    end
    self:HideNewGlowIfShown();
end

function CompanionConfigListButtonMixin:OnHide()
    self:HideNewGlowIfShown();
end

function CompanionConfigListButtonMixin:OnShow()
    if self.data.isUnseen then
        self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB());
        self.Name:SetShadowColor(NEW_FEATURE_SHADOW_COLOR:GetRGBA());
        
        local halfStringWidth = self.Name:GetStringWidth() / 2;
        local doubleStringWidth = self.Name:GetStringWidth() * 2;
        
        self.NewGlow:SetWidth(doubleStringWidth);
        self.NewGlow:SetPoint("CENTER", self.Name, "LEFT", math.ceil(halfStringWidth + 1), -1);

        self.NewGlow:Show();
    else
        self.Name:SetShadowColor(0, 0, 0, 0);
                
        if self.selected then
            self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
        else
            self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB());
        end

        self.NewGlow:Hide();
    end
end

--[[ Abilities Button ]]
CompanionConfigShowAbilitiesButtonMixin = {};

function CompanionConfigShowAbilitiesButtonMixin:OnClick()
    if not DelvesCompanionAbilityListFrame:IsShown() then
        ShowUIPanel(DelvesCompanionAbilityListFrame);
    else
        HideUIPanel(DelvesCompanionAbilityListFrame);
    end
end