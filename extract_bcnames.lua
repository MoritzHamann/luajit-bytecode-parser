-- this file extracts the (machine dependent) offsets for the bytecodes from the
-- "vmdef.lua" file, which is distributed with luajit installation.
-- Normally it resides in the /jit subfolder of the luajit installation folder

function printCallingConvention()
  print("")
  print("\tRun with: luajit [.]\n")
  print("The first parameter is the output directory (if none is provided the current working directory is used)")
end

-- simple split function (wrapper around string.gmatch)
function split(str, pattern)
  local result = {}
  for i in str:gmatch(pattern) do
    table.insert(result, i)
  end
  return result
end

-- simple trim function
function trim(str)
  return str:match "^%s*(.-)%s*$"
end

-- split the bcnames file into chunks of 6 chars and trim the results
function splitBCnames(bcnames)
  local length = bcnames:len()
  local result = {}
  local step = 6

  for i = 1, length, step do
    local bc = bcnames:sub(i, i + step - 1)
    table.insert(result, trim(bc))
  end

  return result
end


local inFilename = arg[1]
local outFilename = arg[2]

-- if no output directory is given, use the current working directory
if outFilename == nil then
  outFilename = "."
end

print("-> Trying to extract the bytecode names and offsets from jit/vmdef.lua and writing it to "..outFilename.. "/bcnames.py")

-- try to require the provided path
local status, vmdef = pcall(require, 'jit.vmdef')

-- if not successful try loadfile
if not status then
  print("-> require not successful, trying setting LUA_PATH correctly")
  printCallingConvention()
  return
end

print("-> input file found, extracting bytecode information")

-- get bcnames and split them
if not vmdef.bcnames then
  print("-> input file does not provide the bcnames variable, may wrong file?")
  printCallingConvention()
  return
end

-- split bcnames and open outputfile
local bcnames = splitBCnames(vmdef.bcnames)

-- wrapp strings in ''
for i, w in pairs(bcnames) do
  bcnames[i] = "'"..w.."'"
end

print("-> writing output file")

-- open file and output the table as a python array
local outputFile = io.open(outFilename.."/bcnames.py", "w")
outputFile:write("bcnames = [")
outputFile:write(table.concat(bcnames, ", "))
outputFile:write("]")

print("-> successful write to "..outFilename.."/bcnames.py")
