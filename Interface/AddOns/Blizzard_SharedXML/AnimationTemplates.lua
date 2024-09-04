-- Anim group whose parent is hidden or shown based on script calls defined in the template xml being used
VisibleWhilePlayingAnimGroupMixin = {}

function VisibleWhilePlayingAnimGroupMixin:Show()
	self:GetParent():Show();
end

function VisibleWhilePlayingAnimGroupMixin:Hide()
	self:GetParent():Hide();
end

-- Anim group whose animation targets are hidden or shown based on script calls defined in the template xml being used
TargetsVisibleWhilePlayingAnimGroupMixin = {}

function TargetsVisibleWhilePlayingAnimGroupMixin:Show()
	self:SetTargetsShown(true, self:GetAnimations());
end

function TargetsVisibleWhilePlayingAnimGroupMixin:Hide()
	self:SetTargetsShown(false, self:GetAnimations());
end

function TargetsVisibleWhilePlayingAnimGroupMixin:SetTargetsShown(shown, ...)
	for i = 1, select("#", ...) do
		local anim = select(i, ...);
		if anim then
			local target = anim:GetTarget();
			if target and target.SetShown then
				target:SetShown(shown);
			end
		end
	end
end

-- Anim group for keeping all groups using the same syncKey in sync via initial start time tracking
SyncedAnimGroupMixin = {};

local s_animGroupSyncTimesByKey = {};

-- Static helper that likely isn't needed by external code, but exposed for ease of debugging
function SyncedAnimGroupMixin.GetTimeSinceSyncTimeForKey(syncKey)
	local timeNow = GetTime();
	if not s_animGroupSyncTimesByKey[syncKey] then
		s_animGroupSyncTimesByKey[syncKey] = timeNow;
		return 0;
	end

	return timeNow - s_animGroupSyncTimesByKey[syncKey];
end

-- Call this instead of Play to play this AnimGroup synchronously with others using the same syncKey
function SyncedAnimGroupMixin:PlaySynced(reverse, syncKey)
	syncKey = syncKey or self.syncKey or "DEFAULT";

	local timeSinceSyncedStart = SyncedAnimGroupMixin.GetTimeSinceSyncTimeForKey(syncKey);
	local syncedOffset = timeSinceSyncedStart % self:GetDuration();

	self:Play(reverse, syncedOffset);
end

-- Frame mixin for playing or stopping all child Anim Groups based on script calls defined in the template xml being used
AnimateWhileShownMixin = { };

local function IterateAllAnimationGroups(frame, func)
	local animGroups = { frame:GetAnimationGroups() };
	for _, animGroup in ipairs(animGroups) do
		func(animGroup);
	end

	local children = { frame:GetChildren() };
	for _, child in ipairs(children) do
		IterateAllAnimationGroups(child, func);
	end
end

function AnimateWhileShownMixin:PlayAnims()
	IterateAllAnimationGroups(self, function(animGroup)
		if animGroup.PlaySynced then
			animGroup:PlaySynced();
		else
			animGroup:Play();
		end
	end);
end

function AnimateWhileShownMixin:StopAnims()
	IterateAllAnimationGroups(self, function(animGroup)
		animGroup:Stop();
	end);
end