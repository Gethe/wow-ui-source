
-- These are functions that were deprecated in 8.1.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Tooltip Changes
do
	-- Use GameTooltip instead.
	WorldmapTooltip = GameTooltip;
end