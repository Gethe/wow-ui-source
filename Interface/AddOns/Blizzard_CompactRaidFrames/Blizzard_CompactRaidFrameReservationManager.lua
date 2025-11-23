

function CompactRaidFrameReservation_NewManager(releaseFunc)
	return { unusedFrames = {}, reservations = {}, releaseFunc = releaseFunc };
end

function CompactRaidFrameReservation_GetFrame(self, key)
	assert(key);
	local frame = self.reservations[key];
	if ( not frame and #self.unusedFrames > 0 ) then
		frame = tremove(self.unusedFrames, #self.unusedFrames);
		CompactRaidFrameReservation_RegisterReservation(self, frame, key);
	end
	return frame;
end

function CompactRaidFrameReservation_RegisterReservation(self, frame, key)
	assert(key);
	assert(not self.reservations[key] or self.reservations[key] == frame);
	self.reservations[key] = frame;
end

function CompactRaidFrameReservation_ReleaseUnusedReservations(self)
	for key, frame in pairs(self.reservations) do
		if ( frame and not frame.inUse ) then
			if ( self.releaseFunc ) then
				self.releaseFunc(frame);
			end
			self.reservations[key] = false;
			tinsert(self.unusedFrames, frame);
		end
	end
end

function CompactRaidFrameReservation_GetReservation(self, key)
	assert(key);
	return self.reservations[key];
end