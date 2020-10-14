
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
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

	Import("math");
	Import("CalculateDistanceSq");
end
----------------

RegionUtil = {};

function RegionUtil.IsDescendantOf(potentialDescendant, potentialAncestor)
	if not potentialDescendant or not potentialAncestor then
		return false;
	end

	local parent = potentialDescendant:GetParent();
	while parent do
		if parent == potentialAncestor then
			return true;
		end
		parent = parent:GetParent();
	end

	return false;
end

function RegionUtil.IsDescendantOfOrSame(potentialDescendant, potentialAncestorOrSame)
	if potentialDescendant and potentialDescendant == potentialAncestorOrSame then
		return true;
	end

	return RegionUtil.IsDescendantOf(potentialDescendant, potentialAncestorOrSame);
end

function RegionUtil.CalculateDistanceSqBetween(region1, region2)
	local x1, y1 = region1:GetCenter();
	local x2, y2 = region2:GetCenter();
	if x1 and x2 then
		return CalculateDistanceSq(x1, y1, x2, y2);
	end
	return 0;
end

function RegionUtil.CalculateDistanceBetween(region1, region2)
	return math.sqrt(RegionUtil.CalculateDistanceSqBetween(region1, region2));
end

function RegionUtil.CalculateAngleBetween(region1, region2)
	local x1, y1 = region1:GetCenter();
	local x2, y2 = region2:GetCenter();
	return CalculateAngleBetween(x1, y1, x2, y2);
end