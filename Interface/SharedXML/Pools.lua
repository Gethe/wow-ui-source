---------------
--NOTE - Please do not change this section
local _, tbl, secureCapsuleGet = ...;
if tbl then
	tbl.SecureCapsuleGet = secureCapsuleGet or SecureCapsuleGet;
	tbl.setfenv = tbl.SecureCapsuleGet("setfenv");
	tbl.getfenv = tbl.SecureCapsuleGet("getfenv");
	tbl.type = tbl.SecureCapsuleGet("type");
	tbl.unpack = tbl.SecureCapsuleGet("unpack");
	tbl.error = tbl.SecureCapsuleGet("error");
	tbl.pcall = tbl.SecureCapsuleGet("pcall");
	tbl.pairs = tbl.SecureCapsuleGet("pairs");
	tbl.setmetatable = tbl.SecureCapsuleGet("setmetatable");
	tbl.getmetatable = tbl.SecureCapsuleGet("getmetatable");
	tbl.pcallwithenv = tbl.SecureCapsuleGet("pcallwithenv");

	local function CleanFunction(f)
		local f = function(...)
			local function HandleCleanFunctionCallArgs(success, ...)
				if success then
					return ...;
				else
					tbl.error("Error in secure capsule function execution: "..(...));
				end
			end
			return HandleCleanFunctionCallArgs(tbl.pcallwithenv(f, tbl, ...));
		end
		setfenv(f, tbl);
		return f;
	end

	local function CleanTable(t, tableCopies)
		if not tableCopies then
			tableCopies = {};
		end

		local cleaned = {};
		tableCopies[t] = cleaned;

		for k, v in tbl.pairs(t) do
			if tbl.type(v) == "table" then
				if ( tableCopies[v] ) then
					cleaned[k] = tableCopies[v];
				else
					cleaned[k] = CleanTable(v, tableCopies);
				end
			elseif tbl.type(v) == "function" then
				cleaned[k] = CleanFunction(v);
			else
				cleaned[k] = v;
			end
		end
		return cleaned;
	end

	local function Import(name)
		local skipTableCopy = true;
		local val = tbl.SecureCapsuleGet(name, skipTableCopy);
		if tbl.type(val) == "function" then
			tbl[name] = CleanFunction(val);
		elseif tbl.type(val) == "table" then
			tbl[name] = CleanTable(val);
		else
			tbl[name] = val;
		end
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	Import("ipairs");
	Import("next");
	Import("assert");
	Import("CreateFrame");
	Import("CreateForbiddenFrame");
	Import("CreateFromMixins");

	if tbl.getmetatable(tbl) == nil then
		local secureEnvMetatable =
		{
			__metatable = false,
			__environment = false,
		}
		tbl.setmetatable(tbl, secureEnvMetatable);
	end
	setfenv(1, tbl);
end
----------------


ObjectPoolMixin = {};

function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc)
	self.creationFunc = creationFunc;
	self.resetterFunc = resetterFunc;

	self.activeObjects = {};
	self.inactiveObjects = {};

	self.numActiveObjects = 0;
end

function ObjectPoolMixin:Acquire()
	local numInactiveObjects = #self.inactiveObjects;
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects];
		self.activeObjects[obj] = true;
		self.numActiveObjects = self.numActiveObjects + 1;
		self.inactiveObjects[numInactiveObjects] = nil;
		return obj, false;
	end

	local newObj = self.creationFunc(self);
	if self.resetterFunc and not self.disallowResetIfNew then
		self.resetterFunc(self, newObj);
	end
	self.activeObjects[newObj] = true;
	self.numActiveObjects = self.numActiveObjects + 1;
	return newObj, true;
end

function ObjectPoolMixin:Release(obj)
	if self:IsActive(obj) then
		self.inactiveObjects[#self.inactiveObjects + 1] = obj;
		self.activeObjects[obj] = nil;
		self.numActiveObjects = self.numActiveObjects - 1;
		if self.resetterFunc then
			self.resetterFunc(self, obj);
		end

		return true;
	end

	return false;
end

function ObjectPoolMixin:ReleaseAll()
	for obj in pairs(self.activeObjects) do
		self:Release(obj);
	end
end

function ObjectPoolMixin:SetResetDisallowedIfNew(disallowed)
	self.disallowResetIfNew = disallowed;
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects);
end

