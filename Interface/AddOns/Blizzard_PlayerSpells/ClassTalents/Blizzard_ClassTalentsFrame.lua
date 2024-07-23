local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;
local PurchaseFXDelay = 1.2;

local NODE_PURCHASE_IN_PROGRESS_FX_1 = 166;
local NODE_PURCHASE_COMPLETE_FX_1 = 150;


ClassTalentCurrencyDisplayMixin = {};

function ClassTalentCurrencyDisplayMixin:SetPointTypeText(text)
	self.CurrencyLabel:SetText(TALENT_FRAME_CURRENCY_DISPLAY_FORMAT_NAME_ONLY:format(text));
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


ClassTalentsFrameMixin = CreateFromMixins(TalentFrameBaseMixin, ClassTalentImportExportMixin, ClassTalentSearchMixin);

local ClassTalentsFrameEvents = {
	"TRAIT_CONFIG_CREATED",
	"ACTIVE_COMBAT_CONFIG_CHANGED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
	"STARTER_BUILD_ACTIVATION_FAILED",
	"TRAIT_CONFIG_DELETED",
	"TRAIT_CONFIG_LIST_UPDATED",
	"ACTIONBAR_SLOT_CHANGED",

	-- TRAIT_CONFIG_UPDATED is handled with special code. See OnTraitConfigUpdated.
	-- "TRAIT_CONFIG_UPDATED",
};

local ClassTalentsFrameUnitEvents = {
	"UNIT_AURA",
	"UNIT_SPELLCAST_SUCCEEDED",
};

ClassTalentsFrameMixin:GenerateCallbackEvents(
{
	"OpenPvPTalentList",
	"ClosePvPTalentList",
	"PvPTalentListClosed",
	"SelectTalentIDForSlot",
});

function ClassTalentsFrameMixin:OnLoad()
	self.initialBasePanOffsetX = self.basePanOffsetX;
	self.initialBasePanOffsetY = self.basePanOffsetY;
	
	self.areClassTalentCommitCompleteVisualsActive = false;
	self.areClassTalentCommitVisualsActive = false;

	TalentFrameBaseMixin.OnLoad(self);

	self:UpdateClassVisuals();

	self.ResetButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CLASS_TALENT_FRAME_RESET");

		rootDescription:CreateTitle(TALENT_FRAME_RESET_BUTTON_DROPDOWN_TITLE);
		rootDescription:CreateButton(TALENT_FRAME_RESET_BUTTON_DROPDOWN_LEFT, GenerateClosure(self.ResetClassTalents, self));
		rootDescription:CreateButton(TALENT_FRAME_RESET_BUTTON_DROPDOWN_RIGHT, GenerateClosure(self.ResetSpecTalents, self));
		rootDescription:CreateButton(TALENT_FRAME_RESET_BUTTON_DROPDOWN_ALL, GenerateClosure(self.ResetTree, self));
	end);

	self.ApplyButton:SetOnClickHandler(GenerateClosure(self.ApplyConfig, self));
	self.ApplyButton:SetOnEnterHandler(GenerateClosure(self.UpdateConfigButtonsState, self));
	self.UndoButton:SetOnClickHandler(GenerateClosure(self.RollbackConfig, self));

	self.InspectCopyButton:SetTextToFit(TALENT_FRAME_INSPECT_COPY_BUTTON_TEXT);
	self.InspectCopyButton:SetOnClickHandler(GenerateClosure(self.CopyInspectLoadout, self));

	self.PvPTalentList:SetTalentFrame(self);
	self.PvPTalentSlotTray:SetTalentFrame(self);

	self.HeroTalentsContainer:Init(self, self.heroSpecSelectionDialog);

	self:InitializeLoadSystem();

	self:InitializeSearch();

	-- Initial inspecting update to start UI in a non-inspecting initial state
	self:UpdateInspecting();

	-- TODO:: Remove this. It's all temporary until there's a better server-side solution.
	EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", GenerateClosure(self.LoadSavedVariables, self));
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED");

	self:RegisterEvent("SELECTED_LOADOUT_CHANGED");

	-- CVars are unloaded when we leave the world, so we have to refresh last selected configID after entering the world.
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

-- This is registered and unregistered dynamically.
function ClassTalentsFrameMixin:OnUpdate()
	TalentFrameBaseMixin.OnUpdate(self);

	self:UpdateFullSearchResults();

	self:UpdateConfigButtonsState();

	self:UpdateStarterBuildHighlights();
	
	-- If player deviated from starter build, but then undid the deviation such that there's no changes to save,
	-- We can no longer wait till next commit so just unflag them now rather than deal with trying to reset ourselves to being in Starter Build mode.
	if self.unflagStarterBuildAfterNextCommit and not self:IsCommitInProgress() and self:GetIsStarterBuildActive() and not self:HasAnyConfigChanges() then
		self:UnflagStarterBuild();
	end

	self.HeroTalentsContainer:UpdateHeroTalentInfo();
end

function ClassTalentsFrameMixin:OnShow()
	self:UpdateSpecBackground();
	self:RefreshConfigID();
	self:CheckSetSelectedConfigID();

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, ClassTalentsFrameEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentsFrameUnitEvents, "player");

	EventRegistry:RegisterCallback("ActionBarShownSettingUpdated", self.OnActionBarsChanged, self);

	EventRegistry:TriggerEvent("PlayerSpellsFrame.TalentTab.Show");

	self:UpdateConfigButtonsState();
	self:UpdateAllButtons();

	self:UpdateStarterBuildHighlights();

	self.HeroTalentsContainer:UpdateHeroTalentInfo();

	self:SetBackgroundAnimationsPlaying(true);
end

function ClassTalentsFrameMixin:LoadSavedVariables()
	self.variablesLoaded = true;

	self:CheckSetSelectedConfigID();
end

function ClassTalentsFrameMixin:UpdateClassVisuals()
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

	self:UpdateSpecBackground();
end

function ClassTalentsFrameMixin:UpdateSpecBackground()
	local currentSpecID = self:GetSpecID();
	local specVisuals = ClassTalentUtil.GetVisualsForSpecID(currentSpecID);
	if specVisuals and specVisuals.background and C_Texture.GetAtlasInfo(specVisuals.background) then
		self.BackgroundFlash:SetAtlas(specVisuals.background, TextureKitConstants.UseAtlasSize);

		for i, background in ipairs(self.specBackgrounds) do
			background:SetAtlas(specVisuals.background, TextureKitConstants.UseAtlasSize);
		end
	end

	local heroContainerOffset = specVisuals and specVisuals.heroContainerOffset or 0;
	self.HeroTalentsContainer:SetPoint("TOP", self.ButtonsParent, heroContainerOffset, 0);
