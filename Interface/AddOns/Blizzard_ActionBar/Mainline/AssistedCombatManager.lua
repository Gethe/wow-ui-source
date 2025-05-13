-- alternative name: OnePunchManager

AssistedCombatManager = {
	rotationSpells = { };
};

function AssistedCombatManager:Init()
	self.init = true;

	CVarCallbackRegistry:RegisterCallback("assistedCombatIconUpdateRate", AssistedCombatManager.ProcessCVars, AssistedCombatManager);
	CVarCallbackRegistry:RegisterCallback("assistedCombatHighlight", AssistedCombatManager.ProcessCVars, AssistedCombatManager);

	AssistedCombatManager:ProcessCVars();
end

function AssistedCombatManager:OnSpellsChanged()
	-- update the rotation spells before anything else
	wipe(self.rotationSpells);
	local rotationSpells = C_AssistedCombat.GetRotationSpells();
	for i, spellID in ipairs(rotationSpells) do
		self.rotationSpells[spellID] = true;
	end

	local actionSpellID = C_AssistedCombat.GetActionSpell();
	self:SetActionSpell(actionSpellID);

	self.hasShapeshiftForms = GetNumShapeshiftForms() > 0;

	-- OnSpellsChanged will fire after VARIABLES_LOADED and PLAYER_ENTERING_WORLD
	if not self.init then
		self:Init();
	elseif self:IsAssistedHighlightActive() then
		self:UpdateAssistedHighlightCandidateActionButtonsList()
	end
end

function AssistedCombatManager:SetActionSpell(actionSpellID)
	if self.actionSpellID == actionSpellID then
		return;
	end

	self.spellDescription = nil;

	if self.spellDataLoadedCancelCallback then
		self.spellDataLoadedCancelCallback();
		self.spellDataLoadedCancelCallback = nil;
	end

	if actionSpellID then
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
	if not self.canHighlightSpellbookSpells and not self:IsAssistedHighlightActive() then
		return false;
	end

	return self:IsHighlightableSpellbookSpell(spellID);
end

function AssistedCombatManager:IsHighlightableSpellbookSpell(spellID)
	if not self:IsRotationSpell(spellID) then
		return false;
	end

	if self:IsAssistedHighlightActive() then
		return true;
	else
		if not self:HasActionSpell() then
			return false;
		end

		return C_ActionBar.HasAssistedCombatActionButtons();
	end
end

function AssistedCombatManager:IsAssistedHighlightActive()
	return not not self.useAssistedHighlight;
end

function AssistedCombatManager:ShouldDowngradeSpellAlertForButton(actionButton)
	if not actionButton.action then
		return false;
	end

	local usingAssistedCombat = self:IsAssistedHighlightActive() or C_ActionBar.HasAssistedCombatActionButtons();
	if not usingAssistedCombat then
		return false;
	end

	-- Only spells that are part of the rotation should have downgrade spell alerts
	local type, id, subType = GetActionInfo(actionButton.action);
	if type == "spell" or (type == "macro" and subType == "spell") then
		return self:IsRotationSpell(id);
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

	self:UpdateAssistedHighlightState(wasUsingAssistedHighlight);
end

function AssistedCombatManager:GetUpdateRate()
	return self.updateRate or 0;
end

function AssistedCombatManager:OnPlayerRegenChanged()
	self.affectingCombat = UnitAffectingCombat("player");
	self:ForceUpdateAtEndOfFrame();
end

-- This will be called when a conditional macro changes which spell will be cast,
-- or when an action changes, like dragging a spell on/off or swapping the main action bar.
function AssistedCombatManager:OnActionButtonActionChanged(actionButton)
	local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
	self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
	self:SetAssistedHighlightFrameShown(actionButton, self.lastNextCastSpellID and spellID == self.lastNextCastSpellID);

	if self.hasShapeshiftForms then
		self:ForceUpdateAtEndOfFrame();
	end
end

