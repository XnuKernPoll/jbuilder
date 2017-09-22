(** Simplified Async/Lwt like monad *)

open Import

type 'a t

val return : 'a -> 'a t
val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
val (>>|) : 'a t -> ('a -> 'b) -> 'b t

val both : 'a t -> 'b t -> ('a * 'b) t

val all : 'a t list -> 'a list t
val all_unit : unit t list -> unit t

val with_exn_handler : (unit -> 'a) -> handler:(exn -> Printexc.raw_backtrace -> unit) -> 'a

module Mutex : sig
  type 'a future = 'a t
  type t
  val create : unit -> t
  val with_lock : t -> (unit -> 'a future) -> 'a future
end with type 'a future := 'a t

type accepted_codes =
  | These of int list
  | All

(** How to handle sub-process failures *)
type ('a, 'b) failure_mode =
  | Strict : ('a, 'a) failure_mode
  (** Fail if the process exits with anything else than [0] *)
  | Accept : accepted_codes -> ('a, ('a, int) result) failure_mode
  (** Accept the following non-zero exit codes, and return [Error code] if the process
      exists with one of these codes. *)

(** Where to redirect standard output *)
type std_output_to =
  | Terminal
  | File        of string
  | Opened_file of opened_file

and opened_file =
  { filename : string
  ; desc     : opened_file_desc
  ; tail     : bool
  (** If [true], the descriptor is closed after starting the command *)
  }

and opened_file_desc =
  | Fd      of Unix.file_descr
  | Channel of out_channel

(** Why a Future.t was run *)
type purpose =
  | Internal_job
  | Build_job of Path.t list

(** [run ?dir ?stdout_to prog args] spawns a sub-process and wait for its termination *)
val run
  :  ?dir:string
  -> ?stdout_to:std_output_to
  -> ?stderr_to:std_output_to
  -> ?env:string array
  -> ?purpose:purpose
  -> (unit, 'a) failure_mode
  -> string
  -> string list
  -> 'a t

(** Run a command and capture its output *)
val run_capture
  :  ?dir:string
  -> ?env:string array
  -> ?purpose:purpose
  -> (string, 'a) failure_mode
  -> string
  -> string list
  -> 'a t
val run_capture_line
  :  ?dir:string
  -> ?env:string array
  -> ?purpose:purpose
  -> (string, 'a) failure_mode
  -> string
  -> string list
  -> 'a t
val run_capture_lines
  :  ?dir:string
  -> ?env:string array
  -> ?purpose:purpose
  -> (string list, 'a) failure_mode
  -> string
  -> string list
  -> 'a t

module Scheduler : sig
  val go : ?log:Log.t -> 'a t -> 'a

  (** Executes [f] before exiting, after all pending commands have finished *)
  val at_exit_after_waiting_for_commands : (unit -> unit) -> unit
end