end

function ClassTalentsFrameMixin:SetBackgroundAnimationsPlaying(playing)
	if self.backgroundAnims then
		for i, animGroup in ipairs(self.backgroundAnims) do
			animGroup:SetPlaying(playing);
		end
	end
end

function ClassTalentsFrameMixin:CheckSetSelectedConfigID()
	if not self.variablesLoaded or not self:IsShown() or self:IsInspecting() then
		return;
	end
	
	local currentSelection = self.LoadSystem:GetSelectionID();
	if (currentSelection ~= nil) and self.LoadSystem:IsSelectionIDValid(currentSelection) then
		-- Check to see if starter build is the correct selection, as on spec change it's a valid choice but may not be active for the new spec
		if (currentSelection ~= Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID) then
			return;
		elseif self:GetIsStarterBuildActive() then
			return;
		end
	end

	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	if not currentSpecID then
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
		return;
	end

	local lastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(currentSpecID);

	-- If the last selected configID has ended up invalid, clear out the saved value
	-- This can happen due to loadout deletion, or base spec config being saved as last selected, prior to the handling of those being fixed
	if lastSelectedSavedConfigID and not self.LoadSystem:IsSelectionIDValid(lastSelectedSavedConfigID) then
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
		self.LoadSystem:ClearSelection();
	end
end

function ClassTalentsFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, ClassTalentsFrameEvents);
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentsFrameUnitEvents);
	EventRegistry:UnregisterCallback("ActionBarShownSettingUpdated", self);

	EventRegistry:TriggerEvent("PlayerSpellsFrame.TalentTab.Hide");

	self:SetBackgroundAnimationsPlaying(false);
end

function ClassTalentsFrameMixin:OnEvent(event, ...)
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
		self:OnActionBarsChanged();
	-- TODO:: Replace this events with more proper "CanChangeTalent" signal(s).
	elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_REGEN_DISABLED") or (event == "UNIT_AURA") then
		self:UpdateConfigButtonsState();
		self:UpdateAllButtons();
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local spellID = select(3, ...);
		if spellID == Constants.TraitConsts.COMMIT_COMBAT_TRAIT_CONFIG_CHANGES_SPELL_ID then
			self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.CommitStoppedComplete);
			self:SetCommitCompleteVisualsActive(true);
		end
	elseif event == "SELECTED_LOADOUT_CHANGED" then
		local currentSpecID = PlayerUtil.GetCurrentSpecID();
		if currentSpecID then
			local lastSelectedSavedConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(currentSpecID);
			self.lastSelectedConfigID = lastSelectedSavedConfigID;
			if lastSelectedSavedConfigID ~= nil then
				self:SetSelectedSavedConfigID(lastSelectedSavedConfigID, false, true);
			else
				self.LoadSystem:ClearSelection();
			end
		end
	end

	TalentFrameBaseMixin.OnEvent(self, event, ...);
end

function ClassTalentsFrameMixin:OnTraitConfigUpdated(configID)
	-- Overrides TalentFrameBaseMixin.

	PlayerSpellsMicroButton:EvaluateAlertVisibility();

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
		if commitedConfigID then
			self:CheckUpdateLastSelectedConfigID(commitedConfigID);
		end

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
		self:CheckUpdateLastSelectedConfigID(configID);
	end

	-- There are expected cases for TRAIT_CONFIG_UPDATED being fired that we don't need to react to
	-- Examples: 
	--  - Deleting a loadout while active may lead to Updated event for the next loadout down
	--  - Saving a change to a loadout may lead to Updated event both for the base spec config id and then the selected loadout config id
	-- If we do start getting "bad" Updated events, make sure to detect & handle those explicitly and not as a catch-all else case
end

function ClassTalentsFrameMixin:OnTraitConfigDeleted(configID)
	self:RefreshLoadoutOptions();

	if configID and self.lastSelectedConfigID == configID then
		-- Handle deletion of the loadout we're currently on by falling back to the default base spec loadout
		self:ClearLastSelectedConfigID();
	end
end

function ClassTalentsFrameMixin:OnTraitConfigCreateStarted(newConfigHasPurchasedRanks)
	-- Only configs with purchased ranks require a populated check to ensure their ranks have been applied
	self.nextNewConfigRequiresPopulatedCheck = newConfigHasPurchasedRanks;
	local active = true;
	local skipSpinnerDelay = true;
	self:SetCommitVisualsActive(active, TalentFrameBaseMixin.VisualsUpdateReasons.CommitOngoing, skipSpinnerDelay);
end

function ClassTalentsFrameMixin:OnTraitConfigCreateFinished(configID)
	self:SetCommitVisualsActive(false, TalentFrameBaseMixin.VisualsUpdateReasons.CommitStoppedComplete);

	local autoApply = true;
	self:SetSelectedSavedConfigID(configID, autoApply);
	self.autoLoadNewConfigID = nil;

	-- Only do completion visuals if SetSelectedSavedConfigID's load did not put us into an in-progress commit or partial loadout.
	if not self:IsCommitInProgress() and not self:HasAnyConfigChanges() then
		self:SetCommitCompleteVisualsActive(true);
	end
end

function ClassTalentsFrameMixin:ResetToLastConfigID()
	if self.lastSelectedConfigID and self.LoadSystem:IsSelectionIDValid(self.lastSelectedConfigID) and not self:IsStarterBuildConfig(self.lastSelectedConfigID) then
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

