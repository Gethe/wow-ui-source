local APPLICANT_COLUMN_INFO = {
	[1] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_LEVEL,
		width = 40,
		attribute = "level",
	},

	[2] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_CLASS,
		width = 45,
		attribute = "classID",
	},

	[3] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NAME,
		width = 100,
		attribute = "name",
	},

	[4] = {
		title = CLUB_FINDER_SPEC,
		width = 65,
		attribute = "spec",
	},

	[5] = {
		title = ITEM_LEVEL_ABBR,
		width = 40,
		attribute = "ilvl",
	},

	[6] = {
		title = COMMUNITIES_ROSTER_COLUMN_TITLE_NOTE,
		width = 315,
		attribute = "memberNote",
	},
};

ClubFinderApplicantEntryMixin = { };

function ClubFinderApplicantEntryMixin:GetApplicantName()
	return self.Info.name;
end 

function ClubFinderApplicantEntryMixin:OnMouseDown(button)
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 100, 0);
	end
end 

function ClubFinderApplicantEntryMixin:UpdateMemberInfo(info)
	self.Info = info;

	local className, classTag = GetClassInfo(info.classID);
	self.ClassName = className; 
	self.ClassColor = CreateColor(GetClassColor(classTag));
	self.Name:SetText(info.name);
	self.Name:SetTextColor(self.ClassColor.r, self.ClassColor.g, self.ClassColor.b);

	self.Level:SetText(info.level);
	self.ItemLevel:SetText(info.ilvl); 
	self.Note:SetText(info.message);

	local isHealer = false; 
	local isDps = false; 
	local isTank = false; 
	local firstBadgeSet = false; 

	for _, specID in ipairs(info.specIds) do 
		local role = GetSpecializationRoleByID(specID);
		if(role == "DAMAGER") then
			isHealer = true; 
		elseif (role == "HEALER") then 
			isTank = true; 
		elseif (role == "TANK") then 
			isDps = true; 
		end
		if(firstBadgeSet) then 
			self.RoleIcon2:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
			self.RoleIcon2:Show(); 
		else 
			self.RoleIcon1:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
			self.RoleIcon1:Show(); 
			firstBadgeSet = true;
		end
		
		if (isHealer and isTank and isDps) then 
			self.RoleIcon2:Hide();
			self.RoleIcon1:Hide();
			self.AllSpec:SetText("All");
			self.AllSpec:Show();
		end
	end 
	self.Class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classTag]));
	UIDropDownMenu_Initialize(self.RightClickDropdown, ApplicantRightClickOptionsMenuInitialize, "MENU");
end 

function ClubFinderApplicantEntryMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddColoredLine(GameTooltip, self.Info.name, self.ClassColor);
	GameTooltip_AddColoredLine(GameTooltip, UNIT_TYPE_LEVEL_TEMPLATE:format(self.Info.level, self.ClassName), HIGHLIGHT_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, LFG_LIST_ITEM_LEVEL_CURRENT:format(self.Info.ilvl));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CLUB_FINDER_SPECIALIZATIONS);
	local className, classTag = GetClassInfo(self.Info.classID);
	local color = CreateColor(GetClassColor(classTag));
	for _, specID in ipairs(self.Info.specIds) do 
		local _, name, _, _, role = GetSpecializationInfoForSpecID(specID);
		local texture;
		if (role == "TANK") then
			texture = CreateAtlasMarkup("roleicon-tiny-tank");
		elseif (role == "DAMAGER") then
			texture = CreateAtlasMarkup("roleicon-tiny-dps");
		elseif (role == "HEALER") then
			texture = CreateAtlasMarkup("roleicon-tiny-healer");
		end
		GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_LEADER_BOARD_NAME_ICON:format(texture, name.. " " ..className), color);
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddColoredLine(GameTooltip, self.Info.message, HIGHLIGHT_FONT_COLOR, true);
	GameTooltip:Show();

end
function ClubFinderApplicantEntryMixin:OnLeave()
	GameTooltip:Hide();
