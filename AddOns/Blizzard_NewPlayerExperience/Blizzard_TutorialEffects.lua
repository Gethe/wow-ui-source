NPE_TutorialButtonPulseGlow = {};

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialButtonPulseGlow:Show(button)
	if not self.framePool then
		self.framePool = CreateFramePool("FRAME", nil, "NPE_TutorialButtonPulseGlowTemplate");
	end

	local frame = self:GetExisting(button);
	if frame then
		return;
	end

	frame = self.framePool:Acquire();
	frame.button = button;
	frame:SetParent(button);
	frame:ClearAllPoints();
	frame:SetFrameStrata("DIALOG");
	frame:SetPoint("LEFT", button, -12, 0);
	frame:SetPoint("RIGHT", button, 12, 0);
	UIFrameFlash(frame, 1, 1, -1);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialButtonPulseGlow:Hide(button)
	local frame = self:GetExisting(button);
	if frame then
		UIFrameFlashStop(frame);
		self.framePool:Release(frame);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialButtonPulseGlow:GetExisting(button)
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
NPE_TutorialSpellDrag = {};
function NPE_TutorialSpellDrag:Show(spellButton, actionButton)
	local originFrame = NPE_TutorialSpellDragOriginFrame;
	originFrame:SetParent(spellButton);
	originFrame:SetPoint("CENTER");
	originFrame:Show();

	local targetFrame = NPE_TutorialSpellDragTargetFrame;
	targetFrame:SetParent(actionButton:GetParent());
	targetFrame:SetPoint("CENTER", actionButton);
	targetFrame:Show();

	local slot = SpellBook_GetSpellBookSlot(spellButton);
	local texture;
	if spellButton.spellID then -- the data is set if this is from a flyout spell button
		texture = GetSpellTexture(spellButton.spellID);
	else
		texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	end
	local animFrame = NPE_TutorialSpellDragAnimationFrame;
	animFrame.Icon:SetTexture(texture);
	animFrame:SetParent(spellButton);
	animFrame:SetPoint("CENTER");
	animFrame:Show();

	animFrame.Anim:Stop();
	local ox, oy = spellButton:GetCenter();
	local tx, ty = actionButton:GetCenter();
	animFrame.Anim.Move:SetOffset(tx - ox, ty - oy);
	animFrame.Anim:Play();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialSpellDrag:Hide()
	NPE_TutorialSpellDragOriginFrame:Hide();
	NPE_TutorialSpellDragTargetFrame:Hide();
	NPE_TutorialSpellDragAnimationFrame:Hide();
end