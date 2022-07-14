GossipTitleButtonMixin = {}
function GossipTitleButtonMixin:OnHide()
	self:CancelCallback();
	self.ClearData();
end

function GossipTitleButtonMixin:CancelCallback()
	if self.cancelCallback then
		self.cancelCallback();
		self.cancelCallback = nil;
	end
end

function GossipTitleButtonMixin:AddCallbackForQuest(questID, cb)
	self:CancelCallback();
	self.cancelCallback = QuestEventListener:AddCancelableCallback(questID, cb);
end

function GossipTitleButtonMixin:SetQuest(titleText, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored, questID)
	self.type = "Available";

	QuestUtil.ApplyQuestIconOfferToTexture(self.Icon, isLegendary, frequency, isRepeatable, QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID), C_QuestLog.IsQuestCalling(questID))
	self:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial);
end

function GossipTitleButtonMixin:SetActiveQuest(titleText, level, isTrivial, isComplete, isLegendary, isIgnored, questID)
	self.type = "Active";

	QuestUtil.ApplyQuestIconActiveToTexture(self.Icon, isComplete, isLegendary, nil, nil, QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID), C_QuestLog.IsQuestCalling(questID));
	self:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial);
end

function GossipTitleButtonMixin:SetOption(titleText, iconName, spellID)
	self.type = "Gossip";
	self.spellID = spellID; 
	self:SetText(titleText);
	self.Icon:SetTexture("Interface/GossipFrame/" .. iconName .. "GossipIcon");
	self.Icon:SetVertexColor(1, 1, 1, 1);

	self:Resize();
end

function GossipTitleButtonMixin:OnEnter()
	if (self.spellID) then 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spellID);
		GameTooltip:Show(); 
	end  
end 

function GossipTitleButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 

