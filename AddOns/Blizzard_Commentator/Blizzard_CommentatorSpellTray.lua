CommentatorSpellCache = {};

function CommentatorSpellCache.Create(spellID, unitToken)
	local obj = CreateFromMixins(CommentatorSpellCache);
	obj.spellID = spellID;
	obj.unitToken = unitToken;
	obj.isActive = false;
	return obj;
end

function CommentatorSpellCache:GetSpellID()
	return self.spellID;
end

function CommentatorSpellCache:GetUnitToken()
	return self.unitToken;
end

function CommentatorSpellCache:SetActive(isActive)
	self.isActive = isActive;
end

function CommentatorSpellCache:IsActive()
	return self.isActive;
end

function CommentatorSpellCache:GetIndirectSpellID()
	return C_Commentator.GetIndirectSpellID(self:GetSpellID());
end

function CommentatorSpellCache:GetSpellCharges()
	return C_Commentator.GetPlayerSpellChargesByUnit(self:GetUnitToken(), self:GetSpellID());
end

function CommentatorSpellCache:GetCooldownInfo()
	return C_Commentator.GetPlayerCooldownInfoByUnit(self:GetUnitToken(), self:GetSpellID());
end

function CommentatorSpellCache:GetPlayerAuraInfo()
	return C_Commentator.GetPlayerAuraInfoByUnit(self:GetUnitToken(), self:GetIndirectSpellID());
end

CommentatorSpellTrayMixin = {};

function CommentatorSpellTrayMixin:OnLoad()
	self.spellCaches = {};

	local resetterCb = function(pool, frame)
		frame:Reset();
		FramePool_HideAndClearAnchors(pool, frame);
	end;
	self.pool = CreateFramePool("FRAME", self, self.spellTemplate, resetterCb);
end

function CommentatorSpellTrayMixin:Reset()
	self.spellCaches = {};
	self.pool:ReleaseAll();
end

function CommentatorSpellTrayMixin:OnUpdate(elapsed)
	for frame in self.pool:EnumerateActive() do
		frame:OnUpdate(elapsed);
	end
end

function CommentatorSpellTrayMixin:SetSpellActive(spellID, isActive)
	local spellCache = self.spellCaches[spellID];
	if spellCache then
		spellCache:SetActive(isActive);

		for spellFrame in self.pool:EnumerateActive() do
			if spellFrame:GetSpellID() == spellID then
				spellFrame:SetActive(isActive);
				break;
			end
		end
	end
end

function CommentatorSpellTrayMixin:GetOrCreateSpellCache(spellID)
	if not self.spellCaches[spellID] then
		self.spellCaches[spellID] = CommentatorSpellCache.Create(spellID, self.unitToken);
	end
	return self.spellCaches[spellID];
end

function CommentatorSpellTrayMixin:InitSpells(alignment, unitToken)
	self.pool:ReleaseAll();
	self.unitToken = unitToken;

	local spells = C_Commentator.GetTrackedSpellsByUnit(unitToken, self.category);
	if spells and #spells > 0 then
		-- Reserve enough frames for every spell so the order of frames returned by
		-- EnumerateActive remains the same below, and in UpdateAlignment().
		for index = 1, #spells do
			self.pool:Acquire();
		end

		local padding = 5;
		local direction = alignment == "LEFT" and 1 or -1;
		local cooldownIndex = 1;
		for spellFrame in self.pool:EnumerateActive() do
			local spellID = spells[cooldownIndex];
			local spellCache = self:GetOrCreateSpellCache(spellID);
			spellFrame:Initialize(spellCache);
			spellFrame.aligner = function(slotIndex)
				spellFrame:ClearAllPoints();
				local extents = spellFrame:GetWidth() + padding;
				local offset = slotIndex * extents * direction;
				spellFrame:SetPoint(alignment, self, alignment, offset, padding);
				return extents;
			end;
			spellFrame:Show();
			cooldownIndex = cooldownIndex + 1;
		end

		self:UpdateAlignment();
		return true;
	end

	return false;
end

function CommentatorSpellTrayMixin:UpdateAlignment()
	local slotIndex = 0;
	local totalWidth = 0;
	for spellFrame in self.pool:EnumerateActive() do
		local extents = spellFrame.aligner(slotIndex);
		totalWidth = totalWidth + extents;
		slotIndex = slotIndex + 1;
	end
	self:SetWidth(totalWidth);
end