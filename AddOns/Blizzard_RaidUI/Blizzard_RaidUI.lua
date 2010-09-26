MAX_RAID_GROUPS = 8;
RAID_RANGE_ALPHA = 0.5;
MOVING_RAID_MEMBER = nil;
TARGET_RAID_SLOT = nil;
RAID_SUBGROUP_LISTS = {};
NUM_RAID_PULLOUT_FRAMES = 0;
RAID_PULLOUT_BUTTON_HEIGHT = 33;
MOVING_RAID_PULLOUT = nil;
RAID_PULLOUT_POSITIONS = {};
RAID_SINGLE_POSITIONS = {};
MAX_RAID_AURAS = 4;

RAID_CLASS_BUTTONS = { };
do
	-- fill in the table
	for index, value in ipairs(CLASS_SORT_ORDER) do
		RAID_CLASS_BUTTONS[value] = { button = index, coords = CLASS_ICON_TCOORDS[value] };
	end
	RAID_CLASS_BUTTONS["PETS"]			= { button = 11, coords = {0, 1, 0, 1} };
	RAID_CLASS_BUTTONS["MAINTANK"]		= { button = 12, coords = {0, 1, 0, 1} };
	RAID_CLASS_BUTTONS["MAINASSIST"]	= { button = 13, coords = {0, 1, 0, 1} };
end
MAX_RAID_CLASS_BUTTONS = MAX_CLASSES + 3;

RAID_PULLOUT_SAVED_SETTINGS = { 
	["showTarget"] = true, 
	["showBuffs"] = true, 
	["showTargetTarget"] = true, 
	["showDebuffs"] = true, 
	["showBG"] = true,
};

local getn = getn;
local format = format;
local next = next;
local gsub = gsub;
local tinsert = tinsert;
local tremove = tremove;
local tonumber = tonumber;
local tostring = tostring;

function RaidClassButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	local id = self:GetID();
	local icon = _G[self:GetName().."IconTexture"];
	for index, value in pairs(RAID_CLASS_BUTTONS) do
		if ( id ==  value.button ) then
			self.class = index;
			if ( index == "PETS" ) then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-Pets");
			elseif ( index == "MAINTANK" ) then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainTank");
			elseif ( index == "MAINASSIST" ) then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainAssist");
			else
				icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
			end
			icon:SetTexCoord(value.coords[1], value.coords[2], value.coords[3], value.coords[4]);

		end
	end
	_G[self:GetName().."Count"]:SetTextHeight(9);
end

function RaidClassButton_Update()
	-- Update Actual Count
	local button, icon, count;
	for index, value in pairs(RAID_CLASS_BUTTONS) do
		button  = _G["RaidClassButton"..value.button];
		count = _G["RaidClassButton"..value.button.."Count"];
		icon = _G["RaidClassButton"..value.button.."IconTexture"];

		if ( index == "PETS" ) then
			local petCount = 0;
			for i, v in pairs(RAID_SUBGROUP_LISTS[index]) do
				if ( UnitExists("raidpet"..RAID_SUBGROUP_LISTS[index][i]) ) then
					petCount = petCount + 1;
				end
			end
			button.count = petCount;
		else
			if ( RAID_SUBGROUP_LISTS[index] ) then
				button.count = #RAID_SUBGROUP_LISTS[index];
			end
		end

		if ( button.count > 0 ) then
			SetItemButtonDesaturated(button, nil);
			icon:SetAlpha(1);
			count:SetText(button.count);
			count:Show();
			if ( index == "PETS" ) then
				button.class = PETS;
				button.fileName = index;
			elseif ( index == "MAINTANK" ) then
				button.class = MAINTANK;
				button.fileName = index;
				button.id = RAID_SUBGROUP_LISTS[index][1];
				count:Hide();
			elseif ( index == "MAINASSIST"  ) then
				button.class = MAINASSIST;
				button.fileName = index;
				button.id = RAID_SUBGROUP_LISTS[index][1];
				count:Hide();
			else
				button.class, button.fileName = UnitClassBase("raid"..RAID_SUBGROUP_LISTS[index][1]);
			end
			button:Enable();
		else
			button:Disable();
			icon:SetAlpha(0.5);
			SetItemButtonDesaturated(button, 1);
			count:Hide();
			button.class = nil;
			button.fileName = nil;
		end
	end
end

