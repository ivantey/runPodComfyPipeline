# 🚀 ComfyUI Auto Setup для RunPod

Автоматическая настройка ComfyUI с твоими workflows и моделями QWEN.

---

## 📦 Что в этом репозитории:

```
runpod-comfyui-setup/
├── setup.sh                     # Основной скрипт установки
├── workflows/
│   └── qwen_batch3.json        # Твой QWEN workflow
└── README.md                   # Эта инструкция
```

---

## 🎯 Что делает скрипт:

1. ✅ Устанавливает ComfyUI Manager (если нет)
2. ✅ Копирует твои workflows из GitHub
3. ✅ Автоматически устанавливает недостающие custom nodes
4. ✅ Скачивает модели QWEN (6.5GB):
   - UNET model (5GB)
   - Lightning LoRA (850MB)
   - Consistence LoRA (614MB)
5. ✅ Проверяет что всё установилось
6. ✅ Готово к работе!

**Результат:** Открываешь ComfyUI → Load → Queue Prompt → Работает! 🎉

---

## 🚀 Как использовать на RunPod:

### Вариант 1: Через Docker Command (при создании пода)

1. Открой **RunPod Console** → **Deploy**
2. Выбери template **"ComfyUI"** (runpod/comfyui:latest)
3. В секции **"Edit Template"** найди **"Docker Command"**
4. Вставь:

```bash
bash -c "curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/runpod-comfyui-setup/main/setup.sh | bash && python /workspace/runpod-slim/main.py"
```

5. Deploy!
6. Подожди 15-20 минут (скрипт скачает всё)
7. Открой ComfyUI → Load → qwen_batch3.json → Работает!

---

### Вариант 2: Вручную после запуска пода

1. Запусти под с ComfyUI template
2. Подключись по SSH к поду
3. Выполни:

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/runpod-comfyui-setup/main/setup.sh | bash
```

4. Подожди завершения (15-20 минут)
5. Обнови страницу ComfyUI
6. Load → qwen_batch3.json → Работает!

---

## ⚙️ Настройка репозитория:

### 1. Создай GitHub репозиторий:

```bash
# На своем компьютере
mkdir runpod-comfyui-setup
cd runpod-comfyui-setup

# Скачай файлы из этого проекта
# setup.sh, workflows/, README.md

# Инициализируй Git
git init
git add .
git commit -m "Initial commit"

# Создай репозиторий на GitHub и загрузи
git remote add origin https://github.com/YOUR_USERNAME/runpod-comfyui-setup.git
git push -u origin main
```

### 2. Положи свой workflow:

```bash
mkdir workflows
# Скопируй свой qwen_batch3.json в workflows/
cp /path/to/qwen_batch3.json workflows/

git add workflows/
git commit -m "Add QWEN workflow"
git push
```

### 3. Готово!

Теперь скрипт будет брать workflow из твоего GitHub!

---

## 🔧 Добавление других workflows:

Когда будут готовы другие workflows:

```bash
# Добавь их в папку workflows/
cp workflow2.json workflows/
cp workflow3.json workflows/

# Загрузи на GitHub
git add workflows/
git commit -m "Add new workflows"
git push
```

Они автоматически скопируются в ComfyUI при установке!

---

## 💡 Полезные команды:

### Проверить что установлено:

```bash
# Custom nodes
ls -la /workspace/runpod-slim/ComfyUI/custom_nodes/

# Модели
ls -lh /workspace/runpod-slim/ComfyUI/models/unet/
ls -lh /workspace/runpod-slim/ComfyUI/models/loras/

# Workflows
ls -la /workspace/runpod-slim/ComfyUI/user/default/workflows/
```

### Запустить установку заново:

```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/runpod-comfyui-setup/main/setup.sh | bash
```

### Логи ComfyUI:

```bash
tail -f /workspace/runpod-slim/ComfyUI/comfyui.log
```

---

## ❗ Troubleshooting:

### Проблема: Скрипт не скачивается

**Решение:**
- Проверь что репозиторий **публичный** (не private)
- Проверь URL: `https://raw.githubusercontent.com/YOUR_USERNAME/runpod-comfyui-setup/main/setup.sh`
- Открой URL в браузере, должен показать содержимое скрипта

### Проблема: Custom nodes не установились

**Решение:**
```bash
# Установи вручную
cd /workspace/runpod-slim/ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Через Manager UI установи недостающие
```

### Проблема: Модели не скачались

**Решение:**
```bash
# Скачай вручную
cd /workspace/runpod-slim/ComfyUI/models/unet
wget https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors

cd ../loras
wget https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Edit-2509/Qwen-Image-Edit-2509-Lightning-4steps-V1.0-bf16.safetensors
wget https://huggingface.co/hoveyc/comfyui-models/resolve/main/loras/qwen-image-edit/consistence_edit_v2.safetensors
```

---

## 💰 Стоимость:

**GPU:** RTX 3090 SPOT = $0.22/час (~20₽/час)

**Установка скрипта (первый раз):**
- ~20 минут = $0.07 (~6₽)

**Для 300 генераций/день:**
- 20.8 часов/день × $0.22 = $4.58/день
- **$137/месяц (~12,330₽)**
- **На фото: 1.4₽** (вместо 5₽ сейчас!)

**Экономия: 72%** 🎉

---

## 📞 Поддержка:

Если что-то не работает - проверь:
1. ✅ Репозиторий публичный
2. ✅ URL правильный
3. ✅ Интернет в поде работает
4. ✅ ComfyUI запущен

---

## 🎯 Roadmap:

- [ ] Добавить остальные 4 workflows
- [ ] Оптимизировать размер моделей
- [ ] Добавить API для бота
- [ ] Мониторинг и алерты

---

**Создано с ❤️ для автоматизации ComfyUI на RunPod**
