

--This File is responsible for animating spells to the actionbar
MULTIBOTTOMLEFTINDEX = 6;

IconIntroTrackerMixin = {};

function IconIntroTrackerMixin:OnLoad()
	self.iconList = {};

	local actionBarIconIntroDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ActionbarIconIntroDisabled);
	if not actionBarIconIntroDisabled then
		self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
		self:RegisterEvent("SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR");
	end
end

function IconIntroTrackerMixin:OnEvent(event, ...)
	if event == "SPELL_PUSHED_TO_ACTIONBAR" or event == "SPELL_PUSHED_TO_FLYOUT_ON_ACTIONBAR" then
		local spellID, slotIndex, slotPos = ...;

		-- The slot index may be zero when the gamepad interface is enabled. Since the gamepad
		-- interface handles its own flyins, we should ignore it here.
		if slotIndex > 0 then
			self:PushSpellToActionBar(spellID, slotIndex, slotPos);
		end
	end
end

function IconIntroTrackerMixin:PushSpellToActionBar(spellID, slotIndex, slotPos)
	ClearNewActionHighlight(slotIndex, true);

	local page = math.floor((slotIndex - 1) / NUM_ACTIONBAR_BUTTONS) + 1;
	local currentPage = C_ActionBar.GetActionBarPage();

	local bonusBarIndex = C_ActionBar.GetBonusBarIndex();
	if (C_ActionBar.HasBonusActionBar() and bonusBarIndex ~= 0) then
		currentPage = bonusBarIndex;
	end

	if (page ~= currentPage and page ~= MULTIBOTTOMLEFTINDEX) then
		return;
	end

	MarkNewActionHighlight(slotIndex);

	local icon = C_Spell.GetSpellTexture(spellID);
	local freeIcon;

	for a,b in pairs(self.iconList) do
		if b.isFree then
			freeIcon = b;
		end
	end

	if not freeIcon then -- Make a new one
		freeIcon = CreateFrame("FRAME", self:GetName().."Icon"..(#self.iconList+1), UIParent, "IconIntroTemplate");
		self.iconList[#self.iconList+1] = freeIcon;
	end

	freeIcon.icon.icon:SetTexture(icon);
	freeIcon.icon.spellID = spellID;
	freeIcon.icon.slot = slotIndex;
	freeIcon:ClearAllPoints();

	if (page == MULTIBOTTOMLEFTINDEX) then
		freeIcon.icon.button = _G["MultiBarBottomLeftButton" .. slotPos];
	else
		freeIcon.icon.button = _G["ActionButton" .. slotPos];
	end

	freeIcon:SetPoint("CENTER", freeIcon.icon.button, 0, 0);
	freeIcon:SetFrameLevel(freeIcon.icon.button:GetFrameLevel() + 1);

	freeIcon.icon.flyin:Play(1);
	freeIcon.isFree = false;
end

function IconIntroTrackerMixin:ResetAll()
	for _, iconIntro in ipairs(self.iconList) do
		if not iconIntro.isFree then
			iconIntro.trail1.flyin:Stop();
			iconIntro.trail1.flyin:OnAnimFinished();
			iconIntro.trail2.flyin:Stop();
			iconIntro.trail2.flyin:OnAnimFinished();
			iconIntro.trail3.flyin:Stop();
			iconIntro.trail3.flyin:OnAnimFinished();
			iconIntro.icon.flyin:Stop();
			iconIntro.icon.flyin:OnAnimFinished();
			iconIntro.isFree = true;
			iconIntro:Hide();
		end
	end
end

IconIntroFlyinAnimMixin = {};

function IconIntroFlyinAnimMixin:OnAnimPlay()
	local iconFrame = self:GetParent();
	iconFrame.bg:SetTexture(iconFrame.icon:GetTexture());

	local trail = iconFrame.trail;
	if trail then
		trail:Show();
		trail.flyin:Stop();
		trail.icon:SetTexture(iconFrame.icon:GetTexture());
		trail.flyin:Play(1);
		if iconFrame.isBase then
			trail:SetFrameLevel(iconFrame:GetFrameLevel()-1);
		else
			trail:SetFrameLevel(iconFrame:GetFrameLevel());
		end
	end

	if iconFrame.isBase then
		iconFrame:GetParent():Show();
		if iconFrame.glow:IsPlaying() then
			iconFrame.glow:Stop();
		end
	end
end

function IconIntroFlyinAnimMixin:OnAnimFinished()
	local iconFrame = self:GetParent();
	if iconFrame.isBase then
		iconFrame.glow:Play();
		C_SpellBook.SetBarSlotFromIntro(iconFrame.spellID, iconFrame.slot);
		iconFrame.isFree = true;

		if not iconFrame.noHighlight then
			MarkNewActionHighlight(iconFrame.slot);
		end

		iconFrame.button:UpdateAction(true);
	else
		iconFrame:SetFrameLevel(1);
	end
end
