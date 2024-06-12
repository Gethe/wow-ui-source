
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

ClassSpecFrameMixin={}

local ClassSpecFrameUnitEvents = {
	"UNIT_LEVEL"
};

function ClassSpecFrameMixin:OnLoad()
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

function ClassSpecFrameMixin:OnShow()
	FrameUtil.RegisterFrameForUnitEvents(self, ClassSpecFrameUnitEvents, "player");
	self:UpdateSpecContents();
	self:UpdateSpecFrame();

	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpecFrame.Show");

	if self:IsActivateInProgress() then
		self:SetActivateVisualsActive(true);
	end

	self:UpdateActivateButtons();

	self:GetTalentsFrame():RegisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self.OnCommitStatusChanged, self);
end

function ClassSpecFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ClassSpecFrameUnitEvents);

	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpecFrame.Hide");

	self:SetActivateVisualsActive(false);
	self:ShowTutorialHelp(false);

	self:GetTalentsFrame():UnregisterCallback(TalentFrameBaseMixin.Event.CommitStatusChanged, self);
end

function ClassSpecFrameMixin:OnCommitStatusChanged()
	self:UpdateActivateButtons();
end

function ClassSpecFrameMixin:ShowTutorialHelp(showHelpFeature)
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
		if showHelpFeature then
			GlowEmitterFactory:Show(specContentFrame.ActivateButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow)			
		else
			GlowEmitterFactory:Hide(specContentFrame.ActivateButton);
		end
	end
end

function ClassSpecFrameMixin:UpdateActivateButtons()
	local shouldBeEnabled = not self:IsCommitInProgress();
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
		specContentFrame.ActivateButton:SetEnabled(shouldBeEnabled)
	end
end

function ClassSpecFrameMixin:UpdateSpecFrame()
	if not C_SpecializationInfo.IsInitialized() then
		return;
	end

	local playerTalentSpec = self:GetCurrentSpecIndex();
	local sex = UnitSex("player");

	if playerTalentSpec == self.activatedSpecIndex and self:IsActivateInProgress() then
		self:SetSpecActivateStarted(nil);
	end

	local canSpecsBeActivated = C_SpecializationInfo.CanPlayerUseTalentSpecUI();
	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
		-- selected spec highlight
		if specContentFrame.specIndex == playerTalentSpec then
			specContentFrame:UpdateActiveGlow(true);
		else
			specContentFrame:UpdateActiveGlow(false);
		end
		
		-- disable activate button
		specContentFrame.ActivateButton:SetEnabled(canSpecsBeActivated);
	end
end

function ClassSpecFrameMixin:UpdateSpecContents()
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
		contentFrame:Setup(i, sex, specContentWidth, numSpecs);
	end
	self:Layout();
end

function ClassSpecFrameMixin:OnEvent(event, ...)
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

function ClassSpecFrameMixin:PlayActivationFlash()
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

function ClassSpecFrameMixin:IsActivateInProgress()
	return self.activatedSpecIndex ~= nil;
end

function ClassSpecFrameMixin:IsCommitInProgress()
	return self:GetTalentsFrame():IsCommitInProgress();
end

function ClassSpecFrameMixin:GetCurrentSpecIndex()
	local talentGroup = 1;
	return GetSpecialization(nil, false, talentGroup);
end

function ClassSpecFrameMixin:SetSpecActivateStarted(specIndex)
	local isActivateStarted = (specIndex ~= nil);
	local wasActivateActive = self:IsActivateInProgress();

	self.activatedSpecIndex = specIndex;

	if isActivateStarted ~= wasActivateActive then
		self:SetActivateVisualsActive(isActivateStarted);
	end
end

function ClassSpecFrameMixin:SetActivateVisualsActive(active)
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

function ClassSpecFrameMixin:GetPlayerSpellsFrame()
	return self:GetParent();
end

function ClassSpecFrameMixin:GetTalentsFrame()
	return self:GetPlayerSpellsFrame().TalentsFrame;
