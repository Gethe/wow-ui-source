BATTLEFIELD_ZONES_DISPLAYED = 5;
BATTLEFIELD_ZONES_HEIGHT = 20;

function BattlefieldFrame_OnLoad()
	this:RegisterEvent("BATTLEFIELDS_SHOW");
	this:RegisterEvent("BATTLEFIELDS_CLOSED");
end

function BattlefieldFrame_OnEvent()
	if ( event == "BATTLEFIELDS_SHOW" ) then
		ShowUIPanel(BattlefieldFrame);
		if ( not BattlefieldFrame:IsVisible() ) then
			CloseBattlefield();
			return;
		end

		BattlefieldFrameJoinButton:Disable();
		UpdateMicroButtons();
		BattlefieldFrame_Update();
	end
	if ( event == "BATTLEFIELDS_CLOSED" ) then
		HideUIPanel(BattlefieldFrame);
	end
end

function BattlefieldFrame_Update()
	local zoneIndex;
	local zoneOffset = FauxScrollFrame_GetOffset(BattlefieldListScrollFrame);
	local mapName, mapDescription, minLevel, maxLevel, mapID, mapX, mapY, mapFull;
	local playerLevel = UnitLevel("player");
	local button, buttonName, buttonLevel, buttonHighlight;

	for i=1, BATTLEFIELD_ZONES_DISPLAYED, 1 do
		zoneIndex = zoneOffset + i;
		button = getglobal("BattlefieldZone"..zoneIndex);
		buttonName = getglobal("BattlefieldZone"..zoneIndex.."Name");
		buttonLevel = getglobal("BattlefieldZone"..zoneIndex.."Level");
		buttonHighlight = getglobal("BattlefieldZone"..zoneIndex.."Highlight");

		if ( zoneIndex > GetNumBattlefields() ) then
			button:Hide();
		else
			mapName, mapDescription, minLevel, maxLevel, mapID, mapX, mapY, mapFull = GetBattlefieldInfo(zoneIndex);

			button:Show();

			if ( mapFull ) then
				buttonName:SetText(format(BATTLEFIELD_FULL, mapName));
			else
				buttonName:SetText(mapName);
			end

			buttonLevel:SetText(minLevel.." - "..maxLevel);
			
			if ( (playerLevel < minLevel) or (playerLevel > maxLevel) ) then
				buttonName:SetTextColor(0.5, 0.5, 0.5);
				buttonLevel:SetTextColor(0.5, 0.5, 0.5);
				buttonHighlight:SetVertexColor(0.5, 0.5, 0.5);
			elseif ( mapFull ) then
				buttonName:SetTextColor(1.0, 0.0, 0.0);
				buttonLevel:SetTextColor(1.0, 0.0, 0.0);
				buttonHighlight:SetVertexColor(1.0, 0.0, 0.0);
			else
				buttonName:SetTextColor(0.0, 1.0, 0.0);
				buttonLevel:SetTextColor(0.0, 1.0, 0.0);
				buttonHighlight:SetVertexColor(0.0, 1.0, 0.0);
			end
		end

		if ( zoneIndex == GetSelectedBattlefield() ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end
	end

	if ( GetSelectedBattlefield() == 0 ) then
		BattlefieldFrameZoneDescription:SetText("");
		BattlefieldFrameJoinButton:Disable();
	else
		mapName, mapDescription, minLevel, maxLevel, mapID, mapX, mapY, mapFull = GetBattlefieldInfo(GetSelectedBattlefield());

		BattlefieldFrameZoneDescription:SetText(mapDescription);
		
		if ( (playerLevel < minLevel) or (playerLevel > maxLevel) or (mapFull) ) then
			BattlefieldFrameJoinButton:Disable();
		else
			BattlefieldFrameJoinButton:Enable();
		end
	end

	FauxScrollFrame_Update(BattlefieldListScrollFrame, GetNumBattlefields(), BATTLEFIELD_ZONES_DISPLAYED, BATTLEFIELD_ZONES_HEIGHT);
end

function BattlefieldButton_OnClick(id)
	SetSelectedBattlefield(FauxScrollFrame_GetOffset(BattlefieldListScrollFrame) + id);
	BattlefieldFrame_Update();
end

function BattlefieldFrameJoinButton_OnClick()
	JoinBattlefield(GetSelectedBattlefield());
	BattlefieldFrame:Hide();
end
