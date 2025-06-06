local API = require("api")
local UTILS = require("utils")
local LODESTONE = require("lodestones")
local inter = { { 1639,3,-1,0 }, { 1639,5,-1,0 }, { 1639,8,-1,0 }, { 1639,11,-1,0 } }
local eatFoodAB = API.GetABs_name1("Eat Food")
local War = API.GetABs_name1("War's Retreat Teleport")
local finger_of_death = API.GetABs_name1("Finger of Death")
local volley_of_souls = API.GetABs_name1("Volley of Souls")
local food = 15272
local ITEMS = {}

ITEMS.Loot = {
    
    
}

local itemIdsToLoot = UTILS.concatenateTables(            
    ITEMS.Loot
)
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
local npcMapping = {
    ["Abyssal beasts"] = { 28781, 29351 },
    ["Abyssal demons"] = { 28781, 29351 },
    ["Abyssal lords"] = { 28783, 29353 },
    ["Abyssal savages"] = { 28782, 29352 },
    ["Acheron mammoths"] = { 22007, 29343 },
    ["Dark beasts"] = { 2783, 26243, 29346 },
    ["Gargoyles"] = { 29354, 1610 },
    ["Greater demon berserkers and ash lords (Wilderness)"] = { 29363,29360},
    ["Hydrix dragons"] = { 24172, 29348 },
    ["Ice strykewyrms"] = { 9463,9462 },
    ["Lava strykewyrms"] = { 20630,20631 },
    ["Kal'gerion demons"] = { 14977, 14975, 14974, 14973, 19874, 14976 },
    ["Living wyverns"] = { 21812, 29356 },
    ["Onyx dragons"] = { 24171, 29347 },
    ["Revenants"] = { 13476,13481,13480,13479,13478,13477 },
    ["Ripper Demons"] = { 21994, 29344 },
    ["Soulgazers"] = { 25125, 29350 }
}

local function moveToTile(x, y, z)
    local randX = x + math.random(-2, 2)
    local randY = y + math.random(-2, 2)
    API.DoAction_Tile(WPOINT.new(randX, randY, z))
    API.RandomSleep2(2000, 500, 500)
    while API.ReadPlayerMovin2() do
        API.RandomSleep2(500, 500, 500)
    end
end

local function wildernessLodestoneTo(tiles)
    LODESTONE.Wilderness()
    API.WaitUntilMovingandAnimEnds(10, 10)
    for _, tile in ipairs(tiles) do
        moveToTile(tile[1], tile[2], tile[3])
    end
end

local function getNewTask()
    print("EDGEVILLE TELEPORT")
    LODESTONE.Edgeville()
    API.WaitUntilMovingandAnimEnds(10, 10)
    moveToTile(3093, 3475, 0)

    print("Lever")
    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {1814}, 50)
    API.RandomSleep2(1000, 500, 500)
    API.WaitUntilMovingandAnimEnds(20, 10)
    moveToTile(3158, 3946, 0)

    print("Slash web")
    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {65346}, 50)
    API.WaitUntilMovingandAnimEnds(10, 10)
    
    local path = {
        {3128, 3954, 0},
        {3068, 3945, 0},
        {3054, 3948, 0}
    }
    for _, tile in ipairs(path) do
        moveToTile(tile[1], tile[2], tile[3])
    end

    print("Getting Task")
    API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route2, {6537}, 50)
    API.WaitUntilMovingEnds(5, 10)
    
    local interfaces = {
        {1191, 15},
        {1188, 8},
        {1184, 15},
        {1188, 13}
    }
    for _, interface in ipairs(interfaces) do
        API.DoAction_Interface(0xffffffff, 0xffffffff, 0, interface[1], interface[2], -1, API.OFF_ACT_GeneralInterface_Choose_option)
        API.RandomSleep2(2000, 500, 500)
    end
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


