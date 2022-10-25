local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;
local PurchaseFXDelay = 1.2;


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
	"TRAIT_CONFIG_LIST_UPDATED",
	"ACTIONBAR_SLOT_CHANGED",
};

local ClassTalentTalentsTabUnitEvents = {
	"UNIT_AURA",
	"UNIT_SPELLCAST_SUCCEEDED",
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

	self:UpdateClassVisuals();

	self.ResetButton:SetOnClickHandler(GenerateClosure(self.ResetTree, self));

	self.ApplyButton:SetOnClickHandler(GenerateClosure(self.ApplyConfig, self));
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

	-- CVars are unloaded when we leave the world, so we have to refresh last selected configID after entering the world.
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- This is registered and unregistered dynamically.
function ClassTalentTalentsTabMixin:OnUpdate()
	TalentFrameBaseMixin.OnUpdate(self);

	self:UpdateFullSearchResults();

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
	EventRegistry:TriggerEvent("TalentFrame.TalentTab.Show");

	self:UpdateConfigButtonsState();

	self:UpdateStarterBuildHighlights();

	self:SetBackgroundAnimationsPlaying(true);
end

function ClassTalentTalentsTabMixin:LoadSavedVariables()
	self.variablesLoaded = true;

	self:CheckSetSelectedConfigID();
end

function ClassTalentTalentsTabMixin:UpdateClassVisuals()
	local classVisuals = ClassTalentUtil.GetVisualsForClassID(self:GetClassID());

	if self.classActivationTextures then
		if classVisuals and classVisuals.activationFX and C_Texture.GetAtlasInfo(classVisuals.activationFX) then
			for i, fxTexture in ipairs(self.classActivationTextures) do
				fxTexture:SetAtlas(classVisuals.activationFX, TextureKitConstants.UseAtlasSize);
			end
		end
	end

	-- TODO:: Replace this temporary fix up.
	local classOffsets = classVisuals and classVisuals.panOffset;
	if classOffsets then
		local basePanOffsetX = self.initialBasePanOffsetX - (classOffsets.x or 0);
		local basePanOffsetY = self.initialBasePanOffsetY - (classOffsets.y or 0);
		self:SetBasePanOffset(basePanOffsetX, basePanOffsetY);
	else
		self:SetBasePanOffset(self.initialBasePanOffsetX, self.initialBasePanOffsetY);
	end

	self:UpdateAllTalentButtonPositions();
end

function ClassTalentTalentsTabMixin:UpdateSpecBackground()
	local currentSpecID = self:GetSpecID();
	local atlas = ClassTalentUtil.GetAtlasForSpecID(currentSpecID);
	if atlas and C_Texture.GetAtlasInfo(atlas) then
		self.BackgroundFlash:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

		for i, background in ipairs(self.specBackgrounds) do
			background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		end
	end
end

function ClassTalentTalentsTabMixin:SetBackgroundAnimationsPlaying(playing)
	if self.backgroundAnims then
		for i, animGroup in ipairs(self.backgroundAnims) do
			animGroup:SetPlaying(playing);
		end
	end
end

function ClassTalentTalentsTabMixin:CheckSetSelectedConfigID()
	if not self.variablesLoaded or not self:IsShown() or self:IsInspecting() then
		return;
	end

	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	if not currentSpecID then
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
		return;
	end

	local lastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(currentSpecID);

	-- If the last selected configID has ended up invalid, clear out the saved value
	-- This can happen due to loadout deletion, or base spec config being saved as last selected, prior to the handling of those being fixed
	if lastSelectedSavedConfigID and not self.LoadoutDropDown:IsSelectionIDValid(lastSelectedSavedConfigID) then
		self:ClearLastSelectedConfigID();
		lastSelectedSavedConfigID = nil;
	end

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
	EventRegistry:TriggerEvent("TalentFrame.TalentTab.Hide");

	self:SetBackgroundAnimationsPlaying(false);
end

function ClassTalentTalentsTabMixin:OnEvent(event, ...)
	-- Overrides TalentFrameBaseMixin. The base method happens after because TRAIT_CONFIG_UPDATED requires self.commitedConfigID.

	if event == "TRAIT_CONFIG_CREATED" then
		local configInfo = ...;
		if configInfo.type == Enum.TraitConfigType.Combat then
			self:RefreshLoadoutOptions();

			local configID = configInfo.ID;

			if self.nextNewConfigRequiresPopulatedCheck and not C_ClassTalents.IsConfigPopulated(configID) then
				-- We'll get an update when the config is ready to load later
				self.nextNewConfigRequiresPopulatedCheck = false;
				self.autoLoadNewConfigID = configID;
			else
				-- Check either passed or not required, process the new config
				self.nextNewConfigRequiresPopulatedCheck = false;
				self:OnTraitConfigCreateFinished(configID);
			end
		end
	elseif event == "TRAIT_CONFIG_LIST_UPDATED" then
		self:RefreshLoadoutOptions();
	elseif event == "TRAIT_CONFIG_UPDATED" then
		self:RefreshLoadoutOptions();
	elseif event ==  "TRAIT_CONFIG_DELETED" then
		local configID = ...;
		self:OnTraitConfigDeleted(configID);
	elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
		local configID = ...;
		self:SetConfigID(configID);
	elseif event == "CONFIG_COMMIT_FAILED" then
		-- If failed to commit while in a "we're waiting until next commit" state, keep us in that state
		if not self.unflagStarterBuildAfterNextCommit then
			self:ResetToLastConfigID();
		end
	elseif event == "STARTER_BUILD_ACTIVATION_FAILED" then
		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.CommitFailed);
		self:ResetToLastConfigID();
		UIErrorsFrame:AddExternalErrorMessage("ERR_INTERNAL_ERROR");
	elseif event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateSpecBackground();
		self:RefreshLoadoutOptions();
		self:MarkTreeDirty();
		self:CheckSetSelectedConfigID();
	elseif event == "PLAYER_TALENT_UPDATE" then
		self:CheckSetSelectedConfigID();
		self:UnregisterEvent("PLAYER_TALENT_UPDATE");
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:CheckSetSelectedConfigID();
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		if not self:IsInspecting() then
			self:UpdateTalentActionBarStatuses();
			self:UpdateFullSearchResults();
		end
	-- TODO:: Replace this events with more proper "CanChangeTalent" signal(s).
	elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_REGEN_DISABLED") or (event == "UNIT_AURA") then
		self:UpdateConfigButtonsState();
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local spellID = select(3, ...);
		if spellID == Constants.TraitConsts.COMMIT_COMBAT_TRAIT_CONFIG_CHANGES_SPELL_ID then
			self:SetCommitVisualsActive(false);
			self:SetCommitCompleteVisualsActive(true);
		end
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

		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.CommitSucceeded);

		-- Avoid overwriting last selected loadout by saving the base spec config id as the selected config
		-- (The spec config will be both GetConfigID and the commited id in the case of applying changes to an active loadout)
		if commitedConfigID and commitedConfigID ~= self:GetConfigID() then
			local autoApply = false;
			local skipLoad = true;
			self:SetSelectedSavedConfigID(commitedConfigID, autoApply, skipLoad);
		end

		-- Button currency updates not needed as SetConfigID -> LoadTalentTree will already have reinstatiated all buttons
		local skipButtonUpdates = true;
		self:UpdateTreeCurrencyInfo(skipButtonUpdates);
	elseif configID == self.autoLoadNewConfigID then
		self:OnTraitConfigCreateFinished(self.autoLoadNewConfigID);
	end

	-- There are expected cases for TRAIT_CONFIG_UPDATED being fired that we don't need to react to
	-- Examples: 
	--  - Deleting a loadout while active may lead to Updated event for the next loadout down
	--  - Saving a change to a loadout may lead to Updated event both for the base spec config id and then the selected loadout config id
	-- If we do start getting "bad" Updated events, make sure to detect & handle those explicitly and not as a catch-all else case
