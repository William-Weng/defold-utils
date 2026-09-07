## Utility

### `debug_print`

帶有 emoji、呼叫端檔案名稱與行號的除錯輸出工具。

它使用 `debug.getinfo()` 取得實際呼叫 `debug_print.print(...)` 的來源位置，讓你在 Defold Console 中快速找到 log 從哪一支 script 印出。

### Import

```lua
local debug_print = require("utility.debug_print")
```

你也可以使用較短的本地名稱：

```lua
local dprint = require("utility.debug_print")
```

### Usage

```lua
local dprint = require("utility.debug_print")

function init(self)
    dprint.print("init")
end

function update(self, dt)
    dprint.print("position:", go.get_position())
    dprint.print("player:", self)
end
```

也可以傳入多個值：

```lua
dprint.print("position:", x, y)
dprint.print("player:", self)
dprint.print("score:", score, "lives:", lives)
```

### Output

輸出格式：

```text
✅ [main/player/player.script:40] init
```

其中：

| 部分 | 說明 |
|---|---|
| `✅` | 可設定的 log emoji |
| `main/player/player.script` | 呼叫 `dprint.print(...)` 的來源 script |
| `40` | 呼叫所在的行數 |
| `init` | 傳給 `dprint.print(...)` 的訊息 |

Defold Console 會再加上自己的輸出前綴：

```text
DEBUG:SCRIPT: ✅ [main/player/player.script:40] init
```

### Configuration

```lua
local dprint = require("utility.debug_print")

-- 關閉所有 debug_print 輸出
dprint.enabled = false

-- 重新開啟
dprint.enabled = true

-- 更換 emoji
dprint.emoji = "🐛"

dprint.print("player initialized")
```

常見 emoji：

```lua
dprint.emoji = "✅" -- 成功／一般流程
dprint.emoji = "🔍" -- 追蹤資料或流程
dprint.emoji = "🐛" -- 除錯
dprint.emoji = "⚠️" -- 警告
dprint.emoji = "❌" -- 錯誤
```

### Example

```lua
local dprint = require("utility.debug_print")

local IDLE = hash("idle")
local WALK = hash("walk")

local function play_animation(self, animation_id)
    if self.current_animation == animation_id then
        return
    end

    self.current_animation = animation_id

    dprint.print("play animation:", animation_id)

    sprite.play_flipbook("#sprite", animation_id)
end

function init(self)
    dprint.print("player initialized")

    play_animation(self, IDLE)
end
```

可能輸出：

```text
DEBUG:SCRIPT: ✅ [main/player/player.script:18] player initialized
DEBUG:SCRIPT: ✅ [main/player/player.script:13] play animation: hash: [idle]
```

## `msg_helpers`

集中管理 Defold 專案中常用的 `msg.post` 呼叫，透過 target、command 常數與高階 helper 函式，減少重複字串並讓訊息用途更容易理解。

### Import

```lua
local msg_helpers = require("utility.msg_helpers")
```

### Targets and commands

`msg_helpers.TARGET` 集中定義常用的訊息目標：

```lua
msg_helpers.TARGET.SELF   -- "."，目前的 script component
msg_helpers.TARGET.RENDER -- "@render:"，Defold render system
```

`msg_helpers.COMMAND` 集中定義常用的 command 名稱：

```lua
msg_helpers.COMMAND.USE_FIXED_FIT_PROJECTION
msg_helpers.COMMAND.ACQUIRE_INPUT_FOCUS
msg_helpers.COMMAND.RELEASE_INPUT_FOCUS
```

### Usage

```lua
local msg_helpers = require("utility.msg_helpers")

function init(self)
    -- 讓目前 component 取得 input focus
    msg_helpers.acquire_input_focus()

    -- 設定 render 的 fixed fit projection
    msg_helpers.use_fixed_fit_projection(-1, 1)
end

function final(self)
    -- 離開或銷毀 component 前釋放 input focus
    msg_helpers.release_input_focus()
end
```

### Available helpers

| 函式 | 說明 |
|---|---|
| `use_fixed_fit_projection(near, far)` | 對 `@render:` 發送 `use_fixed_fit_projection`；`near` 預設為 `-1`，`far` 預設為 `1`。 |
| `acquire_input_focus()` | 對目前 component 發送 `acquire_input_focus`。 |
| `release_input_focus()` | 對目前 component 發送 `release_input_focus`。 |
| `post_render(command, params)` | 對 `@render:` 發送自訂 command 與參數。 |

也可以使用通用的 `post_render`：

```lua
msg_helpers.post_render(
    msg_helpers.COMMAND.USE_FIXED_FIT_PROJECTION,
    { near = -1, far = 1 }
)
```

新增常用 message 時，建議先在 `COMMAND` 中定義 command，再提供一個語意清楚的 helper 函式，讓其他 script 不必直接依賴 command 字串。
