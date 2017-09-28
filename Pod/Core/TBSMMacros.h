//
//  TBSMMacros.h
//  TBStateMachine
//
//  Created by Julian Krumow on 28.09.17.
//  Copyright (c) 2014-2017 Julian Krumow. All rights reserved.
//

#ifndef TBSMMacros_h
#define TBSMMacros_h

#define StateMachineEvents(name) \
^(StateMachineEvents event) { \
switch (event) { \
case name: \
default: \
return @#name; \
} \
}(name)

#endif /* TBSMMacros_h */
