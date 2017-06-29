
local TEMP_LAYOUT = {
	[1] = { tier = 1, links = { }, side = "none" },		-- maybe side should be a keyvalue on button
	[2] = { tier = 2, links = { 1 }, side = "light" },
	[3] = { tier = 2, links = { 1 }, side = "void" },
	[4] = { tier = 3, links = { 2 }, side = "light" },
	[5] = { tier = 3, links = { 2, 3 }, side = "both" },
	[6] = { tier = 3, links = { 3 }, side = "void" },
}

local PREVIEW_RELIC_SLOT = 4;

UIPanelWindows["ArtifactRelicForgeFrame"] =		{ area = "left",	pushable = 0, xoffset = 35, yoffset = -9, bottomClampOverride = 100, showFailedFunc = C_ArtifactUI.Clear, };

-- ===========================================================================================================================
ArtifactRelicForgeMixin = {};

function ArtifactRelicForgeMixin:OnLoad()
	self.Inset:SetPoint("TOPLEFT", 20, -170);
	self.Inset:SetPoint("BOTTOMRIGHT", -24, 26);

	-- customize talent buttons
	for i, talentButton in ipairs(self.Talents) do
		talentButton.Icon:SetSize(45, 45);
		talentButton.IconDesaturated:SetSize(45, 45);
		talentButton.CircleMask:SetSize(45, 45);
		talentButton.RankBorder:Hide();
	end
	-- links
	self.lines = { };
	for i, layout in ipairs(TEMP_LAYOUT) do
		for j, linkIndex in ipairs(layout.links) do
			self:LinkTalents(i, linkIndex, TEMP_LAYOUT[linkIndex].side);
		end
	end

	-- << temp
	self.TEMP_HELP:SetText(GREEN_FONT_COLOR:WrapTextInColorCode("Green").." : Base\n"..YELLOW_FONT_COLOR:WrapTextInColorCode("Yellow").." : Light\n"..RED_FONT_COLOR:WrapTextInColorCode("Red").." : Void\n")
	-- >> temp
	
	self:SetRelicSlot(1);
end

function ArtifactRelicForgeMixin:OnShow()
	self:RegisterEvent("ARTIFACT_RELIC_TALENT_ADDED");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	self:RefreshAll();
end

function ArtifactRelicForgeMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_RELIC_TALENT_ADDED");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");
	self:UnregisterEvent("ARTIFACT_RELIC_FORGE_CLOSE");
	C_ArtifactRelicForgeUI.Clear();
end

function ArtifactRelicForgeMixin:OnEvent(event, ...)
	if ( event == "ARTIFACT_RELIC_TALENT_ADDED" ) then
		self:RefreshTalents();	
	elseif ( event == "ARTIFACT_RELIC_FORGE_UPDATE" ) then
		self:RefreshAll();
	elseif ( event == "ARTIFACT_RELIC_FORGE_CLOSE" ) then
		HideUIPanel(self);
	end
end

function ArtifactRelicForgeMixin:SetRelicSlot(relicSlot)
	self.relicSlot = relicSlot
	self:RefreshAll();
end

function ArtifactRelicForgeMixin:LinkTalents(fromIndex, toIndex, side)
	local fromButton = self.Talents[fromIndex];
	local toButton = self.Talents[toIndex];

	local lineContainer = CreateFrame("FRAME", nil, self, "ArtifactDependencyLineTemplate");
	-- << temp
	if ( TEMP_LAYOUT[fromIndex].side == "light" ) then
		lineContainer:SetConnectedColor(YELLOW_FONT_COLOR);
	elseif ( TEMP_LAYOUT[fromIndex].side == "void" ) then
		lineContainer:SetConnectedColor(RED_FONT_COLOR);
	elseif ( TEMP_LAYOUT[fromIndex].side == "both" ) then
		if ( TEMP_LAYOUT[toIndex].side == "light" ) then
			lineContainer:SetConnectedColor(YELLOW_FONT_COLOR);
		elseif ( TEMP_LAYOUT[toIndex].side == "void" ) then
			lineContainer:SetConnectedColor(RED_FONT_COLOR);
		end
	end
	lineContainer:SetDisconnectedColor(GRAY_FONT_COLOR);
	-- >> temp

	local fromCenter = CreateVector2D(fromButton:GetCenter());
	fromCenter:ScaleBy(fromButton:GetEffectiveScale());

	local toCenter = CreateVector2D(toButton:GetCenter());
	toCenter:ScaleBy(toButton:GetEffectiveScale());

	toCenter:Subtract(fromCenter);

	lineContainer:CalculateTiling(toCenter:GetLength());

	lineContainer:SetEndPoints(fromButton, toButton);
	lineContainer:SetDisconnected();

	lineContainer.toButton = toButton;
	lineContainer.fromButton = fromButton;
	
	tinsert(self.lines, lineContainer);
