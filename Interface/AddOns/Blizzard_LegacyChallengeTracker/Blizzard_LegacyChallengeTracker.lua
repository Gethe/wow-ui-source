LegacyChallengesUnviewed = LegacyChallengesUnviewed or nil;

LegacyChallengeViewedUtil = {};

-- GetCategoryInfo reports this as the parent of a top level category.
local TOP_LEVEL_CATEGORY_ID = -1;

local unviewedCategories = {};

-- Maps achievement ID to the category it belongs to, captured when the challenge was earned.
local function GetUnviewedChallenges()
	if not LegacyChallengesUnviewed then
		LegacyChallengesUnviewed = {};
	end

	return LegacyChallengesUnviewed;
end

-- Flattens the unviewed challenges into every category that should report one, including ancestors so a
-- collapsed parent still reports its children, leaving each query as a single lookup.
local function RebuildUnviewedCategories()
	unviewedCategories = {};

	for _achievementID, challengeCategoryID in pairs(GetUnviewedChallenges()) do
		local categoryID = challengeCategoryID;
		while type(categoryID) == "number" and categoryID ~= TOP_LEVEL_CATEGORY_ID and not unviewedCategories[categoryID] do
			unviewedCategories[categoryID] = true;

			local _name, parentID = GetCategoryInfo(categoryID);
			categoryID = parentID;
		end
	end
end

function LegacyChallengeViewedUtil.SignalUnviewedChallengesUpdated()
	RebuildUnviewedCategories();

	EventRegistry:TriggerEvent("Legacy.UnviewedChallengesUpdated");
end

function LegacyChallengeViewedUtil.CategoryHasUnviewedChallenges(categoryID)
	return unviewedCategories[categoryID] or false;
end

function LegacyChallengeViewedUtil.HasAnyUnviewedChallenges()
	local unviewedChallenges = GetUnviewedChallenges();
	return next(unviewedChallenges) ~= nil;
end

-- Only clears challenges directly in this category; descendants stay unviewed until their own category is opened.
function LegacyChallengeViewedUtil.MarkCategoryViewed(categoryID)
	local unviewedChallenges = GetUnviewedChallenges();
	local changed = false;

	for achievementID, challengeCategoryID in pairs(unviewedChallenges) do
		if challengeCategoryID == categoryID then
			unviewedChallenges[achievementID] = nil;
			changed = true;
		end
	end

	if changed then
		LegacyChallengeViewedUtil.SignalUnviewedChallengesUpdated();
	end
end

EventRegistry:RegisterFrameEventAndCallback("ACHIEVEMENT_EARNED",
	function(_owner, achievementID)
		local categoryID = achievementID and GetAchievementCategory(achievementID);
		if categoryID then
			local unviewedChallenges = GetUnviewedChallenges();
			unviewedChallenges[achievementID] = categoryID;

			LegacyChallengeViewedUtil.SignalUnviewedChallengesUpdated();
		end
	end,
	LegacyChallengeViewedUtil);

RebuildUnviewedCategories();
