----
-- Character Services uses a master which acts as a sort of state machine in combination with flows and blocks.
--
-- Flows must have the following functions:
--  :Initialize(controller):  This sets up the flow and any associated blocks.
--  :Advance(controller):  Advances the flow one step.
--  :Finish(controller):  Finishes the flow and does whatever it needs to process the data.  Should return true if completed sucessfully or false if it failed.
--
-- The methods are provided by a base class for all flows but may be overridden if necessary:
--  :SetUpBlock(controller): This sets up the current block for the given step.
--  :Rewind(controller): Backs the flow up to the next available step.
--  :HideBlock():  Hides the current block.
--  :Restart(controller):  Hide all blocks and restart the flow at step 1.
--  :OnHide():  Check each block for a :OnHide method and call it if it exists.
--
-- Flows should have the following members:
--  .data - reference to an entry in CharacterUpgrade_Items with display info
--  .FinishLabel - The label to show on the finish button for this flow.
--
-- Blocks are opaque data structures.  Frames that belong to blocks inherit the template for blocks, and all controls used for data collection must be in the ControlsFrame.
-- 
-- Blocks must have the following methods:
--  :Initialize() - Initializes the block and any controls to the active state.
--  :IsFinished() - Returns whether or not the block is finished and its result set.
--  :GetResult() - Gets the result from the block in a table passed back to the flow.
--
-- The following optional methods may be present on a block:
--  :FormatResult() - Formats the result for display with the result label.  If absent, :GetResult() will be used instead.
--  :OnHide() - This function is called when a block needs to handle any resetting when the flow is hidden.
--  :OnAdvance() - This function is called in response to the flow:Advance call if the block needs to handle any logic here.
--  :OnRewind() - This function is called in response to the flow:Rewind call if the block needs to handle any logic here.
--  :SkipIf() - Skip this block if a certain result is present
--  :OnSkip() - If you have a SkipIf() then OnSkip() will perform any actions you need if you are skipped.
--  :ShowPopupIf() - If you have a .Popup, then ShowPopupIf will perform a check if the popup should appear.
--  :GetPopupText() - If you have a .Popup, then GetPopupText fetch the text to display.
--
-- The following members must be present on a block:
--  .Back - Show the back button on the flow frame.
--  .Next - Show the next button on the flow frame.  Conflicts with .Finish
--  .Finish - Show the finish button on the flow frame.  Conflicts with .Next

-- The following must be on all blocks not marked as HiddenStep:
--  .ActiveLabel - The label to show when the block is active above the controls.
--  .ResultsLabel - The label to show when the block is finished above the results themselves.
--
-- The following members may be present on a block:
--  .AutoAdvance - If true the flow will automatically advance when the block is finished and will not wait for user input.
--  .HiddenStep - This is only valid for the end step of any flow.  This says that this block has no meaningful controls or results for the user and should instead just
--    cause the master to change the flow controls.
--  .SkipOnRewind - This tells the flow to ignore the :IsFinished() result when deciding where to rewind and instead skip this block.
--  .ExtraOffset - May be set on a block by the flow for the master to add extra vertical offset to a block based on previous results.
--  .Popup - May be set on a block to potentially show a popup before advancing to the next step.
--
-- However a block uses controls to gather data, once it has data and is finished it should call
-- CharacterServicesMaster_Update() to advance the flow and button states.
----

CHARACTER_UPGRADE_CREATE_CHARACTER = false;
CHARACTER_UPGRADE_CREATE_CHARACTER_DATA = nil;

local UPGRADE_90_MAX_LEVEL = 90;
local UPGRADE_100_MAX_LEVEL = 100;
local UPGRADE_BONUS_LEVEL = 60;

LE_EXPANSION_7_0 = 6;
CURRENCY_KRW = 3;

