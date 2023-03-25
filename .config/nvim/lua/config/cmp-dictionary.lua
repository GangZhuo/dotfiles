local cmp_dict = require("cmp_dictionary")
local utils = require("utils")
local dict_root = string.format("%s/dict/", vim.fn.stdpath("config"))
local opts = {
  dic = {
    ["*"] = { dict_root.."global.dic" },
    spelllang = {
      en = dict_root.."en.dic",
    }
  },
  first_case_insensitive = true,
  async = true,
}
if vim.fn.filereadable(opts.dic.spelllang.en) ~= 1 then
  local msg = string.format(
    "Language dictionary not exists!"
    .."\nRun `aspell -d en dump master | aspell -l en expand > %s` to download it.",
    opts.dic.spelllang.en)
  vim.notify(msg, vim.log.levels.WARN, { title = "Nvim-config" })
end
cmp_dict.setup(opts)
--aspell -d <lang> dump master | aspell -l <lang> expand > my.dict
cmp_dict.update()
