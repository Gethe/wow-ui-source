GamepadSharedUtility.BindingStack.InputBindingManager = {};
GamepadSharedUtility.InputBindingManager = GamepadSharedUtility.BindingStack.InputBindingManager; -- Shorter alias.
local InputBindingManager = GamepadSharedUtility.InputBindingManager;

--[[
	Rebinds all bindings in bindingsToReload to what it should be.
	Used to fix bindingsets that are dismissed and burried
]]
local function ReloadBindings(self, bindingsToReload)
	for _, binding in pairs(bindingsToReload) do
		local key = binding.key;

		local bindingFound = false;
		for _, set in ipairs(self.bindingSetStack) do
			local newBinding = set:GetBinding(key);
			if (newBinding) then
				newBinding:Bind();
				bindingFound = true;
			end
		end

		if (not bindingFound) then
			local newBinding = self.coreSet:GetBinding(key);
			if (newBinding) then
				newBinding:Bind();
			elseif binding.Unbind then
				binding:Unbind(); -- If the old binding has specific unbind behavior, use that.
			else
				SetOverrideBinding(UIParent, false, key, "");
			end
		end
	end
end

-----------------------------------------------------------------------------------
-- HUD Input event management
-----------------------------------------------------------------------------------
local function CheckCoreBindingActive(bindingManager)
	local newActive = bindingManager:IsOnlyCoreBindingSetActive();
	if newActive ~= bindingManager.currentCoreBindingActive then
		for _, value in ipairs(bindingManager.coreBindingListenerFunctions) do
			value(newActive);
		end
		bindingManager.currentCoreBindingActive = newActive;
	end
end

function InputBindingManager:BindToCoreBindingActive(functionToCall)
	table.insert(self.coreBindingListenerFunctions, functionToCall);
end

function InputBindingManager:IsOnlyCoreBindingSetActive()
	local function AllBindingsOnStackTreatedAsCore()
		for _, set in ipairs(self.bindingSetStack) do
			if (not set.treatBindsAsCore) then
				return false;
			end
		end
		return true;
	end

	-- Any non-core binding set will put a name on the binding stack
	return AllBindingsOnStackTreatedAsCore() or self.assumeCoreBindingsUsable;
end

-- Set this state if the UI should pretend the core/HUD is active when there are other important blocking binds on the stack
-- For isolated bindings that should co-exist with the core binding set, configure them as treatBindsAsCore = true
function InputBindingManager:AssumeCoreBindingsAreUsable(usable)
	self.assumeCoreBindingsUsable = usable;
	CheckCoreBindingActive(self);
end

-----------------------------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------------------------

function InputBindingManager:Init()
	self.coreSet = nil;
	self.bindingSetStack = {};
	self.type = "InputBindingManager";

	-- Table of which InputBindings are actively bound
	self.activeBindings = {};

	self.coreBindingListenerFunctions = {};
	self.currentCoreBindingActive = true;
	self.assumeCoreBindingsUsable = false;

	InputUtil.RegisterForInterfaceTransitions(self);

	InputUtil.RegisterGamepadInit(self, function()
		-- If booting up into gamepad UI, the core set is not created yet and will be applied when it is.
		if self.coreSet then
			self.coreSet:BindAll();
		end
	end);

	InputUtil.RegisterGamepadUninit(self, function()
		-- Clear the stack down to the core set, and then explicitly clear the core set binds.
		self:ClearBindings();
		for key in self.coreSet:Iterator() do
			SetOverrideBinding(UIParent, false, key, "");
		end
	end);
end