function ClassTalentsFrameMixin:InitializeLoadSystem()
	local dropdown = self.LoadSystem:GetDropdown();
	dropdown:SetWidth(200);

	self.LoadSystem:SetMenuTag("MENU_CLASS_TALENT_PROFILE");
	self.LoadSystem:SetDropdownDefaultText(WrapTextInColor(TALENT_FRAME_DROP_DOWN_DEFAULT, GRAY_FONT_COLOR));
	
	local function SelectionEnabledCallback(selectionID, isUserInput)
		if self:IsCommitInProgress() and (selectionID ~= self.lastSelectedConfigID) then
			return false;
		end
		
		if self:IsStarterBuildConfig(selectionID) then
			if not isUserInput and not self:GetIsStarterBuildActive() then
				return false; -- Cannot auto-select starter build unless already in it, or the player is switching to it
			end
		
			if not self:GetHasStarterBuild() then
				return false; -- Cannot select Starter Build if it is not available
			end
		end

		return true;
	end

	self.LoadSystem:SetSelectionEnabled(SelectionEnabledCallback);

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

	self.LoadSystem:SetNewEntryCallbackCustomPopup(NewEntryCallback, TALENT_FRAME_DROP_DOWN_NEW_LOADOUT, ClassTalentLoadoutCreateDialog, NewEntryDisabledCallback);

	local function EditLoadoutCallback(configID)
		ClassTalentLoadoutEditDialog:ShowDialog(configID);
	end

	local function CanEditLoadoutCallback(configID)
		-- TODO: Enable modified loadout settings dialog for Starter Build
		return not self:IsStarterBuildConfig(configID);
	end

	self.LoadSystem:SetEditEntryCallback(EditLoadoutCallback, TALENT_FRAME_DROP_DOWN_TOOLTIP_EDIT, CanEditLoadoutCallback);

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

	local function ClipboardExportCallback()
		CopyToClipboard(self:GetLoadoutExportString());
		DEFAULT_CHAT_FRAME:AddMessage(TALENT_FRAME_EXPORT_TEXT, YELLOW_FONT_COLOR:GetRGB());
	end

	local function ChatLinkCallback()
		local linkDisplayText = ("[%s]"):format(TALENT_BUILD_CHAT_LINK_TEXT:format(PlayerUtil.GetSpecName(), PlayerUtil.GetClassName()));
		local linkText = LinkUtil.FormatLink("talentbuild", linkDisplayText, PlayerUtil.GetCurrentSpecID(), UnitLevel("player"), self:GetLoadoutExportString());
		local chatLink = PlayerUtil.GetClassColor():WrapTextInColorCode(linkText);
		if not ChatEdit_InsertLink(chatLink) then
			ChatFrame_OpenChat(chatLink);
		end
	end

	local function ExportDisabledCallback()
		local disabled = self:HasAnyConfigChanges() or C_ClassTalents.HasUnspentTalentPoints() or C_ClassTalents.HasUnspentHeroTalentPoints();
		local title = ""; -- this needs to be set or the tooltip does not display
		local text = nil;
		local warning = TALENT_FRAME_EXPORT_LOADOUT_DISABLED_TOOLTIP;
		return disabled, title, text, warning;
	end

	local importSentinelInfo = {
		text = TALENT_FRAME_DROP_DOWN_IMPORT,
		color = WHITE_FONT_COLOR,
		callback = ImportCallback,
		disabledCallback = ImportDisabledCallback,
	};

	self.LoadSystem:AddSentinelValue(importSentinelInfo);

	local copyToClipboardSentinelInfo = {
		text = TALENT_FRAME_DROP_DOWN_EXPORT_CLIPBOARD,
		color = WHITE_FONT_COLOR,
		callback = ClipboardExportCallback,
		disabledCallback = ExportDisabledCallback,
	};

	local chatLinkSentinelInfo = {
		text = TALENT_FRAME_DROP_DOWN_EXPORT_CHAT_LINK,
		color = WHITE_FONT_COLOR,
		callback = ChatLinkCallback,
		disabledCallback = ExportDisabledCallback,
	};

	local exportSentinelListInfo = {
		text = TALENT_FRAME_DROP_DOWN_EXPORT,
		color = WHITE_FONT_COLOR,
		sentinelInfos = {
			copyToClipboardSentinelInfo,
			chatLinkSentinelInfo,
		},
		disabledCallback = ExportDisabledCallback,
	};
	self.LoadSystem:AddSentinelValue(exportSentinelListInfo);

	local function LoadConfiguration(configID, isUserInput)
		if not isUserInput then
			return;
		end

			local function CancelLoadConfiguration()
				if self.lastSelectedConfigID then
				self.LoadSystem:SetSelectionID(self.lastSelectedConfigID);
				else
				self.LoadSystem:ClearSelection();
				end
			end

			local function FinishLoadConfiguration()
				local autoApply = true;
				local loadSuccess, changeError = self:LoadConfigInternal(configID, autoApply);
				if not loadSuccess then
					self:RollbackConfig();
					CancelLoadConfiguration();
					self:UpdateConfigButtonsState();

					if changeError and changeError ~= "" then
						local systemPrefix = "CLASS_TALENTS";
						local notificationType = "LOAD_ERROR";
						StaticPopup_ShowNotification(systemPrefix, notificationType, RED_FONT_COLOR:WrapTextInColorCode(changeError));
					end
				end
			end

			local function ConfirmFinishLoadConfiguration()
				self:CheckConfirmSwapFromDefault(FinishLoadConfiguration, CancelLoadConfiguration);
			end

			self:GetParent():CheckConfirmResetAction(ConfirmFinishLoadConfiguration, CancelLoadConfiguration);
		end

	self.LoadSystem:SetLoadCallback(LoadConfiguration);
end

function ClassTalentsFrameMixin:CheckUpdateLastSelectedConfigID(configID)
	if self:IsInspecting() then
		return;
	end

	if configID == C_ClassTalents.GetActiveConfigID() then
		return;
	end

	self.lastSelectedConfigID = configID;

	local currentSpecID = self:GetSpecID();
	if currentSpecID then
		C_ClassTalents.UpdateLastSelectedSavedConfigID(currentSpecID, configID);
	end
end

function ClassTalentsFrameMixin:ClearLastSelectedConfigID()
	self.lastSelectedConfigID = nil;
	local currentSpecID = self:GetSpecID();
	if currentSpecID then
		C_ClassTalents.UpdateLastSelectedSavedConfigID(currentSpecID, nil);
	end
	self.LoadSystem:ClearSelection();
end

function ClassTalentsFrameMixin:RefreshGates()
	self.traitCurrencyIDToGate = {};

	TalentFrameBaseMixin.RefreshGates(self);
end

function ClassTalentsFrameMixin:ShouldDisplayGate(firstButton, condInfo)
	return TalentFrameBaseMixin.ShouldDisplayGate(self, firstButton, condInfo) and (not condInfo.traitCurrencyID or not self.traitCurrencyIDToGate[condInfo.traitCurrencyID]);
end

function ClassTalentsFrameMixin:ShouldInstantiateNode(nodeID, nodeInfo)
	-- Overrides TalentFrameBaseMixin.
	-- SubTreeSelection nodes are used to track what SubTrees are active under the hood, but we use a bespoke UI for them for Hero Talents (see HeroTalentsContainer)
	return nodeInfo.type ~= Enum.TraitNodeType.SubTreeSelection;
