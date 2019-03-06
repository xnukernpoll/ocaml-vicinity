open Vicinity
open OUnit2
open Printf

let view_len = 7
let xchg_len = 5
let my_nid = "ME"
let my_data = 23

let print_view msg view =
  printf "\n%s\n" msg;
  View.iter (fun id n -> Printf.printf "%s: %d (%d)\n" id n.data n.age) view;;

let print_xchg msg xchg =
  Printf.printf "\n%s\n" msg;
  View.iter (fun id n -> Printf.printf "%s: %d\n" id n.data) xchg;;

let opt2str v =
  match v with
  | Some v -> v
  | None -> "-"

let opt2int v =
  match v with
  | Some v -> v
  | None -> -1

let my_view =
  add "a" 7
    (add "b" 11
       (add "c" 13
          (add "d" 17
             (add "e" 19
                (add "f" 29
                   (add "g" 37
                      View.empty))))))

let my_recvd =
  (add "V" 10
     (add "W" 20
        (add "X" 30
           (add "Y" 40
              (add "Z" 50
                 View.empty)))))

let my_view_rnd =
  add "A" 10
    (add "B" 20
       (add "C" 30
          (add "D" 40
             (add "E" 50
                (add "F" 60
                   (add "G" 70
                      View.empty))))))

let distance _nid1 data1 _nid2 data2 =
  abs @@ data1 - data2

let test_add _ctx =
  let view = my_view in
  print_view "add" view;
  assert_equal (View.cardinal view) 7

let test_xchg _ctx =
  let view = my_view in
  let (nid, data, sent, _view) =
    make_exchange view my_view_rnd xchg_len my_nid my_data distance in
  printf "\nSEND TO %s (%d)\n" (opt2str nid) (opt2int data);
  print_xchg "SEND:" sent;
  print_newline ();
  assert_equal (View.cardinal sent) xchg_len

let test_recv _ctx =
  let view = my_view in
  let (nid, data, sent, view) =
    make_exchange view my_view_rnd xchg_len my_nid my_data distance in
  let recvd = my_recvd in
  printf "\n\nSEND TO %s (%d)\n" (opt2str nid) (opt2int data);
  print_view "VIEW BEFORE:" view;
  print_xchg "SENT:" sent;
  print_xchg "RECVD:" recvd;
  assert_equal (View.cardinal view) (view_len - 1);
  assert_equal (View.cardinal sent) xchg_len;
  let view2 = merge_recvd view view_len recvd xchg_len my_nid my_data distance in
  print_view "VIEW AFTER:" view2;
  assert_equal (View.cardinal view2) view_len;
  assert_equal (View.mem "ME" view2) false;
  assert_equal (View.mem "W" view2) true;
  assert_equal (View.mem "X" view2) true;
  let (rnid, rdata) = ("x", 69) in
  let resp =
    make_response view2 my_view_rnd xchg_len rnid rdata recvd
      my_nid my_data distance in
  printf "\nRESPOND TO %s (%d)\n" rnid rdata;
  print_xchg "RESP:" resp;
  assert_equal (View.cardinal resp) xchg_len;
  let (rnid, _rdata) = View.choose recvd in
  assert_equal (View.mem "F" resp) true;
  assert_equal (View.mem "G" resp) true;
  assert_equal (View.mem rnid resp) false

let suite =
  "suite">:::
    [
      "add">:: test_add;
      "exchange">:: test_xchg;
      "receive">:: test_recv;
    ]

let () =
  Random.self_init ();
  run_test_tt_main suite
