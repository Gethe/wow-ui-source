QuestSessionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function QuestSessionDataProviderMixin:OnShow()
	self:RegisterEvent("QUEST_SESSION_JOINED");
	self:RegisterEvent("QUEST_SESSION_LEFT");
end

function QuestSessionDataProviderMixin:OnHide()
	self:UnregisterEvent("QUEST_SESSION_JOINED");
	self:UnregisterEvent("QUEST_SESSION_LEFT");
end

function QuestSessionDataProviderMixin:OnEvent()
	self:GetMap():ForceRefreshDetailLayers();
	self:GetMap():RefreshAll(true);
end