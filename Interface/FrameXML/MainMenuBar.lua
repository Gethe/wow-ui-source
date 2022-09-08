MAIN_MENU_BAR_MARGIN = 75;		-- number of art pixels on one side, used by UIParent_ManageFramePositions. It's not the art's full size, don't care about the gryphon's tail.

MainMenuBarMixin = { };


function MainMenuBarMixin:OnLoad()
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");

	MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion();

	self.state = "player";
	MainMenuBar.ActionBarPageNumber.Text:SetText(GetActionBarPage());
	MicroButtonAndBagsBar:SetFrameLevel(self:GetFrameLevel()+2);
	self:UpdateEndCaps();

	self:SetShowGrid(true, ACTION_BUTTON_SHOW_GRID_REASON_CVAR);
end

function MainMenuBarMixin:OnShow()
	UpdateMicroButtonsParent(MicroButtonAndBagsBar);
	MoveMicroButtons("BOTTOMLEFT", MicroButtonAndBagsBar, "BOTTOMLEFT", 7, 6, false);
end

function MainMenuBarMixin:SetYOffset(yOffset)
	self.yOffset = yOffset;
end

function MainMenuBarMixin:GetYOffset()
	return self.yOffset;
end

function MainMenuBarMixin:OnEvent(event, ...)
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainMenuBar.ActionBarPageNumber.Text:SetText(GetActionBarPage());
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame = GetCVarBool("showTokenFrame");
		if ( not showTokenFrame ) then
			if ( C_CurrencyInfo.GetCurrencyListSize() > 0 ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					MicroButtonPulse(CharacterMicroButton, 60);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab3, 60, 1);
				end

				TokenFrame_Update();
				BackpackTokenFrame:UpdateIfVisible();
			else
				CharacterFrameTab3:Hide();
			end
		else
			TokenFrame_Update();
			BackpackTokenFrame:UpdateIfVisible();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		local unitToken = ...;
		if ( unitToken == "player" ) then
			UpdateMicroButtons();
		end
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		UpdateMicroButtons();
	elseif ( event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		self:UpdateEndCaps();
	end
end

MainMenuBarVehicleLeaveButtonMixin = {};

function MainMenuBarVehicleLeaveButtonMixin:OnLoad()
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("VEHICLE_UPDATE");
end

function MainMenuBarVehicleLeaveButtonMixin:OnEnter()
	if UnitOnTaxi("player") then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, TAXI_CANCEL);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, LEAVE_VEHICLE);
		GameTooltip:Show();
	end
end

function MainMenuBarVehicleLeaveButtonMixin:OnEvent(event, ...)
	self:Update();
end

function MainMenuBarVehicleLeaveButtonMixin:CanExitVehicle()
	return CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN;
end

function MainMenuBarVehicleLeaveButtonMixin:UpdateShownState()
	self:SetShown(self.isInEditMode or self:CanExitVehicle());
end

function MainMenuBarVehicleLeaveButtonMixin:Update()
	self:UpdateShownState();

	if self:CanExitVehicle() then
		self:Enable();
		if (PetHasActionBar()) then
			PetActionBar:Show();
		end
	else
		self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD");
		self:UnlockHighlight();
		if PetHasActionBar() then
			PetActionBar:Show();
		end
	end
end

function MainMenuBarVehicleLeaveButtonMixin:OnClicked()
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding();

		-- Show that the request for landing has been received.
		self:Disable();
		self:SetHighlightTexture([[Interface\Buttons\CheckButtonHilight]], "ADD");
		self:LockHighlight();
	else
		VehicleExit();
	end
end

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

