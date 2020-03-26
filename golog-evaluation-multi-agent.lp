%%%%%%%%%%%%%%%%%
%%%% + FACTS %%%%
%%%%%%%%%%%%%%%%%
shift_pointer(X,-1,0,0,0) :- agent(X), not nil.
node_to_visit(X,0,0) :- agent(X), is_node(0).
leaf_to_visit(X,0,0) :- agent(X), is_leaf(0).
%%%%%%%%%%%%%%%%%
%%%% = FACTS %%%%
%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
%%%% + HELPER %%%%
%%%%%%%%%%%%%%%%%%
is_leaf(I) :- gst(I,A), action(A).
is_leaf(I) :- gst(I,test(_)).
is_node(I) :- not is_leaf(I), gst(I,_).
is_or(I) :- gst(I,or(_,_)).
is_cat(I) :- gst(I,seq(_,_)).
is_star(I) :- gst(I,star(_)).

child_of(C,P) :- gst(P,seq(C,_)).
child_of(C,P) :- gst(P,seq(_,C)).
child_of(C,P) :- gst(P,or(C,_)).
child_of(C,P) :- gst(P,or(_,C)).
child_of(C,P) :- gst(P,star(C)).

% the empty program
nil :- not gst(_,_).

% nodes and leaves that are to be visited
% determine which path to go from OR nodes (coming from above)
1 { chosen_alternative(X,I,R) : child_of(I,P) } 1 :- is_or(P), shift_pointer(X,N,P,T,R), N<P.
node_to_visit(X,I,R) :- chosen_alternative(X,I,R), shift_pointer(X,_,I,_,R), is_node(I).
leaf_to_visit(X,I,R) :- chosen_alternative(X,I,R), shift_pointer(X,_,I,_,R), is_leaf(I).
% propagate NODE_TO_VISIT downwards
node_to_visit(X,A,R) :- shift_pointer(X,I,P,T,R), I<P, gst(P, seq(A,_)), is_node(A).
node_to_visit(X,B,R) :- shift_pointer(X,I,P,T,R), gst(P, seq(_,B)), R = #max{ R0 : shift_pointer(X,I,P,T,R0) }, is_node(B).

node_to_visit(X,I,R) :- node_to_visit(X,P,R), child_of(I,P), is_node(I), not is_star(P), not is_or(P).
leaf_to_visit(X,I,R) :- node_to_visit(X,P,R), child_of(I,P), is_leaf(I), not is_star(P), not is_or(P).

node_to_visit(X,I,R) :- shift_pointer(X,P,I,_,R), is_star(P), child_of(I,P), is_node(I).
leaf_to_visit(X,I,R) :- shift_pointer(X,P,I,_,R), is_star(P), child_of(I,P), is_leaf(I).

% a leaf/node is marked as visited if the pointer is shifted onto and from it respectively
visited(X,I,R) :- leaf_to_visit(X,I,R), shift_pointer(X,_,I,_,R), shift_pointer(X,I,_,_,R).
visited(X,I,R) :- node_to_visit(X,I,R), shift_pointer(X,_,I,T,R), shift_pointer(X,I,_,T,R).

% end of traversal
1 { end_of_traversal(X,I) : is_leaf(I) } 1 :- agent(X), horizon > 0, not nil.
% we declare a star node to be a leaf if the horizon is 0
end_of_traversal(X,P) :- shift_pointer(X,I,P,horizon,R), I<P, is_star(P), R = #max{ R0 : shift_pointer(X,_,I,_,R0) }, horizon = 0.
end_of_traversal(X,0) :- agent(X), is_leaf(0), horizon = 0.

zero_or_more(I) :- is_star(I).
% propagate downwards
zero_or_more(I) :- child_of(I,P), zero_or_more(P).
% propagate upwards
zero_or_more(I) :- gst(I, seq(A,B)), zero_or_more(A), zero_or_more(B).
zero_or_more(I) :- is_or(I), child_of(A,I), chosen_alternative(X,A,R), zero_or_more(A), node_to_visit(X,I,R).
%%%%%%%%%%%%%%%%%%
%%%% = HELPER %%%%
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%% + FORMULAS %%%%
%%%%%%%%%%%%%%%%%%%%
% literals
holds_for(X,fst_node_formula(F,I),T) :- shift_pointer(X,_,P,T,_), gst(P, test(F)), fst(F,I,A), fluent(A), holds_for(X,A,T).
% and
holds_for(X,fst_node_formula(F,I),T) :- fst(F,I, and(A,B)), holds_for(X,fst_node_formula(F,A),T), holds_for(X,fst_node_formula(F,B),T).
% or
holds_for(X,fst_node_formula(F,I),T) :- fst(F,I, or(A,_)), holds_for(X,fst_node_formula(F,A),T).
holds_for(X,fst_node_formula(F,I),T) :- fst(F,I, or(_,B)), holds_for(X,fst_node_formula(F,B),T).
% not
holds_for(X,fst_node_formula(F,I),T) :- fst(F,I, neg(N)), time(T), agent(X), not holds_for(X,fst_node_formula(F,N),T).
%%%%%%%%%%%%%%%%%%%%
%%%% = FORMULAS %%%%
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%
%%%% + TRAVERSAL %%%%
%%%%%%%%%%%%%%%%%%%%%
%%% ACTIONS %%%
% only way is up
shift_pointer(X,I,P,T,R) :- T<=horizon, shift_pointer(X,P,I,T-1,R), gst(I,A), action(A), performs(X,A,T-1), child_of(I,P), not shift_pointer(X,I,-1,T,R).