end

function ClassSpecFrameMixin:IsInspecting()
	return self:GetPlayerSpellsFrame():IsInspecting();
end


--------------------------- Script Command Helpers --------------------------------
function ClassSpecFrameMixin:ActivateSpecByPredicate(predicate)
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

function ClassSpecFrameMixin:ActivateSpecByName(specName)
	if not specName or specName == "" then
		UIErrorsFrame:AddExternalErrorMessage(ERR_TALENT_FAILED_INVALID_SPEC_NAME);
		return;
	end

	self:ActivateSpecByPredicate(function(specFrame)
		return specFrame.name and (strcmputf8i(specFrame.name, specName) == 0);
	end);
end

function ClassSpecFrameMixin:ActivateSpecByIndex(specIndex)
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
	self.AnimationHolder.ActivationFlashBack:SetScript("OnFinished", GenerateClosure(self.OnActivationFlashFinished, self));
end

function ClassSpecContentFrameMixin:Setup(index, sex, frameWidth, numSpecs)
	self:Show();
	self:SetWidth(frameWidth);
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

	self.ColumnDivider:SetShown(not self.isRightMostSpec)

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

function ClassSpecContentFrameMixin:UpdateActiveGlow(isInGlowState)
	if self.isInGlowState == isInGlowState then
		return;
	end

	self.isInGlowState = isInGlowState;
	if isInGlowState then
		self.ActivatedText:Show();
		self.ActivateButton:Hide();
		self.SpecImageBorderOn:Show();
		self.SpecImageBorderOff:Hide();

		MixinUtil.CallMethodOnAllSafe(self.ActivatedBackFrames, "Show");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedLeftFrames, "SetShown", not self.isLeftMostSpec);
		MixinUtil.CallMethodOnAllSafe(self.ActivatedRightFrames, "SetShown", not self.isRightMostSpec);
	else
		self.ActivatedText:Hide();
		self.ActivateButton:Show();
		self.SpecImageBorderOn:Hide();
		self.SpecImageBorderOff:Show();

		MixinUtil.CallMethodOnAllSafe(self.ActivatedBackFrames, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedLeftFrames, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedRightFrames, "Hide");
	end

	-- Mouse already hovering, update hover state visibility based on new glow state
	if self:IsMouseOver() then
		self:SetHoverStateActive(not self.isInGlowState);
	end
end

function ClassSpecContentFrameMixin:SetActivationFlashPlaying(playFlash)
	if playFlash == self.playingActivationFlash then
		return;
	end

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

function ClassSpecContentFrameMixin:OnActivationFlashFinished()
	self.playingActivationFlash = false;
end

function ClassSpecContentFrameMixin:OnActivateClicked()
	if self:IsVisible() then
		PlaySound(SOUNDKIT.UI_CLASS_TALENT_SPEC_ACTIVATE);
	end
	if SetSpecialization(self.specIndex, false) then
		self:GetParent():SetSpecActivateStarted(self.specIndex);
	end
	EventRegistry:TriggerEvent("PlayerSpellsFrame.SpecFrame.ActivateSpec");
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

ClassSpecSpellMixin = {}

function ClassSpecSpellMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ClassSpecSpellMixin:Setup(index, spellID)
	self.index = index;
	local _, icon = C_Spell.GetSpellTexture(spellID);
	SetPortraitToTexture(self.Icon, icon);
	self.spellID = spellID;
	self.extraTooltip = nil;
	self.disabled = true;
	self:Show();
end

function ClassSpecSpellMixin:OnDragStart()
	if not self.disabled then
		C_Spell.PickupSpell(self.spellID);
	end
end
function ClassSpecSpellMixin:OnReceiveDrag()
	if not self.disabled then
		C_Spell.PickupSpell(self.spellID);
	end
end

function ClassSpecSpellMixin:OnEnter()
	self:GetParent():OnEnter();

    if not self.spellID or not C_Spell.GetSpellName(self.spellID) then
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
