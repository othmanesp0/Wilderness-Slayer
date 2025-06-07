local API = require("api")
local UTILS = require("utils")
local LODESTONE = require("lodestones")
local startTime = os.time() 
local inter = { { 1639,3,-1,0 }, { 1639,5,-1,0 }, { 1639,8,-1,0 }, { 1639,11,-1,0 } }
local eatFoodAB = API.GetABs_name1("Eat Food")
local War = API.GetABs_name1("War's Retreat Teleport")
local finger_of_death = API.GetABs_name1("Finger of Death")
local volley_of_souls = API.GetABs_name1("Volley of Souls")
local food = 15272
local task_refresh = 0
local last_task = ""
local kills_remaining = 0

local task_text = API.CreateIG_answer()
task_text.box_start = API.CreateFFPOINT(10, 50, 0) 
task_text.string_value = "Slayer Task: Loading..."
task_text.radius = 20
task_text.colour = ImColor.new(0, 255, 0, 255)

function UpdateSlayerInfo()
    local now = os.clock()
    if now - task_refresh > 5 then
        task_refresh = now
        local result = API.ScanForInterfaceTest2Get(false, inter)
        if result and #result > 0 then
            last_task = result[1].textids or "No task"
        else
            last_task = "Interface not found"
        end
    end
    
    task_text.string_value = "Slayer Task: " .. last_task
end

local ITEMS = {}


ITEMS.Loot = {
    
    
}

local itemIdsToLoot = UTILS.concatenateTables(            
    ITEMS.Loot
)
local function eat()
        if API.GetHPrecent() < 60 then
           API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
           API.RandomSleep2(1000, 500, 500)
           end
end

local npcMapping = {
    ["Abyssal beasts (Wilderness)"] = { 28781, 29351 },
    ["Abyssal demons (Wilderness)"] = { 28781, 29351 },
    ["Abyssal lords (Wilderness)"] = { 28783, 29353 },
    ["Abyssal savages (Wilderness)"] = { 28782, 29352 },
    ["Acheron mammoths (Wilderness)"] = { 22007, 29343 },
    ["Dark beasts (Wilderness)"] = { 2783, 26243, 29346 },
    ["Gargoyles (Wilderness)"] = { 29354, 1610 },
    ["Greater demon berserkers and ash lords (Wilderness)"] = { 29363,29360},
    ["Hydrix dragons (Wilderness)"] = { 24172, 29348 },
    ["Ice strykewyrms (Wilderness)"] = { 9463,9462 },
    ["Lava strykewyrms (Wilderness)"] = { 20630,20631 },
    ["Kal'gerion demons (Wilderness)"] = { 14977, 14975, 14974, 14973, 19874, 14976 },
    ["Living wyverns (Wilderness)"] = { 21812, 29356 },
    ["Onyx dragons (Wilderness)"] = { 24171, 29347 },
    ["Revenants (Wilderness)"] = { 13476,13481,13480,13479,13478,13477 },
    ["Ripper Demons (Wilderness)"] = { 21994, 29344 },
    ["Soulgazers (Wilderness)"] = { 25125, 29350 }
}

local function getBuff(buffId)
  local buff = API.Buffbar_GetIDstatus(buffId, false)
  return { found = buff.found, remaining = (buff.found and API.Bbar_ConvToSeconds(buff)) or 0 }
end
local function necrosisStacks()
  return getBuff(30101).remaining or 0
end

local function soulStacks()
  return getBuff(30123).remaining or 0
end
local function waitForMovement()
    while API.ReadPlayerMovin2() do
        API.RandomSleep2(300, 300, 600)
        eat()
    end
    API.RandomSleep2(50, 100, 200)
end



local function checkStepArea(step)
    if not step.area then return true end
    return API.PInArea(step.area.x, step.area.range[1], step.area.y, step.area.range[2], step.area.z)
end

local function Traverse(steps)
    local start = 1
    
    for i, step in ipairs(steps) do
        if step.area and checkStepArea(step) then
            start = i
            break
        end
    end

    for i = start, #steps do
        if not API.Read_LoopyLoop() then return end
        
        local step = steps[i]
        
        if not checkStepArea(step) then
            print("Not in expected area for step "..i)
            return false
        end

        if step.next then
            step.next()
            waitForMovement()
        end

        if step.check then
            local attempts = 0
            while not step.check() do
                if attempts >= 20 then
                    print("Step condition not met after 20 attempts")
                    return false
                end
                API.RandomSleep2(300, 200, 500)
                attempts = attempts + 1
            end
        end
    end
    
    return true
