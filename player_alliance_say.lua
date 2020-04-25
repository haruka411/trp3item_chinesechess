local gameMap_W = 9;
local gameMap_H = 10;

ChessTypeChinese = {
    ["空"] = "None",
    ["将"] = "King", --将帅，王
    ["士"] = "Mandarin", --士
    ["象"] = "Elephant", --象
    ["马"] = "Knight", --马
    ["车"] = "Rook", --车
    ["炮"] = "Cannon", --炮
    ["兵"] = "Pawn", --兵
    ["帅"] = "King",
    ["卒"] = "Pawn"
}

ChessType = {
    ["None"] = "None",
    ["King"] = "King", --将帅，王
    ["Mandarin"] = "Mandarin", --士
    ["Elephant"] = "Elephant", --象
    ["Knight"] = "Knight", --马
    ["Rook"] = "Rook", --车
    ["Cannon"] = "Cannon", --炮
    ["Pawn"] = "Pawn" --兵
}

PlayerColor = {
    ["None"] = "None",
    ["Red"] = "Horde", --红，先
    ["Black"] = "Alliance" --黑
}

ChessTypeHStr = {
    ["None"] = "{icon:ui_hordeicon:35",
    ["King"] = "{icon:achievement_leader_sylvanas:35", --将帅，王
    ["Mandarin"] = "{icon:achievement_character_undead_female:35", --士
    ["Elephant"] = "{icon:ability_mount_kodo_01:35", --象
    ["Knight"] = "{icon:ability_mount_whitedirewolf:35", --马
    ["Rook"] = "{icon:inv_garrison_hordedestroyer:35", --车
    ["Cannon"] = "{icon:ability_mount_rocketmount:35", --炮
    ["Pawn"] = "{icon:achievement_character_orc_male:35" --兵
}

ChessTypeAStr = {
    ["None"] = "{icon:ui_allianceicon:35",
    ["King"] = "{icon:expansionicon_classic:35", --将帅，王
    ["Mandarin"] = "{icon:achievement_worganhead:35", --士
    ["Elephant"] = "{icon:ability_mount_ridingelekkelite:35", --象
    ["Knight"] = "{icon:inv_horse3saddle003_white:35", --马
    ["Rook"] = "{icon:inv_garrison_alliancedestroyer:35", --车
    ["Cannon"] = "{icon:ability_mount_gyrocoptor:35", --炮
    ["Pawn"] = "{icon:achievement_character_human_male:35" --兵
}

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

function chineseNumStrToNum(Str, color)
    local result = 0;
    if type(Str) == "number" then
       return Str;
    end
    local chineseNums = {"一", "二", "三", "四", "五", "六", "七", "八", "九"};
    if color == PlayerColor.Red then
        --chineseNums = {"九", "八", "七", "六", "五", "四", "三", "二", "一"};
    end
    local Nums = {"1", "2", "3", "4", "5", "6", "7", "8", "9"};
    if color == PlayerColor.Red then
        --Nums = {"9", "8", "7", "6", "5", "4", "3", "2", "1"};
    end
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

function calMoveChessLocByStr(stepStr, playerColor)
    if stepStr == "悔棋" then
        MoveChessBack();
        return;
    end

    local strTable = Utf8toChars(stepStr);

    if #strTable == 5 then
        calMoveChessLocByStrSp(strTable, playerColor);
    end

    if #strTable ~= 4 then
        return;
    end

    local loc = ScanColumn(strTable[1], strTable[2], playerColor);
    if loc == nil then
        return;
    end
    local desloc = {};

    if strTable[3] == "平" then
        desloc.row = loc.row;
        desloc.column = chineseNumStrToNum(strTable[4], playerColor);
        if loc.column == desloc.column then
            return;
        end
    elseif strTable[3] == "进" then
        --马象士的进为路数，其他棋子为步数
        if strTable[1] == "马" then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 2;
                end
            elseif math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 1;
                end
            else
                return
            end
        elseif strTable[1] == "象" then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 2;
                end
            else
                return;
            end
        elseif strTable[1] == "士" then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 1;
                end
            else
                return;
            end
        else
            --兵将车炮的进为前进步数，列数不变
            if playerColor == PlayerColor.Red then
                desloc.row = loc.row + chineseNumStrToNum(strTable[4], playerColor);
            elseif playerColor == PlayerColor.Black then
                desloc.row = loc.row - chineseNumStrToNum(strTable[4], playerColor);
            end
            desloc.column = loc.column;
        end
    elseif strTable[3] == "退" then
        --马象士的退为路数，其他棋子为步数
        if strTable[1] == "马" then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 2;
                end
            elseif math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 1;
                end
            else
                return
            end
        elseif strTable[1] == "象" then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 2;
                end
            else
                return;
            end
        elseif strTable[1] == "士" then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 1;
                end
            else
                return;
            end
        else
            --兵将车炮的退为后退步数，列数不变
            if playerColor == PlayerColor.Red then
                desloc.row = loc.row - chineseNumStrToNum(strTable[4], playerColor);
            elseif playerColor == PlayerColor.Black then
                desloc.row = loc.row + chineseNumStrToNum(strTable[4], playerColor);
            end
            desloc.column = loc.column;
        end
    end
    moveChess(loc, desloc, playerColor);
