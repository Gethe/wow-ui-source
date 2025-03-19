--[[
	Queries some data retrieval API (specifically where the data may not be currently available) and when it becomes available
	calls a user-supplied function.  The callback can be canceled if necessary (e.g. the frame that would use the data becomes
	hidden before the data arrives).

	The API is managed so that arbitrary query functions cannot be executed.
--]]

AsyncCallbackAPIType = {
	ASYNC_QUEST = 1,
	ASYNC_ITEM = 2,
	ASYNC_SPELL = 3,
}

local permittedAPI =
{
	[AsyncCallbackAPIType.ASYNC_QUEST] = { event = "QUEST_DATA_LOAD_RESULT", accessor =  C_QuestLog.RequestLoadQuestByID },
	[AsyncCallbackAPIType.ASYNC_ITEM] = { event = "ITEM_DATA_LOAD_RESULT", accessor =  C_Item.RequestLoadItemDataByID },
	[AsyncCallbackAPIType.ASYNC_SPELL] = { event = "SPELL_DATA_LOAD_RESULT", accessor =  C_Spell.RequestLoadSpellData },
};

AsyncCallbackSystemMixin = {};

function AsyncCallbackSystemMixin:Init(apiType)
	self.callbacks = {};

	-- API Type should be set up from key value pairs before OnLoad.
	self.api = permittedAPI[apiType];

	self:SetScript("OnEvent",
		function(self, event, ...)
			if event == self.api.event then
				local id, success = ...;
				if success then
					self:FireCallbacks(id);
				else
					self:ClearCallbacks(id);
				end
			end
		end
	);
	self:RegisterEvent(self.api.event);
end

local CANCELED_SENTINEL = -1;

function AsyncCallbackSystemMixin:AddCallback(id, callbackFunction)
	local callbacks = self:GetOrCreateCallbacks(id);
	table.insert(callbacks, callbackFunction);
	local needsAccessorCall = #callbacks == 1;
	if needsAccessorCall then
		self.api.accessor(id);
	end

	return #callbacks, callbacks;
end

function AsyncCallbackSystemMixin:AddCancelableCallback(id, callbackFunction)
	-- NOTE: If the data is currently availble then the callback will be executed and callbacks cleared, so there will be nothing to cancel.
	local index, callbacks = self:AddCallback(id, callbackFunction);
	return function()
		if #callbacks > 0 and callbacks[index] ~= CANCELED_SENTINEL then
			callbacks[index] = CANCELED_SENTINEL;
			return true;
		end
		return false;
	end;
end

function AsyncCallbackSystemMixin:FireCallbacks(id)
	local callbacks = self:GetCallbacks(id);
	if callbacks then
		self:ClearCallbacks(id);
		for i, callback in ipairs(callbacks) do
			if callback ~= CANCELED_SENTINEL then
				xpcall(callback, CallErrorHandler);
			end
		end

		-- The cancel functions have a reference to this table, so ensure that it's cleared out.
		for i = #callbacks, 1, -1 do
			callbacks[i] = nil;
		end
	end
end

function AsyncCallbackSystemMixin:ClearCallbacks(id)
	self.callbacks[id] = nil;
end

function AsyncCallbackSystemMixin:GetCallbacks(id)
	return self.callbacks[id];
end

function AsyncCallbackSystemMixin:GetOrCreateCallbacks(id)
	local callbacks = self.callbacks[id];
	if not callbacks then
		callbacks = {};
		self.callbacks[id] = callbacks;
	end
	return callbacks;
end

local function CreateListener(apiType)
	local listener = Mixin(CreateFrame("Frame"), AsyncCallbackSystemMixin);
	listener:Init(apiType);
	return listener;
end

ItemEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_ITEM);
SpellEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_SPELL);
QuestEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_QUEST);