-- Will return a spellID for an actionButton that holds a rotation spell (ignoring AssistedRotation button)
-- or any macro (since a macro can contain multiple spells or include non-spells), nil otherwise
function AssistedCombatManager:GetActionButtonSpellForAssistedHighlight(actionButton)
	if actionButton.action then
		local type, id, subType = GetActionInfo(actionButton.action);
		if type == "macro" then
			if subType == "spell" then
				return id;
			else
				-- This macro doesn't display a spell right now, but it could contain one.
				-- 0 won't match a spell but will keep this button as a candidate.
				return 0;
			end
		elseif type == "spell" and subType ~= "assistedcombat" then
			if self:IsRotationSpell(id) then
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
			highlightFrame:SetPoint("CENTER");
			highlightFrame:SetFrameLevel(MainMenuBar:GetEndCapsFrameLevel() - 1);
			-- have to do this to get a single frame of the flipbook instead of the whole texture
			highlightFrame.Flipbook.Anim:Play();
			highlightFrame.Flipbook.Anim:Stop();
			-- stance buttons are smaller
			if not actionButton.action then
				highlightFrame.Flipbook:SetSize(48, 48);
			end
		end
		highlightFrame:Show();
		if self.affectingCombat then
			highlightFrame.Flipbook.Anim:Play();
		else
			highlightFrame.Flipbook.Anim:Stop();
		end
	elseif highlightFrame then
		highlightFrame:Hide();
	end
end

function AssistedCombatManager:UpdateAllAssistedHighlightFramesForSpell(spellID)
	if self.assistedHighlightCandidateActionButtons then
		local hasHighlightedActionButton = false;
		for actionButton, actionSpellID in pairs(self.assistedHighlightCandidateActionButtons) do
			local show = actionSpellID == spellID;
			hasHighlightedActionButton = hasHighlightedActionButton or show;
			self:SetAssistedHighlightFrameShown(actionButton, show);
		end
		-- don't highlight anything on the stance bar if there's already a highlight on a normal action button
		for i = 1, StanceBar.numForms or 0 do
			local actionButton = StanceBar.actionButtons[i];
			local show = not hasHighlightedActionButton and spellID and actionButton.spellID == spellID;
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

function AssistedCombatManager:UpdateAssistedHighlightState(wasActive)
	local isActive = self:IsAssistedHighlightActive();
	if isActive then
		if not self.updateFrame then
			self.updateFrame = CreateFrame("FRAME");
		end
		if not wasActive then
			self:BuildAssistedHighlightCandidateActionButtonsList();

			self.lastNextCastSpellID = nil;
			self.updateTimeLeft = 0;
			self.updateFrame:SetScript("OnUpdate", GenerateClosure(self.OnUpdate, self));

			EventRegistry:RegisterCallback("ActionButton.OnActionChanged", self.OnActionButtonActionChanged, self);
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self.OnPlayerRegenChanged, self);
			EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self.OnPlayerRegenChanged, self);
		end
	elseif wasActive then
		local spellID = nil;  -- hide all
		self:UpdateAllAssistedHighlightFramesForSpell(spellID);
		-- this must be after UpdateAllAssistedHighlightFramesForSpell
		self.assistedHighlightCandidateActionButtons = nil;

		self.lastNextCastSpellID = nil;
		self.updateFrame:SetScript("OnUpdate", nil);

		EventRegistry:UnregisterCallback("ActionButton.OnActionChanged", self);
		EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", self);
		EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", self);
	end

	if isActive ~= wasActive then
		EventRegistry:TriggerEvent("AssistedCombatManager.OnSetUseAssistedHighlight", isActive);
	end
end

function AssistedCombatManager:ForceUpdateAtEndOfFrame()
	self.updateTimeLeft = 0;
	self.lastNextCastSpellID = nil;
end

function AssistedCombatManager:OnUpdate(updateFrame, elapsed)
	self.updateTimeLeft = self.updateTimeLeft - elapsed;
	if self.updateTimeLeft <= 0 then
		self.updateTimeLeft = self:GetUpdateRate();

		local checkForVisibleButton = true;
		local spellID = C_AssistedCombat.GetNextCastSpell(checkForVisibleButton);

		if spellID ~= self.lastNextCastSpellID then
			self.lastNextCastSpellID = spellID;
			self:UpdateAllAssistedHighlightFramesForSpell(spellID);
			EventRegistry:TriggerEvent("AssistedCombatManager.OnAssistedHighlightSpellChange");
		end
	end
end

EventRegistry:RegisterFrameEventAndCallback("SPELLS_CHANGED", AssistedCombatManager.OnSpellsChanged, AssistedCombatManager);
