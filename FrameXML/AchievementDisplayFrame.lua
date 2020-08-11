AchievementDisplayMixin = {};

function AchievementDisplayMixin:OnLoad()
	self.bulletPool = CreateFramePool("FRAME", self, "AchievementDisplayOverviewBulletTemplate");

	if self.title then
		self:SetTitle(self.title);
		self.title = nil;
	end
end

function AchievementDisplayMixin:SetTitle(title)
	self.Title:SetText(title);
end

function AchievementDisplayMixin:SetAchievement(achievementID)
	self.bulletPool:ReleaseAll();
	self.contentHeight = 0;

	local lastBullet;
	local BULLET_SPACING = 14;

	for criteriaIndex = 1, GetAchievementNumCriteria(achievementID) do
		local bullet = self.bulletPool:Acquire();
		bullet:SetUp(achievementID, criteriaIndex);

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

AchievementDisplayOverviewBulletMixin = {};

function AchievementDisplayOverviewBulletMixin:SetUp(achievementID, criteriaIndex)
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
	local _, _, _, achievementCompleted = GetAchievementInfo(achievementID);

	completed = completed or achievementCompleted;

	if (criteriaString and criteriaString ~= "") then
		self.achievementID = achievementID;
		self.criteriaIndex = criteriaIndex;

		self.Text:SetText(criteriaString);
		self.Text:SetTextColor((completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR):GetRGB());
		self.Dash:SetShown(not completed);
		self.Check:SetShown(completed);
		self:SetSize(self.Text:GetStringWidth() + 27, self.Text:GetHeight());
		self:Show();
	end
end

function AchievementDisplayOverviewBulletMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local criteriaString, criteriaType, criteriaCompleted, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex);

	local achievementID = self.achievementID;
	local _, _, _, overallAchievementCompleted = GetAchievementInfo(achievementID);
	local criteriaAchievementCompleted, month, day, year;

	if criteriaCompleted or overallAchievementCompleted then
		-- check if the criteria is an achievement to use its completion date, otherwise try main achievement in case it's all complete
		if AchievementUtil.IsCriteriaAchievementEarned(achievementID, self.criteriaIndex) then
			achievementID = assetID;
			 _, _, _, criteriaAchievementCompleted, month, day, year = GetAchievementInfo(achievementID); --Grab the criteria completed info if we have earned it.
		end

		if criteriaAchieveCompleted then
			local completionDate = FormatShortDate(day, month, year);
			GameTooltip_AddColoredLine(GameTooltip, CRITERIA_COMPLETED_DATE:format(completionDate), HIGHLIGHT_FONT_COLOR);
		else
			GameTooltip_AddColoredLine(GameTooltip, CRITERIA_COMPLETED, HIGHLIGHT_FONT_COLOR);
		end
	else
		GameTooltip_SetTitle(GameTooltip, CRITERIA_NOT_COMPLETED, DISABLED_FONT_COLOR);
	end

	GameTooltip_AddColoredLine(GameTooltip, CLICK_FOR_MORE_INFO, GREEN_FONT_COLOR);
	GameTooltip:Show();
end

function AchievementDisplayOverviewBulletMixin:OnLeave()
	GameTooltip:Hide();
end

function AchievementDisplayOverviewBulletMixin:OnMouseUp()
	local criteriaString, criteriaType, criteriaCompleted, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex);
	-- check if it's rep-related
	local CHECK_CRITERIA_ACHIEVEMENT = true;
	if AchievementUtil.IsCriteriaReputationGained(self.achievementID, self.criteriaIndex, CHECK_CRITERIA_ACHIEVEMENT) then
		if not ReputationFrame:IsVisible() then
			ToggleCharacter("ReputationFrame");
		end
	else
		-- see if it's an achievement, otherwise use main achievement
		if AchievementUtil.IsCriteriaAchievementEarned(self.achievementID, self.criteriaIndex) then
			OpenAchievementFrameToAchievement(assetID);
		else
			OpenAchievementFrameToAchievement(self.achievementID);
		end
	end
end