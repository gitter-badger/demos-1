import 'dart:html';
import 'dart:math' as math;
import 'package:polymer/polymer.dart';
import 'package:stagexl/stagexl.dart';

@CustomTag('analog-element-clock')
class AnalogElementClockElement extends PolymerElement {
  @observable final int CLOCKFACE_RADIUS = 360;

  CanvasElement canvas = null;
  Stage stage = null;
  RenderLoop renderLoop = null;


  AnalogElementClockElement.created() : super.created() {
    var resourceManager = new ResourceManager()
      ..addTextureAtlas('elements', 'elements.json', TextureAtlasFormat.JSONARRAY);

    resourceManager.load().then((var _) {
      TextureAtlas textureAtlas = resourceManager.getTextureAtlas('elements');
      var elementNames = textureAtlas.frameNames;

      int count = 0;
      textureAtlas.frameNames.forEach((String name) {
        BitmapData bitmapData = textureAtlas.getBitmapData(name);
        ElementIcon elementIcon = new ElementIcon(bitmapData, 0, 0);
        elementIcon.mask = new Mask.circle(elementIcon.width / 2, elementIcon.width / 2, elementIcon.width / 2);
        elementIcon.pivotX = elementIcon.width / 2;
        elementIcon.pivotY = elementIcon.height / 2;
        elementIcon.width = unitChordDistance() * CLOCKFACE_RADIUS;
        elementIcon.height = unitChordDistance() * CLOCKFACE_RADIUS;

        elementIcon.x = math.cos(((2*math.PI) / 60) * count) * CLOCKFACE_RADIUS + CLOCKFACE_RADIUS;
        elementIcon.y = math.sin(((2*math.PI) / 60) * count) * CLOCKFACE_RADIUS + CLOCKFACE_RADIUS;

        stage.addChild(elementIcon);
        count += 1;
      });
    });

    canvas = shadowRoot.querySelector('#clockface');
    stage = new Stage(canvas);
    renderLoop = new RenderLoop();

    renderLoop.addStage(stage);
  }

  double unitChordDistance() {
    double theta = (2*math.PI) / 60; // 1/60th of a rotation
    return 2 * math.sin(theta / 2);
  }
}

class ElementIcon extends Bitmap implements Animatable {
  num vx, vy;
  
  ElementIcon(BitmapData bitmapData, this.vx, this.vy) : super(bitmapData) {}

  bool advanceTime(num time) {
    
  }
}
