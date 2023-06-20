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
end
---------------

EventScrollFrameMixin = CreateFromMixins(CallbackRegistryMixin);

EventScrollFrameMixin:GenerateCallbackEvents(
	{
		"OnHorizontalScroll",
		"OnVerticalScroll",
		"OnScrollRangeChanged",
		"OnMouseWheel",
		"OnSizeChanged",
	}
);

function EventScrollFrameMixin:OnLoad_Intrinsic()
	CallbackRegistryMixin.OnLoad(self);
end

function EventScrollFrameMixin:OnHorizontalScroll_Intrinsic(offset)
	self:TriggerEvent("OnHorizontalScroll", offset);
end

function EventScrollFrameMixin:OnVerticalScroll_Intrinsic(offset)
	self:TriggerEvent("OnVerticalScroll", offset);
end

function EventScrollFrameMixin:OnScrollRangeChanged_Intrinsic(xrange, yrange)
	self:TriggerEvent("OnScrollRangeChanged", xrange, yrange);
end

function EventScrollFrameMixin:OnMouseWheel_Intrinsic(direction)
	self:TriggerEvent("OnMouseWheel", direction);
end

function EventScrollFrameMixin:OnSizeChanged_Intrinsic(width, height)
	self:TriggerEvent("OnSizeChanged", width, height);
end