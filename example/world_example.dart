///   Copyright 2013 Stefan Nolde snolde@gmail.com
///
///   Licensed under the Apache License, Version 2.0 (the "License");
///   you may not use this file except in compliance with the License.
///   You may obtain a copy of the License at
///
///       http://www.apache.org/licenses/LICENSE-2.0
///
///   Unless required by applicable law or agreed to in writing, software
///   distributed under the License is distributed on an "AS IS" BASIS,
///   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///   See the License for the specific language governing permissions and
///   limitations under the License.

import 'dart:io';
import 'dart:async';

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


void main() {
  var created = new List<Object>();
  
  Flight ctx= new Flight.named("root");
  ctx.instantiatorHook = (obj) => created.add(obj);
  ctx.singleton(World, () => new World.ioc(ctx, true), (c) => c.init('BaseWorld',
                           ctx.depends('someWorld'), ctx.depends('otherWorld')));
  ctx.register('someWorld',
      () => new World.named('Bogus'),
      singleton : false,
      injector:(c) => c.init('Scheibenwelt', ctx.depends('otherWorld'), ctx.depends(World)));  
  ctx.register('otherWorld',
      () => new World.named('Anderswelt'),
      singleton : false,
      injector : (c) => c.init('Anderswelt', ctx.depends(World),ctx.depends('lostWorld')));  
  ctx.register('lostWorld', 
      () => new World.named('cf'),
      singleton : false,
      injector : (c) => c.init('Moons', new ClusterWorld('Satelites'), new ClusterWorld('Asteroids')));
  World world1=ctx.resolve(World);
  /**
  World world2=world1.prev;
  World world3=world1.next;
  World world4=world2.prev;
  print("1: ${world1.summary()}");
  print("2: ${world2.summary()}");
  print("3: ${world3.summary()}");
  **/
  print("Please, enter a line \n");
  Stream cmdLine = stdin
      .transform(new StringDecoder())
      .transform(new LineTransformer());

  StreamSubscription cmdSubscription = cmdLine.listen(
    (line) => print('Entered line: $line '),
    onDone: () => print(' finished'),
    onError: (e) => print(' error on input') );
  
  for (World w in created){
    print("${w.summary()}");
  }
  
}
