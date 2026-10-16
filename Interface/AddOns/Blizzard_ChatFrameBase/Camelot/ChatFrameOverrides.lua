function ChatFrameMixin:PlayerLevelChanged(...)
end

function ChatFrameMixin:PlayerLevelUp(...)
	ChatFrameUtil.DisplayLevelUp(self, ...);
end
