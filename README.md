# c_template — CUDA + C 開發範本 

## 簡介 
這是一個 **CUDA + C** 開發範本，目標是提供一個可編譯的專案結構，讓你快速開始開發包含 CPU（C）與 GPU（CUDA）的程式。README 以中文說明如何建置、執行、以及如何擴充範本。

---

## 專案結構（重點檔案）
- `Makefile` — 標準化的建置規則（使用 `gcc` 與 `nvcc`）
- `main.c` — 範例主程式（Host）
- `alg.c`, `alg.h` — 範例 C 模組
- `gpu/` — 放置所有 CUDA 原始檔（`.cu`）與標頭（`.cuh`），範例：`gpu/simd.cu`, `gpu/simd.cuh`
- `build/` — 中間檔（object files）與暫存檔（由 `make` 產生）
- `main_app` — 預設輸出執行檔名稱（由 Makefile 產生）

---

## 先決條件
- GNU Make
- `gcc`（支援 C99）
- NVIDIA CUDA Toolkit（含 `nvcc`）與對應驅動

---

## 快速開始（範例指令）
1. 建置：

```bash
make
```

2. 執行：

```bash
make run
# 或直接執行 ./main_app
```

3. 清除中間檔：

```bash
make clean
```

---

## 如何新增/擴充程式碼
- 新增 C 檔案：
  - 把 `*.c` 放在專案根目錄（或合適子目錄），並在 `Makefile` 的 `C_SRCS` 變數中加入檔名，例如：`C_SRCS := main.c alg.c new_module.c`。
- 新增 CUDA 檔案：
  - 把 `*.cu` 放到 `gpu/`，並在 `Makefile` 的 `CU_SRCS` 中加入，例如：`CU_SRCS := $(GPU_DIR)/simd.cu $(GPU_DIR)/new_kernel.cu`。
  - 若你的專案包含多個 `.cu` 且需要分別編譯與連結（separate compilation），請在 `Makefile` 的 `NVCCFLAGS` 加上 `-dc`。

---

## 可調整的常見設定
- CUDA 架構：`Makefile` 中的 `CUDA_ARCH`（預設範例如 `-arch=sm_89`），若不確定可移除交給 `nvcc` 選擇預設。
- 若 `nvcc` 找不到，請設定 `CUDA_PATH` 環境變數或把 CUDA bin 加到 `PATH` 中（`CUDA_PATH ?= /usr/local/cuda`）。

---

## 注意事項
- `Makefile` 目前使用 `NVCC` 來連結所有物件檔（C + CUDA），以避免連結時找不到 CUDA runtime 的情況。
- Makefile 註解提到 `-dc`（relocatable device code），但預設 `NVCCFLAGS` 並未包含 `-dc`：如果你需要將多個 `.cu` 個別編譯（使用 separate compilation），請把 `-dc` 加入 `NVCCFLAGS`（例如 `NVCCFLAGS := -O3 -dc $(CUDA_ARCH)`）。

---

## 範例開發流程
1. 新增或修改 C/CUDA 檔
2. 更新 `C_SRCS` / `CU_SRCS`（如有必要）
3. `make` → `make run` → 驗證結果
