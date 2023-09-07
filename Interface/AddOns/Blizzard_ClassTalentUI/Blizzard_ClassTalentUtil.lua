local SpecIDToBackgroundAtlas = {
	-- DK
	[250] = "talents-background-deathknight-blood",
	[251] = "talents-background-deathknight-frost",
	[252] = "talents-background-deathknight-unholy",

	-- DH
	[577] = "talents-background-demonhunter-havoc",
	[581] = "talents-background-demonhunter-vengeance",

	-- Druid
	[102] = "talents-background-druid-balance",
	[103] = "talents-background-druid-feral",
	[104] = "talents-background-druid-guardian",
	[105] = "talents-background-druid-restoration",

	-- Evoker
	[1467] = "talents-background-evoker-devastation",
	[1468] = "talents-background-evoker-preservation",
	[1473] = "talents-background-evoker-augmentation",

	-- Hunter
	[253] = "talents-background-hunter-beastmastery",
	[254] = "talents-background-hunter-marksmanship",
	[255] = "talents-background-hunter-survival",

	-- Mage
	[62] = "talents-background-mage-arcane",
	[63] = "talents-background-mage-fire",
	[64] = "talents-background-mage-frost",

	-- Monk
	[268] = "talents-background-monk-brewmaster",
	[269] = "talents-background-monk-windwalker",
	[270] = "talents-background-monk-mistweaver",

	-- Paladin
	[65] = "talents-background-paladin-holy",
	[66] = "talents-background-paladin-protection",
	[70] = "talents-background-paladin-retribution",

	-- Priest
	[256] = "talents-background-priest-discipline",
	[257] = "talents-background-priest-holy",
	[258] = "talents-background-priest-shadow",

	-- Rogue
	[259] = "talents-background-rogue-assassination",
	[260] = "talents-background-rogue-outlaw",
	[261] =  "talents-background-rogue-subtlety",

	-- Shaman
	[262] = "talents-background-shaman-elemental",
	[263] = "talents-background-shaman-enhancement",
	[264] = "talents-background-shaman-restoration",

	-- Warlock
	[265] = "talents-background-warlock-affliction",
	[266] = "talents-background-warlock-demonology",
	[267] = "talents-background-warlock-destruction",

	-- Warrior
	[71] = "talents-background-warrior-arms",
	[72] = "talents-background-warrior-fury",
	[73] = "talents-background-warrior-protection",
};

-- TODO:: Replace panOffset fixups.
local ClassVisuals = {
	[1]	 --[[Warrior--]]	 = { activationFX = "talents-animations-class-warrior", panOffset = { x = 30, y = 31 }, },
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
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
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
};

ClassTalentUtil = {};

function ClassTalentUtil.GetAtlasForSpecID(specID)
	return SpecIDToBackgroundAtlas[specID];
end

function ClassTalentUtil.GetVisualsForClassID(classID)
	return ClassVisuals[classID];
end

function ClassTalentUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
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
	if nodeInfo and (nodeInfo.type == Enum.TraitNodeType.Selection) then
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

	if not spellID or IsPassiveSpell(spellID) then
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

	if not spellID or IsPassiveSpell(spellID) then
		return false;
	end

	return not C_ActionBar.IsOnBarOrSpecialBar(spellID);
end

function ClassTalentUtil.GetSheenAlphaForVisualState(visualState)
	return SheenAlphaByVisualState[visualState];
end

ClassTalentUtil.ShouldRefundClearEdges = IsShiftKeyDown;
