local ccRemoverFrameInitialAnchor =
{
	point = "TOPLEFT";
	relativePoint = "TOPRIGHT";
	xOffset = 2;
	yOffset = -1;
}

local debuffFrameInitialAnchor =
{
	point = "TOPRIGHT";
	relativePoint = "TOPLEFT";
	xOffset = -3;
	yOffset = -2;
}

local useClassColorsCvarName = "pvpFramesDisplayClassColor";
CVarCallbackRegistry:SetCVarCachable(useClassColorsCvarName);

local function GetUseClassColors()
	return CVarCallbackRegistry:GetCVarValueBool(useClassColorsCvarName);
end

local function GetArenaSize()
	-- Use opponent specs first since we know those before the match has started
	local numOpponentSpecs = GetNumArenaOpponentSpecs();
	if numOpponentSpecs and numOpponentSpecs > 0 then
		return numOpponentSpecs;
	end

	-- If we don't know opponent specs, we're probably in an arena which doesn't have a set size
	-- In this case base it on whoever happens to be in the arena
	-- Note we won't know this until the match actually starts
	local numOpponents = GetNumArenaOpponents();
	if numOpponents and numOpponents > 0 then
		return numOpponents;
	end

	return 0;
end

local function IsMatchEngaged()
	return C_PvP.GetActiveMatchState() == Enum.PvPMatchState.Engaged;
end

local function IsInArena()
	return C_PvP.IsMatchConsideredArena() and (C_PvP.IsMatchActive() or C_PvP.IsMatchComplete());
end

local function GetUnitToken(unitIndex)
	return "arena"..unitIndex;
end

local function GetPetUnitToken(unitIndex)
	return "arenapet"..unitIndex;
end

