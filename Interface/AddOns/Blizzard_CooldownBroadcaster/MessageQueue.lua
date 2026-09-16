local _, namespace = ...;

local MAX_TOKENS = 10;
local REFILL_RATE = 1;

local tokens = MAX_TOKENS;
local lastUpdate = GetTime();
local queue = {};


local function RefillTokens()
	local now = GetTime();
	local elapsed = now - lastUpdate;
	if elapsed > 0 then
		tokens = math.min(MAX_TOKENS, tokens + elapsed * REFILL_RATE);
		lastUpdate = now;
	end
end

local function Send(msg)
	C_Commentator.SendAddonMessage(
		msg.prefix,
		msg.message,
		msg.chatType,
		msg.target
	);
end

local function QueueEmpty()
	return #queue == 0;
end

local function Enqueue(msg)
	table.insert(queue, msg);
end

local function Dequeue()
	return table.remove(queue, 1);
end


local worker = CreateFrame("Frame");
worker:Hide();

worker:SetScript("OnUpdate", function(self)
	RefillTokens();

	while tokens >= 1 and not QueueEmpty() do
		local msg = Dequeue();
		Send(msg);
		tokens = tokens - 1;
	end

	if QueueEmpty() then
		self:Hide();
	end
end);

local function EnsureWorker()
	if not worker:IsShown() then
		worker:Show();
	end
end


local MessageQueue = {};

function MessageQueue.Send(prefix, message, chatType, target, key)
	RefillTokens();

	if tokens >= 1 and QueueEmpty() then
		Send({
			prefix = prefix,
			message = message,
			chatType = chatType,
			target = target,
		});
		tokens = tokens - 1;
		return true;
	end

	local msg = {
		prefix = prefix,
		message = message,
		chatType = chatType,
		target = target,
		key = key,
	};

	if key then
		for i, m in ipairs(queue) do
			if m.key == key then
				queue[i] = msg;
				return false;
			end
		end
	end

	Enqueue(msg);
	EnsureWorker();
	return false;
end

function MessageQueue.GetQueueSize()
	return #queue;
end

function MessageQueue.GetTokens()
	RefillTokens();
	return tokens;
end

namespace.MessageQueue = MessageQueue;
