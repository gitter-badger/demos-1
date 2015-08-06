import 'dart:async';
import 'package:polymer/polymer.dart';

@CustomTag('digital-element-clock')
class DigitalElementClockElement extends PolymerElement {
  Timer timer = null;

  @observable int hours;
  @observable int minutes;
  @observable int seconds;

  @observable bool is24HourTime = false;

  @observable String am_pm = "am";
  
  DigitalElementClockElement.created() : super.created() {
    hours = new DateTime.now().hour;
    minutes = new DateTime.now().minute;
    seconds = new DateTime.now().second;

    if (hours > 12) {
      am_pm = "pm";
    }

    hours = hours % 12;
    if (hours == 0) hours = 1;

    timer = new Timer.periodic(new Duration(seconds: 1), tick);
  }

  void tick(Timer t) {
    seconds++;

    if (seconds == 60) {
      minutes++;
      seconds = 0;

      if (minutes == 60) {
        hours++;
        minutes = 0;

        if (hours > (is24HourTime ? 24 : 12)) {
          if (is24HourTime) {
            hours = 0;
          } else {
            hours = 1;
          }
        }
      }
    }
  }

  void on24HourToggle() {
    int curHours = new DateTime.now().hour;
    if (is24HourTime) { // Prepare to change to 12 hour time
      hours = hours % 12;
      if (hours == 0) {
        hours = 1; 
      }
      am_pm = curHours > 12 ? "pm" : "am";
    } else { // Prepare to change to 24 hour time
      hours = curHours;
    }

    is24HourTime = !is24HourTime;
    print(is24HourTime);
  }
}
