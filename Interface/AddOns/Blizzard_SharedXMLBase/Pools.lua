local SpecializeFrameWithMixins = FrameUtil.SpecializeFrameWithMixins;
local CreateSecureMap = SecureTypes.CreateSecureMap;
local CreateSecureStack = SecureTypes.CreateSecureStack;
local CreateSecureNumber = SecureTypes.CreateSecureNumber;
local CreateProxy = ProxyUtil.CreateProxy;
local CreateProxyDirectory = ProxyUtil.CreateProxyDirectory;
local CreateProxyMixin = ProxyUtil.CreateProxyMixin;
local SetPrivateReference = ProxyUtil.SetPrivateReference;
local ReleasePrivateReference = ProxyUtil.ReleasePrivateReference;
local ProxyConvertablePrivateMixin = CreateFromMixins(ProxyConvertableMixin);
local CreateFromMixinsPrivate = CreateFromMixins;

local enableProxyReporting = false; -- For debugging purposes only.
local Proxies = CreateProxyDirectory("Pools.lua", enableProxyReporting);

local ObjectPoolBaseMixin = {};

--[[
Reserve() is not exposed on the pool to prevent the attack vector of addons having control 
over the quantity of objects available to a preexisting pool.
]]--
local function Reserve(pool, capacity)
	pool.capacity = capacity or math.huge;

	if pool.capacity ~= math.huge then
		for index = 1, pool.capacity do
			pool:Acquire();
		end
		pool:ReleaseAll();
	end
end

local function GetObjectIsInvalidMsg(object, poolCollection)
	return string.format("Attempted to release inactive object '%s'", tostring(object));
end

function ObjectPoolBaseMixin:Acquire()
	if self:GetNumActive() == self.capacity then
		return nil, false;
	end

	local object = self:PopInactiveObject();
	local new = object == nil;
	if new then
		object = self:CallCreate();

		--[[
		While pools don't necessarily need to only contain tables, support for other types
		has not been tested, and therefore isn't allowed until we can justify a use for them.
		]]--
		assert(type(object) == "table");

		--[[
		The reset function will error if forbidden actions are attempted insecurely,
		particularly in scenarios involving forbidden and protected frames. If an error
		is thrown, it will do so before we make any further modifications to this pool.

		Note this does create a potential for a dangling frame or region, but that is less of a
		concern than mutating the pool.
		]]--
		self:CallReset(object, new);
	end

	self:AddObject(object);
	return object, new;
end

function ObjectPoolBaseMixin:Release(object, canFailToFindObject)
	local active = self:IsActive(object);

	--[[
	If Release() is called on a pool directly from external code, then we expect
	an assert if the object is not found. However, if it was called from a pool
	collection, the object not being active is expected as the pool collection iterates
	all the pools until it is found. A separate assert in pool collections accounts for
	the case where the object was not found in any pool.
	]]--
	if not canFailToFindObject then
		assertsafe(active, GetObjectIsInvalidMsg, object, self);
	end

	if active then
		--[[
		The reset function will error if forbidden actions are attempted insecurely,
		particularly in scenarios involving forbidden and protected frames. If an error
		is thrown, it will do so before we make any further modifications to this pool.
		]]--
		self:CallReset(object);

		self:ReclaimObject(object);
	end

	return active;
end

function ObjectPoolBaseMixin:Dump()
	for index, object in self:EnumerateActive() do
		print(tostring(object));
	end
end

--[[
ObjectPoolMixin is not exposed for use at this time. All code requiring pools or
pool collections are currently using the secure variants. If you need a proxyless pool
for any reason, you'll need to expose a function to create this.

You'll also need to create a PoolCollectionMixin that doesn't make use of any secure types.
]]--
local ObjectPoolMixin = CreateFromMixinsPrivate(ObjectPoolBaseMixin);

function ObjectPoolMixin:Init(createFunc, resetFunc, capacity)
	self.createFunc = createFunc;
	self.resetFunc = resetFunc;
	self.activeObjects = {};
	self.inactiveObjects = {};
	self.activeObjectCount = 0;
	
	Reserve(self, capacity);
end

function ObjectPoolMixin:CallReset(object, new)
	self.resetFunc(self, object, new);
end

