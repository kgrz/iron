Setup a feature with seconding recommended.

  $ start_test
  $ setup_repo_and_root file
  $ echo change >file; hg com -m change
  $ feature_to_server root -fake-valid
  $ fe change -add-whole-feature-reviewers user1
  $ fe enable
  $ fe internal mark-fully-reviewed root
  $ fe internal mark-fully-reviewed root -for user1 -reason reason
  $ fe todo -for user1
  CRs and review line counts:
  |--------------------------------|
  | feature | catch-up | next step |
  |---------+----------+-----------|
  | root    |        2 | second    |
  |--------------------------------|

Change the feature and start hydra working on it:

  $ echo change2 >file; hg com -m change2
  $ tip=$(hg log -r . --template='{node|short}')
  $ fe internal rpc-to-server call synchronize-state <<EOF
  > ((remote_repo_path $PWD)
  >  (bookmarks (((bookmark root)
  >               (first_12_of_rev ${tip})
  >               (rev_author_or_error (Ok committer))
  >               (status Pending_or_working_on_it)))))
  > EOF
  ((bookmarks_to_rerun ()))

Now seconding is not recommend.

  $ fe todo -for user1
  CRs and review line counts:
  |--------------------|
  | feature | catch-up |
  |---------+----------|
  | root    |        2 |
  |--------------------|