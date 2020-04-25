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

setVar(args, "c", "player_horde_id", "未设置");
setVar(args, "c", "player_alliance_id", "未设置");
setVar(args, "c", "viewport", "horde");

local gameMap = {};
local gameMap_W = 9;
local gameMap_H = 10;

function initMap ()
    for i = 1, gameMap_W*gameMap_H do
        gameMap[i] = {};
        gameMap[i].chessType = ChessType.None;
        gameMap[i].chessColor = PlayerColor.None;
    end

    local baseLine = {ChessType.Rook, ChessType.Knight, ChessType.Elephant, ChessType.Mandarin, ChessType.King,
        ChessType.Mandarin, ChessType.Elephant, ChessType.Knight, ChessType.Rook};
    local pawnLine = {ChessType.Pawn, ChessType.None, ChessType.Pawn, ChessType.None, ChessType.Pawn, ChessType.None, ChessType.Pawn,
        ChessType.None, ChessType.Pawn};
    local cannonLine = {ChessType.None, ChessType.Cannon, ChessType.None, ChessType.None, ChessType.None, ChessType.None, ChessType.None,
        ChessType.Cannon, ChessType.None};
    --设置初始棋盘
    for i = 1, gameMap_W do
        --gameMap[i] = {};
        gameMap[i].chessType = baseLine[i];
        gameMap[i].chessColor = PlayerColor.Red;
        --gameMap[(gameMap_H-1)*gameMap_W+i] = {};
        gameMap[(gameMap_H-1)*gameMap_W+i].chessType = baseLine[i];
        gameMap[(gameMap_H-1)*gameMap_W+i].chessColor = PlayerColor.Black;

        --gameMap[i+2*gameMap_W] = {};
        gameMap[i+2*gameMap_W].chessType = cannonLine[i];
        if gameMap[i+2*gameMap_W].chessType ~= ChessType.None then
            gameMap[i+2*gameMap_W].chessColor = PlayerColor.Red;
        end
        --gameMap[(gameMap_H-3)*gameMap_W+i] = {};
        gameMap[(gameMap_H-3)*gameMap_W+i].chessType = cannonLine[i];
        if gameMap[(gameMap_H-3)*gameMap_W+i].chessType ~= ChessType.None then
            gameMap[(gameMap_H-3)*gameMap_W+i].chessColor = PlayerColor.Black;
        end

        --gameMap[i+3*gameMap_W] = {};
        gameMap[i+3*gameMap_W].chessType = pawnLine[i];
        if gameMap[i+3*gameMap_W].chessType ~= ChessType.None then
            gameMap[i+3*gameMap_W].chessColor = PlayerColor.Red;
        end
        --gameMap[(gameMap_H-4)*gameMap_W+i] = {};
        gameMap[(gameMap_H-4)*gameMap_W+i].chessType = pawnLine[i];
        if gameMap[(gameMap_H-4)*gameMap_W+i].chessType ~= ChessType.None then
            gameMap[(gameMap_H-4)*gameMap_W+i].chessColor = PlayerColor.Black;
        end
    end

    for i = 1, gameMap_W*gameMap_H do
        if i < 46 then
            setVar(args, "c", "v"..i, ChessTypeHStr["None"]);
        else
            setVar(args, "c", "v"..i, ChessTypeAStr["None"]);
        end
    end
    for i = 1, gameMap_W*gameMap_H do
        local tmpItem = gameMap[i];
        if tmpItem.chessColor == PlayerColor.Red then
            setVar(args, "c", "v"..i, ChessTypeHStr[tmpItem.chessType]);
        elseif tmpItem.chessColor == PlayerColor.Black then
            setVar(args, "c", "v"..i, ChessTypeAStr[tmpItem.chessType]);
        end
    end

    for i = 1, gameMap_W*gameMap_H do
        setVar(args, "c", "c"..i, PlayerColor.None);
    end
    for i = 1, gameMap_W*gameMap_H do
        local tmpItem = gameMap[i];
        if tmpItem.chessColor == PlayerColor.Red then
            setVar(args, "c", "c"..i, PlayerColor.Red);
        elseif tmpItem.chessColor == PlayerColor.Black then
            setVar(args, "c", "c"..i, PlayerColor.Black);
        end
    end
end

initMap();