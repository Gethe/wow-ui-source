MAX_ALWAYS_UP_UI_FRAMES = 2;
MAX_WORLDSTATE_SCORE_BUTTONS = 23;
MAX_NUM_STAT_COLUMNS = 7;
WORLDSTATESCOREFRAME_BASE_WIDTH = 530;
WORLDSTATESCOREFRAME_COLUMN_SPACING = 75;
WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET = -32;

-- Always up stuff (i.e. capture the flag indicators)
function WorldStateAlwaysUpFrame_OnLoad()
	this:RegisterEvent("UPDATE_WORLD_STATES");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WorldStateAlwaysUpFrame_OnEvent()
	if ( event == "UPDATE_WORLD_STATES" or event == "PLAYER_ENTERING_WORLD" ) then
		WorldStateAlwaysUpFrame_Update();
	end
end

function WorldStateAlwaysUpFrame_Update()
	local numUI = GetNumWorldStateUI();
	local frame, frameText, frameDynamicIcon, frameIcon, frameFlash, flashTexture, frameDynamicButton; 
	local text, icon, isFlashing, dynamicIcon, tooltip, dynamicTooltip;
	for i=1, MAX_ALWAYS_UP_UI_FRAMES do
		frame = getglobal("AlwaysUpFrame"..i);
		if ( i <= numUI ) then
			frameText = getglobal("AlwaysUpFrame"..i.."Text");
			frameDynamicIcon = getglobal("AlwaysUpFrame"..i.."DynamicIconButtonIcon");
			frameIcon = getglobal("AlwaysUpFrame"..i.."Icon");
			frameFlash = getglobal("AlwaysUpFrame"..i.."Flash");
			flashTexture = getglobal("AlwaysUpFrame"..i.."FlashTexture");
			frameDynamicButton = getglobal("AlwaysUpFrame"..i.."DynamicIconButton");

			text, icon, isFlashing, dynamicIcon, tooltip, dynamicTooltip = GetWorldStateUIInfo(i);
			frameText:SetText(text);
			frameDynamicIcon:SetTexture(dynamicIcon);
			frameIcon:SetTexture(icon);
			flashTexture:SetTexture(dynamicIcon.."Flash");
			frame.tooltip = tooltip;
			frameDynamicButton.tooltip = dynamicTooltip;
			if ( isFlashing ) then
				UIFrameFlash(frameFlash, 0.5, 0.5, -1);
				frameDynamicButton:Show();
			else
				UIFrameFlash(frameFlash, 0.5, 0.5, 0);
				frameDynamicButton:Hide();
			end
			frame:Show();
		else
			frame:Hide();
		end
	end
end

-------------- FINAL SCORE FUNCTIONS ---------------

function WorldStateScoreFrame_OnLoad()
	this:RegisterEvent("UPDATE_BATTLEFIELD_SCORE");
	this:RegisterEvent("UPDATE_WORLD_STATES");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 3);

	WorldStateScoreFrame_Resize();
end