local function SetRoleIconTexture(texture, role)
	if role and (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		texture:SetSize(12, 12);
		texture:SetAtlas(GetMicroIconForRole(role), TextureKitConstants.IgnoreAtlasSize);
		texture:Show();
	else
		texture:Hide();
		texture:SetSize(1, 12);
	end
end

local function SetFrameBarColor(barTexture, class)
	local r, g, b = 1.0, 0.0, 0.0;
	if GetUseClassColors() and class then
		local classColor = RAID_CLASS_COLORS[class];
		r, g, b = classColor.r, classColor.g, classColor.b;
	end
	barTexture:SetVertexColor(r, g, b);
end

function CompactArenaFrame_Generate()
	local frame = CompactArenaFrame;
	local didCreate = false;
	if not frame then
		frame = CreateFrame("Frame", "CompactArenaFrame", UIParent, "CompactArenaFrameTemplate");
		frame:RegisterEvent("ARENA_OPPONENT_UPDATE");
		frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
		didCreate = true;
	end
	return frame, didCreate;
end

CompactArenaFrameMixin = CreateFromMixins(CompactPartyFrameMixin);

function CompactArenaFrameMixin:OnLoad()
	CompactPartyFrameMixin.OnLoad(self);
	self.updateLayoutFunc = self.UpdateLayout;

	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		memberUnitFrame.frameIndex = i;
		CompactUnitFrame_SubscribeToVisibilityChanged(memberUnitFrame, self,
			function(subscribingFrame, unitFrame)
				-- If a frame stopped showing but we're in edit mode and the frame should be shown then RefreshMembers to make it show again by putting a dummy unit into it
				if not unitFrame:IsShown() and self.isInEditMode and unitFrame.frameIndex <= EditModeManagerFrame:GetNumArenaFramesForcedShown() then
					self:RefreshMembers();
				end
			end);

		-- Create CcRemover frame
		local ccRemoverFrame = CreateFrame("Frame", nil, memberUnitFrame, "ArenaUnitFrameCcRemoverTemplate");
		memberUnitFrame.CcRemoverFrame = ccRemoverFrame;
		ccRemoverFrame:SetPoint(ccRemoverFrameInitialAnchor.point, memberUnitFrame, ccRemoverFrameInitialAnchor.relativePoint, ccRemoverFrameInitialAnchor.xOffset, ccRemoverFrameInitialAnchor.yOffset);

		-- Create debuff frame
		local debuffFrame = CreateFrame("Frame", nil, memberUnitFrame, "ArenaUnitFrameDebuffTemplate");
		memberUnitFrame.DebuffFrame = debuffFrame;
		debuffFrame:SetPoint(debuffFrameInitialAnchor.point, memberUnitFrame, debuffFrameInitialAnchor.relativePoint, debuffFrameInitialAnchor.xOffset, debuffFrameInitialAnchor.yOffset);

		-- Create casting bar
		local castingBarFrame = CreateFrame("StatusBar", nil, memberUnitFrame, "ArenaUnitFrameCastingBarTemplate");
		memberUnitFrame.CastingBarFrame = castingBarFrame;
		castingBarFrame:SetPoint("TOPRIGHT", debuffFrame, "TOPLEFT", -5, -2);

		-- Create stealthed unit frames
		local stealthedUnitFrame = CreateFrame("Frame", nil, self, "StealthedArenaUnitFrameTemplate");
		self["StealthedUnitFrame"..i] = stealthedUnitFrame;
		stealthedUnitFrame:SetPoint("TOPLEFT", memberUnitFrame, "TOPLEFT");
		stealthedUnitFrame:SetPoint("BOTTOMRIGHT", memberUnitFrame, "BOTTOMRIGHT");
	end

	self:RefreshMembers();
	EditModeSystemMixin.OnSystemLoad(self);
end

function CompactArenaFrameMixin:UpdateLayout()
	local arenaSize = GetArenaSize();
	self.minUnitFrames = arenaSize > 0 and arenaSize or 1;

	CompactPartyFrameMixin.UpdateLayout(self);

	local firstMemberUnitFrame = self.memberUnitFrames[1];
	local frameBorderOffset = self.borderFrame:IsShown() and 4 or 0;
	local unitFrameXOffset = -frameBorderOffset;

	-- Anchor title to top of first member unit frame
	local title = self.title;
	title:ClearAllPoints();
	title:SetPoint("BOTTOM", firstMemberUnitFrame, "TOP");

	local width, height = self:GetSize();

	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		local ccRemoverFrame = memberUnitFrame.CcRemoverFrame;
		local debuffFrame = memberUnitFrame.DebuffFrame;
		local castingBarFrame = memberUnitFrame.CastingBarFrame;

		if ccRemoverFrame and debuffFrame and castingBarFrame then

			-- Adjust ccRemoverFrame anchor to account for the frame border
			local ccRemoverFrameXOffset = ccRemoverFrameInitialAnchor.xOffset + frameBorderOffset;
			ccRemoverFrame:ClearAllPoints();
			ccRemoverFrame:SetPoint(ccRemoverFrameInitialAnchor.point, memberUnitFrame, ccRemoverFrameInitialAnchor.relativePoint, ccRemoverFrameXOffset, ccRemoverFrameInitialAnchor.yOffset);

			-- AdjustTimeByDays debuff frame anchor to account for the frame border
			local debuffFrameXOffset = debuffFrameInitialAnchor.xOffset - frameBorderOffset;
			debuffFrame:ClearAllPoints();
			debuffFrame:SetPoint(debuffFrameInitialAnchor.point, memberUnitFrame, debuffFrameInitialAnchor.relativePoint, debuffFrameXOffset, debuffFrameInitialAnchor.yOffset);

			-- Adjust frame width to fit various frames
			-- Only need to adjust if this is the first frame since all subsequent frames will be the same size/layout
			local isFirstMemberFrame = i == 1;
			if isFirstMemberFrame then
				local ccRemoverWidth = ccRemoverFrame:GetWidth() + math.abs(ccRemoverFrameXOffset) - frameBorderOffset;
				local debuffFrameWidth = debuffFrame:GetWidth() + math.abs(debuffFrameXOffset) - frameBorderOffset;
				local castingBarXOffset = math.abs(select(4, castingBarFrame:GetPoint(1)));
				local castingBarFrameWidth = castingBarFrame:GetWidth() + castingBarFrame.BorderShield:GetWidth() + castingBarXOffset;

				width = width + ccRemoverWidth + debuffFrameWidth + castingBarFrameWidth;
				unitFrameXOffset = unitFrameXOffset - ccRemoverWidth;
			end
		end
	end
	firstMemberUnitFrame:ClearAllPoints();
	firstMemberUnitFrame:SetPoint("TOPRIGHT", self, "TOPRIGHT", unitFrameXOffset, -14);
	self:SetSize(width, height);

	UIParent_ManageFramePositions();
end

function CompactArenaFrameMixin:UpdateVisibility()
	self:SetShown(IsInArena() or EditModeManagerFrame:GetNumArenaFramesForcedShown() > 0);
end

function CompactArenaFrameMixin:RefreshMembers()
	-- Add player units
	local numEditModeForcedShownArenaFrames = EditModeManagerFrame:GetNumArenaFramesForcedShown();
	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		memberUnitFrame.unitIndex = i;
		memberUnitFrame.unitToken = GetUnitToken(memberUnitFrame.unitIndex);
		local usePlayerOverride = i <= numEditModeForcedShownArenaFrames and not ArenaUtil.UnitExists(memberUnitFrame.unitToken);
		memberUnitFrame.unitToken = usePlayerOverride and "player" or memberUnitFrame.unitToken;

		CompactUnitFrame_SetUnit(memberUnitFrame, memberUnitFrame.unitToken);
		CompactUnitFrame_SetUpFrame(memberUnitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(memberUnitFrame, "ARENA_OPPONENT_UPDATE");

		if memberUnitFrame.CastingBarFrame then
			local showTradeSkillsNo, showShieldYes = false, true;
			memberUnitFrame.CastingBarFrame:SetUnit(memberUnitFrame.unitToken, showTradeSkillsNo, showShieldYes);
		end

		if memberUnitFrame.CcRemoverFrame then
			memberUnitFrame.CcRemoverFrame:SetUnit(memberUnitFrame.unitToken);
		end

		if memberUnitFrame.DebuffFrame then
			memberUnitFrame.DebuffFrame:SetUnit(memberUnitFrame.unitToken);
		end

		local stealthedUnitFrame = self.stealthedUnitFrames and self.stealthedUnitFrames[i];
		if stealthedUnitFrame then
			stealthedUnitFrame:SetUnitFrame(memberUnitFrame);
		end
	end

	-- Add pet units if we're set to display pets
	-- Pets should always appear at the bottom under the real players
	-- Pets order should match the units order
	for i, petUnitFrame in ipairs(self.petUnitFrames) do
		local petUnitToken = CompactRaidFrameContainer.pvpDisplayPets and GetPetUnitToken(i) or nil;

		CompactUnitFrame_SetUpFrame(petUnitFrame, DefaultCompactMiniFrameSetup);
		CompactUnitFrame_SetUnit(petUnitFrame, petUnitToken);
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "ARENA_OPPONENT_UPDATE");
		CompactUnitFrame_SetUpdateAllEvent(petUnitFrame, "UNIT_PET");
	end

	self:UpdateLayout();
	self:UpdateVisibility();
	self.PreMatchFramesContainer:UpdateUnitFrames();
end

ArenaPreMatchFramesContainerMixin = {};

function ArenaPreMatchFramesContainerMixin:OnLoad()
	-- Create pre-match unit frame
	local memberUnitFrames = CompactArenaFrame.memberUnitFrames;
	for i, memberUnitFrame in ipairs(memberUnitFrames) do
		local preMatchFrame = CreateFrame("Frame", nil, self, "PreMatchArenaUnitFrameTemplate");
		self["PreMatchFrame"..i] = preMatchFrame;
		preMatchFrame:SetPoint("TOPLEFT", memberUnitFrame, "TOPLEFT");
		preMatchFrame:SetPoint("BOTTOMRIGHT", memberUnitFrame, "BOTTOMRIGHT");
	end

	CVarCallbackRegistry:RegisterCallback(useClassColorsCvarName, self.OnUseClassColorsChanged, self);

	self:UpdateUnitFrames();
end

function ArenaPreMatchFramesContainerMixin:OnUseClassColorsChanged()
	self:UpdateUnitFrames();
end

function ArenaPreMatchFramesContainerMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function ArenaPreMatchFramesContainerMixin:UpdateShownState()
	self:SetShown(IsInArena() and not IsMatchEngaged() and not self.isInEditMode);
end

function ArenaPreMatchFramesContainerMixin:UpdateUnitFrames()
	-- update pre match unit frames
	for i, preMatchUnitFrame in ipairs(self.preMatchUnitFrames) do
		preMatchUnitFrame:Update(i);
	end

	self:UpdateShownState();
end

PreMatchArenaUnitFrameMixin = {};

function PreMatchArenaUnitFrameMixin:Update(index)
	local specID, gender = GetArenaOpponentSpec(index);
	if specID and specID > 0 then
		local _, specName, _, specIcon, role, class, className = GetSpecializationInfoByID(specID, gender);

		self.SpecNameText:SetText(specName);
		self.ClassNameText:SetText(className);

		SetPortraitToTexture(self.SpecPortraitTexture, specIcon);
		SetRoleIconTexture(self.RoleIconTexture , role);
		SetFrameBarColor(self.BarTexture, class);

		self:Show();
	else
		self:Hide();
	end
end

ArenaUnitFrameCcRemoverMixin = {};

local ccRemoverAlwaysEvents =
{
	"ARENA_CROWD_CONTROL_SPELL_UPDATE"
};

local ccRemoverShownEvents =
{
	"ARENA_COOLDOWNS_UPDATE"
};

function ArenaUnitFrameCcRemoverMixin:OnEvent(event, ...)
	if event == "ARENA_COOLDOWNS_UPDATE" then
		self:UpdateCooldown();
	elseif event == "ARENA_CROWD_CONTROL_SPELL_UPDATE" then
		local unitToken, spellId = ...;
		self:SetSpellId(spellId);
		self:UpdateCooldown();
	end
end

function ArenaUnitFrameCcRemoverMixin:OnShow()
	if self.unitToken then
		FrameUtil.RegisterFrameForUnitEvents(self, ccRemoverShownEvents, self.unitToken);
	end

	self:UpdateCooldown();
end

function ArenaUnitFrameCcRemoverMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ccRemoverShownEvents);
end

