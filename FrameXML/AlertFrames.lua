MAX_ACHIEVEMENT_ALERTS = 2;

function AlertFrame_OnLoad (self)
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("LFG_COMPLETION_REWARD");
end

function AlertFrame_OnEvent (self, event, ...)
	if ( event == "ACHIEVEMENT_EARNED" ) then
		local id = ...;
		
		if ( not AchievementFrame ) then
			AchievementFrame_LoadUI();
		end
		
		AchievementAlertFrame_ShowAlert(id);
	elseif ( event == "LFG_COMPLETION_REWARD" ) then
		DungeonCompletionAlertFrame_ShowAlert();
	end
end

function AlertFrame_FixAnchors()
	AchievementAlertFrame_FixAnchors();
	DungeonCompletionAlertFrame_FixAnchors();
end

function AlertFrame_AnimateIn(frame)
	frame:Show();
	frame.animIn:Play();
	frame.glow.animIn:Play();
	frame.shine.animIn:Play();
	frame.waitAndAnimOut:Stop();	--Just in case it's already animating out, but we want to reinstate it.
	if ( frame:IsMouseOver() ) then
		frame.waitAndAnimOut.animOut:SetStartDelay(1);
	else
		frame.waitAndAnimOut.animOut:SetStartDelay(4.05);
		frame.waitAndAnimOut:Play();
	end
end

function AlertFrame_StopOutAnimation(frame)
	frame.waitAndAnimOut:Stop();
	frame.waitAndAnimOut.animOut:SetStartDelay(1);
end

function AlertFrame_ResumeOutAnimation(frame)
	frame.waitAndAnimOut:Play();
end

-- [[ DungeonCompletionAlertFrame ]] --
function DungeonCompletionAlertFrame_OnLoad (self)
	self.glow = self.glowFrame.glow;
end

function DungeonCompletionAlertFrame_FixAnchors()
	for i=MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		local frame = _G["AchievementAlertFrame"..i];
		if ( frame and frame:IsShown() ) then
			DungeonCompletionAlertFrame1:SetPoint("BOTTOM", frame, "TOP", 0, 10);
			return;
		end
	end
	
	for i=NUM_GROUP_LOOT_FRAMES, 1, -1 do
		local frame = _G["GroupLootFrame"..i];
		if ( frame and frame:IsShown() ) then
			DungeonCompletionAlertFrame1:SetPoint("BOTTOM", frame, "TOP", 0, 10);
			return;
		end
	end
	
	DungeonCompletionAlertFrame1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
end

DUNGEON_COMPLETION_MAX_REWARDS = 1;
function DungeonCompletionAlertFrame_ShowAlert()
	PlaySound("LFG_Rewards");
	local frame = DungeonCompletionAlertFrame1;
	--For now we only have 1 dungeon alert frame. If you're completing more than one dungeon within ~5 seconds, tough luck.
	local name, typeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards= GetLFGCompletionReward();
	
	
	--Set up the rewards
	local moneyAmount = moneyBase + moneyVar * numStrangers;
	local experienceGained = experienceBase + experienceVar * numStrangers;
	
	local rewardsOffset = 0;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		SetPortraitToTexture(DungeonCompletionAlertFrame1Reward1.texture, "Interface\\Icons\\inv_misc_coin_02");
		DungeonCompletionAlertFrame1Reward1.rewardID = 0;
		DungeonCompletionAlertFrame1Reward1:Show();

		rewardsOffset = 1;
	end
	
	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local reward = _G["DungeonCompletionAlertFrame1Reward"..frameID];
		if ( not reward ) then
			reward = CreateFrame("FRAME", "DungeonCompletionAlertFrame1Reward"..frameID, DungeonCompletionAlertFrame1, "DungeonCompletionAlertFrameRewardTemplate");
			reward:SetID(frameID);
			DUNGEON_COMPLETION_MAX_REWARDS = frameID;
		end
		DungeonCompletionAlertFrameReward_SetReward(reward, i);
	end
	
	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, DUNGEON_COMPLETION_MAX_REWARDS do
		_G["DungeonCompletionAlertFrame1Reward"..i]:Hide();
	end
	
	if ( usedButtons > 0 ) then
		--Set up positions
		local spacing = 36;
		DungeonCompletionAlertFrame1Reward1:SetPoint("TOP", DungeonCompletionAlertFrame1, "TOP", -spacing/2 * usedButtons + 41, 0);
		for i = 2, usedButtons do
			_G["DungeonCompletionAlertFrame1Reward"..i]:SetPoint("CENTER", "DungeonCompletionAlertFrame1Reward"..(i - 1), "CENTER", spacing, 0);
		end
	end
	
	--Set up the text and icons.
	
	frame.instanceName:SetText(name);
	if ( typeID == TYPEID_HEROIC_DIFFICULTY ) then
		frame.heroicIcon:Show();
		frame.instanceName:SetPoint("TOP", 33, -44);
	else
		frame.heroicIcon:Hide();
		frame.instanceName:SetPoint("TOP", 25, -44);
	end
		
	frame.dungeonTexture:SetTexture("Interface\\LFGFrame\\LFGIcon-"..textureFilename);
	
	AlertFrame_AnimateIn(frame)
	
	
	AlertFrame_FixAnchors();