end

function ClassTalentsFrameMixin:UpdateTalentButtonPosition(talentButton)
	-- Overrides TalentFrameBaseMixin.
	local nodeInfo = talentButton:GetNodeInfo();

	if nodeInfo.subTreeID then
		self.HeroTalentsContainer:UpdateHeroTalentButtonPosition(talentButton);
	else
		-- Position regular Nodes on Buttons Parent like normal
		if(talentButton:GetParent() ~= self.ButtonsParent) then
			talentButton:SetParent(self.ButtonsParent);
		end

		talentButton:ClearAllPoints();
		talentButton:SetPoint("CENTER", self.ButtonsParent, "TOPLEFT");
		TalentButtonUtil.ApplyPosition(talentButton, self, nodeInfo.posX, nodeInfo.posY);
	end
end

function ClassTalentsFrameMixin:GetFrameLevelForButton(nodeInfo)
	-- Overrides TalentFrameBaseMixin.

	local posY = nodeInfo.posY;

	if nodeInfo.subTreeID then
		-- Since we manually position subTree nodes based on a normalized position,
		-- normalize the posY of them here so that overlapping nodes from different subTrees will have the same
		-- base frame level, which will then be accurately offset by the node's Invisible state handling
		local subTreeInfo = self:GetAndCacheSubTreeInfo(nodeInfo.subTreeID);
		posY = posY - subTreeInfo.posY;
	end

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	-- Ensure calculated offset is a whole number so we don't end up with any floating point weirdness
	scaledYOffset = Round(scaledYOffset);

	return TotalFrameLevelSpread - scaledYOffset;
end

function ClassTalentsFrameMixin:OnGateDisplayed(gate, firstButton, condInfo)
	-- Overrides TalentFrameBaseMixin.

	if condInfo.traitCurrencyID then
		self.traitCurrencyIDToGate[condInfo.traitCurrencyID] = gate;
	end
end

function ClassTalentsFrameMixin:AnchorGate(gate, button)
	-- Overrides TalentFrameBaseMixin.

	gate:SetPoint("RIGHT", button, "LEFT");
end

function ClassTalentsFrameMixin:UpdateTreeCurrencyInfo(skipButtonUpdates)
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

function ClassTalentsFrameMixin:RefreshCurrencyDisplay()
	local classCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local className = self:GetClassName();
	self.ClassCurrencyDisplay:SetPointTypeText(string.upper(className));
	self.ClassCurrencyDisplay:SetAmount(classCurrencyInfo and classCurrencyInfo.quantity or 0);

	local specCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[2] or nil;
	self.SpecCurrencyDisplay:SetPointTypeText(string.upper(self:GetSpecName()));
	self.SpecCurrencyDisplay:SetAmount(specCurrencyInfo and specCurrencyInfo.quantity or 0);

	self.HeroTalentsContainer:UpdateHeroTalentCurrency();
end

function ClassTalentsFrameMixin:IsLocked()
	-- Overrides TalentFrameBaseMixin.

	local canEditTalents, errorMessage = C_ClassTalents.CanEditTalents();
	return not canEditTalents, errorMessage;
end

function ClassTalentsFrameMixin:RefreshLoadoutOptions()
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

	self.LoadSystem:SetSelectionOptions(self.configIDs, SelectionNameTranslation, NORMAL_FONT_COLOR, SelectionTooltipTranslation);

	if #self.configIDs == 0 then
		self.LoadSystem:ClearSelection();
	end
end

function ClassTalentsFrameMixin:ResetClassTalents()
	local classTraitCurrencyID = self.treeCurrencyInfo and self.treeCurrencyInfo[1] and self.treeCurrencyInfo[1].traitCurrencyID;
	self:AttemptConfigOperation(C_Traits.ResetTreeByCurrency, self:GetTalentTreeID(), classTraitCurrencyID);
end

function ClassTalentsFrameMixin:ResetSpecTalents()
	local specTraitCurrencyID = self.treeCurrencyInfo and self.treeCurrencyInfo[2] and self.treeCurrencyInfo[2].traitCurrencyID;
	self:AttemptConfigOperation(C_Traits.ResetTreeByCurrency, self:GetTalentTreeID(), specTraitCurrencyID);
end

function ClassTalentsFrameMixin:ResetTree()
	-- Intentionally not using C_Traits.ResetTree so that Hero Talents are not reset.
	self:ResetClassTalents();
	self:ResetSpecTalents();
end

function ClassTalentsFrameMixin:LoadTalentTreeInternal()
	TalentFrameBaseMixin.LoadTalentTreeInternal(self);

	self:UpdateConfigButtonsState();

	-- If commit visuals are active, need to refresh them since nodes get reset and re-intialized on tree load
	if self.areClassTalentCommitVisualsActive then
		self:SetCommitVisualsActive(true, TalentFrameBaseMixin.VisualsUpdateReasons.TalentTreeReset);
	end
end

function ClassTalentsFrameMixin:SetSelectedSavedConfigID(configID, autoApply, skipLoad, forceSkipAnimation)
	local previousSelection = self.LoadSystem:GetSelectionID();
	if previousSelection == configID then
		return;
	end

	self.LoadSystem:SetSelectionID(configID);

	if not skipLoad then
		local skipAnimation = forceSkipAnimation or (previousSelection == nil);
		self:LoadConfigInternal(configID, not not autoApply, skipAnimation);
	end
end

function ClassTalentsFrameMixin:RefreshConfigID()
	if self:IsInspecting() then
		if self:GetInspectUnit() then
			local forceUpdate = true;
			self:SetConfigID(Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID, forceUpdate);
		else
			local forceUpdate = true;
			self:SetConfigID(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, forceUpdate);
		end
	else
		local activeConfigID = C_ClassTalents.GetActiveConfigID() or self.configIDs[1];
		self:SetConfigID(activeConfigID);
	end
end

function ClassTalentsFrameMixin:SetConfigID(configID, forceUpdate)
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

function ClassTalentsFrameMixin:SetTalentTreeID(talentTreeID, forceUpdate)
	if TalentFrameBaseMixin.SetTalentTreeID(self, talentTreeID, forceUpdate) then
		self:UpdateConfigButtonsState();
	end
end

function ClassTalentsFrameMixin:CanCommitInstantly()
	-- Overrides TalentFrameBaseMixin.

	-- return C_ClassTalents.CanCommitInstantly();
	return false;
end

