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
* Pseudo states (fork and join)
* External, internal and local transitions with guards and actions
* State switching using least common ancestor algorithm (LCA)
* Thread safe event handling
* Asynchronous event handling
* NSNotificationCenter support

## Example Project

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Requirements

* Xcode 6
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

### Event Handling

You can add event handlers which trigger transitions to specified target states:

```objective-c
[stateA addHandlerForEvent:@"EventA" target:stateB];
```

You can also add event handlers with additional action and guard blocks:

```objective-c

TBSMActionBlock action = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {
                
    // ...
};

TBSMGuardBlock guard = ^BOOL(TBSMState *source, TBSMState *target, NSDictionary *data) {

    return YES;
};

[stateA addHandlerForEvent:@"EventA" target:stateB kind:TBSMTransitionExternal action:action guard:guard];
```

If you register multiple handlers for the same event the guard blocks decide which transition will be fired.

#### Different Kinds of Transitions

By default transitions are external. To define a transition kind explicitly choose one of the three kind attributes:

```objective-c
[stateA addHandlerForEvent:@"EventA" target:stateB kind:TBSMTransitionExternal action:action guard:guard];
[stateA addHandlerForEvent:@"EventA" target:stateA kind:TBSMTransitionInternal action:action guard:guard];
[stateA addHandlerForEvent:@"EventA" target:stateB kind:TBSMTransitionLocal action:action guard:guard];
```

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
TBSMSubState *subState = [TBSMSubState subStateWithName:@"SubState"];
substate.stateMachine = subMachine;

stateMachine.states = @[stateA, stateB, subState];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Orthogonal Regions

To build orthogonal regions you will use the `TBSMParallelState`:

```objective-c
TBSMParallelState *parallel = [TBSMParallelState parallelStateWithName:@"ParallelState"];
parallel.stateMachines = @[subMachineA, subMachineB, subMachineC];
    
stateMachine.states = @[stateA, stateB, parallel];
```

### Pseudostates

TBStateMachine supports fork and join pseudo states to construct compound transitions:

#### Fork

```objective-c
TBSMFork *fork = [TBSMFork forkWithName:@"fork"];
[fork setTargetStates:@[stateB,stateC] inRegion:parallel];
[stateA addHandlerForEvent:@"EventA" target:fork];
```

#### Join

```objective-c
TBSMJoin *join = [TBSMJoin joinWithName:@"join"];
[stateA addHandlerForEvent:@"EventA" target:join];
[stateB addHandlerForEvent:@"EventB" target:join];
[join setSourceStates:@[stateA,stateB] target:stateC];
```

### Notfications

`TBSMState` posts NSNotifications on entry and exit:

* TBSMStateDidEnterNotification
* TBSMStateDidExitNotification

The notification's `userInfo` contains:

```objective-c
{
    TBSMSourceStateUserInfo:theSourceState,
    TBSMTargetStateUserInfo:theTargetState,
    TBSMDataUserInfo:theData
}
```

To receive a notification:

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myHandler:) name:TBSMStateDidEnterNotification object:stateA];

- (void)myHandler:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo[TBSMDataUserInfo];
    
    id myPayloadObject = data[@"myPayload"];
    
    // ...
}
```

### Thread Safety and Concurrency

`TBStateMachine` is thread safe. Each event is processed following the RTC (Run To Completion) model, encapsulated in a block which is dispatched asynchronously to the main queue by default.

To use a custom queue simply set:

```objective-c
NSOperationQueue *queue = [NSOperationQueue new];
queue.name = @"com.mycompany.queue";
queue.maxConcurrentOperationCount = 1;
stateMachine.scheduledEventsQueue = queue;
```

## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
