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
	self:CheckVisibilityForActiveScene();
end

function ClientSceneVisManagerMixin:OnEvent(event, ...)
	self:CheckVisibilityForActiveScene();
end

function ClientSceneVisManagerMixin:CheckVisibilityForActiveScene()
	local hasActiveSceneOfDesiredType = C_ClientScene.IsSceneTypeActive(Enum.ClientSceneType.MinigameSceneType);
	if hasActiveSceneOfDesiredType then
		UIModeUtil.SetModeActive("ClientScene", true);
	else
		UIModeUtil.SetModeActive("ClientScene", false);
	end
end
