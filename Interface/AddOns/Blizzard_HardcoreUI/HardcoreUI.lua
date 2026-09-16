function GetDeathStaticPopup()
	if (C_GameRules.IsHardcoreActive()) then
		return "HARDCORE_DEATH";
	else
		return "DEATH";
	end
end

function CheckHardcoreGuildLeadStatus()
	return (C_GameRules.IsHardcoreActive() and IsGuildLeader());
end

function ShowHardcoreGuildHandoff()
	local guildName = GetGuildInfo("player");
	if (guildName and guildName ~= "") then
		StaticPopup_Show("HARDCORE_DEATH_GUILD_HANDOFF", guildName);
	end
end

if (C_GameRules.IsHardcoreActive()) then
	StaticPopupDialogs["HARDCORE_DEATH_GUILD_HANDOFF"] = {
		button1 = ACCEPT,
		text = HARDCORE_GUILDLEADER_DEATH,
		OnAccept = function(dialog, data)
			if ( dialog:GetButton1():IsEnabled() ) then
				local text = dialog:GetEditBox():GetText();
				C_GuildInfo.SetLeader(text);
				dialog:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		OnUpdate = function(dialog, elapsed)
		end,
		timeout = 0,
		whileDead = 1,
		exclusive = 1,
		showAlert = 1,
		hasEditBox = 1,
		maxLetters = 12,
		notClosableByLogout = 1,
		cancels = "HARDCORE_RECOVER_CORPSE",
		OnShow = function(dialog, data)
			dialog:GetButton1():Disable();
			dialog:GetEditBox():SetFocus();
		end,
		EditBoxOnEnterPressed = function(editBox, data)
			local dialog = editBox:GetParent();
			if ( dialog:GetButton1():IsEnabled() ) then
				local text = editBox:GetText();
				C_GuildInfo.SetLeader(text);
				dialog:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		EditBoxOnTextChanged = function(editBox, data)
			local dialog = editBox:GetParent();
			local text = editBox:GetText();
			if (text == "") then
				return
			end
			local playerInSameGuild = C_GuildInfo.MemberExistsByName(text);
			if (playerInSameGuild) then
				dialog:GetButton1():Enable();
			else
				dialog:GetButton1():Disable();
			end
		end,
	};
end
