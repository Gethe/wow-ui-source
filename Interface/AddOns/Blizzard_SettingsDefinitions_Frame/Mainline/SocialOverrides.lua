SocialOverrides = {}

function SocialOverrides.AdjustSocialSettings(category)
end

function SocialOverrides.CreateCensorMessagesSetting(category)
		local cvar = "excludedCensorSources";
		local friendsAndGuild = bit.bor(Enum.ExcludedCensorSources.Friends, Enum.ExcludedCensorSources.Guild);

		local EVERYONE = 1;
		local EVERYONE_EXCEPT_FRIEND = 2;
		local EVERYONE_EXCEPT_FRIEND_AND_GUILD = 3;
		local NO_ONE = 4;

		local function GetValue()
			local censoredMessageSources = tonumber(C_CVar.GetCVar(cvar));
			if censoredMessageSources == 0 then
				return EVERYONE;
			elseif censoredMessageSources == Enum.ExcludedCensorSources.Friends then
				return EVERYONE_EXCEPT_FRIEND;
			elseif censoredMessageSources == friendsAndGuild then
				return EVERYONE_EXCEPT_FRIEND_AND_GUILD;
			else
				return NO_ONE;
			end
		end
		
		local function SetValue(value)
			if value == EVERYONE then
				SetCVar(cvar, 0);
			elseif value == EVERYONE_EXCEPT_FRIEND then
				SetCVar(cvar, Enum.ExcludedCensorSources.Friends);
			elseif value == EVERYONE_EXCEPT_FRIEND_AND_GUILD then
				SetCVar(cvar, friendsAndGuild);
			else
				SetCVar(cvar, 255);
			end
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(EVERYONE, CENSOR_SOURCE_EVERYONE);
			container:Add(EVERYONE_EXCEPT_FRIEND, CENSOR_SOURCE_EXCLUDE_FRIENDS);
			container:Add(EVERYONE_EXCEPT_FRIEND_AND_GUILD, CENSOR_SOURCE_EXCLUDE_FRIENDS_AND_GUILD);
			container:Add(NO_ONE, CENSOR_SOURCE_NO_ONE);
			return container:GetData();
		end

		local defaultValue = EVERYONE_EXCEPT_FRIEND;
		local setting = Settings.RegisterProxySetting(category, "PROXY_CENSOR_MESSAGES",
			Settings.VarType.Number, CENSOR_SOURCE_EXCLUDE, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_CENTER_SOURCE_EXCLUDE);
end