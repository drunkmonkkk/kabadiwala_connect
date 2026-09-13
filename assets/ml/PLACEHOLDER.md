# ML Model Assets

Place these two files here before running inference:

1. scrap_classifier.tflite  — TFLite flatbuffer model
2. labels.txt               — One label per line, matching model output indices

Expected label order (one per line in labels.txt):
copper_wire
aluminium
brass
iron
pcb
battery

Model input spec the code expects:
  - Shape  : [1, 224, 224, 3]  (batch=1, H=224, W=224, channels=3)
  - Type   : float32
  - Range  : [0.0, 1.0]  (pixel values divided by 255.0)

If your model uses a different input size, update ScrapClassifierService.inputSize.
