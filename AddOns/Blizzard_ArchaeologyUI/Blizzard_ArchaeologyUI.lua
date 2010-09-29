


UIPanelWindows["ArchaeologyFrame"] = {area = "left", pushable = 3, showFailedFunc = "ArchaeologyFrame_ShowFailed" };

ARCHAEOLOGY_BUTTON_HEIGHT = 59;
ARCHAEOLOGY_MID_TITLE_YOFFSET = -110;



ARCHAEOLOGY_MAX_RACES = 12;
ARCHAEOLOGY_MAX_STONES = 4;
ARCHAEOLOGY_MAX_COMPLETED_SHOWN = 12;

ARCHAEOLOGY_HELP_TAB = 0;
ARCHAEOLOGY_SUMMARY_TAB = 1;
ARCHAEOLOGY_COMPLETED_TAB = 2;

ARCHAEOLOGY_SUMMARY_PAGE = 1;
ARCHAEOLOGY_COMPLETED_PAGE = 2;
ARCHAEOLOGY_CURRENT_PAGE = 3;



local ArcheologyLayoutInfo = {
	[ARCHAEOLOGY_SUMMARY_PAGE] 	= 		{ 	
																		--updateFunc = "SpellBook_UpdateProfTab",
																		bgFileL="Interface\\Archeology\\Arch-BookItemLeft",
																		bgFileR="Interface\\Archeology\\Arch-BookItemRight"
																	};
	[ARCHAEOLOGY_COMPLETED_PAGE] 	= 		{ 	
																		--updateFunc = "SpellBook_UpdateProfTab",
																		bgFileL="Interface\\Archeology\\Arch-BookCompletedLeft",
																		bgFileR="Interface\\Archeology\\Arch-BookCompletedRight"
																	};
	[ARCHAEOLOGY_CURRENT_PAGE] 	= 		{ 	
																		--updateFunc = "SpellBook_UpdateProfTab",
																		bgFileL="Interface\\Archeology\\Arch-BookItemLeft",
																		bgFileR="Interface\\Archeology\\Arch-BookItemRight"
																	};




};


function ArchaeologyFrame_Show()
	ShowUIPanel(ArchaeologyFrame);
end
function ArchaeologyFrame_Hide()
	HideUIPanel(ArchaeologyFrame);
end

function ArchaeologyFrame_ShowFailed(self)
	CloseResearch();
end



function ArchaeologyFrame_OnLoad(self)
	ButtonFrameTemplate_HideButtonBar(ArchaeologyFrame);
	ButtonFrameTemplate_HideAttic(ArchaeologyFrame);
	
	self.bgLeft:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileL);
	self.bgRight:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileR);
	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("ARTIFACT_HISTORY_READY");
	self:RegisterEvent("ARTIFACT_COMPLETE");
	self:RegisterEvent("ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("BAG_UPDATE");
	
	
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup ) then
		if ( factionGroup == "Alliance" ) then
			self.tab1.factionIcon:SetTexCoord(0.31250000, 0.36914063, 0.79296875, 0.93359375);
			self.factionIcon:SetTexCoord(0.41992188, 0.47265625, 0.45703125, 0.58593750);
		else		
			self.tab1.factionIcon:SetTexCoord(0.21484375, 0.27343750, 0.79296875, 0.93750000);
			self.factionIcon:SetTexCoord(0.41992188, 0.47265625, 0.32031250, 0.44921875);
		end
	end	
	
	local name = GetArchaeologyInfo();
	self.TitleText:SetText(name);
	self.helpPage.titleText:SetText(name);
	
	
	self.summaryPage.UpdateFrame = ArchaeologyFrame_UpdateSummary;
	self.completedPage.UpdateFrame = ArchaeologyFrame_UpdateComplete;
	self.artifactPage.UpdateFrame = ArchaeologyFrame_CurrentArtifactUpdate;	
	
	self.completedPage.prevData ={ };
	self.completedPage.currData ={ onRare = false, raceIndex = 0, projectIndex = 0};
	

	self.currentFrame = self.summaryPage;
	
	UIDropDownMenu_SetWidth(self.raceFilterDropDown, 95);
	UIDropDownMenu_JustifyText(self.raceFilterDropDown, "LEFT");
	UIDropDownMenu_Initialize(self.raceFilterDropDown, ArchaeologyFrame_InitRaceFilter);
	self.currentFrame:UpdateFrame();
	self.artifactPage.glow:SetAlpha(0.0);
end


