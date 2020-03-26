#const horizon = 0.

% facts
time(0..horizon).
floor(0..5).
elevator(1).

% calls on floors 3 and 5 for elevator 1 on floor 4
holds(on(3),0).
holds(on(5),0).
holds(current_floor(1,4),0).

% actions and their preconditions
action(turnoff(E,N)) :- elevator(E), floor(N).
action(open(E)) :- elevator(E).
action(close(E)) :- elevator(E).
action(up(E,N)) :- elevator(E), floor(N).
action(down(E,N)) :- elevator(E), floor(N).
action(idle(E)) :- elevator(E).

poss(up(E,N),T) :- holds(current_floor(E,M),T), floor(N), M < N.
poss(down(E,N),T) :- holds(current_floor(E,M),T), floor(N), M > N.
poss(open(E),T) :- elevator(E), time(T).
poss(close(E),T) :- elevator(E), time(T).
poss(turnoff(E,N),T) :- holds(current_floor(E,N),T), holds(on(N),T).
poss(idle(E),T) :- elevator(E), time(T).

% fluents
fluent(on(N)) :- floor(N).
fluent(current_floor(E,N)) :- elevator(E), floor(N).

% frame axioms
holds(current_floor(E,N),T) :- holds(current_floor(E,N),T-1), not occurs(up(E,_),T-1), not occurs(down(E,_),T-1), time(T).

holds(on(N),T) :- holds(on(N),T-1), not occurs(turnoff(_,N),T-1), time(T).

% successor state axioms
holds(current_floor(E,N),T) :- occurs(up(E,N),T-1).
holds(current_floor(E,N),T) :- occurs(down(E,N),T-1).

% generation of actions
1 { occurs(up(E,N),T) : floor(N) ;
    occurs(down(E,N),T) : floor(N) ;
    occurs(open(E),T) ;
    occurs(close(E),T) ;
    occurs(turnoff(E,N),T) : floor(N) ;
    occurs(idle(E), T) } 1 :- elevator(E), time(T), T < horizon.

% action must not occur if their preconditions are not met
:- occurs(A,T), not poss(A,T).