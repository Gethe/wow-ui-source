local animaPinTextureKitRegions = {
	[Enum.AnimaDiversionNodeState.Unavailable] = "AnimaChannel-Icon-%s-Normal",
	[Enum.AnimaDiversionNodeState.Available] = "AnimaChannel-Icon-%s-Select",
	[Enum.AnimaDiversionNodeState.SelectedTemporary] = "AnimaChannel-Icon-%s-Ready",
	[Enum.AnimaDiversionNodeState.SelectedPermanent] = "AnimaChannel-Icon-%s-Ready",
	[Enum.AnimaDiversionNodeState.Cooldown] = "AnimaChannel-Icon-%s-Normal",
};

local reinforceNodeTextureKitAnimationEffectId = {
	["Kyrian"] = 22,
	["NightFae"] = 28,
	["Venthyr"] = 25,
	["Necrolord"] = 31, 
}; 

local animaConnectionShowBlackLink = { 
	["Venthyr"] = true,
	["Necrolord"] = true, 
}; 

local ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS = {
	"ANIMA_DIVERSION_TALENT_UPDATED",
	"CURRENCY_DISPLAY_UPDATE",
	"GARRISON_TALENT_COMPLETE",
	"GARRISON_TALENT_EVENT_UPDATE",
	"GARRISON_TALENT_UNLOCKS_RESULT",
};

local ANIMA_DIVERSION_ORIGIN_PIN_BORDER = "AnimaChannel-Icon-Device-%s-Border";
local ANIMA_DIVERSION_LINK_TEXTURE = "animachannel-link-anima-%s";
local ANIMA_DIVERSION_LINE_TEXTURE = "_AnimaChannel-Channel-Line-horizontal-%s";
local ANIMA_SELECTION_MODEL_EFFECT_ID = 35;

AnimaDiversionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AnimaDiversionDataProviderMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS);
end 

function AnimaDiversionDataProviderMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS);
	self:ResetModelScene();
end 

function AnimaDiversionDataProviderMixin:OnEvent(event, ...)
	self:RefreshAllData(); 
end 

function AnimaDiversionDataProviderMixin:SetupConnectionOnPin(pin)
	local connection = self.connectionPool:Acquire();
	connection:Setup(self.textureKit, self.origin, pin);
	connection:Show();

	self.origin.IconBorder:Show();
end

function AnimaDiversionDataProviderMixin:ResetModelScene()
	if self.modelScenePin then
		self.modelScenePin.ModelScene:ClearEffects();
		self.modelScenePin = nil;
	end

	self.pinEffects = {};
end

function AnimaDiversionDataProviderMixin:AddEffectOnPin(effectID, pin, permanent)
	if self.modelScenePin then
		if not self.pinEffects[pin] then
			self.pinEffects[pin] = {};
		end

		if not self.pinEffects[pin][effectID] then
			local pinEffect = self.modelScenePin.ModelScene:AddEffect(effectID, pin, pin);
			self.pinEffects[pin][effectID] = {effect = pinEffect, temporary =  not permanent};
		end
	end
end

function AnimaDiversionDataProviderMixin:ClearEffectOnPin(effectID, pin, onlyTemporaryEffects)
	if self.modelScenePin then
		if self.pinEffects[pin] and self.pinEffects[pin][effectID] then
			if not onlyTemporaryEffects or self.pinEffects[pin][effectID].temporary then
				self.pinEffects[pin][effectID].effect:CancelEffect();
				self.pinEffects[pin][effectID] = nil;
			end
		end
	end
end

function AnimaDiversionDataProviderMixin:ClearEffectOnAllPins(effectID, onlyTemporaryEffects, exemptPin)
	if self.modelScenePin then
		for pin, _ in pairs(self.pinEffects) do
			if pin ~= exemptPin then
				self:ClearEffectOnPin(effectID, pin, onlyTemporaryEffects);
			end
		end
	end
end

function AnimaDiversionDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AnimaDiversionPinTemplate");

	self:ResetModelScene();
	self:GetMap():RemoveAllPinsByTemplate("AnimaDiversionModelScenePinTemplate");
end

function AnimaDiversionDataProviderMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	self.bolsterProgress = C_AnimaDiversion.GetReinforceProgress();

	if not self.connectionPool then
		self.connectionPool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "AnimaDiversionConnectionTemplate");
	else
		self.connectionPool:ReleaseAll(); 
	end

	self.textureKit = C_AnimaDiversion.GetTextureKit();

	self:AddModelScene();

	local originPosition = C_AnimaDiversion.GetOriginPosition();
	if not originPosition then
		return;
	end

	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	if not animaNodes then 
		return;
	end 

	self:AddOrigin(originPosition);

	local hasAnyChanneledNodes = false;
	for _, nodeData in ipairs(animaNodes) do
		local wasChanneled = self:AddNode(nodeData);

		if wasChanneled then
			hasAnyChanneledNodes = true;
		end
	end
end