end

function ClassTalentTalentsTabMixin:OnTraitConfigDeleted(configID)
	self:RefreshLoadoutOptions();

	if configID and self.lastSelectedConfigID == configID then
		-- Handle deletion of the loadout we're currently on by falling back to the default base spec loadout
		self:ClearLastSelectedConfigID();
	end
end

function ClassTalentTalentsTabMixin:OnTraitConfigCreateStarted(newConfigHasPurchasedRanks)
	-- Only configs with purchased ranks require a populated check to ensure their ranks have been applied
	self.nextNewConfigRequiresPopulatedCheck = newConfigHasPurchasedRanks;
	local active = true;
	local skipSpinnerDelay = true;
	self:SetCommitVisualsActive(active, skipSpinnerDelay);
end

function ClassTalentTalentsTabMixin:OnTraitConfigCreateFinished(configID)
	self:SetCommitVisualsActive(false);

	local autoApply = true;
	self:SetSelectedSavedConfigID(configID, autoApply);
	self.autoLoadNewConfigID = nil;

	-- Only do completion visuals if SetSelectedSavedConfigID's load did not put us into an in-progress commit or partial loadout.
	if not self:IsCommitInProgress() and not self:HasAnyConfigChanges() then
		self:SetCommitCompleteVisualsActive(true);
	end
