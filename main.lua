--[[
2019.12.27
珍妮的Lua中国象棋
TRP3用
--]]

--[[
print_dump是一个用于调试输出数据的函数，能够打印出nil,boolean,number,string,table类型的数据，以及table类型值的元表
参数data表示要输出的数据
参数showMetatable表示是否要输出元表
参数lastCount用于格式控制，用户请勿使用该变量
]]
function print_dump(data, showMetatable, lastCount)
    if type(data) ~= "table" then
        --Value
        if type(data) == "string" then
            io.write("\"", data, "\"")
        else
            io.write(tostring(data))
        end
    else
        --Format
        local count = lastCount or 0
        count = count + 1
        io.write("{\n")
        --Metatable
        if showMetatable then
            for i = 1,count do io.write("\t") end
            local mt = getmetatable(data)
            io.write("\"__metatable\" = ")
            print_dump(mt, showMetatable, count)    -- 如果不想看到元表的元表，可将showMetatable处填nil
            io.write(",\n")     --如果不想在元表后加逗号，可以删除这里的逗号
        end
        --Key
        for key,value in pairs(data) do
            for i = 1,count do io.write("\t") end
            if type(key) == "string" then
                io.write("\"", key, "\" = ")
            elseif type(key) == "number" then
                io.write("[", key, "] = ")
            else
                io.write(tostring(key))
            end
            print_dump(value, showMetatable, count) -- 如果不想看到子table的元表，可将showMetatable处填nil
            io.write(",\n")     --如果不想在table的每一个item后加逗号，可以删除这里的逗号
        end
        --Format
        for i = 1,lastCount or 0 do io.write("\t") end
        io.write("}")
    end
    --Format
    if not lastCount then
        io.write("\n")
    end
end

--字符串分割函数
function Utf8toChars(input)
    local list = {};
    local len  = string.len(input);
    local index = 1;
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc};
    while index <= len do
        local c = string.byte(input, index);
        local offset = 1;
        if c < 0xc0 then
            offset = 1;
        elseif c < 0xe0 then
            offset = 2;
        elseif c < 0xf0 then
            offset = 3;
        elseif c < 0xf8 then
            offset = 4;
        elseif c < 0xfc then
            offset = 5;
        end
        local str = string.sub(input, index, index+offset-1);
        index = index + offset;
        table.insert(list, str);
    end

    return list;
end

ChessType = {
    ["None"] = "＋",
    ["King"] = "将", --将帅，王
    ["Mandarin"] = "士", --士
    ["Elephant"] = "象", --象
    ["Knight"] = "马", --马
    ["Rook"] = "车", --车
    ["Cannon"] = "炮", --炮
    ["Pawn"] = "兵" --兵
}

PlayerColor = {
    ["None"] = "空",
    ["Red"] = "红", --红，先
    ["Black"] = "黑" --黑
}

local ChChess = {};

function ChChess:new ()
    self.gameMap_W = 9;
    self.gameMap_H = 10;
    self:initMap();
    return self;
end

--初始棋盘函数
function ChChess:initMap ()
    self.gameMap = {};
    for i = 1, self.gameMap_W*self.gameMap_H do
        self.gameMap[i] = {};
        self.gameMap[i].chessType = ChessType.None;
        self.gameMap[i].chessColor = PlayerColor.None;
    end

    local baseLine = {ChessType.Rook, ChessType.Knight, ChessType.Elephant, ChessType.Mandarin, ChessType.King,
        ChessType.Mandarin, ChessType.Elephant, ChessType.Knight, ChessType.Rook};
    local pawnLine = {ChessType.Pawn, ChessType.None, ChessType.Pawn, ChessType.None, ChessType.Pawn, ChessType.None, ChessType.Pawn,
        ChessType.None, ChessType.Pawn};
    local cannonLine = {ChessType.None, ChessType.Cannon, ChessType.None, ChessType.None, ChessType.None, ChessType.None, ChessType.None,
        ChessType.Cannon, ChessType.None};
    --设置初始棋盘
    for i = 1, self.gameMap_W do
        --self.gameMap[i] = {};
        self.gameMap[i].chessType = baseLine[i];
        self.gameMap[i].chessColor = PlayerColor.Red;
        --self.gameMap[(self.gameMap_H-1)*self.gameMap_W+i] = {};
        self.gameMap[(self.gameMap_H-1)*self.gameMap_W+i].chessType = baseLine[i];
        self.gameMap[(self.gameMap_H-1)*self.gameMap_W+i].chessColor = PlayerColor.Black;

        --self.gameMap[i+2*self.gameMap_W] = {};
        self.gameMap[i+2*self.gameMap_W].chessType = cannonLine[i];
        if self.gameMap[i+2*self.gameMap_W].chessType ~= ChessType.None then
            self.gameMap[i+2*self.gameMap_W].chessColor = PlayerColor.Red;
        end
        --self.gameMap[(self.gameMap_H-3)*self.gameMap_W+i] = {};
        self.gameMap[(self.gameMap_H-3)*self.gameMap_W+i].chessType = cannonLine[i];
        if self.gameMap[(self.gameMap_H-3)*self.gameMap_W+i].chessType ~= ChessType.None then
            self.gameMap[(self.gameMap_H-3)*self.gameMap_W+i].chessColor = PlayerColor.Black;
        end

        --self.gameMap[i+3*self.gameMap_W] = {};
        self.gameMap[i+3*self.gameMap_W].chessType = pawnLine[i];
        if self.gameMap[i+3*self.gameMap_W].chessType ~= ChessType.None then
            self.gameMap[i+3*self.gameMap_W].chessColor = PlayerColor.Red;
        end
        --self.gameMap[(self.gameMap_H-4)*self.gameMap_W+i] = {};
        self.gameMap[(self.gameMap_H-4)*self.gameMap_W+i].chessType = pawnLine[i];
        if self.gameMap[(self.gameMap_H-4)*self.gameMap_W+i].chessType ~= ChessType.None then
            self.gameMap[(self.gameMap_H-4)*self.gameMap_W+i].chessColor = PlayerColor.Black;
        end
    end