function WorldStateScoreFrame_Update()
	--Show the frame if its hidden and there is a victor
	if ( GetBattlefieldWinner() ) then
		-- Show the final score frame, set textures etc.
		ShowUIPanel(WorldStateScoreFrame);
		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();

		-- Set num visible buttons
		--MAX_WORLDSTATE_SCORE_BUTTONS = 22;
		WorldStateScoreButton23:Hide();

		-- Show winner
		local battlefieldWinner = GetBattlefieldWinner(); 
		WorldStateScoreWinnerFrameText:SetText(getglobal("VICTORY_TEXT"..battlefieldWinner));
		if ( battlefieldWinner == 0 ) then
			-- Horde won
			WorldStateScoreWinnerFrameLeft:SetTexCoord(0, 1, 0.5, 0.75);
			WorldStateScoreWinnerFrameRight:SetTexCoord(0, 0.97265625, 0.75, 1.0);
			WorldStateScoreWinnerFrameText:SetVertexColor(1.0, 0.1, 0.1);
		else
			-- Alliance won
			WorldStateScoreWinnerFrameLeft:SetTexCoord(0, 1, 0, 0.25);
			WorldStateScoreWinnerFrameRight:SetTexCoord(0, 0.97265625, 0.25, 0.5);
			WorldStateScoreWinnerFrameText:SetVertexColor(0, 0.68, 0.94);	
		end
		WorldStateScoreWinnerFrame:Show();

		-- Flag cap stuff
		--[[
		if ( GetNumBattlefieldWorldStateUI() == 1 ) then
			local text = GetBattlefieldWorldStateUIInfo(1);
			WorldStateScoreTotalFrameText:SetText(text);
			if ( PanelTemplates_GetSelectedTab(WorldStateScoreFrame) == 2 ) then
				WorldStateScoreTotalFrameLeft:SetTexCoord(0, 1, 0, 0.25);
				WorldStateScoreTotalFrameRight:SetTexCoord(0, 0.97265625, 0.25, 0.5);
				WorldStateScoreTotalFrameText:SetVertexColor(0, 0.68, 0.94);				
			elseif ( PanelTemplates_GetSelectedTab(WorldStateScoreFrame) == 3 ) then
				WorldStateScoreTotalFrameLeft:SetTexCoord(0, 1, 0.5, 0.75);
				WorldStateScoreTotalFrameRight:SetTexCoord(0, 0.97265625, 0.75, 1.0);
				WorldStateScoreTotalFrameText:SetVertexColor(1.0, 0.1, 0.1);
			end
			WorldStateScoreTotalFrame:Show();
		else
			WorldStateScoreTotalFrame:Hide();
		end
		]]
	else
		--MAX_WORLDSTATE_SCORE_BUTTONS = 23;
		
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
		WorldStateScoreFrameTimerLabel:Hide();
		WorldStateScoreFrameTimer:Hide();
		--WorldStateScoreTotalFrame:Hide();
	end
	
	-- Update buttons
	local numScores = GetNumBattlefieldScores();
	local scoreButton, buttonIcon, buttonName, nameButton, buttonKills, buttonDeaths, buttonHonorGained, buttonFaction, columnButtonText, columnButtonIcon, buttonFactionLeft, buttonFactionRight;
	local name, kills, killingBlows, deaths, honorGained, faction, rank, race, class;
	local index;
	local columnData;

        -- ScrollFrame update
	local hasScrollBar;
	if ( numScores > MAX_WORLDSTATE_SCORE_BUTTONS ) then
		hasScrollBar = 1;
		WorldStateScoreScrollFrame:Show();
	else
		WorldStateScoreScrollFrame:Hide();
        end
	FauxScrollFrame_Update(WorldStateScoreScrollFrame, numScores, MAX_WORLDSTATE_SCORE_BUTTONS, 16 );

	-- Setup Columns
	local text, icon, tooltip, columnButton;
	local numStatColumns = GetNumBattlefieldStats();
	local columnButton, columnButtonText, columnTextButton, columnIcon;
	local honorGainedAnchorFrame = "WorldStateScoreFrameHK";
	for i=1, MAX_NUM_STAT_COLUMNS do
		if ( i <= numStatColumns ) then
			text, icon, tooltip = GetBattlefieldStatInfo(i);
			columnButton = getglobal("WorldStateScoreColumn"..i);
			columnButtonText = getglobal("WorldStateScoreColumn"..i.."Text");
			columnButtonText:SetText(text);
			columnButton.icon = icon;
			columnButton.tooltip = tooltip;
			
			columnTextButton = getglobal("WorldStateScoreButton1Column"..i.."Text");

			if ( icon ~= "" ) then
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, -33);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, -33);
			end

			
			if ( i == numStatColumns ) then
				honorGainedAnchorFrame = "WorldStateScoreColumn"..i;
			end
			

			getglobal("WorldStateScoreColumn"..i):Show();
		else
			getglobal("WorldStateScoreColumn"..i):Hide();
		end
	end
	
	-- Anchor the bonus honor gained to the last column shown
	WorldStateScoreFrameHonorGained:SetPoint("CENTER", honorGainedAnchorFrame, "CENTER", 88, 0);
	
	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		-- Need to create an index adjusted by the scrollframe offset
		index = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame) + i;
		scoreButton = getglobal("WorldStateScoreButton"..i);
		if ( hasScrollBar ) then
			scoreButton:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		else
			scoreButton:SetWidth(WorldStateScoreFrame.buttonWidth);
		end
		if ( index <= numScores ) then
			buttonIcon = getglobal("WorldStateScoreButton"..i.."RankButtonIcon");
			buttonName = getglobal("WorldStateScoreButton"..i.."NameButtonName");
			nameButton = getglobal("WorldStateScoreButton"..i.."NameButton");
			buttonKills = getglobal("WorldStateScoreButton"..i.."HonorableKills");
			buttonKillingBlows = getglobal("WorldStateScoreButton"..i.."KillingBlows");
			buttonDeaths = getglobal("WorldStateScoreButton"..i.."Deaths");
			buttonHonorGained = getglobal("WorldStateScoreButton"..i.."HonorGained");
			buttonFactionLeft = getglobal("WorldStateScoreButton"..i.."FactionLeft");
			buttonFactionRight = getglobal("WorldStateScoreButton"..i.."FactionRight");
			
			name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class = GetBattlefieldScore(index);
			rankName, rankNumber = GetPVPRankInfo(rank, faction);
			if ( rankNumber > 0 ) then
				buttonIcon:SetTexture(format("%s%02d","Interface\\PvPRankBadges\\PvPRank", rankNumber));
				buttonIcon:Show();
			else
				buttonIcon:Hide();
			end
			
			buttonName:SetText(name);
			nameButton:SetWidth(buttonName:GetWidth());
			nameButton.tooltip = race.." "..class;
			getglobal("WorldStateScoreButton"..i.."RankButton").tooltip = rankName;
			buttonKills:SetText(honorableKills);
			buttonKillingBlows:SetText(killingBlows);
			buttonDeaths:SetText(deaths);
			buttonHonorGained:SetText(honorGained);
			for j=1, MAX_NUM_STAT_COLUMNS do
				columnButtonText = getglobal("WorldStateScoreButton"..i.."Column"..j.."Text");
				columnButtonIcon = getglobal("WorldStateScoreButton"..i.."Column"..j.."Icon");
				if ( j <= numStatColumns ) then
					-- If there's an icon then move the icon left and format the text with an "x" in front
					columnData = GetBattlefieldStatData(index, j);
					if ( getglobal("WorldStateScoreColumn"..j).icon ~= "" ) then
						if ( columnData > 0 ) then
							columnButtonText:SetText(format(FLAG_COUNT_TEMPLATE, columnData));
							columnButtonIcon:SetTexture(getglobal("WorldStateScoreColumn"..j).icon..faction);
							columnButtonIcon:Show();
						else
							columnButtonText:SetText("");
							columnButtonIcon:Hide();
						end
						
					else
						columnButtonText:SetText(columnData);
						columnButtonIcon:Hide();
					end
					columnButtonText:Show();
				else
					columnButtonText:Hide();
					columnButtonIcon:Hide();
				end
			end
			
			if ( faction ) then
				if ( faction == 0 ) then
					buttonFactionLeft:SetTexCoord(0, 1, 0.5, 0.75);
					buttonFactionRight:SetTexCoord(0, 0.97265625, 0.75, 1.0);
					buttonName:SetVertexColor(1.0, 0.1, 0.1);
				else
					buttonFactionLeft:SetTexCoord(0, 1, 0, 0.25);
					buttonFactionRight:SetTexCoord(0, 0.97265625, 0.25, 0.5);
					buttonName:SetVertexColor(0, 0.68, 0.94);
				end
				if ( name == UnitName("player") ) then
					buttonName:SetVertexColor(1.0, 0.82, 0);
				end
				buttonFactionLeft:Show();
				buttonFactionRight:Show();
			else
				buttonFactionLeft:Hide();
				buttonFactionRight:Hide();
			end

			scoreButton:Show();
		else
			scoreButton:Hide();
		end
	end

	if ( hasScrollBar ) then
		--WorldStateScoreTotalFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		WorldStateScoreWinnerFrame:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth-22);
	else
		--WorldStateScoreTotalFrame:SetWidth(WorldStateScoreFrame.buttonWidth);
		WorldStateScoreWinnerFrame:SetWidth(WorldStateScoreFrame.buttonWidth-22);
	end
