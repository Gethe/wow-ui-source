local SCROLL_BOX_EDGE_FADE_LENGTH = 30;

LegacyChallengeDetailPaneMixin = {}

function LegacyChallengeDetailPaneMixin:OnLoad()
	AchievementFrameAchievements_OnLoad(self);

	self.ScrollBox:SetEdgeFadeLength(SCROLL_BOX_EDGE_FADE_LENGTH);

	EventRegistry:RegisterCallback("Legacy.SelectChallengeCategory", function(_, info)
		self:SelectCategory(info);
	end, self);

	EventRegistry:RegisterCallback("Legacy.RefreshChallenges", function(_, _)
		self:RefreshChallenges();
	end, self);

	EventRegistry:RegisterCallback("Legacy.SelectChallenge", function(_, achievementId)
		self:SelectChallenge(achievementId);
	end, self);

	EventRegistry:RegisterCallback("Legacy.UpdateChallenge", function(_, elementData)
		self:UpdateChallenge(elementData);
	end, self);
end

function LegacyChallengeDetailPaneMixin:SelectCategory(info)
	self:GenerateDataProvider(info);
end

function LegacyChallengeDetailPaneMixin:RefreshChallenges()
	if self.info then
		self:GenerateDataProvider(self.info);
	end
end

function LegacyChallengeDetailPaneMixin:GenerateDataProvider(categoryInfo)
	self.info = categoryInfo;
	local startOffset, count = LegacySystem.GetChallengeIndices(categoryInfo.id);
	local hideIncomplete = not LegacyChallengeFilters[ACHIEVEMENTFRAME_FILTER_INCOMPLETE].value;
	local filteredChallenges = LegacySystem.GetFilteredChallenges();

	local newDataProvider = CreateDataProvider();
	for index = 1 + startOffset, count + startOffset do
		local achievementId, _,_,_,_,_,_,_,_,_,_,_, wasEarnedByMe = GetAchievementInfo(categoryInfo.id, index);
		-- consider achievements earned by others incomplete
		local shouldHideCompletedByOther = not wasEarnedByMe and hideIncomplete;
		local passedFilter = filteredChallenges[achievementId];
		if not shouldHideCompletedByOther and passedFilter then
			newDataProvider:Insert({category = categoryInfo.id, index = index, id = achievementId});
		end
	end
	self.ScrollBox:SetDataProvider(newDataProvider);
end

function LegacyChallengeDetailPaneMixin:SelectChallenge(achievementId, scrollToChallenge)
	local elementData = AchievementFrame_SelectAndScrollToAchievementId(self.ScrollBox, achievementId);
	if elementData then
		if InputUtil.IsGamepadUIEnabled() then
			local frame = self.ScrollBox:FindFrame(elementData);
			if frame then
				SmartNavigation:SelectButton(frame);
			end
		end
	end
end

function LegacyChallengeDetailPaneMixin:UpdateChallenge(elementData)
	local button = self.ScrollBox:FindFrame(elementData);
	if button then
		button:Init(elementData);
	end
end