function ObjectPoolMixin:CallCreate()
	-- The pool argument 'self' is passed only for addons already reliant on it.
	return self.createFunc(self);
end

function ObjectPoolMixin:PopInactiveObject()
	return tremove(self.inactiveObjects);
end

function ObjectPoolMixin:AddObject(object)
	local dummy = true;
	self.activeObjects[object] = dummy;
	self.activeObjectCount = self.activeObjectCount + 1;
end

function ObjectPoolMixin:ReclaimObject(object)
	tinsert(self.inactiveObjects, object);
	self.activeObjects[object] = nil;
	self.activeObjectCount = self.activeObjectCount - 1;
end

function ObjectPoolMixin:ReleaseAll()
	for object in pairs(self.activeObjects) do
		self:Release(object);
	end
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects);
end

function ObjectPoolMixin:GetNextActive(current)
	return next(self.activeObjects, current);
end

function ObjectPoolMixin:IsActive(object)
	return self.activeObjects[object] ~= nil;
end

function ObjectPoolMixin:GetNumActive()
	return self.activeObjectCount;
end

local SecureObjectPoolMixin = CreateFromMixinsPrivate(ObjectPoolBaseMixin, ProxyConvertablePrivateMixin);

function SecureObjectPoolMixin:Init(proxy, createFunc, resetFunc, capacity)
	local tags = ProxyConvertablePrivateMixin.Init(self, proxy, Proxies);
	tags[proxy] = "SecureObjectPoolMixin";

	self.createFunc = createFunc;
	self.resetFunc = resetFunc;
	self.activeObjects = CreateSecureMap();
	self.inactiveObjects = CreateSecureStack();
	self.activeObjectCount = CreateSecureNumber();
	
	Reserve(self, capacity);
end

function SecureObjectPoolMixin:CallReset(object, new)
	self.resetFunc(self:ToProxy(), object, new);
end

function SecureObjectPoolMixin:CallCreate()
	return self.createFunc(self:ToProxy());
end

function SecureObjectPoolMixin:PopInactiveObject()
	return self.inactiveObjects:Pop();
end

function SecureObjectPoolMixin:AddObject(object)
	local dummy = true;
	self.activeObjects:SetValue(object, dummy);
	self.activeObjectCount:Increment();
end

function SecureObjectPoolMixin:ReclaimObject(object)
	self.inactiveObjects:Push(object);
	self.activeObjects:ClearValue(object);
	self.activeObjectCount:Decrement();
end

function SecureObjectPoolMixin:ReleaseAll()
	for object in self.activeObjects:Enumerate() do
		self:Release(object);
	end
end

function SecureObjectPoolMixin:EnumerateActive()
	return self.activeObjects:Enumerate();
end

function SecureObjectPoolMixin:GetNextActive(current)
	return self.activeObjects:GetNext(current);
end

function SecureObjectPoolMixin:IsActive(object)
	return self.activeObjects:HasKey(object);
end

function SecureObjectPoolMixin:GetNumActive()
	return self.activeObjectCount:GetValue();
end

local ObjectPoolProxyMixin;
do
	local Funcs =
	{
		"Acquire",
		"ReleaseAll",
		"Release",
		"EnumerateActive",
		"GetNextActive",
		"IsActive",
		"GetNumActive",
	};

	ObjectPoolProxyMixin = CreateProxyMixin(Proxies, SecureObjectPoolMixin, Funcs);
	ObjectPoolProxyMixin.__index = ObjectPoolProxyMixin;
end

local function GetPoolKey(template, specialization)
	if specialization == nil then
		return template.."nil";
	end
	return template..tostring(specialization);
end

local PoolCollectionBaseMixin = {};

function PoolCollectionBaseMixin:GetPool(template, specialization)
	local poolKey = GetPoolKey(template, specialization);
	return self:GetPoolByKey(poolKey);
end

function PoolCollectionBaseMixin:HasPool(poolKey)
	return self:GetPoolByKey(poolKey) ~= nil;
end

function PoolCollectionBaseMixin:Acquire(template, specialization)
	local pool = self:GetPool(template, specialization);
	return pool:Acquire();
end

function PoolCollectionBaseMixin:ReleaseAllByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		pool:ReleaseAll();
	end
end

