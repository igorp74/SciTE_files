-- 💎💎💎  [HELPER FUNCTIONS START] 💎💎💎

-- 🚀 [Check if selected item numeric]
function is_numeric(x)
    if tonumber(x) ~= nil then
        return true
    end
    return false
end

-- 🚀 [Collect lines]
function lines(str)
  local t = {}
  local i, lstr = 1, #str
  while i <= lstr do
    local x, y = string.find(str, "\r?\n", i)
    if x then t[#t + 1] = string.sub(str, i, x - 1)
    else break
    end
    i = y + 1
  end
  if i <= lstr then t[#t + 1] = string.sub(str, i) end
  return t
end

-- 🚀[ Run shell command with collecting output]
local function cmd_output(cmd, param_string)
    command_str = string.format("%s %s", cmd, param_string or "")

    local handle = io.popen(command_str)
    local match = handle:read("*a")
    return match
end


-- 🚀[ Difference between 2 Lua table structures]
function tbl_diff(a, b)
    local aa = {}
    for k,v in pairs(a) do aa[v]=true end
    for k,v in pairs(b) do aa[v]=nil end
    local ret = {}
    local n = 0
    for k,v in pairs(a) do
        if aa[v] then n=n+1 ret[n]=v end
    end
    return ret
end

-- 💎💎💎  [HELPER FUNCTIONS END] 💎💎💎




-- 🚀  [INSERT DATE]
function InsertDate()
   editor:AddText(os.date("%Y-%m-%d %H:%M:%S"))
end

-- 🚀 [MARK CURRENT WORD]
function clearOccurrences()
    scite.SendEditor(SCI_SETINDICATORCURRENT, 0)
    scite.SendEditor(SCI_INDICATORCLEARRANGE, 0, editor.Length)
end

function markOccurrences()
    if editor.SelectionStart == editor.SelectionEnd then
        return
    end
    clearOccurrences()
    scite.SendEditor(SCI_INDICSETSTYLE, 0, INDIC_ROUNDBOX)
    scite.SendEditor(SCI_INDICSETFORE, 0, 255)
    local txt   = GetCurrentWord()
    local flags = SCFIND_WHOLEWORD
    local s,e = editor:findtext(txt,flags,0)
    while s do
        scite.SendEditor(SCI_INDICATORFILLRANGE, s, e - s)
        s,e = editor:findtext(txt,flags,e+1)
    end
end

function isWordChar(char)
    local strChar = string.char(char)
    local beginIndex = string.find(strChar, '%w')
    if beginIndex ~= nil then
        return true
    end
    if strChar == '_' or strChar == '$' then
        return true
    end

    return false
end

function GetCurrentWord()
    local beginPos = editor.CurrentPos
    local endPos = beginPos
    if editor.SelectionStart ~= editor.SelectionEnd then
        return editor:GetSelText()
    end
    while isWordChar(editor.CharAt[beginPos-1]) do
        beginPos = beginPos - 1
    end
    while isWordChar(editor.CharAt[endPos]) do
        endPos = endPos + 1
    end
    return editor:textrange(beginPos,endPos)
end





-- 🚀 [SORT SELECTED TEXT]
-- Sort ascending
function sort_text()
  local sel = editor:GetSelText()
  if #sel == 0 then return end
  local eol = string.match(sel, "\n$")
  local buf = lines(sel)
  --table.foreach(buf, print) --used for debugging
  table.sort(buf)
  local out = table.concat(buf, "\n")
  if eol then out = out.."\n" end
  editor:ReplaceSel(out)
end

-- Sort descending
function sort_text_reverse()
  local sel = editor:GetSelText()
  if #sel == 0 then return end
  local eol = string.match(sel, "\n$")
  local buf = lines(sel)
  --table.foreach(buf, print) --used for debugging
  table.sort(buf, function(a, b) return a > b end)
  local out = table.concat(buf, "\n")
  if eol then out = out.."\n" end
  editor:ReplaceSel(out)
end


-- 🚀 [REMOVE DUPLICATES]
function remove_duplicates()
  local sel = editor:GetSelText()
  local hash = {}
  local res = {}

  if #sel == 0 then return end

  local eol = string.match(sel, "\n$")
  local buf = lines(sel)

  for _,v in ipairs(buf) do
    if (not hash[v]) then
       res[#res+1] = v
       hash[v] = true
    end
  end

  local out = table.concat(res, "\n")
  if eol then out = out.."\n" end
  editor:ReplaceSel(out)
end


 function underline_text(pos,len,ind)
   local es = editor.EndStyled
   editor:StartStyling(pos,INDIC_BOX)
   editor:SetStyling(len,INDIC_BOX + ind)
 end


-- 🚀 [ LINE ANALYSIS ]
function line_analysis()
    local sel   = editor:GetSelText()
    local hash  = {}
    local hash2 = {}
    local res   = {}
    local dup   = {}

    if #sel == 0 then return end

    local eol = string.match(sel, "\n$")
    local buf = lines(sel)

    for k,v in ipairs(buf) do
        if (not hash[v]) then
           res[#res+1] = v
           hash[v] = true
        else
            if (not hash2[v]) then
                table.insert(dup,v)
                hash2[v] = true
            end
        end
    end

    local unq = tbl_diff(res, dup)

    table.sort(res)
    table.sort(dup)
    table.sort(unq)

    local all_unique   = table.concat(res, "\n")
    local duplicates   = table.concat(dup, "\n")
    local only_unique  = table.concat(unq, "\n")

    if eol then all_unique = all_unique.."\n" end
    if eol then duplicates = duplicates.."\n" end
    if eol then only_unique = only_unique.."\n" end

    print('⚙️ Unique lines')
    print('--------------------')
    print(all_unique)
    print('\n⚖ Duplicate lines')
    print('--------------------------')
    print(duplicates)
    print('\n👍 No duplicates')
    print('----------------------------')
    print(only_unique)
end


-- 🚀 [TRANSPOSE TO LINE FOR SQL]
function transpose_2_line()
  local sel = editor:GetSelText()
  local hash = {}
  local res = {}

  local eol = string.match(sel, "\n$")
  local buf = lines(sel)

  for _,v in ipairs(buf) do
    if (not hash[v]) then
        -- Recognize numbers atextrange
        if is_numeric(v) then
           res[#res+1] = v
        else
           res[#res+1] = "'"..v.."'"
        end

       hash[v] = true
    end
  end

  local out = table.concat(res, ", ")
  if eol then out = out.."\n" end
  editor:ReplaceSel(out)
end


-- 🚀 [TABS TO SPACES]
function tabs_to_spaces_obey_tabstop()
    -- replace one tab tab followed by one or more (space or tab)
    -- but obey tabstops (preserves alignment)
        for m in editor:match("[\\t][\\t ]*", SCFIND_REGEXP) do
            local posColumn = ( scite.SendEditor(SCI_GETCOLUMN, (m.pos ) ) )
            local poslenColumn = ( scite.SendEditor(SCI_GETCOLUMN, (m.pos + m.len) ) )
            m:replace(string.rep(' ', poslenColumn - posColumn ))
		end
end


-- 🚀 [ENCLOSE BRACES AUTOMATICALLY]
local Braces={['[']=']',['\'']='\'',['{']='}',['(']=')',['"']='"'}
OnChar=function(c)
    c=Braces[c]
    if c and editor.Focus then editor:insert(-1,c) end
end


-- 🚀[ PRINT FILTER RESULTS ]
function print_marked_lines()
    local ml = 0
    local lines = {}

    while true do
        ml = editor:MarkerNext(ml, 2)
        if (ml == -1) then break end
        table.insert(lines, (editor:GetLine(ml)))
        ml = ml + 1
    end
    local text = table.concat(lines)
    print(text)
end


-- 🚀 [TRIM LEADING AND TRAILING SPACE AROUND STRING]
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end


-- 🚀 [SPLIT COMMA SEPARATED VALUES]
function split()
    local str = editor:GetSelText()
    local pat = "[^,]*"  -- everything except commas
    local tbl = {}
    str:gsub(pat, function(x) tbl[#tbl+1]=trim(x)..'\n' end)
    local text = table.concat(tbl)
    editor:ReplaceSel(text)
end


-- 🚀 [DELETE EMPTY LINES]
function del_empty_lines()
  local txt = editor:GetText()
  if #txt == 0 then return end
  local chg, n = false
  while true do
    txt, n = string.gsub(txt, "(\r?\n)%s*\r?\n", "%1")
    if n == 0 then break end
    chg = true
  end
  if chg then
    editor:SetText(txt)
    editor:GotoPos(0)
  end
end


-- 🚀[ STRIP TRAILING SPACES]
function stripTrailingSpaces(reportNoMatch)
    local count = 0
    local fs,fe = editor:findtext("[ \\t]+$", SCFIND_REGEXP)
    if fe then
        repeat
            count = count + 1
            editor:remove(fs,fe)
            fs,fe = editor:findtext("[ \\t]+$", SCFIND_REGEXP, fs)
        until not fe
        print("Removed trailing spaces from " .. count .. " line(s).")
    elseif reportNoMatch then
        print("Document was clean already; nothing to do.")
    end
    return count
end


-- 🚀[ FIGLETS]
-- Figlet called from shell command (works in Linux)
function figlet()
    local str = editor:GetSelText()
    res = cmd_output("figlet -f Roman", str)
    editor:ReplaceSel(res)
end
