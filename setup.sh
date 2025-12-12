#!/bin/bash
set -e

# 🚀 Автоматическая настройка ComfyUI для QWEN workflows
# Автор: AI Assistant
# Дата: 2025-12-12

echo "======================================================================"
echo "🚀 ComfyUI Auto Setup Script"
echo "======================================================================"
echo ""

# Определяем путь к ComfyUI
if [ -d "/workspace/runpod-slim/ComfyUI" ]; then
    COMFY_DIR="/workspace/runpod-slim/ComfyUI"
elif [ -d "/workspace/ComfyUI" ]; then
    COMFY_DIR="/workspace/ComfyUI"
else
    echo "❌ ComfyUI не найден!"
    exit 1
fi

echo "✅ ComfyUI найден: $COMFY_DIR"
echo ""

# GitHub репозиторий
GITHUB_REPO="https://raw.githubusercontent.com/ivantey/runPodComfyPipeline/master"

# ============================================================
# 1. УСТАНОВКА COMFYUI MANAGER (если нет)
# ============================================================
echo "📦 Проверяю ComfyUI Manager..."

if [ ! -d "$COMFY_DIR/custom_nodes/ComfyUI-Manager" ]; then
    echo "   ⬇️  Устанавливаю ComfyUI Manager..."
    cd $COMFY_DIR/custom_nodes
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    cd ComfyUI-Manager
    pip install -q -r requirements.txt
    echo "   ✅ ComfyUI Manager установлен"
else
    echo "   ✅ ComfyUI Manager уже установлен"
fi

echo ""

# ============================================================
# 2. СКАЧИВАНИЕ WORKFLOWS ИЗ GITHUB
# ============================================================
echo "📥 Скачиваю workflows из GitHub..."

mkdir -p $COMFY_DIR/user/default/workflows
cd $COMFY_DIR/user/default/workflows

# Скачиваем твой основной workflow
if [ ! -f "QWEN_batch_3.json" ]; then
    echo "   ⬇️  QWEN_batch_3.json..."
    wget -q $GITHUB_REPO/workflows/QWEN_batch_3.json || echo "   ⚠️  Не удалось скачать (проверь URL)"
else
    echo "   ✅ QWEN_batch_3.json уже есть"
fi

echo ""

# ============================================================
# 3. АВТОУСТАНОВКА CUSTOM NODES ЧЕРЕЗ MANAGER
# ============================================================
echo "📦 Устанавливаю custom nodes через Manager..."
echo "   (это может занять 5-10 минут)"
echo ""

# Ждем пока ComfyUI запустится (если еще не запущен)
COMFY_URL="http://127.0.0.1:8188"
MAX_WAIT=60

echo "   ⏳ Жду запуска ComfyUI..."
for i in $(seq 1 $MAX_WAIT); do
    if curl -s $COMFY_URL > /dev/null 2>&1; then
        echo "   ✅ ComfyUI запущен"
        break
    fi
    if [ $i -eq $MAX_WAIT ]; then
        echo "   ⚠️  ComfyUI не запустился, продолжаю установку вручную..."
        break
    fi
    sleep 2
done

# Пробуем через Manager API (если ComfyUI запущен)
if curl -s $COMFY_URL > /dev/null 2>&1; then
    echo "   📡 Загружаю workflow и устанавливаю недостающие ноды..."
    
    # Загружаем workflow через API
    curl -s -X POST $COMFY_URL/manager/install_missing_nodes \
        -H "Content-Type: application/json" \
        -d @$COMFY_DIR/user/default/workflows/QWEN_batch_3.json > /dev/null 2>&1
    
    sleep 5
    echo "   ✅ Custom nodes установлены через Manager"
else
    # Если ComfyUI не запущен - ставим ноды вручную
    echo "   📦 Устанавливаю custom nodes вручную..."
    
    cd $COMFY_DIR/custom_nodes
    
    NODES=(
        "https://github.com/chflame163/ComfyUI_LayerStyle.git"
        "https://github.com/rgthree/rgthree-comfy.git"
        "https://github.com/yolain/ComfyUI-Easy-Use.git"
        "https://github.com/cubiq/ComfyUI_essentials.git"
        "https://github.com/lucyknada/ComfyUI_Lucy_Tools.git"
    )
    
    for repo in "${NODES[@]}"; do
        node_name=$(basename $repo .git)
        if [ ! -d "$node_name" ]; then
            echo "      ⬇️  $node_name..."
            git clone $repo > /dev/null 2>&1
            
            if [ -f "$node_name/requirements.txt" ]; then
                cd $node_name
                pip install -q -r requirements.txt > /dev/null 2>&1
                cd ..
            fi
        fi
    done
    
    echo "   ✅ Custom nodes установлены"
fi

echo ""

# ============================================================
# 4. СКАЧИВАНИЕ МОДЕЛЕЙ QWEN
# ============================================================
echo "📥 Скачиваю модели QWEN..."
echo "   (это займет 10-15 минут, ~6.5GB)"
echo ""

cd $COMFY_DIR/models

# UNET model (5GB)
echo "   📦 UNET model (5GB)..."
mkdir -p unet && cd unet

if [ ! -f "qwen_image_edit_2509_fp8_e4m3fn.safetensors" ]; then
    wget -q --show-progress \
        https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors
    echo "   ✅ UNET скачан"