function ClassTalentsFrameMixin:SetCommitStarted(configID, reason, skipAnimation)
	if configID then
		-- Cache nodes with staged purchases so we can animate them during the commit and once the commit is complete
		self.stagedPurchaseNodes = self.stagedPurchaseNodesForNextCommit;
		if not self.stagedPurchaseNodes then
			local stagedPurchases, _, stagedSelectionSwaps = C_Traits.GetStagedChanges(self:GetConfigID());
			
			local allGainedNodes = stagedPurchases or {};
			if stagedSelectionSwaps and #stagedSelectionSwaps > 0 then
				tAppendAll(allGainedNodes, stagedSelectionSwaps);
			end

			if #allGainedNodes > 0 then
				self.stagedPurchaseNodes = allGainedNodes;
			end
		end
		self.stagedPurchaseNodesForNextCommit = nil;
	end
	
	TalentFrameBaseMixin.SetCommitStarted(self, configID, reason, skipAnimation);

	local isCommitOngoing = configID and (reason ~= TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit);
	-- If commit isn't actively processing and complete visuals aren't using the staged nodes, we can clear them out
	if not isCommitOngoing and not self.areClassTalentCommitCompleteVisualsActive then
		self.stagedPurchaseNodes = nil;
	end

	self:UpdateConfigButtonsState();
end

function ClassTalentsFrameMixin:SetCommitCastBarActive(active)
	-- Overrides TalentFrameBaseMixin
	if active then
		-- Show the castbar high enough to be over both the Hero Spec Selection dialog and ourselves
		local anchor = CreateAnchor("BOTTOM", self.heroSpecSelectionDialog.DisabledOverlay, "BOTTOM", 0, 140);
		OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(UIParent, { overrideBarType = "applyingtalents", overrideAnchor = anchor, overrideStrata = "DIALOG" });
	else
		OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
	end
end

function ClassTalentsFrameMixin:SetCommitVisualsActive(active, reason, skipSpinnerDelay)
	TalentFrameBaseMixin.SetCommitVisualsActive(self, active, reason, skipSpinnerDelay);

	local forceUpdateVisuals = reason == TalentFrameBaseMixin.VisualsUpdateReasons.TalentTreeReset;

	if ((active and not self:IsVisible()) or (self.areClassTalentCommitVisualsActive == active)) and not forceUpdateVisuals then
		return;
	end

	-- If deactivating due to hiding the frame, avoid actually deactivating purchase effects to prevent a delayed pop-in on showing the frame again
	-- Reason check will still ensure they do get deactivated if the commit completes/fails while the frame is hidden
	if not active and reason == TalentFrameBaseMixin.VisualsUpdateReasons.FrameHidden then
		return;
	end

	if active then
		if self.stagedPurchaseNodes then
			self:PlayPurchaseEffectOnNodes(self.stagedPurchaseNodes, "PlayPurchaseInProgressEffect", {NODE_PURCHASE_IN_PROGRESS_FX_1});
		end
	else
		self.FxModelScene:ClearEffects();
		self:StopPurchaseEffectOnNodes(self.stagedPurchaseNodes, "StopPurchaseInProgressEffect");
	end

	local isHeroSpecSelectionActive = self.heroSpecSelectionDialog:IsActive();
	if isHeroSpecSelectionActive then
		self.heroSpecSelectionDialog:SetCommitVisualsActive(active);
	end

	self.areClassTalentCommitVisualsActive = active and (self.stagedPurchaseNodes or isHeroSpecSelectionActive);
end

function ClassTalentsFrameMixin:SetCommitCompleteVisualsActive(active)
	TalentFrameBaseMixin.SetCommitCompleteVisualsActive(self, active);

	if (active and not self:IsVisible()) or (self.areClassTalentCommitCompleteVisualsActive == active) then
		return;
	end

	self.areClassTalentCommitCompleteVisualsActive = active;

	if self.commitFlashAnims then
		for _, animGroup in ipairs(self.commitFlashAnims) do
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
			self.stagedPurchaseTimer = C_Timer.NewTimer(PurchaseFXDelay, function()
				if not self.stagedPurchaseNodes then
					self.areClassTalentCommitCompleteVisualsActive = false;
					return;
				end

				self:PlayPurchaseEffectOnNodes(self.stagedPurchaseNodes, "PlayPurchaseCompleteEffect", {NODE_PURCHASE_COMPLETE_FX_1});

				-- Play sound for collective node purchase effects unless the hero spec selection is displayed and playing its own animation and sound.
				if not self.heroSpecSelectionDialog:IsActive() then
					PlaySound(SOUNDKIT.UI_CLASS_TALENT_APPLY_COMPLETE);
				end

				self.stagedPurchaseNodes = nil;
				self.stagedPurchaseTimer = nil;
				self.areClassTalentCommitCompleteVisualsActive = false;
			end);
		elseif not self.stagedPurchaseNodes then
			self.areClassTalentCommitCompleteVisualsActive = false;
		end
	elseif not active then
		if self.stagedPurchaseTimer then
			self.stagedPurchaseTimer:Cancel();
			self.stagedPurchaseTimer = nil;
		end
		self.FxModelScene:ClearEffects();
		self:StopPurchaseEffectOnNodes(self.stagedPurchaseNodes, "StopPurchaseCompleteEffect");
	end

	if self.heroSpecSelectionDialog:IsActive() then
		self.heroSpecSelectionDialog:SetCommitCompleteVisualsActive(active);
	end
end

function ClassTalentsFrameMixin:PlayPurchaseEffectOnNodes(nodes, playMethodName, fxIDs)
	-- If no nodes provided, don't play any purchase effects
	if not nodes then
		return;
	end
	for _, nodeID in ipairs(nodes) do
		local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
		if buttonWithPurchase and buttonWithPurchase[playMethodName] then
			buttonWithPurchase[playMethodName](buttonWithPurchase, self.FxModelScene, fxIDs);
		end
	end
end

function ClassTalentsFrameMixin:StopPurchaseEffectOnNodes(nodes, stopMethodName)
	local function StopPurchaseOnButton(button)
		if button and button[stopMethodName] then
			button[stopMethodName](button);
		end
	end

	if nodes then
		-- If nodes provided, stop effects on those buttons
		for _, nodeID in ipairs(nodes) do
			local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
			StopPurchaseOnButton(buttonWithPurchase);
		end
	else
		-- If no nodes provided, stop effects on all buttons
		for button in self:EnumerateAllTalentButtons() do
			StopPurchaseOnButton(button);
		end
	end
	
end

