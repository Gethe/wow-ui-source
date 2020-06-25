SoulbindConduitMixin = CreateFromMixins(SpellMixin)

function SoulbindConduitMixin:Init(conduitID, conduitRank)
	self.conduitID = conduitID;
	self.conduitRank = conduitRank;
	self:SetSpellID(C_Soulbinds.GetConduitSpellID(conduitID, conduitRank));
end

function SoulbindConduitMixin:GetConduitID()
	return self.conduitID;
end

function SoulbindConduitMixin:GetRank()
	return self.conduitRank;
end

function SoulbindConduitMixin:Matches(conduit)
	return conduit and self:GetConduitID() == conduit:GetConduitID() and self:GetRank() == conduit:GetRank();
end

function SoulbindConduitMixin_Create(conduitID, conduitRank)
	return CreateAndInitFromMixin(SoulbindConduitMixin, conduitID, conduitRank);
end
