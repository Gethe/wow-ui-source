SoulbindConduitMixin = CreateFromMixins(SpellMixin)

function SoulbindConduitMixin:Init(conduitID)
	self.conduitID = conduitID;
	if self:IsValid() then
		self:SetSpellID(C_Soulbinds.GetConduitSpellID(conduitID, self:GetConduitRank()));
	end
end

function SoulbindConduitMixin:IsValid()
	return self.conduitID > 0;
end

function SoulbindConduitMixin:GetConduitID()
	return self.conduitID;
end

function SoulbindConduitMixin:GetConduitRank()
	local rank = C_Soulbinds.GetConduitRank(self:GetConduitID());
	return self:IsValid() and math.max(rank, 1) or 1;
end

function SoulbindConduitMixin:Matches(conduit)
	return conduit and self:GetConduitID() == conduit:GetConduitID();
end

function SoulbindConduitMixin:GetHyperlink()
	return C_Soulbinds.GetConduitHyperlink(self:GetConduitID(), self:GetConduitRank());
end

function SoulbindConduitMixin_Create(conduitID)
	return CreateAndInitFromMixin(SoulbindConduitMixin, conduitID);
end
