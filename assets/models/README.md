# YOLO Model Setup Instructions

## Required Model Files

You need to download the nutrition table detection model from OpenFoodFacts:

### 1. Download Model from Hugging Face

Visit: https://huggingface.co/openfoodfacts/nutrition-table-yolo

Download the following file:
- `weights/best.onnx` or `weights/best.pt`

### 2. Convert to TensorFlow Lite

The model needs to be converted to `.tflite` format for mobile deployment.

#### Option A: Using Ultralytics (if .pt file)

```bash
pip install ultralytics

# Convert PyTorch model to TFLite
yolo export model=best.pt format=tflite imgsz=640
```

#### Option B: Using ONNX converter (if .onnx file)

```bash
pip install onnx tf2onnx tensorflow

# Convert ONNX to TensorFlow
python -m tf2onnx.convert --opset 13 --onnx best.onnx --output model.pb

# Convert TensorFlow to TFLite
import tensorflow as tf
converter = tf.lite.TFLiteConverter.from_saved_model('model.pb')
tflite_model = converter.convert()
with open('nutrition_table_yolo.tflite', 'wb') as f:
    f.write(tflite_model)
```

### 3. Place Files in This Directory

After conversion, place these files here:
- `nutrition_table_yolo.tflite` (the converted model)
- `nutrition_table_labels.txt` (already provided)

### 4. Alternative: Use Pre-converted Model

If you have issues with conversion, you can:
1. Use YOLOv8n as base model and fine-tune it yourself
2. Or disable table detection and use full-image OCR (less accurate but functional)

To disable table detection, set `useTableDetection: false` in the OCR scanner screen.

## Model Size

Expected file size:
- YOLOv8-nano (.tflite): ~6 MB
- YOLOv8-small (.tflite): ~22 MB

Recommendation: Use nano version for mobile deployment.

## License

The nutrition-table-yolo model is licensed under AGPLv3, which is compatible with this project's GPLv3 license.
