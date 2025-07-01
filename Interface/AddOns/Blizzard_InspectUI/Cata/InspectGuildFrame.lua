
InspectGuildFrameMixin = {};

function InspectGuildFrameMixin:OnLoad()
	self:RegisterEvent("INSPECT_READY");
end

function InspectGuildFrameMixin:OnEvent(event, unit, ...)
	if ( event == "INSPECT_READY" and InspectFrame.unit and (UnitGUID(InspectFrame.unit) == unit) ) then
		self:Update();
	end
end

function InspectGuildFrameMixin:OnShow()
	ButtonFrameTemplate_ShowButtonBar(InspectFrame);
	self:Update();
end

function InspectGuildFrameMixin:Update()
	local guildPoints, guildNumMembers, guildName = C_PaperDollInfo.GetInspectGuildInfo(InspectFrame.unit);
	local _, guildFactionName = UnitFactionGroup(InspectFrame.unit);

	InspectGuildFrame.guildName:SetText(guildName);

	if (guildFactionName) then
		InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_FACTION, guildFactionName);
	end
	if(guildNumMembers) then
		InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_NUM_MEMBERS, guildNumMembers);
	end

	local pointFrame = InspectGuildFrame.Points;
	pointFrame.SumText:SetText(guildPoints);
	local width = pointFrame.SumText:GetStringWidth() + pointFrame.LeftCap:GetWidth() + pointFrame.RightCap:GetWidth() + pointFrame.Icon:GetWidth();
	pointFrame:SetWidth(width);
	
	SetDoubleGuildTabardTextures(InspectFrame.unit, InspectGuildFrameTabardLeftIcon, InspectGuildFrameTabardRightIcon, InspectGuildFrameBanner, InspectGuildFrameBannerBorder);
	
end