function GossipTitleButtonMixin:UpdateTitleForQuest(questID, titleText, isIgnored, isTrivial)
	if ( isIgnored ) then
		self:SetFormattedText(IGNORED_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(0.5,0.5,0.5);
	elseif ( isTrivial ) then
		self:SetFormattedText(TRIVIAL_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(0.5,0.5,0.5);
	else
		self:SetFormattedText(NORMAL_QUEST_DISPLAY, titleText);
		self.Icon:SetVertexColor(1,1,1);
	end

	self:Resize();
end

function GossipTitleButtonMixin:Resize()
	self:SetHeight(math.max(self:GetTextHeight() + 2, self.Icon:GetHeight()));
end

function GossipFrame_OnLoad(self)
	self:RegisterEvent("QUEST_LOG_UPDATE");

	self.titleButtonPool = CreateFramePool("Button", GossipGreetingScrollChildFrame, "GossipTitleButtonTemplate");
end

function GossipFrame_HandleShow(self, textureKit)
-- if there is only a non-gossip option, then go to it directly
	if ( (C_GossipInfo.GetNumAvailableQuests() == 0) and (C_GossipInfo.GetNumActiveQuests()  == 0) and (C_GossipInfo.GetNumOptions() == 1) and not C_GossipInfo.ForceGossip() ) then
		local gossipInfoTable = C_GossipInfo.GetOptions();
		if ( gossipInfoTable[1].type ~= "gossip" ) then
			C_GossipInfo.SelectOption(1);
			return;
		end
	end

	if ( not GossipFrame:IsShown() ) then
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			C_GossipInfo.CloseGossip();
			return;
		end
	end

	self.Background:SetAtlas(GossipFrame_GetBackgroundTexture(self, textureKit), TextureKitConstants.UseAtlasSize);
	NPCFriendshipStatusBar_Update(self);
	GossipFrameUpdate();
end

local backgroundTextureKit = "QuestBG-%s";

function GossipFrame_GetBackgroundTexture(self, textureKit)
	if (textureKit) then 
		local backgroundAtlas = GetFinalNameFromTextureKit(backgroundTextureKit, textureKit);
		local atlasInfo = C_Texture.GetAtlasInfo(backgroundAtlas); 
		if(atlasInfo) then 
			return backgroundAtlas; 
		end
	end
	return QuestUtil.GetDefaultQuestBackgroundTexture(); 
end 

function GossipFrame_HandleHide(self)
	HideUIPanel(self);
end

function GossipFrame_OnEvent(self, event, ...)
	if ( event == "QUEST_LOG_UPDATE" and GossipFrame.hasActiveQuests ) then
		GossipFrameUpdate();
	end
end

function GossipFrameUpdate()
	GossipFrame.titleButtonPool:ReleaseAll();
	GossipFrame.buttons = {};

	GossipGreetingText:SetText(C_GossipInfo.GetText());
	GossipFrameAvailableQuestsUpdate();
	GossipFrameActiveQuestsUpdate();
	GossipFrameOptionsUpdate();
	GossipFrameNpcNameText:SetText(UnitName("npc"));
	if ( UnitExists("npc") ) then
		SetPortraitTexture(GossipFramePortrait, "npc");
	else
		GossipFramePortrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	end

	-- Set Spacer
	local buttonCount = GossipFrame_GetTitleButtonCount();
	if buttonCount > 1 then
		GossipSpacerFrame:SetPoint("TOP", GossipFrame_GetTitleButton(buttonCount - 1), "BOTTOM", 0, 0);
	else
		GossipSpacerFrame:SetPoint("TOP", GossipGreetingText, "BOTTOM", 0, 0);
	end

	-- Update scrollframe
	GossipGreetingScrollFrame:SetVerticalScroll(0);
end

function GossipFrame_GetTitleButtonCount()
	return GossipFrame.buttons and #GossipFrame.buttons or 0;
end

function GossipFrame_GetTitleButton(index)
	return GossipFrame.buttons[index];
end

local function GossipFrame_AcquireTitleButton()
	local button = GossipFrame.titleButtonPool:Acquire();
	table.insert(GossipFrame.buttons, button);
	button:Show();
	return button;
end

local function GossipFrame_InsertTitleSeparator()
	if GossipFrame_GetTitleButtonCount() > 1 then
		GossipFrame.insertSeparator = true;
	end
end

local function GossipFrame_CancelTitleSeparator()
	GossipFrame.insertSeparator = false;
end

local function GossipFrame_AnchorTitleButton(button)
	local buttonCount = GossipFrame_GetTitleButtonCount();
	if buttonCount > 1 then
		button:SetPoint("TOPLEFT", GossipFrame_GetTitleButton(buttonCount - 1), "BOTTOMLEFT", 0, (GossipFrame.insertSeparator and -19 or 0) - 3);
	else
		button:SetPoint("TOPLEFT", GossipGreetingText, "BOTTOMLEFT", -10, -20);
	end

	GossipFrame_CancelTitleSeparator();
end

function GossipTitleButton_OnClick(self, button)
	if ( self.type == "Available" ) then
		C_GossipInfo.SelectAvailableQuest(self:GetID());
	elseif ( self.type == "Active" ) then
		C_GossipInfo.SelectActiveQuest(self:GetID());
	else
		C_GossipInfo.SelectOption(self:GetID());
	end
end

function GossipFrameAvailableQuestsUpdate()
	local GossipQuests = C_GossipInfo.GetAvailableQuests();
	for titleIndex, questInfo in ipairs(GossipQuests) do
		local button = GossipFrame_AcquireTitleButton();
		button:SetQuest(questInfo.title, questInfo.questLevel, questInfo.isTrivial, questInfo.frequency, questInfo.repeatable, questInfo.isLegendary, questInfo.isIgnored, questInfo.questID);
		button:SetID(titleIndex);
		GossipFrame_AnchorTitleButton(button);
	end

	GossipFrame_InsertTitleSeparator();
end

function GossipFrameActiveQuestsUpdate()
	local gossipQuests = C_GossipInfo.GetActiveQuests();

	GossipFrame.hasActiveQuests = (#gossipQuests > 0);
	for titleIndex, questInfo in ipairs(gossipQuests) do
		local button = GossipFrame_AcquireTitleButton();
		button:SetActiveQuest(questInfo.title, questInfo.questLevel, questInfo.isTrivial, questInfo.isComplete, questInfo.isLegendary, questInfo.isIgnored, questInfo.questID);
		button:SetID(titleIndex);
		GossipFrame_AnchorTitleButton(button);
	end

	GossipFrame_InsertTitleSeparator();
end

function GossipFrameOptionsUpdate()
	local gossipOptions = C_GossipInfo.GetOptions();

	local titleIndex = 1;
	for titleIndex, optionInfo in ipairs(gossipOptions) do
		local button = GossipFrame_AcquireTitleButton();
		button:SetOption(optionInfo.name, optionInfo.type, optionInfo.spellID);

		button:SetID(titleIndex);
		GossipFrame_AnchorTitleButton(button);
	end
end

local FRIENDSHIP_BAR_COLORS = {
	[1] = PURE_RED_COLOR,
	[2] = FACTION_ORANGE_COLOR,
	[3] = FACTION_YELLOW_COLOR,
	[4] = FACTION_GREEN_COLOR,
};
local function GetColorIndex(currentRank, numRanks, numColors)
	if numRanks < numColors then
		if currentRank == 1 then
			return 1;
		elseif currentRank == numRanks then
			return numColors;
		else
			return 3;
		end
	end

	-- Each chunk of rank colors will either have smallColorChunkCount or largeColorChunkCount ranks in them
	local smallColorChunkCount = math.floor(numRanks/numColors);
	local largeColorChunkCount = math.ceil(numRanks/numColors);
	local numLargeColorChunks = numRanks % numColors;
	-- Any ranks <= highestMaxColorIndex will be part of a chunk of largeColorChunkCount colors
	-- Any ranks above this will be part of a chunk of smallColorChunkCount colors
	local highestMaxColorIndex = numLargeColorChunks * largeColorChunkCount;

	if currentRank <= highestMaxColorIndex then
		return math.ceil(currentRank / largeColorChunkCount);
	else
		-- This rank is in a small color chunk
		-- First remove highestMaxColorIndex to get back into a 1->x distribution
		local relativeIndex = currentRank - highestMaxColorIndex;
		-- Then distrubute ranks evenly within that group of colors
		local relativeColorIndex = math.ceil(relativeIndex / smallColorChunkCount);
		return numLargeColorChunks + relativeColorIndex;
	end
end

function NPCFriendshipStatusBar_Update(frame, factionID --[[ = nil ]])
	local statusBar = NPCFriendshipStatusBar;
	local id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold, reversedColor, overrideColor = GetFriendshipReputation(factionID);
	statusBar.friendshipFactionID = id;
	if ( id and id > 0 ) then
		statusBar:SetParent(frame);
		-- if max rank, make it look like a full bar
		if ( not nextThreshold ) then
			threshold, nextThreshold, rep = 0, 1, 1;
		end
		if ( texture ) then
			statusBar.icon:SetTexture(texture);
		else
			statusBar.icon:SetTexture("Interface\\Common\\friendship-heart");
		end

		local numColors = 4;
		local colorIndex;
		if (not overrideColor) then
			local currRank, numRanks = GetFriendshipReputationRanks(factionID);

			colorIndex = GetColorIndex(currRank, numRanks, numColors);
			if (reversedColor) then
				colorIndex = (numColors + 1) - colorIndex;
			end
		else
			colorIndex = overrideColor;
		end

		statusBar:SetMinMaxValues(threshold, nextThreshold);
		statusBar:SetValue(rep);
		statusBar:ClearAllPoints();
		statusBar:SetPoint("TOPLEFT", 80, -41);

		local barFillColor = FRIENDSHIP_BAR_COLORS[colorIndex];
		statusBar:SetStatusBarColor(barFillColor:GetRGBA()); 
		statusBar:Show();
	else
		statusBar:Hide();
	end
end

function NPCFriendshipStatusBar_OnEnter(self)
	ShowFriendshipReputationTooltip(self.friendshipFactionID, self, "ANCHOR_BOTTOMRIGHT");
end