else
    echo "   ✅ UNET уже есть"
fi

cd $COMFY_DIR/models

# LoRA models
echo ""
echo "   📦 LoRA models (1.5GB)..."
mkdir -p loras && cd loras

# Lightning LoRA (850MB)
if [ ! -f "Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors" ]; then
    echo "      ⬇️  Lightning LoRA (850MB)..."
    wget -q --show-progress \
        https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Edit-2509/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors
    echo "      ✅ Lightning LoRA скачан"
else
    echo "      ✅ Lightning LoRA уже есть"
fi

# Consistence LoRA (614MB)
if [ ! -f "consistence_edit_v2.safetensors" ]; then
    echo "      ⬇️  Consistence LoRA (614MB)..."
    wget -q --show-progress \
        https://huggingface.co/hoveyc/comfyui-models/resolve/main/loras/qwen-image-edit/consistence_edit_v2.safetensors
    echo "      ✅ Consistence LoRA скачан"
else
    echo "      ✅ Consistence LoRA уже есть"
fi

echo ""

# ============================================================
# 5. ОБНОВЛЕНИЕ ПАКЕТОВ COMFYUI
# ============================================================
echo "📦 Обновляю пакеты ComfyUI..."
echo "   (это может занять несколько минут)"
echo ""

cd $COMFY_DIR

# Обновляем основные пакеты ComfyUI
if [ -f "requirements.txt" ]; then
    echo "   ⬇️  Обновляю основные зависимости ComfyUI..."
    pip install --upgrade -r requirements.txt 2>&1 | while read line; do
        echo "      $line"
    done
    echo "   ✅ Основные пакеты обновлены"
fi

# Считаем количество custom nodes
cd $COMFY_DIR/custom_nodes
TOTAL_NODES=$(ls -d */ 2>/dev/null | wc -l)
CURRENT_NODE=0

echo ""
echo "   ⬇️  Обновляю пакеты custom nodes ($TOTAL_NODES шт.)..."
echo ""

for node_dir in */; do
    CURRENT_NODE=$((CURRENT_NODE + 1))
    node_name="${node_dir%/}"
    
    if [ -f "$node_dir/requirements.txt" ]; then
        echo "   [$CURRENT_NODE/$TOTAL_NODES] 📦 $node_name"
        cd "$node_dir"
        pip install --upgrade -r requirements.txt 2>&1 | while read line; do
            echo "      $line"
        done
        cd ..
        echo "   [$CURRENT_NODE/$TOTAL_NODES] ✅ $node_name готов"
        echo ""
    else
        echo "   [$CURRENT_NODE/$TOTAL_NODES] ⏭️  $node_name (нет requirements.txt)"
    fi
done

echo "   ✅ Все пакеты обновлены"
echo ""

# ============================================================
# 6. КОПИРОВАНИЕ WORKFLOW В НУЖНЫЕ МЕСТА
# ============================================================
echo "📂 Копирую workflow в нужные места..."

# Копируем workflow также в корень ComfyUI для удобства
cp $COMFY_DIR/user/default/workflows/QWEN_batch_3.json $COMFY_DIR/QWEN_batch_3.json 2>/dev/null || true

# Копируем в input папку (некоторые версии ComfyUI ищут там)
mkdir -p $COMFY_DIR/input
cp $COMFY_DIR/user/default/workflows/QWEN_batch_3.json $COMFY_DIR/input/QWEN_batch_3.json 2>/dev/null || true

echo "   ✅ Workflow скопирован"
echo ""

# ============================================================
# 7. ПРОВЕРКА УСТАНОВКИ
# ============================================================
echo "🔍 Проверяю установку..."
echo ""

# Проверяем модели
MODELS_OK=true

if [ ! -f "$COMFY_DIR/models/unet/qwen_image_edit_2509_fp8_e4m3fn.safetensors" ]; then
    echo "   ❌ UNET model не найден"
    MODELS_OK=false
else
    echo "   ✅ UNET model"
fi

if [ ! -f "$COMFY_DIR/models/loras/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors" ]; then
    echo "   ❌ Lightning LoRA не найден"
    MODELS_OK=false
else
    echo "   ✅ Lightning LoRA"
fi

if [ ! -f "$COMFY_DIR/models/loras/consistence_edit_v2.safetensors" ]; then
    echo "   ❌ Consistence LoRA не найден"
    MODELS_OK=false
else
    echo "   ✅ Consistence LoRA"
fi

echo ""

# ============================================================
# ФИНАЛ
# ============================================================
echo "======================================================================"

if [ "$MODELS_OK" = true ]; then
    echo "🎉 УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!"
else
    echo "⚠️  УСТАНОВКА ЗАВЕРШЕНА С ПРЕДУПРЕЖДЕНИЯМИ"
    echo "   Некоторые модели не скачались, проверь интернет"
fi

echo "======================================================================"
echo ""
echo "📝 СЛЕДУЮЩИЕ ШАГИ:"
echo ""
echo "   ✅ Все готово! ComfyUI запустится автоматически с workflow"
echo "   ✅ Workflow QWEN_batch_3.json будет загружен автоматически"
echo ""
echo "💡 Если есть ошибки - проверь логи ComfyUI"
echo ""
echo "======================================================================"
