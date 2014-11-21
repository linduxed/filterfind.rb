filterfind.rb
=============

Have you ever written something like this before?

```sh
grep -l 'foo' $(grep -l 'bar' $(grep -l 'baz' $(git ls-files)))
```

You're looking for files which match all provided regex-patterns, somewhere in the file.

The command above can be refined to use `xargs` to make it look a bit nicer, but it'd be preferable to just provide a number of regex-patterns to a command and have it figure out the rest.

This is an attempt to do just that.
