local function GetPreyHuntProgressVisInfoData(widgetID)
	local widgetInfo = C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo(widgetID);
	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
		return widgetInfo;
	end
end

UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.PreyHuntProgress, {frameType = "FRAME", frameTemplate = "UIWidgetTemplatePreyHuntProgress"}, GetPreyHuntProgressVisInfoData);

local ANIMS_WAIT_TIME = 0.5;	-- how many seconds to wait after the widget shows up before anims can play

local stateAtlases = {
	[Enum.PreyHuntProgressState.Cold] = "ui-prey-targeticon-regular",
	[Enum.PreyHuntProgressState.Warm] = "ui-prey-targeticon-inprogress",
	[Enum.PreyHuntProgressState.Hot] = "ui-prey-targeticon-final",
	[Enum.PreyHuntProgressState.Final] = "ui-prey-targeticon-final",
};

UIWidgetTemplatePreyHuntProgressMixin = CreateFromMixins(UIWidgetBaseTemplateMixin);

function UIWidgetTemplatePreyHuntProgressMixin:Setup(widgetInfo, widgetContainer)
	-- only want effect for final state
	if widgetInfo.progressState < Enum.PreyHuntProgressState.Final then
		widgetInfo.scriptedAnimationEffectID = 0;
	end
	UIWidgetBaseTemplateMixin:ApplyEffectToFrame(widgetInfo, widgetContainer, self);

	UIWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	local atlas = stateAtlases[widgetInfo.progressState];
	if atlas then
		self.StateTexture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end
	self:SetSize(self.StateTexture:GetSize());
	self:SetTooltip(widgetInfo.tooltip);

	if not self.startTime then
		self.startTime = GetTime();
	end

	if self.progressState and widgetInfo.progressState >= self.progressState then
		-- don't try to play anims to soon, prevents gain anim sometimes playing when the widget shows up
		local uptime = GetTime() - self.startTime;
		if uptime > ANIMS_WAIT_TIME then
			if self.progressState == widgetInfo.progressState then
				self:PlayGainProgressAnim();
			else
				self:PlayTransitionAnim();
			end
		end
	end

	self:SetMouseClickEnabled(widgetInfo.progressState == Enum.PreyHuntProgressState.Final);

	self.progressState = widgetInfo.progressState;
end

function UIWidgetTemplatePreyHuntProgressMixin:OnMouseDown()
	self.StateTexture:AdjustPointsOffset(2, -2);
end

function UIWidgetTemplatePreyHuntProgressMixin:OnMouseUp(_mouseButton, upInside)
	self.StateTexture:AdjustPointsOffset(-2, 2);

	if upInside then
		local questID = C_QuestLog.GetActivePreyQuest();
		if questID then
			local ignoreWaypoints = true;
			local mapID = GetQuestUiMapID(questID, ignoreWaypoints);
			OpenWorldMap(mapID);
			EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID);
		else
			-- this shouldn't happen, but just in case
			local mapID = C_Map.GetBestMapForUnit("player");
			OpenWorldMap(mapID);
		end
	end
end

function UIWidgetTemplatePreyHuntProgressMixin:OnEnter(...)
	UIWidgetBaseTemplateMixin.OnEnter(self, ...)
	if self.progressState == Enum.PreyHuntProgressState.Final then
		self.HighlightTexture:Show();
	end
end

function UIWidgetTemplatePreyHuntProgressMixin:OnLeave(...)
	UIWidgetBaseTemplateMixin.OnLeave(self, ...)
	self.HighlightTexture:Hide();
end

function UIWidgetTemplatePreyHuntProgressMixin:OnReset()
	UIWidgetBaseTemplateMixin.OnReset(self);
	self.progressState = nil;
	self.GainProgressAnim:Stop();
	self.ShineFrame.Anim:Stop();
	self.TransitionAnim:Stop();
	self.startTime = nil;
end

function UIWidgetTemplatePreyHuntProgressMixin:PlayGainProgressAnim()
	self.GainProgressAnim:Restart();
	self.ShineFrame.Anim:Restart();
end

function UIWidgetTemplatePreyHuntProgressMixin:PlayTransitionAnim()
	self.GainProgressAnim:Restart();
	self.ShineFrame.Anim:Restart();

	local priorAtlas = stateAtlases[self.progressState];
	self.PriorStateTexture:SetAtlas(priorAtlas, TextureKitConstants.UseAtlasSize);
	self.PriorStateTexture:SetAlpha(1);

	self.TransitionAnim:Restart();
end