function ArchaeologyFrame_OnShow(self)
	PlaySound("igSpellBookOpen");
	local _, _, arch = GetProfessions();
	if arch then
		local name, texture, rank, maxRank = GetProfessionInfo(arch);
		SetPortraitToTexture(ArchaeologyFramePortrait, texture);
		self.rankBar:SetMinMaxValues(0, maxRank);
		self.rankBar:SetValue(rank);
		self.rankBar.text:SetText(rank.."/"..maxRank);
	end
	self.tab1:Click();
	
	local found = false;
	local numRaces = GetNumArchaeologyRaces();
	for i=1,ARCHAEOLOGY_MAX_RACES do
		if i <= numRaces then
			if  GetNumArtifactsByRace(i) > 0 then
				found = true;
				break;
			end
		end
	end	
	
	if not found then
		self.helpPage:Hide();
		self.infoButton:Click();
	else
		self.tab1:Click();
	end
end


function ArchaeologyFrame_OnHide(self)
	CloseResearch();
	PlaySound("igSpellBookClose");
end


function ArchaeologyFrame_OnEvent(self, event, ...)
	if event == "ARTIFACT_COMPLETE" then
		local name  = ...;
		if self.artifactPage:IsShown() and self.artifactPage.currentName == name  then
			self.artifactPage.glow:SetFrameLevel(self:GetFrameLevel()+3);
			self.artifactPage.glow.completeAnim:Play();
		end
	elseif event == "ARTIFACT_HISTORY_READY" then
		self.currentFrame:UpdateFrame();
	elseif event == "BAG_UPDATE" then
		if self:IsShown() and self.artifactPage:IsShown() then
			ArchaeologyFrame_CurrentArtifactUpdate(ArchaeologyFrame.artifactPage);
		end
	elseif event == "SKILL_LINES_CHANGED" then
		local _, _, arch = GetProfessions();
		if arch then
			local name, texture, rank, maxRank = GetProfessionInfo(arch);
			SetPortraitToTexture(ArchaeologyFramePortrait, texture);
			self.rankBar:SetMinMaxValues(0, maxRank);
			self.rankBar:SetValue(rank);
			self.rankBar.text:SetText(rank.."/"..maxRank);
		end
	else
		if self.completedPage:IsShown() then
			self.currentFrame.raceFilter = 0;
			self.completedPage.currentPage = 1;
			self.completedPage.currData.raceIndex = 1;
			self.completedPage.currData.projectIndex = 1;
			self.completedPage.currData.onRare = true;
			RequestArtifactCompletionHistory();
		else
			self.currentFrame:UpdateFrame();
		end
	end
end



function ArchaeologyFrame_UpdateSummary(self)
	local numRaces = GetNumArchaeologyRaces();
	local raceButton;
	for i=1,ARCHAEOLOGY_MAX_RACES do
		raceButton = self["race"..i];
		if i <= numRaces then
			local name, currency, texture, itemID =  GetArchaeologyRaceInfo(i);
			if texture and texture ~= "" then
				raceButton:GetNormalTexture():SetTexture(texture);
			end
			
			local numProjects = GetNumArtifactsByRace(i);
			if numProjects==0 then
				raceButton:Disable();
			else
				raceButton:Enable();
				raceButton.raceName:SetText(name);
			end
		else
			self["race"..i]:Hide();
		end
	end	
end


