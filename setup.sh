#!/bin/bash
set -e

echo "======================================================================"
echo "🚀 ComfyUI Auto Setup Script for QWEN Workflow"
echo "======================================================================"

# --- Определяем пути ---
if [ -d "/workspace/runpod-slim/ComfyUI" ]; then
    COMFY_DIR="/workspace/runpod-slim/ComfyUI"
elif [ -d "/workspace/ComfyUI" ]; then
    COMFY_DIR="/workspace/ComfyUI"
else
    echo "❌ ComfyUI не найден!"
    exit 1
fi

CUSTOM_NODES="$COMFY_DIR/custom_nodes"
WORKFLOWS_DIR="$COMFY_DIR/user/default/workflows"
GITHUB_RAW="https://raw.githubusercontent.com/ivantey/runPodComfyPipeline/master"

echo "✅ ComfyUI: $COMFY_DIR"


# ============================================================
# 1. COMFYUI MANAGER
# ============================================================
echo ""
echo "📦 [1/5] ComfyUI Manager..."

if [ ! -d "$CUSTOM_NODES/ComfyUI-Manager" ]; then
    cd "$CUSTOM_NODES"
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    pip install -q -r ComfyUI-Manager/requirements.txt
    echo "   ✅ Установлен"
else
    echo "   ✅ Уже есть"
fi

# ============================================================
# 2. CUSTOM NODES
# ============================================================
echo ""
echo "📦 [2/5] Custom Nodes..."

cd "$CUSTOM_NODES"

install_node() {
    local name=$1
    local url=$2
    if [ ! -d "$name" ]; then
        echo "   ⬇️  $name"
        git clone "$url" 2>/dev/null || echo "   ⚠️  Ошибка: $name"
    else
        echo "   ✅ $name"
    fi
}

install_node "ComfyUI_LayerStyle" "https://github.com/chflame163/ComfyUI_LayerStyle.git"
install_node "rgthree-comfy" "https://github.com/rgthree/rgthree-comfy.git"
install_node "ComfyUI-Easy-Use" "https://github.com/yolain/ComfyUI-Easy-Use.git"
install_node "was-node-suite-comfyui" "https://github.com/WASasquatch/was-node-suite-comfyui.git"


# ============================================================
# 3. ЗАВИСИМОСТИ (через cm-cli)
# ============================================================
echo ""
echo "📦 [3/5] Зависимости..."

cd "$COMFY_DIR"

if [ -f "$CUSTOM_NODES/ComfyUI-Manager/cm-cli.py" ]; then
    echo "   Запускаю cm-cli restore-dependencies..."
    python3 "$CUSTOM_NODES/ComfyUI-Manager/cm-cli.py" restore-dependencies 2>&1 | tail -30 || true
    echo "   ✅ Готово"
else
    echo "   Устанавливаю вручную..."
    for dir in "$CUSTOM_NODES"/*/; do
        if [ -f "$dir/requirements.txt" ]; then
            pip install -q -r "$dir/requirements.txt" 2>/dev/null || true
        fi
    done
    echo "   ✅ Готово"
fi


# ============================================================
# 4. МОДЕЛИ QWEN (~6.5GB)
# ============================================================
echo ""
echo "📥 [4/5] Модели QWEN..."

cd "$COMFY_DIR/models"

# Text Encoder
echo "   📦 Text Encoder..."
mkdir -p text_encoders && cd text_encoders
[ ! -f "qwen_2.5_vl_7b_fp8_scaled.safetensors" ] && \
    wget -q --show-progress "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
cd "$COMFY_DIR/models"

# VAE
echo "   📦 VAE..."
mkdir -p vae && cd vae
[ ! -f "qwen_image_vae.safetensors" ] && \
    wget -q --show-progress "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors"
cd "$COMFY_DIR/models"

# UNET
echo "   📦 UNET (5GB)..."
mkdir -p unet && cd unet
[ ! -f "qwen_image_edit_2509_fp8_e4m3fn.safetensors" ] && \
    wget -q --show-progress "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors"
cd "$COMFY_DIR/models"

# LoRA
echo "   📦 LoRA..."
mkdir -p loras && cd loras
[ ! -f "Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors" ] && \
    wget -q --show-progress "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Edit-2509/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors"
[ ! -f "consistence_edit_v2.safetensors" ] && \
    wget -q --show-progress "https://huggingface.co/hoveyc/comfyui-models/resolve/main/loras/qwen-image-edit/consistence_edit_v2.safetensors"

echo "   ✅ Модели готовы"


# ============================================================
# 5. WORKFLOW
# ============================================================
echo ""
echo "📥 [5/5] Workflow..."

mkdir -p "$WORKFLOWS_DIR"
cd "$WORKFLOWS_DIR"

if [ ! -f "QWEN_batch_3.json" ]; then
    wget -q "$GITHUB_RAW/workflows/QWEN_batch_3.json" && echo "   ✅ Скачан" || echo "   ⚠️  Ошибка"
else
    echo "   ✅ Уже есть"
fi

# ============================================================
# ПРОВЕРКА
# ============================================================
echo ""
echo "🔍 Проверка файлов..."

check() { [ -f "$1" ] && echo "   ✅ $(basename $1)" || echo "   ❌ $(basename $1)"; }

check "$COMFY_DIR/models/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
check "$COMFY_DIR/models/vae/qwen_image_vae.safetensors"
check "$COMFY_DIR/models/unet/qwen_image_edit_2509_fp8_e4m3fn.safetensors"
check "$COMFY_DIR/models/loras/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors"
check "$COMFY_DIR/models/loras/consistence_edit_v2.safetensors"
check "$WORKFLOWS_DIR/QWEN_batch_3.json"

echo ""
echo "======================================================================"
echo "🎉 ГОТОВО! Открой ComfyUI → Load → QWEN_batch_3.json"
echo "======================================================================"