function PoolCollectionBaseMixin:EnumerateActiveByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		return pool:EnumerateActive();
	end

	return nop;
end

function PoolCollectionBaseMixin:GetOrCreatePool(...)
	assert(false);
end

function PoolCollectionBaseMixin:CreatePool(...)
	assert(false);
end

function PoolCollectionBaseMixin:CreatePoolWithArgs(args)
	local poolKey = self:CreatePoolKeyFromPoolArgs(args);
	assert(not self:HasPool(poolKey));

	local pool = self:CreatePoolInternal(args);
	self:SetPool(poolKey, pool);
	return pool;
end

function PoolCollectionBaseMixin:GetOrCreatePoolWithArgs(args)
	local poolKey = self:CreatePoolKeyFromPoolArgs(args);
	local pool = self:GetPoolByKey(poolKey);
	local new = pool == nil;
	if new then
		pool = self:CreatePoolWithArgs(args);
	end
	return pool, new;
end

function PoolCollectionBaseMixin:Dump()
	for object in self:EnumerateActive() do
		print(tostring(object));
	end
end

local PoolCollectionMixin = CreateFromMixinsPrivate(PoolCollectionBaseMixin);

function PoolCollectionMixin:Init(proxy)
	self.pools = {};
end

function PoolCollectionMixin:GetNumActive()
	local total = 0;
	for poolKey, pool in pairs(self.pools) do
		total = total + pool:GetNumActive();
	end
	return total;
end

function PoolCollectionMixin:SetPool(poolKey, pool)
	self.pools[poolKey] = pool;
end

function PoolCollectionMixin:GetPoolByKey(poolKey)
	return self.pools[poolKey];
end

function PoolCollectionMixin:Release(object)
	local canFailToFindObject = true;
	for poolKey, pool in pairs(self.pools) do
		if pool:Release(object, canFailToFindObject) then
			return;
		end
	end
	assertsafe(false, GetObjectIsInvalidMsg, object, self);
end

function PoolCollectionMixin:ReleaseAll()
	for poolKey, pool in pairs(self.pools) do
		pool:ReleaseAll();
	end
end

-- Warning: this function only returns the object, unlike a pool that also returns the key.
function PoolCollectionMixin:EnumerateActive()
	local currentObject = nil;
	local currentPoolKey, currentPool = next(self.pools, currentObject);
	return function()
		if currentPool then
			currentObject = currentPool:GetNextActive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey)
				if currentPool then
					currentObject = currentPool:GetNextActive(nil);
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end

local SecurePoolCollectionMixin = CreateFromMixinsPrivate(PoolCollectionBaseMixin, ProxyConvertablePrivateMixin);

function SecurePoolCollectionMixin:Init(proxy)
	local tags = ProxyConvertablePrivateMixin.Init(self, proxy, Proxies);
	tags[proxy] = "SecurePoolCollectionMixin";

	self.pools = CreateSecureMap();
end

do
	local function Accumulate(poolKey, pool, total)
		total:Add(pool:GetNumActive());
	end

	function SecurePoolCollectionMixin:GetNumActive()
		local total = CreateSecureNumber();
		self.pools:ExecuteRange(Accumulate, total);
		return total:GetValue();
	end
end

function SecurePoolCollectionMixin:SetPool(poolKey, pool)
	self.pools:SetValue(poolKey, pool);
end

function SecurePoolCollectionMixin:GetPoolByKey(poolKey)
	return self.pools:GetValue(poolKey);
end

function SecurePoolCollectionMixin:Release(object)
	local canFailToFindObject = true;
	for poolKey, pool in self.pools:Enumerate() do
		if pool:Release(object, canFailToFindObject) then
			return;
		end
	end
	assertsafe(false, GetObjectIsInvalidMsg, object, self);
end

do
	-- Taint protection reading insecure pool
	local function ReleaseAll(poolKey, pool)
		pool:ReleaseAll();
	end

	function SecurePoolCollectionMixin:ReleaseAll()
		self.pools:ExecuteRange(ReleaseAll);
	end
end

