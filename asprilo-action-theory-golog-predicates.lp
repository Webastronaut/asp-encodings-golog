% every robot is an agent
agent(X) :- isRobot(X).

% actions
action(move(R,D)) :- isRobot(R), direction(D).
action(pickup(R,S)) :- isRobot(R), isShelf(S).
action(putdown(R,S)) :- isRobot(R), isShelf(S).
action(wait(R)) :- isRobot(R).

performs(R,move(R,D),T) :- move(R,D,T).
performs(R,pickup(R,S),T) :- pickup(R,S,T).
performs(R,putdown(R,S),T) :- putdown(R,S,T).
performs(R,wait(R),T) :- waits(R,T).

% fluents
fluent(position(robot(R),(X,Y))) :- position(robot(R),(X,Y),_).
fluent(position(shelf(S),(X,Y))) :- position(shelf(S),(X,Y),_).
fluent(position(station(P),(X,Y))) :- position(station(P),(X,Y)).
fluent(carries(R,S)) :- isRobot(R), isShelf(S).
fluent(contains_ordered_products(S,P,O)) :- isShelf(S), isProduct(P), isOrder(O).
fluent(robot_under_shelf_with_ordered_products(R,S,P,O)) :- isShelf(S), isProduct(P), isOrder(O), isRobot(R).
fluent(shelf_not_on_highway(S)) :- isShelf(S).
fluent(shelf_on_highway(S)) :- isShelf(S).
fluent(not_on_highway(R)) :- isRobot(R).
fluent(all_delivered).
fluent(delivered(O,A)) :- ordered(O,A).
fluent(not_delivered(O,A)) :- ordered(O,A).
fluent(robot_under_shelf(R,S)) :- isRobot(R), isShelf(S).
fluent(robot_on_pickingstation(R)) :- isRobot(R).

holds_for(R,position(R,(X,Y)),T) :- position(R,(X,Y),T), agent(R).
holds_for(R,position(shelf(S),(X,Y)),T) :- position(shelf(S),(X,Y),T), agent(R).
holds_for(R,position(station(P),(X,Y)),T) :- position(station(P),(X,Y)), agent(R), time(T).
holds_for(R,carries(R,S),T) :- carries(R,S,T).
holds_for(R,contains_ordered_products(shelf(S),product(A),order(O)),T) :- shelved(shelf(S),product(A)), ordered(order(O),product(A)), time(T), agent(R).
holds_for(R,robot_under_shelf_with_ordered_products(R,S,P,O),T) :- position(R,C,T), position(S,C,T), isRobot(R), isShelf(S), holds_for(R,contains_ordered_products(S,P,O),T).
holds_for(R,shelf_not_on_highway(S),T) :- highway(C), time(T), not position(S,C,T), isShelf(S), agent(R).
holds_for(R,shelf_on_highway(S),T) :- highway(C), time(T), position(S,C,T), isShelf(S), agent(R).
holds_for(R,not_on_highway(R),T) :- highway(C), time(T), not position(R,C,T), isRobot(R).
holds_for(R,not_delivered(O,A),T) :- ordered(O,A), time(T), not holds_for(R,delivered(O,A),T), agent(R).
holds_for(R,delivered(O,A),T) :- ordered(O,A), target(O,P), position(P,C), shelved(S,A), position(S,C,T), agent(R).
holds_for(R,delivered(O,A),Ta) :- holds_for(R,delivered(O,A),T), time(Ta), Ta > T, agent(R).
holds_for(R,all_delivered,T) :- not holds_for(_,not_delivered(_,_),T), agent(R), time(T).
holds_for(R,all_delivered,Ta) :- holds_for(R,all_delivered,T), time(Ta), Ta > T, agent(R).
holds_for(R,robot_under_shelf(R,S),T) :- position(R,C,T), position(S,C,T), isRobot(R), isShelf(S).
holds_for(R,robot_on_pickingstation(R),T) :- position(R,C,T), position(P,C), isRobot(R).