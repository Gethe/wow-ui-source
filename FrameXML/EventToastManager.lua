local textureKitRegionFormatStrings = {
	["BG1"] = "%s-TitleBG",
	["BG2"] = "%s-TitleBG",
}

local defaultAtlases = {
	["BG1"] = "legioninvasion-title-bg",
	["BG2"] = "legioninvasion-title-bg",
}

local eventToastTextureKitRegions = {
	["GLine"] = "levelup-bar-%s",
	["GLine2"] = "levelup-bar-%s",
}; 

local eventToastTemplatesByToastType = {
	[Enum.EventToastDisplayType.NormalSingleLine] = "EventToastManagerNormalSingleLineTemplate",
	[Enum.EventToastDisplayType.NormalBlockText] = "EventToastManagerNormalBlockTextTemplate",
	[Enum.EventToastDisplayType.NormalTitleAndSubTitle] = "EventToastManagerNormalTitleAndSubtitleTemplate",
	[Enum.EventToastDisplayType.NormalTextWithIcon] = "EventToastWithIconNormalTemplate",
	[Enum.EventToastDisplayType.LargeTextWithIcon] = "EventToastWithIconLargeTextTemplate",
	[Enum.EventToastDisplayType.NormalTextWithIconAndRarity] = "EventToastWithIconWithRarityTemplate",
	[Enum.EventToastDisplayType.Scenario] = "EventToastScenarioToastTemplate",
	[Enum.EventToastDisplayType.ChallengeMode] = "EventToastChallengeModeToastTemplate",
}

EventToastManagerMixin = { }
function EventToastManagerMixin:OnLoad()
	self.eventToastPools = CreateFramePoolCollection();
end

function EventToastManagerMixin:ReleaseToasts() 
	self.eventToastPools:ReleaseAll();
end 

--Override these functions in inherited mixins. 
function EventToastManagerMixin:ToastingEnded() 
end 

function EventToastManagerMixin:PlayAnim()
end 

function EventToastManagerMixin:HideAnimatedLines()
end 

function EventToastManagerMixin:SetAnimStartDelay(delay)

end 

EventToastManagerFrameMixin = CreateFromMixins(EventToastManagerMixin); 
function EventToastManagerFrameMixin:OnLoad()
	EventToastManagerMixin.OnLoad(self);
	
	self.PlayBanner = function(self)
		self:DisplayToast(true);
	end

	self.StopBanner = function(self)
		self:StopToasting();
	end
	self:RegisterEvent("DISPLAY_EVENT_TOASTS"); 
end

function EventToastManagerFrameMixin:OnEvent(event, ...)
	if(event == "DISPLAY_EVENT_TOASTS") then 
		TopBannerManager_Show(self, true);
	end 
end

function EventToastManagerFrameMixin:DisplayToastLink(chatFrame, link)
	if(not link or link == "") then 
		return;
	end 
	info = ChatTypeInfo["SYSTEM"];
	chatFrame:AddMessage(link, info.r, info.g, info.b, info.id);
end 

function EventToastManagerFrameMixin:SetAnimStartDelay(delay)
	self.GLine.grow.anim1:SetStartDelay(delay);
	self.GLine2.grow.anim1:SetStartDelay(delay);
	self.BlackBG.grow.anim1:SetStartDelay(delay);
end 


function EventToastManagerFrameMixin:ShouldShowAnimation(hidden)
	self.shouldAnim = not hidden; 
end 


function EventToastManagerFrameMixin:DisplayToast(firstToast) 
	self:ReleaseToasts();

	if(not firstToast) then 
		C_EventToastManager.RemoveCurrentToast(); 
	end 

	local toastInfo = C_EventToastManager.GetNextToastToDisplay(); 
	if(toastInfo) then 
		ZoneTextFrame:Hide();
		SubZoneTextFrame:Hide();

		local toastTemplate = eventToastTemplatesByToastType[toastInfo.displayType];
		if(not toastTemplate) then 
			return; 
		end 

		if not self.eventToastPools:GetPool(toastTemplate) then
			self.eventToastPools:CreatePool("FRAME", self, toastTemplate);
		end
		local toast = self.eventToastPools:Acquire(toastTemplate);
		self.shouldAnim = true; 
		toast:ClearAllPoints();
		toast:SetPoint("TOP", self);
		toast:Setup(toastInfo); 

		self:Show();
		self:PlayAnim();
	elseif(self:IsShown()) then 
		self:Hide();
		TopBannerManager_BannerFinished();
	end 
	self:Layout();