end

local function moveToTile(x, y, z)
    local randX = x + math.random(-2, 2)
    local randY = y + math.random(-2, 2)
    API.DoAction_Tile(WPOINT.new(randX, randY, z))
    API.RandomSleep2(2000, 200, 500)
    waitForMovement()
end
local function isFightingCorrectMob(task)
    if not API.LocalPlayer_IsInCombat_() then
        return false 
    end
    
    local targetId = API.Local_PlayerInterActingWith_Id()
    if targetId == 0 then
        return false 
    end
    
    local taskNpcs = npcMapping[task]
    if not taskNpcs then
        return false 
    end
    
    for _, id in ipairs(taskNpcs) do
        if id == targetId then
            return true
        end
    end
    
    return false
end

local locationSteps = {
    ["Abyssal beasts (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3091, 3657, 0) end },
        { area = {x = 3091, y = 3657, z = 0, range = {10,10}}, next = function() moveToTile(3070, 3721, 0) end },
        { area = {x = 3070, y = 3721, z = 0, range = {10,10}}, next = function() moveToTile(3104, 3777, 0) end },
        { area = {x = 3104, y = 3777, z = 0, range = {10,10}}, next = function() moveToTile(3093, 3800, 0) end },
        { area = {x = 3093, y = 3800, z = 0, range = {20,20}} }
    },
    ["Abyssal demons (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3091, 3657, 0) end },
        { area = {x = 3091, y = 3657, z = 0, range = {10,10}}, next = function() moveToTile(3070, 3721, 0) end },
        { area = {x = 3070, y = 3721, z = 0, range = {10,10}}, next = function() moveToTile(3104, 3777, 0) end },
        { area = {x = 3104, y = 3777, z = 0, range = {10,10}}, next = function() moveToTile(3093, 3800, 0) end },
        { area = {x = 3093, y = 3800, z = 0, range = {20,20}} }
    },
    ["Abyssal lords (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3091, 3657, 0) end },
        { area = {x = 3091, y = 3657, z = 0, range = {10,10}}, next = function() moveToTile(3070, 3721, 0) end },
        { area = {x = 3070, y = 3721, z = 0, range = {10,10}}, next = function() moveToTile(3104, 3777, 0) end },
        { area = {x = 3104, y = 3777, z = 0, range = {10,10}}, next = function() moveToTile(3119, 3782, 0) end },
        { area = {x = 3119, y = 3782, z = 0, range = {10,10}}, next = function() moveToTile(3136, 3867, 0) end },
        { area = {x = 3136, y = 3867, z = 0, range = {20,20}} }
    },
    ["Abyssal savages (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {20,20}} }
    },
    ["Acheron mammoths (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3023, 3925, 0) end },
        { area = {x = 3023, y = 3925, z = 0, range = {10,10}}, next = function() moveToTile(2970, 3937, 0) end },
        { area = {x = 2970, y = 3937, z = 0, range = {20,20}} }
    },
    ["Dark beasts (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {10,10}}, next = function() moveToTile(2996, 3782, 0) end },
        { area = {x = 2996, y = 3782, z = 0, range = {20,20}} }
    },
    ["Gargoyles (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3225, 3731, 0) end },
        { area = {x = 3225, y = 3731, z = 0, range = {20,20}} }
    },
    ["Greater demon berserkers and ash lords (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3263, 3717, 0) end },
        { area = {x = 3263, y = 3717, z = 0, range = {10,10}}, next = function() moveToTile(3297, 3764, 0) end },
        { area = {x = 3297, y = 3764, z = 0, range = {10,10}}, next = function() moveToTile(3335, 3812, 0) end },
        { area = {x = 3335, y = 3812, z = 0, range = {20,20}} }
    },
    ["Hydrix dragons (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {10,10}}, next = function() moveToTile(2996, 3782, 0) end },
        { area = {x = 2996, y = 3782, z = 0, range = {10,10}}, next = function() moveToTile(3009, 3834, 0) end },
        { area = {x = 3009, y = 3834, z = 0, range = {10,10}}, next = function() moveToTile(3023, 3886, 0) end },
        { area = {x = 3023, y = 3886, z = 0, range = {20,20}} }
    },
    ["Ice strykewyrms (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {10,10}}, next = function() moveToTile(2996, 3782, 0) end },
        { area = {x = 2996, y = 3782, z = 0, range = {10,10}}, next = function() moveToTile(3058, 3813, 0) end },
        { area = {x = 3058, y = 3813, z = 0, range = {20,20}} }
    },
    ["Lava strykewyrms (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {10,10}}, next = function() moveToTile(2996, 3782, 0) end },
        { area = {x = 2996, y = 3782, z = 0, range = {10,10}}, next = function() moveToTile(3058, 3813, 0) end },
        { area = {x = 3058, y = 3813, z = 0, range = {20,20}} }
    },
    ["Kal'gerion demons (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3263, 3717, 0) end },
        { area = {x = 3263, y = 3717, z = 0, range = {10,10}}, next = function() moveToTile(3297, 3764, 0) end },
        { area = {x = 3297, y = 3764, z = 0, range = {10,10}}, next = function() moveToTile(3335, 3812, 0) end },
        { area = {x = 3335, y = 3812, z = 0, range = {10,10}}, next = function() moveToTile(3332, 3859, 0) end },
        { area = {x = 3332, y = 3859, z = 0, range = {10,10}}, next = function() moveToTile(3298, 3879, 0) end },
        { area = {x = 3298, y = 3879, z = 0, range = {20,20}} }
    },
    ["Living wyverns (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3046, 3724, 0) end },
        { area = {x = 3046, y = 3724, z = 0, range = {10,10}}, next = function() moveToTile(2996, 3782, 0) end },
        { area = {x = 2996, y = 3782, z = 0, range = {10,10}}, next = function() moveToTile(3009, 3834, 0) end },
        { area = {x = 3009, y = 3834, z = 0, range = {10,10}}, next = function() moveToTile(3023, 3886, 0) end },
        { area = {x = 3023, y = 3886, z = 0, range = {10,10}}, next = function() moveToTile(2964, 3894, 0) end },
        { area = {x = 2964, y = 3894, z = 0, range = {20,20}} }
    },
    ["Onyx dragons (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3225, 3731, 0) end },
        { area = {x = 3225, y = 3731, z = 0, range = {10,10}}, next = function() moveToTile(3261, 3791, 0) end },
        { area = {x = 3261, y = 3791, z = 0, range = {20,20}} }
    },
    ["Revenants (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3076, 3649, 0) end },
        { 
            area = {x = 3076, y = 3649, z = 0, range = {10,10}},
            next = function() 
                API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, {20600}, 50) 
            end,
            check = function() return API.PInArea(3105, 5, 10123, 5, 0) end 
        },
        { area = {x = 3105, y = 10123, z = 0, range = {10,10}}, next = function() moveToTile(3115, 10146, 0) end },
        { area = {x = 3115, y = 10146, z = 0, range = {20,20}} }
    },
    ["Ripper Demons (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3225, 3731, 0) end },
        { area = {x = 3225, y = 3731, z = 0, range = {10,10}}, next = function() moveToTile(3261, 3791, 0) end },
        { area = {x = 3261, y = 3791, z = 0, range = {10,10}}, next = function() moveToTile(3247, 3862, 0) end },
        { area = {x = 3247, y = 3862, z = 0, range = {20,20}} }
    },
    ["Soulgazers (Wilderness)"] = {
        { area = nil, next = function() LODESTONE.Wilderness() end },
        { area = {x = 3143, y = 3635, z = 0, range = {10,10}}, next = function() moveToTile(3197, 3680, 0) end },
        { area = {x = 3197, y = 3680, z = 0, range = {10,10}}, next = function() moveToTile(3225, 3731, 0) end },
        { area = {x = 3225, y = 3731, z = 0, range = {10,10}}, next = function() moveToTile(3327, 3805, 0) end },
        { area = {x = 3327, y = 3805, z = 0, range = {10,10}}, next = function() moveToTile(3326, 3725, 0) end },
        { area = {x = 3326, y = 3725, z = 0, range = {20,20}} }
    }
}

