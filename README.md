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

```
TBStateMachineState *stateA = [TBStateMachineState stateWithName:@"StateA"];
stateA.enterBlock = ^(TBStateMachineState *previousState, TBStateMachineTransition *transition) {
        
    // ...
       
};
    
stateA.exitBlock = ^(TBStateMachineState *nextState, TBStateMachineTransition *transition) {
        
    // ...
       
};

TBStateMachineEvent *eventA = [TBStateMachineEvent eventWithName:@"EventA"];
[stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    // ...
        
    return // another state object or nil
}];
```


Create a state machine instance:

```
TBStateMachine *stateMachine = [TBStateMachine stateMachineWithName:@"StateMachine"];
```

Add states and set state machine up:

```
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateA;
[stateMachine setup];
```

### Sub state machines

A TBStateMachine can also be nested as a sub state machines. Instead of a `TBMachineStateState` instance you can set a `TBStateMachine` instance:

```
TBStateMachine *subStateMachine = [TBStateMachine stateMachineWithName:@"SubStateMachine"];
subStateMachine.states = @[stateC, stateD];
subStateMachine.initialState = stateC;

stateMachine.states = @[stateA, stateB, subStateMachine];
```

You do not need to call `- (void)setup` and `- (void)tearDown` since the implementations of `-(void)enter:transition:` and `- (void)exit:transition:` will do that.

### Parallel States and State Machines

To run multiple states and sub state machines use the `TBStateMachineParallelWrapper`:

```
TBStateMachineParallelWrapper *parallelWrapper = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
parallelWrapper.states = @[stateC, stateD, subStateMachine];
    
stateMachine.states = @[stateA, stateB, parallelWrapper];
```

### Switching states

Manual switching:

```
[stateMachine switchState:stateB];
```

Switching in an event handler block:

```
[stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    NSDictionary *data = event.data;
    // evaluate event data ...
      
    return stateB;
}];
```

### Event handling

To send an event:

```
NSDictionary *userInfo = @{@"message" : @"foobar", @"code", @[8]};
TBStateMachineEvent *eventA = [TBStateMachineEvent eventWithName:@"EventA" data:userInfo];
[stateMachine handleEvent:eventA];
```

The top-most state object will execute the event (if it implements a handler for it).
Return values will bubble up to the parent (sub) state machine.


## Author

Julian Krumow, julian.krumow@tarbrain.com

Thanks to [mask](https://github.com/mask) and [monolar](https://github.com/monolar) for technical and academic advice.

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.

