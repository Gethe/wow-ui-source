
SPEC_STAT_STRINGS = {
	[LE_UNIT_STAT_STRENGTH] = SPEC_FRAME_PRIMARY_STAT_STRENGTH,
	[LE_UNIT_STAT_AGILITY] = SPEC_FRAME_PRIMARY_STAT_AGILITY,
	[LE_UNIT_STAT_INTELLECT] = SPEC_FRAME_PRIMARY_STAT_INTELLECT,
};

local NUM_SPELLS_PER_SPEC = 2;
local ROLE_ICON_TEXT_MARGIN = 5;
local BASIC_SPELL_INDEX = 1;
local SIGNATURE_SPELL_INDEX = 6;
local SPELL_HORIZONTAL_OFFSET = 34;
local SPEC_TEXTURE_FORMAT = "spec-thumbnail-%s";

local SPEC_FORMAT_STRINGS = {
	[62] = "mage-arcane",
	[63] = "mage-fire",
	[64] = "mage-frost",
	[65] = "paladin-holy",
	[66] = "paladin-protection",
	[70] = "paladin-retribution",
	[71] = "warrior-arms",
	[72] = "warrior-fury",
	[73] = "warrior-protection",
	[102] = "druid-balance",
	[103] = "druid-feral",
	[104] = "druid-guardian",
	[105] = "druid-restoration",
	[250] = "deathknight-blood",
	[251] = "deathknight-frost",
	[252] = "deathknight-unholy",
	[253] = "hunter-beastmastery",
	[254] = "hunter-marksmanship",
	[255] = "hunter-survival",
	[256] = "priest-discipline",
	[257] = "priest-holy",
	[258] = "priest-shadow",
	[259] = "rogue-assassination",
	[260] = "rogue-outlaw",
	[261] = "rogue-subtlety",
	[262] = "shaman-elemental",
	[263] = "shaman-enhancement",
	[264] = "shaman-restoration",
	[265] = "warlock-affliction",
	[266] = "warlock-demonology",
	[267] = "warlock-destruction",
	[268] = "monk-brewmaster",
	[269] = "monk-windwalker",
	[270] = "monk-mistweaver",
	[577] = "demonhunter-havoc",
	[581] = "demonhunter-vengeance",
	[1467] = "evoker-devastation",
	[1468] = "evoker-preservation",
	[1473] = "evoker-augmentation",
}

ClassTalentSpecTabMixin={}

local ClassTalentSpecTabUnitEvents = {
	"UNIT_LEVEL"
};

function ClassTalentSpecTabMixin:OnLoad()
	self.SpecContentFramePool = CreateFramePool("FRAME", self, "ClassSpecContentFrameTemplate");
	self.DisabledOverlay.GrayOverlay:SetAlpha(self.disabledOverlayAlpha);

	-- TODO: Replace with bespoke spec change state flow
	self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player");
	self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");

	-- This needs to always be registered so that the entire spec change process is always captured.
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");

	self:UpdateSpecContents();
	self:UpdateSpecFrame();
end

function ClassTalentSpecTabMixin:OnShow()
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentSpecTabUnitEvents, "player");
	self:UpdateSpecContents();
	self:UpdateSpecFrame();

	EventRegistry:TriggerEvent("TalentFrame.SpecTab.Show");

	if self:IsActivateInProgress() then
		self:SetActivateVisualsActive(true);
	end

	self:UpdateActivateButtons();

	self:GetTalentsTab():RegisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self.OnCommitStatusChanged, self);
end

function ClassTalentSpecTabMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentSpecTabUnitEvents);

	EventRegistry:TriggerEvent("TalentFrame.SpecTab.Hide");

	self:SetActivateVisualsActive(false);
	self:ShowTutorialHelp(false);

	self:GetTalentsTab():UnregisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self);
end

function ClassTalentSpecTabMixin:OnCommitStatusChanged()
	self:UpdateActivateButtons();
end