local RAID_CLASS_COLORS = {
	["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
	["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
	["PRIEST"] = { r = 1.0, g = 1.0, b = 1.0, colorStr = "ffffffff" },
	["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
	["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, colorStr = "ff69ccf0" },
	["ROGUE"] = { r = 1.0, g = 0.96, b = 0.41, colorStr = "fffff569" },
	["DRUID"] = { r = 1.0, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
	["SHAMAN"] = { r = 0.0, g = 0.44, b = 0.87, colorStr = "ff0070de" },
	["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23, colorStr = "ffc41f3b" },
	["MONK"] = { r = 0.0, g = 1.00 , b = 0.59, colorStr = "ff00ff96" },
};

local classIds = {
	["WARRIOR"] = 1,
	["PALADIN"] = 2,
	["HUNTER"] = 3,
	["ROGUE"] = 4,
	["PRIEST"] = 5,
	["DEATHKNIGHT"] = 6,
	["SHAMAN"] = 7,
	["MAGE"] = 8,
	["WARLOCK"] = 9,
	["MONK"] = 10,
	["DRUID"] = 11,
}; 

local factionLogoTextures = {
	[1]	= "Interface\\Icons\\Inv_Misc_Tournaments_banner_Orc",
	[2]	= "Interface\\Icons\\Achievement_PVP_A_A",
};

local factionLabels = {
	[1] = FACTION_HORDE,
	[2] = FACTION_ALLIANCE,
};

local factionIds = {
	["Horde"] = 1,
	["Alliance"] = 2,
};

local factionColors = { 
	[factionIds["Horde"]] = "ffe50d12", 
	[factionIds["Alliance"]] = "ff4a54e8"
};

local stepTextures = {
	[1] = { 0.16601563, 0.23535156, 0.00097656, 0.07812500 },	
	[2] = { 0.23730469, 0.30664063, 0.00097656, 0.07812500 },	
	[3] = { 0.30859375, 0.37792969, 0.00097656, 0.07812500 },	
	[4] = { 0.37988281, 0.44921875, 0.00097656, 0.07812500 },	
	[5] = { 0.45117188, 0.52050781, 0.00097656, 0.07812500 },	
	[6] = { 0.52246094, 0.59179688, 0.00097656, 0.07812500 },	
	[7] = { 0.59375000, 0.66308594, 0.00097656, 0.07812500 },	
	[8] = { 0.66503906, 0.73437500, 0.00097656, 0.07812500 },	
	[9] = { 0.73632813, 0.80566406, 0.00097656, 0.07812500 },	
};

local professionsMap = {
	[164] = CHARACTER_PROFESSION_BLACKSMITHING,
	[165] = CHARACTER_PROFESSION_LEATHERWORKING,
	[171] = CHARACTER_PROFESSION_ALCHEMY,
	[182] = CHARACTER_PROFESSION_HERBALISM,
	[186] = CHARACTER_PROFESSION_MINING,
	[197] = CHARACTER_PROFESSION_TAILORING,
	[202] = CHARACTER_PROFESSION_ENGINEERING,
	[333] = CHARACTER_PROFESSION_ENCHANTING,
	[393] = CHARACTER_PROFESSION_SKINNING,
	[755] = CHARACTER_PROFESSION_JEWELCRAFTING,
	[773] = CHARACTER_PROFESSION_INSCRIPTION,
};

local classDefaultProfessionMap = {
	["WARRIOR"] = "PLATE",
	["PALADIN"] = "PLATE",
	["HUNTER"] = "LEATHERMAIL",
	["ROGUE"] = "LEATHERMAIL",
	["PRIEST"] = "CLOTH",
	["DEATHKNIGHT"] = "PLATE",
	["SHAMAN"] = "LEATHERMAIL",
	["MAGE"] = "CLOTH",
	["WARLOCK"] = "CLOTH",
	["MONK"] = "LEATHERMAIL",
	["DRUID"] = "LEATHERMAIL",
};

local defaultProfessions = {
	["PLATE"] = { [1] = 164, [2] = 186 },
	["LEATHERMAIL"] = { [1] = 165, [2] = 393 },
	["CLOTH"] = { [1] = 197, [2] = 333 },
};

GlueDialogTypes["PRODUCT_ASSIGN_TO_TARGET_FAILED"] = {
	text = BLIZZARD_STORE_INTERNAL_ERROR,
	button1 = OKAY,
	escapeHides = true,
};

local CharacterUpgradeCharacterSelectBlock = { Back = false, Next = false, Finish = false, AutoAdvance = true, ActiveLabel = SELECT_CHARACTER_ACTIVE_LABEL, ResultsLabel = SELECT_CHARACTER_RESULTS_LABEL };
local CharacterUpgradeSpecSelectBlock = { Back = true, Next = true, Finish = false, ActiveLabel = SELECT_SPEC_ACTIVE_LABEL, ResultsLabel = SELECT_SPEC_RESULTS_LABEL, Popup = "BOOST_NOT_RECOMMEND_SPEC_WARNING" };
local CharacterUpgradeFactionSelectBlock = { Back = true, Next = true, Finish = false, ActiveLabel = SELECT_FACTION_ACTIVE_LABEL, ResultsLabel = SELECT_FACTION_RESULTS_LABEL };
local CharacterUpgradeEndStep = { Back = true, Next = false, Finish = true, HiddenStep = true, SkipOnRewind = true };

CharacterServicesFlowPrototype = {};

CharacterUpgradeFlow = { Icon = "Interface\\Icons\\achievement_level_90", Text = CHARACTER_UPGRADE_90_FLOW_LABEL, FinishLabel = CHARACTER_UPGRADE_FINISH_LABEL };
CharacterUpgradeFlow.Steps = {
	[1] = CharacterUpgradeCharacterSelectBlock,
	[2] = CharacterUpgradeSpecSelectBlock,
	[3] = CharacterUpgradeFactionSelectBlock,
	[4] = CharacterUpgradeEndStep,
}
CharacterUpgradeFlow.numSteps = 4;

CharacterUpgrade_Items = {
	[LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_90_CHARACTER_UPGRADE] = {
		free = {
			productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_90_CHARACTER_UPGRADE,
			Size = { x = 72, y = 68 },
			icon = "Interface\\Icons\\achievement_level_90",		
			iconBorder = "services-ring-wod",
			
			maxLevel = UPGRADE_90_MAX_LEVEL,
			expansion = LE_EXPANSION_WARLORDS_OF_DRAENOR,
			popupDesc = {
				title = CHARACTER_UPGRADE_FREE_90_POPUP_TITLE,
				desc = CHARACTER_UPGRADE_FREE_90_POPUP_DESCRIPTION,
				width = 430,
				offset = { x = 8, y = 26 },
				topAtlas = "boostpopup-wod-top",
				middleAtlas = "boostpopup-wod-middle",
				bottomAtlas = "boostpopup-wod-bottom",
			},
			
			tooltipTitle = CHARACTER_UPGRADE_WOD_TOKEN_TITLE,
			tooltipDesc = CHARACTER_UPGRADE_WOD_TOKEN_DESCRIPTION,
			flowTitle = CHARACTER_UPGRADE_90_FLOW_LABEL,
			
			glowOffset = { x = 2, y = 4 },
			free = true,
			
			professionLevel = 600,
		},
		paid = {
			productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_90_CHARACTER_UPGRADE,
			icon = "Interface\\Icons\\achievement_level_90",
			iconBorder = "services-ring",
			
			maxLevel = UPGRADE_90_MAX_LEVEL,
			tooltipTitle = CHARACTER_UPGRADE_90_TOKEN_TITLE,
			tooltipDesc = CHARACTER_UPGRADE_90_TOKEN_DESCRIPTION,
			flowTitle = CHARACTER_UPGRADE_90_FLOW_LABEL,
			
			professionLevel = 600,
		},
	},
	[LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_100_CHARACTER_UPGRADE] = {
		free = {
			productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_100_CHARACTER_UPGRADE;
			icon = "Interface\\Icons\\achievement_level_100",
			iconBorder = "services-ring",
			
			maxLevel = UPGRADE_100_MAX_LEVEL,
			expansion = LE_EXPANSION_7_0,
			popupDesc = {
				title = CHARACTER_UPGRADE_FREE_100_POPUP_TITLE,
				desc = CHARACTER_UPGRADE_FREE_100_POPUP_DESCRIPTION,
				width = 430,
				offset = { x = 8, y = 18 },
				topAtlas = "boostpopup-legion-top",
				middleAtlas = "boostpopup-legion-middle",
				bottomAtlas = "boostpopup-legion-bottom",
			},
			
			tooltipTitle = CHARACTER_UPGRADE_100_TOKEN_TITLE,
			tooltipDesc = CHARACTER_UPGRADE_100_TOKEN_DESCRIPTION,
			flowTitle = CHARACTER_UPGRADE_100_FLOW_LABEL,
			free = true,
			
			professionLevel = 700,
		},
		paid = {
			productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_100_CHARACTER_UPGRADE;
			icon = "Interface\\Icons\\achievement_level_100",		
			iconBorder = "services-ring",
			maxLevel = UPGRADE_100_MAX_LEVEL,
			tooltipTitle = CHARACTER_UPGRADE_100_TOKEN_TITLE,
			tooltipDesc = CHARACTER_UPGRADE_100_TOKEN_DESCRIPTION,
			flowTitle = CHARACTER_UPGRADE_100_FLOW_LABEL,
			
			professionLevel = 700,
		},
	}
}

CharacterUpgrade_DisplayOrder = { 
	{ productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_90_CHARACTER_UPGRADE,		free = false},
	{ productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_90_CHARACTER_UPGRADE,		free = true	},
	{ productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_100_CHARACTER_UPGRADE,	free = true	},
	{ productId = LE_BATTLEPAY_PRODUCT_ITEM_LEVEL_100_CHARACTER_UPGRADE ,	free = false},
}

function CharacterServicesFlowPrototype:BuildResults(steps)
	if (not self.results) then
		self.results = {};
	end
	wipe(self.results);
	for i = 1, steps do
		for k,v in pairs(self.Steps[i]:GetResult()) do
			self.results[k] = v;
		end
	end
	return self.results;
end

function CharacterServicesFlowPrototype:Rewind(controller)
	local block = self.Steps[self.step];
	local results;
	if (block.OnRewind) then
		block:OnRewind();
	end
	if (block:IsFinished() and not block.SkipOnRewind) then
		if (self.step ~= 1) then
			results = self:BuildResults(self.step - 1);
		end
		self:SetUpBlock(controller, results);
	else	
		self:HideBlock(self.step);
		self.step = self.step - 1;
		while ( self.Steps[self.step].SkipOnRewind ) do
			if (self.Steps[self.step].OnRewind) then
				self.Steps[self.step]:OnRewind();
			end
			self:HideBlock(self.step);
			self.step = self.step - 1;
		end
		if (self.step ~= 1) then
			results = self:BuildResults(self.step - 1);
		end
		self:SetUpBlock(controller, results);
	end
end

function CharacterServicesFlowPrototype:Restart(controller)
	for i = 1, #self.Steps do
		self:HideBlock(i);
	end
	self.step = 1;
	self:SetUpBlock(controller);
end

local function moveBlock(self, block, offset)
	local extraOffset = block.ExtraOffset or 0;
	local lastNonHiddenStep = self.step - 1;
	while (self.Steps[lastNonHiddenStep].HiddenStep and lastNonHiddenStep >= 1) do
		lastNonHiddenStep = lastNonHiddenStep - 1;
	end
	if (lastNonHiddenStep >= 1) then
		block.frame:SetPoint("TOP", self.Steps[lastNonHiddenStep].frame, "TOP", 0, offset - extraOffset);
	end
end

function CharacterServicesFlowPrototype:SetUpBlock(controller, results)
	local block = self.Steps[self.step];
	CharacterServicesMaster_SetCurrentBlock(controller, block);
	if (not block.HiddenStep) then
		if (self.step == 1) then
			block.frame:SetPoint("TOP", CharacterServicesMaster, "TOP", -30, 0);
		else
			moveBlock(self, block, -105);
		end
		block.frame.StepNumber:SetTexCoord(unpack(stepTextures[self.step]));
		block.frame:Show();
	end
	block:Initialize(results);
	CharacterServicesMaster_Update();
end

function CharacterServicesFlowPrototype:HideBlock(step)
	local block = self.Steps[step];
	if (not block.HiddenStep) then
		block.frame:Hide();
	end
end

function CharacterServicesFlowPrototype:OnHide()
	for i = 1, #self.Steps do
		local block = self.Steps[i];
		if (block.OnHide) then
			block:OnHide();
		end
	end
end

function CharacterUpgradeFlow:SetTarget(data)
	self.data = data;
end

function CharacterUpgradeFlow:Initialize(controller)
	CharacterUpgradeSecondChanceWarningFrame.warningAccepted = false;

	CharacterUpgradeCharacterSelectBlock.frame = CharacterUpgradeSelectCharacterFrame;
	CharacterUpgradeSpecSelectBlock.frame = CharacterUpgradeSelectSpecFrame;
	CharacterUpgradeFactionSelectBlock.frame = CharacterUpgradeSelectFactionFrame;

	CharacterUpgradeSecondChanceWarningFrame:Hide();

	self:Restart(controller);
end

function CharacterUpgradeFlow:OnAdvance()
	local block = self.Steps[self.step];
	if (self.step == 1) then return end;
	if (not block.HiddenStep) then
		local extraOffset = 0;
		if (self.step == 2) then
			extraOffset = 15;
		end
		moveBlock(self, block, -60 - extraOffset);
	end
end

function CharacterUpgradeFlow:Advance(controller)
	if (self.step == self.numSteps) then
		self:Finish(controller);
	else
		local block = self.Steps[self.step];
		if (block.OnAdvance) then
			block:OnAdvance();
		end

		self:OnAdvance();

		local results = self:BuildResults(self.step);
		if (self.step == 1) then
			local level = select(6, GetCharacterInfo(results.charid));
			if (level >= UPGRADE_BONUS_LEVEL) then
				self.Steps[2].ExtraOffset = 45;
			else
				self.Steps[2].ExtraOffset = 0;
			end
			local factionGroup = C_CharacterServices.GetFactionGroupByIndex(results.charid);
			
			if ( factionGroup ~= "Neutral" ) then
				self.Steps[3].SkipOnRewind = true;
			else
				self.Steps[3].SkipOnRewind = false;
			end
		end
		self.step = self.step + 1;
		while (self.Steps[self.step].SkipIf and self.Steps[self.step]:SkipIf(results)) do
			if (self.Steps[self.step].OnSkip) then
				self.Steps[self.step]:OnSkip();
			end
			self.step = self.step + 1;
		end
		self:SetUpBlock(controller, results);
	end
end

function CharacterUpgradeFlow:Finish(controller)
	if (not CharacterUpgradeSecondChanceWarningFrame.warningAccepted) then
		if ( C_PurchaseAPI.GetCurrencyID() == CURRENCY_KRW ) then
			CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_KRW_FINISH_BUTTON_POPUP_TEXT);
		else
			CharacterUpgradeSecondChanceWarningBackground.Text:SetText(CHARACTER_UPGRADE_FINISH_BUTTON_POPUP_TEXT);
		end
		CharacterUpgradeSecondChanceWarningFrame:Show();
		return false;
	end

	local results = self:BuildResults(self.numSteps);
	if (not results.faction) then
		-- Non neutral character, convert faction group to id.
		results.faction = factionIds[C_CharacterServices.GetFactionGroupByIndex(results.charid)];
	end
	local guid = select(14, GetCharacterInfo(results.charid));
	if (guid ~= results.playerguid) then
		-- Bail because guid has changed!
		message(CHARACTER_UPGRADE_CHARACTER_LIST_CHANGED_ERROR);
		self:Restart(controller);
		return false;
	end

	C_CharacterServices.AssignUpgradeDistribution(results.playerguid, results.faction, results.spec, results.classId, self.data.free, self.data.productId);
	return true;
end

local function replaceScripts(button)
	button:SetScript("OnClick", nil);
	button:SetScript("OnDoubleClick", nil);
	button:SetScript("OnDragStart", nil);
	button:SetScript("OnDragStop", nil);
	button:SetScript("OnMouseDown", nil);
	button:SetScript("OnMouseUp", nil);
	button.upButton:SetScript("OnClick", nil);
	button.downButton:SetScript("OnClick", nil);
	button:SetScript("OnEnter", nil);
	button:SetScript("OnLeave", nil);
end

local function resetScripts(button)
	button:SetScript("OnClick", CharacterSelectButton_OnClick);
	button:SetScript("OnDoubleClick", CharacterSelectButton_OnDoubleClick);
	button:SetScript("OnDragStart", CharacterSelectButton_OnDragStart);
	button:SetScript("OnDragStop", CharacterSelectButton_OnDragStop);
	-- Functions here copied from CharacterSelect.xml
	button:SetScript("OnMouseDown", function(self)
		CharacterSelect.pressDownButton = self;
		CharacterSelect.pressDownTime = 0;
	end);
	button.upButton:SetScript("OnClick", function(self)
		PlaySound("igMainMenuOptionCheckBoxOn");
		local index = self:GetParent().index;
		MoveCharacter(index, index - 1);
	end);
	button.downButton:SetScript("OnClick", function(self)
		PlaySound("igMainMenuOptionCheckBoxOn");
		local index = self:GetParent().index;
		MoveCharacter(index, index + 1);
	end);
	button:SetScript("OnEnter", function(self)
		if ( self.selection:IsShown() ) then
			CharacterSelectButton_ShowMoveButtons(self);
		end
		if ( self.isVeteranLocked ) then
			GlueTooltip:SetText(CHARSELECT_CHAR_LIMITED_TOOLTIP, nil, nil, nil, nil, true);
			GlueTooltip:Show();
			GlueTooltip:SetOwner(self, "ANCHOR_LEFT", -16, -5);
			CharSelectAccountUpgradeButtonPointerFrame:Show();
			CharSelectAccountUpgradeButtonGlow:Show();
		end
	end);
	button:SetScript("OnLeave", function(self)
		if ( self.upButton:IsShown() and not (self.upButton:IsMouseOver() or self.downButton:IsMouseOver()) ) then
			self.upButton:Hide();
			self.downButton:Hide();
		end
		CharSelectAccountUpgradeButtonPointerFrame:Hide();
		CharSelectAccountUpgradeButtonGlow:Hide();
		GlueTooltip:Hide();
	end);
	button:SetScript("OnMouseUp", CharacterSelectButton_OnDragStop);
end

local function disableScroll(scrollBar)
	scrollBar.ScrollUpButton:SetEnabled(false);
	scrollBar.ScrollDownButton:SetEnabled(false);
	scrollBar:GetParent():EnableMouseWheel(false);
end

local function enableScroll(scrollBar)
	scrollBar.ScrollUpButton:SetEnabled(true);
	scrollBar.ScrollDownButton:SetEnabled(true);
	scrollBar:GetParent():EnableMouseWheel(true);
end

local function replaceAllScripts()
	for i = 1, math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED) do
		local button = _G["CharSelectCharacterButton"..i];
		replaceScripts(button);
		button.upButton:Hide();
		button.downButton:Hide();
	end
end

function CharacterUpgradeCharacterSelectBlock:Initialize(results)
	for i = 1, 3 do
		if (self.frame.BonusResults[i]) then
			self.frame.BonusResults[i]:Hide();
		end
	end
	self.frame.NoBonusResult:Hide();
	enableScroll(CharacterSelectCharacterFrame.scrollBar);

	self.charid = nil;
	self.lastSelectedIndex = CharacterSelect.selectedIndex;

	local num = math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED);

	if (CHARACTER_UPGRADE_CREATE_CHARACTER) then
		CharacterSelect_UpdateButtonState()
		CHARACTER_LIST_OFFSET = max(num - MAX_CHARACTERS_DISPLAYED, 0);
		if (self.createNum < GetNumCharacters()) then
			CharacterSelect.selectedIndex = num;
			UpdateCharacterSelection(CharacterSelect);
			self.index = CharacterSelect.selectedIndex;
			self.charid = GetCharIDFromIndex(CharacterSelect.selectedIndex + CHARACTER_LIST_OFFSET);
			self.playerguid = select(14, GetCharacterInfo(self.charid));
			local button = _G["CharSelectCharacterButton"..num];
			replaceScripts(button);
			CharacterServicesMaster_Update();
			return;
		end
	end

	CharacterSelect_SaveCharacterOrder();
	-- Set up the GlowBox around the show characters
	self.frame.ControlsFrame.GlowBox:SetHeight(58 * num);
	if (CharacterSelectCharacterFrame.scrollBar:IsShown()) then
		self.frame.ControlsFrame.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, -8, -60);
		self.frame.ControlsFrame.GlowBox:SetWidth(238);
	else
		self.frame.ControlsFrame.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, 2, -60);
		self.frame.ControlsFrame.GlowBox:SetWidth(244);
	end
	for i = 1, MAX_CHARACTERS_DISPLAYED do
		if (not self.frame.ControlsFrame.Arrows[i]) then
			self.frame.ControlsFrame.Arrows[i] = CreateFrame("Frame", nil, self.frame.ControlsFrame, "CharacterServicesArrowTemplate");
		end
		if (not self.frame.ControlsFrame.BonusIcons[i]) then
			self.frame.ControlsFrame.BonusIcons[i] = CreateFrame("Frame", nil, self.frame.ControlsFrame, "CharacterServicesBonusIconTemplate");
		end
		local arrow = self.frame.ControlsFrame.Arrows[i];
		local bonusIcon = self.frame.ControlsFrame.BonusIcons[i];
		arrow:SetPoint("RIGHT", _G["CharSelectCharacterButton"..i], "LEFT", -8, 8);
		bonusIcon:SetPoint("LEFT", _G["CharSelectCharacterButton"..i.."ButtonTextName"], "RIGHT", -1, 0);
		arrow:Hide();
		bonusIcon:Hide();
	end

	CharacterSelect.selectedIndex = -1;
	UpdateCharacterSelection(CharacterSelect);

	local numEligible = 0;
	self.hasVeteran = false;
	replaceAllScripts();
	for i = 1, num do
		local button = _G["CharSelectCharacterButton"..i];
		_G["CharSelectPaidService"..i]:Hide();
		local level, _, _, _, _, _, _, _, _, _, _, _, boostInProgress = select(6, GetCharacterInfo(GetCharIDFromIndex(i+CHARACTER_LIST_OFFSET)));
		if (level >= CharacterUpgradeFlow.data.maxLevel or boostInProgress) then
			button.buttonText.name:SetTextColor(0.25, 0.25, 0.25);
			button.buttonText.Info:SetTextColor(0.25, 0.25, 0.25);
			button.buttonText.Location:SetTextColor(0.25, 0.25, 0.25);
			button:SetEnabled(false);
		else
			self.frame.ControlsFrame.Arrows[i]:Show();
			if (level >= UPGRADE_BONUS_LEVEL) then
				self.frame.ControlsFrame.BonusIcons[i]:Show();
			end
			button.buttonText.name:SetTextColor(1.0, 0.82, 0);
			button.buttonText.Info:SetTextColor(1, 1, 1);
			button.buttonText.Location:SetTextColor(0.5, 0.5, 0.5);
			button:SetEnabled(true);
			button:SetScript("OnClick", function(button)
				self.index = button:GetID();
				self.charid = GetCharIDFromIndex(self.index + CHARACTER_LIST_OFFSET);
				self.playerguid = select(14, GetCharacterInfo(self.charid));
				CharacterSelectButton_OnClick(button);
				button.selection:Show();
				CharacterServicesMaster_Update();
			end)
		end
	end
	
	for i = 1, GetNumCharacters() do
		local level, _, _, _, _, _, _, _, _, _, _, _, boostInProgress = select(6, GetCharacterInfo(GetCharIDFromIndex(i)));
		if (level < CharacterUpgradeFlow.data.maxLevel and not boostInProgress) then
			if (level >= UPGRADE_BONUS_LEVEL) then
				self.hasVeteran = true;
			end
			numEligible = numEligible + 1;
		end
	end

	self.frame.ControlsFrame.BonusLabel:SetHeight(self.frame.ControlsFrame.BonusLabel.BonusText:GetHeight());
	self.frame.ControlsFrame.BonusLabel:SetPoint("BOTTOM", CharSelectServicesFlowFrame, "BOTTOM", 10, 60);
	self.frame.ControlsFrame.BonusLabel:SetShown(self.hasVeteran);

	local errorFrame = CharacterUpgradeMaxCharactersFrame;
	errorFrame:Hide();
	self.frame.ControlsFrame.OrLabel:Hide();
	self.frame.ControlsFrame.CreateCharacterButton:Hide();
	if (num < MAX_CHARACTERS_DISPLAYED_BASE) then
		self.frame.ControlsFrame.OrLabel:Show();
		self.frame.ControlsFrame.CreateCharacterButton:Show();
		self.frame.ControlsFrame.CreateCharacterButton:SetID(CharacterSelect.createIndex);
	elseif (numEligible == 0) then
		self.frame:Hide();
		if (not errorFrame.initialized) then
			errorFrame:SetPoint("TOP", CharacterServicesMaster, "TOP", -30, 0);
			errorFrame:SetFrameLevel(CharacterServicesMaster:GetFrameLevel()+2);
			errorFrame:SetParent(CharacterServicesMaster);
			errorFrame.initialized = true;
		end
		errorFrame:Show();
	end
end

function CharacterUpgradeCharacterSelectBlock:IsFinished()
	return self.charid ~= nil;
end

function CharacterUpgradeCharacterSelectBlock:GetResult()
	return { charid = self.charid; playerguid = self.playerguid; }
end

function CharacterUpgradeCharacterSelectBlock:FormatResult()
	local name, _, class, classFileName, _, level, _, _, _, _, _, _, _, _, prof1, prof2 = GetCharacterInfo(self.charid);
	if (level >= UPGRADE_BONUS_LEVEL) then
		local defaults = defaultProfessions[classDefaultProfessionMap[classFileName]];
		if (prof1 == 0 and prof2 == 0) then
			prof1 = defaults[1];
			prof2 = defaults[2];
		elseif (prof1 == 0) then
			if (prof2 == defaults[1]) then
				prof1 = defaults[2];
			else
				prof1 = defaults[1];
			end
		elseif (prof2 == 0) then
			if (prof1 == defaults[1]) then
				prof2 = defaults[2];
			else
				prof2 = defaults[1];
			end
		end
		local bonuses = { 
			[1] = professionsMap[prof1], 
			[2] = professionsMap[prof2], 
			[3] = CHARACTER_PROFESSION_FIRST_AID 
		};
		for i = 1,3 do
			if (not self.frame.BonusResults[i]) then
				local frame = CreateFrame("Frame", nil, self.frame, "CharacterServicesBonusResultTemplate");
				self.frame.BonusResults[i] = frame;
			end
			local result = self.frame.BonusResults[i];
			if ( i == 1 ) then
				result:SetPoint("TOPLEFT", self.frame.ResultsLabel, "BOTTOMLEFT", 0, -2);
			else
				result:SetPoint("TOPLEFT", self.frame.BonusResults[i-1], "BOTTOMLEFT", 0, -2);
			end
			result.Label:SetText(CHARACTER_UPGRADE_PROFESSION_BOOST_RESULT_FORMAT:format(bonuses[i], CharacterUpgradeFlow.data.professionLevel));
			result:Show();
		end
	elseif (self.hasVeteran) then
		self.frame.NoBonusResult:Show();
	end
	return SELECT_CHARACTER_RESULTS_FORMAT:format(RAID_CLASS_COLORS[classFileName].colorStr, name, level, class);
end

function CharacterUpgradeCharacterSelectBlock:OnHide()
	enableScroll(CharacterSelectCharacterFrame.scrollBar);

	local num = math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED);

	for i = 1, num do
		local button = _G["CharSelectCharacterButton"..i];
		resetScripts(button);
		button:SetEnabled(true);
		button.buttonText.name:SetTextColor(1.0, 0.82, 0);
		button.buttonText.Info:SetTextColor(1, 1, 1);
		button.buttonText.Location:SetTextColor(0.5, 0.5, 0.5);
	end

	UpdateCharacterList(true);
	local index = self.lastSelectedIndex;
	if (self:IsFinished()) then
		index = self.index;
	end
	if (index <= 0 or index > MAX_CHARACTERS_DISPLAYED) then return end;
	CharacterSelect.selectedIndex = index;
	local button = _G["CharSelectCharacterButton"..index];
	CharacterSelectButton_OnClick(button);
	button.selection:Show();
