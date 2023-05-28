
pacman -Sy sbcl
curl -o /tmp/ql.lisp http://beta.quicklisp.org/quicklisp.lisp
sbcl --no-sysinit --no-userinit --load /tmp/ql.lisp \
       --eval '(quicklisp-quickstart:install :path "~/.quicklisp")' \
       --eval '(ql:add-to-init-file)' \
       --quit
sbcl --eval '(ql:quickload :quicklisp-slime-helper)' --quit
# (load (expand-file-name "~/.quicklisp/slime-helper.el"))
# (setq inferior-lisp-program "sbcl")
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install cbindgen --force
cargo install slint-lsp --git https://github.com/slint-ui/slint --force