--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.ShowGameTooltip(text, x, y)
	securecall("GameTooltip_SetBasicTooltip", GameTooltip, text, x, y);
end

function Outbound.HideGameTooltip()
	securecall("GameTooltip_Hide");
end