end

--扫描列
function ScanColumn(chessType, columnStr, color)
    local column = chineseNumStrToNum(columnStr, color);
    if column == 0 then
        return;
    end
    local row = -1;
    for i = 0, gameMap_H - 1 do
        local index = i * gameMap_W + column;
        local typeValStr = ChessTypeHStr[ChessTypeChinese[chessType]];
        if color == PlayerColor.Red then
            typeValStr = ChessTypeHStr[ChessTypeChinese[chessType]];
        elseif color == PlayerColor.Black then
            typeValStr = ChessTypeAStr[ChessTypeChinese[chessType]];
        end

        if isChessEqual(index, typeValStr, color) == true then
            row = i;
            break;
        end
    end
    local result = {};
    result.row = row;
    result.column = column;
    if result.row == -1 then
        return;
    end
    return result;
end

--特别的重叠同一列时的判断，如"前车一进一"，"兵/卒三五平四"
function calMoveChessLocByStrSp(strTable, playerColor)
    local loc = ScanColumnSp(strTable[1], strTable[2], strTable[3], playerColor);

    if loc == nil then
        return;
    end
    local desloc = {};

    if strTable[3+1] == "平" then
        desloc.row = loc.row;
        desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
    elseif strTable[3+1] == "进" then
        --马象士的进为路数，其他棋子为步数
        if strTable[1+1] == "马" then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 2;
                    --effect("text", args, desloc.row, 1);
                    --effect("text", args, desloc.column, 1);
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 2;
                end
            elseif math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 1;
                end
            else
                return
            end
        elseif strTable[1+1] == "象" then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 2;
                end
            else
                return;
            end
        elseif strTable[1+1] == "士" then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row + 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row - 1;
                end
            else
                return;
            end
        else
            --兵将车炮的进为前进步数，列数不变
            if playerColor == PlayerColor.Red then
                desloc.row = loc.row + chineseNumStrToNum(strTable[4+1], playerColor);
            elseif playerColor == PlayerColor.Black then
                desloc.row = loc.row - chineseNumStrToNum(strTable[4+1], playerColor);
            end
            desloc.column = loc.column;
        end
    elseif strTable[3+1] == "退" then
        --马象士的退为路数，其他棋子为步数
        if strTable[1+1] == "马" then
            --马走日字，进时列差二则行差一，行差二则列差一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 2;
                end
            elseif math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 1;
                end
            else
                return
            end
        elseif strTable[1+1] == "象" then
            --象走田字，行列差距都应当为二，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 2 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 2;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 2;
                end
            else
                return;
            end
        elseif strTable[1+1] == "士" then
            --士斜着走，行列差距都应当为一，不应当出现其他情况
            desloc.column = chineseNumStrToNum(strTable[4+1], playerColor);
            if math.abs(desloc.column - loc.column) == 1 then
                if playerColor == PlayerColor.Red then
                    desloc.row = loc.row - 1;
                elseif playerColor == PlayerColor.Black then
                    desloc.row = loc.row + 1;
                end
            else
                return;
            end
        else
            --兵将车炮的退为后退步数，列数不变
            if playerColor == PlayerColor.Red then
                desloc.row = loc.row - chineseNumStrToNum(strTable[4+1], playerColor);
            elseif playerColor == PlayerColor.Black then
                desloc.row = loc.row + chineseNumStrToNum(strTable[4+1], playerColor);
            end
            desloc.column = loc.column;
        end
    end
    moveChess(loc, desloc, playerColor);