end

function ClassTalentTalentsTabMixin:ResetToLastConfigID()
	if self.lastSelectedConfigID and self.LoadoutDropDown:IsSelectionIDValid(self.lastSelectedConfigID) and not self:IsStarterBuildConfig(self.lastSelectedConfigID) then
		-- Have a valid last selected config, reset back to that
		local autoApply = false;
		local skipLoad = false;
		local forceSkipAnimation = true;
		self:SetSelectedSavedConfigID(self.lastSelectedConfigID, autoApply, skipLoad, forceSkipAnimation);
	else
		-- No valid last selected config, reset to the base spec config
		self:ClearLastSelectedConfigID();

		local baseConfigID = C_ClassTalents.GetActiveConfigID();
		if baseConfigID then
			local autoApply = false;
			self:LoadConfigInternal(baseConfigID, autoApply);
		end
		-- If there's no base config either, nothing we can do except wait and hope we'll get a talent load event or something
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
		-- The new config will have all the state of the current config
		-- So if we have ranks now, the new one will have ranks too
		local newConfigHasPurchasedRanks = self:HasAnyPurchasedRanks();
		local success = C_ClassTalents.RequestNewConfig(entryName);

		if success then
			self:OnTraitConfigCreateStarted(newConfigHasPurchasedRanks);
		end

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

	local function CanEditLoadoutCallback(configID)
		-- TODO: Enable modified loadout settings dialog for Starter Build
		return not self:IsStarterBuildConfig(configID);
	end

	self.LoadoutDropDown:SetEditEntryCallback(EditLoadoutCallback, TALENT_FRAME_DROP_DOWN_TOOLTIP_EDIT, CanEditLoadoutCallback);

	local function ImportCallback()
		ClassTalentLoadoutImportDialog:ShowDialog();
	end

	local function ImportDisabledCallback()
		local disabled = not C_ClassTalents.CanCreateNewConfig();
		local title = ""; -- this needs to be set or the tooltip does not display
		local text = nil;
		local warning = TALENT_FRAME_NEW_LOADOUT_DISABLED_TOOLTIP;
		return disabled, title, text, warning;
	end

	local function ExportCallback()	
		local configID = self.lastSelectedConfigID or C_ClassTalents.GetActiveConfigID();
		local configInfo = C_Traits.GetConfigInfo(configID);
		local exportString = self:GetLoadoutExportString();
		CopyToClipboard(exportString);

		local configName = nil;
		if self:IsStarterBuildConfig(configID) then
			configName = TALENT_FRAME_DROP_DOWN_STARTER_BUILD;
		elseif configInfo and self.LoadoutDropDown:IsSelectionIDValid(configID) then
			configName = configInfo.name;
		else
			configName = TALENT_FRAME_DROP_DOWN_DEFAULT;
		end

		DEFAULT_CHAT_FRAME:AddMessage(TALENT_FRAME_EXPORT_TEXT:format(configName), YELLOW_FONT_COLOR:GetRGB());
	end

	local function ExportDisabledCallback()
		local disabled = self:HasAnyConfigChanges() or C_ClassTalents.HasUnspentTalentPoints();
		local title = ""; -- this needs to be set or the tooltip does not display
		local text = nil;
		local warning = TALENT_FRAME_EXPORT_LOADOUT_DISABLED_TOOLTIP;
		return disabled, title, text, warning;
	end

	local importSentinelInfo = {
		text = TALENT_FRAME_DROP_DOWN_IMPORT,
		colorCode = WHITE_FONT_COLOR_CODE,
		callback = ImportCallback,
		disabledCallback = ImportDisabledCallback,
	};

	local exportSentinelInfo = {
		text = TALENT_FRAME_DROP_DOWN_EXPORT,
		colorCode = WHITE_FONT_COLOR_CODE,
		callback = ExportCallback,
		disabledCallback = ExportDisabledCallback,
	};

	self.LoadoutDropDown:AddSentinelValue(importSentinelInfo);
	self.LoadoutDropDown:AddSentinelValue(exportSentinelInfo);

	local function LoadConfiguration(configID, isUserInput)
		if isUserInput then
			local function FinishLoadConfiguration()
				local autoApply = true;
				self:LoadConfigInternal(configID, autoApply);
			end

			local function CancelLoadConfiguration()
				if self.lastSelectedConfigID then
					self.LoadoutDropDown:SetSelectionID(self.lastSelectedConfigID);
				else
					self.LoadoutDropDown:ClearSelection();
				end
			end

			self:GetParent():CheckConfirmResetAction(FinishLoadConfiguration, CancelLoadConfiguration);
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

