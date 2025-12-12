# ComfyUI QWEN Setup для RunPod

Автоматическая установка ComfyUI с QWEN workflow и всеми зависимостями.

## Быстрый старт

```bash
curl -sSL https://raw.githubusercontent.com/ivantey/runPodComfyPipeline/master/setup.sh | bash
```

## Что устанавливается

- ComfyUI Manager
- Custom nodes: LayerStyle, rgthree, Easy-Use, WAS
- Модели QWEN (~6.5GB): Text Encoder, VAE, UNET, LoRA
- Workflow: QWEN_batch_3.json

## Использование на RunPod

### Вариант 1: При создании пода

1. Выбери template **ComfyUI**
2. В **Docker Command** вставь:

```bash
bash -c "curl -sSL https://raw.githubusercontent.com/ivantey/runPodComfyPipeline/master/setup.sh | bash && python /workspace/runpod-slim/main.py"
```

3. Deploy и жди ~15-20 минут

### Вариант 2: На запущенном поде

```bash
curl -sSL https://raw.githubusercontent.com/ivantey/runPodComfyPipeline/master/setup.sh | bash
```

## После установки

1. Открой ComfyUI
2. Load → QWEN_batch_3.json
3. Queue Prompt → Готово!

## Структура

```
├── setup.sh              # Скрипт установки
└── workflows/
    └── QWEN_batch_3.json # Workflow
```
