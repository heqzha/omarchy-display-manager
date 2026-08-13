const fs = require("fs")
const vm = require("vm")
const assert = require("assert")

const path = require("path")
const source = fs.readFileSync(path.join(__dirname, "../DisplayModel.js"), "utf8")
  .replace(/^\.pragma library\s*/m, "")
const context = { JSON, Math, Number, String, Array, Object, isFinite }
vm.createContext(context)
vm.runInContext(source, context)

assert.deepStrictEqual(Array.from(context.resolutions(["1920x1080@60", "1920x1080@144", "2560x1440@60"])), ["1920x1080", "2560x1440"])
assert.strictEqual(context.nearestMode(["1920x1080@60", "1920x1080@144"], "1920x1080", 120), "1920x1080@144")
assert.strictEqual(context.logicalSize({ mode: "3840x2160@60", scale: 2, transform: 0 }).width, 1920)
assert.strictEqual(context.logicalSize({ mode: "1920x1080@60", scale: 1, transform: 1 }).width, 1080)
assert.strictEqual(context.hasOverlap([
  { mode: "1920x1080@60", scale: 1, transform: 0, x: 0, y: 0 },
  { mode: "1920x1080@60", scale: 1, transform: 0, x: 1800, y: 0 }
]), true)
assert.strictEqual(context.hasOverlap([
  { mode: "1920x1080@60", scale: 1, transform: 0, x: 0, y: 0 },
  { mode: "1920x1080@60", scale: 1, transform: 0, x: 1920, y: 0 }
]), false)
assert.deepStrictEqual(Array.from(context.validScales("1920x1080@60")), [1, 1.25, 1.5, 1.6, 2, 2.5, 3, 4])

console.log("DisplayModel tests passed")
