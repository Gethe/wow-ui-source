-- Internal implementation of UI mode state management.
-- Handles the mode stack and resolves combined visibility from all active modes.
--
-- Each mode defines either:
--   rolesetBlocklist: rolesets to force hidden
--   rolesetAllowlist: only listed rolesets are allowed to show
--
-- When multiple modes are active, blocklists are unioned and allowlists are intersected.

UIModeManagerMixin = {};

function UIModeManagerMixin:Init()
	self.registeredModes = {};
	self.modeStack = {};
end

function UIModeManagerMixin:RegisterMode(modeName, config)
	self.registeredModes[modeName] = config;
end

function UIModeManagerMixin:PushMode(modeName)
	table.insert(self.modeStack, modeName);
	self:ResolveVisibility();
end

function UIModeManagerMixin:PopMode(modeName)
	for i = #self.modeStack, 1, -1 do
		if self.modeStack[i] == modeName then
			table.remove(self.modeStack, i);
			break;
		end
	end

	self:ResolveVisibility();
end

function UIModeManagerMixin:IsModeActive(modeName)
	for i = 1, #self.modeStack do
		if self.modeStack[i] == modeName then
			return true;
		end
	end

	return false;
end

function UIModeManagerMixin:ResolveVisibility()
	if #self.modeStack == 0 then
		C_Roleset.ApplyRolesetFilters({}, {});
		return;
	end

	-- Do a first pass to de-dupe modes that are on the stack more than once.
	local activeModeSet = {};
	for _, modeName in ipairs(self.modeStack) do
		activeModeSet[modeName] = true;
	end

	-- Do a second pass to build the combined blocklist and allowlist.
	-- blocklist is unioned, allowlist is intersected.
	local blocklistSet = {};
	local allowlistSet = {};
	for modeName, _isActive in pairs(activeModeSet) do
		local mode = self.registeredModes[modeName];
		if mode.rolesetBlocklist then
			for _, roleset in ipairs(mode.rolesetBlocklist) do
				blocklistSet[roleset] = true;
			end
		end

		if mode.rolesetAllowlist then
			if TableIsEmpty(allowlistSet) then
				for _, roleset in ipairs(mode.rolesetAllowlist) do
					allowlistSet[roleset] = true;
				end
			else
				local modeRolesetSet = {};
				for _, roleset in ipairs(mode.rolesetAllowlist) do
					modeRolesetSet[roleset] = true;
				end

				for roleset in pairs(allowlistSet) do
					if not modeRolesetSet[roleset] then
						allowlistSet[roleset] = nil;
					end
				end
			end
		end
	end

	local blocklistArray = {};
	for roleset, _ in pairs(blocklistSet) do
		table.insert(blocklistArray, roleset);
	end

	local allowlistArray = allowlistSet and {} or nil;
	if allowlistSet then
		for roleset, _ in pairs(allowlistSet) do
			table.insert(allowlistArray, roleset);
		end
	end

	C_Roleset.ApplyRolesetFilters(blocklistArray, allowlistArray);
end