local locationHandlers = {
    ["Abyssal beasts"] = function() wildernessLodestoneTo({{3091,3657,0}, {3070,3721,0}, {3104,3777,0}, {3093,3800,0}}) end,
    ["Abyssal demons"] = function() wildernessLodestoneTo({{3091,3657,0}, {3070,3721,0}, {3104,3777,0}, {3093,3800,0}}) end,
    ["Abyssal lords"] = function() wildernessLodestoneTo({{3091,3657,0}, {3070,3721,0}, {3104,3777,0}, {3119,3782,0}, {3136,3867,0}}) end,
    ["Abyssal savages"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}}) end,
    ["Acheron mammoths"] = function() moveToTile(3023,3925,0); moveToTile(2970,3937,0) end,
    ["Dark beasts"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}, {2996,3782,0}}) end,
    ["Gargoyles"] = function() wildernessLodestoneTo({{3197,3680,0}, {3225,3731,0}}) end,
    ["Greater demon berserkers and ash lords (Wilderness)"] = function() wildernessLodestoneTo({{3197,3680,0}, {3263,3717,0}, {3297,3764,0}, {3335,3812,0}}) end,
    ["Hydrix dragons"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}, {2996,3782,0}, {3009,3834,0}, {3023,3886,0}}) end,
    ["Ice strykewyrms"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}, {2996,3782,0}, {3058,3813,0}}) end,
    ["Lava strykewyrms"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}, {2996,3782,0}, {3058,3813,0}}) end,
    ["Kal'gerion demons"] = function() wildernessLodestoneTo({{3197,3680,0}, {3225,3731,0}, {3327,3805,0}, {3302,3880,0}}) end,
    ["Living wyverns"] = function() wildernessLodestoneTo({{3083,3658,0}, {3046,3724,0}, {2996,3782,0}, {3009,3834,0}, {3023,3886,0}, {2964,3894,0}}) end,
    ["Onyx dragons"] = function() wildernessLodestoneTo({{3197,3680,0}, {3225,3731,0}, {3261,3791,0}}) end,
    ["Revenants"] = function()
        wildernessLodestoneTo({{3076,3649,0}})
        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, {20600}, 50)
        API.RandomSleep2(2000, 500, 500)
        API.WaitUntilMovingandAnimEnds()
        moveToTile(3105, 10123, 0)
        moveToTile(3115, 10146, 0)
    end,
    ["Ripper Demons"] = function() wildernessLodestoneTo({{3197,3680,0}, {3225,3731,0}, {3261,3791,0}, {3247,3862,0}}) end,
    ["Soulgazers"] = function() wildernessLodestoneTo({{3197,3680,0}, {3225,3731,0}, {3327,3805,0}, {3326,3725,0}}) end
}
local function war()
    task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
    local handler = locationHandlers[task]
      API.DoAction_Ability_Direct(War, 1, API.OFF_ACT_GeneralInterface_route)
      API.RandomSleep2(4000, 500, 500)
      API.DoAction_Object1(0x33,API.OFF_ACT_GeneralObject_route3,{ 114750 },50);
      API.RandomSleep2(4000, 500, 500)
      handler()
end
local function killMobs(task)
    local npcIds = npcMapping[task]
    if not npcIds then
        print("No NPC mapping for task: " .. task)
        API.Write_LoopyLoop(false)
        return
    end
    
    while API.VB_FindPSettinOrder(183).state > 0 and API.Read_LoopyLoop() do
        local targets = API.GetAllObjArrayInteract(npcIds, 30, {1})
        if #targets > 0 then
        targets = API.Math_SortAODistA(targets)
        if not isFightingCorrectMob(task) then
            print("fighting")
            API.DoAction_NPC__Direct(0x2a, API.OFF_ACT_AttackNPC_route, targets[1])
            print("Attacking target: " .. targets[1].Id)
            API.RandomSleep2(2000, 500, 500)
            if necrosisStacks() == 12 and API.GetAddreline_() > 60 then
            API.DoAction_Ability_Direct(finger_of_death, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(3000,500,500)
        end
        if soulStacks() == 5 and arch.Life > 3000 then
            API.DoAction_Ability_Direct(volley_of_souls, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(3000,500,500)
        end
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
while API.Read_LoopyLoop() do
    local count = API.VB_FindPSettinOrder(183).state
    if count == 0 then
        getNewTask()
        task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
    else
        task = API.ScanForInterfaceTest2Get(false, inter)[1].textids
        local handler = locationHandlers[task]
        if handler then
            handler()
            killMobs(task)
        else
            print("No path defined for task: " .. tostring(task))
            API.Write_LoopyLoop(false)
        end
    end
end
