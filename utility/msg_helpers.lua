-- msg_helpers.lua
--
-- 集中管理專案中常用的 msg.post 呼叫，
-- 提供統一的 TARGET / COMMAND 常數與高階 helper 函式，
-- 避免在多個 script 中重複寫死字串。

local M = {}

-- ========== 常數 ==========

-- 常用的 msg.post command 名稱
M.COMMAND = {
	-- 要求 render 使用 fixed fit projection（用於自訂 camera/projection 設定）
	USE_FIXED_FIT_PROJECTION = "use_fixed_fit_projection",

	-- 要求當前 component 取得 input focus（例如要開始接收輸入事件）
	ACQUIRE_INPUT_FOCUS      = "acquire_input_focus",

	-- 要求當前 component 釋放 input focus（例如暫停或切換場景時）
	RELEASE_INPUT_FOCUS      = "release_input_focus",
}

-- 常用的 msg.post target
M.TARGET = {
	SELF   = ".",        -- 當前 component
	RENDER = "@render:", -- render 系統
}

-- ========== 通用 helper ==========

-- 對 @render: 發送任意 command
-- @param command string: command 名稱（例如 M.COMMAND.USE_FIXED_FIT_PROJECTION）
-- @param params table?: 要傳的參數 table
local function post_render(command, params)
	msg.post(M.TARGET.RENDER, command, params)
end

-- 對當前 component (".") 發送任意 command（內部使用）
-- @param command string: command 名稱
-- @param params table?: 要傳的參數 table
local function post_self(command)
	msg.post(M.TARGET.SELF, command)
end

-- ========== 高階 helper ==========

-- 泛用的 msg.post 包裝函式
-- 提供統一的進入點，方便未來集中處理 log、除錯或額外邏輯。
--
-- @param target string: msg.post 的 target，例如 ".", "@render:", "#game_object"
-- @param command string: 要發送的 command 名稱
-- @param params table?: 要傳的參數 table，可省略
function M.post(target, command, params)
	msg.post(target, command, params)
end

-- 設定 render 使用 fixed fit projection
-- @param near number: near plane（預設 -1）
-- @param far number: far plane（預設 1）
function M.use_fixed_fit_projection(near, far)
	post_render(M.COMMAND.USE_FIXED_FIT_PROJECTION, {
		near = near or -1,
		far  = far or 1,
	})
end

-- 要求當前 component 取得 input focus
function M.acquire_input_focus()
	post_self(M.COMMAND.ACQUIRE_INPUT_FOCUS)
end

-- 要求當前 component 釋放 input focus
function M.release_input_focus()
	post_self(M.COMMAND.RELEASE_INPUT_FOCUS)
end

return M