function ArchaeologyFrame_CurrentArtifactUpdate(self)
	local RaceName, RaceCurrency, RaceTexture, RaceitemID	= GetArchaeologyRaceInfo(self.raceID);
	local name, description, rarity, icon, spellDescription, numSockets, bgTexture =  GetSelectedArtifactInfo();
	self.currentName = name;
	if 	self.solveFrame:IsShown() then
		local base, adjust, totalCost = GetArtifactProgress();
		self.solveFrame.statusBar:SetMinMaxValues(0, totalCost);
		self.solveFrame.statusBar:SetValue(min(base+adjust, totalCost));
		if adjust > 0 then
			self.solveFrame.statusBar.text:SetText((base+adjust).." "..GREEN_FONT_COLOR_CODE.."(+"..adjust.." "..ARCHAEOLOGY_RUNE_STONES..")|r /"..totalCost);
		else
			self.solveFrame.statusBar.text:SetText(base.."/"..totalCost);
		end	
			
		if CanSolveArtifact() then
			self.solveFrame.solveButton:Enable();
		else 
			self.solveFrame.solveButton:Disable();
		end
	end
		
	self.artifactName:SetText(name);
	self.icon:SetTexture(icon);	
	self.historyScroll.child.text:SetText(description);
	
	self.historyTitle:ClearAllPoints();
	local runeName, _, _, _, _, _, _, _, _, runeStoneIconPath = GetItemInfo(RaceitemID);
	local endFound = false;
	for i=1,ARCHAEOLOGY_MAX_STONES do
		if i > numSockets or not runeName then
			self.solveFrame["keystone"..i]:Hide();
		else
			self.solveFrame["keystone"..i].icon:SetTexture(runeStoneIconPath);
			if ItemAddedToArtifact(i) then
				self.solveFrame["keystone"..i].icon:Show();
				self.solveFrame["keystone"..i].tooltip = string.format(ARCHAEOLOGY_KEYSTONE_REMOVE_TOOLTIP, runeName);
				self.solveFrame["keystone"..i]:Enable();
			else
				self.solveFrame["keystone"..i].icon:Hide();
				self.solveFrame["keystone"..i].tooltip = string.format(ARCHAEOLOGY_KEYSTONE_ADD_TOOLTIP, runeName);
				self.solveFrame["keystone"..i]:Enable();
				if endFound then
					self.solveFrame["keystone"..i]:Disable();
				end
				endFound = true;
			end
			self.solveFrame["keystone"..i]:Show();
		end
	end
	
	if rarity == 0 then --Common Item
		self.historyTitle:SetPoint("RIGHT", -110, 140);
		self.historyScroll:SetSize(190, 200);
		self.historyScroll.child:SetSize(190, 200);
		self.historyScroll.child.text:SetWidth(190);
		self.artifactBG:SetTexture("");
		self.raceRarity:SetText(RaceName.." - "..ITEM_QUALITY1_DESC);
		if RaceTexture and RaceTexture ~= "" then
			self.raceBG:SetTexture(RaceTexture.."BIG");
		else
			self.raceBG:SetTexture("Interface\\Archeology\\Arch-TempLogo".."BIG");
		end
	else
		if 	self.solveFrame:IsShown() then
			self.historyTitle:SetPoint("CENTER", 0, -25);
			self.historyScroll:SetSize(400, 68);
			self.historyScroll.child:SetSize(400, 68);
			self.historyScroll.child.text:SetWidth(400);
		else
			self.historyTitle:SetPoint("CENTER", 0, -25);
			self.historyScroll:SetSize(400, 118);
			self.historyScroll.child:SetSize(400, 118);
			self.historyScroll.child.text:SetWidth(400);
			
			self.historyScroll.child.text:SetText(spellDescription);
		end
		self.raceBG:SetTexture("");
		self.raceRarity:SetText(RaceName.." - "..ITEM_QUALITY3_DESC);
		if bgTexture and bgTexture ~= "" then
			self.artifactBG:SetTexture(bgTexture);
		else
			self.artifactBG:SetTexture("Interface\\Archeology\\Arch-TempRareSketch");
		end
	end		
end