function ClassTalentTalentsTabMixin:ClearLastSelectedConfigID()
	self.lastSelectedConfigID = nil;
	local currentSpecID = self:GetSpecID();
	if currentSpecID then
		C_ClassTalents.UpdateLastSelectedSavedConfigID(currentSpecID, nil);
	end
	self.LoadoutDropDown:ClearSelection();
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

function ClassTalentTalentsTabMixin:UpdateTreeCurrencyInfo(skipButtonUpdates)
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self, skipButtonUpdates);

	self:RefreshCurrencyDisplay();

	if not skipButtonUpdates then
		for condID, condInfo in pairs(self.condInfoCache) do
			if condInfo.isGate then
				self:MarkCondInfoCacheDirty(condID);
				self:ForceCondInfoUpdate(condID);
			end
		end

		self:RefreshGates();
	end
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
	local oldConfigIDs = self.configIDs;
	local oldConfigNames = self.configIDToName;
	self.configIDs = C_ClassTalents.GetConfigIDsBySpecID(self:GetSpecID());

	self.configIDToName = {};
	for i, configID in ipairs(self.configIDs) do
		local configInfo = C_Traits.GetConfigInfo(configID);
		self.configIDToName[configID] = (configInfo and configInfo.name) or "";
	end

	local function SelectionNameTranslation(configID)
		return self.configIDToName[configID];
	end

	local function SelectionTooltipTranslation(configID)
		if self:IsStarterBuildConfig(configID) then
			return YELLOW_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD_TOOLTIP);
		end

		return nil;
	end

	-- If spec has a starter build, add Starter Build as a dropdown option
	if self:GetHasStarterBuild() then
		table.insert(self.configIDs, Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID);
		self.configIDToName[Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID] = BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD);
	end

	if oldConfigIDs and oldConfigNames then
		-- Avoid performance hit from calling SetSelectionOptions with the same options as were already set
		if tCompare(oldConfigIDs, self.configIDs) and tCompare(oldConfigNames, self.configIDToName) then
			return;
		end
	end

	self.LoadoutDropDown:SetSelectionOptions(self.configIDs, SelectionNameTranslation, NORMAL_FONT_COLOR, SelectionTooltipTranslation);

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

