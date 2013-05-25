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

class Instantiator{
  
  //static List<World> objects = new List<World>();
  
  String classref;
  var lastInstance=null;
  bool singleton=false;
  bool inited=false;
  Function _instantiatorHook=null;
  
  Function constructor;
  Function initializer=null;
  
  Instantiator(this.classref, this.constructor, [singleton = true]){
    this.singleton = singleton;
  }
  initialize(o){
    if (initializer!=null){
      //print("call initializer");
      initializer(o);
      finalize();
    }
  }
  
  bool finalize(){
    if (singleton) inited=true;
    return inited;
  }
  
  getInstance(){
    if (lastInstance==null || !singleton){
      var instance = constructor();
      // how do we work with detecting fatory methods that deliver singletons "sometimes"?
      lastInstance = instance;
      
      // call inst Hook
      if (_instantiatorHook!=null) _instantiatorHook(instance);
      
      //print("Instantiated ${lastInstance.num}");
      //objects.add(lastInstance);
    }
    return lastInstance;
  }
  
}

class FlightCrashException implements Exception{
  
  final String message="";
  
  const FlightCrashException([String message = ""]);

  String toString(){
    return "FlightCrashException, fasten seatbelts, we're going down... - " +message;
  }
}

class Flight{
  
  var name;
  
  Map<String,Instantiator> cache = new Map<String,Instantiator>();
  
  List<Function> injectors = [];
  
  bool isRoot = true;
  
  Function _instantiatorHook=null;
  
  Flight({bool root : true}){
    name = "default";
  }
  
  Flight.named(this.name, {bool root : true}){}

  /// Convenience method to register singletons enforced by the context
  void singleton(type, Function constructor, [Function injector] ){
    if (?injector){
      register(type, constructor, singleton : true, injector : injector);
    } else {
      register(type, constructor, singleton : true);
    }
  }
  
  /// Sets a Function in the format (obj) => f(obj) to be invoked whenever
  /// the instantiator calls the constructor for a new object.
  /// If the container does not enforce a singleton, but the Constructor method does,
  /// this might happen several times whenever that object is requested.
  void set instantiatorHook(Function f){
    _instantiatorHook = f;
  }
  
  
  
  /// Convenience method to register object prototypes by the context
  void protoype(type, Function constructor, [Function injector] ){
    if (?injector){
      register(type, constructor, singleton : false, injector : injector);
    } else {
      register(type, constructor, singleton : false);
    }
  }
  
  /// Registers a constructor according to a type. Type.toString() is used for lookup,
  /// so either Classes or Strings can be used for registry and lookup.
  ///
  /// Recommended is to use lower case keys or classnames.
  /// 
  void register(type, Function constructor, {bool singleton : true, Function injector}){
    //print(type.toString());
    Instantiator inst;
    if (!cache.containsKey(type.toString())){
      inst = new Instantiator(type.toString(), constructor, singleton);
      
      _setInstantiatorHook(inst);
      cache[type.toString()] = inst;
    }
    if (?injector){
      inst.initializer=injector;
    }
  }
  
  resolve(Object name){
    return _resolve(name, true);
  }
  
  depends(Object name){
    return _resolve(name, false);
  }
  
  void _setInstantiatorHook(Instantiator inst){
    if (_instantiatorHook!=null){
      inst._instantiatorHook = _instantiatorHook;
    }
  }

  _resolve(name, [bool complete = true]){
    //print("resolve ${name}");
    var o=null;
    if (cache.containsKey(name.toString())){
      Instantiator inst = cache[name.toString()];
      o = inst.getInstance();

      //we have an object, but it need not be complete
      //start the cascade
      if (complete) inst.initialize(o); 
      
      //init logic
      if (!complete){
        // if we know it's a singleton, we are inited?
        if (inst.initializer!=null){
          if (!inst.inited){
            //print("defer init for ${o.num.toString()} ${o.runtimeType}");
            _deferInit(() => inst.initialize(o) );
            // initialization is on the way
          }
        }
        return o;
      } else {
        // only on the main resolve call
        //print("init depends");
        _initDepends(0);
      }
      //finally we get to initialize this (or not)
      return o;
    } else {

      // now we are in trouble, lets throw some exception
      throw new FlightCrashException("Cannot resolve " + name + " in context " + this.name + ".");

    }
  }
  
  void _initDepends(int i){

    List inj = new List.from(injectors);

    //inj.addAll(injectors);
    
    this.injectors.clear();

    for (Function f in inj){
      f();
    }

    //reiterate over next level initiators
    if (injectors.length>0) {
      _initDepends(i);
    }
  }
  
  void _deferInit(Function f){
    injectors.add(f);
  }
  
  bool test(){
    // some smart test of container integrity?
    bool pass=true;
    
  }
}