end

function ApplicantRightClickOptionsMenuInitialize(self, level)
	local info = UIDropDownMenu_CreateInfo();

	if UIDROPDOWNMENU_MENU_VALUE == 1 then
		info.text = CLUB_FINDER_REPORT_SPAM; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_NAME; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level); 

		info.text = CLUB_FINDER_REPORT_DESCRIPTION; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level); 
	end
	
	if (level == 1) then 
		info.text = self:GetParent():GetApplicantName();
		info.isTitle = true; 
		info.notCheckable = true; 
		UIDropDownMenu_AddButton(info, level);

		info.text = WHISPER;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.isTitle = false; 
		info.notCheckable = true; 
		info.disabled = nil;
		UIDropDownMenu_AddButton(info, level);

		info.text = CLUB_FINDER_REPORT_FOR; 
		info.isTitle = false; 
		info.disabled = nil;
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE; 
		info.notCheckable = true; 
		info.hasArrow = true
		info.value = 1; 
		UIDropDownMenu_AddButton(info, level);
	end
end

ClubFinderApplicantListMixin = { }; 

function ClubFinderApplicantListMixin:OnLoad()
	self:RegisterEvent("CLUB_FINDER_RECRUITS_UPDATED");

	self.ColumnDisplay:LayoutColumns(APPLICANT_COLUMN_INFO);
	self.ColumnDisplay.Background:Hide();
	self.ColumnDisplay.TopTileStreaks:Hide();
	self.ColumnDisplay:Show();
end

function ClubFinderApplicantListMixin:OnShow()
	CommunitiesFrameInset:Hide(); 

	local communityFrame = self:GetParent();
	if (communityFrame:GetSelectedClubId()) then 
		local clubInfo = C_Club.GetClubInfo(communityFrame:GetSelectedClubId());
		if (clubInfo) then 
			C_ClubFinder.RequestApplicantList(clubInfo.clubId); 
		end 
	end
end 

function ClubFinderApplicantListMixin:OnHide()
	CommunitiesFrameInset:Show(); 
end 
function ClubFinderApplicantListMixin:OnEvent(event, ...)
	if(event == "CLUB_FINDER_RECRUITS_UPDATED") then 
		self.ApplicantInfoList = C_ClubFinder.GetApplicantInfoList();
		self:RefreshLayout();
	end
end 

function ClubFinderApplicantListMixin:RefreshLayout()
	if (not self.ApplicantInfoList) then 
		return; 
	end 

	if not self.ListScrollFrame.buttons then
		HybridScrollFrame_CreateButtons(self.ListScrollFrame, "ClubFinderApplicantEntryTemplate", 0, 0);
	end

	for i, applicant in ipairs(self.ListScrollFrame.buttons) do 
		if (self.ApplicantInfoList[i]) then 
			applicant:UpdateMemberInfo(self.ApplicantInfoList[i]); 
			applicant:Show(); 
		else 
			applicant:Hide();
		end 
	end 
end 

ClubFinderApplicantInviteButtonMixin = { }; 
function ClubFinderApplicantInviteButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(INVITE);
	GameTooltip:Show();
end 

function ClubFinderApplicantInviteButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function ClubFinderApplicantInviteButtonMixin:OnClick() 
	C_ClubFinder.RespondToApplicant(0, self:GetParent().Info.playerGUID, true, Enum.ClubFinderRequestType.Guild); --TO DO CLUBFINDER: Check which type we are (or have a way of figuring it out)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end 

ClubFinderApplicantCancelButtonMixin = { }; 
function ClubFinderApplicantCancelButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(DECLINE);
	GameTooltip:Show();
end 

function ClubFinderApplicantCancelButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function ClubFinderApplicantCancelButtonMixin:OnClick() 
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_ClubFinder.RespondToApplicant(0, self:GetParent().Info.playerGUID, false, Enum.ClubFinderRequestType.Guild);--TO DO CLUBFINDER: Check which type we are (or have a way of figuring it out)
end 