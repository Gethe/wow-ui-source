
local SpecIDToBackgroundAtlas = {
	-- DK
	[250] = "talents-background-deathknight-blood",
	[251] = "talents-background-deathknight-frost",
	[252] = "talents-background-deathknight-unholy",

	-- DH
	[577] = "talents-background-demonhunter-havoc",
	[581] = "talents-background-demonhunter-vengeance",

	-- Druid
	[102] = "talents-background-druid-balance",
	[103] = "talents-background-druid-feral",
	[104] = "talents-background-druid-guardian",
	[105] = "talents-background-druid-restoration",

	-- Evoker
	[1467] = "talents-background-evoker-devastation",
	[1468] = "talents-background-evoker-preservation",

	-- Hunter
	[253] = "talents-background-hunter-beastmastery",
	[254] = "talents-background-hunter-marksmanship",
	[255] = "talents-background-hunter-survival",

	-- Mage
	[62] = "talents-background-mage-arcane",
	[63] = "talents-background-mage-fire",
	[64] = "talents-background-mage-frost",

	-- Monk
	[268] = "talents-background-monk-brewmaster",
	[269] = "talents-background-monk-windwalker",
	[270] = "talents-background-monk-mistweaver",

	-- Paladin
	[65] = "talents-background-paladin-holy",
	[66] = "talents-background-paladin-protection",
	[70] = "talents-background-paladin-retribution",

	-- Priest
	[256] = "talents-background-priest-discipline",
	[257] = "talents-background-priest-holy",
	[258] = "talents-background-priest-shadow",

	-- Rogue
	[259] = "talents-background-rogue-assassination",
	[260] = "talents-background-rogue-outlaw",
	[261] =  "talents-background-rogue-subtlety",

	-- Shaman
	[262] = "talents-background-shaman-elemental",
	[263] = "talents-background-shaman-enhancement",
	[264] = "talents-background-shaman-restoration",

	-- Warlock
	[265] = "talents-background-warlock-affliction",
	[266] = "talents-background-warlock-demonology",
	[267] = "talents-background-warlock-destruction",

	-- Warrior
	[71] = "talents-background-warrior-arms",
	[72] = "talents-background-warrior-fury",
	[73] = "talents-background-warrior-protection",
};

local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;


ClassTalentCurrencyDisplayMixin = {};

function ClassTalentCurrencyDisplayMixin:SetPointTypeText(text)
	self.CurrencyLabel:SetText(TALENT_FRAME_CURRENCY_DISPLAY_FORMAT:format(text));
	self:MarkDirty();
end

function ClassTalentCurrencyDisplayMixin:SetAmount(amount)
	self.CurrencyAmount:SetText(amount);

	local enabled = not self:IsInspecting() and (amount > 0);
	local textColor = enabled and GREEN_FONT_COLOR or GRAY_FONT_COLOR;
	self.CurrencyAmount:SetTextColor(textColor:GetRGBA());

	self:MarkDirty();
end

function ClassTalentCurrencyDisplayMixin:IsInspecting()
	return self:GetTalentFrame():IsInspecting();
end

function ClassTalentCurrencyDisplayMixin:GetTalentFrame()
	return self:GetParent();
end


ClassTalentTalentsTabMixin = CreateFromMixins(TalentFrameBaseMixin, ClassTalentImportExportMixin, ClassTalentTalentsSearchMixin);

local ClassTalentTalentsTabEvents = {
	"TRAIT_CONFIG_CREATED",
	"ACTIVE_COMBAT_CONFIG_CHANGED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
	"STARTER_BUILD_ACTIVATION_FAILED",
	"TRAIT_CONFIG_DELETED",
	"TRAIT_CONFIG_UPDATED",
	"ACTIONBAR_SLOT_CHANGED"
};

local ClassTalentTalentsTabUnitEvents = {
	"UNIT_AURA",
};

ClassTalentTalentsTabMixin:GenerateCallbackEvents(
{
	"OpenPvPTalentList",
	"ClosePvPTalentList",
	"PvPTalentListClosed",
	"SelectTalentIDForSlot",
});