function RaidClassButton_OnEnter(self)
	self.tooltip = format("%s%s (%d)%s", self.class, NORMAL_FONT_COLOR_CODE, self.count, FONT_COLOR_CODE_CLOSE);
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, 1);
	local classList;
	if ( getn(RAID_SUBGROUP_LISTS[self.fileName]) > 0 ) then
		local unit = "raid";
		if ( self.fileName == "PETS" ) then
			unit = "raidpet";
		end
		for index, value in pairs(RAID_SUBGROUP_LISTS[self.fileName]) do
			if (  UnitExists(unit..value) ) then
				if ( classList ) then
					classList = classList..", "..UnitName(unit..value);
				else
					classList = UnitName(unit..value);
				end
			end
		end
	end
	GameTooltip:AddLine(classList, 1, 1, 1);
	GameTooltip:AddLine(TOOLTIP_RAID_CLASS_BUTTON, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	GameTooltip:Show();
end

function RaidGroupFrame_OnLoad()
	RaidFrame:RegisterEvent("UNIT_PET");
	RaidFrame:RegisterEvent("UNIT_NAME_UPDATE");
	RaidFrame:RegisterEvent("UNIT_LEVEL");
	RaidFrame:RegisterEvent("UNIT_HEALTH");
	RaidFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	RaidFrame:RegisterEvent("VARIABLES_LOADED")
	RaidFrame:SetScript("OnHide", RaidGroupFrame_OnHide);
	RaidFrame:SetScript("OnEvent", RaidGroupFrame_OnEvent);
	RaidFrame:SetScript("OnUpdate", RaidGroupFrame_OnUpdate);
	
	RaidFrame.showRange = GetCVarBool("showRaidRange");
end

function RaidGroupFrame_OnHide()
	-- If there's a selected button then call the onmouseup function on it when the frame is hidden
	if ( MOVING_RAID_MEMBER ) then
		RaidGroupButton_OnDragStop(MOVING_RAID_MEMBER);
	end
end

function RaidGroupFrame_OnEvent(self, event, ...)
	RaidFrame_OnEvent(self, event, ...);
	if ( event == "UNIT_LEVEL" ) then
		local arg1 = ...;
		local id, found = gsub(arg1, "raid([0-9]+)", "%1");
		if ( found == 1 ) then
			RaidGroupFrame_UpdateLevel(id);
		end
	elseif ( event == "UNIT_HEALTH" ) then
		local arg1 = "...";
		local id, found = gsub(arg1, "raid([0-9]+)", "%1");
		if ( found == 1 ) then
			RaidGroupFrame_UpdateHealth(id);
		end
	elseif ( event == "UNIT_PET" or event == "UNIT_NAME_UPDATE" ) then
		RaidClassButton_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		RaidFrameReadyCheckButton_Update();
		RaidFrameRaidBrowserButton_Update();
		RaidPullout_RenewFrames();
	elseif ( event == "VARIABLES_LOADED" ) then
		RaidFrame.showRange = GetCVarBool("showRaidRange");
	end
end

local raid_groupSlots;

function RaidGroup_ResetSlotButtons()
	if ( raid_groupSlots ) then
		for i, group in next, raid_groupSlots do
			for j, slot in next, group do
				slot.button = nil;
			end
		end
	else
		raid_groupSlots = {};
		for i=1, NUM_RAID_GROUPS do
			raid_groupSlots[i] = {};
			for j=1, MEMBERS_PER_RAID_GROUP do
				raid_groupSlots[i][j] = _G["RaidGroup"..i.."Slot"..j];
				raid_groupSlots[i][j].button = nil;
			end
		end
	end
end

local raid_groupFrames;
local classes;
local raid_buttons;

function RaidGroupFrame_Update()
	-- Update raid group labels
	if ( not raid_groupFrames ) then
		raid_groupFrames = {};
		for i=1, NUM_RAID_GROUPS do
			raid_groupFrames[i] = _G["RaidGroup"..i];
		end
	end
	
	if ( not classes ) then
		classes = {};
		for i=1, MAX_RAID_CLASS_BUTTONS do
			classes[i] = _G["RaidClassButton"..i];
		end
	end
	
	
	if ( GetNumRaidMembers() == 0 ) then
		for i=1, NUM_RAID_GROUPS do
			raid_groupFrames[i]:Hide()
		end
		for i=1, MAX_RAID_CLASS_BUTTONS do
			classes[i]:Hide();
		end
		RaidFrameReadyCheckButton:Hide();
	else
		for i=1, NUM_RAID_GROUPS do
			raid_groupFrames[i]:Show();
		end
		for i=1, MAX_RAID_CLASS_BUTTONS do
			--classes[i]:Show();
		end
	end

	RaidFrameReadyCheckButton_Update();
	RaidFrameRaidBrowserButton_Update();
	if ( RaidFrameReadyCheckButton:IsShown() ) then
		RaidFrameRaidInfoButton:SetPoint("LEFT", "RaidFrameReadyCheckButton", "RIGHT", 2, 0);
	end


	-- Reset group index counters;
	for i=1, NUM_RAID_GROUPS do
		raid_groupFrames[i].nextIndex = 1;
	end
	-- Clear out all the slots buttons
	RaidGroup_ResetSlotButtons();

	-- Clear out subgroup list
	for i, j in next, RAID_SUBGROUP_LISTS do
		RAID_SUBGROUP_LISTS[i] = nil;
	end
	
	for i=1, NUM_RAID_GROUPS do
		if ( RAID_SUBGROUP_LISTS[i] ) then
			for k, v in next, RAID_SUBGROUP_LISTS[i] do
				RAID_SUBGROUP_LISTS[i][k] = nil;
			end
		else
			RAID_SUBGROUP_LISTS[i] = {};
		end
	end

	-- Use the class color list to clear out the class list
	for index, value in pairs(RAID_CLASS_BUTTONS) do
		if ( RAID_SUBGROUP_LISTS[index] ) then
			for k, v in next, RAID_SUBGROUP_LISTS[index] do
				RAID_SUBGROUP_LISTS[index][k] = nil;
			end
		else
			RAID_SUBGROUP_LISTS[index] = {};
		end
	end

	-- Fill out buttons
	local numRaidMembers = GetNumRaidMembers();
	local raidGroup, color;
	local buttonFrameName, buttonName, buttonLevel, buttonClass, buttonRank;
	local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot, muted, unit;
	local buttonCount;
	local readyCheckStatus;
	local button, subframes;
	
	if ( not raid_buttons ) then
		raid_buttons = {};
		for i = 1, MAX_RAID_MEMBERS do
			raid_buttons[i] = _G["RaidGroupButton"..i];
		end
	end
	
	for i=1, MAX_RAID_MEMBERS do
		button = raid_buttons[i];
		if ( i <= numRaidMembers ) then
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(i);
			unit = "raid"..i;
			muted = GetMuteStatus(unit, "raid");
			raidGroup = raid_groupFrames[subgroup];
			readyCheckStatus = GetReadyCheckStatus(unit);
			-- To prevent errors when the server hiccups
			if ( raidGroup.nextIndex <= MEMBERS_PER_RAID_GROUP ) then
				subframes = button.subframes;
				if ( not subframes ) then
					subframes = {};
					subframes.name = _G["RaidGroupButton"..i.."Name"];
					subframes.class = _G["RaidGroupButton"..i.."Class"];
					subframes.level = _G["RaidGroupButton"..i.."Level"];
					subframes.rank = _G["RaidGroupButton"..i.."Rank"];
					subframes.role = _G["RaidGroupButton"..i.."Role"];
					subframes.loot = _G["RaidGroupButton"..i.."Loot"];
					subframes.rankTexture = _G["RaidGroupButton"..i.."RankTexture"];
					--buttonMutedTexture = _G["RaidGroupButton"..i.."RankMuted"];
					subframes.roleTexture = _G["RaidGroupButton"..i.."RoleTexture"];
					subframes.lootTexture = _G["RaidGroupButton"..i.."LootTexture"];
					subframes.readyCheck = _G["RaidGroupButton"..i.."ReadyCheck"];
					button.subframes = subframes;
				end
				
				button.name = name;
				button.class = fileName;

				if ( level == 0 ) then
					level = "";
				end
				
				if ( not name ) then
					name = UNKNOWN;
				end

				-- Fill in subgroup list
				tinsert(RAID_SUBGROUP_LISTS[subgroup], i);

				-- Fill in class list
				if ( fileName ) then
					tinsert(RAID_SUBGROUP_LISTS[fileName], i);
					--if ( UnitExists("raidpet"..i) ) then
					if ( fileName == "HUNTER" or fileName == "WARLOCK" ) then
						tinsert(RAID_SUBGROUP_LISTS["PETS"], i);
					end		
					--end
				end
				
				-- Place Main Tank & Main Assist into a subgroup
				if ( role ) then
					tinsert(RAID_SUBGROUP_LISTS[role], i);
				end

				subframes.name:SetText(name);
				if ( class ) then
					subframes.class:SetText(class);
				else
					subframes.class:SetText("");
				end
				if ( level ) then
					subframes.level:SetText(level);
				else
					subframes.level:SetText("");
				end
				if ( online ) then
					if ( isDead ) then
						subframes.name:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
						subframes.class:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
						subframes.level:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					else
						color = RAID_CLASS_COLORS[fileName];
						if ( color ) then
							subframes.name:SetTextColor(color.r, color.g, color.b);
							subframes.class:SetTextColor(color.r, color.g, color.b);
							subframes.level:SetTextColor(color.r, color.g, color.b);
						end
					end
				else
					subframes.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					subframes.class:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
					subframes.level:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				end

				--[[if ( muted ) then
					buttonMutedTexture:Show();
				else
					buttonMutedTexture:Hide();
				end]]

				-- Sets the Leader/Assistant Icon
				if ( rank == 2 ) then
					subframes.rankTexture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				elseif ( rank == 1 ) then
					subframes.rankTexture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon");
				elseif ( (rank == 0 ) and ( muted == 2 ) ) then
					subframes.rankTexture:SetTexture("Interface\\Common\\VoiceChat-Speaker");
				else 
					subframes.rankTexture:SetTexture("");
				end

				-- Sets the Main Tank/Assist Icon
				if ( role == "MAINTANK" ) then
					subframes.roleTexture:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon");
				elseif (role == "MAINASSIST" ) then
					subframes.roleTexture:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon");
				else
					subframes.roleTexture:SetTexture("");
				end

				-- Sets the Master Looter Icon
				if ( loot ) then
					subframes.lootTexture:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter");
				else
					subframes.lootTexture:SetTexture("");
				end

				-- Resizes if there are all 3 visible
				if ( ( rank > 0 ) and role and loot ) then
					subframes.rank:SetWidth(10);
					subframes.rank:SetHeight(10);
					subframes.role:SetWidth(10);
					subframes.role:SetHeight(10);
					subframes.loot:SetWidth(9);
					subframes.loot:SetHeight(9);
					subframes.readyCheck:SetWidth(10);
					subframes.readyCheck:SetHeight(10);
				else
					subframes.rank:SetWidth(11);
					subframes.rank:SetHeight(11);
					subframes.role:SetWidth(11);
					subframes.role:SetHeight(11);
					subframes.loot:SetWidth(11);
					subframes.loot:SetHeight(11);
					subframes.readyCheck:SetWidth(11);
					subframes.readyCheck:SetHeight(11);
				end
				
				button.jobs = button.jobs or {};
				
				for i, j in next, button.jobs do
					button.jobs[i] = nil;
				end
				
				buttonCount = 0;

				if ( rank > 0 or muted == 2 ) then
					tinsert(button.jobs, subframes.rank);
					buttonCount = buttonCount + 1;
				else
					subframes.rank:Hide();
				end

				if ( role ) then
					tinsert(button.jobs, subframes.role);			
					buttonCount = buttonCount + 1;
				else
					subframes.role:Hide();
				end

				if ( loot ) then
					tinsert(button.jobs, subframes.loot);
					buttonCount = buttonCount + 1;
				else
					subframes.loot:Hide();
				end
				
				for i=1, buttonCount, 1 do
					if ( i == 1 ) then
						button.jobs[i]:SetPoint("LEFT", button, "LEFT", 2, 0);
					else
						button.jobs[i]:SetPoint("LEFT", button.jobs[i-1], "RIGHT", -1, 0);
					end
					button.jobs[i]:Show();
				end

				-- Sets the Ready Check Icon
				if ( readyCheckStatus ) then
					if ( readyCheckStatus == "ready" ) then
						ReadyCheck_Confirm(subframes.readyCheck, 1);
					elseif ( readyCheckStatus == "notready" ) then
						ReadyCheck_Confirm(subframes.readyCheck, 0);
					else -- "waiting"
						ReadyCheck_Start(subframes.readyCheck);
					end

					-- hide the second job icon if there is one
					if ( #button.jobs >= 2 ) then
						button.jobs[2]:Hide();
					end
				else
					subframes.readyCheck:Hide();
				end

				-- Save slot for future use
				button.slot = raid_groupSlots[subgroup][raidGroup.nextIndex];
				
				-- Anchor button to slot
				if ( MOVING_RAID_MEMBER ~= button  ) then
					button:SetPoint("TOPLEFT", button.slot, "TOPLEFT", 0, 0);
				end

				-- Save the button's subgroup too
				button.subgroup = subgroup;
				-- Tell the slot what button is in it
				button.slot.button = button:GetName();
				raidGroup.nextIndex = raidGroup.nextIndex + 1;
				button.voice = voice;
				button.rank = rank;
				button.role = role;
				button.loot = loot;
				button:SetID(i);
				button:Show();
			end
		else
			button:Hide();
		end
	end
	
	-- Update Class Count Buttons
	RaidClassButton_Update();
end

function RaidGroupFrame_UpdateLevel(id)
	local unit = "raid"..id;
	local buttonLevel = _G["RaidGroupButton"..id.."Level"];

	buttonLevel:SetText(UnitLevel(unit));
end

function RaidGroupFrame_UpdateHealth(id)
	local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(id);

	local buttonName = _G["RaidGroupButton"..id.."Name"];
	local buttonClass = _G["RaidGroupButton"..id.."Class"];
	local buttonLevel = _G["RaidGroupButton"..id.."Level"];

	local color;
	if ( online ) then
		if ( isDead ) then
			buttonName:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			buttonClass:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			buttonLevel:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			color = RAID_CLASS_COLORS[fileName];
			if ( color ) then
				buttonName:SetTextColor(color.r, color.g, color.b);
				buttonClass:SetTextColor(color.r, color.g, color.b);
				buttonLevel:SetTextColor(color.r, color.g, color.b);
			end
		end
	else
		buttonName:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		buttonClass:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		buttonLevel:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
end

function RaidGroupFrame_OnUpdate(elapsed)
	if ( MOVING_RAID_MEMBER ) then
		local button, slot;
		TARGET_RAID_SLOT = nil;
		for i=1, NUM_RAID_GROUPS do
			for j=1, MEMBERS_PER_RAID_GROUP do
				slot = _G["RaidGroup"..i.."Slot"..j];
				if ( slot:IsMouseOver() ) then
					slot:LockHighlight();
					TARGET_RAID_SLOT = slot;
				else
					slot:UnlockHighlight();
				end
			end
		end
	end
end

function RaidGroupFrame_ReadyCheckFinished()
	local numRaidMembers = GetNumRaidMembers();
	local readyCheckFrame;
	for i=1, numRaidMembers do
		ReadyCheck_Finish(_G["RaidGroupButton"..i.."ReadyCheck"], 1.5, RaidGroupFrame_Update);
	end
end

function RaidGroupButton_ShowMenu(self)
	HideDropDownMenu(1);
	if ( self.id and self.name ) then
		FriendsDropDown.name = self.name;
		FriendsDropDown.id = self.id;
		FriendsDropDown.unit = self.unit;
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize;
		FriendsDropDown.displayMode = "MENU";
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor");
	end
end

function RaidGroupButton_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self.raidButton = self;
	
	self.id = self:GetID();
	self.unit = "raid"..self.id;
end

function RaidGroupButton_OnDragStart(raidButton)
	if ( not IsRaidLeader() and not IsRaidOfficer() ) then
		return;
	end
	local cursorX, cursorY = GetCursorPosition();
	raidButton:StartMoving();
	raidButton:ClearAllPoints();
	raidButton:SetPoint("CENTER", nil, "BOTTOMLEFT", cursorX*GetScreenWidthScale(), cursorY*GetScreenHeightScale());
	MOVING_RAID_MEMBER = raidButton;
	SetRaidRosterSelection(raidButton.id);
end

function RaidGroupButton_OnDragStop(raidButton)
	if ( not IsRaidLeader() and not IsRaidOfficer() ) then
		return;
	end
	
	raidButton:StopMovingOrSizing();
	MOVING_RAID_MEMBER = nil;
	if ( TARGET_RAID_SLOT and TARGET_RAID_SLOT:GetParent():GetID() ~= raidButton.subgroup ) then
		if (TARGET_RAID_SLOT.button) then
			local button = _G[TARGET_RAID_SLOT.button];
			--button:SetPoint("TOPLEFT", this, "TOPLEFT", 0, 0);
			SwapRaidSubgroup(raidButton:GetID(), button:GetID());
		else
			local slot = TARGET_RAID_SLOT:GetParent():GetName().."Slot"..TARGET_RAID_SLOT:GetParent().nextIndex;
			raidButton:ClearAllPoints();
			raidButton:SetPoint("TOPLEFT", slot, "TOPLEFT", 0, 0);
			TARGET_RAID_SLOT:UnlockHighlight();
			SetRaidSubgroup(raidButton:GetID(), TARGET_RAID_SLOT:GetParent():GetID());
		end
	else
		if ( TARGET_RAID_SLOT ) then
			TARGET_RAID_SLOT:UnlockHighlight();
		end
		raidButton:ClearAllPoints();
		raidButton:SetPoint("TOPLEFT", raidButton.slot, "TOPLEFT", 0, 0);
	end
end

function RaidGroupButton_OnEnter(raidbutton)
	if ( raidbutton.unit ) then
		UnitFrame_UpdateTooltip(raidbutton);
	end
end

function RaidFrameDropDown_Initialize(self)
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "RAID", self.unit, self.name, self.id);
end

function RaidButton_OnClick(self, button)
	SetRaidRosterSelection(self.index);
	RaidFrame_Update();
end

-------------------- Pullout Button Functions --------------------
function RaidPullout_OnEvent(self, event, ...)
	if ( self:IsShown() ) then
		if ( event == "RAID_ROSTER_UPDATE" or event == "UNIT_PET" or event == "UNIT_NAME_UPDATE" or
			 event == "READY_CHECK" or event == "READY_CHECK_CONFIRM" ) then
			RaidPullout_Update(self);
		elseif ( event == "READY_CHECK_FINISHED" ) then
			RaidPullout_ReadyCheckFinished(self);
		end
	end
end

function RaidPullout_ReadyCheckFinished(pulloutFrame)
	local pulloutButton;
	for i=1, pulloutFrame.numPulloutButtons do
		pulloutButton = pulloutFrame.buttons[i];
		ReadyCheck_Finish(_G[pulloutButton:GetName().."ReadyCheck"], 1.5, RaidPullout_ReadyCheckFinishFunc, pulloutButton);
	end
end

function RaidPullout_ReadyCheckFinishFunc(pulloutButton)
	RefreshAuras(pulloutButton, pulloutButton.unit, MAX_RAID_AURAS, "Aura", true, pulloutButton:GetParent().showBuffs);
end

function RaidPullout_GeneratePulloutFrame(fileName, class)
	-- Get a handle on a pullout frame
	local pullOutFrame = RaidPullout_GetFrame(fileName);
	if ( pullOutFrame ) then

		pullOutFrame.filterID = fileName;
		pullOutFrame.showBuffs = nil;

		-- Set pullout name
		if ( class ) then
			pullOutFrame.class = class;
			pullOutFrame.label:SetText(class);
		elseif ( tonumber(fileName) ) then
			pullOutFrame.label:SetText(GROUP.." "..fileName);
		else
			pullOutFrame.label:SetText("");
		end

		if ( fileName == "MAINTANK" or fileName == "MAINASSIST" ) then
			pullOutFrame.showTarget = 1;
			if (  fileName == "MAINTANK" ) then
				pullOutFrame.showTargetTarget = 1;
			else 
				pullOutFrame.showTargetTarget = nil;
			end
		else
			pullOutFrame.showTargetTarget = nil;
			pullOutFrame.showTarget = nil;
			pullOutFrame.name = nil;
		end

		if ( RaidPullout_Update(pullOutFrame) ) then
			return pullOutFrame;		
		end
	end
end

function RaidPullout_UpdateTarget(pullOutFrame, pullOutButton, unit, which)
	pullOutFrame = _G[pullOutFrame];
	local statusBar = _G[pullOutButton..which];
	local name = _G[pullOutButton..which.."Name"];
	local frame = _G[pullOutButton..which.."Frame"];
	if ( not pullOutFrame.showTarget ) then
		pullOutFrame.showTargetTarget = nil;
	end
	if ( pullOutFrame["show"..which] ) then
		if ( frame ) then
			if ( ( not _G[pullOutFrame:GetName().."MenuBackdrop"]:IsShown() ) and which == "TargetTarget" ) then
				frame:Hide();
			else
				frame:Show();
			end
		end
		statusBar:Show();

		local unitName = UnitName(unit);
		if ( unitName and unitName ~= UNKNOWNOBJECT ) then
			-- Init the Healthbars
			local temp, class = UnitClass(unit);
			name:SetText(unitName);
			securecall("UnitFrameHealthBar_Initialize", unit, statusBar, nil, true);
			securecall("UnitFrameHealthBar_Update", statusBar, unit);
			
			-- If Unknown, turn the bar grey and fill it
			if ( not class ) then
				statusBar:SetMinMaxValues(0,1);
				statusBar:SetValue(1);
				statusBar:SetStatusBarColor(0.5, 0.5, 0.5, 1.0);
			end

			-- Color the name if the unit is a player
			if ( UnitCanCooperate("player", unit) ) then
				local color = RAID_CLASS_COLORS[class];
				if ( color ) then
					name:SetVertexColor(color.r, color.g, color.b);
				end
			else
				name:SetVertexColor(1.0, 0.82, 0);
			end

			statusBar:SetStatusBarColor(UnitSelectionColor(unit));
			name:Show();

		else
			statusBar:SetMinMaxValues(0,1);
			statusBar:SetValue(1);
			name:SetText("");
			name:Hide();							
			statusBar:SetStatusBarColor(0.5, 0.5, 0.5, 1.0);
			if ( which == "TargetTarget" ) then
				statusBar:Hide();
				if ( frame ) then
					frame:Hide();
				end
			else
				if ( frame ) then
					frame:Show();
				end
				statusBar:Show();
			end
		end
	else
		statusBar:Hide();
		name:Hide();
		if ( frame ) then
			frame:Hide();
		end
	end
end

function RaidPullout_OnUpdate(self, elapsed)
	if ( _G[self:GetName().."Target"]:IsVisible() ) then
		if ( not self.timer ) then
			self.timer = .25;
		elseif ( self.timer < 0 ) then
			local parent = self:GetParent():GetName();
			local frame = self:GetName();
			RaidPullout_UpdateTarget(parent, frame, self.unit.."target", "Target");
			if ( self:GetParent().showTargetTarget ) then
				RaidPullout_UpdateTarget(parent, frame, self.unit.."targettarget", "TargetTarget");
			end
			self.timer = .25;
		else
			self.timer = self.timer - elapsed;
		end
	end
	if ( RaidFrame.showRange ) then
		if ( UnitIsConnected(self.unit) and  not UnitInRange(self.unit) ) then
			if ( self.healthbar:GetAlpha() == 1 ) then
				_G[self:GetName().."Name"]:SetAlpha(RAID_RANGE_ALPHA);
				self.healthbar:SetAlpha(RAID_RANGE_ALPHA);
				self.manabar:SetAlpha(RAID_RANGE_ALPHA);
			end
		else
			_G[self:GetName().."Name"]:SetAlpha(1);
			self.healthbar:SetAlpha(1);
			self.manabar:SetAlpha(1);
		end
	elseif ( self.healthbar:GetAlpha() ~= 1 ) then
		_G[self:GetName().."Name"]:SetAlpha(1);
		self.healthbar:SetAlpha(1);
		self.manabar:SetAlpha(1);
	end
end

function RaidPullout_Update(pullOutFrame)
	local id, single;
	local filterID = pullOutFrame.filterID;
	local numPulloutEntries = 0;
	if ( RAID_SUBGROUP_LISTS[filterID] ) then
		numPulloutEntries = getn(RAID_SUBGROUP_LISTS[filterID]);
		-- Hide the pullout if no entries
		if ( numPulloutEntries == 0 ) then
			pullOutFrame:Hide();
			return nil;
		end
	else
		numPulloutEntries = 1;
		single = 1;
	end
	local pulloutList = RAID_SUBGROUP_LISTS[filterID];

	-- Fill out the buttons
	local pulloutButton, pulloutButtonName, color, unit, target;
	local pulloutHealthBar, pulloutManaBar, pulloutThreatIndicator;
	local pulloutClearButton;
	if ( numPulloutEntries > pullOutFrame.numPulloutButtons ) then
		local index = pullOutFrame.numPulloutButtons + 1;
		local relative;
		for i=index, numPulloutEntries do
			pulloutButton = CreateFrame("Frame", pullOutFrame:GetName().."Button"..i, pullOutFrame, "RaidPulloutButtonTemplate");
			if ( i == 1 ) then
				pulloutButton:SetPoint("TOP", pullOutFrame, "TOP", 1, -10);
			else
				pulloutButton:SetPoint("TOP", pullOutFrame:GetName().."Button"..(i-1), "BOTTOM", 0, -8);
			end
			pullOutFrame.buttons[i] = pulloutButton;
		end
		pullOutFrame.numPulloutButtons = numPulloutEntries;
	end
	-- Populate Data
	local name, rank, subgroup, level, class, fileName, zone, online, isDead, role;
	local readyCheckStatus;
	local debuff;
	for i=1, pullOutFrame.numPulloutButtons do
		pulloutButton = pullOutFrame.buttons[i];
		if ( i <= numPulloutEntries ) then
			pulloutButtonName = pulloutButton.nameLabel;
			pulloutHealthBar = pulloutButton.healthbar;
			pulloutManaBar = pulloutButton.manabar;
			pulloutThreatIndicator = pulloutButton.threatIndicator;
			if ( pulloutList ) then
				id = pulloutList[i];
			elseif ( single ) then
				id = RaidPullout_MatchName(filterID);
			end
			-- Hide the pullout if no name
			if ( single ) then
				if ( not id ) then
					pullOutFrame:Hide();
					return nil;
				end
			end

			name, rank, subgroup, level, class, fileName, zone, online, isDead, role = GetRaidRosterInfo(id);

			pulloutButton:SetScript("OnUpdate", RaidPullout_OnUpdate);

			if ( pullOutFrame.showTarget ) then
				pulloutButton:SetHeight(40);
			else
				pulloutButton:SetHeight(25);
			end

			-- Set Unit Values
			if ( filterID == "PETS" ) then
				unit = "raidpet"..id;
				if ( not UnitExists("raidpet"..id) ) then
					online = nil;
				end
			else
				unit = "raid"..id;
			end

			name = UnitName(unit);
			pulloutButtonName:SetText(name);
			pulloutButton.unit = unit;
			pulloutButton.secondaryUnit = unit;

			-- Set for tooltip support
			pulloutClearButton = pulloutButton.clearButton;
			SecureUnitButton_OnLoad(pulloutClearButton, unit, RaidPulloutButton_ShowMenu);
			pullOutFrame.name = name;
			pullOutFrame.single = single;
			pulloutButton.raidIndex = id;

			-- Setup status bars (health, mana, threat, etc)
			RaidPulloutButton_UpdateSwapFrames(pulloutButton, unit)

			local minVal, maxVal;
			if ( online ) then	
				RaidPulloutButton_UpdateDead(pulloutButton, isDead, fileName);
			else
				-- Offline so set name grey and full alpha
				if ( pulloutHealthBar:GetAlpha() ~= 1 ) then
					pulloutButtonName:SetAlpha(1);
					pulloutHealthBar:SetAlpha(1);
					pulloutManaBar:SetAlpha(1);
				end
				pulloutButtonName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end

			RaidPulloutButton_UpdateVoice(pulloutButton);

			-- Handle unit's target
			RaidPullout_UpdateTarget(pullOutFrame:GetName(), pulloutButton:GetName(), pulloutButton.unit.."target", "Target");
			RaidPullout_UpdateTarget(pullOutFrame:GetName(), pulloutButton:GetName(), pulloutButton.unit.."targettarget", "TargetTarget");

			-- Handle ready check
			readyCheckStatus = GetReadyCheckStatus(unit);
			if ( readyCheckStatus ) then
				if ( readyCheckStatus == "ready" ) then
					ReadyCheck_Confirm(_G[pulloutButton:GetName().."ReadyCheck"], 1);
				elseif ( readyCheckStatus == "notready" ) then
					ReadyCheck_Confirm(_G[pulloutButton:GetName().."ReadyCheck"], 0);
				else -- "waiting"
					ReadyCheck_Start(_G[pulloutButton:GetName().."ReadyCheck"]);
				end

				-- hide auras while ready check is up
				for i=1, MAX_RAID_AURAS do
					_G[pulloutButton:GetName().."Aura"..i]:Hide();
				end
			else
				_G[pulloutButton:GetName().."ReadyCheck"]:Hide();

				-- Handle auras if ready check is hidden
				RefreshAuras(pulloutButton, pulloutButton.unit, MAX_RAID_AURAS, "Aura", true, pullOutFrame.showBuffs);
			end

			--Handle vehicle indicator
			if ( UnitHasVehicleUI(unit) ) then
				pulloutButton.vehicleIndicator:Show();
			else
				pulloutButton.vehicleIndicator:Hide();
			end

			pulloutButton:RegisterEvent("PLAYER_ENTERING_WORLD");
			pulloutButton:RegisterEvent("UNIT_HEALTH");
			pulloutButton:RegisterEvent("UNIT_AURA");
			pulloutButton:RegisterEvent("UNIT_NAME_UPDATE");
			pulloutButton:RegisterEvent("VOICE_STATUS_UPDATE");
			pulloutButton:RegisterEvent("VOICE_START");
			pulloutButton:RegisterEvent("VOICE_STOP");
			pulloutButton:RegisterEvent("UNIT_ENTERED_VEHICLE");
			pulloutButton:RegisterEvent("UNIT_EXITED_VEHICLE");
			pulloutButton:Show();
		else
			pulloutButton:UnregisterEvent("PLAYER_ENTERING_WORLD");
			pulloutButton:UnregisterEvent("UNIT_HEALTH");
			pulloutButton:UnregisterEvent("UNIT_AURA");
			pulloutButton:UnregisterEvent("UNIT_NAME_UPDATE");
			pulloutButton:UnregisterEvent("VOICE_STATUS_UPDATE");
			pulloutButton:UnregisterEvent("VOICE_START");
			pulloutButton:UnregisterEvent("VOICE_STOP");
			pulloutButton:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			pulloutButton:UnregisterEvent("UNIT_EXITED_VEHICLE");
			pulloutButton:Hide();
		end
	end

	local buttonHeight = RAID_PULLOUT_BUTTON_HEIGHT;
	local height;

	if ( pullOutFrame.showTarget ) then
		buttonHeight = buttonHeight + 15;
	end
	
	if ( pullOutFrame.showBG == false ) then
		_G[pullOutFrame:GetName().."MenuBackdrop"]:Hide();
	end
	
	pullOutFrame:SetHeight( (numPulloutEntries * buttonHeight) + 14);
	pullOutFrame:Show();
	return 1;
end

function RaidPulloutButton_OnEvent(self, event, ...)
	local speaker = self.speaker;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		RaidPulloutButton_UpdateVoice(self);
	elseif ( event == "UNIT_HEALTH" ) then
		local arg1 = ...;
		if ( arg1 == self.unit ) then
			local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(self.raidIndex);
			if ( online ) then
				RaidPulloutButton_UpdateDead(self, isDead, fileName);
			end
		end
	elseif ( event == "UNIT_AURA" ) then
		-- suppress while ready check is up
		local arg1 = ...;
		if ( arg1 == self.unit ) then
			if ( not _G[self:GetName().."ReadyCheck"]:IsShown() ) then
				RefreshAuras(self, self.unit, MAX_RAID_AURAS, "Aura", true, self:GetParent().showBuffs);
			end
		end
	elseif ( event == "VOICE_START") then
		local arg1 = ...;
		if ( arg1 == (self.secondaryUnit or self.unit) ) then
			speaker.timer = nil;
			speaker:Show();
			UIFrameFadeIn(speaker, 0.2, speaker:GetAlpha(), 1);
			if ( not self.muted ) then
				VoiceChat_Animate(speaker, 1);
			end
		end
	elseif ( event == "VOICE_STOP" ) then
		local arg1 = ...;
		if ( arg1 == (self.secondaryUnit or self.unit) ) then
			speaker.timer = VOICECHAT_DELAY;
			VoiceChat_Animate(speaker, nil);
			if ( self.muted ) then
				speaker:Show();
			else
				UIFrameFadeOut(speaker, 0.2, speaker:GetAlpha(), 0);
			end
		end
	elseif ( event == "VOICE_STATUS_UPDATE" ) then
		RaidPulloutButton_UpdateVoice(self);
	elseif (( event == "UNIT_ENTERED_VEHICLE" ) or ( event == "UNIT_EXITED_VEHICLE" )) then
		local arg1 = ...;
		if ( arg1 == (self.secondaryUnit or self.unit) ) then
			if ( UnitHasVehicleUI(arg1) ) then
				self.vehicleIndicator:Show();
			else
				self.vehicleIndicator:Hide();
			end
			RaidPulloutButton_UpdateSwapFrames(self, arg1);
		end
	end
end

function RaidPulloutButton_UpdateSwapFrames(self, unit)
	if ( UnitTargetsVehicleInRaidUI(unit) ) then
		local prefix, id = unit:match("([^%d]+)([%d]+)");
		self.secondaryUnit = unit;
		unit = prefix.."pet"..id;
		self.unit = unit;
		_G[self:GetName().."ClearButton"]:SetAttribute("unit", unit)		
	elseif ( self.secondaryUnit ) then
		self.unit = self.secondaryUnit;
		_G[self:GetName().."ClearButton"]:SetAttribute("unit", self.secondaryUnit);
		self.secondaryUnit = nil;
	end
	securecall("UnitFrameHealthBar_Initialize", unit, self.healthbar, nil, true);
	securecall("UnitFrameManaBar_Initialize", unit, self.manabar, nil);
	securecall("UnitFrameThreatIndicator_Initialize", unit, self);
	securecall("UnitFrameHealthBar_Update", self.healthbar, unit);
	securecall("UnitFrameManaBar_Update", self.manabar, unit);
	securecall("UnitFrame_UpdateThreatIndicator", self.threatIndicator, nil, unit);
end

function RaidPulloutButton_UpdateDead(button, isDead, class)
	local unit;
	local pulloutButtonName = button.nameLabel;
	if ( isDead ) then
		pulloutButtonName:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
	else
		if ( class == "PETS" ) then
			class = UnitClass(gsub(button.unit, "raidpet", "raid"));
		end
		local color = RAID_CLASS_COLORS[class];
		if ( color ) then
			pulloutButtonName:SetVertexColor(color.r, color.g, color.b);
		end
	end
end

function RaidPulloutButton_UpdateVoice(pullOutButton)
	local button = pullOutButton:GetName();
	local icon = pullOutButton.speaker;
	local muted = _G[button.."SpeakerMuted"];
	local muteStatus = GetMuteStatus(UnitName((pullOutButton.secondaryUnit or pullOutButton.unit)), "raid");
	local state = UnitIsTalking(UnitName(pullOutButton.secondaryUnit or pullOutButton.unit));
	if ( muteStatus ) then
		VoiceChat_Animate(icon, nil);
		icon:SetAlpha(1);
		icon:Show();
		muted:Show();
	else
		if ( state ) then
			VoiceChat_Animate(icon, 1);
			icon:Show();
		else
			VoiceChat_Animate(icon, nil);
			icon:Hide();
		end
		muted:Hide();
	end
	pullOutButton.muted = muteStatus;
end

function RaidPulloutButton_ShowMenu(self)
	ToggleDropDownMenu(1, nil, _G[self:GetParent():GetParent():GetName().."DropDown"]);
end

function RaidPulloutButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:SetFrameLevel(self:GetFrameLevel() + 1);

	self.showmenu = RaidPulloutButton_ShowMenu;
end

function RaidPulloutButton_OnDragStart(frame)
	if ( not frame ) then
		MOVING_RAID_PULLOUT = nil;
		return;
	end
	local cursorX, cursorY = GetCursorPosition();
	frame:SetFrameStrata("DIALOG");
	frame:StartMoving();
	frame:ClearAllPoints();
	frame:SetPoint("TOP", nil, "BOTTOMLEFT", cursorX*GetScreenWidthScale(), cursorY*GetScreenHeightScale());
	MOVING_RAID_PULLOUT = frame;
end

function RaidPulloutStopMoving(frame)
	if ( not frame ) then
		frame = MOVING_RAID_PULLOUT;
	end
	if ( frame ) then
		frame:StopMovingOrSizing();
		frame:SetFrameStrata("BACKGROUND");
		frame:ClearAllPoints();
		
		local x, _ = frame:GetCenter();
		local y = frame:GetTop();
		frame:SetPoint("TOP", nil, "BOTTOMLEFT", x, y);
		ValidateFramePosition(frame, 25);
		-- Save the end positions
		RaidPullout_SaveFrames(frame);
	end
end

function RaidPullout_SaveFrames(pullOutFrame)
	local point, relativeTo, relativePoint, offsetX, offsetY = pullOutFrame:GetPoint();
	local filterID = tostring(pullOutFrame.filterID);
	local settings = {};
	if ( pullOutFrame:IsShown() ) then
		if ( pullOutFrame.single ) then
			-- Check for an existing entry
			for index, value in pairs(RAID_SINGLE_POSITIONS) do
				if ( index > 19 ) then
					tremove(RAID_SINGLE_POSITIONS, index);
				end
				if ( value["name"] == pullOutFrame.name ) then
					tremove(RAID_SINGLE_POSITIONS, index);
				end
			end
			
			-- Get its settings
			for setting in next, RAID_PULLOUT_SAVED_SETTINGS do
				if ( pullOutFrame[setting] ~= nil ) then
					settings[setting] = pullOutFrame[setting];
				end
			end
			
			-- Save its position and settings
			tinsert(RAID_SINGLE_POSITIONS, 1, { point = point, relativePoint = relativePoint, x = offsetX, y = offsetY, name = pullOutFrame.filterID, ["settings"] = settings });
		else
			if ( not RAID_PULLOUT_POSITIONS[filterID] ) then
				RAID_PULLOUT_POSITIONS[filterID] = {};
			end
			RAID_PULLOUT_POSITIONS[filterID].point = point;
			RAID_PULLOUT_POSITIONS[filterID].relativePoint = relativePoint;
			RAID_PULLOUT_POSITIONS[filterID].x = offsetX;
			RAID_PULLOUT_POSITIONS[filterID].y = offsetY;
			-- Save detail information such as name and class value
			if ( pullOutFrame.id ) then
				RAID_PULLOUT_POSITIONS[filterID].name = UnitName("raid"..pullOutFrame.id);
			end
			if ( pullOutFrame.class ) then
				RAID_PULLOUT_POSITIONS[filterID].class = pullOutFrame.class;
			end
			
			for setting in next, RAID_PULLOUT_SAVED_SETTINGS do
				if ( pullOutFrame[setting] ~= nil ) then
					settings[setting] = pullOutFrame[setting];
				end
			end
			
			RAID_PULLOUT_POSITIONS[filterID]["settings"] = settings;
		end
	end
end

function RaidPullout_RenewFrames()
	local pullOutFrame;
	for index, pullOut in pairs(RAID_PULLOUT_POSITIONS) do
		if ( tonumber(index) ) then
			pullOutFrame = RaidPullout_GeneratePulloutFrame(tonumber(index));		
		else
			pullOutFrame = RaidPullout_GeneratePulloutFrame(index, pullOut["class"]);
		end
		if ( pullOutFrame ) then
			if ( pullOut.x ) then
				pullOutFrame:ClearAllPoints();
				if ( not pullOut.point ) then
					pullOut.point = "TOPLEFT";
					pullOut.relativePoint = "TOPLEFT";
				end
				pullOutFrame:SetPoint(pullOut["point"], UIParent, pullOut["relativePoint"], pullOut["x"], pullOut["y"]);
			end
			
			if ( pullOut.settings ) then
				for setting, value in next, pullOut.settings do
					pullOutFrame[setting] = value;
				end			
			end
			
			RaidPullout_Update(pullOutFrame);
		end
	end
	for index, pullOut in pairs(RAID_SINGLE_POSITIONS) do
		if ( RaidPullout_MatchName(pullOut["name"]) ) then
			pullOutFrame = RaidPullout_GeneratePulloutFrame(pullOut["name"], nil );
			if ( pullOutFrame ) then
				if ( pullOut.x ) then
					pullOutFrame:ClearAllPoints();
					if ( not pullOut.point ) then
						pullOut.point = "TOPLEFT";
						pullOut.relativePoint = "TOPLEFT";
					end
					pullOutFrame:SetPoint(pullOut["point"], UIParent, pullOut["relativePoint"], pullOut["x"], pullOut["y"]);
				end
				
				if ( pullOut.settings ) then
					for setting, value in next, pullOut.settings do
						pullOutFrame[setting] = value;
					end
				end
				
				RaidPullout_Update(pullOutFrame);
			end
		end
	end
end

function RaidPullout_MatchName(name)
	if ( name ) then
		for i=1, GetNumRaidMembers(), 1 do
			if ( name == GetRaidRosterInfo(i) ) then
				return i;
			end			
		end	
	end
end

local raid_pullout_frames = {};

function RaidPullout_GetFrame(filterID)
	-- Grab an available pullout frame
	local frame, freeFrame;
	for i=1, NUM_RAID_PULLOUT_FRAMES do
		frame = raid_pullout_frames[i]
		-- if frame is visible see if its group id is already taken
		if ( frame:IsShown() and filterID == frame.filterID ) then
			return nil;
		elseif ( not freeFrame and not frame:IsShown() ) then
			freeFrame = frame;
		end
	end
	if ( freeFrame ) then
		return freeFrame;
	end
	NUM_RAID_PULLOUT_FRAMES = NUM_RAID_PULLOUT_FRAMES + 1;
	frame = CreateFrame("Button", "RaidPullout"..NUM_RAID_PULLOUT_FRAMES, UIParent, "RaidPulloutFrameTemplate");
	frame.numPulloutButtons = 0;
	raid_pullout_frames[NUM_RAID_PULLOUT_FRAMES] = frame;
	return frame;
end

function RaidPulloutDropDown_OnLoad(self)
	self.raidPulloutDropDown = true;
	UIDropDownMenu_Initialize(self, RaidPulloutDropDown_Initialize, "MENU");
	UIDropDownMenu_SetAnchor(self, 0, 0, "TOPLEFT", self:GetParent():GetName(), "TOPRIGHT")
end

function RaidPulloutDropDown_Initialize()
	if ( not UIDROPDOWNMENU_OPEN_MENU or not UIDROPDOWNMENU_OPEN_MENU.raidPulloutDropDown ) then
		return;
	end
	local currentPullout = UIDROPDOWNMENU_OPEN_MENU:GetParent();
	local unit, voice, muted, silenced, pvpType;
	local info = UIDropDownMenu_CreateInfo();

	if ( IsVoiceChatEnabled() ) then
		-- Display the option to mute voice chat.	
		for i=1, currentPullout.numPulloutButtons do
			local button = _G[currentPullout:GetName().."Button"..i];
			if ( button:IsMouseOver() ) then
				unit = (button.secondaryUnit or button.unit);
				break;
			end
		end
		if ( unit and currentPullout.filterID ~= "PETS" ) then
			if ( UnitInBattleground("player") ) then
				pvpType = "battleground";
			else
				pvpType = "raid";
			end
			voice = GetVoiceStatus(UnitName(unit), pvpType);
		end
		if ( voice ) then
			-- Set a name header
			if ( not UnitIsUnit(unit, "player") or IsRaidOfficer() ) then
				info = UIDropDownMenu_CreateInfo();
				info.text = UnitName(unit);
				info.isTitle = 1;
				info.notCheckable = nil;
				info.disabled = nil;
				UIDropDownMenu_AddButton(info);

				-- Set a mute option
				muted = IsMuted(UnitName(unit));	
				if ( muted ) then
					info.text = UNMUTE;
				else
					info.text = MUTE;
				end
				info.func = function()
					AddOrDelMute(unit);
				end;
				info.checked = nil;
				info.isTitle = nil;
				info.notCheckable = nil;
				info.disabled = nil;
				UIDropDownMenu_AddButton(info);
			end
			
			-- Display the option to silence voice chat if RaidLeader.	
			if ( IsRaidOfficer() ) then
				silenced = UnitIsSilenced(UnitName(unit), "raid");	
				if ( not silenced ) then
					info.text = RAID_SILENCE;
					info.func = function()
						ChannelSilenceVoice("raid", UnitName(unit));
					end;
				else
					info.text = RAID_UNSILENCE;
					info.func = function()
						ChannelUnSilenceVoice("raid", UnitName(unit));
					end;
				end
				info.isTitle = nil;
				info.notCheckable = nil;
				info.disabled = nil;
				UIDropDownMenu_AddButton(info);
			end
			if ( not UnitIsUnit(unit, "player") or IsRaidOfficer() ) then
				-- spacer
				info = UIDropDownMenu_CreateInfo();
				info.isTitle = 1;
				info.notCheckable = 1;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	-- Show target if it is allowed
	info.text = SHOW_TARGET;
	info.func = function()
		if ( currentPullout.showTarget == 1 ) then
			currentPullout.showTarget = nil;
		else
			currentPullout.showTarget = 1;
		end
		RaidPullout_Update(currentPullout);
		RaidPullout_SaveFrames(currentPullout);
	end;
	info.checked = currentPullout.showTarget;
	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	UIDropDownMenu_AddButton(info);

	if ( currentPullout.showTarget == 1 ) then
		info.text = SHOW_TARGET_OF_TARGET_TEXT;
		info.func = function()
			if ( currentPullout.showTargetTarget == 1 ) then
				currentPullout.showTargetTarget = nil;
			else
				currentPullout.showTargetTarget = 1;
			end
			RaidPullout_Update(currentPullout);
			RaidPullout_SaveFrames(currentPullout);
		end;
		info.checked = currentPullout.showTargetTarget;
		info.isTitle = nil;
		info.disabled = nil;
		info.notCheckable = nil;
		UIDropDownMenu_AddButton(info);
	end

	-- Show buffs or debuffs they are exclusive for now
	info.text = SHOW_BUFFS;
	info.func = function()
		currentPullout.showBuffs = 1;
		RaidPullout_Update(currentPullout);
		RaidPullout_SaveFrames(currentPullout);
	end;
	info.checked = currentPullout.showBuffs;
	UIDropDownMenu_AddButton(info);

	info.text = SHOW_DEBUFFS;
	info.func = function()
		currentPullout.showBuffs = nil;
		RaidPullout_Update(currentPullout);
		RaidPullout_SaveFrames(currentPullout);
	end;
	info.checked = (not currentPullout.showBuffs);
	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	UIDropDownMenu_AddButton(info);
	
	-- Hide background option
	local backdrop = _G[currentPullout:GetName().."MenuBackdrop"];
	info.text = HIDE_PULLOUT_BG;
	info.func = function ()
		currentPullout.showBG = (not backdrop:IsShown());
		if ( backdrop:IsShown() ) then
			backdrop:Hide();
		else
			backdrop:Show();
		end
		RaidPullout_SaveFrames(currentPullout);
	end;
	info.checked = (not backdrop:IsShown());
	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	UIDropDownMenu_AddButton(info);

	-- Close option
	info.text = CLOSE;
	info.func = function()
		if ( currentPullout.showTarget == 1 ) then
			currentPullout.showTarget = nil;
		end
		if ( RAID_PULLOUT_POSITIONS[tostring(currentPullout.filterID)] ) then
			RAID_PULLOUT_POSITIONS[tostring(currentPullout.filterID)] = nil;
		end
		for index, value in pairs(RAID_SINGLE_POSITIONS) do
			if ( value["name"] == currentPullout.filterID ) then
				tremove(RAID_SINGLE_POSITIONS, index);
			end
		end 
		currentPullout:Hide();
	end;
	info.checked = nil;
	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	UIDropDownMenu_AddButton(info);
end

function RaidFrameReadyCheckButton_Update()
	if ( GetNumRaidMembers() > 0 and (IsRaidLeader() or IsRaidOfficer()) ) then
		RaidFrameReadyCheckButton:Show();
	else
		RaidFrameReadyCheckButton:Hide();
	end
end

function RaidFrameRaidBrowserButton_Update()
	if ( GetNumRaidMembers() > 0 ) then
		RaidFrameRaidBrowserButton:Show();
	else	
		RaidFrameRaidBrowserButton:Hide();
	end
end