function ObjectPoolMixin:GetNextActive(current)
	return (next(self.activeObjects, current));
end

function ObjectPoolMixin:GetNextInactive(current)
	return (next(self.inactiveObjects, current));
end

function ObjectPoolMixin:IsActive(object)
	return (self.activeObjects[object] ~= nil);
end

function ObjectPoolMixin:GetNumActive()
	return self.numActiveObjects;
end

function ObjectPoolMixin:EnumerateInactive()
	return ipairs(self.inactiveObjects);
end

function CreateObjectPool(creationFunc, resetterFunc)
	local objectPool = CreateFromMixins(ObjectPoolMixin);
	objectPool:OnLoad(creationFunc, resetterFunc);
	return objectPool;
end

FramePoolMixin = CreateFromMixins(ObjectPoolMixin);

local function FramePoolFactory(framePool)
	return CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
end

local function ForbiddenFramePoolFactory(framePool)
	return CreateForbiddenFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
end

function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	if forbidden then
		local creationFunc = ForbiddenFramePoolFactory;
		if frameInitFunc ~= nil then
			creationFunc = function(framePool)
				local frame =  CreateForbiddenFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
				frameInitFunc(frame);
				return frame;
			end
		end

		ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc);
	else
		local creationFunc = FramePoolFactory;
		if frameInitFunc ~= nil then
			creationFunc = function(framePool)
				local frame = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate);
				frameInitFunc(frame);
				return frame;
			end
		end

		ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc);
	end
	self.frameType = frameType;
	self.parent = parent;
	self.frameTemplate = frameTemplate;
end

function FramePoolMixin:GetTemplate()
	return self.frameTemplate;
end

function FramePool_Hide(framePool, frame)
	frame:Hide();
end

function FramePool_HideAndClearAnchors(framePool, frame)
	frame:Hide();
	frame:ClearAllPoints();
end

function CreateFramePool(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	local framePool = CreateFromMixins(FramePoolMixin);
	framePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or FramePool_HideAndClearAnchors, forbidden, frameInitFunc);
	return framePool;
end

TexturePoolMixin = CreateFromMixins(ObjectPoolMixin);

local function TexturePoolFactory(texturePool)
	return texturePool.parent:CreateTexture(nil, texturePool.layer, texturePool.textureTemplate, texturePool.subLayer);
end

function TexturePoolMixin:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, TexturePoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.textureTemplate = textureTemplate;
end

TexturePool_Hide = FramePool_Hide;
TexturePool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

function CreateTexturePool(parent, layer, subLayer, textureTemplate, resetterFunc)
	local texturePool = CreateFromMixins(TexturePoolMixin);
	texturePool:OnLoad(parent, layer, subLayer, textureTemplate, resetterFunc or TexturePool_HideAndClearAnchors);
	return texturePool;
end

MaskPoolMixin = CreateFromMixins(ObjectPoolMixin);

local function MaskPoolFactory(maskPool)
	return maskPool.parent:CreateMaskTexture(nil, maskPool.layer, maskPool.maskTemplate, maskPool.subLayer);
end

function MaskPoolMixin:OnLoad(parent, layer, subLayer, maskTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, MaskPoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.maskTemplate = maskTemplate;
end

MaskPool_Hide = FramePool_Hide;
MaskPool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

function CreateMaskPool(parent, layer, subLayer, maskTemplate, resetterFunc)
	local maskPool = CreateFromMixins(MaskPoolMixin);
	maskPool:OnLoad(parent, layer, subLayer, maskTemplate, resetterFunc or MaskPool_HideAndClearAnchors);
	return maskPool;
end

FontStringPoolMixin = CreateFromMixins(ObjectPoolMixin);

local function FontStringPoolFactory(fontStringPool)
	return fontStringPool.parent:CreateFontString(nil, fontStringPool.layer, fontStringPool.fontStringTemplate, fontStringPool.subLayer);
end

function FontStringPoolMixin:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, FontStringPoolFactory, resetterFunc);
	self.parent = parent;
	self.layer = layer;
	self.subLayer = subLayer;
	self.fontStringTemplate = fontStringTemplate;
