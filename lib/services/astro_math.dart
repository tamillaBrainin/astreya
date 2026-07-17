double angularDistance(double a, double b) {
  final delta = (a - b).abs() % 360;
  return delta > 180 ? 360 - delta : delta;
}

bool isNearAspect(double angle, double target, double orb) {
  return (angle - target).abs() <= orb;
}