end

--走棋，响应字符串的方式
function ChChess:calMoveChessLocByStr(stepStr, playerColor)
    local strTable = Utf8toChars(stepStr);
    local loc = self:ScanColumn(strTable[1], strTable[2], playerColor);
    local desloc = {};
    if strTable[3] == "平" then
        desloc.row = loc.row;
        desloc.column = self:chineseNumStrToNum(strTable[4]);
    elseif strTable[3] == "进" then
        --马象士的进为路数，其他棋子为步数
        if strTable[1] == ChessType.Knight then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 1 then
                desloc.row = loc.row + 2;
            elseif math.abs(desloc.column - loc.column) == 2 then
                desloc.row = loc.row + 1;
            else
                return
            end
        elseif strTable[1] == ChessType.Elephant then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 2 then
                desloc.row = loc.row + 2;
            else
                return;
            end
        elseif strTable[1] == ChessType.Mandarin then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 1 then
                desloc.row = loc.row + 1;
            else
                return;
            end
        else
            --兵将车炮的进为前进步数，列数不变
            desloc.row = loc.row + self:chineseNumStrToNum(strTable[4]);
            desloc.column = loc.column;
        end
    elseif strTable[3] == "退" then
        --马象士的退为路数，其他棋子为步数
        if strTable[1] == ChessType.Knight then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 1 then
                desloc.row = loc.row - 2;
            elseif math.abs(desloc.column - loc.column) == 2 then
                desloc.row = loc.row - 1;
            else
                return
            end
        elseif strTable[1] == ChessType.Elephant then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 2 then
                desloc.row = loc.row - 2;
            else
                return;
            end
        elseif strTable[1] == ChessType.Mandarin then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = self:chineseNumStrToNum(strTable[4]);
            if math.abs(desloc.column - loc.column) == 1 then
                desloc.row = loc.row - 1;
            else
                return;
            end
        else
            --兵将车炮的退为后退步数，列数不变
            desloc.row = loc.row - self:chineseNumStrToNum(strTable[4]);
            desloc.column = loc.column;
        end
    end

    self:moveChess(loc, desloc, playerColor);
end

function ChChess:moveChess(loc, desloc, color)
    self.gameMap[desloc.column + desloc.row * self.gameMap_W].chessType = self.gameMap[loc.column + loc.row * self.gameMap_W].chessType;
    self.gameMap[desloc.column + desloc.row * self.gameMap_W].chessColor = self.gameMap[loc.column + loc.row * self.gameMap_W].playerColor;
    self.gameMap[loc.column + loc.row * self.gameMap_W].chessType = ChessType.None;
    self.gameMap[loc.column + loc.row * self.gameMap_W].chessColor = PlayerColor.None;
end

function ChChess:chineseNumStrToNum(Str)
    local result = 0;
    if type(Str) == "number" then
       return Str;
    end
    local chineseNums = {"一", "二", "三", "四", "五", "六", "七", "八", "九"};
    local Nums = {"1", "2", "3", "4", "5", "6", "7", "8", "9"};
    for i = 1, #chineseNums do
        if chineseNums[i] == Str then
            result = i;
            break;
        end
        if Nums[i] == Str then
            result = i;
            break;
        end
    end
    return result;
end

--扫描列
function ChChess:ScanColumn(chessType, columnStr, color)
    local column = self:chineseNumStrToNum(columnStr);
    if column == 0 then
        return;
    end
    local row = 0;
    for i = 0, self.gameMap_H - 1 do
        if self:isChessEqual(i * self.gameMap_W + column, chessType, color) then
            row = i;
            break;
        end
    end
    local result = {};
    result.row = row;
    result.column = column;
    return result;
end

function ChChess:isChessEqual(loc, type, color)
    --print_dump(self.gameMap);
    if self.gameMap[loc] == nil then
        return false;
    end
    return self.gameMap[loc].chessType == type and self.gameMap[loc].chessColor == color;
end

local chChess = ChChess:new();

function main()
    io.write("Chess Test!");
    drawMap();
    drawMapColor();
    stepTest();
end

function drawMap()
    io.write('\n');
    for i = 1, #chChess.gameMap do
        io.write(chChess.gameMap[i].chessType);
        if (i % chChess.gameMap_W == 0) then
            io.write('\n');
        end
    end
end

function drawMapColor()
    io.write('\n');
    for i = 1, #chChess.gameMap do
        io.write(chChess.gameMap[i].chessColor);
        if (i % chChess.gameMap_W == 0) then
            io.write('\n');
        end
    end
end

function stepTest()
    local s1 = "${v";
    local s2 = "::{icon:spell_chargepositive:25}}";

    local pawn = "::{icon:icon_petfamily_humanoid:25}}";

    for i = 0, 9 do
        for j = 1, 9 do
            local index = j + i * 9; 
            io.write(s1..tostring(index)..s2);
        end
        io.write('\n');
    end
    chChess:calMoveChessLocByStr("炮二平五", "红");
    drawMap();
end

main();