function MainMenuBarPerformanceBarFrame_OnEnter(self)
	local string = "";
	local i, j, k = 0, 0, 0;

	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);

	-- latency
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latencyHome, latencyWorld);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	-- protocol types
	if ( GetCVarBool("useIPv6") ) then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes();
		string = format(MAINMENUBAR_PROTOCOLS_LABEL, ipTypes[ipTypeHome or 0] or UNKNOWN, ipTypes[ipTypeWorld or 0] or UNKNOWN);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		GameTooltip:AddLine(" ");
	end

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	string = format(MAINMENUBAR_BANDWIDTH_LABEL, GetAvailableBandwidth());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	local percent = floor(GetDownloadedPercentage()*100+0.5);
	string = format(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL, percent);
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);

	-- Downloaded cinematics
	local firstMovie = true;
	for i, movieList in next, MovieList do
		local inProgress, downloaded, total = MainMenu_GetMovieDownloadProgress(i);
		if ( inProgress ) then
			if ( firstMovie ) then
				GameTooltip:AddLine("   "..CINEMATICS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
				firstMovie = false;
			end
			GameTooltip:AddLine("   "..format(CINEMATIC_DOWNLOAD_FORMAT, _G["CINEMATIC_NAME_"..i], downloaded/total*100), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
	end

	-- AddOn mem usage
	for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
		topAddOns[i].value = 0;
	end

	UpdateAddOnMemoryUsage();
	local totalMem = 0;

	for i=1, GetNumAddOns(), 1 do
		local mem = GetAddOnMemoryUsage(i);
		totalMem = totalMem + mem;
		for j=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if( mem > topAddOns[j].value ) then
				for k=NUM_ADDONS_TO_DISPLAY, 1, -1 do
					if( k == j ) then
						topAddOns[k].value = mem;
						topAddOns[k].name = GetAddOnInfo(i);
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

		local size;
		for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if ( topAddOns[i].value == 0 ) then
				break;
			end
			size = topAddOns[i].value;
			if ( size > 1000 ) then
				size = size / 1000;
				string = format(ADDON_MEM_MB_ABBR, size, topAddOns[i].name);
			else
				string = format(ADDON_MEM_KB_ABBR, size, topAddOns[i].name);
			end
			GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		end
	end
	GameTooltip:Show();
end

function MainMenuBarMixin:SetQuickKeybindModeEffectsShown(showEffects)
	self.QuickKeybindBottomShadow:SetShown(showEffects);
	self.QuickKeybindGlowSmall:SetShown(showEffects);
	self.QuickKeybindGlowLarge:SetShown(showEffects);
	MicroButtonAndBagsBar.QuickKeybindsMicroBagBarGlow:SetShown(showEffects);
	local useRightShadow = MultiBarRight:IsShown();
	self.QuickKeybindRightShadow:SetShown(useRightShadow and showEffects);
end

function MainMenuBarMixin:UpdateEndCaps(overrideHideEndCaps)
	local factionGroup = UnitFactionGroup("player");
	local showEndCaps = false;

	if ( factionGroup and factionGroup ~= "Neutral" ) then

		if ( factionGroup == "Alliance" ) then
			self.EndCaps.LeftEndCap:SetAtlas("ui-hud-actionbar-gryphon-left");
			self.EndCaps.RightEndCap:SetAtlas("ui-hud-actionbar-gryphon-right");
		elseif ( factionGroup == "Horde" ) then
			self.EndCaps.LeftEndCap:SetAtlas("ui-hud-actionbar-wyvern-left");
			self.EndCaps.RightEndCap:SetAtlas("ui-hud-actionbar-wyvern-right");
		end

		showEndCaps = true;
	end

	self.EndCaps:SetShown(showEndCaps and not overrideHideEndCaps);
end

function MainMenuBarMixin:EditModeSetScale(newScale)
	self.BorderArt:SetScale(newScale);

	-- For end caps and page number, only scale down, not up
	self.EndCaps:SetScale(newScale < 1 and newScale or 1);
	self.ActionBarPageNumber:SetScale(newScale < 1 and newScale or 1);
end

MainActionBarUpButtonMixin = {}

function MainActionBarUpButtonMixin:OnClick()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ActionBar_PageUp();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function MainActionBarUpButtonMixin:OnLeave()
	GameTooltip:Hide();
end

MainActionBarDownButtonMixin = {}

function MainActionBarDownButtonMixin:OnClick()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		ActionBar_PageDown();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end
end

function MainActionBarDownButtonMixin:OnLeave()
	GameTooltip:Hide();
end