function ClassTalentsFrameMixin:LoadConfigInternal(configID, autoApply, skipAnimation)
	local loadResult = nil;
	local changeError = nil;
	local newlyLearnedNodes = nil;

	self.stagedPurchaseNodesForNextCommit = nil;

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

		loadResult, changeError, newlyLearnedNodes = C_ClassTalents.LoadConfig(configID, autoApply);
	end

	local isConfigReadyToApply = (loadResult == Enum.LoadConfigResult.Ready);
	self.isConfigReadyToApply = isConfigReadyToApply;

	if loadResult == Enum.LoadConfigResult.NoChangesNecessary then
		self:CheckUpdateLastSelectedConfigID(configID);

		if self.unflagStarterBuildAfterNextCommit then
			self:UnflagStarterBuild();
		end

		self:SetCommitStarted(nil, TalentFrameBaseMixin.CommitUpdateReasons.InstantCommit, skipAnimation);
	elseif (loadResult == Enum.LoadConfigResult.LoadInProgress) and autoApply then
		self.stagedPurchaseNodesForNextCommit = newlyLearnedNodes;
		self:SetCommitStarted(configID, TalentFrameBaseMixin.CommitUpdateReasons.CommitStarted, skipAnimation);
	end

	self:UpdateConfigButtonsState();
	return loadResult ~= Enum.LoadConfigResult.Error, changeError;
end

function ClassTalentsFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function ClassTalentsFrameMixin:ApplyConfig()
	if self:HasAnyConfigChanges() then
		self.isConfigReadyToApply = false;
		self:CommitConfig();
	else
		local selectedConfig = self.LoadSystem:GetSelectionID();
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

function ClassTalentsFrameMixin:CommitConfigInternal()
	-- Overrides TalentFrameBaseMixin.

	local selectedConfigID = self.LoadSystem:GetSelectionID();

	return C_ClassTalents.CommitConfig(selectedConfigID);
end

function ClassTalentsFrameMixin:RollbackConfig(...)
	TalentFrameBaseMixin.RollbackConfig(self, ...);

	self:UpdateTreeCurrencyInfo();
	self:UpdateConfigButtonsState();
end

function ClassTalentsFrameMixin:AttemptConfigOperation(...)
	TalentFrameBaseMixin.AttemptConfigOperation(self, ...);

	self:UpdateConfigButtonsState();
end

function ClassTalentsFrameMixin:PurchaseRank(nodeID)
	-- Overrides TalentFrameBaseMixin.

	if not self:WillDeviateFromStarterBuild(nodeID) then
		TalentFrameBaseMixin.PurchaseRank(self, nodeID);
	else
		local function FinishPurchase()
			-- Player is deviating from the Starter Build, so need to unflag them as using it
			-- Unflagging resets any pending changes though, so we have to wait until they commit all their changes to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
			self.LoadSystem:ClearSelection();
			TalentFrameBaseMixin.PurchaseRank(self, nodeID);
		end
		self:CheckConfirmStarterBuildDeviation(FinishPurchase);
	end
end

function ClassTalentsFrameMixin:RefundRank(nodeID)
	-- Overrides TalentFrameBaseMixin.

	local shouldClearEdges = ClassTalentUtil.ShouldRefundClearEdges();
	return self:AttemptConfigOperation(C_Traits.RefundRank, nodeID, shouldClearEdges);
end

function ClassTalentsFrameMixin:SetSelection(nodeID, entryID, oldEntryID)
	-- Overrides TalentFrameBaseMixin.

	local shouldClearEdges = ClassTalentUtil.ShouldRefundClearEdges();
	if not self:WillDeviateFromStarterBuild(nodeID, entryID) then
		self:AttemptConfigOperation(C_Traits.SetSelection, nodeID, entryID, shouldClearEdges);
	else
		local function FinishSelect()
			-- Player is deviating from the Starter Build, so need to unflag them as using it
			-- Unflagging resets any pending changes though, so we have to wait until they commit all their changes to unflag safely
			self.unflagStarterBuildAfterNextCommit = true;
			self.LoadSystem:ClearSelection();
			self:AttemptConfigOperation(C_Traits.SetSelection, nodeID, entryID, shouldClearEdges);
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

function ClassTalentsFrameMixin:HasValidConfig()
	return (self:GetConfigID() ~= nil) and (self:GetTalentTreeID() ~= nil);
end

function ClassTalentsFrameMixin:HasAnyConfigChanges()
	if self:IsCommitInProgress() then
		return false;
	end

	return self:HasValidConfig() and C_Traits.ConfigHasStagedChanges(self:GetConfigID());
end

function ClassTalentsFrameMixin:CheckConfirmSwapFromDefault(callback, cancelCallback)
	if self:IsDefaultLoadout() then
		local referenceKey = self;
		if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			local customData = {
				text = TALENT_FRAME_CONFIRM_LEAVE_DEFAULT_LOADOUT,
				callback = callback,
				cancelCallback = cancelCallback,
				acceptText = CONTINUE,
				cancelText = CANCEL,
				referenceKey = referenceKey,
			};

			StaticPopup_ShowCustomGenericConfirmation(customData);
		end
	else
		callback();
	end
end

function ClassTalentsFrameMixin:IsDefaultLoadout()
	return self.lastSelectedConfigID == nil;
end

function ClassTalentsFrameMixin:GetConfigApplicationState()
	if self:IsInspecting() then
		return;
	end

	local canChangeTalents, canAdd, canChangeError = self:CanChangeTalents();

	local hasAnyChanges = self:HasAnyConfigChanges();

	local anyChangesPending = self.isConfigReadyToApply or hasAnyChanges;
	local canApplyChanges = anyChangesPending and (canChangeTalents or canAdd);
	local applyDisabledTooltip = anyChangesPending and not canChangeTalents and canChangeError or nil;

	return anyChangesPending, canApplyChanges, applyDisabledTooltip;
end

