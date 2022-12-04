mazeTable = {}
visitedStack = {}
mazeHeight = 0
mazeWidth = 0

moveDirections = {
   {-1, 0}, -- N
   {0, 1}, -- E
   {1, 0}, -- S
   {0, -1} -- W
}

function saveMaze(path)
   local fs = io.open(path, 'w')

   local h = mazeHeight*2 + 1
   local w = mazeWidth*2 + 1

   local outputMaze = {}
   
   for i=1,h,1 do
      outputMaze[i] = {}
      for j=1,w,1 do
	 outputMaze[i][j] = '#'
      end
   end

   for idx1, v1 in ipairs(mazeTable) do
      for idx2, v2 in ipairs(v1) do
	 print(v2)
	 outputMaze[idx1*2][idx2*2] = '.'
	 outputMaze[idx1*2 + v2.move[1]][idx2*2 + v2.move[2]] = '.'
      end
   end

   for k1, v1 in pairs(outputMaze) do
      for k2, v2 in pairs(v1) do
	 fs:write(v2)
      end
      fs:write('\n')
   end
   
   fs:close()
end

function createBlankMaze(height, width)
   mazeHeight = height
   mazeWidth = width
   
   for i=1, height, 1 do
      mazeTable[i] = {}
      for j=1, width, 1 do
	 mazeTable[i][j] = {pos={r=i, c=j}, move={}}
      end
   end
end

function getAvailableMoves(node)
   local flags = {true,true,true,true}
   local availableMoves = {}
   local lastMove = node.move
   local currPos = node.pos
   
   for i=1, #moveDirections, 1 do
      local skip = false
      local md = moveDirections[i]
      local newPos = {r=currPos.r+md[1], c=currPos.c+md[2]}
      print("newPos", "r="..newPos.r, "c="..newPos.c)

      -- CHECK: last move
      if not skip and md[1] == lastMove[1] and md[2] == lastMove[2] then
	 flags[i] = false
	 skip = true
      end

      -- CHECK: boundries
      if not skip and (newPos.r < 1 or newPos.c < 1 or newPos.r > mazeHeight or newPos.c > mazeWidth) then
	 flags[i] = false
	 skip = true
      end
      
      -- CHECK: visited
      for k, v in pairs(visitedStack) do
	 if not skip and v.r == newPos.r and v.c == newPos.c then
	    flags[i] = false
	    skip = true
	 end
      end
   end

   for k, v in pairs(flags) do
      if v then
	 table.insert(availableMoves, k)
      end
   end

   return availableMoves
end


steps = 0
function generateMaze(pos, madeMove)
   print("------- Iteration "..(steps+1).." -------")
   mazeTable[pos.r][pos.c].move = madeMove

   -- add to stack current node
   table.insert(visitedStack, mazeTable[pos.r][pos.c].pos)

   -- get available moves
   local availableMoves = getAvailableMoves(mazeTable[pos.r][pos.c])
   if #availableMoves == 0 then
      table.remove(visitedStack)
      return nil
   end
   for k, v in pairs(availableMoves) do
      print("idx="..k, v)
   end
   -- draw one from them
   local nextMove = moveDirections[availableMoves[math.random(1,#availableMoves)]]
   -- use the move and go to another node
   steps = steps + 1
   generateMaze({r=pos.r+nextMove[1], c=pos.c+nextMove[2]}, nextMove)
end

createBlankMaze(10, 10)
math.randomseed(os.time())
generateMaze({r=1, c=1}, moveDirections[1])
saveMaze("maze.txt")