local function getNewTask()
    local steps = {
        { area = nil, next = function() LODESTONE.Edgeville() end },
        { area = {x = 3067, y = 3505, z = 0, range = {10,10}}, next = function() moveToTile(3094, 3476, 0) end },
        {
            area = {x = 3094, y = 3476, z = 0, range = {10,10}},
            next = function() API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {1814}, 50) 
            API.RandomSleep2(2000,500,500)
            waitForMovement()
            API.RandomSleep2(4000,500,500)
             end,
            check = function() return API.PInArea(3154, 5, 3924, 5, 0) end
        },
        { area = {x = 3154, y = 3924, z = 0, range = {10,10}}, next = function() moveToTile(3160, 3946, 0) end  },
        {
            area = {x = 3160, y = 3946, z = 0, range = {10,10}},
            next = function() API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {65346}, 50) 
            API.RandomSleep2(2000,500,500)
            waitForMovement()
            API.RandomSleep2(4000,500,500)
            end,
            check = function() return API.PInArea(3158, 5, 3950, 5, 0) end
        },
        { area = {x = 3158, y = 3950, z = 0, range = {10,10}} , next = function() moveToTile(3121, 3956, 0) end},
        { area = {x = 3121, y = 3956, z = 0, range = {10,10}} , next = function() moveToTile(3074, 3949, 0) end},
        { area = {x = 3074, y = 3949, z = 0, range = {10,10}} , next = function() moveToTile(3053, 3949, 0) end},
        {
            area = {x = 3053, y = 3949, z = 0, range = {10,10}},
            next = function() API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route2, {6537}, 50) waitForMovement() end
        }
    }
    
    if not Traverse(steps) then
        print("Failed to get new task")
        return
    end

    local interfaces = {
        {1191, 15}, {1188, 8}, {1184, 15}, {1188, 13}
    }
    for _, interface in ipairs(interfaces) do
        API.DoAction_Interface(0xffffffff, 0xffffffff, 0, interface[1], interface[2], -1, API.OFF_ACT_GeneralInterface_Choose_option)
        API.RandomSleep2(1000, 500, 500)
    end
