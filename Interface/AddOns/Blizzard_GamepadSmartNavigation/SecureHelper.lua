local SecureHelper = CreateFrame("FRAME", "SmartNavigationSecureHelper");

local assert = assert;
local CreateTable = table.create;
local forceinsecure = forceinsecure;
local issecretvalue = issecretvalue;
local issecure = issecure;
local issecurevalue = issecurevalue;
local securecallfunction = securecallfunction;
local rawget = rawget;
local tostring = tostring;
local type = type;
local unpack = unpack;
local IsAddOnRestrictionActive = C_RestrictedActions.IsAddOnRestrictionActive;
local CombatAddOnRestriction = Enum.AddOnRestrictionType.Combat;

local function DisplayInterfaceActionBlockedMessage()
	if _G.DisplayInterfaceActionBlockedMessage then
		_G.DisplayInterfaceActionBlockedMessage();
	end
end

-- Guarantee that we don't trust the global table post-load by using a completely empty environment.
setfenv(function()

	local function IsSecureOrOutOfCombatRestriction()
		return issecure() or not IsAddOnRestrictionActive(CombatAddOnRestriction);
	end

	local function WrapValue(isSecure, value)
		-- Wrap function arguments from insecure calls with a function that makes sure they run
		-- insecurely, so secure functions can't be passed and execute securely.
		if not isSecure and type(value) == "function" then
			return function(...)
				forceinsecure();
				return value(...);
			end;
		end
		return value;
	end

	-- Don't allow setting keys besides those that have been explicitly marked as allowed from
	-- secure code
	local allowedKeys = {};
	local functionOpts = {};

	SecureHelper:SetScript("OnAttributeChanged", function(self, attribName, newValue)
		if attribName == "setkeyvalue" then
			self:ClearAttribute("setkeyvalue");

			local name = securecallfunction(function() return rawget(newValue, 2); end);
			local entry = allowedKeys[name];
			local isValid, isSecure, obj, value;

			if entry then
				isValid, isSecure, obj, name, value = securecallfunction(function()
					-- All variables must be accessed before validate is called, to ensure any
					-- taint has been applied, so the validation function can check for it.
					-- Re-read name to have tainted names apply as well.
					local insecureObj = rawget(newValue, 1);
					local insecureName = rawget(newValue, 2);
					local insecureValue = rawget(newValue, 3);
					-- Make sure that we didn't get any secrets
					assert(not issecretvalue(insecureObj));
					assert(not issecretvalue(insecureName));
					assert(not issecretvalue(insecureValue));
					return entry.validate(), issecure(), insecureObj, insecureName, insecureValue;
				end);
			end

			if isValid then
				value = entry.transform(value);
				value = WrapValue(isSecure, value);
				assert(issecure());
				obj[name] = value;
			else
				DisplayInterfaceActionBlockedMessage();
			end
		elseif attribName == "invoke" then
			self:ClearAttribute("invoke");

			local insecureArgs = newValue;
			local func = securecallfunction(function() return insecureArgs.func; end);
			local opts = functionOpts[func];
			local isValid, args;

			if opts then
				-- We need to check security separately since we can't launder taint easily while
				-- still keeping the stack insecure to validate later.
				local isSecure = securecallfunction(function()
					if not issecurevalue(insecureArgs.func) then
						return false;
					end

					for i=1, #insecureArgs do
						if not issecurevalue(rawget(insecureArgs, i)) then
							return false;
						end
					end

					return issecure();
				end);

				args = CreateTable(#insecureArgs);
				for i=1, #insecureArgs do
					local arg = securecallfunction(function() return rawget(insecureArgs, i); end);
					assert(not issecretvalue(arg));
					args[i] = WrapValue(isSecure, arg);
				end

				isValid = securecallfunction(function()
					if not isSecure then
						forceinsecure();
					end
					return opts.validate();
				end);
			end

			if isValid then
				assert(issecure());
				local results = {func(unpack(args))};
				self:SetAttributeNoHandler("invoke-results", results);
			else
				DisplayInterfaceActionBlockedMessage();
				self:ClearAttribute("invoke-results");
			end
		end
	end);

	function SecureHelper:RegisterKey(name, transform, validate)
		if not issecure() then
			DisplayInterfaceActionBlockedMessage();
			return;
		end

		validate = validate or IsSecureOrOutOfCombatRestriction;

		assert(type(name) == "string");
		assert(type(transform) == "function");
		assert(type(validate) == "function");
		allowedKeys[name] = { validate=validate, transform=transform };
	end

	function SecureHelper:SetSecureValue(obj, name, value)
		if issecure() then
			local entry = allowedKeys[name];
			assert(entry ~= nil, "Attempting to set unregistered key: "..tostring(name));
			value = entry.transform(value);
			assert(issecure());
			obj[name] = value;
		else
			-- We must keep the taint on the elements to ensure issecure can remain accurate in the
			-- attribute handler. If the values weren't already tainted they will become so by being
			-- copied into the table.
			local args = { obj, name, value };
			self:SetAttribute("setkeyvalue", args);
		end
	end

	-- Prefer to throw away the reference to the input function after calling this, so it can't be
	-- called directly anymore.
	function SecureHelper:WrapFunction(func, validate)
		if not issecure() then
			DisplayInterfaceActionBlockedMessage();
			return;
		end

		validate = validate or IsSecureOrOutOfCombatRestriction;

		assert(not issecretvalue(func));
		assert(not issecretvalue(validate));

		functionOpts[func] = { validate=validate };

		local function InvokeFunction(...)
			if issecure() then
				return func(...);
			end

			local args = {...};
			args.func = func;
			self:SetAttribute("invoke", args);
			local retvals = self:GetAttribute("invoke-results");
			if retvals then
				self:ClearAttribute("invoke-results");
				return unpack(retvals);
			end
		end

		return InvokeFunction;
	end

	-- An insecure addon is able to replace these functions at runtime, so don't blindly trust these
	-- functions to actually be these functions post-load.

	SecureHelper.IsSecureOrOutOfCombatRestriction = IsSecureOrOutOfCombatRestriction;

	function SecureHelper.CoerceToBoolean(value)
		return not not value;
	end

	function SecureHelper.ToOptionalString(value)
		return value ~= nil and tostring(value) or nil;
	end

	-- Acts like securecallmethod, except:
	-- 	1. The method is allowed to be nil without erroring
	--  2. `obj` is not implicitly passed as first argument
	--  3. The first return value is whether the function was called
	function SecureHelper.SecureCallOptionalFunction(obj, name, ...)
		return securecallfunction(function(...)
			local func = obj[name];
			if func then
				return true, func(...);
			end
			return false;
		end, ...);
	end

end, {})();

SecureHelper:AddForbiddenAspects(Enum.ForbiddenAspect.ScriptBindings);

return SecureHelper;
