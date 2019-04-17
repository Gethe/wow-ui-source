PVPRowMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPRowMixin:Init(useAlternateColor)
	self.useAlternateColor = useAlternateColor;
end

function PVPRowMixin:Populate(rowData, dataIndex)
	local faction = rowData.faction;
	local color = PVPMatchUtil.GetRowColor(faction, self.useAlternateColor);
	local r, g, b = color:GetRGB();
	for k, background in pairs(self.Backgrounds) do
		background:SetVertexColor(r, g, b);
	end
end

PVPHeaderMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPHeaderMixin:Init(sortType, tooltipText)
	self.sortType = sortType;
	self.tooltipText = tooltipText;
end

function PVPHeaderMixin:OnClick()
	local sortType = self.sortType;
	if sortType then
        SortBattlefieldScoreData(sortType);
	end
	
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function PVPHeaderMixin:OnEnter()
	local tooltipText = self.tooltipText;
	if tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddColoredLine(GameTooltip, tooltipText, WHITE_FONT_COLOR, true);
		GameTooltip:Show();
	end
end

function PVPHeaderMixin:OnLeave()
	GameTooltip:Hide();
end

PVPHeaderIconMixin = CreateFromMixins(PVPHeaderMixin);

function PVPHeaderIconMixin:Init(textureFileID, sortType)
	PVPHeaderMixin.Init(self, sortType);
	self.textureFileID = textureFileID;

	local icon = self.icon;
	icon:SetTexture(self.textureFileID);
	self:SetSize(icon:GetSize());
end

PVPCellClassMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPCellClassMixin:Populate(rowData, dataIndex)
	local classToken = rowData.classToken;
	if classToken then
		local icon = self.icon;
		icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		local coords = CLASS_ICON_TCOORDS[classToken];
		icon:SetTexCoord(unpack(coords));
	end
end

function PVPCellClassMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local className = self.rowData.className or "";
	local talentSpec = self.rowData.talentSpec;
	if talentSpec then
		local tooltipText = format(TALENT_SPEC_AND_CLASS, talentSpec, className);
		GameTooltip_AddNormalLine(GameTooltip, tooltipText, true);
	else
		GameTooltip_AddNormalLine(GameTooltip, className, true);
	end
	GameTooltip:Show();
end

function PVPCellClassMixin:OnLeave()
	GameTooltip:Hide();
end

PVPCellHonorLevelMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPCellHonorLevelMixin:Populate(rowData, dataIndex)
	local honorLevel = rowData.honorLevel;
	if honorLevel then
		-- No info until level 5.
		local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
		if honorRewardInfo then
			self.icon:SetTexture(honorRewardInfo.badgeFileDataID or 0);
		end
	end
end

function PVPCellHonorLevelMixin:OnEnter()
	local honorLevel = self.rowData.honorLevel;
	if honorLevel then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, HONOR_LEVEL_TOOLTIP:format(honorLevel), true);
		GameTooltip:Show();
	end
end

function PVPCellHonorLevelMixin:OnLeave()
	GameTooltip:Hide();
end

PVPHeaderStringMixin = CreateFromMixins(PVPHeaderMixin);

function PVPHeaderStringMixin:Init(textID, textAlignment, sortType, tooltipText)
	PVPHeaderMixin.Init(self, sortType, tooltipText)
	self.textID = textID;

	local text = self.text;
	text:SetJustifyH(textAlignment);
	text:SetText(self.textID);
	local width = text:GetStringWidth();

	local maxColumnWidth = 80;
	local maxWidth = math.min(width, maxColumnWidth);
	text:SetWidth(maxWidth);
	self:SetWidth(maxWidth);
end

local function FormatCellColor(frame, rowData, useAlternateColor)
	local faction = rowData.faction;
	local guid = rowData.guid;
	local GetCellColor = function(useAlternateColor)
		if IsPlayerGuid(guid) then
			return WHITE_FONT_COLOR;
		else
			return PVPMatchUtil.GetCellColor(faction, useAlternateColor);
		end
	end;

	local color = GetCellColor(useAlternateColor);
	frame:SetVertexColor(color:GetRGB());
end

PVPCellStringMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPCellStringMixin:Init(dataProviderKey, useAlternateColor)
	self.dataProviderKey = dataProviderKey;
	self.useAlternateColor = useAlternateColor;
end
function PVPCellStringMixin:Populate(rowData, dataIndex)
	local value = rowData[self.dataProviderKey];
	local text = self.text;
	text:SetText(value);

	FormatCellColor(text, rowData, self.useAlternateColor);
end

PVPCellNameMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPCellNameMixin:Init(useAlternateColor)
	self.useAlternateColor = useAlternateColor;
	self.text:SetJustifyH("LEFT");
end

function PVPCellNameMixin:Populate(rowData, dataIndex)
	local name = rowData.name;
	local text = self.text;
	text:SetText(name);

	FormatCellColor(text, rowData, self.useAlternateColor);
end

function PVPCellNameMixin:OnEnter()
	local tooltipOffset = 0 - self.text:GetWidth();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", tooltipOffset, 0);
	
	local className = self.rowData.className or "";
	local raceName = self.rowData.raceName or "";
	GameTooltip_AddNormalLine(GameTooltip, self.rowData.name);
	GameTooltip_AddColoredLine(GameTooltip, raceName.." "..className, WHITE_FONT_COLOR, true);
	GameTooltip:Show();