end

function CharacterUpgradeCharacterSelectBlock:OnAdvance()
	disableScroll(CharacterSelectCharacterFrame.scrollBar);

	local index = self.index;

	local num = math.min(GetNumCharacters(), MAX_CHARACTERS_DISPLAYED);
	for i = 1, num do
		if (i ~= index) then
			local button = _G["CharSelectCharacterButton"..i];
			button:SetEnabled(false);
			button.buttonText.name:SetTextColor(0.25, 0.25, 0.25);
			button.buttonText.Info:SetTextColor(0.25, 0.25, 0.25);
			button.buttonText.Location:SetTextColor(0.25, 0.25, 0.25);
		end
	end
end

function CharacterUpgradeCreateCharacter_OnClick(self)
	CharacterUpgradeCharacterSelectBlock.createNum = GetNumCharacters();
	CHARACTER_UPGRADE_CREATE_CHARACTER = true;
	CHARACTER_UPGRADE_CREATE_CHARACTER_DATA = CharacterServicesMaster.flow.data;
	CharacterSelect_SelectCharacter(self:GetID());
end

local function formatDescription(description,results)
	if (not strfind(description, "%$")) then
		return description;
	end

	-- This is a very simple parser that will only handle $G/$g tokens
	local sex = select(17, GetCharacterInfo(results.charid));
	return gsub(description, "$[Gg]([^:]+):([^;]+);", "%"..sex);
