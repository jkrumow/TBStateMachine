# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://img.shields.io/travis/tarbrain/TBStateMachine/master.svg?style=flat)](https://travis-ci.org/tarbrain/TBStateMachine)
[![Coverage Status](https://img.shields.io/coveralls/tarbrain/TBStateMachine/master.svg?style=flat)](https://coveralls.io/r/tarbrain/TBStateMachine)


A lightweight event-driven hierarchical state machine implementation in Objective-C.

## Features

* block based API
* wrapper class for nested state machines (sub state machines)
* wrapper class for parallel state machines (orthogonal regions)
* transitions with guards and actions
* thread safe event handling and switching
* state switching using lowest common ancestor algorithm (LCA)

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

Create a state, set enter and exit blocks:

```objective-c
TBSMState *stateA = [TBSMState stateWithName:@"StateA"];
stateA.enterBlock = ^(TBSMState *source, TBSMState *destination, NSDictionary *data) {
        
    // ...
       
};
    
stateA.exitBlock = ^(TBSMState *source, TBSMState *destination, NSDictionary *data) {
        
    // ...
       
};
```

Create a state machine:

```objective-c
TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"Main"];
```

Add states and set state machine up. The state machine will always set the first state in the given array as the initial state unless you set the initial state explicitly:

```objective-c
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateB;
[stateMachine setup];
```

The state machine will immediately enter the initial state.

### Event Handlers

You can register an event handler from a given event and target state:

```objective-c
[stateA registerEvent:event target:stateB];
```

You can also register an event handler with additional action and guard blocks:

```objective-c

TBSMActionBlock action = ^(TBSMState *source, TBSMState *destination, NSDictionary *data) {
                
    // ...
};

TBSMGuardBlock guard = ^BOOL(TBSMState *source, TBSMState *destination, NSDictionary *data) {

    return YES;
};

[stateA registerEvent:event target:stateB action:action guard:guard];
```

To schedule the event call `scheduleEvent:` and pass the specified `TBSMEvent` instance and (optionally) an `NSDictionary` with payload:

```objective-c
TBSMEvent *event = [TBSMEvent eventWithName:@"EventA"];
[stateMachine scheduleEvent:event data:@{@"myPayload":aPayloadObject}];
```

The state machine will queue all events it receives until processing of the current event has finished.

The payload will be available in all action, guard, enter and exit handlers which are passed until the event is successfully handled.

### Nested State Machines

`TBSMStateMachine` instances can also be nested as sub-state machines. To achieve this you will use the `TBSMSubState` wrapper class:

```objective-c
TBSMStateMachine *subMachine = [TBSMStateMachine stateMachineWithName:@"Sub"];
subMachine.states = @[stateC, stateD];

TBSMSubState *subState = [TBSMSubState subStateWithName:@"SubState" 
                                           stateMachine:subMachine];

stateMachine.states = @[stateA, stateB, subState];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Parallel State Machines

To run multiple state machines in parallel you will use the `TBSMParallelState`:

```objective-c
TBSMParallelState *parallel = [TBSMParallelState parallelStateWithName:@"P"];
parallel.states = @[subMachineA, subMachineB, subMachineC];
    
stateMachine.states = @[stateA, stateB, parallel];
```
### Concurrency

Actions, guards, enter and exit blocks of states within a TBSMParallelState will be executed on a concurrent background queue. Make sure the code in these blocks is dispatched back onto the expected queue.



## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
