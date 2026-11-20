
CHARACTER_LIST_X_OFFSET = 3;
CHARACTER_LIST_Y_OFFSET = -9;

local CHARACTER_LIST_CONTENT_Y_OFFSET = 63;

local function GetCurrentSuperDistrictTitle()
	local superDistrictID = C_Login.GetSelectedSuperDistrictID();
	local superDistrictInfo = C_DistrictUtils.GetSuperDistrictInfo(superDistrictID);
	if not superDistrictInfo then
		return "";
	end

	return superDistrictInfo.displayName;
end

local function EnsureSuperdistrictVisuals(self)
	if not self.SuperdistrictText then
		local superdistrictText = self:CreateFontString(nil, "BACKGROUND", "GlueFontNormalLarge");
		superdistrictText:SetSize(350, 20);
		superdistrictText:SetPoint("TOP", 0, -23.0);
		self.SuperdistrictText = superdistrictText;
	end

	if not self.SuperdistrictRulesetTexture then
		local superdistrictRulesetTexture = self:CreateTexture(nil, "BACKGROUND", nil, -1);
		superdistrictRulesetTexture:SetPoint("TOP", self.SuperdistrictText, "BOTTOM", 0, 43);
		self.SuperdistrictRulesetTexture = superdistrictRulesetTexture;
	end

	local atlas = C_GameRules.IsHardcoreActive() and "glues-characterSelect-ruleset-hardcore" or "glues-characterSelect-ruleset-generic";
	self.SuperdistrictRulesetTexture:SetAtlas(atlas, true);
end

local CharacterSelectListMixinOnShow = CharacterSelectListMixin.OnShow;
function CharacterSelectListMixin:OnShow()
	CharacterSelectListMixinOnShow(self);

	EnsureSuperdistrictVisuals(self);

	self.SuperdistrictText:SetText(GetCurrentSuperDistrictTitle());
end

function CharacterSelectListMixin:AdjustSearchBox()
	self.SearchBox:ClearAllPoints();
	self.SearchBox:SetPoint("TOPLEFT", 13, -5 - CHARACTER_LIST_CONTENT_Y_OFFSET);
	self.SearchBox:SetWidth(358);
end

function CharacterSelectListMixin:AdjustElements()
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", self:GetParent().VASTokenContainer, "BOTTOMRIGHT", CHARACTER_LIST_X_OFFSET, CHARACTER_LIST_Y_OFFSET);
	self:SetPoint("BOTTOMRIGHT", self:GetParent().ListToggle, "TOPRIGHT", 0, 10);

	self:AdjustSearchBox();

	self.ScrollBox:ClearAllPoints();
	self.ScrollBox:SetPoint("TOPLEFT", -115, -42 - CHARACTER_LIST_CONTENT_Y_OFFSET);
	self.ScrollBox:SetPoint("BOTTOMRIGHT", -32, 83);
end

function CharacterSelectCreateCharacterButtonMixin:OnEnter()
	-- No realm tooltip displayed; we are realmless
end
