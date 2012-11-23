(* -------------------------------------------------------------------- *)
let tryexn (ignoreexn : exn -> bool) (f : unit -> 'a) =
  try  Some (f ())
  with e -> if ignoreexn e then None else raise e

let try_nf (f : unit -> 'a) =
  tryexn (function Not_found -> true | _ -> false) f

(* -------------------------------------------------------------------- *)
let obind (x : 'a option) (f : 'a -> 'b option) =
  match x with None -> None | Some x -> f x

(* -------------------------------------------------------------------- *)
module List = struct
  include List

  let ohead (xs : 'a list) =
    match xs with [] -> None | x :: _ -> Some x

  let findopt (f : 'a -> bool) (xs : 'a list) =
    try  Some (List.find f xs)
    with Not_found -> None

  let rec pick (f : 'a -> 'b option) (xs : 'a list) =
    match xs with
      | []      -> None
      | x :: xs -> begin
        match f x with
          | None        -> pick f xs
          | Some _ as r -> r
      end

  let index (v : 'a) (xs : 'a list) : int option =
    let rec index (i : int) = function
      | [] -> None
      | x :: xs -> if x = v then Some i else index (i+1) xs
    in
      index 0 xs

  let all2 (f : 'a -> 'b -> bool) xs ys =
    let rec all2 = function
      | ([]     , []     ) -> true
      | (x :: xs, y :: ys) -> (f x y) && (all2 (xs, ys))
      | (_      , _      ) -> false
    in
      all2 (xs, ys)

  let rec uniq (xs : 'a list) =
    match xs with
      | []      -> true
      | x :: xs -> (not (List.mem x xs)) && (uniq xs)
end

(* -------------------------------------------------------------------- *)
module Parray : sig 
  type 'a t

  val empty : 'a t
  val get : 'a t -> int -> 'a
  val length : 'a t -> int 
  val of_list : 'a list -> 'a t
  val to_list : 'a t -> 'a list
  val of_array : 'a array -> 'a t
  val init : int -> (int -> 'a) -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val fmap : ('a -> 'b) -> 'a list -> 'b t
  val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b t -> 'a
  val fold_right : ('b -> 'a -> 'a) -> 'b t -> 'a -> 'a
  val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b t -> 'c t -> 'a
  val iter : ('a -> unit) -> 'a t -> unit 
  val split : ('a * 'b) t -> ('a t * 'b t)
  val exists : ('a -> bool) -> 'a t -> bool
  val for_all : ('a -> bool) -> 'a t -> bool
end = struct
  type 'a t = 'a array

  include Array

  let empty = [||]

  let of_array = Array.copy

  let fmap (f : 'a -> 'b) (xs : 'a list) =
    Array.map f (of_list xs)

  let split a =
    (Array.init (Array.length a) (fun i -> fst a.(i)),
     Array.init (Array.length a) (fun i -> snd a.(i)))

  let fold_left2 f a t1 t2 =
    if Array.length t1 <> Array.length t2 then 
      raise (Invalid_argument "Parray.fold_left2");
    let rec aux i a t1 t2 = 
      if i < Array.length t1 then f a t1.(i) t2.(i) 
      else a in
    aux 0 a t1 t2

  let exists f t =
    let rec aux i t = 
      if i < Array.length t then f t.(i) || aux (i+1) t 
      else false in
    aux 0 t 

  let for_all f t = 
    let rec aux i t =
      if i < Array.length t then f t.(i) && aux (i+1) t 
      else true in
    aux 0 t 
end
