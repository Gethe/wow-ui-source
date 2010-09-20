
function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_READY");
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_READY" ) then
		InspectGuildFrame_Update();
	end
end

function InspectGuildFrame_OnShow()
	ButtonFrameTemplate_ShowButtonBar(InspectFrame);
	InspectGuildFrame_Update();
end

function InspectGuildFrame_Update()
	local guildName, _, _ = GetGuildInfo(InspectFrame.unit);
	
	InspectGuildFrame.guildName:SetText(guildName);
	
	local _, guildLevel, guildXP, guildNumMembers = GetInspectGuildInfo(InspectFrame.unit);
	local _, guildFactionName = UnitFactionGroup(InspectFrame.unit);
	if ( GetGuildLevelEnabled() ) then
		InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_LEVEL, guildLevel, guildFactionName);
	else
		InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_FACTION, guildFactionName);
	end
	InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_NUM_MEMBERS, guildNumMembers);
	
	SetDoubleGuildTabardTextures(InspectFrame.unit, InspectGuildFrameTabardLeftIcon, InspectGuildFrameTabardRightIcon, InspectGuildFrameBanner, InspectGuildFrameBannerBorder);
	
end