function ClassTalentTalentsTabMixin:OnLoad()
	self.initialBasePanOffsetX = self.basePanOffsetX;
	self.initialBasePanOffsetY = self.basePanOffsetY;

	TalentFrameBaseMixin.OnLoad(self);

	self:UpdateBasePanOffset();

	self.ResetButton:SetOnClickHandler(GenerateClosure(self.ResetTree, self));

	self.ApplyButton:SetOnClickHandler(GenerateClosure(self.CommitConfig, self));
	self.ApplyButton:SetOnEnterHandler(GenerateClosure(self.UpdateConfigButtonsState, self));
	self.UndoButton:SetOnClickHandler(GenerateClosure(self.RollbackConfig, self));

	self.PvPTalentList:SetTalentFrame(self);
	self.PvPTalentSlotTray:SetTalentFrame(self);

	self:InitializeLoadoutDropDown();

	self:InitializeSearch();

	-- TODO:: Remove this. It's all temporary until there's a better server-side solution.
	EventUtil.ContinueOnAddOnLoaded("Blizzard_ClassTalentUI", GenerateClosure(self.LoadSavedVariables, self));
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED");
end

-- This is registered and unregistered dynamically.
function ClassTalentTalentsTabMixin:OnUpdate()
	TalentFrameBaseMixin.OnUpdate(self);

	if self.searchString then
		self:UpdateFullSearchResults();
	end

	self:UpdateConfigButtonsState();

	self:UpdateStarterBuildHighlights();
	
	-- If player deviated from starter build, but then undid the deviation such that there's no changes to save,
	-- We can no longer wait till next commit so just unflag them now rather than deal with trying to reset ourselves to being in Starter Build mode.
	if self.unflagStarterBuildAfterNextCommit and not self:IsCommitInProgress() and self:GetIsStarterBuildActive() and not self:HasAnyConfigChanges() then
		self:UnflagStarterBuild();
	end
end

function ClassTalentTalentsTabMixin:OnShow()
	self:UpdateSpecBackground();
	self:RefreshConfigID();
	self:CheckSetSelectedConfigID();

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, ClassTalentTalentsTabEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentTalentsTabUnitEvents, "player");

	self:UpdateConfigButtonsState();

	-- Art TODO: Un-Comment this once animation graphics are updated
	--self:SetBackgroundAnimationsPlaying(true);
end

function ClassTalentTalentsTabMixin:LoadSavedVariables()
	self.variablesLoaded = true;

	self:CheckSetSelectedConfigID();
end

function ClassTalentTalentsTabMixin:UpdateBasePanOffset()
	-- TODO:: Replace this temporary fix up.
	local classIDToOffsets = {
		[1] = { extraOffsetX = 30, extraOffsetY = 0, }, -- Warrior
		[2] = { extraOffsetX = -60, extraOffsetY = -29, }, -- Paladin
		[3] = { extraOffsetX = 0, extraOffsetY = -29, }, -- Hunter
		[4] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Rogue
		[5] = { extraOffsetX = -30, extraOffsetY = -29, }, -- Priest
		[8] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Mage
		[11] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Druid
		[12] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Demon Hunter
		[13] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Evoker
	};

	local classOffsets = classIDToOffsets[self:GetClassID()];
	if classOffsets then
		local basePanOffsetX = self.initialBasePanOffsetX - (classOffsets.extraOffsetX or 0);
		local basePanOffsetY = self.initialBasePanOffsetY - (classOffsets.extraOffsetY or 0);
		self:SetBasePanOffset(basePanOffsetX, basePanOffsetY);
	else
		self:SetBasePanOffset(self.initialBasePanOffsetX, self.initialBasePanOffsetY);
	end

	self:UpdateAllTalentButtonPositions();
end

function ClassTalentTalentsTabMixin:UpdateSpecBackground()
	local currentSpecID = self:GetSpecID();
	local atlas = SpecIDToBackgroundAtlas[currentSpecID];
	if atlas and C_Texture.GetAtlasInfo(atlas) then
		self.Background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		self.OverlayBackground:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		self.BackgroundFlash:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end
end

function ClassTalentTalentsTabMixin:SetBackgroundAnimationsPlaying(playing)
	self.Sheen1.Anim:SetPlaying(playing);
	self.Sheen2.Anim:SetPlaying(playing);
	self.Sheen3.Anim:SetPlaying(playing);
	self.OverlayBackground.Anim:SetPlaying(playing);
