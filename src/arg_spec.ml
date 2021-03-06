open Import

module Pset = Path.Set

type 'a t =
  | A        of string
  | As       of string list
  | S        of 'a t list
  | Dep      of Path.t
  | Deps     of Path.t list
  | Target   of Path.t
  | Path     of Path.t
  | Paths    of Path.t list
  | Dyn      of ('a -> nothing t)

let rec add_deps ts set =
  List.fold_left ts ~init:set ~f:(fun set t ->
    match t with
    | Dep  fn  -> Pset.add fn set
    | Deps fns -> Pset.union set (Pset.of_list fns)
    | S ts -> add_deps ts set
    | _ -> set)

let rec add_targets ts acc =
  List.fold_left ts ~init:acc ~f:(fun acc t ->
    match t with
    | Target fn  -> fn :: acc
    | S ts -> add_targets ts acc
    | _ -> acc)

let expand ~dir ts x =
  let dyn_deps = ref Path.Set.empty in
  let add_dep path = dyn_deps := Path.Set.add path !dyn_deps in
  let rec loop_dyn : nothing t -> string list = function
    | A s  -> [s]
    | As l -> l
    | Dep fn ->
      add_dep fn;
      [Path.reach fn ~from:dir]
    | Path fn -> [Path.reach fn ~from:dir]
    | Deps fns ->
      List.map fns ~f:(fun fn ->
        add_dep fn;
        Path.reach ~from:dir fn)
    | Paths fns ->
      List.map fns ~f:(Path.reach ~from:dir)
    | S ts -> List.concat_map ts ~f:loop_dyn
    | Target _ -> die "Target not allowed under Dyn"
    | Dyn _ -> assert false
  in
  let rec loop = function
    | A s  -> [s]
    | As l -> l
    | (Dep fn | Path fn) -> [Path.reach fn ~from:dir]
    | (Deps fns | Paths fns) -> List.map fns ~f:(Path.reach ~from:dir)
    | S ts -> List.concat_map ts ~f:loop
    | Target fn -> [Path.reach fn ~from:dir]
    | Dyn f -> loop_dyn (f x)
  in
  let l = List.concat_map ts ~f:loop in
  (l, !dyn_deps)

let quote_args =
  let rec loop quote = function
    | [] -> []
    | arg :: args -> quote :: arg :: loop quote args
  in
  fun quote args -> As (loop quote args)
