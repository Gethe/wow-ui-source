--[[ 
	Any file using ProxyUtil needs to have local references to each function in the event
	an addon tries to replace them eo expose the private objects.
--]]

local NewTicker = C_Timer.NewTicker;
local nop = function(obj) end
local securecall = securecall;
local setmetatable = setmetatable;
local ipairs = ipairs;

local ProxyTags = {};
setmetatable(ProxyTags, { __mode = 'k' });

local ReportFrequency = 120;

ProxyUtil = {};

function ProxyUtil.SetPrivateReference(proxy, obj)
	--[[ 
	Wrap a reference to the object via closure to prevent it from being gc'ed without exposing 
	a reference to the object externally. The object will be released once all references to the 
	proxy are released. See comment below for debugging.
	--]]
	proxy.private = function()
		return nop(obj);
	end;
	
	-- Uncomment only during debugging if you need to easily access the object.
	--proxy.private_debug = obj;
end

function ProxyUtil.ReleasePrivateReference(proxy)
	--assert(proxy.private ~= nil, "Private reference was expected, but not set.");
	proxy.private = nil;
end

--[[
Proxies are always be created using CreateProxy. This is important so that the underlying
object references are retained correctly.
--]]

local SetPrivateReference = ProxyUtil.SetPrivateReference;

function ProxyUtil.CreateProxy(obj, mixin)
	--assert(mixin.__index == mixin);
	local proxy = {};

	SetPrivateReference(proxy, obj);

	-- Assign the mixin as a metatable to the proxy.
	setmetatable(proxy, mixin);
	return proxy;
end

--[[
Helper to convert from an object to it's proxy equivalent, and to provide
an API as an alternative to using '.proxy' references.
]]--
ProxyConvertableMixin = {};

function ProxyConvertableMixin:Init(proxy, proxies, permitOverwrite)
	--assert(proxy ~= nil, "ProxyConvertableMixin:Init(): Proxy was nil");
	--assert(proxy.private ~= nil, "Proxy must be created using CreateProxy.");
	self.proxy = proxy;

	proxies:AddProxy(self, permitOverwrite);
	return ProxyTags;
end

local function GetProxy(tbl)
	return tbl.proxy;
end

function ProxyConvertableMixin:ToProxy()
	--assert(self.proxy ~= nil, "ProxyConvertableMixin:ToProxy(): Proxy was nil");
	return securecall(GetProxy, self);
end

--[[
The proxy directory stores all of the proxies and prevents them from being gc'ed independently of each other.
]]
function ProxyUtil.CreateProxyDirectory(name, enableReporting)
	local tbl = {};

	--[[
	An explaination into the use of the 'kv' weak mode here:
	
	Each object uses the ProxyConvertableMixin to store a reference to the proxy when initialized, and
	every proxy stores a reference wrapper to the object. This ensures convertability between each without
	risk of either being gc'ed without the other. Because this table is 'kv', it's references are excluded
	from gc consideration. Once all external references have released the pair of objects, they will be
	gc'ed together.
	--]]

	setmetatable(tbl, { __mode = 'kv' });

	local Proxies = {};

	function Proxies:AddProxy(object, permitOverwrite)
		--assert(object ~= nil, "Proxies:AddProxy(): Object is nil.");
		--assert(object.ToProxy ~= nil, "AddProxy(): Object appears not to have inherited from ProxyConvertableMixin");
		local proxy = object:ToProxy();
		--assert(proxy ~= nil, "Proxies:AddProxy(): Object:ToProxy() returned nil. Ensure the ProxyConvertableMixin's Init function was called in the object's initializer.");

		-- Ensure this proxy is unique and that an object was passed so the
		-- value isn't accidentally cleared.
		--assert(permitOverwrite or (tbl[proxy] == nil), "Proxies:AddProxy(): Proxy already exists.");
		tbl[proxy] = object;
	end
	
	function Proxies:RemoveProxy(proxy)
		-- Ensure this proxy was present so code expected to be being removing
		-- a proxy actually is.
		--assert(tbl[proxy], "Proxies:RemoveProxy(): Proxy doesn't exist.");
		tbl[proxy] = nil;
	end

	function Proxies:ToPrivate(proxy)
		--assert(tbl[proxy], "Proxies:ToPrivate(): Object doesn't exist for this proxy.");
		return tbl[proxy];
	end
	
	function Proxies:Contains(proxy)
		return tbl[proxy] ~= nil;
	end

	-- For garbage collection debugging only.
	if enableReporting then
		local counter = 1;

		NewTicker(ReportFrequency, function()
			local byTags = {};
			for k, v in pairs(tbl) do
				local tag = ProxyTags[k] or "Unassigned";
				byTags[tag] = (byTags[tag] and (byTags[tag] + 1)) or 1;
			end

			if print and Dump then
				print("#", counter, " Proxies:", name, CountTable(tbl), Proxies);
				Dump(byTags);
			end

			counter = counter + 1;
		end);
	end

	return Proxies;