end

function ClassTalentTalentsTabMixin:CheckSetSelectedConfigID()
	if not self.variablesLoaded or not self:IsShown() or self:IsInspecting() then
		return;
	end

	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	local lastSelectedSavedConfigID = currentSpecID and C_ClassTalents.GetLastSelectedSavedConfigID(currentSpecID) or nil;

	if self:GetIsStarterBuildActive() and not self.unflagStarterBuildAfterNextCommit then
		local autoApply = false;
		local skipLoad = true;
		self:SetSelectedSavedConfigID(Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID, autoApply, skipLoad);
	elseif lastSelectedSavedConfigID then
		self:SetSelectedSavedConfigID(lastSelectedSavedConfigID);
	else
		self.LoadoutDropDown:ClearSelection();
	end
end

function ClassTalentTalentsTabMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, ClassTalentTalentsTabEvents);
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentTalentsTabUnitEvents);

	-- Art TODO: Un-Comment this once animation graphics are updated
	--self:SetBackgroundAnimationsPlaying(false);
end

function ClassTalentTalentsTabMixin:OnEvent(event, ...)
	-- Overrides TalentFrameBaseMixin. The base method happens after because TRAIT_CONFIG_UPDATED requires self.commitedConfigID.
	
	if event == "TRAIT_CONFIG_CREATED" then
		local configInfo = ...;
		if configInfo.type == Enum.TraitConfigType.Combat then
			self:RefreshLoadoutOptions();

			local configID = configInfo.ID;
			if C_ClassTalents.IsConfigReady(configID) then
				local autoApply = true;
				self:SetSelectedSavedConfigID(configID, autoApply);
			else
				-- We'll get an update when the config is ready later.
				self.autoLoadNewConfigID = configID;
			end
		end
	elseif (event ==  "TRAIT_CONFIG_DELETED") or (event == "TRAIT_CONFIG_UPDATED") then
		self:RefreshLoadoutOptions();
	elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
		local configID = ...;
		self:SetConfigID(configID);
	elseif event == "CONFIG_COMMIT_FAILED" then
		-- If failed to commit while in a "we're waiting until next commit" state, keep us in that state
		if not self.unflagStarterBuildAfterNextCommit then
			self:SetSelectedSavedConfigID(self.lastSelectedConfigID);
		end
	elseif event == "STARTER_BUILD_ACTIVATION_FAILED" then
		self:SetSelectedSavedConfigID(self.lastSelectedConfigID);
	elseif event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateSpecBackground();
		self:RefreshLoadoutOptions();
		self:MarkTreeDirty();
		self:CheckSetSelectedConfigID();
	elseif event == "PLAYER_TALENT_UPDATE" then
		self:CheckSetSelectedConfigID();
		self:UnregisterEvent("PLAYER_TALENT_UPDATE");
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		if not self:IsInspecting() then
			self:UpdateTalentActionBarStatuses();
			self:UpdateFullSearchResults();
		end
	-- TODO:: Replace this events with more proper "CanChangeTalent" signal(s).
	elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_REGEN_DISABLED") or (event == "UNIT_AURA") then
		self:UpdateConfigButtonsState();
	end

	TalentFrameBaseMixin.OnEvent(self, event, ...);
end

function ClassTalentTalentsTabMixin:OnTraitConfigUpdated(configID)
	-- Overrides TalentFrameBaseMixin.

	if self.unflagStarterBuildAfterNextCommit and self.commitedConfigID then
		-- Player committed changes, it is now save to unflag them as using the Starter Build
		self:UnflagStarterBuild();
		return;
	end

	self:RefreshLoadoutOptions();

	if configID == self:GetConfigID() then
		local forceUpdate = true;
		self:SetConfigID(configID, forceUpdate);

		local commitedConfigID = self.commitedConfigID;

		self:SetCommitStarted(nil);

		if commitedConfigID then
			local autoApply = false;
			local skipLoad = true;
			self:SetSelectedSavedConfigID(commitedConfigID, autoApply, skipLoad);
		end

		self:UpdateTreeCurrencyInfo();
	elseif configID == self.autoLoadNewConfigID then
		local autoApply = true;
		self:SetSelectedSavedConfigID(self.autoLoadNewConfigID, autoApply);
		self.autoLoadNewConfigID = nil;
	else
		-- There was an error, reset.
		self:SetCommitStarted(nil);

		local forceUpdate = true;
		self:SetConfigID(self:GetConfigID(), forceUpdate);
	end
