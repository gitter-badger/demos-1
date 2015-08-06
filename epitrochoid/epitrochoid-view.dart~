import 'package:stagexl/stagexl.dart';
import 'package:polymer/polymer.dart';
import 'dart:math' as math;
import 'dart:async';

@CustomTag('epicycloid-view')
class EpicycloidViewElement extends PolymerElement {
  @observable HEIGHT = 600;
  @observable WIDTH = 600;

  // StageXL Variables
  Stage stage = null;
  RenderLoop renderLoop = null;

  @observable int a1Input = 100;
  @observable int a2Input = 100;

  @observable bool paused = true;

  EpicycloidView view = null;

  EpicycloidViewElement.created() : super.created() {
    StageXL.stageOptions.renderEngine = RenderEngine.Canvas2D;
    Stage canvas = shadowRoot.query('#stage');
    this.stage = new Stage(canvas);
    this.renderLoop = new RenderLoop()
      ..addStage(this.stage);

    this.view = new EpicycloidView(WIDTH, HEIGHT);
    this.stage.addChild(this.view);
  }

  void a1InputChanged() {
    view.a1 = int.parse(a1Input);
    view.resetShapes();
  }

  void a2InputChanged() {
    view.a2 = int.parse(a2Input);
    view.resetShapes();
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

class EpicycloidView extends DisplayObjectContainer {
  int a1 = 100;
  int a2 = 100;

  int WIDTH;
  int HEIGHT;

  Shape _innerCircle = new Shape();
  Shape _outerCircle = new Shape();

  Shape _line = new Shape();
  Shape _dot = new Shape();

  bool paused = true;

  EpicycloidView(this.WIDTH, this.HEIGHT) {
    resetShapes();

    this.onEnterFrame.listen(_onEnterFrame);
  }

  void resetShapes() {
    double centerX = WIDTH / 2;
    double centerY = HEIGHT / 2;

    _innerCircle.removeFromParent();
    _outerCircle.removeFromParent();
    _line.removeFromParent();
    _dot.removeFromParent();

    _innerCircle = new Shape();
    _outerCircle = new Shape();
    _line = new Shape();
    _dot = new Shape();

    _innerCircle.graphics.circle(centerX, centerY, a1);
    _innerCircle.graphics.strokeColor(Color.Blue, 2);
    this.addChild(_innerCircle);

    _outerCircle.graphics.circle(a1 + a2, 0, a2);
    _outerCircle.graphics.strokeColor(Color.Black, 2);
    _outerCircle.x = centerX;
    _outerCircle.y = centerY;
    this.addChild(_outerCircle);

    _dot.graphics.circle(0, 0, 4);
    _dot.graphics.fillColor(Color.Lime);
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

    double t = -elapsedTime*2*math.PI / 4;

    _outerCircle.rotation = t;

    double innerCircleCircum = 2*math.PI*a1;
    double outerCircleCircum = 2*math.PI*a2;

    double outerRotationRatio = outerCircleCircum / innerCircleCircum;

    // int x = (a*( 2*math.cos(t) - math.cos(2*t) ) + WIDTH/2).toInt();
    // int y = (a*( 2*math.sin(t) - math.sin(2*t) ) + WIDTH/2).toInt();

    double outerCenterX = ((a1 + a2)*math.cos(t) + WIDTH/2);
    double outerCenterY = ((a1 + a2)*math.sin(t) + HEIGHT/2);

    double x = outerCenterX - math.cos((outerRotationRatio+1)*t / outerRotationRatio) * a2;
    double y = outerCenterY - math.sin((outerRotationRatio+1)*t / outerRotationRatio) * a2;

    // if (a1 > a2) {
    //   var temp = a2;
    //   a2 = a1;
    //   a1 = temp;
    // }

    // double x = (a2 + a1)*math.cos(t) - a1*math.cos(((a2 + a1)/a1) * t) + WIDTH / 2;
    // double y = (a2 + a1)*math.sin(t) - a1*math.sin(((a2 + a1)/a1) * t) + HEIGHT / 2;

    _dot.x = x;
    _dot.y = y;

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
