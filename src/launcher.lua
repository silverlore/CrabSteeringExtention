
local directory = g_currentModDirectory
local modName = g_currentModName

local vehicles = {}
local vehiclesByReplaceType = {}

local function validateVehicleTypes(typeManager)
    if typeManager.typeName == "vehicle" then
        print("CrabSteeringExtention: started vehicleTypesValidation.")
        CrabSteeringExtention.modName = modName
        g_specializationManager:addSpecialization("crabSteeringExtention", "CrabSteeringExtention", Utils.getFilename("src/vehicles/specialization/CrabSteeringExtention.lua", directory), nil)


        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(CrabSteering, typeEntry.specializations) and
                not SpecializationUtil.hasSpecialization(CrabSteeringExtention, typeEntry.specializations) then
                    print("adding CrabSteeringExtention to " .. typeName  .. ".")
                    typeManager:addSpecialization(typeName, modName .. ".CrabSteeringExtention")
                
            end
        end
    end
end

local function init()
    print("CrabSteeringExtention: started mod.")
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateVehicleTypes)
end

init()