end 

function EventToastManagerFrameMixin:ToastingEnded() 
	self:DisplayToast(); 
end 

function EventToastManagerFrameMixin:DisplayNextToast()
	self.fastHide:Play();
end		

function EventToastManagerFrameMixin:PlayAnim()
	self.GLine.grow:Stop();
	self.GLine2.grow:Stop();
	self.BlackBG.grow:Stop();
	self.BlackBG:SetShown(self.shouldAnim); 
	self.GLine:SetShown(self.shouldAnim);
	self.GLine2:SetShown(self.shouldAnim);

	if(self.shouldAnim) then 
		self.GLine.grow:Play();
		self.GLine2.grow:Play();
		self.BlackBG.grow:Play();
	end
end 

function EventToastManagerFrameMixin:StopToasting()
	self.GLine.grow:Stop();
	self.GLine2.grow:Stop();
	self:Hide();
end 

EventToastManagerSideDisplayMixin = CreateFromMixins(EventToastManagerMixin);
function EventToastManagerSideDisplayMixin:OnLoad()
	EventToastManagerMixin.OnLoad(self);
end 

function EventToastManagerSideDisplayMixin:DisplayToastAtIndex(index)
	local toastInfo = self.toasts[index];
	if(not toastInfo) then
		return;
	end 
	self.currentlyDisplayingToastIndex = index; 
	local toastTemplate = eventToastTemplatesByToastType[toastInfo.displayType];
	if(not toastTemplate) then 
		return; 
	end 
	if not self.eventToastPools:GetPool(toastTemplate) then
		self.eventToastPools:CreatePool("FRAME", self, toastTemplate);
	end
	local toast = self.eventToastPools:Acquire(toastTemplate);
	if(not self.lastToastFrame) then 
		toast:SetPoint("TOPLEFT", self);
	else
		toast:SetPoint("TOP", self.lastToastFrame, "BOTTOM", 0, -10);
	end 
	self.lastToastFrame = toast; 
	toast.isSideDisplayToast = true; 
	toast:Setup(toastInfo); 
	self:Layout();  
end 

function EventToastManagerSideDisplayMixin:DisplayNextToast()
	self:DisplayToastAtIndex(self.currentlyDisplayingToastIndex + 1);
end 

function EventToastManagerSideDisplayMixin:DisplayToastsByLevel(level)
	self:ReleaseToasts();
	self.lastToastFrame = nil;
	self.toasts = C_EventToastManager.GetLevelUpDisplayToastsFromLevel(level);
	self.level = level;
	self:Show(); 
	self.fadeIn:Play();
end 

function EventToastManagerSideDisplayMixin:OnClick()
	if(self:IsShown()) then 
		self.fadeOut:Play();
	end 
end 

function EventToastManagerSideDisplayMixin:OnHide()
	if(self.eventToastPools) then 
		self.eventToastPools:ReleaseAll(); 
	end 
	self.lastToastFrame = nil;
	self.level = nil; 
end 

EventToastScenarioToastMixin = { }; 

