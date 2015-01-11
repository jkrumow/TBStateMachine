# TBStateMachine CHANGELOG

## 4.0.2

- fixed bug which caused `TBSMParallelState` not to setup all sub machines when performing transition into one state machine

## 4.0.1

- corrected event deferral algorithm

## 4.0.0

- corrected event deferral algorithm
- changed event registration / deferral API

## 3.1.0

- added internal transitions
- added event deferral
- removed method `-unregisterEvent:` from class `TBSMState`
- renamed property `states` to `stateMachines` in class `TBSMParallelState`

## 3.0.4

- re-added internal dispatch queue for `TBSMParallelState`

## 3.0.3

- removed internal dispatch queues

## 3.0.2

- removed log messages
- code cleanup

## 3.0.1

- removed method `- (TBSMTransition *)handleEvent:(TBSMEvent *)event` from `TBSMNode` protocol

## 3.0.0

- changed class name to use prefix `TBSM` instead of `TBStateMachine`
- added TBSMSubState which derives from `TBSMState` (formerly known as `TBStateMachineState`)

## 2.0.1

### fixes

- LCA handling was broken and resulted in a wrong execution sequence of exit - action - enter
- corrected typos in CHANGELOG.md (this document)

## 2.0.0

### enhanced state switching:

- state machine can now switch from a substate of a sub state machine deep into another submachine. Implementation uses LCA (Lowest Common Ancestor) - algorithm

### re-worked event handling:

- events will be registered by setting target action and guard:

```
- (void)registerEvent:(TBStateMachineEvent *)event
               target:(id<TBStateMachineNode>)target
               action:(TBStateMachineActionBlock)action
                guard:(TBStateMachineGuardBlock)guard;
```

- event processing follows RTC-model. The state machine will queue all events it receives until processing of the current event has finished

## 1.0.0

- updated documentation
- updated API

## 0.9.0

- initial release
