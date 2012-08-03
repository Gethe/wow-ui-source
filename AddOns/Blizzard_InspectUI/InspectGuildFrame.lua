
function InspectGuildFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_READY");
end

function InspectGuildFrame_OnEvent(self, event, unit, ...)
	if ( event == "INSPECT_READY" and InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit) ) then
		InspectGuildFrame_Update();
	end
end

function InspectGuildFrame_OnShow()
	ButtonFrameTemplate_ShowButtonBar(InspectFrame);
	InspectGuildFrame_Update();
end

function InspectGuildFrame_Update()
	local guildLevel, guildXP, guildNumMembers, guildName = GetInspectGuildInfo(InspectFrame.unit);
	local _, guildFactionName = UnitFactionGroup(InspectFrame.unit);

	InspectGuildFrame.guildName:SetText(guildName);

	if ( guildLevel and guildFactionName and guildNumMembers ) then
		if ( GetGuildLevelEnabled() ) then
			InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_LEVEL, guildLevel, guildFactionName);
		else
			InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_FACTION, guildFactionName);
		end
		InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_NUM_MEMBERS, guildNumMembers);
	end
	
	SetDoubleGuildTabardTextures(InspectFrame.unit, InspectGuildFrameTabardLeftIcon, InspectGuildFrameTabardRightIcon, InspectGuildFrameBanner, InspectGuildFrameBannerBorder);
	
end
