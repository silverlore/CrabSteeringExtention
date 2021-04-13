CrabSteeringExtention = {}

function CrabSteeringExtention.prerequisitesPresent(specializations)
    return true
end

function CrabSteeringExtention.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CrabSteeringExtention)
end

function CrabSteeringExtention.onPreLoad(savegame)

    print("CrabSteeringExtention: loading specialitation")

    --setXMLString(self.xmlFile, "vehicle.crabSteering.steeringMode(%d)#inputBindingName":format(0), "CRABSTEERING_ALLWHEEL")
    --setXMLString(self.xmlFile, "vehicle.crabSteering.steeringMode(%d)#inputBindingName":format(2), "CRABSTEERING_CRABLEFT")
    --setXMLString(self.xmlFile, "vehicle.crabSteering.steeringMode(%d)#inputBindingName":format(3), "CRABSTEERING_CRABRIGHT")
end