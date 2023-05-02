---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
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

EventFrameMixin = CreateFromMixins(CallbackRegistryMixin);

EventFrameMixin:GenerateCallbackEvents(
	{
		"OnHide",
		"OnShow",
		"OnSizeChanged",
	}
);

function EventFrameMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventFrameMixin:OnHide_Intrinsic()
	self:TriggerEvent("OnHide");
end

function EventFrameMixin:OnShow_Intrinsic()
	self:TriggerEvent("OnShow");
end

function EventFrameMixin:OnSizeChanged_Intrinsic(width, height)
	self:TriggerEvent("OnSizeChanged", width, height);
end