--[[
	Sets what the default control bindings are

	bindingSet: InputBindingSet to set as the core binding
]]
function InputBindingManager:SetCoreBindingSet(bindingSet)
	if (bindingSet.type ~= "InputBindingSet") then
		error("Tried to call InputBindingManager:SetCoreBindingSet with an incorrect type for bindingSet");
	end
	self.coreSet = bindingSet;

	-- The core set will be activated once gamepad UI is enabled.
	if InputUtil.IsGamepadUIEnabled() then
		-- If the core is active, bind keys
		if (self.bindingSetStack[#self.bindingSetStack] == nil) then
			self.coreSet:BindAll();
		end
	end
end

--[[
	Adds an InputBindingSet to the top of the stack and binds it

	bindingSet: InputBindingSet to add to stack
	stayOnTop: True if the InputBindingSet should always take priority
]]
function InputBindingManager:AddBindingSet(bindingSet, stayOnTop)
	if (bindingSet.type ~= "InputBindingSet") then
		error("Tried to call InputBindingManager:AddBindingSet with an incorrect type for bindingSet");
	end

	-- If this binding is already in the stack but wants to be re-added, remove it from its old location.
	for i, entry in ipairs(self.bindingSetStack) do
		if (entry == bindingSet) then
			table.remove(self.bindingSetStack, i);
			break;
		end
	end

	local oldTop = self.bindingSetStack[#self.bindingSetStack];
	if oldTop and oldTop.stayOnTop and not stayOnTop then
		table.remove(self.bindingSetStack);

		table.insert(self.bindingSetStack, bindingSet);
		bindingSet:BindAll();

		table.insert(self.bindingSetStack, oldTop);
		oldTop:BindAll();
	else
		bindingSet.stayOnTop = stayOnTop;
		table.insert(self.bindingSetStack, bindingSet);
		bindingSet:BindAll();
		if (oldTop) then
			oldTop:RunOnBuried();
		end
	end

	CheckCoreBindingActive(self);
end

--[[
	Marks an InputBindingSet for removal and disables any active bindings
	in the set.

	bindingSet: Set to be removed once surfaced, will also remove if on top
]]
function InputBindingManager:RemoveSet(bindingSet)
	for i, entry in ipairs(self.bindingSetStack) do
		if (entry == bindingSet) then
			table.remove(self.bindingSetStack, i);
			break;
		end
	end

	-- Check if any bindings from the removed set are still active
	local bindingsToRemove = {};
	for _, binding in bindingSet:Iterator() do
		if (binding.isActive) then
			table.insert(bindingsToRemove, binding);
		end
	end
	ReloadBindings(self, bindingsToRemove);

	CheckCoreBindingActive(self);
end

--[[
	Reverts all bindings to the core and wipes the stack
]]
function InputBindingManager:ClearBindings()
	table.wipe(self.bindingSetStack);
	self.coreSet:BindAll();

	CheckCoreBindingActive(self);
end

--[[
	Returns the name of the top InputBindingSet

	returns: Name of the top InputBindingSet
]]
function InputBindingManager:PeekName()
	local top = self.bindingSetStack[#self.bindingSetStack];
	if (top) then
		return top.name;
	end
	return nil;
end

--[[
	Returns if the InputBindingSet exists in the stack

	returns: True if the InputBindingSet exists in the stack
]]
function InputBindingManager:Contains(bindingSet)
	for _, entry in ipairs(self.bindingSetStack) do
		if (entry == bindingSet) then
			return true;
		end
	end
	return false;
end

--[[
	Called by an InputBinding after it binds itself

	binding: Binding that calls this function that is now bound
]]
function InputBindingManager:SetNewActiveKey(binding)
	local currentBinding = self.activeBindings[binding.key];
	if (currentBinding and currentBinding ~= binding) then
		currentBinding:OnOverbound();
	end
	self.activeBindings[binding.key] = binding;
end

--[[ 
	Dumps the binding stack into a string

	return: String describing the InputBindingManager stack populated from core to top of the stack
]]
function InputBindingManager:DumpStack()
	local stacksString = "Binding Formatting:\n" ..
						 "Button Bindings: <Physical Key> = <Name of virtual button to click> | <Left or Right Click when binding is triggered> | <Is Binding Active?>\n" ..
						 "Action Bindings: <Physical Key> = <Action to trigger> | <Is Binding Active?>\n\n" ..
						 "---------------------------------------------------------------------------------\n" ..
						 "Binding Sets Stack (Bottom to Top)\n\n" ..
						 "Format:\n" ..
						 "<Set Name>\nAlways on Top: <Should set always be on top of stack?>\n" ..
						 "-----------------\n" ..
						 "<Bindings in the set ...>\n" ..
						 "---------------------------------------------------------------------------------\n\n";
	stacksString = stacksString .. self.coreSet:ToString();
	for _, set in ipairs(self.bindingSetStack) do
		stacksString = stacksString .. "\n\n" .. set:ToString();
	end

	stacksString = stacksString .. "\n\n\n\n-----------------\nActiveBindings\n-----------------\n\n";
	for _, bind in pairs(self.activeBindings) do
		stacksString = stacksString .. bind:ToString() .. "\n";
	end

	return stacksString;
end

-- Global shortcuts for easier debugging when running through console.
function DumpGamepadBindingsToClipboard()
	local outputString = InputBindingManager:DumpStack();
	CopyToClipboard(outputString);
	print("Gamepad binding stack copied to clipboard!");
end

function DumpGamepadBindingsToWindow()
	local outputString = InputBindingManager:DumpStack();
	ScriptErrorsFrame:Warn(outputString);
end

InputBindingManager:Init();

-- Supports binding stack usage in the front end ui
if (InGlue()) then
	local frontEndCoreSet = CreateAndInitFromMixin(GamepadSharedUtility.BindingStack.InputBindingSet, "GlueCore", GamepadSharedUtility.InputBindingManager);
	InputBindingManager:SetCoreBindingSet(frontEndCoreSet);
end
