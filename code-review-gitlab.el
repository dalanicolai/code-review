Optionally using VARIABLES.  Provide HOST and CALLBACK fn."
  (string-remove-suffix
   "\n"
   (-reduce-from
    (lambda (acc c)
      (let-alist c
        (let ((header1 (format "diff --git %s %s\n" .new_path .old_path))
              (header2 (cond
                        (.deleted_file
                         (format "deleted file mode %s\n" .a_mode))
                        (.new_file
                         (format "new file mode %s\nindex 0000000000000000000000000000000000000000..1111\n" .b_mode))
                        (.renamed_file)
                        (t
                         (format "index 1111..2222 %s\n" .a_mode))))
              (header3 (cond
                        (.deleted_file
                         (format "--- %s\n+++ /dev/null\n" .old_path))
                        (.new_file
                         (format "--- /dev/null\n+++ %s\n" .new_path))
                        (.renamed_file)
                        (t
                         (format "--- %s\n+++ %s\n"
                                 .old_path
                                 .new_path)))))
          (format "%s%s%s%s%s"
                  acc
                  header1
                  header2
                  header3
                  .diff))))
    ""
    pr-changes)))
                  (bodyHTML .,"")
                  (comments (nodes ((bodyHTML . ,.bodyHTML)
          bodyHTML:bodyHtml
      bodyHTML:descriptionHtml
  (let* ((if-zero-null (lambda (n)
                         (let ((nn (string-to-number n)))
                           (when (> nn 0)
                             nn))))
         (regex
          (rx "@@ -"
              (group-n 1 (one-or-more digit))
              ","
              (group-n 2 (one-or-more digit))
              " +"
              (group-n 3 (one-or-more digit))
              ","
              (group-n 4 (one-or-more digit))))
         (res
                 (if (and (string-match regex str))
                     ;;; NOTE: it's possible that using "old_path" blindly here
                     ;;; might cause issues when this value is null
                     (a-assoc acc (or (a-get it 'old_path)
                                      (a-get it 'new_path))
                              (a-alist 'old (a-alist 'beg (funcall if-zero-null (match-string 1 str))
                                                     'end (funcall if-zero-null (match-string 2 str))
                                                     'path (a-get it 'old_path))
                                       'new (a-alist 'beg (funcall if-zero-null (match-string 3 str))
                                                     'end (funcall if-zero-null (match-string 4 str))
                                                     'path (a-get it 'new_path))))
                   acc))))
           gitlab-diff)))
    (setq code-review-gitlab-line-diff-mapping res)))
  "Default warning message."
(cl-defmethod code-review-core-get-labels ((_gitlab code-review-gitlab-repo))
(cl-defmethod code-review-core-set-labels ((_gitlab code-review-gitlab-repo) _callback)
(cl-defmethod code-review-core-get-assignees ((_gitlab code-review-gitlab-repo))
(cl-defmethod code-review-core-set-assignee ((_gitlab code-review-gitlab-repo) _callback)
(cl-defmethod code-review-core-get-milestones ((_gitlab code-review-gitlab-repo))
(cl-defmethod code-review-core-set-milestone ((_gitlab code-review-gitlab-repo) _callback)
(cl-defmethod code-review-core-set-title ((_gitlab code-review-gitlab-repo) _callback)
(cl-defmethod code-review-core-set-description ((_gitlab code-review-gitlab-repo) _callback)
(cl-defmethod code-review-core-merge ((_gitlab code-review-gitlab-repo) _strategy)
(cl-defmethod code-review-core-set-reaction ((_gitlab code-review-gitlab-repo))
(cl-defmethod code-review-binary-file-url ((gitlab code-review-gitlab-repo) filename &optional blob?)
  "Make the GITLAB url for the FILENAME.
Return the blob URL if BLOB? is provided."
  (let ((sha (a-get-in (oref gitlab raw-infos) (list 'diffRefs 'headSha))))
    (if blob?
        (format "https://gitlab.com/%s/%s/-/blob/%s/%s"
                (oref gitlab owner)
                (oref gitlab repo)
                sha
                filename)
      (format "https://%s/v4/projects/%s/repository/files/%s/raw?ref=%s"
              code-review-gitlab-host
              (code-review-gitlab--project-id gitlab)
              filename
              sha))))

(cl-defmethod code-review-binary-file ((gitlab code-review-gitlab-repo) filename)
  "Get FILENAME from GITLAB."
  (let* ((pwd (auth-source-pick-first-password :host code-review-gitlab-host))
         (headers (format "--header 'PRIVATE-TOKEN: %s'" pwd))
         (url (code-review-binary-file-url gitlab filename)))
    (code-review-utils--fetch-binary-data url filename headers)))

(cl-defmethod code-review-core-new-issue-comment ((gitlab code-review-gitlab-repo) comment-msg callback)
  "Create a new comment issue for GITLAB sending the COMMENT-MSG and call CALLBACK."
  (glab-post (format "/v4/projects/%s/merge_requests/%s/notes"
                     (code-review-gitlab--project-id gitlab)
                     (oref gitlab number))
             nil
             :auth 'code-review
             :host code-review-gitlab-host
             :payload (a-alist 'body comment-msg)
             :callback callback
             :errorback #'code-review-gitlab-errback))
