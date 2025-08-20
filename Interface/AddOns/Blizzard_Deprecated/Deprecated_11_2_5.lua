-- These are functions that were deprecated in 11.2.5 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

-- NOTE FOR ADDON DEVELOPERS:
-- In 12.0 the client will no longer support rendering frames or regions
-- (except for Lines) that have inverted rects.
--
-- This means that any region that, for example, anchors both its LEFT and
-- RIGHT points to opposite edges on the same anchor target will result in the
-- region resolving a rect that has a zero width or height, and thus will
-- not render.

IsArtifactRelicItem = C_ItemSocketInfo.IsArtifactRelicItem;