function AnimaDiversionDataProviderMixin:AddNode(nodeData)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");

	pin:SetPosition(nodeData.normalizedPosition.x, nodeData.normalizedPosition.y);
	pin.nodeData = nodeData;
	pin.owner = self;
	pin.textureKit = self.textureKit;
	pin:SetSize(150,175);
	pin:SetupNode();

	if pin:IsConnected() then
		self:SetupConnectionOnPin(pin);
		return true;
	end
end

function AnimaDiversionDataProviderMixin:AddOrigin(position)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");

	pin:SetPosition(position.x, position.y);
	pin.nodeData = nil;
	pin.owner = self; 
	pin.textureKit = self.textureKit;
	pin:SetSize(175,175); 
	pin:SetupOrigin();

	self.origin = pin; 
end 

function AnimaDiversionDataProviderMixin:AddModelScene()
	local pin = self:GetMap():AcquirePin("AnimaDiversionModelScenePinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.modelScenePin = pin; 
	local width = self:GetMap():DenormalizeHorizontalSize(1.0); 
	local height = self:GetMap():DenormalizeVerticalSize(1.0);
	pin:SetSize(width, height);
	pin.ModelScene:SetSize(width, height);
	pin.ModelScene:SetFrameLevel(1000);
	pin.ModelScene:RefreshModelScene();
end 

AnimaDiversionModelScenePinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionModelScenePinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_MODELSCENE_PIN");
end 

AnimaDiversionPinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_PIN");
	self:SetNudgeSourceRadius(1);

	-- This map doesn't zoom so set them both the same.
	local zoomedInNudge = 4;
	local zoomedOutNudge = zoomedInNudge;
	self:SetNudgeSourceMagnitude(zoomedInNudge, zoomedOutNudge);
end 

function AnimaDiversionPinMixin:SetupOrigin()
	self.visualState = nil;
	self.Icon:SetAtlas("AnimaChannel-Icon-Device", TextureKitConstants.UseAtlasSize);
	self.Icon:SetDesaturated(false);
	SetupTextureKitOnFrame(self.textureKit, self.IconBorder, ANIMA_DIVERSION_ORIGIN_PIN_BORDER, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	self.IconBorder:Hide();
	self.IconDisabledOverlay:Hide();
	self:Show();
end 

function AnimaDiversionPinMixin:IsConnected() 
	return AnimaDiversionUtil.IsNodeActive(self.nodeData.state);
end 

function AnimaDiversionPinMixin:SetupNode()
	local useState = self.nodeData.state;
	
	if self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent then
		local permanent = true;
		self:SetReinforceState(true, permanent);
	elseif self.owner:CanReinforceNode() then
		if self.nodeData.state ~= Enum.AnimaDiversionNodeState.Unavailable then
			useState = Enum.AnimaDiversionNodeState.Available;
			self:SetReinforceState(true);
		end
	elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Available then
		self:SetSelectedState(true, true);
	end

	local worldQuestID = C_Garrison.GetTalentUnlockWorldQuest(self.nodeData.talentID);
	if worldQuestID then
		-- prime the data;
		HaveQuestRewardData(worldQuestID);
	end

	self:SetVisualState(useState);
	self.IconBorder:Hide();

	self:Show();
end 

function AnimaDiversionPinMixin:SetVisualState(state)
	self.visualState = state;
	SetupTextureKitOnFrame(self.textureKit, self.Icon, animaPinTextureKitRegions[state], TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(self.textureKit, self.IconDisabledOverlay, animaPinTextureKitRegions[state], TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	if state == Enum.AnimaDiversionNodeState.Unavailable then
		self.IconDisabledOverlay:SetVertexColor(0, 0, 0, 0.4);
		self.IconDisabledOverlay:Show();
		self.Icon:SetDesaturated(true);
	else
		self.IconDisabledOverlay:Hide();
		self.Icon:SetDesaturated(false);
	end
end

function AnimaDiversionPinMixin:SetReinforceState(reinforce, permanent) 
	if reinforce then
		self.owner:AddEffectOnPin(reinforceNodeTextureKitAnimationEffectId[self.textureKit], self, permanent);
	else
		self.owner:ClearEffectOnPin(reinforceNodeTextureKitAnimationEffectId[self.textureKit], self);
	end
end 

function AnimaDiversionPinMixin:SetSelectedState(selected, leaveOtherSelections)
	if selected then
		local onlyTemporaryEffects = true;
		self.owner:ClearEffectOnAllPins(reinforceNodeTextureKitAnimationEffectId[self.textureKit], onlyTemporaryEffects, self);

		if not leaveOtherSelections then
			self.owner:ClearEffectOnAllPins(ANIMA_SELECTION_MODEL_EFFECT_ID, onlyTemporaryEffects, self);
		end

		self.owner:AddEffectOnPin(ANIMA_SELECTION_MODEL_EFFECT_ID, self);
	else
		self.owner:ClearEffectOnPin(ANIMA_SELECTION_MODEL_EFFECT_ID, self);
	end
end 

function AnimaDiversionPinMixin:OnMouseEnter() 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:RefreshTooltip();
end

function AnimaDiversionPinMixin:HaveEnoughAnimaToActivate()
	local talentInfo = self.nodeData and self.nodeData.talentID and C_Garrison.GetTalentInfo(self.nodeData.talentID);

	local animaCurrencyID = C_CovenantSanctumUI.GetAnimaInfo()
	local animaCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(animaCurrencyID);

	if talentInfo and animaCurrencyInfo then
		for _, researchCostInfo in ipairs(talentInfo.researchCurrencyCosts) do
			if researchCostInfo.currencyType == animaCurrencyID then
				if animaCurrencyInfo.quantity < researchCostInfo.currencyQuantity then 
					return false;
				else
					return true;
				end
			end
		end

		return true;
	end

	return false;
end 

function AnimaDiversionPinMixin:RefreshTooltip()
	GameTooltip:ClearLines();
	self.UpdateTooltip = nil;

	if not self.nodeData then -- If we are the origin pin we want to show a special tooltip. 
		GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_ORIGIN_TOOLTIP);
	else
		GameTooltip_AddNormalLine(GameTooltip, self.nodeData.name);
		GameTooltip_AddHighlightLine(GameTooltip, self.nodeData.description);
		if self.nodeData.state == Enum.AnimaDiversionNodeState.Unavailable then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NODE_UNAVAILABLE);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Cooldown and not self.owner:CanReinforceNode() then
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NODE_COOLDOWN);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, ANIMA_DIVERSION_POI_REINFORCED, GREEN_FONT_COLOR);
		elseif self.nodeData.state == Enum.AnimaDiversionNodeState.Available then 
			local notEnoughAnima = not self:HaveEnoughAnimaToActivate();

			local talentInfo = C_Garrison.GetTalentInfo(self.nodeData.talentID);
			if talentInfo then
				local abbreviateCost = false;
				local colorCode = notEnoughAnima and RED_FONT_COLOR_CODE or nil;
				local costString = GetGarrisonTalentCostString(talentInfo, abbreviateCost, colorCode);
				if costString then
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddHighlightLine(GameTooltip, costString);
				end
			end

			if notEnoughAnima then
				GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NOT_ENOUGH_CURRENCY);
			else
				GameTooltip_AddColoredLine(GameTooltip, ANIMA_DIVERSION_CLICK_CHANNEL, GREEN_FONT_COLOR);
			end
		end
		local worldQuestID = C_Garrison.GetTalentUnlockWorldQuest(self.nodeData.talentID);
		if worldQuestID then
			GameTooltip_AddQuestRewardsToTooltip(GameTooltip, worldQuestID);
			if not HaveQuestRewardData(worldQuestID) then
				self.UpdateTooltip = self.RefreshTooltip;
			end
		end
	end 

	GameTooltip:Show(); 
