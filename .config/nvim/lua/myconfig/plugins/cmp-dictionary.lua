local cmp_dict = require("cmp_dictionary")
local dict_root = string.format("%s/dict/", vim.fn.stdpath("config"))

-- get fullpath
local F = function (filename)
  return dict_root..filename
end

cmp_dict.setup({
  first_case_insensitive = true,
  async = true,
})

cmp_dict.switcher({
  filepath = {
    ["*"] = {
      F"global.dic",
    },
  },
  spelllang = {
    en = F"en.dic",
  },
})