end

function CharacterUpgradeSpecSelectBlock:Initialize(results)
	self.selected = nil;

	local classID = classIds[select(4,GetCharacterInfo(results.charid))];
	local sex = select(17, GetCharacterInfo(results.charid));
	local numSpecs = GetNumSpecializationsForClassID(classID);

	for i = 1, 4 do
		if (not self.frame.ControlsFrame.SpecButtons[i]) then
			local frame = CreateFrame("CheckButton", nil, self.frame.ControlsFrame, "CharacterUpgradeSelectSpecRadioButtonTemplate");
			frame:SetPoint("TOP", self.frame.ControlsFrame.SpecButtons[i - 1], "BOTTOM", 0, -35);
			self.frame.ControlsFrame.SpecButtons[i] = frame;
		end
		local button = self.frame.ControlsFrame.SpecButtons[i];
		if (i <= numSpecs ) then
			local specID, name, description, icon, _, role, isRecommended  = GetSpecializationInfoForClassID(classID, i, sex);
			button:SetID(specID);
			button.SpecIcon:SetTexture(icon);
			button.SpecName:SetText(name);
			button.RoleIcon:SetTexCoord(GetTexCoordsForRole(role));
			button.RoleName:SetText(_G["ROLE_"..role]);
			if ( isRecommended ) then
				button.SpecName:SetPoint("TOPLEFT", button.Frame, "TOPRIGHT", 6, -3);
				button.Recommended:Show();
				button.RoleName:SetPoint("TOPLEFT", button.Recommended, "BOTTOMLEFT");
			else
				button.SpecName:SetPoint("TOPLEFT", button.Frame, "TOPRIGHT", 6, -8);
				button.Recommended:Hide();
				button.RoleName:SetPoint("TOPLEFT", button.SpecName, "BOTTOMLEFT");
			end
			button:SetChecked(false);
			button:Show();
			button.tooltip = formatDescription(description, results);
		else
			button:Hide();
		end
	end
	self.classID = classID;
