import 'package:dart_flight/flight_core.dart';

class World{
  var name = "Home";
  
  World prev;
  
  World next;
  
  int num;
  
  static int c=0;
  
  static var _singleton = null;
  
  World();
  
  factory World.named(name){
    return new World().setNum();
  }
  
  factory World.ioc(Flight ctx, [ singleton = false]){
    print("Instantiate World in context ${ctx.name}");
    World o;
    if (!singleton || _singleton==null){
      if (ctx.name=='default'){
        o = new World().setNum();
      } else {
        o = new FlatWorld().setNum();
      }
      if (singleton) _singleton = o;
      return o;
    } else {
      return _singleton;
    }
  }
  
  factory World.singleton(){
    if (_singleton==null){
      _singleton=new World().setNum();
    }
    return _singleton;
  }
  void init(name, [prev, next]){
    this.name=name;
    print("inited ${num.toString()} ${name}");
    if (?prev) this.prev=prev;
    if (?next) this.next=next;
    if (?prev) print("set on ${num.toString()}: ${prev.num.toString()} ${prev.name}");
    if (?next) print("set on ${num.toString()}: ${next.num.toString()} ${next.name}");
  }
  
  String summary(){
    String s = "World ${num.toString()}: ${name}";
    if (prev is World) s += ", previous ${prev.num.toString()}: ${prev.name}";
    if (next is World) s += ", next ${next.num.toString()}: ${next.name}";
    return s;
  }
  
  World setNum(){
    num = c++;
    return this;
  }
}

class FlatWorld extends World{
  
  FlatWorld (){
    this.name = "Discworld";
  }
}

class ClusterWorld extends World{
  
  ClusterWorld(name){
    this.name=name;
  }
}

