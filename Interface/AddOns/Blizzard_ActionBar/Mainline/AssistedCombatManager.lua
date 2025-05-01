-- alternative name: OnePunchManager

AssistedCombatManager = {
	rotationSpells = { };
};

function AssistedCombatManager:OnSpellsChanged()
	local actionSpellID = C_AssistedCombat.GetActionSpell();
	self:SetActionSpell(actionSpellID);

	if self.assistedHighlightCandidateActionButtons and self:IsAssistedHighlightActive() then
		self:UpdateAssistedHighlightCandidateActionButtonsList()
	end
end

function AssistedCombatManager:SetActionSpell(actionSpellID)
	if self.actionSpellID == actionSpellID then
		return;
	end

	wipe(self.rotationSpells);

	self.spellDescription = nil;

	if self.spellDataLoadedCancelCallback then
		self.spellDataLoadedCancelCallback();
		self.spellDataLoadedCancelCallback = nil;
	end

	if actionSpellID then
		local rotationSpells = C_AssistedCombat.GetRotationSpells();
		for i, spellID in ipairs(rotationSpells) do
			self.rotationSpells[spellID] = true;
		end

		-- store the spell description now so there are no sparse headaches later
		local spell = Spell:CreateFromSpellID(actionSpellID);
		self.spellDataLoadedCancelCallback = spell:ContinueWithCancelOnSpellLoad(function()
			self.spellDescription = spell:GetSpellDescription(actionSpellID);
			self.spellDataLoadedCancelCallback = nil;
		end);
	end

	self.actionSpellID = actionSpellID;
	EventRegistry:TriggerEvent("AssistedCombatManager.OnSetActionSpell", actionSpellID);
end

function AssistedCombatManager:HasActionSpell()
	return not not self.actionSpellID;
end

function AssistedCombatManager:GetActionSpellID()
	return self.actionSpellID;
end

function AssistedCombatManager:GetActionSpellDescription()
	return self.spellDescription;
end

function AssistedCombatManager:IsRotationSpell(spellID)
	return not not self.rotationSpells[spellID];
end

function AssistedCombatManager:SetCanHighlightSpellbookSpells(on)
	self.canHighlightSpellbookSpells = on;
	EventRegistry:TriggerEvent("AssistedCombatManager.OnSetCanHighlightSpellbookSpells");
end

function AssistedCombatManager:ShouldHighlightSpellbookSpell(spellID)
	if not self.canHighlightSpellbookSpells and not self.useAssistedHighlight then
		return false;
	end

	return self:IsHighlightableSpellbookSpell(spellID);
end

function AssistedCombatManager:IsHighlightableSpellbookSpell(spellID)
	if not self:IsRotationSpell(spellID) then
		-- try the base spell in case of overrides
		local baseSpellID = C_Spell.GetBaseSpell(spellID);
		if not self:IsRotationSpell(baseSpellID) then
			return false;
		end
	end

	if self.useAssistedHighlight then
		return true;
	else
		if not self:HasActionSpell() then
			return false;
		end

		return C_ActionBar.HasAssistedCombatActionButtons();
	end
end

function AssistedCombatManager:IsAssistedHighlightActive()
	return self.useAssistedHighlight and self.affectingCombat;
end

function AssistedCombatManager:ShouldDowngradeSpellAlertForButton(actionButton)
	if not self:IsAssistedHighlightActive() or not actionButton.action then
		return false;
	end

	-- only spells that are part of the rotation should have downgrade spell alerts
	if self.assistedHighlightCandidateActionButtons and self.assistedHighlightCandidateActionButtons[actionButton] then
		local type, id, subType, overriddenID = GetActionInfo(actionButton.action);
		if type == "spell" or (type == "macro" and subType == "spell") then
			if overriddenID then
				id = overriddenID;
			end
			return self:IsRotationSpell(id);
		end
	end

	return false;
end

function AssistedCombatManager:IsRecommendedAssistedHighlightButton(actionButton)
	if not self:IsAssistedHighlightActive() then
		return false;
	end
	if not actionButton.AssistedCombatHighlightFrame then
		return false;
	end
	return actionButton.AssistedCombatHighlightFrame:IsShown();
end

function AssistedCombatManager:ProcessCVars()
	local updateRate = tonumber(GetCVar("assistedCombatIconUpdateRate"));
	self.updateRate = Clamp(updateRate, 0, 1);

	local wasUsingAssistedHighlight = self.useAssistedHighlight or false;
	self.useAssistedHighlight = GetCVarBool("assistedCombatHighlight");

	if self.useAssistedHighlight then
		if not wasUsingAssistedHighlight then
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.OnPlayerRegenChanged, self);
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.OnPlayerRegenChanged, self);
		else
			self.resetTicker = true;
		end
	elseif wasUsingAssistedHighlight then
		EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.OnPlayerRegenChanged, self);
		EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.OnPlayerRegenChanged, self);
	end

	if self.useAssistedHighlight ~= wasUsingAssistedHighlight then
		EventRegistry:TriggerEvent("AssistedCombatManager.OnSetUseAssistedHighlight", self.useAssistedHighlight);
	end

	self:UpdateAssistedHighlightState();
end

function AssistedCombatManager:OnPlayerRegenChanged()
	self.affectingCombat = UnitAffectingCombat("player");
	self:UpdateAssistedHighlightState();
end

function AssistedCombatManager:OnPlayerEnteringWorld()
	EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", AssistedCombatManager.OnPlayerEnteringWorld);
	self:ProcessCVars();
end

