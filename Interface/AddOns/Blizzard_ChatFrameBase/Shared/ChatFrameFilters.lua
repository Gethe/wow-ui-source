local _, addonTbl = ...;

local canaccessvalue = canaccessvalue;
local securecallfunction = securecallfunction;

function ChatFrameUtil.CreateSenderNameFilterRegistry()
	local filters = SecureTypes.CreateSecureArray();
	local registry = {};

	local function FindFilterByCallback(originalCallback)
		local function Predicate(filter)
			return filter.originalCallback == originalCallback;
		end

		return filters:FindInTableIf(Predicate);
	end

	local function SecureGetWrappedCallback(filter)
		return filter.wrappedCallback;
	end

	local function GetWrappedCallback(filter)
		return securecallfunction(SecureGetWrappedCallback, filter);
	end

	function registry:AddFilter(callback)
		-- For insecure callers, this ApplyFilter closure captures current
		-- execution taint at the point of creation.
		--
		-- When ApplyFilter is called, that stored taint then re-activates and
		-- applies to execution. If at that point we determine that we can't
		-- access the (potentially secret) decorated player name, we'll skip
		-- evaluating the (tainted) user-supplied callback function because
		-- it's highly unlikely that it'd be able to do anything with the data.

		local function ApplyFilter(event, decoratedPlayerName, ...)
			if canaccessvalue(decoratedPlayerName) then
				return callback(event, decoratedPlayerName, ...);
			else
				return decoratedPlayerName;
			end
		end

		if not FindFilterByCallback(callback) then
			filters:Insert({ wrappedCallback = ApplyFilter, originalCallback = callback });
		end
	end

	function registry:RemoveFilter(callback)
		local index = FindFilterByCallback(callback);

		if index then
			filters:Remove(index);
		end
	end

	function registry:ProcessFilters(event, decoratedPlayerName, ...)
		for _, filter in filters:Enumerate() do
			local newDecoratedPlayerName = securecallfunction(GetWrappedCallback(filter), event, decoratedPlayerName, ...);

			-- Callbacks can return nil to skip processing a message without
			-- replacing the name. The nil case will also occur if the
			-- callback function errored.

			if newDecoratedPlayerName ~= nil then
				decoratedPlayerName = newDecoratedPlayerName;
			end
		end

		return decoratedPlayerName;
	end

	return registry;
end

function ChatFrameUtil.CreateMessageEventFilterRegistry()
	local filtersByEvent = SecureTypes.CreateSecureMap();
	local registry = {};

	local function GetFiltersForEvent(event)
		local callbacks = filtersByEvent[event];
		return callbacks;
	end

	local function GetOrCreateFiltersForEvent(event)
		local filters = filtersByEvent[event];

		if not filters then
			filters = addonTbl.CreateSecureFiltersArray();
			filtersByEvent[event] = filters;
		end

		return filters;
	end

	local function FindFilterByCallback(filters, originalCallback)
		local function Predicate(filter)
			return filter.originalCallback == originalCallback;
		end

		return filters:FindInTableIf(Predicate);
	end

	local function SecureGetWrappedCallback(filter)
		return filter.wrappedCallback;
	end

	local function GetWrappedCallback(filter)
		return securecallfunction(SecureGetWrappedCallback, filter);
	end

	function registry:AddFilter(event, callback)
		local callbacks = GetOrCreateFiltersForEvent(event);

		local function ApplyFilter(chatFrame, event, ...)
			if canaccessvalue(...) then
				return callback(chatFrame, event, ...);
			end
		end

		if not FindFilterByCallback(callbacks, callback) then
			callbacks:Insert({ wrappedCallback = ApplyFilter, originalCallback = callback });
		end
	end

	function registry:RemoveFilter(event, callback)
		local callbacks = GetFiltersForEvent(event);

		if callbacks then
			local index = FindFilterByCallback(callbacks, callback);

			if index then
				callbacks:Remove(index);
			end
		end
	end

	function registry:ProcessFilters(chatFrame, event, ...)
		local filters = GetFiltersForEvent(event);
		local shouldDiscardMessage = false;
		
		if not filters or filters:IsEmpty() then
			return shouldDiscardMessage, ...;
		end

		local transformedArguments = SafePack(...);

		for _, filter in filters:Enumerate() do
			local results = SafePack(securecallfunction(GetWrappedCallback(filter), chatFrame, event, SafeUnpack(transformedArguments)));

			-- The first return value from callbacks is expected to be
			-- a boolean that indicates if we should entirely filter out
			-- this message.

			shouldDiscardMessage = results[1];
			if shouldDiscardMessage then
				break;
			end

			-- The second return onwards replace the arguments we fed into
			-- the callback. An exception to this is if the callback returns
			-- a nil or false value as the second return value, which acts
			-- as a signal to skip and continue running other filters.

			if results[2] then
				transformedArguments = SafePack(SafeUnpack(results, 2));
			end
		end

		return shouldDiscardMessage, SafeUnpack(transformedArguments);
	end

	return registry;
end

local senderNameFilters = ChatFrameUtil.CreateSenderNameFilterRegistry();
local messageEventFilters = ChatFrameUtil.CreateMessageEventFilterRegistry();

function ChatFrameUtil.GetSenderNameFilters()
	return senderNameFilters;
end

function ChatFrameUtil.AddSenderNameFilter(callback)
	local filters = ChatFrameUtil.GetSenderNameFilters();
	filters:AddFilter(callback);
end

function ChatFrameUtil.RemoveSenderNameFilter(callback)
	local filters = ChatFrameUtil.GetSenderNameFilters();
	filters:RemoveFilter(callback);
end

function ChatFrameUtil.ProcessSenderNameFilters(event, decoratedPlayerName, ...)
	local filters = ChatFrameUtil.GetSenderNameFilters();
	return filters:ProcessFilters(event, decoratedPlayerName, ...);
end

function ChatFrameUtil.GetMessageEventFilters()
	return messageEventFilters;
end

function ChatFrameUtil.AddMessageEventFilter(event, callback)
	local filters = ChatFrameUtil.GetMessageEventFilters();
	filters:AddFilter(event, callback);
end

function ChatFrameUtil.RemoveMessageEventFilter(event, callback)
	local filters = ChatFrameUtil.GetMessageEventFilters();
	filters:RemoveFilter(event, callback);
end

function ChatFrameUtil.ProcessMessageEventFilters(chatFrame, event, ...)
	local filters = ChatFrameUtil.GetMessageEventFilters();
	return filters:ProcessFilters(chatFrame, event, ...);
end
