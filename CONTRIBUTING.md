# Contributing to Sepomex

Thanks for your interest in improving Sepomex! This guide covers how to get set
up and what we expect from a pull request.

## Getting set up

```bash
git clone git@github.com:IcaliaLabs/sepomex.git
cd sepomex
bundle install
bin/rails db:prepare        # create the SQLite database + load the schema
bin/rake data:loadev        # import the ~154k settlements from the bundled CSV
bin/rails server            # http://localhost:3000
```

See the [README](README.md) for the Docker workflow and more detail.

## Making a change

We use the [roundhouse](https://github.com/kurenn/roundhouse) Rails agent for
feature work — see [CLAUDE.md](CLAUDE.md) — but any workflow is welcome. Whatever
you use:

1. Branch off `main` (`git checkout -b my-change`).
2. Keep the **public REST API contract stable** (root keys + `meta.pagination`).
   It's covered by request specs under `spec/requests`.
3. Add or update tests. Run the suite and the checks locally:

   ```bash
   bundle exec rspec        # tests (aim to keep coverage up)
   bundle exec rubocop      # lint
   bundle exec brakeman     # security scan
   ```

4. Open a PR against `main` with a clear description. CI runs the tests,
   security analysis and lint on every PR.

## Reporting bugs / requesting features

Open an issue using one of the [templates](.github/ISSUE_TEMPLATE). For security
issues, please follow [SECURITY.md](SECURITY.md) instead of opening a public
issue.

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By
participating you agree to uphold it.
