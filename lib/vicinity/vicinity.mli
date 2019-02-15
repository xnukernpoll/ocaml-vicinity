(** VICINITY *)

type 'data node =
  {
    age: int;
    data: 'data;
  }

module View : module type of Map.Make(String)

val add :
  View.key
  -> 'data
  -> 'data node View.t
  -> 'data node View.t
(** [add_node id data view]
    adds an entry to [view]
    returns new view with the added entry *)

val remove :
  View.key
  -> 'data node View.t
  -> 'data node View.t
(** [remove_node id view]
    removes an entry from [view]
    returns new view without the removed entry *)

val make_exchange :
  'data node View.t
  -> 'data node View.t
  -> View.key
  -> 'data
  -> int
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> (View.key option * 'data option * 'data node View.t * 'data node View.t)
(** [view view_rnd my_nid my_data xchg_len distance] *)

val make_response :
  'data node View.t
  -> 'data node View.t
  -> View.key
  -> 'data
  -> View.key
  -> 'data
  -> 'data node View.t
  -> int
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> 'data node View.t
(** [view view_rnd my_nid my_data rnid rdata recvd xchg_len distance] *)

val merge_recvd :
  'data node View.t
  -> int
  -> View.key
  -> 'data
  -> 'data node View.t
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> 'data node View.t
(** [merge_recvd view view_len my_nid my_data recvd distance] *)