function ClassTalentSpecTabMixin:ShowTutorialHelp(showHelpFeature)
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
		if showHelpFeature then
			GlowEmitterFactory:Show(specContentFrame.ActivateButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow)			
		else
			GlowEmitterFactory:Hide(specContentFrame.ActivateButton);
		end
	end
end

function ClassTalentSpecTabMixin:UpdateActivateButtons()
	local shouldBeEnabled = not self:IsCommitInProgress();
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
		specContentFrame.ActivateButton:SetEnabled(shouldBeEnabled)
	end
end

function ClassTalentSpecTabMixin:UpdateSpecFrame()
	if not C_SpecializationInfo.IsInitialized() then
		return;
	end

	local playerTalentSpec = self:GetCurrentSpecIndex();
	local sex = UnitSex("player");

	if playerTalentSpec == self.activatedSpecIndex and self:IsActivateInProgress() then
		self:SetSpecActivateStarted(nil);
	end

	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
		-- selected spec highlight
		if specContentFrame.specIndex == playerTalentSpec then
			specContentFrame:UpdateSelectionGlow(true);
		else
			specContentFrame:UpdateSelectionGlow(false);
		end
		
		-- disable activate button
		if C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
			specContentFrame.ActivateButton:Enable();
		else
			specContentFrame.ActivateButton:Disable();
		end
	end
end

function ClassTalentSpecTabMixin:UpdateSpecContents()
	if self.isInitialized or not C_SpecializationInfo.IsInitialized() then
		return;
	end
	self.isInitialized = true;

	local numSpecs = GetNumSpecializations(false, false);
	self.numSpecs = numSpecs;
	if numSpecs == 0 then 
		return;
	end
	local sex = UnitSex("player");
	local specContentWidth = self:GetWidth() / numSpecs;

	-- set spec infos
	self.SpecContentFramePool:ReleaseAll();
	for i = 1, numSpecs do
		local contentFrame = self.SpecContentFramePool:Acquire();
		contentFrame:Setup(i, sex, specContentWidth, self:GetHeight(), numSpecs);
	end
	self:Layout();
end

function ClassTalentSpecTabMixin:OnEvent(event, ...)
	if (event == "UNIT_LEVEL") or (event == "PLAYER_SPECIALIZATION_CHANGED") then
		self:UpdateSpecFrame();

		if event == "PLAYER_SPECIALIZATION_CHANGED" then
			self:PlayActivationFlash();
			self:SetSpecActivateStarted(nil);
		end
	-- TODO: Replace with bespoke spec change state flow
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) and ( self:IsActivateInProgress()) then
		local cancelledSpellID = select(3, ...);
		if ( cancelledSpellID and IsSpecializationActivateSpell(cancelledSpellID) ) then
			self:SetSpecActivateStarted(nil);
		end
	end
end

function ClassTalentSpecTabMixin:PlayActivationFlash()
	if not self:IsShown() then
		return;
	end

	local currentSpecIndex = self:GetCurrentSpecIndex();
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
		if specContentFrame.specIndex == currentSpecIndex then
			specContentFrame:SetActivationFlashPlaying(true);
		end
	end
end

function ClassTalentSpecTabMixin:IsActivateInProgress()
	return self.activatedSpecIndex ~= nil;
end

function ClassTalentSpecTabMixin:IsCommitInProgress()
	return self:GetTalentsTab():IsCommitInProgress();
end

function ClassTalentSpecTabMixin:GetCurrentSpecIndex()
	local talentGroup = 1;
	return GetSpecialization(nil, false, talentGroup);
end

function ClassTalentSpecTabMixin:SetSpecActivateStarted(specIndex)
	local isActivateStarted = (specIndex ~= nil);
	local wasActivateActive = self:IsActivateInProgress();

	self.activatedSpecIndex = specIndex;

	if isActivateStarted ~= wasActivateActive then
		self:SetActivateVisualsActive(isActivateStarted);
	end
end

function ClassTalentSpecTabMixin:SetActivateVisualsActive(active)
	if active and not self:IsVisible() then
		return;
	end

	if active then
		OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(self.DisabledOverlay, { overrideBarType = "applyingtalents" });
		self.DisabledOverlay:SetShown(true);
	else
		OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
		self.DisabledOverlay:SetShown(false);
	end
