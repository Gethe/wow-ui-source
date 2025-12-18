-- For displaying individual buffs/debuffs/crowd control.
NamePlateAuraItemMixin = {};

function NamePlateAuraItemMixin:OnLoad()
	self:SetSize(NamePlateConstants.AURA_ITEM_HEIGHT, NamePlateConstants.AURA_ITEM_HEIGHT);
	self.Cooldown:SetUseAuraDisplayTime(self.useAuraDisplayTime);
end

function NamePlateAuraItemMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	GameTooltip_SetDefaultAnchor(tooltip, self);
	self:RefreshTooltip();
	tooltip:Show();
end

function NamePlateAuraItemMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function NamePlateAuraItemMixin:RefreshTooltip()
	local tooltip = GetAppropriateTooltip();
	if self.auraInstanceID then
		tooltip:SetUnitAuraByAuraInstanceID(self.unitToken, self.auraInstanceID);
	elseif self.spellID then
		local isPet = false;
		tooltip:SetSpellByID(self.spellID, isPet);
	end
end

function NamePlateAuraItemMixin:UpdateTooltip()
	if GameTooltip:IsOwned(self) then
		self:RefreshTooltip();
	end
end

function NamePlateAuraItemMixin:SetAura(aura)
	self.auraInstanceID = aura.auraInstanceID;
	self.isBuff = aura.isHelpful;
	self.spellID = aura.spellId;

	self.Icon:SetTexture(aura.icon);

	if aura.applications > 1 then
		self.CountFrame.Count:SetText(aura.applications);
		self.CountFrame.Count:Show();
	else
		self.CountFrame.Count:Hide();
	end

	local enabled = aura.duration > 0;
	local forceShowDrawEdge = true;
	CooldownFrame_Set(self.Cooldown, aura.expirationTime - aura.duration, aura.duration, enabled, forceShowDrawEdge);

	-- Don't show numbers for auras longer than a minute.
	local hideCountdownNumbers = aura.duration > 60;
	self.Cooldown:SetHideCountdownNumbers(hideCountdownNumbers);
end

-- The unit to which the nameplate is attached.
function NamePlateAuraItemMixin:SetUnit(unitToken)
	self.unitToken = unitToken;
end

CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR);
CVarCallbackRegistry:SetCVarCachable(NamePlateConstants.AURA_SCALE_CVAR);

-- For displaying all the buffs/debuffs/crowd control/loss of control auras on a nameplate.
NamePlateAurasMixin = CreateFromMixins(NamePlateComponentMixin);

function NamePlateAurasMixin:OnLoad()
	local auraItemFrameResetCallback = function(pool, auraItemFrame)
		Pool_HideAndClearAnchors(pool, auraItemFrame);
		auraItemFrame.layoutIndex = nil;
		auraItemFrame:SetParent(nil);
	end;

	self.auraItemFramePool = CreateFramePool("FRAME", self, "NameplateAuraItemTemplate", auraItemFrameResetCallback);

	local filters = {};

	table.insert(filters, AuraUtil.AuraFilters.Harmful);
	table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
	self.debuffFilterString = AuraUtil.CreateFilterString(unpack(filters));

	filters = {};

	table.insert(filters, AuraUtil.AuraFilters.Helpful);
	table.insert(filters, AuraUtil.AuraFilters.IncludeNameplateOnly);
	self.buffFilterString = AuraUtil.CreateFilterString(unpack(filters));
end

function NamePlateAurasMixin:OnEvent(event, ...)
	if event == "LOSS_OF_CONTROL_UPDATE" then
		self:RefreshLossOfControl();
	elseif event == "LOSS_OF_CONTROL_ADDED" then
		self:RefreshLossOfControl();
	end
end

function NamePlateAurasMixin:SetUnit(unitToken)
	self.unitToken = unitToken;

	self:UpdateShownState();

	if self.unitToken then
		CVarCallbackRegistry:RegisterCallback(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, self.UpdateShownState, self);
		CVarCallbackRegistry:RegisterCallback(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, self.UpdateShownState, self);
		CVarCallbackRegistry:RegisterCallback(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, self.UpdateShownState, self);
		CVarCallbackRegistry:RegisterCallback(NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR, self.UpdateShownState, self);
		CVarCallbackRegistry:RegisterCallback(NamePlateConstants.AURA_SCALE_CVAR, self.UpdateAuraScale, self);

		local unitAuraUpdateInfo = nil;
		self:RefreshAuras(unitAuraUpdateInfo);
		self:RefreshLossOfControl();
		self:UpdateAuraScale();

		self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", self.unitToken);
		self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", self.unitToken);
	else
		CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, self);
		CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, self);
		CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, self);
		CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR, self);
		CVarCallbackRegistry:UnregisterCallback(NamePlateConstants.AURA_SCALE_CVAR, self);

		self:UnregisterEvent("LOSS_OF_CONTROL_UPDATE");
		self:UnregisterEvent("LOSS_OF_CONTROL_ADDED");
	end