end

FontStringPool_Hide = FramePool_Hide;
FontStringPool_HideAndClearAnchors = FramePool_HideAndClearAnchors;

function CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	local fontStringPool = CreateFromMixins(FontStringPoolMixin);
	fontStringPool:OnLoad(parent, layer, subLayer, fontStringTemplate, resetterFunc or FontStringPool_HideAndClearAnchors);
	return fontStringPool;
end

ActorPoolMixin = CreateFromMixins(ObjectPoolMixin);

local function ActorPoolFactory(actorPool)
	return actorPool.parent:CreateActor(nil, actorPool.actorTemplate);
end

function ActorPoolMixin:OnLoad(parent, actorTemplate, resetterFunc)
	ObjectPoolMixin.OnLoad(self, ActorPoolFactory, resetterFunc);
	self.parent = parent;
	self.actorTemplate = actorTemplate;
end

ActorPool_Hide = FramePool_Hide;
function ActorPool_HideAndClearModel(actorPool, actor)
	actor:ClearModel();
	actor:Hide();
end

function CreateActorPool(parent, actorTemplate, resetterFunc)
	local actorPool = CreateFromMixins(ActorPoolMixin);
	actorPool:OnLoad(parent, actorTemplate, resetterFunc or ActorPool_HideAndClearModel);
	return actorPool;
end

FramePoolCollectionMixin = {};

function CreateFramePoolCollection()
	local poolCollection = CreateFromMixins(FramePoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

-- If different frames are used for specialized cases even though they have the same template,
-- supply a specialization key to differentiate. If specialization is a function, it will be
-- called the first time a frame is acquired. If specialization is a table, it will be mixed
-- in with FrameUtil.SpecializeFrameWithMixins.
local function FramePoolCollection_GetPoolKey(template, specialization)
	return template..tostring(specialization);
end

local function FramePoolCollection_GetSpecializedFrameInit(specialization)
	local specializationType = type(specialization);
	if specializationType == "function" then
		return specialization;
	elseif specializationType == "table" then
		local function SpecializationFrameInit(frame)
			FrameUtil.SpecializeFrameWithMixins(frame, specialization);
		end

		return SpecializationFrameInit;
	end

	return nil;
end

function FramePoolCollectionMixin:OnLoad()
	self.pools = {};
end

function FramePoolCollectionMixin:GetNumActive()
	local numTotalActive = 0;
	for _, pool in pairs(self.pools) do
		numTotalActive = numTotalActive + pool:GetNumActive();
	end
	return numTotalActive;
end

-- Returns the pool, and whether or not the pool needed to be created.
function FramePoolCollectionMixin:GetOrCreatePool(frameType, parent, template, resetterFunc, forbidden, specialization)
	local pool = self:GetPool(template, specialization);
	if not pool then
		return self:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization), true;
	end
	return pool, false;
end

function FramePoolCollectionMixin:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization)
	assert(self:GetPool(template, specialization) == nil);
	local frameInitFunc = FramePoolCollection_GetSpecializedFrameInit(specialization);
	local pool = CreateFramePool(frameType, parent, template, resetterFunc, forbidden, frameInitFunc);
	local poolKey = FramePoolCollection_GetPoolKey(template, specialization);
	self.pools[poolKey] = pool;
	return pool;
end

function FramePoolCollectionMixin:CreatePoolIfNeeded(frameType, parent, template, resetterFunc, forbidden, specialization)
	if not self:GetPool(template, specialization) then
		self:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization);
	end
end