function ArenaUnitFrameCcRemoverMixin:UpdateCooldown()
	local spellId, startTimeMs, durationMs = C_PvP.GetArenaCrowdControlInfo(self.unitToken);
	if spellId and startTimeMs > 0 and durationMs > 0 then
		self.Cooldown:SetCooldown(startTimeMs / 1000.0, durationMs / 1000.0);
	else
		self.Cooldown:Clear();
	end

	self.Cooldown:UpdateText();
end

function ArenaUnitFrameCcRemoverMixin:SetSpellId(spellId)
	local newSpellId = (spellId and spellId > 0) and spellId or nil;
	if self.spellId == newSpellId then
		return;
	end

	local texture = select(3, GetSpellInfo(newSpellId)) or QUESTION_MARK_ICON;
	self.Icon:SetTexture(texture);
	self.spellId = newSpellId;
	self:UpdateShownState();
end

function ArenaUnitFrameCcRemoverMixin:SetUnit(unitToken)
	self.unitToken = unitToken;

	FrameUtil.UnregisterFrameForEvents(self, ccRemoverAlwaysEvents);
	FrameUtil.UnregisterFrameForEvents(self, ccRemoverShownEvents);

	if self.unitToken then
		FrameUtil.RegisterFrameForUnitEvents(self, ccRemoverAlwaysEvents, self.unitToken);
		if self:IsShown() then
			FrameUtil.RegisterFrameForUnitEvents(self, ccRemoverShownEvents, self.unitToken);
		end
	end

	if ArenaUtil.UnitExists(self.unitToken) then
		C_PvP.RequestCrowdControlSpell(self.unitToken);
	else
		self:SetSpellId(nil);
		self:UpdateCooldown();
	end
