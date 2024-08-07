local SpecializationVisuals = {
	-- DK
	[250] = { background = "talents-background-deathknight-blood", heroContainerOffset = -15, },
	[251] = { background = "talents-background-deathknight-frost", heroContainerOffset = -15, },
	[252] = { background = "talents-background-deathknight-unholy", heroContainerOffset = -15, },

	-- DH
	[577] = { background = "talents-background-demonhunter-havoc", heroContainerOffset = -15, },
	[581] = { background = "talents-background-demonhunter-vengeance", heroContainerOffset = -45, },

	-- Druid
	[102] = { background = "talents-background-druid-balance", heroContainerOffset = 15, },
	[103] = { background = "talents-background-druid-feral", heroContainerOffset = 15, },
	[104] = { background = "talents-background-druid-guardian", heroContainerOffset = 15, },
	[105] = { background = "talents-background-druid-restoration", heroContainerOffset = -15, },

	-- Evoker
	[1467] = { background = "talents-background-evoker-devastation", heroContainerOffset = -15, },
	[1468] = { background = "talents-background-evoker-preservation", heroContainerOffset = -15, },
	[1473] = { background = "talents-background-evoker-augmentation", heroContainerOffset = -15, },

	-- Hunter
	[253] = { background = "talents-background-hunter-beastmastery", heroContainerOffset = -15, },
	[254] = { background = "talents-background-hunter-marksmanship", heroContainerOffset = -15, },
	[255] = { background = "talents-background-hunter-survival", heroContainerOffset = -15, },

	-- Mage
	[62] = { background = "talents-background-mage-arcane", heroContainerOffset = -15, },
	[63] = { background = "talents-background-mage-fire", heroContainerOffset = -15, },
	[64] = { background = "talents-background-mage-frost", heroContainerOffset = -15, },

	-- Monk
	[268] = { background = "talents-background-monk-brewmaster", heroContainerOffset = -15, },
	[269] = { background = "talents-background-monk-windwalker", heroContainerOffset = -15, },
	[270] = { background = "talents-background-monk-mistweaver", heroContainerOffset = -15, },

	-- Paladin
	[65] = { background = "talents-background-paladin-holy", heroContainerOffset = -45, },
	[66] = { background = "talents-background-paladin-protection", heroContainerOffset = -15, },
	[70] = { background = "talents-background-paladin-retribution", heroContainerOffset = -45, },

	-- Priest
	[256] = { background = "talents-background-priest-discipline", heroContainerOffset = 15, },
	[257] = { background = "talents-background-priest-holy", heroContainerOffset = 15, },
	[258] = { background = "talents-background-priest-shadow", heroContainerOffset = 15, },

	-- Rogue
	[259] = { background = "talents-background-rogue-assassination", heroContainerOffset = -45, },
	[260] = { background = "talents-background-rogue-outlaw", heroContainerOffset = -45, },
	[261] = { background = "talents-background-rogue-subtlety", heroContainerOffset = -45, },

	-- Shaman
	[262] = { background = "talents-background-shaman-elemental", heroContainerOffset = 15, },
	[263] = { background = "talents-background-shaman-enhancement", heroContainerOffset = 15, },
	[264] = { background = "talents-background-shaman-restoration", heroContainerOffset = 15, },

	-- Warlock
	[265] = { background = "talents-background-warlock-affliction", heroContainerOffset = -15, },
	[266] = { background = "talents-background-warlock-demonology", heroContainerOffset = -15, },
	[267] = { background = "talents-background-warlock-destruction", heroContainerOffset = -15, },

	-- Warrior
	[71] = { background = "talents-background-warrior-arms", heroContainerOffset = -15, },
	[72] = { background = "talents-background-warrior-fury", heroContainerOffset = -15, },
	[73] = { background = "talents-background-warrior-protection", heroContainerOffset = -15, },
};

