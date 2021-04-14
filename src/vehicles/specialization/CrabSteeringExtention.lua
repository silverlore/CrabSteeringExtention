CrabSteeringExtention = {}

function CrabSteeringExtention.prerequisitesPresent(specializations)
    return true
end

function CrabSteeringExtention.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CrabSteeringExtention)
end

function CrabSteeringExtention:onPreLoad(savegame)

    local i = 0
    local keytemplate = "vehicle.crabSteering.steeringMode(%d)"
    local needInputBinding = true
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
            break
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


end