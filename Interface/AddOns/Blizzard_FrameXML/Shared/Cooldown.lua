---------------
--NOTE - Please do not change this section
local _, tbl, secureCapsuleGet = ...;
if tbl then
	tbl.SecureCapsuleGet = secureCapsuleGet or SecureCapsuleGet;
	tbl.setfenv = tbl.SecureCapsuleGet("setfenv");
	tbl.getfenv = tbl.SecureCapsuleGet("getfenv");
	tbl.type = tbl.SecureCapsuleGet("type");
	tbl.unpack = tbl.SecureCapsuleGet("unpack");
	tbl.error = tbl.SecureCapsuleGet("error");
	tbl.pcall = tbl.SecureCapsuleGet("pcall");
	tbl.pairs = tbl.SecureCapsuleGet("pairs");
	tbl.setmetatable = tbl.SecureCapsuleGet("setmetatable");
	tbl.getmetatable = tbl.SecureCapsuleGet("getmetatable");
	tbl.pcallwithenv = tbl.SecureCapsuleGet("pcallwithenv");

	local function CleanFunction(f)
		local f = function(...)
			local function HandleCleanFunctionCallArgs(success, ...)
				if success then
					return ...;
				else
					tbl.error("Error in secure capsule function execution: "..(...));
				end
			end
			return HandleCleanFunctionCallArgs(tbl.pcallwithenv(f, tbl, ...));
		end
		setfenv(f, tbl);
		return f;
	end

	local function CleanTable(t, tableCopies)
		if not tableCopies then
			tableCopies = {};
		end

		local cleaned = {};
		tableCopies[t] = cleaned;

		for k, v in tbl.pairs(t) do
			if tbl.type(v) == "table" then
				if ( tableCopies[v] ) then
					cleaned[k] = tableCopies[v];
				else
					cleaned[k] = CleanTable(v, tableCopies);
				end
			elseif tbl.type(v) == "function" then
				cleaned[k] = CleanFunction(v);
			else
				cleaned[k] = v;
			end
		end
		return cleaned;
	end

	local function Import(name)
		local skipTableCopy = true;
		local val = tbl.SecureCapsuleGet(name, skipTableCopy);
		if tbl.type(val) == "function" then
			tbl[name] = CleanFunction(val);
		elseif tbl.type(val) == "table" then
			tbl[name] = CleanTable(val);
		else
			tbl[name] = val;
		end
	end

	if tbl.getmetatable(tbl) == nil then
		local secureEnvMetatable =
		{
			__metatable = false,
			__environment = false,
		}
		tbl.setmetatable(tbl, secureEnvMetatable);
	end
	setfenv(1, tbl);
end
----------------

function CooldownFrame_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		self:SetDrawEdge(forceShowDrawEdge);
		self:SetCooldown(start, duration, modRate);
	else
		CooldownFrame_Clear(self);
	end
end

function CooldownFrame_Clear(self)
	self:Clear();
end

function CooldownFrame_SetDisplayAsPercentage(self, percentage)
	local seconds = 100;	-- any number, really
	self:Pause();
	self:SetCooldown(GetTime() - (seconds * Saturate(percentage)), seconds);
end