function EventToastScenarioToastMixin:Setup(toastInfo)
	self.Title:SetText(toastInfo.title);
	self.Subtitle:SetText(toastInfo.subtitle);
	self.Description:SetText(toastInfo.instructionText);

	if(toastInfo.uiTextureKit) then 
		SetupTextureKitOnRegions(toastInfo.uiTextureKit, self, textureKitRegionFormatStrings, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	else
		SetupAtlasesOnRegions(self, defaultAtlases, true);
	end 

	self.WidgetContainer:UnregisterForWidgetSet();
	self.WidgetContainer:SetShown(toastInfo.uiWidgetSetID);
	if(toastInfo.uiWidgetSetID) then 
		self.WidgetContainer:RegisterForWidgetSet(toastInfo.uiWidgetSetID, DefaultWidgetLayout);
	end 

	self.uiTextureKit = toastInfo.uiTextureKit; 
	self.BannerFrame:Hide(); 

	if(self.animStartDelay) then 
		self:GetParent():SetAnimStartDelay(self.animStartDelay);
	else 
		self:GetParent():SetAnimStartDelay(0);
	end

	self:Show(); 
	self:PlayAnim(); 
	self:Layout(); 
end

function EventToastScenarioToastMixin:NewStageAnimationOnPlay()
	self.BG1:SetAlpha(0);
	self.BG2:SetAlpha(0);
	self.Title:SetTextColor(SCENARIO_STAGE_COLOR:GetRGB());
	self:GetParent():ShouldShowAnimation(self.hideParentAnim);
	self.BannerFrame:Show(); 
	self.BannerFrame.fadeIn:Play();
end 

function EventToastScenarioToastMixin:PlayAnim()
	if(self.uiTextureKit) then 
		self.NewStageTextureKit:Play(); 
	else 
		self.NewStage:Play(); 
		self:NewStageAnimationOnPlay(); 
	end 
end 

function EventToastScenarioToastMixin:OnAnimFinished()
	self.WidgetContainer:UnregisterForWidgetSet();
	self:GetParent():DisplayNextToast();
end 

EventToastWithIconBaseMixin = { }; 

function EventToastWithIconBaseMixin:Setup(toastInfo)
	self.Icon:SetTexture(toastInfo.iconFileID); 
	self.Name:SetText(toastInfo.title);
	self.SubText:SetText(toastInfo.subtitle);
	if(toastInfo.subIcon) then 
		self.SubIcon:SetAtlas(toastInfo.subIcon);
	end 
	self.SubIcon:SetShown(toastInfo.subIcon);
	self.InstructionalText:SetText(toastInfo.instructionText); 
	
	self.WidgetContainer:UnregisterForWidgetSet();
	self.WidgetContainer:SetShown(toastInfo.uiWidgetSetID);
	if(toastInfo.uiWidgetSetID) then 
		self.WidgetContainer:RegisterForWidgetSet(toastInfo.uiWidgetSetID, DefaultWidgetLayout);
		self.WidgetContainer:ClearAllPoints();
		if(toastInfo.instructionText ~= "") then
			self.WidgetContainer:SetPoint("TOP", self.InstructionalText, "BOTTOM", 0, -5);
		else
			self.WidgetContainer:SetPoint("TOP", self.Icon, "BOTTOM", 50, -20);
		end
	end 

	if(self.animStartDelay) then 
		self:GetParent():SetAnimStartDelay(self.animStartDelay);
	else 
		self:GetParent():SetAnimStartDelay(0);
	end
	self:Layout(); 
end 

function EventToastWithIconBaseMixin:PlayAnim()
	self.sideAnimIn:Stop(); 
	self.showAnim:Stop(); 
	if(self.isSideDisplayToast) then
		self.sideAnimIn:Play();
	else 
		self.showAnim:Play();
	end 
end 

function EventToastWithIconBaseMixin:OnAnimFinished()
	self.WidgetContainer:UnregisterForWidgetSet();
	self:GetParent():DisplayNextToast();
end 

EventToastWithIconNormalMixin = { };
function EventToastWithIconNormalMixin:Setup(toastInfo)
	EventToastWithIconBaseMixin.Setup(self, toastInfo); 
	self:Show(); 
	self:PlayAnim(); 
end 

EventToastWithIconLargeTextMixin = { };
function EventToastWithIconLargeTextMixin:Setup(toastInfo)
	EventToastWithIconBaseMixin.Setup(self, toastInfo); 
	self.Icon:ClearAllPoints();
	self.Icon:SetPoint("TOPLEFT", 0, -20);
	self:Show(); 
	self:PlayAnim(); 
end 

EventToastWithIconWithRarityMixin = { };
function EventToastWithIconWithRarityMixin:Setup(toastInfo)
	EventToastWithIconBaseMixin.Setup(self, toastInfo); 
	local quality = toastInfo.quality;

	if(toastInfo.qualityString) then 
		self.RarityValue:SetText(toastInfo.qualityString);
	end 

	if(quality) then 
		self.IconBorder:SetVertexColor(ITEM_QUALITY_COLORS[quality].color:GetRGB());
		self.RarityValue:SetTextColor(ITEM_QUALITY_COLORS[quality].color:GetRGB());
	end
	self.IconBorder:SetShown(quality);
	self.RarityValue:SetShown(toastInfo.qualityString); 
	self:Show(); 
	self:PlayAnim(); 
end 

EventToastChallengeModeToastMixin = { };
function EventToastChallengeModeToastMixin:Setup(toastInfo) 
	self.Title:SetText(toastInfo.title);
	self.SubTitle:SetText(toastInfo.subtitle);
	if(toastInfo.time) then 
		self.SubTitle:SetText(toastInfo.subtitle:format(SecondsToClock(toastInfo.time/1000, true)));
	else 
		self.SubTitle:SetText(toastInfo.subtitle);
	end 
	self:GetParent():ShouldShowAnimation(self.hideParentAnim);
	if(self.animStartDelay) then 
		self:GetParent():SetAnimStartDelay(self.animStartDelay);
	else 
		self:GetParent():SetAnimStartDelay(0);
	end
	self.BannerFrame:Hide(); 
	self:Show(); 
	self:PlayAnim(); 
end 

function EventToastChallengeModeToastMixin:PlayAnim() 
	self.challengeComplete:Play(); 
end 

function EventToastChallengeModeToastMixin:OnAnimationPlay()
	self:GetParent():PlayAnim();
	self.BannerFrame:Show(); 
	self.BannerFrame.fadeIn:Play();
end 

EventToastManagerNormalMixin = { };
function EventToastManagerNormalMixin:Setup(toastInfo) 
	self:GetParent():ShouldShowAnimation(self.hideParentAnim);

	if(self.animStartDelay) then 
		self:GetParent():SetAnimStartDelay(self.animStartDelay);
	else 
		self:GetParent():SetAnimStartDelay(0);
	end

	self.WidgetContainer:UnregisterForWidgetSet();
	self.WidgetContainer:SetShown(toastInfo.uiWidgetSetID);
	if(toastInfo.uiWidgetSetID) then 
		self.WidgetContainer:RegisterForWidgetSet(toastInfo.uiWidgetSetID, DefaultWidgetLayout);
	end 
end 

function EventToastManagerNormalMixin:PlayAnim() 
	self.sideAnim:Stop(); 
	self.levelUp:Stop(); 
	if(self.isSideDisplayToast) then
		self.sideAnim:Play();
	else
		self.levelUp:Play(); 
	end
end	 

function EventToastManagerNormalMixin:OnAnimFinished()
	self.WidgetContainer:UnregisterForWidgetSet();
	self:GetParent():DisplayNextToast();
end 

function EventToastManagerNormalMixin:AnchorWidgetFrame(frame)
	if (self.WidgetContainer:IsShown()) then 
		self.WidgetContainer:ClearAllPoints();
		self.WidgetContainer:SetPoint("TOP", frame, "BOTTOM", 0, -10);
	end
end 

EventToastManagerNormalTitleAndSubtitleMixin = CreateFromMixins(EventToastManagerNormalMixin);
function EventToastManagerNormalTitleAndSubtitleMixin:Setup(toastInfo) 
	self.Title:SetText(toastInfo.title);
	self.SubTitle:SetText(toastInfo.subtitle);
	self:AnchorWidgetFrame(self.SubTitle);
	self:Show(); 
	self:PlayAnim(); 
	self:Layout(); 
end 

EventToastManagerNormalSingleLineMixin = CreateFromMixins(EventToastManagerNormalMixin);
function EventToastManagerNormalSingleLineMixin:Setup(toastInfo) 
	self.SingleLine:SetText(toastInfo.title);
	self:AnchorWidgetFrame(self.SingleLine);
	self:Show(); 
	self:PlayAnim(); 
	self:Layout(); 
end 

EventToastManagerNormalBlockTextMixin = CreateFromMixins(EventToastManagerNormalMixin);
function EventToastManagerNormalBlockTextMixin:Setup(toastInfo) 
	self.BlockText:SetText(toastInfo.title);
	self:AnchorWidgetFrame(self.BlockText);
	self:Show(); 
	self:PlayAnim(); 
	self:Layout(); 
end 