end

function AnimaDiversionPinMixin:OnMouseLeave() 
	GameTooltip:Hide();
end

function AnimaDiversionPinMixin:OnClick(button) 
	if not self.nodeData then -- If we are the origin pin, don't do anything.
		return;
	end 

	if AnimaDiversionFrame.disallowSelection or button ~= "LeftButton" then	-- if selection is disabled or they didn't use left button, don't do anything.
		return;
	end

	if self.owner:CanReinforceNode() then 
		if self.nodeData.state == Enum.AnimaDiversionNodeState.Unavailable or self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent then 
			return;
		end

		AnimaDiversionFrame.ReinforceInfoFrame:SelectNodeToReinforce(self);
	else
		if self.nodeData.state == Enum.AnimaDiversionNodeState.Available and self:HaveEnoughAnimaToActivate() then 
			StaticPopup_Show("ANIMA_DIVERSION_CONFIRM_CHANNEL", self.nodeData.name, nil, self);
		end
	end
end

AnimaDiversionConnectionMixin = {}

function AnimaDiversionConnectionMixin:Setup(textureKit, origin, pin)
		-- Anchor straight up from the origin
	self:SetPoint("BOTTOM", origin, "CENTER");

	-- Then adjust the height to be the length from origin to pin
	local length = RegionUtil.CalculateDistanceBetween(origin, pin) * origin:GetEffectiveScale();
	self:SetHeight(length);

	-- And finally rotate all the textures around the origin so they line up
	local quarter = (math.pi / 2);
	local angle = RegionUtil.CalculateAngleBetween(origin, pin) - quarter;
	self:RotateTextures(angle, 0.5, 0);

	self.Line:SetStartPoint("CENTER", origin);
	self.Line:SetEndPoint("CENTER", pin);

	local lineThickness = (pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary) and 20 or 40;
	self.Line:SetThickness(lineThickness);

	SetupTextureKitOnFrame(textureKit, self.Line, ANIMA_DIVERSION_LINE_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(textureKit, self.AnimaLink1, ANIMA_DIVERSION_LINK_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	SetupTextureKitOnFrame(textureKit, self.AnimaLink2, ANIMA_DIVERSION_LINK_TEXTURE, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	self.AnimaLinkBlack:SetShown(animaConnectionShowBlackLink[textureKit]);

	self.Mask:SetShown(pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary);

	for _, animationGroup in ipairs(self.animationGroups) do
		animationGroup:Play();
	end
end
