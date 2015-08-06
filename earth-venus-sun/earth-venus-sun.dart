import 'package:stagexl/stagexl.dart';
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';

void main() {
}

@CustomTag('earth-venus-sun')
class EarthVenusSunElement extends PolymerElement {
  @observable int WIDTH = 600;
  @observable int HEIGHT = 600;

  EarthVenusSunSystem system = null;

  EarthVenusSunElement.created() : super.created() {
    print('created!!');
    this.system = new EarthVenusSunSystem(this.shadowRoot.query('#stage'), this.WIDTH, this.HEIGHT);
  }

  void pauseSystem() {
    system.pauseSystem();
  }
  void unpauseSystem() {
    system.unpauseSystem();
  }
  void exactRatioToggle() {
    system.exactRatioToggle();
  }
}

class EarthVenusSunSystem extends DisplayObjectContainer {
  Stage stage = null;
  RenderLoop renderLoop = new RenderLoop();

  int WIDTH;
  int HEIGHT;

  Shape _sun = new Shape();
  Shape _earth = new Shape();
  Shape _venus = new Shape();
  Shape _line = new Shape();

  double _sunRadius = 696342 / 40000;
  double _earthRadius = 6371 / 2000;
  double _venusRadius = 6052 / 2000;

  double _earthDistance = 149512500 ~/ 600000;
  double _venusDistance = 108208000 ~/ 600000;

  double lengthOfYear = 5; // Seconds

  bool useExactRatio = false;
  bool paused = true;

  EarthVenusSunSystem(Canvas canvas, this.WIDTH, this.HEIGHT) {
    StageXL.stageOptions.renderEngine = RenderEngine.Canvas2D;
    this.stage = new Stage(canvas);
    this.renderLoop.addStage(this.stage);

    this.stage.addChild(this);

    resetShapes();

    this.onEnterFrame.listen(_onEnterFrame);
  }

  void pauseSystem() {
    this.paused = true;
  }

  void unpauseSystem() {
    this.paused = false;
  }

  void exactRatioToggle() {
    this.useExactRatio = !this.useExactRatio;
    this.resetShapes();
  }

  resetShapes() {
    double centerX = WIDTH / 2;
    double centerY = HEIGHT / 2;

    _sun.removeFromParent();
    _earth.removeFromParent();
    _venus.removeFromParent();
    _line.removeFromParent();

    _sun.graphics.circle(centerX, centerY, _sunRadius);
    _sun.graphics.fillColor(Color.Yellow);
    this.addChild(_sun);

    _earth.graphics.circle(_earthDistance, 0, _earthRadius);
    _earth.graphics.fillColor(Color.Green);
    _earth.x = centerX;
    _earth.y = centerY;
    this.addChild(_earth);

    _venus.graphics.circle(_venusDistance, 0, _venusRadius);
    _venus.graphics.fillColor(Color.Brown);
    _venus.x = centerX;
    _venus.y = centerY;
    this.addChild(_venus);

    _line = new Shape();
    this.addChild(_line);

    this.elapsedTime = 0.0;
    this.prevMidX = null;
    this.prevMidY = null;
  }
  

  double elapsedTime = 0.0;
  double prevMidX = null;
  double prevMidY = null;

  _onEnterFrame(EnterFrameEvent e) {
    if (paused) return;
    elapsedTime += e.passedTime;

    _earth.rotation = elapsedTime*2*3.14159 / lengthOfYear;
    double ratio = useExactRatio ? (365.2563 / 224.7008) : (13 / 8);
    _venus.rotation = (elapsedTime*2*3.14159 / lengthOfYear) * ratio;

    double earthX = math.cos(_earth.rotation) * _earthDistance + (WIDTH / 2);
    double earthY = math.sin(_earth.rotation) * _earthDistance + (HEIGHT / 2);
    double venusX = math.cos(_venus.rotation) * _venusDistance + (WIDTH / 2);
    double venusY = math.sin(_venus.rotation) * _venusDistance + (HEIGHT / 2);
    double midX = (earthX + venusX) / 2;
    double midY = (earthY + venusY) / 2;

    if (prevMidX != null) {
      _line.graphics.beginPath();
      _line.graphics.moveTo(prevMidX, prevMidY);
      _line.graphics.lineTo(midX, midY);
      _line.graphics.closePath();
      _line.graphics.strokeColor(Color.Blue, 0.5);
    }

    prevMidX = midX;
    prevMidY = midY;
  }
}