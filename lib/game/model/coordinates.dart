class Coordinates{
  Coordinates(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(dynamic other) {
    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => (x * y).hashCode;
}