do
	-- Taint protection reading insecure pool
	local function GetNextActive(pool, currentObject)
		return pool:GetNextActive(currentObject);
	end

	-- Warning: this function only returns the object, unlike a pool that also returns the key.
	function SecurePoolCollectionMixin:EnumerateActive()
	local currentObject = nil;
		local currentPoolKey, currentPool = self.pools:GetNext(currentObject);
		return function()
			if currentPool then
					currentObject = securecallfunction(GetNextActive, currentPool, currentObject);
				while not currentObject do
						currentPoolKey, currentPool = self.pools:GetNext(currentPoolKey);
					if currentPool then
							currentObject = securecallfunction(GetNextActive, currentPool, nil);
					else
						break;
					end
				end
			end

			return currentObject;
		end, nil;
	end
end

function Pool_HideAndClearAnchors(pool, region)
	region:Hide();
	region:ClearAllPoints();
end

local function CreateSecureObjectPoolInstance(createFunc, resetFunc, capacity)
	local pool = CreateFromMixinsPrivate(SecureObjectPoolMixin);
	local proxy = CreateProxy(pool, ObjectPoolProxyMixin);
	pool:Init(proxy, createFunc, resetFunc or nop, capacity);
	return pool;
end

local function CreateSecureRegionPoolInstance(template, createFunc, resetFunc, capacity)
	local pool = CreateSecureObjectPoolInstance(createFunc, resetFunc or Pool_HideAndClearAnchors, capacity);
	local proxy = pool:ToProxy();
	proxy.GetTemplate = function(self)
		return template;
	end

	return pool;
end

local function CreateSecureFramePoolInstance(frameType, parent, template, resetFunc, forbidden, postCreate, capacity)
	local function Create()
		local createFrame = forbidden and CreateForbiddenFrame or CreateFrame;
		local name = nil;
		local frame = createFrame(frameType, name, parent, template);
		
		if postCreate then
			postCreate(frame);
		end

		return frame;
	end

	return CreateSecureRegionPoolInstance(template, Create, resetFunc, capacity);
end

function ActorPool_HideAndClearModel(actorPool, actor)
	actor:ClearModel();
	actor:Hide();
end

