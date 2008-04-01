NUM_FACTIONS_DISPLAYED = 14;
REPUTATIONFRAME_FACTIONHEIGHT = 26;
FACTION_BAR_COLORS = {
	[1] = {r = 0.8, g = 0, b = 0},
	[2] = {r = 0.8, g = 0, b = 0},
	[3] = {r = 0.75, g = 0.27, b = 0},
	[4] = {r = 0.9, g = 0.7, b = 0},
	[5] = {r = 0, g = 0.6, b = 0.1},
	[6] = {r = 0, g = 0.6, b = 0.1},
	[7] = {r = 0, g = 0.6, b = 0.1},
	[8] = {r = 0, g = 0.6, b = 0.1},
};
function ReputationFrame_OnLoad()
	this:RegisterEvent("UPDATE_FACTION");
end

function ReputationFrame_OnShow()
	ReputationFrame_Update();
end

function ReputationFrame_OnEvent(event)
	if ( event == "UPDATE_FACTION" ) then
		if ( this:IsVisible() ) then
			ReputationFrame_Update();
		end
	end
end

function ReputationFrame_Update()
	local numFactions = GetNumFactions();
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame);
	local factionIndex, factionStanding, factionBar, factionHeader, color;
	local name, standingID, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed;
	local checkbox, check, rightBarTexture;

	-- Update scroll frame
	FauxScrollFrame_Update(ReputationListScrollFrame, numFactions, NUM_FACTIONS_DISPLAYED, REPUTATIONFRAME_FACTIONHEIGHT )
		
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		factionIndex = factionOffset + i;
		factionBar = getglobal("ReputationBar"..i);
		factionHeader = getglobal("ReputationHeader"..i);
		if ( factionIndex <= numFactions ) then
			name, standingID, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed = GetFactionInfo(factionIndex);
			if ( isHeader ) then
				factionHeader:SetText(name);
				if ( isCollapsed ) then
					factionHeader:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					factionHeader:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up"); 
				end
				factionHeader.index = factionIndex;
				factionHeader.isCollapsed = isCollapsed;
				factionBar:Hide();
				factionHeader:Show();
			else
				factionStanding = getglobal("FACTION_STANDING_LABEL"..standingID);
				getglobal("ReputationBar"..i.."FactionName"):SetText(name);
				getglobal("ReputationBar"..i.."FactionStanding"):SetText(factionStanding);
				checkbox = getglobal("ReputationBar"..i.."AlliedCheckButton");
				check = getglobal("ReputationBar"..i.."AlliedCheckButtonCheck");
				rightBarTexture = getglobal("ReputationBar"..i.."ReputationBarRight");
				checkbox:SetChecked(atWarWith);
				if ( canToggleAtWar ) then
					checkbox:Enable();
					check:SetVertexColor(1.0, 1.0, 1.0);
					rightBarTexture:SetTexCoord(0, 0.14453125, 0.34375, 0.71875);
				else
					if ( atWarWith ) then
						check:SetVertexColor(1.0, 0.1, 0.1);
						rightBarTexture:SetTexCoord(0.1484375, 0.29296875, 0.34375, 0.71875);
					else
						check:SetVertexColor(1.0, 1.0, 1.0);
						rightBarTexture:SetTexCoord(0.296875, 0.44140625, 0.34375, 0.71875);
					end
					checkbox:Disable();
				end
				factionBar:SetValue(barValue);
				color = FACTION_BAR_COLORS[standingID];
				factionBar:SetStatusBarColor(color.r, color.g, color.b);
				factionBar:SetID(factionIndex);
				factionBar:Show();
				factionHeader:Hide();
			end
		else
			factionHeader:Hide();
			factionBar:Hide();
		end
	end
end
