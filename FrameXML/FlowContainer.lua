function FlowContainer_Initialize(container)
	container.flowFrames = {};
	--Default orientation to horizontal for now.
	FlowContainer_SetOrientation(container, "horizontal");
end

function FlowContainer_PauseUpdates(container)
	container.flowPauseUpdates = true;
end

function FlowContainer_ResumeUpdates(container)
	container.flowPauseUpdates = false;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetOrientation(container, orientation)	--"vertical" or "horizontal". This is the direction it tries to fill first.
	container.flowOrientation = orientation;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetMaxPerLine(container, maxPerLine)	--nil means we fit as much as possible.
	container.flowMaxPerLine = maxPerLine;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetHorizontalSpacing(container, horizontalSpacing)
	container.flowHorizontalSpacing = horizontalSpacing;
	FlowContainer_DoLayout(container);
end

function FlowContainer_SetVerticalSpacing(container, verticalSpacing)
	container.flowVerticalSpacing = verticalSpacing;
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddObject(container, object)
	tinsert(container.flowFrames, object);	--Do we want to let people choose where it will appear?
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddLineBreak(container)
	tinsert(container.flowFrames, "linebreak");
	FlowContainer_DoLayout(container);
end

function FlowContainer_AddSpacer(container, spacerSize)
	tinsert(container.flowFrames, spacerSize);
	FlowContainer_DoLayout(container);
end

function FlowContainer_BeginAtomicAdd(container)
	tinsert(container.flowFrames, "beginatomic");
	FlowContainer_DoLayout(container);
end

function FlowContainer_EndAtomicAdd(container)
	tinsert(container.flowFrames, "endatomic");
	FlowContainer_DoLayout(container);
end
	
function FlowContainer_RemoveObject(container, object)
	assert(type(object) == "table");	--For now, Remove can't be used with non-widgets.
	for i=1, #container.flowFrames do	--Used instead of tRemoveItem to eliminate dependencies.
		if ( container.flowFrames[i] == object ) then
			tremove(container.flowFrames, i);
			break;
		end
	end
	FlowContainer_DoLayout(container);
end

function FlowContainer_RemoveAllObjects(container)
	container.flowFrames = {};	--GC no worse than a table.wipe here.
end

--:GetWidth() and :GetHeight() are used in this function. --meta-comment: Comment added in case anyone ever searches all files for these.
function FlowContainer_DoLayout(container)
	if ( container.flowPauseUpdates ) then
		return;
	end
	
	local primaryDirection, secondaryDirection;
	local primarySpacing, secondarySpacing;
	if ( container.flowOrientation == "horizontal" ) then
		primaryDirection = "Width";
		secondaryDirection  = "Height";
		primarySpacing = container.flowHorizontalSpacing or 0;
		secondarySpacing = container.flowVerticalSpacing or 0;
	else
		primaryDirection = "Height";
		secondaryDirection  = "Width";
		primarySpacing = container.flowVerticalSpacing or 0;
		secondarySpacing = container.flowHorizontalSpacing or 0;
	end
	
	local currentSecondaryLine, currentPrimaryLine = 1, 1;
	local currentSecondaryOffset, currentPrimaryOffset = 0, 0;
	local lineMaxSize = 0;
	local atomicAddStart = nil;
	local i = 1;
	while ( i <= #container.flowFrames ) do
		local object = container.flowFrames[i];
		local doContinue = false;
		--To make things easier to understand, I'll comment this as if it was horizontal. To see the vertical comments, just turn your head 90 degrees.
		--If it doesn't fit on the current row, move to the next.
		if ( object == "linebreak" or	--Force a new line
			type(object) == "table" and	--Make sure this is an actual object before checking further.
				((container.flowMaxPerLine and currentPrimaryLine > container.flowMaxPerLine) or	--We went past the max number of columns
					currentSecondaryOffset + object["Get"..primaryDirection](object) > container["Get"..primaryDirection](container)) ) then	--We went past the max pixel width.
				currentSecondaryOffset = 0;	--Move back all the way to the left
				currentPrimaryLine = 1;	--Reset column count
				currentPrimaryOffset = currentPrimaryOffset + lineMaxSize + secondarySpacing;	--Move down by the size of the biggest object in the last row
				currentSecondaryLine = currentSecondaryLine + 1;	--Move to the next row.
				lineMaxSize = 0;
				if ( atomicAddStart ) then
					--We wrapped around. So we want to move back to the first item in the atomic add and continue from the position we're leaving off (the new line).
					i = atomicAddStart;
					atomicAddStart = nil;
					doContinue = true;
				end
		end
		
		if ( not doContinue ) then
			local objectType = type(object);
			if ( objectType == "table" ) then	--This is an actual frame
				--Did we completely run out of room? Assert for now.
				assert(currentPrimaryOffset + object["Get"..secondaryDirection](object) < container["Get"..secondaryDirection](container));
				
				--Add it.
				object:ClearAllPoints();
				if ( container.flowOrientation == "horizontal" ) then
					object:SetPoint("TOPLEFT", container, "TOPLEFT", currentSecondaryOffset, -currentPrimaryOffset);
				else
					object:SetPoint("TOPLEFT", container, "TOPLEFT", currentPrimaryOffset, -currentSecondaryOffset);
				end
				
				currentSecondaryOffset = currentSecondaryOffset + object["Get"..primaryDirection](object) + primarySpacing;
				currentPrimaryLine = currentPrimaryLine + 1;
				lineMaxSize = max(lineMaxSize, object["Get"..secondaryDirection](object));
			elseif ( objectType == "number" ) then	--This is a spacer.
				currentSecondaryOffset = currentSecondaryOffset + object;
			elseif ( objectType == "string" ) then
				if ( object == "beginatomic" ) then
					atomicAddStart = i + 1;
				elseif ( object == "endatomic" ) then
					atomicAddStart = nil;
				end
			end
			i = i + 1;
		end		
	end	
end