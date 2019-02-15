(** VICINITY *)

(** {1 Vicinity_lwt} *)

(** High-level library implementing the VICINITY protocol using Lwt *)

open Vicinity

type 'data t

val init :
  View.key -> 'data -> 'data node View.t -> int -> int -> float
  -> ('data t -> View.key -> 'data -> 'data View.t -> 'data View.t Lwt.t)
  -> ('data t -> View.key -> 'data -> 'data node View.t -> 'data View.t -> 'data View.t Lwt.t)
  -> ('data t -> View.key -> 'data -> 'data node View.t -> unit Lwt.t)
  -> 'data t
(** [init my_nid my_data view view_size shuffle_size period send_cb recv_cb view_cb]
    initialize configuration with:

    - [my_nid] - peer ID of this node,
    - [my_data] - data associated with [my_nid] in sent entries,
    - [view] - map of neighbour entries with peer ID as key,
    - [view_size] - max size of view,
    - [shuffle_size] - number of entries to exchange at each period,
    - [period] - gossip period, in seconds,
    - [transmit] - function to transmit view entries to a node
    - [send_cb peer_id data entries] - send [entries] to peer [(peer_id, data)]
    - [recv_cb my_nid my_node view recvd] - called after receiving entries
      during an exchange; allows rewriting [recvd] entries with the returned value,
      thus allows using a stream sampler to provide uniformly random nodes
      instead of the possibly biased exchanged nodes
    - [view_cb my_nid my_node view] - called after the view has been updated
 *)

val view :
  'data t
  -> 'data node View.t
(** [view t]
    retrieve current view *)

val run :
  'data t
  -> unit Lwt.t
(** [run t send_cb recv_cb view_cb]
    run initiator:
    pick a random node from [view] to gossip with every [period] seconds
 **)

val recv :
  'data t -> View.key -> 'data -> 'data View.t
  -> 'data node View.t Lwt.t
(** [recv t peer_id data recvd send_cb recv_cb]
    receive entries from a peer and send response;
    run [recv_cb] with received entries, and
    return updated view *)
