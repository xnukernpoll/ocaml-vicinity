(** VICINITY: P2P gossip-based topology management protocol *)

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
  -> int
  -> View.key
  -> 'data
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> (View.key option * 'data option * 'data node View.t * 'data node View.t)
(** [view view_rnd xchg_len my_nid my_data distance]
    selects a node to exchange with and a list of nodes to send
    from the union of [view] and [view_rnd]

    - [view] is the current view of this node
    - [view_rnd] is the current view of the random peer sampling service
    - [xchg_len] is the number of nodes in the gossip exchange
    - [my_nid] is the ID of this node,
    - [my_data] is the data associated with this node,
    - [distance] is a function that returns the distance of two nodes

    return [(Some nid, Some ndata, xchg, view)] where
    [nid] is the node_id to exchange with
    [ndata] associated with [nid] in [view]
    [xchg] is the [xchg_len] nodes from the two views to send to [nid]
    [view] is the updated view with the age of all nodes increased
           and the node associated with [nid] removed *)

val make_response :
  'data node View.t
  -> 'data node View.t
  -> int
  -> View.key
  -> 'data
  -> 'data node View.t
  -> View.key
  -> 'data
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> 'data node View.t
(** [view view_rnd xchg_len rnid rndata recvd my_nid my_data distance]
    responds to a gossip exchange initiated by [(rnid, rndata)]

    selects a list of nodes for the response
    from the union of [view] and [view_rnd]

    - [view] is the current view of this node
    - [view_rnd] is the current view of the random peer sampling service
    - [xchg_len] is the number of nodes in the gossip exchange
    - [my_nid] is the ID of this node
    - [my_data] is the data associated with this node
    - [distance] is a function that returns the distance of two nodes
 *)

val merge_recvd :
  'data node View.t
  -> int
  -> 'data node View.t
  -> View.key
  -> 'data
  -> (View.key -> 'data -> View.key -> 'data -> int)
  -> 'data node View.t
(** [merge_recvd view view_len recvd my_nid my_data distance]
    merges received nodes during an exchange to the current [view]

    - [view] is the current view of this node
    - [view_len] is the maximum number of nodes in [view]
    - [recvd] are the received nodes to be merged
    - [my_nid] is the ID of this node
    - [my_data] is the data associated with this node
    - [distance] is a function that returns the distance of two nodes
*)