-- This will be called when a conditional macro changes which spell will be cast,
-- or when an action changes, like dragging a spell on/off or swapping the main action bar.
function AssistedCombatManager:OnActionButtonActionChanged(actionButton)
	if not self.assistedHighlightCandidateActionButtons then
		return;
	end

	local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
	self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
	self:SetAssistedHighlightFrameShown(actionButton, spellID == self.lastNextCastSpellID);
end

-- Will return a spellID for an actionButton that holds a rotation spell (ignoring AssistedRotation button)
-- or any macro (since a macro can contain multiple spells or include non-spells), nil otherwise
function AssistedCombatManager:GetActionButtonSpellForAssistedHighlight(actionButton)
	if actionButton.action then
		local type, id, subType, overriddenID = GetActionInfo(actionButton.action);
		if overriddenID  then
			id = overriddenID;
		end
		if type == "macro" then
			if subType == "spell" then
				return id;
			else
				-- This macro doesn't display a spell right now, but it could contain one.
				-- 0 won't match a spell but will keep this button as a candidate.
				return 0;
			end
		elseif type == "spell" then
			if subType ~= "assistedcombat" and self:IsRotationSpell(id) then
				return id;
			end
		end
	end
	return nil;
end

function AssistedCombatManager:SetAssistedHighlightFrameShown(actionButton, shown)
	local highlightFrame = actionButton.AssistedCombatHighlightFrame;
	if shown then
		if not highlightFrame then
			highlightFrame = CreateFrame("FRAME", nil, actionButton, "ActionBarButtonAssistedCombatHighlightTemplate");
			actionButton.AssistedCombatHighlightFrame = highlightFrame;
			if not actionButton.action then
				highlightFrame.Flipbook:SetSize(42, 42);
			end
			highlightFrame:SetPoint("CENTER");
			highlightFrame:SetFrameLevel(MainMenuBar:GetEndCapsFrameLevel() - 1);
			local reverse = true;
			highlightFrame.Flipbook.Anim:Play(reverse);
		end
		highlightFrame:Show();
	elseif highlightFrame then
		highlightFrame:Hide();
	end
end

function AssistedCombatManager:UpdateAllAssistedHighlightFramesForSpell(spellID)
	if self.assistedHighlightCandidateActionButtons then
		for actionButton, actionSpellID in pairs(self.assistedHighlightCandidateActionButtons) do
			self:SetAssistedHighlightFrameShown(actionButton, actionSpellID == spellID);
		end
		for i = 1, StanceBar.numForms or 0 do
			local actionButton = StanceBar.actionButtons[i];
			local show = spellID and actionButton.spellID == spellID;
			self:SetAssistedHighlightFrameShown(actionButton, show);
		end
	end
end

function AssistedCombatManager:BuildAssistedHighlightCandidateActionButtonsList()
	self.assistedHighlightCandidateActionButtons = { };
	ActionBarButtonEventsFrame:ForEachFrame(function(actionButton)
		local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
		if spellID then
			self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
		end
	end);
end

function AssistedCombatManager:UpdateAssistedHighlightCandidateActionButtonsList()
	if self.assistedHighlightCandidateActionButtons then
		for actionButton in pairs(self.assistedHighlightCandidateActionButtons) do
			local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
			self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
		end
	end
end

function AssistedCombatManager:UpdateAssistedHighlightState()
	if self.useAssistedHighlight and self.affectingCombat then
		if not self.highlightTicker then
			self.highlightTicker = C_Timer.NewTicker(self.updateRate, function() self:OnHighlightTicker() end);
		end
		EventRegistry:RegisterCallback("ActionButton.OnActionChanged", self.OnActionButtonActionChanged, self);
	elseif self.highlightTicker then
		self.highlightTicker:Cancel();
		self.highlightTicker = nil;
		self.lastNextCastSpellID = nil;
		EventRegistry:UnregisterCallback("ActionButton.OnActionChanged", self);
		local spellID = nil;  -- hide all
		self:UpdateAllAssistedHighlightFramesForSpell(spellID);
		-- do this last
		self.assistedHighlightCandidateActionButtons = nil;
	end
end

function AssistedCombatManager:OnHighlightTicker()
	if self.resetTicker then
		self.resetTicker = nil;
		self.highlightTicker:Cancel();
		self.highlightTicker = C_Timer.NewTicker(self.updateRate, GenerateClosure(self.OnHighlightTicker, self));
	end

	if not self.assistedHighlightCandidateActionButtons then
		self:BuildAssistedHighlightCandidateActionButtonsList();
	end

	local checkForVisibleButton = true;
	local spellID = C_AssistedCombat.GetNextCastSpell(checkForVisibleButton);

	if spellID ~= self.lastNextCastSpellID then
		self.lastNextCastSpellID = spellID;
		self:UpdateAllAssistedHighlightFramesForSpell(spellID);
		EventRegistry:TriggerEvent("AssistedCombatManager.OnAssistedHighlightSpellChange");
	end
end

EventRegistry:RegisterFrameEventAndCallback("SPELLS_CHANGED", AssistedCombatManager.OnSpellsChanged, AssistedCombatManager);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", AssistedCombatManager.OnPlayerEnteringWorld, AssistedCombatManager);

CVarCallbackRegistry:RegisterCallback("assistedCombatIconUpdateRate", AssistedCombatManager.ProcessCVars, AssistedCombatManager);
CVarCallbackRegistry:RegisterCallback("assistedCombatHighlight", AssistedCombatManager.ProcessCVars, AssistedCombatManager);
