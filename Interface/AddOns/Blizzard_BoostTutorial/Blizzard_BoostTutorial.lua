-- TODO: Fix up console/dev functionality to use correct APIs
-- TODO: How to handle reloadui while tutorial is in progress

BoostTutorial = {
	spellQueue = {},
	MINIMUM_POINTER_SHOW_TIME = 3,
};

function BoostTutorial:TUTORIAL_UNHIGHLIGHT_SPELL()
	self:UnhighlightSpells();
end

function BoostTutorial:TUTORIAL_HIGHLIGHT_SPELL(spellID, textID)
	self:HighlightSpell(spellID, textID);
end

function BoostTutorial:SPELL_PUSHED_TO_ACTIONBAR(spellID)
	self.spellQueue[spellID] = true;
end

function BoostTutorial:UNIT_SPELLCAST_SUCCEEDED(unit, cast, spellID)
	-- NOTE: Might not want to to do this here in case the tutorial requires multiple spell casts...
	-- but in that case, shouldn't the server be telling the client to highlight a spell?
	self:UnhighlightSpells(spellID);
end

function BoostTutorial:ACTIONBAR_SLOT_CHANGED()
	self:UpdateQueuedActionBarHighlight();
end

function BoostTutorial:UPDATE_BONUS_ACTIONBAR()
	self:UpdateQueuedActionBarHighlight();
end

function BoostTutorial:SCENARIO_UPDATE()
	if not IsBoostTutorialScenario() then
		MainMenuMicroButton_SetAlertsEnabled(true, "boostTutorial");
		self:UnhighlightSpells();
	end
end

function BoostTutorial:OnEvent(event, ...)
	if (self[event]) then
		self[event](self, ...);
	end
end

-- TODO: Follow up about this, specifically the need for the comparisons against magic numbers (120, 25, and 72).
-- And maybe for adding a safe way for the client/server to entirely clear all action bars
function BoostTutorial:ClearActionBar()
	for i = 1, 120 do
		if ((i < 25) or (i > 72)) then
			PickupAction(i);
			ClearCursor();
		end
	end
end

function BoostTutorial:IsSpellInPushQueue(spellID)
	return self.spellQueue[spellID];
end

function BoostTutorial:RemoveSpellFromPushQueue(spellID)
	self.spellQueue[spellID] = nil;
end

function BoostTutorial:CanDismissPointer(nextSpellID, nextTextID)
	local info = self.currentPointerInfo;
	if (info) then
		if ((GetTime() - info.startTime) < self.MINIMUM_POINTER_SHOW_TIME) then
			return false;
		end

		if ((info.spellID == nextSpellID) and (info.textID == nextTextID)) then
			return false;
		end
	end

	return true;
end

function BoostTutorial:GetPointerFrameID(matchingSpellID)
	if (self.currentPointerInfo) then
		if (not matchingSpellID or self.currentPointerInfo.spellID == matchingSpellID) then
			return self.currentPointerInfo.pointerFrameID;
		end
	end
end

function BoostTutorial:HidePointerFrame(matchingSpellID)
	local pointerFrameID = self:GetPointerFrameID(matchingSpellID);
	if (pointerFrameID) then
		NPE_TutorialPointerFrame:Hide(pointerFrameID);
		return true;
	end
end

function BoostTutorial:SetQueuedHighlight(spellID, textID)
	self.pendingHighlightSpellID = spellID;
	self.pendingHighlightTextID = textID;
end

function BoostTutorial:UpdateQueuedActionBarHighlight()
	if (self.pendingHighlightSpellID and self.pendingHighlightTextID) then
		local spellID, textID = self.pendingHighlightSpellID, self.pendingHighlightTextID;
		self:SetQueuedHighlight();
		self:HighlightSpell(spellID, textID);
	end
end

function BoostTutorial:HighlightSpell(spellID, textID)
	if (not self:CanDismissPointer(spellID, textID)) then
		return;
	end

	local exists = false;
	local frame;

	-- Figure out what slot the spell is in, do not set the frame, this just gets the info
	for i = 1, 120 do
		local actionType, id = GetActionInfo(i);
		if ((actionType == "spell") and (id == spellID)) then
			exists = true;
			break;
		end
	end

	-- Check stance bar, this can set the frame, since this bar doesn't change
	if (not exists) then
		for i = 1, GetNumShapeshiftForms() do
			local id = select(4, GetShapeshiftFormInfo(i));
			if (id == spellID) then
				frame = StanceBar.actionButtons[i];
				exists = true;
				break;
			end
		end
	end

	-- Check the vehicle bar (For Illidan scenario)
	if (not exists) then
		if (OverrideActionBar and OverrideActionBar:IsShown()) then
			for i = 1, NUM_OVERRIDE_BUTTONS do
				local button = _G["OverrideActionBarButton" .. i];
				local actionType, id = GetActionInfo(button.action);
				if (actionType == "spell" and id == spellID) then
					frame = button;
					exists = true;
					break;
				end
			end
		end
	end

	-- Check pending actions (actions animating in from being learned)
	if (not exists) then
		if (self:IsSpellInPushQueue(spellID)) then
			self:SetQueuedHighlight(spellID, textID);
			return;
		end
	end

	-- Spell wasn't found on any action bar and wasn't pending, there's nothing to highlight.
	-- TODO: Potentially just show the desired tutorial in the bottom center of the screen (will also need to do this for addons)
	if (not exists) then
		return;
	end

	-- Check and see if the action is currently visible
	if (not frame) then
		-- Search the (visible) buttons for the action
		for i = 1, 12 do
			local f = _G["ActionButton" .. i];
			local _, id = GetActionInfo(f.action);
			if (id == spellID) then
				frame = f;
				break;
			end
		end

		-- If the action is not visible, wait for the action bar to change
		if (not frame) then
			self:SetQueuedHighlight(spellID, textID);
			return;
		end
	end

	-- Clean up state
	self:UnhighlightSpells();

	if (self:IsSpellInPushQueue(spellID)) then
		self:RemoveSpellFromPushQueue(spellID);
	end

	-- Show the highlight
	self.currentPointerInfo = {
		spellID = spellID,
		textID = textID,
		startTime = GetTime(),
		pointerFrameID = NPE_TutorialPointerFrame:Show(_G[textID] or textID, "DOWN", frame),
	};
end

function BoostTutorial:UnhighlightSpells(matchingSpellID)
	if (self:HidePointerFrame(matchingSpellID)) then
		self.currentPointerInfo = nil;
	end
end

function BoostTutorial:Init()
	local eventFrame = CreateFrame("Frame");
	eventFrame:SetScript("OnEvent", function (frame, ...) self:OnEvent(...) end);

	MainMenuMicroButton_SetAlertsEnabled(false, "boostTutorial");

	eventFrame:RegisterEvent("TUTORIAL_UNHIGHLIGHT_SPELL");
	eventFrame:RegisterEvent("TUTORIAL_HIGHLIGHT_SPELL");
	eventFrame:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	eventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	eventFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	eventFrame:RegisterEvent("SCENARIO_UPDATE");

	if (C_CharacterServicesPublic.ShouldSeeControlPopup()) then
		NPE_TutorialKeyboardMouseFrame_Frame:Show();
	end
end

BoostTutorial:Init();
