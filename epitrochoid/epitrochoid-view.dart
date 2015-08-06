import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:polymer/polymer.dart';
import 'dart:math' as math;
import 'dart:async';

@CustomTag('epitrochoid-view')
class EpitrochoidViewElement extends PolymerElement {
  @observable HEIGHT = 600;
  @observable WIDTH = 600;

  // StageXL Variables
  Stage stage = null;
  RenderLoop renderLoop = null;

  @observable int R = 100;
  @observable int r = 100;
  @observable int d = 100;
  @observable double rotationsPerSecond = 0.25;

  @observable bool paused = true;

  EpitrochoidView view = null;

  EpitrochoidViewElement.created() : super.created() {
    StageXL.stageOptions.renderEngine = RenderEngine.Canvas2D;
    CanvasElement canvas = shadowRoot.query('#stage');
    this.stage = new Stage(canvas);
    this.renderLoop = new RenderLoop()
      ..addStage(this.stage);

    this.view = new EpitrochoidView(WIDTH, HEIGHT);
    this.stage.addChild(this.view);
  }

  void RChanged() {
    view.R = int.parse(R.toString());
    view.reset();
  }

  void rChanged() {
    view.r = int.parse(r.toString());
    view.reset();
  }

  void dChanged() {
    view.d = int.parse(d.toString());
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

class EpitrochoidView extends DisplayObjectContainer {
  int R = 100;
  int r = 100;
  int d = 100;
  double rotationsPerSecond = 0.25;

  int WIDTH;
  int HEIGHT;

  Shape _innerCircle = new Shape();
  Shape _outerCircle = new Shape();
  Shape _radius = new Shape();
  Shape _line = new Shape();
  Shape _dot = new Shape();

  bool paused = true;

  EpitrochoidView(this.WIDTH, this.HEIGHT) {
    reset();

    this.onEnterFrame.listen(_onEnterFrame);
  }

  void reset() {
    _innerCircle.removeFromParent();
    _outerCircle.removeFromParent();
    _radius.removeFromParent();
    _line.removeFromParent();
    _dot.removeFromParent();

    _innerCircle = new Shape();
    _outerCircle = new Shape();
    _radius = new Shape();
    _line = new Shape();
    _dot = new Shape();

    _innerCircle.graphics.circle(0, 0, R);
    _innerCircle.graphics.strokeColor(Color.Red, 2);
    _innerCircle.x = WIDTH / 2;
    _innerCircle.y = HEIGHT / 2;
    this.addChild(_innerCircle);

    _outerCircle.graphics.circle(R + r, 0, r);
    _outerCircle.graphics.strokeColor(Color.Blue, 2);
    _outerCircle.x = WIDTH / 2;
    _outerCircle.y = HEIGHT / 2;
    this.addChild(_outerCircle);

    _radius.graphics.moveTo(0, 0);
    _radius.graphics.lineTo(d, 0);
    _radius.graphics.strokeColor(Color.Black, 2);
    _radius.x = WIDTH / 2 + R + r;
    _radius.y = HEIGHT / 2;
    _radius.rotation = math.PI;
    this.addChild(_radius);

    _dot.graphics.circle(0, 0, 4);
    _dot.graphics.fillColor(Color.Lime);
    _dot.x = WIDTH/2 + R;
    _dot.y = HEIGHT / 2;
    this.addChild(_dot);

    this.addChild(_line);

    this.elapsedTime = 0.0;
    this.prevX = null;
    this.prevY = null;
  }

  double elapsedTime = 0.0;

  double prevX = null;
  double prevY = null;

  _onEnterFrame(EnterFrameEvent e) {
    if (paused) return;
    elapsedTime += e.passedTime;


    double t = elapsedTime*2*math.PI * rotationsPerSecond;
    _outerCircle.rotation = t;

    double x = (R + r)*math.cos(t) - d*math.cos( ((R + r)/r) * t ) + WIDTH/2;
    double y = (R + r)*math.sin(t) - d*math.sin( ((R + r)/r) * t ) + HEIGHT/2;

    _dot.x = x;
    _dot.y = y;

    double radiusX = math.cos(t) * (R + r) + WIDTH/2;
    double radiusY = math.sin(t) * (R + r) + HEIGHT/2;
    _radius.rotation = math.atan2(y - radiusY, x - radiusX);
    _radius.x = radiusX;
    _radius.y = radiusY;

    if (prevX != null) {
      _line.graphics.beginPath();
      _line.graphics.moveTo(prevX, prevY);
      _line.graphics.lineTo(x, y);
      _line.graphics.closePath();
      _line.graphics.strokeColor(Color.Red, 0.5);
    }

    prevX = x;
    prevY = y;
  }
}
