--改变视角变了设置，根据这个变量展示不同的文档
local tviewport = getVar(args, "c", "viewport");
if tviewport == nil then
    tviewport = "horde"
else
    if tviewport == "alliance" then
        tviewport = "horde"
    elseif tviewport == "horde" then
        tviewport = "alliance"
    end
end
setVar(args, "c", "viewport", tviewport);