CrabSteeringExtention = {}

function CrabSteeringExtention.prerequisitesPresent(specializations)
    return true
end

function CrabSteeringExtention.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CrabSteeringExtention)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CrabSteeringExtention)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", CrabSteeringExtention)
end

function CrabSteeringExtention:onPreLoad(savegame)

    local i = 0
    local keytemplate = "vehicle.crabSteering.steeringMode(%d)"
    local needInputBinding = true
    local needOrder = true
    local steering = {}

    while true do
        local key = (keytemplate):format(i)
        if not self.xmlFile:hasProperty(key) then
            break
        end
        
        inputKey = key .. "#inputBindingName"

        local input = self.xmlFile:getString(inputKey)
        if input ~= nil then
            needInputBinding = false
        end

        local order = self.xmlFile:getString(key .. "#switchOrder")
        if order ~= nil then
            needOrder = false
        end
        
        local crabSteeringName = self.xmlFile:getString(key .. "#name")
        steering[crabSteeringName] = i
        print(crabSteeringName);

        i = i + 1
    end

    if needInputBinding then 
        if(steering["$l10n_action_steeringModeAllWheel"] ~= nil) then
            self.xmlFile:setString((keytemplate):format(steering["$l10n_action_steeringModeAllWheel"]) .. "#inputBindingName", "CRABSTEERING_ALLWHEEL")
        end
        if(steering["$l10n_action_steeringModeCrabLeft"] ~= nil) then
            self.xmlFile:setString((keytemplate):format(steering["$l10n_action_steeringModeCrabLeft"]) .. "#inputBindingName", "CRABSTEERING_CRABLEFT")
        end
        if(steering["$l10n_action_steeringModeCrabRight"] ~= nil) then
            self.xmlFile:setString((keytemplate):format(steering["$l10n_action_steeringModeCrabRight"]) .. "#inputBindingName", "CRABSTEERING_CRABRIGHT")
        end
    end

    if needOrder then 
        self.xmlFile:setInt("vehicle.crabSteering#defaultOrder", 1)
        if(steering["$l10n_action_steeringModeAllWheel"] ~= nil) then
            self.xmlFile:setInt((keytemplate):format(steering["$l10n_action_steeringModeAllWheel"]) .. "#switchOrder", 1)
        end
        if(steering["$l10n_action_steeringModeCrabLeft"] ~= nil) then
            self.xmlFile:setInt((keytemplate):format(steering["$l10n_action_steeringModeCrabLeft"]) .. "#switchOrder", 0)
        end
        if(steering["$l10n_action_steeringModeCrabRight"] ~= nil) then
            self.xmlFile:setInt((keytemplate):format(steering["$l10n_action_steeringModeCrabRight"]) .. "#switchOrder", 2)
        end
    end
end

function CrabSteeringExtention:onLoad(savegame)
    if(self.xmlFile:hasProperty("vehicle.crabSteering")) then
        local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
        spec.orderToState = {}
        spec.StateToOrder = {}

        local default = self.xmlFile:getInt("vehicle.crabSteering#defaultOrder")

        local i = 0
        local keytemplate = "vehicle.crabSteering.steeringMode(%d)"
        local orderList = {}
        local orderMapper = {}
        

        while true do
            local key = (keytemplate):format(i)
            if not self.xmlFile:hasProperty(key) then
                break
            end

            local order = self.xmlFile:getInt(key .. "#switchOrder")
            if order ~= nil then
                table.insert(orderList,order)
                orderMapper[order] = i + 1
            end

            i = i + 1
        end

        table.sort(orderList)

        for i,n in ipairs(orderList) do
            spec.orderToState[i] = orderMapper[n]
            spec.StateToOrder[orderMapper[n]] = i
            if default == n then
                spec.defaultOrder = i
            end
        end
    end
end

function CrabSteeringExtention:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
        
        self:clearActionEventsTable(spec.actionEvents)

        if self:getIsActiveForInput(true, true) then
            if not self:getIsAIActive() then 
                local nonDrawActionEvents = {}
                local function insert(_, actionEventId)
                    table.insert(nonDrawActionEvents, actionEventId)
                end

                insert(self:addActionEvent(spec.actionEvents, InputAction.CSE_TOWARD_RIGHT, self, CrabSteeringExtention.actionTowardRight, false, true, false, true, nil, nil, true))
                insert(self:addActionEvent(spec.actionEvents, InputAction.CSE_TOWARD_LEFT, self, CrabSteeringExtention.actionTowardLeft, false, true, false, true, nil, nil, true))

                for _, actionEventId in ipairs(nonDrawActionEvents) do
                    g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
                    g_inputBinding:setActionEventTextVisibility(actionEventId, false)
                end
            end
        end
    end
end

function CrabSteeringExtention:actionTowardRight()
    local crapspec = self.spec_crabSteering
    local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
    if table.getn(spec.orderToState) > 0 then
        local state = crapspec.state;
        local currentMode = spec.StateToOrder[state]
        
        if currentMode == nil then
            state = spec.orderToState[spec.defaultOrder]
        else
            if currentMode + 1 <= table.getn(spec.orderToState) then
                state = spec.orderToState[currentMode + 1]
            end
        end
        if state ~= crapspec.state then
            self:setCrabSteering(state)
        end
    end
end

function CrabSteeringExtention:actionTowardLeft()
    local crapspec = self.spec_crabSteering
    local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
    if table.getn(spec.orderToState) > 0 then
        local state = crapspec.state;
        local currentMode = spec.StateToOrder[state]
        
        if currentMode == nil then
            state = spec.orderToState[spec.defaultOrder]
        else
            if currentMode - 1 > 0 then
                state = spec.orderToState[currentMode - 1]
            end
        end
        if state ~= crapspec.state then
            self:setCrabSteering(state)
        end
    end
end