end

function CharacterUpgradeSpecSelectBlock:IsFinished()
	return self.selected ~= nil;
end

function CharacterUpgradeSpecSelectBlock:GetResult()
	return { spec = self.selected, classId = self.classID };
end

function CharacterUpgradeSpecSelectBlock:FormatResult()
	return GetSpecializationNameForSpecID(self.selected);
end

function CharacterUpgradeSpecSelectBlock:ShowPopupIf()
	local role = select(6, GetSpecializationInfoForSpecID(self.selected));
	return role == "HEALER";
end

function CharacterUpgradeSpecSelectBlock:GetPopupText()
	return string.format(BOOST_NOT_RECOMMEND_SPEC_WARNING, GetSpecializationNameForSpecID(self.selected));
end

function CharacterUpgradeSelectSpecRadioButton_OnClick(self, button, down)
	local owner = CharacterUpgradeSpecSelectBlock;
	local numSpecs = GetNumSpecializationsForClassID(owner.classID);
	if ( owner.selected == self:GetID() ) then
		self:SetChecked(true);
		return;
	else
		owner.selected = self:GetID();
		self:SetChecked(true);
	end
	
	for i = 1, numSpecs do
		local button = owner.frame.ControlsFrame.SpecButtons[i];
		if ( button:GetID() ~= self:GetID() ) then
			button:SetChecked(false);
		end
	end

	CharacterServicesMaster_Update();
