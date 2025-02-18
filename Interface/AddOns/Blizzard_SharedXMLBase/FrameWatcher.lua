FrameWatcher = {};

function FrameWatcher:Init()
	self.pool = CreateFramePool("Frame");
	self.watchedFrames = {};
end

function FrameWatcher:WatchFrame(frame, onShow, onHide)
	if not self.watchedFrames[frame] then
		local watcher = self.pool:Acquire();
		watcher:Show(); -- watcher always shows so that it matches parent shown state
		watcher:SetParent(frame);
		watcher:SetScript("OnShow", function(w)
			if onShow then
				onShow();
			end
		end);

		watcher:SetScript("OnHide", function(w)
			if onHide then
				onHide();
			end
		end);

		self.watchedFrames[frame] = { watcher = watcher }; -- Could do multiple watchers per frame
	end
end

function FrameWatcher:StopWatchingFrame(frame)
	if self.watchedFrames[frame] then
		local watcher = self.watchedFrames[frame].watcher;
		self.watchedFrames[frame] = nil;
		watcher:SetParent(nil);
		watcher:SetScript("OnShow", nil);
		watcher:SetScript("OnHide", nil);
		
		self.pool:Release(watcher);
	end
end

FrameWatcher:Init();