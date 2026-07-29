#!/usr/bin/env texlua
-- Recover a straight-alpha PNG from matched black- and white-background
-- Asymptote renders.  texlua and its zlib module are provided by TeX Live.

local zlib = require("zlib")

local black_path, white_path, output_path = arg[1], arg[2], arg[3]
if not output_path then
  io.stderr:write(
    "usage: texlua recover_asymptote_alpha.lua BLACK.png WHITE.png OUTPUT.png\n"
  )
  os.exit(2)
end

local png_signature = "\137PNG\r\n\26\n"

local function read_file(path)
  local file, message = io.open(path, "rb")
  if not file then error(message) end
  local data = file:read("*a")
  file:close()
  return data
end

local function write_file(path, data)
  local file, message = io.open(path, "wb")
  if not file then error(message) end
  assert(file:write(data))
  file:close()
end

local function decode_png(path)
  local png = read_file(path)
  assert(png:sub(1, 8) == png_signature, path .. ": invalid PNG signature")

  local position = 9
  local width, height, bit_depth, color_type, interlace
  local compressed = {}

  while position <= #png do
    local length
    length, position = string.unpack(">I4", png, position)
    local chunk_type = png:sub(position, position + 3)
    position = position + 4
    local chunk_data = png:sub(position, position + length - 1)
    position = position + length + 4 -- Skip data and CRC.

    if chunk_type == "IHDR" then
      width, height, bit_depth, color_type, _, _, interlace =
        string.unpack(">I4I4BBBBB", chunk_data)
    elseif chunk_type == "IDAT" then
      compressed[#compressed + 1] = chunk_data
    elseif chunk_type == "IEND" then
      break
    end
  end

  assert(width and height, path .. ": missing IHDR chunk")
  assert(bit_depth == 8, path .. ": only 8-bit PNG input is supported")
  assert(color_type == 2 or color_type == 6,
         path .. ": only RGB and RGBA PNG input is supported")
  assert(interlace == 0, path .. ": interlaced PNG input is unsupported")

  local channels = color_type == 6 and 4 or 3
  local stride = width * channels
  local filtered = zlib.decompress(table.concat(compressed))
  assert(#filtered == height * (stride + 1), path .. ": invalid image data size")

  local rows = {}
  local previous = {}
  local source = 1

  local function paeth(left, above, upper_left)
    local estimate = left + above - upper_left
    local left_distance = math.abs(estimate - left)
    local above_distance = math.abs(estimate - above)
    local diagonal_distance = math.abs(estimate - upper_left)
    if left_distance <= above_distance and left_distance <= diagonal_distance then
      return left
    elseif above_distance <= diagonal_distance then
      return above
    end
    return upper_left
  end

  for row_index = 1, height do
    local filter = filtered:byte(source)
    source = source + 1
    local row = {}
    for column = 1, stride do
      local value = filtered:byte(source)
      source = source + 1
      local left = column > channels and row[column - channels] or 0
      local above = previous[column] or 0
      local upper_left = column > channels and (previous[column - channels] or 0) or 0

      if filter == 1 then
        value = value + left
      elseif filter == 2 then
        value = value + above
      elseif filter == 3 then
        value = value + math.floor((left + above) / 2)
      elseif filter == 4 then
        value = value + paeth(left, above, upper_left)
      elseif filter ~= 0 then
        error(path .. ": unsupported PNG filter " .. filter)
      end
      row[column] = value % 256
    end
    rows[row_index] = row
    previous = row
  end

  return {
    width = width,
    height = height,
    channels = channels,
    rows = rows,
  }
end

local function png_chunk(chunk_type, data)
  local payload = chunk_type .. data
  local crc = zlib.crc32(0, payload) % 0x100000000
  return string.pack(">I4", #data) .. payload .. string.pack(">I4", crc)
end

local function encode_rgba(path, width, height, scanlines)
  local header = string.pack(">I4I4BBBBB", width, height, 8, 6, 0, 0, 0)
  local png = png_signature
    .. png_chunk("IHDR", header)
    .. png_chunk("IDAT", zlib.compress(table.concat(scanlines)))
    .. png_chunk("IEND", "")
  write_file(path, png)
end

local black = decode_png(black_path)
local white = decode_png(white_path)
assert(black.width == white.width and black.height == white.height,
       "render sizes differ")

local output = {}
for row_index = 1, black.height do
  local black_row = black.rows[row_index]
  local white_row = white.rows[row_index]
  local scanline = {"\0"} -- PNG filter type None.
  local black_column = 1
  local white_column = 1

  for _ = 1, black.width do
    local br, bg, bb = black_row[black_column],
                       black_row[black_column + 1],
                       black_row[black_column + 2]
    local wr, wg, wb = white_row[white_column],
                       white_row[white_column + 1],
                       white_row[white_column + 2]
    local background = math.max(wr - br, wg - bg, wb - bb)
    local alpha = math.max(0, math.min(255, 255 - background))
    local red, green, blue = 0, 0, 0

    if alpha > 0 then
      red = math.min(255, math.floor(br * 255 / alpha + 0.5))
      green = math.min(255, math.floor(bg * 255 / alpha + 0.5))
      blue = math.min(255, math.floor(bb * 255 / alpha + 0.5))
    end
    scanline[#scanline + 1] = string.char(red, green, blue, alpha)
    black_column = black_column + black.channels
    white_column = white_column + white.channels
  end
  output[row_index] = table.concat(scanline)
end

encode_rgba(output_path, black.width, black.height, output)
