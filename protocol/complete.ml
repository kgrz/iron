module Stable = struct

  open Import_stable

  module Which_user_info = struct
    module V1 = struct
      type t =
        | Alias
        | Existing_user
        | Typo
      [@@deriving bin_io, sexp]
    end

    module Model = V1
  end

  module Type = struct
    module V6 = struct
      type t =
        | Absolute_feature_path
        | Archived_feature_path
        | Feature_path
        | Feature_path_with_catch_up
        | Remote_repo_path
        | Root_feature_path
        | User_info of Which_user_info.V1.t
      [@@deriving bin_io, sexp]
    end

    module V5 = struct
      type t =
        | Absolute_feature_path
        | Archived_feature_path
        | Feature_path
        | Remote_repo_path
        | Root_feature_path
        | User_info of Which_user_info.V1.t
      [@@deriving bin_io]

      let to_v6 = function
        | Absolute_feature_path -> V6.Absolute_feature_path
        | Archived_feature_path -> V6.Archived_feature_path
        | Feature_path          -> V6.Feature_path
        | Remote_repo_path      -> V6.Remote_repo_path
        | Root_feature_path     -> V6.Root_feature_path
        | User_info which_user  -> V6.User_info which_user
      ;;
    end

    module V4 = struct
      type t =
        | Absolute_feature_path
        | Archived_feature_path
        | Feature_path
        | Remote_repo_path
        | User_info of Which_user_info.V1.t
      [@@deriving bin_io]

      let to_v5 = function
        | Absolute_feature_path -> V5.Absolute_feature_path
        | Archived_feature_path -> V5.Archived_feature_path
        | Feature_path          -> V5.Feature_path
        | Remote_repo_path      -> V5.Remote_repo_path
        | User_info which_user  -> V5.User_info which_user
      ;;
    end

    module Model = V6
  end

  module Action = struct
    module V6 = struct
      type t =
        { types  : Type.V6.t list
        ; prefix : string
        }
      [@@deriving bin_io, fields, sexp]

      let to_model (t : t) = t
    end

    module V5 = struct
      type t =
        { types  : Type.V5.t list
        ; prefix : string
        }
      [@@deriving bin_io]

      let to_model { types; prefix } =
        V6.to_model
          { types  = List.map types ~f:Type.V5.to_v6
          ; prefix
          }
      ;;
    end

    module V4 = struct
      type t =
        { type_  : Type.V4.t
        ; prefix : string
        }
      [@@deriving bin_io]

      let to_model { type_; prefix } =
        V5.to_model
          { types = [ Type.V4.to_v5 type_ ]
          ; prefix
          }
      ;;
    end

    module Model = V6
  end

  module Reaction = struct
    module V1 = struct
      type t = string list [@@deriving bin_io, sexp]

      let of_model t = t
    end

    module Model = V1
  end

end

include Iron_versioned_rpc.Make
    (struct let name = "complete" end)
    (struct let version = 6 end)
    (Stable.Action.V6)
    (Stable.Reaction.V1)

include Register_old_rpc
    (struct let version = 5 end)
    (Stable.Action.V5)
    (Stable.Reaction.V1)

include Register_old_rpc
    (struct let version = 4 end)
    (Stable.Action.V4)
    (Stable.Reaction.V1)

module Action          = Stable.Action.          Model
module Reaction        = Stable.Reaction.        Model
module Type            = Stable.Type.            Model
module Which_user_info = Stable.Which_user_info. Model