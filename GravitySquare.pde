class GravitySquare 
{
  int positionX;
  int positionY;
  int positionZ;

  boolean _stroke;
  boolean _fill;

  GravitySquare(boolean stroke, boolean fill) {
   
    _fill = fill;
    _stroke = stroke;
  }
  void DrawRect( PVector size,color c,boolean draw, PVector position) {

    if (!draw) return;
    pushMatrix();
    translate(position.x, position.y, position.z);//likea a mirror
    /*noFill();
     stroke(c);*/
    if (!_stroke) {
      noStroke();
    } else {
      stroke(c);
    };
     if (!_fill) {
      noFill();
    } else {
      fill(c);
    };
  
    rect(0, 0, size.x, size.y);
    popMatrix();
  }
}