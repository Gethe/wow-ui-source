---------------
--NOTE - Please do not change this section without talking to Dan
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);
end
---------------

ModifyOrbitCameraButtonMixin = {}

function ModifyOrbitCameraButtonMixin:OnMouseDown()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function ModifyOrbitCameraButtonMixin:OnMouseUp()
	self:SetScript("OnUpdate", nil);
end

function ModifyOrbitCameraButtonMixin:OnUpdate(elapsed)
	local orbitCamera = self:GetActiveOrbitCamera();
	if orbitCamera then
		orbitCamera:HandleMouseMovement(self.cameraMode, elapsed * self.amountPerSecond, not self.interpolationEnabled);
	end
end

function ModifyOrbitCameraButtonMixin:GetActiveOrbitCamera()
	local modelScene = self:GetParent();
	local camera = modelScene:GetActiveCamera();
	if camera and camera:GetCameraType() == "OrbitCamera" then
		return camera;
	end
end

WRAPPED_PRESENT_CREATURE_DISPLAY_ID = 71933;
WRAPPED_PRESENT_SPELL_VISUAL_KIT_ID = 73393;

WrappedModelSceneMixin = {};

function WrappedModelSceneMixin:IsUnwrapAnimating()
	return self.isUnwrapping;
end

function WrappedModelSceneMixin:NeedsFanfare()
	return self.needsFanFare;
end

function WrappedModelSceneMixin:OnShow()
	self:SetLightAmbientColor(self.normalIntensity, self.normalIntensity, self.normalIntensity);
end

function WrappedModelSceneMixin:OnMouseEnter()
	if self:NeedsFanfare() then
		self:SetLightAmbientColor(self.highlightIntensity, self.highlightIntensity, self.highlightIntensity);
	else
		self:SetLightAmbientColor(self.normalIntensity, self.normalIntensity, self.normalIntensity);
	end
end

function WrappedModelSceneMixin:OnMouseLeave()
	self:SetLightAmbientColor(self.normalIntensity, self.normalIntensity, self.normalIntensity);
end

function WrappedModelSceneMixin:PrepareForFanfare(needsFanFare)
	self.needsFanFare = needsFanFare;

	local wrappedActor = self:GetActorByTag("wrapped");
	if wrappedActor then
		wrappedActor:SetModelByCreatureDisplayID(WRAPPED_PRESENT_CREATURE_DISPLAY_ID);
		if self:NeedsFanfare() then
			wrappedActor:Show();
			if not self:IsUnwrapAnimating() then
				wrappedActor:SetAnimation(0);
				wrappedActor:SetAlpha(1);
			end
		else
			wrappedActor:Hide();
		end
	end
end

function WrappedModelSceneMixin:StartUnwrapAnimation(OnFinishedCallback)
	if not self:NeedsFanfare() or self:IsUnwrapAnimating() then
		return;
	end

	local wrappedActor = self:GetActorByTag("wrapped");

	if wrappedActor then
		self.isUnwrapping = true;
		self.needsFanFare = false;

		self.UnwrapAnim.WrappedAnim:SetTarget(wrappedActor);
		self.UnwrapAnim:Play();

		wrappedActor:SetAnimation(148);

		PlaySound(SOUNDKIT.UI_STORE_UNWRAP);

		C_Timer.After(0.8, function()
			for actor in self:EnumerateActiveActors() do
				actor:SetSpellVisualKit(WRAPPED_PRESENT_SPELL_VISUAL_KIT_ID, true);
			end
		end)

		C_Timer.After(3.0, function()
			self.isUnwrapping = nil;
			if OnFinishedCallback then
				OnFinishedCallback();
			end
		end)
	end
end

WrappedAndUnwrappedModelSceneMixin = CreateFromMixins(WrappedModelSceneMixin);

function WrappedAndUnwrappedModelSceneMixin:PrepareForFanfare(needsFanFare)
	self.needsFanFare = needsFanFare;

	local wrappedActor = self:GetActorByTag("wrapped");
	local unwrappedActor = self:GetActorByTag("unwrapped");
	if wrappedActor and unwrappedActor then
		wrappedActor:SetModelByCreatureDisplayID(WRAPPED_PRESENT_CREATURE_DISPLAY_ID);
		if self:NeedsFanfare() then
			wrappedActor:Show();
			if not self:IsUnwrapAnimating() then
				unwrappedActor:SetAlpha(0);
				wrappedActor:SetAnimation(0);
				wrappedActor:SetAlpha(1);
			end
		else
			wrappedActor:Hide();
			if not self:IsUnwrapAnimating() then
				unwrappedActor:SetAlpha(1);
			end
		end
	end
end

function WrappedAndUnwrappedModelSceneMixin:StartUnwrapAnimation(OnFinishedCallback)
	if not self:NeedsFanfare() or self:IsUnwrapAnimating() then
		return;
	end

	local wrappedActor = self:GetActorByTag("wrapped");
	local unwrappedActor = self:GetActorByTag("unwrapped");

	if unwrappedActor and wrappedActor then
		self.isUnwrapping = true;
		self.needsFanFare = false;

		self.UnwrapAnim.WrappedAnim:SetTarget(wrappedActor);
		self.UnwrapAnim.UnwrappedAnim:SetTarget(unwrappedActor);

		self.UnwrapAnim:Play();

		wrappedActor:SetAnimation(148);

		PlaySound(SOUNDKIT.UI_STORE_UNWRAP);

		C_Timer.After(.8, function()
			for actor in self:EnumerateActiveActors() do
				actor:SetSpellVisualKit(WRAPPED_PRESENT_SPELL_VISUAL_KIT_ID, true);
			end
		end)

		C_Timer.After(1.6, function()
			self.isUnwrapping = nil;
			if OnFinishedCallback then
				OnFinishedCallback();
			end
		end)
	end
end
