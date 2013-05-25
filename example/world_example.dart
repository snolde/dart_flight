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
import 'world_example/world_classes.dart';


void main() {
  var created = new List<Object>();
  
  Flight ctx= new Flight.named("root");
  ctx.instantiatorHook = (obj) => created.add(obj);
  ctx.singleton(World,
      () => new World.ioc(ctx, true),
      (o) => o.init('BaseWorld', ctx.depends('someWorld'), ctx.depends('otherWorld')));
  ctx.prototype('someWorld',
      () => new World.named('Bogus'),
      (o) => o.init('Scheibenwelt', ctx.depends('otherWorld'), ctx.depends(World)));  
  ctx.prototype('otherWorld',
      () => new World.named('Anderswelt'),
      (o) => o.init('Anderswelt', ctx.depends(World),ctx.depends('lostWorld')));  
  ctx.register('lostWorld', 
      () => new World.named('cf'),
      singleton : false,
      injector : (o) => o.init('Moons', new ClusterWorld('Satelites'), new ClusterWorld('Asteroids')));
  World world1=ctx.resolve(World);
  
  for (World w in created){
    print("${w.summary()}");
  }
  
}
