
MAX_PARTY_MEMBERS = 4;

-- Allow these to be overwritten.
MAX_PARTY_BUFFS = MAX_PARTY_BUFFS or 4;
MAX_PARTY_DEBUFFS = MAX_PARTY_DEBUFFS or 4;

MAX_PARTY_TOOLTIP_BUFFS = 16;
MAX_PARTY_TOOLTIP_BUFFS_PER_ROW = 8;
MAX_PARTY_TOOLTIP_DEBUFFS = 8;

CVarCallbackRegistry:SetCVarCachable("showPartyPets");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");

PartyMemberAuraMixin={};

function PartyMemberAuraMixin:UpdateMemberAuras(unitAuraUpdateInfo)
	self:UpdateAurasInternal(unitAuraUpdateInfo);
end

function PartyMemberAuraMixin:UpdateAurasInternal(unitAuraUpdateInfo)
	local displayOnlyDispellableDebuffs = CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", self.unit);
	-- Buffs are only displayed in the Party Buff Tooltip
	local ignoreBuffs = MAX_PARTY_TOOLTIP_BUFFS == 0;
	local ignoreDebuffs = MAX_PARTY_DEBUFFS == 0;
	local ignoreDispelDebuffs = MAX_PARTY_DEBUFFS == 0;

	local debuffsChanged = false;
	local buffsChanged = false;

	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.debuffs == nil then
		self:ParseAllAuras(displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
		debuffsChanged = true;
		buffsChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);

				if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
					self.debuffs[aura.auraInstanceID] = aura;
					debuffsChanged = true;
				elseif type == AuraUtil.AuraUpdateChangedType.Buff then
					self.buffs[aura.auraInstanceID] = aura;
					buffsChanged = true;
				end
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				if self.debuffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					local oldDebuffType = self.debuffs[auraInstanceID].debuffType;
					if newAura ~= nil then
						newAura.debuffType = oldDebuffType;
					end
					self.debuffs[auraInstanceID] = newAura;
					debuffsChanged = true;
				elseif self.buffs[auraInstanceID] ~= nil then
					local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID);
					if newAura ~= nil then
						newAura.isBuff = true;
					end
					self.buffs[auraInstanceID] = newAura;
					buffsChanged = true;
				end
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				if self.debuffs[auraInstanceID] ~= nil then
					self.debuffs[auraInstanceID] = nil;
					debuffsChanged = true;
				elseif self.buffs[auraInstanceID] ~= nil then
					self.buffs[auraInstanceID] = nil;
					buffsChanged = true;
				end
			end
		end
	end

	local showingBuffs = self.showBuffs;
	if (showingBuffs and buffsChanged) or (not showingBuffs and debuffsChanged) then
		local iterateList = showingBuffs and self.buffs or self.debuffs;
		local maxFrames = showingBuffs and MAX_PARTY_BUFFS or MAX_PARTY_DEBUFFS;
		local frameNum = 1;
		self.AuraFramePool:ReleaseAll();
		iterateList:Iterate(function(auraInstanceID, aura)
			if frameNum > maxFrames then
				return true;
			end

			local auraFrame = self.AuraFramePool:Acquire();
			auraFrame:SetPoint("TOPLEFT");
			auraFrame.layoutIndex = frameNum;
			auraFrame:Setup(self.unit, aura, showingBuffs);
			frameNum = frameNum + 1;
			return false;
		end);

		self.AuraFrameContainer:Layout();

		local unitStatus;
		if self.PartyMemberOverlay then
			unitStatus = self.PartyMemberOverlay.Status;
		end

		if not showingBuffs and unitStatus then
			local highestPriorityDebuff = self.debuffs:GetTop();
			if highestPriorityDebuff then
				AuraUtil.SetAuraBorderColor(unitStatus, highestPriorityDebuff.dispelName);
				unitStatus:Show();
			else
				unitStatus:Hide();
			end
		end
	end
end

function PartyMemberAuraMixin:ParseAllAuras(displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs)
	if self.debuffs == nil then
		self.debuffs = TableUtil.CreatePriorityTable(AuraUtil.UnitFrameDebuffComparator, TableUtil.Constants.AssociativePriorityTable);
		self.buffs = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	else
		self.debuffs:Clear();
		self.buffs:Clear();
	end

	local batchCount = nil;
	local usePackedAura = true;
	local function HandleAura(aura)
		local type = AuraUtil.ProcessAura(aura, displayOnlyDispellableDebuffs, ignoreBuffs, ignoreDebuffs, ignoreDispelDebuffs);
		if type == AuraUtil.AuraUpdateChangedType.Debuff or type == AuraUtil.AuraUpdateChangedType.Dispel then
			self.debuffs[aura.auraInstanceID] = aura;
		elseif type == AuraUtil.AuraUpdateChangedType.Buff then
			self.buffs[aura.auraInstanceID] = aura;
		end
	end
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Helpful), batchCount, HandleAura, usePackedAura);
	AuraUtil.ForEachAura(self.unit, AuraUtil.CreateFilterString(AuraUtil.AuraFilters.Harmful, AuraUtil.AuraFilters.Raid), batchCount, HandleAura, usePackedAura);
end

PartyAuraFrameMixin = {};
function PartyAuraFrameMixin:Setup(unit, aura, isBuff)
	self.unit = unit;
	self.auraInstanceID = aura.auraInstanceID;

	local isBossBuff = aura.isBossAura and aura.isHelpful;
	local filter = aura.isRaid and AuraUtil.AuraFilters.Raid or nil;
	self.isBuff = isBuff;
	self.isBossBuff = isBossBuff;
	self.filter = filter;

	if aura.icon then
		self.Icon:SetTexture(aura.icon);

		if aura.applications > 1 then
			local countText = aura.applications >= 100 and BUFF_STACKS_OVERFLOW or aura.applications;
			self.Count:Show();
			self.Count:SetText(countText);
		else
			self.Count:Hide();
		end

		self.DebuffBorder:SetShown(not isBuff);
		if not isBuff then
			AuraUtil.SetAuraBorderColor(self.DebuffBorder, aura.dispelName);
		end

		local enabled = aura.expirationTime and aura.expirationTime ~= 0;
		if enabled then
			local startTime = aura.expirationTime - aura.duration;
			CooldownFrame_Set(self.Cooldown, startTime, aura.duration, true);
		else
			CooldownFrame_Clear(self.Cooldown);
		end

		self:Show();
	end
end

function PartyAuraFrameMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		self:UpdateTooltip();
	end
end

function PartyAuraFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:UpdateTooltip();
end

function PartyAuraFrameMixin:OnLeave()
	GameTooltip:Hide();
end

function PartyAuraFrameMixin:UpdateTooltip()
	if self.isBossBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	elseif self.isBuff then
		GameTooltip:SetUnitBuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	else
		GameTooltip:SetUnitDebuffByAuraInstanceID(self.unit, self.auraInstanceID, self.filter);
	end
end

ResurrectableIndicatorMixin = {};
function ResurrectableIndicatorMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, PARTY_FRAME_RESURRECTABLE_TOOLTIP);
	GameTooltip:Show();
end

function ResurrectableIndicatorMixin:OnLeave()
	GameTooltip_Hide();
end
