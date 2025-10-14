local _, addonTbl = ...;

-- Slash command registration is split across two registries; one for secure
-- commands and one for general registrations. The secure command registry
-- is always consulted first when a command is executed and must not allow
-- access outside of this addon.
--
-- The general registry tables (SlashCmdList and hash_SlashCmdList) must at
-- present remain global tables, as there exists a lot of addon code that
-- is directly accessing these tables to enable dynamic unregistration of
-- commands or to invoke commands by name.

local function CreateCommandListProxyTable()
	return setmetatable({}, { __index = {} });
end

addonTbl.hash_SecureCmdList = {};
addonTbl.SecureCmdList = CreateCommandListProxyTable();

_G.SlashCmdList = CreateCommandListProxyTable();
_G.hash_SlashCmdList = {};

function IsSecureCmd(command)
	command = strupper(command);
	-- first check the hash table
	if addonTbl.hash_SecureCmdList[command] then
		return true;
	end

	for index, value in pairs(addonTbl.SecureCmdList) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while cmdString do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				return true;
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end
end

function RegisterNewSlashCommand(callback, command, commandAlias)
	local name = string.upper(command);
	if issecure() then
		AddSecureCmdAliases(callback, "/"..command, "/"..commandAlias);
	else
		_G["SLASH_"..name.."1"] = "/"..command;
		_G["SLASH_"..name.."2"] = "/"..commandAlias;
		SlashCmdList[name] = callback;
	end
end

function AddSecureCmd(cmd, cmdString)
	if not issecure() then
		error("Cannot call AddSecureCmd from insecure code");
	end

	addonTbl.hash_SecureCmdList[strupper(cmdString)] = cmd;
end

function AddSecureCmdAliases(cmd, ...)
	for i = 1, select("#", ...) do
		local cmdString = select(i, ...);
		AddSecureCmd(cmd, cmdString);
	end
end