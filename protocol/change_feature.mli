open! Core.Std
open! Import

module Update : sig
  type t =
    [ `Add_owners                     of User_name.t list
    | `Add_reviewing                  of User_name.Set.t
    | `Add_send_email_to              of Email_address.Set.t
    | `Add_send_email_upon            of Send_email_upon.Set.t
    | `Add_whole_feature_followers    of User_name.Set.t
    | `Add_whole_feature_reviewers    of User_name.Set.t
    | `Remove_owners                  of User_name.Set.t
    | `Remove_properties              of string list
    | `Remove_reviewing               of User_name.Set.t
    | `Remove_send_email_to           of Email_address.Set.t
    | `Remove_send_email_upon         of Send_email_upon.Set.t
    | `Remove_whole_feature_followers of User_name.Set.t
    | `Remove_whole_feature_reviewers of User_name.Set.t
    | `Set_base                       of Rev.t
    | `Set_crs_are_enabled            of bool
    | `Set_crs_shown_in_todo_only_for_users_reviewing of bool
    | `Set_description                of string
    | `Set_is_permanent               of bool
    | `Set_owners                     of User_name.t list
    | `Set_properties                 of Properties.t
    | `Set_release_process            of Release_process.t
    | `Set_review_is_enabled          of bool
    | `Set_reviewing                  of Reviewing.t
    | `Set_send_email_to              of Email_address.Set.t
    | `Set_send_email_upon            of Send_email_upon.Set.t
    | `Set_who_can_release_into_me    of Who_can_release_into_me.t
    | `Set_whole_feature_followers    of User_name.Set.t
    | `Set_whole_feature_reviewers    of User_name.Set.t
    | `Set_xcrs_shown_in_todo_only_for_users_reviewing of bool
    ]
  [@@deriving sexp_of]
end

module Action : sig
  type t =
    { feature_path : Feature_path.t
    ; updates      : Update.t list
    }
  [@@deriving fields, sexp_of]
end

module Reaction : sig
  type t = (Update.t * unit Or_error.t) list
  [@@deriving sexp_of]
end

include Iron_versioned_rpc.S
  with type action   = Action.t
  with type reaction = Reaction.t