end

function ClassTalentSpecTabMixin:GetClassTalentFrame()
	return self:GetParent();
end

function ClassTalentSpecTabMixin:GetTalentsTab()
	return self:GetClassTalentFrame().TalentsTab;
end

function ClassTalentSpecTabMixin:IsInspecting()
	return self:GetClassTalentFrame():IsInspecting();
end


--------------------------- Script Command Helpers --------------------------------
function ClassTalentSpecTabMixin:ActivateSpecByPredicate(predicate)
	if self:IsInspecting() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INSPECTING);
		return;
	end

	if not self.isInitialized or not self.numSpecs or self.numSpecs == 0 then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_NO_DATA);
		return;
	end

	if self:IsActivateInProgress() or self:IsCommitInProgress() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_COMMIT_IN_PROGRESS);
		return;
	end

	local specFrameToActivate = nil;
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
		if predicate(specContentFrame) then
			specFrameToActivate = specContentFrame;
			break;
		end
	end

	if specFrameToActivate then
		specFrameToActivate:OnActivateClicked();
	else
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_SPEC);
	end
end

function ClassTalentSpecTabMixin:ActivateSpecByName(specName)
	if not specName or specName == "" then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_SPEC_NAME);
		return;
	end

	self:ActivateSpecByPredicate(function(specFrame)
		return specFrame.name and (strcmputf8i(specFrame.name, specName) == 0);
	end);
end

function ClassTalentSpecTabMixin:ActivateSpecByIndex(specIndex)
	if not self.isInitialized or not self.numSpecs or self.numSpecs == 0 then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_NO_DATA);
		return;
	end

	if not specIndex or specIndex <= 0 or specIndex > self.numSpecs then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_SPEC_INDEX);
		return;
	end

	self:ActivateSpecByPredicate(function(specFrame)
		return specFrame.specIndex == specIndex;
	end);
end
--------------------------- End Script Command Helpers --------------------------------

ClassSpecContentFrameMixin={}

function ClassSpecContentFrameMixin:OnLoad()
	self.SpellButtonPool = CreateFramePool("BUTTON", self, "ClassSpecSpellTemplate");

	self.selectedBackgrounds = {
		back = 	{ self.SelectedBackgroundBack1, self.SelectedBackgroundBack2 },
		left = 	{ self.SelectedBackgroundLeft1, self.SelectedBackgroundLeft2, self.SelectedBackgroundLeft3, self.SelectedBackgroundLeft4, },
		right = { self.SelectedBackgroundRight1, self.SelectedBackgroundRight2,	self.SelectedBackgroundRight3, self.SelectedBackgroundRight4 }
	};
	self.activatedBackgrounds = {
		back = 	{ self.ActivatedBackgroundBack1, self.ActivatedBackgroundBack2 },
		left = 	{ self.ActivatedBackgroundLeft1, self.ActivatedBackgroundLeft2, self.ActivatedBackgroundLeft3, self.ActivatedBackgroundLeft4 },
		right = { self.ActivatedBackgroundRight1, self.ActivatedBackgroundRight2, self.ActivatedBackgroundRight3, self.ActivatedBackgroundRight4 }
	};
end

