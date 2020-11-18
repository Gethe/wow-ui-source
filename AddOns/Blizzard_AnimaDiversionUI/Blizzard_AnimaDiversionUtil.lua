
AnimaDiversionUtil = {};

function AnimaDiversionUtil.IsNodeActive(nodeState)
	return (nodeState == Enum.AnimaDiversionNodeState.SelectedTemporary) or (nodeState == Enum.AnimaDiversionNodeState.SelectedPermanent);
end

function AnimaDiversionUtil.IsAnyNodeActive()
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	if (not animaNodes) then 
		return false;
	end

	for i, animaNode in ipairs(animaNodes) do
		if (AnimaDiversionUtil.IsNodeActive(animaNode.state)) then
			return true;
		end
	end

	return false;
end