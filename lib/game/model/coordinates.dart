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

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'x': x,
      'y': y
    };
  }
}