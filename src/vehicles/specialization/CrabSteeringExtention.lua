CrabSteeringExtention = {}

function CrabSteeringExtention.prerequisitesPresent(specializations)
    return true
end

function CrabSteeringExtention.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CrabSteeringExtention)
end

function CrabSteeringExtention:onPreLoad(savegame)

    local i = 0
    while true do
        local key = ("vehicle.crabSteering.steeringMode(%d)"):format(i)
        if not hasXMLProperty(self.xmlFile, key) then
            break
        end
        local crabSteeringName = getXMLString(self.xmlFile, key .. "#name") 

        if(crabSteeringName == "action_steeringModeAllWheel") then
            setXMLString(self.xmlFile, key .. "#inputBindingName", "CRABSTEERING_ALLWHEEL")
        end
        if(crabSteeringName == "action_steeringModeCrabLeft") then
            setXMLString(self.xmlFile, key .. "#inputBindingName", "CRABSTEERING_CRABLEFT")
        end
        if(crabSteeringName == "action_steeringModeCrabRight") then
            setXMLString(self.xmlFile, key .. "#inputBindingName", "CRABSTEERING_CRABRIGHT")
        end
        i = i + 1
    end
end