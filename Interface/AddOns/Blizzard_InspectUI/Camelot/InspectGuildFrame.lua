function InspectGuildFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_READY");
end

function InspectGuildFrame_OnEvent(self, event, unit, ...)
	local inspectUnit = InspectFrame:GetInspectUnit();
	if ( event == "INSPECT_READY" and inspectUnit and (UnitGUID(inspectUnit) == unit) ) then
		InspectGuildFrame_Update();
	end
end

function InspectGuildFrame_OnShow()
	ButtonFrameTemplate_ShowButtonBar(InspectFrame);
	InspectGuildFrame_Update();
end

function InspectGuildFrame_Update()
	local inspectUnit = InspectFrame:GetInspectUnit();
	if not inspectUnit then
		return;
	end

	local _, guildNumMembers, guildName = C_PaperDollInfo.GetInspectGuildInfo(inspectUnit);
	local _, guildFactionName = UnitFactionGroup(inspectUnit);

	InspectGuildFrame.guildName:SetText(guildName);

	if ( guildFactionName and guildNumMembers ) then
		InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_FACTION, guildFactionName);
		InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_NUM_MEMBERS, guildNumMembers);
	end

	SetDoubleGuildTabardTextures(inspectUnit, InspectGuildFrameTabardLeftIcon, InspectGuildFrameTabardRightIcon, InspectGuildFrameBanner, InspectGuildFrameBannerBorder);
end
