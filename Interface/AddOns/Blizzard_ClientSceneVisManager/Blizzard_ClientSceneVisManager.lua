UIModeUtil.RegisterMode("ClientScene", {
	rolesetBlocklist = {
		"unitFrames",
		"cooldownViewers",
	},
});

ClientSceneVisManagerMixin = {};

function ClientSceneVisManagerMixin:OnLoad()
	self:RegisterEvent("CLIENT_SCENE_OPENED");
	self:RegisterEvent("CLIENT_SCENE_CLOSED");
end

function ClientSceneVisManagerMixin:OnEvent(event, ...)
	if (event == "CLIENT_SCENE_OPENED") then
		local sceneType = ...;
		self:OnClientSceneOpened(sceneType);
	elseif (event == "CLIENT_SCENE_CLOSED") then
		self:OnClientSceneClosed(nil);
	end
end

function ClientSceneVisManagerMixin:OnClientSceneOpened(sceneType)
	if sceneType == Enum.ClientSceneType.MinigameSceneType then
		UIModeUtil.SetModeActive("ClientScene", true);
	else
		UIModeUtil.SetModeActive("ClientScene", false);
	end
end

function ClientSceneVisManagerMixin:OnClientSceneClosed()
	UIModeUtil.SetModeActive("ClientScene", false);
end
