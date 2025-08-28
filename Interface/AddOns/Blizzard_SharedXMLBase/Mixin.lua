
local select = select;
local pairs = pairs;

local PrivateMixin = Mixin;
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

-- Secure Mixins
-- where ... are the mixins to mixin
function SecureMixin(object, ...)
	if ( not issecure() ) then
		return;
	end

	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

-- This is Private because we need a pristine copy to reference in CreateFromSecureMixins.
local SecureMixinPrivate = SecureMixin;

-- where ... are the mixins to mixin
function CreateFromSecureMixins(...)
	if ( not issecure() ) then
		return;
	end

	return SecureMixinPrivate({}, ...)
end
