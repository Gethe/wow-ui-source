--[[
Order of evaluation is dependent entirely on the priority chosen. If you need to guarantee one registree is called
before another, you have to coordinate their call order. If you cannot do that, the next option is to create another
priority level. 
]]
GameMenuEscPriority = {
	-- Static popups
	Dialog = 1,

	-- Context menus, spell flyouts, popup lists
	Menu = 2,

	--[[
	Consumes ESC for active spell interactions before normal
	UI teardown begins. These occur prior to addons because
	the casting may be in support of the addon, such as
	casting a spell to create a profession item.
	]]--
	
	Casting = 4,

	--[[
	Framework-owned overlays or top-level mode handlers that
	must run before normal panel teardown, such as
	OpacityFrame, HelpFrame, and HouseEditor.
	]]--
	FrameworkPre = 5,

	--[[
	For foundational UI such as edit mode that would
	be expected to be closed before an addon behind it.
	]]--
	Framework = 6,

	-- Use only when a framework handler must run immediately after another framework handler.
	FrameworkPost = 7,

	--[[
	For addons whose handler order is generally unimportant.
	Do not rely on ordering within this bucket.
	Note, this should be replaced in the future with an approach
	that attempts to close these UIs in an order related to their
	display level.
	]]--
	AddOn = 8,

	--[[
	For generic post-addon cleanup that should occur after all
	addon handlers have had a chance to run.
	]]--
	AddOnPost = 9,

	--[[
	Reserved for ordered follow-up after AddOnPost cleanup,
	such as CloseAllWindows and LootFrame.
	]]--
	AddOnPost2 = 10,

	-- Final gameplay fallback after no UI handler claimed ESC.
	World = 11,
};

local handlers = {};
local nextOrder = 0;

local function IsValidGameMenuEscPriority(priority)
	for _, value in pairs(GameMenuEscPriority) do
		if value == priority then
			return true;
		end
	end

	return false;
end

function RegisterGameMenuEscHandler(priority, handler)
	assert(priority ~= nil, "RegisterGameMenuEscHandler requires a priority.");
	assert(handler ~= nil, "RegisterGameMenuEscHandler requires a handler.");
	assert(IsValidGameMenuEscPriority(priority), "RegisterGameMenuEscHandler received an invalid priority.");
	assert(type(handler) == "function", "RegisterGameMenuEscHandler handler must be a function.");

	nextOrder = nextOrder + 1;

	table.insert(handlers, {
		handler = handler,
		priority = priority,
		order = nextOrder,
	});

	table.sort(handlers, function(left, right)
		if left.priority == right.priority then
			return left.order < right.order;
		end

		return left.priority < right.priority;
	end);
end

local function TryHandleGameMenuEsc()
	for _, entry in ipairs(handlers) do
		if securecallfunction(entry.handler) then
			return true;
		end
	end

	return false;
end

function ToggleGameMenu()
	if not TryHandleGameMenuEsc() and GameMenuFrame_Show then
		GameMenuFrame_Show();
	end
end
