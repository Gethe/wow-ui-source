local Mode =
{
	Fixed = 1,
	Rotated = 2,
};

local ModeData =
{
	[Mode.Fixed] = {
		frame = "UI-HUD-Minimap-Frame",
		mask = "ui-hud-minimap-frame-generic-mask",
	};

	[Mode.Rotated] = {
		frame = "UI-HUD-Minimap-Frame-Pointer",
		mask = "ui-hud-minimap-frame-generic-mask",
		underlay = "UI-HUD-Minimap-Frame-Circle",
	};
};

CVarCallbackRegistry:SetCVarCachable("rotateMinimap");

local function UpdateMinimapConfig()
	local rotateMinimap = CVarCallbackRegistry:GetCVarValueBool("rotateMinimap");
	local mode = rotateMinimap and Mode.Rotated or Mode.Fixed;
	local data = ModeData[mode];

	local atlasInfo = C_Texture.GetAtlasInfo(data.frame);
	local w, h = atlasInfo.width, atlasInfo.height;
	local minimapContainer = MinimapCluster.MinimapContainer;
	minimapContainer:SetSize(w, h);

	local minimap = minimapContainer.Minimap;
	minimap:SetMaskTexture(data.mask);

	MinimapBackdrop:SetSize(w, h);

	MinimapCompassTexture:SetAtlas(data.frame);
	MinimapCompassTexture:SetSize(w, h);

	-- The rotated implementation utilizes an underlay to achieve the effect of having
	-- the directional indicator rotated around a fixed circular frame.
	if data.underlay then
		MinimapCompassTextureUnderlay:SetAtlas(data.underlay);
		MinimapCompassTextureUnderlay:SetSize(w, h);
		MinimapCompassTextureUnderlay:Show();
	else
		MinimapCompassTextureUnderlay:Hide();
	end
end

do
	CVarCallbackRegistry:RegisterCallback("rotateMinimap", function()
		UpdateMinimapConfig();
	end);

	UpdateMinimapConfig();
end