end

function ArtifactRelicForgeMixin:RefreshAll()
	self.TitleContainer:EvaluateRelics();
	self:RefreshTalents();
	self:RefreshRelics();
	self.PreviewRelicFrame:Update();
end

function ArtifactRelicForgeMixin:RefreshRelics()
	-- << temp
	for i, relicSlotButton in ipairs(self.TitleContainer.RelicSlots) do
		if relicSlotButton:GetID() == self.relicSlot then
			local isAttuned, canAttune = C_ArtifactUI.GetRelicAttuneInfo(self.relicSlot)
			relicSlotButton.SelectionBox:Show();
			relicSlotButton.AttuneButton:SetShown(canAttune);
		else
			relicSlotButton.SelectionBox:Hide();
			relicSlotButton.AttuneButton:Hide();
		end
	end
	-- >> temp	
end

function ArtifactRelicForgeMixin:RefreshTalents()
	local talents;
	if ( self.relicSlot == PREVIEW_RELIC_SLOT ) then
		talents = C_ArtifactRelicForgeUI.GetPreviewRelicTalents();
	else
		talents = C_ArtifactRelicForgeUI.GetSocketedRelicTalents(self.relicSlot);
	end

	if ( not talents ) then
		for i, talentButton in ipairs(self.Talents) do
			talentButton:Hide();
		end
		return;
	end
	
	for index, talentInfo in ipairs(talents) do
		local talentButton = self.Talents[index];
		talentButton:Show();
		talentButton.powerID = talentInfo.powerID;
		talentButton.Icon:SetTexture(talentInfo.icon);
		talentButton.IconDesaturated:SetTexture(talentInfo.icon);
		talentButton.Icon:SetShown(talentInfo.canChoose or talentInfo.isChosen);
		talentButton.canChoose = true;
		-- << temp
		local vertexColor = CreateColor(1, 1, 1);
		local myLayoutInfo = TEMP_LAYOUT[index];
		if ( myLayoutInfo.side == "none" ) then
			vertexColor = CreateColor(0, 1, 0);
		elseif ( myLayoutInfo.side == "light" ) then
			vertexColor = CreateColor(1, 1, 0);
		elseif ( myLayoutInfo.side == "void" ) then
			vertexColor = CreateColor(1, 0, 0);
		else
			-- light or void?
			for _, linkIndex in ipairs(myLayoutInfo.links) do
				if ( talents[linkIndex].isChosen ) then
					if ( TEMP_LAYOUT[linkIndex].side == "light" ) then
						vertexColor = CreateColor(1, 1, 0);
					else
						vertexColor = CreateColor(1, 0, 0);
					end
					break;
				end
			end
		end

		if talentInfo.isChosen then
			talentButton.IconBorder:SetAtlas("Artifacts-PerkRing-MainProc", true);
			talentButton.IconBorder:SetVertexColor(vertexColor:GetRGB());
		else
			talentButton.IconBorder:SetAtlas("Artifacts-PerkRing-Small", true);	
			talentButton.IconBorder:SetVertexColor(1, 1, 1);
		end
		if ( talentInfo.canChoose ) then
			talentButton.YellowRing:SetAlpha(0.5);
			talentButton.YellowRing:SetVertexColor(vertexColor:GetRGB());
			talentButton.WaitingAnimation:Play();
		else
			talentButton.YellowRing:SetAlpha(0);
			talentButton.WaitingAnimation:Stop();
		end
		-- >> temp
	end
	
	-- << temp
	for i, line in ipairs(self.lines) do
		if ( (line.fromButton.canChoose or line.fromButton.isChosen) and line.toButton.isChosen ) then
			line:SetConnected();
		else
			line:SetDisconnected();
		end
	end
	-- >> temp
