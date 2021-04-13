
local directory = g_currentModDirectory
local modName = g_currentModName

local vehicles = {}
local vehiclesByReplaceType = {}

local function validateVehicleTypes(vehicleTypeManager)
    print("CrabSteeringExtention: started vehicleTypesValidation.")
    local typeManager = g_vehicleTypeManager
    local specializationManager = g_specializationManager
    for typeName, typeEntry in pairs(typeManager:getVehicleTypes()) do
        if SpecializationUtil.hasSpecialization(CrabSteering, typeEntry.specializations) then
            typeManager:addSpecialization(typeName, modName .. ".CrabSteeringExtention")
        end
    end
end

local function init()
    print("CrabSteeringExtention: started mod.")
    VehicleTypeManager.validateVehicleTypes = Utils.prependedFunction(VehicleTypeManager.validateVehicleTypes, validateVehicleTypes)
end

init()
