# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://img.shields.io/travis/tarbrain/TBStateMachine/master.svg?style=flat)](https://travis-ci.org/tarbrain/TBStateMachine)
[![Coverage Status](https://img.shields.io/coveralls/tarbrain/TBStateMachine/master.svg?style=flat)](https://coveralls.io/r/tarbrain/TBStateMachine)


A lightweight hierarchical state machine implementation in Objective-C.

## Features

* Block based API
* Nested states
* Orthogonal regions
* Pseudo states (fork, join and junction)
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

```objc
#import <TBStateMachine/TBSMStateMachine.h>
```

Create a state, set enter and exit blocks:

```objc
TBSMState *stateA = [TBSMState stateWithName:@"StateA"];
stateA.enterBlock = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {

};
    
stateA.exitBlock = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {

};
```

Create a state machine:

```objc
TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"Main"];
```

Add states and set state machine up. The state machine will always set the first state in the given array as the initial state unless you set the initial state explicitly:

```objc
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateB;
[stateMachine setUp:nil];
```

### Event Handling

You can add event handlers which trigger transitions to specified target states:

```objc
[stateA addHandlerForEvent:@"EventA" target:stateB];
```

You can also add event handlers with additional action and guard blocks:

```objc

TBSMActionBlock action = ^(TBSMState *source, TBSMState *target, NSDictionary *data) {

};

TBSMGuardBlock guard = ^BOOL(TBSMState *source, TBSMState *target, NSDictionary *data) {

    return YES;
};

[stateA addHandlerForEvent:@"EventA" target:stateB kind:TBSMTransitionExternal action:action guard:guard];
```

If you register multiple handlers for the same event the guard blocks decide which transition will be fired.

#### Different Kinds of Transitions

By default transitions are external. To define a transition kind explicitly choose one of the three kind attributes:

```
- TBSMTransitionExternal
- TBSMTransitionInternal
- TBSMTransitionLocal
```

#### Scheduling Events

To schedule the event call `scheduleEvent:` and pass the specified `TBSMEvent` instance and (optionally) an `NSDictionary` with payload:

```objc
TBSMEvent *event = [TBSMEvent eventWithName:@"EventA" data:@{@"myPayload":aPayloadObject}];
[stateMachine scheduleEvent:event];
```

The payload will be available in all action, guard, enter and exit blocks which are executed until the event is successfully handled.

#### Run-to-Completion

Event processing follows the Run-to-Completion model to ensure that only one event will be handled at a time. A single RTC-step encapsulates the whole logic from evaluating the event to performing the transition to executing guards, actions, exit and enter blocks.

Events will be queued and processed one after the other.

### Nested States

`TBSMState` instances can also be nested by using the `TBSMSubState` wrapper class:

```objc
TBSMSubState *subState = [TBSMSubState subStateWithName:@"SubState"];
substate.stateMachine = subMachine;

stateMachine.states = @[stateA, stateB, subState];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Orthogonal Regions

To build orthogonal regions you will use the `TBSMParallelState`:

```objc
TBSMParallelState *parallel = [TBSMParallelState parallelStateWithName:@"ParallelState"];
parallel.stateMachines = @[subMachineA, subMachineB, subMachineC];
    
stateMachine.states = @[stateA, stateB, parallel];
```

### Pseudo States

TBStateMachine supports fork and join pseudo states to construct compound transitions:

#### Fork

```objc
TBSMFork *fork = [TBSMFork forkWithName:@"fork"];
[stateA addHandlerForEvent:@"EventA" target:fork];
[fork setTargetStates:@[stateB, stateC] inRegion:parallel];
```

#### Join

```objc
TBSMJoin *join = [TBSMJoin joinWithName:@"join"];
[stateA addHandlerForEvent:@"EventA" target:join];
[stateB addHandlerForEvent:@"EventB" target:join];
[join setSourceStates:@[stateA, stateB] inRegion:parallel target:stateC];
```

#### Junction

```objc
TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
stateA addHandlerForEvent:@"EventA" target:junction];
[junction addOutgoingPathWithTarget:stateB action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
    
    return // ...
}];
[junction addOutgoingPathWithTarget:stateC action:nil guard:^BOOL(TBSMState *sourceState, TBSMState *targetState, NSDictionary *data) {
    
    return // ...
}];
```

### Notifications

`TBSMState` posts NSNotifications on entry and exit:

* TBSMStateDidEnterNotification
* TBSMStateDidExitNotification

The notification's `userInfo` contains:

```objc
{
    TBSMSourceStateUserInfo:theSourceState,
    TBSMTargetStateUserInfo:theTargetState,
    TBSMDataUserInfo:theData
}
```

To receive a notification:

```objc
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myHandler:) name:TBSMStateDidEnterNotification object:stateA];

- (void)myHandler:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo[TBSMDataUserInfo];
    id myPayloadObject = data[@"myPayload"];
}
```

### Thread Safety and Concurrency

`TBStateMachine` is thread safe. Each event is processed asynchronously on the main queue by default.

To use a custom serial queue simply set:

```objc
NSOperationQueue *queue = [NSOperationQueue new];
queue.name = @"com.mycompany.queue";
queue.maxConcurrentOperationCount = 1;
stateMachine.scheduledEventsQueue = queue;
```

### Debug Support

`TBStateMachine` offers debug support through the subspec `DebugSupport`. Simply add it to your `Podfile` (most likely to a beta target to keep it out of production code):

```
target 'MyBetaApp', :exclusive => true do
  pod "TBStateMachine/DebugSupport"
end
```

Then include `TBSMStateMachine+DebugSupport.h` and activate the debug support features on the state machine **at the top of the hierarchy**:

```objc
#import <TBStateMachine/TBSMStateMachine+DebugSupport.h>

[stateMachine activateDebugSupport];
```

The category will then output a log message for every event, transition, setup, teardown, enter and exit including the duration of the performed Run-to-Completion step:

```
[Main]: will handle event 'EventA' data: (null)
[Main] will perform transition: stateA --> stateCc data: (null)
    Exit 'stateB' source: 'stateA' target: 'stateCc' data: (null)
	Enter 'stateC' source: 'stateA' target: 'stateCc' data: (null)
	Enter 'stateCc' source: 'stateA' target: 'stateCc' data: (null)
[Main]: run-to-completion step took 1.15 milliseconds
[Main]: remaining events in queue: 0
```

When calling `-activeStateConfiguration` you will get the current active state configuration of the whole hierarchy:

```objc
NSLog(@"%@", [stateMachine activeStateConfiguration]);
```

```
Main
    stateC
        subMachineC
            stateCc
```

## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
