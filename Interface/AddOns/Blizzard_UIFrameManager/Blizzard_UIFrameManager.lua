UIFrameManagerMixin = {};

function UIFrameManagerMixin:OnLoad()
	self.registeredFrames = {};
	self.registeredFrameTypeToFrames = {};

	self:RegisterEvent("FRAME_MANAGER_UPDATE_ALL");
	self:RegisterEvent("FRAME_MANAGER_UPDATE_FRAME");
end

function UIFrameManagerMixin:OnEvent(event, ...)
	if event == "FRAME_MANAGER_UPDATE_ALL" then
		for frameType, frames in pairs(self.registeredFrameTypeToFrames) do
			for frame, _ in pairs(frames) do
				frame:UpdateFrameState(C_FrameManager.GetFrameVisibilityState(frameType));
			end
		end
	else
		local frameType, show = ...;
		local frames = self.registeredFrameTypeToFrames[frameType];

		if frames then
			for frame, _ in pairs(frames) do
				frame:UpdateFrameState(show);
			end
		end
	end
end

function UIFrameManagerMixin:RegisterFrameForFrameType(frame, frameType)
	if self.registeredFrames[frame] then
		-- Each frame can only be registered once
		return;
	end

	if not self.registeredFrameTypeToFrames[frameType] then
		self.registeredFrameTypeToFrames[frameType] = {};
	end

	self.registeredFrameTypeToFrames[frameType][frame] = true;
	self.registeredFrames[frame] = true;

	frame:UpdateFrameState(C_FrameManager.GetFrameVisibilityState(frameType));
end

UIFrameManager_ManagedFrameMixin= {};

function UIFrameManager_ManagedFrameMixin:OnLoad()
	UIFrameManager:RegisterFrameForFrameType(self, self.frameType);
end

function UIFrameManager_ManagedFrameMixin:UpdateFrameState(show)
	self:SetShown(show);
end
