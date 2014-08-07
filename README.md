# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)

## Example Project

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Requirements

* Xcode 5
* iOS 5.0
* OS X 10.7

## Installation

TBStateMachine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TBStateMachine"

## Usage

Create state objects, set enter and exit blocks and event handler:

```objective-c
TBStateMachineState *stateA = [[TBStateMachineState alloc] initWithName:@"StateA"];
[stateA setEnterBlock:^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        
    // ...
       
}];
    
[stateA setExitBlock:^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        
    // ...
       
}];

NSDictionary *eventData = // ...
TBStateMachineEvent *eventA = [[TBStateMachineEvent alloc] initWithName:@"EventA" data:eventData];
[stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    // ...
        
    return // another state object or nil
}];
```


Create a state machine instance:

```objective-c
TBStateMachine *stateMachine = [[TBStateMachine alloc] initWithName:@"StateMachine"];
```

Add states and set state machine up:

```objective-c
NSArray *states = @[stateA, stateB, ...];
[stateMachine setStates:states];
[stateMachine setInitialState:stateA];
[stateMachine setup];
```

### Sub state machines

A TBStateMachine can also be nested as a sub state machines. Instead of a `TBMachineStateState` instance you can set a `TBStateMachine` instance:

```objective-c
NSArray *subStates = @[stateC, stateD];
TBStateMachine *subStateMachine = [[TBStateMachine alloc] initWithName:@"SubStateMachine"];
[subStateMachine setStates:subStates];
[subStateMachine setInitialState:stateC];

NSArray *states = @[stateA, stateB, subStateMachine];
[stateMachine setStates:states];
```

You do not need to call `- (void)setup` and `- (void)tearDown` since the implementations of `-(void)enter:transition:` and `- (void)exit:transition:` will do that.

### Parallel States and State Machines

To run multiple states and sub state machines use the `TBStateMachineParallelWrapper`:

```objective-c
TBStateMachineParallelWrapper *parallelWrapper = [[TBStateMachineParallelWrapper alloc] initWithName:@"ParallelWrapper"];
NSArray *parallelStates = @[stateC, stateD, subStateMachine];
[parallelWrapper setStates:parallelStates];
    
NSArray *states = @[stateA, stateB, parallelWrapper];
[stateMachine setStates:states];
```

### Switching states

Manual switching:

```objective-c
[stateMachine switchState:stateB];
```

Switching in an event handler block:

```objective-c
__block weakSelf = self;
[stateA addEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    // ...
      
    return weakSelf.stateB;
}];
```

### Event handling

To send an event:

```objective-c
[stateMachine handleEvent:eventA];
```

The top-most state object will execute the event (if it implements a handler for it).
Return values will bubble up to the parent (sub) state machine.


## Author

Julian Krumow, julian.krumow@tarbrain.com

Thanks to [mask](https://github.com/mask) and [monolar](https://github.com/monolar) for technical and academic advice.

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.

