# RailsBump::Checker

This project is a side project that is required by [RailsBump](https://railsbump.org)

It gathers all the check strategies and it leverages GitHub Actions to calculate compatibility between a Ruby gem and a version of Ruby or Rails.

## Installation

You can test this project like this:

1. `git clone git@github.com:railsbump/checker.git`
2. `bin/setup`
3. `bundle exec rspec spec`

## Usage

For now it can only do this: 

- Check with Bundler: It will generate a `Gemfile` and attempt to `bundle install` with the combination of `dependencies` and `rails_version`

### Check with Bundler

If you want to call this command locally (after following Installation steps):

```
exe/check_bundler.sh --rails_version '6.1.0' --dependencies '{"cronex":"<= 0.13.0","fugit":"~> 1.8","globalid":"<= 1.0.1","sidekiq":"<= 6"}'
```

If you want it to report back to railsbump.org, then you will need to pass the compat_id value:

```
exe/check_bundler.sh --compat_id '999' --rails_version '6.1.0' --dependencies '{"cronex":"<= 0.13.0","fugit":"~> 1.8","globalid":"<= 1.0.1","sidekiq":"<= 6"}'
```

In order to report back to railsbump.org, you will need to have the right RAILS_BUMP_API_KEY in your environment. Otherwise you will see a failed authentication error.

If you want to call this command using GitHub Actions: 

```
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token <SECRET_TOKEN>" \
  https://api.github.com/repos/railsbump/checker/actions/workflows/check_bundler.yml/dispatches \
  -d '{"ref":"main","inputs":{"rails_version":"6.1.0","dependencies":"{\"cronex\":\"<= 0.13.0\",\"fugit\":\"~> 1.8\",\"globalid\":\"<= 1.0.1\",\"sidekiq\":\"<= 6\"}"}}'
```

You will need to specify these values:

- rails_version
- dependencies
- SECRET_TOKEN (from GitHub)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/railsbump/checker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/railsbump/checker/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Railsbump::Checker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/railsbump/checker/blob/master/CODE_OF_CONDUCT.md).
