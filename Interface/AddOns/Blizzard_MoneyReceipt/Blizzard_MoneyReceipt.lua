local ReceiptMixin = {};

function ReceiptMixin:OnLoad()
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MAIL_SHOW");
	self:RegisterEvent("MAIL_CLOSED");
	self:SetScript("OnEvent", self.OnEvent);
end

local beginTrackingEvents = {
	MERCHANT_SHOW = true,
	MAIL_SHOW = true,
};

local endTrackingEvents = {
	MERCHANT_CLOSED = true,
	MAIL_CLOSED = true,
};

function ReceiptMixin:OnEvent(event, ...)
	if beginTrackingEvents[event] then
		self:BeginTracking();
	elseif endTrackingEvents[event] then
		self:EndTracking();
	end
end

function ReceiptMixin:BeginTracking()
	if not self.startingMoney then
		self.startingMoney = GetMoney();
	end
end

function ReceiptMixin:EndTracking()
	self:Display();
	self:Clear();
end

function ReceiptMixin:Clear()
	self.startingMoney = nil;
end

function ReceiptMixin:Display()
	if self.startingMoney then
		local delta = GetMoney() - self.startingMoney;
		if delta > 0 then
			ChatFrame_DisplaySystemMessageInPrimary(GENERIC_MONEY_GAINED_RECEIPT:format(GetMoneyString(delta, true)));
		end
	end
end

local ReceiptDisplay = Mixin(CreateFrame("FRAME"), ReceiptMixin);
ReceiptDisplay:OnLoad();



