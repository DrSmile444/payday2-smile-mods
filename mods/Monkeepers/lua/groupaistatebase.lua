local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mkp_original_groupaistatebase_cloneobjective = GroupAIStateBase.clone_objective
function GroupAIStateBase.clone_objective(objective)
	local route = objective.mkp_route
	objective.mkp_route = nil
	local new_objective = mkp_original_groupaistatebase_cloneobjective(objective)
	objective.mkp_route = route
	new_objective.mkp_route = route
	return new_objective
end