end

function NamePlateAurasMixin:SetActive(isActive)
	self.isActive = isActive;
end

function NamePlateAurasMixin:IsPlayer()
	return self.isPlayer == true;
end

function NamePlateAurasMixin:SetIsPlayer(isPlayer)
	self.isPlayer = isPlayer;

	self:UpdateShownState();
end

function NamePlateAurasMixin:IsFriend()
	return self.isFriend == true;
end

function NamePlateAurasMixin:SetIsFriend(isFriend)
	self.isFriend = isFriend;

	self:UpdateShownState();
end

function NamePlateAurasMixin:IsSimplified()
	return self.isSimplified;
end

function NamePlateAurasMixin:SetIsSimplified(isSimplified)
	self.isSimplified = isSimplified;

	self:UpdateShownState();
end

function NamePlateAurasMixin:AddAura(aura, checkFilters)
	local auraInstanceID = aura.auraInstanceID;

	if aura.isHarmful == false then
		-- Avoid filling up the list of enemy unit buffs with information not relevant to the player.
		if self:IsFriend() == false and aura.isStealable == false and C_Spell.IsSpellImportant(aura.spellId) == false then
			return false;
		end

		self.buffList[auraInstanceID] = aura;
		return true;
	elseif C_Spell.IsSpellCrowdControl(aura.spellId) then
		self.crowdControlList[auraInstanceID] = aura;
		return true;
	else
		if checkFilters and C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unitToken, aura.auraInstanceID, self.debuffFilterString) then
			return false;
		end

		if not aura.nameplateShowPersonal then
			return false;
		end

		self.debuffList[auraInstanceID] = aura;
		return true;
	end
end

function NamePlateAurasMixin:UpdateAura(auraInstanceID)
	if self.buffList[auraInstanceID] ~= nil then
		local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unitToken, auraInstanceID);
		self.buffList[auraInstanceID] = newAura;
		return true;
	end

	if self.debuffList[auraInstanceID] ~= nil then
		local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unitToken, auraInstanceID);
		self.debuffList[auraInstanceID] = newAura;
		return true;
	end

	if self.crowdControlList[auraInstanceID] ~= nil then
		local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unitToken, auraInstanceID);
		self.crowdControlList[auraInstanceID] = newAura;
		return true;
	end

	return false;
end

function NamePlateAurasMixin:RemoveAura(auraInstanceID)
	if self.buffList[auraInstanceID] ~= nil then
		self.buffList[auraInstanceID] = nil;
		return true;
	end

	if self.debuffList[auraInstanceID] ~= nil then
		self.debuffList[auraInstanceID] = nil;
		return true;
	end

	if self.crowdControlList[auraInstanceID] ~= nil then
		self.crowdControlList[auraInstanceID] = nil;
		return true;
	end

	return false;
end

function NamePlateAurasMixin:ParseAllAuras()
	if self.buffList == nil then
		self.buffList = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
		self.debuffList = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
		self.crowdControlList = TableUtil.CreatePriorityTable(AuraUtil.DefaultAuraCompare, TableUtil.Constants.AssociativePriorityTable);
	else
		self.buffList:Clear();
		self.debuffList:Clear();
		self.crowdControlList:Clear();
	end

	local checkFilters = false;
	local maxAuraCount = nil;

	for _index, auraData in ipairs(C_UnitAuras.GetUnitAuras(self.unitToken, self.debuffFilterString, maxAuraCount)) do
		self:AddAura(auraData, checkFilters);
	end

	for _index, auraData in ipairs(C_UnitAuras.GetUnitAuras(self.unitToken, self.buffFilterString, maxAuraCount)) do
		self:AddAura(auraData, checkFilters);
	end
end

