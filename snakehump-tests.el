(ert-deftest snakehump--split-names-t ()
  (should (equal (snakehump--split-name "foo_bar_baz") '("foo" "bar" "baz")))
  (should (equal (snakehump--split-name "foo-bar-baz") '("foo" "bar" "baz")))
  (should (equal (snakehump--split-name "fooBarBaz") '("foo" "bar" "baz")))
  (should (equal (snakehump--split-name "FooBarBaz") '("foo" "bar" "baz")))
  (should (equal (snakehump--split-name "Foo::Bar::Baz") '("foo" "bar" "baz")))
)

;;; Formats
(ert-deftest snakehump-dromcase-t ()
  (should (equal (snakehump-dromcase "foo-bar-baz") "fooBarBaz"))
  (should (equal (snakehump-dromcase "foo-bar")     "fooBar"))
  (should (equal (snakehump-dromcase "foo")         "foo"))
)

(ert-deftest snakehump-camelcase-t ()
  (should (equal (snakehump-camelcase "foo-bar-baz") "FooBarBaz"))
  (should (equal (snakehump-camelcase "foo-bar")     "FooBar"))
  (should (equal (snakehump-camelcase "foo")         "Foo"))
)

(ert-deftest snakehump-snakecase-t ()
  (should (equal (snakehump-snakecase "foo-bar-baz") "foo_bar_baz"))
  (should (equal (snakehump-snakecase "foo-bar")     "foo_bar"))
  (should (equal (snakehump-snakecase "foo")         "foo"))
)

(ert-deftest snakehump-dasherize-t ()
  (should (equal (snakehump-dasherize "foo-bar-baz") "foo-bar-baz"))
  (should (equal (snakehump-dasherize "foo-bar")     "foo-bar"))
  (should (equal (snakehump-dasherize "foo")         "foo"))
)

(ert-deftest snakehump-colonize-t ()
  (should (equal (snakehump-colonize "foo-bar-baz") "Foo::Bar::Baz"))
  (should (equal (snakehump-colonize "foo-bar")     "Foo::Bar"))
  (should (equal (snakehump-colonize "foo")         "Foo"))
)


;;; Predicates
(ert-deftest snakehump-snake-p-t ()
  (should (equal (snakehump-snake-p "foo_bar_baz")   t))
  (should (equal (snakehump-snake-p "foo-bar-baz")   nil))
  (should (equal (snakehump-snake-p "Foo::Bar::Baz") nil))
  (should (equal (snakehump-snake-p "FooBarBaz")     nil))
  (should (equal (snakehump-snake-p "fooBarBaz")     nil))
)

(ert-deftest snakehump-dashed-p-t ()
  (should (equal (snakehump-dashed-p "foo_bar_baz")   nil))
  (should (equal (snakehump-dashed-p "foo-bar-baz")   t))
  (should (equal (snakehump-dashed-p "Foo::Bar::Baz") nil))
  (should (equal (snakehump-dashed-p "FooBarBaz")     nil))
  (should (equal (snakehump-dashed-p "fooBarBaz")     nil))
)

(ert-deftest snakehump-coloned-p-t ()
  (should (equal (snakehump-coloned-p "foo_bar_baz")   nil))
  (should (equal (snakehump-coloned-p "foo-bar-baz")   nil))
  (should (equal (snakehump-coloned-p "Foo::Bar::Baz") t))
  (should (equal (snakehump-coloned-p "FooBarBaz")     nil))
  (should (equal (snakehump-coloned-p "fooBarBaz")     nil))
)

(ert-deftest snakehump-camel-p-t ()
  (should (equal (snakehump-camel-p "foo_bar_baz")   nil))
  (should (equal (snakehump-camel-p "foo-bar-baz")   nil))
  (should (equal (snakehump-camel-p "Foo::Bar::Baz") nil))
  (should (equal (snakehump-camel-p "FooBarBaz")     t))
  (should (equal (snakehump-camel-p "fooBarBaz")     nil))
)

(ert-deftest snakehump-dromedar-p-t ()
  (should (equal (snakehump-dromedar-p "foo_bar_baz")   nil))
  (should (equal (snakehump-dromedar-p "foo-bar-baz")   nil))
  (should (equal (snakehump-dromedar-p "Foo::Bar::Baz") nil))
  (should (equal (snakehump-dromedar-p "FooBarBaz")     nil))
  (should (equal (snakehump-dromedar-p "fooBarBaz")     t))
)


;;; Query
(ert-deftest snakehump-current-format-t ()
  (should (equal (snakehump-current-format "foo_bar_baz")   'snake))
  (should (equal (snakehump-current-format "foo-bar-baz")   'dash))
  (should (equal (snakehump-current-format "Foo::Bar::Baz") 'colon))
  (should (equal (snakehump-current-format "FooBarBaz")     'camel))
  (should (equal (snakehump-current-format "fooBarBaz")     'drom))
)

;; Format
(ert-deftest snakehump-format-t ()
  (should (equal (snakehump-format "foo-bar-baz" 'snake) "foo_bar_baz"))
  (should (equal (snakehump-format "foo-bar-baz" 'dash)  "foo-bar-baz"))
  (should (equal (snakehump-format "foo-bar-baz" 'colon) "Foo::Bar::Baz"))
  (should (equal (snakehump-format "foo-bar-baz" 'camel) "FooBarBaz"))
  (should (equal (snakehump-format "foo-bar-baz" 'drom)  "fooBarBaz"))
)


;;; List / Cycle
(ert-deftest snakehump--list-next-t ()
  (should (equal (snakehump--list-next 'a '(a b c d)) 'b))
  (should (equal (snakehump--list-next 'd '(a b c d)) nil))
)

(ert-deftest snakehump--cycle-next-t ()
  (should (equal (snakehump--cycle-next 'a '(a b c d)) 'b))
  (should (equal (snakehump--cycle-next 'd '(a b c d)) 'a))
  (should (equal (snakehump--cycle-next 'x '(a b c d)) 'a))
)

(ert-deftest snakehump--list-prev-t ()
  (should (equal (snakehump--list-prev 'a '(a b c d)) nil))
  (should (equal (snakehump--list-prev 'd '(a b c d)) 'c))
)

(ert-deftest snakehump--cycle-prev-t ()
  (should (equal (snakehump--cycle-prev 'a '(a b c d)) 'd))
  (should (equal (snakehump--cycle-prev 'd '(a b c d)) 'c))
  (should (equal (snakehump--cycle-prev 'x '(a b c d)) 'd))
)

;;; Next / Prev
(ert-deftest snakehump-current-format-t ()
  (let ((snakehump-hump-cycle '(snake dash colon camel drom)))
    (should (equal (snakehump-next "foo_bar_baz"  ) "foo-bar-baz"  ))
    (should (equal (snakehump-next "foo-bar-baz"  ) "Foo::Bar::Baz"))
    (should (equal (snakehump-next "Foo::Bar::Baz") "FooBarBaz"    ))
    (should (equal (snakehump-next "FooBarBaz"    ) "fooBarBaz"    ))
    (should (equal (snakehump-next "fooBarBaz"    ) "foo_bar_baz"  ))
    )
)

(ert-deftest snakehump-current-format-custom-t ()
  (let ((snakehump-hump-cycle '(drom camel colon dash snake)))
    (should (equal (snakehump-next "fooBarBaz"    ) "FooBarBaz"    ))
    (should (equal (snakehump-next "FooBarBaz"    ) "Foo::Bar::Baz"))
    (should (equal (snakehump-next "Foo::Bar::Baz") "foo-bar-baz"  ))
    (should (equal (snakehump-next "foo-bar-baz"  ) "foo_bar_baz"  ))
    (should (equal (snakehump-next "foo_bar_baz"  ) "fooBarBaz"))
    )
)

(ert-deftest snakehump-xcurrent-format-custom-restrict-t ()
  (let ((snakehump-hump-cycle '(camel dash)))
    (should (equal (snakehump-next "fooBarBaz"    ) "FooBarBaz"))
    (should (equal (snakehump-next "FooBarBaz"    ) "foo-bar-baz"))
    (should (equal (snakehump-next "Foo::Bar::Baz") "FooBarBaz"))
    (should (equal (snakehump-next "foo-bar-baz"  ) "FooBarBaz"))
    (should (equal (snakehump-next "foo_bar_baz"  ) "FooBarBaz"))
    )
)