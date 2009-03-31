
MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 20;
MAX_RAID_INFOS_DISPLAYED = 4;

function RaidFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("VOICE_STATUS_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("READY_CHECK_FINISHED");

	-- Update party frame visibility
	RaidOptionsFrame_UpdatePartyFrames();
	RaidFrame_Update();

	RaidFrame.hasRaidInfo = nil;
end

function RaidFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RequestRaidInfo();
	elseif ( event == "PLAYER_LOGIN" ) then
		if ( GetNumRaidMembers() > 0 ) then
			RaidFrame_LoadUI();
			RaidFrame_Update();
		end
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		RaidFrame_LoadUI();
		RaidFrame_Update();
		RaidPullout_RenewFrames();
	elseif ( event == "READY_CHECK" or
		 event == "READY_CHECK_CONFIRM" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_Update ) then
			RaidGroupFrame_Update();
		end
	elseif ( event == "READY_CHECK_FINISHED" ) then
		if ( RaidFrame:IsShown() and RaidGroupFrame_ReadyCheckFinished ) then
			RaidGroupFrame_ReadyCheckFinished();
		end
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( not RaidFrame.hasRaidInfo ) then
			-- Set flag
			RaidFrame.hasRaidInfo = 1;
			return;
		end
		if ( GetNumSavedInstances() > 0 ) then
			RaidFrameRaidInfoButton:Enable();
		else
			RaidFrameRaidInfoButton:Disable();
		end
		RaidInfoFrame_Update();
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "VOICE_STATUS_UPDATE" ) then
		RaidFrame_Update();
	end
end

function RaidFrame_Update()
	-- If not in a raid hide all the UI and just display raid explanation text
	if ( GetNumRaidMembers() == 0 ) then
		RaidFrameConvertToRaidButton:Show();
		if ( GetPartyMember(1) and IsPartyLeader() ) then
			RaidFrameConvertToRaidButton:Enable();
		else
			RaidFrameConvertToRaidButton:Disable();
		end
		RaidFrameRaidDescription:Show();
	else
		RaidFrameConvertToRaidButton:Hide();
		RaidFrameRaidDescription:Hide();
	end

	if ( RaidGroupFrame_Update ) then
		RaidGroupFrame_Update();
	end
end

-- Function for raid options
function RaidOptionsFrame_UpdatePartyFrames()
	if ( HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0) then
		HidePartyFrame();
	else
		HidePartyFrame();
		ShowPartyFrame();
	end
	UpdatePartyMemberBackground();
end

-- Populates Raid Info Data
function RaidInfoFrame_Update()
	local savedInstances = GetNumSavedInstances();
	local instanceName, instanceID, instanceReset, instanceDifficulty, extend, width;
	local frameName, frameNameText, frameID, frameReset;
	if ( savedInstances > 0 ) then
		if ( savedInstances > MAX_RAID_INFOS_DISPLAYED ) then
			width = 210;
			RaidInfoScrollFrameTop:Show();
			RaidInfoScrollFrameBottom:Show();
			RaidInfoScrollFrameScrollBar:Show();
			RaidInfoFrame.scrolling = 1;
		else
			width = 235;
			RaidInfoScrollFrameTop:Hide();
			RaidInfoScrollFrameBottom:Hide();
			RaidInfoScrollFrameScrollBar:Hide();
			RaidInfoFrame.scrolling = nil;
		end
		for i=1, MAX_RAID_INFOS do
			local frame = _G["RaidInfoInstance"..i];
			if ( i <=  savedInstances) then
				instanceName, instanceID, instanceReset, instanceDifficulty, extend = GetSavedInstanceInfo(i);
				 
				if ( not frame ) then
					local name =  "RaidInfoInstance"..i;
					frame = CreateFrame("FRAME", name, RaidInfoScrollChildFrame, "RaidInfoInstanceTemplate");
					frame:SetPoint("TOPLEFT", "RaidInfoInstance"..i-1, "BOTTOMLEFT", 0, 5);
				end

				frameName = _G["RaidInfoInstance"..i.."Name"];
				frameNameText = _G["RaidInfoInstance"..i.."NameText"];
				frameID = _G["RaidInfoInstance"..i.."ID"];
				frameReset = _G["RaidInfoInstance"..i.."Reset"];

				if ( instanceDifficulty > 1 ) then
					frameNameText:SetFormattedText(DUNGEON_NAME_WITH_DIFFICULTY, instanceName, _G["DUNGEON_DIFFICULTY"..instanceDifficulty]);
				else
					frameNameText:SetText(instanceName);
				end
				frameID:SetText(instanceID);
				if (extend) then
					if (instanceReset == 0) then
						frameReset:SetFormattedText(RAID_INSTANCE_EXPIRES_EXPIRED);
					else
						frameReset:SetFormattedText(RAID_INSTANCE_EXPIRES_EXTENDED, SecondsToTime(instanceReset, nil, nil, 3));
					end
				else
					frameReset:SetFormattedText(RAID_INSTANCE_EXPIRES, SecondsToTime(instanceReset, nil, nil, 3));
				end
				if ( RaidInfoFrame.scrolling ) then
					frameName:SetWidth(170);
				else
					frameName:SetWidth(180);
				end
				frame:SetWidth(width);
				frame:Show();
			else
				if ( frame ) then
					frame:Hide();
				end
			end
			
		end
	end
end