end

function ClassTalentTalentsTabMixin:InitializeLoadoutDropDown()
	self.LoadoutDropDown:SetEnabledCallback(GenerateClosure(self.CanSetDropDownValue, self));

	local loadoutWidth = self.LoadoutDropDown:GetWidth();
	local loadoutDropDownControl = self.LoadoutDropDown:GetDropDownControl();
	loadoutDropDownControl:SetDropDownListMinWidth(loadoutWidth+5);
	loadoutDropDownControl:SetControlWidth(loadoutWidth);
	loadoutDropDownControl:SetCustomMenuAnchorInfo(-2, 0, "BOTTOMLEFT", "TOPLEFT", loadoutDropDownControl);
	loadoutDropDownControl:SetNoneSelectedText(TALENT_FRAME_DROP_DOWN_DEFAULT);
	loadoutDropDownControl:SetNoneSelectedTextColor(0.5, 0.5, 0.5, 1);

	self:RefreshLoadoutOptions();
	self:RefreshConfigID();

	local function NewEntryCallback(entryName)
		C_ClassTalents.RequestNewConfig(entryName);

		-- Don't select the new config until the server responds.
		return nil;
	end

	local function NewEntryDisabledCallback()
		local disabled = not C_ClassTalents.CanCreateNewConfig();
		local title = ""; -- this needs to be set or the tooltip does not display
		local text = nil;
		local warning = TALENT_FRAME_NEW_LOADOUT_DISABLED_TOOLTIP;
		return disabled, title, text, warning;
	end

	self.LoadoutDropDown:SetNewEntryCallbackCustomPopup(NewEntryCallback, TALENT_FRAME_DROP_DOWN_NEW_LOADOUT, ClassTalentLoadoutCreateDialog, NewEntryDisabledCallback);

	local function EditLoadoutCallback(configID)
		ClassTalentLoadoutEditDialog:ShowDialog(configID);
	end

	self.LoadoutDropDown:SetEditEntryCallback(EditLoadoutCallback, TALENT_FRAME_DROP_DOWN_TOOLTIP_EDIT);

	local function ImportCallback()
		ClassTalentLoadoutImportDialog:ShowDialog();
	end

	local function ExportCallback()	
		-- TODO: lastSelectedConfigID is always set to ActiveConfigID, and returns the 
		local configID = self.lastSelectedConfigID or C_ClassTalents.GetActiveConfigID();
		local configInfo = C_Traits.GetConfigInfo(configID);
		local exportString = self:GetLoadoutExportString();
		CopyToClipboard(exportString);
		DEFAULT_CHAT_FRAME:AddMessage(TALENT_FRAME_EXPORT_TEXT:format(configInfo.name), YELLOW_FONT_COLOR:GetRGB());
	end


	local importSentinelInfo = {
		text = WHITE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_IMPORT),
		callback = ImportCallback,
	};

	local exportSentinelInfo = {
		text = WHITE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_EXPORT),
		callback = ExportCallback,
	};

	self.LoadoutDropDown:AddSentinelValue(importSentinelInfo);
	self.LoadoutDropDown:AddSentinelValue(exportSentinelInfo);

	local function LoadConfiguration(configID, isUserInput)
		if isUserInput then
			local function FinishLoadConfiguration()
				-- Eventually, this should probably check if we're previewing talents somewhere we can't change them.
				local autoApply = true;
				self:LoadConfigInternal(configID, autoApply);
			end

			self:GetParent():CheckConfirmResetAction(FinishLoadConfiguration);
		end
	end

	self.LoadoutDropDown:SetLoadCallback(LoadConfiguration);
end

function ClassTalentTalentsTabMixin:UpdateLastSelectedConfigID(configID)
	if self:IsInspecting() then
		return;
	end

	self.lastSelectedConfigID = configID;

	local currentSpecID = self:GetSpecID();
	if currentSpecID then
		C_ClassTalents.UpdateLastSelectedSavedConfigID(currentSpecID, configID);
	end
