local M = {
  lang = 'en_US',
  ch = -1,
}

local function split(s, sep)
  local fields = {}

  sep = sep or " "
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

local function show_suggestions(suggestions)
  print(vim.inspect(suggestions))
end

function M.on_attach()
  M.ch = vim.fn.jobstart('hunspell -a -d '..M.lang, {
    on_stdout = function(_, data)
      data = require('tb/utils/job').handle_data(data)
      if not data then
        return
      end
      local output = data[1]
      if not output:match("^@%(#%)") then
        if output:match("^&") then
          show_suggestions(split(output:gsub("(.*): (.*)", "%2"), ", "))
        end
      end
    end
  })
end

function M.on_exit()
  vim.defer_fn(function()
    vim.fn.jobstop(M.ch)
  end, 1000)
end

function M.check(to_test)
  if M.ch <= 0 then
    print('[spell] command not ready or failed') return
  end
  vim.fn.chansend(M.ch, to_test.."\n")
end

M.on_attach()
M.check('teft')
M.on_exit()

return M