end

function ArenaUnitFrameCcRemoverMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function ArenaUnitFrameCcRemoverMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self.spellId);
end

ArenaUnitFrameCooldownMixin = {};

local cooldownTextFormatter = CreateFromMixins(SecondsFormatterMixin);
cooldownTextFormatter:Init(1, SecondsFormatter.Abbreviation.OneLetter, true, true);
cooldownTextFormatter:SetDesiredUnitCount(1);
cooldownTextFormatter:SetStripIntervalWhitespace(true);

function ArenaUnitFrameCooldownMixin:OnHide()
	self:StopUpdateTextTicker();
	self.Text:SetText("");
end

function ArenaUnitFrameCooldownMixin:OnCooldownDone()
	self:StopUpdateTextTicker();
	self.Text:SetText("");
end

function ArenaUnitFrameCooldownMixin:UpdateText()
	local startTimeMs, durationMs = self:GetCooldownTimes();
	local currentTimeSeconds = GetTime();
	local remainingTimeSeconds = (durationMs / 1000.0) - (currentTimeSeconds - (startTimeMs / 1000.0))

	if remainingTimeSeconds > 0 then
		self.Text:SetText(cooldownTextFormatter:Format(remainingTimeSeconds));

		if not self.updateTextTicker and self:IsShown() then
			self.updateTextTicker = C_Timer.NewTicker(1, function() self:UpdateText() end);
		end
	else
		self:StopUpdateTextTicker();
		self.Text:SetText("");
	end
