# TBStateMachine CHANGELOG

## 3.0.0

- added TBStateMachineSubState
- added event handler and enter / exit blocks to sub substates

## 2.0.1

### fixes

- LCA handling was broken and resulted in a wrong execution sequence of exit - action - enter.
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