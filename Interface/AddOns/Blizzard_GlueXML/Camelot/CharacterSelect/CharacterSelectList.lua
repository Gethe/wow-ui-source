
CHARACTER_LIST_X_OFFSET = 3;
CHARACTER_LIST_Y_OFFSET = -9;

local function GetCurrentSuperDistrictTitle()
	local superDistrictID = C_Login.GetSelectedSuperDistrictID();
	local superDistrictInfo = C_DistrictUtils.GetSuperDistrictInfo(superDistrictID);
	if not superDistrictInfo then
		return UNKNOWN;
	end

	return superDistrictInfo.displayName;
end

local function EnsureSuperdistrictText(self)
	if not self.SuperdistrictText then
		local superdistrictText = self:CreateFontString(nil, "BACKGROUND", "GlueFontNormalLarge");
		superdistrictText:SetSize(350, 20);
		superdistrictText:SetPoint("TOP", 0, -40);
		self.SuperdistrictText = superdistrictText;
	end
end

local CharacterSelectListMixinOnShow = CharacterSelectListMixin.OnShow;
function CharacterSelectListMixin:OnShow()
	CharacterSelectListMixinOnShow(self);

	EnsureSuperdistrictText(self);

	self.SuperdistrictText:SetText(GetCurrentSuperDistrictTitle());
end

function CharacterSelectListMixin:AdjustElements()
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", self:GetParent().VASTokenContainer, "BOTTOMRIGHT", CHARACTER_LIST_X_OFFSET, CHARACTER_LIST_Y_OFFSET);
	self:SetPoint("BOTTOMRIGHT", self:GetParent().ListToggle, "TOPRIGHT", 0, 10);

	self.SearchBox:ClearAllPoints();
	self.SearchBox:SetPoint("TOPLEFT", 13, -5);
	self.SearchBox:SetWidth(358);
end

function CharacterSelectCreateCharacterButtonMixin:OnEnter()
	-- No realm tooltip displayed; we are realmless
end
