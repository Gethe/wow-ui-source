--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
ProfessionsMixin.useFooterJumpHints = true;

professionsFrameWidthOverride = 750;

-- Text to display next to jump hints on other frames, if the jump takes them here
function ProfessionsMixin:GetJumpHintLabel()
	return TRADE_SKILLS;
end

function ProfessionsMixin:RefreshRightTabs()
	local prim1, prim2, sec1, sec2, sec3, sec4, sec5 = GetProfessions();

	local nextTab = 1;
	local function SetupTab(profession)
		if profession then
			if self:RefreshRightTab(self.rightProfessionTabs[nextTab], profession) then
				nextTab = nextTab + 1;
			end
		end		
	end

	SetupTab(prim1);
	SetupTab(prim2);
	SetupTab(sec1);
	SetupTab(sec2);
	SetupTab(sec3);
	SetupTab(sec4);
	SetupTab(sec5);

	while nextTab <= #self.rightProfessionTabs do
		self.rightProfessionTabs[nextTab]:Hide();
		nextTab = nextTab + 1;
	end

	local effectiveSkillLineID = Professions.GetEffectiveSkillLineID();
	for _, tab in ipairs(self.rightProfessionTabs) do
		if tab.skillLine == effectiveSkillLineID and not self.BookPage:IsShown() then
			self:RightTabSelected(tab);
			return;
		end
	end

	-- An open trade skill with no matching tab shouldn't be recast on reopen.
	if effectiveSkillLineID ~= 0 then
		self.selectedSkillLine = nil;
	end
end

function ProfessionsMixin:RefreshRightTab(frame, skillIndex)
	if not skillIndex then
		frame:Hide();
		return false;
	end

	local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(skillIndex);
	frame.Icon:SetTexture(texture);
	frame.tooltipText = name;
	frame.spellOffsetIndex = spellOffset;
	frame.skillLine = skillLine;

	local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(spellOffset + 1, Enum.SpellBookSpellBank.Player);
	if spellBookItemInfo and spellBookItemInfo.spellID then
		if not C_TradeSkillUI.CanTradeSkillShowCraftingUI(spellBookItemInfo.spellID) then
			return false;
		end
	else
		return false;
	end

	frame:Show();
	return true;
end

function ProfessionsMixin:RightTabSelected(frame)
	self.selectedGamepadTabID = frame:GetID();
	self.selectedSkillLine = frame.skillLine;

	self.ProfessionsOverviewTab:SetChecked(frame == self.ProfessionsOverviewTab);

	for _, tab in ipairs(self.rightProfessionTabs) do
		tab:SetChecked(tab == frame);
	end

	if InputUtil.IsGamepadUIEnabled() then
		local tabIndicators = self.TabIndicators;
		tabIndicators:UpdateTabVisibility();

		local visibleIndex = tIndexOf(tabIndicators.visibleTabs, frame);
		if visibleIndex then
			tabIndicators:SetCurrentIndex(visibleIndex);
			tabIndicators:UpdateTabIndicators();
		end

		self:UpdateSmartNavFocus();
	end
end

function ProfessionsMixin:RecastSelectedProfession()
	-- Casting while a trade skill is open re-enters SetTradeSkill during TRADE_SKILL_SHOW.
	local effectiveSkillLineID = Professions.GetEffectiveSkillLineID();
	if effectiveSkillLineID ~= 0 then
		return;
	end

	if self.selectedSkillLine then
		for _, tab in ipairs(self.rightProfessionTabs) do
			if tab:IsShown() and tab.skillLine == self.selectedSkillLine then
				tab:CastProfessionSpell();
				return;
			end
		end
	end

	self:SelectBookPage();
end

function ProfessionsMixin:SelectBookPage()
	ProfessionsFrame.BookPage:Show();
	ProfessionsFrame.CraftingPage:Hide();

	ProfessionsFrame:SetPortraitToAsset("Interface/ICONS/INV_SideTab_Professions_c60");
	ProfessionsFrame:SetTitleFormatted(TRADE_SKILL_TITLE, TRADE_SKILLS);

	ProfessionsFrame:RightTabSelected(self.ProfessionsOverviewTab);
end

-- The book page lives inside this frame, so stay open and only drop a trade skill still open for the abandoned profession.
function ProfessionsMixin:OnSkillAbandoned(skillLine)
	if Professions.IsSelectedProfession(skillLine) then
		C_TradeSkillUI.CloseTradeSkill();
	end
end

-- Closing a trade skill behind the book page must not dismiss the frame.
function ProfessionsMixin:OnTradeSkillClosed()
	if self.BookPage:IsShown() then
		self:RefreshRightTabs();
	else
		HideUIPanel(self);
	end
end

function ProfessionsMixin:OverrideArt()
	SetTextureWithAddressModeOptions(self.Bg, "Profession-Background-Overview");
	self.TopTileStreaks:Hide();

	self.CraftingPage.RecipeList.BackgroundNineSlice:Hide();
end