end

--扫描列
function ScanColumnSp(cindexStr, chessType, columnStr, color)
    local cindex = 0;
    if chessType ~= ChessType.Pawn then
        if cindexStr == "前" then
            if color == PlayerColor.Red then
                cindex = 2;
            elseif color == PlayerColor.Black then
                cindex = 1;
            end
        elseif cindexStr == "后" then
            if color == PlayerColor.Red then
                cindex = 1;
            elseif color == PlayerColor.Black then
                cindex = 2;
            end
        else
            return;
        end
    else
        local cindexStrs = {"一", "二", "三", "四", "五"};
        if color == PlayerColor.Red then
            cindexStrs = {"五", "四", "三", "二", "一"};
        end
        for i = 0, #cindexStrs do
            if cindexStrs[i] == cindexStr then
                cindex = i;
                break;
            end
        end
    end

    if cindex == 0 then
        return;
    end

    local column = chineseNumStrToNum(columnStr, color);
    if column == 0 then
        return;
    end
    local row = 0;
    local tmpindex = 0;
    for i = 0, gameMap_H - 1 do
        local index = i * gameMap_W + column;
        local typeValStr = ChessTypeHStr[ChessTypeChinese[chessType]];
        if color == PlayerColor.Red then
            typeValStr = ChessTypeHStr[ChessTypeChinese[chessType]];
        elseif color == PlayerColor.Black then
            typeValStr = ChessTypeAStr[ChessTypeChinese[chessType]];
        end

        if isChessEqual(index, typeValStr, color) then
            tmpindex = tmpindex + 1;
            if tmpindex == cindex then
                row = i;
                break;
            end
        end
    end
    local result = {};
    result.row = row;
    result.column = column;
    return result;
end

--棋子是否相等
function isChessEqual(loc, type, color)
    --得到棋子类型与颜色，从trp战役全局变量中
    local chessType = getVar(args, "c", "v"..loc);
    if chessType == nil then
        return false;
    end
    local chessColor = getVar(args, "c", "c"..loc);
    if chessColor == nil then
        return false;
    end

    local result = (chessType == type and chessColor == color);
    --effect("text", args, result, 1);
    return result;
end

function moveChess(loc, desloc, color)
    if loc == nil then
        return;
    end

    local desindex = desloc.column + desloc.row * gameMap_W;
    local index = loc.column + loc.row * gameMap_W;
    if index <= 0 or index > gameMap_W * gameMap_H then
        return;
    end
    if desindex <= 0 or desindex > gameMap_W * gameMap_H then
        return;
    end

    setVar(args, "c", "oldloc", index);
    setVar(args, "c", "newloc", desindex);

    local chessType = getVar(args, "c", "v"..index);
    local chessColor = getVar(args, "c", "c"..index);
    local deschessType = getVar(args, "c", "v"..desindex);
    local deschessColor = getVar(args, "c", "c"..desindex);

    setVar(args, "c", "oldtype", chessType);
    setVar(args, "c", "oldcolor", chessColor);
    setVar(args, "c", "newtype", deschessType);
    setVar(args, "c", "newcolor", deschessColor);

    setVar(args, "c", "v"..desindex, chessType);
    setVar(args, "c", "c"..desindex, chessColor);

    if index < 46 then
        setVar(args, "c", "v"..index, ChessTypeHStr["None"]);
    else
        setVar(args, "c", "v"..index, ChessTypeAStr["None"]);
    end
    setVar(args, "c", "c"..index, chessColor.None);
end

--加入悔棋，防止误操作，只存一步
function MoveChessBack()
    local oldindex = getVar(args, "c", "oldloc");
    local newindex = getVar(args, "c", "newloc");

    local oldchessType = getVar(args, "c", "oldtype");
    local oldchessColor = getVar(args, "c", "oldcolor");
    local newdeschessType = getVar(args, "c", "newtype");
    local newdeschessColor = getVar(args, "c", "newcolor");

    setVar(args, "c", "v"..oldindex, oldchessType);
    setVar(args, "c", "c"..oldindex, oldchessColor);
    setVar(args, "c", "v"..newindex, newdeschessType);
    setVar(args, "c", "c"..newindex, newdeschessColor);
end

local speakStrVal = getVar(args, "w", "speakstr");
local playerColor = PlayerColor.Black;

calMoveChessLocByStr(speakStrVal, playerColor);