end

do
	--[[
	local function TryConvertArgsToPrivate(proxyCollection, arg, ...)
		if arg == nil and (select("#", ...) == 0) then
			return nil;
		end

		local private = proxyCollection:ToPrivate(arg);
		if private then
			return private, TryConvertArgsToPrivate(proxyCollection, ...);
		end
		return arg, TryConvertArgsToPrivate(proxyCollection, ...);
	end

	local function TryConvertArgsToProxy(arg, ...)
		if arg == nil and (select("#", ...) == 0) then
			return nil;
		end

		if type(arg) == "table" and arg.ToProxy then
			return arg:ToProxy(), TryConvertArgsToProxy(...);
		end
		return arg, TryConvertArgsToProxy(...);
	end
	]]--

	--[[
	CreateProxyMixin creates a mixin to describe a proxy to a private object whose purpose is to prevent or limit access 
	to the private objects internal details or API. The desired APIs on the proxy are exposed by creating wrapper 
	functions that convert the arguments between proxy and private form. If a proxy mixin is created, it should be
	expected that the private mixin is intended to be completely internal to a system.

	An extra implementation goal is to make it more difficult to accidentally expose the private object
	to external callsites when forwarding arguments between both forms.

	Note that `convertFuncs` has been removed from the signature because of perf concerns and have been written
	regularly instead.
	
	For example, this code would create the HandleGlobalMouseEvent and OpenMenu below:

	local funcs = {"OpenMenu"};
	local convertFuncs = {"HandleGlobalMouseEvent"};
	local MenuManagerProxyMixin = ProxyUtil.CreateProxyMixin(Proxies, MenuManagerMixin, convertFuncs, funcs);

	function MenuManagerProxyMixin:OpenMenu(ownerRegion, menuDescriptionProxy, anchor)
		-- Convert the description and menu manager to private objects:
		local menuDescription = Proxies:ToPrivate(menuDescriptionProxy);
		local menuManager = Proxies:ToPrivate(self);

		-- Call the desired function:
		local menuPrivate = menuManager:OpenMenu(ownerRegion, menuDescription, anchor);

		-- Convert the menu back to a proxy before returning.
		local menuProxy = menuPrivate:ToProxy();
		return menuProxy;
	end

	-- See 'convertFuncs' note above.
	function MenuManagerProxyMixin:HandleGlobalMouseEvent(buttonName, event)
		local menuManager = Proxies:ToPrivate(self);
		local handled = menuManager:HandleGlobalMouseEvent(buttonName, event);
		return handled;
	end
	]]--

	--function ProxyUtil.CreateProxyMixin(proxyCollection, privateMixin, funcs, convertFuncs)
	function ProxyUtil.CreateProxyMixin(proxyCollection, privateMixin, funcs)
		local mixin = {};
	
		for index, funcString in ipairs(funcs) do
			--assert(type(funcString) == "string", "Function expected as a string.");
	
			local func = privateMixin[funcString];
			--assert(type(func) == "function", string.format("Function %s could not be found.", funcString));
	
			mixin[funcString] = function(self, ...)
				return func(proxyCollection:ToPrivate(self), ...);
			end;
		end

		--[[
		Wrappers for 'convertFuncs' are no longer generated to avoid undesireable perf related to
		TryConvertArgsToProxy and TryConvertArgsToPrivate. See 'convertFuncs' note above.

		for index, funcString in ipairs(convertFuncs) do

			--assert(type(funcString) == "string", "Function expected as a string.");
		
			local func = privateMixin[funcString];
			--assert(type(func) == "function", string.format("Function %s could not be found.", funcString));
		
			mixin[funcString] = function(self, ...)
				local object = proxyCollection:ToPrivate(self);
		
				return TryConvertArgsToProxy(func(object, TryConvertArgsToPrivate(proxyCollection, ...)));
			end;
		end
		]]--

		return mixin;
	end
end