function ClassTalentTalentsTabMixin:SetSelectedSavedConfigID(configID, autoApply, skipLoad, forceSkipAnimation)
	self:UpdateLastSelectedConfigID(configID);

	local previousSelection = self.LoadoutDropDown:GetSelectionID();
	if previousSelection == configID then
		return;
	end

	self.LoadoutDropDown:SetSelectionID(configID);

	if not skipLoad then
		local skipAnimation = forceSkipAnimation or (previousSelection == nil);
		self:LoadConfigInternal(configID, not not autoApply, skipAnimation);
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

function ClassTalentTalentsTabMixin:CanCommitInstantly()
	-- Overrides TalentFrameBaseMixin.

	-- return C_ClassTalents.CanCommitInstantly();
	return false;
end

function ClassTalentTalentsTabMixin:SetCommitStarted(configID, reason, skipAnimation)
	TalentFrameBaseMixin.SetCommitStarted(self, configID, reason, skipAnimation);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:SetCommitCompleteVisualsActive(active)
	TalentFrameBaseMixin.SetCommitCompleteVisualsActive(self, active);

	if self.commitFlashAnims then
		for i, animGroup in ipairs(self.commitFlashAnims) do
			local isPlaying = animGroup:IsPlaying();
			if isPlaying ~= active then
				if active then
					animGroup:Restart();
				else
					animGroup:Stop();
				end
			end
		end
	end

	if active then
		if self.stagedPurchaseNodes and not self.stagedPurchaseTimer then
			-- Delay purchase animations a moment to allow post-commit refreshes/updates to process
			-- Otherwise the immediate frame gets clogged up and visuals get missed
			self.stagedPurchaseTimer = C_Timer.After(PurchaseFXDelay, function()
				if not self.stagedPurchaseNodes then
					return;
				end

				for i, nodeID in ipairs(self.stagedPurchaseNodes) do
					local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
					if buttonWithPurchase and buttonWithPurchase.PlayPurchaseEffect then
						buttonWithPurchase:PlayPurchaseEffect(self.FxModelScene);
					end
				end

				-- Play sound for collective node purchase effects
				PlaySound(SOUNDKIT.UI_CLASS_TALENT_APPLY_COMPLETE);

				self.stagedPurchaseNodes = nil;
				self.stagedPurchaseTimer = nil;
			end);
		end
	elseif not active then
		self.stagedPurchaseNodes = nil;
		self.FxModelScene:ClearEffects();
	end
end