function NamePlateAurasMixin:RefreshList(listFrame, auraList)
	if listFrame:IsShown() == false then
		return;
	end

	local auraIndex = 1;
	auraList:Iterate(function(auraInstanceID, aura)
		-- Depending on if the nameplate is for an enemy or friend or player or Npc certain lists have a
		-- requirement that the aura come from the local player.
		if listFrame.requireSourceIsLocalPlayer == true and (aura.sourceUnit == nil or UnitIsUnit("player", aura.sourceUnit) == false) then
			local stopIterating = false;
			return stopIterating;
		end

		local auraItemFrame = self.auraItemFramePool:Acquire();
		auraItemFrame.layoutIndex = auraIndex;
		auraItemFrame:SetAura(aura);
		auraItemFrame:SetScale(self.auraItemScale);
		auraItemFrame:SetUnit(self.unitToken);
		auraItemFrame:SetParent(listFrame);
		auraItemFrame:Show();

		auraIndex = auraIndex + 1;

		local stopIterating = auraIndex > listFrame.maxAuraItemsDisplayed
		return stopIterating;
	end);

	-- Needed for layout of lists vertically centered on the health bar (buff and crowd control) so they have a discrete height.
	if listFrame.needsFixedHeight then
		listFrame.fixedHeight = self.auraItemScale * NamePlateConstants.AURA_ITEM_HEIGHT;
	end

	listFrame:Layout();
end

function NamePlateAurasMixin:GetLossOfControlAura()
	if self.explicitAuraList and self.explicitAuraList:Size() > 0 then
		return self.explicitAuraList.GetTop();
	end

	local lossOfControlData = C_LossOfControl.GetActiveLossOfControlDataByUnit(self.unitToken, LOSS_OF_CONTROL_ACTIVE_INDEX);
	if not lossOfControlData then
		return nil;
	end

	if not lossOfControlData.auraInstanceID then
		return nil;
	end

	return C_UnitAuras.GetAuraDataByAuraInstanceID(self.unitToken, lossOfControlData.auraInstanceID);
end

function NamePlateAurasMixin:RefreshLossOfControl()
	if self.LossOfControlFrame:IsShown() == false then
		return;
	end

	local auraItemFrame = self.LossOfControlFrame.AuraItemFrame;

	local auraData = self:GetLossOfControlAura();
	if auraData then
		self.LossOfControlFrame:SetScale(self.auraItemScale);

		auraItemFrame:SetAura(auraData);
		auraItemFrame:SetUnit(self.unitToken);
		auraItemFrame:Show();
	else
		auraItemFrame:Hide();
	end
end

function NamePlateAurasMixin:RefreshAuras(unitAuraUpdateInfo)
	if self.isActive == false then
		return;
	end

	local isFriend = self:IsFriend();

	self.DebuffListFrame.requireSourceIsLocalPlayer = isFriend == false;
	self.BuffListFrame.requireSourceIsLocalPlayer = isFriend == true;

	local aurasChanged = false;
	if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate or self.buffList == nil then
		self:ParseAllAuras();
		aurasChanged = true;
	else
		if unitAuraUpdateInfo.addedAuras ~= nil then
			local checkFilters = true;
			for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
				aurasChanged = self:AddAura(aura, checkFilters) or aurasChanged;
			end
		end

		if unitAuraUpdateInfo.updatedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
				aurasChanged = self:UpdateAura(auraInstanceID) or aurasChanged;
			end
		end

		if unitAuraUpdateInfo.removedAuraInstanceIDs ~= nil then
			for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
				aurasChanged = self:RemoveAura(auraInstanceID) or aurasChanged;
			end
		end
	end

	if aurasChanged == true then
		self.auraItemFramePool:ReleaseAll();

		self:RefreshList(self.DebuffListFrame, self.debuffList);
		self:RefreshList(self.BuffListFrame, self.buffList);
		self:RefreshList(self.CrowdControlListFrame, self.crowdControlList);
	end
end

function NamePlateAurasMixin:RefreshExplicitAuras()
	assertsafe(self.explicitAuraList);

	self.auraItemFramePool:ReleaseAll();

	-- Allow special cases (e.g. the Options Preview Nameplate) to control the contents of the lists.
	self:RefreshList(self.DebuffListFrame, self.explicitAuraList);
	self:RefreshList(self.BuffListFrame, self.explicitAuraList);
	self:RefreshList(self.CrowdControlListFrame, self.explicitAuraList);

	self:RefreshLossOfControl();
end

function NamePlateAurasMixin:ShouldBeShown()
	if not self.unitToken then
		return false;
	end

	if self:IsShowOnlyName() then
		return false;
	end

	if self:IsSimplified() then
		return false;
	end

	if self:IsWidgetsOnlyMode() then
		return false;
	end

	return true;
end

function NamePlateAurasMixin:UpdateEnemyNpcAuraFrames()
	local buffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Buffs);
	self.BuffListFrame:SetShown(buffListFrameShown);

	local debuffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Debuffs);
	self.DebuffListFrame:SetShown(debuffListFrameShown);

	local crowdControlListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl);
	self.CrowdControlListFrame:SetShown(crowdControlListFrameShown);

	-- Npcs never display the LossOfControlFrame.
	local lossOfControlFrameShown = false;
	self.LossOfControlFrame:SetShown(lossOfControlFrameShown);
