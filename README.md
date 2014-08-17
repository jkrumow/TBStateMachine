# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)

A lightweight event-driven hierarchical finite state machine implementation in Objective-C.

## Features

* light-weight implementation
* state objects
* event handling
* thread safe event handling and switching
* nested state machines (sub-state machines)
* wrapper for parallel states and state machines
* block based API

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

### Configuration

Create state objects, set enter and exit blocks and register event handlers:

```
TBStateMachineState *stateA = [TBStateMachineState stateWithName:@"StateA"];
stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
        
    // ...
       
};
    
stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
        
    // ...
       
};

[stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    // ...
        
    return // the follow-up node or nil
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

The state machine will immediately enter the initial state.

### Sub-State Machines

TBStateMachine instances can also be nested as sub-state machines. Instead of a `TBMachineStateState` instance you can set a `TBStateMachine` instance:

```
TBStateMachine *subStateMachine = [TBStateMachine stateMachineWithName:@"SubStateMachine"];
subStateMachine.states = @[stateC, stateD];
subStateMachine.initialState = stateC;

stateMachine.states = @[stateA, stateB, subStateMachine];
```

You do not need to call `- (void)setup` and `- (void)tearDown` since they are wrapped by `-(void)enter:transition:` and `- (void)exit:transition:`.

### Parallel States and State Machines

To run multiple states and sub-state machines you can use the `TBStateMachineParallelWrapper`:

```
TBStateMachineParallelWrapper *parallelWrapper = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
parallelWrapper.states = @[subStateMachineA, subStateMachineB, stateZ];
    
stateMachine.states = @[stateA, stateB, parallelWrapper];
```

**Notice:**
When sending events into the TBStateMachineParallelWrapper instance each node will handle the event, but only the follow-up node which was returned first to the wrapper will switch out of the parallel state.

**Concurrency:**
Actions will be executed in parallel on different background threads. Make sure your event, enter and exit handler code is dispatched back onto the right queue.

### Switching States

Register an event handler which returns a valid node**:

```
[stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event) {
    
    NSDictionary *data = event.data;
    // evaluate event data ...
      
    return // the follow-up node or nil
}];
```

Send the event:

```
NSDictionary *userInfo = @{@"message" : @"abcde", @"code", @[12345]};
TBStateMachineEvent *eventA = [TBStateMachineEvent eventWithName:@"EventA" data:userInfo];
[stateMachine handleEvent:eventA];
```


## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.

