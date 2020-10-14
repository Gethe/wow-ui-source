CriterionMixin = {};

function CriterionMixin:Init(criterionType, text, id, isComplete)
	self.criterionType = criterionType;
	self.text = text;
	self.id = id;
	self.isComplete = isComplete;
end

function CriterionMixin:IsComplete()
	local t = type(self.isComplete);
	if t == "function" then
		return self.isComplete();
	elseif t == "boolean" then
		return self.isComplete;
	end

	return false;
end

function CriterionMixin:GetText()
	return self.text;
end

CriteriaDisplayMixin = {};

function CriteriaDisplayMixin:OnLoad()
	self.bulletPool = CreateFramePool("FRAME", self, "CriteriaBulletTemplate");
	self.criteria = {};

	if self.title then
		self:SetTitle(self.title);
		self.title = nil;
	end
end

function CriteriaDisplayMixin:SetTitle(title)
	self.Title:SetText(title);
end

function CriteriaDisplayMixin:AddCriterion(text, isComplete)
	table.insert(self.criteria, CreateAndInitFromMixin(CriterionMixin, "user", text, nil, isComplete));
end

function CriteriaDisplayMixin:ClearCriteria()
	self.criteria = {};
end

function CriteriaDisplayMixin:Update()
	self.bulletPool:ReleaseAll();
	self.contentHeight = 0;

	local lastBullet;
	local BULLET_SPACING = 14;

	for index, criterion in ipairs(self.criteria) do
		local bullet = self.bulletPool:Acquire();
		bullet:CheckSetFontOverride(self.font);

		bullet:SetUp(criterion, self.verticalLineOffset);

		if not lastBullet then
			bullet:SetPoint("TOPLEFT", self.HeaderBackground, "BOTTOMLEFT", 13, -6);
		else
			bullet:SetPoint("TOPLEFT", lastBullet, "BOTTOMLEFT", 0, -BULLET_SPACING);
		end
		lastBullet = bullet;

		self.contentHeight = self.contentHeight + bullet.Text:GetHeight() + BULLET_SPACING;
	end

	self:SetHeight(self.contentHeight + 43);	-- total of header height plus top and bottom padding
end

CriteriaBulletMixin = {};

function CriteriaBulletMixin:SetUp(criterion, verticalLineOffset)
	local completed = criterion:IsComplete();
	verticalLineOffset = verticalLineOffset or 0;
	if not completed then
		verticalLineOffset = 0;
	end

	self.Text:SetText(criterion:GetText());
	self.Text:SetTextColor((completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR):GetRGB());
	self.Text:SetPoint("TOPLEFT", self, "TOPLEFT", 27, verticalLineOffset);
	self.Dash:SetShown(not completed);
	self.Check:SetShown(completed);
	self:SetSize(self.Text:GetStringWidth() + 27, self.Text:GetHeight());
	self:Show();
end

function CriteriaBulletMixin:CheckSetFontOverride(font)
	if font then
		self.Dash:SetFontObject(font);
		self.Text:SetFontObject(font);
	end
end

function CriteriaBulletMixin:OnHyperlinkClick(link, text, button, ...)
	-- HACK: This fixes the damage from any frames that marked a link as green for completed.
	local achievementID, complete = GetAchievementInfoFromHyperlink(text);
	if achievementID then
		text = text:gsub("ff20ff20", "ffffff00");

		if not IsModifiedClick("CHATLINK") and (complete or not AchievementUtil.IsFeatOfStrength(achievementID)) then
			OpenAchievementFrameToAchievement(achievementID);
			return;
		end
	end

	SetItemRef(link, text, button, nil);
end