%%% TEST %%%
% only way is up
shift_pointer(X,I,P,T,R) :- T<=horizon, shift_pointer(X,P,I,T,R), gst(I,test(C)), holds_for(X,fst_node_formula(C,0),T), child_of(I,P), not shift_pointer(X,I,-1,T,R).

%%% SEQ %%%
% up
shift_pointer(X,P,I,T,R) :- shift_pointer(X,B,P,T,R), gst(P, seq(A,B)), child_of(P,I).

% down
shift_pointer(X,P,A,T,R) :- shift_pointer(X,I,P,T,R), gst(P, seq(A,_)), I<P.
shift_pointer(X,P,B,T,R) :- shift_pointer(X,A,P,T,R), gst(P, seq(A,B)).

%%% OR %%%
% down
shift_pointer(X,P,C,T,R) :- child_of(C,P), chosen_alternative(X,C,R), shift_pointer(X,I,P,T,R), I<P, is_or(P).

% up
shift_pointer(X,P,I,T,R) :- shift_pointer(X,A,P,T,R), gst(P,or(A,_)), child_of(P,I).
shift_pointer(X,P,I,T,R) :- shift_pointer(X,B,P,T,R), gst(P,or(_,B)), child_of(P,I).

%%% STAR %%%
% down
% from above --> go down
{ shift_pointer(X,P,C,T,R+1) } 1 :- shift_pointer(X,I,P,T,R), gst(P,star(C)), I<P, horizon>0.
% from below --> go down again
{ shift_pointer(X,P,C,T,R+1) } 1 :- shift_pointer(X,C,P,T,R), gst(P,star(C)), T>T0, shift_pointer(X,P,C,T0,R). 

% up
% coming from above --> go up without visiting the subtree
{ shift_pointer(X,P,I,T,R) } 1 :- shift_pointer(X,I,P,T,R), gst(P,star(C)), I<P.
% coming from below --> go up after a visit of the subtree
{ shift_pointer(X,P,I,T,R0) } 1 :- shift_pointer(X,I,P,T0,R0), I<P, child_of(P,I), shift_pointer(X,C,P,T,R), gst(P,star(C)), R = #max{ N : shift_pointer(X,C,P,_,N) }.
%%%%%%%%%%%%%%%%%%%%%
%%%% = TRAVERSAL %%%%
%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% + END OF TRAVERSAL %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shift_pointer(X,I,-1,horizon,R) :- end_of_traversal(X,I), shift_pointer(X,_,I,horizon-1,R), gst(I,A), action(A), performs(X,A,horizon-1), R = #max{ R0 : shift_pointer(X,_,I,_,R0) }.

shift_pointer(X,I,-1,horizon,R) :- end_of_traversal(X,I), shift_pointer(X,_,I,horizon,R), gst(I,test(C)), holds_for(X,fst_node_formula(C,0),horizon), R = #max{ R0 : shift_pointer(X,_,I,_,R0) }.

shift_pointer(X,P,-1,horizon,R) :- shift_pointer(X,I,P,horizon,R), I<P, is_star(P), R = #max{ R0 : shift_pointer(X,_,I,_,R0) }.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% = END OF TRAVERSAL %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
%%%% + ERRORS %%%%
%%%%%%%%%%%%%%%%%%
% Traversal not done
error(1) :- end_of_traversal(X,I), not shift_pointer(X,I,-1,horizon,_), not nil.
% Not all leaves visited
error(2) :- leaf_to_visit(X,I,R), not visited(X,I,R), not nil.
% Not all nodes visited
error(3) :- node_to_visit(X,I,R), not zero_or_more(I), not visited(X,I,R), not nil.
% Leaf visited that is to be omitted
error(4) :- shift_pointer(X,_,I,T,R), is_leaf(I), not leaf_to_visit(X,I,R), not nil.
% no going up and down at the same time (star)
error(5) :- gst(P,star(A)), shift_pointer(X,P,A,T,Ra), shift_pointer(X,P,B,T,Rb), B<P, Ra>Rb, not nil.
% Up and out at node at end of traversal
error(6) :- shift_pointer(X,I,P,T,R), child_of(I,P), shift_pointer(X,I,-1,T,R), not nil.

:- error(_).
%%%%%%%%%%%%%%%%%%
%%%% = ERRORS %%%%
%%%%%%%%%%%%%%%%%%