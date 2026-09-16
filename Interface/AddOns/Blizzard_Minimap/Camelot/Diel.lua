local DielFrameData =
{
	BorderAtlas = "UI-HUD-Minimap-Frame-Cycle",
	DayAtlas = "UI-HUD-Minimap-DayCycle",
	NightAtlas = "UI-HUD-Minimap-NightCycle",
	AnchorX = 63,
	AnchorY = 72,
};

local function SetDielCycleIndicator(isDayTime)
	local atlas = isDayTime and DielFrameData.DayAtlas or DielFrameData.NightAtlas;
	local atlasInfo = C_Texture.GetAtlasInfo(atlas);
	local background = MinimapCluster.DielFrame.Background;
	background:SetSize(atlasInfo.width, atlasInfo.height);
	background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

local function CreateDielCycleFrame()
	local dielFrame = CreateFrame("Frame", nil, MinimapCluster);
	MinimapCluster.DielFrame = dielFrame;

	-- Prevent this overlay from inflating MinimapCluster's ResizeLayoutFrame bounds.
	dielFrame.ignoreInLayout = true;

	local atlasInfo = C_Texture.GetAtlasInfo(DielFrameData.BorderAtlas);
	dielFrame:SetSize(atlasInfo.width, atlasInfo.height);

	-- Elevated so the minimap arrow can pass below it when it rotated mode.
	dielFrame:SetFrameLevel(5);
	dielFrame:RegisterEvent("DIEL_CYCLE_CHANGED")
	dielFrame:SetScript("OnEvent", function(frame, event, ...)
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
end

local originalSetEditModeScale = MinimapCluster.SetEditModeScale;
local function SetEditModeScale(minimapCluster, scale)
	local dielFrame = minimapCluster.DielFrame;
	dielFrame:SetScale(math.max(1.0, scale));

	if scale >= 1.0 then
		-- No position change required for >= 1.0 scale
		dielFrame:SetPoint("CENTER", DielFrameData.AnchorX, DielFrameData.AnchorY);
	else
		-- As the scale decreases from zero, the position needs to change to keep the
		-- diel frame aligned.
		local scaledX = DielFrameData.AnchorX * scale;
		local scaledY = DielFrameData.AnchorY * scale;
		dielFrame:SetPoint("CENTER", scaledX, scaledY);
	end

	originalSetEditModeScale(minimapCluster, scale);
end

do
	MinimapCluster.SetEditModeScale = SetEditModeScale;
	
	CreateDielCycleFrame();

	SetDielCycleIndicator(C_DateAndTime.IsDayTime());
end
