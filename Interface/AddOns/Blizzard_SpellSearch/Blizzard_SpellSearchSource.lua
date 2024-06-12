SpellSearchSourceMixin = {};

function SpellSearchSourceMixin:Init(...)
	-- Required
	-- Implement in source-specific derived mixin
	assert(false);
end

-- sourceType: SpellSearchUtil.SourceType
function SpellSearchSourceMixin:GetSourceType()
	return self.sourceType;
end

function SpellSearchSourceMixin:GetAllSourceDataEntries()
	-- Required
	-- Implement in source-specific derived mixin
	assert(false);
end


TraitSearchSourceMixin = CreateFromMixins(SpellSearchSourceMixin);

-- allNodeInfosGetter: func<table<nodeID, nodeInfo>>() (return all active nodeInfos)
-- entryDefinitionInfoGetter: func<entryDefinition>(entryID)
-- subTreeInfoGetter: func<subTreeInfo>(entryID)
function TraitSearchSourceMixin:Init(allNodeInfosGetter, entryDefinitionInfoGetter, subTreeInfoGetter)
	self.sourceType = SpellSearchUtil.SourceType.Trait;
	self.allNodeInfosGetter = allNodeInfosGetter;
	self.entryDefinitionInfoGetter = entryDefinitionInfoGetter;
	self.subTreeInfoGetter = subTreeInfoGetter;
end

function TraitSearchSourceMixin:GetAllSourceDataEntries()
	return self.allNodeInfosGetter();
end

function TraitSearchSourceMixin:GetEntryDefinitionInfo(entryID)
	return self.entryDefinitionInfoGetter(entryID);
end

function TraitSearchSourceMixin:GetEntrySubTreeInfo(entryID)
	return self.subTreeInfoGetter(entryID);
end

PvPTalentsSearchSourceMixin = CreateFromMixins(SpellSearchSourceMixin);

-- allPvPTalentInfosGetter: func<table<pvpTalentID, pvpTalentInfo>>() (return all active pvpTalentInfos)
function PvPTalentsSearchSourceMixin:Init(allPvPTalentInfosGetter)
	self.sourceType = SpellSearchUtil.SourceType.PvPTalent;
	self.allPvPTalentInfosGetter = allPvPTalentInfosGetter;
end

function PvPTalentsSearchSourceMixin:GetAllSourceDataEntries()
	return self.allPvPTalentInfosGetter();
end

SpellBookItemSearchSourceMixin = CreateFromMixins(SpellSearchSourceMixin);

-- spellBookItemsGetter: func<table<SpellBookItemElementData>>() (return ElementData for all SpellBookItems)
function SpellBookItemSearchSourceMixin:Init(allSpellBookItemsGetter)
	self.sourceType = SpellSearchUtil.SourceType.SpellBookItem;
	self.allSpellBookItemsGetter = allSpellBookItemsGetter;
end

function SpellBookItemSearchSourceMixin:GetAllSourceDataEntries()
	return self.allSpellBookItemsGetter();
end