function ClassTalentTalentsTabMixin:LoadConfigInternal(configID, autoApply, skipAnimation)
	local loadResult = nil;

	if self:IsStarterBuildConfig(configID) then
		if not self:GetHasStarterBuild() then
			error("Error loading Talents: Attempted to load Starter Build when Starter Build is not available");
		end

		loadResult = self:SetStarterBuildActive(true);
	else
		if self:GetIsStarterBuildActive() then
			-- Player is switching from Starter Build to a saved Loadout, unflag them as using Starter Build
			-- Unflagging resets any pending changes, so we have to wait until loading is complete to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
		end

		loadResult = C_ClassTalents.LoadConfig(configID, autoApply);
	end

	local isConfigReadyToApply = (loadResult == Enum.LoadConfigResult.Ready);
	self.isConfigReadyToApply = isConfigReadyToApply;

	if isConfigReadyToApply then
		self:UpdateLastSelectedConfigID(configID);
	elseif loadResult == Enum.LoadConfigResult.NoChangesNecessary then
		self:UpdateLastSelectedConfigID(configID);

		if self.unflagStarterBuildAfterNextCommit then
			self:UnflagStarterBuild();
		end

		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit, skipAnimation);
	elseif (loadResult == Enum.LoadConfigResult.LoadInProgress) and autoApply then
		self:SetCommitStarted(configID, TalentFrameBaseMixin.CommitUpdateReasons.CommitStarted, skipAnimation);
	end

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function ClassTalentTalentsTabMixin:ApplyConfig()
	if self:HasAnyConfigChanges() then
		self.isConfigReadyToApply = false;
		self:CommitConfig();
	else
		local selectedConfig = self.LoadoutDropDown:GetSelectionID();
		if selectedConfig and not self:IsStarterBuildConfig(selectedConfig) then
			-- Selected config is a loadout, save to that config
			self.isConfigReadyToApply = not C_ClassTalents.SaveConfig(selectedConfig);
		else
			-- Selected config is "Default Loadout" or StarterBuild, no need to save as changes exist in active config
			self.isConfigReadyToApply = false;
		end
		self:UpdateConfigButtonsState();
	end
end

function ClassTalentTalentsTabMixin:CommitConfigInternal()
	-- Overrides TalentFrameBaseMixin.

	local selectedConfigID = self.LoadoutDropDown:GetSelectionID();

	-- Cache nodes with staged purchases so we can animate them once the commit is complete
	self.stagedPurchaseNodes = C_Traits.GetStagedPurchases(self:GetConfigID());

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

function ClassTalentTalentsTabMixin:SetSelection(nodeID, entryID, oldEntryID)
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
		local function CancelSelect()
			local button = self:GetTalentButtonByNodeID(nodeID);
			-- If player cancelled, make sure button is reset back to previous selection 
			if button and button:GetSelectedEntryID() == entryID then
				button:SetSelectedEntryID(oldEntryID);
			end
		end
		self:CheckConfirmStarterBuildDeviation(FinishSelect, CancelSelect);
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

	local isAnythingPending = self.isConfigReadyToApply or hasAnyChanges;

	self.ApplyButton:SetEnabled(isAnythingPending and (canChangeTalents or canAdd));

	if (isAnythingPending and not canChangeTalents and canChangeError) then
		self.ApplyButton:SetDisabledTooltip(canChangeError);
	else
		self.ApplyButton:SetDisabledTooltip(nil);
	end

	if isAnythingPending then
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

	local shouldShowUndo = hasAnyChanges and not self.isConfigReadyToApply;
	self.UndoButton:SetShown(shouldShowUndo);
	self.ResetButton:SetShown(not shouldShowUndo);
	self.ResetButton:SetEnabledState(self:HasValidConfig() and self:HasAnyPurchasedRanks() and not self:IsCommitInProgress());
	self.LoadoutDropDown:SetEnabledState(not self:IsCommitInProgress());

	self:UpdatePendingChangeState(isAnythingPending);
end

function ClassTalentTalentsTabMixin:HasAnyPendingChanges()
	return self.isAnythingPending;
end

function ClassTalentTalentsTabMixin:UpdatePendingChangeState(isAnythingPending)
	local wasAnythingPending = self.isAnythingPending;
	self.isAnythingPending = isAnythingPending;

	if wasAnythingPending ~= isAnythingPending then
		self:UpdateTalentActionBarStatuses();
		self:UpdateEnabledSearchTypes();
	end
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

