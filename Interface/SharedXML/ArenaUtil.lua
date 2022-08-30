ArenaUtil = {};

function ArenaUtil.GetArenaBannerInfo(rating, rank)
	local emblem, emblemColor, border, borderColor, banner, bannerColor, rankColor;

	if rank == 1 then
		border = "Interface\\PVPFrame\\PVP-Banner-5-Border-5";
		borderColor = {r=0.72, g=0.33, b=0.03};
		banner = "Interface\\PVPFrame\\PVP-Banner-5";
		bannerColor = {r=0.44, g=0.25, b=0};
		rankColor = {r=1, g=0.7, b=0.17};
	elseif rank <= 100 then
		border = "Interface\\PVPFrame\\PVP-Banner-3-Border-5";
		borderColor = {r=0.6, g=0.25, b=0.85};
		banner = "Interface\\PVPFrame\\PVP-Banner-3";
		bannerColor = {r=0.2, g=0.12, b=0.71};
		rankColor = {r=0.79, g=0.53, b=0.97};
	elseif rank <= 2500 then
		border = "Interface\\PVPFrame\\PVP-Banner-3-Border-5";
		borderColor = {r=0.08, g=0.48, b=0.67};
		banner = "Interface\\PVPFrame\\PVP-Banner-3";
		bannerColor = {r=0.09, g=0.24, b=0.55};
		rankColor = {r=0.24, g=0.76, b=1};
	elseif rank <= 5000 then
		border = "Interface\\PVPFrame\\PVP-Banner-2-Border-5";
		borderColor = {r=0.46, g=0.41, b=0.31};
		banner = "Interface\\PVPFrame\\PVP-Banner-2";
		bannerColor = {r=0.62, g=0.63, b=0.72};
		rankColor = {r=1, g=1, b=1};
	else
		border = nil;
		borderColor = nil;
		banner = "Interface\\PVPFrame\\PVP-Banner-2";
		bannerColor = {r=0.22, g=0.23, b=0.33};
		rankColor = {r=1, g=1, b=1};
	end

	if rank == 1 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-10";
		emblemColor = {r=1, g=0.94, b=0.25};
	elseif rating >= 2700 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-9";
		emblemColor = {r=0.95, g=0.77, b=0.16};
	elseif rating >= 2400 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-8";
		emblemColor = {r=0.87, g=0.87, b=0.87};
	elseif rating >= 2200 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-7";
		emblemColor = {r=0.94, g=0.57, b=0.17};
	elseif rating >= 2000 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-6";
		emblemColor = {r=1, g=0.87, b=0};
	elseif rating >= 1750 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-5";
		emblemColor = {r=0.87, g=0.87, b=0.87};
	elseif rating >= 1550 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-4";
		emblemColor = {r=0.44, g=0.22, b=0};
	elseif rating >= 1000 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-3";
		emblemColor = {r=0.37, g=0.24, b=0};
	elseif rating >= 500 then
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-2";
		emblemColor = {r=1, g=0.62, b=0.09};
	else
		emblem = "Interface\\PVPFrame\\Icons\\PVP-Banner-Classic-1";
		emblemColor = {r=0.82, g=0.82, b=0.82};
	end

	return emblem, emblemColor, border, borderColor, banner, bannerColor, rankColor;
end
