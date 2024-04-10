local BULLET_SPACING = 14; 
local ACHIEVEMENT_FRAME_PADDING = 43; 
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

function AchievementDisplayMixin:SetupBulletAnchoring(achievementID, criteriaIndex)
	local bullet = self.bulletPool:Acquire();

	if(criteriaIndex) then 
		bullet:SetUpCriteria(achievementID, criteriaIndex);
	else
		bullet:SetUpAchievement(achievementID);
	end

	if not self.lastBullet then
		bullet:SetPoint("TOPLEFT", self.HeaderBackground, "BOTTOMLEFT", 13, -6);
	else
		bullet:SetPoint("TOPLEFT", self.lastBullet, "BOTTOMLEFT", 0, -BULLET_SPACING);
	end

	self.contentHeight = self.contentHeight + bullet.Text:GetHeight() + BULLET_SPACING;
	self.lastBullet = bullet;
end 

function AchievementDisplayMixin:SetAchievements(achievementIds)
	self.bulletPool:ReleaseAll();
	self.contentHeight = 0;
	self.lastBullet = nil;

	for _, achievementID in ipairs(achievementIds) do 
		if(GetAchievementNumCriteria(achievementID) == 0) then 
			self:SetupBulletAnchoring(achievementID)
		else
			for criteriaIndex = 1, GetAchievementNumCriteria(achievementID) do
				self:SetupBulletAnchoring(achievementID, criteriaIndex);
			end
		end 
	end 

	self:SetHeight(self.contentHeight + ACHIEVEMENT_FRAME_PADDING);	-- total of header height plus top and bottom padding
end

AchievementDisplayOverviewBulletMixin = {};
function AchievementDisplayOverviewBulletMixin:Setup(achievementID, criteriaIndex, bulletText, completed)
	self.achievementID = achievementID;
	self.criteriaIndex = criteriaIndex;

	if (bulletText and bulletText ~= "") then
		self.achievementID = achievementID;
		self.criteriaIndex = criteriaIndex;

		self.Text:SetText(bulletText);
		self.Text:SetTextColor((completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR):GetRGB());
		self.Dash:SetShown(not completed);
		self.Check:SetShown(completed);
		self:SetSize(self.Text:GetStringWidth() + 27, self.Text:GetHeight());
		self:Show();
	end
end 

function AchievementDisplayOverviewBulletMixin:SetUpCriteria(achievementID, criteriaIndex)
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
	local _, name, _, achievementCompleted, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
	completed = completed or (achievementCompleted and wasEarnedByMe);
	local bulletString = criteriaString or name; 
	self:Setup(achievementID, criteriaIndex, bulletString, completed);
end

function AchievementDisplayOverviewBulletMixin:SetUpAchievement(achievementID)
	local _, name, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
	local completed = completed and wasEarnedByMe; 
	self:Setup(achievementID, nil, name, completed);
end

function AchievementDisplayOverviewBulletMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local achievementID = self.achievementID;
	local _, _, _, overallAchievementCompleted, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
	local criteriaCompleted = nil; 
	local assetID = nil; 

	if (self.criteriaIndex) then 
		_, _, criteriaCompleted, _, _, _, _, assetID = GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex);
	end

	if criteriaCompleted or (overallAchievementCompleted and wasEarnedByMe) then
		-- check if the criteria is an achievement to use its completion date, otherwise try main achievement in case it's all complete
		if self.criteriaIndex and AchievementUtil.IsCriteriaAchievementEarned(achievementID, self.criteriaIndex) then
			achievementID = assetID;
		end

		local _, _, _, completed, month, day, year, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(achievementID);
		if completed then
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
	-- check if it's rep-related
	local CHECK_CRITERIA_ACHIEVEMENT = true;
	if self.criteriaIndex and AchievementUtil.IsCriteriaReputationGained(self.achievementID, self.criteriaIndex, CHECK_CRITERIA_ACHIEVEMENT) then
		if not ReputationFrame:IsVisible() then
			ToggleCharacter("ReputationFrame");
		end
	else
		-- see if it's an achievement, otherwise use main achievement
		if self.criteriaIndex and AchievementUtil.IsCriteriaAchievementEarned(self.achievementID, self.criteriaIndex) then
			local assetID = select(8, GetAchievementCriteriaInfo(self.achievementID, self.criteriaIndex));
			OpenAchievementFrameToAchievement(assetID);
		else
			OpenAchievementFrameToAchievement(self.achievementID);
		end
	end
end