function ClassSpecContentFrameMixin:Setup(index, sex, frameWidth, frameHeight, numSpecs)
	self:Show();
	self:SetWidth(frameWidth);
	self:SetHeight(frameHeight);
	self.layoutIndex = index;
	self.specIndex = index;

	self.isLeftMostSpec = index == 1;
	self.isRightMostSpec = index == numSpecs;

	local specID, name, description, icon, _, primaryStat = GetSpecializationInfo(index, false, false, nil, sex);

	if not specID then
		return;
	end

	self.name = name;

	local atlasName = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[specID]);
	if C_Texture.GetAtlasInfo(atlasName) then
		self.SpecImage:SetAtlas(atlasName);
		self.ActivatedSpecImage:SetAtlas(atlasName);
		self.HoverSpecImage:SetAtlas(atlasName);
	end
	self.SpecName:SetText(name);
	if primaryStat and primaryStat ~= 0 then
		self.Description:SetText(description.."|n"..SPEC_FRAME_PRIMARY_STAT:format(SPEC_STAT_STRINGS[primaryStat]));
	end
	local role = GetSpecializationRoleEnum(index, false, false);
	self.RoleIcon:SetAtlas(GetMicroIconForRoleEnum(role), TextureKitConstants.IgnoreAtlasSize);
	self.RoleName:SetText(GetLFGStringFromEnum(role));

	-- set positions
	local length = (self.RoleIcon:GetWidth() + self.RoleName:GetWidth() + ROLE_ICON_TEXT_MARGIN)/2;
	local offset = self.RoleIcon:GetWidth()/2 - length;

	self.RoleIcon:ClearAllPoints();
	self.RoleIcon:SetPoint("TOP", self.SpecName, "BOTTOM", offset, -11);

	self.RoleName:ClearAllPoints();
	self.RoleName:SetPoint("LEFT", self.RoleIcon, "RIGHT", ROLE_ICON_TEXT_MARGIN, 0);

	-- highlights and columns
	self:SetFramesSize(frameWidth, frameHeight, self.selectedBackgrounds.back);
	self:SetFramesHeight(frameHeight, self.selectedBackgrounds.left);
	self:SetFramesHeight(frameHeight, self.selectedBackgrounds.right);
	self:SetFramesSize(frameWidth, frameHeight, self.activatedBackgrounds.back);
	self:SetFramesHeight(frameHeight, self.activatedBackgrounds.left);
	self:SetFramesHeight(frameHeight, self.activatedBackgrounds.right);

	if self.isRightMostSpec then
		self.ColumnDivider:Hide();
	else
		self.ColumnDivider:Show();
	end

	-- adjust background positioning
	local leftBGPadding = self.isLeftMostSpec and 0 or self.ColumnDivider:GetWidth() / 2;
	local rightBGPadding = self.isRightMostSpec and 0 or self.ColumnDivider:GetWidth() / 2;
	self.HoverBackground:SetPoint("TOPLEFT", leftBGPadding, 0);
	self.HoverBackground:SetPoint("BOTTOMRIGHT", rightBGPadding, 0);

	-- set spec spells
	self.SpellButtonPool:ReleaseAll();

	local bonuses;
	bonuses = C_SpecializationInfo.GetSpellsDisplay(specID);
	local spellIndex=1;

	if bonuses then
		for i, bonus in ipairs(bonuses) do
			if i == BASIC_SPELL_INDEX then
				local spellButton = self.SpellButtonPool:Acquire();
				spellButton:Setup(spellIndex, bonus);
				spellButton:ClearAllPoints();
				spellButton:SetPoint("TOP", self.SampleAbilityText, "BOTTOM", -SPELL_HORIZONTAL_OFFSET, -10);
				spellIndex = spellIndex + 1;
			elseif i == SIGNATURE_SPELL_INDEX then
				local spellButton = self.SpellButtonPool:Acquire();
				spellButton:Setup(spellIndex, bonus);
				spellButton:ClearAllPoints();
				spellButton:SetPoint("TOP", self.SampleAbilityText, "BOTTOM", SPELL_HORIZONTAL_OFFSET, -10);
				spellIndex = spellIndex + 1;
			end
		end
	end
end

function ClassSpecContentFrameMixin:UpdateSelectionGlow(isInGlowState)
	self.isInGlowState = isInGlowState;
	if isInGlowState then
		self.ActivatedText:Show();
		self.ActivateButton:Hide();
		self.SpecImageBorderOn:Show();
		self.SpecImageBorderOff:Hide();

		self:SetFramesShown(true, self.selectedBackgrounds.back);
		if not self.isLeftMostSpec then
			self:SetFramesShown(true, self.selectedBackgrounds.left);
		end
		if not self.isRightMostSpec then
			self:SetFramesShown(true, self.selectedBackgrounds.right);
		end
	else
		self.ActivatedText:Hide();
		self.ActivateButton:Show();
		self.SpecImageBorderOn:Hide();
		self.SpecImageBorderOff:Show();

		self:SetFramesShown(false, self.selectedBackgrounds.back);
		self:SetFramesShown(false, self.selectedBackgrounds.left);
		self:SetFramesShown(false, self.selectedBackgrounds.right);
	end

	-- Mouse already hovering, update hover state visibility based on new glow state
	if self:IsMouseOver() then
		self:SetHoverStateActive(not self.isInGlowState);
	end