local function CreateSecureActorPoolInstance(parent, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateActor(name, template);
	end
	return CreateSecureRegionPoolInstance(template, Create, resetFunc or ActorPool_HideAndClearModel, capacity);
end

local function CreateSecureTexturePoolInstance(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateTexture(name, layer, template, subLayer);
	end
	return CreateSecureRegionPoolInstance(template, Create, resetFunc, capacity);
end

local function CreateSecureFontStringPoolInstance(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateFontString(name, layer, template, subLayer);
	end
	return CreateSecureRegionPoolInstance(template, Create, resetFunc, capacity);
end

local function CreateSecureMaskTexturePoolInstance(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateMaskTexture(name, layer, template, subLayer);
	end
	return CreateSecureRegionPoolInstance(template, Create, resetFunc, capacity);
end

--[[
In addition to a specialization being used to create separate pools for the same template, it can
be used to modify a frame after being created. See FrameUtil.SpecializeFrameWithMixins
for the behavior when providing tables with conventionally named script handlers included.
]]--
local function ConvertSpecializationToPostCreate(specialization)
	local specializationType = type(specialization);
	if specializationType == "function" then
		return specialization;
	elseif specializationType == "table" then
		local function Initializer(frame)
			SpecializeFrameWithMixins(frame, specialization);
		end
		return Initializer;
	end

	return nil;
end

--[[
Arguments are packed into a table for ease of implementation in PoolCollectionBaseMixin. which is derived with
different argument signatures. This will also be helpful if we want to access a particular field off the table,
such as 'parent' without dealing with argument position in ...
]]--
local function FramePoolCollection_ArgsToTable(frameType, parent, template, resetFunc, forbidden, specialization, capacity)
	local args = 
	{
		frameType = frameType,
		parent = parent,
		template = template,
		resetFunc = resetFunc,
		forbidden = forbidden,
		specialization = specialization,
		capacity = capacity,
	};
	return args;
end

local FramePoolCollectionConverterMixin = {};

local function SecureCreatePoolKeyFromPoolArgs(args)
	return GetPoolKey(args.template, args.specialization);
end

function FramePoolCollectionConverterMixin:CreatePoolKeyFromPoolArgs(args)
	return securecallfunction(SecureCreatePoolKeyFromPoolArgs, args);
end	

function FramePoolCollectionConverterMixin:GetOrCreatePool(...)
	local args = FramePoolCollection_ArgsToTable(...);
	return SecurePoolCollectionMixin.GetOrCreatePoolWithArgs(self, args);
end

function FramePoolCollectionConverterMixin:CreatePool(...)
	local args = FramePoolCollection_ArgsToTable(...);
	return SecurePoolCollectionMixin.CreatePoolWithArgs(self, args);
end

local FramePoolCollectionMixin = CreateFromMixinsPrivate(PoolCollectionMixin, FramePoolCollectionConverterMixin);

function CreateUnsecuredRegionPoolInstance(template, createFunc, resetFunc, capacity)
	local pool = CreateFromMixinsPrivate(ObjectPoolMixin);
	pool:Init(createFunc, resetFunc or Pool_HideAndClearAnchors, capacity);
	pool.GetTemplate = function(self)
		return template;
	end

	return pool;
end

do
	local function CreateFramePoolInstance(frameType, parent, template, resetFunc, forbidden, postCreate, capacity)
		local function Create()
			local createFrame = forbidden and CreateForbiddenFrame or CreateFrame;
			local name = nil;
			local frame = createFrame(frameType, name, parent, template);
			
			if postCreate then
				postCreate(frame);
			end
	
			return frame;
		end
		
		return CreateUnsecuredRegionPoolInstance(template, Create, resetFunc, capacity);
	end

	function FramePoolCollectionMixin:CreatePoolInternal(args)
		local postCreate = ConvertSpecializationToPostCreate(args.specialization);
		return CreateFramePoolInstance(args.frameType, args.parent, args.template, args.resetFunc, args.forbidden, postCreate, args.capacity);
	end
end

local SecureFramePoolCollectionMixin = CreateFromMixinsPrivate(SecurePoolCollectionMixin, FramePoolCollectionConverterMixin);

function SecureFramePoolCollectionMixin:CreatePoolInternal(args)
	local postCreate = ConvertSpecializationToPostCreate(args.specialization);
	return CreateSecureFramePoolInstance(args.frameType, args.parent, args.template, args.resetFunc, args.forbidden, postCreate, args.capacity);
end

local SecureFontStringPoolCollectionMixin = CreateFromMixinsPrivate(SecurePoolCollectionMixin);

function SecureFontStringPoolCollectionMixin:CreatePoolKeyFromPoolArgs(args)
	return args.template;
end	

local function FontStringPoolCollection_ArgsToTable(parent, layer, subLayer, template, resetFunc, capacity)
	local args = 
	{
		parent = parent,
		layer = layer,
		subLayer = subLayer,
		template = template,
		resetFunc = resetFunc,
		capacity = capacity,
	};
	return args;
end

function SecureFontStringPoolCollectionMixin:GetOrCreatePool(...)
	local args = FontStringPoolCollection_ArgsToTable(...)
	return SecurePoolCollectionMixin.GetOrCreatePoolWithArgs(self, args);
end

function SecureFontStringPoolCollectionMixin:CreatePool(...)
	local args = FontStringPoolCollection_ArgsToTable(...);
	return SecurePoolCollectionMixin.CreatePoolWithArgs(self, args);
end

function SecureFontStringPoolCollectionMixin:CreatePoolInternal(args)
	return CreateSecureFontStringPoolInstance(args.parent, args.layer, args.subLayer, args.template, args.resetFunc, args.capacity);
end

function CreateSecureObjectPool(createFunc, resetFunc, capacity)
	return CreateSecureObjectPoolInstance(createFunc, resetFunc, capacity):ToProxy();
end

function CreateSecureFramePool(frameType, parent, template, resetFunc, forbidden, postCreate, capacity)
	return CreateSecureFramePoolInstance(frameType, parent, template, resetFunc, forbidden, postCreate, capacity):ToProxy();
end

function CreateSecureTexturePool(parent, layer, subLayer, template, resetFunc, capacity)
	return CreateSecureTexturePoolInstance(parent, layer, subLayer, template, resetFunc, capacity):ToProxy();
end

function CreateSecureFontStringPool(parent, layer, subLayer, template, resetFunc, capacity)
	return CreateSecureFontStringPoolInstance(parent, layer, subLayer, template, resetFunc, capacity):ToProxy();
end

function CreateSecureActorPool(parent, template, resetFunc, capacity)
	return CreateSecureActorPoolInstance(parent, template, resetFunc, capacity):ToProxy();
end

function CreateSecureMaskTexturePool(parent, layer, subLayer, template, resetFunc, capacity)
	return CreateSecureMaskTexturePoolInstance(parent, layer, subLayer, template, resetFunc, capacity):ToProxy();
end

do
	local Funcs =
	{
		"GetNumActive",
		"Acquire",
		"Release",
		"ReleaseAll",
		"ReleaseAllByTemplate",
		"EnumerateActiveByTemplate",
		"EnumerateActive",
		--"Dump",
	};
	
	local PoolCollectionProxyMixin = CreateProxyMixin(Proxies, SecurePoolCollectionMixin, Funcs);
	PoolCollectionProxyMixin.__index = PoolCollectionProxyMixin;

	function PoolCollectionProxyMixin:GetPool(...)
		local poolCollection = Proxies:ToPrivate(self);
		local pool = poolCollection:GetPool(...);
		if not pool then
			return nil;
		end

		return pool:ToProxy();
	end

	function PoolCollectionProxyMixin:CreatePool(...)
		local poolCollection = Proxies:ToPrivate(self);
		return poolCollection:CreatePool(...):ToProxy();
	end

	function PoolCollectionProxyMixin:GetOrCreatePool(...)
		local poolCollection = Proxies:ToPrivate(self);
		return poolCollection:GetOrCreatePool(...):ToProxy();
	end

	local function CreatePoolCollectionInstance(collectionMixin)
		local poolCollection = CreateFromMixinsPrivate(collectionMixin);
		local proxy = CreateProxy(poolCollection, PoolCollectionProxyMixin);
		poolCollection:Init(proxy);
		return poolCollection;
	end

	function CreateSecureFramePoolCollection()
		return CreatePoolCollectionInstance(SecureFramePoolCollectionMixin):ToProxy();
	end

	function CreateSecureFontStringPoolCollection()
		return CreatePoolCollectionInstance(SecureFontStringPoolCollectionMixin):ToProxy();
	end
end

function CreateUnsecuredObjectPool(createFunc, resetFunc, capacity)
	local pool = CreateFromMixinsPrivate(ObjectPoolMixin);
	pool:Init(createFunc, resetFunc, capacity);
	return pool;
end

function CreateUnsecuredTexturePool(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateTexture(name, layer, template, subLayer);
	end
	return CreateUnsecuredRegionPoolInstance(template, Create, resetFunc, capacity);
end

function CreateUnsecuredFontStringPool(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateFontString(name, layer, template, subLayer);
	end	
	return CreateUnsecuredRegionPoolInstance(template, Create, resetFunc, capacity);
end

function CreateUnsecuredFramePool(frameType, parent, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return CreateFrame(frameType, name, parent, template);
	end
	return CreateUnsecuredRegionPoolInstance(template, Create, resetFunc, capacity);
end

function CreateUnsecuredFramePoolCollection()
	local poolCollection = CreateFromMixinsPrivate(FramePoolCollectionMixin);
	poolCollection:Init();
	return poolCollection;
end

function CreateUnsecuredMaskTexturePool(parent, layer, subLayer, template, resetFunc, capacity)
	local function Create()
		local name = nil;
		return parent:CreateMaskTexture(name, layer, template, subLayer);
	end
	return CreateUnsecuredRegionPoolInstance(template, Create, resetFunc, capacity);
end

-- Aliases until we determine if we want to change any code to explicitly create
-- the secure or unsecured variant of pools and pool collections.
CreateObjectPool = CreateSecureObjectPool;
CreateFramePool = CreateSecureFramePool;
CreateTexturePool = CreateSecureTexturePool;
CreateFontStringPool = CreateSecureFontStringPool;
CreateActorPool = CreateSecureActorPool;
CreateFramePoolCollection = CreateSecureFramePoolCollection;
CreateFontStringPoolCollection = CreateSecureFontStringPoolCollection;
CreateMaskTexturePool = CreateSecureMaskTexturePool;