function FramePoolCollectionMixin:GetPool(template, specialization)
	local poolKey = FramePoolCollection_GetPoolKey(template, specialization);
	return self.pools[poolKey];
end

function FramePoolCollectionMixin:Acquire(template, specialization)
	local pool = self:GetPool(template, specialization);
	assert(pool);
	return pool:Acquire();
end

function FramePoolCollectionMixin:Release(object)
	for _, pool in pairs(self.pools) do
		if pool:Release(object) then
			-- Found it! Just return
			return;
		end
	end

	-- Huh, we didn't find that object
	assert(false);
end

function FramePoolCollectionMixin:ReleaseAllByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		pool:ReleaseAll();
	end
end

function FramePoolCollectionMixin:ReleaseAll()
	for key, pool in pairs(self.pools) do
		pool:ReleaseAll();
	end
end

function FramePoolCollectionMixin:EnumerateActiveByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		return pool:EnumerateActive();
	end

	return nop;
end

function FramePoolCollectionMixin:EnumerateActive()
	local currentPoolKey, currentPool = next(self.pools, nil);
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextActive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey);
				if currentPool then
					currentObject = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end

function FramePoolCollectionMixin:EnumerateInactiveByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		return pool:EnumerateInactive();
	end

	return nop;
end

function FramePoolCollectionMixin:EnumerateInactive()
	local currentPoolKey, currentPool = next(self.pools, nil);
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextInactive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey);
				if currentPool then
					currentObject = currentPool:GetNextInactive();
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end


FixedSizeFramePoolCollectionMixin = CreateFromMixins(FramePoolCollectionMixin);

function CreateFixedSizeFramePoolCollection()
	local poolCollection = CreateFromMixins(FixedSizeFramePoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

function FixedSizeFramePoolCollectionMixin:OnLoad()
	FramePoolCollectionMixin.OnLoad(self);
	self.sizes = {};
end

function FixedSizeFramePoolCollectionMixin:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization, maxPoolSize, preallocate)
	local pool = FramePoolCollectionMixin.CreatePool(self, frameType, parent, template, resetterFunc, forbidden, specialization);

	if preallocate then
		for i = 1, maxPoolSize do
			pool:Acquire();
		end
		pool:ReleaseAll();
	end

	local poolKey = FramePoolCollection_GetPoolKey(template, specialization);
	self.sizes[poolKey] = maxPoolSize;

	return pool;
end

function FixedSizeFramePoolCollectionMixin:Acquire(template, specialization)
	local pool = self:GetPool(template, specialization);
	assert(pool);

	local poolKey = FramePoolCollection_GetPoolKey(template, specialization);
	if pool:GetNumActive() < self.sizes[poolKey] then
		return pool:Acquire();
	end
	return nil;
end


FontStringPoolCollectionMixin = CreateFromMixins(FramePoolCollectionMixin);

function CreateFontStringPoolCollection()
	local poolCollection = CreateFromMixins(FontStringPoolCollectionMixin);
	poolCollection:OnLoad();
	return poolCollection;
end

function FontStringPoolCollectionMixin:GetOrCreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	local pool = self:GetPool(fontStringTemplate);
	if not pool then
		pool = self:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	end
	return pool;
end

function FontStringPoolCollectionMixin:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	assert(self:GetPool(fontStringTemplate) == nil);
	local pool = CreateFontStringPool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	self.pools[fontStringTemplate] = pool;
	return pool;
end

function FontStringPoolCollectionMixin:CreatePoolIfNeeded(parent, layer, subLayer, fontStringTemplate, resetterFunc)
	if not self:GetPool(fontStringTemplate) then
		self:CreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	end
end

function FontStringPoolCollectionMixin:Acquire(fontStringTemplate, parent, layer, subLayer, resetterFunc)
	local pool = self:GetOrCreatePool(parent, layer, subLayer, fontStringTemplate, resetterFunc);
	local newString = pool:Acquire();

	if parent then
		newString:SetParent(parent);
	end

	if layer then
		newString:SetDrawLayer(layer, subLayer);
	end

	return newString;
end