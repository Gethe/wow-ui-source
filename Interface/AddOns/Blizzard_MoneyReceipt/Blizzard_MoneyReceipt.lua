local ReceiptMixin = {};

function ReceiptMixin:OnLoad()
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
	self:SetScript("OnEvent", self.OnEvent);
end

do
	local eventToTrackingType =
	{
		PLAYER_INTERACTION_MANAGER_FRAME_SHOW = "begin",
		PLAYER_INTERACTION_MANAGER_FRAME_HIDE = "end",
	};

	local relevantInteractionTypes =
	{
		[Enum.PlayerInteractionType.Merchant] = true,
		[Enum.PlayerInteractionType.MailInfo] = true,
	};

	local function GetTrackingEventType(event, interactionType)
		if relevantInteractionTypes[interactionType] then
			return eventToTrackingType[event];
		end
	end

	function ReceiptMixin:OnEvent(event, ...)
		local trackingType = GetTrackingEventType(event, ...);
		if trackingType == "begin" then
			self:BeginTracking();
		elseif trackingType == "end" then
			self:EndTracking();
		end
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



