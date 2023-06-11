local greopop = require("grepop")

describe("setup", function()
  it("Setup works", function()
    greopop.setup()
    assert(_G.telescope_grep_op, "Operator Exists")
    assert(_G.telescope_grep_all_op, "All Operator Exists")
  end)
end)
