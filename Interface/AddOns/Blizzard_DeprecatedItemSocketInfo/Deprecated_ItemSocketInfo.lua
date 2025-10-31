-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	CloseSocketInfo = C_ItemSocketInfo.CloseSocketInfo;

	GetSocketItemInfo = C_ItemSocketInfo.GetSocketItemInfo;

	GetNumSockets = C_ItemSocketInfo.GetNumSockets;

	GetExistingSocketInfo = C_ItemSocketInfo.GetExistingSocketInfo;

	GetExistingSocketLink = C_ItemSocketInfo.GetExistingSocketLink;

	GetNewSocketInfo = C_ItemSocketInfo.GetNewSocketInfo;

	GetNewSocketLink = C_ItemSocketInfo.GetNewSocketLink;

	ClickSocketButton = C_ItemSocketInfo.ClickSocketButton;

	AcceptSockets = C_ItemSocketInfo.AcceptSockets;

	GetSocketTypes = C_ItemSocketInfo.GetSocketTypes;

	GetSocketItemRefundable = C_ItemSocketInfo.GetSocketItemRefundable;

	GetSocketItemBoundTradeable = C_ItemSocketInfo.GetSocketItemBoundTradeable;

	HasBoundGemProposed = C_ItemSocketInfo.HasBoundGemProposed;
end