end

function ClassSpecContentFrameMixin:SetActivationFlashPlaying(playFlash)
	if playFlash then
		self.AnimationHolder.ActivationFlashBack:Restart();
		if not self.isLeftMostSpec then
			--self.AnimationHolder.ActivationFlashLeft:Restart();
		end
		if not self.isRightMostSpec then
			--self.AnimationHolder.ActivationFlashRight:Restart();
		end
		self.playingActivationFlash = true;
	else
		self.AnimationHolder.ActivationFlashBack:Stop();
		--self.AnimationHolder.ActivationFlashLeft:Stop();
		--self.AnimationHolder.ActivationFlashRight:Stop();
		self.playingActivationFlash = false;
	end
end

function ClassSpecContentFrameMixin:OnActivateClicked()
	if self:IsVisible() then
		PlaySound(SOUNDKIT.UI_CLASS_TALENT_SPEC_ACTIVATE);
	end
	if SetSpecialization(self.specIndex, false) then
		self:GetParent():SetSpecActivateStarted(self.specIndex);
	end
	EventRegistry:TriggerEvent("TalentFrame.SpecTab.ActivateSpec");
end

function ClassSpecContentFrameMixin:OnHide()
	if self.playingActivationFlash then
		self:SetActivationFlashPlaying(false);
	end
end

function ClassSpecContentFrameMixin:OnEnter()
	if not self.isInGlowState then
		self:SetHoverStateActive(true);
	end
end

function ClassSpecContentFrameMixin:OnLeave()
	if not self.isInGlowState then
		self:SetHoverStateActive(false);
	end
end

function ClassSpecContentFrameMixin:SetHoverStateActive(isActive)
	self.HoverSpecImageBorder:SetShown(isActive);
	self.HoverSpecImage:SetShown(isActive);
	self.HoverBackground:SetShown(isActive);
end

function ClassSpecContentFrameMixin:SetFramesSize(width, height, frames)
	for i, frame in ipairs(frames) do
		frame:SetSize(width, height);
	end
end

function ClassSpecContentFrameMixin:SetFramesHeight(height, frames)
	for i, frame in ipairs(frames) do
		frame:SetHeight(height);
	end
end

function ClassSpecContentFrameMixin:SetFramesShown(shown, frames)
	for i, frame in ipairs(frames) do
		frame:SetShown(shown);
	end
end

ClassSpecSpellMixin = {}

function ClassSpecSpellMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ClassSpecSpellMixin:Setup(index, spellID)
	self.index = index;
	local _, icon = GetSpellTexture(spellID);
	SetPortraitToTexture(self.Icon, icon);
	self.spellID = spellID;
	self.extraTooltip = nil;
	self.disabled = true;
	self:Show();
end

function ClassSpecSpellMixin:OnDragStart()
	if not self.disabled then
		PickupSpell(self.spellID);
	end
end
function ClassSpecSpellMixin:OnReceiveDrag()
	if not self.disabled then
		PickupSpell(self.spellID);
	end
end

function ClassSpecSpellMixin:OnEnter()
	self:GetParent():OnEnter();

    if not self.spellID or not GetSpellInfo(self.spellID) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID, false, false, true);
	if self.extraTooltip then
		GameTooltip:AddLine(self.extraTooltip);
	end
	self.UpdateTooltip = self.OnEnter;
	GameTooltip:Show();
end

function ClassSpecSpellMixin:OnLeave()
	self:GetParent():OnLeave();

	self.UpdateTooltip = nil;
	GameTooltip:Hide();
end