function ArchaeologyFrame_UpdateComplete(self)
	local name, rarity, icon, completionCount, completionCount;
	local raceName;
	local numRaces = GetNumArchaeologyRaces();
	local outOfArtifacts = false;
	local numRare = 0;
	local numCommon = 0;
	local buttonSkip = 0;
	
	
	if not self.prevData[self.currentPage] then
		self.prevData[self.currentPage] = {};
	end
	self.prevData[self.currentPage].raceIndex = self.currData.raceIndex;
	self.prevData[self.currentPage].projectIndex = self.currData.projectIndex;
	self.prevData[self.currentPage].onRare = self.currData.onRare;

	
	if IsArtifactCompletionHistoryAvailable() then
		local i = 1;
		while i<=ARCHAEOLOGY_MAX_COMPLETED_SHOWN+1 do
			if outOfArtifacts  or buttonSkip > 0 then
				if i<=ARCHAEOLOGY_MAX_COMPLETED_SHOWN then
					self["artifact"..i]:Hide();
					buttonSkip = buttonSkip-1;
				end
			else
				local failed = false;
				local rareStatus = self.currData.onRare;
				name, description, rarity, icon, spellDescription,  _, _, firstComletionTime, completionCount = GetArtifactInfoByRace(self.currData.raceIndex, self.currData.projectIndex);
				if not name then
					if self.raceFilter ~= 0 then
						outOfArtifacts = true;
					else
						self.currData.raceIndex = self.currData.raceIndex+1;
						self.currData.projectIndex = 1;
						if self.currData.raceIndex > numRaces then
							if self.currData.onRare then
								self.currData.raceIndex = 1;
								self.currData.onRare = false;
							else	-- WE ARE DONE
								outOfArtifacts = true;
							end
						end
					end
					failed = true;
				elseif self.currData.onRare and rarity==0 then -- common item
					if self.raceFilter == 0 then
						self.currData.raceIndex = self.currData.raceIndex+1;
						self.currData.projectIndex = 1;
					else 
						self.currData.onRare = false;
					end
					if self.currData.raceIndex > numRaces then
						self.currData.onRare = false;
						self.currData.raceIndex = 1;
					end
					failed = true;
				elseif not self.currData.onRare and rarity~=0 then
					self.currData.projectIndex = self.currData.projectIndex+1;
					failed = true;
				elseif completionCount ==  0 then
					self.currData.projectIndex = self.currData.projectIndex+1;
					failed = true;
				end
				
				if rareStatus ~= self.currData.onRare and i > 1 then -- we have switched to common
					local yoffset =  ARCHAEOLOGY_MID_TITLE_YOFFSET - floor(i/2)*ARCHAEOLOGY_BUTTON_HEIGHT;
					self.titleMid:SetPoint("TOP", 0 , yoffset);
					buttonSkip = 2 + mod(i+1,2);
				end
				
				if not failed  and  i<=ARCHAEOLOGY_MAX_COMPLETED_SHOWN then
					raceName = GetArchaeologyRaceInfo(self.currData.raceIndex);
					local projectButton = self["artifact"..i];
					projectButton:Show();
					projectButton.icon:SetTexture(icon);
					projectButton.artifactName:SetText(name);
					projectButton.raceIndex =  self.currData.raceIndex;
					projectButton.projectIndex =  self.currData.projectIndex;
					if rarity == 0 then
						projectButton.spellDescription = spellDescription;
					else
						projectButton.spellDescription = description;
					end
					if rarity == 0 then
						numCommon = numCommon +1;
						projectButton.artifactSubText:SetText(raceName.." - "..ITEM_QUALITY1_DESC);
						projectButton:Disable();
					else
						numRare = numRare +1;
						projectButton.artifactSubText:SetText(raceName.." - "..ITEM_QUALITY3_DESC);
						projectButton:Enable();
					end
					self.currData.projectIndex = self.currData.projectIndex+1;
				elseif failed then
					i = i-1; -- Try this loop again with new race and artifact
				end	
			end
			i=i+1;
		end
	else
		for i=1,ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
			self["artifact"..i]:Hide();
		end
	end
	
	
	self.pageText:SetFormattedText(PAGE_NUMBER, self.currentPage);
	if self.currentPage == 1 then
		self.prevPageButon:SetButtonState("NORMAL");
		self.prevPageButon:Disable();
	else	
		self.prevPageButon:Enable();
	end
	name = GetArtifactInfoByRace(self.currData.raceIndex, self.currData.projectIndex);
	if not name then
		self.nextPageButon:SetButtonState("NORMAL");
		self.nextPageButon:Disable();
	else	
		self.nextPageButon:Enable();
	end
		
	
	if numRare + numCommon == 0 then
		self.titleBig:Show();
		self.titleBigLeft:Show();
		self.titleBigRight:Show();
		self.infoText:Show();		
		
		self.titleTop:Hide();
		self.titleTopLeft:Hide();
		self.titleTopRight:Hide();
		self.titleMid:Hide();
		self.titleMidLeft:Hide();
		self.titleMidRight:Hide();
		ArchaeologyFrame.raceFilterDropDown:Hide();
	else
		
		ArchaeologyFrame.raceFilterDropDown:Show();
		self.titleBig:Hide();
		self.titleBigLeft:Hide();
		self.titleBigRight:Hide();
		self.infoText:Hide();	
	
		self.titleTop:Show();
		self.titleTopLeft:Show();
		self.titleTopRight:Show();
		if numRare == 0 then
			self.titleTop:SetText(ARCHAEOLOGY_COMMON_COMPLETED);
			self.titleMid:Hide();
			self.titleMidLeft:Hide();
			self.titleMidRight:Hide();
		else
			self.titleTop:SetText(ARCHAEOLOGY_RARE_COMPLETED);
			if numCommon > 0 then
				self.titleMid:Show();
				self.titleMidLeft:Show();
				self.titleMidRight:Show();
			else 
				self.titleMid:Hide();
				self.titleMidLeft:Hide();
				self.titleMidRight:Hide();
			end
		end
	end
