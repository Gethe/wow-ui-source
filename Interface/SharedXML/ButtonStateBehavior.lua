--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
		Import("C_StoreGlue");
	end

	setfenv(1, tbl);
end
----------------

ButtonStateBehaviorMixin = {};

function ButtonStateBehaviorMixin:OnEnter()
	if self:IsEnabled() then
		self.over = true;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnLeave()
	if self:IsEnabled() then
		self.over = nil;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseDown()
	if self:IsEnabled() then
		self.down = true;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnMouseUp()
	if self:IsEnabled() then
		self.down = nil;
		return true;
	end
	return false;
end

function ButtonStateBehaviorMixin:OnDisable()
	self.over = nil;
	self.down = nil;
end