function ClassTalentsFrameMixin:UpdateConfigButtonsState()
	if self:IsInspecting() then
		return;
	end

	local anyChangesPending, canApplyChanges, applyDisabledTooltip = self:GetConfigApplicationState();

	local isHeroSpecApplyButtonShowing = false;

	if self.heroSpecSelectionDialog:IsActive() then
		-- If Hero Spec Selection is up, have it update its "Apply Changes" shortcut button and find out whether it's currently displaying it
		isHeroSpecApplyButtonShowing = self.heroSpecSelectionDialog:UpdateApplyButtons(anyChangesPending, canApplyChanges);
	end

	self.ApplyButton:SetEnabled(canApplyChanges);
	self.ApplyButton:SetDisabledTooltip(applyDisabledTooltip);

	-- Avoid showing our button's glow if the Hero Spec Selection's button is showing, since it will also be glowing
	if anyChangesPending and not isHeroSpecApplyButtonShowing then
		if canApplyChanges then
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

	local shouldShowUndo = self:HasAnyConfigChanges() and not self.isConfigReadyToApply;
	self.UndoButton:SetShown(shouldShowUndo);
	self.ResetButton:SetShown(not shouldShowUndo);
	self.ResetButton:SetEnabledState(self:HasValidConfig() and self:HasAnyPurchasedRanks() and not self:IsCommitInProgress());

	self.LoadSystem:SetEnabledState(not self:IsCommitInProgress());

	self:UpdatePendingChangeState(isAnythingPending);
end

function ClassTalentsFrameMixin:HasAnyPendingChanges()
	return self.isAnythingPending;
end

function ClassTalentsFrameMixin:UpdatePendingChangeState(isAnythingPending)
	local wasAnythingPending = self.isAnythingPending;
	self.isAnythingPending = isAnythingPending;

	if wasAnythingPending ~= isAnythingPending then
		self:UpdateTalentActionBarStatuses();
		self:UpdateEnabledSearchTypes();
	end
end

function ClassTalentsFrameMixin:HasAnyPurchasedRanks()
	for button in self:EnumerateAllTalentButtons() do
		local nodeInfo = button:GetNodeInfo();
		if nodeInfo and (nodeInfo.ranksPurchased > 0) then
			return true;
		end
	end

	return false;
end

function ClassTalentsFrameMixin:HasAnyRefundInvalidNodes()
	for button in self:EnumerateAllTalentButtons() do
		if button:IsRefundInvalid() then
			return true;
		end
	end

	return false;
end

function ClassTalentsFrameMixin:CanChangeTalents()
	if self:HasAnyRefundInvalidNodes() then
		return false, false, TALENT_FRAME_REFUND_INVALID_ERROR;
	end

	if self:IsCommitInProgress() then
		return false, false;
	end

	return C_ClassTalents.CanChangeTalents();
end

function ClassTalentsFrameMixin:UpdateInspecting()
	self:UpdateClassVisuals();
	self:RefreshConfigID();

	local hiddenDuringInspect = {
		self.ApplyButton,
		self.ResetButton,
		self.UndoButton,
		self.WarmodeButton,
		self.LoadSystem,
	};

	local isInspecting = self:IsInspecting();
	for i, frame in ipairs(hiddenDuringInspect) do
		frame:SetShown(not isInspecting);
	end

	self.InspectCopyButton:SetShown(isInspecting);

	self.PvPTalentSlotTray:SetPoint("RIGHT", self.BottomBar, "RIGHT", isInspecting and -24 or -114, 0);
	self.PvPTalentSlotTray:SetShown(not isInspecting or (self:GetInspectUnit() ~= nil));

	self.SearchBox:ClearAllPoints();
	if isInspecting then
		self.SearchBox:SetPoint("BOTTOMLEFT", 53, 27);
	else
		self.SearchBox:SetPoint("LEFT", self.LoadSystem, "RIGHT", 20, 0);
	end

	self:RefreshCurrencyDisplay();

	self:UpdateEnabledSearchTypes();
end

function ClassTalentsFrameMixin:IsInspecting()
	-- Overrides TalentFrameBaseMixin.

	return self:GetPlayerSpellsFrame():IsInspecting();
end

function ClassTalentsFrameMixin:GetInspectUnit()
	-- Overrides TalentFrameBaseMixin.

	return self:GetPlayerSpellsFrame():GetInspectUnit();
end

function ClassTalentsFrameMixin:GetInspectString()
	-- Overrides TalentFrameBaseMixin.

	return self:GetPlayerSpellsFrame():GetInspectString();
end

function ClassTalentsFrameMixin:CopyInspectLoadout()
	local loadoutString = self:GetInspectUnit() and C_Traits.GenerateInspectImportString(self:GetInspectUnit()) or self:GetInspectString();
	if loadoutString and (loadoutString ~= "") then
		CopyToClipboard(loadoutString);
		DEFAULT_CHAT_FRAME:AddMessage(TALENT_FRAME_EXPORT_TEXT, YELLOW_FONT_COLOR:GetRGB());
	end
end

function ClassTalentsFrameMixin:GetClassID()
	return self:GetPlayerSpellsFrame():GetClassID();
end

function ClassTalentsFrameMixin:GetClassName()
	return self:GetPlayerSpellsFrame():GetClassName();
end

function ClassTalentsFrameMixin:GetSpecID()
	return self:GetPlayerSpellsFrame():GetSpecID();
end

function ClassTalentsFrameMixin:GetSpecName()
	return self:GetPlayerSpellsFrame():GetSpecName();
end

function ClassTalentsFrameMixin:GetDefinitionInfoForEntry(entryID)
	local definitionID = self:GetAndCacheEntryInfo(entryID).definitionID;
	if definitionID then
		return self:GetAndCacheDefinitionInfo(definitionID);
	end
	return nil;
end

function ClassTalentsFrameMixin:GetSubTreeInfoForEntry(entryID)
	local subTreeID = self:GetAndCacheEntryInfo(entryID).subTreeID;
	if subTreeID then
		return self:GetAndCacheSubTreeInfo(subTreeID);
	end
	return nil;
end

function ClassTalentsFrameMixin:GetPlayerSpellsFrame()
	return self:GetParent();
end

function ClassTalentsFrameMixin:GetSpecializationTab()
	return self:GetPlayerSpellsFrame().SpecFrame;
end

function ClassTalentsFrameMixin:IsSpecActivationInProgress()
	return self:GetSpecializationTab():IsActivateInProgress();
end

function ClassTalentsFrameMixin:IsHighlightedStarterBuildEntry(entryID)
	return self.activeStarterBuildHighlight and self.activeStarterBuildHighlight.entryID == entryID;
end

function ClassTalentsFrameMixin:UpdateStarterBuildHighlights()
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

function ClassTalentsFrameMixin:CheckConfirmStarterBuildDeviation(acceptCallback, cancelCallback)
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

function ClassTalentsFrameMixin:WillDeviateFromStarterBuild(selectedNodeID, selectedEntryID)
	if not self:GetIsStarterBuildActive() or self.unflagStarterBuildAfterNextCommit then
		return false;
	end

	local starterNodeID, starterEntryID = C_ClassTalents.GetNextStarterBuildPurchase();
	return (starterNodeID and starterNodeID ~= selectedNodeID) or 
			(selectedEntryID and starterEntryID and starterEntryID ~= selectedEntryID);
