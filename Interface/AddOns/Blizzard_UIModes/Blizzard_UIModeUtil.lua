
local manager = CreateAndInitFromMixin(UIModeManagerMixin);

UIModeUtil = {};

local HIDE_MOST_BLOCKLIST = {
	"unitFrames",
	"actionBars",
	"minimap",
	"buffs",
	"objectives",
	"statusBars",
	"cooldownViewers",
	"encounterUI",
	"pvp",
	"extraAbilities",
	"widgets",
};

function UIModeUtil.RegisterMode(modeName, config)
	manager:RegisterMode(modeName, config);
end

-- The mode manager can handle a complete complex stack of modes being pushed and popped
-- but for now, we're only going to expose a simple on/off API.
function UIModeUtil.SetModeActive(modeName, active)
	if active then
		if not manager:IsModeActive(modeName) then
			manager:PushMode(modeName);
		end
	else
		if manager:IsModeActive(modeName) then
			manager:PopMode(modeName);
		end
	end
end

function UIModeUtil.IsModeActive(modeName)
	return manager:IsModeActive(modeName);
end

-- Useful if you want the standard "hide most" blocklist plus a few extra things.
function UIModeUtil.CreateExtendedBlocklist(...)
	local blocklist = CopyTable(HIDE_MOST_BLOCKLIST);
	for i = 1, select("#", ...) do
		table.insert(blocklist, (select(i, ...)));
	end

	return blocklist;
end

-- Like CreateExtendedBlocklist, but also removes specific rolesets from the base list.
function UIModeUtil.CreateModifiedBlocklist(excludeSet, ...)
	local blocklist = {};
	for _, roleset in ipairs(HIDE_MOST_BLOCKLIST) do
		if not excludeSet[roleset] then
			table.insert(blocklist, roleset);
		end
	end

	for i = 1, select("#", ...) do
		table.insert(blocklist, (select(i, ...)));
	end

	return blocklist;
end