function ClassTalentTalentsTabMixin:CanSetDropDownValue(selectedValue, isUserInput)
	if self:IsCommitInProgress() and (selectedValue ~= self.lastSelectedConfigID) then
		return false;
	end

	if selectedValue == nil then
		return true; -- The dropdown can always be cleared.
	end

	if self:IsStarterBuildConfig(selectedValue) then
		if not isUserInput and not self:GetIsStarterBuildActive() then
			return false; -- Cannot auto-select starter build unless already in it, or the player is switching to it
		end

		if not self:GetHasStarterBuild() then
			return false; -- Cannot select Starter Build if it is not available
		end
	end

	local currentSelectionID = self.LoadoutDropDown:GetSelectionID();
	if (currentSelectionID == nil) or not self.LoadoutDropDown:IsSelectionIDValid(currentSelectionID) then
		return true; -- The dropdown can always be initialized if the current selection is invalid.
	end

	local sentinelKey = self.LoadoutDropDown:GetSentinelKeyInfoFromSelectionID(selectedValue);
	if sentinelKey ~= nil then
		return true; -- new/import/export always enabled
	end

	return self.LoadoutDropDown:IsSelectionIDValid(selectedValue);
end

function ClassTalentTalentsTabMixin:CanChangeTalents()
	if self:IsCommitInProgress() then
		return false, false;
	end

	return C_ClassTalents.CanChangeTalents();
end

function ClassTalentTalentsTabMixin:UpdateInspecting()
	self:UpdateClassVisuals();
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
		self.SearchBox:SetPoint("BOTTOMLEFT", 53, 27);
	else
		self.SearchBox:SetPoint("LEFT", self.LoadoutDropDown, "RIGHT", 20, 0);
	end

	self:RefreshCurrencyDisplay();

	self:UpdateEnabledSearchTypes();
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
	local wereSelectableGlowsDisabled = false;
	if self.activeStarterBuildHighlight then
		local previousHighlightedButton = self:GetTalentButtonByNodeID(self.activeStarterBuildHighlight.nodeID);
		if previousHighlightedButton then
			previousHighlightedButton:SetGlowing(false);
		end
		self.activeStarterBuildHighlight = nil;

		wereSelectableGlowsDisabled = true;
	end

	if not self:GetIsStarterBuildActive() or self.unflagStarterBuildAfterNextCommit then

		if wereSelectableGlowsDisabled then
			-- Re-enable selection glows now that starter build highlight is inactive
			for button in self:EnumerateAllTalentButtons() do
				button:SetSelectableGlowDisabled(false);
			end
		end
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

		if not wereSelectableGlowsDisabled then
			-- Disable selection glows since the starter build highlight is active
			for button in self:EnumerateAllTalentButtons() do
				button:SetSelectableGlowDisabled(true);
			end
		end
	end
end

function ClassTalentTalentsTabMixin:CheckConfirmStarterBuildDeviation(acceptCallback, cancelCallback)
	local referenceKey = self;
	if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
		local customData = {
			text = TALENT_FRAME_CONFIRM_STARTER_DEVIATION,
			callback = acceptCallback,
			cancelCallback = cancelCallback,
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

function ClassTalentTalentsTabMixin:IsStarterBuildConfig(configID)
	return configID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID;
end

function ClassTalentTalentsTabMixin:GetHasStarterBuild()
	return C_ClassTalents.GetHasStarterBuild();
end

function ClassTalentTalentsTabMixin:GetIsStarterBuildActive()
	return C_ClassTalents.GetStarterBuildActive();
end

function ClassTalentTalentsTabMixin:SetStarterBuildActive(isActive)
	EventRegistry:TriggerEvent("TalentFrame.TalentTab.StarterBuild", isActive);
	return C_ClassTalents.SetStarterBuildActive(isActive);
end

function ClassTalentTalentsTabMixin:UnflagStarterBuild()
	self.unflagStarterBuildAfterNextCommit = false;
	if self:IsStarterBuildConfig(self.lastSelectedConfigID) then
		self:ClearLastSelectedConfigID();
	end
	self:SetStarterBuildActive(false);
end

function ClassTalentTalentsTabMixin:UpdateTalentActionBarStatuses()
	for button in self:EnumerateAllTalentButtons() do
		button:UpdateActionBarStatus();
	end
end