end

function ArenaUnitFrameCooldownMixin:StopUpdateTextTicker()
	if not self.updateTextTicker then
		return;
	end

	self.updateTextTicker:Cancel();
	self.updateTextTicker = nil;
end

ArenaUnitFrameDebuffMixin = {};

local arenaUnitFrameDebuffEvents = {
	"LOSS_OF_CONTROL_UPDATE",
	"LOSS_OF_CONTROL_ADDED",
};

function ArenaUnitFrameDebuffMixin:OnEvent(event, ...)
	if event == "LOSS_OF_CONTROL_UPDATE" then
		self:Update();
	elseif event == "LOSS_OF_CONTROL_ADDED" then
		self:Update();
	end
end

function ArenaUnitFrameDebuffMixin:OnEnter()
	if not self.shownData or not self.shownData.auraInstanceID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
	self:UpdateTooltip();
end

function ArenaUnitFrameDebuffMixin:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide();
	end
end

function ArenaUnitFrameDebuffMixin:UpdateTooltip()
	if not GameTooltip:IsOwned(self) then
		return;
	end

	GameTooltip:SetUnitDebuffByAuraInstanceID(self.unitToken, self.shownData.auraInstanceID, nil);
end

function ArenaUnitFrameDebuffMixin:SetUnit(unitToken)
	if unitToken == self.unitToken then
		return;
	end

	FrameUtil.UnregisterFrameForEvents(self, arenaUnitFrameDebuffEvents);

	self.unitToken = unitToken;
	if self.unitToken then
		FrameUtil.RegisterFrameForUnitEvents(self, arenaUnitFrameDebuffEvents, self.unitToken);
	end

	self:Update();
end

