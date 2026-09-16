ProfessionsUnlearnButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function ProfessionsUnlearnButtonMixin:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP);
end

function ProfessionsUnlearnButtonMixin:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	GameTooltip_Hide();
end

function ProfessionsUnlearnButtonMixin:OnButtonStateChanged()
	self.Overlay:SetShown(self:IsDown());
end

function ProfessionsBookFrameMixin:Update()
	local prof1, prof2, faid, fish, cook = GetProfessions();
	self:FormatProfession(self.ProfessionsContentFrame.PrimaryProfession1, prof1);
	self:FormatProfession(self.ProfessionsContentFrame.PrimaryProfession2, prof2);
	self:FormatProfession(self.ProfessionsContentFrame.SecondaryProfession1, cook);
	self:FormatProfession(self.ProfessionsContentFrame.SecondaryProfession2, fish);
	self:FormatProfession(self.ProfessionsContentFrame.SecondaryProfession3, faid);
end

function ProfessionsBookFrameMixin:UpdateRankBar(frame, skillLine, rank, maxRank, rankModifier)
	local professionInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLine);
	if frame and professionInfo then
		if professionInfo.skillLevel == 0 and professionInfo.maxSkillLevel == 0 then
			professionInfo.skillLevel = rank;
			professionInfo.maxSkillLevel = maxRank;
			professionInfo.skillModifier = rankModifier;
		end

		-- Prevent the status bar from listening to events and instead depend on Updates from the book, which have more context.
		frame.StatusBar.ownerManagesEvents = true;
		frame.StatusBar:Update(professionInfo);
		frame.StatusBar:Show();
	end
end

function ProfessionsBookFrameMixin:FormatProfession(frame, index)
	if frame.isPrimary then
		frame.Background:SetAtlas("Profession-overview-Card");
	end

	frame.SpellButton1.OutlineMask:Show();
	frame.SpellButton2.OutlineMask:Show();

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

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Show();
			frame.UnlearnButton:SetScript("OnClick", function()
				local popupName = InputUtil.IsGamepadUIEnabled() and "UNLEARN_SKILL_GAMEPAD" or "UNLEARN_SKILL";
				StaticPopup_Show(popupName, name, nil, skillLine);
			end);
		end

		if frame.icon and texture then
			frame.icon:SetTexture(texture);
		end

		frame.ProfessionName:SetText(name);

		if frame.isPrimary then
			frame.Background:SetAtlas(string.format("Profession-overview-Card-%s", name));
		end

		self:UpdateRankBar(frame, skillLine, rank, maxRank, rankModifier);

		local spellButtonID = 1;
		while spellButtonID <= #frame.spellButtons do
			frame.spellButtons[spellButtonID]:SetShown(spellButtonID <= numSpells);
			if spellButtonID <= numSpells then
				frame.spellButtons[spellButtonID]:SetID(spellButtonID);
				frame.spellButtons[spellButtonID]:UpdateButton();
			end
			spellButtonID = spellButtonID + 1;
		end

		local hasSpell = numSpells >= 1;

		if frame.isPrimary then
			if numSpells == 1 then
				frame.SpellButton1:SetPoint("BOTTOMLEFT", 15, 46);
			else
				frame.SpellButton1:SetPoint("BOTTOMLEFT", 15, 60);
				frame.SpellButton2:SetPoint("BOTTOMLEFT", 15, 10);
			end
		end

		if hasSpell and self.showProfessionSpellHighlights and C_ProfSpecs.ShouldShowPointsReminderForSkillLine(skillLine) then
			UIFrameFlash(frame.SpellButton1.Flash, 0.5, 0.5, -1);
		else
			UIFrameFlashStop(frame.SpellButton1.Flash);
		end

		if numSpells >  #frame.spellButtons then
			local errorStr = "Found "..numSpells.." skills for "..name.." the max is " .. #frame.spellButtons;
			for i=1,numSpells do
				errorStr = errorStr.." ("..C_SpellBook.GetSpellBookItemName(i + spellOffset, Enum.SpellBookSpellBank.Player)..")";
			end
			assert(false, errorStr);
		end
	else
		frame.missingHeader:Show();
		frame.missingText:Show();

		if frame.icon then
			frame.icon:SetTexture("Interface\\Icons\\INV_Scroll_04");
			frame.specialization:SetText("");
		end

		for i = 1, #frame.spellButtons do
			frame.spellButtons[i]:Hide();
		end

		frame.StatusBar:Hide();
		frame.ProfessionName:SetText("");

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Hide();
			frame.GamepadUnlearnButton:Hide();
		end
	end
end

function ProfessionSpellButtonMixin:UpdateOverlay()
	self.IconTextureOverlay:SetAtlas("Profession-square-frame", TextureKitConstants.UseAtlasSize);
	self.IconTextureOverlay:Show();
end

function ProfessionSpellButtonMixin:UpdateSelection()
	-- No highlight in Camelot.
	self:SetChecked(false);
end
