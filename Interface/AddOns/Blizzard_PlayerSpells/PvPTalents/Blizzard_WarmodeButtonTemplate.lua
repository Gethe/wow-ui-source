
WarmodeButtonMixin = {};

function WarmodeButtonMixin:OnLoad()
	self:SetUp();
end

function WarmodeButtonMixin:OnShow()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	local warModeButtonHelpTipComplete = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK);
	local talentChangesTutorialComplete = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT_CHANGES);
	if (talentChangesTutorialComplete and not warModeButtonHelpTipComplete) then
		local helpTipInfo = {
			text = WAR_MODE_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PVP_WARMODE_UNLOCK,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			offsetX = -4,
		};

		HelpTip:Show(self, helpTipInfo, self);
	end
	self:Update();
end

function WarmodeButtonMixin:OnHide()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED");
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
	self:UnregisterEvent("ZONE_CHANGED");
end

function WarmodeButtonMixin:OnEvent(event, ...)
	if (event == "PLAYER_FLAGS_CHANGED") then
		local previousValue = self.predictedToggle:Get();
		self.predictedToggle:UpdateCurrentValue();
		self.predictedToggle:Clear();
		if (C_PvP.IsWarModeDesired() ~= previousValue) then
			self:Update();
		end
	elseif ((event == "ZONE_CHANGED") or (event == "ZONE_CHANGED_NEW_AREA")) then
		self:Update();
	end
end

function WarmodeButtonMixin:SetUp()
	self.predictedToggle = CreatePredictedToggle(
		{
			["toggleFunction"] = function()
				C_PvP.ToggleWarMode();
			end,
			["getFunction"] = function()
				return C_PvP.IsWarModeDesired();
			end,
		}
	);
end

function WarmodeButtonMixin:GetWarModeDesired()
	return self.predictedToggle:Get();
end

function WarmodeButtonMixin:Update()
	self:SetEnabled(not IsInInstance());
	local isPvp = self.predictedToggle:Get();
	local disabledAdd = isPvp and "" or "-disabled";
	local swordsAtlas = "pvptalents-warmode-swords"..disabledAdd;
	local ringAtlas = "talents-warmode-ring"..disabledAdd;
	self.Swords:SetAtlas(swordsAtlas);
	self.Ring:SetAtlas(ringAtlas);

	self:UpdateModelScenes();

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
	end

	self.WarmodeIncentive:Update();
end

function WarmodeButtonMixin:UpdateModelScenes(forceUpdate)
	if (self:GetWarModeDesired() == self.lastKnownDesiredState) then
		return;
	end

	if (self:GetWarModeDesired()) then
		self:UpdateModelScene(self.OrbModelScene, 108, 1102774, forceUpdate); -- 6AK_Arakkoa_Lamp_Orb_Fel.m2
		self:UpdateModelScene(self.FireModelScene, 109, 517202, forceUpdate); -- Firelands_Fire_2d.m2
	else
		self.OrbModelScene:Hide();
		self.FireModelScene:Hide();
	end
	self.lastKnownDesiredState = self:GetWarModeDesired();
end

function WarmodeButtonMixin:UpdateModelScene(scene, sceneID, fileID, forceUpdate)
	if (not scene) then
		return;
	end

	scene:Show();
	scene:SetFromModelSceneID(sceneID, forceUpdate);
	local effect = scene:GetActorByTag("effect");
	if (effect) then
		effect:SetModelByFileID(fileID);
	end
end

function WarmodeButtonMixin:OnClick()
	if (C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local warmodeEnabled = self.predictedToggle:Get();

		if (warmodeEnabled) then
			PlaySound(SOUNDKIT.UI_WARMODE_DECTIVATE);
		else
			PlaySound(SOUNDKIT.UI_WARMODE_ACTIVATE);
		end

		self.predictedToggle:Toggle();

		self:Update();

		HelpTip:Acknowledge(self:GetParent(), WAR_MODE_TUTORIAL);
	end
end

function WarmodeButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 14, 0);
	GameTooltip_SetTitle(GameTooltip, PVP_LABEL_WAR_MODE);
	if C_PvP.IsWarModeActive() or self:GetWarModeDesired() then
		GameTooltip_AddInstructionLine(GameTooltip, PVP_WAR_MODE_ENABLED);
	end
	local wrap = true;
	local warModeRewardBonus = C_PvP.GetWarModeRewardBonus();
	GameTooltip_AddNormalLine(GameTooltip, PVP_WAR_MODE_DESCRIPTION_FORMAT:format(warModeRewardBonus), wrap);

	-- Determine if the player can toggle warmode on/off.
	local canToggleWarmode = C_PvP.CanToggleWarMode(true);
	local canToggleWarmodeOFF = C_PvP.CanToggleWarMode(false);

	-- Confirm there is a reason to show an error message
	if(not canToggleWarmode or not canToggleWarmodeOFF) then

		-- player is not high enough level
		if (not C_PvP.ArePvpTalentsUnlocked()) then
			GameTooltip_AddErrorLine(GameTooltip, PVP_TALENT_SLOT_LOCKED:format(C_PvP.GetPvpTalentsUnlockedLevel()), wrap);
		else
			local warmodeErrorText;

			-- Outdoor world environment
			if(not C_PvP.CanToggleWarModeInArea()) then
				if(self:GetWarModeDesired()) then
					if(not canToggleWarmodeOFF and not IsResting()) then
						warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA;
					end
				else
					if(not canToggleWarmode) then
						warmodeErrorText = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
					end
				end
			end

			-- player is not allowed to toggle warmode in combat.
			if(warmodeErrorText) then
				GameTooltip_AddErrorLine(GameTooltip, warmodeErrorText, wrap);
			elseif (UnitAffectingCombat("player")) then
				GameTooltip_AddErrorLine(GameTooltip, SPELL_FAILED_AFFECTING_COMBAT, wrap);
			end
		end
	end
		
	GameTooltip:Show();
end

WarmodeIncentiveMixin = {};

function WarmodeIncentiveMixin:OnEnter()
	local base, current, bonus = self:GetPercentages();

	if bonus > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, WAR_MODE_CALL_TO_ARMS);
		GameTooltip_AddNormalLine(GameTooltip, WAR_MODE_BONUS_INCENTIVE_TOOLTIP:format(bonus, current));
		GameTooltip:Show();
	end
end

function WarmodeIncentiveMixin:GetPercentages()
	local basePercentage = C_PvP.GetWarModeRewardBonusDefault();
	local currentPercentage = C_PvP.GetWarModeRewardBonus();
	return basePercentage, currentPercentage, currentPercentage - basePercentage;
end

function WarmodeIncentiveMixin:Update()
	local base, current, bonus = self:GetPercentages();
	self:SetShown(bonus > 0);
end
