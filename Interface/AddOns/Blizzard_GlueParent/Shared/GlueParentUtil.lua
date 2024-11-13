local modalFrames = { };

function GlueParent_AddModalFrame(frame)
	local index = tIndexOf(modalFrames, frame);
	if index then
		return;
	end

	table.insert(modalFrames, frame);

	if #modalFrames == 1 then
		GlueParent.BlockingFrame:Show();
	end
end

function GlueParent_RemoveModalFrame(frame)
	local index = tIndexOf(modalFrames, frame);
	if not index then
		return;
	end

	table.remove(modalFrames, index);

	if #modalFrames == 0 then
		GlueParent.BlockingFrame:Hide();
	end
end

function GlueParentBlockingFrame_OnKeyDown(self, key)
	if key == "ESCAPE" then
		local frame = modalFrames[#modalFrames];
		local continueHide = true;
		if frame.onCloseCallback then
			continueHide = frame.onCloseCallback(self);
		end
		if continueHide then
			frame:Hide();
		end
	elseif key == "PRINTSCREEN" then
		Screenshot();
	end
end
