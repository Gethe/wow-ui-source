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

	Import("GetTime");
	Import("assert");

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

function FadingFrame_SetFadeInTime(fadingFrame, time)
	fadingFrame.fadeInTime = time;
end
function FadingFrame_SetHoldTime(fadingFrame, time)
	fadingFrame.holdTime = time;
end
function FadingFrame_SetFadeOutTime(fadingFrame, time)
	fadingFrame.fadeOutTime = time;
end
function FadingFrame_OnLoad(fadingFrame)
	assert(fadingFrame);
	fadingFrame.fadeInTime = 0;
	fadingFrame.holdTime = 0;
	fadingFrame.fadeOutTime = 0;
	fadingFrame:Hide();
end
function FadingFrame_Show(fadingFrame)
	assert(fadingFrame);
	fadingFrame.startTime = GetTime();
	fadingFrame:Show();
end
function FadingFrame_OnUpdate(fadingFrame)
	assert(fadingFrame);
	local elapsed = GetTime() - fadingFrame.startTime;
	local fadeInTime = fadingFrame.fadeInTime;
	if ( elapsed < fadeInTime ) then
		local alpha = (elapsed / fadeInTime);
		fadingFrame:SetAlpha(alpha);
		return;
	end
	local holdTime = fadingFrame.holdTime;
	if ( elapsed < (fadeInTime + holdTime) ) then
		fadingFrame:SetAlpha(1.0);
		return;
	end
	local fadeOutTime = fadingFrame.fadeOutTime;
	if ( elapsed < (fadeInTime + holdTime + fadeOutTime) ) then
		local alpha = 1.0 - ((elapsed - holdTime - fadeInTime) / fadeOutTime);
		fadingFrame:SetAlpha(alpha);
		return;
	end
	fadingFrame:Hide();
end

function FadingFrame_GetRemainingTime(fadingFrame)
	local elapsed = GetTime() - fadingFrame.startTime;
	return (fadingFrame.holdTime + fadingFrame.fadeInTime + fadingFrame.fadeOutTime - elapsed);
end

function FadingFrame_CopyTimes(src, dest)
	dest.fadeInTime = src.fadeInTime;
	dest.holdTime = src.holdTime;
	dest.fadeOutTime = src.fadeOutTime;
	dest.startTime = src.startTime;
end