end



function ArchaeologyFrame_ShowArtifact(RaceID, ArtifactID)
	ArchaeologyFrame.summaryPage:Hide();
	ArchaeologyFrame.completedPage:Hide();	
	if ArtifactID then
		SetSelectedArtifact(RaceID, ArtifactID);
		ArchaeologyFrame.raceFilterDropDown:Hide();
		ArchaeologyFrame.artifactPage.solveFrame:Hide();
		ArchaeologyFrame.artifactPage.backButton:Show();
	else	
		ArchaeologyFrame.raceFilterDropDown:Show();
		SetSelectedArtifact(RaceID);
		ArchaeologyFrame.artifactPage.solveFrame:Show();
		ArchaeologyFrame.artifactPage.backButton:Hide();
		UIDropDownMenu_SetText(ArchaeologyFrame.raceFilterDropDown, GetArchaeologyRaceInfo(RaceID));
	end
	
	ArchaeologyFrame.artifactPage.raceFilter = RaceID;
	ArchaeologyFrame.artifactPage.raceID = RaceID;
	ArchaeologyFrame.artifactPage.isFinished = ArtifactID ~= nil;
	ArchaeologyFrame.currentFrame = ArchaeologyFrame.artifactPage;
	ArchaeologyFrame_CurrentArtifactUpdate(ArchaeologyFrame.artifactPage);
	ArchaeologyFrame.artifactPage:Show();
end


function ArchaeologyFrame_OnTabClick(self)	
	local archFrame = self:GetParent();
	archFrame.selectedTab = self:GetID()
	
	CloseDropDownMenus();
	archFrame.summaryPage:Hide();
	archFrame.completedPage:Hide();
	archFrame.artifactPage:Hide();
	archFrame.rankBar:Show();
	
	UIDropDownMenu_SetText(archFrame.raceFilterDropDown, ALL);

	
	if archFrame.selectedTab ==  ARCHAEOLOGY_HELP_TAB then
		if archFrame.helpPage:IsShown() then
			archFrame.selectedTab = ARCHAEOLOGY_SUMMARY_TAB;
			archFrame.helpPage:Hide();
		else
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetSize(63, 57);
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetSize(63, 57);
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250);
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250);
			archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB].factionIcon:SetPoint("CENTER", -6, 0);
			
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetSize(48, 57);
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetSize(48, 57);
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetTexCoord(0.31250000, 0.40625000, 0.56250000, 0.78515625);
			archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetTexCoord(0.31250000, 0.40625000, 0.56250000, 0.78515625);
			
			archFrame.bgLeft:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileL);
			archFrame.bgRight:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileR);	
			archFrame.helpPage:Show();
			archFrame.raceFilterDropDown:Hide();
			archFrame.rankBar:Hide();
			archFrame.factionIcon:Show();
		end
	else
		archFrame.helpPage:Hide();
	end


	if archFrame.selectedTab ==  ARCHAEOLOGY_SUMMARY_TAB then
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetSize(63, 57);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetSize(63, 57);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB].factionIcon:SetPoint("CENTER", -6, 0);
		
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetSize(48, 57);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetSize(48, 57);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetTexCoord(0.31250000, 0.40625000, 0.56250000, 0.78515625);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetTexCoord(0.31250000, 0.40625000, 0.56250000, 0.78515625);
		
		archFrame.bgLeft:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileL);
		archFrame.bgRight:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_SUMMARY_PAGE].bgFileR);	
		archFrame.summaryPage:Show();
		archFrame.currentFrame = archFrame.summaryPage;
		archFrame.currentFrame.raceFilter = 0;
		ArchaeologyFrame.raceFilterDropDown:Hide();
		ArchaeologyFrame.factionIcon:Show();
		archFrame.currentFrame:UpdateFrame();
	elseif archFrame.selectedTab ==  ARCHAEOLOGY_COMPLETED_TAB then
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetSize(48, 57);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetSize(48, 57);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetNormalTexture():SetTexCoord(0.21484375, 0.30859375, 0.56250000, 0.78515625);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB]:GetHighlightTexture():SetTexCoord(0.21484375, 0.30859375, 0.56250000, 0.78515625);
		archFrame["tab"..ARCHAEOLOGY_SUMMARY_TAB].factionIcon:SetPoint("CENTER", -13, 0);
		
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetSize(63, 57);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetSize(63, 57);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetNormalTexture():SetTexCoord(0.72851563, 0.85156250, 0.00390625, 0.22656250);
		archFrame["tab"..ARCHAEOLOGY_COMPLETED_TAB]:GetHighlightTexture():SetTexCoord(0.72851563, 0.85156250, 0.00390625, 0.22656250);
		
		archFrame.bgLeft:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_COMPLETED_PAGE].bgFileL);
		archFrame.bgRight:SetTexture(ArcheologyLayoutInfo[ARCHAEOLOGY_COMPLETED_PAGE].bgFileR);	
		archFrame.completedPage:Show();
		archFrame.completedPage.currentPage = 1;
		archFrame.completedPage.currData.raceIndex = 1;
		archFrame.completedPage.currData.projectIndex = 1;
		archFrame.completedPage.currData.onRare = true;
		archFrame.currentFrame = archFrame.completedPage;
		archFrame.currentFrame.raceFilter = 0;
		ArchaeologyFrame.factionIcon:Hide();
		RequestArtifactCompletionHistory();
	end