end

function ClassTalentTalentsTabMixin:RefreshGates()
	self.traitCurrencyIDToGate = {};

	TalentFrameBaseMixin.RefreshGates(self);
end

function ClassTalentTalentsTabMixin:ShouldDisplayGate(firstButton, condInfo)
	return TalentFrameBaseMixin.ShouldDisplayGate(self, firstButton, condInfo) and (not condInfo.traitCurrencyID or not self.traitCurrencyIDToGate[condInfo.traitCurrencyID]);
end

function ClassTalentTalentsTabMixin:GetFrameLevelForButton(nodeInfo)
	-- Overrides TalentFrameBaseMixin.

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((nodeInfo.posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	return TotalFrameLevelSpread - scaledYOffset;
end

function ClassTalentTalentsTabMixin:OnGateDisplayed(gate, firstButton, condInfo)
	-- Overrides TalentFrameBaseMixin.

	if condInfo.traitCurrencyID then
		self.traitCurrencyIDToGate[condInfo.traitCurrencyID] = gate;
	end
end

function ClassTalentTalentsTabMixin:AnchorGate(gate, button)
	-- Overrides TalentFrameBaseMixin.

	gate:SetPoint("RIGHT", button, "LEFT");
end

function ClassTalentTalentsTabMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	self:RefreshCurrencyDisplay();

	-- TODO:: Replace this pattern of updating gates.
	for condID, condInfo in pairs(self.condInfoCache) do
		if condInfo.isGate then
			self:MarkCondInfoCacheDirty(condID);
			self:ForceCondInfoUpdate(condID);
		end
	end

	self:RefreshGates();
end

function ClassTalentTalentsTabMixin:RefreshCurrencyDisplay()
	local classCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local classInfo = self:GetClassInfo();
	self.ClassCurrencyDisplay:SetPointTypeText(string.upper(classInfo.className));
	self.ClassCurrencyDisplay:SetAmount(classCurrencyInfo and classCurrencyInfo.quantity or 0);

	local specCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[2] or nil;
	self.SpecCurrencyDisplay:SetPointTypeText(string.upper(self:GetSpecName()));
	self.SpecCurrencyDisplay:SetAmount(specCurrencyInfo and specCurrencyInfo.quantity or 0);
end

function ClassTalentTalentsTabMixin:RefreshLoadoutOptions()
	self.configIDs = C_ClassTalents.GetConfigIDsBySpecID(self:GetSpecID());

	self.configIDToName = {};
	for i, configID in ipairs(self.configIDs) do
		local configInfo = C_Traits.GetConfigInfo(configID);
		self.configIDToName[configID] = (configInfo and configInfo.name) or "";
	end

	local function SelectionNameTranslation(configID)
		if configID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID then
			return TALENT_FRAME_DROP_DOWN_STARTER_BUILD;
		end

		return self.configIDToName[configID];
	end

	-- If spec has a starter build, add Starter Build as a dropdown option
	if self:GetHasStarterBuild() then
		table.insert(self.configIDs, Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID);
	end

	self.LoadoutDropDown:SetSelectionOptions(self.configIDs, SelectionNameTranslation, NORMAL_FONT_COLOR);

	if #self.configIDs == 0 then
		self.LoadoutDropDown:ClearSelection();
	end
end

function ClassTalentTalentsTabMixin:ResetTree()
	self:AttemptConfigOperation(C_Traits.ResetTree, self:GetTalentTreeID());
end

function ClassTalentTalentsTabMixin:LoadTalentTreeInternal()
	TalentFrameBaseMixin.LoadTalentTreeInternal(self);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:SetSelectedSavedConfigID(configID, autoApply, skipLoad)
	self.LoadoutDropDown:SetSelectionID(configID);

	self:UpdateLastSelectedConfigID(configID);

	if not skipLoad then
		self:LoadConfigInternal(configID, not not autoApply);
	end
end

function ClassTalentTalentsTabMixin:RefreshConfigID()
	if self:IsInspecting() then
		local forceUpdate = true;
		self:SetConfigID(Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID, forceUpdate);
	else
		local activeConfigID = C_ClassTalents.GetActiveConfigID() or self.configIDs[1];
		self:SetConfigID(activeConfigID);
	end
end

function ClassTalentTalentsTabMixin:SetConfigID(configID, forceUpdate)
	if not forceUpdate and (configID == self:GetConfigID()) then
		return;
	end

	local configInfo = C_Traits.GetConfigInfo(configID);
	if not configInfo then
		return;
	end

	TalentFrameBaseMixin.SetConfigID(self, configID);

	self.configurationInfo = configInfo;

	local forceTreeUpdate = true;
	self:SetTalentTreeID(self.configurationInfo.treeIDs[1], forceTreeUpdate);
end

function ClassTalentTalentsTabMixin:SetTalentTreeID(talentTreeID, forceUpdate)
	if TalentFrameBaseMixin.SetTalentTreeID(self, talentTreeID, forceUpdate) then
		self:UpdateConfigButtonsState();
	end
end

function ClassTalentTalentsTabMixin:SetCommitStarted(configID, commitFailed)
	TalentFrameBaseMixin.SetCommitStarted(self, configID, commitFailed);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:LoadConfigInternal(configID, autoApply)
	local loadResult = nil;

	if configID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID then
		loadResult = self:SetStarterBuildActive(true);
	else
		if self:GetIsStarterBuildActive() then
			-- Player is switching from Starter Build to a saved Loadout, unflag them as using Starter Build
			-- Unflagging resets any pending changes, so we have to wait until loading is complete to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
		end

		loadResult = C_ClassTalents.LoadConfig(configID, autoApply);
	end

	if loadResult == Enum.LoadConfigResult.NoChangesNecessary then
		self:UpdateLastSelectedConfigID(configID);

		if self.unflagStarterBuildAfterNextCommit then
			self:UnflagStarterBuild();
		end
	elseif (loadResult == Enum.LoadConfigResult.LoadInProgress) and autoApply then
		self:SetCommitStarted(configID);
	end
end

function ClassTalentTalentsTabMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function ClassTalentTalentsTabMixin:CommitConfigInternal()
	-- Overrides TalentFrameBaseMixin.

	local selectedConfigID = self.LoadoutDropDown:GetSelectionID();

	C_ClassTalents.CommitConfig(selectedConfigID);
end

function ClassTalentTalentsTabMixin:RollbackConfig(...)
	TalentFrameBaseMixin.RollbackConfig(self, ...);

	self:UpdateTreeCurrencyInfo();
	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:AttemptConfigOperation(...)
	TalentFrameBaseMixin.AttemptConfigOperation(self, ...);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:PurchaseRank(nodeID)
	-- Overrides TalentFrameBaseMixin.

	if not self:WillDeviateFromStarterBuild(nodeID) then
		TalentFrameBaseMixin.PurchaseRank(self, nodeID);
	else
		local function FinishPurchase()
			-- Player is deviating from the Starter Build, so need to unflag them as using it
			-- Unflagging resets any pending changes though, so we have to wait until they commit all their changes to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
			self.LoadoutDropDown:ClearSelection();
			TalentFrameBaseMixin.PurchaseRank(self, nodeID);
		end
		self:CheckConfirmStarterBuildDeviation(FinishPurchase);
	end
end

function ClassTalentTalentsTabMixin:SetSelection(nodeID, entryID)
	-- Overrides TalentFrameBaseMixin.

	if not self:WillDeviateFromStarterBuild(nodeID, entryID) then
		TalentFrameBaseMixin.SetSelection(self, nodeID, entryID);
	else
		local function FinishSelect()
			-- Player is deviating from the Starter Build, so need to unflag them as using it
			-- Unflagging resets any pending changes though, so we have to wait until they commit all their changes to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
			self.LoadoutDropDown:ClearSelection();
			TalentFrameBaseMixin.SetSelection(self, nodeID, entryID);
		end
		self:CheckConfirmStarterBuildDeviation(FinishSelect);
	end
end

function ClassTalentTalentsTabMixin:HasValidConfig()
	return (self:GetConfigID() ~= nil) and (self:GetTalentTreeID() ~= nil);
end

function ClassTalentTalentsTabMixin:HasAnyConfigChanges()
	if self:IsCommitInProgress() then
		return false;
	end

	return self:HasValidConfig() and C_Traits.ConfigHasStagedChanges(self:GetConfigID());
end

function ClassTalentTalentsTabMixin:UpdateConfigButtonsState()
	if self:IsInspecting() then
		return;
	end

	local canChangeTalents, canAdd, canChangeError = self:CanChangeTalents();

	local hasAnyChanges = self:HasAnyConfigChanges();
	self.ApplyButton:SetEnabled(hasAnyChanges and (canChangeTalents or canAdd));

	if hasAnyChanges and not canChangeTalents and canChangeError then
		self.ApplyButton:SetDisabledTooltip(canChangeError);
	else
		self.ApplyButton:SetDisabledTooltip(nil);
	end

	if hasAnyChanges then
		if self.ApplyButton:IsEnabled() then
			GlowEmitterFactory:Show(self.ApplyButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
			self.ApplyButton.YellowGlow:Hide();
		else
			GlowEmitterFactory:Hide(self.ApplyButton);
			self.ApplyButton.YellowGlow:Show();
		end
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
		self.ApplyButton.YellowGlow:Hide();
	end

	self.UndoButton:SetShown(hasAnyChanges);
	self.ResetButton:SetShown(not hasAnyChanges);
	self.ResetButton:SetEnabledState(self:HasValidConfig() and self:HasAnyPurchasedRanks() and not self:IsCommitInProgress());
	self.LoadoutDropDown:SetEnabledState(not self:IsCommitInProgress());
end

function ClassTalentTalentsTabMixin:HasAnyPurchasedRanks()
	for button in self:EnumerateAllTalentButtons() do
		local nodeInfo = button:GetNodeInfo();
		if nodeInfo and (nodeInfo.ranksPurchased > 0) then
			return true;
		end
	end

	return false;
end

function ClassTalentTalentsTabMixin:CanSetDropDownValue(selectedValue)
	if self:IsCommitInProgress() and (selectedValue ~= self.lastSelectedConfigID) then
		return false, false;
	end

	if selectedValue == nil then
		return true; -- The dropdown can always be cleared.
	end

	local currentSelectionID = self.LoadoutDropDown:GetSelectionID();
	if (currentSelectionID == nil) or not self.LoadoutDropDown:IsSelectionIDValid(currentSelectionID) then
		return true; -- The dropdown can always be initialized if the current selection is invalid.
	end

	local sentinelKey = self.LoadoutDropDown:GetSentinelKeyInfoFromSelectionID(selectedValue);
	if sentinelKey ~= nil then
		return true; -- new/import/export always enabled
	end

	return C_ClassTalents.CanChangeTalents();
end

function ClassTalentTalentsTabMixin:CanChangeTalents()
	if self:IsCommitInProgress() then
		return false, false;
	end

	return C_ClassTalents.CanChangeTalents();
end

function ClassTalentTalentsTabMixin:UpdateInspecting()
	self:UpdateBasePanOffset();
	self:RefreshConfigID();

	local hiddenDuringInspect = {
		self.ApplyButton,
		self.ResetButton,
		self.UndoButton,
		self.WarmodeButton,
		self.LoadoutDropDown,
	};

	local isInspecting = self:IsInspecting();
	for i, frame in ipairs(hiddenDuringInspect) do
		frame:SetShown(not isInspecting);
	end

	self.PvPTalentSlotTray:SetPoint("RIGHT", self.BottomBar, "RIGHT", isInspecting and -24 or -114, 0);

	self.SearchBox:ClearAllPoints();
	if isInspecting then
		self.SearchBox:SetPoint("BOTTOM", 0, 30);
	else
		self.SearchBox:SetPoint("LEFT", self.LoadoutDropDown, "RIGHT", 20, 0);
	end

	self:RefreshCurrencyDisplay();

	ClassTalentTalentsSearchMixin.UpdateInspecting(self);
end

function ClassTalentTalentsTabMixin:IsInspecting()
	-- Overrides TalentFrameBaseMixin.

	return self:GetClassTalentFrame():IsInspecting();
end

function ClassTalentTalentsTabMixin:GetInspectUnit()
	-- Overrides TalentFrameBaseMixin.

	return self:GetClassTalentFrame():GetInspectUnit();
end

function ClassTalentTalentsTabMixin:GetUnitSex()
	local unit = self:IsInspecting() and self:GetInspectUnit() or "player";
	return UnitSex(unit);
end

function ClassTalentTalentsTabMixin:GetClassID()
	if self:IsInspecting() then
		return select(3, UnitClass(self:GetInspectUnit()));
	end

	return PlayerUtil.GetClassID();
end

function ClassTalentTalentsTabMixin:GetClassInfo()
	return C_CreatureInfo.GetClassInfo(self:GetClassID());
end

function ClassTalentTalentsTabMixin:GetSpecID()
	if self:IsInspecting() then
		return GetInspectSpecialization(self:GetInspectUnit());
	end

	return PlayerUtil.GetCurrentSpecID();
end

function ClassTalentTalentsTabMixin:GetSpecName()
	local unitSex = self:GetUnitSex();
	local specID = self:GetSpecID();
	return select(2, GetSpecializationInfoByID(specID, unitSex));
end

function ClassTalentTalentsTabMixin:GetDefinitionInfoForEntry(entryID)
	local definitionID = self:GetAndCacheEntryInfo(entryID).definitionID;
	if definitionID then
		return self:GetAndCacheDefinitionInfo(definitionID);
	end
	return nil;
end

function ClassTalentTalentsTabMixin:GetClassTalentFrame()
	return self:GetParent();
end

function ClassTalentTalentsTabMixin:IsHighlightedStarterBuildEntry(entryID)
	return self.activeStarterBuildHighlight and self.activeStarterBuildHighlight.entryID == entryID;
end

function ClassTalentTalentsTabMixin:UpdateStarterBuildHighlights()
	if self.activeStarterBuildHighlight then
		local previousHighlightedButton = self:GetTalentButtonByNodeID(self.activeStarterBuildHighlight.nodeID);
		if previousHighlightedButton then
			previousHighlightedButton:SetGlowing(false);
		end
		self.activeStarterBuildHighlight = nil;
	end

	if not self:GetIsStarterBuildActive() or self.unflagStarterBuildAfterNextCommit then
		return;
	end

	local nodeID, entryID = C_ClassTalents.GetNextStarterBuildPurchase();
	if not nodeID then
		return;
	end

	local highlightButton = self:GetTalentButtonByNodeID(nodeID);
	if highlightButton and highlightButton:IsSelectable() then
		highlightButton:SetGlowing(true);

		self.activeStarterBuildHighlight = { nodeID = nodeID, entryID = entryID };
	end
end

function ClassTalentTalentsTabMixin:CheckConfirmStarterBuildDeviation(callback)
	local referenceKey = self;
	if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
		local customData = {
			text = TALENT_FRAME_CONFIRM_STARTER_DEVIATION,
			callback = callback,
			acceptText = CONTINUE,
			cancelText = CANCEL,
			referenceKey = referenceKey,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	end
end

function ClassTalentTalentsTabMixin:WillDeviateFromStarterBuild(selectedNodeID, selectedEntryID)
	if not self:GetIsStarterBuildActive() or self.unflagStarterBuildAfterNextCommit then
		return false;
	end

	local starterNodeID, starterEntryID = C_ClassTalents.GetNextStarterBuildPurchase();
	return (starterNodeID and starterNodeID ~= selectedNodeID) or 
			(selectedEntryID and starterEntryID and starterEntryID ~= selectedEntryID);
end

function ClassTalentTalentsTabMixin:GetHasStarterBuild()
	return C_ClassTalents.GetHasStarterBuild();
end

function ClassTalentTalentsTabMixin:GetIsStarterBuildActive()
	return C_ClassTalents.GetStarterBuildActive();
end

function ClassTalentTalentsTabMixin:SetStarterBuildActive(isActive)
	return C_ClassTalents.SetStarterBuildActive(isActive);
end

function ClassTalentTalentsTabMixin:UnflagStarterBuild()
	self.unflagStarterBuildAfterNextCommit = false;
	self:SetStarterBuildActive(false);
end

function ClassTalentTalentsTabMixin:UpdateTalentActionBarStatuses()
	for button in self:EnumerateAllTalentButtons() do
		button:UpdateActionBarStatus();
	end
end