-- TODO:: Replace panOffset fixups.
local ClassVisuals = {
	[1]	 --[[Warrior--]]	 = { activationFX = "talents-animations-class-warrior", panOffset = { x = 60, y = 31 }, },
	[2]  --[[Paladin--]] 	 = { activationFX = "talents-animations-class-paladin", panOffset = { x = -60, y = -29 }, },
	[3]  --[[Hunter--]] 	 = { activationFX = "talents-animations-class-hunter", panOffset = { x = 0, y = -29 }, },
	[4]  --[[Rogue--]] 		 = { activationFX = "talents-animations-class-rogue", panOffset = { x = 30, y = -29 }, },
	[5]  --[[Priest--]] 	 = { activationFX = "talents-animations-class-priest", panOffset = { x = -30, y = -29 }, },
	[6]  --[[DeathKnight--]] = { activationFX = "talents-animations-class-deathknight", panOffset = { x = 0, y = 1 }, },
	[7]  --[[Shaman--]] 	 = { activationFX = "talents-animations-class-shaman", panOffset = { x = 0, y = 1 }, },
	[8]  --[[Mage--]] 		 = { activationFX = "talents-animations-class-mage", panOffset = { x = 30, y = -29 }, },
	[9]  --[[Warlock--]] 	 = { activationFX = "talents-animations-class-warlock", panOffset = { x = 0, y = 1 }, },
	[10] --[[Monk--]] 		 = { activationFX = "talents-animations-class-monk", panOffset = { x = 0, y = -29 }, },
	[11] --[[Druid--]] 		 = { activationFX = "talents-animations-class-druid", panOffset = { x = 30, y = -29 }, },
	[12] --[[DemonHunter--]] = { activationFX = "talents-animations-class-demonhunter", panOffset = { x = 30, y = -29 }, },
	[13] --[[Evoker--]]		 = { activationFX = "talents-animations-class-evoker", panOffset = { x = 30, y = -29 }, },
}

local ClassTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "ClassTalentButtonSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "ClassTalentButtonCircleTemplate",
};

local ClassLargeTemplatesByTalentType = {
	[Enum.TraitNodeEntryType.SpendSquare] = "ClassTalentButtonLargeSquareTemplate",
	[Enum.TraitNodeEntryType.SpendCircle] = "ClassTalentButtonLargeCircleTemplate",
};

local ClassTemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "ClassTalentEdgeArrowTemplate",
};

local SheenAlphaByVisualState = {
	[TalentButtonUtil.BaseVisualState.Normal] = 1,
	[TalentButtonUtil.BaseVisualState.Gated] = 0,
	[TalentButtonUtil.BaseVisualState.Disabled] = 1,
	[TalentButtonUtil.BaseVisualState.Locked] = 1,
	[TalentButtonUtil.BaseVisualState.Selectable] = 0,
	[TalentButtonUtil.BaseVisualState.Maxed] = 1,
	[TalentButtonUtil.BaseVisualState.Invisible] = 0,
	[TalentButtonUtil.BaseVisualState.RefundInvalid] = 0,
	[TalentButtonUtil.BaseVisualState.DisplayError] = 1,
};

ClassTalentUtil = {};

function ClassTalentUtil.GetVisualsForSpecID(specID)
	return SpecializationVisuals[specID];
end

function ClassTalentUtil.GetVisualsForClassID(classID)
	return ClassVisuals[classID];
end

function ClassTalentUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	if nodeInfo and nodeInfo.type == Enum.TraitNodeType.Selection then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return "ClassTalentButtonChoiceTemplate";
		end
	end

	if useLarge then
		return ClassLargeTemplatesByTalentType[talentType] or "ClassTalentButtonLargeCircleTemplate";
	end

	-- Anything without a specific shared template will be a circle for now.
	return ClassTemplatesByTalentType[talentType] or "ClassTalentButtonCircleTemplate";
end

function ClassTalentUtil.GetEdgeTemplateType(edgeVisualStyle)
	return ClassTemplatesByEdgeVisualStyle[edgeVisualStyle];
end

function ClassTalentUtil.GetSpecializedMixin(nodeInfo, talentType)
	if nodeInfo and nodeInfo.type == Enum.TraitNodeType.Selection then
		if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowMultipleIcons) then
			return ClassTalentButtonSplitSelectMixin;
		else
			return ClassTalentButtonSelectMixin;
		end
	end

	return ClassTalentButtonSpendMixin;
end

function ClassTalentUtil.GetSpecializedChoiceMixin(entryInfo, talentType)
	return ClassTalentSelectionChoiceMixin;
end

function ClassTalentUtil.IsTalentMissingFromActionBars(nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return false;
	end

	if not spellID or C_Spell.IsSpellPassive(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end

function ClassTalentUtil.IsEntryTalentMissingFromActionBars(entryID, nodeInfo, spellID)
	if not nodeInfo or not nodeInfo.entryIDsWithCommittedRanks or (#nodeInfo.entryIDsWithCommittedRanks <= 0)  then
		return false;
	end

	local foundEntryID = false;
	for i, committedEntryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
		if committedEntryID == entryID then
			foundEntryID = true;
			break;
		end
	end

	if not foundEntryID then
		return false;
	end

	if not spellID or C_Spell.IsSpellPassive(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end

function ClassTalentUtil.GetSheenAlphaForVisualState(visualState)
	return SheenAlphaByVisualState[visualState];
end

ClassTalentUtil.ShouldRefundClearEdges = IsShiftKeyDown;