end

function ArtifactRelicForgeMixin:ChooseTalent(index)
	C_ArtifactRelicForgeUI.AddRelicTalent(self.relicSlot, index);
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseEnter()
end

function ArtifactRelicForgeMixin:OnRelicSlotMouseLeave()
end

--========================================================================================================================
ArtifactRelicForgeTitleTemplateMixin = CreateFromMixins(ArtifactTitleTemplateMixin);

function ArtifactRelicForgeTitleTemplateMixin:RefreshTitle()
end

function ArtifactRelicForgeTitleTemplateMixin:OnRelicSlotClicked(relicSlot)
	self:GetParent():SetRelicSlot(relicSlot:GetID());
end

function ArtifactRelicForgeTitleTemplateMixin:Foo(relicSlot)
	C_ArtifactRelicForgeUI.AttuneSocketedRelic(relicSlot);
end

--========================================================================================================================
ArtifactRelicTalentButtonMixin = CreateFromMixins(ArtifactPowerButtonMixin);

function ArtifactRelicTalentButtonMixin:OnClick()
	if ( self.canChoose ) then
		self:GetParent():ChooseTalent(self:GetID());
	end
end

--========================================================================================================================
ArtifactRelicForgePreviewRelicMixin = { };

function ArtifactRelicForgePreviewRelicMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.Top:SetColorTexture(1, 1, 1);
	self.Bottom:SetColorTexture(1, 1, 1);
	self.Left:SetColorTexture(1, 1, 1);
	self.Right:SetColorTexture(1, 1, 1);
end

function ArtifactRelicForgePreviewRelicMixin:OnShow()
	self:RegisterEvent("ARTIFACT_PENDING_ATTUNE_RELIC_UPDATE");
	self:Update();
end

function ArtifactRelicForgePreviewRelicMixin:OnHide()
	self:UnregisterEvent("ARTIFACT_PENDING_ATTUNE_RELIC_UPDATE");
end

function ArtifactRelicForgePreviewRelicMixin:OnEvent(event, ...)
	self:Update();
end

function ArtifactRelicForgePreviewRelicMixin:OnEnter()
	local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
	if ( relicItemID ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetItemByID(relicItemID);
	end
end

function ArtifactRelicForgePreviewRelicMixin:OnClick(button)
	if ( button == "LeftButton" ) then
		local type, itemID, itemLink = GetCursorInfo();
		if type == "item" and IsArtifactRelicItem(itemID) then
			C_ArtifactRelicForgeUI.SetPreviewRelicFromCursor();
		else
			self:GetParent():SetRelicSlot(PREVIEW_RELIC_SLOT);
		end
	elseif ( button == "RightButton" ) then
		C_ArtifactRelicForgeUI.ClearPreviewRelic();
	end
end

function ArtifactRelicForgePreviewRelicMixin:Update()
	local isSelected = (self:GetParent().relicSlot == PREVIEW_RELIC_SLOT);
	self.SelectionBox:SetShown(isSelected);
	local relicItemID = C_ArtifactRelicForgeUI.GetPreviewRelicItemID();
	if ( relicItemID ) then
		local itemID, class, subClass, invType, texture = GetItemInfoInstant(relicItemID);
		self.Icon:SetTexture(texture);
		local isAttuned, canAttune = C_ArtifactRelicForgeUI.GetPreviewRelicAttuneInfo();
		self.AttuneButton:SetShown(isSelected and canAttune);
	else
		self.Icon:SetTexture();
		self.AttuneButton:Hide();
	end
end