end

function PVPCellNameMixin:OnLeave()
	GameTooltip:Hide();
end

function PVPCellNameMixin:OnClick(mouseButton)
-- 820FIXME IMPLEMENT NAME DROPDOWN
end

PVPCellStatMixin = CreateFromMixins(TableBuilderElementMixin);

function PVPCellStatMixin:Init(dataProviderKey, useAlternateColor)
	self.dataProviderKey = dataProviderKey;
	self.useAlternateColor = useAlternateColor;
end

function PVPCellStatMixin:Populate(rowData, dataIndex)
	local value = TableBuilderDataProviderUtil.TraverseToValue(rowData, self.dataProviderKey);
	if value then
		local icon = value.icon;
		local amount = value.value;
		local text = self.text;
		if not icon or icon == "" then
			text:SetText(amount);
		else
			local icon = string.gsub(icon, "\\", "/");
			local count = FLAG_COUNT_TEMPLATE:format(amount);
			local string = "|T"..icon..":16:16:0:-2|t"..count;
			text:SetText(string);
		end

		FormatCellColor(text, rowData, self.useAlternateColor);
	end
end

function ConstructPVPMatchTable(tableBuilder, isRatedBG, isArena, isLFD, useAlternateColor)
	local iconPadding = 2;
	local textPadding = 15;
	local categories = PVPMatchUtil.GetOptionalCategories(isRatedBG, isArena, isLFD);
	
	tableBuilder:Reset();
	tableBuilder:SetDataProvider(C_PvP.GetScoreInfo);
	tableBuilder:SetTableMargins(5);

	local column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderIconTemplate", [[Interface/PVPFrame/Icons/prestige-icon-3]]);
	column:ConstrainToHeader();
	column:ConstructCells("BUTTON", "PVPCellHonorLevelTemplate");

	column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderIconTemplate", [[Interface/PvPRankBadges/PvPRank06]], "class");
	column:ConstrainToHeader(iconPadding);
	column:ConstructCells("BUTTON", "PVPCellClassTemplate");

	column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", NAME, "LEFT", "name");
	local fillCoefficient = 1.0;
	local namePadding = 4;
	column:ConstructCells("BUTTON", "PVPCellNameTemplate", useAlternateColor);
	column:SetFillConstraints(fillCoefficient, namePadding);

	column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", SCORE_KILLING_BLOWS, "CENTER", "kills", KILLING_BLOW_TOOLTIP);
	column:ConstrainToHeader(textPadding);
	column:ConstructCells("BUTTON", "PVPCellStringTemplate", "killingBlows", useAlternateColor);

	if categories.honorableKills then
		column = tableBuilder:AddColumn();
		column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", SCORE_HONORABLE_KILLS, "CENTER", "hk", HONORABLE_KILLS_TOOLTIP);
		column:ConstrainToHeader(textPadding);
		column:ConstructCells("BUTTON", "PVPCellStringTemplate", "honorableKills", useAlternateColor);
	end
	 
	if categories.deaths then
		column = tableBuilder:AddColumn();
		column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", DEATHS, "CENTER", "deaths", DEATHS_TOOLTIP);
		column:ConstrainToHeader(textPadding);
		column:ConstructCells("BUTTON", "PVPCellStringTemplate", "deaths", useAlternateColor);
	end
	
	column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", SCORE_DAMAGE_DONE, "CENTER", "damage", DAMAGE_DONE_TOOLTIP);
	column:ConstrainToHeader(textPadding);
	column:ConstructCells("BUTTON", "PVPCellStringTemplate", "damageDone", useAlternateColor);

	column = tableBuilder:AddColumn();
	column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", SCORE_HEALING_DONE, "CENTER", "healing", HEALING_DONE_TOOLTIP);
	column:ConstrainToHeader(textPadding);
	column:ConstructCells("BUTTON", "PVPCellStringTemplate", "healingDone", useAlternateColor);

	if categories.rating then
		column = tableBuilder:AddColumn();
		column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", BATTLEGROUND_RATING, "CENTER", "bgRating", BATTLEGROUND_RATING);
		column:ConstrainToHeader(textPadding);
		column:ConstructCells("BUTTON", "PVPCellStringTemplate", "rating", useAlternateColor);
	end
	
	if categories.ratingChange then
		column = tableBuilder:AddColumn();
		column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", SCORE_RATING_CHANGE, "CENTER", "bgratingChange", RATING_CHANGE_TOOLTIP);
		column:ConstrainToHeader(textPadding);
		column:ConstructCells("BUTTON", "PVPCellStringTemplate", "ratingChange", useAlternateColor);
	end
	
	local mapStats = GetNumBattlefieldStats();
	for statIndex = 1, mapStats do
		local text, icon, tooltip = GetBattlefieldStatInfo(statIndex);
		column = tableBuilder:AddColumn();
		column:ConstructHeader("BUTTON", "PVPHeaderStringTemplate", text, "CENTER", "stat"..statIndex, tooltip);
		column:ConstrainToHeader(textPadding);
		column:ConstructCells("BUTTON", "PVPCellStatTemplate", "stats."..statIndex, useAlternateColor);
	end

	tableBuilder:Arrange();
end