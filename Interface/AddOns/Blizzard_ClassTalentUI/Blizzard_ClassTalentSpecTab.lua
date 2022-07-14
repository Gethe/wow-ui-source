
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
}

ClassTalentSpecTabMixin={}

local ClassTalentSpecTabUnitEvents = {
	"UNIT_LEVEL",
	"PLAYER_SPECIALIZATION_CHANGED",
};

function ClassTalentSpecTabMixin:OnLoad()
	self.SpecContentFramePool = CreateFramePool("FRAME", self, "ClassSpecContentFrameTemplate");

	self:UpdateSpecContents();
	self:UpdateSpecFrame();
end

function ClassTalentSpecTabMixin:OnShow()
	FrameUtil.RegisterFrameForUnitEvents(self, ClassTalentSpecTabUnitEvents, "player");
	self:UpdateSpecContents();
	self:UpdateSpecFrame();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function ClassTalentSpecTabMixin:UpdateSpecFrame()
	if not C_SpecializationInfo.IsInitialized() then
		return;
	end

	local talentGroup = 1;
	local playerTalentSpec = GetSpecialization(nil, false, talentGroup);
	local numSpecs = GetNumSpecializations(nil, false);
	local sex = UnitSex("player");

	for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
		-- selected spec highlight
		if specContentFrame.specIndex == playerTalentSpec then
			specContentFrame:UpdateSelectionGlow(true, numSpecs);
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

function ClassTalentSpecTabMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ClassTalentSpecTabUnitEvents);
	if self.playingBackgroundFlash then
		self:StopBackgroundFlash();
	end
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function ClassTalentSpecTabMixin:OnEvent(event, ...)
	if (event == "UNIT_LEVEL") or (event == "PLAYER_SPECIALIZATION_CHANGED") then
		self:UpdateSpecFrame();

		if event == "PLAYER_SPECIALIZATION_CHANGED" then
			self:PlayBackgroundFlash();
		end
	end
end

function ClassTalentSpecTabMixin:PlayBackgroundFlash()
	self.AnimationHolder.BackgroundFlashAnim:Restart();
	self.playingBackgroundFlash = true;
end

function ClassTalentSpecTabMixin:StopBackgroundFlash()
	self.BackgroundFlash:SetAlpha(0);
	self.AnimationHolder.BackgroundFlashAnim:Stop();
	self.playingBackgroundFlash = false;
end

ClassSpecContentFrameMixin={}

function ClassSpecContentFrameMixin:OnLoad()
	self.SpellButtonPool = CreateFramePool("BUTTON", self, "ClassSpecSpellTemplate");
end

function ClassSpecContentFrameMixin:Setup(index, sex, frameWidth, frameHeight, numSpecs)
	self:Show();
	self:SetWidth(frameWidth);
	self:SetHeight(frameHeight);
	self.layoutIndex = index;
	self.specIndex = index;

	local specID, name, description, icon, _, primaryStat = GetSpecializationInfo(index, false, false, nil, sex);

	if not specID then
		return;
	end
	local atlasName = SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[specID]);
	if C_Texture.GetAtlasInfo(atlasName) then
		self.SpecImage:SetAtlas(atlasName);
	end
	self.SpecName:SetText(name);
	if primaryStat and primaryStat ~= 0 then
		self.Description:SetText(description.."|n"..SPEC_FRAME_PRIMARY_STAT:format(SPEC_STAT_STRINGS[primaryStat]));
	end
	local role = GetSpecializationRole(index, false, false);
	self.RoleIcon:SetTexCoord(GetTexCoordsForRole(role));
	self.RoleName:SetText(_G[role]);

	-- set positions
	local length = (self.RoleIcon:GetWidth() + self.RoleName:GetWidth() + ROLE_ICON_TEXT_MARGIN)/2;
	local offset = self.RoleIcon:GetWidth()/2 - length;

	self.RoleIcon:ClearAllPoints();
	self.RoleIcon:SetPoint("TOP", self.SpecName, "BOTTOM", offset, -15);

	self.RoleName:ClearAllPoints();
	self.RoleName:SetPoint("LEFT", self.RoleIcon, "RIGHT", ROLE_ICON_TEXT_MARGIN, 0);

	-- highlights and columns
	self.SelectedBackgroundBack1:SetSize(frameWidth, frameHeight);
	self.SelectedBackgroundBack2:SetSize(frameWidth, frameHeight);
	self.SelectedBackgroundLeft1:SetHeight(frameHeight);
	self.SelectedBackgroundLeft2:SetHeight(frameHeight);
	self.SelectedBackgroundLeft3:SetHeight(frameHeight);
	self.SelectedBackgroundLeft4:SetHeight(frameHeight);
	self.SelectedBackgroundRight1:SetHeight(frameHeight);
	self.SelectedBackgroundRight2:SetHeight(frameHeight);
	self.SelectedBackgroundRight3:SetHeight(frameHeight);
	self.SelectedBackgroundRight4:SetHeight(frameHeight);
	if index == numSpecs then
		self.ColumnDivider:Hide();
	else
		self.ColumnDivider:Show();
	end

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

function ClassSpecContentFrameMixin:UpdateSelectionGlow(IsInGlowState, numSpecs)
	if IsInGlowState then
		self.ActivatedText:Show();
		self.ActivateButton:Hide();
		self.SpecImageBorderOn:Show();
		self.SpecImageBorderOff:Hide();
		self.SelectedBackgroundBack1:Show()
		self.SelectedBackgroundBack2:Show()
		if self.specIndex ~= 1 then
			self.SelectedBackgroundLeft1:Show()
			self.SelectedBackgroundLeft2:Show()
			self.SelectedBackgroundLeft3:Show()
			self.SelectedBackgroundLeft4:Show()
		end
		if self.specIndex ~= numSpecs then
			self.SelectedBackgroundRight1:Show()
			self.SelectedBackgroundRight2:Show()
			self.SelectedBackgroundRight3:Show()
			self.SelectedBackgroundRight4:Show()
		end
	else
		self.ActivatedText:Hide();
		self.ActivateButton:Show();
		self.SpecImageBorderOn:Hide();
		self.SpecImageBorderOff:Show();
		self.SelectedBackgroundBack1:Hide()
		self.SelectedBackgroundBack2:Hide()
		self.SelectedBackgroundLeft1:Hide()
		self.SelectedBackgroundLeft2:Hide()
		self.SelectedBackgroundLeft3:Hide()
		self.SelectedBackgroundLeft4:Hide()
		self.SelectedBackgroundRight1:Hide()
		self.SelectedBackgroundRight2:Hide()
		self.SelectedBackgroundRight3:Hide()
		self.SelectedBackgroundRight4:Hide()
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
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
end
