-- 建立一張 table（表），作為這個 module 對外公開的物件。
-- Lua 的 table 類似 JavaScript 的 object / Swift 的 Dictionary，
-- 也常被用來當作 namespace。
local debug_print = {}


-- 對外公開的設定值。
-- 呼叫端可用 debug_print.enabled = false 關閉所有 log。
debug_print.enabled = true

-- 要顯示在每一行 log 前面的 emoji。
-- 呼叫端也可以隨時更改，例如：debug_print.emoji = "🐛"
debug_print.emoji = "✅"


-- 定義 debug_print 的 print 函式。
-- `function debug_print.print(...)` 等同於：
--
-- debug_print.print = function(...)
--     ...
-- end
--
-- `...` 表示可變數量的參數（varargs）。
-- 因此以下呼叫都可以：
--
-- debug_print.print("init")
-- debug_print.print("position:", x, y)
-- debug_print.print("player:", self)
function debug_print.print(...)
	-- 若開關關閉，立刻結束函式，不進行後續處理或輸出。
	if not debug_print.enabled then
		return
	end


	-- 取得呼叫這個函式的位置資訊。
	--
	-- `2` 是呼叫堆疊層級：
	--   1 = debug_print.print 這個函式本身
	--   2 = 外部呼叫 debug_print.print(...) 的那行程式碼
	--
	-- `"Sl"` 表示只要求這些資訊：
	--   S = source / short_src，來源檔案資訊
	--   l = currentline，目前執行到的行號
	local info = debug.getinfo(2, "Sl")


	-- `or` 類似 Swift 的 `??`：
	-- 如果左邊是 nil 或 false，就改用右邊的值。
	--
	-- 優先使用 short_src（通常較短、較適合顯示的檔案路徑）。
	-- 若 short_src 沒有值，就使用 source。
	-- 若兩者都沒有，就顯示問號。
	local file = info.short_src or info.source or "?"


	-- 取得呼叫端行號。
	-- 若沒有行號資訊，就使用 0。
	local line = info.currentline or 0


	-- 建立空 table，用來存每個要輸出的參數。
	--
	-- 例如：
	-- debug_print.print("score", 100, true)
	--
	-- 最後 parts 會是：
	-- { "score", "100", "true" }
	local parts = {}


	-- `select("#", ...)` 取得 `...` 裡實際傳入的參數數量。
	--
	-- 例如：
	-- debug_print.print("x", 10, true)
	-- 這裡的結果是 3。
	for i = 1, select("#", ...) do
		-- `select(i, ...)` 取得第 i 個傳入參數。
		--
		-- tostring() 把 number、boolean、table 等值轉成字串，
		-- 讓 table.concat 可以安全地把它們串起來。
		parts[i] = tostring(select(i, ...))
	end


	-- 將 parts 裡的字串，以 Tab 字元 "\t" 串成一段訊息。
	--
	-- 例如：
	-- { "score", "100", "true" }
	--
	-- 會變成：
	-- "score\t100\ttrue"
	local msg = table.concat(parts, "\t")


	-- string.format 類似 Swift 的 String(format:)。
	--
	-- %s = 字串
	-- %d = 整數
	--
	-- 格式字串：
	-- "%s [%s:%d] %s"
	--
	-- 輸出範例：
	-- ✅ [main/player/player.script:40] init
	print(string.format(
	"%s [%s:%d] %s",
	debug_print.emoji,
	file,
	line,
	msg
))
end


-- 回傳這張 table，讓 require() 的呼叫端取得這個 module。
--
-- 在其他檔案：
--
-- local dprint = require("utility.debug_print")
-- dprint.print("init")
return debug_print