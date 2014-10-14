
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
	local guildPoints, guildNumMembers, guildName = GetInspectGuildInfo(InspectFrame.unit);
	local _, guildFactionName = UnitFactionGroup(InspectFrame.unit);

	InspectGuildFrame.guildName:SetText(guildName);

	if ( guildFactionName and guildNumMembers ) then
		InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_FACTION, guildFactionName);
		InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_NUM_MEMBERS, guildNumMembers);
	end
	
	local pointFrame = InspectGuildFrame.Points;
	pointFrame.SumText:SetText(guildPoints);
	local width = pointFrame.SumText:GetStringWidth() + pointFrame.LeftCap:GetWidth() + pointFrame.RightCap:GetWidth() + pointFrame.Icon:GetWidth();
	pointFrame:SetWidth(width); 
	
	SetDoubleGuildTabardTextures(InspectFrame.unit, InspectGuildFrameTabardLeftIcon, InspectGuildFrameTabardRightIcon, InspectGuildFrameBanner, InspectGuildFrameBannerBorder);
end
