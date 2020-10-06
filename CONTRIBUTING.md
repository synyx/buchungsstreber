# How to contribute

Thanks for reading this, we're glad if this piece of software is useful to you
and you want to add to its value.

## How can I contribute?

### Documentation

The documentation is always in need of help.  Whether you are fixing typos or
wordings or create new documents on how to use the `buchuchungsstreber`,
everything is welcome.

### Code

When you are creating or changing code, it is nice if you also create a test
with `rspec` so the behaviour is documented.

There are `rubocop` rules regarding style, but those are not hard and fast.

### Bugs

If you're already using the software, it is helpful if you report problems
via the GitHub issue tracker.
Before submitting bug reports, have a look at the existing ones.  There
might be one you can comment on.

For reporting, try to:

* add a short descriptive title
* add a way to reproduce the behaviour
* add screenshots if applicable
* add the output of the app with `--debug` enabled

## Styleguides

### Git commits

Try to write somewhat clean changes.  To cite [Tom Lord][tla]:

> #### Using commit Well -- The Idea of a Clean Changeset
>
> When you commit a set of changes, it is generally "best practice" to
> make sure you are creating a clean changeset.
>
> A clean changeset is one that contains only changes that are all
> related and for a single purpose. For example, if you have several
> bugs to fix, or several features to add, try not to mix those changes
> up in a single commit .

[tla]: https://www.gnu.org/software/gnu-arch/tutorial-old/exploring-changesets.html#Exploring_Changesets