function ArenaUnitFrameDebuffMixin:Update()
	local highestPriorityData;
	if ArenaUtil.UnitExists(self.unitToken) then
		local numLossOfControlEffects = C_LossOfControl.GetActiveLossOfControlDataCountByUnit(self.unitToken) or 0;
		for i = 1, numLossOfControlEffects do
			local data = C_LossOfControl.GetActiveLossOfControlDataByUnit(self.unitToken, i);
			if data then
				if not highestPriorityData or data.priority > highestPriorityData.priority then
					highestPriorityData = data;
				end
			end
		end
	end

	self.shownData = highestPriorityData;

	local unitFrame = self:GetParent();
	CompactUnitFrame_ClearBlockedAuraInstanceIDs(unitFrame, self);
	if self.shownData then
		CompactUnitFrame_AddBlockedAuraInstanceID(unitFrame, self, self.shownData.auraInstanceID);
	end
	CompactUnitFrame_UpdateAuras(unitFrame);

	self:UpdateIcon();
	self:UpdateCooldown();
	self:UpdateShownState();
	self:UpdateTooltip();
end

function ArenaUnitFrameDebuffMixin:UpdateIcon()
	local texture = self.shownData and select(3, GetSpellInfo(self.shownData.spellID)) or QUESTION_MARK_ICON;
	self.Icon:SetTexture(texture);
end

function ArenaUnitFrameDebuffMixin:UpdateCooldown()
	local startTimeSeconds = self.shownData and self.shownData.startTime or 0;
	local durationSeconds = self.shownData and self.shownData.duration or 0;
	if startTimeSeconds > 0 and durationSeconds > 0 then
		self.Cooldown:SetCooldown(startTimeSeconds, durationSeconds);
	else
		self.Cooldown:Clear();
	end

	self.Cooldown:UpdateText();
end

function ArenaUnitFrameDebuffMixin:SetIsInEditMode(isInEditMode)
	self.isInEditMode = isInEditMode;
	self:UpdateShownState();
end

function ArenaUnitFrameDebuffMixin:UpdateShownState()
	self:SetShown(self.shownData or self.isInEditMode)
end

StealthedArenaUnitFrameMixin = {};

function StealthedArenaUnitFrameMixin:SetUnitFrame(unitFrame)
	if self.unitFrame then
		CompactUnitFrame_UnsubscribeToVisibilityChanged(self.unitFrame, self);
	end

	self.unitFrame = unitFrame;

	if not self:HasValidUnitFrame() then
		self:Hide();
		return;
	end

	CompactUnitFrame_SubscribeToVisibilityChanged(self.unitFrame, self, self.UpdateShownState);

	local unitClassInfo = self:GetUnitClassInfo();
	SetRoleIconTexture(self.RoleIconTexture , unitClassInfo.role);
	SetFrameBarColor(self.BarTexture, unitClassInfo.class);
	self:UpdateName(unitClassInfo);
	self:UpdateShownState();
end

function StealthedArenaUnitFrameMixin:HasValidUnitFrame()
	return self.unitFrame and self.unitFrame.unitToken and self.unitFrame.unitIndex;
end

function StealthedArenaUnitFrameMixin:GetUnitClassInfo()
	local unitClassInfo = {
		role = nil;
		class = nil;
		specName = nil;
		className = nil,
	};
	if self.unitFrame and self.unitFrame.unitIndex then
		local specID, gender = GetArenaOpponentSpec(self.unitFrame.unitIndex);
		if specID and specID > 0 then
			_, unitClassInfo.specName, _, _, unitClassInfo.role, unitClassInfo.class, unitClassInfo.className = GetSpecializationInfoByID(specID, gender);
		end
	end

	return unitClassInfo;
end

function StealthedArenaUnitFrameMixin:UpdateName(unitClassInfo)
	local name;
	if self.unitFrame and self.unitFrame.unitToken then
		name = GetUnitName(self.unitFrame.unitToken);
	end
	self.NameText:SetText(name or unitClassInfo.specName or unitClassInfo.className or "");
end

function StealthedArenaUnitFrameMixin:UpdateShownState()
	if not self:HasValidUnitFrame() or self.unitFrame:IsShown() then
		self:Hide();
		return;
	end

	local isInEditMode = EditModeManagerFrame:IsEditModeActive();
	local isInActiveArena = IsInArena() and IsMatchEngaged();
	local shouldUnitExist = self.unitFrame.unitIndex <= GetArenaSize();

	self:SetShown(not isInEditMode and isInActiveArena and shouldUnitExist);
end