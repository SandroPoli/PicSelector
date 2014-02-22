import 'dart:html';

bool moving = false;
Point start;
InputElement iLink, iZoom;
ImageElement iView;
DivElement output;
PicInfo pInfo;

const testLinkSmall = 'http://i-cms.journaldunet.com/image_cms/original/1112625-les-outils-de-test-et-d-integration-continue-open-source.jpg';
const testLinkBig = 'http://i1-win.softpedia-static.com/screenshots/MonitorTest_2.png';
bool small = false;

void main() {
  querySelector('#btnTest').onClick.listen(testImg);


  iZoom = querySelector('#iZoom')..onChange.listen(zoom);
  iLink = querySelector('#iLink')..onChange.listen(fetchImg);
  iView = querySelector('#iView')..onLoad.listen(showOutput);

  output = querySelector('#iOutput')
  ..onMouseDown.listen(startMove)
  ..onMouseMove.listen(move)
  ..onMouseUp.listen(stopMove)
  ..onMouseLeave.listen(stopMove);
}

zoom(e){
  if(pInfo != null){
    pInfo.zoom = double.parse(iZoom.value);
    iZoom.min = pInfo.minZoom.toStringAsFixed(3);
    iZoom.max = pInfo.maxZoom.toStringAsFixed(3);
    iZoom.step = ((pInfo.maxZoom - pInfo.minZoom) / 50).toStringAsFixed(2);
    showInfo();
  }
}

showInfo(){
  querySelector('#info').text = pInfo.toString();
}

startMove(MouseEvent e){
  if(!moving){
    e.preventDefault();
    start = new Point (e.offset.x,e.offset.y);
    moving=true;
    print('start: $start');
  }
}

move(MouseEvent e){
  if(moving){
    pInfo.incOffset(e.offset.x-start.x, e.offset.y-start.y);
    start = new Point (e.offset.x,e.offset.y);
    showInfo();
  }
}
  stopMove(e){
    if (moving){
      moving = false;
      iZoom.min = pInfo.minZoom.toStringAsFixed(3);
      print("stop");
    }
  }

fetchImg([e]){
  pInfo = new PicInfo();
  iView.src = iLink.value;
}

showOutput (e){
  pInfo.init(output, iView);
  iZoom.min = pInfo.minZoom.toStringAsFixed(2);
  if (pInfo.loader.elapsedMilliseconds > 250)
    window.alert('don\'t use this image, load time too long!');
}

testImg(e){

  if (small)
    iLink.value = testLinkSmall;
  else
    iLink.value = testLinkBig;

  small = !small;

  fetchImg();
}

class PicInfo{
  String link;
  Stopwatch loader;

  num _width = 100,
      _height = 100,
      _posX = 0,
      _posY=0,
      _zoom = 1.0,
      _minZoom = 1.0,
      _maxZoom = 1.0;

  DivElement _viewer;

  PicInfo(){
    loader = new Stopwatch()..start();
  }

  String toString() => 'size: $_width x $_height, pos: ($_posX, $_posY), zoom: ${_zoom.toStringAsFixed(3)}(${minZoom.toStringAsFixed(3)}...${maxZoom.toStringAsFixed(3)}), [loaded in: ${loader.elapsedMilliseconds}ms] link: $link';

  double get minZoom => _minZoom.toDouble()-0.01;
  double get maxZoom => _maxZoom.toDouble()+0.01;

  set zoom(double z){
    _zoom = z;
    _resize();
  }

  set width(num w){
    _zoom = w / _width;
    _resize();
  }

  set height(num h){
    _zoom = h / _height;
    _resize();
  }

  incOffset(num x, num y){
    _posX += x.round();
    _posY += y.round();
    _resize();
  }

  init(DivElement viewer, ImageElement img){
    loader.stop();
    link = img.src;
    _width = img.naturalWidth;
    _height = img.naturalHeight;
    _viewer = viewer;

    var vSize = _viewer.clientWidth >= _viewer.clientHeight ? _viewer.clientHeight : _viewer.clientWidth;
    var iSize = _width > _height ? _height : _width;
    if (iSize > vSize){
      _minZoom = _width > _height ? vSize / _height : vSize / _width;
      _maxZoom = 1.2;
    } else {
      _maxZoom = _width > _height ? vSize / _height : vSize / _width;
      _minZoom = iSize / vSize;
    }
    _viewer
    ..style.backgroundImage = 'url($link)'
    ..style.backgroundRepeat = 'no-repeat';
    _resize();
  }

  _resize(){
    if (_viewer != null){
      if (_zoom < _minZoom) _zoom = _minZoom;
      if (_zoom > _maxZoom) _zoom = _maxZoom;
      var maxX = (_viewer.clientWidth - _width * _zoom).round();
      _posX = _posX < maxX ? maxX : _posX;
      var maxY = (_viewer.clientHeight - _height * _zoom).round();
      _posY = _posY < maxY ? maxY : _posY;
      _posX = _posX > 0 ? 0 : _posX;
      _posY = _posY > 0 ? 0 : _posY;
      _viewer
      ..style.backgroundSize = '${(_width*_zoom).round()}px ${(_height*_zoom).round()}px'
      ..style.backgroundPositionX = '${_posX}px'
      ..style.backgroundPositionY = '${_posY}px';
    }
  }
}