end

function DungeonCompletionAlertFrameReward_SetReward(frame, index)
	local texturePath, quantity = GetLFGCompletionRewardItem(index);
	SetPortraitToTexture(frame.texture, texturePath);
	frame.rewardID = index;
	frame:Show();
end

function DungeonCompletionAlertFrameReward_OnEnter(self)
	AlertFrame_StopOutAnimation(self:GetParent());
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(YOU_RECEIVED);
		local name, typeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards = GetLFGCompletionReward();

		local moneyAmount = moneyBase + moneyVar * numStrangers;
		local experienceGained = experienceBase + experienceVar * numStrangers;
		
		if ( experienceGained > 0 ) then
			GameTooltip:AddLine(string.format(GAIN_EXPERIENCE, experienceGained));
		end
		if ( moneyAmount > 0 ) then
			SetTooltipMoney(GameTooltip, moneyAmount, nil);
		end
	else
		GameTooltip:SetLFGCompletionReward(self.rewardID);
	end
	GameTooltip:Show();
end

function DungeonCompletionAlertFrameReward_OnLeave(frame)
	AlertFrame_ResumeOutAnimation(frame:GetParent());
	GameTooltip:Hide();
end

-- [[ AchievementAlertFrame ]] --
function AchievementAlertFrame_OnLoad (self)
	self:RegisterForClicks("LeftButtonUp");
end

function AchievementAlertFrame_FixAnchors ()
	-- Temporary (here's hoping) workaround so that achievement alerts are anchored to loot roll windows. Eventually we want one system to handle placement for both alerts.
	if ( not AchievementAlertFrame1 ) then
		-- We haven't displayed any achievement alerts yet, so there's nothing to reanchor (read: this got called by LootFrame.lua)
		return;
	end
	
	for i=NUM_GROUP_LOOT_FRAMES, 1, -1  do
		local frame = _G["GroupLootFrame"..i];
		if ( frame and frame:IsShown() ) then
			AchievementAlertFrame1:SetPoint("BOTTOM", frame, "TOP", 0, 10);
			return;
		end
	end
	
	AchievementAlertFrame1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
end

function AchievementAlertFrame_ShowAlert (achievementID)
	local frame = AchievementAlertFrame_GetAlertFrame();
	local _, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID);
	if ( not frame ) then
		-- We ran out of frames! Bail!
		return;
	end

	_G[frame:GetName() .. "Name"]:SetText(name);
	
	local shield = _G[frame:GetName() .. "Shield"];
	AchievementShield_SetPoints(points, shield.points, GameFontNormal, GameFontNormalSmall);
	if ( points == 0 ) then
		shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
	else
		shield.icon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
	end
	
	_G[frame:GetName() .. "IconTexture"]:SetTexture(icon);
	
	frame.id = achievementID;
	
	AlertFrame_AnimateIn(frame);
	
	AlertFrame_FixAnchors();
end

function AchievementAlertFrame_GetAlertFrame()
	local name, frame, previousFrame;
	for i=1, MAX_ACHIEVEMENT_ALERTS do
		name = "AchievementAlertFrame"..i;
		frame = _G[name];
		if ( frame ) then
			if ( not frame:IsShown() ) then
				return frame;
			end
		else
			frame = CreateFrame("Button", name, UIParent, "AchievementAlertFrameTemplate");
			if ( not previousFrame ) then
				frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128);
			else
				frame:SetPoint("BOTTOM", previousFrame, "TOP", 0, -10);
			end
			return frame;
		end
		previousFrame = frame;
	end
	return nil;
end

function AchievementAlertFrame_OnClick (self)
	local id = self.id;
	if ( not id ) then
		return;
	end
	
	CloseAllWindows();
	ShowUIPanel(AchievementFrame);
	
	local _, _, _, achCompleted = GetAchievementInfo(id);
	if ( achCompleted and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	elseif ( (not achCompleted) and (ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func) ) then
		AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL);
	end
	
	AchievementFrame_SelectAchievement(id)
end

function AchievementAlertFrame_OnHide (self)
	AlertFrame_FixAnchors();
end