ContinuableContainer = {};

--[[
	Expected usage:

	local continuableContainer = ContinuableContainer:Create();
	local item = Item:CreateFromItemLocation(itemLoc);
	continuableContainer:AddContinuable(item);
	... add more continuables

	continuableContainer:ContinueOnLoad(function()
		-- code to execute once all continuables are ready, could be immediate
	end);
]]

--[[static]] function ContinuableContainer:Create()
	return CreateFromMixins(self);
end

function ContinuableContainer:AddContinuable(continuable)
	if not self.continuables or not self.evictableObjects then
		self.continuables = {};
		self.evictableObjects = {};

		self.onContinuableLoadedCallback = function()
			self.numOutstanding = self.numOutstanding - 1;
			self:CheckIfSatisifed();
		end;
	end

	self.numOutstanding = self:GetNumOutstandingLoads() + 1;
	if continuable:IsDataEvictable() then
		table.insert(self.evictableObjects, continuable);
	end
	table.insert(self.continuables, continuable:ContinueWithCancelOnItemLoad(self.onContinuableLoadedCallback));
end

function ContinuableContainer:ContinueOnLoad(callbackFunction)
	if type(callbackFunction) ~= "function" then
		error("Usage: ContinuableContainer:ContinueOnLoad(callbackFunction)", 2);
	end

	self.callbackFunction = callbackFunction;
	self:CheckIfSatisifed();
end

function ContinuableContainer:GetNumOutstandingLoads()
	return self.numOutstanding or 0;
end

function ContinuableContainer:AreAnyLoadsOutstanding()
	return self:GetNumOutstandingLoads() > 0;
end

function ContinuableContainer:Cancel()
	local continuables = self.continuables;
	if continuables then
		self.continuables = nil;
		self.evictableObjects = nil;

		for i, continuable in ipairs(continuables) do
			continuable();
		end
	end
end

-- "private"
function ContinuableContainer:CheckIfSatisifed()
	if not self:AreAnyLoadsOutstanding() and self.callbackFunction and self:RecheckEvictableContinuables() then
		local callbackFunction = self.callbackFunction;
		self.callbackFunction = nil;

		self.continuables = nil;
		self.evictableObjects = nil;

		xpcall(callbackFunction, CallErrorHandler);
	end
end

function ContinuableContainer:RecheckEvictableContinuables()
	local areAllLoaded = true;
	if self.evictableObjects then
		for i, evictableObject in ipairs(self.evictableObjects) do
			if not evictableObject:IsItemDataCached() then
				areAllLoaded = false;

				self.numOutstanding = self.numOutstanding + 1;
				table.insert(self.continuables, continuable:ContinueWithCancelOnItemLoad(self.onContinuableLoadedCallback));
			end
		end
	end
	return areAllLoaded;
end