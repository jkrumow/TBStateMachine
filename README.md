# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://img.shields.io/travis/tarbrain/TBStateMachine/master.svg?style=flat)](https://travis-ci.org/tarbrain/TBStateMachine)
[![Coverage Status](https://img.shields.io/coveralls/tarbrain/TBStateMachine/master.svg?style=flat)](https://coveralls.io/r/tarbrain/TBStateMachine)


A lightweight hierarchical state machine implementation in Objective-C.

## Features

* Block based API
* Wrapper class for nested states
* Wrapper class for orthogonal regions
* External, local and internal transitions with guards and actions
* State switching using least common ancestor algorithm (LCA)
* Event deferral
* NSNotificationCenter support

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
stateA.enterBlock = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {
        
    // ...
       
};
    
stateA.exitBlock = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {
        
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
[stateMachine setUp:nil];
```

The state machine will immediately enter the initial state.

### Event Handling

You can register an event which triggers the transition to a specified target state:

```objective-c
[stateA registerEvent:@"EventA" target:stateB];
```

You can also register an event with additional action and guard blocks:

```objective-c

TBSMActionBlock action = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {
                
    // ...
};

TBSMGuardBlock guard = ^BOOL(TBSMState *source, TBSMState *target, NSDictionary *data) {

    return YES;
};

[stateA registerEvent:@"EventA" target:stateB type:TBSMTransitionExternal action:action guard:guard];
```

If you register multiple transitions for the same event the guard blocks decide which one will be fired.

#### Different Types of Transitions

By default transitions are external. To define a transition type explicitly choose one of the three types:

```objective-c
[stateA registerEvent:@"EventA" target:stateB type:TBSMTransitionExternal action:action guard:guard];
[stateA registerEvent:@"EventA" target:stateB type:TBSMTransitionLocal action:action guard:guard];
[stateA registerEvent:@"EventA" target:stateA type:TBSMTransitionInternal action:action guard:guard];
```

#### Event Deferral

Under certain conditions you may want to handle an event later in another state:

```objective-c
[stateA deferEvent:@"EventB"];
```
Now the event will be queued until another state has been entered which can consume the event.

#### Scheduling Events

To schedule the event call `scheduleEvent:` and pass the specified `TBSMEvent` instance and (optionally) an `NSDictionary` with payload:

```objective-c
TBSMEvent *event = [TBSMEvent eventWithName:@"EventA" data:@{@"myPayload":aPayloadObject}];
[stateMachine scheduleEvent:event];
```

Event processing follows the Run to Completion model. All events will be queued until processing of the current event has finished.

The payload will be available in all action, guard, enter and exit blocks which are executed until the event is successfully handled.

### Nested States

`TBSMState` instances can also be nested by using the `TBSMSubState` wrapper class:

```objective-c
TBSMStateMachine *subMachine = [TBSMStateMachine stateMachineWithName:@"Sub"];
subMachine.states = @[stateC, stateD];

TBSMSubState *subState = [TBSMSubState subStateWithName:@"SubState" 
                                           stateMachine:subMachine];

stateMachine.states = @[stateA, stateB, subState];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Orthogonal Regions

To build orthogonal regions you will use the `TBSMParallelState`:

```objective-c
TBSMParallelState *parallel = [TBSMParallelState parallelStateWithName:@"P"];
parallel.states = @[subMachineA, subMachineB, subMachineC];
    
stateMachine.states = @[stateA, stateB, parallel];
```

### Notfications

`TBSMState` posts NSNotifications on entry and exit. The naming scheme is `[state name]_DidEnterNotification` and `[state name]_DidExitNotification`.

## Helpful theory

* [http://www.omg.org/spec/UML/2.5/Beta2/](http://www.omg.org/spec/UML/2.5/Beta2/)
* [http://www.comp.nus.edu.sg/~lius87/uml/techreport/uml_sm_semantics.pdf](http://www.comp.nus.edu.sg/~lius87/uml/techreport/uml_sm_semantics.pdf)


## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
