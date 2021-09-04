------------------------------------------------------------------
-- Top Banner Display Manager
-- 
-- Manager for displaying large UI elements at the top of the HUD.
--
-- Frames that want to display must have the following functions defined:
-- PlayBanner(self, [data, [isExclusiveQueued]])
-- StopBanner(self)
--
-- The following functions are optional:
-- ResumeBanner(self) -- restart banner animation
--
------------------------------------------------------------------

TopBannerMgr = {};
TopBannerQueue = {};

function TopBannerManager_Show( frame, data, isExclusiveQueued )
	local banner = {frame = frame, data = data};
	if ( TopBannerMgr.currentBanner ) then
		-- queue up this frame to play later
		if( isExclusiveQueued ) then
			-- check if multiple instances of this frame should be queued
			for _, queuedBanner in pairs( TopBannerQueue ) do
				if( isExclusiveQueued( banner, queuedBanner ) ) then
					return;
				end
			end
		end
		table.insert( TopBannerQueue, banner );
	else
		TopBannerMgr.currentBanner = banner;
		frame:PlayBanner(data);
	end
end

function TopBannerManager_LoadingScreenEnabled()
	if ( TopBannerMgr.currentBanner ) then
		TopBannerMgr.currentBanner.frame:StopBanner();
		
		TopBannerQueue = {}; -- clear out banner queue;
	end
end

function TopBannerManager_LoadingScreenDisabled()
	local currentBanner = TopBannerMgr.currentBanner;
	if ( currentBanner and currentBanner.frame.ResumeBanner ) then
		currentBanner.frame:ResumeBanner(currentBanner.data);
	else
		TopBannerMgr.currentBanner = nil;
	end
end

function TopBannerManager_BannerFinished()
	if( #TopBannerQueue > 0 ) then
		TopBannerMgr.currentBanner = table.remove(TopBannerQueue, 1);
		TopBannerMgr.currentBanner.frame:PlayBanner(TopBannerMgr.currentBanner.data);
	else
		TopBannerMgr.currentBanner = nil;
	end
end

function TopBannerManager_IsIdle()
	return TopBannerMgr.currentBanner == nil;
end