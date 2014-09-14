# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://img.shields.io/travis/tarbrain/TBStateMachine/master.svg?style=flat)](https://travis-ci.org/tarbrain/TBStateMachine)


A lightweight event-driven hierarchical state machine implementation in Objective-C.

## Features

* block based API
* nested state (sub state machines)
* wrapper for parallel state machines (orthogonal regions)
* guards and transitions and actions
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

Create state objects, set enter and exit blocks:

```objective-c
TBStateMachineState *stateA = [TBStateMachineState stateWithName:@"StateA"];
stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
        
    // ...
       
};
    
stateA.exitBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
        
    // ...
       
};
```

Create a state machine instance:

```objective-c
TBStateMachine *stateMachine = [TBStateMachine stateMachineWithName:@"StateMachine"];
```

Add states and set state machine up:

```objective-c
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateA;
[stateMachine setup];
```

The state machine will immediately enter the initial state.

### Switching States

You can register an event handler from a given event and target state:

```objective-c
[stateA registerEvent:eventA target:stateB];
```

You can also register an event handler with additional action and guard blocks:

```objective-c
[stateA registerEvent:eventA 
               target:stateB
               action:^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                   
                   // ...
                   
               }
                guard:^BOOL(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
                   
                   return // YES or NO;
               }];
```

Send the event:

```objective-c
NSDictionary *payload = // ...
TBStateMachineEvent *eventA = [TBStateMachineEvent eventWithName:@"EventA"];
[stateMachine scheduleEvent:eventA data:payload];
```

The state machine will queue all events it receives until processing of the current state has finished.

### Nested State Machines

TBStateMachine instances can also be nested as sub-state machines. Instead of a `TBMachineStateState` instance you can set a `TBStateMachine` instance:

```objective-c
TBStateMachine *subStateMachine = [TBStateMachine stateMachineWithName:@"SubStateMachine"];
subStateMachine.states = @[stateC, stateD];
subStateMachine.initialState = stateC;

stateMachine.states = @[stateA, stateB, subStateMachine];
```

You do not need to call `- (void)setup` and `- (void)tearDown` on the sub-state machine since these methods will be called by the super-state machine.

### Parallel State Machines

To run multiple state machines in parallel you will use the `TBStateMachineParallelWrapper`:

```objective-c
TBStateMachineParallelWrapper *parallelWrapper = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
parallelWrapper.states = @[subStateMachineA, subStateMachineB, subStateMachineC];
    
stateMachine.states = @[stateA, stateB, parallelWrapper];
```

### Concurrency

Actions, guards, enter and exit blocks will be executed on a background queue. Make sure the code in these blocks is dispatched back onto the right queue:

```objective-c
stateA.enterBlock = ^(id<TBStateMachineNode> sourceState, id<TBStateMachineNode> destinationState, NSDictionary *data) {
    
    // evaluate payload data
    NSString *text = data[@"text"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        label.text = text;
    
    });
    
};
```

## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
