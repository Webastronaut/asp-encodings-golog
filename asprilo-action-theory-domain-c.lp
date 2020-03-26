robot(R) :- init(object(robot,R),_).
shelf(S) :- init(object(shelf,S),_).
station(P) :- init(object(pickingStation,P),_).
product(A) :- init(object(product,A),_).

isRobot(robot(R)) :- robot(R).
isShelf(shelf(S)) :- shelf(S).
isStation(station(T)) :- station(T).
isProduct(product(A)) :- product(A).
isOrder(order(O)) :- order(O).

order(O) :- init(object(order,O),_).
ordered(order(O),product(A)) :- init(object(order,O), value(line,(A,_))).
target(order(O),station(P)) :- init(object(order,O), value(pickingStation,P)).

shelved(shelf(S),product(A)) :- init(object(product,A),value(on,(S,_))).

position((X,Y)) :- init(object(node,_), value(at,(X,Y))).

position(station(P),(X,Y)) :- init(object(pickingStation,P), value(at,(X,Y))).

position(robot(R),(X,Y),0) :- init(object(robot,R), value(at,(X,Y))).
position(shelf(S),(X,Y),0) :- init(object(shelf,S), value(at,(X,Y))).

highway(C) :- init(object(highway,_), value(at,C)).

time(0..horizon).

direction((X,Y)) :- X=-1..1, Y=-1..1, |X+Y|=1.
nextto((X,Y),(X',Y'),(X+X',Y+Y')) :- position((X,Y)), direction((X',Y')), position((X+X',Y+Y')).

{ move(R,D,T) : direction(D) ;
pickup(R,S,T) : isShelf(S) ;
putdown(R,S,T) : isShelf(S) } 1 :- isRobot(R), time(T), T<horizon.

waits(R,T) :- not pickup(R,_,T), not putdown(R,_,T), not move(R,_,T), isRobot(R), time(T), T<horizon.

position(R,C,T) :- move(R,D,T), position(R,C',T-1), nextto(C',D,C).
:- move(R,D,T), position(R,C ,T-1), not nextto(C, D,_).

carries(R,S,T) :- pickup(R,S,T).
:- pickup(R,S,T), carries(R,_,T-1).
:- pickup(R,S,T), carries(_,S,T-1).
:- pickup(R,S,T), position(R,C,T-1), not position(S,C,T-1).
:- pickup(R,S,T), position(S,C,T-1), not position(R,C,T-1).

:- putdown(R,S,T), not carries(R,S,T-1).

position(R,C,T) :- position(R,C,T-1), not move(R,_,T), isRobot(R), time(T).
carries(R,S,T) :- carries(R,S,T-1), not putdown(R,S,T), time(T).

position(S,C,T) :- position(R,C,T ), carries(R,S,T).
position(S,C,T) :- position(S,C,T-1), not carries(_,S,T), isShelf(S), time(T).

moveto(C',C,T) :- nextto(C',D,C), position(R,C',T-1), move(R,D,T).
:- moveto(C',C,T), moveto(C,C',T), C < C'.

:- { position(R,C,T) : isRobot(R) } > 1, position(C), time(T).
:- { position(S,C,T) : isShelf(S) } > 1, position(C), time(T).

:- { position(R,C,T) } != 1, isRobot(R), time(T).
:- { position(S,C,T) } != 1, isShelf(S), time(T).

:- { carries(R,S,T) } > 1, isRobot(R), time(T).
:- { carries(R,S,T) } > 1, isShelf(S), time(T).

process(  A,O,C,T) :- ordered(O,A), target(O,P), position(P,C), shelved(S,A), not position(S,C,0), position(S,C,T).
process(  A,O,C,T) :- ordered(O,A), target(O,P), position(P,C), shelved(S,A), position(S,C,0), carries(_,S,T).
processed(A,  C)   :- process(A,O,C,T).