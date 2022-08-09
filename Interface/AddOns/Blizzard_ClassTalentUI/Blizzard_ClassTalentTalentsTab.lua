
g_classTalentConfigIDBySpec = g_classTalentConfigIDBySpec or {};

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
	[270] = "talents-background-monk-windwalker",
	[269] = "talents-background-monk-mistweaver",

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

	local textColor = (amount > 0) and GREEN_FONT_COLOR or GRAY_FONT_COLOR;
	self.CurrencyAmount:SetTextColor(textColor:GetRGBA());

	self:MarkDirty();
end

function ClassTalentCurrencyDisplayMixin:GetTalentFrame()
	return self:GetParent();
end


ClassTalentTalentsTabMixin = CreateFromMixins(TalentFrameBaseMixin);

local ClassTalentTalentsTabEvents = {
	"TRAIT_CONFIG_CREATED",
	"ACTIVE_COMBAT_CONFIG_CHANGED",
	"PLAYER_REGEN_ENABLED",
	"PLAYER_REGEN_DISABLED",
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
	-- TODO:: Replace this temporary fix up.
	local classIDToOffsets = {
		[1] = { extraOffsetX = 30, extraOffsetY = 0, }, -- Warrior
		[2] = { extraOffsetX = -60, extraOffsetY = -29, }, -- Paladin
		[4] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Rogue
		[5] = { extraOffsetX = -30, extraOffsetY = -29, }, -- Priest
		[8] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Mage
		[11] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Druid
		[13] = { extraOffsetX = 30, extraOffsetY = -29, }, -- Evoker
	};

	local classOffsets = classIDToOffsets[PlayerUtil.GetClassID()];
	if classOffsets then
		self.basePanOffsetX = self.basePanOffsetX - (classOffsets.extraOffsetX or 0);
		self.basePanOffsetY = self.basePanOffsetY - (classOffsets.extraOffsetY or 0);
	end

	TalentFrameBaseMixin.OnLoad(self);

	self.ResetButton:SetOnClickHandler(GenerateClosure(self.ResetTree, self));

	self.ApplyButton:SetOnClickHandler(GenerateClosure(self.CommitConfig, self));
	self.ApplyButton:SetOnEnterHandler(GenerateClosure(self.UpdateConfigButtonsState, self));
	self.UndoButton:SetOnClickHandler(GenerateClosure(self.RollbackConfig, self));

	self.PvPTalentList:SetTalentFrame(self);
	self.PvPTalentSlotTray:SetTalentFrame(self);

	self:InitializeLoadoutDropDown();

	-- TODO:: Remove this. It's all temporary until there's a better server-side solution.
	EventUtil.ContinueOnAddOnLoaded("Blizzard_ClassTalentUI", GenerateClosure(self.LoadSavedVariables, self));
	self:RegisterEvent("PLAYER_TALENT_UPDATE");
	self:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED");
end

-- This is registered and unregistered dynamically.
function ClassTalentTalentsTabMixin:OnUpdate()
	TalentFrameBaseMixin.OnUpdate(self);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:OnShow()
	self:UpdateSpecBackground();
	self:RefreshConfigID();
	self:CheckSetSelectedConfigID();

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, ClassTalentTalentsTabEvents);
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentTalentsTabUnitEvents, "player");

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:LoadSavedVariables()
	self.variablesLoaded = true;

	self:CheckSetSelectedConfigID();
end

function ClassTalentTalentsTabMixin:UpdateSpecBackground()
	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	local atlas = SpecIDToBackgroundAtlas[currentSpecID];
	if atlas and C_Texture.GetAtlasInfo(atlas) then
		self.Background:SetAtlas(SpecIDToBackgroundAtlas[currentSpecID], TextureKitConstants.UseAtlasSize);
	end
end

function ClassTalentTalentsTabMixin:CheckSetSelectedConfigID()
	if not self.variablesLoaded or not self:IsShown() then
		return;
	end

	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	local previouslySelectedConfigID = currentSpecID and g_classTalentConfigIDBySpec[currentSpecID] or nil;
	if previouslySelectedConfigID then
		self:SetSelectedSavedConfigID(previouslySelectedConfigID);
	else
		self.LoadoutDropDown:ClearSelection();
	end
end

function ClassTalentTalentsTabMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, ClassTalentTalentsTabEvents);
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentTalentsTabUnitEvents);
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
	elseif event == "ACTIVE_COMBAT_CONFIG_CHANGED" then
		local configID = ...;
		self:SetConfigID(configID);
	elseif event == "CONFIG_COMMIT_FAILED" then
		self:SetSelectedSavedConfigID(self.lastSelectedConfigID);
	elseif event == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateSpecBackground();
		self:RefreshLoadoutOptions();
		self:MarkTreeDirty();
		self:CheckSetSelectedConfigID();
	elseif event == "PLAYER_TALENT_UPDATE" then
		self:CheckSetSelectedConfigID();
		self:UnregisterEvent("PLAYER_TALENT_UPDATE");

	-- TODO:: Replace this events with more proper "CanChangeTalent" signal(s).
	elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_REGEN_DISABLED") or (event == "UNIT_AURA") then
		self:UpdateConfigButtonsState();
	end

	TalentFrameBaseMixin.OnEvent(self, event, ...);
end

function ClassTalentTalentsTabMixin:OnTraitConfigUpdated(configID)
	-- Overrides TalentFrameBaseMixin.

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

	local loadoutDropDownControl = self.LoadoutDropDown:GetDropDownControl();
	loadoutDropDownControl:SetDropDownTextFontObject("GameFontDisable");
	loadoutDropDownControl:SetDropDownListMinWidth(186);
	loadoutDropDownControl:SetCustomMenuAnchorInfo(-8, 0, "BOTTOMLEFT", "TOPLEFT");

	self:RefreshLoadoutOptions();
	self:RefreshConfigID();

	local function NewEntryCallback(entryName)
		C_ClassTalents.RequestNewConfig(entryName);

		-- Don't select the new config until the server responds.
		return nil;
	end

	self.LoadoutDropDown:SetNewEntryCallback(NewEntryCallback, TALENT_FRAME_DROP_DOWN_NEW_LOADOUT, TALENT_FRAME_DROP_DOWN_NEW_LOADOUT_PROMPT);

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
	self.lastSelectedConfigID = configID;

	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	if currentSpecID then
		g_classTalentConfigIDBySpec[currentSpecID] = configID;
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
	local classInfo = PlayerUtil.GetClassInfo();
	self.ClassCurrencyDisplay:SetPointTypeText(string.upper(classInfo.className));
	self.ClassCurrencyDisplay:SetAmount(classCurrencyInfo and classCurrencyInfo.quantity or 0);

	local specCurrencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[2] or nil;
	self.SpecCurrencyDisplay:SetPointTypeText(string.upper(PlayerUtil.GetSpecName()));
	self.SpecCurrencyDisplay:SetAmount(specCurrencyInfo and specCurrencyInfo.quantity or 0);
end

function ClassTalentTalentsTabMixin:RefreshLoadoutOptions()
	self.configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID());

	self.configIDToName = {};
	for i, configID in ipairs(self.configIDs) do
		local configInfo = C_Traits.GetConfigInfo(configID);
		self.configIDToName[configID] = (configInfo and configInfo.name) or "";
	end

	local function SelectionNameTranslation(configID)
		return self.configIDToName[configID];
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
	local activeConfigID = C_ClassTalents.GetActiveConfigID() or self.configIDs[1];
	self:SetConfigID(activeConfigID);
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

function ClassTalentTalentsTabMixin:SetCommitStarted(configID)
	TalentFrameBaseMixin.SetCommitStarted(self, configID);

	self:UpdateConfigButtonsState();
end

function ClassTalentTalentsTabMixin:LoadConfigInternal(configID, autoApply)
	local loadResult = C_ClassTalents.LoadConfig(configID, autoApply);
	if (loadResult == Enum.LoadConfigResult.LoadInProgress) and autoApply then
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
	local canChangeTalents, canAdd, canChangeError = self:CanChangeTalents();
	self.LoadoutDropDown:SetEnabledState(canChangeTalents, canChangeError);

	local hasAnyChanges = self:HasAnyConfigChanges();
	self.ApplyButton:SetEnabled(hasAnyChanges and (canChangeTalents or canAdd));

	if hasAnyChanges and not canChangeTalents and canChangeError then
		self.ApplyButton:SetDisabledTooltip(canChangeError);
	else
		self.ApplyButton:SetDisabledTooltip(nil);
	end

	if hasAnyChanges then
		GlowEmitterFactory:Show(self.ApplyButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
	end

	self.UndoButton:SetShown(hasAnyChanges);
	self.ResetButton:SetShown(not hasAnyChanges);
	self.ResetButton:SetEnabledState(self:HasValidConfig() and self:HasAnyPurchasedRanks() and not self:IsCommitInProgress());
end

function ClassTalentTalentsTabMixin:HasAnyPurchasedRanks()
	for button in self:EnumerateAllTalentButtons() do
		local nodeInfo = button:GetTalentNodeInfo();
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

	return C_ClassTalents.CanChangeTalents();
end

function ClassTalentTalentsTabMixin:CanChangeTalents()
	if self:IsCommitInProgress() then
		return false, false;
	end

	return C_ClassTalents.CanChangeTalents();
end
