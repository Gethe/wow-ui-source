local ccRemoverFrameInitialAnchor =
{
	point = "TOPLEFT";
	relativePoint = "TOPRIGHT";
	xOffset = 2;
	yOffset = -1;
}

local castingBarFrameInitialAnchor =
{
	point = "TOPRIGHT";
	relativePoint = "TOPLEFT";
	xOffset = -10;
	yOffset = -5;
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
	return C_PvP.IsMatchActive() or C_PvP.IsMatchComplete();
end

local function GetUnitToken(unitIndex)
	return "arena"..unitIndex;
end

local function GetPetUnitToken(unitIndex)
	return "arenapet"..unitIndex;
end

local function GetUnitRoleFromIndex(unitIndex)
	local unitSpecID, unitGender = GetArenaOpponentSpec(unitIndex);
	if unitSpecID ~= nil and unitGender ~= nil then
		local unitRole = select(5, GetSpecializationInfoByID(unitSpecID, unitGender));
		if unitRole then
			return unitRole;
		end
	end

	local unitToken = GetUnitToken(unitIndex);
	return UnitGroupRolesAssigned(unitToken);
end

-- Sort healers to front and then just follow unit index
local roleValues = { HEALER = 1, TANK = 2, DAMAGER = 3, NONE = 4 };
local function ArenaUnitFrameSort(unit1Index, unit2Index)
	local unit1Role = GetUnitRoleFromIndex(unit1Index);
	local unit1RoleValue = roleValues[unit1Role] or roleValues.NONE;

	local unit2Role = GetUnitRoleFromIndex(unit2Index);
	local unit2RoleValue = roleValues[unit2Role] or roleValues.NONE;

	if unit1RoleValue ~= unit2RoleValue then
		return unit1RoleValue < unit2RoleValue;
	end

	return unit1Index < unit2Index;
end

function CompactArenaFrame_Generate()
	local frame = CompactArenaFrame;
	local didCreate = false;
	if not frame then
		frame = CreateFrame("Frame", "CompactArenaFrame", UIParent, "CompactArenaFrameTemplate");
		frame:RegisterEvent("ARENA_OPPONENT_UPDATE");
		frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");
		frame.flowSortFunc = ArenaUnitFrameSort;
		didCreate = true;
	end
	return frame, didCreate;
end

CompactArenaFrameMixin = CreateFromMixins(CompactPartyFrameMixin);

function CompactArenaFrameMixin:OnLoad()
	CompactPartyFrameMixin.OnLoad(self);
	self.updateLayoutFunc = self.UpdateLayout;

	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		-- Create casting bars
		local castingBarFrame = CreateFrame("StatusBar", nil, memberUnitFrame, "ArenaUnitFrameCastingBarTemplate");
		memberUnitFrame.CastingBarFrame = castingBarFrame;
		castingBarFrame:SetPoint(castingBarFrameInitialAnchor.point, memberUnitFrame, castingBarFrameInitialAnchor.relativePoint, castingBarFrameInitialAnchor.xOffset, castingBarFrameInitialAnchor.yOffset);

		-- Create CcRemover frames
		local ccRemoverFrame = CreateFrame("Frame", nil, memberUnitFrame, "ArenaUnitFrameCcRemoverTemplate");
		memberUnitFrame.CcRemoverFrame = ccRemoverFrame;
		ccRemoverFrame:SetPoint(ccRemoverFrameInitialAnchor.point, memberUnitFrame, ccRemoverFrameInitialAnchor.relativePoint, ccRemoverFrameInitialAnchor.xOffset, ccRemoverFrameInitialAnchor.yOffset);
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
		local isFirstMemberFrame = i == 1;

		-- Adjust for CcRemoverFrames
		local ccRemoverFrame = memberUnitFrame.CcRemoverFrame;
		if ccRemoverFrame then
			-- Adjust ccRemoverFrame anchor to account for the frame border
			local ccRemoverFrameXOffset = ccRemoverFrameInitialAnchor.xOffset + frameBorderOffset;
			ccRemoverFrame:ClearAllPoints();
			ccRemoverFrame:SetPoint(ccRemoverFrameInitialAnchor.point, memberUnitFrame, ccRemoverFrameInitialAnchor.relativePoint, ccRemoverFrameXOffset, ccRemoverFrameInitialAnchor.yOffset);

			-- Adjust frame width to fit ccRemoverFrame
			-- Also adjust unit frame x offset to fit ccRemoverFrame since it's on the right side of the frame
			if isFirstMemberFrame then
				local ccRemoverWidth = ccRemoverFrame:GetWidth();

				-- Undo frameBorderOffset from the ccRemoverFrame's x offset since it's already accounted for on the unit frame
				ccRemoverWidth = ccRemoverWidth + ccRemoverFrameXOffset - frameBorderOffset;

				width = width + ccRemoverWidth;
				unitFrameXOffset = unitFrameXOffset - ccRemoverWidth;
			end
		end

		-- Adjust for CastingBarFrames
		local castingBarFrame = memberUnitFrame.CastingBarFrame;
		if castingBarFrame then
			-- Adjust casting bar anchor to account for the frame border
			local castingBarFrameXOffset = castingBarFrameInitialAnchor.xOffset - frameBorderOffset;
			castingBarFrame:ClearAllPoints();
			castingBarFrame:SetPoint(castingBarFrameInitialAnchor.point, memberUnitFrame, castingBarFrameInitialAnchor.relativePoint, castingBarFrameXOffset, castingBarFrameInitialAnchor.yOffset);

			-- Adjust frame width to fit casting bar
			if isFirstMemberFrame then
				local castingBarFrameWidth = (castingBarFrame:GetWidth() + castingBarFrame.BorderShield:GetWidth()) * castingBarFrame:GetScale();

				-- Undo frameBorderOffset from the castingBarFrame's x offset since it's already accounted for on the unit frame
				castingBarFrameWidth = castingBarFrameWidth - castingBarFrameXOffset - frameBorderOffset;

				width = width + castingBarFrameWidth;
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
	local unitIndices = {};
	for i = 1, #self.memberUnitFrames do
		table.insert(unitIndices, i);
	end
	table.sort(unitIndices, ArenaUnitFrameSort);

	local numEditModeForcedShownArenaFrames = EditModeManagerFrame:GetNumArenaFramesForcedShown();
	for i, memberUnitFrame in ipairs(self.memberUnitFrames) do
		local unitIndex = unitIndices[i];
		local unitToken = GetUnitToken(unitIndex);
		local usePlayerOverride = i <= numEditModeForcedShownArenaFrames and not UnitExists(unitToken);
		unitToken = usePlayerOverride and "player" or unitToken;

		CompactUnitFrame_SetUnit(memberUnitFrame, unitToken);
		CompactUnitFrame_SetUpFrame(memberUnitFrame, DefaultCompactUnitFrameSetup);
		CompactUnitFrame_SetUpdateAllEvent(memberUnitFrame, "ARENA_OPPONENT_UPDATE");

		if memberUnitFrame.CastingBarFrame then
			local showTradeSkillsNo, showShieldYes = false, true;
			memberUnitFrame.CastingBarFrame:SetUnit(unitToken, showTradeSkillsNo, showShieldYes);
		end

		if memberUnitFrame.CcRemoverFrame then
			memberUnitFrame.CcRemoverFrame:SetUnit(unitToken);
		end
	end

	-- Add pet units if we're set to display pets
	-- Pets should always appear at the bottom under the real players
	-- Pets order should match the units order
	for i, petUnitFrame in ipairs(self.petUnitFrames) do
		local petUnitIndex = unitIndices[i];
		local petUnitToken = CompactRaidFrameContainer.pvpDisplayPets and GetPetUnitToken(petUnitIndex) or nil;

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
		local preMatchFrame = CreateFrame("Frame", nil, self, "ArenaUnitFramePreMatchTemplate");
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
	local useClassColors = GetUseClassColors();

	-- Sort units
	local unitIndices = {};
	for i = 1, #self.preMatchUnitFrames do
		table.insert(unitIndices, i);
	end
	table.sort(unitIndices, ArenaUnitFrameSort);

	-- update pre match unit frames
	for i, preMatchUnitFrame in ipairs(self.preMatchUnitFrames) do
		preMatchUnitFrame:Update(unitIndices[i], useClassColors);
	end

	self:UpdateShownState();
end

ArenaUnitFramePreMatchMixin = {};

function ArenaUnitFramePreMatchMixin:Update(index, useClassColors)
	local specID, gender = GetArenaOpponentSpec(index);
	if specID and specID > 0 then
		local _, specName, _, specIcon, role, class, className = GetSpecializationInfoByID(specID, gender);

		self.SpecNameText:SetText(specName);
		self.ClassNameText:SetText(className);

		SetPortraitToTexture(self.SpecPortraitTexture, specIcon);

		if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
			self.RoleIconTexture:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
			self.RoleIconTexture:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
			self.RoleIconTexture:Show();
			self.RoleIconTexture:SetSize(12, 12);
		else
			self.RoleIconTexture:Hide();
			self.RoleIconTexture:SetSize(1, 12);
		end

		local r, g, b = 1.0, 0.0, 0.0;
		if useClassColors then
			local classColor = RAID_CLASS_COLORS[class];
			r, g, b = classColor.r, classColor.g, classColor.b;
		end
		self.BarTexture:SetVertexColor(r, g, b);

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
	if spellId and startTimeMs ~= 0 and durationMs ~= 0 then
		self.Cooldown:SetCooldown(startTimeMs / 1000.0, durationMs / 1000.0);
	else
		self.Cooldown:Clear();
	end

	self.Cooldown:UpdateCountdownText();
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

	if UnitExists(self.unitToken) then
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

ArenaUnitCcRemoverCooldownMixin = {};

local ArenaUnitCcRemoverCooldownTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
ArenaUnitCcRemoverCooldownTimeFormatter:Init(1, SecondsFormatter.Abbreviation.OneLetter, true, true);
ArenaUnitCcRemoverCooldownTimeFormatter:SetDesiredUnitCount(1);
ArenaUnitCcRemoverCooldownTimeFormatter:SetStripIntervalWhitespace(true);

function ArenaUnitCcRemoverCooldownMixin:OnHide()
	self:StopCountdownTextTicker();
	self.CountdownText:SetText("");
end

function ArenaUnitCcRemoverCooldownMixin:OnCooldownDone()
	self:StopCountdownTextTicker();
	self.CountdownText:SetText("");
end

function ArenaUnitCcRemoverCooldownMixin:UpdateCountdownText()
	local startTimeMs, durationMs = self:GetCooldownTimes();
	local currentTimeSeconds = GetTime();
	local remainingTimeSeconds = (durationMs / 1000.0) - (currentTimeSeconds - (startTimeMs / 1000.0))

	if remainingTimeSeconds > 0 then
		self.CountdownText:SetText(ArenaUnitCcRemoverCooldownTimeFormatter:Format(remainingTimeSeconds));

		if not self.countdownTextUpdateTicker and self:IsShown() then
			self.countdownTextUpdateTicker = C_Timer.NewTicker(1, function() self:UpdateCountdownText() end);
		end
	else
		self:StopCountdownTextTicker();
		self.CountdownText:SetText("");
	end
end

function ArenaUnitCcRemoverCooldownMixin:StopCountdownTextTicker()
	if not self.countdownTextUpdateTicker then
		return;
	end

	self.countdownTextUpdateTicker:Cancel();
	self.countdownTextUpdateTicker = nil;
end