end

function WorldStateScoreFrame_Resize(width)
	if ( width ) then
		WorldStateScoreFrame:SetWidth(width);
	else
		WorldStateScoreFrame:SetWidth(WORLDSTATESCOREFRAME_BASE_WIDTH + GetNumBattlefieldStats()*WORLDSTATESCOREFRAME_COLUMN_SPACING);
	end
	WorldStateScoreFrameTopBackground:SetWidth(WorldStateScoreFrame:GetWidth()-129);
	WorldStateScoreFrameTopBackground:SetTexCoord(0, WorldStateScoreFrameTopBackground:GetWidth()/256, 0, 1.0);
	WorldStateScoreFrame.scrollBarButtonWidth = WorldStateScoreFrame:GetWidth() - 165;
	WorldStateScoreFrame.buttonWidth = WorldStateScoreFrame:GetWidth() - 137;

	-- Position Column data horizontally
	local buttonKills, buttonDeaths, buttonHonorGained, buttonReturnedIcon, buttonCapturedIcon;
	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		buttonKills = getglobal("WorldStateScoreButton"..i.."HonorableKills");
		buttonKillingBlows = getglobal("WorldStateScoreButton"..i.."KillingBlows");
		buttonDeaths = getglobal("WorldStateScoreButton"..i.."Deaths");
		buttonHonorGained = getglobal("WorldStateScoreButton"..i.."HonorGained");
		if ( i == 1 ) then
			buttonKills:SetPoint("CENTER", "WorldStateScoreFrameHK", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonKillingBlows:SetPoint("CENTER", "WorldStateScoreFrameKB", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonDeaths:SetPoint("CENTER", "WorldStateScoreFrameDeaths", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			buttonHonorGained:SetPoint("CENTER", "WorldStateScoreFrameHonorGained", "CENTER", 0, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
		else
			buttonKills:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorableKills", "CENTER", 0, -15);
			buttonKillingBlows:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."KillingBlows", "CENTER", 0, -15);
			buttonDeaths:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Deaths", "CENTER", 0, -15);
			buttonHonorGained:SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."HonorGained", "CENTER", 0, -15);
			for j=1, MAX_NUM_STAT_COLUMNS do
				getglobal("WorldStateScoreButton"..i.."Column"..j.."Text"):SetPoint("CENTER", "WorldStateScoreButton"..(i-1).."Column"..j.."Text", "CENTER", 0, -15);
			end
		end
	end
end

function WorldStateScoreFrameTab_OnClick(tab)
	if ( not tab ) then
		tab = this;
	end
	local faction = tab:GetID();
	PanelTemplates_SetTab(WorldStateScoreFrame, faction);
	if ( faction == 2 ) then
		faction = 1;
	elseif ( faction == 3 ) then
		faction = 0;
	else
		faction = nil;
	end
	WorldStateScoreFrameLabel:SetText(format(STAT_TEMPLATE, tab:GetText()));
	SetBattlefieldScoreFaction(faction);
	PlaySound("igCharacterInfoTab");
end

function ToggleWorldStateScoreFrame()
	if ( WorldStateScoreFrame:IsVisible() ) then
		HideUIPanel(WorldStateScoreFrame);
	else
		local status, mapName, instanceID = GetBattlefieldStatus();
		if ( status == "active" ) then
			ShowUIPanel(WorldStateScoreFrame);
		end
	end
end


---------------------- TEST DATA AND FUNCTIONS---------------------------
WORLDSTATE_TEST_DATA = {
	{"MCStomp",	20,	36,	6,	3200,	0,	"Tauren",	"Shaman"},
	{"Figluster",	35,	42,	23,	200,	0,	"Tauren",	"Druid"},
};
