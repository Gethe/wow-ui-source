ProfessionsUnlearnButtonMixin = {};

function ProfessionsUnlearnButtonMixin:OnEnter()
    self.Icon:SetAlpha(1.0);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP);
end

function ProfessionsUnlearnButtonMixin:OnLeave()
    self.Icon:SetAlpha(0.75);
	GameTooltip_Hide();
end

function ProfessionsUnlearnButtonMixin:OnMouseDown()
    self.Icon:SetPoint("TOPLEFT", 1, -1);
end

function ProfessionsUnlearnButtonMixin:OnMouseUp()
    self.Icon:SetPoint("TOPLEFT", 0, 0);
end


function UpdateProfessionButton(self)
	local parent = self:GetParent();
	if not parent.professionInitialized then
		return;
	end

	local spellIndex = self:GetID() + parent.spellOffset;
	local texture = GetSpellBookItemTexture(spellIndex, SpellBookFrame.bookType);
	local spellName, _, spellID = GetSpellBookItemName(spellIndex, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType);
	if ( isPassive ) then
		self.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		self.spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		self.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self.spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	self.IconTexture:SetTexture(texture);
	local start, duration, enable = GetSpellCooldown(spellIndex, SpellBookFrame.bookType);
	CooldownFrame_Set(self.cooldown, start, duration, enable);
	if ( enable == 1 ) then
		self.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.IconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	self.spellString:SetText(spellName);
	self.subSpellString:SetText("");
	if spellID then
		local spell = Spell:CreateFromSpellID(spellID);
		spell:ContinueOnSpellLoad(function()
			self.subSpellString:SetText(spell:GetSpellSubtext());
		end);
	end
	self.IconTexture:SetTexture(texture);

	self:UpdateSelection();
end

function FormatProfession(frame, index)
	if index then
		frame.missingHeader:Hide();
		frame.missingText:Hide();

		local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(index);
		frame.professionInitialized = true;
		frame.skillName = name;
		frame.spellOffset = spellOffset;
		frame.skillLine = skillLine;
		frame.specializationIndex = specializationIndex;
		frame.specializationOffset = specializationOffset;

		frame.statusBar:SetMinMaxValues(1,maxRank);
		frame.statusBar:SetValue(rank);

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Show();
			frame.UnlearnButton:SetScript("OnClick", function() 
				StaticPopup_Show("UNLEARN_SKILL", name, nil, skillLine);
			end);
		end

		local prof_title = "";
		if (skillLineName) then
			prof_title = skillLineName;
		else
			for i=1,#PROFESSION_RANKS do
				local value,title = PROFESSION_RANKS[i][1], PROFESSION_RANKS[i][2];
				if maxRank < value then break end
				prof_title = title;
			end
		end
		frame.rank:SetText(prof_title);

		frame.statusBar:Show();
		if rank == maxRank then
			frame.statusBar.capRight:Show();
		else
			frame.statusBar.capRight:Hide();
		end

		frame.statusBar.capped:Hide();
		frame.statusBar.rankText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		frame.statusBar.tooltip = nil;

		-- trial cap
		if ( GameLimitedMode_IsActive() ) then
			local _, _, profCap = GetRestrictedAccountData();
			if rank >= profCap and profCap > 0 then
				frame.statusBar.capped:Show();
				frame.statusBar.rankText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				frame.statusBar.tooltip = RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL..FONT_COLOR_CODE_CLOSE;
			end
		end

		if frame.icon and texture then
			SetPortraitToTexture(frame.icon, texture);
		end

		frame.professionName:SetText(name);

		if ( rankModifier > 0 ) then
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, rank, rankModifier, maxRank);
		else
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK, rank, maxRank);
		end

		local hasSpell = false;
		if numSpells <= 0 then
			frame.SpellButton1:Hide();
			frame.SpellButton2:Hide();
		elseif numSpells == 1 then
			hasSpell = true;
			frame.SpellButton2:Hide();
			frame.SpellButton1:Show();
			UpdateProfessionButton(frame.SpellButton1);
		else
			hasSpell = true;
			frame.SpellButton1:Show();
			frame.SpellButton2:Show();
			UpdateProfessionButton(frame.SpellButton1);
			UpdateProfessionButton(frame.SpellButton2);
		end

		if hasSpell and SpellBookFrame.showProfessionSpellHighlights and C_ProfSpecs.ShouldShowPointsReminderForSkillLine(skillLine) then
			UIFrameFlash(frame.SpellButton1.Flash, 0.5, 0.5, -1);
		else
			UIFrameFlashStop(frame.SpellButton1.Flash);
		end

		if numSpells >  2 then
			local errorStr = "Found "..numSpells.." skills for "..name.." the max is 2:"
			for i=1,numSpells do
				errorStr = errorStr.." ("..GetSpellBookItemName(i + spelloffset, SpellBookFrame.bookType)..")";
			end
			assert(false, errorStr)
		end
	else
		frame.missingHeader:Show();
		frame.missingText:Show();

		if frame.icon then
			SetPortraitToTexture(frame.icon, "Interface\\Icons\\INV_Scroll_04");
			frame.specialization:SetText("");
		end
		frame.SpellButton1:Hide();
		frame.SpellButton2:Hide();
		frame.statusBar:Hide();
		frame.rank:SetText("");
		frame.professionName:SetText("");

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Hide();
		end
	end
end

function SpellBook_UpdateProfTab()
	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	FormatProfession(PrimaryProfession1, prof1);
	FormatProfession(PrimaryProfession2, prof2);
	FormatProfession(SecondaryProfession1, arch);
	FormatProfession(SecondaryProfession2, fish);
	FormatProfession(SecondaryProfession3, cook);
	FormatProfession(SecondaryProfession4, firstAid);
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end