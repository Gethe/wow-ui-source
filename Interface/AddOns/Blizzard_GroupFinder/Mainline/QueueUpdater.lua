local QueueUpdaterMixin = {};

function QueueUpdaterMixin:RequestInfo()
	-- This API exists to preserve previous behavior.  If a frame requiring this information is shown, then this
	-- function always requests the desired info.
	RequestLFDPlayerLockInfo();
	RequestLFDPartyLockInfo();
end

function QueueUpdaterMixin:CheckRequestInfo()
	if self:HasRefCount() and C_LFGInfo.CanPlayerUseLFD() then
		self:RequestInfo();
	end
end

function QueueUpdaterMixin:AddRef()
	self.refCount = (self.refCount or 0) + 1;
end

function QueueUpdaterMixin:RemoveRef()
	self.refCount = self.refCount - 1;
end

function QueueUpdaterMixin:HasRefCount()
	return (self.refCount or 0) > 0;
end

function QueueUpdaterMixin:OnEvent(event, ...)
	self:CheckRequestInfo();
end

function QueueUpdaterMixin:OnLoad()
	self:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("PLAYER_LEVEL_UP");

	self:CheckRequestInfo();

	self:SetScript("OnEvent", self.OnEvent);
end

QueueUpdater = Mixin(CreateFrame("FRAME"), QueueUpdaterMixin);
QueueUpdater:OnLoad();