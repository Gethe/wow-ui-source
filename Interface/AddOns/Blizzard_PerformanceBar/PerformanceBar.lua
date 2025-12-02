
-- latency bar

local NUM_ADDONS_TO_DISPLAY = 3;
local topAddOns = {}
for i=1, NUM_ADDONS_TO_DISPLAY do
	topAddOns[i] = { value = 0, name = "" };
end

-- These are movieID from the MOVIE database file.
local MovieList = {
	-- Movie sequence 1 = Wow Classic
	{ 1, 2 },
	-- Movie sequence 2 = BC
	{ 27 },
	-- Movie sequence 3 = LK
	{ 18 },
	-- Movie sequence 4 = CC
	{ 23 },
	-- Movie sequence 5 = MP
	{ 115 },
	-- Movie sequence 6 = WoD
	-- TODO change movie ID when it is available
	{ 115 },
}

function MainMenu_GetMovieDownloadProgress(id)
	local movieList = MovieList[id];
	if (not movieList) then return; end

	local anyInProgress = false;
	local allDownloaded = 0;
	local allTotal = 0;
	for _, movieId in ipairs(movieList) do
		local inProgress, downloaded, total = GetMovieDownloadProgress(movieId);
		anyInProgress = anyInProgress or inProgress;
		allDownloaded = allDownloaded + downloaded;
		allTotal = allTotal + total;
	end

	return anyInProgress, allDownloaded, allTotal;
end

local ipTypes = { "IPv4", "IPv6" }

function MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self)
	-- Off by default. Override if needed.
	return false;
end

function MainMenuBarPerformanceBarFrame_OnEnter(self)
	local string = "";

	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);

	-- latency
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latencyHome, latencyWorld);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");

	-- protocol types
	if ( GetCVarBool("useIPv6") ) then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes();
		string = format(MAINMENUBAR_PROTOCOLS_LABEL, ipTypes[ipTypeHome or 0] or UNKNOWN, ipTypes[ipTypeWorld or 0] or UNKNOWN);
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_PROTOCOLS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		GameTooltip:AddLine(" ");
	end

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_FRAMERATE, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");

	string = format(MAINMENUBAR_BANDWIDTH_LABEL, GetAvailableBandwidth());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_BANDWIDTH, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");

	local percent = floor(GetDownloadedPercentage()*100+0.5);
	string = format(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL, percent);
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_DOWNLOAD_PERCENT, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end

	-- Downloaded cinematics
	local firstMovie = true;
	for i, movieList in next, MovieList do
		local inProgress, downloaded, total = MainMenu_GetMovieDownloadProgress(i);
		if ( inProgress ) then
			if ( firstMovie ) then
				if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
					-- The "Cinematics" header looks bad when it's next to the newbie tooltip text, so add an extra line break
					GameTooltip:AddLine(" ");
				end
				GameTooltip:AddLine("   "..CINEMATICS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
				firstMovie = false;
			end
			GameTooltip:AddLine("   "..format(CINEMATIC_DOWNLOAD_FORMAT, _G["CINEMATIC_NAME_"..i], downloaded/total*100), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
	end

	local addonCount = C_AddOns.GetNumAddOns();

	if C_AddOnProfiler.IsEnabled() and addonCount > 0 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddColoredLine(GameTooltip, AddonList:GetOverallMetric(ADDON_LIST_PERFORMANCE_AVERAGE_CPU, Enum.AddOnProfilerMetric.SessionAverageTime), WHITE_FONT_COLOR);
		GameTooltip_AddColoredLine(GameTooltip, AddonList:GetOverallMetric(ADDON_LIST_PERFORMANCE_PEAK_CPU, Enum.AddOnProfilerMetric.PeakTime), WHITE_FONT_COLOR);

		local addonCPU = C_AddOnProfiler.GetTopKAddOnsForMetric(Enum.AddOnProfilerMetric.RecentAverageTime, 3);
		if #addonCPU > 0 then
			for _, result in ipairs(addonCPU) do
				GameTooltip_AddColoredLine(GameTooltip, AddonList:GetAddonMetricPercent(result.addOnName, ADDON_PERFORMANCE_MENU_TOOLTIP, Enum.AddOnProfilerMetric.RecentAverageTime), WHITE_FONT_COLOR);
			end
		end
	end

	-- AddOn mem usage
	for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
		topAddOns[i].value = 0;
	end

	UpdateAddOnMemoryUsage();
	local totalMem = 0;

	for i=1, addonCount, 1 do
		local mem = GetAddOnMemoryUsage(i);
		totalMem = totalMem + mem;
		for j=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if( mem > topAddOns[j].value ) then
				for k=NUM_ADDONS_TO_DISPLAY, 1, -1 do
					if( k == j ) then
						topAddOns[k].value = mem;
						topAddOns[k].name = C_AddOns.GetAddOnInfo(i);
						break;
					elseif( k ~= 1 ) then
						topAddOns[k].value = topAddOns[k-1].value;
						topAddOns[k].name = topAddOns[k-1].name;
					end
				end
				break;
			end
		end
	end

	if ( totalMem > 0 ) then
		if ( totalMem > 1000 ) then
			totalMem = totalMem / 1000;
			string = format(TOTAL_MEM_MB_ABBR, totalMem);
		else
			string = format(TOTAL_MEM_KB_ABBR, totalMem);
		end

		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		if ( MainMenuBarPerformanceBarFrame_UseDetailedTooltip(self) ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_MEMORY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end

		local size;
		for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if ( topAddOns[i].value == 0 ) then
				break;
			end
			size = topAddOns[i].value;
			if ( size > 1024 ) then
				size = size / 1024;
				string = format(ADDON_MEM_MB_ABBR, size, topAddOns[i].name);
			else
				string = format(ADDON_MEM_KB_ABBR, size, topAddOns[i].name);
			end
			GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		end
	end
	GameTooltip:Show();
end
