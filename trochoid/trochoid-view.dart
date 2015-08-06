import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:polymer/polymer.dart';
import 'dart:math' as math;
import 'dart:async';

@CustomTag('trochoid-view')
class TrochoidViewElement extends PolymerElement {
  @observable int HEIGHT = 600;
  @observable int WIDTH = 600;

  // StageXL Variables
  Stage stage = null;
  RenderLoop renderLoop = null;

  TrochoidView view = null;

  @observable bool paused = true;

  @observable int a = 50;
  @observable int b = 50;

  @observable double rotationsPerSecond = 0.25;

  TrochoidViewElement.created() : super.created() {
    StageXL.stageOptions.renderEngine = RenderEngine.Canvas2D;
    CanvasElement canvas = shadowRoot.query('#stage');
    this.stage = new Stage(canvas);
    this.renderLoop = new RenderLoop();
    this.renderLoop.addStage(stage);
  
    this.view = new TrochoidView(WIDTH, HEIGHT);
    this.stage.addChild(this.view);
  }

  void aChanged() {
    view.a = int.parse(a.toString());
    view.reset();
  }

  void bChanged() {
    view.b = int.parse(b.toString());
    view.reset();
  }

  void rotationsPerSecondChanged() {
    view.rotationsPerSecond = double.parse(rotationsPerSecond.toString());
    view.reset();
  }

  void pauseView() {
    this.paused = true;
    view.paused = true;
  }

  void unpauseView() {
    this.paused = false;
    view.paused = false;
  }
}

class TrochoidView extends DisplayObjectContainer {
  int a = 50;
  int b = 50;

  double rotationsPerSecond = 0.25;

  int WIDTH;
  int HEIGHT;

  bool paused = true;

  Shape _circle = new Shape();
  Shape _platform = new Shape();
  Shape _line = new Shape();
  Shape _radius = new Shape();
  Shape _dot = new Shape();


  TrochoidView(this.WIDTH, this.HEIGHT) {
    reset();
    this.onEnterFrame.listen(_onEnterFrame);
  }

  void reset() {
    _circle.removeFromParent();
    _platform.removeFromParent();
    _line.removeFromParent();
    _radius.removeFromParent();
    _dot.removeFromParent();

    _circle = new Shape();
    _platform = new Shape();
    _line = new Shape();
    _radius = new Shape();
    _dot = new Shape();

    _circle.graphics.circle(0, HEIGHT / 2, a);
    _circle.graphics.strokeColor(Color.Blue, 2);

    _platform.graphics.moveTo(0, HEIGHT/2 + a);
    _platform.graphics.lineTo(WIDTH, HEIGHT/2 + a);
    _platform.graphics.strokeColor(Color.Black, 2);

    _radius.graphics.moveTo(0, 0);
    _radius.graphics.lineTo(0, b);
    _radius.graphics.strokeColor(Color.Black, 2);
    _radius.y = HEIGHT / 2;

    _dot.graphics.circle(0, 0, 4);
    _dot.graphics.fillColor(Color.Lime);

    this.addChild(_circle);
    this.addChild(_platform);
    this.addChild(_line);
    this.addChild(_radius);
    this.addChild(_dot);

    this.prevX = null;
    this.prevY = null;
    this.elapsedTime = 0.0;
  }

  double elapsedTime = 0.0; 
  double prevX = null;
  double prevY = null;

  _onEnterFrame(EnterFrameEvent e) {
    if (paused) return;
    elapsedTime += e.passedTime;

    double t = elapsedTime*2*math.PI * rotationsPerSecond;

    double x = a*t - b*math.sin(t);
    double y = HEIGHT - (a - b*math.cos(t)) - HEIGHT/2 + a;

    double distanceTraveled = t * a;

    _dot.x = x;
    _dot.y = y;

    _radius.rotation = t;

    _radius.x = distanceTraveled;
    _circle.x = distanceTraveled;

    if (prevX != null) {
      _line.graphics.beginPath();
      _line.graphics.moveTo(prevX, prevY);
      _line.graphics.lineTo(x, y);
      _line.graphics.closePath();
      _line.graphics.strokeColor(Color.Red, 0.5);
    }

    prevX = x;
    prevY = y;

    if (distanceTraveled > WIDTH + a) {
      reset();
    }
  }
}
