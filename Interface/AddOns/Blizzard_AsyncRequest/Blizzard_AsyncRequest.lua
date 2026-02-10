--[[
	Handles state and callbacks for asynchronous requests.

	General idea is:
		1. Specify a request and an event that signals the response. Also, provide a callback for the response event.
			1. Optionally, configure the maximum number of seconds to wait for the reseponse and an associated timeout callback.
		2. If the response event occurs within the (optional) time limit, run the callback function.
		3. Otherwise, if a timeout was configured and the request timed out, run the timeout callback.

	Input
	----------------------------------------------------------------------------------
	{
		requestFunction = Function that is the async request you are making,
		responseEventName = Name of the event that signals the function is complete,
		responseEventCallback = Function that will be called when the completion event occurs (forwards the event's output into the function's input),
		timeoutSeconds = (Optional) Number of seconds to wait before giving up and timing out,
		timeoutCallback = (Optional) Function that will be called if there is a timeout,
	}
	----------------------------------------------------------------------------------

	Create a new async request
	----------------------------------------------------------------------------------
	local asyncRequest = AsyncRequests:CreateAsyncRequest(myAsyncRequestInput);

	-- Some later time
	asyncRequest:StartRequest(myRequestInput);
	----------------------------------------------------------------------------------
--]]

----------------------------------------------------------------------------------
-- AsyncRequestMixin
----------------------------------------------------------------------------------
local AsyncRequestMixin = {};

function AsyncRequestMixin:Init(asyncRequestInput)
	Mixin(self, asyncRequestInput);

	-- Set up state
	self.isRunning = false;
	self.timeoutTimer = nil;
	self:SetScript("OnEvent",
		function(self, event, ...)
			if (event == self.responseEventName) then
				self.responseEventCallback(...);
				self:StopRequest();
			end
		end
	);
end

function AsyncRequestMixin:StartRequest(...)
	if (self.isRunning) then
		return;
	end
	self.isRunning = true;

	self:RegisterEvent(self.responseEventName);

	if (self.timeoutSeconds) then
		self.timeoutTimer = C_Timer.NewTimer(self.timeoutSeconds, function()
			self.timeoutCallback();
			self:StopRequest();
		end);
	end

	self.requestFunction(...);
end

function AsyncRequestMixin:StopRequest()
	self.isRunning = false;

	self:UnregisterEvent(self.responseEventName);

	if (self.timeoutTimer) then
		self.timeoutTimer:Cancel();
		self.timeoutTimer = nil;
	end
end

----------------------------------------------------------------------------------
-- AsyncRequests
----------------------------------------------------------------------------------
AsyncRequests = {};

function AsyncRequests:CreateAsyncRequest(asyncRequestInput)
	assertsafe(asyncRequestInput ~= nil);

	-- Required input
	assertsafe(asyncRequestInput.requestFunction ~= nil);
	assertsafe(asyncRequestInput.responseEventName ~= nil);
	assertsafe(asyncRequestInput.responseEventCallback ~= nil);

	-- Optional input, but you have to specify both or none
	assertsafe((asyncRequestInput.timeoutSeconds ~= nil and asyncRequestInput.timeoutCallback ~= nil)
				or (asyncRequestInput.timeoutSeconds == nil and asyncRequestInput.timeoutCallback == nil));

	-- TODO (WOW12-45327): See if this can be done without a Frame (see https://wowhub.corp.blizzard.net/warcraft/wow/pull/40310)
	local asyncRequest = Mixin(CreateFrame("Frame"), AsyncRequestMixin);
	asyncRequest:Init(asyncRequestInput);
	return asyncRequest;
end
