local DielFrameData =
{
	BorderAtlas = "UI-HUD-Minimap-Frame-Cycle",
	DayAtlas = "UI-HUD-Minimap-DayCycle",
	NightAtlas = "UI-HUD-Minimap-NightCycle",
	AnchorX = 55,
	AnchorY = 86,
};

local DIEL_MINIMAP_INSET_ID = "CamelotDielFrame";
local DIEL_MINIMAP_INSET_DISTANCE_SCALAR = 0.88;

local function SetDielFrameTransform()
	local appliedScale = MinimapCluster.MinimapContainer:GetScale();
	local invScale = 1.0 / appliedScale;

	local dielFrame = MinimapCluster.DielFrame;
	local isCircularInset = true;

	dielFrame:SetScale(invScale);
	dielFrame:ClearAllPoints();
	dielFrame:SetPoint("CENTER", DielFrameData.AnchorX * appliedScale, DielFrameData.AnchorY * appliedScale);
	MinimapUtil.UpdateInsetForFrame(
		dielFrame,
		DIEL_MINIMAP_INSET_ID,
		DIEL_MINIMAP_INSET_DISTANCE_SCALAR,
		isCircularInset
	);
end

local function SetDielCycleIndicator(isDayTime)
	local atlas = isDayTime and DielFrameData.DayAtlas or DielFrameData.NightAtlas;
	local atlasInfo = C_Texture.GetAtlasInfo(atlas);
	local background = MinimapCluster.DielFrame.Background;
	background:SetSize(atlasInfo.width, atlasInfo.height);
	background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

local function CreateDielCycleFrame()
	local parent = MinimapCluster.MinimapContainer;
	local dielFrame = CreateFrame("Frame", nil, parent);
	MinimapCluster.DielFrame = dielFrame;

	-- Prevent this overlay from inflating MinimapCluster's ResizeLayoutFrame bounds.
	dielFrame.ignoreInLayout = true;

	local atlasInfo = C_Texture.GetAtlasInfo(DielFrameData.BorderAtlas);
	dielFrame:SetSize(atlasInfo.width, atlasInfo.height);
	dielFrame:SetPoint("CENTER", DielFrameData.AnchorX, DielFrameData.AnchorY);

	-- Elevated so the minimap arrow can pass below it when in rotated mode.
	dielFrame:SetFrameLevel(5);
	dielFrame:RegisterEvent("DIEL_CYCLE_CHANGED");
	dielFrame:SetScript("OnEvent", function(_frame, event, ...)
		if event == "DIEL_CYCLE_CHANGED" then
			local isDayTime = ...;
			SetDielCycleIndicator(isDayTime);
		end
	end);

	local background = dielFrame:CreateTexture(nil, "BACKGROUND", nil, 0);
	dielFrame.Background = background;
	background:SetPoint("CENTER");

	local border = dielFrame:CreateTexture(nil, "OVERLAY", nil, 1);
	border:SetAllPoints();
	border:SetAtlas(DielFrameData.BorderAtlas, TextureKitConstants.UseAtlasSize);

	EventRegistry:RegisterCallback("Minimap.OnScaleUpdated", SetDielFrameTransform, dielFrame);
end

do
	CreateDielCycleFrame();
	SetDielCycleIndicator(C_DateAndTime.IsDayTime());
	SetDielFrameTransform();
end
