-- These are functions that were deprecated in 8.1.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Tooltip Changes
do
	-- Use GameTooltip instead.
	WorldMapTooltip = GameTooltip;
end

-- Pool Collection Changes
do
	-- Use CreateFramePoolCollection instead.
	CreatePoolCollection = CreateFramePoolCollection;
	PoolCollection = FramePoolCollectionMixin;
end

-- PVP changes
do
	InActiveBattlefield = C_PvP.IsActiveBattlefield;
	HasInspectHonorData = function() return true; end;
	RequestInspectHonorData = function() return; end;
	C_PvP.GetBrawlInfo = function()
		local info = C_PvP.GetAvailableBrawlInfo();
		if info then
			info.active = info.canQueue;
		end
		return info;
	end
end

-- SocialUI changes
do
	C_Social.GetLastScreenshot = C_Social.GetLastScreenshotIndex;
	C_Social.GetScreenshotByIndex = function(index)
		local width, height = C_Social.GetScreenshotInfoByIndex(index);
		return width ~= nil, width, height;
	end
	C_Social.GetNumCharactersPerMedia = function()
		return 0; 
	end
end