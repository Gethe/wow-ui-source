ClassNameplateBarDeathKnight = Mixin({}, RuneFrameMixin);

function ClassNameplateBarDeathKnight:OnLoad()
	self.class = "DEATHKNIGHT";
	self.powerToken = "RUNES";

	RuneFrameMixin.OnLoad(self);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarDeathKnight:Setup()
	if self:MatchesClass() then
		self:RegisterEvent("RUNE_POWER_UPDATE");
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	return ClassNameplateBar.Setup(self);
end

function ClassNameplateBarDeathKnight:OnEvent(event, ...)
	if event == "RUNE_POWER_UPDATE" then
		self:UpdateRunes();
		return true;
	end
	if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
		self:UpdateRunes(true);
		return true;
	end

	return ClassNameplateBar.OnEvent(self, event, ...);
end

function ClassNameplateBarDeathKnightRuneButton_OnLoad(self)
	local size = 16;
	local function SetupRuneTexture(runeTexture)
		runeTexture:SetSize(size, size);
		runeTexture:SetTexelSnappingBias(0.0);
		runeTexture:SetSnapToPixelGrid(false);
	end

	SetupRuneTexture(self.EmptyRune);
	SetupRuneTexture(self.Rune);
	SetupRuneTexture(self.Rune2);
	SetupRuneTexture(self.EnergizeGlow);
end