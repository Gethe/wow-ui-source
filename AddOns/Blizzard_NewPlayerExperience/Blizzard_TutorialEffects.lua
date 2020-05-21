

-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialQuestBangGlow = {};
function NPE_TutorialQuestBangGlow:Show(button)
	if not self.framePool then
		self.framePool = CreateFramePool("FRAME", nil, "NPE_TutorialQuestBangGlowTemplate");
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

function NPE_TutorialQuestBangGlow:Hide(button)
	local frame = self:GetExisting(button);
	if frame then
		frame.GlowAnim:Stop();
		self.framePool:Release(frame);
	end
end

function NPE_TutorialQuestBangGlow:GetExisting(button)
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


-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialButtonPulseGlow = {};
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

function NPE_TutorialButtonPulseGlow:Hide(button)
	local frame = self:GetExisting(button);
	if frame then
		UIFrameFlashStop(frame);
		self.framePool:Release(frame);
	end
end

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

-- ------------------------------------------------------------------------------------------------------------
NPE_TutorialDragButton = {};
function NPE_TutorialDragButton:Show(originButton, destButton)
	local originFrame = NPE_TutorialDragOriginFrame;
	originFrame:SetParent(originButton);
	originFrame:SetPoint("CENTER");
	originFrame:Show();

	local targetFrame = NPE_TutorialDragTargetFrame;
	targetFrame:SetParent(destButton:GetParent());
	targetFrame:SetPoint("CENTER", destButton);
	targetFrame:Show();

	local texture;
	if originButton.icon then
		texture = originButton.icon:GetTexture();
	else
		local slot = SpellBook_GetSpellBookSlot(originButton);
		if slot then
			if originButton.spellID then -- the data is set if this is from a flyout spell button
				texture = GetSpellTexture(originButton.spellID);
			else
				texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
			end
		end
	end

	local animFrame = NPE_TutorialDragAnimationFrame;
	animFrame.Icon:SetTexture(texture);
	
	animFrame:SetParent(UIParent);
	animFrame:SetFrameStrata("DIALOG");
	animFrame:ClearAllPoints();
	animFrame:SetPoint("CENTER", originButton);
	animFrame:Show();

	animFrame.Anim:Stop();
	local ox, oy = originButton:GetCenter();
	local tx, ty = destButton:GetCenter();
	animFrame.Anim.Move:SetOffset(tx - ox, ty - oy);
	animFrame.Anim:Play();
end

function NPE_TutorialDragButton:Hide()
	NPE_TutorialDragOriginFrame:Hide();
	NPE_TutorialDragTargetFrame:Hide();
	NPE_TutorialDragAnimationFrame:Hide();
end
-- ------------------------------------------------------------------------------------------------------------