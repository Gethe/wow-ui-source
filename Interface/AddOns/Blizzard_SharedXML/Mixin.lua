---------------
--NOTE - Please do not change this section without talking to the UI team
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

	Import("pairs");
	Import("select");
end
---------------

local select = select;
local pairs = pairs;

-- where ​... are the mixins to mixin
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

local PrivateMixin = Mixin;

-- where ​... are the mixins to mixin
function CreateFromMixins(...)
	return PrivateMixin({}, ...)
end

local PrivateCreateFromMixins = CreateFromMixins;

function CreateAndInitFromMixin(mixin, ...)
	local object = PrivateCreateFromMixins(mixin);
	object:Init(...);
	return object;
end

-- Note: This should only be used for security purposes during the initial load process in-game.
function CreateSecureMixinCopy(mixin)
	local mixinCopy = PrivateMixin({}, mixin);
	setmetatable(mixinCopy, { __metatable = false, });
	return mixinCopy;
end
