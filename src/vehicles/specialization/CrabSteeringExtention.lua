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
        if not hasXMLProperty(self.xmlFile, key) then
            break
        end
        
        inputKey = key .. "#inputBindingName"

        local input = getXMLString(self.xmlFile, inputKey)
        if input ~= nil then
            needInputBinding = false
        end

        local order = getXMLString(self.xmlFile, "#switchOrder")
        if order ~= nil then
            needOrder = false
        end
        
        local crabSteeringName = getXMLString(self.xmlFile, key .. "#name")
        steering[crabSteeringName] = i

        i = i + 1
    end

    if needInputBinding then 
        if(steering["action_steeringModeAllWheel"] ~= nil) then
            setXMLString(self.xmlFile, (keytemplate):format(steering["action_steeringModeAllWheel"]) .. "#inputBindingName", "CRABSTEERING_ALLWHEEL")
        end
        if(steering["action_steeringModeCrabLeft"] ~= nil) then
            setXMLString(self.xmlFile, (keytemplate):format(steering["action_steeringModeCrabLeft"]) .. "#inputBindingName", "CRABSTEERING_CRABLEFT")
        end
        if(steering["action_steeringModeCrabRight"] ~= nil) then
            setXMLString(self.xmlFile, (keytemplate):format(steering["action_steeringModeCrabRight"]) .. "#inputBindingName", "CRABSTEERING_CRABRIGHT")
        end
    end

    if needOrder then 
        setXMLInt(self.xmlFile, "vehicle.crabSteering#defaultOrder", 1)
        if(steering["action_steeringModeAllWheel"] ~= nil) then
            setXMLInt(self.xmlFile, (keytemplate):format(steering["action_steeringModeAllWheel"]) .. "#switchOrder", 1)
        end
        if(steering["action_steeringModeCrabLeft"] ~= nil) then
            setXMLInt(self.xmlFile, (keytemplate):format(steering["action_steeringModeCrabLeft"]) .. "#switchOrder", 0)
        end
        if(steering["action_steeringModeCrabRight"] ~= nil) then
            setXMLInt(self.xmlFile, (keytemplate):format(steering["action_steeringModeCrabRight"]) .. "#switchOrder", 2)
        end
    end
end

function CrabSteeringExtention:onLoad(savegame)
    if(hasXMLProperty(self.xmlFile, "vehicle.crabSteering")) then
        local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
        spec.orderToState = {}
        spec.StateToOrder = {}

        local default = getXMLInt(self.xmlFile, "vehicle.crabSteering#defaultOrder")

        local i = 0
        local keytemplate = "vehicle.crabSteering.steeringMode(%d)"
        local orderList = {}
        local orderMapper = {}
        

        while true do
            local key = (keytemplate):format(i)
            if not hasXMLProperty(self.xmlFile, key) then
                break
            end

            local order = getXMLInt(self.xmlFile, key .. "#switchOrder")
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

function CrabSteeringExtention:actionTowardLeft()
    local crapspec = self.spec_crabSteering
    local spec = self["spec_" .. CrabSteeringExtention.modName .. ".CrabSteeringExtention"]
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

