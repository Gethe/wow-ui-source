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

	local professionInfo = Professions.GetProfessionInfo();
	local effectiveSkillLineID = professionInfo.parentProfessionID or professionInfo.professionID;
	for _, tab in ipairs(self.rightProfessionTabs) do
		if tab.skillLine == effectiveSkillLineID and not self.BookPage:IsShown() then
			self:RightTabSelected(tab);
			return;
		end
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

	self.ProfessionsOverviewTab:SetChecked(frame == self.ProfessionsOverviewTab);

	for _, tab in ipairs(self.rightProfessionTabs) do
		tab:SetChecked(tab == frame);
	end

	if InputUtil.IsGamepadUIEnabled() then
		self.TabIndicators:SetCurrentIndex(self.selectedGamepadTabID);
		self.TabIndicators:UpdateTabIndicators();
		self:UpdateSmartNavFocus();
	end
end

function ProfessionsMixin:SelectBookPage()
	ProfessionsFrame.BookPage:Show();
	ProfessionsFrame.CraftingPage:Hide();

	ProfessionsFrame:SetPortraitToAsset("Interface/ICONS/INV_SideTab_Professions_c60");
	ProfessionsFrame:SetTitleFormatted(TRADE_SKILL_TITLE, TRADE_SKILLS);

	ProfessionsFrame:RightTabSelected(self.ProfessionsOverviewTab);
end

function ProfessionsMixin:OverrideArt()
	SetTextureWithAddressModeOptions(self.Bg, "Profession-Background-Overview");
	self.TopTileStreaks:Hide();

	self.CraftingPage.RecipeList.BackgroundNineSlice:Hide();
end
