import 'package:polymer/polymer.dart';
import 'package:stagexl/stagexl.dart';
import 'dart:math' as math;

@CustomTag('catenary-view')
class CatenaryViewElement extends PolymerElement {
  @observable int WIDTH = 600;
  @observable int HEIGHT = 600;

  // StageXL Variables
  Stage stage = null;
  RenderLoop renderLoop = null;

  CatenaryView view = null;

  CatenaryViewElement.created() : super.created() {
    StageXL.stageOptions.renderEngine = RenderEngine.Canvas2D;
    this.stage = new Stage(shadowRoot.query('#stage'));
    this.renderLoop = new RenderLoop()
      ..addStage(this.stage);

    this.view = new CatenaryView(WIDTH, HEIGHT);
    this.stage.addChild(this.view);
  }
}

class CatenaryView extends DisplayObjectContainer {
  int WIDTH = null;
  int HEIGHT = null;

  Sprite _p1 = new Sprite();
  Sprite _p2 = new Sprite();
  Shape _line = new Shape();

  double a = 1.0;

  CatenaryView(this.WIDTH, this.HEIGHT) {
    // Setup _p1
    _p1.graphics.beginPath();
    _p1.graphics.circle(0, 0, 5);
    _p1.graphics.closePath();
    _p1.graphics.fillColor(Color.Black);
    _p1.x = WIDTH / 2 - WIDTH / 4;
    _p1.y = HEIGHT / 2;
    _p1.useHandCursor = true;

    _p1.onMouseDown.listen((var _) {
      _p1.startDrag(false); // Don't lock center 
    });

    _p1.onMouseUp.listen((var _) {
      _p1.stopDrag();
      this._drawCatenary();
    });

    this.addChild(_p1);

    // Setup _p2
    _p2.graphics.beginPath();
    _p2.graphics.circle(0, 0, 5);
    _p2.graphics.closePath();
    _p2.graphics.fillColor(Color.Black);
    _p2.x = WIDTH / 2 + WIDTH / 4;
    _p2.y = HEIGHT / 2;
    _p2.useHandCursor = true;

    _p2.onMouseDown.listen((var _) {
      _p2.startDrag(false); // Don't lock center 
    });

    _p2.onMouseUp.listen((var _) {
      _p2.stopDrag();
      this._drawCatenary();
    });

    this.addChild(_p2);

    this.addChild(_line);

    _drawCatenary();
  }

  void _drawCatenary() {
    _line.removeFromParent();
    _line = new Shape();
    this.addChild(_line);

    double r = _p1.x;
    double s = _p1.y;
    double u = _p2.x;
    double v = _p2.y;
    double l = 300.0;

    double distance = math.sqrt( math.pow(_p2.y - _p1.y, 2) + math.pow(_p2.x - _p1.x, 2));
    print('distance: $distance');

    double z = 0.0;
    while (  sinh(z) < math.sqrt(l*l - (v-s)*(v-s)) / (u-r)  ) {
      z += 0.001;
    }

    double a = (u-r)/2/z;
    double p = ( r+u - a*math.log((l+v-s) / (l-v+s)) ) / 2;
    double q = ( v+s - l * cosh(z)/sinh(z)) / 2;

    _line.graphics.moveTo(r, s);

    double step = (u - x) / 10;
    double offset = 0.0;
    for (double x = r; x <= u; x++) {
      // if (x == r) {
      //   offset = s - (a * cosh((x-p) / a)+q);
      //   print('setting offset: $offset');
      // }
      _line.graphics.lineTo(x, (a * cosh((x-p) / a)+q) + offset );
    }

    _line.graphics.strokeColor(Color.Black, 1);
  }

  num sinh(num x) => (math.exp(x) - math.exp(-x)) / 2;
  num cosh(num x) => (math.exp(x) + math.exp(-x)) / 2;

  void _onEnterFrame() {
    
  }
}