end


function ArchaeologyFrame_KeyStoneClick(self)
	if ItemAddedToArtifact(self:GetID()) then
		RemoveItemFromArtifact();
	else
		SocketItemToArtifact();
	end
	ArchaeologyFrame_CurrentArtifactUpdate(ArchaeologyFrame.artifactPage);
end

function ArchaeologyFrame_PageClick(self, nextPage)
	if nextPage then
		ArchaeologyFrame.currentFrame.currentPage = ArchaeologyFrame.currentFrame.currentPage + 1;
		ArchaeologyFrame.currentFrame:UpdateFrame();
	else
		ArchaeologyFrame.completedPage.currentPage = ArchaeologyFrame.completedPage.currentPage - 1;
		ArchaeologyFrame.completedPage.currData.raceIndex = ArchaeologyFrame.completedPage.prevData[ArchaeologyFrame.completedPage.currentPage].raceIndex;
		ArchaeologyFrame.completedPage.currData.projectIndex = ArchaeologyFrame.completedPage.prevData[ArchaeologyFrame.completedPage.currentPage].projectIndex;
		ArchaeologyFrame.completedPage.currData.onRare = ArchaeologyFrame.completedPage.prevData[ArchaeologyFrame.completedPage.currentPage].onRare;
		ArchaeologyFrame.currentFrame:UpdateFrame();
	end
end



function ArchaeologyFrame_RaceFilterSet(self, arg1)
	ArchaeologyFrame.currentFrame.raceFilter = arg1;
	
	if ArchaeologyFrame.currentFrame == ArchaeologyFrame.completedPage  then
		if arg1 == 0 then
			UIDropDownMenu_SetText(ArchaeologyFrame.raceFilterDropDown, ALL);
		else
			UIDropDownMenu_SetText(ArchaeologyFrame.raceFilterDropDown, GetArchaeologyRaceInfo(arg1));
		end
		ArchaeologyFrame.currentFrame.currData.raceIndex = max(1, arg1);
		ArchaeologyFrame.currentFrame.currData.projectIndex = 1;
		ArchaeologyFrame.currentFrame.currData.onRare = true;
		ArchaeologyFrame.currentFrame.currentPage = 1
	else
		 ArchaeologyFrame_ShowArtifact(arg1);
	end
	ArchaeologyFrame.currentFrame:UpdateFrame();
end


function ArchaeologyFrame_InitRaceFilter()
	local numRaces = GetNumArchaeologyRaces();
	
	local info = UIDropDownMenu_CreateInfo();
	if ArchaeologyFrame.currentFrame == ArchaeologyFrame.completedPage  then
		info.text = ALL;
		info.arg1 = 0;
		info.func = ArchaeologyFrame_RaceFilterSet;
		info.checked = ArchaeologyFrame.currentFrame.raceFilter == 0;
		UIDropDownMenu_AddButton(info);
	end
	
	for i=1,numRaces do
		local numProjects = GetNumArtifactsByRace(i);
		if numProjects > 0 then
			local name =  GetArchaeologyRaceInfo(i);
			info = UIDropDownMenu_CreateInfo();
			info.text = name;
			info.arg1 = i;
			info.func = ArchaeologyFrame_RaceFilterSet;
			info.checked = ArchaeologyFrame.currentFrame.raceFilter == i;
			UIDropDownMenu_AddButton(info);
		end
	end
end




