import 'dart:html';
bool moving = false;
Point start;
CssRect clip;

     

void main() {
  querySelector('#iLink').onChange.listen(fetchImg);
  querySelector('#iOutput')
  ..onMouseDown.listen(startMove)
  ..onMouseMove.listen(move)
  ..onMouseUp.listen(stopMove);
}

startMove(MouseEvent e){
  if(!moving){
    e.preventDefault();
    start = new Point (e.offset.x,e.offset.y);
    clip = new CssRect(0, 500, 500, 0);
    moving=true;
    print("start: ${clip.asCss}");
  }
}  

move(MouseEvent e){
  if(moving){
    var dx = e.offset.x-start.x;
    var dy = e.offset.y-start.y;
    clip.offset(-dx,0);
    ImageElement output = querySelector("#iOutput");
    output.style.clip = clip.asCss;
    print("$dx,$dy ${clip.asCss}");
  }
}
  stopMove(e){
    if (moving){
      moving = false; 
      print("stop: ${clip.asCss}");
    }
  }

fetchImg (e){
  var link= e.currentTarget.value;
  print (link);
  showImg(link);
  
}

showImg (link){
  ImageElement view = querySelector("#iView");
  
  view.src = link;
  view.onLoad.listen((e){makeOutput(e.currentTarget);});
}

makeOutput (ImageElement img){
  
ImageElement output = querySelector("#iOutput");
  var w = img.naturalWidth;
  var h = img.naturalHeight;
  var p = h / w;
  print("w: $w, h: $h, h/w: $p");
  if( w > h ){
    output.height=500;
    output.style.width="auto";
  }else{
    output.style.height="auto";
    output.width=500;
  }
  
  output.src = img.src;
  
}

class CssRect {
  num top,left,right,bottom;
  CssRect (this.top,this.right,this.bottom,this.left){}
  set width(num w) => right = right-left+w;
  set height(num h) => bottom = bottom-top+h;
  
  offset (num x, num y){
    top += y;
    bottom += y;
    left += x;
    right += x;
  }
  String get asCss => "rect(${top}px,${right}px,${bottom}px,${left}px)";
}