end
local function war()
    task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
    local steps = locationSteps[task]
      API.DoAction_Ability_Direct(War, 1, API.OFF_ACT_GeneralInterface_route)
      API.RandomSleep2(4000, 500, 500)
      API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ 114750 },50);
      API.RandomSleep2(4000, 500, 500)
      while API.LocalPlayer_IsInCombat_() do
            API.RandomSleep2(500, 500, 500)
      end
      Traverse(steps)
end


local function killMobs(task)
    local npcIds = npcMapping[task]
    if not npcIds then
        print("No NPC mapping for task: " .. task)
        API.Write_LoopyLoop(false)
        return
    end
    local count = API.VB_FindPSettinOrder(183).state
    
    while count > 0 and API.Read_LoopyLoop() do
        local targets = API.GetAllObjArrayInteract(npcIds, 30, {1})
        if #targets > 0 then
        targets = API.Math_SortAODistA(targets)
        if not isFightingCorrectMob(task) then
            print("fighting")
            API.DoAction_NPC__Direct(0x2a, API.OFF_ACT_AttackNPC_route, targets[1])
            print("Attacking target: " .. targets[1].Id)
            API.RandomSleep2(2000, 500, 500)
        end
        if necrosisStacks() == 12 and API.GetAddreline_() > 60 then
            API.DoAction_Ability_Direct(finger_of_death, 1, API.OFF_ACT_GeneralInterface_route)
        end
        if soulStacks() == 5 then
            API.DoAction_Ability_Direct(volley_of_souls, 1, API.OFF_ACT_GeneralInterface_route)
        end
        
        if API.LootWindowOpen_2() then
            API.DoAction_Loot_w(itemIdsToLoot, 10, API.PlayerCoordfloat(), 10)
            API.RandomSleep2(1500, 500, 500)
        end
        
        if API.GetHPrecent() < 60 then
           if not Inventory:Contains(food) then 
            war()
           else
           API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
           API.RandomSleep2(1000, 500, 500)
           end
        end
    end
        API.RandomSleep2(1000, 500, 500)
    end
end
function DrawSlayerInfo()
    UpdateSlayerInfo()
    API.DrawTextAt(task_text)
end
while API.Read_LoopyLoop() do
    DrawSlayerInfo()
    local count = API.VB_FindPSettinOrder(183).state
    local task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
    if count == 0 then
        getNewTask()
    else
        task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
        local steps = locationSteps[task]
        
        if steps then
            if Traverse(steps) then
                killMobs(task)
            else
                print("Failed to traverse to "..task)
                API.Write_LoopyLoop(false)

            end
        else
            print("No path defined for task: "..task)
            API.Write_LoopyLoop(false)
        end
    end
end
