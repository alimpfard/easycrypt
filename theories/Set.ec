require import int.
require import Fun.

type 'a t.

cnst empty : 'a t.

op add    : ('a, 'a t) -> 'a t.

op singleton (x:'a) : 'a t = add x empty.

op rm     : ('a, 'a t) -> 'a t.
op union  : ('a t, 'a t) -> 'a t.
op inter  : ('a t, 'a t) -> 'a t.

op is_empty : 'a t -> bool.

op mem      : ('a, 'a t) -> bool.
op Pmem (X:'a t, x:'a) : bool = mem x X.

op card     : 'a t -> int.

axiom card_pos : forall (X:'a t), 0 <= card X. 

pred [==] (X1:'a t, X2:'a t) = 
  forall (x:'a), mem x X1 <=> mem x X2.

axiom extentionnality : 
  forall (X1:'a t, X2:'a t),
     X1 = X2 <=> X1 == X2.

(* Specification of is_empty *)
axiom is_empty_mem : forall (X:'a t), 
   is_empty X <=> forall (x:'a), !mem x X.

axiom is_empty_card : forall (X:'a t),
   is_empty X <=> card X = 0.

(* Specification of empty *)
axiom is_empty_empty : is_empty<:'a> empty<:'a>.

(* FIXME lemma *)
axiom empty_mem  : forall (x:'a), !mem x empty.

axiom empty_card : card<:'a>(empty) = 0.

(* Specification of add *)

axiom add_mem : forall (x:'a, y:'a, X:'a t), 
   mem x (add y X) <=> mem x X || x = y.

axiom add_card : forall (x:'a, X:'a t), 
   !mem x X => card (add x X) = card X + 1.

(* Need to put extentionality, to get it as a lemma *)
axiom mem_add : forall (x:'a, X:'a t),
   mem x X => X = add x X.

axiom singleton_card : forall (x:'a),
   card (singleton x) = 1.

(* filter *)
op filter : ('a Pred, 'a t) -> 'a t.

axiom filter_mem : forall (P:'a Pred, X:'a t, x:'a),
   mem x (filter P X) <=> (mem x X && P x).

axiom filter_card : forall (P:'a Pred, X : 'a t), 
   card (filter P X) = card X - card(filter (Pnot P) X). 

axiom filter_Peq_in : forall (x:'a, X:'a t),
   mem x X =>
   filter (Peq x) X = singleton x.

axiom filter_Peq_card_in : forall (x:'a, X:'a t),
   mem x X =>
   card (filter (Peq x) X) = 1.
     

