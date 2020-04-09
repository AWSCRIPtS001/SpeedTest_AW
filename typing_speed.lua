local SpeedTest = gui.Tab(gui.Reference("Misc"), "speedtest.tab", "SpeedTest")
local correct_words_label =  gui.Text( SpeedTest, 'Correct words: 0')
local incorrect_words_label =  gui.Text( SpeedTest, 'Incorrect words: 0')
local wpm_label =  gui.Text( SpeedTest, 'WPM: 0')

local minutes_slider = gui.Slider( SpeedTest, "speedtest.slider", "Amount of minutes to for", 1, 1, 30 )

local user_input = gui.Editbox( SpeedTest, "SpeedTest.input", '')

local odrawText = draw.Text




function draw.Text(x, y, text, custom) -- custom cuz idk if this will override other scripts, But I think so
  if not custom then
    odrawText(x,y,text)
    return
  end

  return {
    text = text,
    x = x,
    y = y,
    draw = function() odrawText(x, y, text) end
  }
end


local text_font = draw.CreateFont("Verdana", 77);

function string_to_chars(_string)
  local chars = {}
  if _string then
    for char in _string:gmatch(".") do
      table.insert(chars, char)
    end
  end
  return chars
end

function draw.AwesomeText(x,y,text,font)
  if font then
    draw.SetFont(font)
  end

  local text_size_total = 0
  local chars = {}
  local text_chars = string_to_chars(text)
  for k, char in pairs(text_chars) do
    -- print(char)
    local text_size_x, text_size_h = draw.GetTextSize(char)
    table.insert(chars, draw.Text(text_size_total + x, y, char, true))
    text_size_total = text_size_total + text_size_x
  end

  return chars
end



local words = {}
for word in file.Open("common_words.txt", "r"):Read():gmatch("[^\r\n]+") do
    table.insert(words, word)
end

local buffer_line_1 = {}
local buffer_line_2 = {}

function seed_line_buffers()
  for i=0, 5 do
    table.insert(buffer_line_1, words[math.random( #words )])
  end
end
seed_line_buffers()

local current_word =  words[math.random( #words )]
local text_font = draw.CreateFont("Verdana", 36);
local start_game_font = draw.CreateFont("Verdana", 16);
local info_font = draw.CreateFont("Verdana", 16);



local old_user_input = ''
local total_chars_entered = 0
local total_keystrokes = 0
local total_words_submitted = 0

local game_in_progress = false
local game_start_time = 0
local game_end_time = 0

local number_of_correct_words = 0
local number_of_incorrect_words = 0
-- Number_of_keystroke / time_in_second * 60 * percentages_of_accurate_word

callbacks.Register("Draw", function()

  if user_input:GetValue() ~= old_user_input then
    total_chars_entered = total_chars_entered + 1
    old_user_input = user_input:GetValue()
  end


  local screenW, screenH = draw.GetScreenSize();
  if globals.CurTime() - game_end_time > 5 then -- set disabled doesn't work when textentry is already focused by user
    user_input:SetDisabled(false)
    user_input:SetInvisible(false)
  else
    user_input:SetDisabled(true)
    user_input:SetInvisible(true)
  end
  draw.Color(0,0,0)

  draw.FilledRect(screenW * 0.30, screenH * 0.085, screenW * 0.40, screenH * 0.1)
  draw.FilledRect(screenW * 0.30, screenH * 0.10, screenW * 0.40, screenH * 0.13)
  draw.Color(255,0,0)
  local WPM = math.floor(total_chars_entered / 5)
  local Percentage = number_of_correct_words  / total_words_submitted

  local chars = draw.AwesomeText(screenW * 0.30, screenH * 0.085, "WPM: " .. math.floor(WPM * Percentage))
  for k, char in pairs(chars) do
    draw.Color(255,255,255)
    if char.text ~= "W" and char.text ~= "P" and char.text ~= "M" and char.text ~= ":" and char.text ~= " " then
      draw.Color(0,255,0, 255)
    end
    char.draw()
  end
  draw.Color(255,255,51, 255)
  
  wpm_label:SetText("WPM: " .. math.floor(WPM * Percentage))


  if not game_in_progress then
    local chars = draw.AwesomeText(screenW * 0.30, screenH * 0.10, "Begin space typing to start", start_game_font)
    for k, char in pairs(chars) do
      draw.Color(255,255,255)

      if char.text == "B" then
        draw.Color(255,0,0)
      end
      char.draw()
    end
    if string.len(user_input:GetValue()) > 0 then

      game_in_progress = true
      user_input:SetValue("")
      game_start_time = globals.CurTime()
      math.randomseed(globals.CurTime())
      number_of_correct_words = 0
      total_words_submitted = 0
      total_chars_entered = 0

    end
    return
  end
  draw.SetFont(start_game_font)
  draw.Text(screenW * 0.39, screenH * 0.085, math.floor(globals.CurTime() - game_start_time))
  draw.SetFont(text_font)

  if globals.CurTime() - game_start_time > 60 * minutes_slider:GetValue() then
    user_input:SetValue("")
    game_in_progress = false
    game_end_time = globals.CurTime()
  end
  
  local chars = draw.AwesomeText(screenW * 0.30, screenH * 0.10, current_word)
  for i, char in ipairs(chars) do
    draw.Color(255,255,255)
    local input_chars = string_to_chars(user_input:GetValue())
    for i2, input_char in ipairs(input_chars) do 
      if chars[i].text == input_chars[i2] and i == i2 then
        draw.Color(0,255,0)
      elseif i == i2 then
        draw.Color(255,0,0)
      end

      if string.match(user_input:GetValue(), " ") and string.gsub(user_input:GetValue(), " ", "") == current_word then
        current_word =  words[math.random( #words )]
        user_input:SetValue("")
        number_of_correct_words = number_of_correct_words + 1
        correct_words_label:SetText("Correct words: " .. number_of_correct_words)
        total_words_submitted = total_words_submitted + 1
      elseif string.match(user_input:GetValue(), " ") then
        current_word =  words[math.random( #words )]
        user_input:SetValue("")
        number_of_incorrect_words = number_of_incorrect_words + 1
        incorrect_words_label:SetText("Incorrect words:" .. number_of_incorrect_words)
        total_words_submitted = total_words_submitted + 1
      end
    end
    char.draw()
  end
end)