end

function CharacterUpgradeFactionSelectBlock:Initialize(results)
	self.selected = nil;

	for i = 1, 2 do
		if (not self.frame.ControlsFrame.FactionButtons[i]) then
			local frame = CreateFrame("CheckButton", nil, self.frame.ControlsFrame, "CharacterUpgradeSelectFactionRadioButtonTemplate");
			frame:SetPoint("TOP", self.frame.ControlsFrame.FactionButtons[i - 1], "BOTTOM", 0, -35);
			frame:SetID(i);
			self.frame.ControlsFrame.FactionButtons[i] = frame;
		end
		local button = self.frame.ControlsFrame.FactionButtons[i];
		button.FactionIcon:SetTexture(factionLogoTextures[i]);
		button.FactionName:SetText(factionLabels[i]);
		button:SetChecked(false);
		button:Show();
	end
end

function CharacterUpgradeFactionSelectBlock:IsFinished()
	return self.selected ~= nil;
end

function CharacterUpgradeFactionSelectBlock:GetResult()
	return { faction = self.selected };
end

function CharacterUpgradeFactionSelectBlock:FormatResult()
	return SELECT_FACTION_RESULTS_FORMAT:format(factionColors[self.selected], factionLabels[self.selected]);
end

function CharacterUpgradeFactionSelectBlock:SkipIf(results)
	return C_CharacterServices.GetFactionGroupByIndex(results.charid) ~= "Neutral";
end

function CharacterUpgradeFactionSelectBlock:OnSkip()
	self.selected = nil;
end

function CharacterUpgradeSelectFactionRadioButton_OnClick(self, button, down)
	local owner = CharacterUpgradeFactionSelectBlock;
	local con = owner.ContinueButton;
	
	if ( owner.selected == self:GetID() ) then
		self:SetChecked(true);
		return;
	else
		owner.selected = self:GetID();
		self:SetChecked(true);
	end
	
	for i = 1, 2 do
		local button = owner.frame.ControlsFrame.FactionButtons[i];
		if ( button:GetID() ~= self:GetID() ) then
			button:SetChecked(false);
		end
	end

	CharacterServicesMaster_Update();
end

function CharacterUpgradeEndStep:Initialize(results)
	CharacterServicesMaster_Update();
end

function CharacterUpgradeEndStep:IsFinished()
	return true;
end

function CharacterUpgradeEndStep:GetResult()
	return {};
end

function CharacterUpgradeEndStep:OnRewind()
	if (CharacterUpgradeSecondChanceWarningFrame:IsShown()) then
		CharacterUpgradeSecondChanceWarningFrame:Hide();
	end
end
