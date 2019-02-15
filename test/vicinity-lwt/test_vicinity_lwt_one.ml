open Vicinity

module V = Vicinity
module VL = Vicinity_lwt

let view_len = 8
let xchg_len = 4
let period = 1.0

let print_view nid msg view =
  Lwt.ignore_result (Lwt_io.printf "%s # view: %s (%d)\n"
                       nid msg (V.View.cardinal view));
  V.View.iter (fun id n ->
      Lwt.ignore_result (Lwt_io.printf " - %s: %s (%d)\n%!" id n.data n.age))
    view

let print_xchg nid msg xchg =
  Lwt.ignore_result (Lwt_io.printf "%s # xchg: %s (%d)\n"
                       nid msg (V.View.cardinal xchg));
  V.View.iter (fun id n ->
      Lwt.ignore_result (Lwt_io.printf " - %s: %s\n%!" id n.data))
    xchg

let get_view_rnd () =
  add "RA" "113"
    (add "RB" "133"
       (add "RC" "153"
          (add "RD" "173"
             (add "RE" "233"
                (add "RF" "253"
                   (add "RG" "273"
                      View.empty))))))

let distance _nid1 data1 _nid2 data2 =
  abs @@ (int_of_string data1) - (int_of_string data2)

let read_ch ch c nid rnid rdata =
  let%lwt recvd = Lwt_io.read_value ch in
  print_xchg nid "read_ch" recvd;
  let%lwt view = VL.recv c rnid rdata recvd in
  print_view nid "read_ch" view;
  Lwt.return_unit

let () =
  let (read_ch1, write_ch2) = Lwt_io.pipe () in
  let (read_ch2, write_ch1) = Lwt_io.pipe () in
  let nid1 = "ABC123" in
  let data1 = "151" in
  let view1 = V.add "v1k1" "110"
               (V.add "v1k2" "120"
                  (V.add "v1k3" "130"
                     (V.add "v1k4" "140"
                        (V.add "v1k5" "150"
                           (V.add "v1k6" "160"
                              (V.add "v1k7" "170"
                                 V.View.empty))))))
  in
  let c1 =
    VL.init nid1 data1 view1 view_len xchg_len period get_view_rnd distance
      (fun _c nid data entries ->
        let%lwt _ = Lwt_io.printf "%s # send_cb: %s (%s)\n" nid1 nid data in
        print_xchg nid1 "send_cb: entries to send" entries;
        let%lwt _ = Lwt_io.write_value write_ch1 entries in
        Lwt_io.read_value read_ch1)
      (fun _c my_nid _my_data my_view recvd ->
        print_view my_nid "recv_cb" my_view;
        print_xchg my_nid "recv_cb" recvd;
        Lwt.return recvd)
      (fun c my_nid _my_data my_view ->
        print_view my_nid "updated" my_view;
        print_view my_nid "current" (VL.view c);
        Lwt.return_unit)
  in

  let nid2 = "DEF456" in
  let data2 = "221" in
  let view2 = V.add "v2k1" "210"
                (V.add "v2k2" "220"
                   (V.add "v2k3" "230"
                      (V.add "v2k4" "240"
                         (V.add "v2k5" "250"
                            (V.add "v2k6" "260"
                               (V.add "v2k6" "270"
                                  V.View.empty))))))
  in
  let c2 =
    VL.init nid2 data2 view2 view_len xchg_len period get_view_rnd distance
      (fun _c nid data entries ->
        let%lwt _ = Lwt_io.printf "%s # send_cb: %s (%s)\n" nid2 nid data in
        print_xchg nid2 "send_cb: entries to send" entries;
        let%lwt _ = Lwt_io.write_value write_ch2 entries in
        Lwt_io.read_value read_ch2
      )
      (fun _c _my_nid _my_data _my_view recvd ->
        Lwt.return recvd)
      (fun _c _my_nid _my_data _my_view ->
        Lwt.return_unit)
  in
  let timeout = Lwt_unix.sleep 5.5 in
  Random.self_init ();
  Lwt_main.run @@
    Lwt.pick [ VL.run c1;
               read_ch read_ch2 c2 nid2 nid1 data1;
               timeout ]
