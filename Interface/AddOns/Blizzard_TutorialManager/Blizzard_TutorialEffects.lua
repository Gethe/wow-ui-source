

-- ------------------------------------------------------------------------------------------------------------
TutorialQuestBangGlow = {};
function TutorialQuestBangGlow:Show(button)
	if not self.framePool then
		self.framePool = CreateFramePool("FRAME", nil, "TutorialQuestBangGlowTemplate");
	end

	local frame = self:GetExisting(button);
	if frame then
		return;
	end
	local icon = button.Icon;
	frame = self.framePool:Acquire();
	frame.button = button;
	frame:SetParent(button);
	frame:ClearAllPoints();
	frame:SetFrameStrata("DIALOG");
	frame:SetPoint("CENTER", icon, 0, 0);
	frame.GlowAnim:Play();
	frame:Show();
end

function TutorialQuestBangGlow:Hide(button)
	local frame = self:GetExisting(button);
	if frame then
		frame.GlowAnim:Stop();
		self.framePool:Release(frame);
	end
end

function TutorialQuestBangGlow:GetExisting(button)
	if not self.framePool then
		return;
	end
	for frame in self.framePool:EnumerateActive() do
		if frame.button == button then
			return frame;
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
TutorialDragButton = {};
function TutorialDragButton:Show(originButton, destButton)
	self:Hide();
	Dispatcher:RegisterEvent("OnUpdate", self);

	local texture;
	if originButton.icon then
		texture = originButton.icon:GetTexture();
	elseif originButton.spellID then
		texture = C_Spell.GetSpellTexture(originButton.spellID);
	elseif originButton.GetTexture then
		texture = originButton:GetTexture();
	end

	local dragButton = originButton.DragButton or originButton;
	if originButton.GetDragTarget then
		dragButton = originButton:GetDragTarget();
	end

	local originFrame = TutorialDragOriginFrame;
	originFrame:SetParent(dragButton);
	originFrame:SetPoint("CENTER");
	originFrame:Show();

	local targetFrame = TutorialDragTargetFrame;
	targetFrame:SetParent(destButton:GetParent());
	targetFrame:SetPoint("CENTER", destButton);
	targetFrame:Show();

	local animFrame = TutorialDragAnimationFrame;
	animFrame.Icon:SetTexture(texture);
	
	animFrame:SetParent(UIParent);
	animFrame:SetFrameStrata("DIALOG");
	animFrame:ClearAllPoints();
	animFrame:SetPoint("CENTER", dragButton);
	animFrame:Show();

	self.originFrame = dragButton;
	self.destFrame = destButton;
	self:Animate();
end

function TutorialDragButton:Animate()
	local animFrame = TutorialDragAnimationFrame;
	animFrame.Anim:Stop();

	-- originFrame, destFrame, and animFrame may all have different scales depending on what they're parented to
	-- So for accurate visuals, get scaled center values
	self.ox, self.oy = GetScaledCenter(self.originFrame);
	self.tx, self.ty = GetScaledCenter(self.destFrame);

	local animFrameScale = animFrame:GetEffectiveScale();

	-- Now calculate absolute offsets and account for animFrame's scale,
	-- since that's what its Translate anim will operate relative to
	local xOffset = (self.tx - self.ox)/animFrameScale;
	local yOffset = (self.ty - self.oy)/animFrameScale;

	animFrame.Anim.Move:SetOffset(xOffset, yOffset);
	animFrame.Anim:Play();
end

function TutorialDragButton:OnUpdate()
	local ox, oy = GetScaledCenter(self.originFrame);
	local tx, ty = GetScaledCenter(self.destFrame);

	if (ox ~= self.ox) or (oy ~= self.oy) or (tx ~= self.tx) or (ty ~= self.ty) then
		self:Animate();
	end
end

function TutorialDragButton:Hide()
	Dispatcher:UnregisterEvent("OnUpdate", self);
	TutorialDragOriginFrame:Hide();
	TutorialDragTargetFrame:Hide();
	TutorialDragAnimationFrame:Hide();
end
-- ------------------------------------------------------------------------------------------------------------