end

function NamePlateAurasMixin:UpdateEnemyPlayerAuraFrames()
	local buffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Buffs);
	self.BuffListFrame:SetShown(buffListFrameShown);

	local debuffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs);
	self.DebuffListFrame:SetShown(debuffListFrameShown);

	-- Players never display the CrowdControlListFrame.
	local crowdControlListFrameShown = false;
	self.CrowdControlListFrame:SetShown(crowdControlListFrameShown);

	local lossOfControlFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl);
	self.LossOfControlFrame:SetShown(lossOfControlFrameShown);
end

function NamePlateAurasMixin:UpdateFriendNpcAuraFrames()
	local buffListFrameShown = false;
	self.BuffListFrame:SetShown(buffListFrameShown);

	local debuffListFrameShown = CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SHOW_DEBUFFS_ON_FRIENDLY_CVAR);
	self.DebuffListFrame:SetShown(debuffListFrameShown);

	local crowdControlListFrameShown = false;
	self.CrowdControlListFrame:SetShown(crowdControlListFrameShown);

	-- Npcs never display the LossOfControlFrame.
	local lossOfControlFrameShown = false;
	self.LossOfControlFrame:SetShown(lossOfControlFrameShown);
end

function NamePlateAurasMixin:UpdateFriendPlayerAuraFrames()
	local friendlyPlayerAuraDisplayType = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR);

	local buffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateFriendlyPlayerAuraDisplay.Buffs);
	self.BuffListFrame:SetShown(buffListFrameShown);

	local debuffListFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs);
	self.DebuffListFrame:SetShown(debuffListFrameShown);

	-- Players never display the CrowdControlListFrame.
	local crowdControlListFrameShown = false;
	self.CrowdControlListFrame:SetShown(crowdControlListFrameShown);

	local lossOfControlFrameShown = CVarCallbackRegistry:GetCVarBitfieldIndex(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateFriendlyPlayerAuraDisplay.LossOfControl);
	self.LossOfControlFrame:SetShown(lossOfControlFrameShown);
end

function NamePlateAurasMixin:UpdateShownState()
	local shouldBeShown = self:ShouldBeShown();

	self:SetShown(shouldBeShown);

	-- It's not necessary to update the individual components shown state if the entire frame is hidden.
	if not shouldBeShown then
		return;
	end

	-- Different CVars and frames are used depending on if the unit is a player or NPC and if it's a friend or enemy.
	if self:IsPlayer() then
		if self:IsFriend() then
			self:UpdateFriendPlayerAuraFrames();
		else
			self:UpdateEnemyPlayerAuraFrames();
		end
	else
		if self:IsFriend() then
			self:UpdateFriendNpcAuraFrames();
		else
			self:UpdateEnemyNpcAuraFrames();
		end
	end
end

function NamePlateAurasMixin:UpdateScale(scaleData)
	self.scaleFromSize = scaleData.aura;
	self:UpdateAuraScale();
end

function NamePlateAurasMixin:GetScaleFromSize()
	return self.scaleFromSize or 1.0;
end

function NamePlateAurasMixin:UpdateAuraScale()
	local auraScale = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.AURA_SCALE_CVAR);
	local scaleFromSize = self:GetScaleFromSize();

	local auraItemScale = auraScale * scaleFromSize;
	if auraItemScale == self.auraItemScale then
		return;
	end

	self.auraItemScale = auraItemScale;

	-- The size of the icons dictates how many will fit on a single line. As the size increases, any
	-- debuffs beyond the stride will wrap onto a second line.
	if auraScale <= 0.71 then
		self.DebuffListFrame.stride = 12;
	elseif auraScale <= 0.81 then
		self.DebuffListFrame.stride = 10;
	elseif auraScale <= 0.91 then
		self.DebuffListFrame.stride = 9;
	elseif auraScale <= 1.01 then
		self.DebuffListFrame.stride = 8;
	elseif auraScale <= 1.21 then
		self.DebuffListFrame.stride = 7;
	else
		self.DebuffListFrame.stride = 6;
	end

	if self:IsShown() then
		if self.explicitAuraList then
			self:RefreshExplicitAuras()
		else
			self:RefreshAuras();
			self:RefreshLossOfControl();
		end
	end
end

function NamePlateAurasMixin:SetExplicitValues(explicitValues)
	-- The change to the explicit values can happen after the frame has already responded to the
	-- CVar changes, so force it to re-evaluate.
	self:RefreshExplicitAuras();
end
