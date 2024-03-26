

--This File is responsible for animating spells to the actionbar
MULTIBOTTOMLEFTINDEX = 6;

IconIntroTrackerMixin = {};

function IconIntroTrackerMixin:OnLoad()
	self.iconList = {};
	self:RegisterEvents();
end

function IconIntroTrackerMixin:RegisterEvents()
	self:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR");
end

function IconIntroTrackerMixin:OnEvent(event, ...)
	if event == "SPELL_PUSHED_TO_ACTIONBAR" then
		local spellID, slotIndex, slotPos = ...;
		ClearNewActionHighlight(slotIndex, true);

		local page = math.floor((slotIndex - 1) / NUM_ACTIONBAR_BUTTONS) + 1;
		local currentPage = GetActionBarPage();

		local bonusBarIndex = GetBonusBarIndex();
		if (HasBonusActionBar() and bonusBarIndex ~= 0) then
			currentPage = bonusBarIndex;
		end

		if (page ~= currentPage and page ~= MULTIBOTTOMLEFTINDEX) then
			return;
		end

		MarkNewActionHighlight(slotIndex);

		local _, _, icon = GetSpellInfo(spellID);
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
		freeIcon.icon.slot = slotIndex;
		freeIcon.icon.pos = slotPos;
 		freeIcon:ClearAllPoints();


		if (page == MULTIBOTTOMLEFTINDEX) then
			freeIcon:SetPoint("CENTER", _G["MultiBarBottomLeftButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["MultiBarBottomLeftButton"..slotPos]:GetFrameLevel()+1);
			freeIcon.icon.multibar = true;
		else
			freeIcon:SetPoint("CENTER", _G["ActionButton"..slotPos], 0, 0);
			freeIcon:SetFrameLevel(_G["ActionButton"..slotPos]:GetFrameLevel()+1);
			freeIcon.icon.multibar = false;
		end

		freeIcon.icon.flyin:Play(1);
		freeIcon.isFree = false;
	end
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
		SetBarSlotFromIntro(iconFrame.slot);
		iconFrame.isFree = true;

		local button;
		if (iconFrame.multibar) then
			button = _G["MultiBarBottomLeftButton"..iconFrame.pos];
		else
			button = _G["ActionButton"..iconFrame.pos];
		end

		MarkNewActionHighlight(iconFrame.slot);
		button:UpdateAction(true);
	else
		iconFrame:SetFrameLevel(1);
	end
end