end

function ClassTalentsFrameMixin:IsStarterBuildConfig(configID)
	return configID == Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID;
end

function ClassTalentsFrameMixin:GetHasStarterBuild()
	return C_ClassTalents.GetHasStarterBuild();
end

function ClassTalentsFrameMixin:GetIsStarterBuildActive()
	return C_ClassTalents.GetStarterBuildActive();
end

function ClassTalentsFrameMixin:SetStarterBuildActive(isActive)
	EventRegistry:TriggerEvent("PlayerSpellsFrame.TalentTab.StarterBuild", isActive);
	return C_ClassTalents.SetStarterBuildActive(isActive);
end

function ClassTalentsFrameMixin:UnflagStarterBuild()
	self.unflagStarterBuildAfterNextCommit = false;
	if self:IsStarterBuildConfig(self.lastSelectedConfigID) then
		self:ClearLastSelectedConfigID();
	end
	self:SetStarterBuildActive(false);
end

function ClassTalentsFrameMixin:OnActionBarsChanged()
	if not self:IsInspecting() then
		self:UpdateTalentActionBarStatuses();
		self:UpdateFullSearchResults();
	end
end

function ClassTalentsFrameMixin:UpdateTalentActionBarStatuses()
	for button in self:EnumerateAllTalentButtons() do
		button:UpdateActionBarStatus();
	end
end

function ClassTalentsFrameMixin:UpdateTalentVisualStatesByCondition(condition)
	for button in self:EnumerateAllTalentButtons() do
		if condition(button) then
			button:UpdateVisualState();
		end
	end
end

function ClassTalentsFrameMixin:OnHeroSpecSelectionOpened()
	-- Update the visual state of all SubTree nodes, as inactive SubTree nodes should be visible while the Selection dialog is open
	self:UpdateTalentVisualStatesByCondition(function (talentButton)
		return talentButton:IsSubTreeNode();
	end);

	-- Certain Apply button glows are deactivatd if the Selection dialog is also showing them
	self:UpdateConfigButtonsState();
end

function ClassTalentsFrameMixin:OnHeroSpecSelectionClosed()
	-- Update the visual state of all SubTree nodes again, as inactive SubTree nodes should no longer be visible
	self:UpdateTalentVisualStatesByCondition(function (talentButton)
		return talentButton:IsSubTreeNode();
	end);

	-- Certain Apply button glows are deactivatd if the Selection dialog is also showing them
	self:UpdateConfigButtonsState();
end

function ClassTalentsFrameMixin:IsPreviewingSubTree(subTreeID)
	return self.HeroTalentsContainer:IsPreviewingSubTree(subTreeID);
end

function ClassTalentsFrameMixin:ShouldShowHeroTalentTutorial(subTreeInfo)
	if not subTreeInfo then
		return false;
	end

	-- Don't show the tutorial for inactive subTrees.
	if not self.HeroTalentsContainer:IsHeroSpecActive(subTreeInfo.ID) then
		return false;
	end

	-- Don't show the tutorial for the remainder of the session if the player dismissed it for any subTree.
	if self.heroTalentTutorialAcknowledged then
		return false;
	end

	-- Don't show the tutorial once the player has spent a hero talent point in any subTree.
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HERO_TALENT_NONE_SPENT) then
		return false;
	end

	return true;
end

-- Multiple places in the talent frame can display this tip.
function ClassTalentsFrameMixin:CheckHeroTalentTutorial(subTreeInfo, tipOffsetX, tipOffsetY, tipParent, tipRegion)

	-- If the tutorial hasn't been cleared yet, check to see if the player has spent a hero talent point in any subTree.
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HERO_TALENT_NONE_SPENT) then
		local currencySpent = subTreeInfo and TalentFrameUtil.GetSubTreeCurrencySpent(self, subTreeInfo.ID) or 0;

		-- Clear the tutorial once the player has spent a hero talent point in any subTree.
		if currencySpent > 0 then
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HERO_TALENT_NONE_SPENT, true);
		end
	end

	if self:ShouldShowHeroTalentTutorial(subTreeInfo) then
		local helpTipInfo = {
			text = TUTORIAL_HERO_TALENT_NONE_SPENT,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeTop,
			offsetX = tipOffsetX,
			offsetY = tipOffsetY,
			alignment = HelpTip.Alignment.Right,
			useParentStrata = true,
			acknowledgeOnHide = false;
			system = "TutorialHeroTalent",

			 -- Hide the tutorial for the remainder of the session if the player dismisses it on any subTree.
			onAcknowledgeCallback = function()
				self.heroTalentTutorialAcknowledged = true;
				HelpTip:HideAllSystem("TutorialHeroTalent");
			end;
		};
		HelpTip:Show(tipParent, helpTipInfo, tipRegion);
	else
		HelpTip:Hide(tipParent, TUTORIAL_HERO_TALENT_NONE_SPENT);
	end
end

--------------------------- Script Command Helpers --------------------------------
function ClassTalentsFrameMixin:LoadConfigByPredicate(predicate)
	if self:IsInspecting() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INSPECTING);
		return;
	end

	if not self.configIDs or not self.variablesLoaded then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_NO_DATA);
		return;
	end

	if self:IsCommitInProgress() or self:IsSpecActivationInProgress() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_COMMIT_IN_PROGRESS);
		return;
	end

	local configIDToLoad = nil;
	for index, configID in ipairs(self.configIDs) do
		if predicate(index, configID) then
			configIDToLoad = configID;
			break;
		end
	end

	if configIDToLoad then
		local autoApply = true;
		self:LoadConfigInternal(configIDToLoad, autoApply);
	else
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_CONFIG);
	end
end

function ClassTalentsFrameMixin:LoadConfigByName(name)
	if not name or name == "" then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_CONFIG_NAME);
		return;
	end

	self:LoadConfigByPredicate(function(_, configID)
		return self.configIDToName[configID] and (strcmputf8i(self.configIDToName[configID], name) == 0);
	end);
end

function ClassTalentsFrameMixin:LoadConfigByIndex(index)
	if not self.configIDs then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_NO_DATA);
		return;
	end

	if not index or index <= 0 or index > #self.configIDs then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_CONFIG_INDEX);
		return;
	end

	self:LoadConfigByPredicate(function(configIndex, _)
		return configIndex == index;
	end);
end
--------------------------- End Script Command Helpers --------------------------------