-- https://github.com/JstHope/PalCaptureCounter (discord: jsthop3)
local PAL_DATA = require("pal_data")

function findObjectByPalName(fileName)
    for i, obj in ipairs(PAL_DATA) do
        if obj.FileName == fileName then
            return obj
        end
    end
    return nil -- return nil if no object with the given PalName is found
end

CAPTURE_LIST = {}
function update_capture_list()
    CAPTURE_LIST = {}
    local records = FindAllOf("BP_PalPlayerRecordData_C")
    if records then 
        for Index, record in pairs(records) do
            local items = record.PalCaptureCount.Items
            items:ForEach(function(index, elem_wrapper)
                local palrec = elem_wrapper:get()
                CAPTURE_LIST[palrec.Key:ToString()] = tostring(palrec.Value)
            end)
        end
    end
end
function register_Gauge_Handle()
    RegisterHook("/Game/Pal/Blueprint/UI/NPCHPGauge/WBP_PalNPCHPGauge.WBP_PalNPCHPGauge_C:BindFromHandle", function(self, handler)
        local CharacterID = handler:get():TryGetIndividualParameter().SaveParameter.CharacterID:ToString()
        local eg = self.a.WBP_EnemyGauge
        local PalObject = findObjectByPalName(CharacterID)
        -- If PalObject is nil, return from the function
        if PalObject == nil then
            return
        end
        
        local PalName = PalObject.PalName

        if eg:IsValid() then
            if eg.Text_Name:GetFullName() ~= nil then
                if CAPTURE_LIST[CharacterID] ~= nil then
                    eg.Text_Name:SetText_GDKInternal(1,PalName .. string.format(" [%s/10] ", CAPTURE_LIST[CharacterID]))
                else
                    eg.Text_Name:SetText_GDKInternal(1,PalName .. " [0/10] ")
                end
            end
        end
    end)
end

RegisterHook("/Script/Pal.PalCharacterParameterComponent:SetIsCapturedProcessing", function(self)
    update_capture_list()
end)

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context, NewPawn)
    print("[PalCaptureCounter] INIT......")
    register_Gauge_Handle()
    RegisterHook("/Game/Pal/Blueprint/System/BP_PalGameInstance.BP_PalGameInstance_C:OnCompleteSetup", function(Context)
        print("[PalCaptureCounter] First update CAPTURE_LIST......")
        update_capture_list()
    end)
end)