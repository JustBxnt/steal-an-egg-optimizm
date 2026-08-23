-- ========================================================
-- DEBUG EGG STRUCTURE
-- Script untuk inspect egg model structure
-- ========================================================

print("🔍 DEBUG EGG STRUCTURE")
print("========================================")

local Workspace = game:GetService("Workspace")

-- Function to print tree structure
local function printTree(obj, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    
    local info = prefix .. "├─ " .. obj.Name .. " (" .. obj.ClassName .. ")"
    
    -- Add value if it's a value object
    if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("BoolValue") then
        info = info .. " = " .. tostring(obj.Value)
    end
    
    -- Add text if it's a TextLabel/TextButton
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        info = info .. ' Text="' .. obj.Text .. '"'
    end
    
    print(info)
    
    -- Don't go too deep
    if indent < 5 then
        for _, child in pairs(obj:GetChildren()) do
            printTree(child, indent + 1)
        end
    end
end

-- Find and inspect first egg
local areaEggs = Workspace:FindFirstChild("AreaEggSlotsClient")

if areaEggs then
    print("✅ Found AreaEggSlotsClient\n")
    
    local eggCount = 0
    
    for _, child in pairs(areaEggs:GetDescendants()) do
        if child:IsA("Model") and child.Name:lower():find("egg") then
            eggCount = eggCount + 1
            
            if eggCount <= 3 then  -- Only show first 3 eggs
                print("\n========================================")
                print("🥚 EGG #" .. eggCount)
                print("========================================")
                printTree(child)
            end
        end
    end
    
    print("\n========================================")
    print("Total eggs found:", eggCount)
    print("========================================")
else
    print("❌ AreaEggSlotsClient not found")
    print("\n🔍 Searching for eggs in entire Workspace...")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            print("\n✅ Found egg:", obj:GetFullName())
            printTree(obj)
            break
        end
    end
end

print("\n✅ Debug complete!")
print("📋 Copy console output and send to developer")
